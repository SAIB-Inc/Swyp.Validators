use aiken/cbor
use aiken/collection/list
use aiken/crypto.{blake2b_256}
use cardano/assets.{PolicyId, Value}
use cardano/transaction.{InlineDatum, Output, OutputReference}
use cpmm/constants.{lp_initial_mint, protocol_fee}
use cpmm/functions/calculation.{
  calculate_lp_tokens_to_mint, reserve_ratio_preserved,
}
use cpmm/types/pool.{PoolDatum}
use shared.{Asset, AssetClass, is_same_asset_class}

pub fn do_create_pool(
  assets: (AssetClass, AssetClass),
  input_out_ref: OutputReference,
  pool_output: Output,
  mint_value: Value,
  lp_policy_id: PolicyId,
) -> Bool {
  // Check if the pool is created with valid assets
  let valid_pair = !is_same_asset_class(assets.1st, assets.2nd)

  let reserve_x =
    pool_output.value |> assets.quantity_of(assets.1st.1st, assets.1st.2nd)
  let reserve_y =
    pool_output.value |> assets.quantity_of(assets.2nd.1st, assets.2nd.2nd)
  let valid_reserves = reserve_x > 0 && reserve_y > 0

  expect InlineDatum(inline_datum) = pool_output.datum
  expect datum: PoolDatum = inline_datum

  // Check if the pool id is correct
  let pool_id = datum.id
  let expected_pool_id = cbor.serialise(input_out_ref) |> blake2b_256()
  let correct_pool_id = pool_id == expected_pool_id

  // Check if the LP tokens minted and the datum circulating LP is correct
  let minted_lp = mint_value |> assets.quantity_of(lp_policy_id, pool_id)
  let expected_minted_lp = lp_initial_mint
  let datum_circulating_lp = datum.circulating_lp
  let correct_lp_mint =
    minted_lp == expected_minted_lp && datum_circulating_lp == expected_minted_lp

  // Correct protocol fee
  let correct_protocol_fee = datum.protocol_fee == protocol_fee

  and {
    valid_pair,
    valid_reserves,
    correct_pool_id,
    correct_lp_mint,
    correct_protocol_fee,
  }
}

pub fn do_mint_lp(
  deposit_assets: (Asset, Asset),
  old_reserve_assets: (Asset, Asset),
  new_reserve_assets: (Asset, Asset),
  old_pool_datum: PoolDatum,
  pool_output: Output,
  mint_value: Value,
  lp_policy_id: PolicyId,
) -> Bool {
  expect InlineDatum(inline_datum) = pool_output.datum
  expect datum: PoolDatum = inline_datum

  let old_pool_id = old_pool_datum.id
  let new_pool_id = datum.id

  let pool_id_preserved = old_pool_id == new_pool_id

  let (old_reserve_a, old_reserve_b) = old_reserve_assets
  let (new_reserve_a, new_reserve_b) = new_reserve_assets

  // Check if the assets are preserved
  let reserves_preserved =
    old_reserve_a.1st == new_reserve_a.1st && old_reserve_b.1st == new_reserve_b.1st

  // Check if the ratio between the reserves is preserved
  let ratio_preserved =
    reserve_ratio_preserved(
      (old_reserve_a.2nd, old_reserve_b.2nd),
      (new_reserve_a.2nd, new_reserve_b.2nd),
    )

  // Check if the deposited asset quantity are greater than 0
  let deposit_a = deposit_assets.1st.2nd
  let deposit_b = deposit_assets.2nd.2nd
  let deposit_a_gt_0 = deposit_a > 0
  let deposit_b_gt_0 = deposit_b > 0

  // Get the correct LP tokens to mint
  let current_lp_supply = old_pool_datum.circulating_lp
  let minted_lp = mint_value |> assets.quantity_of(lp_policy_id, new_pool_id)
  let expected_minted_lp =
    calculate_lp_tokens_to_mint(
      current_lp_supply,
      old_reserve_a.2nd,
      old_reserve_b.2nd,
      deposit_a,
      deposit_b,
    )
  let correct_lp_mint = minted_lp == expected_minted_lp

  // Check if the circulating LP is updated correctly
  let expected_circulating_lp = current_lp_supply + minted_lp
  let correct_circulating_lp = datum.circulating_lp == expected_circulating_lp

  and {
    pool_id_preserved,
    reserves_preserved,
    ratio_preserved,
    deposit_a_gt_0,
    deposit_b_gt_0,
    correct_lp_mint,
    correct_circulating_lp,
  }
}
