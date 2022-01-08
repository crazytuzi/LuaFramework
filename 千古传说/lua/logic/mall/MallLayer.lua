--[[
******购物中心图层*******

	-- by david.dai
	-- 2014/6/11
]]

local MallLayer = class("MallLayer", BaseLayer)

function MallLayer:ctor(defaultIndex)
    self.super.ctor(self,defaultIndex)
    self:init("lua.uiconfig_mango_new.shop.Mall")
end

function MallLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.MallInfoList = {
        {path = 'lua.logic.mall.NormalMallInfo',tap = 'ui_new/shop/btn_shop.png'},
        {path = 'lua.logic.mall.CardRoleMallInfo',tap = 'ui_new/shop/btn_xiakeshop.png'},
        {path = 'lua.logic.mall.QunHaoMallInfo',tap = 'ui_new/shop/btn_qunhaoshop.png'},
        {path = 'lua.logic.mall.FactionMallInfo',tap = 'ui_new/shop/btn_zhenbaoge.png'},
        {path = 'lua.logic.mall.AdventureMallInfo',tap = 'ui_new/shop/btn_cangshuge.png'},
        {path = 'lua.logic.mall.HonorMallInfo',tap = 'ui_new/shop/btn_kuafushop.png'},
    }

    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead( self )
    self.generalHead:setData(ModuleType.Mall,{HeadResType.COIN,HeadResType.SYCEE})

    self.btnList = {}
    for i=1,5 do
        self.btnList[i] = TFDirector:getChildByPath(ui, 'btn_'..i)
        self.btnList[i].idx = i
        self.btnList[i].logic = self
    end

    for k,v in pairs(self.MallInfoList) do
        v.info = require(v.path):new()
        v.info:initUI(ui,self)
    end

    self.btnTap = {}
    self.posList = {}
    for i=1,3 do
        self.btnTap[i] = TFDirector:getChildByPath(ui,'btn_tap_'..i)
        self.btnTap[i].logic = self
        self.posList[i] = self.btnTap[i]:getPosition()
    end
    self.img_shensuo    = TFDirector:getChildByPath(ui, 'img_shensuo')
    self.panel_list     = TFDirector:getChildByPath(ui, 'panel_list')
    --self.btn_pageleft   = TFDirector:getChildByPath(ui, 'btn_pageleft')
    --self.btn_pageleft.logic   = self
    --self.btn_pageright  = TFDirector:getChildByPath(ui, 'btn_pageright')
    --self.btn_pageright.logic  = self
    self.curMallInfo = nil
    self.selectedIdx = nil
    self:showInfo(EnumMallType.NormalMall,1)
end

function MallLayer:removeUI()
    print("MallLayer:removeUI() ... ")
end

function MallLayer:registerEvents()
    print("MallLayer:registerEvents() ........")
    self.super.registerEvents(self)
    for i=1,5 do
        self.btnList[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.btnClickHandle))
    end
    for i = 1,3 do
        self.btnTap[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tapClickHandle))
    end
    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function MallLayer:removeEvents()
    print("MallLayer:removeEvents() ........")
    if self.curMallInfo then
        self.curMallInfo:removeEvents()
    end
    if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.super.removeEvents(self)
end

function MallLayer:showGuidePanel()
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

function MallLayer:removeGuidePanel()
    if self.guidePanel ~= nil then
        self.guidePanel:removeFromParent()
        self.guidePanel = nil;
    end
end

function MallLayer:showInfo0(index,btnIdx)
    self.curInfoIndex = index
    self.selectedIdx = btnIdx
    local index1 = self:mallTurnLeft(self.curInfoIndex)
    local index2 = self:mallTurnRight(self.curInfoIndex)
    local indexList = {index1,index2,self.curInfoIndex}
    local opacityList = {140,140,255}
    local visibleList = {true,true,true}
    local scaleList = {0.9,0.9,1}
    if index2 == index1 or index2 == self.curInfoIndex then
        visibleList[2] = false
    end
    if index1 == self.curInfoIndex then
        visibleList[1] = false
    end
    local action = nil
    for i=1,3 do
        local idx = indexList[i]
        local texturePath = self.MallInfoList[idx].tap
        self.btnTap[i]:setTextureNormal(texturePath)
        self.btnTap[i]:setTexturePressed(texturePath)
        local ac0 = CCFadeTo:create(0.3,opacityList[i])
        local ac1 = CCMoveTo:create(0.3,self.posList[i])
        local ac2 = CCScaleTo:create(0.3,1,scaleList[i])
        local spaw = CCSpawn:createWithTwoActions(ac0,ac1)
        spaw = CCSpawn:createWithTwoActions(spaw,ac2)
        local targetAc = CCTargetedAction:create(self.btnTap[i],spaw)
        if action == nil then
            action = targetAc
        else
            action = CCSpawn:createWithTwoActions(action,targetAc)
        end
        self.btnTap[i]:setTouchEnabled(false)
        self.btnTap[i]:setZOrder(self.btnTap[i].myZorder or i)
        self.btnTap[i]:setVisible(visibleList[i])
    end
    --self.isCall1 = true
    --local callFunc = function ()
    --    for i=1,3 do
            
    --        self.isCall1 = false
    --    end
    --end
    --self.btnTap[3]:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.05),CCCallFunc:create(callFunc)))

    self.isCall2 = true
    local callFunc0 = function ()
        for i=1,3 do
            self.btnTap[i]:setTouchEnabled(true)
            self.isCall2 = false
        end
        if self.curMallInfo then
            self.curMallInfo:close()
        end
        self.curMallInfo = self.MallInfoList[index].info
        if self.curMallInfo then
            self.curMallInfo:show(btnIdx)
        end
    end
    self.btnTap[3]:runAction(CCSequence:createWithTwoActions(action,CCCallFunc:create(callFunc0)))
end

function MallLayer:showInfo(index,btnIdx)
    self.curInfoIndex = index
    self.selectedIdx = btnIdx
    local index1 = self:mallTurnLeft(self.curInfoIndex)
    local index2 = self:mallTurnRight(self.curInfoIndex)
    local indexList = {index1,index2,self.curInfoIndex}
    local opacityList = {140,140,255}
    local visibleList = {true,true,true}
    local scaleList = {0.9,0.9,1}
    if index2 == index1 or index2 == self.curInfoIndex then
        visibleList[2] = false
    end
    if index1 == self.curInfoIndex then
        visibleList[1] = false
    end
    local action = nil
    for i=1,3 do
        local idx = indexList[i]
        local texturePath = self.MallInfoList[idx].tap
        self.btnTap[i]:setTextureNormal(texturePath)
        self.btnTap[i]:setTexturePressed(texturePath)
        self.btnTap[i]:setOpacity(opacityList[i])
        self.btnTap[i]:setPosition(self.posList[i])
        self.btnTap[i]:setScaleY(scaleList[i])
        self.btnTap[i]:setZOrder(self.btnTap[i].myZorder or i)
        self.btnTap[i]:setVisible(visibleList[i])
    end
    if self.curMallInfo then
        self.curMallInfo:close()
    end
    self.curMallInfo = self.MallInfoList[index].info
    if self.curMallInfo then
        self.curMallInfo:show(btnIdx)
    end
end

function MallLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function MallLayer.btnClickHandle(sender)
    local self = sender.logic
    if self.selectedIdx == sender.idx then
        return
    end
    self.selectedIdx = sender.idx
    if self.curMallInfo then
        self.curMallInfo:btnSelect(sender.idx)
    end
end

function MallLayer:mallTurnLeft(index0)
    local index = index0
    index = index - 1
    if index <= 0 then
        index = #(self.MallInfoList)
    end
    local mallInfo = self.MallInfoList[index].info
    if mallInfo:isOpen() == false then
        return self:mallTurnLeft(index)
    else
        return index
    end
end

function MallLayer:mallTurnRight(index0)
    local index = index0
    index = index + 1
    if index > #(self.MallInfoList) then
        index = 1
    end
    local mallInfo = self.MallInfoList[index].info
    if mallInfo:isOpen() == false then
        return self:mallTurnRight(index)
    else
        return index
    end
end

function MallLayer:pageRightClickHandle()
    print("pageRightClickHandle")
    if self.curInfoIndex == nil then self.curInfoIndex = 1 end
    self.curInfoIndex = self:mallTurnRight(self.curInfoIndex)
    local tampBtn = {}
    for i=1,3 do
        tampBtn[i] = self.btnTap[i]
    end
    self.btnTap[1] = tampBtn[3]
    self.btnTap[1].myZorder = 2
    self.btnTap[2] = tampBtn[1]
    self.btnTap[2].myZorder = 1
    self.btnTap[2]:setPositionX(self.posList[3].x)
    self.btnTap[3] = tampBtn[2]
    self.btnTap[3].myZorder = 3
    self:showInfo0(self.curInfoIndex,1)
end

function MallLayer.tapClickHandle( sender )
    print("tapClickHandle")
    local self = sender.logic
    if self.isCall1 == true or self.isCall2 == true then
        return
    end
    if sender ==  self.btnTap[1] then
        self:pageLeftClickHandle()
    elseif sender == self.btnTap[2] then
        self:pageRightClickHandle()
    end
end

function MallLayer:pageLeftClickHandle()
    print("pageLeftClickHandle")
    if self.curInfoIndex == nil then self.curInfoIndex = 1 end
    self.curInfoIndex = self:mallTurnLeft(self.curInfoIndex)
    local tampBtn = {}
    for i=1,3 do
        tampBtn[i] = self.btnTap[i]
    end
    self.btnTap[1] = tampBtn[2]
    self.btnTap[1].myZorder = 1
    self.btnTap[1]:setPositionX(self.posList[3].x)
    self.btnTap[2] = tampBtn[3]
    self.btnTap[2].myZorder = 2
    self.btnTap[3] = tampBtn[1]
    self.btnTap[3].myZorder = 3
    self:showInfo0(self.curInfoIndex,1)
end

-----断线重连支持方法
function MallLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    if self.curMallInfo then
        self.curMallInfo:onShow()
    end
end

function MallLayer:dispose()
    if self.curMallInfo then
        self.curMallInfo:dispose()
    end
    
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

return MallLayer