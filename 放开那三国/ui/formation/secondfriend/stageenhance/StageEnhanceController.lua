-- FileName : StageEnhanceController.lua
-- Author   : YangRui
-- Date     : 2015-12-07
-- Purpose  : 

module("StageEnhanceController", package.seeall)

--[[
	@des 	: 强化某个属性小伙伴位置
	@param 	: 
	@return : 
--]]
function strengthAttrExtra( pCurLv, pIndex , pCallback )
	-- 判断是否达到强化上限
	local maxLv =  StageEnhanceData.getEnhanceMaxLv(pIndex)
	if pCurLv >= maxLv then
		AnimationTip.showTip(GetLocalizeStringBy("yr_7012"))
		return
	end
	-- 判断所需材料是否满足
	local silverCost,needItemId,needItemNum = StageEnhanceData.getNextLvEnhanceCost(pCurLv+1)
	local haveResNum = ItemUtil.getCacheItemNumBy(needItemId)
	if haveResNum < needItemNum then
		AnimationTip.showTip(GetLocalizeStringBy("yr_7008"))
		return
	end
	local haveSilverNum = UserModel.getSilverNumber()
	if silverCost > haveSilverNum then
		AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
		return
	end
	local requestCallback = function( pData )
		-- 添加强化等级
		StageEnhanceData.addCurStageLv(pIndex)
		-- 减少所需物品
		StageEnhanceData.addNeedItemNum(-needItemNum)
		-- 扣除银币
		UserModel.addSilverNumber(-silverCost)
		-- 提示强化成功
		AnimationTip.showTip(GetLocalizeStringBy("yr_7009"))
		-- 刷新UI
		StageEnhanceLayer.updateUI()
		if pCallback ~= nil then
			pCallback()
		end
	end
	StageEnhanceService.strengthAttrExtra(pIndex-1,requestCallback)
end

--[[
	@des 	: 获取属性小伙伴位置的等级
	@param 	: 
	@return : 
--]]
function getAttrExtraLevel( pCallback )
	local requestCallback = function( pData )
		if pCallback ~= nil then
			pCallback()
		end
	end
	StageEnhanceService.getAttrExtraLevel(requestCallback)
end
