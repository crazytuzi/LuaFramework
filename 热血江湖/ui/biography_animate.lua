-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_biography_animate = i3k_class("wnd_biography_animate", ui.wnd_base)

function wnd_biography_animate:ctor()
	self._time = 0
	self._delayTime = 1 --延时添加淡入淡出效果，因为ui可能是在进入副本打开的，需要跟其他消耗时间的内容错开
	self._isFadein = false
	self._animateId = 1
end

function wnd_biography_animate:configure()
	--self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_biography_animate:refresh(animateId)
	self._animateId = animateId
	self._layout.vars.blackIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_biography_animate_common.blackIcon))
	self._time = 0
	self._delayTime = 1
	if i3k_db_biography_animate_cfg[self._animateId].bgm ~= 0 then
		i3k_game_play_bgm(i3k_db_sound[i3k_db_biography_animate_cfg[self._animateId].bgm].path, 1)
	end
	self._layout.vars.text:hide()
end

function wnd_biography_animate:onUpdate(dTime)
	if self._delayTime >= 0 then
		self._delayTime = self._delayTime - dTime
	else
		if not self._isFadein then
			self._isFadein = true
			local fadeout = self._layout.vars.text:createFadeOut(i3k_db_biography_animate_common.fadeout)
			local delay = self._layout.vars.text:createDelayTime(i3k_db_biography_animate_common.delay)
			local fadein = self._layout.vars.text:createFadeIn(i3k_db_biography_animate_common.fadein)
			local seq = self._layout.vars.text:createSequence(fadein, delay, fadeout)
			local repeatForever = self._layout.vars.text:createRepeatForever(seq)
			self._layout.vars.text:runAction(repeatForever)
			self._time = 0
			self._layout.vars.text:show()
		end
		self._time = self._time + dTime
		local index = math.ceil(self._time / (i3k_db_biography_animate_common.fadeout + i3k_db_biography_animate_common.fadein + i3k_db_biography_animate_common.delay))
		if i3k_db_biography_animate_cfg[self._animateId].dialogues[index] then
			self._layout.vars.text:setText(i3k_db_biography_animate_cfg[self._animateId].dialogues[index])
		else
			g_i3k_ui_mgr:AddTask(self, {}, function()
				g_i3k_ui_mgr:CloseUI(eUIID_BiographyAnimate)
			end, 1)
		end
	end
end

function wnd_biography_animate:onHide()
	local world = i3k_game_get_world()
	if world then
		world:PlayBGM()
	end
end

function wnd_create(layout)
	local wnd = wnd_biography_animate.new()
	wnd:create(layout)
	return wnd
end