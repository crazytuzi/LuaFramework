-- FileName: KFBWShopController.lua
-- Author: shengyixian
-- Date: 2015-09-30
-- Purpose: 跨服比武商店控制器
module("KFBWShopController",package.seeall)
require "script/ui/kfbw/kfbwshop/KFBWShopService"
--[[
	@des 	: 确认兑换
	@param 	: 
	@return : 
--]]
function sureToExchange( itemInfo,num )
	-- body
	KFBWShopService.buyGoods(itemInfo.id,num,function ( ... )
		-- body
		for i,v in ipairs(itemInfo.priceAry) do
			local priceValue = -(v.num * num)
			if (v.type == "silver") then
				-- 减去需要的银币
				UserModel.addSilverNumber(priceValue)
				-- KFBWMainLayer.refreshSliverLabelFunc()
			elseif(v.type == "gold") then
				-- 减去需要的金币
				UserModel.addGoldNumber(priceValue)
				require "script/ui/kfbw/KuafuLayer"
				KuafuLayer.refreshGoldLabelFunc()
			elseif(v.type == "prestige") then
				-- 减去需要的名望
				UserModel.addPrestigeNum(priceValue)
			elseif(v.type == "cross_honor") then
				-- 减去跨服荣誉
				UserModel.addCrossHonor(priceValue)
			elseif(v.type == "jh") then
				-- 减去武将精华
				UserModel.addHeroJh(priceValue)
			end	
		end
		local nameStr = nil
		local item = nil
		if tonumber(itemInfo.itemType) == 7 then
			item = ItemUtil.getItemById(itemInfo.itemID)
			nameStr = item.name
		else
			item = ItemUtil.getItemsDataByStr(itemInfo.items)[1]
			nameStr = item.name
			if item.type == "cross_honor" then
				UserModel.addCrossHonor(item.num)
			elseif item.type == "jh" then
				UserModel.addHeroJh(item.num)
			elseif item.type == "gold" then
				UserModel.addGoldNumber(item.num)
			end
		end
		KFBWShopLayer.refresh()
		AnimationTip.showTip(GetLocalizeStringBy("syx_1011",num * itemInfo.itemNum,nameStr))
	end)
end
--[[
	@des 	: 兑换前的判断
	@param 	: 
	@return : 
--]]
function beforeExchange(itemInfo,callBack)
	-- body
	-- 背包是否已满
	if (ItemUtil.isBagFull(true,function ( ... )
		KFBWShopLayer.closeButtonCallFunc()
	end)) then
		return
	end
	-- 兑换次数是否大于1
	if (tonumber(itemInfo.exchangeTimes) < 1) then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1009"))
		return
	end
	-- 判断人物等级 add by FQQ
	if(UserModel.getHeroLevel() < tonumber(itemInfo.needLevel))then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1289"))
		return
	end

	for i,v in ipairs(itemInfo.priceAry) do
		if (v.type == "silver") then
			-- 银币是否充足
			if (v.num > UserModel.getSilverNumber()) then
				AnimationTip.showTip(GetLocalizeStringBy("zz_93"))
				return
			end
		elseif(v.type == "gold") then
			-- 金币是否充足
			if (v.num > UserModel.getGoldNumber()) then
				AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
				return
			end
		elseif(v.type == "prestige") then
			-- 名望是否充足
			if (v.num > UserModel.getPrestigeNum()) then
				AnimationTip.showTip(GetLocalizeStringBy("key_2018"))
				return
			end
		elseif(v.type == "cross_honor") then
			-- 跨服荣誉是否充足
			if (tonumber(v.num) > tonumber(UserModel.getCrossHonor())) then
				AnimationTip.showTip(GetLocalizeStringBy("syx_1019"))
				return
			end
		elseif(v.type == "jh") then
			-- 武将精华是否充足
			if (tonumber(v.num) > tonumber(UserModel.getHeroJh())) then
				AnimationTip.showTip(GetLocalizeStringBy("syx_1054"))
				return
			end
		end
	end
	callBack()
end
--[[
	@des 	: 获取当前要显示的物品信息
	@param 	: 
	@return : 
--]]
function getItemInfo( callFunc )
	-- body
	KFBWShopService.getShopInfo(function ( data )
		KFBWShopData.setItemInfo(data)
		callFunc()
	end)
end