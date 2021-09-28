-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arena_choose = i3k_class("wnd_arena_choose", ui.wnd_base)

function wnd_arena_choose:ctor()
	
end

function wnd_arena_choose:configure()
	local widgets = self._layout.vars
--	widgets.title:setText("竞技场")--图片
	widgets.firstClanName:setText("1v1竞技场")
--	widgets.time:setText()
	widgets.arena_btn:onClick(self,self.intoArena)
	widgets.colorhock_btn:onClick(self,self.intoColorhock)
	widgets.close_btn:onClick(self,self.onCloseUI)
end

function wnd_arena_choose:refresh()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local openTime = i3k_db_taoist.openTime
	local endTime = i3k_db_taoist.closeTime
	local openStr = string.sub(openTime, 1, 5)
	local endStr = string.sub(endTime, 1, 5)
	local time = openStr.."~"..endStr
	self._layout.vars.timeLabel:setText(time)
end

function wnd_arena_choose:intoArena(sender)
	local hero = i3k_game_get_logic():GetPlayer():GetHero()
	if hero then
		if tonumber(hero._lvl) < tonumber(i3k_db_arena.arenaCfg.needLvl) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_arena.arenaCfg.needLvl))
		else
			if not g_i3k_game_context:IsInRoom() then
				i3k_sbean.sync_arena_info()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(143))
			end
		end
	end
end

--正邪道场
function wnd_arena_choose:intoColorhock(sender)
	local hero = i3k_game_get_logic():GetPlayer():GetHero()
	if hero then
		if hero._lvl < i3k_db_taoist.needLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_taoist.needLvl))
		else 
			if g_i3k_game_context:GetTransformLvl()>= 2 then
				if not g_i3k_game_context:IsInRoom() then
					--协议
					i3k_sbean.sync_taoist()
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(143))
				end
			else
				--达到两转
				local msg = "大侠，只有完成2转加入正邪势力，方可进入正邪道场比赛。"
				g_i3k_ui_mgr:ShowMessageBox1(msg)
			end
		end
	end
end

--[[function wnd_arena_choose:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Arena_Choose)
end--]]

function wnd_create(layout,...)
	local wnd = wnd_arena_choose.new();
		wnd:create(layout,...)
	return wnd;
end
