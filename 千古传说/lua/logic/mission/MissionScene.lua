--[[
******PVE推图-主场景*******

    -- by haidong.gan
    -- 2013/11/27
]]
local MissionScene = class("MissionScene", BaseScene)
function MissionScene:ctor(...)
	self.super.ctor(self,...)
	local logic = require("lua.logic.mission.MissionLayer")
    self:addLayer(logic:new())
end

return MissionScene