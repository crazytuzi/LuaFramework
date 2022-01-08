--[[
******佣兵baselayer*******

]]

local EmployBaseLayer = class("EmployBaseLayer", BaseLayer)

function EmployBaseLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.yongbing.YongbingBaseLayer")
end

function EmployBaseLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.generalHead = CommonManager:addGeneralHead( self ,10)

    self.generalHead:setData(ModuleType.Employ,{HeadResType.COIN,HeadResType.SYCEE})

    self.tab = {}
    self.normalTextures = {}
    self.selectedTextures = {}
    for i=1,4 do
        self.tab[i] = TFDirector:getChildByPath(ui, 'btn_'..i)
        self.tab[i].logic = self
        self.normalTextures[i] = "ui_new/yongbing/tab_"..i..".png"
        self.selectedTextures[i] = "ui_new/yongbing/tab_"..i.."h.png"

    end

    self.panel_content= TFDirector:getChildByPath(ui, 'panel_content')

    self.layerPath = {'lua.logic.employ.EmployRoleLayer','lua.logic.employ.EmployTeamLayer','lua.logic.employ.ShowEmployRoleLayer','lua.logic.employ.ShowEmployTeamLayer'}
    self.detailsLayer = {}

   
end

function EmployBaseLayer:removeUI()
    self.super.removeUI(self)
    -- self.generalHead:dispose()
end

function EmployBaseLayer:allBtnToNormal()
    for i = 1,#self.tab do
        self.tab[i]:setTextureNormal(self.normalTextures[i])
    end
end

function EmployBaseLayer:selectTabDefault(index)
    if self.selectedIndex then
        return
    end
    self.selectedIndex = 0
    self:updateDetails(index)
    -- self:allBtnToNormal()
    -- self.tab[index]:setTextureNormal(self.selectedTextures[index])
    -- self.selectedIndex = index
end

function EmployBaseLayer.tabButtonClick(sender)
    local self = sender.logic

    local index = sender:getTag()
    self:updateDetails(index)
end

function EmployBaseLayer:updateDetails(index)
    if self.selectedIndex == index then
        return
    end

    if index == 1 then
        EmployManager:getMyEmployInfo()
    elseif index == 2 then
        EmployManager:queryMyMercenaryTeam()
    elseif index == 3 then
        EmployManager:requestAllEmployInfo()
    elseif index == 4 then
        EmployManager:requestMercenaryTeamListOutline()
    end

    self:allBtnToNormal()
    self.tab[index]:setTextureNormal(self.selectedTextures[index])
    self:showDetailsLayer(index)
    self.selectedIndex = index
end

function EmployBaseLayer:showDetailsLayer(index)
    local key = index --tostring(index)
    local layer = self.detailsLayer[key]
    if not layer then
        layer = require(self.layerPath[index]):new()
        -- layer:setHomeLayer(self)
        self.panel_content:addChild(layer)
        self.detailsLayer[key] = layer
    end
    self:showCurrentLayer(layer)
end

function EmployBaseLayer:registerEvents()
    self.super.registerEvents(self)

    for i=1,#self.tab do
        self.tab[i]:setTag(i)
        self.tab[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.tabButtonClick))
    end

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    if self.detailsLayer then
        for k,v in pairs(self.detailsLayer) do
            v:registerEvents()
        end
    end
end

function EmployBaseLayer:removeEvents()
     for i=1,#self.tab do
        self.tab[i]:removeMEListener(TFWIDGET_CLICK)
    end

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    if self.detailsLayer then
        for k,v in pairs(self.detailsLayer) do
            v:removeEvents()
        end
    end
    self.super.removeEvents(self)
end

function EmployBaseLayer:dispose()

    if self.detailsLayer then
        for k,v in pairs(self.detailsLayer) do
            v:dispose()
        end
        self.detailsLayer = nil
    end

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end


function EmployBaseLayer:hideCurrentLayer()
    if self.currentLayer then
        self.currentLayer:setVisible(false)
    end
end

function EmployBaseLayer:showCurrentLayer(layer)
    self:hideCurrentLayer()
    self.currentLayer = layer
    if self.currentLayer then
        self.currentLayer:setVisible(true)
        self.currentLayer:refreshUI()
    end
end

-----断线重连支持方法
function EmployBaseLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshUI()

end

function EmployBaseLayer:refreshUI()
     self:selectTabDefault(1)
    if self.currentLayer then
        self.currentLayer:refreshUI()
    end
end

return EmployBaseLayer
