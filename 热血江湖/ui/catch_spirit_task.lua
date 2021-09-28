-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_catch_spirit_task = i3k_class("wnd_catch_spirit_task", ui.wnd_base)

function wnd_catch_spirit_task:ctor()
	self._isOpen = true
	self._countdown = 1
end

function wnd_catch_spirit_task:configure()
	self._layout.vars.openBtn:onClick(self, self.onOpenTask)
	self._layout.vars.closeBtn:onClick(self, self.onCloseTask)
end

function wnd_catch_spirit_task:refresh()
	self._layout.vars.taskRoot:show()
	self._layout.vars.closeBtn:show()
	self._layout.vars.openBtn:hide()
	self:updateCatchCount()
end

function wnd_catch_spirit_task:updateCatchCount()
	local info = g_i3k_game_context:getGhostSkillInfo()
	if info.daySummonedTimes then
		if info.daySummonedTimes >= i3k_db_catch_spirit_base.dungeon.callTimes then
			local str = "<c=hlred>"..info.daySummonedTimes.."/"..i3k_db_catch_spirit_base.dungeon.callTimes.."</c>"
			self._layout.vars.desc1:setText(i3k_get_string(18639, str))
		else
			local str = "<c=hlgreen>"..info.daySummonedTimes.."/"..i3k_db_catch_spirit_base.dungeon.callTimes.."</c>"
			self._layout.vars.desc1:setText(i3k_get_string(18639, str))
		end
		local count = 0
		if info.spirits then
			for k, v in pairs(info.spirits) do
				count = count + v
			end
		end
		self._layout.vars.desc2:show()
		if count >= i3k_db_catch_spirit_base.spiritFragment.bagMaxCount then
			local str = "<c=hlred>"..count.."/"..i3k_db_catch_spirit_base.spiritFragment.bagMaxCount.."</c>"
			self._layout.vars.desc2:setText(i3k_get_string(18626, str))
		else
			local str = "<c=hlgreen>"..count.."/"..i3k_db_catch_spirit_base.spiritFragment.bagMaxCount.."</c>"
			self._layout.vars.desc2:setText(i3k_get_string(18626, str))
		end
		local boss = g_i3k_game_context:getCatchSpiritBoss()
		self._layout.vars.desc3:show()
		if boss and next(boss) then
			self._layout.vars.desc3:setText(i3k_get_string(18624, i3k_get_string(18645)))
		else
			self._layout.vars.desc3:setText(i3k_get_string(18624, i3k_get_string(18646)))
		end
	end
end

function wnd_catch_spirit_task:onOpenTask(sender)
	if not self._isOpen then
		self._layout.vars.taskRoot:show()
		self._layout.vars.closeBtn:show()
		self._layout.vars.openBtn:hide()
		self._isOpen = true
	end
end

function wnd_catch_spirit_task:onCloseTask(sender)
	if self._isOpen then
		self._layout.vars.taskRoot:hide()
		self._layout.vars.closeBtn:hide()
		self._layout.vars.openBtn:show()
		self._isOpen = false
	end
end

function wnd_catch_spirit_task:onUpdate(dTime)
	self._countdown = self._countdown + dTime
	if self._countdown > 1 then
		local leftTime = i3k_get_catch_spirit_countdown()
		self._layout.vars.countdown:setText(i3k_get_string(18623, math.floor(leftTime/3600)..":"..math.floor(leftTime%3600/60)..":"..math.floor(leftTime%60)))
	end
end

function wnd_create(layout)
	local wnd = wnd_catch_spirit_task.new()
	wnd:create(layout)
	return wnd
end