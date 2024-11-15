/// Identifier for the Pool NFT token
pub const nft_suffix: ByteArray = #"4c505f4e4654"

/// Initial minting amount for LP tokens when a pool is created
pub const lp_initial_mint: Int = 100_000_000

/// Fixed initial protocol fee for each swap
/// Can be updated by authorized wallet later
/// Value is in bips (1 bip = 0.01%)
pub const protocol_fee: Int = 30

/// BIPS denominator
/// for on chain calculations
pub const bips_denominator: Int = 10000
