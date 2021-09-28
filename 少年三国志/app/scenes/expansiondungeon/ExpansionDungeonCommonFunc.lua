local ExpansionDungeonCommonFunc = {}

function ExpansionDungeonCommonFunc.isCostEnough(nType, nCount)
	if type(nType) ~= "number" or type(nCount) ~= "number" then
		return false
	end

	local isEnough = false
	if nType == G_Goods.TYPE_TILI then
		isEnough = G_Me.userData.vit >= nCount
	end
	return isEnough
end

return ExpansionDungeonCommonFunc