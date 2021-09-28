local btnGetRes = {
    normal   =  "#get_tag_n.png",
    pressed  =  "#get_tag_p.png",
    disabled =  "#get_tag_p.png"
}

local typeEnum = {
    task    = 1,
    road    = 2,
    collect = 3
}

local titleDis = {
    task    = "每日任务",
    road    = "成长之路",
    collect = "收集"
}

local GiftGetOkPopup = class("GiftGetOkPopup", function()
    return display.newLayer("GiftGetOkPopup")
end)

function GiftGetOkPopup:ctor(data)
    self._padding = {
        left  = 20,
        right = 10,
        top   = 15,
        down  = 20
    }
    self._mainFrameHeightOffset = 700
    self._mainFrameWidthOffset  = 100
    self._mainPopupSize = nil
    self._innerContainerBorderOffset = 15
    self._innerContainerHeight = 360
    self._innerContainerSize = nil

    self._titleDisOffsetOfTop = 20
    self._titleDisFontSize = 25
    self._data = data

    self._mianPopup = nil
    self._innerContainer = nil
    self:setUpView()
end

function GiftGetOkPopup:setUpView()

    local winSize = CCDirector:sharedDirector():getWinSize()
    local mask = CCLayerColor:create()
    mask:setContentSize(winSize)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(150)
    mask:setAnchorPoint(cc.p(0,0))
    mask:setTouchEnabled(true)
    self:addChild(mask)

    self._mianPopup = display.newScale9Sprite("#win_base_bg2.png", 0, 0, 
        cc.size(display.width - self._mainFrameWidthOffset, (display.width - self._mainFrameWidthOffset) / 2 + 90))
        :pos(display.cx,display.cy)
        :addTo(self)
    self._mainPopupSize = self._mianPopup:getContentSize()
    self._innerContainerHeight = self._mainPopupSize.height - 80
    self._innerContainer = display.newScale9Sprite("#win_base_inner_bg_light.png", 0, 0, 
        cc.size(self._mainPopupSize.width - self._innerContainerBorderOffset * 2, self._innerContainerHeight))
        :pos(self._mainPopupSize.width / 2, self._innerContainerBorderOffset)
        :addTo(self._mianPopup)
    self._innerContainerSize = self._innerContainer:getContentSize()
    self._innerContainer:setAnchorPoint(cc.p(0.5,0))                 
    --关闭按钮
    cc.ui.UIPushButton.new(btnCloseRes)
        :onButtonClicked(function()
            self:removeFromParent()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        end)
        :pos(self._mainPopupSize.width, self._mainPopupSize.height)
        :addTo(self._mianPopup):setAnchorPoint(cc.p(1,1))
    --title标签

    self._titleDisLabel = ui.newTTFLabelWithShadow({
        text = "奖励领取",
        size = 22,
        color = ccc3(225,225,225),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
        })
        :pos( self._mainPopupSize.width / 2, self._mainPopupSize.height - self._titleDisOffsetOfTop - 10)
        :addTo(self._mianPopup)
    self._titleDisLabel:setAnchorPoint(cc.p(0.5,1))    
    --标题
    local marginTop = 30


    local disLabel = ui.newTTFLabelWithShadow({
        text = string.format("达到%d积分奖励领取",self._data.jifen),
        size = 22,
        color = ccc3(225,225,225),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
        })
        :pos(self._innerContainerSize.width / 2, self._innerContainerSize.height - marginTop)
        :addTo(self._innerContainer)
    disLabel:setAnchorPoint(cc.p(0.5,1))    

    local marginLeft  = 20
    local marginRight = 20
    local marginTop   = 0
    local marginDown  = 20
    local itemsViewHeight = self._innerContainerHeight - 140
    local itemViewBng = display.newScale9Sprite("#heroinfo_title_bg.png", 0, 0, 
                        cc.size( self._innerContainerSize.width - marginLeft - marginRight , itemsViewHeight))
                        :pos( self._innerContainerSize.width / 2 , 
                              disLabel:getPositionY() - 
                              disLabel:getContentSize().height - marginTop)
                        :addTo(self._innerContainer)
    itemViewBng:setAnchorPoint(cc.p(0.5,1))

    --按钮
    local marginDown = 10
    local getBtn = cc.ui.UIPushButton.new(btnGetRes)
        :onButtonClicked(function()
            self:removeFromParent()
        end)
        :pos( self._innerContainerSize.width / 2 , marginDown)
        :addTo(self._innerContainer)
    getBtn:setAnchorPoint(cc.p(0.5,0))

    self._giftData = TaskModel:getInstance():getGiftList(self._data.id)
    for i=1, #self._giftData do
        self:createItem(i,itemViewBng,itemViewBng:getContentSize())
    end
end

function GiftGetOkPopup:createItem(index,itemsViewBngs,containnerSize)
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100
    self._icon = ResMgr.getIconSprite(
    {
        id = self._giftData[index].id, 
        resType = ResMgr.getResType(self._giftData[index].type), 
        iconNum = self._giftData[index].num, 
        itemBg = display.newSprite("#gold_close.png"),
        isShowIconNum = false, 
        numLblSize = 22, 
        numLblColor = ccc3(0, 255, 0), 
        numLblOutColor = ccc3(0, 0, 0) 
    }) 
    self._icon:setAnchorPoint(cc.p(0,0.5)) 
    self._icon:setPosition(cc.p(self._padding.left + (index - 1) * offset, containnerSize.height / 2 + marginTop))
    local iconSize = self._icon:getContentSize()
    local iconPosX = self._icon:getPositionX()
    local iconPosY = self._icon:getPositionY()
    itemsViewBngs:addChild(self._icon)

    local type = ResMgr.getResType(self._giftData[index].type)
    -- 名称
    local nameColor = ccc3(255, 255, 255) 
    if type == ResMgr.HERO then 
        nameColor = ResMgr.getHeroNameColor(self._giftData[index].id)
    elseif type == ResMgr.ITEM or type == ResMgr.EQUIP then 
        nameColor = ResMgr.getItemNameColor(self._giftData[index].id) 
    end 

    ui.newTTFLabelWithShadow({
        text = self._giftData[index].name,
        size = 20,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
        })
        :pos(iconSize.width /2 , -20)
        :addTo(self._icon)
        :setAnchorPoint(cc.p(0,1))
end

return GiftGetOkPopup
