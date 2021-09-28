module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_transportProcessBar = i3k_class("wnd_transportProcessBar", ui.wnd_base)
function wnd_transportProcessBar:ctor()
	self.args = 0
	self.flag = 0
	self.cancel = nil
end
function wnd_transportProcessBar:configure()
	local dig = {}
	dig.Digingpanel = self._layout.vars.DigingPanel
	dig.Digtipstext = self._layout.vars.Digtipstext
    self._widgets = {}
	self._widgets.dig = dig
	self._mineactiontime = 0
	self._layout.vars.Digcancel:onClick(self, self.onCancelClick)
end

function wnd_transportProcessBar:refresh(flag,args,cancel)
	g_i3k_game_context:SetAutoFight(false)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:ClearFindwayStatus(true)
	end
	if flag and args then
		self.flag = flag
		self.args = args
	end
	self.cancel = cancel
	self:onShowTransUI(cancel)
end

function wnd_transportProcessBar:onUpdate(dTime)
	self:onUpdateTrans(dTime)
end

function wnd_transportProcessBar:onShowTransUI(cancel)
	g_i3k_game_context:StopMove()
	if cancel == false then
		self._layout.vars.Digcancel:hide()
	end
	self._widgets.dig.Digingpanel:show()
	self._widgets.dig.Digtipstext:setText("传送中... ...")
end

function wnd_transportProcessBar:onUpdateTrans(dTime)
	if self.flag == 3 then
		local loadingbar = self._layout.vars.Digloadingbar
		self._mineactiontime = self._mineactiontime + dTime*50;
		loadingbar:setPercent(self._mineactiontime)
		local percent = loadingbar:getPercent()
		if percent == 100 then
			self.flag = 0
			self._mineactiontime = 0
			loadingbar:setPercent(0)
			local mapId = self.args.mapId
			local areaId = self.args.areaId
			local flage = self.args.flage

			g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
			g_i3k_coroutine_mgr:StartCoroutine(function ()
				g_i3k_coroutine_mgr.WaitForNextFrame()
				g_i3k_game_context:TransportCallBack(mapId,areaId,flage)
			end)
		end
	end
end


function wnd_transportProcessBar:onCancelClick(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_transportProcessBar)
end


function wnd_create(layout)
	local wnd = wnd_transportProcessBar.new();
		wnd:create(layout);
	return wnd;
end
