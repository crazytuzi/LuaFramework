local function _updateLabel(target, name, params)
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.size and params.size or 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

local EffectNode = require "app.common.effects.EffectNode"

local RiotMainLayer = class("RiotMainLayer", UFCCSNormalLayer)

local SHOW_STATUS = {
	SHOW = 1,  -- 本界面显示中屏幕中间
	HIDE = 2,  -- 本界面隐藏起来
}
RiotMainLayer.SHOW_STATUS = SHOW_STATUS


local HIDE_DURATION = 0.25
local offset = 110

function RiotMainLayer.create(...)
	return RiotMainLayer.new("ui_layout/dungeon_Hard_DungeonRiotMainLayer.json", nil, ...)
end

function RiotMainLayer:ctor(json, param, ... )
	self.super.ctor(self, json, param, ...)

	self._nShowStatus = SHOW_STATUS.SHOW
	self._isOnHideStatus = true
	self._tShowedRiotChapterList = G_Me.hardDungeonData:getShowedRiotChapterList()
	self._tTimer = G_GlobalFunc.addTimer(1, handler(self, self._updateAtNextStamp))
	self._nNextTimestamp = G_Me.hardDungeonData:getNextTimestamp(G_ServerTime:getTime())

	self:_initWidgets()
end

function RiotMainLayer:onLayerEnter()
	self:registerTouchEvent(false,false,0)

--	local isShowOnCenter = false --(G_Me.hardDungeonData:getShowOnCenterCount() < 1)
	local isShowOnCenter = G_Me.hardDungeonData:getEnterFlag()
	G_Me.hardDungeonData:setEnterFlag(false)

	local DIS = (display.height + offset)/2 
	local panel = self:getPanelByName("Panel_13")
	local x, y = panel:getPosition()
	panel:setPosition(ccp(x, y-DIS))

	if isShowOnCenter then
		self:_showWithAction()
		G_Me.hardDungeonData:setShowOnCenterCount(G_Me.hardDungeonData:getShowOnCenterCount() + 1)
	else
		self._nShowStatus = SHOW_STATUS.HIDE
	    self._isOnHideStatus = true
	    self:showWidgetByName("Panel_Up", true)
        self:showWidgetByName("Panel_Down", false)
	end
end

function RiotMainLayer:onLayerEixt()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

function RiotMainLayer:adapterLayer()
	-- body
end

function RiotMainLayer:_initWidgets()
	--
	_updateLabel(self, "Label_Time", {text=G_lang:get("LANG_HARD_RIOT_REFRESH_TIME"), stroke=Colors.strokeBrown})

	local titleEffect = EffectNode.new("effect_huoxing", function(event, frameIndex) end)
	self:getImageViewByName("Image_Title"):addNode(titleEffect)
	titleEffect:setPositionY(titleEffect:getPositionY() + 15)
	titleEffect:play()

	local upArraw = EffectNode.new("effect_jiantou", function(event, frameIndex) end)  
    upArraw:setPosition(ccp(self:getPanelByName("Panel_Up"):getSize().width/2, 25))
    upArraw:setScaleY(-1)
    self:getPanelByName("Panel_Up"):addNode(upArraw)
    upArraw:play()

    local downArraw = EffectNode.new("effect_jiantou", function(event, frameIndex) end)  
    downArraw:setPosition(ccp(self:getPanelByName("Panel_Down"):getSize().width/2, 25))
    self:getPanelByName("Panel_Down"):addNode(downArraw)
    downArraw:play()
	
	-- 箭头特效
	self:showWidgetByName("Panel_Up", not self._nShowStatus == SHOW_STATUS.SHOW)
	self:showWidgetByName("Panel_Down", self._nShowStatus == SHOW_STATUS.SHOW)

	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))
	self:registerWidgetTouchEvent("Panel_Up", handler(self, self._onClickArrowUp))
	self:registerWidgetTouchEvent("Panel_Down", handler(self, self._onClickArrowDown))
	self:getButtonByName("Button_ArrowLeft"):setEnabled(false)
	self:getButtonByName("Button_ArrowRight"):setEnabled(false)

	self:registerWidgetTouchEvent("Image_Title", handler(self, self._onUp))
	self:registerWidgetTouchEvent("Panel_13", handler(self, self._onUp))

	self:_initRiotKnightHeads()
end

function RiotMainLayer:_onUp(sender, eventType)
	if self._nShowStatus == SHOW_STATUS.HIDE and self._isOnHideStatus then
		if eventType == TOUCH_EVENT_ENDED then
			self:_showWithAction()
		end
	end
end

function RiotMainLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_HARD_RIOT_HELP_TITLE1"), content=G_lang:get("LANG_HARD_RIOT_HELP_CONTENT1")}
    } )
end

function RiotMainLayer:_onClickArrowUp(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		self:_showWithAction()
	end
end

function RiotMainLayer:_onClickArrowDown(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		self:_hideWithAction()
	end
end

function RiotMainLayer:_onClickArrowLeft()
	if table.nums(self._tShowedRiotChapterList) <= 4 then
		return
	end
end

function RiotMainLayer:_onClickArrowRight()
	if table.nums(self._tShowedRiotChapterList) <= 4 then
		return
	end
end

function RiotMainLayer:_addTitleEffect()
	
end

function RiotMainLayer:_showWithAction()
	local DIS = (display.height + offset)/2 
    self._nShowStatus = SHOW_STATUS.SHOW
	local panel = self:getPanelByName("Panel_13")
	local actMoveTo = nil
	if panel then
		local ptStart = panel:getPositionInCCPoint()
        local ptEnd = ccp(ptStart.x, ptStart.y + DIS)
        actMoveTo = CCMoveTo:create(HIDE_DURATION, ptEnd)

        local actCallFunc = CCCallFunc:create(function ()
		    self._isOnHideStatus = false
		    self:showWidgetByName("Panel_Up", false)
	        self:showWidgetByName("Panel_Down", true)
	    end)

	    local tArray = CCArray:create()
	    tArray:addObject(actMoveTo)
	    tArray:addObject(actCallFunc)
	    local actSeq = CCSequence:create(tArray)
	    panel:runAction(actSeq)
	end
end



function RiotMainLayer:_hideWithAction()
	local DIS = (display.height + offset)/2
    self._nShowStatus = SHOW_STATUS.HIDE
	local panel = self:getPanelByName("Panel_13")
	local actMoveTo = nil
	if panel then
		local ptStart = panel:getPositionInCCPoint()
        local ptEnd = ccp(ptStart.x, ptStart.y - DIS)
        actMoveTo = CCMoveTo:create(HIDE_DURATION, ptEnd)

        local actCallFunc = CCCallFunc:create(function ()
		    self._isOnHideStatus = true
		    self:showWidgetByName("Panel_Up", true)
	        self:showWidgetByName("Panel_Down", false)
	    end)

	    local tArray = CCArray:create()
	    tArray:addObject(actMoveTo)
	    tArray:addObject(actCallFunc)
	    local actSeq = CCSequence:create(tArray)
	    panel:runAction(actSeq)
	end
end


function RiotMainLayer:onTouchBegin(xPos,yPos)
	local tPanelList = {
		"Panel_13", "Panel_Up", "Panel_Down", "Panel_Help",
	}	

	for key, val in pairs(tPanelList) do
		local szPanelName = val
		local panel = self:getPanelByName(szPanelName)
		if panel then
			local x, y = panel:convertToNodeSpaceXY(xPos, yPos)
			local tSize = panel:getSize()
			local tRect = CCRectMake(0, 0, tSize.width, tSize.height)
			if  G_WP8.CCRectContainXY(tRect, x, y) then
			--if tRect:containsPoint(ccp(x, y)) then
				return
			end 
		end
	end

	if self._isOnHideStatus then
		return
	end

    self:_hide()

    return not self._isOnHideStatus
end

function RiotMainLayer:_hide()
	if self._nShowStatus == SHOW_STATUS.SHOW then
        self:_hideWithAction()
	end
end

function RiotMainLayer:_updateAtNextStamp()
	if self._nNextTimestamp == nil then
		return
	end
	local nTime = self._nNextTimestamp - G_ServerTime:getTime()
	nTime = math.max(nTime, 0)
	if nTime == 0 then
		self._nNextTimestamp = G_Me.hardDungeonData:getNextTimestamp(G_ServerTime:getTime())
		self._scrollView:removeAllChildrenWithCleanup(true)
		self:_initRiotKnightHeads()
	end
end

function RiotMainLayer:_initRiotKnightHeads()
	local tShowedRiotChapterList = G_Me.hardDungeonData:getShowedRiotChapterList()

	self._scrollView = self:getScrollViewByName("ScrollView_Head")
	self._scrollView:removeAllChildrenWithCleanup(true)
    local space = 10 --间隙
    local size = self._scrollView:getContentSize()
    local _knightItemWidth = 105
    local maxLength = table.nums(tShowedRiotChapterList)
    local nScrollViewWidth = self._scrollView:getSize().width
    local nOffset = 0
    if maxLength <= 4 then
    	nOffset = (nScrollViewWidth - (_knightItemWidth*maxLength + space*maxLength)) / 2
    end

    for i = 1, maxLength do
    	-- 绑定数据
        local tRiotChapter = tShowedRiotChapterList[i]
		local headItem = require("app.scenes.harddungeon.riot.RiotHeadItem").new(tRiotChapter)
		headItem:setPosition(ccp(nOffset + _knightItemWidth*(i-1)+(i-1)*space,0))
		self._scrollView:addChild(headItem)
    end

    local _scrollViewWidth = _knightItemWidth*maxLength+space*(maxLength+1)
    self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth, size.height))
end

return RiotMainLayer