OpenServiceAcitivityData = OpenServiceAcitivityData or BaseClass()

OPEN_SERVER_GIFT_INDEX = {
	EQUIP_GIFT = 1,
	MONEY_GIFT = 2,
	WEAPON_GIFT = 3,
	WING_GIFT = 4,
	RING_GIFT = 5,
	GEM_GIFT = 6,
	SAINTBALL_GIFT = 7,
}

OPEN_SERVER_TAB_INDEX = {
	OpenServiceAcitivityLeveGift 				= 1, 	--等级礼包
	OpenServiceAcitivityMoldingSoulSports 		= 2, 	--铸魂竞技
	OpenServiceAcitivityMoldingSoulList 		= 3, 	--铸魂榜
	OpenServiceAcitivityGemStoneSports 			= 4, 	--宝石竞技
	OpenServiceAcitivityGemStoneList 			= 5, 	--宝石榜
	OpenServiceAcitivityDragonSpiritSports 		= 6, 	--龙魂竞技
	OpenServiceAcitivityDragonSpiritList 		= 7, 	--龙魂榜
	OpenServiceAcitivityWingSports 				= 8, 	--羽翼竞技
	OpenServiceAcitivityWingList 				= 9, 	--羽翼榜
	OpenServiceAcitivityCardHandlebookSports 	= 10, 	--图鉴竞技
	OpenServiceAcitivityCardHandlebookList 		= 11, 	--图鉴榜
	OpenServiceAcitivityCircleSports 			= 12, 	--转生竞技
	OpenServiceAcitivityCircleList 				= 13, 	--转生榜
	OpenServiceAcitivityCharge 					= 14, 	--累计充值
	OpenServiceAcitivityLuckyDraw 				= 15, 	--幸运抽奖
	OpenServiceAcitivityBoss 					= 16, 	--全民BOSS
	OpenServiceAcitivityWangChengBaYe	 		= 17, 	--王城霸业
	OpenServiceAcitivityXunBao 					= 18,	--开服寻宝
	OpenServiceAcitivityFinancial 				= 19,	--超值理财
	OpenServiceAcitivityConsume 				= 21,	--消费排行
	OpenServiceAcitivityRecharge 				= 22,	--充值排行
	OpenServiceAcitivityExploreRank				= 23,	--寻宝榜
}

SPROT_TYPE = {
	MoldingSoulSports 		= 1,
	GemStoneSports 			= 2,
	DragonSpiritSports 		= 3,
	WingSports 				= 4,
	CardHandlebookSports 	= 5,
	CircleSports 			= 6,
}

SPORT_INDEX = {
	[1] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports,
	[2] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports,
	[3] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports,
	[4] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports,
	[5] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports,
	[6] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports,
}

SPORT_LIST_INDEX = {
	[1] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulList,
	[2] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneList,
	[3] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritList,
	[4] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingList,
	[5] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookList,
	[6] = OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleList,	
}

SPORT_LIST_TITLE_ID = {
	[1] = 3,
	[2] = 4,
	[3] = 5,
	[4] = 6,
	[5] = 7,
	[6] = 8,
}

-- 事件监听
OpenServiceAcitivityData.LevelGiftChange 				= "level_gift_change"
OpenServiceAcitivityData.SportsChange 					= "sports_change"
OpenServiceAcitivityData.SportsListChange				= "sports_list_change"
OpenServiceAcitivityData.ChargeChange 					= "charge_change"
OpenServiceAcitivityData.LuckyDrawChange 				= "lucky_draw_change"
OpenServiceAcitivityData.LuckyStartDraw					= "lucky_start_draw"
OpenServiceAcitivityData.DrawRecordLogCharge			= "draw_record_log_change"
OpenServiceAcitivityData.BossChange 					= "boss_change"
OpenServiceAcitivityData.XunBaoChange 					= "xun_bao_change"
OpenServiceAcitivityData.ExploreRankChange 				= "explore_rank_change"

OpenServiceAcitivityData.TabbarDisplayChange			= "tabbar_display_change"

-- 视图列表
OpenServiceAcitivityData.ViewTable = {
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityLeveGift,		
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityMoldingSoulSports,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityMoldingSoulList,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityGemStoneSports,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityGemStoneList,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityDragonSpiritSports,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityDragonSpiritList,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityWingSports,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityWingList,	
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCardHandlebookSports,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCardHandlebookList,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCircleSports,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCircleList,	
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityCharge,	
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityLuckyDraw,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityBoss,	
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityWangChengBaYe,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityXunBao,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityFinancial,
	ViewDef.OpenServiceAcitivity.GoldDraw,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityConsume,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityRecharge,
	ViewDef.OpenServiceAcitivity.OpenServiceAcitivityExploreRank,
	}

function OpenServiceAcitivityData:__init()
	if OpenServiceAcitivityData.Instance then
		ErrorLog("[OpenServiceAcitivityData] Attemp to create a singleton twice !")
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	OpenServiceAcitivityData.Instance = self

	self.info_list = {}
	self.tabbar_title_list = {}
	self.tabbar_mark_list = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	self.draw_log_list = {}
	self:InitTabbarName()
	self.my_explore_times = -1
	GlobalEventSystem:Bind(OtherEventType.MOLDINGSOUL_INFO_CHANGE, BindTool.Bind(self.OnMoldingSoulChange, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
	self.role_data_listener_h = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleDataChange, self))
end

function OpenServiceAcitivityData:__delete()
	OpenServiceAcitivityData.Instance = nil
	if self.role_data_listener_h and RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.role_data_listener_h)
	end
	self.my_explore_times = -1
end

function OpenServiceAcitivityData:InitTabbarName()
	for k, v in pairs(OpenServiceAcitivityData.ViewTable) do
		table.insert(self.tabbar_title_list, v.name)
	end
end

-- 根据分数获得等级
function OpenServiceAcitivityData.GetGredeContent(level)
	local content = ""
	local sports_type = OpenServiceAcitivityData.Instance:GetSportsShowIndex()
	local rank_grade = level
	if SPROT_TYPE.MoldingSoulSports == sports_type then
		content = "{wordcolor;e3dd9e;我的铸魂等级：}{wordcolor;f8c71b;" .. level .. "}"
	elseif SPROT_TYPE.GemStoneSports == sports_type then
		local totol_grade = level
		local grade = GodFurnaceData.Instance:GetGradeNum(totol_grade)
		local star = GodFurnaceData.Instance:GetStarNum(totol_grade)
		content = "{wordcolor;e3dd9e;我的宝石等级：}{wordcolor;f8c71b;" .. grade .. "阶" .. star .. "星}"
		rank_grade = grade .. "阶" .. star .. "星"
	elseif SPROT_TYPE.DragonSpiritSports == sports_type then
		local totol_grade = level
		local grade = GodFurnaceData.Instance:GetGradeNum(totol_grade)
		local star = GodFurnaceData.Instance:GetStarNum(totol_grade)
		content = "{wordcolor;e3dd9e;我的龙魂等级：}{wordcolor;f8c71b;" .. grade .. "阶" .. star .. "星}"
		rank_grade = grade .. "阶" .. star .. "星"
	elseif SPROT_TYPE.WingSports == sports_type then
		content = "{wordcolor;e3dd9e;我的羽翼等级：}{wordcolor;f8c71b;" .. level .. "阶}"
		rank_grade = level .. "阶"
	elseif SPROT_TYPE.CardHandlebookSports == sports_type then
		content = "{wordcolor;e3dd9e;我的图鉴战力：}{wordcolor;f8c71b;" .. level .. "}"
	elseif SPROT_TYPE.CircleSports == sports_type then
		content = "{wordcolor;e3dd9e;我的转生等级：}{wordcolor;f8c71b;" .. level .. "转}"
		rank_grade = level .. "转"
	end
	return content, rank_grade
end

-- 获取Tabbar显示文字
function OpenServiceAcitivityData:GetTabbarTitleList()
	return self.tabbar_title_list or {}
end

-- 奖励列表是否全部被领取
function OpenServiceAcitivityData:AwardIsAllGet(tabbar_index)
	if nil == tabbar_index or nil == self.info_list[tabbar_index] or nil == self.info_list[tabbar_index].item_list then return false end
	for k, v in pairs(self.info_list[tabbar_index].item_list) do
		if v.btn_state == 1 or v.btn_state == 0 then
			return false
		end
	end
	return true
end

-- 更新Tabbar标志列表
function OpenServiceAcitivityData:UpdateTabbarMarkList()
	-- self.tabbar_mark_list = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1}
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local need_level = 0
	-- 等级礼包标记
	local cfg = OpenLevelGiftBagCfg
	local begin_day = cfg.openDay.startDay
	local end_day = cfg.openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) and not self:AwardIsAllGet(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] = 1
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] = 0
	end
	-- 铸魂竞技标记
	cfg = self:GetSportsConfig(SPROT_TYPE.MoldingSoulSports)
	begin_day = cfg[1].openDay.startDay
	end_day = cfg[1].openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports] = 1
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulList] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulList] = 0
    	end
		self.sports_show_index = SPROT_TYPE.MoldingSoulSports
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports] = 0
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulList] = 0
	end
	-- 宝石竞技标记
	cfg = self:GetSportsConfig(SPROT_TYPE.GemStoneSports)
	begin_day = cfg[1].openDay.startDay
	end_day = cfg[1].openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports] = 1
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneList] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneList] = 0
    	end
		self.sports_show_index = SPROT_TYPE.GemStoneSports
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports] = 0
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneList] = 0
	end
	-- 龙魂竞技标记
	cfg = self:GetSportsConfig(SPROT_TYPE.DragonSpiritSports)
	begin_day = cfg[1].openDay.startDay
	end_day = cfg[1].openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports] = 1
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritList] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritList] = 0
    	end
		self.sports_show_index = SPROT_TYPE.DragonSpiritSports
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports] = 0
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritList] = 0
	end
	-- 羽翼竞技标记
	cfg = self:GetSportsConfig(SPROT_TYPE.WingSports)
	begin_day = cfg[1].openDay.startDay
	end_day = cfg[1].openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports] = 1
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingList] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingList] = 0
    	end
		self.sports_show_index = SPROT_TYPE.WingSports
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports] = 0
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingList] = 0
	end
	-- 图鉴竞技标记
	cfg = self:GetSportsConfig(SPROT_TYPE.CardHandlebookSports)
	begin_day = cfg[1].openDay.startDay
	end_day = cfg[1].openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports] = 1
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookList] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookList] = 0
    	end
		self.sports_show_index = SPROT_TYPE.CardHandlebookSports
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports] = 0
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookList] = 0
	end
	-- 转生竞技标记
	cfg = self:GetSportsConfig(SPROT_TYPE.CircleSports)
	begin_day = cfg[1].openDay.startDay
	end_day = cfg[1].openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports] = 1
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleList] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleList] = 0
    	end
		self.sports_show_index = SPROT_TYPE.CircleSports
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports] = 0
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleList] = 0
	end
	-- 累计充值标记
	cfg = AccumulativeRechargeCfg
	need_level = cfg.openCondition.level
	begin_day = cfg.openCondition.openDay.startDay
	end_day = cfg.openCondition.openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) and not self:AwardIsAllGet(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge] = 1
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge] = 0
	end
	-- 幸运抽奖标记
	cfg = openSvrLuckyDrawCfg
	begin_day = cfg.openDay.startDay
	end_day = cfg.openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] = 0
        end
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] = 0
	end
	-- 全民BOSS标记
	cfg = OpenAllPeopleBossCfg
	need_level = cfg.openCondition.level
	begin_day = cfg.openCondition.openDay.startDay
	end_day = cfg.openCondition.openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) and not self:AwardIsAllGet(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss] = 1
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss] = 0
	end
	-- 王成霸业标记
	cfg = WangChengBaYeCfg
	begin_day = cfg.openCondition.openDay.startDay
	end_day = cfg.openCondition.openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe] = 1
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe] = 0
	end
	-- 开服寻宝标记
	cfg = OpenTreasureHuntingCfg
	need_level = cfg.openCondition.level
	begin_day = cfg.openCondition.openDay.startDay
	end_day = cfg.openCondition.openDay.endDay
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao] = 1
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao] = 0
	end

	-- 超值理财标记
	cfg = FinancingCfg
	need_level = cfg.level
	begin_day = 1
	end_day = cfg.openDay

	local boor = #WelfareData.Instance:GetFinancingItemData() > 0
	if OtherData.Instance:CondOpenServerDayRange({begin_day, end_day}) and boor then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityFinancial] = 1
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityFinancial] = 0
	end

	-- 消费排行标记
	local boor = WelfareData.Instance:GetConsumeRankOpen() ~= nil
	if boor then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityConsume] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityConsume] = 0
        end
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityConsume] = 0
	end

	-- 充值排行标记
	local boor = WelfareData.Instance:GetRechargeRankOpen() ~= nil
	if boor then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityRecharge] = 1
		if IS_AUDIT_VERSION then
        	self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityRecharge] = 0
        end
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityRecharge] = 0
	end


	-- 寻宝榜标记
	cfg = OpenTreasureHuntingRankCfg
	need_level = cfg.level
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if self:GetState() > 0 and need_level <= level then
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] = 1
	if IS_AUDIT_VERSION then
        self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] = 0
    end
	else
		self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] = 0
	end
	self:DispatchEvent(OpenServiceAcitivityData.TabbarDisplayChange)
end

-- 获取Tabbar标志列表
function OpenServiceAcitivityData:GetTabbarMarkList()
	-- self:UpdateTabbarMarkList()
	return self.tabbar_mark_list
end

-- 获取默认显示index
function OpenServiceAcitivityData:GetTabbarDefaultIndex()
	if nil == self.tabbar_mark_list then return end
	for k, v in pairs(self.tabbar_mark_list) do
		if 1 == v then return k end
	end
	return 0
end

function OpenServiceAcitivityData:GetRemindNumByType(remind_name)
	if remind_name == RemindName.OpenServiceLevelGift then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] or self:RewardIsReceived() then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift)
	elseif remind_name == RemindName.OpenServiceMoldingSoulSports then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityMoldingSoulSports)
	elseif remind_name == RemindName.OpenServiceGemStoneSports then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityGemStoneSports)
	elseif remind_name == RemindName.OpenServiceDragonSpiritSports then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityDragonSpiritSports)
	elseif remind_name == RemindName.OpenServiceWingSports then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWingSports)
	elseif remind_name == RemindName.OpenServiceCardHandlebookSports then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCardHandlebookSports)
	elseif remind_name == RemindName.OpenServiceCircleSports then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCircleSports)
	elseif remind_name == RemindName.OpenServiceCharge then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge)
	elseif remind_name == RemindName.OpenServiceLuckyDraw then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] then return 0 end
		return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].draw_left_times
	elseif remind_name == RemindName.OpenServiceBoss then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss)
	elseif remind_name == RemindName.OpenServiceXunBao then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao] then return 0 end
		return self:GetAwardListRemindNum(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao)
	elseif remind_name == RemindName.OpenServiceExploreRank then
		if 0 == self.tabbar_mark_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] then return 0 end
		return self:GetExploreRemindNum()
	end
end

function OpenServiceAcitivityData:GetAwardListRemindNum(tabbar_index)
	local remind_num = 0
	if nil ~= self.info_list[tabbar_index] then
		for k, v in pairs(self.info_list[tabbar_index].item_list) do
			if 1 == v.btn_state then
				remind_num = remind_num + 1
			end
		end
	end
	return remind_num
end

-- 根据按钮状态排序列表
function OpenServiceAcitivityData:SortList(sort_index)
	local temp_list = {}
	local index = 1
	for k, v in pairs(self.info_list[sort_index].item_list) do
		if 1 == v.btn_state then
			temp_list[index] = v
			index = index + 1
		end
	end
	for k, v in pairs(self.info_list[sort_index].item_list) do
		if 0 == v.btn_state then
			temp_list[index] = v
			index = index + 1
		end
	end
	for k, v in pairs(self.info_list[sort_index].item_list) do
		if 2 == v.btn_state then
			temp_list[index] = v
			index = index + 1
		end
	end
	self.info_list[sort_index].item_list = temp_list
end

--------------------------------------
-- 活动时间
--------------------------------------
function OpenServiceAcitivityData:GetActivityTime(begin_day, end_day)
	local open_server_days = OtherData.Instance:GetOpenServerDays() - 1
	if nil ~= begin_day and nil ~= end_day then
		local begin_date_t = self:GetDateTable(OtherData.Instance.open_server_time, begin_day - 1)
		local end_date_t = self:GetDateTable(OtherData.Instance.open_server_time, end_day - 1)
		local begin_date_s = string.format("%d/%d/%d", begin_date_t.year or 0, begin_date_t.month or 0, begin_date_t.day or 0)
		local end_date_s = string.format("%d/%d/%d", end_date_t.year or 0, end_date_t.month or 0, end_date_t.day or 0)
		return begin_date_s .. "-" .. end_date_s
	end

	return Language.OpenServiceAcitivity.NoTimeLimit
end

function OpenServiceAcitivityData:GetDateTable(open_server_time, shift_day)
	shift_day = shift_day or 0
	local time_s = open_server_time + shift_day * 24 * 60 * 60

	local t = {}
	t.year = tonumber(os.date("%Y",time_s))
	t.month = tonumber(os.date("%m",time_s))
	t.day = tonumber(os.date("%d",time_s))
	t.hour = tonumber(os.date("%H",time_s))
	t.min = tonumber(os.date("%M",time_s))
	t.sec = tonumber(os.date("%S",time_s))

	return t
end

-------------------------------------------------
-- 等级奖励Begin
-------------------------------------------------

-- 设置等级礼包信息
function OpenServiceAcitivityData:SetLevelGiftInfo(protocol)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local level_gift_info = self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] or {}
	level_gift_info.receive_state = protocol.receive_state
	level_gift_info.left_award_list = protocol.left_award_list
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] = level_gift_info
	self:SetLevelGiftItemInfo()
end

-- 设置等级礼包item信息
function OpenServiceAcitivityData:SetLevelGiftItemInfo()
	if nil == self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] then return end
	local cfg = OpenLevelGiftBagCfg
	if nil == cfg then return end
	local level_gift_info = self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift]
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_limit = role_circle * 1000 + role_level

	local reverse_receive_state_list = bit:d2b(level_gift_info.receive_state)
	local receive_state_list = {}
	for i = 1, #reverse_receive_state_list do
		receive_state_list[i] = table.remove(reverse_receive_state_list)
	end

	level_gift_info.item_list = {}
	for k, v in pairs(cfg.giftBag) do
		level_gift_info.item_list[k] = {}
		level_gift_info.item_list[k].index = k
		level_gift_info.item_list[k].need_level = v.needLv
		level_gift_info.item_list[k].left_award_num = v.limitCount - level_gift_info.left_award_list[k] -- 剩于数量
		if role_limit >=  v.needLv and level_gift_info.item_list[k].left_award_num > 0 then
			level_gift_info.item_list[k].btn_state = 1
		else
			level_gift_info.item_list[k].btn_state = 0
		end
		level_gift_info.item_list[k].btn_state = receive_state_list[k] == 0 and level_gift_info.item_list[k].btn_state or 2
		level_gift_info.item_list[k].award_list = {}
		for k1, v1 in pairs(v.awards) do
			level_gift_info.item_list[k].award_list[k1] = ItemData.InitItemDataByCfg(v1)
		end
	end
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] = level_gift_info
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceLevelGift)
	self:DispatchEvent(OpenServiceAcitivityData.LevelGiftChange)
end

-- 获取等级奖励面板信息
function OpenServiceAcitivityData:GetLevelGiftInfo()
	self:SortList(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift)
	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift] or {}
end

-- 达到的等级礼包被领完
function OpenServiceAcitivityData:RewardIsReceived()
	for k, v in pairs(self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLeveGift].item_list) do
		if v.left_award_num > 0 and v.btn_state == 1 then return false end
	end
	return true
end

-------------------------------------------------
-- 等级奖励End
-------------------------------------------------

-------------------------------------------------
-- 竞技Begin
-------------------------------------------------

function OpenServiceAcitivityData:SetSportsInfo(protocol)
	local sports_type = protocol.sports_type
	local sports_info = self.info_list[SPORT_INDEX[sports_type]] or {}
	sports_info.sports_type = sports_type
	sports_info.receive_state = protocol.receive_state
	self.info_list[SPORT_INDEX[sports_type]] = sports_info
	if sports_type == SPROT_TYPE.MoldingSoulSports then
		self:OnMoldingSoulChange()
	elseif sports_type == SPROT_TYPE.WingSports then
		self:SetSportsList(SPROT_TYPE.WingSports, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL))
	elseif sports_type == SPROT_TYPE.GemStoneSports then
		self:SetSportsList(SPROT_TYPE.GemStoneSports, GodFurnaceData.Instance:GetSlotData(GodFurnaceData.Slot.GemStonePos).level)
	elseif sports_type == SPROT_TYPE.DragonSpiritSports then
		self:SetSportsList(SPROT_TYPE.DragonSpiritSports, GodFurnaceData.Instance:GetSlotData(GodFurnaceData.Slot.DragonSpiritPos).level)
	elseif sports_type == SPROT_TYPE.CardHandlebookSports then
			self:OnCardHandleBoolChange()
	elseif sports_type == SPROT_TYPE.CircleSports then
		self:SetSportsList(SPROT_TYPE.CircleSports, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE))
	end
end

-- 设置竞技信息列表
function OpenServiceAcitivityData:SetSportsList(sports_type, LimitNum)
	if nil == self.info_list[SPORT_INDEX[sports_type]] then return end
	local cfg = self:GetSportsConfig(sports_type)
	local sports_info = self.info_list[SPORT_INDEX[sports_type]]
	local reverse_receive_state_list = bit:d2b(sports_info.receive_state)
	local receive_state_list = {}
	for i = 1, #reverse_receive_state_list do
		receive_state_list[i] = table.remove(reverse_receive_state_list)
	end
	sports_info.my_grade = LimitNum

	sports_info.item_list = {}
	for k, v in pairs(cfg[1].gradeAwards) do
		sports_info.item_list[k] = {}
		sports_info.item_list[k].sports_type = sports_type
		sports_info.item_list[k].index = k
		sports_info.item_list[k].need_level = v.needLevel
		if LimitNum >=  v.needLevel then
			sports_info.item_list[k].btn_state = 1
		else
			sports_info.item_list[k].btn_state = 0
		end
		sports_info.item_list[k].btn_state = sports_info.item_list[k].btn_state + receive_state_list[k]
		sports_info.item_list[k].award_list = {}
		for k1, v1 in pairs(v.awards) do
			sports_info.item_list[k].award_list[k1] = ItemData.FormatItemData(v1)
		end
	end
	sports_info.tips = cfg[1].tips
	self.info_list[SPORT_INDEX[sports_type]] = sports_info
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceMoldingSoulSports)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceGemStoneSports)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceDragonSpiritSports)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceWingSports)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceCardHandlebookSports)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceCircleSports)
	self:DispatchEvent(OpenServiceAcitivityData.SportsChange)
end

-- 设置竞技榜信息
function OpenServiceAcitivityData:SetSportsListInfo(protocol)
	local sports_type = protocol.sports_type
	local cfg = self:GetSportsConfig(sports_type)
	if nil == cfg then return end
	local sports_list_info = self.info_list[SPORT_LIST_INDEX[sports_type]] or {}
	sports_list_info.rank_data = protocol.rank_data
	sports_list_info.awards_list = {}
	for i = 1, 4 do 
		sports_list_info.awards_list[i] = {}
		for k, v in pairs(cfg[1].rankings[i].award) do
			sports_list_info.awards_list[i][k] = ItemData.FormatItemData(v)
			local t = sports_list_info.awards_list[i][k]
		end
	end
	sports_list_info.my_rank = protocol.my_rank
	sports_list_info.tips = cfg[1].tips
	self.info_list[SPORT_LIST_INDEX[sports_type]] = sports_list_info
	self:DispatchEvent(OpenServiceAcitivityData.SportsListChange)
end

function OpenServiceAcitivityData:GetSportsShowIndex()
	return self.sports_show_index
end

function OpenServiceAcitivityData:GetSportsListDataList(sports_type)
	local sports_list_rank_data = DeepCopy(self.info_list[SPORT_LIST_INDEX[sports_type]].rank_data)
	for i = 1, 3 do
		if sports_list_rank_data[1] then
			table.remove(sports_list_rank_data, 1)
		end
	end
	return sports_list_rank_data
end

function OpenServiceAcitivityData:SetSportsLeftTime(panel, index)
	local cfg = self:GetSportsConfig(index)
	local info_index = 0
	if 1 == panel then
		info_index = SPORT_LIST_INDEX[index]
	elseif 2 == panel then
		info_index = SPORT_INDEX[index]
	end
	if nil == self.info_list[info_index] then return end
	if nil ~= cfg then
		if cfg[1].openDay.startDay > OtherData.Instance:GetOpenServerDays() then
			self.info_list[info_index].time = TimeUtil.Format2TableDHM(0)
		else
			local end_day = cfg[1].openDay.endDay
			local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())
			local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
			local day = end_day - OtherData.Instance:GetOpenServerDays()
			local hour = math.floor(left_sec / 3600 )
			local minute = math.floor((left_sec - hour * 3600) / 60 )

			local end_day = cfg[1].openDay.endDay
			local diff_day = end_day - OtherData.Instance:GetOpenServerDays()
			if diff_day < 0 then
				return 0
			end
			local end_sec = end_day * 24 * 60 * 60
			local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())

			local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
			self.info_list[info_index].time = TimeUtil.Format2TableDHM(diff_day * 24 * 60 * 60 + left_sec)
		end
	end
end

function OpenServiceAcitivityData:GetMySportsGrade(sports_type)
	return self.info_list[SPORT_INDEX[sports_type]].my_grade
end

function OpenServiceAcitivityData:GetSportsInfo(index)
	self:SetSportsLeftTime(2, index)
	self:SortList(SPORT_INDEX[index])
	return self.info_list[SPORT_INDEX[index]] or {}
end

function OpenServiceAcitivityData:GetSportsListInfo(index)
	self:SetSportsLeftTime(1, index)
	return self.info_list[SPORT_LIST_INDEX[index]] or {}
end

function OpenServiceAcitivityData:RecvMainInfoCallBack()
	EventProxy.New(GodFurnaceData.Instance):AddEventListener(GodFurnaceData.SLOT_DATA_CHANGE, BindTool.Bind(self.OnGodFurnaceChange, self))
	EventProxy.New(CardHandlebookData.Instance):AddEventListener(CardHandlebookData.UPDATE_CARD_INFO, BindTool.Bind(self.OnCardHandleBoolChange, self))
end

function OpenServiceAcitivityData:OnMoldingSoulChange()
    self:SetSportsList(SPROT_TYPE.MoldingSoulSports, MoldingSoulData.Instance:GetAllMsStrengthLevel())
end

function OpenServiceAcitivityData:OnGodFurnaceChange(slot, slot_data)
	if GodFurnaceData.Slot.GemStonePos == slot then
		self:SetSportsList(SPROT_TYPE.GemStoneSports, slot_data.level)
	elseif GodFurnaceData.Slot.DragonSpiritPos == slot then
		self:SetSportsList(SPROT_TYPE.DragonSpiritSports, slot_data.level)
	end
end

function OpenServiceAcitivityData:OnCardHandleBoolChange()
	local num = 0
	for k, v in pairs(CardHandlebookData.Instance.show_card_list) do
		for k1, v1 in pairs(v) do
			if v1.level then --等级为空即未激活
				num = num + v1.battle_num
			end
		end
	end
	self:SetSportsList(SPROT_TYPE.CardHandlebookSports, num)
end

function OpenServiceAcitivityData:OnRoleDataChange(vo)
	if vo.key == OBJ_ATTR.ACTOR_SWING_LEVEL then
		self:SetSportsList(SPROT_TYPE.WingSports, vo.value)
	elseif vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		self:SetSportsList(SPROT_TYPE.CircleSports, vo.value)
		self:SetLevelGiftItemInfo()
	elseif vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self:SetLevelGiftItemInfo()
	end
end

function OpenServiceAcitivityData:GetSportsConfig(sprots_type)
	if sports_type == 0 then return end
	return ConfigManager.Instance:GetServerConfig("activityconfig/OpenServer/sports/SportsConfig" .. sprots_type)
end

-------------------------------------------------
-- 竞技End
-------------------------------------------------

-------------------------------------------------
-- 累计充值Begin
-------------------------------------------------

function OpenServiceAcitivityData:SetChargeInfo(protocol)
	local cfg = AccumulativeRechargeCfg
	if nil == cfg then return end
	local charge_info = self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge] or {}
	charge_info.item_list = {}
	local reverse_receive_state_list = bit:d2b(protocol.receive_state)
	local receive_state_list = {}
	charge_info.charge_money = protocol.charge_money
	for i = 1, #reverse_receive_state_list do
		receive_state_list[i] = table.remove(reverse_receive_state_list)
	end

	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(cfg.gradeAwards) do
		charge_info.item_list[k] = {}
		charge_info.item_list[k].index = k
		charge_info.item_list[k].need_money = v.limitYb
		if charge_info.charge_money >=  v.limitYb then
			charge_info.item_list[k].btn_state = 1
		else
			charge_info.item_list[k].btn_state = 0
		end
		charge_info.item_list[k].btn_state = charge_info.item_list[k].btn_state + receive_state_list[k]
		charge_info.item_list[k].award_list = {}
		for k1, v1 in pairs(v.awards) do
			table.insert(charge_info.item_list[k].award_list, ItemData.InitItemDataByCfg(v1))
		end
	end
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge] = charge_info
	self:DispatchEvent(OpenServiceAcitivityData.ChargeChange)
end

function OpenServiceAcitivityData:GetChargeInfo()
	-- -- 累计充值时间
	-- local cfg = AccumulativeRechargeCfg
	-- local open_server_day = OtherData.Instance:GetOpenServerDays() -- 已经开服多少天
	-- if nil ~= cfg then
	-- 	local end_day = cfg.openCondition.openDay.endDay
	-- 	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge].left_day = end_day - open_server_day
	-- end

	local cfg = AccumulativeRechargeCfg
	if nil ~= cfg then
		local end_day = cfg.openCondition.openDay.endDay
		local diff_day = end_day - OtherData.Instance:GetOpenServerDays()
		if diff_day < 0 then
			return 0
		end
		local end_sec = end_day * 24 * 60 * 60
		local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())

		local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge].time = TimeUtil.Format2TableDHM(diff_day * 24 * 60 * 60 + left_sec)
	end

	self:SortList(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge)
	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityCharge] or {}
end

-------------------------------------------------
-- 累计充值End
-------------------------------------------------

-------------------------------------------------
-- 幸运抽奖Begin
-------------------------------------------------

function OpenServiceAcitivityData:SetDrawInfo(protocol)
	local cfg = openSvrLuckyDrawCfg
	if nil == cfg then return end
	local draw_info = self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] or {}
	draw_info.draw_left_times = protocol.draw_left_times
	local pool_index = protocol.award_pool_index
	draw_info.award_list = {}
	for k, v in pairs(cfg.awardPool[pool_index].award) do
		draw_info.award_list[k] = ItemData.FormatItemData(v)
		draw_info.award_list[k].index = k
	end
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] = draw_info

	if nil == protocol.draw_index or 0 == protocol.draw_index then
		self:DispatchEvent(OpenServiceAcitivityData.LuckyDrawChange)
	else
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].draw_index = protocol.draw_index
		self:DispatchEvent(OpenServiceAcitivityData.LuckyStartDraw)
	end
end

function OpenServiceAcitivityData:GetDrawInfo()
	local cfg = openSvrLuckyDrawCfg
	if nil ~= cfg then
		local begin_day = cfg.openDay.startDay
		local end_day = cfg.openDay.endDay
		local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())
		local diff_day = end_day - OtherData.Instance:GetOpenServerDays()
		local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].time = TimeUtil.Format2TableDHM(diff_day * 24 * 60 * 60 + left_sec)

		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].draw_consume = cfg.consumeYb
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].activity_time_interval = self:GetActivityTime(begin_day, end_day)
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].tips = cfg.tips
	end
	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw] or {}
end

function OpenServiceAcitivityData:SetDrawServerRecording(protocol)
	self.draw_log_list = protocol.log_list
	self:DispatchEvent(OpenServiceAcitivityData.DrawRecordLogCharge)
end

function OpenServiceAcitivityData:GetDrawServerRecording()
	return self.draw_log_list or {}
end

-------------------------------------------------
-- 幸运抽奖End
-------------------------------------------------

-------------------------------------------------
-- 全民BOSS Begin
-------------------------------------------------

function OpenServiceAcitivityData:SetBossInfo(protocol)
	local cfg = OpenAllPeopleBossCfg
	if nil == cfg then return end
	local boss_info = self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss] or {}
	boss_info.item_list = {}
	local reverse_receive_state_list = bit:d2b(protocol.receive_state)
	local receive_state_list = {}
	for i = 1, #reverse_receive_state_list do
		receive_state_list[i] = table.remove(reverse_receive_state_list)
	end

	for k, v in pairs(cfg.gradeAwards) do
		boss_info.item_list[k] = {}
		boss_info.item_list[k].index = k
		boss_info.item_list[k].need_kill = v.killCount
		boss_info.item_list[k].kill_count = protocol.kill_num
		if protocol.kill_num >=  v.killCount then
			boss_info.item_list[k].btn_state = 1
		else
			boss_info.item_list[k].btn_state = 0
		end
		boss_info.item_list[k].btn_state = boss_info.item_list[k].btn_state + receive_state_list[k]
		boss_info.item_list[k].award_list = {}
		for k1, v1 in pairs(v.awards) do
			boss_info.item_list[k].award_list[k1] = ItemData.FormatItemData(v1)
		end
	end
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss] = boss_info
	self:DispatchEvent(OpenServiceAcitivityData.BossChange)
end

function OpenServiceAcitivityData:GetBossInfo()
	local cfg = OpenAllPeopleBossCfg
	if nil == cfg then return end
	local begin_day = cfg.openCondition.openDay.startDay
	local end_day = cfg.openCondition.openDay.endDay
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss].activity_time_interval = self:GetActivityTime(begin_day, end_day)
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss].tips = cfg.tips

	self:SortList(OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss)
	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityBoss] or {}
end

-------------------------------------------------
-- 全民BOSS End
-------------------------------------------------

-------------------------------------------------
-- 王城霸业 Begin
-------------------------------------------------

function OpenServiceAcitivityData:GetWangChengBaYeInfo()
	local cfg = WangChengBaYeCfg
	local role_sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	if nil == cfg then return end
	if nil == self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe] then
		local wang_cheng_ba_ye_info = {}
		local begin_day = cfg.openCondition.openDay.startDay
		local end_day = cfg.openCondition.openDay.endDay
		wang_cheng_ba_ye_info.award_list = {}
		for k, v in pairs(cfg.ShowAwards) do
			if role_sex == v.sex or v.sex == nil then
				table.insert(wang_cheng_ba_ye_info.award_list, ItemData.FormatItemData(v))
			end
		end
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe] = wang_cheng_ba_ye_info
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe].activity_time_interval = self:GetActivityTime(begin_day, end_day)
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe].tips = cfg.tips
	end
	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityWangChengBaYe] or {}
end

-------------------------------------------------
-- 王城霸业 End
-------------------------------------------------

-------------------------------------------------
-- 寻宝 Begin
-------------------------------------------------

function OpenServiceAcitivityData:SetXunBaoInfo(protocol)
	local cfg = OpenTreasureHuntingCfg
	if nil == cfg then return end
	local xun_bao_info = self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao] or {}
	xun_bao_info.item_list = {}
	local reverse_receive_state_list = bit:d2b(protocol.receive_state)
	local receive_state_list = {}
	for i = 1, #reverse_receive_state_list do
		receive_state_list[i] = table.remove(reverse_receive_state_list)
	end
	xun_bao_info.xun_bao_times = protocol.xun_bao_times

	for k, v in pairs(cfg.gradeAwards) do
		xun_bao_info.item_list[k] = {}
		xun_bao_info.item_list[k].index = k
		xun_bao_info.item_list[k].limit_times = v.limitTimes
		if xun_bao_info.xun_bao_times >=  v.limitTimes then
			xun_bao_info.item_list[k].btn_state = 1
		else
			xun_bao_info.item_list[k].btn_state = 0
		end
		xun_bao_info.item_list[k].btn_state = xun_bao_info.item_list[k].btn_state + receive_state_list[k]
		xun_bao_info.item_list[k].award_list = {}
	end
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao] = xun_bao_info
	self:DispatchEvent(OpenServiceAcitivityData.XunBaoChange)
end

function OpenServiceAcitivityData:GetXunBaoInfo()
	local cfg = OpenTreasureHuntingCfg
	if nil ~= cfg then
		-- local end_day = cfg.openCondition.openDay.endDay
		-- local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())
		-- local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
		-- local day = end_day - OtherData.Instance:GetOpenServerDays()
		-- local hour = math.floor(left_sec / 3600 )
		-- local minute = math.floor((left_sec - hour * 3600) / 60 )
		-- self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].day = day
		-- self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].hour = hour
		-- self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityLuckyDraw].minute = minute

		local end_day = cfg.openCondition.openDay.endDay
		local diff_day = end_day - OtherData.Instance:GetOpenServerDays()
		if diff_day < 0 then
			return 0
		end
		local end_sec = end_day * 24 * 60 * 60
		local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())

		local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao].time = TimeUtil.Format2TableDHM(diff_day * 24 * 60 * 60 + left_sec)
	end

	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityXunBao] or {}
end

function OpenServiceAcitivityData:GetXunBaoAwardShowData(index)
	local cfg = OpenTreasureHuntingCfg and OpenTreasureHuntingCfg.gradeAwards
	return ItemData.FormatItemData(cfg[index].awards[1])
end

-------------------------------------------------
-- 寻宝 End
-------------------------------------------------

-------------------------------------------------
-- 寻宝榜 Begin
-------------------------------------------------
--第几期寻宝奖励
function OpenServiceAcitivityData:GetState()
	if OpenTreasureHuntingRankCfg then
		for k,v in pairs(OpenTreasureHuntingRankCfg.StageList) do
			local open_day = OtherData.Instance:GetOpenServerDays()
			if v.openDay.sDay <= open_day and v.openDay.eDay >= open_day then
				return k
			end
		end
	end
	return 0
end

function OpenServiceAcitivityData:SetExploreRankInfo(protocol)
	local cfg = OpenTreasureHuntingRankCfg
	local state = self:GetState()
	if nil == cfg then return end
	if 0 == state then return end
	local explore_rank = {}
	explore_rank.is_lingqu = protocol.is_lingqu
	explore_rank.explore_times = protocol.explore_times
	explore_rank.rank_num = protocol.rank_num
	explore_rank.rank_info_list = protocol.rank_info_list or {}
	explore_rank.my_rank_number = protocol.my_rank_number
	
	explore_rank.item_list = {}
	for k, v in pairs(cfg.StageList[state].rankings) do
		explore_rank.item_list[k] = {}
		explore_rank.item_list[k].index = k
		explore_rank.item_list[k].condition = v.condition
		explore_rank.item_list[k].btn_state = 2
		explore_rank.item_list[k].award_list = {}
		for k1, v1 in pairs(v.award) do
			explore_rank.item_list[k].award_list[k1] = ItemData.InitItemDataByCfg(v1)
		end
		if next(explore_rank.rank_info_list) then
			for key, value in pairs(explore_rank.rank_info_list) do
				if tonumber(value.rank_numer) == k then
					explore_rank.item_list[k].rank_info_list = {}
					explore_rank.item_list[k].rank_info_list = value
				end
			end
		end
	end
	if cfg.StageList[state].join_award then
		local num = #cfg.StageList[state].rankings + 1
		explore_rank.item_list[num] = {}
		explore_rank.item_list[num].index = num
		explore_rank.item_list[num].condition = cfg.StageList[state].join_award.condition
		explore_rank.item_list[num].award_list = {}
		for k1, v1 in pairs(cfg.StageList[state].join_award.award) do
			explore_rank.item_list[num].award_list[k1] = ItemData.InitItemDataByCfg(v1)
		end
			if explore_rank.is_lingqu == 0 then
			if explore_rank.explore_times >= cfg.StageList[state].join_award.condition then
				explore_rank.item_list[num].btn_state = 1     --可以领取
			else
				explore_rank.item_list[num].btn_state = 3     --未达到
			end
		else
			explore_rank.item_list[num].btn_state = 4         --已领取
		end
	end

	table.sort(explore_rank.item_list, function(a, b)
			if a.btn_state ~= b.btn_state then
				return a.btn_state < b.btn_state
			else
				return a.index < b.index
			end
		end)
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] = explore_rank
	
	self:DispatchEvent(OpenServiceAcitivityData.ExploreRankChange)
end

function OpenServiceAcitivityData:GetExploreRankInfo()
	self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] =self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] or {}
	local cfg = OpenTreasureHuntingRankCfg
	local state = self:GetState()
	if nil ~= cfg and cfg.StageList[state] then
		local begin_day = cfg.StageList[state].openDay.sDay

		local end_day = cfg.StageList[state].openDay.eDay
		local diff_day = end_day - OtherData.Instance:GetOpenServerDays()
		if diff_day < 0 then
			return 0
		end
		local end_sec = end_day * 24 * 60 * 60
		local server_time = math.ceil(TimeCtrl.Instance:GetServerTime())

		local left_sec = 86400 - ((server_time + 8 * 60 * 60) % 86400)		-- 当天到0点剩余时间
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank].time = TimeUtil.Format2TableDHM(diff_day * 24 * 60 * 60 + left_sec)
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank].activity_time_interval = self:GetActivityTime(begin_day, end_day)
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank].tips = cfg.StageList[state].tips
		self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank].tip_bar = cfg.StageList[state].tip_bar
	end
	return self.info_list[OPEN_SERVER_TAB_INDEX.OpenServiceAcitivityExploreRank] or {}
end

function OpenServiceAcitivityData:SetExploreTimes(protocol)
	self.my_explore_times = protocol.my_explore_times
end

function OpenServiceAcitivityData:GetExploreRemindNum()
	local panel_data = self:GetExploreRankInfo()
	if nil == panel_data then return 0 end
	
	local my_explore_times = self.my_explore_times
	if nil == my_explore_times or my_explore_times == -1 then
		my_explore_times =  panel_data.explore_times
	end
	
	local condition = 0
	for k,v in pairs(panel_data.item_list) do 
		if v.btn_state ~= 2 then
			condition = v.condition
		end
	end
	if panel_data.is_lingqu == 0 and my_explore_times >= condition then
		return 1
	else
		return 0
	end
end
-------------------------------------------------
-- 寻宝榜 End
-------------------------------------------------