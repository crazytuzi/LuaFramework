-- FileName: PocketController.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: 锦囊模块逻辑层
--[[TODO List]]

module("PocketController", package.seeall)

require "script/ui/pocket/PocketService"

--[[
	@des:锦囊强化方法
	@parm:pItemId 要强化的物品id
	@parm:pItemIds 强化要消耗的物品id数组
	@ret:ret 描述
--]]
-- /**
--  * @param int $itemId
--  * @param array $itemIds
--  * @return array
--  * <code>
--  * {
--  * 		item_id:int				物品ID
--  * 		item_template_id:int	物品模板ID
--  * 		item_num:int			物品数量
--  * 		item_time:int			物品产生时间
--  * 		va_item_text:			物品扩展信息
--  * 		{
--  * 			pocketLevel:int		当前等级
--  * 			pocketExp:int		总经验值
--  * 		}
--  * }
--  */
-- public function upgradePocket($itemId, $itemIds);
function upgradePocketCallback( pItemId, pItemIds )

	--1.判断是否已经强化达到最大级别

	local function createNextFun(curLv, totalExp, item_id)
		-- 修改目标装备的等级和经验
		if(PocketUpgradeLayer._desItemData.equip_hid and tonumber(PocketUpgradeLayer._desItemData.equip_hid) > 0)then
			-- 修改装备锦囊数据
			PocketUpgradeLayer._desItemData.va_item_text.pocketLevel = curLv
			PocketUpgradeLayer._desItemData.va_item_text.pocketExp = totalExp
			HeroModel.changeHeroPocketBy( PocketUpgradeLayer._desItemData.hid, PocketUpgradeLayer._desItemData.pos, PocketUpgradeLayer._desItemData )
			PocketData.upgradeChangePocketFightPower(PocketUpgradeLayer._desItemData.hid,PocketUpgradeLayer._desItemData)
		else
			-- 修改背包锦囊数据
			DataCache.changePocketLvAndExpInBag(PocketUpgradeLayer._desItemData.item_id,curLv,totalExp)
		end
		-- 刷新一下背包
		PocketUpgradeLayer._fsoulData = PocketData.getDifferentData( PocketUpgradeLayer._fsoulData, pItemIds )
		PocketUpgradeLayer._playAction = true
		for key,value in pairs(PocketUpgradeLayer._fsoulDataButton)do
			local chooseData = PocketData.getChooseFSItemTable()
			for k,v in pairs(chooseData) do
				if(tonumber(v) == tonumber(key))then
					local materialAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/god_weapon/effect/wupindakai/wupindakai", 1, CCString:create(""))
			        materialAnimSprite:setAnchorPoint(ccp(0.5, 0))
			        materialAnimSprite:retain()
			        local pItem = tolua.cast(value,"CCMenuItemSprite")
			        if(pItem~=nil)then
				        materialAnimSprite:setPosition(ccp(pItem:getContentSize().width*0.5,pItem:getContentSize().height*0.5))
				        pItem:addChild(materialAnimSprite,10)
				        -- 特效结束回调
				        local animationEnd = function ( p_frameIndex,p_xmlSprite )
				        	-- materialAnimSprite:removeFromParentAndCleanup(true)
				        	PocketUpgradeLayer._bagTableView:reloadData()
				        	PocketUpgradeLayer._playAction = false
				        end
				        local animationFrameChanged = function(frameIndex,xmlSprite)

    					end
				        local materialDelegate = BTAnimationEventDelegate:create()
				        materialDelegate:registerLayerEndedHandler(animationEnd)
				        materialDelegate:registerLayerChangedHandler(animationFrameChanged)
				        materialAnimSprite:setDelegate(materialDelegate)
				    end
				end
			end
	    end
	    -- 清空选择锦囊列表
		PocketData.ClearChooseFSItemTable()
		-- 去除增加值特效
		PocketUpgradeLayer.removeAddAttrAnimation()
		-- 升级特效
		PocketUpgradeLayer.upAnimation()
		
		-- 刷新真实进度条
		PocketUpgradeLayer.refreshRealProgress()
		-- 漂增加属性提示
		if(tonumber(PocketUpgradeLayer.oldLeveNum) < tonumber(curLv))then
			local tipArr = PocketUpgradeLayer.addAttrNumAndAtrrName(tonumber(PocketUpgradeLayer.oldLeveNum),tonumber(curLv))
			require "script/utils/LevelUpUtil"
			LevelUpUtil.showFlyText(tipArr)
			PocketUpgradeLayer._addLevel = tonumber(curLv)-PocketUpgradeLayer.oldLeveNum
			PocketUpgradeLayer.oldLeveNum = tonumber(curLv)
		end
		PocketUpgradeLayer._desItemData = PocketUpgradeLayer.getDesItemInfoByItemId(item_id)
		-- 刷新
		PocketUpgradeLayer.refreshUI()
		-- 刷新真实等级
		PocketUpgradeLayer.refreshLevelAndAttr()

		PocketUpgradeLayer._addLevel 		= 0
		PocketUpgradeLayer.addAttrNumArr 		= {}
		PocketUpgradeLayer.addExpNum 			= nil
		PocketUpgradeLayer.addNeedNum 			= nil
   	end
	PocketService.upgradePocket(pItemId, pItemIds,createNextFun)
end

-- return: 'ok'
-- access: public
-- string addPocket (int $hid, int $pos, int $itemId, [int $fromHid = 0])
-- int $hid: 装备锦囊的武将id
-- int $pos: 装备锦囊的位置
-- int $itemId: 装备的锦囊物品id
-- int $fromHid: 锦囊原来属于的武将id 如果是从背包装备 此参数是0
function addPocketCallback( p_hid, p_pos, p_info, p_fromId, pPocketInfo)
	local oldPocketData=nil
	if(pPocketInfo~=nil)then
		oldPocketData = PocketData.countSinglePocketPower(pPocketInfo.item_id)
	end
	--1.判断是否已经强化达到最大级别
	local requestCallback = function ( p_hid, p_pos, p_info, p_fromId )
		--1.删除消耗物品
		--2.更新英雄锦囊数据
		HeroModel.changeHeroPocketBy( p_hid,p_pos,p_info)
		local data = {}
		data = PocketData.countSinglePocketPower(p_info.item_id,nil)
		PocketData.changePocketFightPower(p_hid,data,true)
		if(pPocketInfo~=nil)then
			PocketData.changePocketFightPower(p_hid,oldPocketData,false)
		end
		if(p_fromId~=nil)then
			local heroInfo = HeroModel.getHeroByHid(tostring(p_fromId))
			for k,v in pairs(heroInfo.equip.pocket)do
				if(v.item_template_id==p_info.item_template_id)then
					HeroModel.removePocketFromHeroBy( p_fromId,tonumber(k) )
					PocketData.changePocketFightPower(p_fromId,data,false)
					break
				end
			end
			
		end
		--3.刷新ui显示
		if(pPocketInfo~=nil)then
			PocketChooseLayer.fnHandlerOfClose(p_info,p_hid,pPocketInfo)
		else
			PocketChooseLayer.fnHandlerOfClose(p_info,p_hid)
		end
	end
	PocketService.addPocket(p_hid, p_pos, p_info, p_fromId,requestCallback(p_hid, p_pos, p_info, p_fromId))
end

function removePocketCallback( p_hid, p_pos, p_info)
	local requestCallback = function ( pRetData )
		local data = PocketData.countSinglePocketPower(p_info.item_id)
		--2.更新英雄锦囊数据
		HeroModel.removePocketFromHeroBy( p_hid,  p_pos)
		PocketData.changePocketFightPower(p_hid,data,false)
		--3.刷新ui显示
		PocketMainLayer.updateTableView()
		PocketMainLayer.updateMiddleMenu()
		PocketMainLayer.afterRemove(p_info,false,p_hid)
		PocketData.setItemData(nil)
	end
	PocketService.removePocket(p_hid, p_pos,requestCallback)
end