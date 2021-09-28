MainUIData = MainUIData or BaseClass()

MainUIData.IsFightState = false

MainUIData.ChatViewState = {
	Short = 0,
	Length = 1,
}

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
	YiZhanDaoDi = 69,
	JinYinTa = 70,
	ZhenBaoGe = 71,
	ZhuanZhuanLe = 72,
	ThreePiece = 73,
	Huan_Zhuang_Shop = 74,
	ShuShan = 75,
	DailyLove = 76, 			--开服活动：每日一爱
	RedName = 77, 				--红名提醒
	TripleGuaji = 78,
	JingHuaHuSong = 79,			--精华护送
	WeddingActivity = 80,
	MountDegree = 81,
	Worship = 82,
	WingDegree = 83,
	HaloDegree = 84,
	FootDegree = 85,
	FightMountDegree = 86,
	ShenGongDegree = 87,
	ShenYiDegree = 88,
	LoopCharge2 = 89,
	Kf_Mining = 90,
	SingleRebate = 91,
	RechargeCapacity = 92,
	SingleCharge2 = 93,
	SingleCharge3 = 94,
	IncreaseCapability = 95,
	DanBiChongZhi = 96,
	SecretrShop = 97,
	YaoShiDegree = 98,
	TouShiDegree = 99,
	QiLinBiDegree = 100,
	Fishing = 101,
	MaskDegree = 102,
	XianBaoDegree = 103,
	LingZhuDegree = 104,
	TianShenGrave = 105,
	WeekBoss = 106,
	OnYuan = 107,
	Clothespress = 108,
	LingChongDegree = 109,
	LingGongDegree = 110,
	LingQiDegree = 111,
	RedEquip = 112,
}

function MainUIData:__init()
	if MainUIData.Instance then
		print_error("[MainUIData]:Attempt to create singleton twice!")
	end
	MainUIData.Instance = self
	self.mainui_icon_list = {}
	self.jinghuahusong_num = 0
end

function MainUIData:__delete()
	MainUIData.Instance = nil
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

function MainUIData:SetChatViewState(state)
	self.chat_view_state = state
end

function MainUIData:GetChatViewState()
	return self.chat_view_state or MainUIData.ChatViewState.Short
end

function MainUIData:SendJingHuaHuSongNum(num)
	self.jinghuahusong_num = num or 0
end

function MainUIData:GetJingHuaHuSongNum()
	return self.jinghuahusong_num
end