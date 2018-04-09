Require Import HOASExamples.
Require Import DBCircuits.
Require Import TypeChecking.
Require Import HOASLib.
Require Import Oracles.
Require Import SemanticLib.
Require Import Symmetric.
Require Import Reversible.
Require Import Matrix.
Require Import Denotation.
Require Import Monad.
Require Import Program.

Require Import List.
Import ListNotations.

Open Scope circ_scope.
Open Scope nat_scope.
Open Scope bexp_scope.

Infix "⊻" := b_xor (at level 40).
Infix "∧" := b_and (at level 40).

Definition nat_to_var (n : nat) : Var := n. 
Coercion b_var : Var >-> bexp. 
Coercion nat_to_var : nat >-> Var.

(*
Input : var 1 : y
        var 2 : x
        var 3 : cin
Output : cout = cin(x ⊕ y) ⊕ xy
*)
Definition adder_cout_bexp : bexp := (3 ∧ (2 ⊻ 1)) ⊻ (2 ∧ 1).

(*
Input : var 0 : y
        var 1 : x
        var 2 : cin
Output : z = cin ⊕ (x ⊕ y)
 *)
Definition adder_z_bexp : bexp := 2 ⊻ (1 ⊻ 0).

(*
Input : var 0 : x
        var 1 : y
Output : z = x ⊕ y
*)
Definition xor_bexp : bexp := 0 ⊻ 1.

(*
Input : var 0 : x
Output : z = x
*)
Definition id_bexp : bexp := 0.

Definition list_to_function {A} (l : list A) (d : A) := fun (n : nat) => nth n l d.
Definition fun_of_bools (l : list bool) := fun n => nth n l false.

Definition bools_to_matrix (l : list bool) : Square (2^(length l)) := 
  big_kron (map bool_to_matrix l).

(*
Fixpoint bools_to_matrix (l : list bool) : Square (2^(length l)) := 
  match l with
  | []      => Id 1
  | b :: bs => (bool_to_matrix b ⊗ bools_to_matrix bs)%M
  end.
*)

Lemma test_adder_cout_bexp_000 : 
⌈ adder_cout_bexp | fun_of_bools [false; false; false; false]⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_001 : 
⌈ adder_cout_bexp | fun_of_bools [false; false; false; true] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_010 : 
⌈ adder_cout_bexp | fun_of_bools [false; false; true; false] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_011 : 
⌈ adder_cout_bexp | fun_of_bools [false; false; true; true] ⌉ = true.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_100 : 
⌈ adder_cout_bexp | fun_of_bools [false; true; false; false] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_101 : 
⌈ adder_cout_bexp | fun_of_bools [false; true; false; true] ⌉ = true.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_110 : 
⌈ adder_cout_bexp | fun_of_bools [false; true; true; false] ⌉ = true.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_cout_bexp_111 : 
⌈ adder_cout_bexp | fun_of_bools [false; true; true; true] ⌉ = true.
Proof. simpl. reflexivity. Qed.

Lemma test_adder_z_bexp_000 : 
⌈ adder_z_bexp | fun_of_bools [false; false; false] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_001 : 
⌈ adder_z_bexp | fun_of_bools [false; false; true] ⌉ = true.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_010 : 
⌈ adder_z_bexp | fun_of_bools [false; true; false] ⌉ = true.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_011 : 
⌈ adder_z_bexp | fun_of_bools [false; true; true] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_100 : 
⌈ adder_z_bexp | fun_of_bools [true; false; false] ⌉ = true.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_101 : 
⌈ adder_z_bexp | fun_of_bools [true; false; true] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_110 : 
⌈ adder_z_bexp | fun_of_bools [true; true; false] ⌉ = false.
Proof. simpl. reflexivity. Qed.
Lemma test_adder_z_bexp_111 : 
⌈ adder_z_bexp | fun_of_bools [true; true; true] ⌉ = true.
Proof. simpl. reflexivity. Qed.

Close Scope bexp_scope.


Definition list_of_Qubits (n : nat) : Ctx := repeat (Some Qubit) n.

Definition adder_cout_circ :=
  compile adder_cout_bexp (list_of_Qubits 4).
Eval compute in adder_cout_circ.

Definition adder_z_circ := compile adder_z_bexp (list_of_Qubits 3).

(* adder_cout circuit with pads, input type is ((4+n) ⨂ Qubit), Box ((5+n) ⨂ Qubit) ((5+n) ⨂ Qubit) *)
Definition adder_cout_circ_with_pads (n : nat) :=
  compile adder_cout_bexp (list_of_Qubits (4+n)).

(* adder_z circuit with pads, input type is ((3+n) ⨂ Qubit), Box ((4+n) ⨂ Qubit) ((4+n) ⨂ Qubit) *)
Definition adder_z_circ_with_pads (n : nat) :=
  compile adder_z_bexp (list_of_Qubits (3+n)).

Definition calc_xor_circ :=
  compile xor_bexp (list_of_Qubits 2).

Definition calc_id_circ := compile id_bexp (list_of_Qubits 1).

Definition calc_id_circ_with_pads (n : nat) := compile id_bexp (list_of_Qubits (1+n)).

Lemma adder_cout_circ_WT : Typed_Box adder_cout_circ.
Proof. apply compile_WT. Qed.
Lemma adder_z_circ_WT : Typed_Box adder_z_circ.
Proof. apply compile_WT. Qed.
Lemma adder_cout_circ_with_pads_WT : forall n,
  Typed_Box (adder_cout_circ_with_pads n).
Proof. intros. apply compile_WT. Qed.
Lemma adder_z_circ_with_pads_WT : forall n,
  Typed_Box (adder_z_circ_with_pads n).
Proof. intros. apply compile_WT. Qed.
Lemma calc_xor_circ_WT : Typed_Box calc_xor_circ.
Proof. apply compile_WT. Qed.
Lemma calc_id_circ_WT : Typed_Box calc_id_circ.
Proof. apply compile_WT. Qed.
Lemma calc_id_circ_with_pads_WT : forall n,
  Typed_Box (calc_id_circ_with_pads n).
Proof. intros. apply compile_WT. Qed.

Open Scope matrix_scope.

Lemma adder_cout_circ_spec : forall (cout z y x cin : bool),
⟦adder_cout_circ⟧ (bool_to_matrix cout ⊗ bools_to_matrix [z; y; x; cin])
= bools_to_matrix ((cout ⊕ ⌈ adder_cout_bexp | fun_of_bools [z; y; x; cin] ⌉) :: [z; y; x; cin]).
Proof.
intros.
apply (compile_correct adder_cout_bexp (list_of_Qubits 4) 
  (fun_of_bools [z; y; x; cin]) cout).
repeat constructor.
Qed.

Lemma adder_z_circ_spec : forall (z y x cin : bool),
⟦adder_z_circ⟧ (bool_to_matrix z ⊗ bools_to_matrix [y; x; cin])
= bool_to_matrix (z ⊕ ⌈ adder_z_bexp | fun_of_bools [y; x; cin]⌉) ⊗ 
  bools_to_matrix [y; x; cin].
Proof.
intros.
apply (compile_correct adder_z_bexp [Some Qubit; Some Qubit; Some Qubit] 
  (fun_of_bools [y; x; cin]) z).
repeat constructor.
Qed.

Lemma adder_cout_circ_with_pads_spec : forall (n : nat) (f : Var -> bool),
⟦adder_cout_circ_with_pads n⟧ ((bool_to_matrix (f 0%nat)) ⊗ (ctx_to_matrix (list_of_Qubits (4+n)) (fun x => f (S x))))
= (bool_to_matrix ((f 0%nat) ⊕ ⌈ adder_cout_bexp | (fun x => f (S x)) ⌉)) ⊗ 
  (ctx_to_matrix (list_of_Qubits (4+n)) (fun x => f (S x))).
Proof.
intros.
apply (compile_correct adder_cout_bexp (list_of_Qubits (4+n)) (fun x => f (S x)) (f 0)).
repeat constructor.
Qed.

Lemma adder_z_circ_with_pads_spec : forall (n : nat) (f : Var -> bool),
⟦adder_z_circ_with_pads n⟧ ((bool_to_matrix (f 0)) ⊗ (ctx_to_matrix (list_of_Qubits (3+n)) (fun x => f (S x))))
= (bool_to_matrix ((f 0) ⊕ ⌈ adder_z_bexp | (fun x => f (S x)) ⌉)) ⊗ 
  (ctx_to_matrix (list_of_Qubits (3+n)) (fun x => f (S x))).
Proof.
intros.
apply (compile_correct adder_z_bexp (list_of_Qubits (3+n)) (fun x => f (S x)) (f 0%nat)).
repeat constructor.
Qed.

Lemma calc_xor_circ_spec : forall (x y r : bool),
⟦calc_xor_circ⟧ (bool_to_matrix r ⊗ bools_to_matrix [x; y])
= bool_to_matrix (r ⊕ ⌈ xor_bexp | fun_of_bools [x; y] ⌉) ⊗ 
  bools_to_matrix [x; y].
Proof.
intros.
apply (compile_correct xor_bexp [Some Qubit; Some Qubit] (fun_of_bools [x; y]) r).
repeat constructor.
Qed.

(* Proof of specification using matrix_denote : failed
Lemma calc_xor_circ_spec_matrix : forall (x y z : bool),
  ⟦xor_circ⟧ ((bool_to_matrix x) ⊗ (bool_to_matrix y) ⊗ (bool_to_matrix z))
  = ((bool_to_matrix x) ⊗ (bool_to_matrix y) ⊗ (bool_to_matrix (x ⊕ y ⊕ z))).
Proof.
  matrix_denote. Msimpl.
  destruct x, y, z; unfold bool_to_ket; simpl; Msimpl; solve_matrix. 
Qed.
*)

(* Should just be bool_to_matrix x *)
Lemma calc_id_circ_spec : forall (x r : bool),
⟦calc_id_circ⟧ (bool_to_matrix r ⊗ bools_to_matrix [x])
= (bool_to_matrix (r ⊕ ⌈ id_bexp | fun_of_bools [x] ⌉)) ⊗ 
  bools_to_matrix [x].
Proof.
intros.
apply (compile_correct id_bexp [Some Qubit] (fun_of_bools [x]) r).
apply (sub_some (Some Qubit) Qubit []).
apply sub_empty.
Qed.

Lemma calc_id_circ_with_pads_spec : forall (n : nat) (f : Var -> bool),
⟦calc_id_circ_with_pads n⟧ ((bool_to_matrix (f 0%nat)) ⊗ (ctx_to_matrix (list_of_Qubits (1+n)) (fun x => f (S x))))
= ((bool_to_matrix (f 0%nat  ⊕ ⌈ id_bexp | (fun x => f (S x)) ⌉)) ⊗ (ctx_to_matrix (list_of_Qubits (1+n)) (fun x => f (S x)))).
Proof.
intros.
apply (compile_correct id_bexp (list_of_Qubits (1+n)) (fun x => f (S x)) (f 0%nat)).
repeat constructor.
Qed.
Close Scope matrix_scope.

(*
Input : (cout, (z, (y, (x, (cin, ())))))
Output : (cout', (z', (y, (x, (cin, ())))))
*)
Definition adder_circ_1 : Box (5 ⨂ Qubit) (5 ⨂ Qubit) := 
  (id_circ ∥ adder_z_circ) ;; adder_cout_circ.

Local Obligation Tactic := program_simpl; try omega.
Program Definition adder_circ_1_with_pads (n : nat) : Box ((5+n) ⨂ Qubit) ((5+n) ⨂ Qubit) := 
  ((@id_circ Qubit) ∥ (adder_z_circ_with_pads n)) ;; 
  (adder_cout_circ_with_pads n).
Next Obligation.
  induction n.
  - reflexivity.
  - simpl. rewrite IHn. reflexivity.
Defined.
Next Obligation.
  induction n.
  - reflexivity.
  - simpl. rewrite IHn. reflexivity.
Defined.

Lemma adder_circ_1_WT : Typed_Box adder_circ_1.
Proof.
  apply inSeq_WT.
  - apply inPar_WT.
    + apply id_circ_WT.
    + apply adder_z_circ_WT.
  - apply adder_cout_circ_WT.
Qed.

Lemma adder_circ_1_with_pads_WT : forall (n : nat),
  Typed_Box (adder_circ_1_with_pads n).
Proof.
  intros.
  unfold adder_circ_1_with_pads. simpl_eq.
  apply inSeq_WT.
  - apply inPar_WT.
    + apply id_circ_WT.
    +apply adder_z_circ_with_pads_WT.
  - apply adder_cout_circ_with_pads_WT.
Qed.

Open Scope matrix_scope.
Lemma adder_circ_1_spec : forall (cin x y z cout : bool),
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [cout; z; y; x; cin]))
  = (ctx_to_matrix 
      (list_of_Qubits 5) 
      (fun_of_bools [cout ⊕ ⌈ adder_cout_bexp | fun_of_bools [z; y; x; cin] ⌉; 
                         z ⊕ ⌈ adder_z_bexp | fun_of_bools [y; x; cin] ⌉; y; x; cin])).
Proof.
  intros.
  unfold adder_circ_1.
  rewrite inSeq_correct.
  - unfold compose_super.
    unfold denote. unfold Denote_Box.
    unfold ctx_to_matrix. simpl.
    rewrite_inPar.
    + remember adder_z_circ_spec as H; clear HeqH.
      unfold bools_to_matrix in H. simpl in H.
      rewrite H. clear H.
      simpl_rewrite id_circ_Id.
      * remember adder_cout_circ_spec as H; clear HeqH.
      unfold bools_to_matrix in H. simpl in H.
        rewrite H. clear H.
        reflexivity.
      * apply WF_bool_to_matrix.
  - apply adder_cout_circ_WT.
  - apply inPar_WT.
    + apply id_circ_WT.
    + apply adder_z_circ_WT.
Qed.

Lemma adder_circ_1_with_pads_spec : forall (n : nat) (f : Var -> bool),
⟦adder_circ_1_with_pads n⟧ (ctx_to_matrix (list_of_Qubits (5+n)) f)
= (bool_to_matrix ((f 0) ⊕ ⌈ adder_cout_bexp | (fun x => f (S x)) ⌉)) ⊗
  ((bool_to_matrix ((f 1) ⊕ ⌈ adder_z_bexp | (fun x => f (S (S x))) ⌉)) ⊗
  (ctx_to_matrix (list_of_Qubits (3+n)) (fun x => f (S (S x))))).
Proof.
  intros.
  unfold adder_circ_1_with_pads.
  Opaque denote. simpl_eq. Transparent denote.
  rewrite inSeq_correct.
  - unfold compose_super.
    unfold denote. unfold Denote_Box.
    unfold ctx_to_matrix. simpl.
    rewrite_inPar.
    + 
      assert (H1 : forall n f, length (ctx_to_mat_list (list_of_Qubits n) f) = 
                          size_ctx (list_of_Qubits n)).
      { induction n0.
        - easy.
        - intros. simpl. rewrite IHn0. easy. }
      remember adder_z_circ_with_pads_spec as H; clear HeqH.
      specialize (H n%nat (fun (x : Var) => f (S x))).
      unfold ctx_to_matrix in H.
      simpl in *. unfold kron at 5.
      unfold kron in H at 4.
      rewrite H1 in H. unfold list_of_Qubits in H.
      rewrite H.
      clear H1 H.
      simpl_rewrite id_circ_Id.
      * 
        assert (H1 : forall n f, length (ctx_to_mat_list (list_of_Qubits n) f) = size_ctx (list_of_Qubits n)).
        { induction n0.
          - reflexivity.
          - intros. simpl. rewrite IHn0. reflexivity. }
        remember adder_cout_circ_with_pads_spec as H; clear HeqH.
        specialize (H n%nat (fun (x : Var) => match x with
                                              | S O => f 1%nat ⊕ (f 4%nat ⊕ (f 3%nat ⊕ f 2%nat))
                                              | _ => f x
                                              end)).
        unfold ctx_to_matrix in H. simpl in H.
        simpl in *. unfold kron at 5.
        unfold kron in H at 5.
        rewrite H1 in H. unfold list_of_Qubits in H.
        apply H.
      * apply WF_bool_to_matrix.
  - apply adder_cout_circ_with_pads_WT.
  - apply inPar_WT.
    + apply id_circ_WT.
    + apply adder_z_circ_with_pads_WT.
Qed.
Close Scope matrix_scope.

Lemma adder_circ_1_test_000 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; false; false; false]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false ; false; false; false])).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_001 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; false; false; true]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; true ; false; false; true])).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_010 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; false; true; false]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; true ; false; true; false] )).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_011 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; false; true; true]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [true; false ; false; true; true] )).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_100 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; true; false; false]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; true ; true; false; false] )).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_101 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; true; false; true]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [true; false ; true; false; true] )).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_110 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; true; true; false]))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [true; false ; true; true; false] )).
Proof. apply adder_circ_1_spec. Qed.
Lemma adder_circ_1_test_111 :
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [false; false; true; true; true] ))
  = (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [true; true ; true; true; true] )).
Proof. apply adder_circ_1_spec. Qed.

(*
Input : (cout, (z1, (y1, (x1, (z2, (y2, (x2, ... , (zn, (yn, (xn, (cin, ())))))))))))
Output : (cout', (z1', (y1, (x1, (z2', (y2, (x2, ... , (zn', (yn, (xn, (cin, ())))))))))))
*)

(* This can be refactored using init_at *)
Program Fixpoint adder_circ_n (n : nat) : Box ((2+n+n+n) ⨂ Qubit) ((2+n+n+n) ⨂ Qubit) := 
  match n with
  | O => calc_id_circ
  | S n' => ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ (strip_one_l_in (init0 ∥ (inParMany (1+n'+n'+n') (@id_circ Qubit)))))))) ;; 
            ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((adder_circ_n n')))))) ;; 
            (adder_circ_1_with_pads (1+n'+n'+n')) ;;
            ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ ((@id_circ Qubit) ∥ (strip_one_l_out (assert0 ∥ (inParMany (1+n'+n'+n') (@id_circ Qubit))))))))
  end.
Next Obligation.
  replace (n' + S n' + S n')%nat with (2 + n' + n' + n')%nat by omega.
  simpl. reflexivity.
Defined.
Next Obligation.
  replace (n' + S n' + S n')%nat with (2 + n' + n' + n')%nat by omega.
  simpl. reflexivity.
Defined.

Lemma adder_circ_n_WT : forall (n : nat),
  Typed_Box (adder_circ_n n).
Proof.
  intros. induction n.
  - unfold adder_circ_n. unfold calc_id_circ.
    simpl. apply (Symmetric.CNOT_at_WT 2 1 0).
  - unfold adder_circ_n. simpl_eq.
    apply inSeq_WT.
    + compile_typing True. apply inParMany_WT. apply id_circ_WT.
    + apply inSeq_WT.
      * compile_typing True. unfold adder_circ_n in IHn.
        program_simpl.
      * apply inSeq_WT.
        { apply (adder_circ_1_with_pads_WT (S (n + n + n))). }
        { compile_typing True. apply inParMany_WT. apply id_circ_WT. }
Qed.

(* For n-adder specification *)
Fixpoint n_adder_cout_bexp (n m : nat) : bexp :=
  match m with
  | O => b_var (1+n+n+n)%nat (* cin = b_var (1+n+n+n)%nat *)
  | S m' => let i := (n-m)%nat in
            b_xor (b_and (n_adder_cout_bexp n m') (b_xor (b_var (3+i+i+i)%nat) (b_var (2+i+i+i)%nat))) (b_and (b_var (3+i+i+i)%nat) (b_var (2+i+i+i)%nat))
             (* cin = n_adder_cout_bexp n m'
                x = b_var (3+i+i+i)%nat
                y = b_var (2+i+i+i)%nat *)
  end.

Eval simpl in n_adder_cout_bexp 3 3.
Eval simpl in n_adder_cout_bexp 3 2.
Eval simpl in n_adder_cout_bexp 3 1.
Eval simpl in n_adder_cout_bexp 3 0.

Definition n_adder_z_bexp (n m : nat) : bexp :=
  match m with
  | O => b_var (1+n+n+n)%nat (* cin = b_var (1+n+n+n)%nat *)
  | S m' => let i := (n-m)%nat in
            b_xor (n_adder_cout_bexp n m') (b_xor (b_var (3+i+i+i)%nat) (b_var (2+i+i+i)%nat))
             (* cin = n_adder_cout_bexp n m'
                x = b_var (3+i+i+i)%nat
                y = b_var (2+i+i+i)%nat *)
  end.

Eval simpl in n_adder_z_bexp 3 3.
Eval simpl in n_adder_z_bexp 3 2.
Eval simpl in n_adder_z_bexp 3 1.
Eval simpl in n_adder_z_bexp 3 0.

Fixpoint increase_vars_by (k : nat) (b : bexp) : bexp :=
  match b with
  | b_t   => b_t
  | b_f   => b_f
  | b_var x => b_var (k + x)%nat
  | b_not b' => b_not (increase_vars_by k b')
  | b_and b1 b2 => b_and (increase_vars_by k b1) (increase_vars_by k b2)
  | b_xor b1 b2 => b_xor (increase_vars_by k b1) (increase_vars_by k b2)
  end.

Lemma bexp_interpret_equiv_1 : forall (k : nat) (b : bexp) (f : Var -> bool),
    ⌈ b | fun x : Var => f (k + x)%nat ⌉
    = ⌈ increase_vars_by k b | f ⌉.
Proof.
  induction b.
  - intros. simpl. reflexivity.
  - intros. simpl. reflexivity.
  - intros. simpl. reflexivity.
  - intros. simpl. rewrite IHb. reflexivity.
  - intros. simpl. rewrite IHb1. rewrite IHb2. reflexivity.
  - intros. simpl. rewrite IHb1. rewrite IHb2. reflexivity.
Qed.

Lemma n_adder_cout_bexp_equiv_1 : forall (n m : nat),
    (m <= n)%nat ->
    increase_vars_by 3%nat (n_adder_cout_bexp n m) = n_adder_cout_bexp (S n) m.
Proof.
  intros. generalize dependent n.
  induction m.
  - intros. simpl. replace (n + S n + S n)%nat with (2 + n + n + n)%nat by omega.
    reflexivity.
  - intros. simpl. rewrite IHm.
    remember (n - S m)%nat as i.
    replace (n - m)%nat with (1 + i)%nat by omega. simpl.
    replace (i + S i + S i)%nat with (2 + i + i + i)%nat by omega. simpl.
    reflexivity.
    omega.
Qed.

Lemma n_adder_z_bexp_equiv_1 : forall (n m : nat),
    (m <= n)%nat ->
    increase_vars_by 3%nat (n_adder_z_bexp n m) = n_adder_z_bexp (S n) m.
Proof.
  intros. generalize dependent n.
  induction m.
  - intros. simpl. replace (n + S n + S n)%nat with (2 + n + n + n)%nat by omega.
    reflexivity.
  - intros. simpl. rewrite n_adder_cout_bexp_equiv_1.
    remember (n - S m)%nat as i.
    replace (n - m)%nat with (1 + i)%nat by omega. simpl.
    replace (i + S i + S i)%nat with (2 + i + i + i)%nat by omega. simpl.
    reflexivity.
    omega.
Qed.

Fixpoint n_adder_z_compute (n m : nat) (f : Var -> bool) : (Var -> bool) :=
  match m with
  | O => f
  | S m' => let i := (n-m)%nat in
            fun x => (if x =? (1+i+i+i)%nat then
                        ((n_adder_z_compute n m' f) x)
                        ⊕ ⌈ n_adder_z_bexp n m | (n_adder_z_compute n m' f) ⌉
                     else
                       ((n_adder_z_compute n m' f) x))
  end.

Definition n_adder_cout_compute (n : nat) (f : Var -> bool) : (Var -> bool) :=
  fun x => match x with
           | O => (f 0%nat) ⊕ ⌈ n_adder_cout_bexp n n | f ⌉
           | S x' => f (S x')
           end.

Eval compute in (n_adder_z_compute 2 2 (fun_of_bools [false; false ; true; true; false; true; true; false])) 1%nat.
Eval compute in (n_adder_z_compute 3 3 (fun_of_bools [false; false ; true; true; false; true; true; false; true; true; true])).
Eval compute in (n_adder_cout_compute 3 (fun_of_bools [false; false ; true; true; false; true; true; false; true; true; true])).
Eval compute in (n_adder_cout_compute 3 (n_adder_z_compute 3 3 (fun_of_bools [false; false ; true; true; false; true; true; false; true; true; true]))).

Open Scope matrix_scope.
Open Scope nat_scope.

Lemma mixed_state_big_kron_ctx_to_mat_list : forall n f,  Mixed_State (⨂ ctx_to_mat_list (list_of_Qubits n) f).
Proof.
  induction n.
  - intros. simpl. show_mixed.
  - intros. simpl.
    specialize (mixed_kron 2) as H. apply H.
    + show_mixed.
    + apply IHn.
Qed.
Lemma dim_eq_lemma_1 : forall n, (size_ctx (list_of_Qubits n )) = n.
Proof.
  induction n.
  - reflexivity.
  - simpl. rewrite IHn. reflexivity.
Qed.
Lemma dim_eq_lemma_2 : forall n f,
    @length (Square 2) (ctx_to_mat_list (list_of_Qubits n) f) = n.
Proof.
  induction n.
  - reflexivity.
  - intros. simpl. rewrite IHn. reflexivity.
Qed.
Lemma dim_eq_lemma_3 : forall n, size_wtype (NTensor n Qubit) = n.
Proof.
  induction n.
  - reflexivity.
  - simpl. rewrite IHn. reflexivity.
Qed.
Lemma kron_eq_1 : forall {m n o p} m11 m12 m21 m22,
                 m11 = m21 -> m12 = m22 -> @kron m n o p m11 m12 = @kron m n o p m21 m22.
  intros. rewrite H. rewrite H0. reflexivity.
Qed.
Lemma big_kron_eq_1 : forall n f1 f2,
    (forall x, f1 x = f2 x) ->
    ⨂ ctx_to_mat_list (list_of_Qubits n) f1 = ⨂ ctx_to_mat_list (list_of_Qubits n) f2.
Proof.
  induction n.
  - intros. simpl. reflexivity.
  - intros. simpl. rewrite (IHn (fun v : Var => f1 (S v)) (fun v : Var => f2 (S v))).
    rewrite H. show_dimensions. rewrite dim_eq_lemma_2. rewrite dim_eq_lemma_2. reflexivity.
    intros. rewrite H. reflexivity.
Qed.
Lemma ctx_to_matrix_eq_1 : forall n f1 f2,
    (forall x, f1 x = f2 x) ->
    ctx_to_matrix (list_of_Qubits n) f1 = ctx_to_matrix (list_of_Qubits n) f2.
Proof.
  induction n.
  - intros. matrix_denote. solve_matrix.
  - intros.
    specialize (IHn (fun v : Var => f1 (S v)) (fun v : Var => f2 (S v))).
    unfold ctx_to_matrix in *.
    unfold big_kron in *. simpl in *.
    show_dimensions.
    rewrite dim_eq_lemma_2.
    rewrite dim_eq_lemma_2.
    apply kron_eq_1.
    + rewrite H. reflexivity.
    + apply IHn. intros. apply H.
Qed.
Lemma mod_3_0 : forall n, (n + n + n) mod 3 = 0.
Proof.
  induction n.
  - reflexivity.
  - assert (forall n x, snd (Nat.divmod (n+n+n) 2 x 2) = snd (Nat.divmod (n+n+n) 2 (S x) 2)).
    { induction n0.
      - intros. simpl. reflexivity.
      - intros. replace (S n0 + S n0 + S n0) with (3 + n0 + n0 + n0) by omega.
        simpl. apply IHn0. }
    replace (S n + S n + S n) with (3 + n + n + n) by omega.
    simpl. rewrite <- H. apply IHn.
Qed.
Lemma mod_3_1 : forall n, (n + n + n + 1) mod 3 = 1.
Proof.
  induction n.
  - intros. simpl. reflexivity.
  - simpl. simpl. replace (n + S n + S n + 1) with (2 + n + n + n + 1) by omega.
    assert (forall n x, snd (Nat.divmod (n+n+n+1) 2 x 2) = snd (Nat.divmod (n+n+n+1) 2 (S x) 2)).
    { induction n0.
      - intros. simpl. reflexivity.
      - intros. replace (S n0 + S n0 + S n0) with (3 + n0 + n0 + n0) by omega.
        simpl. apply IHn0. }
    simpl. rewrite <- H. apply IHn.
Qed.
Lemma mod_3_2 : forall n, (n + n + n + 2) mod 3 = 2.
Proof.
  induction n.
  - intros. simpl. reflexivity.
  - simpl. simpl. replace (n + S n + S n + 2) with (2 + n + n + n + 2) by omega.
    assert (forall n x, snd (Nat.divmod (n+n+n+2) 2 x 2) = snd (Nat.divmod (n+n+n+2) 2 (S x) 2)).
    { induction n0.
      - intros. simpl. reflexivity.
      - intros. replace (S n0 + S n0 + S n0) with (3 + n0 + n0 + n0) by omega.
        simpl. apply IHn0. }
    simpl. rewrite <- H. apply IHn.
Qed.
Lemma n_adder_z_compute_preserve : forall (n m : nat) (f : Var -> bool),
    m <= n -> forall x, (x mod 3) <> 1 -> (n_adder_z_compute n m f x) = (f x).
Proof.
  intros n m. generalize dependent n. induction m.
  - intros. simpl. reflexivity.
  - intros. simpl. remember (n - S m) as i.
    destruct (x =? S (i + i + i)) eqn:Hb.
    + apply beq_nat_true in Hb. rewrite Hb in *.
      replace (S (i + i + i)) with (i + i + i + 1) in H0 by omega.
      rewrite mod_3_1 in H0. exfalso. apply H0. reflexivity.
    + apply IHm. apply le_Sn_le. apply H. apply H0.
Qed.
Lemma n_adder_cout_interpret_equiv_1 : forall n m f1 f2,
    (forall x, x > 0 -> f1 x = f2 x) ->
    ⌈ n_adder_cout_bexp n m | f1 ⌉ = ⌈ n_adder_cout_bexp n m | f2 ⌉.
Proof.
  intros n m. generalize dependent n. induction m.
  - intros. simpl. apply H. apply gt_Sn_O.
  - intros. simpl. remember (n - S m) as i. destruct i.
    + simpl. rewrite IHm with (f1:=f1) (f2:=f2).
      replace (f2 2) with (f1 2) by (apply H; apply gt_Sn_O).
      replace (f2 3) with (f1 3) by (apply H; apply gt_Sn_O).
      reflexivity. apply H.
    + simpl. rewrite IHm with (f1:=f1) (f2:=f2).
      replace (f2 (S (S (S (S (i + S i + S i)))))) with
          (f1 (S (S (S (S (i + S i + S i)))))) by (apply H; apply gt_Sn_O).
      replace (f2 (S (S (S (i + S i + S i))))) with
          (f1 (S (S (S (i + S i + S i))))) by (apply H; apply gt_Sn_O).
      reflexivity. apply H.
Qed.
Lemma n_adder_z_compute_equiv_1 : forall (n m : nat) (f : Var -> bool),
    m <= n ->
    n_adder_z_compute n m (fun x => f (3+x))
    = (fun x => (n_adder_z_compute (S n) m f) (3+x)).
Proof.
  intros n m. generalize dependent n. induction m.
  - intros. simpl. reflexivity.
  - intros. simpl. repeat rewrite IHm.
    rewrite <- n_adder_cout_bexp_equiv_1.
    rewrite <- bexp_interpret_equiv_1.
    remember (n - S m) as i.
    replace (n - m) with (S i). simpl.
    replace (i + S i + S i) with (2 + i + i + i) by omega. simpl. reflexivity.
    omega. omega. omega.
Qed.
Lemma n_adder_z_compute_equiv_2 : forall (n m : nat) (f1 f2 : Var -> bool),
    m <= n -> f1 = (fun x => f2 (3+x)) ->
    (n_adder_z_compute n m f1)
    = (fun x => ((n_adder_z_compute (S n) m f2) (3+x))).
Proof.
  intros n m. generalize dependent n. induction m.
  - intros. simpl. rewrite H0. reflexivity.
  - intros. simpl. remember (n - S m) as i.
    replace (n - m) with (1 + i) by omega. simpl.
    replace (i + S i + S i) with (2 + i + i + i) by omega. simpl.
    repeat rewrite IHm with (f1:=f1) (f2:=f2). simpl.
    rewrite <- n_adder_cout_bexp_equiv_1.
    rewrite <- bexp_interpret_equiv_1. reflexivity.
    omega. omega. apply H0.
Qed.
Lemma n_adder_z_compute_equiv_3 : forall n m f1 f2,
    m <= n ->
    (forall x, x > 0 -> f1 x = f2 (3 + x)) ->
    forall x, x > 0 -> n_adder_z_compute n m f1 x =
                       n_adder_z_compute n m (fun x0 : nat => f2 (3 + x0)) x.
Proof.
  induction m.
  - intros. simpl. rewrite H0. reflexivity. apply H1.
  - intros. simpl. remember (n - S m) as i.
    rewrite (IHm f1 f2).
    rewrite n_adder_cout_interpret_equiv_1 with (f1:=n_adder_z_compute n m f1)
                    (f2:=n_adder_z_compute n m (fun x0 : nat => f2 (3+x0))).
    rewrite (n_adder_z_compute_preserve n m f1). simpl.
    rewrite (n_adder_z_compute_preserve n m f1). simpl.
    destruct (x =? S (i + i + i)) eqn:Heqx.
    + remember (n_adder_z_compute n m (fun x0 : nat => f2 (S (S (S x0)))) x).
      rewrite (n_adder_z_compute_preserve n m (fun x0 : nat => f2 (3+x0))).
      rewrite (n_adder_z_compute_preserve n m (fun x0 : nat => f2 (3+x0))).
      rewrite H0. rewrite H0. simpl. reflexivity.
      all: try replace (S (S (i + i + i))) with (i + i + i + 2) by omega;
        try replace (S (S (S (i + i + i)))) with (S i + S i + S i) by omega;
        try replace (S (i + i + i + 2)) with (S i + S i + S i) by omega;
        try rewrite mod_3_2; try rewrite mod_3_3; try rewrite mod_3_0; try omega.
    + reflexivity.
    + omega.
    + replace (S (S (i + i + i))) with (i + i + i + 2) by omega.
      rewrite mod_3_2. omega.
    + omega.
    + replace (S (S (S (i + i + i)))) with (S i + S i + S i) by omega.
      rewrite mod_3_0. omega.
    + intros. rewrite (IHm f1 f2). reflexivity. omega. apply H0. omega.
    + omega.
    + apply H0.
    + omega.
Qed.

Lemma adder_circ_n_spec : forall (n : nat) (f : Var -> bool),
⟦adder_circ_n n⟧ (ctx_to_matrix (list_of_Qubits (2+n+n+n)) f)
= (ctx_to_matrix (list_of_Qubits (2+n+n+n)) (n_adder_cout_compute n (n_adder_z_compute n n f))).
Proof.
  induction n.
  - intros.
    remember (calc_id_circ_spec (f 1%nat) (f 0%nat)).
    simpl in *. unfold ctx_to_matrix in *.
    unfold big_kron in *. simpl in *. apply e.
  - intros.
    Opaque denote. simpl_eq. Transparent denote.
    specialize inSeq_correct as IS. simpl in IS.
    simpl. repeat (rewrite IS; compile_typing (compile_WT)). clear IS.
    unfold compose_super.
    replace (n + S n + S n)%nat with (2 + n + n + n)%nat by omega.
    unfold ctx_to_matrix at 1. simpl.
    Set Printing Implicit.
    show_dimensions.
    rewrite dim_eq_lemma_2. (* simplify dimension of matrices *)
    specialize (inPar_correct Qubit Qubit (NTensor (4+n+n+n) Qubit) (NTensor (5+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (3+n+n+n) Qubit) (NTensor (4+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (2+n+n+n) Qubit) (NTensor (3+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (1+n+n+n) Qubit) (NTensor (2+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    rewrite strip_one_l_in_eq.
    assert (Hkron1 : kron' 2 2 (2 ^ (n+n+n)) (2 ^ (n+n+n)) (bool_to_matrix (f 4))
                           (⨂ ctx_to_mat_list (list_of_Qubits (n+n+n))
                              (fun v : Var => f (S (S (S (S (S v))))))) =
                     (Id 1) ⊗ (kron' 2 2 (2 ^ (n+n+n)) (2 ^ (n+n+n)) (bool_to_matrix (f 4))
                                     (⨂ ctx_to_mat_list (list_of_Qubits (n+n+n))
                                        (fun v : Var => f (S (S (S (S (S v))))))))).
    { rewrite kron_1_l.
      - reflexivity.
      - apply WF_kron; try reflexivity.
        + apply WF_bool_to_matrix.
        + specialize (WF_ctx_to_matrix (list_of_Qubits (n+n+n)) (fun v : Var => f (S (S (S (S (S v))))))) as HWF.
          unfold ctx_to_matrix in HWF. rewrite dim_eq_lemma_1 in HWF. apply HWF. }
    rewrite Hkron1. clear Hkron1.
    specialize (inPar_correct One Qubit (NTensor (1+n+n+n) Qubit) (NTensor (1+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (n+n+n) Qubit) (NTensor (n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    remember id_circ_Id. simpl in e. repeat rewrite e. clear e Heqe.
    remember init0_spec. simpl in e. rewrite e. clear e Heqe.
    assert (inParMany_correct : forall n f, denote_box true (inParMany n (@id_circ Qubit)) (⨂ ctx_to_mat_list (list_of_Qubits (n)) f)%M = (⨂ ctx_to_mat_list (list_of_Qubits (n)) f)%M).
    { induction n0.
      - intros. simpl. remember id_circ_Id. simpl in e. rewrite e. reflexivity.
        apply WF_I1.
      - intros. simpl. show_dimensions. rewrite dim_eq_lemma_2.
        specialize (inPar_correct Qubit Qubit (NTensor n0 Qubit) (NTensor n0 Qubit)) as IP.
        rewrite dim_eq_lemma_3 in IP. simpl in IP. rewrite IP.
        rewrite IHn0. remember id_circ_Id. simpl in e. rewrite e. reflexivity.
        + simpl. apply WF_bool_to_matrix.
        + apply id_circ_WT.
        + apply inParMany_WT. apply id_circ_WT.
        + show_mixed.
        + specialize (mixed_state_big_kron_ctx_to_mat_list n0 (fun v : Var => f0 (S v)))
            as Hmixed. rewrite dim_eq_lemma_2 in Hmixed. apply Hmixed. }
    rewrite inParMany_correct.
    
    show_dimensions. simpl. rewrite dim_eq_lemma_3.
    specialize (inPar_correct Qubit Qubit (NTensor (5+n+n+n) Qubit) (NTensor (5+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (4+n+n+n) Qubit) (NTensor (4+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (3+n+n+n) Qubit) (NTensor (3+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (2+n+n+n) Qubit) (NTensor (2+n+n+n) Qubit)) as IP.
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    remember id_circ_Id. simpl in e. repeat rewrite e. clear e Heqe.
    unfold ctx_to_matrix in IHn. simpl in IHn.
    specialize (IHn (fun x => match x with
                              | 0 => false
                              | x => (f (3+x))
                              end)).
    show_dimensions. rewrite dim_eq_lemma_2 in IHn. (* simplify dimension of matrices *)
    simpl in *. replace (Mmult' 2 1 2 |0⟩ ⟨0|) with (|0⟩⟨0|). rewrite IHn.
    hide_dimensions. clear IHn.
    specialize (adder_circ_1_with_pads_spec (S (n + n + n))
                                            (fun x => match x with
                                                      | 0 => f 0
                                                      | 1 => f 1
                                                      | 2 => f 2
                                                      | 3 => f 3
                                                      | 4 => (n_adder_z_compute n n
                                                             (fun x : Var =>
                                                                match x with
                                                                | 0 => false
                                                                | x => f (3+x)
                                                                end) 0
                                                             ⊕ ⌈ n_adder_cout_bexp n n
                                                             | n_adder_z_compute n n
                                                               (fun x : Var =>
                                                                  match x with
                                                                  | 0 => false
                                                                  | _ => f (3+x)
                                                                  end) ⌉)
                                                      | x => (n_adder_z_compute n n
                                                             (fun x : Var =>
                                                                match x with
                                                                | 0 => false
                                                                | S _ => f (3+x)
                                                                end) (x-4))
                                                      end)) as I1.
    unfold ctx_to_matrix in I1. simpl in *.
    show_dimensions. rewrite dim_eq_lemma_2 in *. (* simplify dimension of matrices *)
    rewrite I1. hide_dimensions. clear I1.

    show_dimensions. rewrite dim_eq_lemma_1. hide_dimensions.
    specialize (inPar_correct Qubit Qubit (NTensor (5+n+n+n) Qubit) (NTensor (4+n+n+n) Qubit)) as IP. 
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (4+n+n+n) Qubit) (NTensor (3+n+n+n) Qubit)) as IP. 
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (3+n+n+n) Qubit) (NTensor (2+n+n+n) Qubit)) as IP. 
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (2+n+n+n) Qubit) (NTensor (1+n+n+n) Qubit)) as IP. 
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    rewrite strip_one_l_out_eq.
    specialize (inPar_correct Qubit One (NTensor (1+n+n+n) Qubit) (NTensor (1+n+n+n) Qubit)) as IP. 
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    specialize (inPar_correct Qubit Qubit (NTensor (n+n+n) Qubit) (NTensor (n+n+n) Qubit)) as IP. 
    rewrite dim_eq_lemma_3 in IP. (* simplify dimension of boxes *)
    rewrite IP. clear IP.
    remember id_circ_Id. simpl in e. repeat rewrite e. clear e Heqe.
    remember inSeq_correct. simpl in e. rewrite e. unfold compose_super. clear e Heqe.
    rewrite inParMany_correct. clear inParMany_correct.
    assert (meas_spec : forall b, ⟦boxed_gate meas⟧ (bool_to_matrix b) = bool_to_matrix b).
    { destruct b; matrix_denote; Msimpl; solve_matrix. }
    simpl in meas_spec. rewrite meas_spec. clear meas_spec.
    assert (discard_spec : forall b, ⟦boxed_gate discard⟧ (bool_to_matrix b) = Id 1).
    { destruct b; matrix_denote; Msimpl; solve_matrix;
        rewrite Nat.ltb_compare; simpl; rewrite andb_false_r; reflexivity. }
    simpl in discard_spec. rewrite discard_spec. clear discard_spec.

    all: repeat (try apply inParMany_WT; try apply inSeq_WT; try apply inPar_WT;
                 try apply boxed_gate_WT; try apply id_circ_WT;
                 try apply strip_one_l_out_WT; try apply strip_one_l_in_WT).
    all: repeat (try apply adder_circ_n_WT).
    all: repeat try apply (adder_circ_1_with_pads_WT (S (n + n + n))).
    all: repeat (try apply WF_bool_to_matrix).
    all: remember (fun x : Var => match x with
                                  | 0 => false
                                  | S _ => f (S (S (S x)))
                                  end) as f'.
    all: repeat (try apply (mixed_kron 2); try apply mixed_big_kron; try show_mixed).
    all: specialize (mixed_state_big_kron_ctx_to_mat_list
                  (n+n+n) (fun v : Var => f (S (S (S (S (S v))))))) as Hmixed1.
    all: specialize (mixed_state_big_kron_ctx_to_mat_list
                  (n+n+n) (fun v : Var => n_adder_z_compute n n f' (S (S v)))) as Hmixed2.
    all: rewrite dim_eq_lemma_2 in Hmixed1; rewrite dim_eq_lemma_2 in Hmixed2.
    all: repeat (try apply Hmixed1; try apply Hmixed2).
    all: clear Hmixed1 Hmixed2.
    all: hide_dimensions; try reflexivity.

    + unfold ctx_to_matrix. simpl.
      replace (n - n) with (0) by omega. simpl.
      assert (L1 : forall n m f, n_adder_z_compute n m f 0 = f 0).
      { intros. induction m.
        - simpl. reflexivity.
        - simpl. remember (n0 - S m + (n0 - S m) + (n0 - S m)). apply IHm. }
      assert (L2 : forall n m f, n_adder_z_compute n m f 2 = f 2).
      { intros. induction m.
        - simpl. reflexivity.
        - simpl. remember (n0 - S m) as n1. destruct n1.
          + simpl. rewrite IHm. destruct (f0 2); reflexivity.
          + simpl. replace (n1 + S n1 + S n1 + 1) with (3 + n1 + n1 + n1) by omega.
            simpl. rewrite IHm. replace (n1 + S n1 + S n1) with (2 + n1 + n1 + n1) by omega.
            destruct (f0 2); reflexivity. }
      assert (L3 : forall n m f, n_adder_z_compute n m f 3 = f 3).
      { intros. induction m.
        - simpl. reflexivity.
        - simpl. remember (n0 - S m) as n1. destruct n1.
          + simpl. rewrite IHm. destruct (f0 3); reflexivity.
          + simpl. replace (n1 + S n1 + S n1 + 1) with (3 + n1 + n1 + n1) by omega.
            simpl. rewrite IHm. replace (n1 + S n1 + S n1) with (2 + n1 + n1 + n1) by omega.
            destruct (f0 2); reflexivity. }
      rewrite L1. rewrite L2. rewrite L3. rewrite L1.
      show_dimensions. rewrite dim_eq_lemma_2. rewrite dim_eq_lemma_3.
      assert (Hb : forall (b : bool), (if b then true else false) = b).
      { destruct b; reflexivity. }
      repeat (apply kron_eq_1). repeat rewrite Hb.
      * replace (f' 0) with false by (rewrite Heqf'; reflexivity). rewrite xorb_false_l.
        rewrite <- n_adder_cout_bexp_equiv_1.
        rewrite <- bexp_interpret_equiv_1.
        simpl. rewrite <- n_adder_z_compute_equiv_2 with (f1:=(fun x => f (3+x))) (f2:=f).
        replace (⌈ n_adder_cout_bexp n n | n_adder_z_compute n n (fun x : nat => f (3 + x)) ⌉)
          with (⌈ n_adder_cout_bexp n n | n_adder_z_compute n n f' ⌉). reflexivity.
        apply n_adder_cout_interpret_equiv_1. intros.
        apply n_adder_z_compute_equiv_3.
        omega. destruct x0. intro H0; inversion H0. rewrite Heqf'. reflexivity.
        omega. omega. reflexivity. omega.
      * replace (f' 0) with false by (rewrite Heqf'; reflexivity). rewrite xorb_false_l.
        rewrite <- n_adder_cout_bexp_equiv_1.
        rewrite <- bexp_interpret_equiv_1.
        rewrite n_adder_cout_interpret_equiv_1 with (f1:=n_adder_z_compute n n f')
                        (f2:=fun x : Var => n_adder_z_compute (S n) n f (3 + x)).
        replace (n_adder_z_compute (S n) n f 1) with (f 1).
        reflexivity.
        {  assert (forall n m, m < n -> n_adder_z_compute n m f 1 = f 1).
           { intros n0 m. generalize dependent n0. induction m.
             - intros. simpl. reflexivity.
             - intros. simpl. apply lt_minus_O_lt in H. remember (n0 - S m) as i.
               destruct i eqn:Hi. inversion H.
               simpl. apply IHm.
               simpl in Heqi. omega. }
           rewrite H. reflexivity. omega. }
        { intros.
          rewrite n_adder_z_compute_equiv_3 with (f1:=f') (f2:=f).
          rewrite n_adder_z_compute_equiv_1. reflexivity.
          omega. omega. destruct x0. intro H0; inversion H0. rewrite Heqf'. reflexivity.
          omega. }
        omega.
      * reflexivity.
      * reflexivity.
      * rewrite kron_1_l.
        { apply kron_eq_1.
          { rewrite n_adder_z_compute_equiv_3 with (f1:=f') (f2:=f).
            rewrite n_adder_z_compute_equiv_1. reflexivity.
            omega. omega. destruct x. intro H; inversion H. rewrite Heqf'. reflexivity.
            omega. }
          { apply big_kron_eq_1.
            intros.
            remember (S (S x)) as x'.
            rewrite n_adder_z_compute_equiv_3 with (f1:=f') (f2:=f).
            rewrite n_adder_z_compute_equiv_1. reflexivity.
            omega. omega. destruct x0. intro H0; inversion H0. rewrite Heqf'. reflexivity.
            omega. }
        }
        apply WF_kron; try omega.
        { apply WF_bool_to_matrix. }
        { specialize (WF_ctx_to_matrix (list_of_Qubits (n+n+n))) as HWF.
          unfold ctx_to_matrix in HWF. rewrite dim_eq_lemma_1 in HWF. apply HWF. }
Qed.

Close Scope matrix_scope.
Close Scope nat_scope.

(* Unit test : 10100(2) + 11000(2) + 1(2) = 101101(2) *)
Lemma adder_circ_n_test_10100_11000_1 :
  ⟦adder_circ_n 5⟧ (ctx_to_matrix (list_of_Qubits 17) (list_to_function [false; false; true; true; false; false; true; false; true; false; false; false; false; false; false; false; true] false))
  = (ctx_to_matrix (list_of_Qubits 17) (list_to_function [true; false; true; true; true; false; true; true; true; false; false; false; false; true; false; false; true] false)).
Proof.
  rewrite (adder_circ_n_spec 5).
  apply ctx_to_matrix_eq_1.
  repeat (try destruct x; try reflexivity).
Qed.
(* Unit test : 10100(2) + 11000(2) + 0(2) = 101100(2) *)
Lemma adder_circ_n_test_10100_11000_0 :
  ⟦adder_circ_n 5⟧ (ctx_to_matrix (list_of_Qubits 17) (list_to_function [false; false; true; true; false; false; true; false; true; false; false; false; false; false; false; false; false] false))
  = (ctx_to_matrix (list_of_Qubits 17) (list_to_function [true; false; true; true; true; false; true; true; true; false; false; false; false; false; false; false; false] false)).
Proof.
  rewrite (adder_circ_n_spec 5).
  apply ctx_to_matrix_eq_1.
  repeat (try destruct x; try reflexivity).
Qed.

(*
(* Simplified, but I can't see this doing what we want *)
Fixpoint adder_circ_n' (n : nat) : Box ((2+n) ⨂ Qubit) ((2+n) ⨂ Qubit) := 
  match n with
  | O => calc_id_circ
  | S n' => ((@id_circ Qubit) ∥ (strip_one_l_in (init0 ∥ id_circ))) ;; 
            ((@id_circ Qubit) ∥ (strip_one_l_out (assert0 ∥ id_circ)))
  end.

Open Scope matrix_scope.
Lemma adder_circ_n'_spec : forall (n : nat) (f : Var -> bool),
⟦adder_circ_n' n⟧ (ctx_to_matrix (list_of_Qubits (2+n)) f)
= (ctx_to_matrix (list_of_Qubits (2+n)) (n_adder_cout_compute n (n_adder_z_compute n n f))).
Proof.
  induction n.
  - intros f. apply calc_id_circ_spec.
  - intros f.
    simpl.
    simpl_rewrite inSeq_correct.
    unfold compose_super.
    unfold list_of_Qubits in *.
    simpl. 
    unfold ctx_to_matrix in *. simpl in *.
    rewrite Nat.sub_diag in *. simpl in *.
    rewrite_inPar'.
    rewrite strip_one_l_in_eq.
    rewrite <- (kron_1_l _ _ (bool_to_matrix (f 1) ⊗ _)). 
    repeat rewrite_inPar'.
    repeat simpl_rewrite id_circ_Id.    
    simpl_rewrite init0_spec.
    rewrite strip_one_l_out_eq.
    rewrite_inPar'.
    simpl_rewrite id_circ_Id.    
    simpl_rewrite assert0_spec.
    rewrite kron_1_l.
(* this is an identity, so that's as far as you get *)
Abort.

Open Scope matrix_scope.
Lemma adder_circ_n_spec : forall (n : nat) (f : Var -> bool),
⟦adder_circ_n n⟧ (ctx_to_matrix (list_of_Qubits (2+n+n+n)) f)
= (ctx_to_matrix (list_of_Qubits (2+n+n+n)) (n_adder_cout_compute n (n_adder_z_compute n n f))).
Proof.
  induction n.
  - intros.
    remember (calc_id_circ_spec (f 1%nat) (f 0%nat)).
    simpl in *. unfold ctx_to_matrix in *.
    unfold big_kron in *. simpl in *. apply e.
  - intros.
    Opaque denote. simpl_eq. Transparent denote.
    specialize inSeq_correct as IS. simpl in IS.
    simpl. repeat (rewrite IS; compile_typing (compile_WT)).
    unfold compose_super.
    Set Printing All.

(* ??? *)

    apply inPar_correct 

(Tensor Qubit
        (Tensor Qubit
           (Tensor Qubit
              (Tensor Qubit
                 (Tensor Qubit
                    (Tensor Qubit
                       (NTensor (Init.Nat.add (Init.Nat.add n n) n) Qubit)))))))
(Tensor Qubit
        (Tensor Qubit
           (Tensor Qubit
              (Tensor Qubit
                 (Tensor Qubit
                    (NTensor (Init.Nat.add (Init.Nat.add n n) n) Qubit))))))


(Tensor Qubit
           (Tensor Qubit
              (Tensor Qubit
                 (Tensor Qubit
                    (Tensor Qubit
                       (Tensor Qubit
                          (NTensor (Init.Nat.add (Init.Nat.add n n) n) Qubit)))))))
(Tensor Qubit
           (Tensor Qubit
              (Tensor Qubit
                 (Tensor Qubit
                    (Tensor Qubit
                       (Tensor Qubit
                          (NTensor (Init.Nat.add (Init.Nat.add n n) n) Qubit)))))))

    assert (H1 : forall n, (size_ctx (list_of_Qubits n )) = n).
    { induction n0.
      - reflexivity.
      - simpl. rewrite IHn0. reflexivity. }

    assert (H2 : forall n f, @length (Matrix (S (S O)) (S (S O)))
    (ctx_to_mat_list (list_of_Qubits n) f) = n).
    { induction n0.
      - reflexivity.
      - intros. simpl. rewrite IHn0. reflexivity. }

    + rewrite H1.
      listify_kron.
    rewrite inPar_correct.
 rewrite_inPar.
 rewrite H2.
    rewrite_inPar.
 rewrite H2.
    apply inPar_correct.
    rewrite_inPar.
    rewrite inSeq_correct.
    + unfold compose_super.
      rewrite inSeq_correct.
      * unfold compose_super.
        rewrite inSeq_correct.
        unfold compose_super.
        { unfold denote at 0. unfold Denote_Box.
      unfold ctx_to_matrix. simpl.
      replace (n + S n + S n + 1)%nat with (3 + n + n + n)%nat by omega.
      replace (n + n + n + 1)%nat with (1 + n + n + n)%nat by omega.
      simpl.

      rewrite_inPar.
      rewrite H1.
      rewrite_inPar.
      rewrite_inPar.
      rewrite_inPar.
      Set Printing All.
      apply inSeq_correct.
      remember id_circ_Id. simpl in e. repeat rewrite e. clear e Heqe.
      unfold strip_one_l_in. unfold denote_box at 2. simpl.
      unfold compose_super. unfold apply_new0. unfold super. simpl.
      Locate "⨂".
      Check NTensor.
      Check (denote_box true (inParMany (n + n + n + 1)%nat (@id_circ Qubit))).
      fold (denote_box true (inParMany (n + n + n + 1)%nat (@id_circ Qubit))).
(NTensor (n + n + n + 1)%nat Qubit) (NTensor (n + n + n + 1)%nat Qubit)).
fold inParMany (n + n + n + 1)%nat (@id_circ Qubit).
      Check @denote_box.
      Set Printing All.
      fold (@denote_box true (⨂ ctx_to_mat_list (list_of_Qubits (n + n + n + 1)) (fun v : Var => f (S (S (S (S v))))))
                             (⨂ ctx_to_mat_list (list_of_Qubits (n + n + n + 1)) (fun v : Var => f (S (S (S (S v))))))).
      rewrite strip_one_l_in_eq. matrix_simpl.
      Set Printing All.
      rewrite_inPar.
      Set Printing All.
      apply inSeq_correct.
      Check (denote_box true (init0 ∥ id_circ # (n + n + n + 1))).
      Set Printing All. simpl.
      Set Printing All.
      Check (init0 ∥ id_circ # (n + n + n + 1)).
      Check (ctx_to_mat_list (list_of_Qubits (n + n + n + 1))).
      replace ((n + n + n + 1)%nat) with ((1 + n + n + n)%nat).
      rewrite_inPar.
      
      Transparent 
      replace (list_of_Qubits (n + n + n + 1)%nat) with (list_of_Qubits (1 + n + n + n)%nat).
      rewrite_inPar.
      unfold big_kron.
rewrite H2. rewrite inPar_correct.
      remember
      rewrite id_circ_Id.
      simpl_rewrite calc_id_circ_spec.
      rewrite calc_id_circ_spec.
      unfold strip_one_l_in. simpl.
      listify_kron. simpl.

      listify_kron. simpl.
      clear IHn.
      Set Printing All.

      rewrite inPar.
      unfold kron at 1.
      Check inPar_correct.
      replace (length
              (ctx_to_mat_list (list_of_Qubits (n + n + n))
                 (fun v : Var => f (S (S (S (S (S v)))))))) with (n+n+n)%nat.
      rewrite plus_0_r. simpl.
      rewrite inPar_correct.
      rewrite_inPar.
    Opaque denote. simpl. simpl_eq. Transparent denote.
    rewrite inSeq_correct. unfold compose_super.
    + rewrite inSeq_correct. unfold compose_super.
      * rewrite inSeq_correct. unfold compose_super.
        { unfold denote. unfold Denote_Box.
          rewrite_inPar.
    simpl. simpl_eq.

    rewrite_inPar.
    Opaque denote. unfold adder_circ_n. simpl_eq. Transparent denote.
    Opaque denote. simpl. simpl_eq. Transparent denote.
    rewrite inSeq_correct. unfold compose_super.
    + rewrite_inPar. remember ((⟦ id_circ ∥ (id_circ ∥ (id_circ ∥ (id_circ ∥ adder_circ_n n)));;
   adder_circ_1_with_pads (n + n + n + 1);;
   id_circ
   ∥ (id_circ
       ∥ (id_circ
           ∥ (id_circ
               ∥ strip_one_l_out (assert0 ∥ id_circ # (n + n + n + 1))))) ⟧)).
unfold denote at 2. rewrite inPar_correct. Check inPar_correct. rewrite_inPar.
rewrite inSeq_correct. unfold compose_super.
      * rewrite inSeq_correct. unfold compose_super.
        { assert ().
repeat (try apply inPar_correct; try apply id_circ_spec). )
    apply inSeq_correct.
    rewrite IHn.
    replace (1 + S n + S n + S n + 1)%nat with (5 + n + n + n)%nat by omega.
 unfold NTensor. unfold adder_circ_n. rewrite calc_id_circ_spec.
Qed.

Lemma adder_circ_n_spec : forall (n m : nat),
Close Scope matrix_scope.

(* unit test 0 : 0+01+10=011 (cin : 0, x : 01, y : 10, z : 11, cout : 0)
Input : (0, (0, (1, (0, (0, (0, (1, (0, ()))))))))
Output : (0, (1, (1, (0, (1, (0, (1, (0, ()))))))))
*)
Lemma adder_circ_n_unit_test_0 :
  ⟦adder_circ_n 2⟧ (ctx_to_matrix (list_of_Qubits 8) 
    (fun_of_bools [false; false; true; false; false; false; true; false] false))
  = (ctx_to_matrix (list_of_Qubits 5) 
    (fun_of_bools [false; true ; true; false; true; false; true; false] false)).
Proof.
  simpl.
  rewrite_inPar.
  rewrite_inPar.
  repeat apply inSeq_correct.
  rewrite
  simpl.
apply adder_circ_1_spec. Qed.

(*
Definition adder_circ_1 : Box (5 ⨂ Qubit) (5 ⨂ Qubit) :=
  box_ inp ⇒
    let_ (cout_1, (z_1, (y_1, (x_1, (cin_1, dum1))))) ← output inp;
    let_ (z_2, out_z) ← unbox adder_z_circ (z_1, (y_1, (pair x_1 (pair cin_1 unit))));
    let_ (cout_2, out_cout) ← unbox adder_cout_circ (cout_1, out_z);
    output (cout_2, (z_2, out_cout)).
Check adder_circ_1.
Print adder_circ_1.

Lemma type_adder_circ_1 : Typed_Box adder_circ_1.
Proof.
  unfold adder_circ_1.
  type_check.
Qed.
*)

(*
Fixpoint remove_var {W} (p : Pat W) (i : nat) : Pat W :=
  match p with
  | unit => unit
  | qubit x => qubit (pred x)
  | bit x => bit (pred x)
  | pair p1 p2 => pair (remove_var p1 i) (remove_var p2 i)
  end.
Lemma DBCircuit_equiv : forall {W1 W2} (Γ : Ctx) (b : Box W1 W2) (p : Pat W1), 
          hoas_to_db (Valid (None :: Γ)) (unbox b p) 
          = hoas_to_db Γ (unbox b (remove_var p 0)).
*)

Open Scope matrix_scope.
Lemma adder_circ_1_spec : forall (cin x y z cout : bool),
  ⟦adder_circ_1⟧ (ctx_to_matrix (list_of_Qubits 5) (fun_of_bools [cout; z; y; x; cin] false))
  = (ctx_to_matrix 
      (list_of_Qubits 5) 
      (fun_of_bools [cout ⊕ ⌈ adder_cout_bexp | fun_of_bools [y; x; cin] false ⌉; 
                         z ⊕ ⌈ adder_z_bexp | fun_of_bools [y; x; cin] false ⌉; y; x; cin] false)).
Proof.
intros.
rewrite denote_db_unbox.
unfold adder_circ_1.
Opaque adder_z_circ.
Opaque adder_cout_circ.
simpl.
rewrite denote_compose with (Γ:=Valid [None; Some Qubit; Some Qubit; Some Qubit; Some Qubit]) (Γ1:=Valid [Some Qubit]).
- simpl.
  remember (adder_z_circ_spec y x cin z) as H; clear HeqH.
  rewrite denote_db_unbox in H. simpl in H.
  unfold compose_super.

  simpl in H.
  repeat (autounfold with den_db; simpl). 
  denote_matrix.
 admit.
- apply type_adder_z_circ.
  type_check_once.
  invert_patterns.
  apply types_pair with (Γ1:=Valid [None; Some Qubit]) (Γ2:=Valid [None; None; Some Qubit; Some Qubit; Some Qubit]).
  + exists [None; Some Qubit; Some Qubit; Some Qubit; Some Qubit]. reflexivity.
  + Transparent merge. simpl. reflexivity.
  + apply types_qubit.
    apply SingletonLater. apply SingletonHere.
  + apply types_pair with (Γ1:=Valid [None; None; Some Qubit]) (Γ2:=Valid [None; None; None; Some Qubit; Some Qubit]).
  + exists [None; Some Qubit; Some Qubit; Some Qubit; Some Qubit]. reflexivity.
  + Transparent merge. simpl. reflexivity.
  + apply types_qubit.
    apply SingletonLater. apply SingletonHere.
simpl. Transparent Types_Pat.

 replace (Valid [None; Some Qubit] ⋓ Valid [None; None; Some Qubit; Some Qubit; Some Qubit]) with (Valid [None; Some Qubit; Some Qubit; Some Qubit; Some Qubit]).
 unfold merge. monoid.
 Set Printing All. unfold is_valid. apply pat_ctx_valid. validate.
  eapply types_pair.
  + 

 Print Types_Pat.
  type_check.
  Check types_pair.
 Locate "⊢". Print Types_Circuit.
  
  unfold adder_z_circ.
  type_check.
  apply types_nfold Types_Circuit. simpl.
- unfold denote_circuit at 2.
  simpl.
  unfold denote_db_circuit.
  assert (H : adder_z_circ_spec).
  Check adder_z_circ_spec.
  assert (H : (⟨ (@nil)%nat ⋓ [Some Qubit; None; None; None; None]
   | [None; Some Qubit; Some Qubit; Some Qubit; Some Qubit]
   ⊩ unbox adder_z_circ
       (qubit 1%nat, (qubit 2%nat, (qubit 3%nat, (qubit 4%nat, ())))) ⟩)
  (ctx_to_matrix [Some Qubit; Some Qubit; Some Qubit; Some Qubit; Some Qubit]
     (fun_of_bools [cout; z; y; x; cin] false)) 
    = (bool_to_matrix (z ⊕ ⌈ adder_z_bexp | fun_of_bools [y; x; cin] false ⌉)) ⊗ 
  (ctx_to_matrix [Some Qubit; Some Qubit; Some Qubit] (fun_of_bools [y; x; cin] false))).
unfold compose_super.
  Check denote_circuit.
  Locate "⋓".
  Check merge.
  unfold denote.
  unfold Denote_OCtx.
  unfold size_octx.

  simpl.
  unfold merge.
  rewrite <- denote_db_unbox.
assert (H : (fresh_state (5 ⨂ Qubit)%qc []) = (qubit 0%nat, (qubit 1%nat, (qubit 2%nat, (qubit 3%nat, (qubit 4%nat, ())))))).
{ simpl. reflexivity. }
  Check denote_circuit.
  
  unfold merge_valid.
 rewrite denote_compose with (Γ:=Valid [Some Qubit; None; None; None; None; None; Some Qubit; Some Qubit; Some Qubit]) (Γ1:=Valid [None; None; None; None; None; Some Qubit; None; None; None]).
  + simpl.

(*
assert (H : (fresh_pat (5 ⨂ Qubit)%qc []) = (qubit 0%nat, (qubit 1%nat, (qubit 2%nat, (qubit 3%nat, (qubit 4%nat, ())))))).
{ simpl. reflexivity. }
*)
Set Printing All.
assert (H : (@fresh_pat (list Var) substitution_Gate_State
         (NTensor (S (S (S (S (S O))))) Qubit) (@Datatypes.nil Var)) 
       = (qubit 0%nat, (qubit 1%nat, (qubit 2%nat, (qubit 3%nat, (qubit 4%nat, ())))))).
{ simpl. reflexivity. }
simpl.
rewrite H.
replace (@fresh_pat (list Var) substitution_Gate_State
         (NTensor (S (S (S (S (S O))))) Qubit) (@Datatypes.nil Var)) 
        with ((qubit 0%nat, (qubit 1%nat, (qubit 2%nat, (qubit 3%nat, (qubit 4%nat, ())))))) by H.
unfold wproj at 1.
simpl.
rewrite H.

Locate "return".
rewrite H.
Locate "⨂".
rewrite H.
unfold denote_circuit.

rewrite H.
Check fresh_state.
Check 5 ⨂ Qubit.
Check [].
Print fresh_state.
Print get_fresh.
Print State.
unfold wproj at 1.
unfold fresh_pat at 1.


replace (fresh_state (5 ⨂ Qubit) []) with ([0%nat; 1%nat; 2%nat; 3%nat; 4%nat]) by auto.
rewrite <- denote_db_unbox.
unfold wproj at 1.
unfold letpair at 1.
rewrite denote_compose with (Γ:=Valid [Some Qubit; Some Qubit; Some Qubit; Some Qubit]) (Γ1:=Valid []).
unfold db_
apply (compile_correct xor_bexp [Some Qubit; Some Qubit] (fun_of_bool [x; y] false) r).
apply (sub_some Qubit [Some Qubit]).
Qed.
Close Scope matrix_scope.




Definition 1_adder : Box 

Definition adder_z_circ_test_000 : Box One Qubit :=
  box_ inp ⇒
    gate_ cin ← init0 @() ;
    gate_ x   ← init0 @() ;
    gate_ y   ← init0 @() ;
    gate_ z   ← init0 @() ;
    let_ res  ← unbox adder_z_circ (pair (pair cin (pair x (pair y unit))) z);
    let_ ((y', res'), z') ← output res;
    let_ (x', (cin', t)) ← output res';
    gate_ ()  ← assert0 @cin' ;
    gate_ ()  ← assert0 @x' ;
    gate_ ()  ← assert0 @y' ;
    output z'.
Open Scope matrix_scope.
Lemma denote_adder_z_circ_test_000_correct : ⟦adder_z_circ_test_000⟧ (Id 1)= (bool_to_matrix false).
Proof.
  rewrite denote_db_unbox.
  unfold fresh_state.
  unfold fresh_pat.
  unfold adder_z_circ_test_000.
  unfold unbox at 1.
  rewrite denote_gate_circuit with (Γ1:=Valid []) (Γ2:=Valid []).
  - admit.
  - monoid. has_evars (Valid [] == Valid [] ∙ Valid []). Locate "∙". Check valid_merge. Check valid_merge. Print valid_merge.
    unfold valid_merge.
    reflexivity.
    unfold Build_valid_merge.
    unfold pf_valid. unfold valid_merge. auto.
  - rewrite denote_gate_circuit with (Γ1:=Valid []) (Γ2:=Valid [Some Qubit]).
    + rewrite denote_gate_circuit with (Γ1:=Valid []) (Γ2:=Valid [Some Qubit; Some Qubit]).
      * rewrite denote_gate_circuit with (Γ1:=Valid []) (Γ2:=Valid [Some Qubit; Some Qubit; Some Qubit]).
        { rewrite denote_compose with (Γ:=Valid [Some Qubit; Some Qubit; Some Qubit; Some Qubit]) (Γ1:=Valid []).
          - Check denote_db_unbox. 
            Locate "⋓". Check merge. Print OCtx.
            replace (Valid [] ⋓ Valid []) with (Valid []) by auto.
            rewrite <- (denote_db_unbox adder_z_circ).
            replace ([Some Qubit; Some Qubit; Some Qubit; Some Qubit]) 
with (fresh_pat ⟦[Some Qubit; Some Qubit; Some Qubit; Some Qubit]⟧) by auto.
            unfold compose_super. rewrite denote_compose with (Γ:=Valid [Some Qubit; Some Qubit; Some Qubit; Some Qubit]) (Γ1:=Valid []).
  - Admitted.
  - 
  unfold denote. unfold Denote_Box.
  unfold denote_box. unfold hoas_to_db_box.
  unfold denote_db_box.
  unfold Denote_Pat.
  Check fresh_state.
  Print fresh_state.
  Print get_fresh.
  Check Gate_State.
  Print Gate_State.
  Print Monad.State.
  unfold hoas_to_db at 1. fold compose.
  rewrite comp x1 res'.
  unfold comp.
  unfold hoas_to_db.
  replace (gate_ cin ← init0 @ ();
         gate_ x ← init0 @ ();
         gate_ y ← init0 @ ();
         gate_ z ← init0 @ ();
         comp res (unbox adder_z_circ (cin, (x, (y, ())), z))
           (comp x0 res
              (letpair y0 z' x0
                 (letpair y' res' y0
                    (comp x1 res'
                       (letpair x' y1 x1
                          (let (cin', _) := wproj y1 in
                           gate_ () ← assert0 @ cin';
                           gate_ () ← assert0 @ x';
                           gate_ () ← assert0 @ y'; z'))))))) with c.
  unfold hoas_to_db.
  unfold denote_db_box.
Check denote_gate_circuit.
  apply denote_gate_circuit.
  repeat (autounfold with den_db; simpl).
  unfold state_0.
  solve_matrix.
Qed.
Close Scope matrix_scope.

(*
Eval simpl in adder_z_circ.
Eval compute in adder_z_circ.

Lemma adder_z_circ_type : Typed_Box adder_z_circ.
Proof. type_check. Qed.

Print adder_cout_circ.

Eval simpl in adder_cout_circ.
Eval compute in adder_cout_circ.

Lemma adder_cout_circ_type : Typed_Box adder_cout_circ.
Proof. type_check. Qed.
*)

(*
Eval compute in (S (⟦ list_of_Qubits 3 ⟧) ⨂ Qubit).
Check (qubit 0%nat, (qubit 1%nat, (qubit 2%nat, (qubit 3%nat, unit)))).
Eval simple in (adder_cout_circ (qubit 0%nat, (qubit 1%nat, (qubit 2%nat, qubit 3%nat)))).
*)

(* n_adder_circ : returns a boxed circuit that adds two n-bit inputs
   example : (n_adder_circ 2) (cout2, (z2, (y2, (x2, (cout1, (z1, (y1, (x1, cin))))))))
             returns (cout2', (z2', (y2, (x2, (cout1', (z1', (y1, (x1, cin)))))))) where 
             z1' and cout1' are the first sum and carry, respectively, and
             z2' and cout2' are the second sum and carry.
 *)
Locate "⨂".
Definition adder_circ_1 : Box (5 ⨂ Qubit) (5 ⨂ Qubit) :=
  box_ inp ⇒
    let_ (coutn, (zn, inp')) ← output inp;
    let_ (yn, (xn, inp'')) ← output inp';
    let_ (coutn', dummy1) ← output inp'';
    let_ (out_z, zn') ← unbox adder_z_circ ((pair yn (pair xn (pair coutn' unit))), zn);
    let_ ((yn', tmp), coutn') ← unbox adder_cout_circ (out_z, coutn);
    let_ (xn', (coutn'', dummy2)) ← tmp;
    output (pair coutn' (pair zn' (pair yn' (pair xn' (pair coutn'' unit))))).
Check adder_circ_1.
Print adder_circ_1.

(*
Lemma type_adder_circ_1 : Typed_Box adder_circ_1.
Proof. type_check. Qed.
*)

Definition adder_circ_2 : Box (9 ⨂ Qubit) (9 ⨂ Qubit) :=
  box_ inp ⇒
    let_ (coutn, (zn, inp')) ← output inp;
    let_ (yn, (xn, inp'')) ← output inp';
    let_ out'' ← unbox (adder_circ_1) inp'';
    let_ (coutn', out''') ← output out'';
    let_ (out_z, zn') ← unbox adder_z_circ (pair (pair yn (pair xn (pair coutn' unit))) zn);
    let_ ((yn', tmp), coutn') ← unbox adder_cout_circ (out_z, coutn);
    let_ (xn', (coutn'', dummy)) ← tmp;
    output (pair coutn' (pair zn' (pair yn' (pair xn' (pair coutn'' out'''))))).
Check adder_circ_2.
Print adder_circ_2.

Definition adder_circ_3 : Box (13 ⨂ Qubit) (13 ⨂ Qubit) :=
  box_ inp ⇒
    let_ (coutn, (zn, inp')) ← output inp;
    let_ (yn, (xn, inp'')) ← output inp';
    let_ out'' ← unbox (adder_circ_2) inp'';
    let_ (coutn', out''') ← output out'';
    let_ (out_z, zn') ← unbox adder_z_circ (pair (pair yn (pair xn (pair coutn' unit))) zn);
    let_ ((yn', tmp), coutn') ← unbox adder_cout_circ (out_z, coutn);
    let_ (xn', (coutn'', dummy)) ← tmp;
    output (pair coutn' (pair zn' (pair yn' (pair xn' (pair coutn'' out'''))))).
Check adder_circ_3.
Eval compute in adder_circ_3.

Program Fixpoint n_adder_circ (n : nat) 
: Box (Qubit ⊗ (((n ⨂ Qubit) ⊗ (n ⨂ Qubit)) ⊗ (Qubit ⊗ (n ⨂ Qubit))))
      (Qubit ⊗ (((n ⨂ Qubit) ⊗ (n ⨂ Qubit)) ⊗ (Qubit ⊗ (n ⨂ Qubit)))) :=
  match n with
  | 0 => box_ inp ⇒
         let_ (cin, (xy, cz)) ← output inp;
         let_ (c, z) ← output cz;
         let_ (c', (cin'))
(output inp)
  | S n' => box_ state_in ⇒
           let_ (cin, (xy, cz)) ← output state_in;
           let_ ((x0, x'), (y0, y')) ← output xy;
           let_ ((z0, z'), (c0, c')) ← output zc;
           let_ (xy', zc') ← ((x', y'), (z', c'));
           let_ temp_inp ← (cin, (xy', zc'));
           let_ temp_out ← unbox (n_adder_circ n') temp_inp;
           let_ (cin, (xy'_out, zc'_out)) ← output temp_out;
           let_ ((x'_out, y'_out), (z'_out, c'_out)) ← output (xy'_out, zc'_out);
           
           let_ (yn, (xn, inp'')) ← output inp';
           let_ out'' ← unbox (n_adder_circ n') inp'';
           let_ (coutn', out''') ← output out'';
           let_ (out_z, zn') ← unbox adder_z_circ (pair (pair yn (pair xn (pair coutn' unit))) zn);
           let_ ((yn', tmp), coutn') ← unbox adder_cout_circ (out_z, coutn);
           let_ (xn', (coutn'', dummy)) ← tmp;
           output (pair coutn' (pair zn' (pair yn' (pair xn' (pair coutn'' out''')))))
  end.
Next Obligation.
  fold NTensor.
  fold Init.Nat.add.
  replace (n' + S n' + S n' + S n')%nat with
      (S (S (S (n' + n' + n' + n')%nat))) by omega.
  reflexivity.
Defined.
Next Obligation.
  fold NTensor.
  fold Init.Nat.add.
  replace (n' + S n' + S n' + S n')%nat with
      (S (S (S (n' + n' + n' + n')%nat))) by omega.
  reflexivity.
Defined.
(*
Program Fixpoint n_adder_circ (n : nat) : Box ((1+n+n+n+n) ⨂ Qubit) ((1+n+n+n+n) ⨂ Qubit) :=
  match n with
  | 0 => box_ inp ⇒ (output inp)
  | S n' => box_ inp ⇒
           let_ (coutn, (zn, inp')) ← output inp;
           let_ (yn, (xn, inp'')) ← output inp';
           let_ out'' ← unbox (n_adder_circ n') inp'';
           let_ (coutn', out''') ← output out'';
           let_ (out_z, zn') ← unbox adder_z_circ (pair (pair yn (pair xn (pair coutn' unit))) zn);
           let_ ((yn', tmp), coutn') ← unbox adder_cout_circ (out_z, coutn);
           let_ (xn', (coutn'', dummy)) ← tmp;
           output (pair coutn' (pair zn' (pair yn' (pair xn' (pair coutn'' out''')))))
  end.
Next Obligation.
  fold NTensor.
  fold Init.Nat.add.
  replace (n' + S n' + S n' + S n')%nat with
      (S (S (S (n' + n' + n' + n')%nat))) by omega.
  reflexivity.
Defined.
Next Obligation.
  fold NTensor.
  fold Init.Nat.add.
  replace (n' + S n' + S n' + S n')%nat with
      (S (S (S (n' + n' + n' + n')%nat))) by omega.
  reflexivity.
Defined.
*)
Close Scope circ_scope.

(* Correctness of the adder circuit *)

Open Scope circ_scope.

Definition adder_0_circ := n_adder_circ 0.
Definition adder_1_circ := n_adder_circ 1.
Definition adder_2_circ := n_adder_circ 2.
Definition adder_3_circ := n_adder_circ 3.

Check adder_0_circ.
Lemma type_adder_0_circ : Typed_Box adder_0_circ.
Proof. type_check. Qed.

Check adder_1_circ.
Lemma type_adder_1_circ : Typed_Box adder_1_circ.
Proof.
  unfold Typed_Box.
  unfold unbox.
  unfold adder_1_circ.
  unfold n_adder_circ.
  intros.
  Locate "⊢".
  Locate type_check.
  unfold Types_Circuit.
  repeat (autounfold with den_db; simpl).
unfold type_check. simpl.
Check n_adder_circ_obligation_1 0.
replace (0 + 0)%nat with (0)%nat by omega.
simpl.
type_check.
unfold n_adder_circ_obligation_1.
unfold n_adder_circ_obligation_2.
replace (0 + 0)%nat with (0)%nat by omega.
Csimpl.
Check inj_neq (S (S (S (0 + 0 + 0 + 0)))).
Check eq_rect.
Check eq_ind.
Check eq_refl.
replace (0 + 1)%nat with 1%nat by omega.
replace (0 + 1 + 1 + 1)%nat with 3%nat by omega.
replace (0 + 0)%C with (0)%C.
Check 0 + 0.
Qed.


(* Some tests on type check and denotation 

Definition test_code_1 : Box Qubit Qubit :=
  box_ x ⇒ (gate_ y  ← init0 @() ; gate_ () ← assert0 @y ; output x).
Check Typed_Box test_code_1.
Lemma test_lemma_1 : Typed_Box test_code_1.
Proof.
  type_check.
Qed.
Definition denote_test_1 := ⟦test_code_1⟧.
Open Scope matrix_scope.
Definition state_0 : Matrix 2 2 := (|0⟩)×(⟨0|).
Lemma denote_test_1_correct : (denote_test_1 (state_0))= state_0.
Proof.
  unfold denote_test_1.
  repeat (autounfold with den_db; simpl).
  unfold state_0.
  autounfold with M_db.
  Msimpl.
  solve_matrix.
Qed.
Close Scope matrix_scope.

Definition test_code_2 : Box One (Qubit ⊗ Qubit) :=
  box_ () ⇒
    gate_ cin  ← init0 @() ;
    gate_ x0   ← init0 @() ;
    gate_ y0   ← init0 @() ;
    gate_ z0   ← init0 @() ;
    gate_ cout ← init0 @() ;
    gate_ ()   ← assert0 @cin ;
    gate_ ()   ← assert0 @x0 ;
    gate_ ()   ← assert0 @y0 ;
    output (cout, z0).
Check Typed_Box test_code_2.
Lemma test_lemma_2 : Typed_Box test_code_2.
Proof.
  type_check.
Qed.
Definition denote_test_2 := ⟦test_code_2⟧.
Open Scope matrix_scope.
Definition state_00 : Matrix 4 4 := (|0⟩⊗|0⟩)×(⟨0|⊗⟨0|).
Lemma denote_test_2_correct : (denote_test_2 (Id 1)) = state_00.
Proof.
  unfold denote_test_2.
  repeat (autounfold with den_db; simpl).
  unfold state_00.
  solve_matrix.
Qed.
Close Scope matrix_scope.

Definition test_code_3 : Box One (Qubit ⊗ (Qubit ⊗ (Qubit ⊗ (Qubit ⊗ One)))) :=
  box_ () ⇒
    gate_ cin  ← init0 @() ;
    gate_ x0   ← init0 @() ;
    gate_ y0   ← init0 @() ;
    gate_ z0   ← init0 @() ;
    let_ (res, z0')   ← unbox adder_z_circ (pair (pair y0 (pair x0 (pair cin unit))) z0) ;
    output (z0', res).
Check Typed_Box test_code_3.
Lemma test_lemma_3 : Typed_Box test_code_3.
Proof.
  type_check.
Qed.
Definition denote_test_3 := ⟦test_code_3⟧.
Open Scope matrix_scope.
Definition state_0000 : Matrix 16 16 := (|0⟩⊗|0⟩⊗|0⟩⊗|0⟩)×(⟨0|⊗⟨0|⊗⟨0|⊗⟨0|).
Lemma denote_test_3_correct : (denote_test_3 (Id 1)) = state_0000.
Proof.
  unfold denote_test_3.
  repeat (autounfold with den_db; simpl).
  unfold state_0000.
  solve_matrix.
Qed.
Close Scope matrix_scope.

Definition test_code_4 : Box One (Qubit ⊗ (Qubit ⊗ (Qubit ⊗ One))) :=
  box_ () ⇒
    gate_ cin  ← init0 @() ;
    gate_ x0   ← init0 @() ;
    gate_ y0   ← init0 @() ;
    gate_ z0   ← init0 @() ;
    let_ (res', z0')  ← unbox adder_z_circ (pair (pair y0 (pair x0 (pair cin unit))) z0) ;
    gate_ ()   ← assert0 @z0' ;
    output res'.
Check Typed_Box test_code_4.
Lemma test_lemma_4 : Typed_Box test_code_4.
Proof.
  type_check.
Qed.

Definition test_code_5 : Box One (Qubit ⊗ (Qubit ⊗ (Qubit ⊗ One))) :=
  box_ () ⇒
    gate_ cin  ← init0 @() ;
    gate_ x0   ← init0 @() ;
    gate_ y0   ← init0 @() ;
    gate_ z0   ← init0 @() ;
    let_ res   ← unbox adder_z_circ (pair (pair y0 (pair x0 (pair cin unit))) z0) ;
    let_ ((y0', res'), z0') ← output res ;
    gate_ ()   ← assert0 @y0' ;
    output (z0', res').
Check Typed_Box test_code_5.
Lemma test_lemma_5 : Typed_Box test_code_5.
Proof.
  type_check.
Qed.
Definition denote_test_5 := ⟦test_code_5⟧.
Eval simpl in denote_test_5.
Eval compute in denote_test_5.
Open Scope matrix_scope.
Definition state_000 : Matrix 8 8 := (|0⟩⊗|0⟩⊗|0⟩)×(⟨0|⊗⟨0|⊗⟨0|).
Lemma denote_test_5_correct : (denote_test_5 (Id 1))= state_000.
Close Scope matrix_scope.
*)

Definition circuit_0_plus_0 : Box One (Qubit ⊗ Qubit) :=
  box_ () ⇒
    gate_ cin  ← init0 @() ;
    gate_ x0   ← init0 @() ;
    gate_ y0   ← init0 @() ;
    gate_ z0   ← init0 @() ;
    gate_ cout ← init0 @() ;
    let_ res   ← unbox adder_1_circ
         (pair cout (pair z0 (pair y0 (pair x0 (pair cin unit))))) ;
    let_ (cout', (z0', rem1))
         ← output res ;
    let_ (y0', (x0', rem2))
         ← output rem1 ;
    let_ (cin', dummy)
         ← output rem2 ;
    gate_ ()   ← assert0 @cin' ;
    gate_ ()   ← assert0 @x0' ;
    gate_ ()   ← assert0 @y0' ;
    output (cout', z0').

Print circuit_0_plus_0.
Lemma type_circuit_0_plus_0 : Typed_Box circuit_0_plus_0.
Proof. type_check. Qed.

Definition denote_circuit_0_plus_0 := ⟦circuit_0_plus_0⟧.
Check denote_circuit_0_plus_0.
Check Superoperator 1 4.
Eval compute in ⟦One⟧.
Eval compute in ⟦Qubit ⊗ Qubit⟧.
Check Matrix 1 1.
Check Matrix 4 4.
Check Square 4.
Check Square 1.

Open Scope matrix_scope.
Definition state_00 : Matrix 4 4 := (|0⟩⊗|0⟩)×(⟨0|⊗⟨0|).
Hint Unfold DBCircuits.add_fresh_state : den_db.
                                               
Check Superoperator 1 1.
Print Superoperator.
Locate Superoperator.
Check Id 1.
Locate super.
Eval compute in super (Id 1) (Id 1) 1%nat 1%nat.

Lemma type_circuit_0_plus_0 : Typed_Box circuit_0_plus_0.
Proof. type_check. Qed.

Lemma denote_circuit_0_plus_0_correct : (denote_circuit_0_plus_0 (Id 1)) = state_00.
Proof.
  unfold denote_circuit_0_plus_0.
  unfold denote. unfold Denote_Box.
  unfold denote_box. unfold circuit_0_plus_0.
  unfold adder_1_circ.
  autounfold with den_db; simpl.
  autounfold with den_db; simpl.
  unfold wproj. simpl.
  autounfold with den_db; simpl.
  repeat (autounfold with den_db; simpl).
  unfold n_adder_circ_obligation_1. simpl.
  Check inj_neq.
  Check Nat2Z.inj_succ.
  unfold ex_ind. simpl.
  unfold eq_ind_r. simpl.
  unfold eq_sym. simpl.
  
  
  unfold n_adder_circ_obligation_1. simpl.
  unfold dec_eq_nat. simpl.
  Locate letpair.
  Print Zne.
  Locate comp.
  unfold compose. simpl.
  Locate lift_pat.
  unfold eq_rect. simpl.
  unfold wproj. simpl.
  unfold n_adder_circ_obligation_2. simpl.
  unfold eq_ind. simpl.
  unfold dec_eq_nat. simpl.
  Locate Decidable.dec_not_not.
  unfold eq_ind_r. simpl.
  unfold eq_ind. simpl.
  unfold eq_sym. simpl.
  Check Nat2Z.inj_succ.
  unfold Zne. simpl.
  Locate eq_refl.
  Check Z.succ.
  Print Z.succ.
  Locate plus_comm.
  rewrite (y + 1) with (1 + y).
  rewrite Z.plus_comm.
  Locate or_introl.
  unfold lift. simpl.
  Print Decidable.dec_not_not.
  Check comp.
  replace (Nat2Z.inj_succ 0) with (1%Z).
  unfold Nat2Z.inj_succ .
  Check Zne.
  unfold eq_refl. 
  Print eq_rect.
  Check eq_rect.
  Check or_introl.
  Check Decidable.dec_not_not.
  Print Decidable.decidable.
  simpl.
  unfold DBCircuits.add_fresh_state. simpl.
  unfold DBCircuits.hoas_to_db.
  rewrite denote_compose.
  rewrite process_gate_denote.
  simpl.
  apply process_gate_denote.
  prep_matrix_equality.
  simpl.
  unfold DBCircuits.add_fresh_state.
  unfold DBCircuits.get_fresh.
  simpl.
  autounfold with M_db.
  destruct_m_eq.
  ; clra.
  autounfold.

  unfold circuit_0_plus_0.
  unfold adder_1_circ. unfold n_adder_circ.

  unfold denote. unfold Denote_Box.
  unfold denote_box. unfold denote_db_box. unfold denote_db_circuit.
  unfold DBCircuits.hoas_to_db_box. unfold 
  unfold denote_db_circuit.
    fold_denote.
simpl.
  unfold DBCircuits.hoas_to_db.
  unfold denote_gate.
  unfold Id.
  unfold state_00. unfold conj_transpose. unfold Cconj. unfold kron. unfold Mmult.
  destruct x, y.
  -  simpl.
  unfold ket0. simpl.
  - simpl.
  
   destruct x.
  destruct y. simpl.
 . simpl. omega. plus_comm. omega.
Close Scope matrix_scope.

Check state_00.
Check One.
Print One.
Check Id 1.
Check (denote_circuit_0_plus_0 (Id 1)).

Definition denote_adder_1_circ := ⟦adder_1_circ⟧.
Check denote_adder_1_circ.
Eval compute in denote_adder_1_circ.
Definition circuit_101_plus_010 : 
Lemma adder1 : [n_adder_circ 1]

Definition zn := qubit 3%nat.
Definition yn := qubit 2%nat.
Definition xn := qubit 1%nat.
Definition cin := qubit 0%nat.
Check pair zn (pair yn (pair xn (pair cin unit))).

Close Scope circ_scope.

(*
Eval simpl in (n_adder_circ 1).
Eval simpl in (n_adder_circ 2).
Eval simpl in (n_adder_circ 3).
 *)
*)