module(..., package.seeall)
local require = require
local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_faction_garrison_spirit = i3k_class("wnd_faction_garrison_spirit", ui.taskBase)
--计时变量
local mSecondCounter = 0
-- 计时结束
local spiritEnd = true
function wnd_faction_garrison_spirit:ctor()
	
end

function wnd_faction_garrison_spirit:configure()
	self.isSetPos = false
	self._tabState = 1 -- 当前显示的面板ID(1.任务 2.队伍 3.输出)
	local widgets = self._layout.vars
	widgets.taskBtn:onClick(self, self.onBaseTaskBtn)
	widgets.team:onClick(self,self.onBaseZuduiBtn)
	widgets.closeBtn:onClick(self, self.onCloseAnisBtn)
	widgets.openBtn:onClick(self, self.onOpenAnisBtn)
    BASE.setTabState(self, 1)
end
function wnd_faction_garrison_spirit:onShow()

end
function wnd_faction_garrison_spirit:refresh()
	self:updateScroll()
end

function wnd_faction_garrison_spirit:updateScroll()
	local widgets = self._layout.vars
	local deathSpirit = g_i3k_game_context:GetFactionSpiritKillData() 
	local personal = g_i3k_game_context:GetFactionSpiritKillpersonal()
	local cfgSpiritCount = i3k_db_faction_spirit.spiritCfg.monsterCount
	local addExpId = g_i3k_db.i3k_db_get_faction_spirit_get_addexp(deathSpirit)
	local addExpDesc = nil
	if addExpId == 0 then
		local count = g_i3k_db.i3k_db_get_faction_spirit_get_min_count()
		addExpDesc = i3k_get_string(17463, count)
	else
		local addExp = i3k_db_faction_spirit.blessingRewards[addExpId].expCount
		local addBuf = addExp/100
		addExpDesc = i3k_get_string(17464, deathSpirit).."\n"..i3k_get_string(17465, addBuf)
		
	end
	self:updataLifeTime()
	widgets.desc:setText(addExpDesc)
	widgets.selfCount:setText(i3k_get_string(17487, personal))
	widgets.time_label2:setText(i3k_get_string(17460))
	widgets.number:setText(i3k_get_string(17462, cfgSpiritCount - deathSpirit, cfgSpiritCount)) 
end

--帧事件
function wnd_faction_garrison_spirit:onUpdate(dTime)
	mSecondCounter = mSecondCounter + dTime
	if spiritEnd and mSecondCounter > 0.1  then
		mSecondCounter = 0
		self:updataLifeTime()
	end
end

function wnd_faction_garrison_spirit:updataLifeTime()
	local cfg = i3k_db_faction_spirit.spiritCfg
	local openTimeCfg = cfg.openTime + cfg.lifeTime
	local openTime = g_i3k_get_day_time(openTimeCfg)
	local curTime =  openTime - i3k_game_get_time()
	if curTime < 0 then
		curTime = 0
		spiritEnd = false
	end
	local time = i3k_get_time_show_text(curTime)
	self._layout.vars.time:setText(i3k_get_string(17461, time))
end

function wnd_create(layout)
	local wnd = wnd_faction_garrison_spirit.new()
	wnd:create(layout)
	return wnd
end
