use shared.{Asset, AssetClass}

/// State of a Liquidity Pool.
pub type PoolDatum {
  /// The unique identifier of the pool. Derived from one of the UTxOs that was used to create the pool.
  /// This will also serve as the asset name for the LP tokens to be minted by the pool.
  id: ByteArray,
  /// The two assets that the pool will be trading.
  /// Assets must be unique and in a specific order. 
  assets: (AssetClass, AssetClass),
  /// The amount of the LPs minted that's currently in circulation.
  /// This is used to calculate the share of the pool that each LP token holder owns.
  /// The creator of the pool will be able to mint a certain amount of LP initially as a starting point.
  circulating_lp: Int,
  /// The amount of fee that the pool will charge for each swap.
  /// Fee is fixed and cannot be changed after the pool is created.
  fee: Int,
  /// The amount of fee that the platform will charge for each swap.
  /// Fee can be updated by an authorized wallet.
  protocol_fee: Int,
}

/// Redeemer for minting LP tokens.
pub type PoolMintRedeemer {
  /// The assets traded by the pool. This is used to verify if the pool was properly created
  /// and to calculate the amount of LP tokens to mint initially. 
  CreatePool { assets: (AssetClass, AssetClass) }
  /// The unique identifier of the pool to be removed.
  /// The owner of the pool must burn all the LP tokens in circulation before removing the pool.
  RemovePool { id: ByteArray }
  /// The amount of LP tokens to mint in for depositing to the liquidity pool.
  MintLP { id: ByteArray }
  /// The amount of LP tokens to burn in for withdrawing from the liquidity pool.
  BurnLP { id: ByteArray }
}

/// Redeemer for swapping assets, depositing, and withdrawing from the pool.
pub type PoolRedeemer {
  /// Asset contains the policy id, asset name and quantity of the asset to be swapped.
  Swap { id: ByteArray, asset: Asset }
  /// The amount of assets to deposit.
  Deposit { id: ByteArray, assets: (Asset, Asset) }
  /// The amount of LP tokens to withdraw.
  Withdraw { id: ByteArray, lp: Int }
}
