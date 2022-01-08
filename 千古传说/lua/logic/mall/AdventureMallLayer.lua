--[[
******游历商城层*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local AdventureMallLayer = class("AdventureMallLayer", BaseLayer)

function AdventureMallLayer:ctor(defaultIndex)
    self.super.ctor(self,defaultIndex)
    self:init("lua.uiconfig_mango_new.shop.AdventureMall")
end

function AdventureMallLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.CangShuGe,{HeadResType.ZHENBCY,HeadResType.SYCEE})
    self.headType = {   HeadResType.ZHENBCY,
                        HeadResType.SHANBCY,
                        HeadResType.QUANBCY,
                        HeadResType.CHAOBCY,
                        HeadResType.CANBCY}
    self.btnTap = {}
    for i=1,5 do
        self.btnTap[i] = TFDirector:getChildByPath(ui, 'btn_'..i)
        self.btnTap[i].id = i
    end

    self.img_shensuo        = TFDirector:getChildByPath(ui, 'img_shensuo')

    self.panel_list    = TFDirector:getChildByPath(ui, 'panel_list')
    self.normalShopPage = require('lua.logic.mall.AdventureShopPage'):new()
    self.normalShopPage:setName("shopPage")
    self.panel_list:addChild(self.normalShopPage)
    self:initData()

    self:choiceDefault()
end

function AdventureMallLayer:initData()
    self.dataList = {}
    for data in AdventureShopData:iterator() do
        self.dataList[data.type] = self.dataList[data.type] or {}
        local len = #(self.dataList[data.type])
        self.dataList[data.type][len+1] = data
    end
end

function AdventureMallLayer:refreshButton()
    for i=1,5 do
        self.btnTap[i]:setTextureNormal("ui_new/youli/shop/btn_"..i..".png")
    end
end

function AdventureMallLayer:removeUI()
    print("AdventureMallLayer:removeUI() ... ")
    self.super.removeUI(self)
end

function AdventureMallLayer:registerEvents()
    print("AdventureMallLayer:registerEvents() ........")
    self.super.registerEvents(self)
    for i=1,5 do
        self.btnTap[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(self.OnBtnTapClick,self)))
    end
    self.shopBuyCallBack = function(event)
        self.normalShopPage.tableView:reloadData()
        self.generalHead:refreshUI()
    end
    TFDirector:addMEGlobalListener(AdventureManager.adventureShopBuy, self.shopBuyCallBack)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function AdventureMallLayer:OnBtnTapClick(sender)
    local id = sender.id
    if self.selectedButton == sender then
        return
    end
    self.selectedButton = sender
    self:select(id)
end

function AdventureMallLayer:removeEvents()
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    TFDirector:removeMEGlobalListener(AdventureManager.adventureShopBuy, self.shopBuyCallBack)
    self.super.removeEvents(self)
end

function AdventureMallLayer:showGuidePanel()
    local guidePanel = TFPanel:create()
    guidePanel:setSize(CCSize(GameConfig.WS.width, 80))
    local headPos = self.panel_head:getPosition()
    guidePanel:setPosition(ccp(headPos.x, headPos.y))

    guidePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
    guidePanel:setBackGroundColorOpacity(130)
    guidePanel:setBackGroundColor(ccc3(0,0,0))
    guidePanel:setZOrder(100)
    guidePanel:setTouchEnabled(true)
    self:addChild(guidePanel)
    self.guidePanel = guidePanel
end

function AdventureMallLayer:removeGuidePanel()
    if self.guidePanel ~= nil then
        self.guidePanel:removeFromParent()
        self.guidePanel = nil;
    end
end

function AdventureMallLayer:choiceDefault()
    if self.selectedButton ~= nil then
        return
    end
    self.selectedButton = self.btnTap[1]
    self:select(1)
end

function AdventureMallLayer:select(index)
    self:refreshButton()
    self.btnTap[index]:setTextureNormal("ui_new/youli/shop/btn_"..index.."s.png")
    self.generalHead.buyButtonEventBound = nil
    self.generalHead:setData(ModuleType.CangShuGe,{self.headType[index],HeadResType.SYCEE})
    self.generalHead:refreshUI()
    local data = self.dataList[index]
    self.normalShopPage:setData(self.headType[index],data)
end

function AdventureMallLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function AdventureMallLayer:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function AdventureMallLayer:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:show()
    end
end

-----断线重连支持方法
function AdventureMallLayer:onShow()
    self.super.onShow(self)
    if self.currentLayer then
        self.currentLayer:onShow()
    end
    self.generalHead:onShow();
end

function AdventureMallLayer:dispose()
    if self.normalShopPage then
        self.normalShopPage:dispose()
        self.normalShopPage = nil
    end
    
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

return AdventureMallLayer