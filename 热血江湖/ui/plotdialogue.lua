-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_plotDialogue = i3k_class("wnd_plotDialogue", ui.wnd_base)

function wnd_plotDialogue:ctor()
	self._dialogueList = {}
	self._timeTick = 0
	self._flag = false
end

function wnd_plotDialogue:configure()
	local widget = self._layout.vars	
	widget.closeBtn:onClick(self, self.onCloseBt)
	self._anis = self._layout.anis.c_dakai
end

function wnd_plotDialogue:refresh(list)
	self._dialogueList = clone(list)
	self:InitHeadIcon()
	self:refreshDialogue()
end

function wnd_plotDialogue:InitHeadIcon()
	local widget = self._layout.vars
	local iconTable = 
	{
		[g_PRINCESS_MARRY] = i3k_db_princess_marry.princessHeadId
	}
	
	local mapType = i3k_game_get_map_type()
	
	if not mapType or not iconTable[mapType] then
		local _, headIcon = g_i3k_game_context:GetRoleNameHeadIcon()
		widget.plotheadicon2:setImage(g_i3k_db.i3k_db_get_head_icon_path(headIcon))
	else
		widget.plotheadicon2:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconTable[mapType], true))
	end	
end

function wnd_plotDialogue:refreshDialogue()
	if self._flag then return end
	
	if #self._dialogueList == 0 then
		self._flag = true
		g_i3k_ui_mgr:AddTask(self, {}, function(ui) self:onCloseUI() end, 1)
		return
	end
	local widget = self._layout.vars
	local id = table.remove(self._dialogueList, 1)	
	widget.plottext:setText(i3k_get_string(id))
	self._anis.stop()
	self._anis.play()
end

function wnd_plotDialogue:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	
	if self._timeTick >= i3k_db_princess_marry.dialogueCloseTime then
		self._timeTick = 0
		self:refreshDialogue()
	end
end

function wnd_plotDialogue:onCloseBt()
	self:refreshDialogue()
	self._timeTick = 0
end

function wnd_create(layout, ...)
	local wnd = wnd_plotDialogue.new()
	wnd:create(layout, ...)
	return wnd;
end