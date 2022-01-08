
local Activity_7 = class("Activity_7", BaseLayer)

function Activity_7:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.009")
end

function Activity_7:initUI(ui)
    self.super.initUI(self,ui)
end

function Activity_7:setLogic(logic)
    self.logic = logic
end

function Activity_7:registerEvents()
    self.super.registerEvents(self)
end

function Activity_7:removeEvents()
    self.super.removeEvents(self)
end

return Activity_7