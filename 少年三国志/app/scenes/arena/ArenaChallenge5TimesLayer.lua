-- 竞技场连续挑战五次

-- :精力丹不足终止
-- :扫荡完之后需要升级

-- TODO:碎片已满？
-- TODO:???

local ArenaChallenge5TimesLayer = class("ArenaChallenge5TimesLayer", UFCCSNormalLayer)

local CellItem = require("app.scenes.arena.ArenaChallenge5TimesCellItem")
local EffectNode = require "app.common.effects.EffectNode"

function ArenaChallenge5TimesLayer.create( rank, ... )
	return ArenaChallenge5TimesLayer.new("ui_layout/arena_Challenge5TimesLayer.json", rank, ...)
end


function ArenaChallenge5TimesLayer:ctor( jsonFile, rank, ... )
	ArenaChallenge5TimesLayer.super.ctor(self)

	self._opponentRank = rank

	self._scrollView = self:getScrollViewByName("ScrollView_ChallengeFiveTimes")
	self._scrollContainer = self._scrollView:getInnerContainer()

	self._challengeTimes = 0
	self._scrollViewHeight = self._scrollView:getSize().height

	self._itemPanel = self:getPanelByName("Panel_ChallengeFiveTimes")

	self._cellHeight = 280
	-- 上下部分的宽度 TODO:动态获取
	-- self._adjustHeight = 135/2 + 57/2

	self._finishBtn = self:getButtonByName("Button_Finish")
	self:attachImageTextForBtn("Button_Finish","Image_28")
	self._finishBtn:setTouchEnabled(false)

end

function ArenaChallenge5TimesLayer:onLayerEnter( ... )

	self._scrollViewHeight = self._scrollView:getSize().height
	local bottomBarHeight = self:getWidgetByName("Image_Bottom"):getSize().height

	local topBarHeight = self:getWidgetByName("Image_Title"):getSize().height

	local winHeight = CCDirector:sharedDirector():getWinSize().height

	local deltaHeight = winHeight - bottomBarHeight - topBarHeight - self._scrollViewHeight

	local oldContainerSize = self._scrollContainer:getSize()
	self._scrollContainer:setSize(CCSizeMake(oldContainerSize.width, oldContainerSize.height + deltaHeight))

	local oldViewSize = self._scrollView:getSize()
	self._scrollView:setSize(CCSizeMake(oldViewSize.width, oldViewSize.height + deltaHeight))


	self._scrollViewHeight = self._scrollView:getSize().height

	-- 发送挑战协议
	G_HandlersManager.arenaHandler:sendChallenge(self._opponentRank)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_CHALLENGE, self._onChallengeData, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._onReceiveLevelUpdate, self)

	self:registerBtnClickEvent("Button_Back", function ( ... )
		self:_hitLevelup()

		-- uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new())
		uf_sceneManager:popScene()
	end)
end

function ArenaChallenge5TimesLayer:_onChallengeData( data )
	if data.ret ~= 1 then
		self:_onChallengeFinished()
		return
	end

	-- dump(data)
	self._challengeTimes = self._challengeTimes + 1	

	local cellItem = CellItem.new(data, self._challengeTimes)
	self._itemPanel:addChild(cellItem)

	local cellPosY = self._scrollViewHeight - self._challengeTimes * self._cellHeight

	local deltaY = 0
	-- 当新加入的条目位置小于0时，则调整条目的位置
	if cellPosY < 0 and cellPosY >= -self._cellHeight then
		deltaY = -cellPosY		
	elseif cellPosY < -self._cellHeight then
		deltaY = self._cellHeight
	end	

	local oldContainerSize = self._scrollContainer:getSize()
	self._scrollContainer:setSize(CCSizeMake(oldContainerSize.width, oldContainerSize.height + deltaY))
	
	self._itemPanel:setPositionY(self._itemPanel:getPositionY() + deltaY)
	cellItem:setPositionY(cellPosY)


	if self._challengeTimes < 5 and G_Me.userData.spirit >= 2 then
		-- 动画暂时屏蔽
		-- G_GlobalFunc.flyIntoScreenLR({cellItem}, true, 0.2, 0, 0, function()
		-- 	G_HandlersManager.arenaHandler:sendChallenge(self._opponentRank)
		-- end)
		G_HandlersManager.arenaHandler:sendChallenge(self._opponentRank)

	else
		-- 动画暂时屏蔽
		G_GlobalFunc.flyIntoScreenLR({cellItem}, true, 0.2, 0, 0, function()
			self:_onChallengeFinished()			
		end)
		
	end


end

function ArenaChallenge5TimesLayer:onLayerExit( ... )
	-- body
end

function ArenaChallenge5TimesLayer:onLayerUnload()
	
end

function ArenaChallenge5TimesLayer:_onChallengeFinished( ... )

	self._finishBtn:setTouchEnabled(true)

	self.effectNode = EffectNode.new("effect_around2", function(event, frameIndex) end)     
	self.effectNode:setScale(1.7) 
	self.effectNode:play()
	local pt = self.effectNode:getPositionInCCPoint()
	self.effectNode:setPosition(ccp(pt.x, pt.y))
	self._finishBtn:addNode(self.effectNode)
	
	self:registerBtnClickEvent("Button_Finish", function ( ... )
		self:_hitLevelup()

		-- uf_sceneManager:replaceScene(require("app.scenes.arena.ArenaScene").new())
		uf_sceneManager:popScene()
	end)
end

function ArenaChallenge5TimesLayer:_onReceiveLevelUpdate( oldLevel, newLevel )
    if type(oldLevel) ~= "number" or type(newLevel) ~= "number" then 
        return 
    end

    self._upgradeList = self._upgradeList or {}
    table.insert(self._upgradeList, 1, {level1 = oldLevel, level2 = newLevel})
end

function ArenaChallenge5TimesLayer:_hitLevelup( ... )
    if not self._upgradeList or #self._upgradeList < 1 then 
        return 
    end


    local upgradePair = self._upgradeList[1]
    if type(upgradePair) == "table" then 
    	uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
    		require("app.scenes.common.CommonLevelupLayer").show(upgradePair.level1, upgradePair.level2)
    		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
    	end)        
    end
    self._upgradeList = {}
end

return ArenaChallenge5TimesLayer