----------------------------------------------------------------
module(..., package.seeall)

local require = require;

require("i3k_global");

------------------------------------------------------
i3k_timer = i3k_class("i3k_timer");
function i3k_timer:ctor(tickLine, autoRelease)
	self._tickTime	= 0;
	self._tickLine	= tickLine;
	self._pause		= false;
	self._autoRelease
					= autoRelease or false;
end

function i3k_timer:IsAutoRelease()
	return self._autoRelease;
end

function i3k_timer:OnLogic(dTick)
	if not self._pause then
		local logic = i3k_game_get_logic();
		if logic then
			self._tickTime = self._tickTime + dTick * i3k_engine_get_tick_step();
			if self._tickTime >= self._tickLine then
				self._tickTime = 0;

				return self:Do();
			end
		end
	end

	return false;
end

function i3k_timer:Pause()
	if not self._pause then
		self._pause = true;
		self:OnPause();
	end
end

function i3k_timer:OnPause()
end

function i3k_timer:Resume()
	if self._pause then
		self._pause = false;
		self:OnResume();
	end
end

function i3k_timer:OnResume()
end

function i3k_timer:Do(args)
end

