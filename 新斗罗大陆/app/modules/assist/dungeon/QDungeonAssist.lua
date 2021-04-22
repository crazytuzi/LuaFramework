local QBaseAssist = import("..QBaseAssist")
local QDungeonAssist = class("QDungeonAssist", QBaseAssist)

function QDungeonAssist:ctor(options)
	QDungeonAssist.super.ctor(self, options)
end

function QDungeonAssist:run(callback)
	QDungeonAssist.super.run(self, callback)
	self:logger("开启普通副本辅助")
	if self:checkEnergy() then

	else
		self:logger("体力不足，退出普通副本")
	end
end

function QDungeonAssist:checkEnergy()
	return remote.user.energy >= 6
end

-- function QDungeonAssist:( ... )
-- 	-- body
-- end

return QDungeonAssist