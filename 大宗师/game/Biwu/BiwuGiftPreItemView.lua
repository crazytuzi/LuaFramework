--
-- Author: Daneil 
-- Date: 2015-01-15 15:33:35
--
local btnGetRes = {
    normal   =  "#btn_get_n.png",
    pressed  =  "#btn_get_p.png",
    disabled =  "#btn_get_p.png"
}

local BiwuGiftPreItemView = class("BiwuGiftPreItemView", function()
    return display.newLayer("BiwuGiftPreItemView")
end)

function BiwuGiftPreItemView:ctor(size,data,mainscene,parent)
    self:setContentSize(size)
    self._leftToRightOffset = 10
    self._topToDownOffset = 2
    self._frameSize = size

    self._containner = nil
    self._padding = {
        left  = 20,
        right = 20,
        top   = 15,
        down  = 20
    }
    self._data = data
    self:setUpView()
    self._mainMenuScene = mainscene
    self._parent = parent
    --控件
    self._icon = nil
end


function BiwuGiftPreItemView:setUpView()
    self._containner =  display.newScale9Sprite("#reward_item_bg.png", 0, 0, 
        cc.size(self._frameSize.width - self._leftToRightOffset * 2, 
            self._frameSize.height - self._topToDownOffset * 2))
        :pos(self._frameSize.width / 2, self._frameSize.height / 2)
    local containnerSize = self._containner:getContentSize()
    self._containner:setAnchorPoint(cc.p(0.5,0.5))
    self:addChild(self._containner)

    --15积分可领取背景
    local titleBngHeight = 40
    local titleBng = display.newScale9Sprite("#heroinfo_cost_st_bg.png" , 0 , 0 ,
        cc.size(containnerSize.width - self._padding.left - self._padding.right,titleBngHeight))
        :pos(self._padding.left , containnerSize.height - self._padding.top)
        :addTo(self._containner)
    titleBng:setAnchorPoint(cc.p(0,1))
    local titleBngSize = titleBng:getContentSize()  

    display.newSprite("#reward_item_title_bg.png") 
        :pos(0, titleBngSize.height / 2)
        :addTo(titleBng)
        :setAnchorPoint(cc.p(0,0.5))

    --15积分文字
    local marginLeft = 20
    local text
    if self._data.min == self._data.max then
    	text = self._data.min
    else
    	text = self._data.min.."~"..self._data.max
    end
    local textExt = ""
    if  self._data.max == 0 then
    	textExt = "以后"
    	text = self._data.min
    end

    local dislabel = ui.newTTFLabel({text = "第"..text.."名"..textExt, size = 20, font = FONTS_NAME.font_fzcy, align = ui.TEXT_ALIGN_LEFT})
        :pos(marginLeft, titleBngSize.height / 2)
        :addTo(titleBng)
    dislabel:setAnchorPoint(cc.p(0,0.5))

    --道具框
    local marginTop   = 5
    local offset      = 10
    local marginRight = 120
    local itemsViewBngs = display.newScale9Sprite("#heroinfo_title_bg.png" , 0 , 0 ,
        cc.size(containnerSize.width - self._padding.left - self._padding.right ,
            containnerSize.height - self._padding.top - self._padding.down - titleBngHeight - marginTop))
        :pos(self._padding.left , self._padding.down)
        :addTo(self._containner)
    itemsViewBngs:setAnchorPoint(cc.p(0,0))

    for i=1, #self._data.giftData do
        self:createItem(i,itemsViewBngs,itemsViewBngs:getContentSize())
    end

end

function BiwuGiftPreItemView:setData()

end

function BiwuGiftPreItemView:createItem(index,itemsViewBngs,containnerSize)
    local marginTop  = 10
    local marginLeft = 10
    local offset = 100

    self._icon = ResMgr.refreshIcon(
        {
            id = self._data.giftData[index].id, 
            resType = self._data.giftData[index].iconType, 
            iconNum = self._data.giftData[index].num, 
            isShowIconNum = true, 
            numLblSize = 22, 
            numLblColor = ccc3(0, 255, 0), 
            numLblOutColor = ccc3(0, 0, 0) 
        }) 
    self._icon:setAnchorPoint(cc.p(0,0.5)) 
    self._icon:setPosition(cc.p(self._padding.left + (index - 1) * offset, containnerSize.height / 2 + marginTop))
    local iconSize = self._icon:getContentSize()
    local iconPosX = self._icon:getPositionX()
    local iconPosY = self._icon:getPositionY()


    -- 名称
    local nameColor = ccc3(255, 255, 255) 
    if self._data.giftData[index].iconType == ResMgr.HERO then 
        nameColor = ResMgr.getHeroNameColor(self._data.giftData[index].id)
    elseif self._data.giftData[index].iconType == ResMgr.ITEM or self._data.giftData[index].iconType == ResMgr.EQUIP then 
        nameColor = ResMgr.getItemNameColor(self._data.giftData[index].id) 
    end 

    ui.newTTFLabelWithShadow({
        text = self._data.giftData[index].name,
        size = 20,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_CENTER
    })
        :pos(iconSize.width /2 , -20)
        :addTo(self._icon)
        :setAnchorPoint(cc.p(0,1))

    local tag
    -- 装备碎片
    if self._data.giftData[index].type == 3 then
        tag = display.newSprite("#sx_suipian.png")
    elseif self._data.giftData[index].type == 5 then
        -- 残魂(武将碎片)
        tag = display.newSprite("#sx_canhun.png")
    end
    if tag then
        self._icon:addChild(tag)
        tag:setRotation(-20)
        tag:setPosition(cc.p(40,75))
    end


    if self._data.giftData[index].type == 6 then
        local iconSp = require("game.Spirit.SpiritIcon").new({
            resId = self._data.giftData[index].id,
            bShowName = true,
        })
        itemsViewBngs:addChild(iconSp)
        iconSp:setAnchorPoint(cc.p(0,0.5)) 
        iconSp:setPosition(self._icon:getPosition())
    else
        itemsViewBngs:addChild(self._icon)
    end
end

return BiwuGiftPreItemView
    
    
