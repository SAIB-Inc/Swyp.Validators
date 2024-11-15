use cardano/transaction.{OutputReference, Transaction}
use cpmm/types/pool.{Deposit, PoolDatum, PoolRedeemer, Swap, Withdraw}

validator cpmm {
  spend(
    datum: Option<PoolDatum>,
    redeemer: PoolRedeemer,
    _own_ref: OutputReference,
    self: Transaction,
  ) {
    expect Some(datum) = datum
    when redeemer is {
      Swap { id, asset } -> True
      Deposit { id, assets } -> True
      Withdraw { id, lp } -> True
    }
  }

  else(_) {
    fail
  }
}
