-- FileName: DevelopSoulController.lua 
-- Author: licong 
-- Date: 15/9/1 
-- Purpose: 战魂进阶控制器


module("DevelopSoulController", package.seeall)

require "script/ui/huntSoul/developSoul/DevelopSoulService"
require "script/ui/huntSoul/developSoul/DevelopSoulData"

--[[
	@des 	: 进阶回调
	@param 	: 
	@return :
--]]
function soulDevelopCallback( p_itemInfo, p_itemIds, p_isOnHero, p_callBack, p_maskLayerCallBack )
	local srcItemInfo = p_itemInfo
	-- 1.材料是否为空
	if( table.isEmpty(p_itemIds) )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1643"))
		return
	end
	-- 2.材料是否足够
	local isCan, needSilver = DevelopSoulData.isCanDevelopSoul( srcItemInfo.item_template_id, p_itemIds )
	if( isCan == false )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1556"))
		return
	end	
	-- 3.战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end

	-- 屏蔽层
	if(p_maskLayerCallBack)then
		p_maskLayerCallBack()
	end
	
	local nextCallFun = function ( p_retData )

		-- 修改战魂数据
		if(p_isOnHero)then
			local addCallFun = function ( ... )
				require "script/model/hero/HeroModel"
				local allHeros = HeroModel.getAllHeroes()
				allHeros["" .. srcItemInfo.hid].equip.fightSoul["".. srcItemInfo.pos] = p_retData
				HeroModel.setAllHeroes(allHeros)

				--刷新战魂相关缓存属性
				require "script/model/hero/HeroAffixFlush"
				HeroAffixFlush.onChangeFightSoul(srcItemInfo.hid)
			end
			-- 装上新的战魂
			local args = Network.argsHandlerOfTable({ srcItemInfo.hid, srcItemInfo.pos, p_retData.item_id })
			RequestCenter.hero_addFightSoul(addCallFun, args)
		end

		-- 扣除银币
		UserModel.addSilverNumber(-needSilver)

		-- 修改数据
		p_retData.hid = srcItemInfo.hid
		p_retData.pos = srcItemInfo.pos

		if(p_callBack ~= nil)then 
			p_callBack( p_retData )
		end
	end
	-- 发请求
	local needItemIdTab = {}
	for k,v in pairs(p_itemIds) do
		if( v.type ~= "silver" )then
			local findTab = ItemUtil.getCacheItemIdArrByNum( v.tid, v.num )
			for i,v_itemId in pairs(findTab) do
				table.insert(needItemIdTab,tonumber(v_itemId))
			end
		end
	end

	if(p_isOnHero)then
		-- 先卸下
		local removeCallFun = function ( ... )
			DevelopSoulService.fightSoulDevelop(srcItemInfo.item_id, needItemIdTab, nextCallFun)
		end
		DevelopSoulService.removeFightSoul(srcItemInfo.hid, srcItemInfo.pos, removeCallFun)
	else
		DevelopSoulService.fightSoulDevelop(srcItemInfo.item_id, needItemIdTab, nextCallFun)
	end
end

