-- FileName: SoulRebornController.lua 
-- Author: licong 
-- Date: 15/9/25 
-- Purpose: 战魂重生控制器 


module("SoulRebornController", package.seeall)

require "script/ui/rechargeActive/soulReborn/SoulRebornData"
require "script/ui/rechargeActive/soulReborn/SoulRebornService"

--[[
	@des 	: 重生回调
	@param 	: 
	@return :
--]]
function rebornCallback( p_itemId, p_tid, p_callBack, p_maskLayerCallBack )
	-- 1.活动是否结束
	if( not ActivityConfigUtil.isActivityOpen("fsReborn") )then 
		AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
		return
	end
	-- 2.选择的战魂不为空
	if( p_itemId == nil)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1700"))
		return
	end
	-- 3.背包是否满了
	-- 战魂背包满了
	if(ItemUtil.isFightSoulBagFull(true))then
		return
	end
	-- 4.次数是否足够
	local allNum = SoulRebornData.getRebornAllNum()
	local haveUseNum = SoulRebornData.getHaveRebornNum()
	if( haveUseNum >= allNum )then 
		AnimationTip.showTip(GetLocalizeStringBy("lic_1660"))
		return
	end

	-- 确定重生回调
	local yesCallBack = function ( ... )
		-- 屏蔽层
		if(p_maskLayerCallBack)then
			p_maskLayerCallBack()
		end
		
		local nextCallFun = function ( p_retData )
			-- 修改数据
			SoulRebornData.setHaveRebornNum(haveUseNum + 1)
			SoulRebornData.cleanSelectList()
			-- 修改选择的战魂
			DataCache.changeFSLvByItemId( p_itemId, 0, 0 )
			DataCache.changeFightSouEvolveLvInBag( p_itemId, 0 )

			-- 添加奖励
			local rewardTab = {}
			local tab1 = {}
			tab1.type = "silver"
	        tab1.num  = tonumber(p_retData.silver)
	        tab1.tid  = 0
	        table.insert(rewardTab,tab1)
	        -- 选择战魂
	        local tab2 = {}
			tab2.type = "item"
	        tab2.num  = 1
	        tab2.tid  = p_tid
	        table.insert(rewardTab,tab2)
	        for k,v_tid in pairs(p_retData.item) do
	        	local tab = {}
				tab.type = "item"
		        tab.num  = 1
		        tab.tid  = v_tid
		        if( tonumber(v_tid) == 72004 )then
		        	tab.exp = tonumber(p_retData.exp)
		        end
		        table.insert(rewardTab,tab)
	        end

	        ItemUtil.addRewardByTable(rewardTab)

			if(p_callBack ~= nil)then 
				p_callBack( rewardTab, allNum-haveUseNum-1 )
			end
		end
		-- 发请求
		SoulRebornService.reborn(p_itemId, nextCallFun)
	end

	-- 您确定要重生XXX吗？
	local dbData = ItemUtil.getItemById(p_tid)
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(400,100))
	local textInfo = {
     		width = 400, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        labelDefaultColor = ccc3(0x78,0x25,0x00),
	        linespace = 10, -- 行间距
	        defaultType = "CCLabelTTF",
	        elements =
	        {	
	        	{
	            	type = "CCRenderLabel", 
	            	text = dbData.name,
	            	color = HeroPublicLua.getCCColorByStarLevel(dbData.quality),
	        	}
	        }
	 	}
 	local tipDes = GetLocalizeLabelSpriteBy_2("lic_1703", textInfo)
 	tipDes:setAnchorPoint(ccp(0.5, 0.5))
 	tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
 	tipNode:addChild(tipDes)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(500,360))
end
