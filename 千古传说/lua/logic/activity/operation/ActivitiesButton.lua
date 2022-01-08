
local ActivitiesButton = class("ActivitiesButton", BaseLayer)

function ActivitiesButton:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.list")
end

function ActivitiesButton:initUI(ui)
	self.super.initUI(self,ui)

	self.img_selected                        = TFDirector:getChildByPath(ui, 'img_selected')
	self.img_content 	                     = TFDirector:getChildByPath(ui, 'img_content')
    self.img_zhezhao                         = TFDirector:getChildByPath(ui, 'img_zhezhao')

    self:setSelected(false)
end

function ActivitiesButton:setLogic(logic)
    self.logic = logic
end

function ActivitiesButton:registerEvents()
    self.super.registerEvents(self)
end

function ActivitiesButton:removeEvents()
    self.super.removeEvents(self)
end

function ActivitiesButton:setSelected(selected)
    self.img_selected:setVisible(selected)
    self.img_zhezhao:setVisible(not selected)
end

function ActivitiesButton:setType(type)
    local texturePath = 'ui_new/operatingactivities/yy_00' .. type ..'1.png'
    self.img_content:setTexture(texturePath)
    -- if self.logic.selectedIndex == type then
    if self.logic.selectedtype == type then
        self:setSelected(true)
    else
        self:setSelected(false)
    end
end

function ActivitiesButton:setPath(path, type)
    self.img_content:setTexture(path)
    -- if self.logic.selectedIndex == type then
    if self.logic.selectedtype == type then
        self:setSelected(true)
    else
        self:setSelected(false)
    end
end

return ActivitiesButton