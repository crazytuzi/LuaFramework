
local ActivityMainLayer = class("ActivityMainLayer",UFCCSNormalLayer)
--local ActivityButton = require("app.scenes.activity.ActivityButton")
local ActivityBorderButton = require("app.scenes.activity.ActivityBorderButton")
local ActivityPage= require("app.scenes.activity.ActivityPage")

function ActivityMainLayer.create(...)
    return ActivityMainLayer.new("ui_layout/activity_ActivityMainLayer.json", ...)
end



function ActivityMainLayer:ctor(...)
    self._isDelaying = false

    self.super.ctor(self,...)

    --必须保存全局,因为G_Me.activityData:getTypeList 是动态获取的
    self._activityList = G_Me.activityData:getTypeList()

end

function ActivityMainLayer:showActivity(index)
    self._pageView:scrollToPage(index - 1)
    self:_showScrollViewSelected(index)
end

--显示对应类型的活动页面 add by kaka 
--typeId:活动类型ID required
--isGmActivity:是否为GM可配置活动
--actId:活动data id
function ActivityMainLayer:showActivityPage(typeId, isGmActivity, actId, ...)

    if not typeId or type(typeId) ~= "string" then    
        return
    end

    local pageIndex = 0

    for i,v in ipairs(self._activityList) do

        if isGmActivity == true then
            if not v.data and v.data.act and v.data.act.act_id == actId then
                pageIndex = i
                break
            end
        elseif v.id == typeId then
            pageIndex = i
            break
        end
    end

    if pageIndex > 0 then
        self:showActivity(pageIndex)
    end

end


function ActivityMainLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, self._onUpdatedButtons, self) 
    --极品抽卡结果
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, self._getDropGodlyKnightResult, self)
end


function ActivityMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function ActivityMainLayer:adapterLayer(index)

    index = index or 1

    self:adapterWidgetHeight("Panel_pageView", "", "", 0, 0)
 

    self:_initScrollView()

    self:_initPageView(index)

    -- self:showActivity(index)

    self:_onUpdatedButtons()
end

function ActivityMainLayer:_onUpdatedButtons()
    --更新按钮的小红点
    for i,button in ipairs(self._scrollViewButtons) do
        local activity = self._activityList[i]

        button:showTip(false) --默认

        if activity.needShowTip ~= nil then 
            button:showTip(activity:needShowTip())
        end

        if G_Me.activityData:isGmActivity(activity) and activity.data then
            --是否显示开启标签
            button:showKaiqi(G_Me.activityData.custom:checkPreviewByActId(activity.data.act_id))
            
            --是否显示NEW标签
            button:showNew(G_Me.activityData.custom:isNewActivity(activity.data.act_id))

        end

    end
end


function ActivityMainLayer:_initPageView(defaultIndex)
    local delayLoadPage = {}
    defaultIndex = defaultIndex or 1
    if self._pageView ~= nil then
        self._pageView:removeAllChildrenWithCleanup(true)
        self._pageView = nil
    end
    if self._pageView == nil then
        self._isDelaying = true
        local panel = self:getPanelByName("Panel_pageView")
        self._pageView = CCSNewPageViewEx:createWithLayout(panel)
        self._pageView:setPageCreateHandler(function ( page, index )

            local activity = self._activityList[index+1]
            local cell= ActivityPage.new()
            return cell
        end)
        self._pageView:setPageTurnHandler(function ( page, index, cell )

            self:_showScrollViewSelected(index+1)
            cell:showPage(self._activityList[index+1]) 
    
        end)
        self._pageView:setPageUpdateHandler(function ( page, index, cell )
            if not self._isDelaying then 
                cell:updatePage(self._activityList[index+1])
            else 
                if (index == defaultIndex - 1) then
                    cell:updatePage(self._activityList[index+1])
                else
                    delayLoadPage[index + 1] = cell
                end
            end             
        end)
        self._pageView:showPageWithCount(#self._activityList,defaultIndex-1)
        self:callAfterFrameCount(5, function ( ... )
            for key, value in pairs(delayLoadPage) do 
                if value.updatePage then 
                    value:updatePage(self._activityList[key])
                end
            end
            self._isDelaying = false
        end)
    end
    -- local pageViewSelectedIndex = 0
    -- if self._currentComposeId ~= nil then
    --     pageViewSelectedIndex = self:_getIndexByTreasureId(self._currentComposeId)
    --     self._pageView:scrollToPage(pageViewSelectedIndex-1)
    --     self._currentComposeId = nil
    -- end
    -- self:_initScrollView(pageViewSelectedIndex)
end

--刷新Scroview
function ActivityMainLayer:_initScrollView()

    if self._scrollView == nil then
        self._scrollView = self:getScrollViewByName("ScrollView_top")
    end
    self._scrollView:removeAllChildrenWithCleanup(true)
    self._scrollViewButtons = {}
    local space = -5 --间隙
    local size = self._scrollView:getContentSize()


    local itemWidth = 0
    
    for i,v in ipairs(self._activityList) do

        --edited by kaka   
        self._scrollViewButtons[i] = ActivityBorderButton.new(v)

        itemWidth = self._scrollViewButtons[i]:getWidth()
        self._scrollViewButtons[i]:setPosition(ccp(itemWidth*(i-1)+i*space,(size.height-itemWidth)/2-5))
        --self:addChild(widget)
        self._scrollView:addChild(self._scrollViewButtons[i])
        self._scrollViewButtons[i]:setOnClickEvent(function ( )
           self:showActivity(i)
        end)
    end

    local _scrollViewWidth = itemWidth*#self._activityList + space*(#self._activityList+1)
    --self:_showScrollViewSelected(self._pageView:getCurPageIndex()+1)

    self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
    
    -- if self._isFirstTimeEnter == true then
    --     GlobalFunc.flyIntoScreenLR({self._scrollView}, false, 0.2, 2, 100,function()
    --         self:setClickEnabled(true)
    --     end)
    -- end
end

function ActivityMainLayer:_showScrollViewSelected(index)
    if self._scrollViewButtons == nil or #self._scrollViewButtons == 0 then
        return
    end
    for i,v in ipairs(self._scrollViewButtons) do
        self._scrollViewButtons[i]:showBackgroundImage(index == i)
    end
    if self._scrollView == nil then 
        return
    end
    --按钮的宽度
    local buttonWidth = self._scrollViewButtons[index]:getContentSize().width
    local innerContainer = self._scrollView:getInnerContainer()
    --计算选中按钮的位置是否超出了
    local position = innerContainer:convertToWorldSpace(ccp(self._scrollViewButtons[index]:getPosition()))
    --滑动区域宽度
    local scrollAreaWidth = innerContainer:getContentSize().width- self._scrollView:getContentSize().width
    if position.x < 0 then
        --需要位移
        local percent = self._scrollViewButtons[index]:getPositionX()/scrollAreaWidth
        self._scrollView:scrollToPercentHorizontal(percent*100,0.3,false)
        --因为position是世界坐标
    elseif math.abs(position.x) > self._scrollView:getContentSize().width - self._scrollView:getPositionX() - buttonWidth then
        --需要位移
        local percent = (math.abs(self._scrollViewButtons[index]:getPositionX())-self._scrollView:getContentSize().width + buttonWidth)/scrollAreaWidth
        if percent > 0 then
            self._scrollView:scrollToPercentHorizontal(100*percent,0.3,false)
        end
    end
end

--[[
    因为放在ActivityLingqu里面有点问题
]]
--极品抽卡结果
function ActivityMainLayer:_getDropGodlyKnightResult(data)
    --加上CD时间
    if data.ret == 1 then
        if #data.knight_base_id > 1 then
            self:_showDropTenKnights(100000, data.knight_base_id)
        else
            self:_showOneKnightDrop(2,data.knight_base_id[1])
        end
    end
end

function ActivityMainLayer:_showOneKnightDrop(_type,knightId)
    local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
    OneKnightDrop.show(_type, knightId, function(again, type)  
        if again then
            if type == 1 then   --良品
                require("app.scenes.shop.ShopTools").sendGoodKnightDrop()
            else  --极品
                require("app.scenes.shop.ShopTools").sendGodlyKnightDrop()
            end
        end

    end)
end

function ActivityMainLayer:_showDropTenKnights(buyMoneyNum, knights)
    local ManyKnightDrop = require "app.scenes.shop.animation.ManyKnightDrop"
    ManyKnightDrop.show(buyMoneyNum, knights)
end

function ActivityMainLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end



return ActivityMainLayer
