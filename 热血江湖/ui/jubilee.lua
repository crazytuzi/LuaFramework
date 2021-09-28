--[[
        @Date    : 2019-02-16
        @Author  : zhangbing
        @layout  : zhounianqing
    	@UIID	 : eUIID_Jubilee
--]]
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
---------------------------------------------------------------
local TIME_SPACE = 1 --间隔
local BASE_CFG = i3k_clone(i3k_db_jubilee_base)
local COMMON_CFG = BASE_CFG.commonCfg
local STAGE1_CFG = BASE_CFG.stage1

wnd_jubilee = i3k_class("wnd_jubilee", ui.wnd_base)

function wnd_jubilee:ctor()
	self._recordTime = 0
	self._info = {}
end

function wnd_jubilee:configure()
	local widgets = self._layout.vars

	widgets.gotoBtn:onClick(self, self.onGoto)
	widgets.stage3Btn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_JubileeStageThreeTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_JubileeStageThreeTips)
	end)
	widgets.close:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17939))
	end)
end

function wnd_jubilee:refresh(info)
	self:loadStageWidgets(info)
	self:loadRedPoint()
end

function wnd_jubilee:loadRedPoint()
	local condition1, _, condition3 = g_i3k_game_context:GetJubileeRedState(g_i3k_db.i3k_db_get_jubilee_stage())
	self._layout.vars.redPoint1:setVisible(condition1)
	self._layout.vars.redPoint2:setVisible(g_i3k_game_context:GetJubileeStep2TaskRedPoint()) --ui阶段二红点为任务可否领奖
	self._layout.vars.redPoint3:setVisible(condition3)
end

function wnd_jubilee:loadStageWidgets(info)
	self._info = info
	self:loadStage1Widgets()
	self:loadStage2Widgets(info)
	self:loadStage3Widgets()
	self:updateStageState(g_i3k_db.i3k_db_get_jubilee_stage())
end

function wnd_jubilee:loadStage1Widgets()
    self._layout.vars.timeDesc1:setText(i3k_get_string(17921, i3k_get_show_time_format(COMMON_CFG.startTime1), i3k_get_show_time_format(COMMON_CFG.startTime2)))
	self._layout.vars.explain1:setText(i3k_get_string(17922, STAGE1_CFG.needActivity))
	self._layout.vars.stage1Name:setText(i3k_get_string(17925))
	local activity = g_i3k_game_context:GetJubileeStep1Activity()
	activity = activity > STAGE1_CFG.needActivity and STAGE1_CFG.needActivity or activity
	self._layout.vars.stage1Bar:setPercent(activity / STAGE1_CFG.needActivity * 100)
	self._layout.vars.stage1Activity:setText(i3k_get_string(17928, activity, STAGE1_CFG.needActivity))
	self._layout.vars.stage1Btn:onClick(self, self.onCheckStage1)
end

function wnd_jubilee:onCheckStage1(sender)
	local canReceive = g_i3k_game_context:GetJubileeRedState(g_i3k_db.i3k_db_get_jubilee_stage())
	g_i3k_ui_mgr:OpenUI(eUIID_JubileeStageOneAward)
	g_i3k_ui_mgr:RefreshUI(eUIID_JubileeStageOneAward, canReceive)
end

function wnd_jubilee:loadStage2Widgets(info)
	info = info or self._info
	local widgets = self._layout.vars
    widgets.timeDesc2:setText(i3k_get_string(17921, i3k_get_show_time_format(COMMON_CFG.startTime2), i3k_get_show_time_format(COMMON_CFG.startTime3)))
    self._layout.vars.explain2:setText(i3k_get_string(17923, BASE_CFG.stage2.task1Total))
    self._layout.vars.stage2Name:setText(i3k_get_string(17926))

	local cfg = i3k_db_jubilee_base.stage2
	local awardsCfg = cfg.taskAwards
	for i = 1, 3 do
		local activity = (info.taskNum[i] or 0) + (info.autoAddTaskNum[i] or 0)
		local percent = activity / cfg["task"..i.."Total"] * 100
		widgets["taskName"..i]:setText(i3k_get_string(cfg.taskNames[i]))
		widgets["taskBar"..i]:setPercent(percent)
		local isReceive = g_i3k_game_context:GetJubileeStep2TaskReward(i)
		local idx = i + 4
		self._layout.vars["reward_get_icon"..idx]:setVisible(isReceive)
		self._layout.vars["reward_icon"..idx]:setVisible(not isReceive)
		if percent >= 100 and not isReceive then
			self._layout.anis["c_bx"..idx].play()
		else
			self._layout.anis["c_bx"..idx].stop()
		end
		widgets["chestBtn"..i]:onClick(self, function()
			if percent >= 100 and not isReceive then
				local items = g_i3k_db.i3k_db_cfg_items_to_BagEnougMap(awardsCfg[i])
				if not g_i3k_game_context:IsBagEnough(items) then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
				else
				i3k_sbean.jubilee_activity_step2_reward(i)
				end
			else
				g_i3k_ui_mgr:OpenUI(eUIID_JubileeChestTips)
				g_i3k_ui_mgr:RefreshUI(eUIID_JubileeChestTips, i)
			end
		end)
	end
	widgets.stage2Btn:onClick(self, self.onCheckStage2)
end

function wnd_jubilee:onCheckStage2(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_JubileeStageTwoAward)
	g_i3k_ui_mgr:RefreshUI(eUIID_JubileeStageTwoAward)
end

function wnd_jubilee:loadStage3Widgets()
    self._layout.vars.timeDesc3:setText(i3k_get_string(17921, i3k_get_show_time_format(COMMON_CFG.startTime3), i3k_get_show_time_format(COMMON_CFG.endTime)))
	self._layout.vars.explain3:setText(i3k_get_string(17924))
	self._layout.vars.stage3Name:setText(i3k_get_string(17927))
	self._layout.vars.gotoTxt:setText(i3k_get_string(17933))

	local stage = g_i3k_db.i3k_db_get_jubilee_stage()
	self._layout.vars.countdownTxt:setText(i3k_get_string(17936, self:GetStage3Desc(stage)))
end

function wnd_jubilee:GetStage3Desc(stage)
	if stage < g_JUBILEE_COUNTDOWN then
		return i3k_get_string(17934)
	end

	if stage == g_JUBILEE_COUNTDOWN then
		local cfg = i3k_db_jubilee_base.commonCfg
		local endTime = cfg.startTimeData3 +  i3k_db_jubilee_base.stage3.countdownTime
		local leftTime = endTime - g_i3k_get_GMTtime(i3k_game_get_time())
		return i3k_get_time_show_text(leftTime)
	end

	if stage >= g_JUBILEE_COUNTDOWN_END then
		return i3k_get_string(17935)
	end
end

function wnd_jubilee:onGoto(sender)
	local targetPos = i3k_db_jubilee_base.stage3.targetPos
	local rndIdx = i3k_engine_get_rnd_u(1, #targetPos)
	local randPos = targetPos[rndIdx]
	local mapID = i3k_db_jubilee_base.commonCfg.npcMapID
	g_i3k_game_context:GotoPos(mapID, randPos)
	self:onCloseUI()
end

function wnd_jubilee:GetJubileeStageDesc(stage)
	if stage == g_JUBILEE_STAGE1 then
		return i3k_get_string(17940)
	end

	if stage == g_JUBILEE_STAGE2 then
		return i3k_get_string(17941)
	end

	if stage >= g_JUBILEE_COUNTDOWN and stage <= g_JUBILEE_STAGE3 then
		return i3k_get_string(17942)
	end
	return ""
end

function wnd_jubilee:updateStageState(stage)
	self._layout.vars.stageDesc:setText(i3k_get_string(17938, self:GetJubileeStageDesc(stage)))
	for i = 1, 2 do
		self._layout.vars["stageOverIcon"..i]:setVisible(stage > i)
	end
	self._layout.vars.stageOverIcon3:setVisible(stage > g_JUBILEE_STAGE3)
end

-- 阶段3倒计时
function wnd_jubilee:onUpdate(dTime)
	if i3k_game_get_time() - self._recordTime > TIME_SPACE then
		local stage = g_i3k_db.i3k_db_get_jubilee_stage()
		self._layout.vars.countdownTxt:setText(i3k_get_string(17936, self:GetStage3Desc(stage)))
		self:updateStageState(stage)
	end
end

function wnd_create(layout)
	local wnd = wnd_jubilee.new()
	wnd:create(layout)
	return wnd
end
