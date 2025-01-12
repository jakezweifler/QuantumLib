Require Export Reals.
Require Import Psatz.
Require Export Program.
Require Export Summation.

(******************************************)
(** Relevant lemmas from Rcomplements.v. **)
(******************************************)

Open Scope R_scope.

Lemma Rle_minus_l : forall a b c,(a - c <= b <-> a <= b + c). Proof. intros. lra. Qed.
Lemma Rlt_minus_r : forall a b c,(a < b - c <-> a + c < b). Proof. intros. lra. Qed.
Lemma Rlt_minus_l : forall a b c,(a - c < b <-> a < b + c). Proof. intros. lra. Qed.
Lemma Rle_minus_r : forall a b c,(a <= b - c <-> a + c <= b). Proof. intros. lra. Qed.
Lemma Rminus_le_0 : forall a b, a <= b <-> 0 <= b - a. Proof. intros. lra. Qed.
Lemma Rminus_lt_0 : forall a b, a < b <-> 0 < b - a. Proof. intros. lra. Qed.

(* Automation *)

Lemma Rminus_unfold : forall r1 r2, (r1 - r2 = r1 + -r2). Proof. reflexivity. Qed.
Lemma Rdiv_unfold : forall r1 r2, (r1 / r2 = r1 */ r2). Proof. reflexivity. Qed.

Hint Rewrite Rminus_unfold Rdiv_unfold Ropp_0 Ropp_involutive Rplus_0_l Rplus_0_r 
             Rmult_0_l Rmult_0_r Rmult_1_l Rmult_1_r : R_db.
Hint Rewrite <- Ropp_mult_distr_l Ropp_mult_distr_r : R_db.
Hint Rewrite Rinv_l Rinv_r sqrt_sqrt using lra : R_db.

Notation "√ n" := (sqrt n) (at level 20) : R_scope.

(* Useful Lemmas *)

Lemma Rmult_div_assoc : forall (x y z : R), x * (y / z) = x * y / z.
Proof. intros. unfold Rdiv. rewrite Rmult_assoc. reflexivity. Qed.

Lemma Rmult_div : forall r1 r2 r3 r4 : R, r2 <> 0 -> r4 <> 0 -> 
  r1 / r2 * (r3 / r4) = r1 * r3 / (r2 * r4). 
Proof. intros. unfold Rdiv. rewrite Rinv_mult_distr; trivial. lra. Qed.

Lemma Rdiv_cancel :  forall r r1 r2 : R, r1 = r2 -> r / r1 = r / r2.
Proof. intros. rewrite H. reflexivity. Qed.

Lemma Rsum_nonzero : forall r1 r2 : R, r1 <> 0 \/ r2 <> 0 -> r1 * r1 + r2 * r2 <> 0. 
Proof.
  intros.
  replace (r1 * r1)%R with (r1 ^ 2)%R by lra.
  replace (r2 * r2)%R with (r2 ^ 2)%R by lra.
  specialize (pow2_ge_0 (r1)). intros GZ1.
  specialize (pow2_ge_0 (r2)). intros GZ2.
  destruct H.
  - specialize (pow_nonzero r1 2 H). intros NZ. lra.
  - specialize (pow_nonzero r2 2 H). intros NZ. lra.
Qed.


Lemma Rpow_le1: forall (x : R) (n : nat), 0 <= x <= 1 -> x ^ n <= 1.
Proof.
  intros; induction n.
  - simpl; lra.
  - simpl.
    rewrite <- Rmult_1_r.
    apply Rmult_le_compat; try lra.
    apply pow_le; lra.
Qed.
    
(* The other side of Rle_pow, needed below *)
Lemma Rle_pow_le1: forall (x : R) (m n : nat), 0 <= x <= 1 -> (m <= n)%nat -> x ^ n <= x ^ m.
Proof.
  intros x m n [G0 L1] L.
  remember (n - m)%nat as p.
  replace n with (m+p)%nat in * by lia.
  clear -G0 L1.
  rewrite pow_add.
  rewrite <- Rmult_1_r.
  apply Rmult_le_compat; try lra.
  apply pow_le; trivial.
  apply pow_le; trivial.
  apply Rpow_le1; lra.
Qed.

(******************)
(* Sum Over Reals *)
(******************)

Definition Rsum (n : nat) (f : nat -> R) : R :=
  match n with
  | O => 0
  | S n => sum_f_R0 f n
  end.

Lemma Rsum_eq :
  forall n f1 f2,
    (forall i, f1 i = f2 i) -> Rsum n f1 = Rsum n f2.
Proof.
  intros. induction n.
  - easy.
  - simpl. destruct n.
    + simpl. apply H.
    + simpl. simpl in IHn. rewrite IHn. rewrite H. easy.
Qed.

Lemma Rsum_eq_bounded :
  forall n f1 f2,
    (forall i, (i < n)%nat -> f1 i = f2 i) -> Rsum n f1 = Rsum n f2.
Proof.
  intros. 
  induction n; simpl.
  reflexivity.
  destruct n; simpl.
  apply H. lia.
  simpl in IHn. rewrite IHn. 
  rewrite H by lia. easy.
  intros. apply H; lia.
Qed.

Lemma Rsum_extend : forall n (f : nat -> R),
  Rsum (S n) f = (f n + Rsum n f)%R.
Proof. intros. destruct n; simpl; lra. Qed.

Lemma Rsum_shift : forall n (f : nat -> R),
  Rsum (S n) f = (f O + Rsum n (fun x => f (S x)))%R.
Proof.
  intros n f. 
  simpl.
  induction n; simpl.
  lra.
  rewrite IHn.
  destruct n; simpl; lra.
Qed.

Lemma Rsum_plus_range : forall m n f,
  Rsum (m + n) f = (Rsum m f + Rsum n (fun x => f (x + m)%nat))%R.
Proof.
  intros m n f.
  induction n.
  simpl. 
  rewrite Nat.add_0_r. 
  lra.
  replace (m + S n)%nat with (S (m + n)) by lia. 
  rewrite 2 Rsum_extend.
  rewrite IHn.
  rewrite Nat.add_comm.
  lra.
Qed.

Lemma Rsum_twice : forall n f,
  Rsum (2 * n) f = (Rsum n f + Rsum n (fun x => f (x + n)%nat))%R.
Proof.
  intros n f. replace (2 * n)%nat with (n + n)%nat by lia. apply Rsum_plus_range.
Qed.

Lemma Rsum_plus: forall n f g,
  Rsum n (fun x => (f x + g x)%R) = ((Rsum n f) + (Rsum n g))%R.
Proof.
  intros n f g.
  induction n.
  simpl. lra.
  repeat rewrite Rsum_extend.
  rewrite IHn. lra.
Qed.

Lemma nested_Rsum : forall m n f,
  Rsum (2 ^ (m + n)) f 
    = Rsum (2 ^ m) (fun x => Rsum (2 ^ n) (fun y => f (x * 2 ^ n + y)%nat)).
Proof.
  intros m n.
  replace (2 ^ (m + n))%nat with (2 ^ n * 2 ^ m)%nat by (rewrite Nat.pow_add_r; lia).
  induction m; intro f.
  simpl.
  rewrite Nat.mul_1_r.
  reflexivity.
  replace (2 ^ n * 2 ^ S m)%nat with (2 * (2 ^ n * 2 ^ m))%nat by (simpl; lia).
  replace (2 ^ S m)%nat with (2 * 2 ^ m)%nat by (simpl; lia).
  rewrite 2 Rsum_twice.
  rewrite 2 IHm.
  apply f_equal2; try reflexivity.
  apply Rsum_eq.
  intro x.
  apply Rsum_eq.
  intro y.
  apply f_equal.
  lia.
Qed.

Lemma Rsum_scale : forall n f r,
  (r * Rsum n f = Rsum n (fun x => r * f x))%R.
Proof.
  intros n f r.
  induction n.
  simpl. lra.
  rewrite 2 Rsum_extend.
  rewrite <- IHn. lra.
Qed.

Lemma Rsum_0 : forall f n, (forall x : nat, f x = 0) -> Rsum n f = 0.
Proof.
  intros f n Hf. 
  induction n. reflexivity. 
  rewrite Rsum_extend, IHn, Hf. lra.
Qed.

(****************)
(* Square Roots *)
(****************)

Lemma pow2_sqrt : forall x:R, 0 <= x -> (√ x) ^ 2 = x.
Proof. intros; simpl; rewrite Rmult_1_r, sqrt_def; auto. Qed.

Lemma sqrt_pow : forall (r : R) (n : nat), (0 <= r)%R -> (√ (r ^ n) = √ r ^ n)%R.
Proof.
  intros r n Hr.
  induction n.
  simpl. apply sqrt_1.
  rewrite <- 2 tech_pow_Rmult.
  rewrite sqrt_mult_alt by assumption.
  rewrite IHn. reflexivity.
Qed.

Lemma pow2_sqrt2 : (√ 2) ^ 2 = 2.
Proof. apply pow2_sqrt; lra. Qed.

Lemma pown_sqrt : forall (x : R) (n : nat), 
  0 <= x -> √ x ^ (S (S n)) = x * √ x ^ n.
Proof.
  intros. simpl. rewrite <- Rmult_assoc. rewrite sqrt_sqrt; auto.
Qed.  

Lemma sqrt_neq_0_compat : forall r : R, 0 < r -> √ r <> 0.
Proof. intros. specialize (sqrt_lt_R0 r). lra. Qed.

Lemma sqrt_inv : forall (r : R), 0 < r -> √ (/ r) = (/ √ r)%R.
Proof.
  intros.
  replace (/r)%R with (1/r)%R by lra.
  rewrite sqrt_div_alt, sqrt_1 by lra.
  lra.
Qed.  

Lemma sqrt2_div2 : (√ 2 / 2)%R = (1 / √ 2)%R.
Proof.
   field_simplify_eq; try (apply sqrt_neq_0_compat; lra).
   rewrite pow2_sqrt2; easy.
Qed.

Lemma sqrt2_inv : √ (/ 2) = (/ √ 2)%R.
Proof. apply sqrt_inv; lra. Qed.  

Lemma sqrt_sqrt_inv : forall (r : R), 0 < r -> (√ r * √ / r)%R = 1.
Proof. 
  intros. 
  rewrite sqrt_inv; trivial. 
  rewrite Rinv_r; trivial. 
  apply sqrt_neq_0_compat; easy.
Qed.

Lemma sqrt2_sqrt2_inv : (√ 2 * √ / 2)%R = 1.
Proof. apply sqrt_sqrt_inv. lra. Qed.

Lemma sqrt2_inv_sqrt2 : ((√ / 2) * √ 2)%R = 1.
Proof. rewrite Rmult_comm. apply sqrt2_sqrt2_inv. Qed.

Lemma sqrt2_inv_sqrt2_inv : ((√ / 2) * (√ / 2) = /2)%R.
Proof. 
  rewrite sqrt2_inv. field_simplify. 
  rewrite pow2_sqrt2. easy. 
  apply sqrt_neq_0_compat; lra. 
Qed.

Lemma sqrt_1_unique : forall x, 1 = √ x -> x = 1.
Proof. intros. assert (H' := H). unfold sqrt in H. destruct (Rcase_abs x).
       - apply R1_neq_R0 in H; easy. 
       - rewrite <- (sqrt_def x); try rewrite <- H'; lra.
Qed.

Lemma lt_ep_helper : forall (ϵ : R),
  ϵ > 0 <-> ϵ / √ 2 > 0.
Proof. intros; split; intros. 
       - unfold Rdiv. 
         apply Rmult_gt_0_compat; auto; 
           apply Rinv_0_lt_compat; apply Rlt_sqrt2_0.
       - rewrite <- (Rmult_1_r ϵ).
         rewrite <- (Rinv_l (√ 2)), <- Rmult_assoc.
         apply Rmult_gt_0_compat; auto. 
         apply Rlt_sqrt2_0.
         apply sqrt2_neq_0.
Qed.


(* Automation *)
Ltac R_field_simplify := repeat field_simplify_eq [pow2_sqrt2 sqrt2_inv].
Ltac R_field := R_field_simplify; easy.

(* Trigonometry *)

Lemma sin_upper_bound_aux : forall x : R, 0 < x < 1 -> sin x <= x.
Proof.
  intros x H.
  specialize (SIN_bound x) as B.
    destruct (SIN x) as [_ B2]; try lra.
    specialize PI2_1 as PI1. lra.
    unfold sin_ub, sin_approx in *.
    simpl in B2.
    unfold sin_term at 1 in B2.
    simpl in B2.
    unfold Rdiv in B2.
    rewrite Rinv_1, Rmult_1_l, !Rmult_1_r in B2.
    (* Now just need to show that the other terms are negative... *)
    assert (sin_term x 1 + sin_term x 2 + sin_term x 3 + sin_term x 4 <= 0); try lra.
    unfold sin_term.
    remember (INR (fact (2 * 1 + 1))) as d1.
    remember (INR (fact (2 * 2 + 1))) as d2.
    remember (INR (fact (2 * 3 + 1))) as d3.
    remember (INR (fact (2 * 4 + 1))) as d4.
    assert (0 < d1) as L0.
    { subst. apply lt_0_INR. apply lt_O_fact. }
    assert (d1 <= d2) as L1.
    { subst. apply le_INR. apply fact_le. simpl; lia. }
    assert (d2 <= d3) as L2.
    { subst. apply le_INR. apply fact_le. simpl; lia. }
    assert (d3 <= d4) as L3.
    { subst. apply le_INR. apply fact_le. simpl; lia. }
    simpl.    
    ring_simplify.
    assert ( - (x * (x * (x * 1)) / d1) + x * (x * (x * (x * (x * 1)))) / d2 <= 0).
    rewrite Rplus_comm.
    apply Rle_minus.
    field_simplify; try lra.
    assert (x ^ 5 <= x ^ 3).
    { apply Rle_pow_le1; try lra; try lia. }
    apply Rmult_le_compat; try lra.
    apply pow_le; lra.
    left. apply Rinv_0_lt_compat. lra.
    apply Rinv_le_contravar; lra.
    unfold Rminus.
    assert (- (x * (x * (x * (x * (x * (x * (x * 1)))))) / d3) +
            x * (x * (x * (x * (x * (x * (x * (x * (x * 1)))))))) / d4 <= 0).
    rewrite Rplus_comm.
    apply Rle_minus.
    field_simplify; try lra.
    assert (x ^ 9 <= x ^ 7).
    { apply Rle_pow_le1; try lra; try lia. }
    apply Rmult_le_compat; try lra.
    apply pow_le; lra.
    left. apply Rinv_0_lt_compat. lra.
    apply Rinv_le_contravar; lra.
    lra.
Qed.

Lemma sin_upper_bound : forall x : R, Rabs (sin x) <= Rabs x.
Proof.
  intros x.  
  specialize (SIN_bound x) as B.
  destruct (Rlt_or_le (Rabs x) 1).
  (* abs(x) > 1 *)
  2:{ apply Rabs_le in B. lra. }
  destruct (Rtotal_order x 0) as [G | [E| L]].
  - (* x < 0 *)
    rewrite (Rabs_left x) in * by lra.
    rewrite (Rabs_left (sin x)).
    2:{ apply sin_lt_0_var; try lra.
        specialize PI2_1 as PI1.
        lra. }
    rewrite <- sin_neg.
    apply sin_upper_bound_aux.
    lra.
  - (* x = 0 *)
    subst. rewrite sin_0. lra.
  - rewrite (Rabs_right x) in * by lra.
    rewrite (Rabs_right (sin x)).
    2:{ apply Rle_ge.
        apply sin_ge_0; try lra.
        specialize PI2_1 as PI1. lra. }
    apply sin_upper_bound_aux; lra.
Qed.    


Hint Rewrite sin_0 sin_PI4 sin_PI2 sin_PI cos_0 cos_PI4 cos_PI2 cos_PI sin_neg cos_neg : trig_db.



(** some glb support! (this might exist already, but I could not find it) *) 


Definition is_lower_bound (E:R -> Prop) (m:R) := forall x:R, E x -> m <= x.

Definition bounded_below (E:R -> Prop) := exists m : R, is_lower_bound E m.

Definition is_glb (E:R -> Prop) (m:R) :=
  is_lower_bound E m /\ (forall b:R, is_lower_bound E b -> b <= m).

Definition neg_Rset (E : R -> Prop) :=
  fun r => E (-r).

Lemma lb_negset_ub : forall (E : R -> Prop) (b : R),
  is_lower_bound E b <-> is_upper_bound (neg_Rset E) (-b).
Proof. unfold is_lower_bound, is_upper_bound, neg_Rset; split; intros.
       - apply H in H0; lra. 
       - rewrite <- Ropp_involutive in H0. 
         apply H in H0; lra.
Qed.

Lemma ub_negset_lb : forall (E : R -> Prop) (b : R),
  is_upper_bound E b <-> is_lower_bound (neg_Rset E) (-b).
Proof. unfold is_lower_bound, is_upper_bound, neg_Rset; split; intros.
       - apply H in H0; lra. 
       - rewrite <- Ropp_involutive in H0. 
         apply H in H0; lra.
Qed.

Lemma negset_bounded_above : forall (E : R -> Prop),
  bounded_below E -> (bound (neg_Rset E)).
Proof. intros. 
       destruct H.
       exists (-x).
       apply lb_negset_ub; easy.
Qed.

Lemma negset_glb : forall (E : R -> Prop) (m : R),
  is_lub (neg_Rset E) m -> is_glb E (-m).
Proof. intros.  
       destruct H; split. 
       - apply lb_negset_ub.
         rewrite Ropp_involutive; easy. 
       - intros. 
         apply lb_negset_ub in H1.
           apply H0 in H1; lra.
Qed.

Lemma glb_completeness :
  forall E:R -> Prop,
    bounded_below E -> (exists x : R, E x) -> { m:R | is_glb E m }.
Proof. intros.  
       apply negset_bounded_above in H.
       assert (H' : exists x : R, (neg_Rset E) x).
       { destruct H0; exists (-x).
         unfold neg_Rset; rewrite Ropp_involutive; easy. }
       apply completeness in H'; auto.
       destruct H' as [m [H1 H2] ].
       exists (-m).
       apply negset_glb; easy.
Qed.



(* Showing that R is a field, and a vector space over itself *)

Program Instance R_is_monoid : Monoid R := 
  { Gzero := 0
  ; Gplus := Rplus
  }.
Solve All Obligations with program_simpl; try lra.

Program Instance R_is_group : Group R :=
  { Gopp := Ropp }.
Solve All Obligations with program_simpl; try lra.

Program Instance R_is_comm_group : Comm_Group R.
Solve All Obligations with program_simpl; lra. 

Program Instance R_is_ring : Ring R :=
  { Gone := 1
  ; Gmult := Rmult
  }.
Solve All Obligations with program_simpl; lra. 

Program Instance R_is_comm_ring : Comm_Ring R.
Solve All Obligations with program_simpl; lra. 
                                                     
Program Instance R_is_field : Field R :=
  { Ginv := Rinv }.
Next Obligation. 
  rewrite Rinv_r; easy.
Qed.

Program Instance R_is_vector_space : Vector_Space R R :=
  { Vscale := Rmult }.
Solve All Obligations with program_simpl; lra. 



(* some big_sum lemmas specific to R *)

Lemma Rsum_le : forall (f g : nat -> R) (n : nat),
  (forall i, (i < n)%nat -> f i <= g i) ->
  (big_sum f n) <= (big_sum g n).
Proof. induction n as [| n']; simpl; try lra.  
       intros.
       apply Rplus_le_compat.
       apply IHn'; intros. 
       all : apply H; try lia. 
Qed.

Lemma Rsum_ge_0 : forall (f : nat -> R) (n : nat),
  (forall i, (i < n)%nat -> 0 <= f i) ->
  0 <= big_sum f n.
Proof. induction n as [| n'].
       - intros; simpl; lra. 
       - intros. simpl; apply Rplus_le_le_0_compat.
         apply IHn'; intros; apply H; lia. 
         apply H; lia. 
Qed.
