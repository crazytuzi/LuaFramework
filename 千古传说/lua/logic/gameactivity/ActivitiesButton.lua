
local ActivitiesButton = class("ActivitiesButton", BaseLayer)

function ActivitiesButton:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.listNew")
end

function ActivitiesButton:initUI(ui)
	self.super.initUI(self,ui)

	self.img_selected = TFDirector:getChildByPath(ui, 'bg2')
    self.img_zhezhao = TFDirector:getChildByPath(ui, 'bg1')
    self.text1 = TFDirector:getChildByPath(self.img_selected, 'txt_title')
    self.text2 = TFDirector:getChildByPath(self.img_zhezhao, 'txt_title')
    self.img_kf1 = TFDirector:getChildByPath(self.img_selected, 'img_kf')
    self.img_kf2 = TFDirector:getChildByPath(self.img_zhezhao, 'img_kf')
    self.img_tail = TFDirector:getChildByPath(ui, 'Image_listNew_2')
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
function ActivitiesButton:setMultiServer(multiServer)
    if multiServer == nil then
        multiServer = false
    end
    self.img_kf1:setVisible(multiServer)
    self.img_kf2:setVisible(multiServer)
end

function ActivitiesButton:setTitle(title, type)
    if self.text1 then
        self.text1:setText(title)
    end

    if self.text2 then
        self.text2:setText(title)
    end

    if self.logic.selectedtype == type then
        self:setSelected(true)
    else
        self:setSelected(false)
    end
end

function ActivitiesButton:setTailVisible(visible)
    self.img_tail:setVisible(visible)
end

return ActivitiesButton