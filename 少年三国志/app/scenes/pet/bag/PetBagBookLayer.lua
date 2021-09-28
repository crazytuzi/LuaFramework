-- PetBagBookLayer.lua

local PetBagBookCellThree = require("app.scenes.pet.bag.PetBagBookCellThree")
local PetBagBookCellTwo = require("app.scenes.pet.bag.PetBagBookCellTwo")
local PetBagBookAttrCell = require("app.scenes.pet.bag.PetBagBookAttrCell")

local PetBagBookLayer = class("PetBagBookLayer", UFCCSNormalLayer)
require("app.cfg.pet_compose_info")

PetBagBookLayer.BASE_Y = -450

function PetBagBookLayer.create(scene)

    local layer = PetBagBookLayer.new("ui_layout/petbag_BookLayer.json",require("app.setting.Colors").modelColor) 
    return layer
end

function PetBagBookLayer:ctor(...)

    self.super.ctor(self, ...)

    self._scrollView     = self:getScrollViewByName("ScrollView_List")
    self._attrPanel      = self:getPanelByName("Panel_attrPanel")
    self._attrBg1Image   = self:getImageViewByName("Image_attrBg1")
    self._attrBg2Image   = self:getImageViewByName("Image_attrBg2")
    self._attrTitleLabel = self:getLabelByName("Label_attrTitle")
    self._noAttrLabel    = self:getLabelByName("Label_noAttr")
    self._moreImage      = self:getImageViewByName("Image_more")

    self._petBookIds = {}

    self._attrStatus = false
    
    self:updataAttrBg(true)
    self:registerWidgetClickEvent("Panel_attrPanel", function()
         self:attrPanelMove()
    end)
end

function PetBagBookLayer:onLayerEnter( )

    self:_initScrollView()
    self:attrPanelReset()
end

function PetBagBookLayer:updateData( )

    self:_updateScrollView()
    self:updateAttrs()
end

function PetBagBookLayer:updataAttrBg(state )

    if state then

        self._attrBg1Image:setVisible(false)
        self._attrBg2Image:setVisible(true)
    else

        self._attrBg1Image:setVisible(true)
        self._attrBg2Image:setVisible(false)
    end
end

function PetBagBookLayer:enterAnime( )

self:callAfterFrameCount(2, function ( ... )
    GlobalFunc.flyIntoScreenLR({self._scrollView}, false, 0.2, 2, 100)
    GlobalFunc.flyIntoScreenTB({self:getWidgetByName("Panel_buttom")}, false, 0.2, 2, 100)
end)
    
end

function PetBagBookLayer:updateAttrs( )
    
    self._attrTitleLabel:setText(G_lang:get("LANG_PET_BOOKTOTAL"))
    self._attrTitleLabel:createStroke(Colors.strokeBrown, 1)
    local data = G_Me.bagData.petData:getComposeAttr()
    self:updateAttrPanel(data,self:getPanelByName("Panel_attrs"))
end

function PetBagBookLayer:updateAttrPanel(data,panel )

    panel:removeAllChildrenWithCleanup(true)
    if not data or GlobalFunc.table_is_empty(data) then
        self._noAttrLabel:createStroke(Colors.strokeBrown, 1)
        self._noAttrLabel:setVisible(true)
        self._moreImage:setVisible(false)
        return
    end
    self._noAttrLabel:setVisible(false)
    self._moreImage:setVisible(true)
    local xpos = {33,273,}
    local ypos = 445
    local ystep = 30
    local count = 0
    for k , v in pairs(data) do 

        local widget = PetBagBookAttrCell.new()
        widget:update(k,v)
        widget:setPosition(ccp(xpos[count%2+1],ypos-ystep*math.floor(count/2)))
        panel:addChild(widget)
        count = count + 1
    end
end

function PetBagBookLayer:attrPanelMove( )

    if GlobalFunc.table_is_empty(G_Me.bagData.petData:getComposeAttr()) then
        return 
    end
    self:updataAttrBg(self._attrStatus)
    self._moreImage:setVisible(self._attrStatus)
    local additionPosy = self._attrStatus and PetBagBookLayer.BASE_Y or 0 - PetBagBookLayer.BASE_Y
    local time = 0.2
    local ease = CCEaseIn:create(CCMoveBy:create(time, ccp(0, additionPosy)), time)
    self._attrPanel:runAction(ease)
    self._attrStatus = not self._attrStatus
end

function PetBagBookLayer:attrPanelReset( )

    self._attrStatus = false
    self._attrPanel:setPosition(ccp(0,PetBagBookLayer.BASE_Y))
    self._moreImage:setVisible(true)
end

function PetBagBookLayer:_initScrollView()

    self._scrollView:removeAllChildren()
    local space = 0 --间隙
    local size = self._scrollView:getContentSize()
    local _petItemWidth = 0
    local totalWidth = space
    for i = 1,pet_compose_info.getLength()+1 do
        
        local btnName = "petBookItem_" .. i
        local data = pet_compose_info.indexOf(i)
        if i>pet_compose_info.getLength() then
            data=nil
        end
        local widget 
        if data and data.pet_3 > 0 then
            widget = PetBagBookCellThree.new()
        else
            widget = PetBagBookCellTwo.new()
        end
        widget:updateData(data)
        _petItemWidth = widget:getWidth()
        widget:setName(btnName)

        widget:setPosition(ccp(totalWidth,0))
        totalWidth = totalWidth + _petItemWidth + space
        self._scrollView:addChild(widget)
    end
    self._scrollView:setInnerContainerSize(CCSizeMake(totalWidth,size.height))
end

function PetBagBookLayer:_updateScrollView()

    for i = 1,pet_compose_info.getLength()+1 do
        local widget = self:getWidgetByName("petBookItem_" .. i)
        if i >pet_compose_info.getLength() then
            widget:updateData()
        else
            widget:updateData(pet_compose_info.indexOf(i))
        end
    end
end

function PetBagBookLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_middle", "", "Panel_buttom", 0, 0)
end

function PetBagBookLayer:reset()
    self:updateData()

    if self._attrStatus == true then
        self:attrPanelMove()
    end
    
    self:enterAnime()
end

return PetBagBookLayer

