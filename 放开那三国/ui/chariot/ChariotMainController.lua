-- FileName: ChariotMainController.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车系统控制层

module("ChariotMainController", package.seeall)

require "script/ui/chariot/ChariotMainData"
require "script/ui/chariot/ChariotMainLayer"
require "script/ui/chariot/ChariotMainService"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/ui/tip/AnimationTip"

--[[
	@desc   : 装备战车
    @param  : pPos 位置 pItemId 战车物品Id
    @return : 
--]]
function equip( pCallback, pPos, pItemId )
	-- 判断装备条件
	local needLevel,needType = ChariotMainData.getCanEquipLvAndTypeByPos(pPos)
	local curChariotInfo = ItemUtil.getItemByItemId(pItemId)

	-- 获取之前位置上的战车
	local oldChariotInfo = ChariotMainData.getEquipChariotInfoByPos(pPos)

	-- 1.战车的类型是否符合
	if (needType ~= curChariotInfo.itemDesc.warcar_type) then
		-- 战车的类型不对
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1089"))
		return
	end

	-- 2.玩家等级是否符合
	if (UserModel.getHeroLevel() < needLevel) then
		-- 玩家等级不够
		AnimationTip.showTip(GetLocalizeStringBy("key_1155")..needLevel)
		return
	end

	local serviceCallBack = function ( pData )
		-- 更新战车装备信息 背包里获取
		ChariotMainData.updateChariotInfoByPos(curChariotInfo,pPos)

		-- 记录将要更换下来的战车的 item_id，背包红点用
		require "script/ui/bag/BagUtil"
		if not table.isEmpty(oldChariotInfo) then
			BagUtil.recordUnequipedChariot(oldChariotInfo.item_id)
		end

		-- 更新UI界面显示
		ChariotMainLayer.updateCellByPos(pPos)

		-- 属性飘字
		require "script/ui/chariot/ChariotUtil"
		ChariotUtil.showChariotAttrTip(curChariotInfo,oldChariotInfo)

		-- 更换时，记录被替换的战车id，用于背包红点排除
		require "script/ui/bag/BagUtil"
		if not table.isEmpty(oldChariotInfo) then
			BagUtil.recordUnequipedChariot(oldChariotInfo.item_id)
		end


		if pCallback then
			pCallback()
		end
	end
	ChariotMainService.equip(serviceCallBack,pPos,pItemId)
end

--[[
	@desc   : 卸下战车
    @param  : pPos 位置 pItemId 战车物品Id
    @return : 
--]]
function unEquip( pCallback, pPos, pItemId )
	-- 判断卸下条件
	-- 1.判断背包是否满
    if(ItemUtil.isBagFull() == true )then
    	-- 关闭战车信息
    	require "script/ui/chariot/ChariotInfoLayer"
		ChariotInfoLayer.closeSelfCallBack()
        return
    end

    -- 获取之前位置上的战车
	local oldChariotInfo = ChariotMainData.getEquipChariotInfoByPos(pPos)

	local serviceCallBack = function ( pData )
		-- 更新战车装备信息
		ChariotMainData.updateChariotInfoByPos(nil,pPos)

		-- 记录刚卸下的战车的 item_id，背包红点用
		require "script/ui/bag/BagUtil"
		BagUtil.recordUnequipedChariot(pItemId)

		-- 更新UI界面显示
		ChariotMainLayer.updateCellByPos(pPos)

		-- 属性飘字
		require "script/ui/chariot/ChariotUtil"
		ChariotUtil.showChariotAttrTip(nil,oldChariotInfo)

		if pCallback then
			pCallback()
		end
	end
	ChariotMainService.unEquip(serviceCallBack,pPos,pItemId)
end

--[[
	@desc   : 强化战车
    @param  : pPos 位置 pItemId 战车物品Id
    @return : 
--]]
function enforce( pCallback, pPos, pItemId )
	-- 判断强化条件
	local chariotInfo = ItemUtil.getItemByItemId(pItemId)
	if (pPos and pPos > 0) then
		-- 装备中
		chariotInfo = ChariotMainData.getEquipChariotInfoByPos(pPos)
	end

	-- 1.是否强化到最大等级
	local chariotTid = chariotInfo.item_template_id
	local curLv = tonumber(chariotInfo.va_item_text.chariotEnforce)
	local maxLv = ChariotMainData.getMaxLevelByTid(chariotTid)
	if curLv >= maxLv then
		AnimationTip.showTip(GetLocalizeStringBy("yr_7012"))
		return
	end

	-- 2.判断材料是否满足
	local tipStr = nil
	local silverNum,needTid,needNum = ChariotMainData.getEnforeCostByTidAndLv(chariotTid,curLv)
	if (UserModel.getSilverNumber() < silverNum) then
		-- 银币不够
		tipStr = GetLocalizeStringBy("key_1687")
	end
	local haveItemNum = ItemUtil.getCacheItemNumBy(needTid)
	if (haveItemNum < needNum) then
		-- 物品不够
		local itemName = ItemUtil.getItemNameByTid(needTid)
		if (tipStr ~= nil) then
			tipStr = tipStr..GetLocalizeStringBy("key_1235")..itemName
		else
			tipStr = itemName
		end
	end

	if (tipStr ~= nil) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1097",tipStr))
		return
	end

	local serviceCallBack = function ( pData )
		-- 扣除消耗材料
		UserModel.addSilverNumber(-silverNum)
		
		require "script/ui/chariot/ChariotEnforceLayer"
		ChariotEnforceLayer.setHaveItemNum(haveItemNum-needNum)

		local addLv = 1

		-- 更新战车强化信息
		if (pPos and pPos > 0) then
			-- 装备中
			ChariotMainData.updateChariotEnforceLvByPos(curLv+addLv,pPos)
		else
			-- 背包里
			DataCache.updateChariotEnforceLvInBag(pItemId,curLv+addLv)
		end

		-- 更新UI界面显示
		if (pPos and pPos > 0) then
			-- 战车装备界面
			ChariotMainLayer.updateCellByPos(pPos)
		else
			
		end

		-- 强化属性飘字
		require "script/ui/chariot/ChariotUtil"
		ChariotUtil.showChariotEnforceAttrTip(chariotInfo,addLv)

		if pCallback then
			pCallback()
		end
	end
	ChariotMainService.enforce(serviceCallBack,pItemId)
end