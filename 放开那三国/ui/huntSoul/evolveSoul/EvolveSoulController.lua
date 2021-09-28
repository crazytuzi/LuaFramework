-- FileName: EvolveSoulController.lua 
-- Author: licong 
-- Date: 15/9/7 
-- Purpose: 战魂精炼控制器


module("EvolveSoulController", package.seeall)

require "script/ui/huntSoul/evolveSoul/EvolveSoulData"
require "script/ui/huntSoul/evolveSoul/EvolveSoulService"

--[[
	@des 	: 精炼回调
	@param 	: 
	@return :
--]]
function soulEvolveCallback( p_itemInfo, p_itemIds, p_isOnHero, p_callBack, p_maskLayerCallBack )
	local curEvolveLv = 0
	if( not table.isEmpty(p_itemInfo.va_item_text) and p_itemInfo.va_item_text.fsEvolve )then
		curEvolveLv = tonumber(p_itemInfo.va_item_text.fsEvolve)
	else
		curEvolveLv = 0
	end

	-- 1.上限
	local maxEvolveLv = EvolveSoulData.getSoulEvolveMaxLvByTid( p_itemInfo.item_template_id )
	if( curEvolveLv >= maxEvolveLv )then  
		AnimationTip.showTip(GetLocalizeStringBy("lic_1653"))
		return
	end
	-- 2.材料是否为空
	if( table.isEmpty(p_itemIds) )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1651"))
		return
	end
	-- 3.材料是否足够
	local isCan, needSilver = EvolveSoulData.isCanEvolveSoul( p_itemInfo.item_template_id, curEvolveLv+1, p_itemIds )
	if( isCan == false )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1652"))
		return
	end	

	-- 屏蔽层
	if(p_maskLayerCallBack)then
		p_maskLayerCallBack()
	end
	
	local nextCallFun = function ( p_retData )
		-- 修改战魂数据
		if(p_isOnHero)then
			HeroModel.changeHeroFightSoulEvolveLv( p_itemInfo.hid, p_itemInfo.pos, curEvolveLv+1)
		else
			DataCache.changeFightSouEvolveLvInBag( p_itemInfo.item_id, curEvolveLv+1 )
		end

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
	EvolveSoulService.fightSoulEvolve(p_itemInfo.item_id, needItemIdTab, nextCallFun)
end



