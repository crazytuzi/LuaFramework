module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_homelandOverView = i3k_class("wnd_homelandOverView", ui.wnd_base)
function wnd_homelandOverView:ctor()
	self._hero = i3k_game_get_player_hero();
	self._moveFlag = false
end

function wnd_homelandOverView:configure()
	self._layout.vars.restoreBtn:onClick(self, self.onRestoreBtn)
end

function wnd_homelandOverView:refresh()

end

function wnd_homelandOverView:onShow()

end

function wnd_homelandOverView:onRestoreBtn(sender)
	g_i3k_game_context:setHomelandOverViewStatus(false)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "setChatVisible", true)
	g_i3k_ui_mgr:OpenUI(eUIID_HouseBase)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
	self:onCloseUI()
end

function wnd_homelandOverView:onUpdate()
    if not self._hero._behavior:Test(eEBMove) or self._moveFlag then
        return
    end
	
	self._moveFlag = true
	
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local callback = function()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandOverview, "moveFunction")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "setChatVisible", true)
		end
	
		g_i3k_ui_mgr:OpenUI(eUIID_HouseBase)
		g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase, callback)
	end, 1)
end

function wnd_homelandOverView:moveFunction()
	g_i3k_game_context:setHomelandOverViewStatus(false)
	self:onCloseUI()
end

function wnd_create(layout)
	local wnd = wnd_homelandOverView.new();
	wnd:create(layout);
	return wnd;
end
