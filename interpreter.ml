(*
Author: Ke Li

Ocaml Interpreter 
*)



open Printf

let explode s =
  List.of_seq (String.to_seq s)

let implode ls =
  String.of_seq (List.to_seq ls)





type 'a parser = Parser of (string -> ('a * string ) list)

type const = 
  I of int
|
  B of bool
|
  S of string
|
  U of unit

exception Wrong of string

let error = ["no error"; "type error"; "too few elements on stack"; "div by 0"]

let rec implode (cs: char list): string =
  match cs with
  | c :: cs -> (String.make 1 c) ^ implode cs
  | [] -> ""

let rec explode (s: string): char list =
  let len = String.length s in
  let rec loop i =
    if i < len then (String.get s i) :: loop (i + 1)
    else []
  in loop 0

let parse p s = 
  match p with 
    Parser f -> f s 

let charP  = 
  Parser (
    fun s ->
      match (explode s) with 
        []->[]
      |
        h::rest->[(h,implode rest)]
  )

let returnP a = 
  Parser 
    (
      fun s -> [a,s]
    )

let failP = 
  Parser
    (
      fun s->[]
    )



let (>>=) p f = 
  Parser (
    fun s ->
      match (parse p s ) with 
        []->[]     (* this is where the parser p has has failed and you make the bind fail as well *)
      |
        (h,rest)::_->  let parser2 = f h in 
        match (parse parser2 rest) with (* you can clean up the 2nd pattern matching significantly *)
          []->[]   (* this is where the parser parser2 has has failed and you make the bind fail as well *)
        |
          (h2,rest2)::_->[(h2,rest2)]
  )

let (<|>) a b = 
  Parser (
    fun s->  match (parse a s) with 
        []-> parse b s 
      |
        r->r
  )

let satcP (c:char)= 
  charP>>=fun x->
  if x=c then returnP c 
  else failP

let consuP (c:char)= 
  charP>>=fun x->
  if x=c then returnP (' ') 
  else failP

let unsatcP c = 
  charP >>= fun x ->
  if not (x = c) then returnP c
  else failP

let satsP s = 
  if s="" then failP else
    let rec asats (s:string)= 
      match (explode s) with 
        h::rest->satcP h >>=fun _->asats (implode rest)
      |
        []-> returnP([])
    in 
    asats (s:string)


let rec many0 p =
  (p >>= fun a -> 
   many0 p >>= fun b-> 
   returnP (a::b))
  <|>
  returnP []


let rec many1 p =
  p >>= fun a -> 
  many0 p >>= fun b-> 
  returnP (a::b)

(*whitespaceP can be cleaned up, it is slightly messy right now *)
let whitespaceP = 
  satcP ' ' <|> satcP '\t' <|> satcP '\n'
let semicolP = 
  satcP ';'
(*digitP can be cleaned up, it is slightly messy right now *)
let digitP = 
  satcP '0' <|> satcP '1' <|> satcP '2' <|> satcP '3' <|> satcP '4' <|> satcP '5' <|> satcP '6'<|> satcP '7' <|> satcP '8' <|> satcP '9'

let natP = 
  (many1 digitP >>= fun a-> 
   returnP ( I (int_of_string (implode a))))

let integerP = 
  (natP)
  <|>
  (satcP '-' >>= fun _->
  (many1 digitP >>= fun a-> 
  returnP ( (int_of_string (implode a)))) >>= fun v -> 
   returnP (I ((-1)*v)) )

let boolP =
  (satsP "<true>" >>= fun _ ->
  returnP (B true))
  <|>
  (satsP "<false>" >>= fun _ ->
  returnP (B false))

let unitP = 
  satsP "<unit>" >>= fun _ ->
  returnP (U ())

let contentP = 
  charP >>= fun a ->
  if not (a = '\"') then returnP a
  else failP

let stringP = 
  (satsP "\"\"" >>= fun _ -> returnP (S (implode ['\"';'\"'])))
  <|>
  (satcP '\"'>>= fun _ ->
   many1 contentP >>= fun s ->
   satcP '\"'>>= fun _ ->
   returnP (S (implode (['\"']@s@['\"']))))
  
let constP = 
  integerP <|> boolP <|> unitP <|> stringP

type command = 
    Push of const 
  |
    Add 
  |
    Pop
  |
    Swap
  |
    Log
  |
    Sub
  |
    Mul
  |
    Div
  |
    Rem
  |
    Neg

let pushP = 
  many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Push" >>= fun _-> 
  many1 whitespaceP >>= fun _->
  constP >>= fun i -> 
  returnP (Push i)

let addP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Add" >>= fun _-> 
  returnP Add

let popP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Pop" >>= fun _-> 
  returnP (Pop)

let swapP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Swap" >>= fun _-> 
  returnP (Swap)

let subP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Sub" >>= fun _-> 
  returnP (Sub)

let mulP = many0 (whitespaceP <|> semicolP) >>= fun _->
satsP "Mul" >>= fun _-> 
returnP (Mul)

let divP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Div" >>= fun _-> 
  returnP (Div)

let remP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Rem" >>= fun _-> 
  returnP (Rem)

let negP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Neg" >>= fun _-> 
  returnP (Neg)

let logP = many0 (whitespaceP <|> semicolP) >>= fun _->
  satsP "Log" >>= fun _-> 
  returnP (Log)

let commandP =
  
  (pushP <|> popP <|> swapP <|> logP <|> addP <|> subP <|> mulP <|> divP <|> remP <|> negP)

let commandsP = 
  many1 commandP

let const_to_string c =
  match c with
    I c -> string_of_int c
  |
    B c -> (match c with
              true -> "<true>"
            |
              false -> "<false>"
    
    )
  |
    S c -> c
  |
    U c -> "<unit>"

let execution cl stack = 
  let rec execute leftcomm curstack output errortype= 
    match leftcomm with
    [] -> (output, 0)
    |
    head::tail -> (match head with 
      Push a -> execute tail (a :: curstack) output 0
      |
      Add -> (match curstack with 
                I a :: I b :: rest -> execute tail ((I (a+b))::rest) output 0
                |
                _ :: _ ::rest -> (output,1)
                |
                _ :: [] -> (output, 2)
                |
                [] -> (output, 2)
          )
      |
      Swap -> (match curstack with 
            top1 :: top2 :: rest -> execute tail (top2::(top1::rest)) output 0
            |
            _::[] ->(output, 2 )
            |
            [] -> (output, 2 )
      )
      |
      Log -> (match curstack with
              top :: rest -> execute tail rest (output@[const_to_string top]) 0
              |
              [] -> (output, 2 )
      )
      |
      Sub ->(match curstack with 
              I a :: I b :: rest -> execute tail ((I (a-b))::rest) output 0
              |
              _::_::rest -> (output, 1 )
              |
              _::[] ->(output, 2 )
              |
              [] ->(output, 2 )
      )
      |
      Mul -> (match curstack with 
              I a :: I b :: rest -> execute tail ((I (a*b))::rest) output 0
              |
              _::_::rest -> (output, 1 )
              |
              _::[] -> (output, 2 )
              |
              [] -> (output, 2 )
        )
      |
      Div ->(match curstack with 
            I a :: I 0 :: rest -> (output, 3 )
            |
            I a :: I b :: rest -> execute tail ((I (a/b))::rest) output 0
            |
            _::_::rest -> (output, 1 )
            |
            _::rest -> (output, 2 )
            |
            [] -> (output, 2 )
      )
      |
      Rem ->(match curstack with 
            I a :: I 0 :: rest -> (output, 3 )
            |
            I a :: I b :: rest -> execute tail ((I (a mod b))::rest) output 0
            |
            _::_::rest -> (output, 1 )
            |
            _::rest -> (output, 2 )
            |
            [] ->  (output, 2 )
      )
      |
      Neg ->(match curstack with
            I a :: rest -> execute tail ((I (a * -1)) :: rest) output 0
            |
            top :: rest -> (output, 1 )
            |
            [] -> (output, 2 )
      )
      |
      Pop ->(match curstack with
            top :: rest -> execute tail rest output 0
            |
            [] -> (output, 2 )
      )
    )
  in execute cl stack [] 0

let interpreter s = 
  match (parse commandsP s) with
    [(a,b)] -> execution a []
    |
    _ -> ([],0)


let readlines (file : string) : string =
  let fp = open_in file in
  let rec loop () =
    match input_line fp with
    | s -> s ^ (loop ())
    | exception End_of_file -> ""
  in
  let res = loop () in
  let () = close_in fp in
  res

let runfile (file : string) : string list * int =
  let s = readlines file in
  interpreter s