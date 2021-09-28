
local DressBookLayer = class("DressBookLayer",UFCCSNormalLayer)
require("app.cfg.dress_info")
require("app.cfg.dress_compose_info")
require("app.cfg.knight_info")
local MergeEquipment = require("app.data.MergeEquipment")
local KnightPic = require("app.scenes.common.KnightPic")

function DressBookLayer.create( scene)   
    local layer = DressBookLayer.new("ui_layout/dress_BookLayer.json",require("app.setting.Colors").modelColor) 
    -- layer:updateView(scene)
    return layer
end

function DressBookLayer:ctor(...)
    self.super.ctor(self, ...)
    self._scrollView = self:getWidgetByName("ScrollView_List")
    self._scrollView = tolua.cast(self._scrollView,"ScrollView")
    self:_initScrollView()
    self._attrStatus = false
    self._attrPanel = self:getPanelByName("Panel_attrPanel")
    self._basey = -450
    self:updataAttrBg(true)
    self:registerWidgetClickEvent("Panel_attrPanel", function()
         self:attrPanelMove()
    end)
end

function DressBookLayer:onLayerEnter( )
    self:attrPanelReset()
    self:updataData()
end

function DressBookLayer:updataData( )
    self:_updateScrollView()
    self:updateAttrs()
end

function DressBookLayer:updataAttrBg(state )
    if state then
        self:getImageViewByName("Image_attrBg1"):setVisible(false)
        self:getImageViewByName("Image_attrBg2"):setVisible(true)
    else
        self:getImageViewByName("Image_attrBg1"):setVisible(true)
        self:getImageViewByName("Image_attrBg2"):setVisible(false)
    end
end

function DressBookLayer:enterAnime( )
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ScrollView_List")}, false, 0.2, 2, 100)
    GlobalFunc.flyIntoScreenTB({self:getWidgetByName("Panel_buttom")}, false, 0.2, 2, 100)
end

function DressBookLayer:updateAttrs( )
    self:getLabelByName("Label_attrTitle"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_attrTitle"):setText(G_lang:get("LANG_DRESS_BOOKTOTAL"))
    local data = G_Me.dressData:getComposeAttr()
    self:updateAttrPanel(data,self:getPanelByName("Panel_attrs"))
end

function DressBookLayer:updateAttrPanel(data,panel )
    panel:removeAllChildrenWithCleanup(true)
    if not data or GlobalFunc.table_is_empty(data) then
        self:getLabelByName("Label_noAttr"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_noAttr"):setVisible(true)
        self:getImageViewByName("Image_more"):setVisible(false)
        return
    end
    self:getLabelByName("Label_noAttr"):setVisible(false)
    self:getImageViewByName("Image_more"):setVisible(true)
    local xpos = {33,273,}
    local ypos = 445
    local ystep = 30
    local count = 0
    for k , v in pairs(data) do 
        local widget = require("app.scenes.dress.DressBookAttrCell").new()
        widget:update(k,v)
        widget:setPosition(ccp(xpos[count%2+1],ypos-ystep*math.floor(count/2)))
        panel:addChild(widget)
        count = count + 1
    end
end

function DressBookLayer:attrPanelMove( )
    if GlobalFunc.table_is_empty(G_Me.dressData:getComposeAttr()) then
        return 
    end
    self:updataAttrBg(self._attrStatus)
    self:getImageViewByName("Image_more"):setVisible(self._attrStatus)
    local additionPosy = self._attrStatus and self._basey or 0 - self._basey
    local time = 0.2
    local ease = CCEaseIn:create(CCMoveBy:create(time, ccp(0, additionPosy)), time)
    self._attrPanel:runAction(ease)
    self._attrStatus = not self._attrStatus
end

function DressBookLayer:attrPanelReset( )
    self._attrStatus = false
    self._attrPanel:setPosition(ccp(0,self._basey))
    self:getImageViewByName("Image_more"):setVisible(true)
end

function DressBookLayer:_initScrollView()
    self._scrollView:removeAllChildren();
    local space = 0 --间隙
    local size = self._scrollView:getContentSize()
    local _knightItemWidth = 0
    local totalWidth = space
    for i = 1,dress_compose_info.getLength()+1 do
        
        local btnName = "dressBookItem" .. "_" .. i
        local data = dress_compose_info.indexOf(i)
        if i>dress_compose_info.getLength() then
            data=nil
        end
        local widget 
        if data and data.dress_3 > 0 then
            widget = require("app.scenes.dress.DressBookCellThree").new()
        else
            widget = require("app.scenes.dress.DressBookCellTwo").new()
        end
        widget:updateData(data)
        _knightItemWidth = widget:getWidth()
        widget:setName(btnName)

        widget:setPosition(ccp(totalWidth,0))
        totalWidth = totalWidth + _knightItemWidth + space
        self._scrollView:addChild(widget)
    end
    self._scrollView:setInnerContainerSize(CCSizeMake(totalWidth,size.height))
end

function DressBookLayer:_updateScrollView()
    for i = 1,dress_compose_info.getLength()+1 do
        local widget = self:getWidgetByName("dressBookItem" .. "_" .. i)
        if i >dress_compose_info.getLength() then
            widget:updateData()
        else
            widget:updateData(dress_compose_info.indexOf(i))
        end
    end
end

function DressBookLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end


function DressBookLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_middle", "", "Panel_buttom", 0, 0)
end

function DressBookLayer:reset()
    self:enterAnime()
end

return DressBookLayer

