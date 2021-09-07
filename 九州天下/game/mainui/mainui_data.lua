MainUIData = MainUIData or BaseClass()

MainUIData.IsFightState = false

MainUIData.RemindingName = {
	Player = 1,
	Baoju = 2,
	Forge = 3,
	Advance = 4,
	Goddress = 5,
	Guild = 6,
	Scoiety = 7,
	Marriage = 8,
	Rank = 9,
	Compose = 10,
	Market = 11,
	Spirit = 12,
	FuBenMulti = 13,
	FuBenSingle = 14,
	BattleField = 15,
	ActivityHall = 16,
	TreasureHunt = 17,
	NewServer = 18,
	Welfare = 19,
	Echange = 20,
	Shop = 21,
	Setting = 22,
	Church = 23,
	Auto = 24,
	Package = 25,
	Deposit = 26,
	Vip = 27,
	XiuLuoTower = 28,
	TreasureBowl = 29,
	TombExplore = 30,
	CityCombat = 31,
	Daily_Charge = 32,
	Invest = 33,
	Rebate = 34,
	HuanJing_XunBao = 35,
	Seven_Login_Redpt = 36,
	Show_Seven_Login = 37,
	First_Charge = 38,
	Cross_Hot_Spring = 39,
	Big_Rich = 40,
	Question = 41,
	Double_Escort = 42,
	Cross_One_Vs_One = 43,
	Clash_Territory = 44,
	Guild_Battle = 45,
	Fall_Money = 46,
	Element_Battle = 47,
	Boss = 48,
	Collection_Redpt = 49,
	Show_Collection = 50,
	Show_Reincarnation = 51,
	Reincarnation_Redpt = 52,
	GuildMijing = 53,
	GuildBonfire = 54,
	GuildBoss = 55,
	Pet = 56,
	MagicWeapon = 57,
	CrossCrystal = 58,
	show_invest_icon = 59,
	MarryMe = 60,
	ExpRefine = 61,
	MolongMibao = 62,
	ActHongBao = 63,
	Show_Leiji_ChongZhi = 64,
	BiPin = 65,
	Boss_View = 66,
	Member_repdt = 67,
	ZeroGift = 68,
	BanZhuan = 69,
	Fishing = 70,
	ShowCounTranBtn = 71,
	ShowFamilyTranBtn = 72,
	ShowTeamTranBtn = 73,
	GeneralChou = 74,
	GuildBattle_Worship = 75,
	Kf_Mining = 76,
	DaChen = 77,
	GuoQi = 78,
	MiningFight = 79,
	WorldBoss = 80,
	RedEquip = 81,
	ZhuanZhuanLe = 82,
	DiMai = 83,
	MonsterSiege = 84,
	WeddingActivity = 85,
	HuanZhuangShopActivity = 86,
	ChujunGift = 87,
	SecretrShop = 88,
	LuckyTurntable = 89,
	ShenJiSkill = 90,
	GodDropGift = 91,
	DressShop = 92,
	QixiActivity = 93,
	AdventureShop = 94,
	RareTreasure = 95,
	MidAutumnAct = 96,
	ShowDailyCharge = 97,
	ThanksFeedBack = 98,
	ActRebateFoot = 99,
	ActRebateTouShi = 100,
	ActRebateYaoShi = 101,
	ActRebateMask = 102,
	ActRebateQiLingBi = 103,
	ActRebateLingBao = 104,
	ActRebateXianbao = 105,
}

function MainUIData:__init()
	self.mainui_icon_list = {}
	self.forecast_act_list = {}
	self.on_open_activity_list = {}
	self.open_activity_num = 0

	MainUIData.Instance = self
	self.activity_config = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto").show_cfg	
end

function MainUIData:__delete()

end

function MainUIData.IsInDabaoScene()
	local scene_id = Scene.Instance:GetSceneId()
	return 9000 <= scene_id and scene_id <= 9009
end

function MainUIData.IsInBossHomeScene()
	local scene_id = Scene.Instance:GetSceneId()
	return 300 <= scene_id and scene_id <= 309
end

-- 阵营普通夺宝
function MainUIData.IsInCampDuobaoScene()
	local scene_id = Scene.Instance:GetSceneId()
	local nor_boss_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").normalduobao
	for k,v in pairs(nor_boss_cfg) do
		if scene_id == v.sceneid then
			return true
		end
	end
	return false
end

-- 阵营雕像场景
function MainUIData.IsInCampStatueoScene(scene_id)
	scene_id = scene_id or Scene.Instance:GetSceneId()
	local camp_other_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
	for i = 1, 3 do
		if scene_id == camp_other_cfg["dx_sceneid" .. i] then
			return true
		end
	end
	return false
end

--BOSS洞窟
function MainUIData:IsInBossCave()
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id >= 130 and scene_id <= 139 then
		return true
	end
	return false
end

function MainUIData:ChangeMainUiChatIconList(model_name, flush_name, state)
	local model_list = self.mainui_icon_list[model_name]
	if model_list then
		if not state then
			model_list[flush_name] = nil
		else
			model_list[flush_name] = 1
		end
	else
		if state then
			self.mainui_icon_list[model_name] = {}
			self.mainui_icon_list[model_name][flush_name] = 1
		end
	end
end

function MainUIData:GetMainUiIconList()
	return self.mainui_icon_list
end

function MainUIData:OpenActivityTime()	
	local info_list = self:GetOpenActivityTime()
	local cur_time = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(info_list) do
		if v.activity_type ~= 0 and v.act_begin_time <= cur_time and v.act_end_time > cur_time then
			local activity_info = ActivityData.Instance:GetActivityForecast(v.activity_type)
			return v, activity_info.act_name
		end
		if v.act_begin_cd ~= 0 then	
			local activity_info = ActivityData.Instance:GetActivityForecast(v.activity_type)				
			return v, activity_info.act_name
		end
	end
	return nil, ""
end

function MainUIData:SetOpenActivityTime(protocol)
	self.forecast_act_list = {}
	self.forecast_act_list = protocol.forecast_act_list
	self:SetOnOpenActivityList()
end

function MainUIData:SetOnOpenActivityList()
	self.on_open_activity_list = {}
	local cur_time = TimeCtrl.Instance:GetServerTime()
	self.open_activity_num = 0
	for k, v in pairs(self.forecast_act_list) do
		if v.activity_type ~= 0 and v.act_begin_time <= cur_time and v.act_end_time > cur_time then
			self.open_activity_num = self.open_activity_num + 1
			self.on_open_activity_list[self.open_activity_num] = v
		end
	end
end

function MainUIData:GetOnOpenActivityList()
	return self.on_open_activity_list, self.open_activity_num
end

function MainUIData:GetOpenActivityTime()
	return self.forecast_act_list
end

function MainUIData:GetActivityList()
	local activity_list = {}
	for k, v in pairs(self.forecast_act_list) do
		if v.activity_type ~= 0 then
			table.insert(activity_list, v)
		end
	end

	return activity_list
end