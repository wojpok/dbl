(* This file is part of DBL, released under MIT license.
 * See LICENSE for details.
 *)

(** Core Language. *)

(* Author: Piotr Polesiuk, 2023 *)

include CorePriv.TypeBase
include CorePriv.Syntax

module Kind = CorePriv.Kind
module Type = CorePriv.Type

let check_well_typed = CorePriv.WellTypedInvariant.check_program