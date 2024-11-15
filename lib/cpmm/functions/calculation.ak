use aiken/math
use cpmm/constants.{bips_denominator}

/// Check if the ratio between two numbers is preserved
pub fn reserve_ratio_preserved(
  original_reserves: (Int, Int),
  new_reserves: (Int, Int),
) -> Bool {
  let original_ratio_bips =
    calculate_ratio_bips(original_reserves.1st, original_reserves.2nd)
  let new_ratio_bips = calculate_ratio_bips(new_reserves.1st, new_reserves.2nd)
  original_ratio_bips == new_ratio_bips
}

// Calculate ratio with bips precision (1/10000)
pub fn calculate_ratio_bips(a: Int, b: Int) -> Int {
  a * 10000 / b
}

test preserve_ratio() {
  reserve_ratio_preserved((100, 200), (200, 400))
}

test different_ratio() fail {
  reserve_ratio_preserved((100, 200), (200, 300))
}

pub fn calculate_lp_tokens_to_mint(
  current_lp_supply: Int,
  current_reserve_a: Int,
  current_reserve_b: Int,
  deposit_amount_a: Int,
  deposit_amount_b: Int,
) -> Int {
  // Calculate share in BIPS (what percentage of the pool they're providing)
  let share_bips_a = calculate_share_bips(current_reserve_a, deposit_amount_a)
  let share_bips_b = calculate_share_bips(current_reserve_b, deposit_amount_b)

  // Calculate LP tokens based on share
  let share_a = current_lp_supply * share_bips_a / bips_denominator
  let share_b = current_lp_supply * share_bips_b / bips_denominator

  // Return the smaller share
  math.min(share_a, share_b)
}

// Calculate what share of the pool they're providing in BIPS
pub fn calculate_share_bips(pool_amount: Int, deposit_amount: Int) -> Int {
  deposit_amount * bips_denominator / pool_amount
}

test calculate_mint() {
  let mint_amount =
    calculate_lp_tokens_to_mint(
      current_lp_supply: 1000,
      current_reserve_a: 100,
      current_reserve_b: 200,
      deposit_amount_a: 50,
      deposit_amount_b: 100,
    )
  // Providing 50% more liquidity (5000 BIPS)
  // Should get 500 LP tokens (50% of current supply)
  mint_amount == 500
}
