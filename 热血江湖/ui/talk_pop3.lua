-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_talk_pop3 = i3k_class("wnd_talk_pop3", ui.wnd_base)

function wnd_talk_pop3:ctor()
	self._timeTick = 0
	self.nextEntity = nil
	self.nextText = nil
end

function wnd_talk_pop3:configure()
	self.screenSize = cc.Director:getInstance():getWinSize();
	self.frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	self.qipao = self._layout.vars.qipao
	self._layout.vars.lan:hide()
	self._layout.vars.lv:hide()
	self._layout.vars.hong:hide()
	self._timeTick = 0
end

function wnd_talk_pop3:updateTimer(dTime)
	self._timeTick = self._timeTick + dTime
	if self._timeTick>1 and self.nextEntity and self.nextText then
		g_i3k_ui_mgr:PopTextBubble(self._isTrue, self.nextEntity, self.nextText, nil, nil, self._callback)
		self._hasNext = true
		self.nextEntity = nil
		self.nextText = nil
	end
	if self._timeTick>1 and not self._hasNext and self._callback then
		self._callback()
		self._callback = nil
	end
	if self.entity and self.entity._rescfg then
		local mpos = i3k_vec3_clone(self.entity._curPosE);
		mpos.y = mpos.y + self.entity._rescfg.titleOffset;
		local pos = g_i3k_mmengine:GetScreenPos(i3k_vec3_to_engine(mpos))
		if self._pos.x ~= pos.x or self._pos.y ~= pos.y then
			self:setBubblePos(self.qipao, pos)
		end
		if self._timeTick > i3k_db_common.mercenarypop.popalivetime/1000 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timer)
			self._timer = nil
			g_i3k_ui_mgr:CloseUI(eUIID_TalkPop3)
		end
	end
end

function wnd_talk_pop3:onShow()
	local function update(dTime)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_TalkPop3, "updateTimer", dTime)
	end
		
	self._timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0.01, false)
end

function wnd_talk_pop3:refresh()
	
end

function wnd_talk_pop3:treasureDialogue(isTrue, entity, text, nextEntity, nextText, callback)
	self.entity = entity
	self._isTrue = isTrue
	self._callback = callback
	self.nextEntity = nextEntity
	self.nextText = nextText
	self._layout.vars.text:setText(text)
	g_i3k_ui_mgr:AddTask(self, {}, function (self)
		local bubble = self._layout.vars.lan
		local nwidth = self._layout.vars.text:getInnerSize().width + 20
		local nheight = self._layout.vars.text:getInnerSize().height + 20
		local bgwidth = bubble:getSize().width
		local bgheight = bubble:getSize().height
		
		nwidth = nwidth>bgwidth and nwidth or bgwidth
		nheight = nheight>bgheight and nheight or bgheight
		bubble:setContentSize(nwidth, nheight)
		bubble:show()
	end, 1)
	local mpos = i3k_vec3_clone(entity._curPosE)
	if entity._rescfg then
		mpos.y = mpos.y + entity._rescfg.titleOffset
	end
	self._pos = g_i3k_mmengine:GetScreenPos(i3k_vec3_to_engine(mpos))
	self:setBubblePos(self.qipao, self._pos)
end

function wnd_talk_pop3:onUpdate(dTime)
	
end


function wnd_create(layout, ...)
	local wnd = wnd_talk_pop3.new()
	wnd:create(layout, ...)
	return wnd;
end