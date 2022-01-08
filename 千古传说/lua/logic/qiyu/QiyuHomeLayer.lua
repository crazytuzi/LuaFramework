
local QiyuHomeLayer = class("QiyuHomeLayer", BaseLayer)

function QiyuHomeLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.QiyuHomeLayer")
end

function QiyuHomeLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Qiyu,{HeadResType.COIN,HeadResType.SYCEE})

    self.qiyuLayer = {}

    self:InitQiyuList()
    self:InitQiyuBtn()
end

function QiyuHomeLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
end

function QiyuHomeLayer:registerEvents(ui)
    self.super.registerEvents(self)

    if self.qiyuLayer then
        for k,v in pairs(self.qiyuLayer) do
            v:registerEvents()
        end
    end

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function QiyuHomeLayer:removeEvents()
    self.super.removeEvents(self)
    if self.qiyuLayer then
        for k,v in pairs(self.qiyuLayer) do
            v:removeEvents()
        end
    end
    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

function QiyuHomeLayer:removeUI()
    self.super.removeUI(self)
end

function QiyuHomeLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    for k,v in pairs(self.qiyuLayer) do
        v:dispose()
    end

    self.super.dispose(self)
end

function QiyuHomeLayer:InitQiyuList()
    self.qiyuTmpList = {}

    self.qiyuTmpList[QiYuType.EatPig] = {}
    self.qiyuTmpList[QiYuType.EatPig].btnNormal = "ui_new/qiyu/eatpig_btn.png"
    self.qiyuTmpList[QiYuType.EatPig].btnSelect = "ui_new/qiyu/eatpig_btn_s.png"
    self.qiyuTmpList[QiYuType.EatPig].layerName = "lua.logic.qiyu.EatPigLayer"
    self.qiyuTmpList[QiYuType.EatPig].funId     = 900+QiYuType.EatPig
    --
    self.qiyuTmpList[QiYuType.Invite] = {}
    self.qiyuTmpList[QiYuType.Invite].btnNormal = "ui_new/qiyu/yqm_anniu.png"
    self.qiyuTmpList[QiYuType.Invite].btnSelect = "ui_new/qiyu/yqm_anniu_press.png"
    self.qiyuTmpList[QiYuType.Invite].layerName = "lua.logic.qiyu.InviteFriendLayer_new"
    self.qiyuTmpList[QiYuType.Invite].funId     = 900+QiYuType.Invite

    self.qiyuTmpList[QiYuType.EscortTran] = {}
    self.qiyuTmpList[QiYuType.EscortTran].btnNormal = "ui_new/qiyu/yabiao/yb_biaoju1.png"
    self.qiyuTmpList[QiYuType.EscortTran].btnSelect = "ui_new/qiyu/yabiao/yb_biaoju.png"
    self.qiyuTmpList[QiYuType.EscortTran].layerName = "lua.logic.qiyu.EscortTranLayer"
    self.qiyuTmpList[QiYuType.EscortTran].funId     = 900+QiYuType.EscortTran

    --护驾
    self.qiyuTmpList[QiYuType.Escorting] = {}
    self.qiyuTmpList[QiYuType.Escorting].btnNormal = "ui_new/qiyu/hj_hujia1.png"
    self.qiyuTmpList[QiYuType.Escorting].btnSelect = "ui_new/qiyu/hj_hujia.png"
    self.qiyuTmpList[QiYuType.Escorting].layerName = "lua.logic.qiyu.EscortingLayer"
    self.qiyuTmpList[QiYuType.Escorting].funId     = 900+4--QiYuType.Escorting

    --签到
    self.qiyuTmpList[QiYuType.NewSign] = {}
    self.qiyuTmpList[QiYuType.NewSign].btnNormal = "ui_new/qiyu/btn_sign.png"
    self.qiyuTmpList[QiYuType.NewSign].btnSelect = "ui_new/qiyu/btn_sign_hl.png"
    self.qiyuTmpList[QiYuType.NewSign].layerName = "lua.logic.qiyu.NewSignLayer"
    self.qiyuTmpList[QiYuType.NewSign].funId     = 900+5--QiYuType.NewSign
    --天猫
    self.qiyuTmpList[QiYuType.Tmall] = {}
    self.qiyuTmpList[QiYuType.Tmall].btnNormal = "ui_new/qiyu/btn_tianmao.png"
    self.qiyuTmpList[QiYuType.Tmall].btnSelect = "ui_new/qiyu/btn_tianmao1.png"
    self.qiyuTmpList[QiYuType.Tmall].layerName = "lua.logic.qiyu.TmallLayer"
    self.qiyuTmpList[QiYuType.Tmall].funId     = 900+6--QiYuType.NewSign
    --天猫
    self.qiyuTmpList[QiYuType.Gamble] = {}
    self.qiyuTmpList[QiYuType.Gamble].btnNormal = "ui_new/qiyu/btn_dushi.png"
    self.qiyuTmpList[QiYuType.Gamble].btnSelect = "ui_new/qiyu/btn_dushi_hl.png"
    self.qiyuTmpList[QiYuType.Gamble].layerName = "lua.logic.qiyu.GambleLayer"
    self.qiyuTmpList[QiYuType.Gamble].funId     = 900+7--QiYuType.NewSign

    -- 检测当前那些活动是开启的
    self.qiyuList = {}
    local num = 1
    for i=1,QiYuType.Max-1 do
        local isOpen = QiyuManager:QiyuFuctionIsOpenByIndex(i)
        if isOpen == true then
            self.qiyuList[num] = {}
            self.qiyuList[num].index = i
            self.qiyuList[num].btnNormal = self.qiyuTmpList[i].btnNormal
            self.qiyuList[num].btnSelect = self.qiyuTmpList[i].btnSelect
            self.qiyuList[num].layerName = self.qiyuTmpList[i].layerName
            self.qiyuList[num].funId     = self.qiyuTmpList[i].funId
            num = num + 1
        end
    end

    self.qiyuTmpList = nil
end

function QiyuHomeLayer:InitQiyuBtn()
    local scrollView = TFDirector:getChildByPath(self.ui, 'scrollView')
    local panel_button = TFDirector:getChildByPath(self.ui, 'panel_button')
    scrollView:setTouchEnabled(true)
    scrollView:setZOrder(11)
    local qiyuNum = #self.qiyuList
    for i=1,qiyuNum do
        local btn = TFButton:create()
        btn:setTextureNormal(self.qiyuList[i].btnNormal)
        btn:setAnchorPoint(ccp(0, 0))
        btn:setPosition(ccp(20+(i-1)*150, 0))
        panel_button:addChild(btn)
        btn:setName("qiyuButton_"..self.qiyuList[i].index)
        btn:addMEListener(TFWIDGET_CLICK, 
        audioClickfun(function() 
            self:OnQiyuBtnClick(btn, i) 
        end))
        self.qiyuList[i].btn = btn;

        -- QiyuManager.initQiyuIndex = QiyuManager.initQiyuIndex or 1
        -- if i == QiyuManager.initQiyuIndex then
        --     self:OnQiyuBtnClick(btn, i)
        -- end 
    end

    local size = scrollView:getInnerContainerSize()
    local width = qiyuNum*150
    local scrollViewContentsize = scrollView:getContentSize().width
    if width < scrollViewContentsize then
        width = scrollViewContentsize
    end
    -- panel_button:setContentSize(CCSizeMake(width, size.height))
    scrollView:setInnerContainerSize(CCSizeMake(width, size.height))
    panel_button:setPosition(ccp(0,0))
end

function QiyuHomeLayer:select(index)
    print("外部调用 = index = ", index)
    local qiyuInex = 0
    local qiyuNum = #self.qiyuList
    for i=1,qiyuNum do
        local qiyuInfo = self.qiyuList[i]

        if qiyuInfo ~= nil and qiyuInfo.index == index then
            qiyuInex = i
        end
    end

    if qiyuInex == 0 then
        qiyuInex = 1
    end

    self:OnQiyuBtnClick(self.qiyuList[qiyuInex].btn, qiyuInex);
    -- QiyuManager.initQiyuIndex = index;
end

function QiyuHomeLayer:OnQiyuBtnClick(btn, index)

    if btn == self.selectBtn then
        return
    end
    
    -- self:redraw()
    print("index = ", index)
    local info = self.qiyuList[index]

    local funId     = info.funId
    local teamLev   = MainPlayer:getLevel()
    local openLevel = FunctionOpenConfigure:getOpenLevel(funId)

    if openLevel > teamLev then
        --toastMessage("团队等级达到"..openLevel.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel,openLevel))
        return
    end

    if self.selectBtn ~= nil and self.selectIndex ~= nil then
        local preInfo = self.qiyuList[self.selectIndex]
        self.selectBtn:setTextureNormal(preInfo.btnNormal)
    end

    btn:setTextureNormal(info.btnSelect)
    self.selectBtn      = btn
    self.selectIndex    = index

    if self.currQiyuLayer ~= nil then
        self.currQiyuLayer:setVisible(false)
    end

    if index == QiYuType.Tmall then
        local hasTouch =  CCUserDefault:sharedUserDefault():getBoolForKey("touch_tmall") or false;
        if hasTouch == false then
            CCUserDefault:sharedUserDefault():setBoolForKey("touch_tmall",true)
            CCUserDefault:sharedUserDefault():flush()
        end
    end
    -- QiyuManager.initQiyuIndex = index

    self.currQiyuLayer = self:GetQiyuLayer(index)
    self.currQiyuLayer:setVisible(true)
    self.currQiyuLayer:onShow()
end

function QiyuHomeLayer:GetQiyuLayer(index)
    local info = self.qiyuList[index]

    if self.qiyuLayer[index] ~= nil then
        return self.qiyuLayer[index]
    else
        local layer = require(info.layerName):new()
        layer:setZOrder(10)
        if layer ~= nil then
            self.qiyuLayer[index] = layer
            self.ui:addChild(layer)
            layer.logic = self
        else
            assert(false)
        end
        return layer
    end
end

function QiyuHomeLayer:redraw()
    -- 
    -- print("QiyuHomeLayer:redraw")
    local qiyuNum = #self.qiyuList
    for i=1,qiyuNum do
        local qiyuInfo = self.qiyuList[i]

        if qiyuInfo ~= nil then
            local index = qiyuInfo.index
            CommonManager:setRedPoint(qiyuInfo.btn, QiyuManager:isHaveRedPointWithIndex(index), "qiuyu"..i, ccp(50, 50))
        end
    end
end



return QiyuHomeLayer