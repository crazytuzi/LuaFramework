-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
require("ui/treasure_get_cfg")
local ui = require("ui/base");

-------------------------------------------------------
wnd_activity = i3k_class("wnd_activity", ui.wnd_base)

local f_activityNotOpenState	= 1
local f_activityOpenState		= 2
local f_activityOverState		= 3
local f_notActivityState		= 4

local LEFT_LADDER = 2144
local RIGHT_LADDER = 2145

local f_textColor = {"FF029133", "FF029133", "FF029133", "FFCA0D0D", "FFCA0D0D"}

-- showLvl 字段如果开启等级和显示等级一样则不需要使用开启等级（needLvl），如果不一样则需要初始化赋值
local f_typeTable = {
	[1] = {title = "日常试炼", needLvl = 1, iconID = 3493},--"日常活动",
	[2] = {title = "魔王降临", needLvl = 1, iconID = 3494},--"Boss来袭",
	[3] = {title = "巨灵攻城", needLvl = i3k_db_spirit_boss.common.openLvl,  iconID = 7144, showLvl = i3k_db_spirit_boss.common.showActivityLvl,},--"巨灵攻城",
	[4] = {title = "万寿阁", needLvl = i3k_db_longevity_pavilion.openLvl, iconID = 9629 },--"万寿阁",
	[5] = {title = i3k_get_string(18040), needLvl = i3k_db_princess_marry.openLvl, iconID = 8607, showLvl = i3k_db_princess_marry.openLvl},--"公主出嫁",
	[6] = {title = i3k_get_string(18136), needLvl = i3k_db_magic_machine.openLvl, iconID = 8823, showLvl = i3k_db_magic_machine.openLvl},--神机藏海
	[7] = {title = "五绝试炼", needLvl = i3k_db_climbing_tower_args.openLvl, iconID = 3495, showLvl = i3k_db_climbing_tower_args.showLvl},--"五绝试炼",
	[8] = {title = "江湖探宝", needLvl = i3k_db_treasure_base.other.needLvl, iconID = 3496, },--"藏宝图",
	[9] = {title = i3k_get_string(1485), needLvl = i3k_db_PetDungeonBase.openLvl, iconID = 7813},
	[10] = {title = "武道侠魂", needLvl = g_i3k_game_context:getEpicTaskOpenLvl(), iconID = 4287},
	[11] = {title = i3k_get_string(18332), needLvl = i3k_db_swordsman_circle_cfg.openLvl, iconID = 9323},
	[12] = {title = "江洋大盗", needLvl = i3k_db_robber_monster_base.condition.openLvl, iconID = 4994, showLvl = i3k_db_robber_monster_base.condition.showLvl},
}
local tabColor = {
	press = {textColor = "FFFFFFFF", outlineColor = "FF9F781A"},
	normal = {textColor = "FFBBFFED", outlineColor = "FF276C61"}
}

local levelTypeTbl =
{
	[1] = 2229,
	[2] = 2230,
	[3] = 2231,
}


local TOPLEVEL = "ui/widgets/shilianjmt3"
local BUTTOMLEVEL = "ui/widgets/shilianjmt2"
local JIANGHUDADAO2 = ("ui/widgets/jiangyangdadaot2")

-- 左侧btn
local NORMAL_ICON1	= 3490
local NORMAL_ICON2	= 3491
local PRESSED_ICON	= 3492


local ROBBER_NO_MONTH_BG	= 4988 --江洋大盗普通底板
local ROBBER_MONTH_BG 		= 4989 --江洋大盗月卡底板
local SPECIALACTIVITY		= 2 --特殊任务副本id

local REFRESHINTERVAL = 1 --界面刷新间隔
function wnd_activity:ctor()
	self._activityPercent = 0

	l_isLoadBoss = 1--boss来袭对应的选中的bossIndex
	l_isLoadNpc = 1--江湖客栈Npc对应的选中的NpcIndex

	l_treasureState = 1--藏宝图界面对应的tabbar标签Index

	TREASURE_STATE_CHIP			= 1
	TREASURE_STATE_FIND			= 2
	TREASURE_STATE_COLLECT		= 3

	_collectionIndex = 1--收藏品的界面点击的index，切换时保存

	self.model_btn = {}

	self._punishtime = 0 --势力战惩罚时间
	self._isForceWar = false
	self._activityID = nil
	self._demonHoleWidget = nil
	self._closeTimeStamp = nil
	self._openTimeStamp	= nil
	self._logs = nil
	self._spiritBossWidget = nil
	self._petActivityWidget = nil --宠物试炼
	self._princessMarryWidget = nil -- 公主出嫁
	self._princessMarryOpenFlag = false -- 公主出嫁开放
	self._magicMachineWidget = nil -- 神机藏海
	self._activityOpenState = 0 --各个活动刷新状态 -- 1是开启 2是未开启 避免每帧刷新按钮状态
	self._refreshTimeTicket = 0
	self._swordsmanWidget = nil -- 大侠朋友圈
	self._longevityPavilionWidget = nil --万寿阁
end

function wnd_activity:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	l_makeMapState = g_i3k_game_context:getIsHaveMapCanExplore()--当前是否有宝图处于已合成并且未探索状态

	self._state = 1
	local dailyActivityTable = { allActivity = i3k_db_activity, notOpenTable = {}, openTable = {}, closeTable = {}, notHaveTable = {} }
	local forceWarTable = {}
	local worldBossTable = { allActivity = i3k_db_world_boss, notOpenTable = {}, openTable = {}, closeTable = {}, notHaveTable = {} }

	self._layout.vars.add_vit:onClick(self, self.addVitBtn)
	self._layout.vars.vit_info:onTouchEvent(self, self.vitInfo)


	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local hour = tonumber(os.date("%H", timeStamp))
	if hour < gDay_Refresh_Time then
		if week==0 then
			week = 6;
		else
			week = week - 1;
		end
		--day = day - 1;
	end

	for _,v in ipairs(i3k_db_activity) do
		local open = string.split(v.openTime, ":")
		--local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
		local openTimeStamp = g_i3k_get_GMTtime(g_i3k_get_day_time(v.openOffsetTime))
		if hour < gDay_Refresh_Time then
			openTimeStamp = openTimeStamp - 86400
		end
		local closeTimeStamp = openTimeStamp + v.lifeTime;
		local isHave = false
		for __,t in ipairs(v.openDay) do
			if t==week then
				if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
					table.insert(dailyActivityTable.openTable, v)--当天活动开启状态
				elseif timeStamp>closeTimeStamp then
					table.insert(dailyActivityTable.closeTable, v)--当天活动已结束状态
				elseif timeStamp<openTimeStamp then
					table.insert(dailyActivityTable.notOpenTable, v)--当天活动未开启状态
				end
				isHave = true
				break
			end
		end
		if not isHave then
			for __,t in ipairs(v.openDay) do
				local nowWeek = week==6 and 0 or week + 1;--因为5点结算，所以有偏移，5点之前算昨天，所以5点之前的话week是nowWeek-1，day也是nowDay - 1
				if hour<gDay_Refresh_Time and t==nowWeek then
					openTimeStamp = openTimeStamp + 86400;
					closeTimeStamp = openTimeStamp + v.lifeTime;
					if timeStamp>openTimeStamp and timeStamp<closeTimeStamp then
						table.insert(dailyActivityTable.openTable, v)--当天活动开启状态
					elseif timeStamp>closeTimeStamp then
						table.insert(dailyActivityTable.closeTable, v)--当天活动已结束状态
					elseif timeStamp<openTimeStamp then
						table.insert(dailyActivityTable.notOpenTable, v)--当天活动未开启状态
					end
					isHave = true
					break
				end
			end
			if not isHave then
				table.insert(dailyActivityTable.notHaveTable, v)--当天无此活动状态
			end
		end

	end

	for _,v in ipairs(i3k_db_world_boss) do
		local isHave = false
		for __,t in pairs(v.openDay) do
			local isAdd = false
			for i,u in ipairs(v.openTime) do
				local open = string.split(u, ":")
				local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
				if t==week then
					isHave = true
					if timeStamp<openTimeStamp then
						table.insert(worldBossTable.notOpenTable, v)--当天活动未开启状态
						isAdd = true
						break
					elseif timeStamp>=openTimeStamp and timeStamp<openTimeStamp+v.lifeTime then
						table.insert(worldBossTable.openTable, v)--当天活动在开启状态
						isAdd = true
						break
					elseif timeStamp>=openTimeStamp+v.lifeTime and i==#v.openTime then
						table.insert(worldBossTable.closeTable, v)--当天活动已经结束状态
						isAdd = true
						break
					end
				end
			end
			if isHave then
				break
			end
		end
		if not isHave then
			table.insert(worldBossTable.notHaveTable, v)--当天无此活动状态
		end
	end


	self._allActivityTable = {
		[g_ACTIVITY_STATE] = dailyActivityTable,
		[g_WORLD_BOSS_STATE] = worldBossTable,
	}

	self._rootWidget = self._layout.vars.rootWidget

	self._fiveUnique_model_id = {}
end

function wnd_activity:onShow()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DBF,"setRootVisible",false)
end

function wnd_activity:refresh(activtyID)
	local lvl = g_i3k_game_context:GetLevel()
	if activtyID then
		self._activityID = activtyID
	end
	local scroll1 = self._layout.vars.scroll1

	for i=1, #f_typeTable do
		local node = require("ui/widgets/hdlbt")()
		node.vars.btn:setTag(i)
		node.vars.btn:onClick(self, self.changeState)
		node.vars.name:setText(f_typeTable[i].title)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(f_typeTable[i].iconID))

		--local bgIconId = i%2 ~= 0 and NORMAL_ICON1 or NORMAL_ICON2
		node.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON2))
		if i == self._state then
			node.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(PRESSED_ICON))
		end
		node.vars.showlock:setVisible(lvl < f_typeTable[i].needLvl)

		local showLvl = f_typeTable[i].showLvl or f_typeTable[i].needLvl
		if lvl >= showLvl then  
			scroll1:addItem(node)
		end
	end

	self:updateMoney(g_i3k_game_context:GetVit(), g_i3k_game_context:GetVitMax() )
	if self:judgeFirstTreasure() then
		self:changeStateImpl(g_TREASURE_STATE) -- 默认选中藏宝图，并暂时隐藏得到的碎片
		g_i3k_ui_mgr:OpenUI(eUIID_TreasureAnis)
	end
	
end

function wnd_activity:judgeFirstTreasure()
	local lvl = g_i3k_game_context:GetLevel()
	return lvl >= i3k_db_treasure_base.other.needLvl and g_i3k_game_context:getIsFirstTreasure()
end

function wnd_activity:setTreasureChipsScrollVisiable(bValue)
	if self._treasureChipScroll then
		self._treasureChipScroll:setVisible(bValue)
	end
end

function wnd_activity:finishTreasureGuide()
	local children = self._layout.vars.scroll1:getAllChildren()
	for i,v in ipairs(children) do
		if v.vars.name:getText()=="江湖探宝" then
			v.rootVar:show()
			break
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_TreasureAnis, "finishAnis")
	g_i3k_game_context:setIsFirstTreasure(false)
	self:setTreasureChipsScrollVisiable(true)
end

function wnd_activity:addChildWidget(widget)
	local children = self._rootWidget:getAddChild()
	while #self._rootWidget:getAddChild()~=0 do
		self._rootWidget:removeChild(self._rootWidget:getAddChild()[1])
	end
	self._rootWidget:addChild(widget)
end

function wnd_activity:changeStateImpl(senderTag)
	if senderTag ~= self._state then
		self._demonHoleWidget = nil
		self._closeTimeStamp = nil

		self._openTimeStamp	= nil
		self:releaseSchedule()
		self._isForceWar = false
		self._spiritBossWidget = nil
		self._petActivityWidget = nil
		self._princessMarryWidget = nil
		self._magicMachineWidget = nil
		self._activityOpenState = 0
		self._refreshTimeTicket = 0
		self._swordsmanWidget = nil
		self._longevityPavilionWidget = nil
		local roleLevel = g_i3k_game_context:GetLevel()
		if senderTag == g_ACTIVITY_STATE then
			self:reloadDailyActivity()
		elseif senderTag == g_WORLD_BOSS_STATE then
			self:reloadWorldBoss()
		elseif senderTag == g_TREASURE_STATE then--藏宝图操作
			if roleLevel >= i3k_db_treasure_base.other.needLvl then
				self:loadTreasureWidget()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_treasure_base.other.needLvl))
			end
		elseif senderTag == g_TOWER_STATE	 then--五绝试炼
			if roleLevel >= i3k_db_climbing_tower_args.openLvl then
				--self:reloadFiveUniqueActivity()---需要发协议获取随机塔
				i3k_sbean.sync_activities_tower()--同步爬塔
			else
				local tips = string.format("%s级开启五绝试炼",i3k_db_climbing_tower_args.openLvl)
				g_i3k_ui_mgr:PopupTipMessage(tips)
			end
		elseif senderTag == g_EPIC_STATE then
			self:loadEpicUI()--武道
		elseif senderTag == g_ROBBER_STATE then  --大道
			if roleLevel >= i3k_db_robber_monster_base.condition.openLvl then
				i3k_sbean.robbermonster_sync()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16859, i3k_db_robber_monster_base.condition.openLvl))
			end
		elseif senderTag == g_SPIRIT_MONSTER_STATE then --巨灵攻城
			i3k_sbean.gaintboss_sync()--同步巨灵攻城信息
		elseif senderTag == g_PET_ACTIVITY_STATE then
			self:onLoadPetActivityStateUI()
		elseif senderTag == g_PRINCESS_MARRY_STATE then		
			if roleLevel >= i3k_db_princess_marry.openLvl then
				local opendata = i3k_db_princess_marry.openDate
				if g_i3k_db.i3k_db_get_princess_marry_current_range(opendata.startTime, opendata.endTime) then 
					self:loadPrincessMarry(true)
				else
					self:loadPrincessMarry(false)
				end
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18041, i3k_db_climbing_tower_args.openLvl))
			end
		elseif senderTag == g_MAGIC_MACHINE_STATE then 
			if roleLevel >= i3k_db_magic_machine.openLvl then
				self:loadMagicMachine()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18041, i3k_db_magic_machine.openLvl))
			end
		elseif senderTag == g_SWORDSMAM_CIRCLE then
			i3k_sbean.friend_circle_open()
		elseif senderTag == g_LONGEVITY_PAVILION_STATE then --万寿阁
			if roleLevel >= i3k_db_magic_machine.openLvl then
				self:loadLongevityPavilion()
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18041, i3k_db_magic_machine.openLvl))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("其他功能、需加入新逻辑")
		end
	end
end

function wnd_activity:changeState(sender)
	local tag = sender:getTag()
	self:changeStateImpl(tag)
end
function wnd_activity:setState(state)
	self._state = state
	self:setTabBarLight()
end

function wnd_activity:setTabBarLight()
	local roleLevel = g_i3k_game_context:GetLevel()
	for i,v in ipairs(self._layout.vars.scroll1:getAllChildren()) do
		local tag = v.vars.btn:getTag()
		--local bgIconId = tag%2 ~= 0 and NORMAL_ICON1 or NORMAL_ICON2
		v.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(NORMAL_ICON2))
		if tag == self._state then
			v.vars.btn:setImage(g_i3k_db.i3k_db_get_icon_path(PRESSED_ICON))
		end
	end
end

function wnd_activity:openWithTreasure()
	if g_i3k_game_context:GetLevel() >= i3k_db_treasure_base.other.needLvl then
		self:setState(g_TREASURE_STATE)
		l_treasureState = 2
		self:loadTreasureWidget()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_treasure_base.other.needLvl))
	end
end

function wnd_activity:openWithTreasurePage1()
	if g_i3k_game_context:GetLevel() >= i3k_db_treasure_base.other.needLvl then
		l_treasureState = TREASURE_STATE_CHIP
		self:setState(g_TREASURE_STATE)
		self:loadTreasureWidget()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_treasure_base.other.needLvl))
	end
end

-- function wnd_activity:openWithNpcHostel()
-- 	local hero = i3k_game_get_player_hero()
-- 	if hero._lvl>=i3k_db_treasure_base.other.needLvl then
-- 		self._state = HOSTEL_STATE
-- 		i3k_sbean.sync_hostel()
-- 		self:setTabBarLight()
-- 	else
-- 		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_treasure_base.other.needLvl))
-- 	end
-- end

--打开五绝
function wnd_activity:openWithFiveUnique()
	if g_i3k_game_context:GetLevel() >= i3k_db_climbing_tower_args.openLvl then
		self:setState(g_TOWER_STATE)
		i3k_sbean.sync_activities_tower()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_climbing_tower_args.openLvl))
	end
end

function wnd_activity:openWithFiveUniqueActivity(state,fun)
	if g_i3k_game_context:GetLevel() >= i3k_db_climbing_tower_args.openLvl then
		--i3k_sbean.sync_activities_tower(state)--同步爬塔
		self:setState(g_TOWER_STATE)
		i3k_sbean.sync_activities_tower(state,nil,fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(47, i3k_db_climbing_tower_args.openLvl))
	end
end

function wnd_activity:updateFiveUniqueActivity()
	if self._state == g_TOWER_STATE then
		self:openWithFiveUniqueActivity()
	end
end

function wnd_activity:openWithWorldBoss(levelClose)
	-- 从聊天窗口点击来的，先要检查藏宝图是否第一次点开
	if self:judgeFirstTreasure() then
		self:changeStateImpl(g_TREASURE_STATE) -- 默认选中藏宝图，并暂时隐藏得到的碎片
		g_i3k_ui_mgr:OpenUI(eUIID_TreasureAnis)
		return
	end
	self:setState(g_WORLD_BOSS_STATE)
	self:reloadWorldBoss(levelClose)
end

--local function 日常活动()
--end
function wnd_activity:sortActivityGroup(groupId)
	local dungeonTable = {}
	
	for i,v in pairs(i3k_db_activity_cfg) do
		if v.groupId == groupId then
			table.insert(dungeonTable, v)
		end
	end
	
	table.sort(dungeonTable, function (a, b)
		return a.difficulty < b.difficulty
	end)
	
	return dungeonTable
end

function wnd_activity:refineDifficultyID(groupId, dungeonTable)
	local maxDifficult
	
	for i = #dungeonTable, 1, -1 do
		if self:checkDailyActivityWipe(groupId, dungeonTable[i].id) then
			return dungeonTable[i]
		end
	end
	
	return 0
end

function wnd_activity:onSweepBtClick()
	if self._logs == nil then
		local name = i3k_db_activity[SPECIALACTIVITY].name
		i3k_sbean.activity_instance_logs_sync(SPECIALACTIVITY, name, true)
		return
	end
	
	self:openSweepUI()	
end

--特殊活动检查
function wnd_activity:canSweep(mapId)
	for _, v in pairs(self._logs) do
		if v.mapID == mapId then
			local cfg = i3k_db_activity_cfg[mapId]
			if i3k_db_activity_cfg[mapId].specialSweepType == 1 then
				if v.drops and next(v.drops) then
			return true
		end
			elseif i3k_db_activity_cfg[mapId].specialSweepType == 2 then
				if v.mines and next(v.mines) then
					return true
	end
			elseif i3k_db_activity_cfg[mapId].specialSweepType == 3 then
				if v.monsters and next(v.monsters) then
					return true
				end
			end
		end
	end
	return false
end

function wnd_activity:isWizardEnough(groupId)
	local wizardLvl = g_i3k_game_context:GetOfflineWizardLevel()
	
	for _, e in ipairs(i3k_db_activity_wipe[wizardLvl].groupIds) do
		if e == groupId then
			return true
		end
	end
	
	return false
end

--检查是否可以扫荡
function wnd_activity:checkDailyActivityWipe(groupId, mapId)
	local cfg = i3k_db_activity_cfg[mapId]
	local roleLvl = g_i3k_game_context:GetLevel()
	
	if cfg then
		if roleLvl < cfg.needLvl then
			return false
		end
	end
	
	if cfg.specialSweepType ~= 0 and cfg.groupId ~= 8 then
		if not self:canSweep(mapId) then
			return false
		end
	else
		if g_i3k_game_context:getActMapRecord(i3k_db_activity_cfg[mapId].groupId, mapId) < 10000 then
			return false
		else
			if cfg.groupId == 8 then--秘宝矿洞
				local monsterID = cfg.specialWinCondition5.monsterID
				local logs = self._logs[mapId]
				if not(logs and logs.monsters and logs.monsters[monsterID] and logs.monsters[monsterID] > 0) then
					return false
				end
			end
		end
	end
	
	local needWizardLvl = self:isWizardEnough(groupId)
	
	if not needWizardLvl then
		return false
	end
	
	return true
end

function wnd_activity:initDailyActivitySpecials(logs)
	self._logs = logs == nil and {} or logs
	self:openSweepUI()
end

function wnd_activity:openSweepUI()
	local wipeTable = {}
	local wipeZeroTimesTable = {}
	local dayBuyTimes = i3k_db_kungfu_vip[#i3k_db_kungfu_vip].buyActTimes
	local canBuyTimes = i3k_db_kungfu_vip[g_i3k_game_context:GetPracticalVipLevel()].buyActTimes
	local haveBuyItemTimes = g_i3k_game_context:getActDayItemAddTimes()
	if self._state == nil or self._allActivityTable == nil or self._allActivityTable[self._state] == nil then return end
	local openTable = self._allActivityTable[self._state].openTable
	if openTable == nil then return end
	
	for i,v in ipairs(openTable) do
		local dungeonTable = self:sortActivityGroup(v.id)
		local activityCfgData = self:refineDifficultyID(v.id ,dungeonTable)
		
		if activityCfgData ~= 0 then
			local enterTimes = g_i3k_game_context:getActivityDayEnterTime(v.id) or 0
			local totalTimes = v.times + dayBuyTimes + haveBuyItemTimes
			local myTimes = v.times + canBuyTimes + haveBuyItemTimes
			local remainTimes = myTimes - enterTimes
				
			if remainTimes == 0 then
				table.insert(wipeZeroTimesTable, {data = activityCfgData, toTimes = totalTimes, reTimes = remainTimes})
			else
				table.insert(wipeTable, {data = activityCfgData, toTimes = totalTimes, reTimes = remainTimes})
			end				
		end	
	end
	
	if #wipeTable == 0 and #wipeZeroTimesTable == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17227))
		return
	elseif #wipeTable == 0 and #wipeZeroTimesTable ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17237))
		return
	end
		
	--[[if #wipeZeroTimesTable ~= 0 then
		for	_, v in ipairs(wipeZeroTimesTable) do
			table.insert(wipeTable, v)
		end
	end--]]
	
	g_i3k_ui_mgr:OpenUI(eUIID_sweepActivity)
	g_i3k_ui_mgr:RefreshUI(eUIID_sweepActivity, wipeTable)
end

function wnd_activity:reloadDailyActivity()
	--同步周常宝箱进度 先同步进度 在刷新UI
	i3k_sbean.sync_daily_activity_week_reward()
end
--正常的试炼节点设置
function wnd_activity:setNormalDailyNode(node, info, scroll, index)
	local v = info
		local needLvl
	local activityState = self:getActivityState(v.id)
	if activityState==f_activityOpenState then

			local enterTimes = g_i3k_game_context:getActivityDayEnterTime(v.id) or 0
			local dayBuyTimes = g_i3k_game_context:getActDayBuyTimes(v.id)
		local dayItemTimes = g_i3k_game_context:getActDayItemAddTimes()
		local totalTimes = v.times + dayBuyTimes + dayItemTimes
			local activityOpenStr1 = string.format("%s%d", "剩余次数：", totalTimes - enterTimes)
			node.vars.haveTimes:setText(activityOpenStr1)
			node.descIsRed = totalTimes - enterTimes>0
			node.vars.addBtn:onClick(self, self.addTimes, v.id)
			local vipLvl = g_i3k_game_context:GetVipLevel()
		local addItemCfg = g_i3k_db.i3k_db_get_activity_add_times_cfg()
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(addItemCfg.id)
		local maxUseCount = addItemCfg.useCount
		local showCanItem = haveCount > 0 and dayItemTimes < (addItemCfg.vipDayBuyTimes[vipLvl + 1] or math.huge)
		node.vars.addBtn:setVisible((totalTimes - enterTimes == 0) and (vipLvl~=0 or showCanItem))

			for _,t in pairs(i3k_db_activity_cfg) do
				if t.groupId==v.id and t.difficulty==1 then
					needLvl = t.needLvl
				end
			end
			node.vars.clickBtn:setTag(v.id+1000)
			node.vars.clickBtn:onClick(self, self.onNodeClick, totalTimes>enterTimes)
			local roleLevel = g_i3k_game_context:GetLevel()
			if roleLevel < needLvl then
				local lvlStr = i3k_get_string(47, needLvl)
				node.vars.haveTimes:setText(lvlStr)
				node.descIsRed = false
				node.vars.clickBtn:setTouchEnabled(false)
				node.vars.icon:disable()
			end
			if self._activityID and v.id == self._activityID and not (roleLevel >= i3k_db_treasure_base.other.needLvl and g_i3k_game_context:getIsFirstTreasure()) then
				self:onNodeClick(node.vars.clickBtn,totalTimes>enterTimes)
			self._activityIndex = index
			end
			node.vars.lock:hide()
		elseif activityState==f_activityNotOpenState then
			--活动尚未开启状态
			for _,t in pairs(i3k_db_activity_cfg) do
				if t.groupId==v.id and t.difficulty==1 then
					needLvl = t.needLvl
				end
			end
			local roleLevel = g_i3k_game_context:GetLevel()
			if roleLevel < needLvl then
				local lvlStr = i3k_get_string(47, needLvl)
				node.vars.haveTimes:setText(lvlStr)
				node.vars.clickBtn:setTouchEnabled(false)
				node.vars.icon:disable()
			else
				local openTime = string.sub(v.openTime, 1, #v.openTime-3)
				local hour = tonumber(string.sub(openTime, 1, #openTime-3))
				local len = #openTime
				local min = tonumber(string.sub(openTime, #openTime-1, #openTime))
				local lifeMin = v.lifeTime/60;
				local lifeHour = lifeMin/60;
				local endMin = lifeMin%60;
				local endHour = hour + lifeHour;
				if endMin + min >= 60 then
					endHour = endHour + 1;
					endMin = endMin + min - 60;
				end
				local closeTime = string.format("%02d:%02d", endHour, endMin)
				if endHour >= 24 then
					endHour = endHour - 24;
					closeTime = string.format("次日%02d:%02d", endHour, endMin)
				end
				local str = string.format("%s~%s", openTime, closeTime)
				node.vars.haveTimes:setText(str)
				node.vars.clickBtn:setTouchEnabled(false)
				node.vars.lock:hide()
			end
		else
			isAdd = false--无此活动状态
		end
		node.vars.name:setText(v.name)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))--i3k_db_icons[v.icon].path)
		node.vars.dropWord1:setText(v.dropDesc1)
		local dropStar1 = {node.vars.dropStar11, node.vars.dropStar12, node.vars.dropStar13, node.vars.dropStar14, node.vars.dropStar15}
		for i,t in ipairs(dropStar1) do
			t:setVisible(i<=v.dropStar1)
		end
		node.vars.dropWord2:setText(v.dropDesc2)
		local dropStar2 = {node.vars.dropStar21, node.vars.dropStar22, node.vars.dropStar23, node.vars.dropStar24, node.vars.dropStar25}
		for i,t in ipairs(dropStar2) do
			t:setVisible(i<=v.dropStar2)
		end
		node.vars.drop2:setVisible(v.dropStar2~=0)
end

function wnd_activity:reloadDailyActivityReal()
	if self:judgeFirstTreasure() then--第一次打开 是藏宝图
		return
	end
	self:setState(g_ACTIVITY_STATE)
	local widget = require("ui/widgets/hdlx1")()
	widget.vars.sweepBt:onClick(self, self.onSweepBtClick)
	self:addChildWidget(widget)
	local allTb = {}
	local scroll2 = widget.vars.scroll2
	scroll2:removeAllChildren()
	for i,v in ipairs(self._allActivityTable[self._state].allActivity) do
		--local activityOpenStr2 = string.format("%s", "进行中")
		local needLvl
		local activityState
		activityState = self:getActivityState(v.id)
		local isAdd = true
		if activityState==f_activityOverState then
			--活动结束状态
			isAdd = false
		elseif activityState==f_activityOpenState then
			--活动开启状态
			for _,t in pairs(i3k_db_activity_cfg) do
				if t.groupId==v.id and t.difficulty==1 then
					needLvl = t.needLvl
				end
			end
		elseif activityState==f_activityNotOpenState then
			--活动尚未开启状态
			for _,t in pairs(i3k_db_activity_cfg) do
				if t.groupId==v.id and t.difficulty==1 then
					needLvl = t.needLvl
				end
			end
		else
			isAdd = false--无此活动状态
		end
		if isAdd then
			table.insert(allTb, {needLvl = needLvl, index = i})
		end
	end

	table.sort(allTb, function (a,b)
		return a.needLvl < b.needLvl
	end)
	local settingIndex = 1
	local totalActivityNum = #allTb + #self._allActivityTable[self._state].closeTable + #self._allActivityTable[self._state].notHaveTable
	scroll2:addChildWithCount("ui/widgets/hd1t", 2, totalActivityNum, true)
	for _, e in ipairs(allTb) do
		local node = scroll2:getChildAtIndex(settingIndex)
		self:setNormalDailyNode(node, self._allActivityTable[self._state].allActivity[e.index], scroll2, e.index)
		settingIndex = settingIndex + 1
	end
	
	for _,v in ipairs(self._allActivityTable[self._state].closeTable) do
		local node = scroll2:getChildAtIndex(settingIndex)
		--node.rootVar:disableWithChildren()
		settingIndex = settingIndex + 1
		local activityOverStr = string.format("%s", "活动已结束")
		node.vars.haveTimes:setText(activityOverStr)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))--i3k_db_icons[v.icon].path)
		node.vars.icon:setOpacity(255*0.6)
		node.vars.name:setText(v.name)
		node.vars.clickBtn:setTouchEnabled(false)
		node.vars.lock:hide()

		node.vars.dropWord1:setText(v.dropDesc1)
		local dropStar1 = {node.vars.dropStar11, node.vars.dropStar12, node.vars.dropStar13, node.vars.dropStar14, node.vars.dropStar15}
		for i,t in ipairs(dropStar1) do
			t:setVisible(i<=v.dropStar1)
		end
		node.vars.dropWord2:setText(v.dropDesc2)
		node.vars.drop2:setVisible(v.dropStar2~=0)
		local dropStar2 = {node.vars.dropStar21, node.vars.dropStar22, node.vars.dropStar23, node.vars.dropStar24, node.vars.dropStar25}
		for i,t in ipairs(dropStar2) do
			t:setVisible(i<=v.dropStar2)
		end
	
	end


	for _,v in ipairs(self._allActivityTable[self._state].notHaveTable) do
		local node = scroll2:getChildAtIndex(settingIndex)
		settingIndex = settingIndex + 1
		node.rootVar:disableWithChildren()
		node.isDisable = true
		node.vars.haveTimes:setText(i3k_get_activity_open_desc(v.openDay))
		node.vars.lock:show()
		node.vars.clickBtn:setTouchEnabled(false)
		node.vars.name:setText(v.name)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))--i3k_db_icons[v.icon].path)
		node.vars.dropWord1:setText(v.dropDesc1)
		local dropStar1 = {node.vars.dropStar11, node.vars.dropStar12, node.vars.dropStar13, node.vars.dropStar14, node.vars.dropStar15}
		for i,t in ipairs(dropStar1) do
			t:setVisible(i<=v.dropStar1)
		end
		node.vars.dropWord2:setText(v.dropDesc2)
		node.vars.drop2:setVisible(v.dropStar2~=0)
		local dropStar2 = {node.vars.dropStar21, node.vars.dropStar22, node.vars.dropStar23, node.vars.dropStar24, node.vars.dropStar25}
		for i,t in ipairs(dropStar2) do
			t:setVisible(i<=v.dropStar2)
		end
	end
	local allNode = scroll2:getAllChildren()
	for i, e in ipairs(allNode) do
		e.vars.name:setTextColor("FFf1e9d7")
		e.vars.name:enableOutline("FF743c28")
		e.vars.dropWord1:setTextColor("FFf1e9d7")
		e.vars.dropWord2:setTextColor("FFf1e9d7")
		e.vars.haveTimes:setTextColor(e.descIsRed and "FF76d646" or "FFdb3131")
		e.vars.haveTimes:enableOutline(e.descIsRed and "FF516c31" or "FF6e2f2f")
	end

	if self._activityPercent~=0 then
		scroll2:jumpToListPercent(self._activityPercent)
		self._activityPercent = 0
	end
	if self._activityIndex then
		local row = math.ceil(self._activityIndex / 2)
		local col = math.ceil(totalActivityNum / 2)
		scroll2:jumpToListPercent(row / col * 100)
		self._activityIndex = nil
	end
	self:updateDailyActivityWeekReward()
end
-- 日常试炼 周常 宝箱
function wnd_activity:updateDailyActivityWeekReward()
	local info = g_i3k_game_context:GetDailyActivityWeekRewardInfo()
	local widgets = self._rootWidget:getAddChild()[1]
	if self._state == g_ACTIVITY_STATE and widgets then
		local weedTimes = info.weekTimes
		widgets.vars.txt:setText(i3k_get_string(5495))
		for i=1, 4 do
			local cfg = i3k_db_practice_week_award[i]
			local needTimes = cfg.needTimes
			local percent = weedTimes >= needTimes and 1 or weedTimes / needTimes
			local lastCfg = i3k_db_practice_week_award[i - 1]
			if lastCfg then
				needTimes = needTimes - lastCfg.needTimes
				percent = (weedTimes - lastCfg.needTimes) / needTimes
			end
			widgets.vars["process"..i]:setPercent(100 * percent)
			widgets.vars["reward_txt"..i]:setText(cfg.needTimes)
			widgets.vars["reward_icon"..i]:setVisible(not info.rewards[i])
			widgets.vars["reward_get_icon"..i]:setVisible(info.rewards[i])
			widgets.vars["reward_btn"..i]:onTouchEvent(self, function(_,sender, eventType)
				if eventType == ccui.TouchEventType.ended then
					if info.weekTimes >= cfg.needTimes and not info.rewards[i] then
						i3k_sbean.daily_active_reward(i)
					end
					g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
				elseif eventType == ccui.TouchEventType.canceled then
					g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
				elseif eventType == ccui.TouchEventType.began then
					if not info.rewards[i] and info.weekTimes < cfg.needTimes then
						local data = {actValue = cfg.needTimes, lvlClass= cfg.levelClass, mayDrop = {}, mustDrop = {},}
						for i, v in ipairs(cfg.levelClass) do
							table.insert(data.mustDrop, {id = cfg.dropInfo[v].mustDropId, times =1})
							table.insert(data.mayDrop, {id = cfg.dropInfo[v].mayDropId, times = cfg.dropInfo[v].mayDropCnt})
						end
						g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Tips)
						g_i3k_ui_mgr:RefreshUI(eUIID_Schedule_Tips, data, 6)
					end
				end
			end)
			if not info.rewards[i] and cfg.needTimes <= info.weekTimes then
				widgets.anis["c_bx"..(i+1)].play()
			else
				widgets.anis["c_bx"..(i+1)].stop()
			end
		end
	end
end

function wnd_activity:updateDailyActivity()
	if self._state == g_ACTIVITY_STATE then
		self:reloadDailyActivity()
	end
end

function wnd_activity:resetActivityPercent()
	self._activityPercent = 0
end

function wnd_activity:onNodeClick(sender, canEnter)
	if canEnter then
		local id = sender:getTag()-1000
		local name = i3k_db_activity[id].name
		if id == 8 or id == 2 or id == 1 then
			i3k_sbean.activity_instance_logs_sync(id, name)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ActivityDetail)
			g_i3k_ui_mgr:RefreshUI(eUIID_ActivityDetail, id, name)
		end
	else

	end
end

function wnd_activity:addTimes(sender, id)
	local children = self._rootWidget:getAddChild()
	local widget = children[1]
	self._activityPercent = widget.vars.scroll2:getListPercent()
	local addTimesItemCfg = g_i3k_db.i3k_db_get_activity_add_times_cfg()
	local have = g_i3k_game_context:GetCommonItemCanUseCount(addTimesItemCfg.id)
	local useItemCount = g_i3k_game_context:getActDayItemAddTimes()
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local maxUse = addTimesItemCfg.vipDayBuyTimes[vipLvl + 1] or math.huge
	local canUseItem = maxUse > useItemCount
	if have == 0 then
		g_i3k_logic:OpenActivityVipBuyTimesUI(id)
	else
	local dayBuyTimes = g_i3k_game_context:getActDayBuyTimes(id)
		local vipLvl = g_i3k_game_context:GetVipLevel()
		local maxBuyTimes = i3k_db_kungfu_vip[vipLvl].buyActTimes
		local canVipBuy = dayBuyTimes < maxBuyTimes
		if useItemCount < maxUse and canVipBuy then
			g_i3k_ui_mgr:OpenUI(eUIID_ActivityAddTimesWay)
			g_i3k_ui_mgr:RefreshUI(eUIID_ActivityAddTimesWay, id)
		else
			if useItemCount < maxUse then--可以使用
				g_i3k_ui_mgr:OpenUI(eUIID_ActivityAddTimesByItem)
		else
				g_i3k_logic:OpenActivityVipBuyTimesUI(id)
		end
		end
	end
end




--local function BOSS来袭()
--end
function wnd_activity:reloadWorldBoss(levelClose)
	local widget = require("ui/widgets/bosslx")()
	self:addChildWidget(widget)
	self:setState(g_WORLD_BOSS_STATE)

	self._selectImgTable = {}
	local scroll = widget.vars.bossScroll
	scroll:removeAllChildren()
	local jumpNode
	local minLevel
	local myLevel = g_i3k_game_context:GetLevel()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local function isWeekMatch(openDayList)
		for _,v in pairs(openDayList) do
			if v == week then
				return true
			end
		end
		return false
	end
	local source = self._allActivityTable[self._state].allActivity
	local list = {}
	for k, v in pairs(source) do
		if g_i3k_db.i3k_db_check_world_boss_time(v.id) then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a, b)
		if a.isHolidayBoss == b.isHolidayBoss then
			return a.id < b.id
		end
		return a.isHolidayBoss == true
	end)
	if #list == 0 then -- 防止不在时间范围内，列表为空，造成的崩溃
		return
	end
	l_isLoadBoss = list[1].id
	for i,v in ipairs(list) do
		if isWeekMatch(v.openDay) then
		   local node = require("ui/widgets/bosslxt")()
		   jumpNode = i==1 and node or jumpNode
		   node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(v.icon, true))
		   node.vars.btn:setTag(v.id)
		   node.vars.btn:onClick(self, self.selectBoss)
			node.vars.holiday:setVisible(v.isHolidayBoss)
		   local state = self:getActivityState(v.id)
		   if v.id==l_isLoadBoss and not levelClose then
			   node.vars.select:show()
			   self:selectBoss(node.vars.btn)
			   l_isLoadBoss = v.id
		   end
		   node.vars.inTime:show()
		   if state~=f_activityOpenState then
			   node.vars.inTime:hide()
			   node.vars.btn:setOpacityWithChildren(255*0.6)
		   elseif levelClose then
			   local bossLvl = i3k_db_monsters[v.monsterId].level
			   local disLevel = math.abs(bossLvl - myLevel)
			   if minLevel then
				   if disLevel<minLevel then
					   minLevel = disLevel
					   jumpNode = node
				   end
			   else
				   minLevel = disLevel
				   jumpNode = node
			   end
		   end
		   self._selectImgTable[v.id] = node.vars.select
		   scroll:addItem(node)
		end
	end
	if levelClose and jumpNode then
		jumpNode.vars.select:show()
		self:selectBoss(jumpNode.vars.btn)
		l_isLoadBoss = jumpNode.vars.btn:getTag()
	end
end

function wnd_activity:selectBoss(sender)
	if self._state ~= g_WORLD_BOSS_STATE then
		return
	end
	local id = sender:getTag()
	for i,v in pairs(self._allActivityTable[self._state].allActivity) do
		if v.id==id then
			local syncBoss = i3k_sbean.bosses_sync_req.new()
			syncBoss.info = v
			i3k_game_send_str_cmd(syncBoss, "bosses_sync_res")
		end
	end
end

function wnd_activity:importBossData(bossInfo, boss)
	if self._state~=g_WORLD_BOSS_STATE then
		return
	end
	for i,v in pairs(self._selectImgTable) do
		if i==bossInfo.id then
			v:show()
		else
			v:hide()
		end
	end
	local children = self._rootWidget:getAddChild()
	local widget = children[1]
	widget.vars.nameAndModel:show()
	widget.vars.detail:show()
	self._selectBoss = bossInfo.id
	widget.vars.bossLvl:setText(i3k_db_monsters[bossInfo.monsterId].level .. "级")
	widget.vars.bossName:setText(bossInfo.name)
	local monster = i3k_db_monsters[bossInfo.monsterId].modelID
	ui_set_hero_model(widget.vars.bossModel, monster)
	if bossInfo.modelRotation ~= 0 then
		widget.vars.bossModel:setRotation(bossInfo.modelRotation)
	end
	local refreshTimeText = ""
	for i,v in ipairs(bossInfo.openTime) do
		local tempText = string.sub(v, 1, #v-3)
		if (i-1)%3==0 then
			refreshTimeText = refreshTimeText.."\n"
		end
		if i~=#bossInfo.openTime then
			refreshTimeText = refreshTimeText..tempText..";"
		else
			refreshTimeText = refreshTimeText..tempText
		end
	end
	widget.vars.refreshTime:setText(refreshTimeText)

	local stateText
	if boss.state==1 then
		stateText = string.format("%s", "即将刷新")
	elseif boss.state==2 then
		stateText = string.format("%s", "已经刷新")
	elseif boss.state==3 then
		stateText = string.format("%s", "正在战斗")
	elseif boss.state==4 then
		stateText = string.format("%s", "已死亡")
	elseif boss.state==5 then
		stateText = string.format("%s", "未刷新")
	end
	widget.vars.currentState:setText(stateText)
	widget.vars.currentState:setTextColor(f_textColor[boss.state])
	if #boss.killerName==0 then
		boss.killerName = string.format("%s", "从未被击杀")
	end
	widget.vars.lastTimeKill:setText(boss.killerName)
	widget.vars.distributeBtn:setTag(bossInfo.id)
	widget.vars.distributeBtn:onClick(self, self.toDistributeRecord)

	local drop1 = {root = widget.vars.drop1, icon = widget.vars.dropIcon1, btn = widget.vars.dropBtn1}
	local drop2 = {root = widget.vars.drop2, icon = widget.vars.dropIcon2, btn = widget.vars.dropBtn2}
	local drop3 = {root = widget.vars.drop3, icon = widget.vars.dropIcon3, btn = widget.vars.dropBtn3}
	local drop4 = {root = widget.vars.drop4, icon = widget.vars.dropIcon4, btn = widget.vars.dropBtn4}
	local drop5 = {root = widget.vars.drop5, icon = widget.vars.dropIcon5, btn = widget.vars.dropBtn5}
	local drop6 = {root = widget.vars.drop6, icon = widget.vars.dropIcon6, btn = widget.vars.dropBtn6}
	local dropRootTable = {drop1, drop2, drop3, drop4, drop5, drop6}
	for i,v in ipairs(dropRootTable) do
		v.root:hide()
	end
	local tempItemTable = {bossInfo.dropId1, bossInfo.dropId2, bossInfo.dropId3, bossInfo.dropId4, bossInfo.dropId5, bossInfo.dropId6}
	local dropItemTable = {}
	for i,v in ipairs(tempItemTable) do
		if v~=0 then
			table.insert(dropItemTable, v)
		end
	end
	for i,v in ipairs(dropItemTable) do
		dropRootTable[i].root:show()
		local rank = g_i3k_db.i3k_db_get_common_item_rank(v)
		dropRootTable[i].root:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
		dropRootTable[i].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
		dropRootTable[i].btn:setTag(v+3000)
		dropRootTable[i].btn:onClick(self, self.checkItemGrade)
	end
	widget.vars.startFightBtn:show()
	widget.vars.startFightBtn:setTag(bossInfo.id)
	widget.vars.startFightBtn:onClick(self, self.toBoss, bossInfo)
	-- 周年庆魔王优化
	if bossInfo.isHolidayBoss or bossInfo.showData then
		widget.vars.holidayRoot:show()
		local start = string.sub(bossInfo.startTime, 1, 10)
		local ee = string.sub(bossInfo.endTime, 1, 10)
		local txt = bossInfo.showData and i3k_get_string(1674, start, ee) or ""
		local txt2 = bossInfo.isHolidayBoss and i3k_get_string(1675) or ""
		local showText = txt.."\n"..txt2
		widget.vars.holidayText:setText(showText)
	else
		widget.vars.holidayRoot:hide()
	end
end

function wnd_activity:toDistributeRecord(sender)
	local bossId = sender:getTag()
	i3k_sbean.sync_boss_record(bossId, 0)
end

function wnd_activity:toBoss(sender, bossInfo)
	local bossId = sender:getTag()
	local roleLevel = g_i3k_game_context:GetLevel()
	local bossLevel = i3k_db_monsters[bossInfo.monsterId].level

	if math.abs(bossLevel - roleLevel) >= 10 and not bossInfo.isHolidayBoss then
		if bossLevel > roleLevel then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(178))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(179))
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_BossSelect)
		g_i3k_ui_mgr:RefreshUI(eUIID_BossSelect, bossId)
	end
end
























--[[function 藏宝图()
end--]]
function wnd_activity:loadTreasureChipData(mapInfo)
	if self._state~=g_TREASURE_STATE then
		return
	end
	if mapInfo.curMap.mapID~=0 and mapInfo.curMap.open==0 then
		l_makeMapState = true
	end
	--不管怎样，先获取到控件
	local child = self._rootWidget:getAddChild()
	local widget = child[1]
	--如果是碎片未合成状态
	if l_treasureState==TREASURE_STATE_CHIP and not l_makeMapState then
		local count = 0
		local sortTable = {}
		for i,v in pairs(mapInfo.pieces)do
			count = count + 1
			local tmpTable = {chipId = i, count = v}
			table.insert(sortTable, tmpTable)
		end
		widget.vars.noChip:setVisible(count==0)
		widget.vars.needCount:setVisible(count>0)
		widget.vars.cantText:hide()
		if count==0 then
			widget.vars.hechengBtn:disableWithChildren()
			widget.vars.hechengTX:hide()
			widget.vars.chipName:setText(i3k_get_string(15074))
			widget.vars.descText:setText()
		else
			widget.vars.descText:setText(i3k_get_string(15075))
		end
		table.sort(sortTable, function (a, b)
			return a.count>b.count
		end)
		local children = widget.vars.scroll:addChildWithCount("ui/widgets/cbtt2", 8, count)
		for i,v in ipairs(children) do
			local chipCfg = i3k_db_treasure_chip[sortTable[i].chipId]
			v.vars.hook:setVisible(sortTable[i].count>=chipCfg.needChipCount)
			v.vars.gradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(chipCfg.rank))
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(chipCfg.iconID))
			v.vars.countLabel:setText("x"..sortTable[i].count)
			v.vars.countLabel:setTextColor(g_i3k_get_cond_color(sortTable[i].count>=chipCfg.needChipCount))
			v.vars.btn:setTag(i)
			v.vars.btn:onClick(self, function ()
				self:importChipData(i, sortTable[i], widget)
			end)
			if i==1 then
				self:importChipData(i, sortTable[i], widget)
			end
		end
		self._treasureChipScroll = widget.vars.scroll
		if g_i3k_game_context:getIsFirstTreasure() then
			self:setTreasureChipsScrollVisiable(false)
		end
		-- 获取碎片
		widget.vars.getChipBtn:onClick(self, function()
			g_i3k_logic:OpenHostelUI()
		end)
		if g_i3k_game_context:getTreasureMapInfo()~=nil then
			widget.vars.cantText:show()
			widget.vars.hechengBtn:disableWithChildren()
			widget.vars.hechengTX:hide()
		end
	elseif l_makeMapState then--碎片已经合成，有藏宝图的状态
		local node = require("ui/widgets/yuntcbt")()
		widget.vars.scroll:stateToNoSlip()
		widget.vars.scroll:addItem(node)
		node.anis.c_yun_zhu.play()

		local name = i3k_db_treasure[mapInfo.curMap.mapID].name
		widget.vars.nameLabel:setText(name)--string.format("藏宝图：%s", name))
		local rank = i3k_db_collection[i3k_db_treasure[mapInfo.curMap.mapID].collectId].rank
		widget.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))


		--放弃藏宝图
		widget.vars.giveup:onClick(self, function ()
			local desc = i3k_get_string(15076)
			local callfunc = function (isOk)
				if isOk then
					local callback = function ()
						l_makeMapState = false
						g_i3k_game_context:setIsHaveMapCanExplore(false)
						self:loadTreasureWidget()
					end
					i3k_sbean.giveup_treasure(mapInfo.curMap.mapID, callback)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
		end)
		widget.vars.tiliLabel:setText(i3k_db_treasure_base.other.needTili)
		--探索藏宝图
		widget.vars.exploreBtn:onClick(self, self.onExplore, mapInfo.curMap.mapID)
	end
end

function wnd_activity:onExplore(sender, mapId)
	if g_i3k_game_context:IsOnHugMode() then	
		g_i3k_ui_mgr:PopupTipMessage("您现在处于双人互动中，不能进行探宝")
		return;
	end
	self:releaseSchedule()
	local child = self._rootWidget:getAddChild()
	local widget = child[1]
	local needTili = i3k_db_treasure_base.other.needTili
	local totalTili = g_i3k_game_context:GetVit()
	if needTili<=totalTili then
		local callback = function ()
			g_i3k_game_context:UseVit(i3k_db_treasure_base.other.needTili,AT_TREASURE_TOTAL_SEARCH)
			l_makeMapState = false
			g_i3k_game_context:setIsHaveMapCanExplore(false)
			l_treasureState = TREASURE_STATE_FIND

			TREASURE_EXPLORE_IS_OK = true
			widget.vars.giveup:disableWithChildren()
			widget.vars.exploreBtn:disableWithChildren()
			if TREASURE_EXPLORE_NOT_OK then
				widget.vars.scroll:getChildAtIndex(1).anis.c_yun_san.play(function()
					self:loadTreasureWidget()
				end)
			end
		end


		local time = 0
		local index = 0
		local textTable = i3k_clone(i3k_db_dialogue[i3k_db_treasure_base.other.exploreText])
		local isSetText = false
		self._exploreSC = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dTime)
			time = time + dTime
			local loadingBar = widget.vars.percentBar
			local label = widget.vars.stateLabel
			loadingBar:setPercent(time/2*100)
			widget.vars.percentRoot:show()
			if not isSetText then
				local textIndex = math.random(0, #textTable)
				textIndex = textIndex==0 and 1 or math.ceil(textIndex)
				label:setText(textTable[textIndex].txt)
				table.remove(textTable, textIndex)
				isSetText = true
			end
			if loadingBar:getPercent()>=100 then
				index = index + 1
				isSetText = false
				if index<3 then
					time = 0
				else
					widget.vars.percentRoot:hide()

					if TREASURE_EXPLORE_IS_OK then
						widget.vars.scroll:getChildAtIndex(1).anis.c_yun_san.play(function ()
							if g_i3k_ui_mgr:GetUI(eUIID_Activity) and l_treasureState==TREASURE_STATE_FIND then
								self:loadTreasureWidget()
							end
						end)
					else
						TREASURE_EXPLORE_NOT_OK = true
					end
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._exploreSC)
					self._exploreSC = nil
				end
			end
		end, 0.01, false)


		i3k_sbean.explore_treasure(mapId, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10045))
	end
end

--点击某个碎片之后导入该碎片的信息，是否可以合成、合成需要的碎片数量…
function wnd_activity:importChipData(index, chipData, widget)
	for i,v in ipairs(widget.vars.scroll:getAllChildren()) do
		v.vars.selectImg:setVisible(i==index)
	end
	local chipCfg = i3k_db_treasure_chip[chipData.chipId]
	widget.vars.chipName:setText(chipCfg.name)
	widget.vars.needCount:setText(chipCfg.needChipCount)
	if chipData.count>=chipCfg.needChipCount and not g_i3k_game_context:getTreasureMapInfo() then
		widget.vars.hechengBtn:enableWithChildren()
		widget.vars.hechengBtn:setTag(chipData.chipId)
		widget.vars.hechengBtn:onClick(self, self.hechengMap)
		widget.vars.hechengTX:show()
	else
		widget.vars.hechengBtn:disableWithChildren()
		widget.vars.hechengTX:hide()
	end
end

function wnd_activity:hechengMap(sender)
	local chipId = sender:getTag()
	local callback = function ()
		l_makeMapState = true
		g_i3k_game_context:setIsHaveMapCanExplore(true)
		self:loadTreasureWidget()
		i3k_sbean.sync_treasure()
	end
	i3k_sbean.make_map(chipId, callback)
end

--寻宝线索页签
local beforeOpenState, notOpenState, inRunState, openState = -2, -1, 0, 1--线索图不同状态
function wnd_activity:importFindTreasureData()
	local widget = self._rootWidget:getAddChild()[1]
	local mapInfo = g_i3k_game_context:getTreasureMapInfo()
	local totalPercent = 0
	local mapCfg = i3k_db_treasure[mapInfo.mapID]
	local structCfg = i3k_db_treasure_base["struct"..mapCfg.clueType]--获取线索树结构

	widget.vars.helpBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15133))
	end)
	local treeNode, treeTable = addTreeWidgetAndGetCfg(mapCfg.clueType)
	widget.vars.scroll:removeAllChildren(true)
	widget.vars.scroll:addItem(treeNode)
	--设置树结构体内容
	local mapSpotTable = mapCfg.clueSpotList--情报点列表
	for i,v in ipairs(mapSpotTable) do
		local node = treeTable[i]
		local isInRun = false
		local isFind = false
		node.percentLabel:hide()
		node.btn:setTag(v)
		local points = mapInfo.points

		if not points[i] and points[i-1] then
			node.btn:onClick(self, self.selectSpot, beforeOpenState)
		else
			node.btn:onClick(self, self.selectSpot, notOpenState)
		end
		if points[i] then
			if points[i]==0 then
				local posPercent = node.root:getPositionPercent()
				local fatherSize = node.root:getParent():getContentSize()
				local pos = {x = fatherSize.width*posPercent.x, y = fatherSize.height*posPercent.y}
				treeNode.vars.anisNode:setPosition(pos)
				local size = node.root:getSizePercent()
				treeNode.vars.anisNode:setSizePercent(size)
				isInRun = true
				node.btn:onClick(self, self.selectSpot, inRunState)
				self:selectSpot(node.btn, inRunState)
				node.percentLabel:setTextColor(g_i3k_get_white_color())
				node.lightImg:setImage(g_i3k_db.i3k_db_get_icon_path(1333))
				for _,r in ipairs(node.lineTable) do
					r:setImage(g_i3k_db.i3k_db_get_icon_path(1329))
				end
				local callback = function ()
					mapInfo.points[i] = 1
					if mapSpotTable[i+1] then
						mapInfo.points[i+1] = 0
					end
					g_i3k_game_context:setTreasureMapInfo(mapInfo)
					self:importFindTreasureData()
				end
				widget.vars.gotoTaskBtn:setTag(mapInfo.mapID)
				widget.vars.gotoTaskBtn:onClick(self, self.goToTask, i)
			elseif points[i]==1 then
				if not mapSpotTable[i+1] then
					treeNode.vars.anisNode:hide()
				end
				isFind = true
				totalPercent = totalPercent + node.percent
				node.btn:onClick(self, self.selectSpot, openState)
				node.percentLabel:setTextColor(g_i3k_get_green_color())
				node.lightImg:setImage(g_i3k_db.i3k_db_get_icon_path(1334))
				if not points[i+1] then
					for _,r in ipairs(node.lineTable) do
						r:setImage(g_i3k_db.i3k_db_get_icon_path(1329))
					end
					self:selectSpot(node.btn, openState)
				end
			end
			node.percentLabel:show()
		end
		local spotCfg = i3k_db_spot_list[v]
		node.lightImg:setVisible(isFind or isInRun)
		node.darkImg:setVisible(not node.lightImg:isVisible())
		node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(spotCfg.iconID))
		node.percentLabel:setText(node.percent.."%")
	end
	widget.vars.scroll:stateToNoSlip()
	widget.vars.scroll:setBounceEnabled(false)

	--设置树结构上边的部分
	widget.vars.nameLabel:setText(i3k_db_treasure[mapInfo.mapID].name)
	local rank = i3k_db_collection[i3k_db_treasure[mapInfo.mapID].collectId].rank
	widget.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))
	widget.vars.percent:setPercent(totalPercent)
	widget.vars.percentLabel:setText(totalPercent.."%")

	--widget.vars.box:hide()
	--差判断领过第几个奖励
	local rewardPercentTable = {
		[1] = mapCfg.percent1,
		[2] = mapCfg.percent2,
		[3] = mapCfg.percent3,
	}
	if totalPercent<rewardPercentTable[1] then
		widget.vars.box:disable()
		widget.anis.c_box:quit()
	else
		widget.vars.box:enable()
		widget.anis.c_box:play()
		for i,v in ipairs(rewardPercentTable) do
			if totalPercent>=v then
				widget.vars.box:onClick(self, function ()
					if totalPercent<100 then
						local desc = i3k_get_string(324)
						local callfunc = function (isOk)
							if isOk then
								i3k_sbean.take_map_reward(totalPercent)
							end
						end
						g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
					else
						i3k_sbean.take_map_reward(totalPercent)
					end
				end)
			end
		end
	end


	local callback = function ()
		l_treasureState = TREASURE_STATE_CHIP
		g_i3k_game_context:setTreasureMapInfo(nil)
		--self:loadTreasureWidget()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "loadTreasureWidget")
	end
	widget.vars.giveupBtn:onClick(self, function ()
		local desc = i3k_get_string(323)--string.format("%s", "放弃藏宝图的提示")
		local callfunc = function (isOk)
			if isOk then
				i3k_sbean.giveup_treasure(mapInfo.mapID, callback)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
	end)
end

function wnd_activity:takeTreasureReward()
	l_treasureState = TREASURE_STATE_CHIP
	g_i3k_game_context:setTreasureMapInfo(nil)
	self:loadTreasureWidget()
end

function wnd_activity:goToTask(sender, index)
	local taskTable = {
		[1] = "kill monsters",
		[2] = "NPC dialogue",
		[3] = "dig metal",
		[4] = "screct box",
	}
	local treasureMapId = sender:getTag()
	local mapCfg = i3k_db_treasure[treasureMapId]
	local spotCfg = i3k_db_spot_list[mapCfg.clueSpotList[index]]
	--i3k_log("task: "..taskTable[spotCfg.spotType])
	finishTheTask(spotCfg)
end

--选择一个情报点，显示出对应的树结构下边数据
function wnd_activity:selectSpot(sender, state)--state有四种状态，1已经探索过，0处于正要探索，-1前置未探索过，-2前置已经探索过的
	local stateTable = {
		[-2]	= 15033,
		[-1]	= 15033,
		[0]		= 15034,
		[1]		= 15035,
	}
	local widget = self._rootWidget:getAddChild()[1]
	local tag = sender:getTag()
	local spotCfg = i3k_db_spot_list[sender:getTag()]
	local nameText = state>=0 and spotCfg.name or "???"
	widget.vars.clueStateLabel:setText(nameText..i3k_get_string(stateTable[state]))
	local desc = i3k_db_dialogue[spotCfg.descTextId][1].txt
	desc = state<0 and i3k_get_string(15036) or (state==1 and i3k_get_string(15037)) or desc
	widget.vars.clueDescLabel:setText(desc)
	if state==inRunState then
		widget.vars.gotoTaskBtn:enableWithChildren()
	else
		widget.vars.gotoTaskBtn:disableWithChildren()
	end
	--帮助
	widget.vars.bangzhuBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15168))
	end)
end





--[[function 收藏品()
	end--]]
function wnd_activity:importCollectionData()

	local child = self._rootWidget:getAddChild()
	local widget = child[1]

	local count = 0
	local sortTable = {}
	for i,v in pairs(i3k_db_collection) do
		count = count + 1
		table.insert(sortTable, v)
	end
	table.sort(sortTable, function (a, b)
		return a.id < b.id
	end)
	widget.vars.scroll:setBounceEnabled(false)
	local children = widget.vars.scroll:addChildWithCount("ui/widgets/cbtt", 4, count)
	local isFirst = true
	for i,v in ipairs(children) do
		local collectionId = sortTable[i].id
		local collection = g_i3k_game_context:getCollectionWithId(collectionId)
		v.vars.darkImg:setVisible( collection == nil)--根据是否有当前的藏品决定显隐
		if v.vars.darkImg:isVisible() then
			v.vars.mountImg:hide()
			v.vars.an11:hide()
		else
			v.vars.mountImg:setVisible(g_i3k_game_context:testCollectionIsMounted(collectionId))
			v.vars.an11:setVisible(collection.isEdge)
		end
		local iconPath = g_i3k_db.i3k_db_get_icon_path(sortTable[i].iconID)
		v.vars.gradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(sortTable[i].rank))
		v.vars.icon:setImage(iconPath)
		v.vars.btn:setTag(collectionId)
		v.vars.btn:onClick(self, function ()
			_collectionIndex = i
			self:checkCollectionInfo(v.vars.btn, widget)
		end)--self.checkCollectionInfo, widget)
		v.vars.selectImg:hide()
		if isFirst and not v.vars.darkImg:isVisible() then
			_collectionIndex = i
			self:checkCollectionInfo(v.vars.btn, widget)
			v.vars.selectImg:show()
			isFirst = false
		end
	end
	if isFirst then
		self:checkCollectionInfo(children[_collectionIndex].vars.btn, widget)
		children[_collectionIndex].vars.selectImg:show()
	end
end

function wnd_activity:checkCollectionInfo(sender, widget)
	local children = widget.vars.scroll:getAllChildren()
	local mountImg
	local edgeImg
	for i,v in ipairs(children) do
		if v.vars.btn:getTag()==sender:getTag() then
			mountImg = v.vars.mountImg
			edgeImg = v.vars.an11
		end
		v.vars.selectImg:setVisible(v.vars.btn:getTag()==sender:getTag())
	end
	local attrTable = {}
	for i=1, 2 do
		attrTable[i] = {}
		attrTable[i].root = widget.vars["attrRoot"..i]
		attrTable[i].nameLabel = widget.vars["attrNameLabel"..i]
		attrTable[i].valueLabel = widget.vars["attrValueLabel"..i]
		attrTable[i].addLabel = widget.vars["addLabel"..i]
	end
	local collectionId = sender:getTag()
	local collectionCfg = i3k_db_collection[collectionId]

	widget.vars.nameLabel:setText(collectionCfg.name)
	widget.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(collectionCfg.rank))
	widget.vars.descLabel:setText(collectionCfg.desc)
	local starTable = {
		[1] = widget.vars.star1,
		[2] = widget.vars.star2,
		[3] = widget.vars.star3,
	}
	for i,v in ipairs(starTable) do
		v:setVisible(i<=collectionCfg.rank)
	end
	for i,v in ipairs(i3k_db_treasure) do
		if v.collectId==collectionId then
			widget.vars.fromLabel:setText(i3k_get_string(15077, v.name))
			break
		end
	end
	local collection = g_i3k_game_context:getCollectionWithId(collectionId)
	for i,v in ipairs(attrTable) do
		v.root:hide()
		if collectionCfg["attrId"..i]>=0 then
			v.root:show()
			v.nameLabel:setText(g_i3k_db.i3k_db_get_property_name(collectionCfg["attrId"..i]))
			v.valueLabel:setText(collectionCfg["attrValue"..i])
			local attrValueNums = collectionCfg["attrValue"..i]
			if collection and collection.isEdge then
				attrValueNums = attrValueNums * 2
			end
			v.addLabel:setText("+"..attrValueNums)
			v.addLabel:setVisible(g_i3k_game_context:testCollectionIsMounted(collectionId))
		end
	end

	local MountCount = self:getMountCount(g_i3k_game_context:getAllCollection())
	widget.vars.des:hide() --镶边需要
	widget.vars.edgeRoot:hide()
	widget.vars.mountBtn:hide()
	if collection and collection.isMount then
		widget.vars.edgeRoot:show()
		if collection.isEdge then
			widget.vars.edgeBtn:disableWithChildren()
			widget.vars.edgeLabel:setText(i3k_get_string(17718))
		else
			widget.vars.des:show()
			if MountCount >= collectionCfg.needMountCount then
				widget.vars.edgeBtn:enableWithChildren()
			else
				widget.vars.edgeBtn:disableWithChildren()
			end
			widget.vars.des:setText(i3k_get_string(17723, collectionCfg.needMountCount <= MountCount and "green" or "red", MountCount, collectionCfg.needMountCount))
			widget.vars.edgeLabel:setText(i3k_get_string(17717))
			widget.vars.edgeBtn:onClick(self, self.mountCollection, {id = collection.id,rootBtn = widget.vars.edgeRoot,  btn = widget.vars.edgeBtn, nameLabel = widget.vars.edgeLabel, mountImg = mountImg, attrTable = attrTable, edgeImg = edgeImg, needMount = widget.vars.des})
		end
	else
		widget.vars.mountBtn:show()
	if not collection then
		widget.vars.mountBtn:disableWithChildren()
			widget.vars.mountLabel:setText(i3k_get_string(17724))
	else
		widget.vars.mountBtn:enableWithChildren()
			widget.vars.mountLabel:setText(i3k_get_string(17724))
			widget.vars.mountBtn:onClick(self, self.mountCollection, {id = collection.id, mountBtn = widget.vars.mountBtn,  rootBtn = widget.vars.edgeRoot, btn = widget.vars.edgeBtn, nameLabel = widget.vars.edgeLabel, mountImg = mountImg, attrTable = attrTable, edgeImg = edgeImg, needMount = widget.vars.des})
			widget.vars.edgeBtn:onClick(self, self.mountCollection, {id = collection.id,rootBtn = widget.vars.edgeRoot,  btn = widget.vars.edgeBtn, nameLabel = widget.vars.edgeLabel, mountImg = mountImg, attrTable = attrTable, edgeImg = edgeImg, needMount = widget.vars.des})
		end
	end
end
function wnd_activity:getMountCount(collection)
	local mountCount = 0
	for k,v in pairs(collection) do
		if v.isMount then
			mountCount = mountCount + 1
		end
	end
	return mountCount
end

--装裱按钮点击回调
--1:普通装裱
--2:元宝装裱
function wnd_activity:mountCollection(sender, needValue)
	local callback
	local collection = g_i3k_game_context:getCollectionWithId(needValue.id)	
	if collection.isMount then
		callback = function ()
			if needValue.needMount  then
				needValue.needMount:hide()
			end
			if needValue.edgeImg then
				needValue.edgeImg:show()
			end
			needValue.btn:disableWithChildren()
			needValue.nameLabel:setText(i3k_get_string(17718))
			local collectionCfg = i3k_db_collection[needValue.id]
			for i,v in ipairs(needValue.attrTable) do
				v.addLabel:show()
				v.addLabel:setText("+"..collectionCfg["attrValue"..i]*2)
			end
		end
	else
		local collectionCfg = i3k_db_collection[needValue.id]
		
		callback = function ()
		local MountCount = self:getMountCount(g_i3k_game_context:getAllCollection())
		if needValue.mountImg then
			needValue.mountImg:show()
		end
			if needValue.rootBtn  then
				needValue.rootBtn:show()
			end
			if needValue.mountBtn then
				needValue.mountBtn:hide()
			end
			if MountCount >= collectionCfg.needMountCount then
				needValue.btn:enableWithChildren()
			else
		needValue.btn:disableWithChildren()
			end
			if needValue.needMount then
				needValue.needMount:show()
				needValue.needMount:setText(i3k_get_string(17723, collectionCfg.needMountCount <= MountCount and "green" or "red", MountCount, collectionCfg.needMountCount))
				--needMount:setTextColor(g_i3k_get_cond_color(collectionCfg.needMountCount <= curCount))  -- 需要
			end
			needValue.nameLabel:setText(i3k_get_string(17717))
		for i,v in ipairs(needValue.attrTable) do
			v.addLabel:show()
		end
		end		
	end
	g_i3k_ui_mgr:OpenUI(eUIID_MountCollection)
	g_i3k_ui_mgr:RefreshUI(eUIID_MountCollection, needValue.id, callback)
end



--刷新藏宝图的右侧视图
local treasureStatePath =
{
	[1] = "ui/widgets/baotucanpian",
	[2] = "ui/widgets/xunbao",
	[3] = "ui/widgets/shoucangping",
	[4] = "ui/widgets/baotucanpian", -- sousuo干掉
}
function wnd_activity:loadTreasureWidget()
	local widgetId = (l_treasureState == TREASURE_STATE_CHIP and l_makeMapState) and 4 or l_treasureState
	self:releaseSchedule()
	local widget = require(treasureStatePath[widgetId])()
	self:setState(g_TREASURE_STATE)
	self:addChildWidget(widget)
	if widgetId == 4 then
		widget.vars.baotuRoot:hide()
		widget.vars.sousuoRoot:show()
		widget.vars.percentRoot:hide()
	end
	if widgetId == 2 then
		-- local mapInfo = g_i3k_game_context:getTreasureMapInfo()
		-- if g_i3k_game_context:getCollectionWithId(mapInfo.collectId) then
			widget.vars.saodangBtn:onClick(self, self.OnSaoDangBtn)
		-- else
		-- 	widget.vars.saodangBtn:stateToPressedAndDisable()
		-- end
	end
	if widget.vars.helpBtn then
		widget.vars.helpBtn:onClick(self, function ()
			g_i3k_ui_mgr:ShowHelp(i3k_get_string(15168))
		end)
	end

	local tabBar =
	{
		[1] = widget.vars.chipBtn,
		[2] = widget.vars.findBtn,
		[3] = widget.vars.collectionBtn,
	}
	for i, v in ipairs(tabBar) do
		v:onClick(self, function ()
			if i ~= 2 then
				l_treasureState = i
				self:loadTreasureWidget()
			else
				local mapInfo = g_i3k_game_context:getTreasureMapInfo()
				if mapInfo and mapInfo.mapID ~= 0 and mapInfo.open ~= 0 then
					l_treasureState = i
					self:loadTreasureWidget()
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15078))
				end
			end
		end)
		if i == l_treasureState then
			v:stateToPressedAndDisable()
		end
	end
	if l_treasureState == TREASURE_STATE_CHIP then
		i3k_sbean.sync_treasure()
	elseif l_treasureState == TREASURE_STATE_FIND then
		self:importFindTreasureData()
	else
		self:importCollectionData()
	end
end


function wnd_activity:OnSaoDangBtn(sender)
	local mapInfo = g_i3k_game_context:getTreasureMapInfo()
	if g_i3k_game_context:getCollectionWithId(i3k_db_treasure[mapInfo.mapID].collectId) then
		i3k_sbean.saodangTreasureMap()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17008))
	end
end


--[[function 五绝试炼()
end--]]
function wnd_activity:reloadFiveUniqueActivity(dayTimesBuy,dayTimesUsed,finishFloors)
	local user_cfg = g_i3k_game_context:GetUserCfg()
	local index = user_cfg:GetSelectFiveUnique()
	self:setState(g_TOWER_STATE)
	local widget = require("ui/widgets/wujueshilian")()
	self:addChildWidget(widget)
	---显示当前随机到的五绝,其他阴影
	local widgets = widget.vars
	self:updateAllBossIcon(widget,index)
	for k,v in ipairs(i3k_db_climbing_tower) do

		if index == k then
			self:SetModule(k,v.modelId,widget)
			local dialogueID = i3k_db_climbing_tower[index].dialogueID
			local maxCount = #i3k_db_dialogue[dialogueID]
			local tmp_dialogue = i3k_db_dialogue[dialogueID][math.random(1,maxCount)].txt
			widget.vars.dialogue:setText(tmp_dialogue)
			widget.anis.c_ck.play()
		else
			--虚影
		end

	end

	self._groupId = index

	local info = {id = index, buyTimes = dayTimesBuy,usedTimes = dayTimesUsed}

	local exploits_data = {id = index, level = level,buyTimes = dayTimesBuy,usedTimes = dayTimesUsed}
	widget.vars.refreshBtn:onClick(self, self.onClickEnterBtn, true)---进入试炼
	widget.vars.exploits_btn:onClick(self, self.onClickExploitsBtn,info )---战绩
	widget.vars.prestige_btn:onClick(self, self.onClickPrestigeBtn ,info)---声望
end

--添加所有boss头像
function wnd_activity:updateAllBossIcon(widget,index)
	for i=1, #i3k_db_climbing_tower do
		local tmp_bossBtn = string.format("bossBtn%s",i)
		local tmp_bossIcon = string.format("bossIcon%s",i)
		local tmp_bossSelect = string.format("bossSelect%s",i)
		local bossBtn = widget.vars[tmp_bossBtn]
		local bossIcon = widget.vars[tmp_bossIcon]
		local bossSelect = widget.vars[tmp_bossSelect]
		bossSelect:hide()
		if i == index then
			bossSelect:show()
		end
		bossIcon:setImage(g_i3k_db.i3k_db_get_head_icon_path(i3k_db_climbing_tower[i].iconId))
		bossBtn:setTag(i3k_db_climbing_tower[i].modelId)
		bossBtn:onClick(self,self.onSelectBoss,{widget = widget,index = i})

	end
end

function wnd_activity:onSelectBoss(sender,args)
	local index = args.index

	for i=1, #i3k_db_climbing_tower do
		local tmp_bossBtn = string.format("bossBtn%s",i)
		local bossBtn = args.widget.vars[tmp_bossBtn]
		local tmp_bossSelect = string.format("bossSelect%s",i)
		local bossSelect = args.widget.vars[tmp_bossSelect]
		if i == index then
			bossSelect:show()
		else
			bossSelect:hide()
		end
	end
	local user_cfg = g_i3k_game_context:GetUserCfg()
	user_cfg:SetSelectFiveUnique(index)
	--i3k_sbean.sync_activities_tower()--同步爬塔
	self:updateModel(i3k_db_climbing_tower[index].modelId,args.widget,user_cfg:GetSelectFiveUnique())
end

function wnd_activity:updateModel(id,widget,lastIndex)
		local tmp = self._fiveUnique_model_id
		local index = 1

		for k,v in ipairs(self._fiveUnique_model_id) do
			if v == id then
				index = k
			end
		end
		local dialogueIndex = 1
		for k,v in ipairs(i3k_db_climbing_tower) do
			if v.modelId == id then
				dialogueIndex = k
			end
		end
		self._groupId = dialogueIndex
		widget.vars.dialogueRoot:show()
		local dialogueID = i3k_db_climbing_tower[dialogueIndex].dialogueID
		local maxCount = #i3k_db_dialogue[dialogueID]
		local tmp_dialogue = i3k_db_dialogue[dialogueID][math.random(1,maxCount)].txt
		widget.vars.dialogue:setText(tmp_dialogue)
		widget.anis.c_ck.play()

		if index  ==  1 then
			return
		end
		local model1 = self._fiveUnique_model_id[1]
		local modelT = self._fiveUnique_model_id[index]
		self._fiveUnique_model_id[1] = id
		self._fiveUnique_model_id[index] = model1


		local path = i3k_db_models[modelT].path
		local uiscale = i3k_db_models[modelT].uiscale
		local tmp_str = string.format("model%s",1)
		widget.vars[tmp_str]:setSprite(path)
		widget.vars[tmp_str]:setSprSize(uiscale)
		widget.vars[tmp_str]:setColor(0xffd0d0d0)
		local state = i3k_db_climbing_tower[index].modelActList
		for k,v in ipairs(i3k_db_climbing_tower) do
			if v.modelId == modelT then
				state = v.modelActList
				break
			end
		end
		widget.vars[tmp_str]:pushActionList(state[1],1)--"stand",1
		widget.vars[tmp_str]:pushActionList(state[2],-1)
		widget.vars[tmp_str]:playActionList()--


		local tmp_str = string.format("model%s",index)
		local path = i3k_db_models[model1].path
		local uiscale = i3k_db_models[model1].uiscale
		widget.vars[tmp_str]:setSprite(path)
		widget.vars[tmp_str]:setSprSize(uiscale)
		local state = i3k_db_climbing_tower[index].modelActList
		for k,v in ipairs(i3k_db_climbing_tower) do
			if v.modelId == model1 then
				state = v.modelActList
				break
			end
		end
		widget.vars[tmp_str]:pushActionList(state[1],1)--"stand",1
		widget.vars[tmp_str]:pushActionList(state[2],-1)
		widget.vars[tmp_str]:playActionList()--
		if index == 2 or index == 5 then
			widget.vars[tmp_str]:setColor(0xff354a90)
		else
			widget.vars[tmp_str]:setColor(0xff162042)
		end

end

function wnd_activity:onModle(sender,args)
	local index = args.index
	local widget = args.widget

	for i = 1,#i3k_db_climbing_tower do

		local tmp_bossSelect = string.format("bossSelect%s",i)

		local tmp_bossBtn = string.format("bossBtn%s",i)
		local tmp_bossSelect = string.format("bossSelect%s",i)
		local bossSelect = widget.vars[tmp_bossSelect]
		local bossBtn = widget.vars[tmp_bossBtn]
		bossSelect:hide()
		if self._fiveUnique_model_id[index] == bossBtn:getTag() then
			bossSelect:show()
			i3k_get_load_cfg():SetSelectFiveUnique(i)
		end
	end

	self:updateModel(self._fiveUnique_model_id[index],widget)
end

--添加模型 id
function wnd_activity:SetModule(index,id,widget)----模型id

	--local path = i3k_db_models[id].path
	--local uiscale = i3k_db_models[id].uiscale


	---widget.model1:setSprite(path)
	--widget.model1:setSprSize(uiscale)
	--local state = i3k_db_climbing_tower[index].modelActList
	--self._layout.vars.hero_module:playAction("stand") --
	--widget.model1:pushActionList(state[1],1)--"stand",1
	--widget.model1:pushActionList(state[2],-1)
	--widget.model1:playActionList()--
	for i,v in ipairs(i3k_db_climbing_tower) do
		local tmp_str = string.format("model%s",i)
		if i == 1 then
			self._fiveUnique_model_id[i] = id
			local path = i3k_db_models[id].path
			local uiscale = i3k_db_models[id].uiscale

			widget.vars[tmp_str]:setSprite(path)
			widget.vars[tmp_str]:setSprSize(uiscale)
			local state = i3k_db_climbing_tower[index].modelActList
			--self._layout.vars.hero_module:playAction("stand") --
			widget.vars[tmp_str]:pushActionList(state[1],1)--"stand",1
			widget.vars[tmp_str]:pushActionList(state[2],-1)
			widget.vars[tmp_str]:playActionList()--
			widget.vars[tmp_str]:onClick(self,self.onModle,{index = i,widget = widget,model = id})
		else
			if not i3k_db_climbing_tower[index + 1] then
				index = 0
			end
			index = index + 1

			local id = i3k_db_climbing_tower[index].modelId
			self._fiveUnique_model_id[i] = id
			local path = i3k_db_models[id].path
			local uiscale = i3k_db_models[id].uiscale
			widget.vars[tmp_str]:setSprite(path)
			widget.vars[tmp_str]:setSprSize(uiscale)
			local state = i3k_db_climbing_tower[index].modelActList
			--self._layout.vars.hero_module:playAction("stand") --
			widget.vars[tmp_str]:pushActionList(state[1],1)--"stand",1
			widget.vars[tmp_str]:pushActionList(state[2],-1)
			widget.vars[tmp_str]:playActionList()--
			widget.vars[tmp_str]:onClick(self,self.onModle,{index = i,widget = widget,model = id})
			if i == 2 or i == 5 then
				widget.vars[tmp_str]:setColor(0xff354a90)
			else
				widget.vars[tmp_str]:setColor(0xff162042)
			end
		end
	end
end


function wnd_activity:onClickPrestigeBtn(sender, needValue)
	---发声望同步协议
	i3k_sbean.sync_fame_tower(self._groupId)

end
function wnd_activity:onClickExploitsBtn(sender, needValue)

	---发战绩协议
	i3k_sbean.sync_record_tower(needValue.id)

end
function wnd_activity:onClickEnterBtn(sender,args)
	--g_i3k_ui_mgr:PopupTipMessage("进入试炼")
	--self:enterFiveUniqueActivity(needValue.groupId,needValue)
	i3k_sbean.sync_activities_tower(args)

end
function wnd_activity:enterFiveUniqueActivity(info,seq)
	local widget = require("ui/widgets/shilianjm")()
	local user_cfg = g_i3k_game_context:GetUserCfg()
	local groupId = user_cfg:GetSelectFiveUnique()
	self:setState(g_TOWER_STATE)
	self:addChildWidget(widget)
	self._canset = true
	self._lvl = g_i3k_game_context:GetLevel()
	self._power = g_i3k_game_context:GetRolePower()
	local level = info.history[groupId] or 0
	local maxLevel = #i3k_db_climbing_tower_datas[groupId]--#i3k_db_climbing_tower_prestige[groupId]
	if level == 0 then
		level = 1
	elseif level < maxLevel then
		level = level +1
	end
	widget.vars.backBtn:onClick(self, self.onClickEnterBtn)
	widget.vars.rightBtn:onClick(self,self.onFiveUniqueRight)
	widget.vars.leftBtn:onClick(self,self.onFiveUniqueLeft)
	widget.vars.batchSweep:onClick(self, self.onBatchSweep, info)

	self._bestFloor = info.history[groupId] or 0
	self._usedTimes = info.dayTimesUsed
	self._buyTimes = info.dayTimesBuy
	local fbId = i3k_db_climbing_tower_datas[groupId][level].fbID

	self:setFiveUniqueActivitySelectFloors(groupId,info,widget,fbId,seq)
	if seq and seq < maxLevel then
		level = seq+1
	end

	self:setFiveUniqueActivityData(groupId,level ,widget,fbId,info.finishFloors[groupId],info.dayTimesBuy,info.dayTimesUsed)--info.bestFloor


end

function wnd_activity:onFiveUniqueLeft(sender)
	local user_cfg = g_i3k_game_context:GetUserCfg()
	local groupId = user_cfg:GetSelectFiveUnique()
	groupId = groupId - 1
	if groupId == 0 then
		groupId = #i3k_db_climbing_tower
	end
	user_cfg:SetSelectFiveUnique(groupId)
	i3k_sbean.sync_activities_tower(true)
end

function wnd_activity:onFiveUniqueRight(sender)
	local user_cfg = g_i3k_game_context:GetUserCfg()
	local groupId = user_cfg:GetSelectFiveUnique()
	groupId = groupId + 1
	if groupId == #i3k_db_climbing_tower + 1 then
		groupId = 1
	end
	user_cfg:SetSelectFiveUnique(groupId)
	i3k_sbean.sync_activities_tower(true)
end

function wnd_activity:onBatchSweep(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_FiveUniqueBatchSweep)
	g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniqueBatchSweep, info, self._bestFloor)
end

function wnd_activity:setFiveUniqueActivityData(groupID,level,widget,fbId,finishFloors,dayTimesBuy,dayTimesUsed)

	widget.vars.highest:setText(string.format("个人历史最高：%s",self._bestFloor))--记录最高记录
	widget.vars.nameLabel:setText(string.format("%s试炼",i3k_db_climbing_tower[groupID].name))
	local l_fbId = i3k_db_climbing_tower_datas[groupID][level].fbID
	local totalTimes = i3k_db_climbing_tower_args.maxattackTimes + dayTimesBuy
	g_i3k_game_context:SetTowerChallengeTimes(dayTimesUsed,dayTimesBuy , totalTimes)
	local tb = {groupId = groupID, bestFloor = level,dayTimesBuy = dayTimesBuy,dayTimesUsed = dayTimesUsed,fbId = l_fbId ,_layer = widget, finishFloors = finishFloors}--info = info
	g_i3k_game_context:setSecretareaTaskInfo(tb)
	widget.vars.secretarea_btn:onClick(self, self.onClickSecretareaBtn,tb )			---秘境
	widget.vars.refreshBtn:onClick(self, self.onClickGoOutBtn )						---出战设置
	local havetimes = i3k_db_climbing_tower_args.maxattackTimes+dayTimesBuy-dayTimesUsed
	widget.vars.challengeTimeLabel:setText(havetimes)								---剩余次数
	widget.vars.add_btn:onClick(self, self.onClickAddBtn,tb )						---添加次数
	widget.vars.challenge_btn:onClick(self, self.onClickChallengeBtn,tb )			---挑战
	widget.vars.sweep_btn:onClick(self, self.onClickSweepBtn,tb )					---扫荡
	widget.vars.desc:setText(i3k_db_climbing_tower_datas[groupID][level].desc)		---关卡描述

	widget.vars.opposite_side:setText("对手特点："..i3k_db_climbing_tower_datas[groupID][level].oppositeDesc)--对方特点

	widget.vars.consumeVit:setText("x"..i3k_db_climbing_tower_fb[l_fbId].enterConsume)--消耗体力 fbId

	--帮助  --五绝
	widget.vars.helpBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15167))
	end)
	local needPower = i3k_db_climbing_tower_fb[l_fbId].powerNeed--fbId
	local needLvl = i3k_db_climbing_tower_fb[l_fbId].enterLvl

	if self._bestFloor > 0  then-- 有记录时or info.finishFloors
		if self._lvl>= needLvl and self._power>=needPower and level>=1 and level <= self._bestFloor+1 and not finishFloors[level]  then --满足条件可以点击挑战按钮
			--i3k_log("can ----- ++++++++ = ",self._bestFloor,self._lvl,needLvl,self._power,needPower,level,finishFloors[level])
			widget.vars.challenge_btn:enableWithChildren()
		else
			widget.vars.challenge_btn:disableWithChildren()
		end
	else
		if self._lvl>= needLvl and self._power>=needPower  then --满足条件可以点击挑战按钮
			widget.vars.challenge_btn:enableWithChildren()
		else
			widget.vars.challenge_btn:disableWithChildren()
		end
	end
	if finishFloors[level]  then  --完成当前选中关卡   --不显示体力
		--widget.vars.tili:disable()--置灰
		widget.vars.tili:setVisible(false)
		widget.vars.desLabel:setVisible(true)
    else
		widget.vars.tili:setVisible(true)
		widget.vars.desLabel:setVisible(false)
	end
	--i3k_log("---------- = ",self._bestFloor,self._lvl,needLvl,self._power,needPower,level,finishFloors[level],i3k_table_length(finishFloors))

	---判断秘境显隐
	local secretareaTaskId,value,reward =  g_i3k_game_context:getSecretareaTaskId()

	if secretareaTaskId == 0 and reward == 1 then
		widget.vars.secretarea_btn:hide()
	else
		widget.vars.secretarea_btn:show()
	end

	--判断扫荡的显隐
	local arg = i3k_db_climbing_tower_args.sweeparg--扫荡参数 1~(arg*记录+1)可以扫荡
	local hight = arg*self._bestFloor + 1

	if self._bestFloor == 0 then
		widget.vars.sweep_btn:hide()
	else

		if level>=1 and level <= hight  and not finishFloors[level]then
			widget.vars.sweep_btn:show()--enableWithChildren()
		else
			widget.vars.sweep_btn:hide()
		end
	end

	local group_id,floor,fb_id = g_i3k_game_context:getTowerSweep()
	if group_id>0 and groupID==group_id and level==floor then--该关已经扫荡过
		widget.vars.sweep_btn:disableWithChildren()
	else
		widget.vars.sweep_btn:enableWithChildren()
	end
end

---选择关卡
function wnd_activity:setFiveUniqueActivitySelectFloors(groupId,info,widget,fbId,seq)
	--显示选中的关卡

	local count = #i3k_db_climbing_tower_datas[groupId]
	local num = 1

	self.alreadyUnlock = 0

	widget.vars.scroll1:setBounceEnabled(false)
	---最顶层关卡

	local top_node = require(TOPLEVEL)()
	widget.vars.scroll1:addItem(top_node)--
	local top_children =  widget.vars.scroll1:getChildAtIndex(1)
	local top_pos = top_children.rootVar:getPositionInScroll(widget.vars.scroll1)
	local top_fbID = i3k_db_climbing_tower_datas[groupId][count].fbID
	self:setShowLevelLock(count,info.history[groupId] or 0,top_node)

	self:setShowLevelAndPowerLabel(top_fbID,top_node)


	if count %2 ==1 then --总共奇数关卡
		top_node.vars.bg_image:show()
		top_node.vars.left_image:hide()
		--top_node.rootVar:setPositionInScroll(widget.vars.scroll1,top_pos.x,top_pos.y)--- +170
		top_node.vars.floorImg:setPositionX(top_pos.x+85)
	else
		top_node.vars.left_image:show()
		top_node.vars.bg_image:hide()
		--top_node.rootVar:setPositionInScroll(widget.vars.scroll1,top_pos.x-170,top_pos.y)
		top_node.vars.floorImg:setPositionX(top_pos.x-85)
	end
	local top_children1 =  widget.vars.scroll1:getChildAtIndex(1)
	local top_pos1 = top_children1.rootVar:getPositionInScroll(widget.vars.scroll1)

	top_node.vars.floor_text:setText(string.format("第%d%s",count,"关"))

	top_node.vars.showselect:hide()
	local top_type = i3k_db_climbing_tower_datas[groupId][count].levelType
	top_node.vars.level_bg:setImage(g_i3k_db.i3k_db_get_icon_path(levelTypeTbl[top_type]))

	local top_tb = {groupId = groupId,bestFloor = count ,info = info, _layer = widget,fbId = top_fbID,dayTimesBuy = info.dayTimesBuy,dayTimesUsed =info.dayTimesUsed,finishFloors = info.finishFloors[groupId] }
	top_node.vars.floor_btn:onClick(self, self.onClickSelect,top_tb )





	---中间关卡
	local number = count - 1
	for i=number,2,-1 do

		local fb_id = i3k_db_climbing_tower_datas[groupId][i].fbID

		num = num + 1
		local node = require("ui/widgets/shilianjmt")()

		node.vars.showselect:hide()
		local l_type = i3k_db_climbing_tower_datas[groupId][i].levelType
		node.vars.level_bg:setImage(g_i3k_db.i3k_db_get_icon_path(levelTypeTbl[l_type]))

		local tb = {groupId = groupId,bestFloor = i ,info = info, _layer = widget,fbId = fb_id,dayTimesBuy = info.dayTimesBuy,dayTimesUsed =info.dayTimesUsed,finishFloors = info.finishFloors[groupId] }
		node.vars.floor_btn:onClick(self, self.onClickSelect,tb )
		--node.vars.floor_btn:onTouchEvent(self,self.onClickSelect, tb)
		node.vars.floor_text:setText(string.format("第%d%s",i,"关"))

		self:setShowLevelLock(i,info.history[groupId] or 0,node)

		self:setShowLevelAndPowerLabel(fb_id,node)

		widget.vars.scroll1:addItem(node)--



			local children1 =  widget.vars.scroll1:getChildAtIndex(num)

			local pos = children1.rootVar:getPositionInScroll(widget.vars.scroll1)
			local size = children1.rootVar:getSizeInScroll(widget.vars.scroll1)
			if count %2 ==1 then --总共奇数关卡
				if num %2 ~=1 then
					node.vars.bg_image:setImage(g_i3k_db.i3k_db_get_icon_path(LEFT_LADDER))--向左

					node.rootVar:setPositionInScroll(widget.vars.scroll1,pos.x,pos.y)
				else
					node.vars.bg_image:setImage(g_i3k_db.i3k_db_get_icon_path(RIGHT_LADDER))--向右
					node.vars.floorImg:setPositionX(pos.x+85)
					--node.rootVar:setPositionInScroll(widget.vars.scroll1,pos.x+170,pos.y)
				end
			else
				if num %2 ~=1 then--偶数
					node.vars.bg_image:setImage(g_i3k_db.i3k_db_get_icon_path(RIGHT_LADDER))--RIGHT_LADDER
					node.vars.floorImg:setPositionX(pos.x+85)
					--node.rootVar:setPositionInScroll(widget.vars.scroll1,pos.x+170,pos.y)-- 170
				else
					node.vars.bg_image:setImage(g_i3k_db.i3k_db_get_icon_path(LEFT_LADDER))--LEFT_LADDER

					node.rootVar:setPositionInScroll(widget.vars.scroll1,pos.x,pos.y)
				end
				local p = node.rootVar:getPositionInScroll(widget.vars.scroll1)
				--i3k_log("----------------- weizhi is ===== : ",p.x,p.y,size.x,size.y,num)
			end



	end

	---最底部关卡
	local buttom_node = require(BUTTOMLEVEL)()
	local buttom_index = count - number
	buttom_node.vars.floor_text:setText(string.format("第%d%s",buttom_index,"关"))
	widget.vars.scroll1:addItem(buttom_node)--
	local buttom_children =  widget.vars.scroll1:getChildAtIndex(count)
	--local buttom_pos = buttom_children.rootVar:getPositionInScroll(widget.vars.scroll1)
	local buttom_fbID = i3k_db_climbing_tower_datas[groupId][1].fbID
	self:setShowLevelLock(1,info.history[groupId] or 0,buttom_node)

	self:setShowLevelAndPowerLabel(buttom_fbID,buttom_node)

	buttom_node.vars.showselect:hide()
	local buttom_type = i3k_db_climbing_tower_datas[groupId][1].levelType
	buttom_node.vars.level_bg:setImage(g_i3k_db.i3k_db_get_icon_path(levelTypeTbl[buttom_type]))

	local buttom_tb = {groupId = groupId,bestFloor = 1 ,info = info, _layer = widget,fbId = buttom_fbID,dayTimesBuy = info.dayTimesBuy,dayTimesUsed =info.dayTimesUsed,finishFloors = info.finishFloors[groupId] }
	buttom_node.vars.floor_btn:onClick(self, self.onClickSelect,buttom_tb )


	local children2 =  widget.vars.scroll1:getChildrenCount()



	-----跳到最近的关卡并显示选中箭头
	local index = 0
	if seq then
		index = count -(seq+1)
		----跳到下一层扫荡
	else
		index = count -((info.history[groupId] or 0)+1)
	end
	widget.vars.scroll1:jumpToChildWithIndex(index )--跳到最近的关卡

	self:onClickSelectPoint(widget,index,groupId)


	local floor = {groupId = groupId, bestFloor = self.alreadyUnlock,dayTimesBuy = info.dayTimesBuy,dayTimesUsed = info.dayTimesUsed,fbId = fbId ,_layer = widget,finishFloors = info.finishFloors[groupId] }--info = info
	widget.vars.select_btn:onClick(self, self.onClickSelectBtn, floor)					---选关
end

---设置每关的锁
function wnd_activity:setShowLevelLock(index,bestFloor,node)

	if index <= bestFloor+1 then---前一关通关时 开启下一关 +1

		self.alreadyUnlock = self.alreadyUnlock + 1
		node.vars.suo:hide()
		node.vars.level_bg:enableWithChildren()
		node.vars.floor_btn:enableWithChildren()
	else
		node.vars.suo:show()
		node.vars.level_bg:disableWithChildren()
		node.vars.floor_btn:disableWithChildren()
	end
	--i3k_log("oh select floor open ",index,bestFloor,self.alreadyUnlock)

end

function wnd_activity:setShowLevelAndPowerLabel(fb_id,node)

	local needPower = i3k_db_climbing_tower_fb[fb_id].powerNeed
	local needLvl = i3k_db_climbing_tower_fb[fb_id].enterLvl
	if 	self._lvl< needLvl then--等级不满足
		node.vars.floor_power:setText(string.format("等级：%s",needLvl))
		node.vars.floor_power:setTextColor(g_i3k_get_cond_color(false))

	elseif self._power<needPower then--战力不满足
		node.vars.floor_power:setText("战力："..needPower)--(string.format("战力：%s",needPower))
		node.vars.floor_power:setTextColor(g_i3k_get_cond_color(false))

	else
		node.vars.floor_power:hide()

	end
end
--选中箭头
function wnd_activity:onClickSelectPoint(widget,index,groupId)

	local child = widget.vars.scroll1:getAllChildren()
	for i,v in ipairs(child) do
		v.vars.showselect:hide()
	end
	--local count = i3k_table_length(i3k_db_climbing_tower_fb)
	local count = #i3k_db_climbing_tower_datas[groupId]
	local cur_index
	if index < 0 then
		cur_index = count
		index  = 0
	else
		cur_index = count - index
	end

	local l_type = i3k_db_climbing_tower_datas[groupId][cur_index].levelType

	local children =  widget.vars.scroll1:getChildAtIndex(index+1)

	local pos = children.vars.showselect:getPosition()
	if l_type == 1 then --正常关
		--children.vars.showselect:setPosition(pos.x+5,pos.y)
	end
	children.vars.showselect:show()
	----移动像素
	self.position = children.vars.showselect:getPosition()
	--local rotate1 =  children.vars.showselect:createMoveTo(0.5,pos.x,pos.y-10)
	--local rotate2 =  children.vars.showselect:createMoveTo(0.5,pos.x,pos.y+10)
	local rotate1 =  children.vars.showselect:createMoveBy(0.5,0,-10)
	local rotate2 =  children.vars.showselect:createMoveBy(0.5,0,10)

	local seq1 =  children.vars.showselect:createSequence(rotate1,  rotate2)
	local action = children.vars.showselect:createRepeatForever(seq1)
	children.vars.showselect:runAction(action)



end
--选中关卡后刷新挑战按钮
function wnd_activity:onClickSelect(sender,  needValue)--(sender, needValue)
	--local count = i3k_table_length(i3k_db_climbing_tower_fb)
	local count = #i3k_db_climbing_tower_datas[needValue.groupId]
	local index = count - needValue.bestFloor
	local children =  needValue._layer.vars.scroll1:getChildAtIndex(index+1)
	children.vars.showselect:setPosition(self.position)
	--i3k_log("position is onClickSelect = ",needValue.groupId,cur_index,l_type,self.position.x,self.position.y)
	--if eventType==ccui.TouchEventType.began then


		self:onClickSelectPoint(needValue._layer,index,needValue.groupId)
		self:setFiveUniqueActivityData(needValue.groupId,needValue.bestFloor,needValue._layer,needValue.fbId,needValue.finishFloors,needValue.dayTimesBuy,needValue.dayTimesUsed)
	--elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then


		--children.vars.showselect:setPosition(self.position)
	--end

end

--跳到选中关卡后刷新挑战按钮
function wnd_activity:onClickSelectAndUpdate(needValue)

	local count = #i3k_db_climbing_tower_datas[needValue.groupId]
	local index = count - needValue.bestFloor
	needValue._layer.vars.scroll1:jumpToChildWithIndex(index )--跳到最近的关卡
	self:onClickSelectPoint(needValue._layer,index,needValue.groupId)
	self:setFiveUniqueActivityData(needValue.groupId,needValue.bestFloor,needValue._layer,needValue.fbId,needValue.finishFloors,needValue.dayTimesBuy,needValue.dayTimesUsed)
	--i3k_log("----select and update  =",index,needValue.id,needValue.level,needValue._layer,needValue.fbId)
end

function wnd_activity:onClickSelectBtn(sender, needValue)
	--g_i3k_ui_mgr:PopupTipMessage("选关")
	g_i3k_ui_mgr:OpenUI(eUIID_FiveUniqueSelect)
	g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniqueSelect,needValue)
end

--- 秘境按钮
function wnd_activity:onClickSecretareaBtn(sender, needValue)

	local challengetimes = i3k_db_climbing_tower_args.maxattackTimes
	if needValue.dayTimesUsed>= challengetimes then
		g_i3k_ui_mgr:OpenUI(eUIID_Secretarea)
		g_i3k_ui_mgr:RefreshUI(eUIID_Secretarea,needValue)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("挑战%s次后开启秘境",challengetimes))
	end


end
function wnd_activity:onClickAddBtn(sender, needValue)
	--g_i3k_ui_mgr:PopupTipMessage("添加次数")

	self:buyTimesPanel(needValue)
end

function wnd_activity:buyTimesPanel(needValue)
	local maxBuyTimes = #i3k_db_climbing_tower_args.needGold
	local timeUsed,timeBuy, totalTimes = g_i3k_game_context:GetTowerChallengeTimes()----
	local haveTimes = totalTimes - i3k_db_climbing_tower_args.maxattackTimes--剩余次数
	local canBuyTimes = maxBuyTimes - timeBuy  --可购买的次数

	if canBuyTimes>0 then

		local buyTimeCfg = i3k_db_climbing_tower_args.needGold
		local needDiamond = buyTimeCfg[timeBuy+1]
		if not needDiamond then
			needDiamond = buyTimeCfg[#buyTimeCfg]
		end
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)--绑定
		--i3k_log("--------------- =============== ",have,needDiamond)
		if have == 0 then
			descText = string.format("是否花费<c=green>%d元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次", needDiamond, canBuyTimes)
		elseif have < needDiamond then

			descText = string.format("是否花费<c=green>%d绑定元宝</c>、<c=green>%d元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次",have, needDiamond-have, canBuyTimes)
		else
			descText = string.format("是否花费<c=green>%d绑定元宝</c>购买1次挑战机会\n今日还可购买<c=green>%d</c>次", needDiamond, canBuyTimes)
		end


		local function callback(isOk)
			if isOk then
				local haveDiamond = g_i3k_game_context:GetDiamondCanUse(false)
				if haveDiamond > needDiamond then
					--
					i3k_sbean.set_tower_buytimes(timeBuy+1,needDiamond,needValue._layer,needValue.bestFloor)
				else
					local tips = string.format("%s", "您的元宝不足，购买失败")
					g_i3k_ui_mgr:PopupTipMessage(tips)
				end
			else

			end
		end

		g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(514))
	end
end
function wnd_activity:onClickGoOutBtn(sender, needValue)
	--g_i3k_ui_mgr:PopupTipMessage("出战设置")
	g_i3k_ui_mgr:OpenUI(eUIID_FiveUniquePets)
	g_i3k_ui_mgr:RefreshUI(eUIID_FiveUniquePets)
end

---挑战按钮
function wnd_activity:onClickChallengeBtn(sender, needValue)--timesBuy = info.timesBuy,timesUsed
	--g_i3k_ui_mgr:PopupTipMessage("挑战")
	local timeUsed,timeBuy, totalTimes = g_i3k_game_context:GetTowerChallengeTimes()
	local fbId = i3k_db_climbing_tower_datas[needValue.groupId][needValue.bestFloor].fbID
	local havetimes = i3k_db_climbing_tower_args.maxattackTimes - needValue.dayTimesUsed + timeBuy


	local needVit= i3k_db_climbing_tower_fb[fbId].enterConsume
	local vit = g_i3k_game_context:GetVit()
	--i3k_log("----onClickChallengeBtn  =",timeUsed,timeBuy,totalTimes,needValue.dayTimesUsed,needValue.dayTimesBuy,havetimes)
	if vit < needVit  and  havetimes > 0 then
		g_i3k_logic:GotoOpenBuyVitUI()
		return
	elseif havetimes<=0 then
	---提示购买次数
		self:buyTimesPanel(needValue)
	elseif vit >= needVit then
		self:InRoom(needValue.groupId,needValue.bestFloor,fbId)
	end
end

function wnd_activity:InRoom(id,level,fbId)---判断 房间情况

	--总共有多少随从
	local allPets, playPets = g_i3k_game_context:GetYongbingData()
	local allCount = 0
	for i,v in pairs(allPets) do
		allCount = allCount + 1
	end
	--已经上阵的数量
	local fightPets = g_i3k_game_context:GetTowerActivityPets()
	local fightCount = #fightPets

	--总共能上阵几个随从
	local roleLevel = g_i3k_game_context:GetLevel()
	local totalCount = 0
	if roleLevel >= i3k_db_common.posUnlock.first and roleLevel < i3k_db_common.posUnlock.second then
		totalCount = 1
	elseif roleLevel >= i3k_db_common.posUnlock.second and roleLevel < i3k_db_common.posUnlock.third then
		totalCount = 2
	else
		totalCount = 3
	end


	if g_i3k_game_context:IsInRoom() then -- 房间状态
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))

	elseif fightCount<allCount and fightCount<totalCount then
		local fun = function(isOk)
			if isOk then
				g_i3k_ui_mgr:OpenUI(eUIID_FiveUniquePets)
			else
				self:onTeam(id,level,fbId)
			end
		end
		local desc = i3k_get_string(286)
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	else
		self:onTeam(id,level,fbId)
	end
end


function wnd_activity:onTeam(id,level,fbId)---判断 组队情况

	local teamId = g_i3k_game_context:GetTeamId()
	if teamId~=0 then ---- 处于组队状态
		local function callback(isOk)
			if isOk then
				self:starActivity(id,level,fbId)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(141), callback)
	else
		self:starActivity(id,level,fbId)
	end

end

function wnd_activity:starActivity(id,level,fbId)

	--local mapId = i3k_db_dungeon_base[fbId].mapID

	--g_i3k_game_context:ClearFindWayStatus()



	local function func()
		g_i3k_game_context:ClearFindWayStatus()
		local user_cfg = g_i3k_game_context:GetUserCfg()
		local index = user_cfg:GetSelectFiveUnique()
		i3k_sbean.startfight_tower_activities(level,id,fbId,index)
	end
	g_i3k_game_context:CheckMulHorse(func)

end


function wnd_activity:onClickSweepBtn(sender, needValue)
	--g_i3k_ui_mgr:PopupTipMessage("扫荡")

	local timeUsed,timeBuy, totalTimes = g_i3k_game_context:GetTowerChallengeTimes()
	if not needValue or not i3k_db_climbing_tower_datas[needValue.groupId] or not i3k_db_climbing_tower_datas[needValue.groupId][needValue.bestFloor] then return end
	local fbId = i3k_db_climbing_tower_datas[needValue.groupId][needValue.bestFloor].fbID
	local havetimes = i3k_db_climbing_tower_args.maxattackTimes - needValue.dayTimesUsed + timeBuy


	local needVit= i3k_db_climbing_tower_fb[fbId].enterConsume
	local vit = g_i3k_game_context:GetVit()

	if vit < needVit  and  havetimes > 0 then
		g_i3k_logic:GotoOpenBuyVitUI()
		return
	elseif havetimes<=0 then
	---提示购买次数
		self:buyTimesPanel(needValue)
	elseif vit >= needVit then
		local user_cfg = g_i3k_game_context:GetUserCfg()
		local index = user_cfg:GetSelectFiveUnique()
		i3k_sbean.tower_sweep_take(needValue.bestFloor,needValue,needValue.fbId,index)---只能扫荡一次
	end
end

function wnd_activity:buyTimesCB(haveTimes, totalTimes,item)
	item.vars.challengeTimeLabel:setText(haveTimes)

	g_i3k_ui_mgr:PopupTipMessage("购买成功")
end

--[[function 其他()
end--]]
function wnd_activity:checkItemGrade(sender)
	local itemId = sender:getTag()-3000
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_activity:getActivityState(id)--notOpenTable = {}, openTable = {}, closeTable = {}, notHaveTable = {}
	for i,v in ipairs(self._allActivityTable[self._state].notOpenTable) do
		if v.id==id then
			return f_activityNotOpenState
		end
	end
	for i,v in ipairs(self._allActivityTable[self._state].openTable) do
		if v.id==id then
			return f_activityOpenState
		end
	end
	for i,v in ipairs(self._allActivityTable[self._state].closeTable) do
		if v.id==id then
			return f_activityOverState
		end
	end
	for i,v in ipairs(self._allActivityTable[self._state].notHaveTable) do
		if v.id==id then
			return f_notActivityState
		end
	end
end

function wnd_activity:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_activity:addVitBtn(sender)
	g_i3k_logic:OpenBuyVitUI()
end

function wnd_activity:vitInfo(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_VitTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_VitTips)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_VitTips)
		end
	end
end

function wnd_activity:updateMoney(vit,vitMax)
	local str = string.format("%s/%s",vit,vitMax)
	self._layout.vars.vit_value:setText(str)
end

function wnd_activity:releaseSchedule()
	if self._exploreSC then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._exploreSC)
		self._exploreSC = nil
	end
	if self.npcWordSchedule then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.npcWordSchedule)
		self.npcWordSchedule = nil
	end
end

function wnd_activity:onHide()
	self:releaseSchedule()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DBF,"setRootVisible",true)
end


function wnd_activity:onUpdate(dTime)
	
	self._currentTime  = math.modf(i3k_game_get_time())
	self._curTime = g_i3k_get_GMTtime(i3k_game_get_time())

	if self._currentTime > self._punishtime and self._isForceWar and self._punishtime ~=0 then--当前时间超过惩罚时间,可以再次报名
		self._isForceWar = false
		self._widgets.punishtime:hide()
		self._widgets.punishtime:setTextColor(g_i3k_get_green_color())
		self._widgets.join_text:setText("报名")
		self._widgets.join:enableWithChildren()

	elseif self._isForceWar and self._isDropOut and self._currentTime <= self._punishtime then

		local min = math.modf(( self._punishtime - self._currentTime )  /60)
		local sec =  (self._punishtime - self._currentTime )  %60

		local str = string.format("%d分%d秒",min,sec)--你刚刚逃离了势力战场，暂时无法报名（剩余%d分%d秒）%02d:%02d

		self._widgets.punishtime:setText("逃离惩罚时间："..str)
		self._widgets.join:disableWithChildren()
	end
	self._refreshTimeTicket = self._refreshTimeTicket + dTime
	if self._refreshTimeTicket >= REFRESHINTERVAL then
		self._refreshTimeTicket = 0
		
		if self._state == g_SPIRIT_MONSTER_STATE and self._spiritBossWidget then
		self:onSpiritBossOverCountDownUpdate()
	end
	
		if self._state == g_PET_ACTIVITY_STATE and self._petActivityWidget then
		self:onPetActivity_State()
	end
		if self._state == g_PRINCESS_MARRY_STATE and self._princessMarryWidget and self._princessMarryOpenFlag then
		self:onPrincessMarryUpdate()
	end
		if self._state == g_MAGIC_MACHINE_STATE and self._magicMachineWidget then
		self:onMagicMachineUpdate()	
		end
		if self._state == g_LONGEVITY_PAVILION_STATE and self._longevityPavilionWidget then
			self:onLongevityPavilionUpdate()
		end	
	end
end


--史诗任务
function wnd_activity:loadEpicUI()
	local widget = require("ui/widgets/wudaoxiahun")()
	self:addChildWidget(widget)
	self:setState(g_EPIC_STATE)
	widget = widget.vars
	widget.backBtn:onClick(self, self.updateEpicUI)
	--widget.desc:setText(i3k_get_string(1053))
	self:updateEpicUI()

	local data, index = g_i3k_game_context:getCurrEpicTaskData()
	local cfg = i3k_db_epic_cfg
	local haveAttr = g_i3k_game_context:getEpicTaskAttr()
	local willHave = {}
	if data.id ~= 0 then
		for i,v in ipairs(cfg[data.seriesID].attr) do
			if willHave[v.id] then
				willHave[v.id] = willHave[v.id] + v.value
			else
				willHave[v.id] = v.value
			end
		end
	else
		widget.nextAttrTitle:hide()
		widget.firstAttrTitle:hide()
		widget.finalAttrTitle:show()
		widget.finalImg:show()
	end
	local attrStr = {}
	local addItem = function(id, value)
		local node = require("ui/widgets/wudaoxiahunt")()
		node.vars.attrName:setText(g_i3k_db.i3k_db_get_property_name(id))
		node.vars.attrValue:setText(value)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(id)))
		widget.scroll:addItem(node)
		return node
	end
	for k,v in pairs(haveAttr) do
		local node = addItem(k, v)
		if willHave[k] then
			node.vars.addValue:setText("+" .. willHave[k])
		else
			node.vars.addValue:setText("")
		end
	end
	for k,v in pairs(willHave) do
		if not haveAttr[k] then
			local node = addItem(k, 0)
			node.vars.addValue:setText("+" .. v)
		end
	end

	local titleName = cfg[data.seriesID].titleName[data.groupID]
	widget.titleTxt:setText(titleName)
	for i = 1, 6 do
		local btn = widget["btn"..i]
		local isCurr = data.groupID == i
		local isFinish = data.groupID > i
		widget["dis"..i]:setVisible(not isCurr)
		widget["en"..i]:setVisible(isCurr)
		if i~= 6 then
			widget["fn"..i]:setVisible(isFinish)
			widget["currTask"..i]:setVisible(isCurr)
		end
		btn:setTag(i)
		if isCurr or isFinish then
			btn:onClick(self, self.showEpicTaskUI)
		else
			btn:disable()
		end
	end
	if data.id ~= 0 then
		cfg = g_i3k_db.i3k_db_epic_task_cfg(data.seriesID, data.groupID, data.id)
		local is_ok = g_i3k_game_context:IsTaskFinished(cfg.tyep , cfg.arg1, cfg.arg2, data.value)
		local tmp_desc = is_ok and g_i3k_db.i3k_db_get_task_finish_reward_desc(cfg) or g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, data.value, is_ok)
		tmp_desc = string.gsub(tmp_desc,"<c=hlgreen>","<c=green>")
		widget.taskDesc2:setText(cfg.name.."："..tmp_desc.."\n\n请前往任务栏完成史诗任务")
		widget.taskDesc:setText(cfg.taskDesc)
		widget.taskTitle:setText(titleName)
		widget.taskTitle2:setText(titleName)
		local count = #i3k_db_epic_task[data.seriesID][data.groupID]
		local tmp_str = string.format("完成进度%s/%s", data.id-1,count)
		widget.loadingBarLabel:setText(tmp_str)
		widget.loadingBar:setPercent(math.modf((data.id-1)/count*100))

		widget.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imagePath))
		widget.taskBtnTxt:setText("重置任务")
		widget.taskBtn2:onClick(self, self.goToEpicTask)
		if cfg.abandonTask > 0  then
			widget.taskBtn:onClick(self, self.abandonTask)
		else
			widget.taskBtn:disableWithChildren()
		end
		items = g_i3k_game_context:getMainTaskAward(cfg)
		for id,v in pairs(items) do
			node = require("ui/widgets/plcht")()
			widget.rewardScroll:addItem(node)
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			node.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			node.vars.item_count:setText(v)
			node.vars.suo:setVisible(id>0)
			node.vars.bt:onClick(self, self.onClickItem, id)
		end
	end

end

function wnd_activity:updateEpicUI(sender)
	local widget = self._rootWidget:getAddChild()[1]
	widget = widget.vars
	widget.backBtn:hide()
	widget.taskNode:hide()
	widget.moralityNode:show()
end

function wnd_activity:showEpicTaskUI(sender)
	local data, index = g_i3k_game_context:getCurrEpicTaskData()

	if data.id == 0 then
		local epicqueue = i3k_db_generals[g_i3k_game_context:GetRoleType()].epicQueue
		local nextIndex  = index + 1
		if nextIndex > #epicqueue then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1054))
		elseif g_i3k_game_context:GetLevel() < i3k_db_epic_cfg[epicqueue[nextIndex]].limitLvl then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1055, i3k_db_epic_cfg[epicqueue[nextIndex]].limitLvl))
		end
		return
	end
	if sender:getTag() < data.groupID then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1056))
	elseif sender:getTag() > data.groupID then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1053))
	end

	local widget = self._rootWidget:getAddChild()[1]
	widget = widget.vars
	widget.backBtn:show()
	widget.taskNode:show()
	widget.moralityNode:hide()
end

function wnd_activity:goToEpicTask(sender)
	g_i3k_logic:OpenBattleUI(function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "doEpicTask")
	end)
end

function wnd_activity:abandonTask(sender)
	local data = g_i3k_game_context:getCurrEpicTaskData()
	i3k_sbean.epic_task_quitReq(data.seriesID, data.groupID)
end

function wnd_activity:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

-- 江洋大盗 begin
function wnd_activity:reloadRobberMonster(robbersInfo)
	self:setState(g_ROBBER_STATE)
	local widget = require("ui/widgets/jiangyangdadao")()
	self:addChildWidget(widget)
	self:loadRobberMonsterScroll(robbersInfo)
	self:loadRefreshInfo()
	widget.vars.refreshBtn:onClick(self, self.onRefreshRobber)
	widget.vars.helpBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(16817))
	end)
end

function wnd_activity:loadRobberMonsterScroll(robbersInfo)
	if self._state == g_ROBBER_STATE then
		local rootWidget = self._rootWidget:getAddChild()[1]
		local scroll = rootWidget.vars.scroll
		scroll:removeAllChildren()
		local monthCardCount = i3k_db_robber_monster_base.condition.monthCardCount
		local monsterCount = i3k_db_robber_monster_base.condition.monsterCount
		local allWidget = scroll:addChildWithCount(JIANGHUDADAO2, 2, monsterCount + monthCardCount)
		local stateTxtIDS = { [g_ROBBER_SLEEP] = 16867, [g_ROBBER_WANDER] = 16866, [g_ROBBER_TASK] = 16819,}
		for i, e in ipairs(allWidget) do
			local widget = e.vars
			local isShowDesc = i <= #robbersInfo
			widget.name:setVisible(isShowDesc)
			widget.level:setVisible(isShowDesc)
			widget.stateDesc:setVisible(isShowDesc)
			widget.monthCard:setVisible(not isShowDesc)
			--widget.iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(isShowDesc and ROBBER_NO_MONTH_BG or ROBBER_MONTH_BG))
			if isShowDesc then
				local monsterInfo = robbersInfo[i]
				local robberMonsterCfg = i3k_db_robber_monster_cfg[monsterInfo.id]
				local behaviorCfg = i3k_db_robber_monster_behaviors
				local str = behaviorCfg[monsterInfo.behavior].behaviorType
				local typeDesc = i3k_db_robber_monster_types[robberMonsterCfg.monsterType].typeName
				widget.name:setText(i3k_get_string(16822, robberMonsterCfg.name, typeDesc))
				widget.level:setText(i3k_get_string(16818, monsterInfo.level))
				if monsterInfo.behavior == g_ROBBER_TASK then
					str = i3k_db_robber_monster_task[monsterInfo.taskID].taskName
				end
				widget.stateDesc:setText(i3k_get_string(stateTxtIDS[monsterInfo.behavior], str))
				widget.check:onClick(self, self.onCheckRobberMonster, {info = monsterInfo, name = robberMonsterCfg.name})
				widget.iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(math.random(8010, 8012)))
			else
				widget.iconBg:setImage(g_i3k_db.i3k_db_get_icon_path(ROBBER_MONTH_BG))
				widget.check:onClick(self, function ()
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16828))
				end)
			end
		end
		if #robbersInfo <= 4 then --scroll可否滑动
			scroll:stateToNoSlip()
		else
			scroll:stateToSlip()
		end
	end
end

function wnd_activity:loadRefreshInfo()
	if self._state == g_ROBBER_STATE then
		local rootWidget = self._rootWidget:getAddChild()[1]
		local needDiamond = g_i3k_game_context:getRefreshRobberInfo()
		rootWidget.vars.diamondTxt:setVisible(needDiamond > 0)
		rootWidget.vars.diamondIcon:setVisible(needDiamond > 0)
		rootWidget.vars.diamondRoot:setVisible(needDiamond > 0)
		rootWidget.vars.diamondTxt:setText(string.format("x%s", needDiamond))
	end
end

function wnd_activity:onCheckRobberMonster(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_RobberMonster)
	g_i3k_ui_mgr:RefreshUI(eUIID_RobberMonster, data)
end

function wnd_activity:onRefreshRobber(sender)
	local needDiamond, msg = g_i3k_game_context:getRefreshRobberInfo()
	if needDiamond > 0 and g_i3k_game_context:GetDiamondCanUse(false) < needDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16823))
		return
	end
	local dayRefreshTimes = g_i3k_game_context:getRobberDayRefreshTimes()
	local callfunction = function(ok)
		if ok then
			i3k_sbean.robbermonster_refresh(dayRefreshTimes+1, needDiamond)
		end
	end
	g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, callfunction)
end
-- 江洋大盗end

--巨灵攻城
function wnd_activity:loadSpiritUI(openDays)
	self:setState(g_SPIRIT_MONSTER_STATE)
	local layer = require("ui/widgets/julinggongcheng")()
	local commonCfg = i3k_db_spirit_boss.common
	self:addChildWidget(layer)
	self._state = g_SPIRIT_MONSTER_STATE
	widget = layer.vars
	widget.need_lv:setText(commonCfg.openLvl)
	widget.open_date:setText(i3k_get_activity_open_desc(openDays))
	widget.open_time:setText(i3k_get_activity_open_time_desc(commonCfg.openTime))
	widget.enterBtn:onClick(self, self.onEnterBtn)
	widget.awardBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_SpiritBossReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossReward)
		end)
	widget.helpBtn:onClick(self,function()
			g_i3k_ui_mgr:ShowHelp(i3k_get_string(17326))
		end)
	self._spiritBossWidget = widget
	self._openDays = openDays
	self:onSpiritBossOverCountDownUpdate()
end

function wnd_activity:onEnterBtn(sender)
	local commonCfg = i3k_db_spirit_boss.common
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(commonCfg.openTime)
	local isOpen = i3k_get_activity_is_open(self._openDays)
	if g_i3k_game_context:GetLevel() < commonCfg.openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17331))
	elseif g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17332))
	elseif not(isInTime and isOpen) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17333))
	else
		g_i3k_game_context:CheckMulHorse(function()
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(17334),function(isOK)
				if isOK then
					i3k_sbean.gaintboss_join()
				end
			end)
		end)
	end
end

--巨灵攻城活动倒计时
function wnd_activity:onSpiritBossOverCountDownUpdate()
	local commonCfg = i3k_db_spirit_boss.common
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(commonCfg.openTime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(self._openDays)
	local lvLimit = commonCfg.openLvl <= g_i3k_game_context:GetLevel()
	if isOpen and isInTime then
		self._spiritBossWidget.enterBtn:enableWithChildren()
	else
		self._spiritBossWidget.enterBtn:disableWithChildren()
	end
	self._spiritBossWidget.not_open:setVisible(not(isOpen and isInTime))
	self._spiritBossWidget.countdown_desc:setVisible(not self._spiritBossWidget.not_open:isVisible())
	self._spiritBossWidget.countdown:setVisible(not self._spiritBossWidget.not_open:isVisible())
	self._spiritBossWidget.open_date:setTextColor(g_i3k_get_cond_color(isOpen and isInTime))
	self._spiritBossWidget.open_time:setTextColor(g_i3k_get_cond_color(isOpen and isInTime))
	self._spiritBossWidget.need_lv:setTextColor(g_i3k_get_cond_color(lvLimit))
	if isOpen and isInTime and seconds >= 0 then
		self._spiritBossWidget.countdown:setText(i3k_get_time_show_text(seconds))
	end
end

--巨灵攻城 end

--宠物试炼
function wnd_activity:onLoadPetActivityStateUI()
	self:setState(g_PET_ACTIVITY_STATE)
	local layer = require("ui/widgets/chongwushilian")()
	self:addChildWidget(layer)
	local weight = layer.vars
	self._petActivityWidget = layer.vars
	local opentime = {{startTime = i3k_db_PetDungeonBase.openTime, openOffsetTime = 0, lifeTime = i3k_db_PetDungeonBase.lifeTime},}
	weight.join_time:setText(i3k_get_activity_open_desc(i3k_db_PetDungeonBase.openDay))
	weight.have_times:setText(i3k_get_activity_open_time_desc(opentime))
	weight.need_lvl:setText(i3k_db_PetDungeonBase.openLvl)
	self:onPetActivity_State()
	weight.rewards:removeAllChildren()
	weight.tip:onClick(self, function() g_i3k_logic:OpenPetActivityTipUI() end)
	for _, v in ipairs(i3k_db_PetDungeonBase.rewards) do
		if v ~= 0 then
			local itemInfo = g_i3k_db.i3k_db_get_common_item_cfg(v)
			local node = require("ui/widgets/chongwushiliant")()
			local wht = node.vars
			wht.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v, g_i3k_game_context:IsFemaleRole()))
			wht.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
			wht.suo:setVisible(v > 0)
			wht.btn:onClick(self, function()
				g_i3k_ui_mgr:ShowCommonItemInfo(v)
			end)
			weight.rewards:addItem(node)
		end
	end

	weight.toHelp:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(1486))
	end)
	weight.join:onClick(self, self.onPetEnterBt)
end

--宠物试炼倒计时
function wnd_activity:onPetActivity_State()
	local opentime = {{startTime = i3k_db_PetDungeonBase.openTime, openOffsetTime = 0, lifeTime = i3k_db_PetDungeonBase.lifeTime},}
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(opentime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(i3k_db_PetDungeonBase.openDay)
	
	local lvLimit = i3k_db_PetDungeonBase.openLvl <= g_i3k_game_context:GetLevel()
	if not self._petActivityWidget then return end
	local weight = self._petActivityWidget
	
	local flag = isOpen and isInTime
	self:changeActivityWidState(weight, flag)
	
	weight.join_time:setTextColor(g_i3k_get_cond_color(flag))
	weight.have_times:setTextColor(g_i3k_get_cond_color(flag))
	weight.need_lvl:setTextColor(g_i3k_get_cond_color(lvLimit))
	
	if isOpen and isInTime and seconds >= 0 then
		weight.countdown:setText(i3k_get_time_show_text(seconds))
	end
end

function wnd_activity:onPetEnterBt()
	if g_i3k_game_context:getPetDungeonSatisfyCount() < i3k_db_PetDungeonBase.needPetCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1487, i3k_db_PetDungeonBase.needPetCount, i3k_db_PetDungeonBase.needPetlevel))
		return
	end
	
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	if i3k_check_resources_downloaded(i3k_db_PetDungeonBase.checkSceneID) then
		g_i3k_logic:OpenPetDungeonChoseMapUI()
	end
end
--宠物试炼end

-----------------------------公主出嫁 start -----------------------------
function wnd_activity:loadPrincessMarry(isOpen)
	self:setState(g_PRINCESS_MARRY_STATE)
	if isOpen then
		self._princessMarryOpenFlag = true
		self:loadOpendPrincessMarry()
	else
		self._princessMarryOpenFlag = false
		self:loadUnOpenPrincessMarry()
	end
end
function wnd_activity:loadOpendPrincessMarry()
	local widget = require("ui/widgets/gongzhuchujia")()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._princessMarryWidget = widgets
	self:setPrincessMarryBtn(widgets)
	self:setPrincessMarryInfo(widgets)
end
function wnd_activity:loadUnOpenPrincessMarry()
	local widget = require("ui/widgets/gongzhuchujia2")()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._princessMarryWidget = widgets
end
-- 设置按钮点击事件
function wnd_activity:setPrincessMarryBtn(widgets)
	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_Help)
		g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(18054))
	end)
	widgets.awardBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryReward)
	end)
	if g_i3k_game_context:getPrincessMarrySignUpTime() == 0 then
		widgets.join_text2:setText(i3k_get_string(18042))
		widgets.join:onClick(self, self.enterPrincessMarry) 
	else
		widgets.join_text2:setText(i3k_get_string(18043))
		widgets.join:onClick(self, self.onStopMatchOperation, g_PRINCESS_MARRY_MATCH)
	end
	widgets.cartoonBt:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryCarton)
		g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryCarton, g_plot_cartoon_princess_marry)
	end)	
end

function wnd_activity:setPrincessMarryInfo(widgets)
	local cfg = i3k_db_princess_marry

	widgets.need_lv:setText(cfg.openLvl)

	widgets.open_time:setText(i3k_get_activity_open_time_desc(cfg.openTime))
	widgets.open_date:setText(i3k_get_activity_open_desc(cfg.openWeekDay))
	self:onPrincessMarryUpdate()
end

function wnd_activity:onPrincessMarryUpdate()
	local cfg = i3k_db_princess_marry
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(cfg.openTime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(cfg.openWeekDay)
	local lvLimit = cfg.openLvl <= g_i3k_game_context:GetLevel()
	local flag = isOpen and isInTime
	if not self._princessMarryWidget then return end
	local widgets = self._princessMarryWidget
	self:changeActivityWidState(widgets, flag)
	widgets.open_date:setTextColor(g_i3k_get_cond_color(flag))
	widgets.open_time:setTextColor(g_i3k_get_cond_color(flag))
	widgets.need_lv:setTextColor(g_i3k_get_cond_color(lvLimit))
	if flag and seconds >= 0 then
		widgets.countdown:setText(i3k_get_time_show_text(seconds))
	end
end

function wnd_activity:enterPrincessMarry(sender)
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	
	if g_i3k_game_context:getPrincessMarrydayEnterTimes() >= i3k_db_princess_marry.joinTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1309))
		return
	end

	local function func()
		if i3k_check_resources_downloaded(next(i3k_db_princess_Config))then
		i3k_sbean.princess_marry_sign_up()	
		end
	end

	local func1 = function () -- 队伍
		if g_i3k_game_context:GetTeamId() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17609, i3k_get_string(18039)))
		else
			return func()
		end
	end

	g_i3k_game_context:CheckMulHorse(func1)
end

function wnd_activity:onStopMatchOperation(sender, matchType)
	if matchType == g_PRINCESS_MARRY_MATCH then 
		i3k_sbean.princess_marry_quit_up()
	elseif matchType == g_MAGIC_MACHINE_MATCH then
		local fun = function(ok)
			if ok then
				i3k_sbean.magic_machine_quit_up()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18125), fun)		
	elseif matchType == g_LONGEVITY_PAVILION_MATCH then 
		i3k_sbean.longevity_loft_quit()
	end
end


function wnd_activity:stopActivityMatching(matchType, actType)
	if matchType == g_PRINCESS_MARRY_MATCH and self._state == g_PRINCESS_MARRY_STATE then
		if self._princessMarryWidget and self._princessMarryOpenFlag then
			self._princessMarryWidget.join_text2:setText(i3k_get_string(18042))
			self._princessMarryWidget.join:onClick(self, self.enterPrincessMarry)
		end
	elseif matchType == g_MAGIC_MACHINE_MATCH and self._state == g_MAGIC_MACHINE_STATE then
		if self._magicMachineWidget then
			self._magicMachineWidget.join_text:setText(i3k_get_string(18042))
			self._magicMachineWidget.join:onClick(self, self.magicMachineSignUpCheck)
		end
	elseif matchType == g_LONGEVITY_PAVILION_MATCH and self._state == g_LONGEVITY_PAVILION_STATE then
		if self._longevityPavilionWidget then
			self._longevityPavilionWidget.join_text2:setText(i3k_get_string(18042))
			self._longevityPavilionWidget.join:onClick(self, self.enterLongevityPavilion)
		end
	end
end

function wnd_activity:startActivityMatching(joinTime, matchType, actType)
	if matchType == g_PRINCESS_MARRY_MATCH and self._state == g_PRINCESS_MARRY_STATE then

		if self._princessMarryWidget and self._princessMarryOpenFlag then
			self._princessMarryWidget.join_text2:setText(i3k_get_string(18043))
			self._princessMarryWidget.join:onClick(self, self.onStopMatchOperation, g_PRINCESS_MARRY_MATCH)
		end
	elseif matchType == g_MAGIC_MACHINE_MATCH and self._state == g_MAGIC_MACHINE_STATE then
		if self._magicMachineWidget then 
			self._magicMachineWidget.join_text:setText(i3k_get_string(18043))
			self._magicMachineWidget.join:onClick(self, self.onStopMatchOperation, g_MAGIC_MACHINE_MATCH)
		end
	elseif matchType == g_LONGEVITY_PAVILION_MATCH and self._state == g_LONGEVITY_PAVILION_STATE then
		if self._longevityPavilionWidget then 
			self._longevityPavilionWidget.join_text2:setText(i3k_get_string(18043))
			self._longevityPavilionWidget.join:onClick(self, self.onStopMatchOperation, g_LONGEVITY_PAVILION_MATCH)
		end
	end
	
	local room = g_i3k_game_context:IsInRoom()
	
	if not room or room.type ~= gRoom_Force_War or g_i3k_game_context:getForceWarRoomType() == g_CHANNEL_COMBAT then
		g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
		g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, joinTime, matchType, actType)
	end
end
-----------------------------公主出嫁 end-----------------------------
--神机藏海start
function wnd_activity:loadMagicMachine()
	self:setState(g_MAGIC_MACHINE_STATE)
	local widget = require("ui/widgets/shenjizanghai")()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._magicMachineWidget = widgets
	self:setMagicMachineBtn(widgets)
	self:setMagicMachineInfo(widgets)
end

function wnd_activity:setMagicMachineBtn(widgets)
	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_Help)
		g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(18140))
	end)
	widgets.rewardBt:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_MMReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_MMReward)
	end)
	widgets.rankBt:onClick(self, function()
		i3k_sbean.magic_machine_lucky_teams()
	end)
	widgets.comicBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryCarton)
		g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryCarton, g_plot_cartoon_shenjicanghai_manhua)
	end)
	if g_i3k_game_context:getMagicMachineJoinTime() == 0 then
		widgets.join_text:setText(i3k_get_string(18042))
		widgets.join:onClick(self, self.magicMachineSignUpCheck) 
	else
		widgets.join_text:setText(i3k_get_string(18043))
		widgets.join:onClick(self, self.onStopMatchOperation, g_MAGIC_MACHINE_MATCH)
	end
end

function wnd_activity:setMagicMachineInfo(widgets)
	local cfg = i3k_db_magic_machine

	widgets.need_lvl:setText(cfg.openLvl)

	widgets.open_time:setText(i3k_get_activity_open_time_desc(cfg.openTime))
	widgets.open_date:setText(i3k_get_activity_open_desc(cfg.openWeekDay))
	
	widgets.tips:setText(i3k_get_string(18144))
	self:onMagicMachineUpdate()	
	local rwdCfg = i3k_db_MMRewards
	local info
	local playerLvl = g_i3k_game_context:GetLevel()
	for k, v in ipairs(rwdCfg) do
		info = v
		if cfg.lvl2map[k].uprLmt > playerLvl then
			break
		end
	end
	
	widgets.rewards:removeAllChildren()
	for _, id in ipairs(info.rwdPrv) do
		local ic = g_i3k_db.i3k_db_get_common_item_icon_path(id, i3k_game_context:IsFemaleRole())
		if ic and ic ~= 0 and ic ~= "" then
			local wg = require("ui/widgets/shenjizanghait")()
			wg.vars.icon:setImage(ic)
			wg.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			wg.vars.btn:onClick(self, function() g_i3k_ui_mgr:ShowCommonItemInfo(id) end)
			widgets.rewards:addItem(wg)
		end
	end
end

function wnd_activity:onMagicMachineUpdate()
	local cfg = i3k_db_magic_machine
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(cfg.openTime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(cfg.openWeekDay)
	local lvLimit = cfg.openLvl <= g_i3k_game_context:GetLevel()
	
	
	local flag = isOpen and isInTime
	if not self._magicMachineWidget then return end
	local wid = self._magicMachineWidget
	self:changeActivityWidState(wid, flag)
	wid.open_date:setTextColor(g_i3k_get_cond_color(flag))
	wid.open_time:setTextColor(g_i3k_get_cond_color(flag))
	wid.need_lvl:setTextColor(g_i3k_get_cond_color(lvLimit))
	if flag and seconds >= 0 then
		wid.countdown:setText(i3k_get_time_show_text(seconds))
	end
end

function wnd_activity:magicMachineSignUpCheck()
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18141))
		return false
	end
	
	if g_i3k_game_context:getmagicMachineEnterTimes() >= i3k_db_magic_machine.joinTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1309))
		return
	end

	local function func()
		if i3k_check_resources_downloaded(i3k_db_magic_machine.checkId)then
			i3k_sbean.magic_machine_sign_up()	
		end
	end

	local func1 = function() -- 队伍
		if g_i3k_game_context:GetTeamId() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17609, i3k_get_string(18039)))
		else
			return func()
		end
	end

	g_i3k_game_context:CheckMulHorse(func1)
end

--神机藏海end
--大侠朋友圈
function wnd_activity:loadSwordsmanCircle()
	self:setState(g_SWORDSMAM_CIRCLE)
	local widget = require("ui/widgets/daxia")()
	self:addChildWidget(widget)
	self._swordsmanWidget = widget.vars
	self._swordsmanChoose = 1
	self:setSwordsmanCircleInfo()
end
function wnd_activity:setSwordsmanCircleInfo()
	if self._swordsmanWidget then
		local info = g_i3k_game_context:getSwordsmanCircleData()
		if info.friendshipLvl == 0 then
			self._swordsmanWidget.friendshipName:setText(i3k_get_string(18325))
		else
			self._swordsmanWidget.friendshipName:setText(i3k_db_swordsman_circle_reward[info.friendshipLvl].friendShipName)
		end
		if info.friendshipLvl >= #i3k_db_swordsman_circle_reward then
			self._swordsmanWidget.friendshipPercent:setPercent(100)
			self._swordsmanWidget.friendshipValue:setText("0/0")
		else
			self._swordsmanWidget.friendshipPercent:setPercent(info.friendshipExp / i3k_db_swordsman_circle_reward[info.friendshipLvl + 1].needFriendShip * 100)
			self._swordsmanWidget.friendshipValue:setText(info.friendshipExp.."/"..i3k_db_swordsman_circle_reward[info.friendshipLvl + 1].needFriendShip)
		end
		self._swordsmanWidget.refreshTime:setText(i3k_get_string(18291))
		self._swordsmanWidget.friendName:setText(i3k_get_string(18288))
		self._swordsmanWidget.friendValue:setText(i3k_get_string(18289))
		self._swordsmanWidget.friendshipBtn:onClick(self, self.onFriendShipBtn)
		self._swordsmanWidget.condition:setText(i3k_get_string(18290, math.min(info.dayFinishCnt, i3k_db_swordsman_circle_cfg.rewardNeedCount) .. "/" .. i3k_db_swordsman_circle_cfg.rewardNeedCount))
		self._swordsmanWidget.rewardBtn:onClick(self, self.onSwordsmanRewardBtn)
		self._swordsmanWidget.buyTaskBtn:onClick(self, self.onBuyTaskCount)
		self._swordsmanWidget.helpBtn:onClick(self, self.onSwordsmanHelp)
		self._swordsmanWidget.npcBtn:onClick(self, self.onSwordsmanChoose)
		--[[for k, v in ipairs(i3k_db_swordsman_circle_npc) do
			if v.isOpen == 0 then
				self._swordsmanWidget["npcBtn"..k]:disableWithChildren()
			else
				self._swordsmanWidget["npcBtn"..k]:onClick(self, self.onSwordsmanChoose, k)
			end
		end--]]
		self._swordsmanWidget.scroll:removeAllChildren()
		for i, j in ipairs(i3k_db_swordsman_circle_daily_reward) do
			if j.level >= info.refreshLvl then
				for k, v in ipairs(j.reward) do
					local node = require("ui/widgets/daxiat")()
					node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
					node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
					node.vars.count:setText(v.count)
					node.vars.lock:setVisible(v.id > 0)
					node.vars.btn:onClick(self, self.onClickItem, v.id)
					self._swordsmanWidget.scroll:addItem(node)
				end
				break
			end
		end
		self:changeChooseSwordsman()
		self:updateSwordsmanBuyTimes()
		self:updateSwordsmanReward(info.dayTakeReward == 1)
	end
end
function wnd_activity:onFriendShipBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SwordsmanFriendship)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwordsmanFriendship)
end
function wnd_activity:onSwordsmanChoose(sender)
	if self._swordsmanWidget then
		local parent = self._swordsmanWidget.npcBtn:getParent()
		local touchPos = g_i3k_ui_mgr:GetMousePos()
		local pos = {}
		if parent then
			pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
		end
		local btnPos = self._swordsmanWidget.npcBtn:getPosition()
		local posX = pos.x - btnPos.x
		local posY = pos.y - btnPos.y
		local btnSize = self._swordsmanWidget.npcBtn:getSize()
		if posX * posX + posY * posY >= (btnSize.width / 2) ^ 2 then
			return
		end
		local index = 1
		if posX > 0 then
			if posY > 0 then
				if math.abs(posX) > math.abs(posY) then
					index = 3
				else
					index = 2
				end
			else
				if math.abs(posX) > math.abs(posY) then
					index = 4
				else
					index = 5
				end
			end
		else
			if posY > 0 then
				if math.abs(posX) > math.abs(posY) then
					index = 8
				else
					index = 1
				end
			else
				if math.abs(posX) > math.abs(posY) then
					index = 7
				else
					index = 6
				end
			end
		end
		if i3k_db_swordsman_circle_npc[index].isOpen == 0 then
		else
			self._swordsmanChoose = index
			self:changeChooseSwordsman()
		end
	end
end
--[[function wnd_activity:onSwordsmanChoose(sender, index)
	if i3k_db_swordsman_circle_npc[index].isOpen == 0 then
	else
		self._swordsmanChoose = index
		self:changeChooseSwordsman()
	end
end--]]
function wnd_activity:changeChooseSwordsman()
	for k, v in ipairs(i3k_db_swordsman_circle_npc) do
		if self._swordsmanChoose == k then
			self._swordsmanWidget["npcBg"..k]:show()
			self._swordsmanWidget["npcBg"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.chooseIcon))
			self._swordsmanWidget["npcIcon"..k]:hide()
			self._swordsmanWidget.dialogue:setText(v.dialogue)
		else
			self._swordsmanWidget["npcBg"..k]:hide()
			self._swordsmanWidget["npcIcon"..k]:show()
			self._swordsmanWidget["npcIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.normalIcon))
		end
	end
	self:changeSwordsmanTasks()
end
function wnd_activity:changeSwordsmanTasks()
	local info = g_i3k_game_context:getSwordsmanCircleData()
	local tasks = {}
	local refreshLvl = 1
	for i, j in ipairs(i3k_db_swordsman_circle_npc[self._swordsmanChoose].taskInfo) do
		if j.level >= info.refreshLvl then
			for k, v in ipairs(info.randomTasks) do
				if table.indexof(j.tasks, v) then
					table.insert(tasks, v)
				end
			end
			break
		end
	end
	for k = 1, 2 do
		if tasks[k] then
			local taskCfg = i3k_db_swordsman_circle_tasks[tasks[k]]
			self._swordsmanWidget["taskNode"..k]:show()
			self._swordsmanWidget["taskName"..k]:setText(taskCfg.name)
			self._swordsmanWidget["taskDesc"..k]:setText(taskCfg.description)
			if info.curTaskId == tasks[k] then
				self._swordsmanWidget["abandonBtn"..k]:show()
				self._swordsmanWidget["abandonBtn"..k]:onClick(self, self.abandonSwordsmanTask, tasks[k])
				self._swordsmanWidget["takeBtn"..k]:hide()
				self._swordsmanWidget["finishIcon"..k]:hide()
			elseif table.indexof(info.dayFinishTasks, tasks[k]) then
				self._swordsmanWidget["takeBtn"..k]:hide()
				self._swordsmanWidget["abandonBtn"..k]:hide()
				self._swordsmanWidget["finishIcon"..k]:show()
			else
				self._swordsmanWidget["takeBtn"..k]:show()
				self._swordsmanWidget["takeBtn"..k]:onClick(self, self.acceptSwordsmanTask, tasks[k])
				self._swordsmanWidget["abandonBtn"..k]:hide()
				self._swordsmanWidget["finishIcon"..k]:hide()
			end
		else
			self._swordsmanWidget["taskNode"..k]:hide()
		end
	end
end
function wnd_activity:acceptSwordsmanTask(sender, id)
	local info = g_i3k_game_context:getSwordsmanCircleData()
	if info.curTaskId ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18287))
	elseif info.dayFinishCnt >= info.dayBuyTaskCnt + i3k_db_swordsman_circle_cfg.freeTaskCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18324))
	else
		i3k_sbean.friend_circle_take_task(id, 0)
	end
end
function wnd_activity:abandonSwordsmanTask(sender, id)
	if i3k_db_swordsman_circle_tasks[id].canGiveUp == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18294))
	else
		--防止回调的时候界面关闭取不到值
		local taskId = id
		local _, value, state = g_i3k_game_context:getSwordsmanCircleTask()
		local cfg = i3k_db_swordsman_circle_tasks[taskId]
		local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
		if isFinish then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18328))
		else
			local callback = function (isOk)
				if isOk then
					i3k_sbean.friend_circle_cancel_task(taskId)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18293), callback)
		end
	end
end
function wnd_activity:onSwordsmanRewardBtn(sender)
	local info = g_i3k_game_context:getSwordsmanCircleData()
	if info.dayFinishCnt >= i3k_db_swordsman_circle_cfg.rewardNeedCount and info.dayTakeReward == 0 then
		local items = {}
		local rewards = {}
		for k, v in ipairs(i3k_db_swordsman_circle_daily_reward) do
			if v.level >= info.refreshLvl then
				rewards = v.reward
				break
			end
		end
		for k, v in ipairs(rewards) do
			items[v.id] = v.count
		end
		if g_i3k_game_context:IsBagEnough(items) then
			i3k_sbean.friend_circle_take_day_reward(rewards)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(43))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18327))
	end
end
function wnd_activity:updateSwordsmanReward(isFinish)
	if self._swordsmanWidget then
		if isFinish then
			self._swordsmanWidget.rewardBtn:disableWithChildren()
			self._swordsmanWidget.rewardText:setText(i3k_get_string(18320))
		else
			self._swordsmanWidget.rewardBtn:enableWithChildren()
			self._swordsmanWidget.rewardText:setText(i3k_get_string(18321))
		end
	end
end
function wnd_activity:onBuyTaskCount(sender)
	local info = g_i3k_game_context:getSwordsmanCircleData()
	if info.dayBuyTaskCnt >= i3k_db_swordsman_circle_cfg.canBuyCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18323))
	elseif g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_DIAMOND) < i3k_db_swordsman_circle_cfg.buyCost[info.dayBuyTaskCnt + 1] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18326))
	else
		local callback = function (isOk)
			if isOk then
				i3k_sbean.friend_circle_buy_task_cnt(i3k_db_swordsman_circle_cfg.buyCost[info.dayBuyTaskCnt + 1])
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18286, i3k_db_swordsman_circle_cfg.buyCost[info.dayBuyTaskCnt + 1]), callback)
	end
end
function wnd_activity:onSwordsmanHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18299))
end
function wnd_activity:updateSwordsmanBuyTimes()
	if self._swordsmanWidget then
		local info = g_i3k_game_context:getSwordsmanCircleData()
		self._swordsmanWidget.finishTimes:setText(i3k_get_string(18329, info.dayFinishCnt, info.dayBuyTaskCnt + i3k_db_swordsman_circle_cfg.freeTaskCount))
	end
end
--实时切换按钮状态
function wnd_activity:changeActivityWidState(wid, isOpen)
	if not wid then return end
	if isOpen and self._activityOpenState ~= 1 then
		self._activityOpenState = 1
		wid.join:enableWithChildren()
		wid.not_open:setVisible(false)
		wid.countdown_desc:setVisible(true)
		wid.countdown:setVisible(true)
	elseif self._activityOpenState ~= 2 and not isOpen then
		self._activityOpenState = 2
		wid.join:disableWithChildren()
		wid.not_open:setVisible(true)
		wid.countdown_desc:setVisible(false)
		wid.countdown:setVisible(false)
	end
end
---------------------万寿阁-----------------------------
--g_WAN_SHOU_GE
function wnd_activity:loadLongevityPavilion()
	self:setState(g_LONGEVITY_PAVILION_STATE)
	local widget = require("ui/widgets/wanshouge")()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._longevityPavilionWidget = widgets
	self:setLongevityPavilionBtn(widgets)
	self:setLongevityPavilionInfo(widgets)	
end
function wnd_activity:loadUnOpenLongevityPavilion()
	local widget = require("ui/widgets/gongzhuchujia2")()
	self:addChildWidget(widget)
	local widgets = widget.vars
	self._longevityPavilionWidget = widgets
end
-- 设置按钮点击事件
function wnd_activity:setLongevityPavilionBtn(widgets)
	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_Help)
		g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(18564))
	end)
	widgets.awardBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_LongevityPavilionReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_LongevityPavilionReward)
	end)
	widgets.cartoonBt:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryCarton)
		g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryCarton, g_plot_cartoon_longevity_pavilion)
	end)
	if g_i3k_game_context:getLongevityPavilionSignUpTime() == 0 then
		widgets.join_text2:setText(i3k_get_string(18042))
		widgets.join:onClick(self, self.enterLongevityPavilion) 
	else
		widgets.join_text2:setText(i3k_get_string(18043))
		widgets.join:onClick(self, self.onStopMatchOperation, g_LONGEVITY_PAVILION_MATCH)
	end
	--r32.5 Todo
	widgets.MapBtn:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_PrincessMarryCarton)
		g_i3k_ui_mgr:RefreshUI(eUIID_PrincessMarryCarton, g_plot_cartoon_longevity_pavilion_map)
	end)
end
function wnd_activity:setLongevityPavilionInfo(widgets)
	local cfg = i3k_db_longevity_pavilion
	widgets.need_lvl:setText(cfg.openLvl)	
	widgets.open_time:setText(i3k_get_activity_open_time_desc(cfg.openTime))
	widgets.open_date:setText(i3k_get_activity_open_desc(cfg.openWeekDay))
	self:onLongevityPavilionUpdate()
end
function wnd_activity:onLongevityPavilionUpdate()
	local cfg = i3k_db_longevity_pavilion
	local _, closeTime, isInTime = g_i3k_db.i3k_db_get_activity_open_close_time(cfg.openTime)
	local curtime = g_i3k_get_GMTtime(i3k_game_get_time())
	local seconds = closeTime - curtime
	local isOpen = i3k_get_activity_is_open(cfg.openWeekDay)
	local lvLimit = cfg.openLvl <= g_i3k_game_context:GetLevel()	
	local flag = isOpen and isInTime
	if not self._longevityPavilionWidget then return end
	local widgets = self._longevityPavilionWidget
	self:changeActivityWidState(widgets, flag)
	widgets.open_date:setTextColor(g_i3k_get_cond_color(flag))
	widgets.open_time:setTextColor(g_i3k_get_cond_color(flag))
	widgets.need_lvl:setTextColor(g_i3k_get_cond_color(lvLimit))
	if flag and seconds >= 0 then
		widgets.countdown:setText(i3k_get_time_show_text(seconds))
	end
end
function wnd_activity:enterLongevityPavilion(sender)
	if g_i3k_game_context:IsInRoom() or g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	if g_i3k_game_context:getLongevityPavilionEnterTimes() >= i3k_db_longevity_pavilion.joinTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1309))
		return
	end
	local function func()
		if i3k_check_resources_downloaded(g_i3k_db.i3k_db_get_longevity_pavilion_mapId())then
			i3k_sbean.longevity_loft_sign()	
		end
	end
	local func1 = function () -- 队伍
		if g_i3k_game_context:GetTeamId() ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17609, i3k_get_string(18039)))
		else
			return func()
		end
	end
	g_i3k_game_context:CheckMulHorse(func1)
end
-----------------------------------万寿阁end----------------------------------------------
function wnd_create(layout, ...)
	local wnd = wnd_activity.new();
	wnd:create(layout, ...);
	return wnd;
end
