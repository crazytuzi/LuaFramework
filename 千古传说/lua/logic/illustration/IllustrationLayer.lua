--[[
******图鉴层*******

]]

local IllustrationLayer = class("IllustrationLayer", BaseLayer)

function IllustrationLayer:ctor(defaultIndex)
    self.super.ctor(self)
    self.defaultIndex = defaultIndex
   
    if self.defaultIndex == nil then
        self.defaultIndex = 0
        print("self.defaultIndex is nil")
    end 

    self:init("lua.uiconfig_mango_new.handbook.HandbookMainLayer")
end

function IllustrationLayer:initUI(ui)
    self.super.initUI(self,ui)
    
    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.HandBook,{HeadResType.COIN,HeadResType.SYCEE})


    self.ui             = TFDirector:getChildByPath(ui, 'panel_content')
    self.btn_role       = TFDirector:getChildByPath(ui, 'btn_role')
    self.btn_equipment  = TFDirector:getChildByPath(ui, 'btn_equipment')
    self.btn_tianshu  = TFDirector:getChildByPath(ui, 'btn_tianshu')

    self.btn_role.btnIndex      = 0
    self.btn_role.logic         = self
    self.btn_equipment.btnIndex = 1
    self.btn_equipment.logic    = self
    self.btn_tianshu.btnIndex = 2
    self.btn_tianshu.logic    = self
    -- self:chooseRole()
    self:drawDefault()
end

function IllustrationLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
end

function IllustrationLayer:removeUI()
    self.super.removeUI(self)
end

function IllustrationLayer:dispose()
    if self.RolePage then
        self.RolePage:dispose()
        self.RolePage = nil
    end

    if self.EquipPage then
        self.EquipPage:dispose()
        self.EquipPage = nil
    end
    if self.SkyBookPage then
        self.SkyBookPage:dispose()
        self.SkyBookPage = nil
    end

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function IllustrationLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_role:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle));
    self.btn_equipment:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle));
    self.btn_tianshu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle));

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function IllustrationLayer:removeEvents()
    --按钮事件

    print("IllustrationLayer:removeEvents")
    self.super.removeEvents(self)
    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

function IllustrationLayer:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function IllustrationLayer:showCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:show()
    end
end


function IllustrationLayer:chooseRoleList()

    self:hideCurrentLayer()

    self.btn_role:setTextureNormal("ui_new/handbook/tj_xiake1.png")
    self.btn_equipment:setTextureNormal("ui_new/handbook/tj_zhuangbei11.png")
    self.btn_tianshu:setTextureNormal("ui_new/handbook/tj_tianshu11.png")
    
    --创建显示内容图层
    if self.RolePage == nil then
        self.RolePage = require("lua.logic.illustration.IllustrationRoleLayer"):new()
        self.ui:addChild(self.RolePage, 1)
    end
    
    self.currentLayer = self.RolePage
    self:showCurrentLayer()
end

function IllustrationLayer:chooseEquipList()
    self:hideCurrentLayer()

    self.btn_role:setTextureNormal("ui_new/handbook/tj_xiake11.png")
    self.btn_equipment:setTextureNormal("ui_new/handbook/tj_zhuangbei1.png")
    self.btn_tianshu:setTextureNormal("ui_new/handbook/tj_tianshu11.png")
    
    --创建显示内容图层
    if self.EquipPage == nil then
        self.EquipPage = require("lua.logic.illustration.IllustrationEquipLayer"):new()
        self.ui:addChild(self.EquipPage, 1)
    end
    
    self.currentLayer = self.EquipPage
    self:showCurrentLayer()
end
function IllustrationLayer:chooseSkyBookList()
    self:hideCurrentLayer()

    self.btn_role:setTextureNormal("ui_new/handbook/tj_xiake11.png")
    self.btn_equipment:setTextureNormal("ui_new/handbook/tj_zhuangbei11.png")
    self.btn_tianshu:setTextureNormal("ui_new/handbook/tj_tianshu1.png")
    
    --创建显示内容图层
    if self.SkyBookPage == nil then
        self.SkyBookPage = require("lua.logic.illustration.IllustrationSkyBookLayer"):new()
        self.ui:addChild(self.SkyBookPage, 1)
    end
    
    self.currentLayer = self.SkyBookPage
    self:showCurrentLayer()
end

function IllustrationLayer:drawDefault()
    print("IllustrationLayer:drawDefault = ", self.defaultIndex)
    if self.defaultIndex == 0 then
        self:chooseRoleList()
    elseif self.defaultIndex == 1 then
        self:chooseEquipList()
    elseif self.defaultIndex == 2 then
        self:chooseSkyBookList()
    end
end

function IllustrationLayer.BtnClickHandle(sender)
    local self  = sender.logic
    local index = sender.btnIndex

    if self.defaultIndex == index then
        return
    else
        self.defaultIndex = index
        self:drawDefault()
    end
end

return IllustrationLayer