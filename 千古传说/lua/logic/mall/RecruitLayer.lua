--[[
******购物中心图层*******

	-- by david.dai
	-- 2014/6/11
]]

local RecruitLayer = class("RecruitLayer", BaseLayer)

function RecruitLayer:ctor(defaultIndex)
    self.super.ctor(self,defaultIndex)
    self:init("lua.uiconfig_mango_new.shop.Recruit")
end

function RecruitLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Recruit,{HeadResType.COIN,HeadResType.SYCEE})

    self.panel_list    = TFDirector:getChildByPath(ui, 'panel_list')
    self.btn_guiyin    = TFDirector:getChildByPath(ui, 'btn_guiyin')
    self.btn_guiyin.logic = self
    self.btn_qiyuan    = TFDirector:getChildByPath(ui, 'btn_qiyuan')
    self.img_tishi     = TFDirector:getChildByPath(self.btn_qiyuan, 'img_tishi')
    self.img_tishi:setVisible(false)
    self.QiYuanPos     = self.btn_qiyuan:getPosition()

    self.btn_zhuanhuan = TFDirector:getChildByPath(ui, "btn_zhuanhuan")
    self.btn_zhuanhuan.logic = self

    self:selectRecruit()
end

function RecruitLayer:removeUI()
    self.super.removeUI(self)
    self.panel_list         = nil
    self.btn_guiyin         = nil
end

function RecruitLayer:registerEvents()
    self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
    self.btn_guiyin:addMEListener(TFWIDGET_CLICK, audioClickfun(self.guiYinClickHandle))
    self.btn_qiyuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.qiYuanClick))
    self.btn_zhuanhuan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.zhuanhuanClick))
end

function RecruitLayer:removeEvents()
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.super.removeEvents(self)
end

function RecruitLayer.qiYuanClick(sender)
    QiYuanManager:OpenQiYuanLayer()
end

function RecruitLayer.guiYinClickHandle(sender)
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2201)
    if teamLev < openLev then
        --toastMessage("团队等级达到"..openLev.."级开启")
        toastMessage(stringUtils.format(localizable.common_function_openlevel,openLev))
    else
        local layer =  AlertManager:addLayerByFile("lua.logic.hermit.HermitLayer");
        AlertManager:show();
    end
end

function RecruitLayer.zhuanhuanClick(sender)
    local layer =  AlertManager:addLayerByFile("lua.logic.mall.XiaKeZhuanHuanLayer");
    AlertManager:show();
end

function RecruitLayer:selectRecruit()
    --创建显示内容图层
    GetCardManager:SendQueryStateMsg()
    self.recruitPage = require("lua.logic.shop.GetRoleLayer"):new()

    local frameSize = GameConfig.WS
    self.recruitPage:setPositionX((frameSize.width - self.recruitPage:getSize().width) / 2)
    self.panel_list:addChild(self.recruitPage, 10)

end

-----断线重连支持方法
function RecruitLayer:onShow()
    self.super.onShow(self)
    if self.recruitPage then
        self.recruitPage:onShow()
    end
    self.generalHead:onShow();
    --[[local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2201)
    if teamLev < openLev then
        self.btn_guiyin:setVisible(false)
        self.btn_qiyuan:setPosition(self.btn_guiyin:getPosition())
    else
        self.btn_guiyin:setVisible(true)
        self.btn_qiyuan:setPosition(self.QiYuanPos)
    end
    if QiYuanManager:isUnLockQiYuan() then
        self.img_tishi:setVisible(false)
    else
        self.img_tishi:setVisible(true)
    end]]
    CommonManager:setRedPoint(self.btn_qiyuan, QiYuanManager:isHaveQiYuanFree(),"isHaveQiYuanFree",ccp(0,0))
end

function RecruitLayer:dispose()
    if self.recruitPage then
        self.recruitPage:dispose()
        self.recruitPage = nil
    end

    if generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

return RecruitLayer