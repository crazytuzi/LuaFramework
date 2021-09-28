-- Filename：	EquipFixedService.lua
-- Author：		李晨阳
-- Date：		2013-7-26
-- Purpose：		装备洗练

module("EquipFixedService", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/EquipFixedData"
require "script/model/user/UserModel"

--[[
	@des	:	洗练
	@param	:	item_id, 物品id , fixed_type, 洗练类型（1，普通洗练 2，银币洗练 3, 高级洗练）times, 洗练次数 callbackFunc, 回调方法
]]
function fixedRefresh( item_id, fixed_type, times,callbackFunc )

	print("fixedRefresh times:", times)	
	local fixedTimes = times or 1
	if(EquipFixedData.checkFixedRefreshLogic(item_id ,fixed_type, times) == false) then
		print(GetLocalizeStringBy("key_2718"))
		return
	end
	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
    if(equipInfo   == nil )then
        equipInfo   = ItemUtil.getEquipInfoFromHeroByItemId(item_id)
    end
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			print_t(dictData.ret)
			if(callbackFunc ~= nil) then
				EquipFixedData.modifyItemFixedPotentiality(item_id,dictData.ret.potence)
				--更新洗练石
				local costInfo= EquipFixedData.getFixedCost(equipInfo.itemDesc.fixedPotentialityID, fixed_type)
				EquipFixedData.fixedStoneNum = EquipFixedData.fixedStoneNum - tonumber(costInfo.item.num) * fixedTimes

				-- print(GetLocalizeStringBy("key_3167"))
				-- print_t(costInfo)
				--更新金币
				if(costInfo.gold ~= nil) then
					UserModel.addGoldNumber(- tonumber(costInfo.gold) * fixedTimes)
				end
				--更新银币
				if(costInfo.silver ~= nil) then
					UserModel.addSilverNumber(- tonumber(costInfo.silver) * fixedTimes)
				end
				callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(item_id)))
	args:addObject(CCInteger:create(fixed_type))
	args:addObject(CCInteger:create(fixedTimes))
	Network.rpc(requestFunc, "forge.fixedRefresh", "forge.fixedRefresh", args, true)
end

--一键洗炼
function fixedOneKey( item_id, fixed_type,callbackFunc )
	local fixedTimes = times or 1
	if(EquipFixedData.checkFixedRefreshLogic(item_id ,fixed_type, 1) == false) then
		print(GetLocalizeStringBy("key_2718"))
		return
	end
	local equipInfo = ItemUtil.getItemInfoByItemId(item_id)
    if(equipInfo   == nil )then
        equipInfo   = ItemUtil.getEquipInfoFromHeroByItemId(item_id)
    end
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			print_t(dictData.ret)
			if(callbackFunc ~= nil) then
				EquipFixedData.modifyItemFixedPotentiality(item_id,dictData.ret.potence)
				--更新洗练石
				local costInfo= EquipFixedData.getFixedCost(equipInfo.itemDesc.fixedPotentialityID, fixed_type)
				EquipFixedData.fixedStoneNum = EquipFixedData.fixedStoneNum - tonumber(costInfo.item.num) * (dictData.ret.num)

				--更新金币
				if(costInfo.gold ~= nil) then
					UserModel.addGoldNumber(- tonumber(costInfo.gold) * tonumber(dictData.ret.num))
				end
				--更新银币
				if(costInfo.silver ~= nil) then
					UserModel.addSilverNumber(- tonumber(costInfo.silver) * tonumber(dictData.ret.num))
				end
				callbackFunc(dictData.ret.num)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(item_id)))
	args:addObject(CCInteger:create(fixed_type))
	Network.rpc(requestFunc, "forge.autoFixedRefresh", "forge.autoFixedRefresh", args, true)
end

--[[
	@des	:	固定洗练确认
]]

function fixedRefreshAffirm( item_id,callbackFunc )
	local requestFunc = function ( cbFlag, dictData, bRet )
		if(bRet == true) then
			print_t(dictData.ret)
			if(callbackFunc ~= nil) then
				EquipFixedData.modifyItemPotentiality(item_id)
				callbackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(item_id)))
	Network.rpc(requestFunc, "forge.fixedRefreshAffirm", "forge.fixedRefreshAffirm", args, true)
end
