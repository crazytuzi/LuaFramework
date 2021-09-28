-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
forcewar_showkillnumber = i3k_class("forcewar_showkillnumber",ui.wnd_base)

local FORCEWAR_NPC = 3
local FORCEWAR_COMMON = 4
local FORCEWAR_STATUE = 5
local FORCEWAR_BOSS = 6

function forcewar_showkillnumber:ctor()
	
end

function forcewar_showkillnumber:refresh()
	--要显示小地图，小地图上方要显示本方(黄)和敌方(红)	
	--self:showTargetInfo()
	local score= g_i3k_game_context:getForceWarScore()
	self:showInfo(score.whiteScore,score.blackScore)
	local forceWarType = i3k_get_forcewar_type()
	local iconID = i3k_db_forcewar[forceWarType].battleIconID
	self._nameImage:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
end

function forcewar_showkillnumber:configure(...)
	local widget = self._layout.vars
	self.decent = widget.decent--正派分数
	self.villain = widget.villain--反派
	
	widget.decent:setText("0")
	widget.villain:setText("0")
	
	--widget.exit:onClick(self, self.onExit)
	widget.task_btn:onClick(self,function (sender)
		--战报协议，客户端排序
		i3k_sbean.query_role_forcewar_result()
	end)
	widget.taskName:setText("")--上
	widget.taskDesc:setText("")--下
	widget.self_sideImg:hide()--我方血量条
	widget.other_sideImg:hide()--敌方血量条
	
	f_isPlay = false
	local mapType = i3k_game_get_map_type()
	
	if mapType== g_FORCE_WAR then
		f_fightCoolTime = i3k_db_forcewar_base.otherData.waitTime
	end
	local totalNormalStatue,totalBigStatue = g_i3k_game_context:getForceWarStatuesCount()
	self._showMessage = true
	self._maxTime = 0
	self._timeTick = 0
	self._nameImage = self._layout.vars.nameImage
end

function forcewar_showkillnumber:showInfo(decentscore,villainscore)
	---实时刷新分数
	self._layout.vars.decent:setText(decentscore)
	self._layout.vars.villain:setText(villainscore)
end

function forcewar_showkillnumber:showTargetInfo(id)
	---实时刷新击杀目标
	local totalNormalStatue,totalBigStatue = g_i3k_game_context:getForceWarStatuesCount()
	--local bwtype = g_i3k_game_context:GetTransformBWtype()
	local forceType = g_i3k_game_context:GetForceType()
	--- 判断当雕像都击杀完后，显示水晶信息 协议传雕像数量 
	
	local cfg = g_i3k_game_context:getForceWarStatuesInfo()
	--local double = {whiteSide,blackSide}
	local statue_count = 0
	local bigstatue_count = 0
	local otherbosscurHP = 0
	local otherbossmaxHP = 0
	local selfbosscurHP = 0
	local selfbossmaxHP = 0
	for k,v in pairs(cfg) do--double[bwtype]
		local boss = i3k_db_monsters[v.cfgid].boss --boss类型
		if v.bwtype ~=  forceType then--对方
			if boss == FORCEWAR_NPC  then
		
			elseif boss ==FORCEWAR_COMMON then--普通
				statue_count = statue_count +1
			elseif boss ==FORCEWAR_STATUE then--大雕像
				bigstatue_count = bigstatue_count +1
			else --水晶
				otherbosscurHP = v.curHP
				otherbossmaxHP = v.maxHP
			end
		elseif v.bwtype ==  forceType and boss == FORCEWAR_BOSS then
			selfbosscurHP = v.curHP
			selfbossmaxHP = v.maxHP
		end
	end

	local already_dead = g_i3k_game_context:GetForceWarStatuesNums()
	local already_deadCount =i3k_table_length(already_dead)
	if statue_count==0 and bigstatue_count == 0 then--己方
		--显示水晶的血量
		self._showMessage = false
		self._layout.vars.self_side:setPercent(selfbosscurHP/selfbossmaxHP*100)
		self._layout.vars.other_side:setPercent(otherbosscurHP/otherbossmaxHP*100)
		self._layout.vars.self_sideImg:show()
		self._layout.vars.other_sideImg:show()
		self._layout.vars.taskName:setText("我方水晶")
		self._layout.vars.taskDesc:setText("敌方水晶")
		self._layout.vars.taskName:setTextColor(g_i3k_get_cond_color(true))
		self._layout.vars.taskDesc:setTextColor(g_i3k_get_cond_color(true))

	else
		--self._showMessage = true
		local kill_bigStatue = totalBigStatue-bigstatue_count
		local kill_normalStatue = totalNormalStatue-statue_count
		local bigStatue = string.format("击杀对方雕像%s/%s",kill_bigStatue,totalBigStatue)
		local normalStatue = string.format("击杀对方小雕像%s/%s",kill_normalStatue,totalNormalStatue)
		self._layout.vars.taskName:setText(bigStatue)
		self._layout.vars.taskDesc:setText(normalStatue)
		self._layout.vars.self_sideImg:hide()
		self._layout.vars.other_sideImg:hide()
		self._layout.vars.taskName:setTextColor(g_i3k_get_cond_color(kill_bigStatue>= totalBigStatue))
		self._layout.vars.taskDesc:setTextColor(g_i3k_get_cond_color(kill_normalStatue>=totalNormalStatue))
	end
end

function forcewar_showkillnumber:showPopupTipMessage()
	if self._showMessage then
		self._showMessage = false
		--g_i3k_ui_mgr:PopupTipMessage("毁坏对方全部雕像前，水晶无敌")
	end
end

-- 刷新 成员位置
function forcewar_showkillnumber:SetMemberLocation(roleId, bwType )
	if g_i3k_ui_mgr:GetUI(eUIID_ForceWarMiniMap) then
		local location = g_i3k_game_context:GetForceWarMemberPosition(roleId)
		if location then
			updateDoubleSideInfo(roleId, location.mapId, location.pos)
			if bwType then
				updateDoubleSideMate(roleId, location.mapId, location.pos,bwType,true )
			end
		end
	end
end

-- 刷新 雕像位置
function forcewar_showkillnumber:SetStatueLocation(roleId, bwType)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMiniMap, "updateMapInfo",roleId)
end

function forcewar_showkillnumber:onUpdate(dTime)
	local logic = i3k_game_get_logic();
	if g_i3k_game_context:getForceWarUpdateTime() then---显示势力战自动关闭倒计时
		self._timeTick = self._timeTick + dTime
		local tm = math.ceil(i3k_db_forcewar_base.otherData.autoCloseTime - self._timeTick)--i3k_integer(self._maxTime )
		if tm >= 0 then
			if tm > 10 then
				self:updateTimeElapse(tm, "ffffffff")
			else
				self:updateTimeElapse(tm, "ffff0000")
			end
		end
	end
end

function forcewar_showkillnumber:updateTimeElapse(time, color) -- InvokeUIFunction
	local surplusTime
	local tm = time;
	local h = i3k_integer(tm / (60 * 60));
	tm = tm - h * 60 * 60;
	local m = i3k_integer(tm / 60);
	tm = tm - m * 60;
	local s = tm;
	surplusTime = h*60*60 + m*60 + s
	local mapType = i3k_game_get_map_type()
	local totalTime
	if mapType== g_FORCE_WAR then   --势力战
		totalTime = i3k_db_forcewar[1].maxTime
	else
		return	
	end
	if f_fightCoolTime-(totalTime-surplusTime)<=0 then--等待时间
		f_fightCoolTime = -1
	elseif f_fightCoolTime-(totalTime-surplusTime)<=3 then--显示 3 2 1 Go
		if not f_isPlay then
			if g_i3k_ui_mgr:GetUI(eUIID_BattleFight) then
				g_i3k_ui_mgr:CloseUI(eUIID_BattleFight)
			end
			g_i3k_ui_mgr:OpenUI(eUIID_BattleFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleFight)
			f_isPlay = true
		end
	end
end

function forcewar_showkillnumber:onExit(sender)
	local fun = (function(ok)
		if ok then
			f_isPlay = false
			--离开
			g_i3k_game_context:setForceWarDropOutState(true)
			i3k_sbean.mapcopy_leave()
		else
		end
	end)
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(66), fun)
end

function wnd_create(layout, ...)
	local wnd = forcewar_showkillnumber.new()
	wnd:create(layout, ...)
	return wnd
end
