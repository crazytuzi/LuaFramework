module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_petDungeonReadingbar = i3k_class("wnd_petDungeonReadingbar", ui.wnd_base)

function wnd_petDungeonReadingbar:ctor()
	self._cfg = nil
	self._info = nil
	self._flag = true
	self._actionTime = 0
	self._mineactiontime = 0
end

function wnd_petDungeonReadingbar:configure()
	local weight = self._layout.vars
	self._loadingbar = weight.Digloadingbar
	weight.Digcancel:onClick(self, self.onCancelClick)
end

function wnd_petDungeonReadingbar:refresh(cfg, info)
	self._cfg = i3k_db_resourcepoint[cfg.mineId]
	self._info = info
	self:onUseItemAtPosition()
	local value = g_i3k_game_context:getPetDungeonBuffs(g_ADDSPEED) > 0
	local reduce = 1 - i3k_db_PetDungeonEvents[g_ADDSPEED].effectArg / 20000 
	reduce = reduce <= 0 and 0.1 or reduce
	local time = self._cfg.ActionTime * reduce
	self._actionTime = value and time or self._cfg.ActionTime
end

function wnd_petDungeonReadingbar:onUpdate(dTime)
	if self._flag then
		self:onUpdateMine(dTime)
	end
end

function wnd_petDungeonReadingbar:onUseItemAtPosition()
	g_i3k_game_context:StopMove()
	local weight = self._layout.vars	
	weight.DigingPanel:show()
	weight.Digtipstext:setText(self._cfg.ShowTips)
		
	if self._cfg.heartWordID then
		local heartWord = i3k_db_dialogue[self._cfg.heartWordID][1].txt
		
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			if g_i3k_game_context:IsMineBubbleCanShow() then
				g_i3k_game_context:RecordMineBubbleLastTime()
				g_i3k_ui_mgr:PopTextBubble(true, i3k_game_get_player_hero(), heartWord)
			end
		end, i3k_db_common.mineBubbleDelay * 100)
	end
end

function wnd_petDungeonReadingbar:onUpdateMine(dTime)	
	if g_i3k_game_context:IsHeroMove() then
		self._mineactiontime = 0
		self:onCloseUI()
		return true;
	end
	
	self._mineactiontime = self._mineactiontime + dTime * 1000
		
	if self._mineactiontime < self._actionTime then
		self._loadingbar:setPercent((self._mineactiontime / self._actionTime) * 100)
	else
		self._flag = false
		self._loadingbar:setPercent(100)
		i3k_sbean.pettrain_mineral_gather(self._info)
		self:onCloseUI()
	end
end

function wnd_petDungeonReadingbar:onCancelClick(sender)	
	g_i3k_ui_mgr:CloseUI(eUIID_PetDungeonReadingbar)
end

function wnd_create(layout)
	local wnd = wnd_petDungeonReadingbar.new();
	wnd:create(layout);
	return wnd;
end
