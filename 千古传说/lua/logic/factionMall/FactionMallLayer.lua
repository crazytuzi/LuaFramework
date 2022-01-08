--[[
******购物中心图层*******

	-- by david.dai
	-- 2014/6/11
]]

local FactionMallLayer = class("FactionMallLayer", BaseLayer)

function FactionMallLayer:ctor(defaultIndex)
    self.super.ctor(self,defaultIndex)
    self:init("lua.uiconfig_mango_new.faction.FactionMall")
end

function FactionMallLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.FactionMall,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE})

    self.btn_chuanshuo        = TFDirector:getChildByPath(ui, 'btn_chuanshuo')
    self.btn_normal    = TFDirector:getChildByPath(ui, 'btn_normal')
    self.btn_jingpin          = TFDirector:getChildByPath(ui, 'btn_jingpin')

    self.img_shensuo        = TFDirector:getChildByPath(ui, 'img_shensuo')
    self.btn_chuanshuo.logic = self
    self.btn_normal.logic = self
    self.btn_jingpin.logic = self

    self.panel_list    = TFDirector:getChildByPath(ui, 'panel_list')

    self.back_line = {}
    self.back_line[1] = TFDirector:getChildByPath(ui, 'Image_Mall_1')
    self.back_line[2] = TFDirector:getChildByPath(ui, 'Image_Mall_2')

    self:choiceDefault()
end

function FactionMallLayer:refreshButton()
    local buttonList = {self.btn_normal, self.btn_jingpin,self.btn_chuanshuo}
    local randomStore = MallManager:getrandomStoreTable()
    if randomStore[RandomStoreType.Gang_Normal]:isOpen() == false then
        self.btn_normal:setVisible(false)
    end
    if randomStore[RandomStoreType.Gang_2]:isOpen() == false then
        self.btn_jingpin:setVisible(false)
    end
    if randomStore[RandomStoreType.Gang_3]:isOpen() == false then
        self.btn_chuanshuo:setVisible(false)
    end
    local temp = 0
    local pos_y = buttonList[1]:getPositionY()
    for i=1,3 do
        if buttonList[i]:isVisible() then
            buttonList[i]:setPositionY( pos_y - temp*110 )
            temp = temp + 1
        end
    end
    self.img_shensuo:setPositionY(95 + (4 - temp)*110)
end

function FactionMallLayer:removeUI()
    print("FactionMallLayer:removeUI() ... ")
    self.super.removeUI(self)
end

function FactionMallLayer:registerEvents()
    print("FactionMallLayer:registerEvents() ........")
    self.super.registerEvents(self)
    self:refreshButton()
    self.btn_normal:addMEListener(TFWIDGET_CLICK, audioClickfun(self.normalShopButtonClickHandle))
    self.btn_jingpin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.giftsButtonClickHandle))
    self.btn_chuanshuo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.xiyouButtonClickHandle))

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function FactionMallLayer:removeEvents()
    print("FactionMallLayer:removeEvents() ........")
    --按钮事件
    self.btn_normal:removeMEListener(TFWIDGET_CLICK)
    self.btn_jingpin:removeMEListener(TFWIDGET_CLICK)
    self.btn_chuanshuo:removeMEListener(TFWIDGET_CLICK)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.super.removeEvents(self)
end

-- function FactionMallLayer:showGuidePanel()
--     local guidePanel = TFPanel:create()
--     guidePanel:setSize(CCSize(GameConfig.WS.width, 80))
--     local headPos = self.panel_head:getPosition()
--     guidePanel:setPosition(ccp(headPos.x, headPos.y))

--     guidePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
--     guidePanel:setBackGroundColorOpacity(130)
--     guidePanel:setBackGroundColor(ccc3(0,0,0))
--     guidePanel:setZOrder(100)
--     guidePanel:setTouchEnabled(true)
--     self:addChild(guidePanel)
--     self.guidePanel = guidePanel
-- end

-- function FactionMallLayer:removeGuidePanel()
--     if self.guidePanel ~= nil then
--         self.guidePanel:removeFromParent()
--         self.guidePanel = nil;
--     end
-- end

function FactionMallLayer:choiceDefault()
    if self.selectedButton ~= nil then
        return
    end

    if self.defaultIndex then
        if self.defaultIndex == 2 then
            self:selectNormalShop()
        elseif self.defaultIndex == 3 then
            self:selectGifts()
        else
            self:selectNormalShop()
        end
    else
        self:selectNormalShop()
    end
end

function FactionMallLayer:select(index)
    if index then
        if index == 2 then
            self:selectNormalShop()
        elseif index == 3 then
            self:selectGifts()
        else
            self:selectNormalShop()
        end
    else
        self:selectNormalShop()
    end
end

function FactionMallLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function FactionMallLayer:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function FactionMallLayer:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:show()
    end
end

function FactionMallLayer:selectNormalShop()
    self.selectedButton = self.btn_normal
    self:hideCurrentLayer()

    self.btn_chuanshuo:setTextureNormal("ui_new/faction/btn_shop_chuanshuo1.png")
    self.btn_normal:setTextureNormal("ui_new/faction/btn_shop_putong2.png")
    self.btn_jingpin:setTextureNormal("ui_new/faction/btn_shop_jingpin1.png")

    --创建显示内容图层
    if self.normalShopPage == nil then
        self.normalShopPage = require('lua.logic.factionMall.FactionShopPage'):new(RandomStoreType.Gang_Normal)
        self.panel_list:addChild(self.normalShopPage)
    end

    self.currentLayer = self.normalShopPage
    self:showCurrentLayer()
    for i=1,#self.back_line do
        self.back_line[i]:setVisible(true)
    end
    
    -- MallManager:onIntoGoodsLayer();
    -- CommonManager:updateRedPoint(self.btn_normal, MallManager:isHaveNewGoods(),ccp(-10,-10))
end

function FactionMallLayer:selectGifts()
    self.selectedButton = self.btn_jingpin
    self:hideCurrentLayer()

    self.btn_chuanshuo:setTextureNormal("ui_new/faction/btn_shop_chuanshuo1.png")
    self.btn_normal:setTextureNormal("ui_new/faction/btn_shop_putong1.png")
    self.btn_jingpin:setTextureNormal("ui_new/faction/btn_shop_jingpin2.png")

    --创建显示内容图层
    if self.giftsPage == nil then
        self.giftsPage = require('lua.logic.factionMall.FactionShopPage'):new(RandomStoreType.Gang_2)
        self.panel_list:addChild(self.giftsPage)
    end
    
    self.currentLayer = self.giftsPage
    self:showCurrentLayer()
    for i=1,#self.back_line do
        self.back_line[i]:setVisible(true)
    end
end


function FactionMallLayer:selectXiyou()
    self.selectedButton = self.btn_chuanshuo
    self:hideCurrentLayer()

    self.btn_chuanshuo:setTextureNormal("ui_new/faction/btn_shop_chuanshuo1.png")
    self.btn_normal:setTextureNormal("ui_new/faction/btn_shop_putong1.png")
    self.btn_jingpin:setTextureNormal("ui_new/faction/btn_shop_jingpin1.png")

    --创建显示内容图层
    if self.xiyouPage == nil then
        self.xiyouPage = require('lua.logic.factionMall.FactionShopPage'):new(RandomStoreType.Gang_3)
        self.panel_list:addChild(self.xiyouPage)
    end

    self.currentLayer = self.xiyouPage
    self:showCurrentLayer()
    for i=1,#self.back_line do
        self.back_line[i]:setVisible(true)
    end
end





function FactionMallLayer.normalShopButtonClickHandle(sender)
    local self = sender.logic
    if self.selectedButton == self.btn_normal then
        return
    end
    self:selectNormalShop()

    
end

function FactionMallLayer.giftsButtonClickHandle(sender)
    local self = sender.logic
    if self.selectedButton == self.btn_jingpin then
        return
    end
    self:selectGifts()
end

function FactionMallLayer.xiyouButtonClickHandle(sender)
    local self = sender.logic
    if self.selectedButton == self.btn_chuanshuo then
        return
    end
    self:selectXiyou()

    MallManager:onIntoXiyouLayer();
    -- CommonManager:updateRedPoint(self.btn_chuanshuo, MallManager:isHaveXiyouNewGoods(),ccp(-10,-10))
end




-----断线重连支持方法
function FactionMallLayer:onShow()
    self.super.onShow(self)
    if self.currentLayer then
        self.currentLayer:onShow()
    end
    self.generalHead:onShow();

    -- CommonManager:updateRedPoint(self.btn_jingpin, MallManager:isHaveNewGif(),ccp(-10,-10))
    -- CommonManager:updateRedPoint(self.btn_normal, MallManager:isHaveNewGoods(),ccp(-10,-10))
    -- CommonManager:updateRedPoint(self.btn_chuanshuo, MallManager:isHaveXiyouNewGoods(),ccp(-10,-10))
    
end

function FactionMallLayer:dispose()
    if self.giftsPage then
        self.giftsPage:dispose()
        self.giftsPage = nil
    end

    if self.normalShopPage then
        self.normalShopPage:dispose()
        self.normalShopPage = nil
    end

    if self.xiyouPage then
        self.xiyouPage:dispose()
        self.xiyouPage = nil
    end

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

return FactionMallLayer