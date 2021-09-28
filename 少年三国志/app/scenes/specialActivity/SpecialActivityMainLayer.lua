--SpecialActivityMainLayer.lua
require("app.cfg.special_holiday_info")
require("app.cfg.special_holiday_sale")

local SpecialActivityMainLayer = class("SpecialActivityMainLayer", UFCCSNormalLayer)

SpecialActivityMainLayer.TITLEITEMWIDTH = 420
SpecialActivityMainLayer.TITLECOUNT = 2

SpecialActivityMainLayer.TAB1 = 1
SpecialActivityMainLayer.TAB2 = 2
SpecialActivityMainLayer.TAB3 = 3
SpecialActivityMainLayer.TAB4 = 4

function SpecialActivityMainLayer.create( ... )
	return SpecialActivityMainLayer.new("ui_layout/specialActivity_Main.json", nil,...)
end

function SpecialActivityMainLayer:ctor(...)
	self._views = {}
	self._titleScrollView = self:getScrollViewByName("ScrollView_title")
	self:registerScrollViewEvent("ScrollView_title",handler(self,self.onScrollViewEvent))
	-- self._titleScrollView:setInertiaScrollEnabled(false)
	self._innerContainer = self._titleScrollView:getInnerContainer()
	self._startX = 0
	self._scrollDirect = 1
	self._autoScroll = false
	self._titleIndex = 1 -- 1-4
	self._totalCount = 1
	self._maxCount = G_Me.specialActivityData:getTitleCount()
	self._tabNameList = {}
	-- self:getImageViewByName("Image_title"):loadTexture("ui/text/txt/shuang11tehui.png")
	self.super.ctor(self, ...)
end

function SpecialActivityMainLayer:adapterLayer( )
	self:adapterWidgetHeight("Panel_bottom", "Panel_top", "", 53, 0)
	self:initList()
end

function SpecialActivityMainLayer:onLayerLoad( ... )

	--蔡文姬
	local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	local GlobalConst = require("app.const.GlobalConst")
	if appstoreVersion or IS_HEXIE_VERSION  then 
	    knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
	else
	    knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
	end
	if knight then
	    local heroPanel = self:getPanelByName("Panel_hero")
	    local KnightPic = require("app.scenes.common.KnightPic")
	    KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
	    heroPanel:setScale(0.8)
	    -- if self._smovingEffect == nil then
	    --     local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	    --     self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
	    -- end
	end

        self._totalCount = G_Me.specialActivityData:getCurIndex()
        self:initTitles()

    self:registerBtnClickEvent("Button_shop",function()
    	local top = require("app.scenes.specialActivity.SpecialActivityShop").create()
    	uf_sceneManager:getCurScene():addChild(top)
    end)
    self:registerBtnClickEvent("Button_gift",function()
    	local top = require("app.scenes.specialActivity.SpecialActivityAllAward").create()
    	uf_sceneManager:getCurScene():addChild(top)
    end)
    self:registerBtnClickEvent("Button_left",function()
    	self:scrollToIndex(self._titleIndex-1)
    end)
    self:registerBtnClickEvent("Button_right",function()
    	self:scrollToIndex(self._titleIndex+1)
    end)
end

function SpecialActivityMainLayer:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY, self.flushView, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_UPDATE_SPECIAL_HOLIDAY_ACTIVITY, self.flushView, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_ACTIVITY_REWARD, self._onGetAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_SPECIAL_HOLIDAY_SALES, self.flushView, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BUY_SPECILA_HOLIDAY_SALE, self._onBuy, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self.hasRecharge, self)

	if self._timer == nil then
	    self._timer = GlobalFunc.addTimer(1, handler(self, self._refreshTime))
	end
	self:showTips()
	self:jumpToIndex(G_Me.specialActivityData:getCurIndex())
	self._titleIndex = G_Me.specialActivityData:getCurIndex()
	self:refreshView()

	G_HandlersManager.specialActivityHandler:sendGetSpecialHolidayActivity()
	G_HandlersManager.specialActivityHandler:sendGetSpecialHolidaySales()
end

function SpecialActivityMainLayer:onLayerExit( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        		self._timer = nil
	end
end

function SpecialActivityMainLayer:_refreshTime( )
	if not G_Me.specialActivityData:isInActivityTime() then
		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.mainscene.MainScene").new())
	end
end

function SpecialActivityMainLayer:initTitles( )
	self._titleScrollView:removeAllChildren();
	local space = 0 --间隙
	local size = self._titleScrollView:getContentSize()
	local _knightItemWidth = 0
	for i = 1 , self._maxCount do
	    local widget = require("app.scenes.specialActivity.SpecialActivityTitleCell").new(i)
	    _knightItemWidth = widget:getWidth()

	    widget:setPosition(ccp(_knightItemWidth*(i-1)+i*space,0))
	    self._titleScrollView:addChild(widget)
	end
	-- local _scrollViewWidth = _knightItemWidth*SpecialActivityMainLayer.TITLECOUNT+space*(SpecialActivityMainLayer.TITLECOUNT+1)
	-- self._titleScrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
	local _scrollViewWidth = _knightItemWidth*self._totalCount+space*(self._totalCount+1)
	self._titleScrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
end

function SpecialActivityMainLayer:onCheckCallback( btnName )
	if btnName == "CheckBox_recharge" then

	elseif btnName == "CheckBox_gift" then

	elseif btnName == "CheckBox_fight" then

	elseif btnName == "CheckBox_sell" then

	end
end

function SpecialActivityMainLayer:showTips( )
	for i = 1 , 3 do 
		self:getImageViewByName("Image_tip"..i):setVisible(G_Me.specialActivityData:needTip(i,self._titleIndex))
	end
	self:getImageViewByName("Image_shopTip"):setVisible(G_Me.specialActivityData:canShop())
end

function SpecialActivityMainLayer:initList( )
	if self._tabs == nil then
	    self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
	    self:_createTab("Panel_list1", "CheckBox_recharge","Label_recharge",1)
	    self:_createTab("Panel_list2", "CheckBox_gift","Label_gift",2)
	    self:_createTab("Panel_list3", "CheckBox_fight","Label_fight",3)
	    self:_createTab("Panel_list4", "CheckBox_sell","Label_sell",4)
	end
	self._tabs:checked("CheckBox_recharge")
end

--创建tab
function SpecialActivityMainLayer:_createTab(panelName, btnName,labelName,tabNum)
    self._views[tabNum] = CCSListViewEx:createWithPanel(self:getPanelByName(panelName), LISTVIEW_DIR_VERTICAL)
    self._tabs:add(btnName, self._views[tabNum],labelName)
    self._tabNameList[tabNum] = labelName
    self:_initTabHandler(tabNum)
end

--初始化tab的listview
function SpecialActivityMainLayer:_initTabHandler(tabNum)
    local listView = self._views[tabNum] 
    listView:setCreateCellHandler(function ( list, index)
    	if tabNum == SpecialActivityMainLayer.TAB4 then
    		return require("app.scenes.specialActivity.SpecialActivitySaleListItem").new(list, index)
    	else
        		return require("app.scenes.specialActivity.SpecialActivityTargetListItem").new(list, index)
        	end
    end)
    listView:setUpdateCellHandler(function ( list, index, cell)
    	if index < #self:getData(tabNum) then
        		cell:updateData(self:getData(tabNum)[index+1]) 
        	end
    end)
    -- listView:setSelectCellHandler(function ( cell, index )
       
    -- end)
    listView:initChildWithDataLength( #self:getData(tabNum),0.2)
    listView:setSpaceBorder(0,60)
end

function SpecialActivityMainLayer:getData(tabNum)
	local sort1 = function ( a,b )
		local arrangeA = G_Me.specialActivityData:getInfoArrange(a.id)
		local arrangeB = G_Me.specialActivityData:getInfoArrange(b.id)
		if arrangeA ~= arrangeB then
			return arrangeA < arrangeB
		end
		return a.id < b.id
	end
	local sort2 = function ( a,b )
		local arrangeA = G_Me.specialActivityData:getSaleArrange(a.id)
		local arrangeB = G_Me.specialActivityData:getSaleArrange(b.id)
		if arrangeA ~= arrangeB then
			return arrangeA < arrangeB
		end
		return a.id < b.id
	end
	local data = G_Me.specialActivityData:getInfoData(self._titleIndex,tabNum)
	if tabNum == SpecialActivityMainLayer.TAB4 then
		table.sort(data,sort2)
	else
		table.sort(data,sort1)
	end
	return data
end

function SpecialActivityMainLayer:_onGetAward(data)
	if data.ret == NetMsg_ERROR.RET_OK then
		local awardGot = {}
		local info = special_holiday_info.get(data.info.id)
		for i = 1 , 4 do 
			if info["type_"..i] > 0 then
				table.insert(awardGot,#awardGot+1,{type=info["type_"..i],value=info["value_"..i],size=info["size_"..i],})
			end
		end
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awardGot)
		uf_notifyLayer:getModelNode():addChild(_layer,1000)
		self:flushView()
	end
end

function SpecialActivityMainLayer:_onBuy(data)
	if data.ret == NetMsg_ERROR.RET_OK then
		local awardGot = {}
		local info = special_holiday_sale.get(data.id)
		table.insert(awardGot,#awardGot+1,{type=info.type,value=info.value,size=info.size*data.saleCount})
		
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awardGot)
		uf_notifyLayer:getModelNode():addChild(_layer,1000)
		self:flushView()
	end
end

function SpecialActivityMainLayer:refreshView()
	for k , v in pairs(self._views) do 
		v:reloadWithLength(#self:getData(k),0,0.2)
		self:updateTabName()
	end
	self:showTips()
end

function SpecialActivityMainLayer:flushView()
	for k , v in pairs(self._views) do 
		v:refreshAllCell()
	end
	self:showTips()
end

function SpecialActivityMainLayer:updateTabName( )
	for i = 1 , 4 do
		-- local txt = "LANG_SPECIAL_ACTIVITY_TAB"..i
		-- txt = i == SpecialActivityMainLayer.TAB2 and txt.."_"..self._titleIndex or txt
		-- local labelTxt = G_lang:get(txt)
		local labelTxt = G_Me.specialActivityData:getTabName(i,self._titleIndex)
		self:getLabelByName(self._tabNameList[i]):setText(labelTxt)
		self:getLabelByName(self._tabNameList[i].."_0"):setText(labelTxt)
	end
end

function SpecialActivityMainLayer:onScrollViewEvent(widget,_type)
    local posX = math.abs(self._titleScrollView:getInnerContainer():getPositionX())
    if _type == SCROLLVIEW_EVENT_SCROLL_TO_TOP then
    elseif _type == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then
    elseif _type == SCROLLVIEW_EVENT_SCROLLING then
    	if self._startX - posX < 0 then
            		self._scrollDirect = 1
    	else
            		self._scrollDirect = -1
    	end
    	self._startX = posX
    	self._autoScroll = false
    elseif _type == SCROLLVIEW_EVENT_SCROLL_STOP then
    	self._startX = posX
    	self._titleScrollView:setScrollEnable(true)
    	local delta = posX%SpecialActivityMainLayer.TITLEITEMWIDTH
    	if delta > 2 and delta < SpecialActivityMainLayer.TITLEITEMWIDTH - 2 then
	    	local index = math.floor(posX/SpecialActivityMainLayer.TITLEITEMWIDTH) + 1
	    	index = self._scrollDirect == 1 and index+1 or index
	    	uf_funcCallHelper:callAfterFrameCount(1, function()
	    	    self:scrollToIndex(index)
	    	end)
	else
		local newIndex = math.floor(posX/SpecialActivityMainLayer.TITLEITEMWIDTH) + 1
		newIndex = delta < 10 and newIndex or newIndex + 1
		if self._titleIndex ~= newIndex then
			self._titleIndex = newIndex
			self:refreshView()
		end
    	end
    end

end

function SpecialActivityMainLayer:scrollToIndex(_index)
    if self._autoScroll then 
    	return 
    end
    if _index < 1 or _index > self._totalCount then 
    	return
    end
    self._autoScroll = true
    self._titleScrollView:setScrollEnable(false)
    local scrollAreaHeight = SpecialActivityMainLayer.TITLEITEMWIDTH *(self._totalCount - 1)
    local myPosY = SpecialActivityMainLayer.TITLEITEMWIDTH*(_index - 1)

    local scrollTime = 0.3
    local percent = scrollAreaHeight > 0 and myPosY/scrollAreaHeight or 0
    local currentPercent = self:_getCurrentScrollPercent()
    local diffPercert = math.abs(percent-currentPercent)
    self._titleScrollView:scrollToPercentHorizontal(math.abs(percent*100),diffPercert*scrollTime > 1 and 1 or diffPercert*scrollTime,false)
end

function SpecialActivityMainLayer:jumpToIndex(_index)
    if _index < 1 or _index > self._totalCount then 
    	return
    end
    local scrollAreaHeight = SpecialActivityMainLayer.TITLEITEMWIDTH *(self._totalCount - 1)
    local myPosY = SpecialActivityMainLayer.TITLEITEMWIDTH*(_index - 1)

    local scrollTime = 0.3
    local percent = scrollAreaHeight > 0 and myPosY/scrollAreaHeight or 0
    local currentPercent = self:_getCurrentScrollPercent()
    local diffPercert = math.abs(percent-currentPercent)
    self._titleScrollView:jumpToPercentHorizontal(math.abs(percent*100))
end

--获取当前scrollview的滑动百分比
function SpecialActivityMainLayer:_getCurrentScrollPercent()
    local posY = self._innerContainer:getPositionX()
    local scrollAreaHeight = SpecialActivityMainLayer.TITLEITEMWIDTH *(self._totalCount - 1)
    return math.abs(1-posY/scrollAreaHeight)
end

function SpecialActivityMainLayer:hasRecharge()
	G_HandlersManager.specialActivityHandler:sendGetSpecialHolidayActivity()
end

return SpecialActivityMainLayer

