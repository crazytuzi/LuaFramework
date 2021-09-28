require "Core.Manager.Item.BackpackDataManager";
require "Core.Manager.Item.MoneyDataManager";
require "Core.Manager.Item.EquipDataManager";
require "Core.Manager.Item.EquipLvDataManager";
require "Core.manager.Item.GuildDataManager";
require "Core.Manager.Item.PetManager";
require "Core.Manager.Item.InstanceDataManager";
require "Core.Manager.Item.TaskManager";
require "Core.Manager.Item.SkillManager";
require "Core.Manager.Item.MailManager";
require "Core.Manager.Item.SystemManager";
require "Core.Manager.Item.RideManager";
require "Core.Manager.Item.WingManager";
require "Core.Manager.Item.PVPManager";
require "Core.Manager.Item.ShopDataManager";
require "Core.Manager.Item.AutoFightManager"
require "Core.Manager.Item.ProductManager"
require "Core.Manager.Item.VIPManager"
require "Core.Manager.Item.MouldingDataManager"
--require "Core.Manager.Item.TrumpManager"
require "Core.Manager.Item.StarManager"
require "Core.Manager.Item.LotteryManager"
require "Core.Manager.Item.SeedBagDataManager"
require "Core.Manager.Item.LingYaoDataManager"
require "Core.Manager.Item.AchievementManager"
require "Core.Manager.Item.TitleManager"
require "Core.Manager.Item.NewTrumpManager"
require "Core.Manager.Item.MallManager"
require "Core.Manager.Item.SaleManager"
require "Core.Manager.Item.RealmManager"
require "Core.Manager.FightPowerManager"
require "Core.Manager.Item.SignInManager"
require "Core.Manager.Item.MountManager"
require "Core.Manager.Item.GuideManager"
require "Core.Manager.Item.NewEquipStrongManager"
require "Core.Manager.Item.WildBossManager"
require "Core.Manager.Item.TimeLimitActManager"
require "Core.Manager.Item.FormationManager"
require "Core.Manager.Item.FestivalMgr"

require "Core.Manager.Item.NewestNoticeManager"
require "Core.Manager.Item.SceneEntityMgr"


require "Core.Manager.Item.ActivityDataManager"
require "Core.Manager.Item.ActivityGiftsDataManager"
require "Core.Manager.Item.Login7RewardManager"

require "Core.Manager.KaiFuManager"
require "Core.Manager.Item.CloudPurchaseManager"
require "Core.Manager.Item.CashGiftsManager"




require "Core.Module.Backpack.data.BackPackCDData"
require "Core.Module.Backpack.data.BackPackBoxLockCDCtr"

require "Core.Role.Controller.HeroController";
require "Core.Info.BaseAttrInfo";

require "Core.Manager.ConfigCheck";

local json = require "cjson"
--  角色信息管理
PlayerManager = {};
PlayerManager._token = nil;
PlayerManager._userName = nil
PlayerManager.playerId = nil;
PlayerManager.power = 0;
-- PlayerManager._playInfo = PlayerInfo:New();
PlayerManager._allPlayerData = {}
PlayerManager.SelfExpChange = "SelfExpChange"
PlayerManager.SelfLevelChange = "SelfLevelChange"
PlayerManager.OtherLevelChange = "OtherLevelChange"
PlayerManager.SelfHpChange = "SelfHpChange"
PlayerManager.SelfMpChange = "SelfMpChange"
PlayerManager.SelfDressChange = "PlayerManager.SelfDressChange"
PlayerManager.SelfSkillChange = "SelfSkillChange"
PlayerManager.SELFMOVEEND = "SelfMoveEnd"
PlayerManager.CHANGEPETMODEL = "CHANGEPETMODEL"
PlayerManager.RELIVETIMELIMIT = 15  -- 复活倒计时
PlayerManager.RELIEVEITEMID = 500010  -- 复活丹ID
PlayerManager.RELIEVEITEMCOUNT = 1  -- 复活丹ID

PlayerManager.SELFATTRIBUTECHANGE = "SELFATTRIBUTECHANGE";           -- 属性变化
PlayerManager.SELFATTRIBUTEADD = "SELFATTRIBUTEADD";          -- 属性变化

PlayerManager.SELFFIGHTCHANGE = "SELFFIGHTCHANGE";                   -- 战斗力变化
PlayerManager.StartAutoFight = "StartAutoFight"
PlayerManager.StopAutoFight = "StopAutoFight"
PlayerManager.StartAutoKill = "StartAutoKill"
PlayerManager.StopAutoKill = "StopAutoKill"
PlayerManager.StartAutoRoad = "StartAutoRoad"
PlayerManager.StopAutoRoad = "StopAutoRoad"

PlayerManager.PKDataChange = "PKDataChange"

PlayerManager.OhterInfoChg = "OtherInfoChg";         -- 0x0102 其他信息改变.
PlayerManager.OffLineChg = "OffLineChg";            -- 0x1114 离线时间改变

PlayerManager.CareerType =  -- 角色职业类型
{
	tqm = 101000, tyg = 102000, mxz = 103000, tgz = 104000,
}

PlayerManager.OffLineData = {};
local _careerConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER)

--[[输入：
token：中心服返回的token

输出：
un：username
pl：[{id,name,kind,sex,level,df:0正常 1删除中,dt:删除剩余秒数},...]，空表示还没有创建角色

]]
PlayerManager.OtherInfo = {}
PlayerManager._lastPlayerIndex = 1

local careerExpConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER_EXP)
local heroKind = nil
local canShowFight = false
local createRoleTime = 0;

-- 所有角色数据
function PlayerManager.SetPlayerInfo(playerData)
	if(playerData.un) then
		PlayerManager._userName = playerData.un
	end
	if(playerData.pl) then
		PlayerManager._allPlayerData = playerData.pl
	end
	
	if(playerData and playerData.pi and(playerData.pi ~= "")) then
		PlayerManager.SetLastPlayerIndex(playerData.pi)
	end
end

function PlayerManager.GetLastPlayerIndex()
	return PlayerManager._lastPlayerIndex
end

local insert = table.insert

function PlayerManager.AddPlayerData(data)
	insert(PlayerManager._allPlayerData, data)
end

function PlayerManager.SetLastPlayerIndex(pId)
	for k, v in ipairs(PlayerManager._allPlayerData) do
		if(v.id == pId) then
			PlayerManager._lastPlayerIndex = k
			break
		end
	end
	
end



-- 一般在 0x0105 返回的数据
function PlayerManager.SetCurPlayerData(data)
	if(data and data.errCode == nil) then
		canShowFight = false
		AppConst.UserId = data.id		
		PlayerManager.spend = 0;
		PlayerManager.vp = 0;
		PlayerManager.bscore = 0;
		PlayerManager.tscapital = 0;		
		-- 发布的时候可以移除， 只是配置关联检查
		-- ConfigCheck.StartCheck()
		PartData.SetMyTeam(nil);
		OnlineRewardManager.ReSet()
		-- PlayerManager._playInfo:Init(data);
		PlayerManager.curPlayerData = data
		heroKind = data.kind
		PlayerManager.playerId = data.id
		createRoleTime = data.ct
		MsgUtils.ResetIgnore();
		FightPowerManager.Init()
		FightPowerManager.SetMyCareer(data.kind)
		MoneyDataManager.Init(data.money);
		PVPManager.Init()
		BackpackDataManager.Init(data.bag, data.bsize);
		EquipDataManager.Init(data.equip);
		EquipDataManager.InitExiEq(data.ext_equip);
		SeedBagDataManager.Init(data.farm_bag);
		EquipLvDataManager.Init(data.equip_lv);
		EquipLvDataManager.Set_ext_equip_lv(data.ext_equip_lv)
		NewEquipStrongManager.Init(data.equip_lv, data.plus_id)
		GemDataManager.Init(data.equip_lv);
		-- local testpet = {lev = 1,exp =10,star = 1,adv_exp =1,use_id = 115001}
		-- -- PetManager.Init(data.pet);
		PetManager.Init(data.pet);
		
		-- SkillManager.InitTalent(data.talent);
		WingManager.Init(data.wing, data.kind);
		InstanceDataManager.UpData(nil, nil);
		RideManager.Init(data.ride, data.ride_feed)
		AchievementManager.Init()
		RechargRewardDataManager.Init()
		TitleManager.Init()
		NewTrumpManager.Init()
		MallManager:Init()
		BackPackBoxLockCDCtr.Set_bcd(data.bcd);
		LingYaoDataManager.Init(data.elixir)
		SaleManager.Init()
		SaleManager.SetSaleMoney(data.sales)
		SignInManager.Init()
		ShopDataManager.Init();
		AutoFightManager.Init();
		VIPManager.Init(data.vip)
		MouldingDataManager.Init()
		WildBossManager.Init(data.id)	
		YaoShouManager.Init();
		--TrumpManager.Init(data)
		StarManager.SetData(data)
		TitleManager.SetTitleData(data.titles)
		TitleManager.SetCurrentEquipTitleId(data.title)
		RealmManager.Init(data.realm)
		MountManager.Init(data.mount)
		LotteryManager.Init()
		ChatManager.Init()
		ComposeManager.Init()
		AppSplitDownProxy.Init()
		KaiFuManager.SetKaiFunData(data.ot)
		TimeLimitActManager.Init();
		NewestNoticeManager.Init()
		CloudPurchaseManager.Init()
		CashGiftsManager.Init()

		if(PlayerManager.hero and PlayerManager.hero.id ~= data.id) then
			PlayerManager.DisposeHero()
		end
		
		if(PlayerManager.hero == nil) then
			PlayerManager.hero = HeroController:New(data);			
		else
			PlayerManager.hero:ResetData(data)
		end
		
		
		NewTrumpManager.SetSelfTrumpData(PlayerManager.hero.info.new_trump)
		NewTrumpManager.SetAllNewTrumpData(data.ntrump)
		NewTrumpManager.SetMobaoData(data.mobao)
		FormationManager.SetData(data.gm)
		PlayerManager.StartListener();
		PlayerManager.CalculatePlayerAttribute();
		
		SequenceManager.StopAll();
		TriggerManager.Clear();
		TodoManager.Clear();
		TaskManager.Init();
		SystemManager.Init();
		
		ActivityDataManager.ReInit()
		ActivityGiftsDataManager.Init();
		Login7RewardManager.ReInit()
		
		-- GuildNotes.ENV_GUILD_CHG 已经发了， 所以不需要在这里请求数据
		-- FriendProxy.TryGetTeamFBData();
		-- 获取 套装等级
		EquipProxy.TrySQGetSuitLvData();
		SignInProxy.GetLogin7AwardInfos();
		
		
		GuideManager.Init(data.tutor);		
		
		DaysRankManager.Init();
		
		ActivityProxy.TryGetActivityData();
		
		ActivityGiftsProxy.GetYueKaInfos();
		ActivityGiftsProxy.GetRechageAwardLog();
		SceneEntityMgr.InitStatic()
		InstanceFbItem.currInFbData = nil;
		--初始化结束后再显示战斗力
		canShowFight = true
	end
end

function PlayerManager.StartListener()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ProductChange, PlayerManager.ProductChange);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ExpOrLevelChange, PlayerManager.ExpOrLevelChange);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.MPChange, PlayerManager.SelfMpChange);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Get_MinorData, PlayerManager.MinorDataInHandler);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SelfPVPRankChange, PlayerManager.SelfPVPRankChangeHandler);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.OtherInfoChange, PlayerManager.OtherInfoChangeHandler);	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.OtRec, PlayerManager.OtRecHandler);	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SkillCdChange, PlayerManager.SkillCdChange);	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Daily_Num_Chg, PlayerManager.OnDailyNumChg);	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangePkData, PlayerManager._ChangePkData)	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangePkData, PlayerManager._ChangePkData)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.OffLineChg, PlayerManager._OffLineChg)	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.WorldLevel, PlayerManager._WorldLevel)	
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UnLockSkill, PlayerManager._UnLockSkill)	
	
	MessageManager.AddListener(BackpackProxy, BackpackProxy.MESSAGE_UNLOCK_BOX_NUM_CHANGE, PlayerManager.OnUnlockBagBox);	
	
end

function PlayerManager.RemoveListener()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ProductChange, PlayerManager.ProductChange);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ExpOrLevelChange, PlayerManager.ExpOrLevelChange);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.MPChange, PlayerManager.SelfMpChange);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Get_MinorData, PlayerManager.MinorDataInHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SelfPVPRankChange, PlayerManager.SelfPVPRankChangeHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.OtherInfoChange, PlayerManager.OtherInfoChangeHandler);
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.OtRec, PlayerManager.OtRecHandler);	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SkillCdChange, PlayerManager.SkillCdChange);	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Daily_Num_Chg, PlayerManager.OnDailyNumChg);	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChangePkData, PlayerManager._ChangePkData)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.OffLineChg, PlayerManager._OffLineChg)	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.WorldLevel, PlayerManager._WorldLevel)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UnLockSkill, PlayerManager._UnLockSkill)	
	
	MessageManager.RemoveListener(BackpackProxy, BackpackProxy.MESSAGE_UNLOCK_BOX_NUM_CHANGE, PlayerManager.OnUnlockBagBox);
	
end

function PlayerManager.OnUnlockBagBox()
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Bag)
end

function PlayerManager._WorldLevel(cmd, data)	
	if(data and data.errCode == nil) then
		PlayerManager.curPlayerData.wlev = data.wlev
	end	
end

function PlayerManager._UnLockSkill(cmd, data)	
	if(data and data.errCode == nil) then
		ItemMoveManager.Check(ItemMoveManager.interface_ids.getNewSkillAndMoveToBt, data)
	end	
end


function PlayerManager.OtRecHandler(cmd, data)
	
	if(data and data.errCode == nil) then
		KaiFuManager.SetKaiFunData(data.ot);
		TimeLimitActManager.Init(data.ot);
	end
	
end

function PlayerManager.SkillCdChange(cmd, data)
	if(PlayerManager.hero and data and data.errCode == nil) then
		local info = PlayerManager.hero.info;
		for i, v in pairs(data.l) do
			local sk = info:GetSkill(v.skid);
			if(sk) then sk:SetCurrCoolTime(v.rcd) end
		end
	end
end

function PlayerManager.OtherInfoChangeHandler(cmd, data)
	if(data and data.errCode == nil) then
		if(PlayerManager.OtherInfo == nil) then
			PlayerManager.OtherInfo = {}
		end
		PVPManager.UpdatePVPPoint(data.ascore)
		--TrumpManager.UpdateTrumpCoin(data.trump_coin
		StarManager.SetDebris(data)
		if(data.vp) then
			PlayerManager.vp = data.vp
			MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_ZHENQI_CHANGE);
		end
		if(data.spend) then
			PlayerManager.spend = data.spend
			MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_XIUWEI_CHANGE);
		end
		if(data.bscore) then
			PlayerManager.bscore = data.bscore
		end
		
		if data.tscapital then
			PlayerManager.tscapital = data.tscapital;
			MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE);
		end
		
		MessageManager.Dispatch(PlayerManager, PlayerManager.OhterInfoChg);
	end
end

function PlayerManager.SelfPVPRankChangeHandler(cmd, data)
	if(data and data.errCode == nil) then
		PVPManager.UpdatePVPRank(data.r)
	end
end

-- 次要数据协议返回处理
function PlayerManager.MinorDataInHandler(cmd, data)
	if(data.errCode == nil) then
		VIPManager.SetFirstChargeRecorder(data.rl)
		PVPManager.UpdatePVPRank(data.r)
		PVPManager.UpdatePVPPoint(data.as)
		PVPManager.SetPVPBuyTime(data.bt)
		PVPManager.SetOldPVPRank()
		BackPackCDData.Init(data.item_cds);
		BackPackBoxLockCDCtr.TryInit()
		LotteryManager.SetCdTime(data.locd)
		--		if(data.trump_area) then
		--			TrumpManager.SetCollectAreaData(data.trump_area.l)
		--			TrumpManager.SetNextQc(data.trump_area.qc)
		--			TrumpManager.SetQcList(data.trump_area.qcl)
		--		end
		--		TrumpManager.UpdateTrumpCoin(data.trump_coin)
		StarManager.SetDebris(data)
		
		if(data.achieve) then
			AchievementManager.SetAchievementData(data.achieve)
		end
		
		if(data.vp) then
			PlayerManager.vp = data.vp;
			MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE);
		end
		if(data.spend) then
			PlayerManager.spend = data.spend
			MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_XIUWEI_CHANGE);
		end
		if(data.bscore) then
			PlayerManager.bscore = data.bscore
		end
		
		if data.tscapital then
			PlayerManager.tscapital = data.tscapital;
			MessageManager.Dispatch(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE);
		end
		
		--防止断线重连的时候还存在复活面板
		ModuleManager.SendNotification(MainUINotes.CLOSE_RELIVEPANEL)
		--        if (HeroController:GetInstance().info.hp == 0) then
		--            local reliveConfig = ConfigManager.GetReliveConfig(GameSceneManager.map.info.relive_type) 
		--            ModuleManager.SendNotification(MainUINotes.OPEN_RELIVEPANEL, { data.death, reliveConfig })
		--        end
		GuildDataManager.Init(data.tong.t, data.tong.tm);
		GuildDataManager.Set_tfec(data.tfec)
		GuildProxy.ReqGetGuildHongBaoData();--红包数据请求要在仙盟管理器初始化之后
		-- ZongMenLiLianProxy.GetZongMenLiLianPreInfo()
		MailManager.SetRedPoint(data.letter == 1);
		SystemManager.tong_ap = data.tong_ap == 1 -- 1 有申请入会代审批，0 无
		
		PlayerManager.UpdateOffLineData(data);
		LotProxy.SetLotInfo(data.eqt) --仙缘次数
		LotProxy.SetLotMoneyInfo(data.mqt) --仙缘铜钱次数
		
		DaysRankProxy.SetAward(data.rg);
		DaysTargetProxy.SetNotify(data);
		XuanBaoManager.SetNotify({f = data.treasure or 0});
		if(NoviceManager.oldLevel ~= nil) then
			PlayerManager.SubmitExtraData(3, {roleLevel = NoviceManager.oldLevel, power = PlayerManager.GetMyDefaultPower()})
		else
			PlayerManager.SubmitExtraData(3, {roleLevel = PlayerManager.GetPlayerLevel()})
		end
		
		 
		RechargeAwardProxy.SetData(data.yyl)
		local flg = data.tips and data.tips.ra or false
		SignInManager.SetCanRevertAward(flg and flg ~= 0)
		FestivalMgr.SetData(data.festival);
		
		if GameConfig.instance.autoOpen then
			ModuleManager.SendNotification(GameConfig.instance.autoOpen)
		end

        if SystemManager.IsOpen(SystemConst.Id.MidAutumn) then --中秋节
            SocketClientLua.Get_ins():SendMessage(CmdType.YYGetActvityInfo)
        end

	end
end

--初始化离线数据
function PlayerManager.UpdateOffLineData(data)
	PlayerManager.OffLineData.exp = data.off_exp;
	PlayerManager.OffLineData.lv = data.off_lev;
	PlayerManager.OffLineData.lv2 = data.off_new_lev
	PlayerManager.OffLineData.time = data.off_rm;
	PlayerManager.OffLineData.offTime = data.off_m;
	PlayerManager.OffLineData.offAddExp = data.off_p_exp;
	
	if SystemManager.IsOpen(SystemConst.Id.OffLineExp) then
		ModuleManager.SendNotification(MessageNotes.SHOW_OFFLINE_PANEL);
		
		if GuideManager.GetGuideSt(GuideManager.Id.GuideOfflineTips) < 2 then
			GuideManager.ManualGuide(GuideManager.Id.GuideOfflineTips, true);
		end
	end
	
end

--剩余离线时间变化
function PlayerManager._OffLineChg(cmd, data)
	PlayerManager.OffLineData.time = data.off_rm;
	MessageManager.Dispatch(PlayerManager, PlayerManager.OffLineChg)
end

function PlayerManager.SelfMpChange(cmd, data)
	if(data and data.mp) then
		if(PlayerManager.hero) then
			PlayerManager.hero:GetInfo().mp = data.mp;
			MessageManager.Dispatch(PlayerManager, PlayerManager.SelfMpChange, data.mp)
		end
	end
end

--[[01 经验等级通知（服务器发出）
输出：
id:playerId
exp
cexp:经验改变值
f:来源 ( 0：其他 1：杀怪)
[level]
]]
function PlayerManager.ExpOrLevelChange(cmd, data)
	
	if(data.id ~= PlayerManager.hero.id) then
		if(data.level ~= nil) then
			MessageManager.Dispatch(PlayerManager, PlayerManager.OtherLevelChange, data.id, data.level)
		end
		return
	end
	
	if data.level ~= nil then
		
		local hero = PlayerManager.hero;
		
		local oldLevel = hero.info.level;
		
		hero.info:SetLevel(data.level)
		PlayerManager.CalculatePlayerAttribute()
		--hero:CalculateAttribute();
		hero:LoadLevelUpEffect();
		
		-- 如果有队伍的话， 需要修改自己的等级
		local info = HeroController.GetInstance().info;
		
		local my_id = info.id + 0;
		PartData.SetTeamPlLv(my_id, data.level);
		
 
		
		MessageManager.Dispatch(PlayerManager, PlayerManager.SelfLevelChange)
		UISoundManager.PlayUISound(UISoundManager.ui_role_upgrade)
		PlayerManager.SubmitExtraData(4)
		SystemManager.Check(SystemConst.OpenType.LEVEL, data.level);
		GuideManager.Check(GuideManager.Type.LEVEL, data.level);
		SkillManager.CheckSkillByLevel(oldLevel);
	end
	
	PlayerManager.hero.info:SetExp(data.exp)
	MessageManager.Dispatch(PlayerManager, PlayerManager.SelfExpChange, data.exp, data.cexp, data.f)
end

function PlayerManager.ProductChange(cmd, data)
	SeedBagDataManager.CheckProductChange(data)
	if(data.m) then
		if(data.m[1] and data.m[1].st ~= ProductManager.ST_TYPE_IN_BACKPACK and data.m[1].st ~= ProductManager.ST_TYPE_IN_EQUIPBAG and data.m[1].st ~= ProductManager.ST_TYPE_IN_EXT_EQUIP) then
			return
		end
	end
	
	if(data.u) then
		if(data.u[1] and data.u[1].st ~= ProductManager.ST_TYPE_IN_BACKPACK and data.u[1].st ~= ProductManager.ST_TYPE_IN_EQUIPBAG and data.u[1].st ~= ProductManager.ST_TYPE_IN_EXT_EQUIP) then
			return
		end
	end
	
	if(data.a) then
		if(data.a[1] and data.a[1].st ~= ProductManager.ST_TYPE_IN_BACKPACK and data.a[1].st ~= ProductManager.ST_TYPE_IN_EQUIPBAG and data.a[1].st ~= ProductManager.ST_TYPE_IN_EXT_EQUIP) then
			return
		end
	end
	
	
	local m = data.m;
	if m ~= nil then
		PlayerManager.MoveProduct(m);
	end
	GemDataManager.CheckBagChg(data);
	BackpackDataManager.ProductChange(data);
	
end

-- 物品移动 需要在这里处理
-- {"m":[{"st":1,"pt":"10100103","id":"10142","idx":0},{"st":2,"pt":"10100103","id":"0","idx":0}]}
function PlayerManager.MoveProduct(arr)
	
	local old_obj1;
	local old_obj2;
	
	local extEqCt = EquipDataManager.GetExtEqContainer();
	local quct = EquipDataManager.GetContainer();
	
	if arr[1].st == ProductManager.ST_TYPE_IN_BACKPACK and arr[2].st == ProductManager.ST_TYPE_IN_EQUIPBAG then
		
		old_obj1 = arr[1];
		old_obj2 = arr[2];
		
		BackpackDataManager:Replace(quct, old_obj2, old_obj1);
	elseif arr[2].st == ProductManager.ST_TYPE_IN_BACKPACK and arr[1].st == ProductManager.ST_TYPE_IN_EQUIPBAG then
		old_obj1 = arr[2];
		old_obj2 = arr[1];
		
		BackpackDataManager:Replace(quct, old_obj2, old_obj1);
		
	elseif arr[1].st == ProductManager.ST_TYPE_IN_BACKPACK and arr[2].st == ProductManager.ST_TYPE_IN_EXT_EQUIP then
		
		old_obj1 = arr[1];
		old_obj2 = arr[2];
		
		BackpackDataManager:Replace(extEqCt, old_obj2, old_obj1);
	elseif arr[2].st == ProductManager.ST_TYPE_IN_BACKPACK and arr[1].st == ProductManager.ST_TYPE_IN_EXT_EQUIP then
		old_obj1 = arr[2];
		old_obj2 = arr[1];
		
		BackpackDataManager:Replace(extEqCt, old_obj2, old_obj1);
	end
	
	
	
	
	PlayerManager.CalculatePlayerAttribute()
	BackpackDataManager.DispatchEvent();
	EquipDataManager.DispatchEvent();
	EquipDataManager.DispatchExtEquipEvent()
end


function PlayerManager.GetPlayerLevel()
	return PlayerManager.hero and PlayerManager.hero.info.level or 0
end

function PlayerManager.GetPlayerInfo()
	return PlayerManager.hero and PlayerManager.hero.info or nil
end
--返回我的英雄职业
function PlayerManager.GetPlayerKind()
	return heroKind
end
function PlayerManager.GetWorldLevel()
	return PlayerManager.curPlayerData and PlayerManager.curPlayerData.wlev or 0
end

local tempAttr = BaseAttrInfo:New();
-- 计算角色属性
function PlayerManager.CalculatePlayerAttribute(calculateType, notShow)
	
	local lastPower = PlayerManager.power;
	
	if(PlayerManager.hero) then
		if not notShow then
			tempAttr:Reset()
			tempAttr:Init(PlayerManager.hero.info)
		end
		PlayerManager.hero:CalculateAttribute(calculateType);
	end
	
	MessageManager.Dispatch(PlayerManager, PlayerManager.SELFFIGHTCHANGE, {d = lastPower, notShow = notShow, change = PlayerManager.power - lastPower});
	
	if not notShow then
		MessageManager.Dispatch(PlayerManager, PlayerManager.SELFATTRIBUTEADD, tempAttr);
	end
end

-- 帐号中所有玩家的数据
function PlayerManager.GetAllPlayerData()
	return PlayerManager._allPlayerData
end

function PlayerManager.SetMyToken(token)
	PlayerManager._token = token;
end

function PlayerManager.GetMyToken()
	return PlayerManager._token;
end

function PlayerManager.GetSelfFightPower()
	return PlayerManager.power;
end
--主角物防
function PlayerManager.GetSelfPhyDef()
	local h = PlayerManager.hero
	return h and h.info.phy_def or 0
end
-- --主角法防
-- function PlayerManager.GetSelfMagDef()
-- 	local h = PlayerManager.hero
-- 	return h and h.info.mag_def or 0
-- end
-- 1物系 , 2法系
function PlayerManager.GetMyCareerDmgType()
	local cfg = _careerConfig[PlayerManager.GetPlayerKind()];
	return cfg.dmg_type;
end

function PlayerManager.GetMyDefaultPower()
	local cfg = _careerConfig[PlayerManager.GetPlayerKind()];
	return cfg and cfg.init_power or 9
end

function PlayerManager.GetCareerIcon(kind)
	local data = _careerConfig[kind]
	if(data) then
		return data.icon_id
	else
		log("传入的ID错误")
		return ""
	end
end

function PlayerManager.GetCareerById(id)
	return _careerConfig[id]
end

function PlayerManager.DisposeHero()
	
	if PlayerManager.hero then
		PlayerManager.hero:Dispose()
		PlayerManager.hero = nil;
	end
end

function PlayerManager.SubmitExtraData(t, extraData)
	
	local data = {}
	local server = LoginManager.GetCurrentServer()
	if(server) then
		data.serverID = server.id
		data.serverName = server.name
	end
	local playerData = PlayerManager.curPlayerData
	if(playerData) then
		data.roleID = playerData.id
		data.roleName = playerData.name
		if(PlayerManager.hero) then
			data.roleLevel = PlayerManager.hero.info.level
		else
			data.roleLevel = playerData.level
		end
		
		data.createRoleTime = playerData.ct
		data.vip = VIPManager.GetSelfVIPLevel()
		data.moneyNum = MoneyDataManager.Get_money()
	end
	
	local friend = FriendDataManager.GetAllRelationList()
	data.friends = friend
	data.power = PlayerManager.power
	
	if(PlayerManager.hero and PlayerManager.hero.info) then
		local info = PlayerManager.hero.info
		data.career = info.kind
		data.careerId = info.kind
		data.careerName = info.career
		data.sex =(info.sex == 0) and "男" or "女"
		
		data.guildName = GuildDataManager.GetMyGuildName()
		local guildRoleId = GuildDataManager.GetMyIdentity()
		if(guildRoleId ~= - 1) then
			data.guildRoleId = guildRoleId
			data.guildRoleName = GuildDataManager.GetIdentityName(guildRoleId)
		end		
	end
	
	if(extraData) then
		for k, v in pairs(extraData) do
			data[k] = v
		end
	end
	
	local str = json.encode(data)
	
	
	SDKHelper.instance:SubmitExtraData(str, t)
end

function PlayerManager.ChangePlayer()
	
	TaskManager.Dispose();
	SystemManager.Clear();
	TimeLimitActManager.Clear();
	
	BackPackBoxLockCDCtr.StopTimer()
	PanelManager.RemoveAllPanel()
	PlayerManager.DisposeHero()
	PlayerManager.RemoveListener()
	local func = function()
		ModuleManager.SendNotification(SelectRoleNotes.OPEN_SELECTROLE_PANEL)
	end;
	GameSceneManager.SetMap(700001, func);
	
	ChatManager.Clear()
end

function PlayerManager.OnDailyNumChg(cmd, data)
	if data.vip_daily_gift ~= nil then
		VIPManager.OnNewDailyAward();
	end
	
	if data.dit ~= nil then
		GuildDataManager.Set_donateItem(data.dit);
	end
	
	if data.dgt ~= nil then
		GuildDataManager.Set_donateMoney(data.dgt);
	end
	
	if data.rg ~= nil then
		DaysRankProxy.SetAward(data.rg);
	end
	
	GuildDataManager.Set_tfec(0);
	FestivalMgr.AddLoginDay()
end

function PlayerManager._ChangePkData(cmd, data)
	if(data and data.errCode == nil) then
		local map = GameSceneManager.map;
		local tRole;
		if(map) then
			tRole = map:GetRoleById(data.pid);
		else
			if data.pid == PlayerManager.hero.id then
				tRole = PlayerManager.hero
			end
		end
		if(tRole and tRole.info) then
			tRole.info.pkType = data.pk.m
			tRole.info.pkState = data.pk.st;
			if(tRole == PlayerManager.hero) then
				MessageManager.Dispatch(PlayerManager, PlayerManager.PKDataChange);
			end
		end
	end
end

local gapConfigs
function PlayerManager._GetExpAddValue(gapLev)
	if not PlayerManager.CanExpAdd() then return 0 end
	if not gapConfigs then gapConfigs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EXP_ADD) end
	local c = gapConfigs[gapLev]
	return c and c.value - 100 or 0
end
--返回当前世界等级经验加成,百分比,世界等级,玩家等级,玩家与世界等级差
function PlayerManager.GetExpAdd()
	local wl = PlayerManager.GetWorldLevel()
	local pl = PlayerManager.GetPlayerLevel()
	local gl = wl - pl
	local add =(PlayerManager.CanExpAdd() and gl > 0)
	and math.floor(math.floor(gl / 3) * pl / 100) or 0--PlayerManager._GetExpAddValue(gl)
	return add, wl, pl, gl
end
--返回当前世界等级经验加成,百分比,世界等级,玩家等级,玩家与世界等级差
function PlayerManager.CanExpAdd()
	return SystemManager.IsOpen(SystemConst.Id.WorldLev) --PlayerManager.GetPlayerLevel() >= 120
end

function PlayerManager.CanShowFight()
	return canShowFight
end

function PlayerManager.GetCreateRoleTime()
	return createRoleTime;
end

local _myCareerExpConfig = nil
--获取战斗力修正属性
function PlayerManager.GetPowerRate()
	local level = PlayerManager.GetPlayerLevel()
	if(level ~= 0) then
		
		if(_myCareerExpConfig == nil) then
			_myCareerExpConfig = careerExpConfig[level]
		else
			if(_myCareerExpConfig.level ~= level) then
				_myCareerExpConfig = careerExpConfig[level]
			end
		end
	end
	
	return _myCareerExpConfig and _myCareerExpConfig.zdl_rate or 100
end

 