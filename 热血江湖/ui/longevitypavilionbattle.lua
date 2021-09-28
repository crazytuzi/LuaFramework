-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_longevityPavilionBattle = i3k_class("wnd_longevityPavilionBattle", ui.wnd_base)


--任务类型
local RESOURCEPOINT = 1 --采矿
local KILL_MONSTER = 2 --杀怪

function wnd_longevityPavilionBattle:ctor()

end

function wnd_longevityPavilionBattle:configure()
	local widget = self._layout.vars
	widget.reverseBt:onClick(self, self.onReverseBt)
	widget.closeBtn:onClick(self, self.onCloseAnisBtn)
	widget.openBtn:onClick(self, self.onOpenAnisBtn)
	self._taskdesc = {widget.task1, widget.task2, widget.task3}
	g_i3k_game_context:setLongevityPavilionReset(0)
end

function wnd_longevityPavilionBattle:refresh()
	self:refreshScoll()
end

function wnd_longevityPavilionBattle:refreshScoll()
	local widget = self._layout.vars	
	local score = g_i3k_game_context:getLongevityPavilionScorInfo()	
	--local score = self:getMyScore(scoreInfo)
	local battleInfo = g_i3k_game_context:getLongevityPavilionBattleInfo()
	local cfg = g_i3k_db.i3k_db_get_longevity_pavilion_task_cfg()
	local curStageCfg = cfg[battleInfo.stage and battleInfo.stage  or 1]
	widget.title:setText(i3k_get_string(curStageCfg.title))
	widget.tips:setText(i3k_get_string(curStageCfg.tip))
	widget.score:setText(i3k_get_string(18562, score))
	for i,v in ipairs(self._taskdesc) do
		local taskID = curStageCfg.taskGroup[i]
		if  taskID then
			v:show()
			local curCount = battleInfo.task[taskID] or 0
			local task = i3k_db_longevity_pavilion_task[taskID]
			local str = ""
			if task.type == RESOURCEPOINT then
				str = i3k_db_resourcepoint[task.arg1].name 
			elseif task.type == KILL_MONSTER then
				str = i3k_db_monsters[task.arg1].name
			end
			local str2 = ""
			if task.arg2 ~= curCount then
				str2 = "<c=red>"..curCount.."/"..task.arg2.. "</c>"
			else
				str2 = "<c=hlgreen>"..curCount.."/"..task.arg2.. "</c>"
			end
			v:setText(string.format("%s  %s",str, str2))
		else
			v:hide()
		end
	end
end

function wnd_longevityPavilionBattle:onUpdate(dTime)
	self:updateReset()
end


function wnd_longevityPavilionBattle:updateReset()
	local widget = self._layout.vars	
	local time = g_i3k_game_context:getLongevityPavilionReset()
	local coolTime = i3k_game_get_time() - time
	if coolTime < i3k_db_longevity_pavilion.resetTime then
		widget.time:show()
		widget.time:setText(i3k_get_time_show_text(i3k_db_longevity_pavilion.resetTime - coolTime)) 
	else
		widget.time:hide()
	end
end

function wnd_longevityPavilionBattle:onReverseBt()
	local time = g_i3k_game_context:getLongevityPavilionReset()
	if i3k_game_get_time() - time >= i3k_db_longevity_pavilion.resetTime then
		if g_i3k_game_context:IsInFightTime() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1310))
			return
		end
		
		local fun = (function(ok)
			if ok then
				i3k_sbean.longevity_loft_reset()	
			end
		end)
			
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18131), fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18581))
	end
	
end


function wnd_longevityPavilionBattle:onCloseAnisBtn()
	local widget = self._layout.vars	
	widget.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		widget.openBtn:show()
	end)
end

function wnd_longevityPavilionBattle:onOpenAnisBtn()
	local widget = self._layout.vars
	widget.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		widget.closeBtn:show()
	end)
end

function wnd_create(layout, ...)
	local wnd = wnd_longevityPavilionBattle.new()
	wnd:create(layout, ...)
	return wnd;
end
