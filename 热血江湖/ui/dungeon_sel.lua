-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
require("i3k_global")

-------------------------------------------------------
wnd_dungeon_sel = i3k_class("wnd_dungeon_sel", ui.wnd_base)

local LAYER_FBT = "ui/widgets/fbt"
local LAYER_FBT2 = "ui/widgets/fbt2"
local LAYER_FBT3 = "ui/widgets/fbt3"

local LAYER_FJDWT = "ui/widgets/zdfbt"

local LAYER_DJ1 = "ui/widgets/dj1"
local MAX_COUNT = 4

local TEAMTYPE = 3

-- 要求组队的副本类型
local DUNGEON_TYPE_SINGLE = 1 -- 单人副本
local DUNGEON_TYPE_TEAM   = 2 -- 组队
local DUNGEON_TYPE_GOLD   = 3 -- 赏金
local DUNGEON_TYPE_MASTER = 4 -- 师徒

--快速加入按钮点击时间间隔
local TOUCH_TIME = 2

--扫荡券id
local wipe_itemid = g_i3k_db.i3k_db_get_common_cfg().wipe.itemid
local SCORE_PICTURE = {242, 241, 240}
--左侧外框id 灰化，选中，默认
local SelectBg = {1836, 1835, 1834}

local WIPE_STATE_LVLLIMIT = 1
local WIPE_STATE_SOCLIMIT = 2
local WIPE_STATE_NUMLIMIT = 3
local WIPE_STATE_OPENLIMIT = 4

local l_gold_lvllimit = 40

function wnd_dungeon_sel:ctor()
	self._dungeon = -1
	self._id = nil
	self._data = {}
	self._old_dungeon = 0
	self._btn = {}
	self._root = {}
	self.root_action = {}
	self.c_xz = {}
	self.danrenScore = {}
	self.zuduiScore = {}
	self.wipeState = 0
	self._scroll_children = {} -- 单人本中，可选副本难度的滚动条

	--self.zuduiBtn = false  -- 是否为组队副本
	--self.goldBtn = false   -- 是否为赏金副本
	self.dungeonType = DUNGEON_TYPE_SINGLE
end

function wnd_dungeon_sel:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.danren_btn:onClick(self, self.onDanrenBtn)
	widgets.danren_btn:stateToPressed()
	widgets.zudui_btn:onClick(self, self.onZuduiBtn)
	widgets.gold_btn:onClick(self, self.onGoldBtn)
	widgets.master_btn:onClick(self,self.onMasterBtn) -- 师徒分页
	widgets.danrenRoot:show()
	widgets.zuduiRoot:hide()
	widgets.create_btn:onClick(self, self.onCreatebtn)
	self.fastMatchBtn = widgets.fastMatchBtn
	widgets.fastMatchBtn:onClick(self, self.onFastMatch)
	self.remain_times = widgets.remain_times
	widgets.add_vit:onClick(self, self.addVitBtn)
	widgets.vit_info:onTouchEvent(self, self.vitInfo)
	widgets.xiaoyao:onClick(self, self.xiaoYaoBtn)
	self.diamond = widgets.diamond
	self.diamondLock = widgets.diamondLock
	self.vit_value = widgets.vit_value

	self._btn = {danren_btn = widgets.danren_btn, zudui_btn = widgets.zudui_btn, gold_btn = widgets.gold_btn, master_btn = widgets.master_btn }
	self._root = {danrenRoot = widgets.danrenRoot,zuduiRoot = widgets.zuduiRoot}
	self.fb_scroll = widgets.fb_scroll

	self.wipe_item_icon = widgets.wipe_item_icon
	self.wipe_item_count = widgets.wipe_item_count
	self.pet_btn = widgets.pet_btn

	self.dungeonRoot2 = widgets.dungeonRoot2--普通
	self.dungeonRoot3 = widgets.dungeonRoot3--困难

	-- 切换到单独的控件
	-- self.root1_btn = widgets.root1_btn--剧情
	-- self.root2_btn = widgets.root2_btn
	-- self.root3_btn = widgets.root3_btn

	for i=1, 3 do
		local action = string.format("root%s_action",i)
		local xz = string.format("c_xz%s",i)
		local tmp_score = string.format("score%s",i)
		local zudui_score = string.format("team_score%s",i)
		table.insert(self.danrenScore, widgets[tmp_score])
		table.insert(self.zuduiScore, widgets[zudui_score])
		table.insert(self.root_action, widgets[action])
		table.insert(self.c_xz, self._layout.anis[xz])
	end
	self.no_score = widgets.no_score
	self.no_team_score = widgets.no_team_score
	self.wipe_condition = widgets.wipe_condition

	-- self.root2_desc = widgets.root2_desc
	-- self.root3_desc = widgets.root3_desc
	self.enter_count2 = widgets.enter_count2
	self.enter_count3 = widgets.enter_count3
	self.power_icon2 = widgets.power_icon2
	self.power2 = widgets.power2
	self.power_icon3 = widgets.power_icon3
	self.power3 = widgets.power3

	self.start_btn = widgets.start_btn
	self.start_btn:onClick(self, self.onStart)
	self.start_label = widgets.start_label
	self.buy_btn = widgets.buy_btn

	self.wipe_btn = widgets.wipe_btn
	self.tips = widgets.tips
	self.team_scroll = widgets.team_scroll

	self.level_lable = widgets.level_lable
	self.power_lable = widgets.power_lable
	self.item_scroll = widgets.item_scroll
	self.item_scroll2 = widgets.item_scroll2

	self.power = widgets.power
	self.lvl_lable = widgets.lvl_lable
	self.role_count = widgets.role_count

	self.sj_lable = widgets.sj_lable

	widgets.gold_btn:setVisible(false)
	local masterInfo = g_i3k_game_context:GetMasterBriefInfo()
	if masterInfo.masterId>0 or #masterInfo.apprtcList>0 then
		widgets.master_btn:show()
	else
		widgets.master_btn:hide()
	end
	self.enter_counts = widgets.enter_counts
	self.need_power = widgets.need_power
end

function wnd_create(layout)
	local wnd = wnd_dungeon_sel.new()
	wnd:create(layout)
	return wnd
end
-- LIPING: 修改接口参数含义
	-- bIsTeam   是否为组队副本
	-- mapId     副本Id
	-- teamType  修改，见i3k_global -- 副本类型（副本配置表-副本地图-难度类型）
-- @的deprecated function wnd_dungeon_sel:refresh(zuidui, mapId, goldMap)
function wnd_dungeon_sel:refresh(bIsTeam, mapId, teamType)
	if bIsTeam then
		if g_i3k_game_context:IsInRoom() then
			self:updateDanrenData()
		end
		if teamType==nil or teamType == DUNGEON_DIFF_TEAM then
			self:onZuduiBtnClick(mapId)
		elseif teamType == DUNGEON_DIFF_GOLD then
			self:onGoldBtnClick(mapId)
		elseif teamType == DUNGEON_DIFF_MASTER then
			self:onMasterBtnClick(mapId)
		end
	else
		self:updateDanrenData(mapId)
	end
end

-------------------------UI控件响应相关-----------------------------
--UI单人分页响应函数
function wnd_dungeon_sel:onDanrenBtn(sender)
	--if self.zuduiBtn or self.goldBtn then
	if self.dungeonType~=DUNGEON_TYPE_SINGLE then
		self:updateBtnType("danren_btn")
		self:updateRootType("danrenRoot")
		self._dungeon = -1
		self:updateDanrenData()
	end
end
-- UI组队分页响应函数
function wnd_dungeon_sel:onZuduiBtn(sender)
	--if not self.zuduiBtn or self.goldBtn then
	if self.dungeonType~=DUNGEON_TYPE_TEAM then
		--self.zuduiBtn = true
		--self.goldBtn = false
		self.dungeonType = DUNGEON_TYPE_TEAM
		self:onZuduiBtnClick()
	end
end
-- UI赏金分页响应函数
function wnd_dungeon_sel:onGoldBtn(sender)
	--if not self.goldBtn then
	if self.dungeonType~=DUNGEON_TYPE_GOLD then
		--self.zuduiBtn = true
		--self.goldBtn = true
		self.dungeonType = DUNGEON_TYPE_GOLD
		self:onGoldBtnClick()
	end
end
-- UI师徒分页响应函数
function wnd_dungeon_sel:onMasterBtn(sender)
	if self.dungeonType~=DUNGEON_TYPE_MASTER  then
		self.dungeonType = DUNGEON_TYPE_MASTER
		self:onMasterBtnClick()
	end
end
-- UI创建队伍响应函数
function wnd_dungeon_sel:onCreatebtn(sender)--组队里创建房间
	if g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	local function func()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "createRoomCB")
	end
	g_i3k_game_context:CheckMulHorse(func)
end

-- 快速匹配（跨服）
function wnd_dungeon_sel:onFastMatch(sender)
	local matchType, actType, joinTime = g_i3k_game_context:getMatchState()
	if matchType ~= 0 then
		if matchType == g_DUNGEON_MATCH then
			g_i3k_ui_mgr:OpenUI(eUIID_SignWait)
			g_i3k_ui_mgr:RefreshUI(eUIID_SignWait, joinTime, matchType, actType)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		end
		return
	end
	local function func()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "createRoomCB", true)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

-- UI购买体力
function wnd_dungeon_sel:addVitBtn(sender)
	g_i3k_logic:OpenBuyVitUI()
end
-- UI体力信息
function wnd_dungeon_sel:vitInfo(sender,eventType)--显示恢复体力时间间隔
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_VitTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_VitTips)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_VitTips)
		end
	end
end
-------------------------辅助函数-------------------------------
function wnd_dungeon_sel:createRoomCB(isFastMatch)
	if g_i3k_game_context:GetLevel() < i3k_db_new_dungeon[self._dungeon].reqLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(69))
	end
	local nedd_dungeon = i3k_db_new_dungeon[self._dungeon].conditionDungeon
	if nedd_dungeon ~= -1 then
		if g_i3k_game_context:getDungeonFinishTimes(nedd_dungeon) < 1 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(70, i3k_db_new_dungeon[nedd_dungeon].name, i3k_db_new_dungeon[self._dungeon].name))
		end
	end

	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type==gRoom_Dungeon then
			local fun = (function(ok)
				if ok then
					i3k_sbean.mroom_self()
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(48), fun)
			return
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
			return
		end
	end

	if isFastMatch then
		--副本次数
		local count
		local remainderTimes = g_i3k_game_context:getDungeonDayEnterTimes(self._dungeon)
		local openTimes = i3k_db_new_dungeon[self._dungeon].openTimes
		local goldid = i3k_db_forcewar_base.otherData.goldFuben --黄金副本id
		local Agid =  i3k_db_forcewar_base.otherData.AgFuben--白银
		if self._dungeon == goldid or self._dungeon == Agid then
			count = g_i3k_game_context:getDungeonDayRewardTimes(self._dungeon) or 0
		else
			count = openTimes - remainderTimes >= 0 and openTimes - remainderTimes or 0
		end
		if count == 0 then --跨服匹配添加没有次数提示
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
			return
		end
		i3k_sbean.globalmap_join_request(g_DUNGEON_MATCH, self._dungeon)
	else
		i3k_sbean.mroom_create(self._dungeon)
	end
end

--刷新体力
function wnd_dungeon_sel:updateVitNum(vit, vitMax)
	local str = string.format("%s/%s",vit,vitMax)
	self.vit_value:setText(str)
end

function wnd_dungeon_sel:updateAllBtnNomal()
	for k,v in pairs(self._btn) do
		v:stateToNormal()
	end
end

function wnd_dungeon_sel:updateBtnType(btn)
	self:updateAllBtnNomal()
	for k,v in pairs(self._btn) do
		if k == btn then
			v:stateToPressed()
		end
	end
end

function wnd_dungeon_sel:updateAllRootHide()
	for k,v in pairs(self._root) do
		v:hide()
	end
end

function wnd_dungeon_sel:updateRootType(root)
	self:updateAllRootHide()
	for k,v in pairs(self._root) do
		if k == root then
			v:show()
		end
	end
end

function wnd_dungeon_sel:xiaoYaoBtn()
	g_i3k_ui_mgr:ShowTopMessageBox1(i3k_get_string(1404))
end

function wnd_dungeon_sel:updateSuperMonthCard()
	local endtime = g_i3k_game_context:getRoleSpecialCards(SUPER_MONTH_CARD).cardEndTime
	local nowtime  = i3k_game_get_time()
	local widgets = self._layout.vars
	
	if nowtime  < endtime and self.dungeonType == DUNGEON_TYPE_TEAM then
		widgets.xiaoyao:show()
	else
		widgets.xiaoyao:hide()
	end
end

function wnd_dungeon_sel:onZuduiBtnClick(mapId)
	--判断是否有房间，有房间提示进入
	--self.zuduiBtn = true
	--self.goldBtn = false
	self.dungeonType = DUNGEON_TYPE_TEAM
	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type==gRoom_Dungeon then
			local fun = (function(ok)
				--self.zuduiBtn = false
				--self.goldBtn = false
				self.dungeonType = DUNGEON_TYPE_SINGLE
				if ok then
					i3k_sbean.mroom_self()
				end
			end)
			local desc = i3k_get_string(48)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			return
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
			return
		end
	end
	self:updateBtnType("zudui_btn")
	self:updateRootType("zuduiRoot")
	self._dungeon = -1
	self:updateZuduiData(mapId)
	i3k_sbean.mroom_query(self._dungeon)
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	self:updateVitNum(g_i3k_game_context:GetVit(),g_i3k_game_context:GetVitMax())
	self:updateSuperMonthCard()
end

function wnd_dungeon_sel:onGoldBtnClick(mapId)
	--判断是否有房间，有房间提示进入
	--self.zuduiBtn = true
	--self.goldBtn = true
	self.dungeonType = DUNGEON_TYPE_GOLD
	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type==gRoom_Dungeon then
			local fun = (function(ok)
				--self.zuduiBtn = false
				--self.goldBtn = false
				self.dungeonType = DUNGEON_TYPE_SINGLE
				if ok then
					i3k_sbean.mroom_self()
				end
			end)
			local desc = i3k_get_string(48)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			return
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
			return
		end
	end
	self:updateBtnType("gold_btn")
	self:updateRootType("zuduiRoot")
	self._dungeon = -1
	self:updateGoldData(mapId)
	i3k_sbean.mroom_query(self._dungeon)
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	self:updateVitNum(g_i3k_game_context:GetVit(),g_i3k_game_context:GetVitMax())
	self:updateSuperMonthCard()
end

-- LIPING: 师徒副本标签处理
function wnd_dungeon_sel:onMasterBtnClick(mapId)
	self.dungeonType = DUNGEON_TYPE_MASTER
	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type==gRoom_Dungeon then
			local fun = (function(ok)
				self.dungeonType = DUNGEON_TYPE_SINGLE
				if ok then
					i3k_sbean.mroom_self()
				end
			end)
			local desc = i3k_get_string(48)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			return
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
			return
		end
	end
	self:updateBtnType("master_btn")
	self:updateRootType("zuduiRoot")
	self._dungeon = -1
	self:updateMasterData(mapId)
	i3k_sbean.mroom_query(self._dungeon)
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	self:updateVitNum(g_i3k_game_context:GetVit(),g_i3k_game_context:GetVitMax())
	self:updateSuperMonthCard()
end

function wnd_dungeon_sel:updateDanrenData(mapId)
	--self.zuduiBtn = false
	--self.goldBtn = false
	self.dungeonType = DUNGEON_TYPE_SINGLE

	self.fb_scroll:removeAllChildren()
	local width = self.fb_scroll:getContentSize().width
	self.fb_scroll:setContainerSize(width,0)
	local count = 0
	self._data = {}
	local now_taskID = g_i3k_game_context:getMainTaskIdAndVlaue()
	local dungeon_cfg_data = g_i3k_game_context:GetCacheDungeonCfgData()
	local finishCount = g_i3k_game_context:getDungeonFinishTimes(mapId)
	local beforeFinishCount = 0
	if mapId then
		beforeFinishCount = g_i3k_game_context:getDungeonFinishTimes(mapId-1)
	end

	if self._dungeon == -1 then
		if finishCount > 0 then
			self._dungeon = mapId
		else
			for k, v in ipairs(dungeon_cfg_data) do
				for a,b in pairs(v) do---v代表副本id
					if beforeFinishCount >= 1 then---判断前一个完成次数>=1
						self._dungeon  = mapId
					else
						if b == mapId then
							self._dungeon  = mapId ---- wtf ??? (- a + 1)
						end
					end
				end
			end
		end
		--self._dungeon = mapId  or -1
	else
		self._dungeon = -1
	end
	local groupId = 0
	local Index = 0
	if i3k_db_new_dungeon[self._dungeon] then
		groupId = i3k_db_new_dungeon[self._dungeon].teamid
	end
	for k, v in ipairs(dungeon_cfg_data) do
		local dungeon_id = 0
		for a,b in ipairs(v) do
			local difficulty = a
			local id = b
			if difficulty == 1 then--剧情
				local finshCount = g_i3k_game_context:getDungeonFinishTimes(id)
				if finshCount <= 0 then
					dungeon_id = id
					break
				end
			else
				dungeon_id = id
				break
			end
		end
		-- 当为0的时候，取到表中的最小值（不是以下标为1开始）
		if dungeon_id == 0 then
			for a,b in pairs(v) do
				if dungeon_id == 0 then
					dungeon_id = b
				end
				if dungeon_id > b then
					dungeon_id = b
				end
			end
		end
		-- local dungeon_name = i3k_db_dungeon_base[dungeon_id].desc
		local dungeon_desc = i3k_db_dungeon_base[dungeon_id].desc or "unknow"
		local dungeon_iconid = i3k_db_new_dungeon[dungeon_id].iconid
		-- local difficulty = i3k_db_new_dungeon[dungeon_id].difficulty
		local beforeTask = i3k_db_new_dungeon[dungeon_id].beforeTask
		count = count + 1
		local _layer = require(LAYER_FBT)()
		local widgets = _layer.vars
		widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(dungeon_iconid))
		widgets.name:setText(dungeon_desc)
		-- 如果当前组里最小号副本任务id已经小于主线任务id，那么置灰
		if beforeTask ~= -1  then
			widgets.is_lock:setVisible(now_taskID < beforeTask)
			local iconId = now_taskID > beforeTask and SelectBg[3] or SelectBg[1]
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
			if now_taskID < beforeTask then
				widgets.icon:disable()
				--widgets.name:disable()
			end
		else
			widgets.is_lock:hide()
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[3]))
		end

		if count == 1 and self._dungeon == -1 then
			self._dungeon = dungeon_id
		end
		widgets.is_show:setVisible(dungeon_id == self._dungeon or groupId == k)
		if dungeon_id == self._dungeon or groupId == k then
			Index = count
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[1]))
		end
		widgets.select1_btn:onClick(self, self.onDungeonClick, dungeon_id)---副本框
		self._data[dungeon_id] = {id = dungeon_id,is_show = widgets.is_show, groupid = k,bg = widgets.bg}
		self.fb_scroll:addItem(_layer)
	end
	self.fb_scroll:show()
	self.fb_scroll:jumpToChildWithIndex(Index)
	self:updateDungeonData()
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	self:updateVitNum(g_i3k_game_context:GetVit(),g_i3k_game_context:GetVitMax())
end

function wnd_dungeon_sel:updateFastMatchBtn()
	self.fastMatchBtn:setVisible(self.dungeonType ~= DUNGEON_TYPE_MASTER)
end

function wnd_dungeon_sel:updateZuduiData(mapId)
	self.fb_scroll:removeAllChildren()
	local width = self.fb_scroll:getContentSize().width
	self.fb_scroll:setContainerSize(width,0)
	local count = 0
	self._data = {}
	local tmp_dungeon = {}
	for k, v in pairs(i3k_db_new_dungeon) do
		if v.difficulty == -1 then
			table.insert(tmp_dungeon,v)
		end
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.reqLvl < b.reqLvl
	end)
	local now_taskID = g_i3k_game_context:getMainTaskIdAndVlaue()
	local Index = 0
	if self._dungeon == -1 then
		self._dungeon = mapId or -1
	end
	for k, v in ipairs(tmp_dungeon) do
		count = count + 1
		local _layer = require(LAYER_FBT)()
		local widgets = _layer.vars
		widgets.is_show:hide()
		local beforeTask = i3k_db_new_dungeon[v.id].beforeTask
		if beforeTask ~= -1  then
			widgets.is_lock:setVisible(now_taskID <= beforeTask)
			local iconId = now_taskID > beforeTask and SelectBg[3] or SelectBg[1]
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		else
			widgets.is_lock:hide()
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[3]))
		end
		widgets.name:setText(i3k_db_dungeon_base[v.id].desc)
		widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconid))
		if count == 1 and self._dungeon == -1 then
			self._dungeon = v.id
		end
		if v.id == self._dungeon then
			widgets.is_show:show()
			Index = count
		end
		widgets.select1_btn:onClick(self, self.onTeamDungeon, v.id)---副本框
		self._data[v.id] = {id = v.id, is_show = widgets.is_show, bg = widgets.bg}
		self.fb_scroll:addItem(_layer)
	end
	self.fb_scroll:show()
	self.fb_scroll:jumpToChildWithIndex(Index)
	self:updateTeamsData()
	self:SetTeamDungeonData()
end

function wnd_dungeon_sel:updateGoldData(mapId)
	self.fb_scroll:removeAllChildren()
	local width = self.fb_scroll:getContentSize().width
	self.fb_scroll:setContainerSize(width,0)
	local count = 0
	self._data = {}
	local tmp_dungeon = {}
	for k, v in pairs(i3k_db_new_dungeon) do
		if v.difficulty == -2 then
			table.insert(tmp_dungeon,v)
		end
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.reqLvl < b.reqLvl
	end)
	local now_taskID = g_i3k_game_context:getMainTaskIdAndVlaue()
	local Index = 0
	if self._dungeon == -1 then
		self._dungeon = mapId or -1
	end
	for k, v in ipairs(tmp_dungeon) do
		count = count + 1
		local _layer = require(LAYER_FBT)()
		local widgets = _layer.vars
		widgets.is_show:hide()
		local beforeTask = i3k_db_new_dungeon[v.id].beforeTask
		if beforeTask ~= -1  then
			widgets.is_lock:setVisible(now_taskID <= beforeTask)
			local iconId = now_taskID > beforeTask and SelectBg[3] or SelectBg[1]
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		else
			widgets.is_lock:hide()
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[3]))
		end
		widgets.name:setText(i3k_db_dungeon_base[v.id].desc)
		widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconid))
		if count == 1 and self._dungeon == -1 then
			self._dungeon = v.id
		end
		if v.id == self._dungeon then
			widgets.is_show:show()
			Index = count
		end
		widgets.select1_btn:onClick(self, self.onTeamDungeon, v.id)---副本框
		self._data[v.id] = {id = v.id, is_show = widgets.is_show, bg = widgets.bg}
		self.fb_scroll:addItem(_layer)
	end
	self.fb_scroll:show()
	self.fb_scroll:jumpToChildWithIndex(Index)
	self:updateTeamsData()
	self:SetTeamDungeonData()
end
-- LIPING：更新师徒副本内容
function wnd_dungeon_sel:updateMasterData(mapId)
	self.fb_scroll:removeAllChildren()
	local width = self.fb_scroll:getContentSize().width
	self.fb_scroll:setContainerSize(width,0)
	local count = 0
	self._data = {}
	local tmp_dungeon = {}
	for k, v in pairs(i3k_db_new_dungeon) do
		if v.difficulty == -3 then
			table.insert(tmp_dungeon,v)
		end
	end
	table.sort(tmp_dungeon,function (a,b)
		return a.reqLvl < b.reqLvl
	end)
	local now_taskID = g_i3k_game_context:getMainTaskIdAndVlaue()
	local Index = 0
	if self._dungeon == -1 then
		self._dungeon = mapId or -1
	end
	for k, v in ipairs(tmp_dungeon) do
		count = count + 1
		local _layer = require(LAYER_FBT)()
		local widgets = _layer.vars
		widgets.is_show:hide()
		local beforeTask = i3k_db_new_dungeon[v.id].beforeTask
		if beforeTask ~= -1  then
			widgets.is_lock:setVisible(now_taskID <= beforeTask)
			local iconId = now_taskID > beforeTask and SelectBg[3] or SelectBg[1]
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		else
			widgets.is_lock:hide()
			widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[3]))
		end
		widgets.name:setText(i3k_db_dungeon_base[v.id].desc)
		widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconid))
		if count == 1 and self._dungeon == -1 then
			self._dungeon = v.id
		end
		if v.id == self._dungeon then
			widgets.is_show:show()
			Index = count
		end
		widgets.select1_btn:onClick(self, self.onTeamDungeon, v.id)---副本框
		self._data[v.id] = {id = v.id, is_show = widgets.is_show, bg = widgets.bg}
		self.fb_scroll:addItem(_layer)
	end
	self.fb_scroll:show()
	self.fb_scroll:jumpToChildWithIndex(Index)
	self:updateTeamsData()
	self:SetTeamDungeonData()
end

function wnd_dungeon_sel:updateTeamsData()
	local data = g_i3k_game_context:GetListData()
	self.team_scroll:removeAllChildren()
	if next(data) then
		self.tips:hide()
	else
		self.tips:show()
	end
	for k,v in pairs(data) do
		local _layer = require(LAYER_FJDWT)()
		local teamName_lable = _layer.vars.teamName_lable
		local teamid_lable = _layer.vars.teamid_lable
		local teamCount_lable = _layer.vars.teamCount_lable
		local join_btn = _layer.vars.join_btn
		local tmp_str = string.format("%s的队伍",v.leaderName)
		teamName_lable:setText(tmp_str)
		teamid_lable:hide()
		--teamid_lable:setText(v.id)
		local tmp_str = string.format("%s/%s",v.count,MAX_COUNT)
		teamCount_lable:setText(tmp_str)
		teamCount_lable:setTextColor(g_i3k_get_cond_color(v.count ~= MAX_COUNT))
		join_btn:onClick(self, self.onEnterTeam, {id = v.id, count = v.count})--加入队伍
		self.team_scroll:addItem(_layer)
	end
end

function wnd_dungeon_sel:updateDungeonData()
	if self.dungeonType==DUNGEON_TYPE_SINGLE then
		self:updateDanrenAwardItem()
		self:updatePetBtn()
		self:updateDanrenDifficult()
	end
end

function wnd_dungeon_sel:updateDanrenAwardItem()
	local _t = i3k_db_new_dungeon[self._dungeon]
	if not _t then
		return
	end
	if self._data[self._dungeon] then
		self._data[self._dungeon].bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[2]))
	else
		for i, e in pairs(self._data) do
			if i3k_db_new_dungeon[self._dungeon].teamid == i3k_db_new_dungeon[e.id].teamid then
				e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[2]))
				break
			end
		end
	end
	local groupid = _t.teamid
	local difficulty = _t.difficulty
	local reqLvl = _t.reqLvl
	local enterPower = _t.enterPower
	self.item_scroll:removeAllChildren()
	self.item_scroll:setBounceEnabled(false)
	self.level_lable:setText(reqLvl)
	--self.level_lable:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= reqLvl))
	self.power_lable:setText(enterPower)
	--self.power_lable:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetRolePower() >= enterPower))
	local max_count = g_i3k_game_context:GetNormalMapEnterTotalTimes(self._dungeon)
	local tmp_count = g_i3k_game_context:getDungeonDayEnterTimes(self._dungeon)
	local times = max_count - tmp_count >= 0 and max_count - tmp_count or 0
	self.enter_counts:setText(times)
	self.need_power:setText(_t.consume)
	self:updateDanrenScore(self._dungeon)
	local item_data = {}
	for i=1,6 do
		local temp_item = string.format("awardItem%s",i)
		local itemid = _t[temp_item]
		if itemid ~= 0 then
			table.insert(item_data,itemid)
		end
	end
	for k,v in ipairs(item_data) do
		local _a = require(LAYER_DJ1)()
		_a.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		_a.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
		_a.vars.item_count:hide()
		_a.vars.bt:onClick(self, self.onItemTips, v)
		self.item_scroll:addItem(_a)
	end
	self:updateWipeData()
end

function wnd_dungeon_sel:showDanrenScore()
	for i, e in pairs(self.danrenScore) do
		e:show()
	end
end

function wnd_dungeon_sel:updateDanrenScore(mapId)
	local score = g_i3k_game_context:getDungeonEndSocre(mapId)
	for i, e in pairs(self.danrenScore) do
		e:hide()
	end
	self.no_score:setVisible(score==0)
	self.danrenScore[2]:setVisible(score~=0)
	if score == 1 then
		self.danrenScore[2]:show()
		self.danrenScore[1]:hide()
		self.danrenScore[3]:hide()
	elseif score == 2 then
		self.danrenScore[2]:show()
		self.danrenScore[1]:show()
		self.danrenScore[3]:hide()
	elseif score == 3 then
		self:showDanrenScore()
	end
end

function wnd_dungeon_sel:showZuduiScore()
	for i, e in pairs(self.zuduiScore) do
		e:show()
	end
end

function wnd_dungeon_sel:updateZuduiScore(mapId)
	local score = g_i3k_game_context:getDungeonEndSocre(mapId)
	for i, e in pairs(self.zuduiScore) do
		e:hide()
	end
	self.no_team_score:setVisible(score==0)
	self.zuduiScore[2]:setVisible(score~=0)
	if score == 1 then
		self.zuduiScore[2]:show()
		self.zuduiScore[1]:hide()
		self.zuduiScore[3]:hide()
	elseif score == 2 then
		self.zuduiScore[2]:show()
		self.zuduiScore[1]:show()
		self.zuduiScore[3]:hide()
	elseif score == 3 then
		self:showZuduiScore()
	end
end

-- 设置单人副本中，选中了那个副本
function wnd_dungeon_sel:selectAction(tag)
	for i,v in ipairs(self._scroll_children) do
		local cfg = i3k_db_new_dungeon[v.id]
		local dungeonType = cfg.difficulty
		local normal_img_id = SINGLE_MAPCOPY_BUTTON[dungeonType].normal
		local pressed_img_id = SINGLE_MAPCOPY_BUTTON[dungeonType].selected
		-- v.btn:setImage(g_i3k_db.i3k_db_get_icon_path(normal_img_id), g_i3k_db.i3k_db_get_icon_path(pressed_img_id))
		v.btn:setPressedImgs(g_i3k_db.i3k_db_get_icon_path(normal_img_id), g_i3k_db.i3k_db_get_icon_path(pressed_img_id))
		if cfg.difficulty == tag then
			v.btn:stateToPressed()
		else
			local visiable, isOpen = self:checkSingleMapcopyOpen(v.id)
			if isOpen then
				v.btn:stateToNormal()
			end
		end
	end
end

function wnd_dungeon_sel:updateStartBtn(difficulty)
	if difficulty == 1 then
		self.start_btn:show()
		self.buy_btn:hide()
		self.start_btn:enableWithChildren()
	else
		local total_times = g_i3k_game_context:GetNormalMapEnterTotalTimes(self._dungeon)
		local tmp_count = g_i3k_game_context:getDungeonDayEnterTimes(self._dungeon)
		local vipLevel = g_i3k_game_context:GetVipLevel()
		local buyTimes = i3k_db_kungfu_vip[vipLevel].buyDungeonTimes
		if vipLevel == 0 then
			self.buy_btn:hide()
			if tmp_count >= total_times then
				self.start_btn:disableWithChildren()
			else
				self.start_btn:enableWithChildren()
			end
		else
			self.start_btn:enableWithChildren()
			self.start_btn:setVisible(tmp_count<total_times)
			self.buy_btn:setVisible(tmp_count>=total_times)
			self.buy_btn:onClick(self, self.buyDungeonBtn, self._dungeon)
		end
	end
end


-- 重写此函数。选择副本改为用一个进度条
function wnd_dungeon_sel:updateDanrenDifficult()
	local scroll = self._layout.vars.single_mc_list
	self._scroll_children = {}
	scroll:removeAllChildren()
	-- 测试设置layer
	local data = self:getSingleMapcopyData(self._dungeon)
	local firstSelectFlag = false
	for i, v in ipairs(data) do
		local layer = require(LAYER_FBT2)()
		local widget = layer.vars
		local dungeonType = v.type
		local normal_img_id = SINGLE_MAPCOPY_BUTTON[dungeonType].normal
		local pressed_img_id = SINGLE_MAPCOPY_BUTTON[dungeonType].selected
		local disabled_img_id = SINGLE_MAPCOPY_BUTTON[dungeonType].unlocked
		widget.btn:setImage(g_i3k_db.i3k_db_get_icon_path(normal_img_id), g_i3k_db.i3k_db_get_icon_path(pressed_img_id))
		if v.isOpen then
			widget.btn:onClick(self, self.onDungeonDifficulty, v.id)
			if not firstSelectFlag then
				firstSelectFlag = true
				widget.btn:setPressedImgs(g_i3k_db.i3k_db_get_icon_path(normal_img_id), g_i3k_db.i3k_db_get_icon_path(pressed_img_id))
				widget.btn:stateToPressed()
			end
		else
			-- widget.btn:onClick(self, self.onDungeonDifficulty, v.id)
			widget.btn:stateToPressedAndDisable()
			widget.btn:setImage(g_i3k_db.i3k_db_get_icon_path(disabled_img_id))
		end
		table.insert(self._scroll_children, {id = v.id, btn = widget.btn})
		scroll:addItem(layer)
	end
	-- 如果列表中只有一个，那么在后面添加一个空白的
	if #data == 1 then
		local layer = require(LAYER_FBT3)()
		scroll:addItem(layer)
	end
	local visiable, isOpen = self:checkSingleMapcopyOpen(self._dungeon)
	if isOpen then
		self:selectAction(i3k_db_new_dungeon[self._dungeon].difficulty)
	end
end

-- 由于单人副本部分拆分成一个列表，此函数返回列表中的项数据
-- 根据这个id，遍历所有组号相同的数据
function wnd_dungeon_sel:getSingleMapcopyData(dungeonID)
	local cfg = i3k_db_new_dungeon[dungeonID] -- 获取一列配置即当前正在处于的副本进度
	local gruopID = cfg.teamid
	local roleLevel = g_i3k_game_context:GetLevel()
	local dungeon_cfg_data = g_i3k_game_context:GetCacheDungeonCfgData() -- 缓存的表数据，可以索引当前组号的所有副本id
	local data = {}
	-- 根据一个id，遍历当前组的所有副本ID
	-- 检查是否有剧情副本
	local storyTypeId = dungeon_cfg_data[gruopID][1]
	if storyTypeId then
		local itemCfg = i3k_db_new_dungeon[storyTypeId]
		if itemCfg then
			local visiable, isOpen = self:checkSingleMapcopyOpen(itemCfg.id)
			if visiable then
				table.insert(data, {id = itemCfg.id, type = SINGLE_MAPCOPY_TASK, isOpen = isOpen})
			end
		end
	end
	-- 设置普通副本
	local normalId = dungeon_cfg_data[gruopID][2]
	if normalId then
		local itemCfg = i3k_db_new_dungeon[normalId]
		if itemCfg then
			local visiable, isOpen = self:checkSingleMapcopyOpen(itemCfg.id)
			if visiable then
				table.insert(data, {id = itemCfg.id, type = SINGLE_MAPCOPY_NORMAL, isOpen = isOpen})
			end
		end
	end
	-- 设置困难副本
	local hardId = dungeon_cfg_data[gruopID][3]
	if hardId then
		local itemCfg = i3k_db_new_dungeon[hardId]
		if itemCfg then
			local visiable, isOpen = self:checkSingleMapcopyOpen(itemCfg.id)
			if visiable then
				--local tmp_str = string.format("%s/%s", tmp_count, max_count)
				table.insert(data, {id = itemCfg.id, type = SINGLE_MAPCOPY_HARD, isOpen = isOpen})
			end
		end
	end
	return data
end

-- 如果是disable的根本就不会选中
function wnd_dungeon_sel:checkSingleMapcopyOpen(dungeonID)
	local cfg = i3k_db_new_dungeon[dungeonID]
	local dungeon_cfg_data = g_i3k_game_context:GetCacheDungeonCfgData() -- 缓存的表数据，可以索引当前组号的所有副本id
	local visiable = false -- 是否可见
	local isOpen = false -- 是否开启
	-- local levelReq = false -- 等级需求
	-- 检查上一个等级副本是否开启
	if cfg then
		if cfg.difficulty == 1 then
			local beforeTask = cfg.beforeTask
			local mId, value, state = g_i3k_game_context:getMainTaskIdAndVlaue()
			if beforeTask == mId then
				isOpen = true
			end
			-- 是否可见，根据普通副本的前置是否是剧情本
			local gruopID = cfg.teamid
			local normalId = dungeon_cfg_data[gruopID][2]
			if normalId then
				local normalCfg = i3k_db_new_dungeon[normalId]
				if normalCfg and normalCfg.conditionDungeon == dungeonID then
					visiable = true
				end
			end
		elseif cfg.difficulty == 2 then
			if cfg.conditionDungeon ~= -1 then
				if g_i3k_game_context:getDungeonFinishTimes(cfg.conditionDungeon) > 0 then
					isOpen = true
				end
			else
				local mId, value, state = g_i3k_game_context:getMainTaskIdAndVlaue()
				local beforeTask = cfg.beforeTask
				if beforeTask <= mId then
					isOpen = true
				end
			end
			visiable = true
		elseif cfg.difficulty == 3 then
			if g_i3k_game_context:getDungeonFinishTimes(cfg.conditionDungeon) > 0 then
				isOpen = true
			end
			visiable = true
		end
		-- 检查等级要求(硬条件)
		-- local roleLevel = g_i3k_game_context:GetLevel()
		-- if cfg.reqLvl <= roleLevel then
		-- 	levelReq = true
		-- end
		return visiable, isOpen -- and levelReq -- 等级不足也显示出来
	end
	return false, false
end
--------------------------------------------

function wnd_dungeon_sel:updatePetBtn()
	self.pet_btn:onClick(self, self.onPetSet)
end

local SCORE_DESC = {"一星","二星","三星",}
function wnd_dungeon_sel:updateWipeData()
	self.wipe_item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(wipe_itemid,i3k_game_context:IsFemaleRole()))
	self.wipe_item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(wipe_itemid))
	local _t = i3k_db_new_dungeon[self._dungeon]
	local difficulty = _t.difficulty
	self:updateStartBtn(difficulty)
	local openTimes = _t.openTimes
	local enter_count = 0
	local is_ok = false
	local finishCount = g_i3k_game_context:getDungeonFinishTimes(self._dungeon)
	if finishCount > 0 then
		is_ok = true
		enter_count = g_i3k_game_context:getDungeonDayEnterTimes(self._dungeon)
	end

	if g_i3k_game_context:GetLevel() < _t.wipeLvl  and openTimes ~= -1 then
		local desc = string.format("（等级达到%s级可扫荡）", _t.wipeLvl)
		self.wipe_condition:setText(desc)
	else
		local desc = string.format("（评分达到%s可扫荡）", SCORE_DESC[_t.wipeScore])
		self.wipe_condition:show()
		self.wipe_condition:setText(desc)
	end

	self.wipe_btn:onClick(self, self.onWipeDungeon)
	self.wipe_btn:enableWithChildren()
	self.wipeState = 0
	if not is_ok then
		self.wipeState = WIPE_STATE_OPENLIMIT
	else
		if g_i3k_game_context:GetLevel() < _t.wipeLvl then
			self.wipeState = WIPE_STATE_LVLLIMIT
		elseif g_i3k_game_context:getDungeonEndSocre(self._dungeon) < _t.wipeScore and is_ok then
			self.wipeState = WIPE_STATE_SOCLIMIT
		elseif g_i3k_game_context:GetNormalMapEnterTotalTimes(self._dungeon) <= enter_count then
			self.wipeState = WIPE_STATE_NUMLIMIT
		end
	end

	if openTimes==-1 then
		self.wipe_condition:setText("(剧情副本不可扫荡)")
		self.wipe_btn:disableWithChildren()
	end
end

function wnd_dungeon_sel:SetTeamDungeonData()
	local _t = i3k_db_new_dungeon[self._dungeon]
	if not _t then
		return
	end
	local str = 0
	local isGlod = false
	local remainderTimes = g_i3k_game_context:getDungeonDayEnterTimes(self._dungeon)

	local openTimes = i3k_db_new_dungeon[self._dungeon].openTimes
	local goldid = i3k_db_forcewar_base.otherData.goldFuben --黄金副本id
	local Agid =  i3k_db_forcewar_base.otherData.AgFuben--白银
	if self._dungeon == goldid or self._dungeon == Agid then
		local rewardTimes= g_i3k_game_context:getDungeonDayRewardTimes(self._dungeon)---黄金副本的次数
		str = rewardTimes or 0
		isGlod = true
	else
		str = openTimes - remainderTimes >= 0 and openTimes - remainderTimes or 0
	end

	local desc = ""
	if isGlod then
		desc = i3k_get_string(15424)
	end
	if str == 0 then
		desc = string.format("%s%s%s", desc, isGlod and "\n" or "", i3k_get_string(15425))
	end
	self.sj_lable:setVisible(desc ~= "")
	self.sj_lable:setText(desc)

	self.remain_times:setText(string.format("%s", str))
	--self.remain_times:setTextColor(g_i3k_get_cond_color(str > 0))
	if self._data[self._dungeon] then
		self._data[self._dungeon].bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[2]))
	end
	self.item_scroll2:removeAllChildren()
	self.item_scroll2:setBounceEnabled(false)
	self.lvl_lable:setText(_t.reqLvl)
	self.power:setText(_t.enterPower)
	--self.lvl_lable:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= _t.reqLvl))
	--self.power:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetRolePower() >= _t.enterPower))
	self.role_count:setText(_t.minPlayer)
	self:updateZuduiScore(self._dungeon)
	local item_data = {}
	for i=1,6 do
		local temp_item = string.format("awardItem%s",i)
		local itemid = _t[temp_item]
		if itemid ~= 0 then
			table.insert(item_data,itemid)
		end
	end
	for k,v in ipairs(item_data) do
		local _a = require(LAYER_DJ1)()
		_a.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
		_a.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
		_a.vars.item_count:hide()
		_a.vars.bt:onClick(self, self.onItemTips, v)
		self.item_scroll2:addItem(_a)
	end
	self:updateFastMatchBtn()
end

function wnd_dungeon_sel:onPetSet(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SuicongDungeonPlay)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuicongDungeonPlay)
end

function wnd_dungeon_sel:onItemTips(sender, args)
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end

function wnd_dungeon_sel:onEnterTeam(sender, info)
	if g_i3k_game_context:getMatchState() ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	local function func()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB, "enterTeamCb", info)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_dungeon_sel:enterTeamCb(info)
	if info.count == MAX_COUNT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(391))
		return
	end
	-- local room = g_i3k_game_context:IsInRoom()
	-- if room then
	-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(392))
	-- 	return
	-- end
	-- local hero_lvl = g_i3k_game_context:GetLevel()
	-- local needLevel = i3k_db_new_dungeon[self._dungeon].reqLvl
	-- if hero_lvl < needLevel then
	-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(69))
	-- 	return
	-- end
	-- local dayEnterCount = g_i3k_game_context:getDungeonDayEnterTimes(self._dungeon)
	-- local nedd_dungeon = i3k_db_new_dungeon[self._dungeon].conditionDungeon
	-- local finishCount = g_i3k_game_context:getDungeonFinishTimes(nedd_dungeon)
	-- if nedd_dungeon ~= -1 then
	-- 	if finishCount < 1 then
	-- 		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(70, i3k_db_new_dungeon[nedd_dungeon].name, i3k_db_new_dungeon[self._dungeon].name))
	-- 		return
	-- 	end
	-- end
	-- --副本次数
	-- local count = i3k_db_new_dungeon[self._dungeon].openTimes

	-- local goldid = i3k_db_forcewar_base.otherData.goldFuben --黄金副本id
	-- local Agid =  i3k_db_forcewar_base.otherData.AgFuben--白银
	-- if self._dungeon == goldid or self._dungeon == Agid then

	-- 	local rewardTimes= g_i3k_game_context:getDungeonDayRewardTimes(self._dungeon)-----势力战获得的黄金/白银组队副本
	-- 	count = count+rewardTimes
	-- end
	-- if count ~= -1 then
	-- 	if dayEnterCount  >= count then
	-- 		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
	-- 		return
	-- 	end
	-- end
	-- local data = i3k_sbean.mroom_enter_req.new()
	-- data.roomId = info.id
	-- data.mapId = self._dungeon
	-- i3k_game_send_str_cmd(data,i3k_sbean.mroom_enter_res.getName())
	g_i3k_game_context:MroomEnterReq(self._dungeon, info.id)
end

function wnd_dungeon_sel:onWipeDungeon(sender)

	if self.wipeState == WIPE_STATE_LVLLIMIT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(613))
	elseif self.wipeState == WIPE_STATE_SOCLIMIT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(614))
	elseif self.wipeState == WIPE_STATE_NUMLIMIT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(616))
	elseif self.wipeState == WIPE_STATE_OPENLIMIT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(617))
	else
		g_i3k_logic:OpenDungeonWipe(self._dungeon)
	end
end

function wnd_dungeon_sel:onDungeonClick(sender, tag)
	if i3k_db_new_dungeon[self._dungeon].teamid == i3k_db_new_dungeon[tag].teamid then
		return
	end
	for i, e in pairs(self._data) do
		local now_taskID = g_i3k_game_context:getMainTaskIdAndVlaue()
		local beforeTask = i3k_db_new_dungeon[e.id].beforeTask
		if beforeTask ~= -1  then
			local iconId = now_taskID > beforeTask and SelectBg[3] or SelectBg[1]
			e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
		else
			e.bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[3]))
		end
	end
	if self._data[tag] then
		self._data[tag].bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[2]))
	end
	for k,v in pairs(self._data) do
		v.is_show:setVisible(k == tag)
	end
	self._dungeon = tag
	self:updateDungeonData()
end

function wnd_dungeon_sel:onDungeonDifficulty(sender, data)
	self._dungeon = data
	self:selectAction(i3k_db_new_dungeon[self._dungeon].difficulty)
	self:updateDanrenAwardItem()
end

function wnd_dungeon_sel:onTeamDungeon(sender, tag)
	if self._dungeon == tag then
		return
	end
	if self._data[self._dungeon] then
		self._data[self._dungeon].bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[3]))
	end
	self._data[tag].bg:setImage(g_i3k_db.i3k_db_get_icon_path(SelectBg[2]))
	for k,v in pairs(self._data) do
		v.is_show:setVisible(k == tag)
	end
	self._dungeon = tag
	i3k_sbean.mroom_query(self._dungeon)
	self:SetTeamDungeonData()
end

function wnd_dungeon_sel:onStart(sender)
	local function func()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FBLB,"startCB")
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_dungeon_sel:startCB()
	local hero_lvl = g_i3k_game_context:GetLevel()

	local func3 = function () -- 随从
		local allPets, playPets = g_i3k_game_context:GetYongbingData()
		local count = 0
		if playPets[DUNGEON] then
			count = #playPets[DUNGEON]
		end
		local have = 0
		for k,v in pairs(allPets) do
			have = have + 1
		end
		local max_count = 1
		local first = g_i3k_db.i3k_db_get_common_cfg().posUnlock.first;
		local second = g_i3k_db.i3k_db_get_common_cfg().posUnlock.second;
		local third = g_i3k_db.i3k_db_get_common_cfg().posUnlock.third;
		if hero_lvl >= third then
			max_count = 3
		elseif hero_lvl >= second then
			max_count = 2
		end
		if count < max_count  and have - count > 0 then
			local fun = (function(ok)
				if ok then
					g_i3k_ui_mgr:OpenUI(eUIID_SuicongDungeonPlay)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuicongDungeonPlay)
				else
					self:enterDungeon(self._dungeon)
				end
			end)
			local desc = i3k_get_string(286)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			return
		else
			self:enterDungeon(self._dungeon)
		end
	end

	local func2 = function ()  --队伍
		if self._dungeon and self._dungeon > 0 then
			if i3k_db_new_dungeon[self._dungeon].difficulty ~= 0 then
				local teamId = g_i3k_game_context:GetTeamId()
				if teamId ~= 0 then
					local fun = (function(ok)
						if not ok then
							return
						else
							func3()
						end
					end)
					g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(68),fun)
					return
				else
					func3()
					return
				end
			end
			self:enterDungeon()
		end
	end

	local func1 = function ()  --相依相偎
		if not g_i3k_db.i3k_db_get_dungeon_can_enter(self._dungeon) then
			local startTime = g_i3k_db.i3k_db_get_dungeon_start_time(self._dungeon)
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(307, i3k_db_new_dungeon[self._dungeon].name, startTime))
		end

		if hero_lvl < i3k_db_new_dungeon[self._dungeon].reqLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(60))
			return
		end
		if g_i3k_game_context:GetVit() < i3k_db_new_dungeon[self._dungeon].consume then
			g_i3k_logic:GotoOpenBuyVitUI()
			return
		end
		local beforeTask = i3k_db_new_dungeon[self._dungeon].beforeTask
		if beforeTask ~= -1 then
			local mId,value,state = g_i3k_game_context:getMainTaskIdAndVlaue()
			local score = g_i3k_game_context:getDungeonEndSocre(self._dungeon)
			if mId < beforeTask then
				local mainTaskCfg = g_i3k_db.i3k_db_get_main_task_cfg(beforeTask)
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(62, mainTaskCfg.name))
				return
				-- 此处由于去掉了剧情本，所以没有此限制
			-- elseif mId > beforeTask then
			-- 	g_i3k_ui_mgr:PopupTipMessage(string.format("剧情副本只能通关一次"))
			-- 	return
			elseif mId == beforeTask and state == 0 then
				g_i3k_ui_mgr:PopupTipMessage("请先接取主线任务")
				return
			end
		end
		func2()
	end

	func1()

end

function wnd_dungeon_sel:enterDungeon(mapId)
	local fun = function(ok)
		if ok then
			g_i3k_game_context:ClearFindWayStatus()
			i3k_sbean.normalmap_start(mapId)
		end
	end
	g_i3k_game_context:CheckJudgeEmailIsFull(fun, true)
end

--单人里购买
function wnd_dungeon_sel:buyDungeonBtn(sender, mapId)
	local vipLevel = g_i3k_game_context:GetVipLevel()
	local buyTimes = i3k_db_kungfu_vip[vipLevel].buyDungeonTimes
	local index
	for i=1, #i3k_db_kungfu_vip do
		local cfg = i3k_db_kungfu_vip[i]
		if cfg.buyDungeonTimes > buyTimes then
			index = i
			break
		end
	end
	if index and g_i3k_game_context:GetNormalMapDayBuyTimes(mapId) == buyTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(269, index, i3k_db_new_dungeon[mapId].name, i3k_db_kungfu_vip[index].buyDungeonTimes - buyTimes))
		return
	elseif not index and g_i3k_game_context:GetNormalMapDayBuyTimes(mapId) == buyTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(268, i3k_db_new_dungeon[mapId].name))
		return
	end

	if vipLevel > 0 and buyTimes >= 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_BuyDungeonTimes)
		g_i3k_ui_mgr:RefreshUI(eUIID_BuyDungeonTimes, {mapId = mapId, vipLevel = vipLevel, buyTimes = buyTimes, mapType = 1})
	end
end

function wnd_dungeon_sel:updateDungeonUI()
	--if self.zuduiBtn then
	if self.dungeonType~=DUNGEON_TYPE_SINGLE then
		g_i3k_ui_mgr:CloseUI(eUIID_FBLB)
	end
end
