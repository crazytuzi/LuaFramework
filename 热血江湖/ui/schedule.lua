-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_schedule = i3k_class("wnd_schedule", ui.wnd_base)

local sch_path = "ui/widgets/rcbt"

local l_tag = 1000

local KE_JU = 0 --科举
local HEGEMONY = 1 -- 五绝争霸
local GROOM_STATE = 1
local TIME_STATE = 2
local FES_STATE = 3

local SCHEDULE_ACT_TYPE = 1
local SCHEDULE_DUNGENON_GROUP_TYPE = 2
local SCHEDULE_DUNGENON_COMMON_TYPE = 3
local SCHEDULE_DUNGENON_HARD_TYPE = 4
local SCHEDULE_RIGHTHEART_TYPE = 21

local GROUP_BEST_GROOM = 3
local GROUP_COMMON_GROOM = 2
local COMMON_BEST_GROOM = 3
local COMMON_COMMON_GROOM = 1
local HARD_BEST_GROOM = 3
local HARD_COMMON_GROOM = 1

local GROOM_FLAG = 3
local MUST_FLAG = 4
local GALA_FLAG = 5
local EXP_FLAG = 6

local GROOM_ICON_ID = 2567
local MUST_ICON_ID = 2566
local GALA_ICON_ID = 5209
local EXP_ICON_ID = 8372

local REWARD_STATE_NOT = 0
local REWARD_STATE_READY = 1
local REWARD_STATE_FINISH = 2

local SCHEDULE_ONE = 1
local SCHEDULE_TWO = 2

local CAN_SCHEDULE_COLOR = "ffffd512"
local NOT_SCHEDULE_COLOR = "ffe2e2e2"

local  CAN_SCHEDULE_TXT_ICON_ID = 2564
local  NOT_SCHEDULE_TXT_ICON_ID = 2565

local l_unmarried = 0
local l_married = 1

-------日常start------------------------------

local l_TabName = {[1] = 2354,[2] = 2827,[3] = 6592}
local l_pItem 	= "ui/widgets/rcht1"
local l_sExpTab = {491}
--日常任务跳转表
local gotoDailyTask = {
	[1] = function()
			g_i3k_logic:OpenDungeonUI()
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[2] = function()
			g_i3k_logic:OpenDungeonUI()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "onZuduiBtnClick")
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[3] = function()
			--i3k_log("帮派任务")
			local fun1 = function ()
				local data = i3k_sbean.sect_task_sync_req.new()
				i3k_game_send_str_cmd(data,i3k_sbean.sect_task_sync_res.getName())
			end
			local data = i3k_sbean.sect_sync_req.new()
			data.callBack = fun1
			i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[4] = function()
			--i3k_log("竞技场")

			g_i3k_logic:OpenArenaUI(function()
				g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
			end)

		end,
	[5] = function()
			--月卡功能
			local fun = (function()
					--g_i3k_logic:OpenDailyTask(1)
					g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
					g_i3k_ui_mgr:RefreshUI(eUIID_Schedule,4)  --状态4为日常按钮
			end)
			g_i3k_logic:OpenChannelPayUI(fun)
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)

		end,
	[6] = function()
			--i3k_log("体力1")
		end,
	[7] = function()
			--i3k_log("体力2")
		end,
	[8] = function()
			--i3k_log("体力3")
		end,
	[9] = function()
			--i3k_log("活动介面")
			g_i3k_logic:OpenShiLianUI()
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[10] = function()
			--i3k_log("帮派副本")
			--发协议
			local tmp_dungeon = {}
			for k, v in pairs(i3k_db_faction_dungeon) do
				table.insert(tmp_dungeon,v)
			end
			table.sort(tmp_dungeon,function (a,b)
				return a.enterLevel < b.enterLevel
			end)
			local fun = function ()
				local data = i3k_sbean.sectmap_query_req.new()
				data.mapId = tmp_dungeon[1].id
				i3k_game_send_str_cmd(data,i3k_sbean.sectmap_query_res.getName())
			end
			local fun1 = function ()
				local data = i3k_sbean.sectmap_status_req.new()
				data.fun = fun
				i3k_game_send_str_cmd(data,i3k_sbean.sectmap_status_res.getName())
			end
			local data = i3k_sbean.sect_sync_req.new()
			--传回调的参数
			data.callBack = fun1
			i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[11] = function()
			--i3k_log("买金币")
			--i3k_log("--OpenUI = -------")----
			local fun = (function()
					g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
					g_i3k_ui_mgr:RefreshUI(eUIID_Schedule,4)  --状态4为日常按钮
			end)
			g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyCoin, "backDailyUiSign" ,fun)
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)

		end,
	[12] = function(cfg)
			--i3k_log("困难副本")
			g_i3k_logic:OpenDungeonUI()
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[13] = function()
			--i3k_log("任意副本")
			g_i3k_logic:OpenDungeonUI()
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,
	[14] = function()
			--i3k_log("活动介面 任意日常活动2")

		end,
	
	[15] = function()
			g_i3k_logic:OpenHostelUI()
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end,

	[16] = function()
			--i3k_log("正邪道场参与次数")

			local hero = i3k_game_get_logic():GetPlayer():GetHero()
			if hero then
				if hero._lvl < i3k_db_taoist.needLvl then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_taoist.needLvl))
				else
					if g_i3k_game_context:GetTransformLvl()>= 2 then
						if not g_i3k_game_context:IsInRoom() then
							--协议
							--i3k_sbean.sync_taoist()
							g_i3k_logic:OpenTaoistUI(function()
								g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
							end)
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

		end,
	[17] = function()
		--帮派运镖
		g_i3k_logic:OpenFactionEscortUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[18] = function()
		--参与会武副本
		g_i3k_logic:OpenTournamentUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[19] = function()
		--参与五绝试炼
		g_i3k_logic:OpenFiveUniqueUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[20] = function()
		--好友ui
		g_i3k_logic:OpenMyFriendsUI()

		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[21]=function()
		if i3k_game_get_os_type() == eOS_TYPE_IOS then
			g_i3k_game_handler:ShareTaskID(i3k_db_common.shareIosSdkId)
		elseif i3k_game_get_os_type() == eOS_TYPE_OTHER then
			g_i3k_game_handler:ShareTaskID(i3k_db_common.shareAndroidSdkId)
		end
	end,
	[22] = function()
		g_i3k_game_context:GotoNpc(i3k_db_rightHeart.npcId)
	end,
	[23] = function()
		--g_i3k_logic:OpenDemonHoleUI()
		g_i3k_logic:OpenMazeBattleActivityUI()
	end,
	[24] = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "OpenRightLimitTimeAct")
	end,
	[25] = function()
		g_i3k_logic:OpenSpiritBossUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[26] =  function()
		--竞技场
		g_i3k_logic:OpenArenaUI(function()
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		end)
	end,
	[27] = function()
		g_i3k_game_context:GotoNpc(i3k_db_illusory_dungeon_cfg.npcId)
	end,
	[28] = function()
		g_i3k_logic:OpenPrincessMarryActivityUI()	
	end,
	[29] = function ()
		g_i3k_logic:OpenLongevityPavilionActivityUI()
	end,
}

local gotoWeeklyTask = {
	
	[208] = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "gotoActivity")
	end,
	
	[201] = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "OpenRightRecommendAct")
	end,
	[202] = function()
		g_i3k_logic:OpenVipStoreUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[203] = function()
		g_i3k_logic:OpenTournamentUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	[204] = function()
		g_i3k_logic:OpenSectFightUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,

	[205] = function()
		g_i3k_logic:OpenArenaUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,
	
	[206] = function()
		g_i3k_logic:OpenStrengEquipUI()
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
	end,

	[207] = function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "OpenRightDailyTask")
	end,
	
}
-------日常end------------------------------

function wnd_schedule:ctor()
	self.rightBtn = {}
	self.rewardBtn = {}
	self.rightState = 1
	self.scheduleCfg = {}
	self.scheduleInfo = {}
	self.rewardsState = {}
	self._gbOpenTime = {}
end

function wnd_schedule:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	widgets.calendarBtn:onClick(self,self.onShowCalendar)
	self.rightBtn = {widgets.groom_btn, widgets.time_btn, widgets.fes_btn ,widgets.dailyBtn}
	for k,v in ipairs(self.rightBtn) do
		v:setTag(k + l_tag)
		v:onClick(self,self.onRightClick)
	end
	local fs = g_i3k_game_context:getFeishengInfo()
	local str = fs._isFeisheng and 1757 or 17502
	widgets.quick_des:setText(i3k_get_string(str))
	self._layout.vars.quick_des_btn:onClick(self,function()
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg()
		local msg
		if fs._isFeisheng then
			msg = i3k_get_string(1758,cfg[1].needActivity,cfg[2].needActivity,cfg[3].needActivity, cfg[4].needActivity, cfg[5].needActivity)
		else
			msg = i3k_get_string(17504,cfg[1].needActivity,cfg[2].needActivity,cfg[3].needActivity, cfg[4].needActivity)
		end
		g_i3k_ui_mgr:ShowHelp(msg)
	end)
	-------日常start---------------
	self.scroll = widgets.scroll1
	self.red_img4 = widgets.red_img4
	self.red_img4:setVisible(false)
	self.rcbUI = widgets.rcbUI		--活动ui
	self.DailyUi = widgets.DailyUi --日常任务ui
	self.weekUi = widgets.WeekUi
	self.rcbUI:show()
	self.DailyUi:hide()
	self.weekUi:hide()
	self.tital = widgets.tital  --标题
	self.desa = widgets.desa      				--日常任务状况标题
	self.batchBtn = widgets.batchBtn  	 		--日常任务一键领取领取按钮
	self.showNone = widgets.showNone
	-------日常end-----------------

	--week task
	self.red_img3 = widgets.red_img3
	widgets.weektips:setText(i3k_get_string(16945))
	local anis = self._layout.anis
	self.weekTaskWidgets = {}
	for i = 1 , 5 do
		local wdg = {
			btn = widgets["reward_btn1".. i],
			valueTxt = widgets["reward_txt1"..i],
			ani = anis[string.format("c_fudai%s",i)],
			openIcon = widgets["reward_get_icon1"..i],
			closeIcon = widgets["reward_icon1"..i],
		}
		table.insert(self.weekTaskWidgets, wdg)
	end
end

function wnd_schedule:refresh(state)
	--self.activity:		int32
	--self.task2num:		map[int32, int32]
	--self.rewards:		set[int32]
	if state then
		self.rightState = state
	end
	self.scheduleInfo = g_i3k_game_context:GetScheduleInfo()
	self._layout.vars.act_txt:setText(self.scheduleInfo.activity)
	self:getScheduleCfg()
	self:updateRightBtnState()
	self:setSchedule()
	self.red_img4:setVisible(g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_REWARD_DAILY_TASK))
	self.red_img3:setVisible(g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_REWARD_WEEK_TASK))
	--self:changeRetrieveActState()
end

function wnd_schedule:onShowCalendar()
	g_i3k_ui_mgr:OpenUI(eUIID_Activity_Calendar)
	g_i3k_ui_mgr:RefreshUI(eUIID_Activity_Calendar)
end

function wnd_schedule:changeRetrieveActState()
	if g_i3k_game_context:IsRetrieveActExist() then
		self._layout.vars.retrieveBtn:onClick(self, self.gotoRetrieveAct)
	else
		self._layout.vars.retrieveBtn:hide()
	end
end

function wnd_schedule:gotoRetrieveAct()
	g_i3k_ui_mgr:OpenUI(eUIID_RetrieveChoose)
	g_i3k_ui_mgr:RefreshUI(eUIID_RetrieveChoose)
end

function wnd_schedule:updateRightBtnState()
	if self.rightState == 4 then
		--这里的代码转移到了wnd_schedule:clearScorll()
		--目的是为了优化切换到日常任务界面时标题和一键领取按钮出现闪动的问题
		self:gotoDaily()
	elseif self.rightState == 3 then
		local cfg = i3k_db_weekTask.cfg
		if g_i3k_game_context:GetLevel() < cfg.openLvl then
			return g_i3k_ui_mgr:PopupTipMessage(string.format("达到%s级开启",cfg.openLvl))
		end

		if g_i3k_get_GMTtime(i3k_game_get_time()) < cfg.openTime then
			return g_i3k_ui_mgr:PopupTipMessage(string.format("%s开启",os.date("%c",cfg.openTime)))
		end
		self.rcbUI:hide()
		self.DailyUi:hide()
		self.tital:setImage(i3k_db_icons[l_TabName[3]].path)
		self:gotoWeak()
	else
		self.DailyUi:hide()
		self.weekUi:hide()
		self.rcbUI:show()
		self.tital:setImage(i3k_db_icons[l_TabName[2]].path)
		self:updateList()
	end

	for k,v in ipairs(self.rightBtn) do
		if k ~= self.rightState then
			v:stateToNormal()
		else
			v:stateToPressed()
		end
	end
end

function wnd_schedule:updateList()
	-- body
	local heroLvl = g_i3k_game_context:GetLevel()
	local sch_list = self._layout.vars.sch_list
	sch_list:removeAllChildren(true)
	local visuallist = self.scheduleCfg[self.rightState]--i3k_clone()
	allList = sch_list:addChildWithCount(sch_path,2,#visuallist)
	for k,v in ipairs(allList) do
		local detailCfg = visuallist[k]
		local Vars = v.vars
		Vars.icon_img:setImage(i3k_db.i3k_db_get_icon_path(detailCfg.iconID))
		if detailCfg.groomLvl == GROOM_FLAG then
			Vars.groom_img:setImage(i3k_db.i3k_db_get_icon_path(GROOM_ICON_ID))
		elseif detailCfg.groomLvl == MUST_FLAG then
			Vars.groom_img:setImage(i3k_db.i3k_db_get_icon_path(MUST_ICON_ID))
		elseif detailCfg.groomLvl == GALA_FLAG then
			Vars.groom_img:setImage(i3k_db.i3k_db_get_icon_path(GALA_ICON_ID)) 
		elseif detailCfg.groomLvl == EXP_FLAG then
			Vars.groom_img:setImage(i3k_db.i3k_db_get_icon_path(EXP_ICON_ID))
		else
			Vars.groom_img:setVisible(false)
		end
		Vars.name_txt:setText(detailCfg.name)
		Vars.act_txt:setText(i3k_get_string(627,detailCfg.actValue))
		if detailCfg.canEnterTimes ~= -1 then
			Vars.num_txt:setText("<c=green>"..detailCfg.finishTimes.."/"..((detailCfg.finishTimes > detailCfg.canEnterTimes) and detailCfg.finishTimes or detailCfg.canEnterTimes).."</c>")
		else
			Vars.num_txt:setText("<c=red>"..i3k_get_string(629).."</c>")
		end
		Vars.item_btn:setTag(k + l_tag)
		Vars.item_btn:onClick(self,self.onItemClick, detailCfg)

		if detailCfg.isTime then
			Vars.go_btn:setTag(k + l_tag)
			Vars.go_btn:onClick(self,self.onGoClick,detailCfg)
			Vars.time_txt:setVisible(false)
		else
			Vars.go_btn:setVisible(false)
			Vars.time_txt:setVisible(true)
			Vars.time_txt:setText(detailCfg.timeStr)
			--Vars.time_txt:setTextColor(g_i3k_get_cond_color(false))
		end
		if detailCfg.finishFlag then
			Vars.go_btn:disableWithChildren()
			Vars.goBtn_txt:setText("已完成")
		end
		if not detailCfg.timeStr then
			Vars.go_btn:setVisible(true)
			Vars.time_txt:setVisible(false)
			Vars.go_btn:disableWithChildren()
			Vars.goBtn_txt:setText("已结束")
		end
		if detailCfg.typeNum == g_SCHEDULE_TYPE_SPRING then
			local weekly_time = g_i3k_game_context:getSpringWeeklyTimes()
			Vars.weekly_time:show()
			Vars.weekly_time:setText(string.format("周次数：%s/%s", weekly_time > i3k_db_spring.common.weeklyEnter and i3k_db_spring.common.weeklyEnter or weekly_time, i3k_db_spring.common.weeklyEnter))
		end
	end
end

function wnd_schedule:onGoClick(sender,cfg)
	local tag = sender:getTag() - l_tag
	--if self.scheduleCfg[self.rightState] and self.scheduleCfg[self.rightState][tag] then
		--local cfg = self.scheduleCfg[self.rightState][tag]
		if g_i3k_game_context:GetTransformLvl() >= cfg.transformLvl then
			if cfg.typeNum == g_SCHEDULE_TYPE_ACT then
				g_i3k_logic:OpenActivityToIDUI(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_GROUP or cfg.typeNum == g_SCHEDULE_TYPE_COMMON or cfg.typeNum == g_SCHEDULE_TYPE_HARD then
				if cfg.isGroup == 1 then
					g_i3k_logic:OpenDungeonUI(false,cfg.mapID)
				else
					g_i3k_logic:OpenDungeonUI(true, cfg.mapID)
				end

			elseif cfg.typeNum == g_SCHEDULE_TYPE_TREASURE then
				g_i3k_logic:OpenTreasurePage1UI()
			elseif  cfg.typeNum == g_SCHEDULE_TYPE_TOWER then
				g_i3k_logic:OpenFiveUniqueUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_KONGFU then
				g_i3k_logic:OpenFactionCreateGongfuUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SECTDUNG then
				g_i3k_logic:OpenFactionDungeonUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SECTDART then
				g_i3k_logic:OpenFactionEscortUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SECTTASK then
				g_i3k_logic:OpenFactionTaskUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_AREA then
				g_i3k_logic:OpenArenaUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_TAOIST then
				self:toTaoist()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_TOURNAMENT then
				g_i3k_logic:OpenTournamentUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_FORCE_WAR then
				g_i3k_logic:OpenForceWarUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_WORldBOSS then
				g_i3k_logic:OpenWorldBossUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_PRODUCT then
				g_i3k_logic:OpenFactionProduction()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_RESOLVE then
				g_i3k_logic:OpenProductUI(nil,nil,2)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_NPC then
				local npcID = cfg.mapID
				local mapID = g_i3k_db.i3k_db_get_npc_map_id(npcID)
				i3k_sbean.transToNpc(mapID,npcID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_MAR then
				local data = g_i3k_game_context:GetMarriageTaskData()
				g_i3k_logic:OpenTaskUI(data.id,i3k_get_MrgTaskCategory())
			elseif cfg.typeNum == g_SCHEDULE_TYPE_ANSWER_QUE then
				if cfg.mapID == KE_JU then
				g_i3k_logic:OpenAnswerQuestionsUI()
				elseif cfg.mapID == HEGEMONY then
					i3k_sbean.five_hegemony_sync(g_HEGEMONY_PROTOCOL_STATE_SYNC)
				end
			elseif cfg.typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN then
				g_i3k_logic:OpenRightHeart()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_STELE then
				i3k_sbean.stele_sync_req_send()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_ANNUNCIATE then
				i3k_sbean.emergency_sync_req_send()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SECT_GRAB then
				g_i3k_logic:OpenFactionGrabBanner()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2 then
				if self:checkIsInDate(cfg) then --TODO 改为策划配置npcID
					g_i3k_game_context:GotoNpc(i3k_db_NpcDungeon[cfg.mapID].npcId)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
				end
			elseif cfg.typeNum == g_SCHEDULE_TYPE_TOWER_DEFENCE then
				if self:checkIsInDate(cfg) then
					g_i3k_game_context:GotoNpc(i3k_db_defend_cfg[cfg.mapID].NPCID)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
				end
			elseif cfg.typeNum == g_SCHEDULE_TYPE_Pray then
				g_i3k_game_context:GotoNpc(cfg.mapID) --此处是npcid
			elseif cfg.typeNum == g_SCHEDULE_TYPE_DEMONHOLE then
				g_i3k_logic:OpenDemonHoleUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_GLOBAL_PVE then
				g_i3k_logic:OpenGlobalPveUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_EXPTREE then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SECTFIGHT then
				g_i3k_logic:OpenSectFightUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_HAPPY_MATCH then
				g_i3k_game_context:GotoNpc(cfg.mapID) --此处是npcid
			elseif cfg.typeNum == g_SCHEDULE_TYPE_DRIFT_BOTTLE then
				g_i3k_logic:OpenDriftBottleUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_PET_RACE then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SPRING then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_FACTION_ZONE then
				g_i3k_game_context:GotoNpc(cfg.mapID) 
			elseif cfg.typeNum == g_SCHEDULE_TYPE_ROBBER_MONSTER then
				g_i3k_logic:OpenRobberMonsterUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_BREAK_SEAL then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_NEW_YEAR_RED then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SINGLE_CHALLENGE then
				local npcId = i3k_db_single_challenge_cfg[cfg.mapID] and i3k_db_single_challenge_cfg[cfg.mapID].npcId or 0
				g_i3k_game_context:GotoNpc(npcId)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_CHESS_TASK then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SPIRIT_BOSS then
				g_i3k_logic:OpenSpiritBossUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_PASS_EXAM_GIGT then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_FACTION_FAIRY then
				self:GotoFactionGarrison()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_PET_DUNGEON then
				self:GotoPetDungeon()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_DESERT then
				g_i3k_logic:OpenDesertUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_MZAE_BATTLE then
				g_i3k_logic:OpenMazeBattleActivityUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_LING_QIAN then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SHAKE_TREE then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_DIVINATION then 
				g_i3k_logic:OpenDivination()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_PRINCESSMARRY then 
				g_i3k_logic:OpenPrincessMarryActivityUI()				
			elseif cfg.typeNum == g_SCHEDULE_TYPE_MAGIC_MACHINE then
				g_i3k_logic:OpenMagicMachineActivityUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_FIVE_ELEMENTS then
				if self:checkIsInDate(cfg) then
					g_i3k_game_context:GotoNpc(cfg.enterNPC)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15417))
				end
			elseif cfg.typeNum == g_SCHEDULE_TYPE_DETECTIVE then
				g_i3k_game_context:GotoNpc(cfg.enterNPC)
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SWORDSMAN then
				g_i3k_logic:OpenSwordsmanCircle()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_LONGEVITY_PAVILION then
				g_i3k_logic:OpenLongevityPavilionActivityUI()
			elseif cfg.typeNum == g_SCHEDULE_TYPE_SPY_STORY then
				g_i3k_game_context:GotoNpc(cfg.mapID)
			end
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(673,cfg.transformLvl,cfg.name))
		end
	--end
end

function wnd_schedule:toTaoist()

	if not g_i3k_game_context:IsInRoom() then
		--协议
		g_i3k_logic:OpenTaoistUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(143))
	end
end

function wnd_schedule:onRightClick(sender)
	local tag = sender:getTag() - l_tag
	if tag == self.rightState then
		return
	else
		self.rightState = tag
		self:updateRightBtnState()
	end
end

function wnd_schedule:OpenRightLimitTimeAct()
	self.rightState = 2
	self:updateRightBtnState()
end

function wnd_schedule:OpenRightRecommendAct()
	self.rightState = 1
	self:updateRightBtnState()
end

function wnd_schedule:OpenRightDailyTask()
	self.rightState = 4
	self:updateRightBtnState()
end

function wnd_schedule:onRewardClick(sender)
	local tag = sender:getTag() - l_tag
	local allCell = g_i3k_game_context:GetBagSize()
	local useCell = g_i3k_game_context:GetBagUseCell()
	local restCell = allCell - useCell
	if self.rewardsState[tag] == REWARD_STATE_READY then
		if restCell >= i3k_db_schedule.actRewards[tag].bgFree then
			local data = i3k_sbean.schedule_mapreward_req.new()
			data.sid = tag
			i3k_game_send_str_cmd(data,i3k_sbean.schedule_mapreward_res.getName())
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(628))
		end
	end
end

function wnd_schedule:onTips(sender, eventType, data)
	if eventType==ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Tips)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule_Tips, data[1], data[2])
	elseif eventType==ccui.TouchEventType.moved then

	else
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
	end
end

function wnd_schedule:onItemClick(sender, info)
	-- body
	--local tag = sender:getTag() - l_tag
	--if self.scheduleCfg[self.rightState] then self.scheduleCfg[self.rightState][tag]
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Detail)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule_Detail,info)
	--end
end

function wnd_schedule:setSchedule(rewardsTag)
	-- body
	if rewardsTag then
		self.scheduleInfo.rewards[rewardsTag] = true
	end

	local boxAni = {}

	for k,v in ipairs(i3k_db_schedule.actRewards) do
		local  state = REWARD_STATE_NOT
		if self.scheduleInfo.activity >= v.actValue then
			state = REWARD_STATE_READY
			if self.scheduleInfo.rewards[k] then
				state = REWARD_STATE_FINISH
			end
		end
		self.rewardsState[k] = state
		local aniDetail
		if k == 1 then
			aniDetail = self._layout.anis.c_bx
		else
			aniDetail = self._layout.anis[string.format("c_bx%s",k)]
		end
		aniDetail.stop()
		table.insert( boxAni, aniDetail )
	end

	local scheduleType = SCHEDULE_TWO
	for i=1,(#self.rewardsState / 2)do
		if self.rewardsState[i] ~= REWARD_STATE_FINISH then
			scheduleType = SCHEDULE_ONE
			break
		end
	end

	local  widgets = self._layout.vars
	widgets.sche1Cont:setVisible(false)
	widgets.sche2Cont:setVisible(false)

	local startNum,endNum
	if scheduleType == SCHEDULE_ONE then
		startNum = 1
		endNum = #self.rewardsState / 2
	else
		startNum = #self.rewardsState / 2 + 1
		endNum = #self.rewardsState
	end

	local scheValue,findFlag = 0,false
	for i=startNum,endNum do
		widgets[string.format("reward_btn%s",i)]:setTag(i + l_tag)

		widgets[string.format("reward_btn%s",i)]:setTouchEnabled(true)
		if self.rewardsState[i] == REWARD_STATE_NOT then
			--i3k_log("not")
			widgets[string.format("reward_icon%s",i)]:setVisible(true)
			widgets[string.format("reward_btn%s",i)]:onTouchEvent(self, self.onTips, {i3k_db_schedule.actRewards[i], 1})
		elseif self.rewardsState[i] == REWARD_STATE_READY then
			--i3k_log("ready")
			widgets[string.format("reward_icon%s",i)]:setVisible(true)
			widgets[string.format("reward_btn%s",i)]:onClick(self,self.onRewardClick)
			boxAni[i].play()
		else
			--i3k_log("finishi")
			widgets[string.format("reward_icon%s",i)]:setVisible(false)
			widgets[string.format("reward_get_icon%s",i)]:setVisible(true)
			widgets[string.format("reward_btn%s",i)]:setTouchEnabled(false)
		end
		widgets[string.format("reward_txt%s",i)]:setText(i3k_db_schedule.actRewards[i].actValue)
		if self.rewardsState[i] == REWARD_STATE_NOT then
			widgets[string.format("reward_txt%s",i)]:setTextColor(NOT_SCHEDULE_COLOR)
			widgets[string.format("value_img%s",i)]:setImage(i3k_db.i3k_db_get_icon_path(NOT_SCHEDULE_TXT_ICON_ID))
		end


		if i3k_db_schedule.actRewards[i].actValue <= self.scheduleInfo.activity then
			scheValue = scheValue + 1 / (endNum - startNum + 1)
		elseif not findFlag then
			scheValue = scheValue + 1 / (endNum - startNum + 1) * (self.scheduleInfo.activity - (i3k_db_schedule.actRewards[i - 1] and i3k_db_schedule.actRewards[i - 1].actValue or 0 )) / (i3k_db_schedule.actRewards[i].actValue - (i3k_db_schedule.actRewards[i - 1] and i3k_db_schedule.actRewards[i - 1].actValue or 0 ))
			findFlag = true
		end
	end
	scheValue = scheValue * 100
	widgets[string.format("sche%sCont",scheduleType)]:setVisible(true)
 	widgets[string.format("schedule%s",scheduleType)]:setPercent(scheValue < 100 and scheValue or 100)
end

function wnd_schedule:getScheduleCfg()

	local heroLvl = g_i3k_game_context:GetLevel()
	local widgets = self._layout.vars

	local  marryFlag = (g_i3k_game_context:getRecordSteps() ~= -1) and l_married or l_unmarried

	for i=GROOM_STATE,TIME_STATE do
		local redFlag = 0
		self.scheduleCfg[i] = {}
		local  i3k_db_schedule_clone = i3k_clone(i3k_db_schedule)
		local totalDay = g_i3k_get_day(i3k_game_get_time())
		local week = math.mod(g_i3k_get_week(totalDay), 7)

		for _,v in ipairs(i3k_db_schedule_clone.cfg) do
			if v.groupID == i and heroLvl >= v.lvlLimit and marryFlag >= v.marryFlag then
				if week == 1 then
					table.sort( v.actDay, function (a,b)
						return a < b
					end )
				end
				local justiceHeartMapID = i3k_db_common.wipe.justiceHeartMapID
				if v.typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2 then
				for key, val in ipairs(justiceHeartMapID) do
					if (v.mapID == val) then
						v.actDay = g_i3k_db.i3k_db_get_justiceHeart_info(v.mapID)
						end
					end
				end
				for _,e in ipairs(v.actDay) do
					if e == week or (e + 1 == week) or (e == 6 and week == 0) then
						v.isTime,v.timeStr = self:checkTime(v.actTime,e,week)
						if v.isTime or e == week then
							v.finishTimes = 0
							v.canEnterTimes = v.canActNum
							v.finishFlag = false
							if v.typeNum == SCHEDULE_ACT_TYPE then
								v.finishTimes = g_i3k_game_context:getActivityDayEnterTime(v.mapID) and g_i3k_game_context:getActivityDayEnterTime(v.mapID) or 0
								v.canEnterTimes = v.canEnterTimes + g_i3k_game_context:getActDayBuyTimes(v.mapID)
							elseif v.typeNum == SCHEDULE_DUNGENON_GROUP_TYPE or v.typeNum == SCHEDULE_DUNGENON_COMMON_TYPE or v.typeNum == SCHEDULE_DUNGENON_HARD_TYPE then
								v.finishTimes = g_i3k_game_context:getDungeonDayEnterTimes(v.mapID)
								if v.typeNum == SCHEDULE_DUNGENON_GROUP_TYPE and v.finishTimes > v.canActNum then
									v.finishTimes = v.canActNum
								end
								v.canEnterTimes = v.canEnterTimes + g_i3k_game_context:GetNormalMapDayBuyTimes(v.mapID)
							elseif v.typeNum == SCHEDULE_RIGHTHEART_TYPE then
								v.finishTimes = g_i3k_game_context:getRightHeartEnterTimes()
								v.finishTimes = v.finishTimes > v.canActNum and v.canActNum or v.finishTimes
							elseif v.typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2 then
								v.finishTimes = g_i3k_game_context:getNpcDungeonEnterTimes(v.mapID)
								v.finishTimes = v.finishTimes > v.canActNum and v.canActNum or v.finishTimes
							elseif v.typeNum == g_SCHEDULE_TYPE_TOWER_DEFENCE then
								v.finishTimes = g_i3k_game_context:getTowerDefenceDayEnterTimes(v.mapID)
								v.finishTimes = v.finishTimes > v.canActNum and v.canActNum or v.finishTimes
							elseif v.typeNum == g_SCHEDULE_TYPE_DRIFT_BOTTLE then
								v.finishTimes = g_i3k_game_context:getDriftBottleTimes()
								v.finishTimes = v.finishTimes > v.canActNum and v.canActNum or v.finishTimes
							elseif v.typeNum == g_SCHEDULE_TYPE_SINGLE_CHALLENGE or v.typeNum == g_SCHEDULE_TYPE_FIVE_ELEMENTS then --单人闯关
								local times = self.scheduleInfo.task2num[v.typeNum * 65536 + v.mapID] or 0
								v.finishTimes = times > v.canActNum and v.canActNum or times
							elseif v.typeNum == g_SCHEDULE_TYPE_CHESS_TASK then
								local times = g_i3k_game_context:getChessTaskFinishTimes()
								v.finishTimes = times > v.canActNum and v.canActNum or times
							elseif v.typeNum == g_SCHEDULE_TYPE_PASS_EXAM_GIGT then --登科有礼
								local times = self.scheduleInfo.task2num[v.typeNum * 65536 + v.mapID] or 0
								v.finishTimes = times > v.canActNum and v.canActNum or times
							elseif v.typeNum == g_SCHEDULE_TYPE_DETECTIVE then --登科有礼
								local times = self.scheduleInfo.task2num[v.typeNum * 65536 + v.mapID] or 0
								v.finishTimes = times > v.canActNum and v.canActNum or times
							elseif v.typeNum == g_SCHEDULE_TYPE_SPY_STORY then
								local times = self.scheduleInfo.task2num[v.typeNum * 65536 + v.mapID] or 0
								v.finishTimes = times > v.canActNum and v.canActNum or times
							else
								v.finishTimes = self.scheduleInfo.task2num[v.typeNum * 65536 + v.mapID] or 0
							end

							if not v.isTime then
								v.timeStr = self:getNearTimeStr(v.actTime)
							else
								if v.finishTimes >= v.canEnterTimes and v.canEnterTimes ~= -1 then
									v.finishFlag = true
								else
									redFlag = redFlag + 1
								end
							end
							if not v.timeStr then
								v.hasEnd = true
							end

							if self:checkIsMillsionAnswer(v) and self:checkIsInDate(v) and self:checkIsBanpaizhan(v) then
								if i == GROOM_STATE then
									if v.lastlvl == 0 or v.lastlvl > heroLvl then
										table.insert(self.scheduleCfg[i], v)
									end
								else
									table.insert(self.scheduleCfg[i], v)
								end
							end
							break
						end
					end
				end
			end
		end

		if i == TIME_STATE and redFlag ~= 0 then
			widgets[string.format("red_img%s",i)]:setVisible(true)
		else
			widgets[string.format("red_img%s",i)]:setVisible(false)
		end

		local function sortF1( a,b )
			-- body
			if a.typeNum ~= b.typeNum then
				return a.typeNum < b.typeNum
			else
				return a.lvlLimit < b.lvlLimit
			end
		end
		table.sort( self.scheduleCfg[i], sortF1)

		for k,v in ipairs(self.scheduleCfg[i]) do
			if v.typeNum == SCHEDULE_DUNGENON_GROUP_TYPE then --组队本
				-- if not self.scheduleCfg[i][k + 1] or (self.scheduleCfg[i][k + 1] and self.scheduleCfg[i][k + 1].typeNum ~= v.typeNum) or not self.scheduleCfg[i][k + 2]
				-- 	or (self.scheduleCfg[i][k + 2] and self.scheduleCfg[i][k + 2].typeNum ~= v.typeNum ) then
				if not self.scheduleCfg[i][k + 1] or (self.scheduleCfg[i][k + 1] and self.scheduleCfg[i][k + 1].typeNum ~= v.typeNum)  then
					v.groomLvl = GROUP_BEST_GROOM --3
				end
			elseif v.typeNum == SCHEDULE_DUNGENON_COMMON_TYPE then -- 普通本
				if (self.scheduleCfg[i][k + 1] and self.scheduleCfg[i][k + 1].typeNum ~= v.typeNum) or not self.scheduleCfg[i][k + 1] then
					v.groomLvl = COMMON_BEST_GROOM --3 
				end
			elseif v.typeNum == SCHEDULE_DUNGENON_HARD_TYPE then -- 困难本
				if not self.scheduleCfg[i][k + 1] or (self.scheduleCfg[i][k + 1] and self.scheduleCfg[i][k + 1].typeNum ~= v.typeNum) then
					v.groomLvl = HARD_BEST_GROOM --3 
				end
			end
		end

		local function sortF2(a,b)
			-- body
			if a.finishFlag ~= b.finishFlag then
				return not a.finishFlag
			else
				if a.hasEnd ~= b.hasEnd then
					return not  a.hasEnd
				elseif a.groomLvl ~= b.groomLvl then
					return a.groomLvl > b.groomLvl
				else
					if a.typeNum ~= b.typeNum then
						return a.typeNum < b.typeNum
					else
						if a.id ~= b.id then
							return a.id > b.id
						end
					end
				end
			end
			return false
		end
		table.sort(self.scheduleCfg[i],sortF2)
	end
end

function wnd_schedule:checkTime(timeStr, cfgDay, day)
	local timeNow = i3k_game_get_time()
	local dateTab = os.date("*t",g_i3k_get_GMTtime(i3k_game_get_time()))
	local todaySec = dateTab.hour * 60 * 60 + dateTab.min * 60 + dateTab.sec

	local formatStr = ""
	local checkFlag = false
	if timeStr == "-1.0" then
		formatStr = i3k_get_string(621)
		if cfgDay == day  and todaySec >= (5 * 60 * 60) then
			checkFlag = true
		elseif (cfgDay + 1 == day or (cfgDay == 6 and day == 0)) and ( todaySec < 5 * 60 * 60) then
			checkFlag = true
		end
	else
		local timeStrTab = string.split(timeStr,";")
		for i=1,#timeStrTab,2 do
			local startTimeNumTab = string.split(timeStrTab[i], ":")
			local endTimeNumTab = string.split(timeStrTab[i+1], ":")
			local startSec = tonumber(startTimeNumTab[1]) * 60 * 60 + tonumber(startTimeNumTab[2]) * 60 + tonumber(startTimeNumTab[3])
			local endSec = tonumber(endTimeNumTab[1]) * 60 * 60 + tonumber(endTimeNumTab[2]) * 60 + tonumber(endTimeNumTab[3])

			formatStr = string.sub(timeStrTab[i],1,5).."~"..string.sub(timeStrTab[i+1],1,5)

			if cfgDay == day and startSec <= todaySec and ( startSec >= endSec or todaySec < endSec) then
				checkFlag = true
				break
			elseif (cfgDay + 1 == day or (cfgDay == 6 and day == 0)) and (startSec >= endSec and todaySec < endSec) then
				checkFlag = true
				break
			end
		end
	end
	return checkFlag,formatStr
end

function wnd_schedule:getNearTimeStr(timeStr)
	-- body
	if timeStr == "-1.0" then
		return i3k_get_string(621)
	else
		local formatStr
		local secRange = 0
		local timeStrTab = string.split(timeStr,";")
		local timeNow = i3k_game_get_time()
		local dateTab = os.date("*t",i3k_game_get_time() - 8 * 60 * 60)
		local secNow = dateTab.hour * 60 * 60 + dateTab.min * 60 + dateTab.sec
		local secStartTab = {}

		for i=1,#timeStrTab,2 do
			local startTimeNumTab = string.split(timeStrTab[i], ":")
			local secStart = tonumber(startTimeNumTab[1]) * 60 * 60 +  tonumber(startTimeNumTab[2]) * 60 + tonumber(startTimeNumTab[3])
			local secRange = secStart - secNow
			if secRange >= 0 then
				formatStr = string.sub(timeStrTab[i],1,5).."~"..string.sub(timeStrTab[i + 1],1,5)
				break
			end
		end
		return formatStr
	end
end

function wnd_schedule:checkIsInDate(cfg)
	if cfg.openDate  and cfg.closeDate then
		return g_i3k_checkIsInDate(cfg.openDate, cfg.closeDate)
	end
	return true
end

--检测当天是否开启，科举，五绝争霸
function wnd_schedule:checkIsMillsionAnswer(cfg)
	if cfg.typeNum == g_SCHEDULE_TYPE_ANSWER_QUE  then
		if cfg.mapID == HEGEMONY then
			if g_i3k_db.i3k_db_get_millions_answer_is_open() or g_i3k_db.i3k_db_get_open_answer_type() == g_ANSWER_TYPE_KEJU then
				return false
			end
		elseif cfg.typeNum == KE_JU then
			if g_i3k_db.i3k_db_get_millions_answer_is_open() or g_i3k_db.i3k_db_get_open_answer_type() == g_ANSWER_TYPE_HEGEMONY then
		return false
			end
		end
	end
	return true
end
--检测当天是否开启帮派战，开启如果不是本周则关闭
function wnd_schedule:checkIsBanpaizhan(cfg)
	if cfg.typeNum ~= g_SCHEDULE_TYPE_SECTFIGHT then return true 
    elseif g_i3k_db.i3k_db_is_open_bangpaizhan() then return true
	else return false end	
end
--日常start--------------------------------------------------------------
function wnd_schedule:gotoDaily()
	i3k_sbean.sync_dtask_info()
end

function wnd_schedule:clearScorll()
	self.rcbUI:hide()
	self.weekUi:hide()
	self.DailyUi:show()
	self.tital:setImage(i3k_db_icons[l_TabName[1]].path)
	self.scroll:removeAllChildren()
	local width = self.scroll:getContainerSize().width
	self.scroll:setContainerSize(width, 0)
end


function wnd_schedule:reloadTask(tasks)
	local takeIDList = {}								--可领取日常任务的ID列表
	local canTakeNum = 0
	local remainTaskNum = 0
	local dailyTasks = {}
	for i, v in pairs(tasks) do
		local task = {}
		task.id = v.id
		task.times= v.times
		task.canreward = 0
		if task.id ~= 21 or i3k_is_longtu_channel() then
			table.insert(dailyTasks, task)
		end
	end
	local count = #dailyTasks
	if count==0 then
		self.red_img4:hide()
		self.showNone:show()
		local str = i3k_get_string(18081)
		self.desa:setText(str)
		g_i3k_game_context:ClearDailyUINotice(g_NOTICE_TYPE_CAN_REWARD_DAILY_TASK)
	else
		self.showNone:hide()
		local showdailyTasks = self:setDailyTaskSort(dailyTasks)
		self.notice = false
		for i,v in pairs(showdailyTasks) do--根据排序id排一下之后再添加
			local rch = require(l_pItem)()

			local task = i3k_db_dailyTask[v.id]
			rch.vars.taskIcon:setImage(i3k_db_icons[task.iconId].path)
			rch.vars.taskName:setText(task.name)

			if task.exp==0 then
				self:DailyTaskRewardNoExp(rch,task)
			else
				rch.vars.image1:show()
				rch.vars.count1:show()
				rch.vars.lock1:hide()
				rch.vars.icon1:setImage(g_i3k_db.i3k_db_get_icon_path(l_sExpTab[1]))
				local hero = i3k_game_get_player_hero()
				local expCount = i3k_db_exp[hero._lvl].dailyTaskExp
				rch.vars.count1:setText("x"..expCount * task.exp)
				self:DailyTaskRewardExp(rch,task)

			end

			local id = 0
			if v.id==6 or v.id==7 or v.id==8 then
				rch.vars.btn:hide()
				id = self:loadStrength(v, rch, i)
			else
				id = self:commonTask(v, rch, i)
			end
			if id then
				takeIDList[id] = true
			end
			if v.canreward == 1 then
				self.notice = true
			end
		end
		for k, v in pairs(takeIDList) do
			canTakeNum = canTakeNum + 1
		end
		remainTaskNum = #dailyTasks - canTakeNum
		local str = i3k_get_string(18080, canTakeNum, remainTaskNum)
		self.desa:setText(str)
		self.red_img4:setVisible(self.notice)
		if not self.notice then
			g_i3k_game_context:ClearDailyUINotice(g_NOTICE_TYPE_CAN_REWARD_DAILY_TASK)
		end
	end

	if canTakeNum > 0 then
		self.batchBtn:show()
		self.batchBtn:onClick(self, self.batchReward, {index = index, taskIds = takeIDList})
	else
		self.batchBtn:hide()
	end
end
function wnd_schedule:setDailyTaskSort(showdailyTasks)
	local dailyTask = i3k_db_dailyTask
	local timeNow = i3k_game_get_time()
	for i,v in pairs(showdailyTasks) do
		local openTime = g_i3k_get_day_time(dailyTask[v.id].startTime)
		local closeTime = g_i3k_get_day_time(dailyTask[v.id].endTime)
		if v.id==6 or v.id==7 or v.id==8 then--强化

			v.canreward = timeNow >= openTime and timeNow < closeTime and 1 or 0
		else
			v.canreward = v.times >= dailyTask[v.id].targetTime and 1 or 0--普通
		end

	end
	table.sort(showdailyTasks, function(a, b)
		local sortIdA = i3k_db_dailyTask[a.id].sortId
		local sortIdB = i3k_db_dailyTask[b.id].sortId

		return a.canreward * 100 + (100-sortIdA) > b.canreward * 100 + (100-sortIdB)
	end)
	return showdailyTasks
end

function wnd_schedule:DailyTaskRewardNoExp(rch,task)
	if task.itemId1~=0 then
		rch.vars.image1:show()
		rch.vars.count1:show()
		rch.vars.lock1:setVisible(g_i3k_common_item_has_binding_icon(task.itemId1))
		local item1 = g_i3k_db.i3k_db_get_common_item_cfg(task.itemId1)
		local grade = item1.rank
		rch.vars.image1:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
		rch.vars.icon1:setImage(i3k_db_icons[item1.icon].path)
		rch.vars.count1:setText("x"..task.itemCount1)
		rch.vars.tips1:setTouchEnabled(true)
		rch.vars.tips1:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(item1.id)
		end)
	else
		rch.vars.image1:hide()
		rch.vars.count1:hide()
		rch.vars.tips1:setTouchEnabled(false)
	end


	if task.itemId2~=0 then
		rch.vars.image2:show()
		rch.vars.count2:show()
		rch.vars.lock2:setVisible(g_i3k_common_item_has_binding_icon(task.itemId2))
		local item2 = g_i3k_db.i3k_db_get_common_item_cfg(task.itemId2)
		local grade = item2.rank
		rch.vars.image2:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
		rch.vars.icon2:setImage(i3k_db_icons[item2.icon].path)
		rch.vars.count2:setText("x"..task.itemCount2)
		rch.vars.tips2:setTouchEnabled(true)
		rch.vars.tips2:onClick(self, function ()
 			g_i3k_ui_mgr:ShowCommonItemInfo(item2.id)
		end)
	else
		rch.vars.image2:hide()
		rch.vars.count2:hide()
		rch.vars.tips2:setTouchEnabled(false)
	end


	if task.itemId3~=0 then
		rch.vars.image3:show()
		rch.vars.count3:show()
		rch.vars.lock3:setVisible(g_i3k_common_item_has_binding_icon(task.itemId3))
		local item3 = g_i3k_db.i3k_db_get_common_item_cfg(task.itemId3)
		local grade = item3.rank
		rch.vars.image3:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
		rch.vars.icon3:setImage(i3k_db_icons[item3.icon].path)
		rch.vars.count3:setText("x"..task.itemCount3)
		rch.vars.tips3:setTouchEnabled(true)
		rch.vars.tips3:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(item3.id)
		end)
	else
		rch.vars.count3:hide()
		rch.vars.image3:hide()
		rch.vars.tips3:setTouchEnabled(false)
	end

end
function wnd_schedule:DailyTaskRewardExp(rch,task)
	if task.itemId1~=0 then
		rch.vars.image2:show()
		rch.vars.count2:show()
		rch.vars.lock2:setVisible(g_i3k_common_item_has_binding_icon(task.itemId1))
		local item2 = g_i3k_db.i3k_db_get_common_item_cfg(task.itemId1)
		local grade = item2.rank
		rch.vars.image2:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
		rch.vars.icon2:setImage(i3k_db_icons[item2.icon].path)
		rch.vars.count2:setText("x"..task.itemCount1)
		rch.vars.tips2:setTouchEnabled(true)
		rch.vars.tips2:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(item2.id)
		end)
	else
		rch.vars.image2:hide()
		rch.vars.count2:hide()
		rch.vars.tips2:setTouchEnabled(false)
	end


	if task.itemId2~=0 then
		rch.vars.image3:show()
		rch.vars.count3:show()
		rch.vars.lock3:setVisible(g_i3k_common_item_has_binding_icon(task.itemId2))
		local item3 = g_i3k_db.i3k_db_get_common_item_cfg(task.itemId2)
		local grade = item3.rank
		rch.vars.image3:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
		rch.vars.icon3:setImage(i3k_db_icons[item3.icon].path)
		rch.vars.count3:setText("x"..task.itemCount2)
		rch.vars.tips3:setTouchEnabled(true)
		rch.vars.tips3:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(item3.id)
		end)
	else
		rch.vars.image3:hide()
		rch.vars.count3:hide()
		rch.vars.tips3:setTouchEnabled(false)
	end

end

function wnd_schedule:loadStrength(theTask, node, index)
	local taskName = node.vars.taskName
	local condition = node.vars.condition
	local rewardLabel = node.vars.rewardLabel
	local complete = node.vars.complete
	local noFinish = node.vars.noFinish

	local takeBtn = node.vars.take
	takeBtn:show()

	local id
	local task = i3k_db_dailyTask[theTask.id]

	local timeNow = i3k_game_get_time()
	local openTime = g_i3k_get_day_time(task.startTime)
	local closeTime = g_i3k_get_day_time(task.endTime)

	if timeNow>=openTime and timeNow<closeTime then
		condition:setText(task.desc)

		noFinish:hide()
		complete:show()
		takeBtn:enable()
		takeBtn:onClick(self, self.takeReward, {index = index, taskId = task.id})
		id = theTask.id
	else
		condition:setText(task.desc)

		noFinish:show()
		complete:hide()
		takeBtn:disable()
		id = nil
	end
	self.scroll:addItem(node)
	return id
end

function wnd_schedule:commonTask(theTask, node, index)
	local taskName = node.vars.taskName
	local condition = node.vars.condition
	local rewardLabel = node.vars.rewardLabel
	local goBtn = node.vars.btn
	local takeBtn = node.vars.take
	local complete = node.vars.complete
	local noFinish = node.vars.noFinish

	local id 
	local task = i3k_db_dailyTask[theTask.id]
	if theTask.times>=task.targetTime then
		condition:setText(task.desc.."("..theTask.times.."/"..task.targetTime..")")

		noFinish:hide()
		complete:show()
		takeBtn:show()
		goBtn:hide()
		takeBtn:onClick(self, self.takeReward, {index = index, taskId = task.id})
		id = theTask.id;
	else
		condition:setText(task.desc.."("..theTask.times.."/"..task.targetTime..")")

		noFinish:show()
		complete:hide()
		takeBtn:hide()
		goBtn:show()
		goBtn:onClick(self, self.gotoTask, task.id)
		id = nil
	end
	self.scroll:addItem(node)
	return id
end

function wnd_schedule:itemTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--立即前往
function wnd_schedule:gotoTask(sender, taskId)
	if gotoDailyTask[taskId] then
		gotoDailyTask[taskId]()
	end
end

function wnd_schedule:takeReward(sender, args)
	local index = args.index
	local tid = args.taskId
	-- i3k_log("tag = "..tag)
	local gifts = {}
	local index = 1
	local task = i3k_db_dailyTask[tid]

	local hero = i3k_game_get_player_hero()
	local expCount = i3k_db_exp[hero._lvl].dailyTaskExp
	if task then
		local isEnoughTable  = {}
		if  task.exp ~=0 then
			local expText = expCount * task.exp
			isEnoughTable = {[g_BASE_ITEM_EXP] = expText, [task.itemId1] = task.itemCount1, [task.itemId2] = task.itemCount2, [task.itemId3] = task.itemCount3}
		else
			isEnoughTable= {[task.itemId1] = task.itemCount1, [task.itemId2] = task.itemCount2, [task.itemId3] = task.itemCount3}
		end
		local isenough = g_i3k_game_context:IsBagEnough(isEnoughTable)
		for i,v in pairs (isEnoughTable) do
			if i ~= 0 then
				gifts[index] = {id = i,count = v}
				index = index + 1
			end

		end
		if isenough then
			i3k_sbean.take_dtask_reward(tid, index,gifts)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
		end
	end
end

function wnd_schedule:takeRewardUpdate(index)
	self:clearScorll()
	i3k_sbean.sync_dtask_info()
end

function wnd_schedule:batchReward(sender, args)
	local tids = args.taskIds               --所有任务ID列表
	local isEnoughTable = {}				--所有任务的奖励汇总
	local isEnoughTable_b = {}
	local can_isEnoughTable = {}
	local can_ids = {}
	local gifts = {}
	local hero = i3k_game_get_player_hero()
	local expCount = i3k_db_exp[hero._lvl].dailyTaskExp
	for tid, _ in pairs(tids) do						--遍历可领取的任务ID
		local task = i3k_db_dailyTask[tid]						--拿到ID对应任务数据
		local taskGifts = {}
		if task.exp ~= 0 then
			local expText = expCount * task.exp
			taskGifts = {[g_BASE_ITEM_EXP] = expText, [task.itemId1] = task.itemCount1, [task.itemId2] = task.itemCount2, [task.itemId3] = task.itemCount3}
		else
			taskGifts = {[task.itemId1] = task.itemCount1, [task.itemId2] = task.itemCount2, [task.itemId3] = task.itemCount3}
		end
		--这里要把任务奖励做一个合并加法
		for k,v in pairs(taskGifts) do
			if isEnoughTable[k] then
				isEnoughTable[k] = isEnoughTable[k] + taskGifts[k]
			else
				isEnoughTable[k] = taskGifts[k]
			end
		end
		can_isEnoughTable = isEnoughTable
		local isBagEnough = g_i3k_game_context:IsBagEnough(can_isEnoughTable)
		if isBagEnough then
			--如果可以放进背包，将列表b赋值
			can_ids[tid] = true
			for k,v in pairs(taskGifts) do
				if isEnoughTable_b[k] then
					isEnoughTable_b[k] = isEnoughTable_b[k] + taskGifts[k]
				else
					isEnoughTable_b[k] = taskGifts[k]
				end
			end
		else
			can_isEnoughTable = isEnoughTable_b
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
			break
		end
	end
	--至此 所有可领取奖励的任务奖励已经统计完毕
	for i,v in pairs (can_isEnoughTable) do
		if i ~= 0 then
			table.insert(gifts, {id = i,count = v}) 
		end
	end
	if next(can_ids) ~= nil then
		i3k_sbean.batch_dtask_reward(can_ids, gifts)
	end
end
--日常end---------------------------------------------------------------

----周常

function wnd_schedule:gotoWeak()
	i3k_sbean.week_task_syncReq()
end

function wnd_schedule:clearWeekScorll()
	self.scroll:removeAllChildren()
	local width = self.scroll:getContainerSize().width
	self.scroll:setContainerSize(width, 0)
end

function wnd_schedule:reloadWeekTask(tasks, reward, score, data, gbOpenTime)
	self.weekUi:show()
	for k, v in pairs(gbOpenTime) do
		table.insert(self._gbOpenTime, k)
	end
	local widgets = self._layout.vars
	local taskCfg = i3k_db_weekTask.task
	local rewardsCfg = i3k_db_weekTask.rewards
	local scroll = widgets.sch_list2
	widgets.schedule3:setPercent( ( score / rewardsCfg[#rewardsCfg].needPoints * 100) )
	widgets.act_txt2:setText(score)

	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)
	local haveRed = false
	-- local index = 0
	for i,v in pairs(tasks) do--根据排序id排一下之后再添加
		local node = require("ui/widgets/zhouchangt")()
		
		local widgets = node.vars
		local cfg = taskCfg[v.id]
		widgets.taskIcon:setImage(i3k_db_icons[cfg.iconId].path)
		widgets.taskName:setText(cfg.name)
		widgets.rewardLabel:setText(string.format("积分：%d", cfg.points))
		widgets.condition:setText(cfg.desc)
		if v.id == 206 then
			widgets.targetTxt:setText(string.format("进度：%s", data.curWeekMaxPower.."/".. data.lastWeekMaxPower))
		else
			widgets.targetTxt:setText(string.format("进度：%s", v.times.."/".. cfg.targetTime))
		end
		
		widgets.takeBtn:hide()
		widgets.goBtn:hide()
		widgets.noFinish:hide()
		widgets.complete:hide()
		if v.times < cfg.targetTime then
			widgets.noFinish:show()
			widgets.goBtn:show():onClick(self, self.gotoWeekTask, v.id)
			scroll:addItem(node)
		elseif v.rewards > 0 then
			widgets.noFinish:show()
			widgets.goLabel2:setText("已领取")
			widgets.takeBtn:disable()
			scroll:addItem(node)
		else
			-- if index == 0 then
			-- 	index = i
			-- end
			widgets.complete:show()
			haveRed = true
			widgets.takeBtn:show():onClick(self, self.takeWeekTask, v.id)
			scroll:insertChildToIndex(node,1)
		end
	end
	-- if index ~= 0 then
	-- 	scroll:jumpToChildWithIndex(index+1)
	-- end

	for i , v in ipairs(rewardsCfg) do
		local node = self.weekTaskWidgets[i]
		node.valueTxt:setText(v.needPoints)
		node.closeIcon:show()
		node.openIcon:hide()
		if score >= v.needPoints and not reward[v.needPoints] then
			node.btn:onClick(self, self.takeWeekReward, v)
			node.ani:play()
			haveRed = true
		elseif reward[v.needPoints] then
			node.closeIcon:hide()
			node.openIcon:show()
			node.btn:hide()
			node.ani:stop()
		else
			node.btn:onTouchEvent(self, self.onTips, {v, 2})
			node.ani:stop()
		end
	end
	self.red_img3:setVisible(haveRed)
	if not haveRed then
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_REWARD_WEEK_TASK)
	end
end

--立即前往
function wnd_schedule:gotoWeekTask(sender, taskId)
	if gotoWeeklyTask[taskId] then
		gotoWeeklyTask[taskId]()
	end
end

function wnd_schedule:takeWeekTask(sender, taskId)
	i3k_sbean.week_task_finishReq(taskId)
end

function wnd_schedule:takeWeekReward(sender, cfg)

	local allCell = g_i3k_game_context:GetBagSize()
	local useCell = g_i3k_game_context:GetBagUseCell()
	local restCell = allCell - useCell
	
	if restCell >= cfg.bgFree then
		i3k_sbean.week_task_score_reward_takeReq(cfg.needPoints)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(628))
	end
end

function wnd_schedule:gotoActivity()
	local activityTb = {
		{openDay = i3k_db_maze_battle.openWeekDay, openTimes = i3k_db_maze_battle.openTime, gotfunc = g_i3k_logic.OpenMazeBattleActivityUI},
		{openDay = self._gbOpenTime, openTimes = i3k_db_spirit_boss.common.openTime, gotfunc = g_i3k_logic.OpenSpiritBossUI},
		{openDay = i3k_db_desert_battle_base.openWeekDay, openTimes = i3k_db_desert_battle_base.openTime, gotfunc = g_i3k_logic.OpenDesertUI},
		{openDay = i3k_db_princess_marry.openWeekDay, openTimes = i3k_db_princess_marry.openTime, gotfunc = g_i3k_logic.OpenPrincessMarryActivityUI},
	}
	for _, e in ipairs(activityTb) do
		if g_i3k_db.i3k_get_activity_is_open(e.openDay) and g_i3k_db.i3k_db_get_activity_max_time(e.openTimes) > 0 then
			return e.gotfunc(g_i3k_logic)
		end
	end

		g_i3k_ui_mgr:PopupTipMessage("不在副本开启时间内")
end

-- 驻地精灵
function wnd_schedule:GotoFactionGarrison()
	if g_i3k_game_context:GetFactionSectId() <= 0 then
		return g_i3k_logic:OpenFactionUI()
	end

	g_i3k_logic:OnOpenFactionZone(true)
end

-- 宠物试炼
function wnd_schedule:GotoPetDungeon()
	g_i3k_logic:OpenPetDungeonActivityUI()
end

function wnd_create(layout,...)
	local wnd = wnd_schedule.new();
		wnd:create(layout,...)
	return wnd;
end
