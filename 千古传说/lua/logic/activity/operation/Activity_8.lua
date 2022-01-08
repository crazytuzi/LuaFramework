
local Activity_8 = class("Activity_8", BaseLayer)

function Activity_8:ctor(data)
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.operatingactivities.008")
end

function Activity_8:initUI(ui)
    self.super.initUI(self,ui)
end

function Activity_8:setLogic(logic)
    self.logic = logic
end

function Activity_8:registerEvents()
    self.super.registerEvents(self)
end

function Activity_8:removeEvents()
    self.super.removeEvents(self)
end

return Activity_8