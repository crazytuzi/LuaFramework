-------------------------------------------------------
-- eUIID_DailyTask
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_dailyTask = i3k_class("wnd_dailyTask", ui.wnd_base)

local detailTable = {[1] = 1, [2] = 2, [13] = 13, [14] = 14, [15] = 15, [16] = 16,}
local l_tNotShowCount = {[1] = true, [2] = true, [24] = true, [75] = true}
local l_tTabName = {[1] = "rw#tzrw.png",[2] = "rw#mingwang.png",[3] = "rw#qiyuan.png"}
local l_pItem 	= "ui/widgets/rcht1"
local l_pItem2 = "ui/widgets/rcht2"
local l_pItem3 = "ui/widgets/rcht3"
local mingwangGetReward 	= "ui/widgets/mwt1"
local mingwangNeedItem 		= "ui/widgets/mwt2"
local mingwangTitle 		= "ui/widgets/mwt3"
local finishChallengeWidget = "ui/widgets/rcht3"
--local l_sExp 	= "ty#exp.png"
local l_sExpTab = {491}

local challengeTypeCount = 5
local epicChallengeType = 5

local TIPSCOUNT = 3 --成就达到这个值领取时提示
local ONE_REWARD = 1 --一次 
local ALL_REWARD = 2 -- 一键

local g_epic_challenge = 5

local OutCastState = {
	STATE_FORBID = 1, 
	STATE_LOCK = 2, 
	STATE_UNLOCK = 3, 
	STATE_COMPLETE = 4, -- 副本通关（没有领取奖励）
	STATE_FINISHED = 5, -- 副本完成（已经领取奖励）
}

local function finishOneMapCopy(mapID)
	local finishCount = g_i3k_game_context:getDungeonDayEnterTimes(mapID)
	return finishCount > 0
end

local function getMapOpenType(mapID)
	local cfgs = i3k_db_new_dungeon
	if not cfgs[mapID] then
		return -1
	end

	return cfgs[mapID].openType
end

local function finishOneTypeMapCopy(openType)
	local mapLogs = g_i3k_game_context:GetDungeonData()

	local times = 0
	local ltype = 0

	for mapID, log in pairs(mapLogs) do
		ltype = getMapOpenType(mapID)
		if ltype == openType and log.finishCount then
			times = times + log.finishCount
		end
	end

	return times
end

local function openDetailMapCopy(mapID, teamMap)
	g_i3k_logic:OpenDungeonUI(teamMap, mapID)
end

local gotochTask = 
{
	[1] = function(cfg)				--等级(打开背包？)
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")--江湖百事通
	end ,

	[2] = function(cfg)				--战力(打开背包？)
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end , 

	[3] = function(cfg)				--装备X件紫装（历史穿戴）
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end , 

	[4] = function(cfg)				--装备X件橙装（历史穿戴）
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end , 

	[5] = function(cfg)				--通关xx剧情副本
		openDetailMapCopy(cfg.param1)
		return eUIID_FBLB
	end , 

	[6] = function(cfg)				--通关xx普通副本
		
		openDetailMapCopy(cfg.param1)
		return eUIID_FBLB
	end , 

	[7] = function(cfg)				--通关xx困难副本
		openDetailMapCopy(cfg.param1)
		return eUIID_FBLB
	end ,

	[8] = function(cfg)				--通关xx组队副本
		openDetailMapCopy(cfg.param1, true)
		return eUIID_FBLB
	end ,

	[9] = function(cfg)				--通关任意单人副本
		openDetailMapCopy()
		return eUIID_FBLB
	end ,

	[10] = function(cfg)			--通关任意组队副本
		openDetailMapCopy(nil, true)
		return eUIID_FBLB
	end ,

	[11] = function(cfg)			--连续X天个人竞技场进入前100（待定）
		g_i3k_logic:OpenArenaUI()
		return eUIID_ArenaList
	end ,

	[12] = function(cfg)			--连续X天4vs4竞技场进入前100（待定）
		g_i3k_logic:OpenArenaUI()
		return eUIID_ArenaList
	end,

	[13] = function(cfg)			--历史消耗X绑定铜钱
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,

	[14] = function(cfg)			--历史消耗X绑定元宝
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,

	[15] = function(cfg)			--历史消耗X铜钱
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,

	[16] = function(cfg)			--历史消耗X元宝
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,

	[17] = function(cfg)			--获得X件神兵
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,

	[18] = function(cfg)			--X件神兵达到Y级
		g_i3k_logic:OpenShenBingUI()
		return eUIID_ShenBing
	end ,

	[19] = function(cfg)			--X件神兵达到满星
		g_i3k_logic:OpenShenBingUI()
		return eUIID_ShenBing
	end ,

	[20] = function(cfg)			--获得X个随从
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,

	[21] = function(cfg)			--X个随从达到Y级
		g_i3k_logic:OpenPetUI()
		return eUIID_SuiCong
	end ,

	[22] = function(cfg)			--X个随从达到满星
		g_i3k_logic:OpenPetUI()
		return eUIID_SuiCong
	end ,

	[27] = function(cfg)			--加入帮派界面
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,
	-------------------------------------------------------
	[28] = function(cfg)			--进入装备强化界面
		if g_i3k_game_context:isCanOpenEquipStreng() then
			g_i3k_logic:OpenStrengEquipUI()
			return eUIID_StrengEquip
		end
	end ,
	[29] = function(cfg)			--进入装备升星界面
		if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.starUpLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(126, i3k_db_common.functionOpen.starUpLvl))
			return
		end
		g_i3k_logic:OpenEquipStarUpUI()
		return eUIID_EquipUpStar
	end ,
	[30] = function(cfg)			--进入武功界面
		g_i3k_logic:OpenSkillLyUI()
		return eUIID_SkillLy
	end ,
	[31] = function(cfg)			--进入绝技界面
		local need_lvl = i3k_db_common.functionHide.HideUniqueSkillLabel
		local open_lvl = i3k_db_common.functionOpen.uniqueSkillOpenLvl
		local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills() 

		if g_i3k_game_context:GetLevel() >= need_lvl and g_i3k_game_context:GetLevel() < open_lvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(495))
		elseif g_i3k_game_context:GetLevel() >= open_lvl then
			if next(role_unique_skill) ~= nil then
				--g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
				g_i3k_ui_mgr:OpenUI(eUIID_SkillLy)--red_point_3红点
				g_i3k_ui_mgr:RefreshUI(eUIID_SkillLy, true)
				return eUIID_SkillLy
			else
				---当没有任何绝技时

				local desc = i3k_get_string(496,i3k_db_climbing_tower_args.openLvl)
				local callfunc = function (isOk)
					if isOk then
						---跳转到活动---爬塔标签
						local fun = (function(id)
							local callBack = function()
								g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
								g_i3k_ui_mgr:CloseUI(eUIID_DailyTask)
							end
							i3k_sbean.sync_fame_tower(id, nil, callBack)
						end)
						g_i3k_logic:OpenTowerUI(nil, fun)					
					end
				end
				g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
			end
		end
	end ,
	[32] = function(cfg)			--江湖百事通之%s
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,
	[33] = function(cfg)			--进入武功界面
		g_i3k_logic:OpenSkillLyUI()
		return eUIID_SkillLy
	end ,
	[34] = function(cfg)			--进入装备界面
		if g_i3k_game_context:GetLevel() < i3k_db_common.functionOpen.strengLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(127, i3k_db_common.functionOpen.strengLvl))
			return
		end
		g_i3k_logic:OpenStrengEquipUI()
		return eUIID_StrengEquip
	end ,
	[35] = function(cfg)			--江湖百事通之
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
		return eUIID_SkillLy
	end ,
	[36] = function(cfg)			--进入坐骑界面
		g_i3k_logic:OpenSteedUI()
		return eUIID_SkillLy
	end ,
	[37] = function(cfg)			--进入会武界面
		--参与会武副本
		g_i3k_logic:OpenTournamentUI()
		return eUIID_SkillLy
	end ,
	[38] = function(cfg)			--进入势力战界面
		g_i3k_logic:OpenForceWarUI()
		return eUIID_SkillLy
	end ,
	
	[39] = function(cfg)			--进入五绝试炼界面
		--参与五绝试炼
		g_i3k_logic:OpenFiveUniqueUI()
		return eUIID_SkillLy
	end ,
	[40] = function(cfg)			--进入正邪界面
		g_i3k_logic:OpenTaoistUI()
		return eUIID_SkillLy
	end ,
	[41] = function(cfg)			--江湖百事通之
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,
	[42] = function(cfg)			--江湖百事通之
		g_i3k_ui_mgr:PopupTipMessage("官方资料库建设中")
	end ,
	[43] = function(cfg)			--进入生产界面
		g_i3k_logic:OpenFactionProduction()
		return eUIID_SkillLy
	end ,
	[44] = function(cfg)			--进入售卖界面
		g_i3k_logic:OpenAuctionUI()
		return eUIID_SkillLy
	end ,
	[45] = function(cfg)			--进入内甲界面
		g_i3k_logic:enterUnderWearUI()
		return eUIID_SkillLy
	end ,
	[46] = function(cfg)			--进入内甲界面
		g_i3k_logic:enterUnderWearUI()
		return eUIID_SkillLy
	end ,
	[47] = function(cfg)			--神兵器灵总等级达到X
		g_i3k_logic:OpenShenBingUI()
		return eUIID_ShenBing
	end ,
	[48] = function(cfg)			--跳转月卡
		g_i3k_logic:OpenPayActivityUI(2)
		return eUIID_ShenBing
	end ,
	[49] = function(cfg)			--跳转逍遥卡
		if g_i3k_game_context:getRoleSpecialCards(MONTH_CARD).cardEndTime > 0 then  --历史充值过月卡
			g_i3k_logic:OpenPayActivityUI(3)
			return eUIID_PayActivity
		else
			local desc = string.format("拥有月卡才能购买逍遥卡")
			local fun = (function(ok)
				if ok then
					g_i3k_logic:OpenPayActivityUI(2)
					g_i3k_ui_mgr:CloseUI(eUIID_DailyTask)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
		end
	end ,
	[50] = function(cfg)			--跳转星耀
		g_i3k_logic:OpenStarDish()
		return eUIID_StarDish
	end ,
	[51] = function(cfg)			--跳转经脉
		g_i3k_logic:OpenMeridian(eUIID_DailyTask)
		return eUIID_Meridian
	end ,
	[52] = function(cfg)			--跳转经脉
		g_i3k_logic:OpenMeridian(eUIID_DailyTask)
		return eUIID_Meridian
	end ,
	[53] = function(cfg)			--跳转八卦
		return g_i3k_logic:OpenBagua()
	end ,
	[54] = function(cfg)			--跳转八卦
		return g_i3k_logic:OpenBagua()
	end ,
	[55] = function(cfg)			--跳转武魂
		return g_i3k_logic:OpenMartialSoulUI()
		--return eUIID_MartialSoul
	end ,
	[56] = function(cfg)			--跳转武魂
		return g_i3k_logic:OpenMartialSoulUI()
		--return 
	end ,
	[57] = function(cfg)			--跳转坐骑皮肤
		if g_i3k_game_context:getUseSteed() ~= 0 then
			g_i3k_logic:OpenSteedSkinUI()
			return eUIID_SteedSkin
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
		end
	end ,
	[58] = function(cfg)			--跳转坐骑
		return g_i3k_logic:OpenSteedFight(STEED_MASTER_STATE)
	end ,
	[59] = function(cfg)			--跳转坐骑
		return g_i3k_logic:OpenSteedFight(STEED_SPIRIT_STATE)
	end ,
	[60] = function(cfg)			--跳转坐骑
		return g_i3k_logic:OpenSteedFight(STEED_SPIRIT_STATE)
	end ,
	[61] = function(cfg)			--跳转星魂
		return g_i3k_logic:OpenStarSoul()
	end ,
	[63] = function(cfg)			--跳转暗器
		g_i3k_logic:OpenHideWeaponUI()
		return eUIID_HideWeapon
	end ,
	[64] = function(cfg)			--跳转暗器
		g_i3k_logic:OpenHideWeaponUI()
		return eUIID_HideWeapon
	end ,
	[65] = function(cfg)			--跳转骑战套装
		g_i3k_logic:OpenSteedSuitUI()
		return eUIID_SteedSuit
	end ,
	[66] = function(cfg)			--跳转骑战熔炉
		g_i3k_logic:OpenSteedStoveUI()
		return eUIID_SteedStove
	end ,
	[67] = function(cfg)	
		g_i3k_logic:OpenTournamentUI()
		return eUIID_SkillLy
	end,
	[68] = function(cfg)			--五绝试炼
		g_i3k_logic:OpenFiveUniqueUI()
		return eUIID_Activity
	end,
	[69] = function(cfg)			--寻路到怪物
		local callBack = function ()
			g_i3k_game_context:SetAutoFight(true)
		end
		g_i3k_game_context:GotoMonsterPos(cfg.param1, callBack)
		--tbl.transport = {flage = 3, mapId = tbl.mapId, areaId = cfg.arg1}
		return true
	end,
	[75] = function(cfg, index) --提交道具
		g_i3k_logic:OpenChallengeSubmitItems(cfg.groupId, index)
		return false--不让ui关闭
	end,
}

local showTaskFunc =
{
	[1] = function(group)
		return g_i3k_game_context:GetLevel() >= group.conditionArg1
	end,
	[2] = function(group)
		local titles = g_i3k_game_context:GetAllRoleTitle()
		if titles then
			return table.nums(titles) >= group.conditionArg1
		end
	end,
	[3] = function(group)
		return group.conditionArg1 >= g_i3k_game_context:GetLevel()
	end,
	[4] = function(group)
		return g_i3k_game_context:GetPetCount() >= group.conditionArg1
	end,
	[5] = function(group)
		local horses = g_i3k_game_context:getAllSteedInfo()
		if horses then
			return table.nums(horses) >= group.conditionArg1
		end
	end,
	[6] = function(group)
		local weapons = g_i3k_game_context:GetShenbingData()
		return table.nums(weapons) >= group.conditionArg1
	end,
}

function wnd_dailyTask:ctor()
	self._state = 1
	self.showTasks = {}
	self.reward_bg = {}
	self.reward_btn = {}
	self.reward_icon = {}
	self.reward_count = {}

	self.condition = {}
	self.duihao = {}

	self.refer_bg = {}
	self.refer_icon = {}
	self.refer_btn = {}
	self.refer_count = {}

	self.isCondition = {}

	self.fameLvl = 20
	self.fameLvlNext = 1

	self.reward_max_bg = {}
	self.reward_max_btn = {}
	self.reward_max_icon = {}
	self.reward_max_count = {}


	self.reward_next_bg = {}
	self.reward_next_btn = {}
	self.reward_next_icon = {}
	self.reward_next_count = {}

	self.recordTime = 1
	self.info = {}

	self._record = false

	self.timeCounter = 0
	self.itemState = 1	--记录挑战条目当前分页状态
	--分页显示后任务条目获取相关变量----
	self.isShowIndex= 0 --记录可领取奖励数量
	self.task = {} --领取奖励后下一个任务数据……
	self.taskTab = {}   --每个类型记录最后一条领取记录，切换页签时将任务条目同步
	self.taskIndex = 0	--设置领取奖励分类型记录
	self.taskType  = 0-- 设置领取奖励的类型
	-----------------------------------
	self.curReward = 0
	self.tasks = nil

	--------
	self.advenTaskBtn = nil
	self._outCastInfo = nil
end


local STATE_CHALLENAGE = 1 -- 成就
local STATE_FAME = 2 -- 名声
local STATE_ADV = 3 -- 奇缘
local STATE_CARD_PACK = 4 -- 图鉴

function wnd_dailyTask:configure(...)
	local widgets = self._layout.vars
	self._widgets = widgets
	widgets.challengeBtn:onClick(self, self.challengeCB)
	---------------------------------
	--挑战任务条目修改
	self.achNameIds = {15365, 15366, 15367, 15368, 50200}
	self.taskItem = {}
	for i=1, 5 do  
		local item =  string.format("item%s",i)
		local itemBtn = string.format("itemBtn%s",i)
		local itemPointNum = string.format("itemPointNum%s",i)
		local itemName = string.format("itemName%s",i)
		local itemRed = string.format("itemRed%s",i)
		self.taskItem[i] = {item = widgets[item],itemBtn =widgets[itemBtn], itemPointNum =widgets[itemPointNum],itemName =widgets[itemName],itemRed =widgets[itemRed]}		
	end
	self.totalPointNum = widgets.totalPointNum
	self.des = widgets.des   --评价

	for k,v in ipairs(self.taskItem) do
		v.itemBtn:setTag(k + 1000)
		v.itemBtn:onClick(self,self.onItemClick)
	end
	---------------------------------
	self.fame_btn = widgets.fame_btn
	self.fame_btn:onClick(self,self.onFame)

	self.advtBtn = widgets.advtBtn
	self.advtBtn:hide()
	widgets.advtBtn:onClick(self, self.onUpdateAdventrue)
	self.advtRoot = widgets.advtRoot
	self.advtRoot:hide()
	-- self.outcastBtn = widgets.outcastBtn
	self._tabbar = {
		[STATE_CHALLENAGE] = widgets.challengeBtn, 
		[STATE_FAME] = self.fame_btn, 
		[STATE_ADV] = widgets.advtBtn, 
		[STATE_CARD_PACK] = widgets.outcastBtn,
	}
	self.scroll = self._layout.vars.scroll1
	self.framList = self._layout.vars.framList
	self.rewardlist = self._layout.vars.rewardlist
	self.needitemlist = self._layout.vars.needitemlist
	self.tabName = self._layout.vars.tabName

	self.red_point2 = self._layout.vars.red_point2
	self.red_point3 = widgets.red_point3
	self.chTaskMaxValue = {}

	self.dailyUI = widgets.dailyUI
	
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	self.fame_root = widgets.fame_root
	self.fame_root:hide()
--------------------------------------------
	self.fame_icon_now = widgets.fame_icon_now
	self.fame_icon_next = widgets.fame_icon_next
	self.fame_name_now = widgets.fame_name_now
	self.fame_name_next = widgets.fame_name_next

	self.outCast_root = widgets.outCastRoot
	-- self.outCast_root:hide()
	-- widgets.outcastBtn:onClick(self, self.goToOutCast)
	
	self.receive_btn = widgets.receive_btn
	self.promotion_btn = widgets.promotion_btn

	self.refer_duihao = widgets.refer_duihao

	self.fame_icon_now = widgets.fame_icon_now
	self.fame_icon_next = widgets.fame_icon_next
	self.tiaojian1 = widgets.tiaojian1
	self.tiaojian2 = widgets.tiaojian2
	self.tiaojian3 = widgets.tiaojian3
	self.time_desc = widgets.time_desc
	self.ismax = widgets.ismax
	self.hidetxt = widgets.hidetxt
	for i = 1,3 do
		local reward_bg  = "reward_bg"..i
		local reward_btn = "reward_btn"..i
		local reward_icon = "reward_icon"..i
		local reward_count = "reward_count"..i

		local condition = "condition"..i
		local duihao = "duihao"..i

		local reward_max_bg  = "reward_max_bg"..i
		local reward_max_btn = "reward_max_btn"..i
		local reward_max_icon = "reward_max_icon"..i
		local reward_max_count = "reward_max_count"..i

		local reward_next_bg  = "reward_next_bg"..i
		local reward_next_btn = "reward_next_btn"..i
		local reward_next_icon = "reward_next_icon"..i
		local reward_next_count = "reward_next_count"..i

		table.insert(self.reward_bg,widgets[reward_bg])
		table.insert(self.reward_btn,widgets[reward_btn])
		table.insert(self.reward_icon,widgets[reward_icon])
		table.insert(self.reward_count,widgets[reward_count])

		table.insert(self.condition,widgets[condition])
		table.insert(self.duihao,widgets[duihao])

		table.insert(self.reward_max_bg,widgets[reward_max_bg])
		table.insert(self.reward_max_btn,widgets[reward_max_btn])
		table.insert(self.reward_max_icon,widgets[reward_max_icon])
		table.insert(self.reward_max_count,widgets[reward_max_count])

		table.insert(self.reward_next_bg,widgets[reward_next_bg])
		table.insert(self.reward_next_btn,widgets[reward_next_btn])
		table.insert(self.reward_next_icon,widgets[reward_next_icon])
		table.insert(self.reward_next_count,widgets[reward_next_count])
	end
	for i = 1,3 do
		local refer_bg = "refer_bg"..i
		local refer_icon = "refer_icon"..i
		local refer_btn = "refer_btn"..i
		local refer_count = "refer_count"..i

		table.insert(self.refer_bg,widgets[refer_bg])
		table.insert(self.refer_icon,widgets[refer_icon])
		table.insert(self.refer_btn,widgets[refer_btn])
		table.insert(self.refer_count,widgets[refer_count])
	end
	-------------------max--------------------------
	-- self.receive_max_btn = widgets.receive_max_btn
	-- self.fame_max_name = widgets.fame_max_name
	-- self.fame_max_root = widgets.fame_max_root
	-- self.fame_max_root:hide()
	-- self.fame_max_icon = widgets.fame_max_icon

	widgets.outcastBtn:setVisible(g_i3k_game_context:checkCardPacketOpen())
	widgets.outcastBtn:onClick(self, self.onCardPack)
end

function wnd_dailyTask:onShow()

end

function wnd_dailyTask:refresh(state)
	self._state = state
	if state == 1 then
		self.dailyUI:show()
	end
	self:setTabBtn()
	self:SetFameBtnState()
	if state == STATE_FAME then
		self:onFame()
	elseif state == STATE_ADV then
		self:onUpdateAdventrue()
	end
end

function wnd_dailyTask:setTabBtn()
	for i,v in ipairs(self._tabbar) do
		if i == self._state then
			v:stateToPressed()
		else
			v:stateToNormal()
		end
	end
	self.tabName:setImage(l_tTabName[self._state])
	self:updateRightRedPoint()
end

function wnd_dailyTask:challengeCB(sender)    --挑战按钮
	self._record = false
	self.dailyUI:show()
	self.fame_root:hide()
	self.advtRoot:hide()
	self.outCast_root:hide()
	--self.fame_max_root:hide()
	-------
	self.isShowIndex= 0 
	self.task = {} 
	self.taskTab = {}  
	self.taskIndex = 0
	self.taskType  = 0
	-------
	self._state = 1
	self:setTabBtn()
	i3k_sbean.sync_chtask_info(1)
end

function wnd_dailyTask:onFame(sender)          --名望按钮
	self:clearScorll()
	self.dailyUI:hide()
	self.advtRoot:hide()
	self.outCast_root:hide()
	self._state = 2
	self:setTabBtn()
	self._record = true		
	self:updateFameItems1()
	self:selectFrame(nil, g_i3k_game_context:GetFameLevel())
	self.framList:jumpToChildWithIndex(self.frameIndex)
end

function wnd_dailyTask:SetFameData(info)
	self.fameLvl = info.level or self.frameIndex
	self.recordTime = info.upgradeTime
	self.info = info 
	self.fame_root:show()
	self:selectFrame(nil, info.level,true)
	self:setFrameIndex()
end

function wnd_dailyTask:onPromotion(sender)
	i3k_sbean.fame_promotion(self.fameLvlNext)
end

function wnd_dailyTask:SetTimeDesc()
	if self.curReward == 1 and self.frameIndex == g_i3k_game_context:GetFameLevel() then
		local serverTime = i3k_game_get_time()
		local cd = i3k_db_fame[self.fameLvl+1].nextLvlCD
		local judgeTime = serverTime - self.recordTime
		if (judgeTime > cd and self.info.reawrd == 1) or cd == 0 then
			self.time_desc:hide()
			if self._isCondition == 2 then
				self.promotion_btn:enableWithChildren()
			end
			return true
		else
			self.time_desc:show()
			self.promotion_btn:disableWithChildren()
			local time = cd - judgeTime
			if time <= 60 then
				self.time_desc:setText(string.format("距离下次晋阶还需%d%s",time,"秒"))
			elseif time > 60 and time <= 3600 then
				local t1,t2 = math.modf(time/60)
				self.time_desc:setText(string.format("距离下次晋阶还需%d%s%d%s",t1,"分",math.floor(t2*60),"秒"))
			elseif time > 3600 and time <= 86400 then
				local t1,t2 = math.modf(time/3600)
				self.time_desc:setText(string.format("距离下次晋阶还需%d%s%d%s",t1,"时",math.ceil(t2*60),"分"))
			elseif time > 86400 then
				local t1,t2 = math.modf(time/86400)
				self.time_desc:setText(string.format("距离下次晋阶还需%d%s%d%s",t1,"天",math.ceil(t2*24),"时"))
			end
			return false 
		end	
	else
		self.time_desc:setText("")
	end
end

function wnd_dailyTask:onReceive(sender)
	local isCanReceive = self:isBagEnoughFameReceive(self.fameLvl)
	local cfg = i3k_db_fame[self.fameLvl]
	local all_items = {}
	for i=1,3 do
		local tmp_id = string.format("receiveRevardId%s",i)
		local itemid = cfg[tmp_id]

		local tmp_count = string.format("receiveRevardCount%s",i)
		local count = cfg[tmp_count]
		if itemid ~= 0 and itemid ~= g_BASE_ITEM_DIAMOND and itemid ~= g_BASE_ITEM_COIN then
			all_items[itemid] = count
		end
	end
	local gifts = {}
	local index = 1
	for i,v in pairs (all_items) do
		if i ~= 0 then
			gifts[index] = {id = i,count = v}
			index = index + 1
		end	
	end
	if isCanReceive then
		i3k_sbean.fame_receive(self.fameLvl,gifts)
	else
		g_i3k_ui_mgr:PopupTipMessage("您的背包空间不足,请清理空间后再来领取")
	end
end

function wnd_dailyTask:updateFameItems1()
	self.framList:removeAllChildren()
	if self._record  then
		for i , v in ipairs(i3k_db_fame) do
			local rch = require(mingwangTitle)()
			rch.vars.title:setText(v.name)
			rch.vars.button:onClick(self, self.selectFrame, i)
			self.framList:addItem(rch)
		end
	end
end

function wnd_dailyTask:selectFrame( sender,index,needreq )
	self.frameIndex = index
	if not needreq then
		i3k_sbean.fame_sync_data(self.frameIndex)
	end
	if self.framList then
		local widgets = self.framList:getAllChildren()
		for i,item in ipairs(widgets) do
			if i == index then
				item.vars.button:stateToPressed()
				item.vars.title:setTextColor("ff2b7751")
			else
				item.vars.button:stateToNormal()
				item.vars.title:setTextColor("ffc14326")
			end
		end
	end
end

function wnd_dailyTask:setFrameIndex( )
	local index = self.frameIndex or 0
	self.rewardlist:removeAllChildren()
	self.needitemlist:removeAllChildren()
	local cfg_now = i3k_db_fame[index]
	if not cfg_now then
		return
	end
	--------当前奖励--------------------------------------------
	for i=1,3 do
		local itemId = cfg_now["receiveRevardId"..i]
		local itemCount = cfg_now["receiveRevardCount"..i]
		if itemId ~= 0 then
			local rch = require(mingwangGetReward)()
			rch.vars.reward_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			rch.vars.reward_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
			rch.vars.reward_btn1:onClick(self, self.itemTips, itemId)
			rch.vars.reward_count1:setText("×"..itemCount)
			self.rewardlist:addItem(rch)
		end
	end
	self.fame_icon_now:setImage(g_i3k_db.i3k_db_get_icon_path(cfg_now.iconId))
	if index == #i3k_db_fame then
		self.ismax:show()
		self.hidetxt:hide()
		self.tiaojian1:hide()
		self.tiaojian2:hide()
		self.tiaojian3:hide()
		self.receive_btn:show()
		self.promotion_btn:hide()
		self.time_desc:hide()
		if g_i3k_game_context:GetFameLevel() == index then
			if self.info.reawrd == 1 then
				self.receive_btn:hide()
				self.red_point3:hide()
				g_i3k_game_context:ClearDailyTaskNotice(g_NOTICE_TYPE_CAN_FAME)
			elseif self.info.reawrd == 0 then
				self.receive_btn:enableWithChildren()
				self.receive_btn:onClick(self,self.onReceive)
			end
		else
			self.receive_btn:disableWithChildren()
		end
	else
		self.fameLvlNext = self.fameLvl + 1
		self.ismax:hide()
		self.hidetxt:show()
		self.tiaojian1:show()
		self.tiaojian2:show()
		self.tiaojian3:show()
		self._receiveNotice = false
		local cfg_next = i3k_db_fame[index+1]
		if g_i3k_game_context:GetFameLevel() == index then
			if self.info.reawrd == 1 then
				self.receive_btn:disableWithChildren()
				self._receiveNotice = false
				self:SetTimeDesc()
				self.receive_btn:hide()
				self.promotion_btn:show()
				self.promotion_btn:enableWithChildren()
				self.promotion_btn:onClick(self,self.onPromotion)
			elseif self.info.reawrd == 0 then
				self.receive_btn:enableWithChildren()
				self.receive_btn:onClick(self,self.onReceive)
				self._receiveNotice = true
				self.receive_btn:show()
				self.promotion_btn:hide()
				self.time_desc:show()
				self.time_desc:setText("每日5:00重置")
			end
			self.curReward = self.info.reawrd
		else
			self.receive_btn:hide()
			self.promotion_btn:hide()
			self.time_desc:hide()
		end

		--------提交道具-------------------------
		for i=1,3 do
			local itemId = cfg_next["promotionUseId"..i]
			local item_count = cfg_next["promotionUseCount"..i]
			if itemId ~= 0 then
				local rch = require(mingwangNeedItem)()
				rch.vars.refer_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
				rch.vars.refer_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
				rch.vars.refer_btn1:onClick(self, self.itemTips, itemId)
				if itemId == 2 then
					rch.vars.refer_count1:setText(item_count)
				else
					rch.vars.refer_count1:setText(g_i3k_game_context:GetCommonItemCanUseCount(itemId).."/"..item_count)
				end
				rch.vars.refer_count1:setTextColor(g_i3k_get_cond_color(item_count <= g_i3k_game_context:GetCommonItemCanUseCount(itemId)))
				self.needitemlist:addItem(rch)
			end
		end
		if self.info.nextLevelCond then
			for i,v in ipairs(self.info.nextLevelCond) do
				local target1={}
				target1[i] = cfg_next["promotionTarget"..i]
				if v == 0 then
					self.isCondition[i] = false
				elseif v >= target1[i] then
					self.isCondition[i] = true
				elseif v == -1 then
					self.isCondition[i] = true
				else
					self.isCondition[i] = false
				end
			end
		end

		for k,v in ipairs(self.isCondition) do
			if v == false then
				self.duihao[k]:setImage(g_i3k_db.i3k_db_get_icon_path(2804))
			else
				self.duihao[k]:setImage(g_i3k_db.i3k_db_get_icon_path(2803))
			end
		end

		---------判断进阶提交道具------------------
		for i=1,3 do
			local itemId = cfg_next["promotionUseId"..i]
			local item_count = cfg_next["promotionUseCount"..i]
			if itemId ~= 0 then
				if item_count > g_i3k_game_context:GetCommonItemCanUseCount(itemId) then
					--self.refer_duihao:setImage(g_i3k_db.i3k_db_get_icon_path(2804))
					self.isCondition1 = false 
					break
				else
					--self.refer_duihao:setImage(g_i3k_db.i3k_db_get_icon_path(2803))
					self.isCondition1 = true 
				end
			end
		end
		-----------设置进阶条件------------------------------
		local _type = {}
		for i=1,3 do
			_type[i] = cfg_next["promotionType"..i]
			if _type[i] ~= 0 then
				local condition = i3k_db_fame_typeDesc[_type[i]].typeName
				local target = cfg_next["promotionTarget"..i]
				if g_i3k_game_context:GetFameLevel() == index or (g_i3k_game_context:GetFameLevel() + 1) == index then
					if not self.isCondition[i] and self.info.nextLevelCond and target ~= 0 then
						target = "(".. self.info.nextLevelCond[i].."/"..target..")"
					end
				end
				self.condition[i]:setText(string.format(condition,target))
				self.condition[i]:show()
				self.duihao[i]:show()
			else
				self.condition[i]:hide()
				self.duihao[i]:hide()
				self["tiaojian"..i]:hide()
			end
		end
		----------根据双条件设置红点------------------------------------
		for k,v in ipairs(self.isCondition) do
			if v == 0 and _type[k] ~= 0 or not v then
				self.isCondition2 = false
				break
			else
				self.isCondition2 = true
			end
		end
		if self.isCondition1 and self.isCondition2 then
			self.promotion_btn:enableWithChildren()
			self._isCondition = 2
		else
			self.promotion_btn:disableWithChildren()
			self._isCondition = 1
		end		
	end
	
end

function wnd_dailyTask:itemTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_dailyTask:isBagEnoughFameReceive(lvl)
	local cfg = i3k_db_fame[lvl]
	local all_items = {}
	for i=1,3 do
		local tmp_id = string.format("receiveRevardId%s",i)
		local itemid = cfg[tmp_id]

		local tmp_count = string.format("receiveRevardCount%s",i)
		local count = cfg[tmp_count]
		if itemid ~= 0 and itemid ~= g_BASE_ITEM_DIAMOND and itemid ~= g_BASE_ITEM_COIN then
			all_items[itemid] = count
		end
	end
	return g_i3k_game_context:IsBagEnough(all_items)
end

--立即前往
function wnd_dailyTask:gotoTask(sender, taskId)
	if gotoDailyTask[taskId] then
		gotoDailyTask[taskId]()
	end
end

function wnd_dailyTask:takeReward(sender, args)
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
			isEnoughTable = {[1000] = expText, [task.itemId1] = task.itemCount1, [task.itemId2] = task.itemCount2, [task.itemId3] = task.itemCount3}
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

function wnd_dailyTask:takeRewardUpdate(index)
	self:clearScorll()
	i3k_sbean.sync_dtask_info(1)
end

--function 挑战任务() end
--------------------challengeTask----------------------

function wnd_dailyTask:onItemClick(sender)
	local tag = sender:getTag() - 1000
	if tag == self.itemState then 
		return
	else
		if self.task then
		self.itemState = tag
		self:updateChallengeData()
		self:updateChallengeRed()
		end
	end 
end

function wnd_dailyTask:reloadChallengeTask(tasks, maxValue)
	if self._state ~= 1 then
		return
	end
	self._layout.vars.challengeTipBg:hide()
	self.taskTab = {}
	self.tasks = tasks
	self.chTaskMaxValue = maxValue or {}
	self:updateChallengeData()
	self:updateChallengeRed()
end

function wnd_dailyTask:updateChallengeRed()
	for k = 1, challengeTypeCount do
		self._layout.vars["itemRed"..k]:hide()
	end
	local isShowRed = false
	for k, v in pairs(self.tasks) do
		local groupCfg = i3k_db_challengeTask[k]
		if v.reward < #groupCfg then
			local index = v.reward + 1
			if showTaskFunc[groupCfg[index].showCondition](groupCfg[index]) and v.seq > v.reward then
				self._layout.vars["itemRed"..groupCfg[index].achievementType]:show()
				isShowRed = true
			end
		end
	end
	if isShowRed then
		self.red_point2:setVisible(true)
	else
		self.red_point2:setVisible(false)
		g_i3k_game_context:ClearDailyTaskNotice(G_NOTICE_TYPE_CAN_REWARD_CHALLENGE_TASK)
	end
end

function wnd_dailyTask:updateChallengeData()
	self:clearScorll()
	for k, v in ipairs(self.taskItem) do
		if k ~= self.itemState then 
			v.itemBtn:stateToNormal()
		else
			v.itemBtn:stateToPressed()
		end 
	end
	if self.itemState == epicChallengeType then
		self._layout.vars.scrollBg1:hide()
		self._layout.vars.scrollBg2:show()
		self:updateFinishedChallengeTasks()
	else
		self._layout.vars.scrollBg1:show()
		self._layout.vars.scrollBg2:hide()
	end
	self:updateChallengeList()
	self:setAchPoint() --设置成就点数显示
end

function wnd_dailyTask:updateChallengeList()
	local showTasks = self:setChallengeTaskSort()
	local index = 1
	for i,v in ipairs(showTasks) do
		local group = i3k_db_challengeTask[v.groupId]
		local cfg = group[v.index]
		if cfg then
			if self.itemState == epicChallengeType then
				local rch = require(l_pItem2)()
				self:setItem(cfg, v, rch, index)
				self._layout.vars.scroll2:addItem(rch)
			else
				local rch = require(l_pItem)()
				self:setItem(cfg, v, rch, index)
				self.scroll:addItem(rch)
			end
			index = index + 1
		end
	end
end

function wnd_dailyTask:setChallengeTaskSort()
	local showTasks = {}
	for groupId, group in pairs(i3k_db_challengeTask) do
		if self.tasks[groupId].reward < #group then
			local index = self.tasks[groupId].reward + 1
			if group[index].achievementType == self.itemState and showTaskFunc[group[index].showCondition](group[index]) then
				local task = {groupId = groupId, index = index, weight = group[index].weight, canreward = 0}
				if self.tasks[groupId].seq > self.tasks[groupId].reward then
					task.canreward = 1
				end
				table.insert(showTasks, task)
			end
		end
	end
	table.sort(showTasks, function (p1, p2)
		return p1.canreward * 100 + (100 - p1.weight) + (100 - p1.groupId) > p2.canreward * 100 + (100 - p2.weight) + (100 - p2.groupId)
	end)
	return showTasks
end

function wnd_dailyTask:setAchPoint()
	--成就点展示start
	local vars = self._layout.vars
	local achPoints = g_i3k_game_context:getTaskAchPiont()
	local itemMaxDes = string.format("item%sMaxDes",self.itemState)
	vars.achName:setText(i3k_get_string(self.achNameIds[self.itemState]) )
	vars.achPoint:setText(achPoints[self.itemState])
	local totalNum = 0
	for i = 1, challengeTypeCount do
		self.taskItem[i].itemPointNum:setText(0)
	end
	for i,v in ipairs(achPoints) do
		self.taskItem[i].itemPointNum :setText(v)
		totalNum = totalNum + v
	end
	self.totalPointNum:setText(totalNum)
	for k,v in pairs(i3k_db_evaluation) do
		if achPoints[self.itemState] < v.achievementPoint then
			self.des:setText(v[itemMaxDes])
			break
		end
	end
end

--获取可以领取的条目
function wnd_dailyTask:CanRewardTask()
	local count = 0
	local rewardTable = {}
	local infoTable = {items = {}}
	for i,v in pairs(self.tasks) do
		if v.seq > v.reward then
			count = count + v.seq - v.reward
			rewardTable[v.type] = v.seq
			local info = i3k_db_challengeTask[v.type]
			local start = v.reward + 1
			for  k = start, v.seq do
				for q, e in ipairs (info[k].rewards) do
					if e.itemID ~= 0 then
						if infoTable.items[e.itemID] then
							infoTable.items[e.itemID].count = infoTable.items[e.itemID].count + e.itemCount
						else
							infoTable.items[e.itemID] = {
								id = e.itemID,
								count = e.itemCount
							}
						end
					end
				end
				local genderReward = g_i3k_game_context:IsFemaleRole() and info[k].femaleReward or info[k].maleReward
				if genderReward.id ~= 0 then
					if infoTable.items[genderReward.id] then
						infoTable.items[genderReward.id].count = infoTable.items[genderReward.id].count + genderReward.count
					else
						infoTable.items[genderReward.id] = {
							id = genderReward.id,
							count = genderReward.count
						}
					end
				end
				local justiceReward
				if g_i3k_game_context:GetTransformBWtype() == 1 then
					justiceReward = info[k].justiceReward
				elseif g_i3k_game_context:GetTransformBWtype() == 2 then
					justiceReward = info[k].evilReward
				end
				if justiceReward and justiceReward.id ~= 0 then
					if infoTable.items[justiceReward.id] then
						infoTable.items[justiceReward.id].count = infoTable.items[justiceReward.id].count + justiceReward.count
					else
						infoTable.items[justiceReward.id] = {
							id = justiceReward.id,
							count = justiceReward.count
						}
					end
				end
			end
		end
	end
	infoTable.reward = rewardTable
	return infoTable, count
end

function wnd_dailyTask:setItem(cfg, task, rch, index)
	rch.vars.taskIcon:setImage(i3k_db_icons[cfg.iconId].path)
	rch.vars.taskName:setText(cfg.title)
	rch.vars.achPoint:show()
	rch.vars.achPoint:setText("成就点数:"..cfg.achievementPoint)
	self:setChallengeRewards(cfg, rch)
	if task.canreward == 1 then
		rch.vars.condition:setText(cfg.desc)
		self.red_point2:show()
		rch.vars.noFinish:hide()
		rch.vars.complete:show()
		rch.vars.take:show()
		rch.vars.btn:hide()
		rch.vars.take:onClick(self, self.takeChTaskReward, {task = task, index = index})
	else
		if l_tNotShowCount[cfg.achieveCondition] then
			rch.vars.condition:setText(cfg.desc)
		else
			local finishTime = 0
			if cfg.achieveCondition == 69 then
				finishTime = (self.tasks[task.groupId] and self.tasks[task.groupId].logCnt and self.tasks[task.groupId].logCnt.cnt) or 0
			elseif cfg.achieveCondition == 72 then
				finishTime = g_i3k_game_context:getAllSteedPower()
			elseif cfg.achieveCondition == 73 then
				finishTime = g_i3k_game_context:getWeaponPower()
			elseif cfg.achieveCondition == 74 then
				finishTime = g_i3k_game_context:getAllPetPower()
			else
				finishTime = self.chTaskMaxValue[cfg.achieveCondition] or 0
			end
			rch.vars.condition:setText(cfg.desc.."(".. finishTime .."/".. cfg.target ..")")
		end
		rch.vars.noFinish:show()
		rch.vars.complete:hide()
		rch.vars.take:hide()
		rch.vars.btn:show()
		rch.vars.notCanJump:hide()
		if cfg.canJump == 1 then
			rch.vars.btn:show()
			rch.vars.notCanJump:hide()
		else
			rch.vars.btn:hide()
			rch.vars.notCanJump:show()
		end
		rch.vars.btn:onClick(self, self.gotoChallengeTask, task)
	end
end

function wnd_dailyTask:setChallengeRewards(taskCfg, node)
	local rewards = {}
	for k, v in ipairs(taskCfg.rewards) do
		if v.itemID ~= 0 then
			table.insert(rewards, {id = v.itemID, count = v.itemCount})
		end
	end
	--性别奖励
	if g_i3k_game_context:IsFemaleRole() then
		if taskCfg.femaleReward.id ~= 0 then
			table.insert(rewards, {id = taskCfg.femaleReward.id, count = taskCfg.femaleReward.count})
		end
	else
		if taskCfg.maleReward.id ~= 0 then
			table.insert(rewards, {id = taskCfg.maleReward.id, count = taskCfg.maleReward.count})
		end
	end
	if g_i3k_game_context:GetTransformBWtype() == 1 then
		if taskCfg.justiceReward.id ~= 0 then
			table.insert(rewards, {id = taskCfg.justiceReward.id, count = taskCfg.justiceReward.count})
		end
	elseif g_i3k_game_context:GetTransformBWtype() == 2 then
		if taskCfg.evilReward.id ~= 0 then
			table.insert(rewards, {id = taskCfg.evilReward.id, count = taskCfg.evilReward.count})
		end
	end
	for i = 1, 4 do
		if rewards[i] then
			node.vars["image"..i]:show()
			node.vars["image"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(rewards[i].id))
			node.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(rewards[i].id, g_i3k_game_context:IsFemaleRole()))
			node.vars["lock"..i]:setVisible(g_i3k_common_item_has_binding_icon(rewards[i].id))
			node.vars["count"..i]:setText("x"..rewards[i].count)
			node.vars["tips"..i]:onClick(self, self.onShowItemInfo, rewards[i].id)
		else
			node.vars["image"..i]:hide()
		end
	end
end

function wnd_dailyTask:onShowItemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_dailyTask:takeChTaskReward(sender, args)
	local items, count = self:CanRewardTask()
	local state = g_i3k_game_context:getShowAchievementRewardTips()
	if count > TIPSCOUNT and not state then
		g_i3k_ui_mgr:OpenUI(eUIID_ReceiveAchievementReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_ReceiveAchievementReward, function(args) self:onceTakeChTaskReward(args) end, function(items)self:onekeyTakeChTaskReward(items) end, args, items)
		return
	end
	if state and state == ALL_REWARD then -- 2 一键领取
		self:onekeyTakeChTaskReward(items)
	else
		self:onceTakeChTaskReward(args)
	end
	
end

--单次领取
function wnd_dailyTask:onceTakeChTaskReward(args)
	local cfg = i3k_db_challengeTask[args.task.groupId][args.task.index]
	local isEnoughTable = {}
	local gifts = {}
	for i, v in ipairs(cfg.rewards) do
		if v.itemID ~= 0 then
			isEnoughTable[v.itemID] = v.itemCount
			table.insert(gifts, {id = v.itemID, count = v.itemCount})
		end
	end
	if g_i3k_game_context:IsFemaleRole() then
		if cfg.femaleReward.id ~= 0 then
			isEnoughTable[cfg.femaleReward.id] = cfg.femaleReward.count
			table.insert(gifts, {id = cfg.femaleReward.id, count = cfg.femaleReward.count})
		end
	else
		if cfg.maleReward.id ~= 0 then
			isEnoughTable[cfg.maleReward.id] = cfg.maleReward.count
			table.insert(gifts, {id = cfg.maleReward.id, count = cfg.maleReward.count})
		end
	end
	if g_i3k_game_context:GetTransformBWtype() == 1 then
		if cfg.justiceReward.id ~= 0 then
			isEnoughTable[cfg.justiceReward.id] = cfg.justiceReward.count
			table.insert(gifts, {id = cfg.justiceReward.id, count = cfg.justiceReward.count})
		end
	elseif g_i3k_game_context:GetTransformBWtype() == 2 then
		if cfg.evilReward.id ~= 0 then
			isEnoughTable[cfg.evilReward.id] = cfg.evilReward.count
			table.insert(gifts, {id = cfg.evilReward.id, count = cfg.evilReward.count})
		end
	end
	local isenough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isenough then
		i3k_sbean.take_chtask_reward(args.task.groupId, args.task.index, args.index, gifts, cfg.achievementType, cfg.achievementPoint)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end

--一键领取
function wnd_dailyTask:onekeyTakeChTaskReward(tableInfo)
	local items = {}
	for k, v in pairs(tableInfo.items) do
		if items[v.id] then
			items[v.id] = v.count + items[v.id]
		else
			items[v.id] = v.count
		end
	end
	local isenough = g_i3k_game_context:IsBagEnough(items)
	if isenough then
		i3k_sbean.chtask_batchtake(tableInfo.reward, tableInfo.items)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end


function wnd_dailyTask:takeChTaskRewardHandle(groupId, seq, index)
	self._layout.vars.challengeTipBg:hide()
	self.tasks[groupId].reward = self.tasks[groupId].reward + 1
	local group = i3k_db_challengeTask[groupId]
	if seq + 1 > #group then
		i3k_sbean.sync_chtask_info()
	else
		local rch
		if self.itemState == 5 then
			rch = self._layout.vars.scroll2:getChildAtIndex(index)
		else
			rch = self.scroll:getChildAtIndex(index)
		end
		if rch then
			local newCfg = group[seq + 1]
			if newCfg then
				if self.tasks[groupId].seq > self.tasks[groupId].reward then
					local taskCfg = {groupId = groupId, index = seq + 1, weight = newCfg.weight, canreward = 1}
					self:setItem(newCfg, taskCfg, rch, index)
					self:updateChallengeRed()
				else
					i3k_sbean.sync_chtask_info()
				end
			end
		end
	end
end

function wnd_dailyTask:gotoChallengeTask(sender, args)
	local cfg = g_i3k_db.i3k_db_get_chanllenge_task_cfg(args.groupId, args.index)
	if not cfg then
		return
	end
	if gotochTask[cfg.achieveCondition] then
		if gotochTask[cfg.achieveCondition](cfg, args.index) then
			g_i3k_ui_mgr:CloseUI(eUIID_DailyTask)
		end
	end
end

function wnd_dailyTask:updateFinishedChallengeTasks()
	self._layout.vars.finishScroll:removeAllChildren()
	local finishTasks = self:getFinishedChallengeTasks(g_epic_challenge)
	if #finishTasks > 0 then
		self._layout.vars.getEmojiText:hide()
		local children = self._layout.vars.finishScroll:addItemAndChild(l_pItem3, 3, #finishTasks)
		for k, v in ipairs(finishTasks) do
			local node = children[k]
			local cfg = i3k_db_challengeTask[v.type]
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg[#cfg].iconId))
			node.vars.bt:onTouchEvent(self, self.onShowChallengeFinish, v)
		end
	else
		self._layout.vars.getEmojiText:show()
		self._layout.vars.getEmojiText:setText(i3k_get_string(50100))
	end
end

function wnd_dailyTask:getFinishedChallengeTasks(achievementType)
	local finished = {}
	for k, v in pairs(self.tasks) do
		if i3k_db_challengeTask[v.type][1].achievementType == achievementType and v.reward >= #i3k_db_challengeTask[v.type] then
			table.insert(finished, v)
		end
	end
	return finished
end

function wnd_dailyTask:onShowChallengeFinish(sender, eventType, data)
	if eventType == ccui.TouchEventType.began then
		local challengeCfg = i3k_db_challengeTask[data.type]
		self._layout.vars.challengeTipBg:show()
		self._layout.vars.challengeTip:setText(i3k_get_string(50099, challengeCfg[#challengeCfg].title))
	elseif eventType == ccui.TouchEventType.moved then
	else
		self._layout.vars.challengeTipBg:hide()
	end
end

function wnd_dailyTask:clearScorll()
	self.scroll:removeAllChildren()
	self._layout.vars.challengeTipBg:hide()
	self._layout.vars.scroll2:removeAllChildren()
	for k = 1, 5 do
		self.taskItem[k].itemRed:setVisible(false)
	end
	local width = self.scroll:getContainerSize().width
	self.scroll:setContainerSize(width, 0)
end



--右侧红点  
function wnd_dailyTask:updateRightRedPoint()
	self._challengeTask = true
	self._fame = true
	for k,v in pairs (g_i3k_game_context:getDailyTaskRedPoint()) do
		if k == G_NOTICE_TYPE_CAN_REWARD_CHALLENGE_TASK and v then
			self._challengeTask = nil
			self.red_point2:show()
		end
		if k == g_NOTICE_TYPE_CAN_FAME and v then
			self._fame = nil
			self.red_point3:show()
		end
	end
	if self._challengeTask then
		g_i3k_game_context:ClearDailyTaskNotice(G_NOTICE_TYPE_CAN_REWARD_CHALLENGE_TASK)
	end
	if self._fame then
		g_i3k_game_context:ClearDailyTaskNotice(g_NOTICE_TYPE_CAN_FAME)
	end
	local widgets = self._layout.vars
	widgets.red_point5:setVisible(g_i3k_game_context:getCardPacketRed())
end

function wnd_dailyTask:SetFameBtnState()
	local lvl = g_i3k_game_context:GetLevel()
	local requireLvl = i3k_db_fame_condition.openFameLvl[1]
	self.fame_btn:setVisible(lvl >= requireLvl)
	self.advtBtn:setVisible(lvl >= i3k_db_adventure.cfg.openlvl)
	-- self.outcastBtn:setVisible(false)
	-- self.outcastBtn:setVisible(lvl >= i3k_db_out_cast_base.baseCfg.openLvl)
end

function wnd_dailyTask:onUpdate(dTime)
	local isCd = false 
	if self._record and self.frameIndex == g_i3k_game_context:GetFameLevel() then
		if self.fameLvl < #i3k_db_fame then
			isCd = self:SetTimeDesc()
			if self._isCondition == 2 and isCd then
				self.red_point3:show()
			elseif self._receiveNotice then
				self.red_point3:show()
			elseif self._isCondition == 1 then
				self.red_point3:hide()
				g_i3k_game_context:ClearDailyTaskNotice(g_NOTICE_TYPE_CAN_FAME)
			elseif self._isCondition == 2 and not isCd then 
				self.red_point3:hide()
				g_i3k_game_context:ClearDailyTaskNotice(g_NOTICE_TYPE_CAN_FAME)
			end
		elseif self.fameLvl == #i3k_db_fame then
			if self._isCondition == 2 and isCd then
				self.red_point3:show()
			elseif self._receiveNotice then
				self.red_point3:show()
			elseif self._isCondition == 1 then
				self.red_point3:hide()
				g_i3k_game_context:ClearDailyTaskNotice(g_NOTICE_TYPE_CAN_FAME)
			elseif self._isCondition == 2 and not isCd then 
				self.red_point3:hide()
				g_i3k_game_context:ClearDailyTaskNotice(g_NOTICE_TYPE_CAN_FAME)
			end
		end
	end
end

function wnd_dailyTask:onCloseUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Main, "updateNotices")
	g_i3k_ui_mgr:CloseUI(eUIID_DailyTask)
end

-----奇遇
function wnd_dailyTask:getAdventureFinishDesc(taskIDs)
	local str = ""
	local context = g_i3k_game_context:getAdventure()
	local circuit = i3k_db_adventure.circuit
	for _, id in ipairs(taskIDs) do
		if circuit[id].finishDescId ~= "0.0" then
			str = str.. circuit[id].finishDesc
		end
	end
	return str
end

function wnd_dailyTask:setYesOrNo(yesTxt, noTxt)
	local widgets = self._layout.vars
	widgets.yes_desc:setText(yesTxt)
	widgets.no_desc:setText(noTxt)
end

function wnd_dailyTask:updateAdventureFinishRewards(items)
	local scroll = self._layout.vars.rewardScroll
	scroll:removeAllChildren()
	for id,v in pairs(items) do
		scroll:addItem(self:createAdvtTaskItem(id, v))
	end
end

function wnd_dailyTask:createAdvtTaskItem(id, value)
	node = require("ui/widgets/rchqyt3")()
	node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	node.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	node.vars.count:setText(value)
	node.vars.lock:setVisible(id>0)
	node.vars.item_btn:onClick(self, self.onClickItem, id)
	return node
end

function wnd_dailyTask:onClickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_dailyTask:updateAdventureTask(cfg, taskId)
	local widgets = self._layout.vars
	
	self:setYesOrNo("重置任务", "立即前往")
	self:addTaskDesc(widgets.descScroll1, cfg.taskDesc)

	widgets.taskName:setText(cfg.name)
	widgets.no_btn:show():onClick(self, self.goToAdvtTask)
	if cfg.abandonTask > 0  then
		widgets.yes_btn:show():onClick(self, self.abandonAdvtTask, taskId)
	else
		widgets.yes_btn:hide()
	end

	items = g_i3k_game_context:getMainTaskAward(cfg)
	widgets.taskReward:removeAllChildren()
	for id,v in pairs(items) do
		widgets.taskReward:addItem(self:createAdvtTaskItem(id, v))
	end
end

function wnd_dailyTask:updateAdventureState(trigID)
	local widgets = self._layout.vars
	local context = g_i3k_game_context:getAdventure()
	local db = i3k_db_adventure
	
	widgets.npcRoot:show()
	widgets.taskRoot2:hide()
	widgets.taskRoot:hide()
	widgets.rewardsRoot:hide()
	widgets.chooseRoot:hide()
	widgets.finishIcon:hide()
	widgets.noneRoot:hide()
	widgets.descScroll1:removeAllChildren()
	widgets.descScroll2:removeAllChildren()

	local head = db.head[trigID]
	
	ui_set_hero_model(widgets.taskIcon, head.iconId)
	local qiyun = g_i3k_game_context:getQiyun()
	widgets.qiyun1:setText(string.format("气运值：%s", qiyun))
	local d_finished = context.finished[trigID]
	
	if d_finished then
		widgets.taskRoot2:show()
		self:addTaskDesc(widgets.descScroll2, self:getAdventureFinishDesc(d_finished.taskIDs))
		if d_finished.isTake > 0 then
			widgets.finishIcon:show()
		else
			widgets.rewardsRoot:show()
			widgets.getBtn:onClick(self, self.getTotalRewards, trigID)
			self:updateAdventureFinishRewards(d_finished.rewards)
		end
	else
		if context.trigID == trigID then
			local task = context.task
			local taskId = task.id
			local circuit = db.circuit[taskId]
			local g_time = i3k_game_get_time()
			if taskId <= 0 and context.trigEndTime ~= 0 and g_time < context.trigEndTime then
				widgets.chooseRoot:show()
				local time = context.trigEndTime - g_time
				local min = math.modf(time/60)
				widgets.leftTime:show():setText(string.format("剩余时间%d分%d秒", min, time%60))
				widgets.yes_btn:show():onClick(self, self.chooseHeadTask, head.firstTaskId)
				widgets.no_btn:onClick(self, self.chooseHeadTask, 0)
				widgets.taskRoot2:show()
				self:addTaskDesc(widgets.descScroll2, head.startDesc)
				self:setYesOrNo(head.yesTxt, head.noTxt)
			elseif taskId > 0 then
				widgets.chooseRoot:show()
				widgets.leftTime:hide()
				if circuit.isChoose > 0 then
					local choose = db.choose[taskId]
					widgets.yes_btn:show():onClick(self.chooseTask, circuit.nextId[1])
					widgets.no_btn:onClick(self.chooseTask, circuit.nextId[2])
					self:setYesOrNo(choose.yesTxt, choose.noTxt)
					widgets.taskRoot2:show()
					self:addTaskDesc(widgets.descScroll2, choose.desc)
				else
					widgets.taskRoot:show()
					self:updateAdventureTask(db.tasks[taskId], taskId)
				end
			else
				widgets.chooseRoot:show()
				widgets.yes_btn:hide()
				widgets.no_btn:hide()
				widgets.leftTime:hide()
				widgets.npcRoot:hide()
				widgets.noneRoot:show()
				widgets.dsa2:setText(i3k_get_string(17141))
				ui_set_hero_model(widgets.taskIcon2, head.iconId)
				widgets.qiyun2:setText(string.format("气运值：%s", qiyun))
				widgets.dsa:setText(head.desc)
			end
		else
			widgets.chooseRoot:show()
			widgets.yes_btn:hide()
			widgets.no_btn:hide()
			widgets.leftTime:hide()
			widgets.npcRoot:hide()
			widgets.noneRoot:show()
			widgets.dsa2:setText(i3k_get_string(17141))
			ui_set_hero_model(widgets.taskIcon2, head.iconId)
			widgets.qiyun2:setText(string.format("气运值：%s", qiyun))
			widgets.dsa:setText(head.desc)
		end
	end
end

function wnd_dailyTask:addTaskDesc(scroll, showText)
	local node = require("ui/widgets/rchqyt4")()
	node.vars.txt:setText(showText)
	node.vars.txt:setRichTextFormatedEventListener(function(sender)
		local nheight = node.vars.txt:getInnerSize().height
		local tSizeH = node.vars.txt:getSize().height

		if nheight > tSizeH then
			local size = node.rootVar:getContentSize()
			node.rootVar:changeSizeInScroll(scroll, size.width, size.height + nheight - tSizeH, true)
	 	end
		node.vars.txt:setRichTextFormatedEventListener(nil)
	end)

	scroll:addItem(node)
end

function wnd_dailyTask:updateAdventureScroll(trigID)
	local scroll = self._layout.vars.taskScroll
	local context = g_i3k_game_context:getAdventure()
	scroll:removeAllChildren()
	for id, v in ipairs(i3k_db_adventure.head) do
		node = require("ui/widgets/rchqyt1")()
		scroll:addItem(node)
		node.vars.name:setText(v.name)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.bgIcon))
		if context.finished[id] then
			node.vars.redPoint:show()
			node.vars.redPoint:setImage(i3k_db_icons[5935].path)
		elseif context.trigID == id and context.task and context.task.id and context.task.state == 1 and context.task.id > 0 then
			node.vars.redPoint:show()
			node.vars.redPoint:setImage(i3k_db_icons[5934].path)
		else
			node.vars.redPoint:hide()
		end
		if trigID == id then
			self.advenTaskBtn = node.vars.btn
			self.advenTaskBtn:stateToPressed()
		end
		node.vars.btn:onClick(self, self.onAdventureItem, id)
	end
end

function wnd_dailyTask:updateOutCastScroll(sender)
		self._outCastInfo = g_i3k_game_context:getOutCastInfo()
		local info = g_i3k_game_context:getOutCastItemsInfo()
		local scroll = self._layout.vars.taskScroll2
		scroll:removeAllChildren()
		local listener = {
			onInitView = self.onInitViewCallBack, -- 初始化页签时
			onSelected = self.onSelectedCallBack, -- 页签被选中时
		}
		self._dropDownList = g_i3k_ui_mgr:createDropDownList(scroll, info, i3k_getDropDownWidgetsMap(g_DROPDOWNLIST_DAILYTASK))
		self._dropDownList:rgListener(self, listener) 
		self._dropDownList:show(g_i3k_game_context:getOutCastFirstShowID()) -- 要放在注册回调之后
--	end 
end 

function wnd_dailyTask:onInitViewCallBack(node, nodeData, view, childIndex)
	if not nodeData then 
		return 
	end 
	local state = self:updateOutCastItemState(nodeData)
	-- local id = nodeData.cfg.id
	local widgets = view.vars
	if state == OutCastState.STATE_FINISHED then -- 已完成
		widgets.finish:show()
	else
		widgets.finish:hide()
		if state == OutCastState.STATE_FORBID or state == OutCastState.STATE_COMPLETE then 
			node:setRedCount(0)
		else
			node:setRedCount(1)
			local parentNode = node:getParent()
			parentNode:setRedCount(1)
			if state == OutCastState.STATE_LOCK then -- 未解锁
			
			elseif state == OutCastState.STATE_UNLOCK then -- 已解锁

			end
		end 
	end 
end 

function wnd_dailyTask:onSelectedCallBack(node, nodeData)
	i3k_sbean.biography_sync_conditions(nodeData)
	self:refreshOutCastCostItems(nodeData)
	self:refreshOutCastAward(nodeData.cfg.awards)
	self:refreshOutCastDesc(nodeData)
end 

function wnd_dailyTask:onOutCastCondition(nodeData, con)
	local allOk = true
	local widgets = self._widgets
	local imgOk, txtCondition, isOk, str
	for index, value in ipairs(nodeData.cfg.unlockCondition) do 
		isOk, str = g_i3k_game_context:getOutCastCondition(value.unlockType, value.unlockNum, con)
		imgOk = widgets["duihao"..(index + 3)]
		txtCondition = widgets["condition"..(index + 3)]
		txtCondition:setText(string.format(str, value.unlockNum))
		if isOk then 
			imgOk:setImage(i3k_db_icons[2803].path)
		else 
			allOk = false
			imgOk:setImage(i3k_db_icons[2804].path)
		end
	end
	nodeData.info.allOk = allOk
end 

function wnd_dailyTask:refreshOutCastCostItems(nodeData)
	local state = nodeData.info.state
	self._widgets.ok_desc3:setText("解锁")
	if state == OutCastState.STATE_FINISHED then -- 已完成
		self._widgets.finishIcon2:show()
		self._widgets.ok_btn3:onClick(self, function() end)
	else
		self._widgets.finishIcon2:hide()
		if state == OutCastState.STATE_FORBID then 
			self._widgets.ok_btn3:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage("请先完成之前的外传")
			end)
		elseif state == OutCastState.STATE_LOCK then -- 未解锁
			self._widgets.ok_btn3:onClick(self, self.showUnlockOutcastTips, nodeData)
		elseif state == OutCastState.STATE_UNLOCK then -- 已解锁
			self._widgets.ok_desc3:setText("进入")
			self._widgets.ok_btn3:onClick(self, self.enterOutCast, nodeData)
		elseif state == OutCastState.STATE_COMPLETE then  
			self._widgets.ok_desc3:setText("领奖")
			self._widgets.ok_btn3:onClick(self, self.getOutCastAward, nodeData)
		end
	end 
end 

function wnd_dailyTask:refreshOutCastAward(awards)
	g_i3k_ui_mgr:refreshScrollItems(self._widgets.taskReward2, awards, "ui/widgets/rchwzt4", g_ITEM_NUM_SHOW_TYPE_NEED)
end 

function wnd_dailyTask:refreshOutCastDesc(nodeData)
	local taskID = nodeData.cfg.id 
	taskID = nodeData.cfg.taskID
	if nodeData.info.state == OutCastState.STATE_UNLOCK then  
		local taskcfg = i3k_db_out_cast_task[self._outCastInfo.curTaskID]
		if taskcfg then 
			taskID = self._outCastInfo.curTaskID
		end 
	end
	local taskCfg = i3k_db_out_cast_task[taskID]
	self._widgets.taskName3:setText(taskCfg.taskName)
	self._widgets.descScroll3:removeAllChildren()
	item = require("ui/widgets/rchwzt3")()
	item.vars.txt:setText(taskCfg.taskDesc)
	self._widgets.descScroll3:addItem(item)
	local size = item.vars.txt:getContentSize()
	item.rootVar:changeSizeInScroll(self._widgets.descScroll3, size.width, size.height*1.5, true)
	self._widgets.descScroll3:update()
	local npcId = taskCfg.npcID -- taskCfg.replActionNpcId
	local npcCfg = i3k_db_npc[npcId]
	ui_set_hero_model(self._widgets.taskIcon3, npcCfg and npcCfg.monsterID or 0)
end 

function wnd_dailyTask:showUnlockOutcastTips(sender, nodeData)
	if g_i3k_db.i3k_db_checkHasItemByCfg(nodeData.cfg.needItems) then 
		if nodeData.info.allOk then 
			g_i3k_ui_mgr:OpenUI(eUIID_UnlockOutcastTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_UnlockOutcastTips, nodeData)
		else 
			g_i3k_ui_mgr:PopupTipMessage("解锁条件不满足")
		end
	else 
		i3k_sbean.biography_unlock(nodeData.cfg.id, nodeData)
	end
end 

function wnd_dailyTask:enterOutCast(sender, nodeData)
	if nodeData.info.allOk then 
		i3k_sbean.biography_start_mapcopy(nodeData.cfg)
	else 
		g_i3k_ui_mgr:PopupTipMessage("进入条件不满足")
	end
end

function wnd_dailyTask:getOutCastAward(sender, nodeData)
	i3k_sbean.biography_take_reward(nodeData)
end  
 
function wnd_dailyTask:updateOutCastItemState(nodeData) 
	local state = OutCastState.STATE_FORBID
	local id = nodeData.cfg.id
	if id <= self._outCastInfo.lastUnlockID then -- 已完成
		if g_i3k_game_context:isOutCastReward(id) then -- 已经领奖
			state = OutCastState.STATE_FINISHED
		else 
			state = OutCastState.STATE_COMPLETE -- 完成没有领奖
		end
	elseif id == self._outCastInfo.curUnlockID then -- 已解锁
		state = OutCastState.STATE_UNLOCK
	elseif id == self._outCastInfo.lastUnlockID + 1 then -- 进行中未解锁
		state = OutCastState.STATE_LOCK
	end 
	nodeData.info.state = state 
	return state 
end 

function wnd_dailyTask:onUpdateAdventrue()
	self.dailyUI:hide()
	self.fame_root:hide()
	self.outCast_root:hide()
	self.advtRoot:show()
	self._state = 3
	self:SetFameBtnState()
	self:setTabBtn()
	local context = g_i3k_game_context:getAdventure()
	local trigID = context.trigID == 0 and 1 or context.trigID
	self:updateAdventureScroll(trigID)
	self:updateAdventureState(trigID)
end

function wnd_dailyTask:onAdventureItem(sender, id)
	if self.advenTaskBtn == sender then
		return
	end
	self.advenTaskBtn:stateToNormal()
	self.advenTaskBtn = sender
	sender:stateToPressed()
	self:updateAdventureState(id)
end

function wnd_dailyTask:OnOutCast(sender)
	self.dailyUI:hide()
	self.fame_root:hide()
	self.advtRoot:hide()
	self.outCast_root:show()
	self._state = 4
	self:setTabBtn()
	self:SetFameBtnState()
	self:updateOutCastScroll(sender)
end 

function wnd_dailyTask:chooseTask(sender, taskId)
	i3k_sbean.adtask_selectReq(taskId)
end

function wnd_dailyTask:chooseHeadTask(sender, taskId)
	i3k_sbean.adtask_acceptReq(taskId)
end

-- function wnd_dailyTask:goToOutCast(sender)
-- 	self:OnOutCast(sender)
-- end

function wnd_dailyTask:goToAdvtTask(sender)
	g_i3k_logic:OpenBattleUI(function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "doAdventureTask")
	end)
end

function wnd_dailyTask:abandonAdvtTask(sender, taskId)
	g_i3k_sbean.adtask_quit_req(taskId)
end

function wnd_dailyTask:getTotalRewards(sender, trigID)
	local data = g_i3k_game_context:getAdventure()
	local items = {}
	for k, v in pairs(data.finished[trigID].rewards) do
		items[k] = v
	end
	if g_i3k_game_context:IsBagEnough(items) then
		i3k_sbean.adtask_total_rewardReq(trigID)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包已满，请先清理背包再领取奖励")
	end
end


-- 图鉴
function wnd_dailyTask:onCardPack(sender)
	local state = self._state
	self:onCloseUI()
	g_i3k_logic:OpenCardPacketUI(oldState)
end


function wnd_create(layout, ...)
	local wnd = wnd_dailyTask.new();
		wnd:create(layout, ...);
	return wnd;
end
