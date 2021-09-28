module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_timingActivity = i3k_class("wnd_timingActivity", ui.wnd_base)

local DQHD_PATH = "ui/widgets/dingqihuodongt"
local CHANGE = "ui/widgets/dingqihuodongt2"
local DESCWIDGET = "ui/widgets/hufuzht2"

local SELECT_FONT_COLOR = "ffbc541e"--cc.c4b(63,15,96,255)--选中标签的字体颜色
local UNSELECT_FONT_COLOR = "ffc4a279"--cc.c4b(223,221,255,255)--没选中标签的字体颜色
local SELECT_FONT_OUTLINE_COLOR = "fffdf2ba"--选中标签字体描边颜色
local UNSELECT_FONT_OUTLINE_COLOR = "ff653919"--没选中的标签字体的描边颜色
local l_tag = 1000

local REWARD_STATE_NOT = 0
local REWARD_STATE_READY = 1
local REWARD_STATE_FINISH = 2

local SCHEDULE_ONE = 1
local SCHEDULE_TWO = 2

local ACTIVITY_STATE = 1
local EXCHANGE_STATE = 2
local PRAY_STATE = 3 --祈愿
local RETURN_STATE = 4 --还愿

local CAN_SCHEDULE_COLOR = "ff094020"
local NOT_SCHEDULE_COLOR = "fff8eba3"

local CAN_VALUE_ICO = 7405
local NOT_VALUE_ICO = 7406

local REWARDS_COUNT_ONE = 5
local REWARDS_COUNT_TWO = 10

local ALIGNMENT_LEFT = 1   --左对齐
local ALIGNMENT_CENTER = 2 --居中对齐

--跳转列表
local gototimingactivity = {
	[1] = function()
		g_i3k_logic:OpenDungeonUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[2] = function()
		g_i3k_logic:OpenDungeonUI()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "onZuduiBtnClick")
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
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
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[4] = function()
		--i3k_log("竞技场")
		g_i3k_logic:OpenArenaUI(function()
			g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
		end)
	end,
	[5] = function()
		--月卡功能
		local fun = (function()
			--g_i3k_logic:OpenDailyTask(1)
			g_i3k_ui_mgr:OpenUI(eUIID_TimingActivity)
			g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivity)
		end)
		g_i3k_logic:OpenChannelPayUI(fun)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
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
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
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
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[11] = function()
		--i3k_log("买金币")
		--i3k_log("--OpenUI = -------")----
		local fun = (function()
			g_i3k_ui_mgr:OpenUI(eUIID_TimingActivity)
			g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivity)  --状态4为日常按钮
		end)
		g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyCoin, "backDailyUiSign" ,fun)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[12] = function(cfg)
		--i3k_log("困难副本")
		g_i3k_logic:OpenDungeonUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[13] = function()
		--i3k_log("任意副本")
		g_i3k_logic:OpenDungeonUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[14] = function()
		--i3k_log("活动介面 任意日常活动2")
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,

	[15] = function()
		g_i3k_logic:OpenHostelUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
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
							g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
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
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[18] = function()
		--参与会武副本
		g_i3k_logic:OpenTournamentUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[19] = function()
		--参与五绝试炼
		g_i3k_logic:OpenFiveUniqueUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[20] = function()
		--好友ui
		g_i3k_logic:OpenMyFriendsUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
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
		g_i3k_logic:OpenDemonHoleUI()
	end,
	[24] = function()
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Schedule, "OpenRightLimitTimeAct")
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[25] = function()
		g_i3k_logic:OpenSpiritBossUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[201] = function()
		--活动推荐
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule,1)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[202] = function()
		g_i3k_logic:OpenVipStoreUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[203] = function()
		--参与会武副本
		g_i3k_logic:OpenTournamentUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[204] = function()
		g_i3k_logic:OpenSectFightUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[205] = function()
		--i3k_log("竞技场")
		g_i3k_logic:OpenArenaUI(function()
			g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
		end)
	end,

    [206] = function()
		--强化
		g_i3k_logic:OpenStrengEquipUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[207] = function()
		--完成日常任务
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule,4)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[301] = function()
			--i3k_log("帮派任务")
			local fun1 = function ()
				local data = i3k_sbean.sect_task_sync_req.new()
				i3k_game_send_str_cmd(data,i3k_sbean.sect_task_sync_res.getName())
			end
			local data = i3k_sbean.sect_sync_req.new()
			data.callBack = fun1
			i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
			g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
		end,

	[302] = function()
		--好友ui
	    i3k_sbean.plusListFriend()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	
	[305] = function()
		--精灵旅行
		g_i3k_logic:OpenWizardUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[306] = function()
		--访问好友家园
		g_i3k_logic:OpenMyFriendsUI()
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[307] = function(arg)
		--拼诗句
		--[[local cfg = g_i3k_db.i3k_db_get_main_task_cfg(1)--]]
		g_i3k_ui_mgr:OpenUI(eUIID_ChessTaskVerse)
		g_i3k_ui_mgr:RefreshUI(eUIID_ChessTaskVerse, arg, g_TASK_VERSE_STATE_REGULAR, 307)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[308] = function(npcid)
		if npcid == 0 then return end
		local isOpen = g_i3k_db.i3k_db_is_spring_festival_npc_time()
		if not isOpen then return end
		g_i3k_game_context:GotoNpc(npcid)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end,
	[309] = function(npcid)
		if npcid == 0 then return end
		local isOpen = g_i3k_db.i3k_db_get_shake_tree_activityID
		if not isOpen then return end
		g_i3k_game_context:GotoNpc(npcid)
		g_i3k_ui_mgr:CloseUI(eUIID_TimingActivity)
	end
}

function wnd_timingActivity:ctor()
	--self.rightBtn = {}
	self.rightState = 1
	self.rewardsState = {}
end

function wnd_timingActivity:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.help:onClick(self, self.onActivityHelp)
	widgets.groom_btn:onClick(self, self.onRightClick, ACTIVITY_STATE)
	widgets.time_btn:onClick(self, self.onRightClick, EXCHANGE_STATE)
	widgets.pray_tab:onClick(self, self.onRightClick, PRAY_STATE)
	widgets.return_wish_tab:onClick(self, self.onRightClick, RETURN_STATE)
	widgets.return_wish_award:onTouchEvent(self, self.onReturnWishAwardClick)
	widgets.take_wish_award:onClick(self, self.onTakeWishAwardClick)
	widgets.pray_btn:onClick(self, self.onPrayClick)
	widgets.pray_tips:setText(i3k_get_string(18276))
	-- widgets.pray_desc:setText(i3k_get_string(18282, i3k_db_common.inputlen.timingPrayMaxLen))
	widgets.upPage:onClick(self, self.onNextPage, -1)
	widgets.downPage:onClick(self, self.onNextPage, 1)
	self.tabInfos = {
		[EXCHANGE_STATE] = {root = widgets.changeUI, tab = widgets.time_btn, txt = widgets.tagName2},
		[ACTIVITY_STATE] = {root = widgets.rcbUI, tab = widgets.groom_btn, txt = widgets.tagName1},
		[PRAY_STATE] 	 = {root = widgets.pray_root, tab = widgets.pray_tab, txt = widgets.tagName3},
		[RETURN_STATE]	 = {root = widgets.return_wish_root, tab = widgets.return_wish_tab, txt = widgets.tagName4},
	}
end

function wnd_timingActivity:refresh(state)
	if state then
		self.rightState = state
	end
	self:setSchedule()
	self:updateRightBtnState()
end

function wnd_timingActivity:updateRightBtnState(state)
	self.rightState = state or self.rightState
	local widgets = self._layout.vars
	for k,v in pairs(self.tabInfos) do
		v.root:setVisible(k == self.rightState)
		v.tab[k == self.rightState and "stateToPressed" or "stateToNormal"](v.tab)
		local color = k == self.rightState and SELECT_FONT_COLOR or UNSELECT_FONT_COLOR
		v.txt:setTextColor(color)
		v.txt:enableOutline(k == self.rightState and SELECT_FONT_OUTLINE_COLOR or UNSELECT_FONT_OUTLINE_COLOR)
	end
	if self.rightState == EXCHANGE_STATE then
		--兑换按钮
		self:updateActivityExchange()
	elseif self.rightState == ACTIVITY_STATE then
		self:setSchedule()
		self:updateList()
	elseif self.rightState == PRAY_STATE then
		self:updateWishWall()
	elseif self.rightState == RETURN_STATE then
		self:updateReturnWish()
    end
	self:refreshRed()
end

---box
function wnd_timingActivity:setSchedule()
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local boxAni = {}
	local actRewards = i3k_db_timing_activity.actRewards[timingActivityInfo.id]
	for k,v in ipairs(actRewards) do
		local  state = REWARD_STATE_NOT
		if timingActivityInfo.totalScore >= v.actValue then
			state = REWARD_STATE_READY
			if timingActivityInfo.reward[k] then
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
	self:setRewards(boxAni)
end

--设置rewards
function wnd_timingActivity:setRewards(boxAni)
	local startNum, endNum, scheduleType = g_i3k_db.i3k_db_get_rewards_show_cfg(self.rewardsState)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local widgets = self._layout.vars
	widgets.sche1Cont:setVisible(false)
	widgets.sche2Cont:setVisible(false)
	local scheValue, findFlag = 0, false
	local cfgActRewards = i3k_db_timing_activity.actRewards[timingActivityInfo.id]
	for i = startNum, endNum do
		self:setRewardsShow(i, boxAni)
		if cfgActRewards[i].actValue <= timingActivityInfo.totalScore  then
			scheValue = scheValue + 1 / (endNum - startNum + 1)
		elseif not findFlag then
			local num = endNum - startNum + 1
			scheValue = scheValue + g_i3k_db.i3k_db_get_timing_activity_reward_value(num, i, timingActivityInfo)
			findFlag = true
		end
	end
	scheValue = scheValue * 100
	widgets[string.format("sche%sCont", scheduleType)]:setVisible(true)
 	widgets[string.format("schedule%s", scheduleType)]:setPercent(scheValue < 100 and scheValue or 100)
	widgets.act_txt:setText(timingActivityInfo.totalScore)
	local cfg = i3k_db_timing_activity.openday[timingActivityInfo.id]
	local itemId = cfg.rewardItemsId
	widgets.itemIcon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
	local cfgEndTime = i3k_db_timing_activity.openday[timingActivityInfo.id].endtime
	local endTime = g_i3k_get_MonthAndDayTime(cfgEndTime)
	widgets.activitytime:setText("活动期限："..endTime)
end

--设置宝箱显示
function wnd_timingActivity:setRewardsShow(index, boxAni)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local cfgActRewards = i3k_db_timing_activity.actRewards[timingActivityInfo.id]
	local widgets = self._layout.vars
	widgets[string.format("reward_btn%s", index)]:setTag(index + l_tag)
	widgets[string.format("reward_btn%s", index)]:onClick(self, self.onRewardClick, index)
	widgets[string.format("reward_btn%s", index)]:setTouchEnabled(true)
	widgets[string.format("reward_get_icon%s", index)]:setVisible(false)
	if self.rewardsState[index] == REWARD_STATE_NOT then
		--i3k_log("not")
		widgets[string.format("reward_icon%s", index)]:setVisible(true)
		widgets[string.format("reward_btn%s", index)]:onTouchEvent(self, self.onTips, {cfgActRewards[index], 3})
	elseif self.rewardsState[index] == REWARD_STATE_READY then
		--i3k_log("ready")
		widgets[string.format("reward_icon%s", index)]:setVisible(true)
		widgets[string.format("reward_btn%s", index)]:onClick(self,self.onRewardClick, index)
		boxAni[index].play()
	else
		--i3k_log("finishi")
		--widgets[string.format("reward_icon%s",index)]:setVisible(false)
		widgets[string.format("reward_get_icon%s", index)]:setVisible(true)
		widgets[string.format("reward_btn%s", index)]:setTouchEnabled(false)
	end
	widgets[string.format("reward_txt%s", index)]:setText(cfgActRewards[index].actValue)
	if self.rewardsState[index] == REWARD_STATE_NOT then
		widgets[string.format("reward_txt%s", index)]:setTextColor(NOT_SCHEDULE_COLOR)
		widgets[string.format("value_img%s", index)]:setImage(i3k_db.i3k_db_get_icon_path(NOT_VALUE_ICO))
	end
end

--活动列表
function wnd_timingActivity:updateList()
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
    local heroLvl = g_i3k_game_context:GetLevel()
	local sch_list = self._layout.vars.sch_list
	sch_list:removeAllChildren(true)
	local isVisible = self:clearList()
	self:listState(isVisible)
	if isVisible then
		return
	end
	local visualList = timingActivityInfo.tasks
	local list = g_i3k_db.i3k_db_timing_activity_tasks_sort(visualList)
	--[[local list = self:setDailyTaskSort(visualList)--]]
	for k, v in ipairs(list) do
		local node = require(DQHD_PATH)()
		local vars = node.vars
		vars.taskIcon:setImage(i3k_db.i3k_db_get_icon_path(v.cfg.icon))
		vars.taskicon:hide()
		vars.taskName:setText(v.cfg.name)
		vars.count1:setText("x"..v.cfg.count) --次数
		vars.des:setText(v.times.."/"..v.cfg.targetcount1.."</c>")
		vars.btn:onClick(self, self.gotoTask, v.cfg)
		vars.notCanJump:hide()
		vars.noFinish:show()
		vars.complete:hide()
		vars.condition:setText(string.format(v.cfg.desc, v.cfg.targetcount1))
		if v.rewards == 1 then
			vars.noFinish:hide()
			vars.complete:show()
			vars.btn:hide()
			vars.notCanJump:show()
		end
		sch_list:addItem(node)
	end
end


--列表状态
function wnd_timingActivity:listState(isend)
	local widgets = self._layout.vars
	widgets.activityEnd:setVisible(isend)
	widgets.activityDesc:setText("活动已结束")
	widgets.sch_list:setVisible(not isend)
end

--清除列表
function wnd_timingActivity:clearList()
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local curTime = g_i3k_get_GMTtime(i3k_game_get_time())
	local endTime = i3k_db_timing_activity.openday[timingActivityInfo.id].endtime
	if curTime > endTime then
		return true
	end
	return false
end

--等级不足
function wnd_timingActivity:levelTips(sender)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17437))
end

--立即前往
function wnd_timingActivity:gotoTask(sender, cfg)
	local taskId = cfg.id
	local arg = cfg.targetArg
	if gototimingactivity[taskId] then
		gototimingactivity[taskId](arg)
	end
end

--刷新红点
function wnd_timingActivity:refreshRed()
	local activity_red = g_i3k_game_context:getTimingAcitivitRed()
    local exchange = g_i3k_game_context:getTimingAcitivitExchangeRed()
	local takePrayRed = g_i3k_game_context:getTimingActivityReturnWishRed()
	self._layout.vars.red_img2:setVisible(exchange)
	self._layout.vars.red_img1:setVisible(activity_red)
	self._layout.vars.return_wish_red:setVisible(takePrayRed)
end

--活动兑换
function wnd_timingActivity:updateActivityExchange(index)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	if not timingActivityInfo or timingActivityInfo.id <= 0 then return end
	local exchange_list = self._layout.vars.sch_list2
	local curindex = exchange_list:getListPercent()
	--exchange_list:removeAllChildren(true)
	local cfg = i3k_db_timing_activity.openday[timingActivityInfo.id]
	local itemId = cfg.rewardItemsId
	self._layout.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
	self._layout.vars.act_txt2:setText(timingActivityInfo.totalScore - timingActivityInfo.usedScore)
	local cfgEndTime = i3k_db_timing_activity.openday[timingActivityInfo.id].receivetime
	local endTime = g_i3k_get_MonthAndDayTime(cfgEndTime)
	self._layout.vars.finishdesc:setText("活动兑换截止到："..endTime)
	local visualList = i3k_db_timing_activity_exchange[timingActivityInfo.id]--i3k_clone()
	local listAllChild = exchange_list:getAllChildren()
	for i, v in ipairs(visualList) do
		local node
		if  listAllChild[i] then
			node = listAllChild[i]
		else
			node = require(CHANGE)()
		end
        local exchangeInfo = v
		local widgets = node.vars
		widgets.exchange:enableWithChildren()
        self:setExchangeItem(widgets, exchangeInfo)
		widgets.leftTimes:setText("最大剩余次数："..exchangeInfo.limit_times)
		local a=exchangeInfo.limit_times
		if timingActivityInfo.exchange and timingActivityInfo.exchange[i]   then
			if timingActivityInfo.exchange[i] >= exchangeInfo.limit_times then
                widgets.exchange:disableWithChildren() --次数不足按钮置灰
			end
			widgets.leftTimes:setText("最大剩余次数："..exchangeInfo.limit_times - timingActivityInfo.exchange[i])
		end
		local exchangeTable =
		{
			id = i,
			count = 1,
			needItems = exchangeInfo.needItems,
			exchangeItems = exchangeInfo.exchangeItems,
		}
		widgets.exchange:onClick(self, self.onExchange, exchangeTable)
		if not listAllChild[i] then
			exchange_list:addItem(node)
		end
	end
--[[	if index then
		exchange_list:jumpToChildWithIndex(index)
	elseif curindex then
		exchange_list:jumpToChildWithIndex(curindex)
	end--]]
end

--设置兑换item
function wnd_timingActivity:setExchangeItem(widgets, exchangeInfo)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local alignmentState = self:getSetGetGoodsState()
	for j = 1, 3 do
		if j == 1 then
			--widgets.require_goods_icon1:setImage(i3k_db.i3k_db_get_icon_path(exchangeInfo.require_goods_icon1))
			widgets.require_icon1:setImage(i3k_db.i3k_db_get_icon_path(exchangeInfo.require_goods_icon1))
			widgets.require_goods_icon1:hide()
			widgets.require_goods_btn1:setVisible(false)
			local add_goods_count = timingActivityInfo.totalScore - timingActivityInfo.usedScore
			if add_goods_count < exchangeInfo.require_goods_count1 then
				widgets.require_goods_count1:setTextColor(g_i3k_get_red_color())
				widgets.exchange:disableWithChildren() --道具数量不足，兑换按钮置灰
			else
				widgets.require_goods_count1:setTextColor(g_i3k_get_green_color())
			end
			widgets.require_goods_count1:setText(add_goods_count.."/"..exchangeInfo.require_goods_count1)
		else
			if exchangeInfo.needItems[j-1] then
				local item = exchangeInfo.needItems[j-1]
				widgets[string.format("require_goods_icon%s", j)]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id, g_i3k_game_context:IsFemaleRole()))
				widgets[string.format("require_icon%s", j)]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
				local add_goods_count = g_i3k_game_context:GetCommonItemCanUseCount(item.id)
				if add_goods_count < item.count then
					widgets[string.format("require_goods_count%s", j)]:setTextColor(g_i3k_get_red_color())
					widgets.exchange:disableWithChildren() --道具数量不足，兑换按钮置灰
				else
					widgets[string.format("require_goods_count%s", j)]:setTextColor(g_i3k_get_green_color())
				end
				if  math.abs(item.id) == g_BASE_ITEM_COIN then -- 铜钱
					widgets[string.format("require_goods_count%s", j)]:setText(i3k_get_num_to_show(item.count))
				else
					widgets[string.format("require_goods_count%s", j)]:setText(add_goods_count.."/"..item.count)
				end
				local item_id = item.id
				widgets[string.format("require_goods_btn%s",j)]:onClick(self,self.openTips, item_id)
			end
		end
		self:setGetGoodsNode(widgets, exchangeInfo, j, alignmentState)
	end
end

--设置获取格子居中
function wnd_timingActivity:setGetGoodsNode(widgets, exchangeInfo, index, alignmentState)
	if alignmentState == ALIGNMENT_LEFT then
		if widgets[string.format("get_icon%s", index)] then
			if exchangeInfo.exchangeItems[index] then
				local exchangeItem = exchangeInfo.exchangeItems[index]
				self:setGoodsValues(widgets, index, exchangeItem)
			else
				widgets[string.format("get_icon%s", index)]:setVisible(false)
			end
		end
	else
		if widgets[string.format("get_icon%s", index)] then
			if exchangeInfo.exchangeItems[index] then
				local exchangeItem = exchangeInfo.exchangeItems[index]
				local j = index
				if  widgets[string.format("get_icon%s", j+1)] then
					j = j +1
					widgets[string.format("get_icon%s", index)]:setVisible(false)
				end
				self:setGoodsValues(widgets, j, exchangeItem)
			else
				if index ~= 2 then
					widgets[string.format("get_icon%s", index)]:setVisible(false)
				end
			end
		end
	end
end

--设置格子的值
function wnd_timingActivity:setGoodsValues(widgets, index, exchangeItem)
	widgets[string.format("get_goods_icon%s", index)]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(exchangeItem.id, g_i3k_game_context:IsFemaleRole()))
	widgets[string.format("get_icon%s", index)]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(exchangeItem.id))
	widgets[string.format("get_goods_count%s", index)]:setText("x"..exchangeItem.count)
	local item_id = exchangeItem.id
	widgets[string.format("get_goods_btn%s", index)]:onClick(self, self.openTips, item_id)
end

--获取格子对齐状态
function wnd_timingActivity:getSetGetGoodsState()
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local visuallist = i3k_db_timing_activity_exchange[timingActivityInfo.id]
	for i, v in ipairs(visuallist) do
		local getGoods = v.exchangeItems
		if #getGoods >1 then
			return ALIGNMENT_LEFT
		end
	end
	return ALIGNMENT_CENTER
end

--页签跳转
function wnd_timingActivity:onRightClick(sender, index)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	if not timingActivityInfo or timingActivityInfo.id <= 0 then return end
	if index == self.rightState then
		return
    else
    	if index == PRAY_STATE then
    		i3k_sbean.regular_pray_open(function()
    			g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "updateRightBtnState", PRAY_STATE)
	    	end)
    	elseif index == RETURN_STATE and not g_i3k_game_context:getTimingActivityPrayInfo() then
    		i3k_sbean.regular_pray_open(function()
    			g_i3k_ui_mgr:InvokeUIFunction(eUIID_TimingActivity, "updateRightBtnState", RETURN_STATE)
	    	end)
    	else
			self:updateRightBtnState(index)
    	end
	end
end

--活跃奖励领取
function wnd_timingActivity:onRewardClick(sender,index)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
    if not 	timingActivityInfo or timingActivityInfo.id <= 0 then return end
	--local tag = index
	local allCell = g_i3k_game_context:GetBagSize()
	local useCell = g_i3k_game_context:GetBagUseCell()
	local restCell = allCell - useCell
	local cfgRewards = i3k_db_timing_activity.actRewards[timingActivityInfo.id]
	if self.rewardsState[index] == REWARD_STATE_READY then
		if restCell >= cfgRewards[index].bgFree then
			i3k_sbean.activityreward(index)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(628))
		end
	end
end

--物品介绍
function wnd_timingActivity:openTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

--按住显示宝箱获取
function wnd_timingActivity:onTips(sender, eventType, data)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Tips)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule_Tips, data[1], data[2])
	elseif eventType == ccui.TouchEventType.moved then

	else
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
	end
end

--兑换
function wnd_timingActivity:onExchange(sender, tbl)
	for k, item in ipairs(tbl.exchangeItems) do
		local t = {}
		t[item.id] = item.count
		if not g_i3k_game_context:IsBagEnough(t) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(628))
			return
		end
	end
	i3k_sbean.activity_exchange_req(tbl)
end

--帮助
function wnd_timingActivity:onActivityHelp(sender)
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
    if not 	timingActivityInfo or timingActivityInfo.id <= 0 then return end
	local cfgDb = i3k_db_timing_activity.openday[timingActivityInfo.id]
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(cfgDb.activityHelp))
end

----------------------------↓新加 祈愿 还愿↓---------
local PRAY_TXT_WIDGET = "ui/widgets/dingqihuodongt4"
function wnd_timingActivity:updateWishWall()--更新许愿墙
	self.isCanTake = nil
	local widgets = self._layout.vars
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local prayInfo = g_i3k_game_context:getTimingActivityPrayInfo()
	if not timingActivityInfo then
		self:onCloseUI()
	end
	widgets.pray_btn_txt:setText(i3k_get_string(prayInfo.selfPray.firstPrayTime == 0 and 18279 or 18280))
	local cfg = i3k_db_timing_activity.openday[timingActivityInfo.id]
	--典故
	self:InitAllusion(i3K_db_timing_activity_pray_txt.allusion[cfg.allusionId])
	--许愿
	self:SetWishInfo(prayInfo.prayDatas, prayInfo.selfPray.firstPrayTime ~= 0 and prayInfo.selfPray.content or nil)
end
function wnd_timingActivity:SetWishInfo(data, selfContent)
	self.wishData = data
	local widgets = self._layout.vars
	for i = 1, 20 do
		local v = data[i]
		if v then
			str = v.roleId > 0 and v.content or i3K_db_timing_activity_pray_txt.virtualPray[tonumber(v.content)]
			widgets['xy'..i]:setText(str)
		else
			if i <= 20 and selfContent then
				self.selfContent = self.selfContent or widgets['xy'..i]
				self.selfContent:setText(selfContent)
			end
			break
		end
	end
end
function wnd_timingActivity:ModifySelfContent(txt)
	if self.selfContent then
		self.selfContent:setText(txt)
	else
		self._layout.vars.pray_btn_txt:setText(i3k_get_string(18280))
		local idx
		if #self.wishData < 20 then
			idx = #self.wishData + 1
		else
			idx = math.random(1,10)
		end
		self.selfContent = self._layout.vars["xy"..idx]
		self.selfContent:setText(txt)
	end
end
function wnd_timingActivity:InitAllusion(txts)
	local widgets = self._layout.vars
	self.allusions = txts
	self.curAllusionIndex = 1
	widgets.txt:setText(txts[self.curAllusionIndex])
end
function wnd_timingActivity:onNextPage(sender, direction)--下一页
	if self.showingPage then return end
	if self.curAllusionIndex + direction < 1 then
		g_i3k_ui_mgr:PopupTipMessage("当前处于第一页")
	elseif self.curAllusionIndex + direction > #self.allusions then
		g_i3k_ui_mgr:PopupTipMessage("当前处于最后一页")
	else
		self.curAllusionIndex = self.curAllusionIndex + direction
		self:showNextPage(self.allusions[self.curAllusionIndex])
	end
	self.isShowingPageTips = false
end
local emptyFunc = cc.CallFunc:create(function()end)
function wnd_timingActivity:showNextPage(txt)--显示下一页的内容
	local delay = cc.DelayTime:create(0.5)
	local delay2 = cc.DelayTime:create(1)	
	self._layout.anis.txt.stop()
	self._layout.anis.txt.play()
	self.showingPage = true
	local seq = cc.Sequence:create(emptyFunc, delay, cc.CallFunc:create(function()
		self._layout.vars.txt:setText(txt)
	end))
	local seq2 = cc.Sequence:create(emptyFunc, delay2, cc.CallFunc:create(function()
		self.showingPage = false
	end))
	self._layout.vars.txt:runAction(seq)
	self._layout.vars.txt:runAction(seq2)
end
					--------还愿↓------
function wnd_timingActivity:updateReturnWish()--还愿界面
	local widgets = self._layout.vars
	local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
	local red = g_i3k_game_context:getTimingActivityReturnWishRed()
	widgets.take_wish_award:SetIsableWithChildren(red)
end
function wnd_timingActivity:onReturnWishAwardClick(sender, eventType)--还愿抽奖奖励预览
	if eventType==ccui.TouchEventType.began then
		local timingActivityInfo = g_i3k_game_context:getTimingActivityinfo()
		local cfg = i3k_db_timing_activity_pray_return_wish[timingActivityInfo.id]
		local btnPos = sender:getPosition()
		local pos = {x = btnPos.x + 400, y = btnPos.y + 200}
		g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Tips)
		g_i3k_ui_mgr:RefreshUI(eUIID_Schedule_Tips, {mustDropId = cfg.mustDrop, mayDropNum = #cfg.mayDrop}, 7, pos)--7是定期活动祈愿类型 只在这里调用 懒得加global了
	elseif eventType==ccui.TouchEventType.canceled or eventType==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
	end
end
function wnd_timingActivity:onTakeWishAwardClick(sender)
	i3k_sbean.regular_pray_take_reward()
end
function wnd_timingActivity:onPrayClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_TimingActivityPray)
	g_i3k_ui_mgr:RefreshUI(eUIID_TimingActivityPray)
end
function wnd_timingActivity:judgeCanTakeAward()
	local txt = self._layout.vars.countDown
	local btn = self._layout.vars.take_wish_award
	local info = g_i3k_game_context:getTimingActivityPrayInfo()
	if not info then--没有信息 或者已经领过奖
		txt:setVisible(false)
		btn:disableWithChildren()
		return
	end
	if info.selfPray.rewardCount >= i3k_db_timing_activity_pray_common_cfg.maxTimes then
		txt:setVisible(true)
		txt:setText("已领取")
		btn:disableWithChildren()
		return
	end
	if info.selfPray.firstPrayTime == 0 then
		txt:setVisible(true)
		txt:setText(i3k_get_string(18276))
		btn:disableWithChildren()
		return
	end
	local leftTime = info.selfPray.firstPrayTime + i3k_db_timing_activity_pray_common_cfg.rewardTimeOffset - i3k_game_get_time()
	if leftTime > 0 then--不可以领奖
		txt:setVisible(true)
		txt:setText("剩余时间"..(g_i3k_get_HourAndMin(leftTime) or " 2"))
		btn:disableWithChildren()
		self.isCanTake = false
	else
		txt:setVisible(false)
		if self.isCanTake ~= nil and not self.isCanTake then
			btn:enableWithChildren()
			self._layout.vars.return_wish_red:setVisible(true)
		end
		self.isCanTake = true
	end
end
function wnd_timingActivity:onUpdate(dTime)
	if self.rightState == RETURN_STATE then
		self:judgeCanTakeAward()
	elseif self.rightState == PRAY_STATE then
	end
end
-------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_timingActivity.new();
		wnd:create(layout,...)
	return wnd;
end
