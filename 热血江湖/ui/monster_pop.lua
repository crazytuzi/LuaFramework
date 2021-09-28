-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_monster_pop = i3k_class("wnd_monster_pop", ui.wnd_base)

function wnd_monster_pop:ctor()
	self._uiid = eUIID_MonsterPop
end

function wnd_monster_pop:configure()
	self._fullTime = i3k_db_common.skill.monsterPopTime/1000
	self._timeTick = 0
	self._entity = nil;
	self._isAlterend = false;
	self.bg = self._layout.vars.bgImg
	self.qipao = self._layout.vars.qipao
	self.text = self._layout.vars.text
end

function wnd_monster_pop:onShow()

end

function wnd_monster_pop:refresh(text, entity, isAlterend)
	self._entity = entity
	if isAlterend then
		self._isAlterend = isAlterend
	end
	self.text:setText(text)
	g_i3k_ui_mgr:AddTask(self, {}, function (self)
		if not self.bg then
			self.bg = self._layout.vars.bgImg
		end
		local nwidth = self._layout.vars.text:getInnerSize().width + 20
		local nheight = self._layout.vars.text:getInnerSize().height + 20
		local bgwidth = self.bg:getSize().width
		local bgheight = self.bg:getSize().height

		nwidth = nwidth>bgwidth and nwidth or bgwidth
		nheight = nheight>bgheight and nheight or bgheight
		self.bg:setContentSize(nwidth, nheight)
		self.bg:setVisible(true)
	end, 1)
	local mpos = i3k_vec3_clone(self._entity._curPosE);
	mpos.y = mpos.y + self._entity._rescfg.titleOffset;
	self._pos = g_i3k_mmengine:GetScreenPos(i3k_vec3_to_engine(mpos))
	self:setBubblePos(self.qipao, self._pos)
end

function wnd_monster_pop:onUpdate(dTime)
	if self._entity then
		local mpos = i3k_vec3_clone(self._entity._curPosE);
		mpos.y = mpos.y + self._entity._rescfg.titleOffset;
		local pos = g_i3k_mmengine:GetScreenPos(i3k_vec3_to_engine(mpos))
		if self._pos.x ~= pos.x or self._pos.y ~= pos.y then
			self:setBubblePos(self.qipao, pos)
		end
	end

	if self._timeTick and not self._isAlterend then
		self._timeTick = self._timeTick + dTime
		if self._timeTick > self._fullTime then
			if self._entity then
				self._entity._isPop = false
			end
			g_i3k_ui_mgr:CloseUI(self._uiid)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_monster_pop.new()
	wnd:create(layout, ...)
	return wnd;
end
