-- Filename:TreasureEvolveService.lua
-- Author: 	lichenyang
-- Date: 	2014-1-7
-- Purpose: 宝物升级网络处理

module("TreasureEvolveService", package.seeall)

require "script/ui/treasure/evolve/TreasureEvolveUtil"
require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"

function evolve( treasure_id,callback )
	local 	treasureInfo 	= ItemUtil.getItemInfoByItemId(tonumber(treasure_id))
	if(table.isEmpty(treasureInfo))then
		treasureInfo 		= ItemUtil.getTreasInfoFromHeroByItemId(tonumber(treasure_id))
	end
	
	if(tonumber(treasureInfo.va_item_text.treasureLevel) == 0) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2662"))
		return
	end

	if(tonumber(treasureInfo.va_item_text.treasureEvolve) >= tonumber(treasureInfo.itemDesc.max_upgrade_level)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2873"))
		return
	end

	local cost_info = TreasureEvolveUtil.getEvolveCostInfo(treasureInfo.item_id, tonumber(treasureInfo.va_item_text.treasureEvolve) + 1)
	if(tonumber(cost_info.silver) > UserModel.getSilverNumber()) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2765"))
		return
	end
	for k,v in pairs(cost_info.items) do
		local haveNum = TreasureEvolveUtil.getItemNumByTid(v.tid, treasure_id)
		if(haveNum < tonumber(v.num)) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1708"))
			return
		end
	end

	local function requestFunc( cbFlag, dictData, bRet )
		-- print ("getMailBoxList---后端数据")
		if(bRet == true)then

			--修改消耗消耗银币
			UserModel.addSilverNumber(-tonumber(cost_info.silver))
			--修改缓存属性
			TreasureEvolveUtil.setTreasureEvolve(treasure_id ,dictData.ret.va_item_text.treasureEvolve)
			if(callback ~= nil) then
				callback()
			end
		end
	end
	-- 参数
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(treasure_id)))
	local twoParm = CCArray:create()
	for k,v in pairs(cost_info.items) do
		for key,idValue in pairs(v.id) do
			twoParm:addObject(CCInteger:create(tonumber(idValue)))
		end
	end
	args:addObject(twoParm)
	Network.rpc(requestFunc, "forge.evolve", "forge.evolve", args, true)
end




