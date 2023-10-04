(* This file is part of DBL, released under MIT license.
 * See LICENSE for details.
 *)

(** Core Language. *)

(* Author: Piotr Polesiuk, 2023 *)

(** Type-level constructor of a kind of all types. The main purpose of this
  type is to encode kind-system in OCaml's GADT. Values of this types are
  never used. *)
type ktype = Dummy_Ktype

(** Type-level constructor of a kind of all effects. *)
type keffect = Dummy_Keffect

(** Kinds, self-indexed thanks to GADT *)
type 'k kind =
  | KType : ktype kind
    (** Kind of all types *)

  | KEffect : keffect kind
    (** Kind of all effects *)

(** Type variable, indexed by its kind *)
type 'k tvar

(** Types, indexed by a type-represented kind *)
type _ typ =
  | TUnit : ktype typ
    (** Unit type *)

  | TEffPure : keffect typ
    (** Pure effect *)

  | TEffJoin : effect * effect -> keffect typ
    (** Join of two effects *)

  | TVar  : 'k tvar -> 'k typ
    (** Type variable *)

  | TArrow  : ttype * ttype * effect -> ktype typ
    (** Arrow type *)

  | TForall : 'k tvar * ttype -> ktype typ
    (** Polymorphic type *)

(** Proper types *)
and ttype = ktype typ

(** Effects *)
and effect = keffect typ

(* ========================================================================= *)

(** Variables *)
type var = Var.t

(** Expressions *)
type expr =
  | EValue of value
    (** value *)

  | ELet of var * expr * expr
    (** Let expression *)

  | ELetPure of var * expr * expr
    (** Let expression, that binds pure expression *)

  | EApp of value * value
    (** Function application *)

  | ETApp : value * 'k typ -> expr
    (** Type application *)

  | ERepl of (unit -> expr) * effect
    (** REPL. It is a function that prompts user for another input. It returns
      an expression to evaluate, usually containing another REPL expression.
      The second parameter is an effect of an expression returned by the
      function. *)

  | EReplExpr of expr * string * expr
    (** Print type (second parameter), evaluate and print the first expression,
      then continue to the second expression. *)

(** Values *)
and value =
  | VUnit
    (** Unit value *)

  | VVar of var
    (** Variable *)

  | VFn  of var * ttype * expr
    (** Lambda-abstraction *)

  | VTFun : 'k tvar * expr -> value
    (** Type function *)

(** Program *)
type program = expr

(* ========================================================================= *)
(** Operations on kinds *)
module Kind : sig
  (** Existential version of kind, where its kind index is packed *)
  type ex = Ex : 'k kind -> ex
end

(* ========================================================================= *)
(** Operations on type variables *)
module TVar : sig
  type 'k t = 'k tvar

  (** Create a fresh type variable of given kind *)
  val fresh : 'k kind -> 'k tvar

  (** Create exact copy (with different UID) of a type variable *)
  val clone : 'k tvar -> 'k tvar

  (** Existential version of type variable, where its kind is packed *)
  type ex = Ex : 'k tvar -> ex

  (** Finite maps from type variables *)
  module Map : Map1.S with type 'k key = 'k t
end

(* ========================================================================= *)
(** Operations on types *)
module Type : sig
  (** Get the kind of given type *)
  val kind : 'k typ -> 'k kind

  (** Existential version of type representation, where its kind is packed *)
  type ex = Ex : 'k typ -> ex
end

(* ========================================================================= *)

(** Internal type-checker for Core programs.
  It is used as a sanity check, if implemented transformations preserve
  types. *)
val check_well_typed : program -> unit