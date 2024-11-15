use cardano/assets.{AssetName, PolicyId, ada_asset_name, ada_policy_id}

/// AssetClass is a tuple of PolicyId and AssetName that uniquely identifies an asset.
pub type AssetClass =
  (PolicyId, AssetName)

/// AssetClass with the amount of the asset.
pub type Asset =
  (AssetClass, Int)

/// Checks whether the given asset class is ada
pub fn is_ada(asset: AssetClass) -> Bool {
  let (policy_id, asset_name) = asset
  policy_id == ada_policy_id && asset_name == ada_asset_name
}

/// Check whether two asset classes are the same
pub fn is_same_asset_class(asset1: AssetClass, asset2: AssetClass) -> Bool {
  let (policy_id1, asset_name1) = asset1
  let (policy_id2, asset_name2) = asset2
  policy_id1 == policy_id2 && asset_name1 == asset_name2
}
