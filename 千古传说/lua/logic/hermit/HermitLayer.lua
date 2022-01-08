--[[
******归隐*******

]]

local HermitLayer = class("HermitLayer", BaseLayer)

function HermitLayer:ctor(defaultIndex)
    self.super.ctor(self,defaultIndex)
    self:init("lua.uiconfig_mango_new.shop.RoleHermit")
end

function HermitLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Hermit,{HeadResType.XIAYI,HeadResType.COIN,HeadResType.SYCEE})

    self.btn_fire        = TFDirector:getChildByPath(ui, 'btn_fire')
    self.btn_rebirth    = TFDirector:getChildByPath(ui, 'btn_rebirth')
    self.btn_shop          = TFDirector:getChildByPath(ui, 'btn_shop')

    self.btn_fire.logic = self
    self.btn_rebirth.logic = self
    self.btn_shop.logic = self
   
    self.panel_layer    = TFDirector:getChildByPath(ui, 'panel_layer')


    self:choiceDefault()
end

function HermitLayer:removeUI()
    self.super.removeUI(self)
end

function HermitLayer:registerEvents()
    self.super.registerEvents(self)
    self.btn_fire:addMEListener(TFWIDGET_CLICK, audioClickfun(self.roleFireButtonClickHandle))
    self.btn_rebirth:addMEListener(TFWIDGET_CLICK, audioClickfun(self.roleBirthButtonClickHandle))
    self.btn_shop:addMEListener(TFWIDGET_CLICK, audioClickfun(self.shopButtonClickHandle))

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function HermitLayer:removeEvents()
    print("HermitLayer:removeEvents() ........")
    --按钮事件
    self.btn_fire:removeMEListener(TFWIDGET_CLICK)
    self.btn_rebirth:removeMEListener(TFWIDGET_CLICK)
    self.btn_shop:removeMEListener(TFWIDGET_CLICK)

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.super.removeEvents(self)
end


function HermitLayer:choiceDefault()
    if self.selectedButton ~= nil then
        return
    end

    if self.defaultIndex then
        if self.defaultIndex == 2 then
            self:selectRoleRebirth()
        --elseif self.defaultIndex == 3 then
        --    self:selectMall()
        else
            self:selectRoleFire()
        end
    else
        self:selectRoleFire()
    end
end

function HermitLayer:select(index)
    if index then
        if index == 2 then
            self:selectRoleRebirth()
        --elseif index == 3 then
        --    self:selectMall()
        else
            self:selectRoleFire()
        end
    else
        self:selectRoleFire()
    end
end

function HermitLayer:handleClose()
    AlertManager:close(AlertManager.TWEEN_1);
end

function HermitLayer:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function HermitLayer:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:onclear()
        self.currentLayer:onShow()
    end
end

function HermitLayer:selectRoleFire()
    self.selectedButton = self.btn_fire
    self:hideCurrentLayer()

    self.btn_fire:setTextureNormal("ui_new/common/tab_guiyin1.png")
    self.btn_rebirth:setTextureNormal("ui_new/common/tab_chongsheng2.png")
    self.btn_shop:setTextureNormal("ui_new/common/tab_shangcheng2.png")

    --创建显示内容图层
    if self.roleFirePage == nil then
        self.roleFirePage = require('lua.logic.hermit.RoleFireLayer'):new()
        self.panel_layer:addChild(self.roleFirePage)
    end

    self.currentLayer = self.roleFirePage
    self:showCurrentLayer()
end

function HermitLayer:selectMall()
    MallManager:openCardRoleMallLayer()
	--[[self.selectedButton = self.btn_gifts
    self:hideCurrentLayer()

    self.btn_fire:setTextureNormal("ui_new/common/tab_guiyin2.png")
    self.btn_rebirth:setTextureNormal("ui_new/common/tab_chongsheng2.png")
    self.btn_shop:setTextureNormal("ui_new/common/tab_shangcheng1.png")

    --创建显示内容图层
    if self.mallPage == nil then
        self.mallPage = require('lua.logic.hermit.RoleShopPage'):new()
        self.panel_layer:addChild(self.mallPage)
    end
    self.currentLayer = self.mallPage
    self:showCurrentLayer()]]
end


function HermitLayer:selectRoleRebirth()
    self.selectedButton = self.btn_xiyou
    self:hideCurrentLayer()

    self.btn_fire:setTextureNormal("ui_new/common/tab_guiyin2.png")
    self.btn_rebirth:setTextureNormal("ui_new/common/tab_chongsheng1.png")
    self.btn_shop:setTextureNormal("ui_new/common/tab_shangcheng2.png")

    --创建显示内容图层
    if self.rebirthPage == nil then
        self.rebirthPage = require('lua.logic.hermit.RoleReBirthLayer'):new()
        self.panel_layer:addChild(self.rebirthPage)
    end

    self.currentLayer = self.rebirthPage
    self:showCurrentLayer()
end




function HermitLayer.roleFireButtonClickHandle(sender)
    local self = sender.logic
    PlayerGuideManager:showNextGuideStep()
    if self.selectedButton == self.btn_fire then
        return
    end
    self:selectRoleFire()
end

function HermitLayer.roleBirthButtonClickHandle(sender)
    local self = sender.logic
    if self.selectedButton == self.btn_rebirth then
        return
    end
    self:selectRoleRebirth()
end

function HermitLayer.shopButtonClickHandle(sender)
    local self = sender.logic
    --if self.selectedButton == self.btn_shop then
    --    return
    --end
    self:selectMall()

end


-----断线重连支持方法
function HermitLayer:onShow()
    self.super.onShow(self)
    if self.currentLayer then
        self.currentLayer:onShow()
    end
    self.generalHead:onShow();
end

function HermitLayer:dispose()
    if self.mallPage then
        self.mallPage:dispose()
        self.mallPage = nil
    end

    if self.roleFirePage then
        self.roleFirePage:dispose()
        self.roleFirePage = nil
    end

    if self.rebirthPage then
        self.rebirthPage:dispose()
        self.rebirthPage = nil
    end


    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

return HermitLayer