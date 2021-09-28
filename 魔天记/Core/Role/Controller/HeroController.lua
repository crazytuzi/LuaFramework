require "Core.Role.Action.StandAction"
require "Core.Role.Action.SendCmd.SendStandAction"
require "Core.Role.Action.SendCmd.SendSkillStandAction"
require "Core.Role.Action.SendCmd.SendMoveToAngleAction"
require "Core.Role.Action.SendCmd.SendSkillMoveAction"
require "Core.Role.Action.SendCmd.SendMoveToNpcAction"
require "Core.Role.Action.SendCmd.SendMoveToAction"
require "Core.Role.Action.SendCmd.SendMoveToPathAction"
require "Core.Role.AI.AutoFightAiController"
require "Core.Role.AI.AutoRestoreController"
require "Core.Role.AI.RoleFollowAiController"
require "Core.Role.AI.RoleEscortAiController"
require "Core.Role.Controller.PlayerController";
require "Core.Role.Controller.AttackController";
require "Core.Role.Controller.MountLangController";
require "Core.Info.HeroInfo";
require "Core.Role.ModelCreater.RoleModelCreater"
require "Core.Role.ModelCreater.HeroModelCreater"
require "Core.Manager.Item.RealmManager"

require "Core.Role.Proxy.HeroCtrProxy"

HeroController = class("HeroController", PlayerController);
HeroController._attkCtrl = nil;
HeroController._instance = nil;

-- 上坐骑间隔时间
HeroController.RIDEINTERVAL = 5
HeroController.MESSAGE_ON_MOUNTLANG = "MESSAGE_ON_MOUNTLANG";
HeroController.MESSAGE_OUT_MOUNTLANG = "MESSAGE_OUT_MOUNTLANG";

HeroController.MESSAGE_FOLLOWTYPE_CHANGE = "MESSAGE_FOLLOWTYPE_CHANGE";




HeroController.FOLLOWTYPE_FOR_TEAM = 1;

function HeroController.GetInstance()
	return HeroController._instance
end

function HeroController:New(data)
	self = {};
	setmetatable(self, {__index = HeroController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.HERO;
	self._guards = {}
	self._hires = {}
	self._calAttr = {}
	-- 计算战斗力的属性集
	self._exCalAttr = {}
	-- 不计算战斗力的属性集
	self._skillPower = 0
	self._talentPower = 0
	self._mobaoPower = 0
	-- 用于保存计算后的属性
	self:_Init(data);
	HeroController._instance = self;
	return self;
end

function HeroController:_Init(data)
	self.id = data.id;
	self.info = HeroInfo:New(data);
	if(data.dress and data.dress.m ~= 0) then
		self._isRideHide = true
	end
	self:_InitEntity(EntityNamePrefix.HERO .. self.id, nil, true);
	self:SetLayer(Layer.Hero);
	self:_LoadModel(HeroModelCreater);
	self._autoRestoreCtr = AutoRestoreController:New(self);
	self._attkCtrl = AttackController:New(self);
	
	self.isstopForDie = false;
	
	self.currMountInfo = nil;
	
	
	self._isFight = false;
	-- self:SetRideTimer()
	if(self.info.hp == 0) then
		self:Die()
	end
	self._autoRestoreCtr:Start();
	GameObject.DontDestroyOnLoad(self.gameObject);
	
	
	MessageManager.AddListener(HeroCtrProxy, HeroCtrProxy.MESSAGE_USEMOUNT_SUCCESS, HeroController.UseMountSuccess, self);
	
	HeroCtrProxy.AddLister()
	
	self:AddBuffs(data.buff)
end

function HeroController:ResetData(data)
    if self.info then self.info:Dispose() end
    self.info = HeroInfo:New(data)
    self:RemoveBuffAll()
	self:AddBuffs(data.buff)
    self._roleCreater:ChangeData(data)
    MessageManager.Dispatch(PlayerManager, PlayerManager.SelfLevelChange)
end


function HeroController:AddGuard(role)
	if(role) then
		local site = table.getCount(self._guards) + 1;
		self._guards[site] = role
		role:SetMaster(self);
		role:SetSite(site)
	end
end

function HeroController:RemoveGuard(role)
	for i, v in pairs(self._guards) do
		if(v == role or role == nil) then
			self._guards[i] = nil;
		end
	end
end

function HeroController:GetGuards()
	return self._guards;
end

function HeroController:AddHire(role)
	if(role) then
		local site = table.getCount(self._hires) + 1;
		self._hires[site] = role
		role:SetMaster(self);
	end
end

function HeroController:RemoveHire(role)
	for i, v in pairs(self._hires) do
		if(v == role or role == nil) then
			self._hires[i] = nil;
		end
	end
end

function HeroController:GetHires()
	return self._hires;
end

function HeroController:GetGuardCount()
	return table.getCount(self._guards);
end


function HeroController:SetTarget(target, selectName, selecter)
	--	if(target == nil) then
	--		if(GameSceneManager.map) then
	--			GameSceneManager.map:ResetLastSelectRole()
	--		end
	--	end
	--	if(self.target and self.target.transform) then
	--		self.target:SetSelect(false);
	--	end
	if(target == nil or(target ~= nil and target:CanSelect())) then
		self.target = target;
		
		if(target and target.transform) then
			self.target:SetSelect(true, selectName, selecter);
			if(target ~= self) then
				SequenceManager.TriggerEvent(SequenceEventType.Guide.NOVICE_OPERATION_SELECT_TARGET);
			end
		end
	end
end

function HeroController:GetTarget()
	if(self._mountLangController) then
		return self._mountLangController:GetTarget();
	end
	return self.target;
end

function HeroController:StartAutoFight()
	
	if(self._autoFightCtr == nil) then
		self._autoFightCtr = AutoFightAiController:New(self);
	end
	
	if self._mountLangController ~= nil then
		self._autoFightCtr:SetRole(self._mountLangController);
	end
	
	local isFl = self:IsFollowAiCtr();
	--不自动跟随才发出自动战斗的消息
	if isFl then
		log("正在跟随，需要暂停 StartAutoFight");
		self._autoFightCtr:Pause();
		self._isAutoFight = false;
	else
		self._autoFightCtr:StartAutoFight();
		self._isAutoFight = true;
		MessageManager.Dispatch(PlayerManager, PlayerManager.StartAutoFight);
		
		HeroCtrProxy.SetHeroAutoFightState(1)
	end	
	
	-- local isFl = self:IsFollowAiCtr();
	-- if isFl then
	-- 	log("正在跟随，需要暂停 StartAutoFight");
	-- 	self._autoFightCtr:Pause();
	-- end
end

function HeroController:StopAutoFight()
	
	if(self._autoFightCtr) then
		
		self._autoFightCtr:StopAutoFight();
		MessageManager.Dispatch(PlayerManager, PlayerManager.StopAutoFight)
		-- self:Stand();
		HeroCtrProxy.SetHeroAutoFightState(0)
	end
	self._isAutoFight = false;
	
end

function HeroController:StartAutoKill(id)
	if(self._autoFightCtr == nil) then
		self._autoFightCtr = AutoFightAiController:New(self);
	end
	if self._mountLangController ~= nil then
		self._autoFightCtr:SetRole(self._mountLangController);
	end
	
	
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("正在跟随，需要暂停 StartAutoFight");
		self._autoFightCtr:Pause();
	else
		self._autoFightCtr:StartAutoKill(id);
		MessageManager.Dispatch(PlayerManager, PlayerManager.StartAutoKill);		
	end
end

function HeroController:StopAutoKill()
	if(self._autoFightCtr) then
		self._autoFightCtr:StopAutoKill();
		MessageManager.Dispatch(PlayerManager, PlayerManager.StopAutoKill);
	end
end

function HeroController:IsAutoKill()
	if(self._autoFightCtr) then
		return self._autoFightCtr.isAutoKill;
	end
	return false
end


-- 开始 跟随目标
function HeroController:StartFollow(p_id, followType)
	
	-- 如果 正在自己战斗， 那么 暂停
	if(self._autoFightCtr ~= nil) then
		self._autoFightCtr:Pause();
	end
	
	
	if self._followAiCtr == nil then
		self._followAiCtr = RoleFollowAiController:New(self);
	end
	
	self.follow_id = p_id;
	self.follow_type = followType;
	
	self._followAiCtr:SetFollowTarget(p_id, followType);
	self._followAiCtr:Start();
	
	MessageManager.Dispatch(HeroController, HeroController.MESSAGE_FOLLOWTYPE_CHANGE);
end



-- 获取跟随控制器
function HeroController:GetFollowAiCtr()
	return self._followAiCtr;
end

-- 停止跟随目标
function HeroController:StopFollow()
	
	
	if self._followAiCtr ~= nil then
		self._followAiCtr:SetFollowTarget(nil);
		self._followAiCtr:Stop();
		self._followAiCtr:Dispose();
		self._followAiCtr = nil;
	end
	
	MessageManager.Dispatch(HeroController, HeroController.MESSAGE_FOLLOWTYPE_CHANGE);
	
	-- 如果之前有 自动战斗状态， 那么久恢复 战斗
	if(self._autoFightCtr ~= nil) then
		self._autoFightCtr:Resume();
	end
end

function HeroController:IsFollowAiCtr()
	if(self._followAiCtr and not self._followAiCtr.can_not_follow) then
		return true;
	end
	return false
end

-- 自动护送
function HeroController:StartAutoEscort(targetId)
	if self._escortAiCtr == nil then
		self._escortAiCtr = RoleEscortAiController:New(self);
	end
	
	self._escortAiCtr:SetTarget(targetId);
	self._escortAiCtr:Start();
	
end

-- 停止自动护送
function HeroController:StopAutoEscort()
	if self._escortAiCtr ~= nil then
		self._escortAiCtr:Stop();
		self._escortAiCtr:Dispose();
		self._escortAiCtr = nil;
	end
	--self:StopAutoFight();
end


function HeroController:SetAutoFightSkill(skill)
	local autoFightCtr = self._autoFightCtr;
	if(autoFightCtr) then
		if((autoFightCtr.isAutoFight or autoFightCtr.isAutoKill)) then
			autoFightCtr:SetDefaultSkill(skill);
			if(not autoFightCtr.isPause and not autoFightCtr:IsResumeTime()) then
				return true;
			end
		end
	end
	return false
end

function HeroController:IsAutoFight()
	if(self._autoFightCtr) then
		return self._autoFightCtr.isAutoFight;
		-- self._autoFightCtr.isRunning;
	end
	return false
end

function HeroController:IsPauseAutoFight()
	if(self._autoFightCtr) then
		return self._autoFightCtr.isPause
		-- self._autoFightCtr.isRunning;
	end
	return true
end

-- 暂停
function HeroController:PauseAutoFight()
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("正在跟随，不能进行 PauseAutoFight");
		return;
	end
	
	if(self._autoFightCtr) then
		self._autoFightCtr:Pause();
	end
end

-- 继续
function HeroController:ResumeAutoFight()
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("正在跟随，不能进行 PauseAutoFight");
		return;
	end
	
	if(self._autoFightCtr) then
		self._autoFightCtr:Resume();
		-- MessageManager.Dispatch(PlayerManager, PlayerManager.StartAutoFight)
	end
end
--local oldAttr = BaseAttrInfo:New()
--local newAttr = BaseAttrInfo:New()
HeroController.CalculateAttrType =
{
	None = - 1,
	All = 0,
	GuideSkill = 1,
	Equip = 2,
	EquipReine = 3,
	EquipStrong = 4,
	EquipShenqi = 5,
	Ride = 6,
	Wing = 7,
	Gem = 8,
	NewTrump = 9,
	PetAdvance = 10, --宠物进阶数据
	Bag = 11,
	LingYao = 12,
	Title = 13,
	Realm = 14,
	Trump = 15,
	Buffer = 16,
	Talent = 17,
	SkillPower = 18,
	PetFashion = 19, -- 宠物幻形数据
	EquipNewStrong = 20,
	-- 强化属性
	EquipNewStrongSuit = 21,
	-- 套装属性
	EquipSuit = 22,-- 套装属性 3件 5件  8件
	WingFashion = 23,-- 翅膀时装属性
	EquipFoMo = 24, -- 仙器附魔
	Mobao = 25, --魔宝	
	VIP = 26, --vip	
	WiseEquipDuanZao = 27, -- 仙器属性锻造
	Formation = 28, -- 阵图
	RideFeed = 29, -- 坐骑养魂
	Star = 30, -- 命星
	
}
local floor = math.floor
-- 计算角色属性
function HeroController:CalculateAttribute(calculateType)
	
	calculateType = calculateType or HeroController.CalculateAttrType.All
	local calAll =(calculateType == HeroController.CalculateAttrType.All)
	local info = self.info;
	if(info and HeroController._instance) then
		
		info:ResetAttribute(false);
		-- 姿态属性
		-- info:AddAttribute(self.info:GetPostureAttributs(), false);
		-- 仙盟技能
		if(calculateType == HeroController.CalculateAttrType.GuideSkill or calAll) then
			self._calAttr[HeroController.CalculateAttrType.GuideSkill] = GuildDataManager.GetGuildSkillAttr()
			--            info:AddAttribute(GuildDataManager.GetGuildSkillAttr(), false);
		end
		
		-- 装备
		if(calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Equip] = EquipDataManager.GetMyEquipsAllAttrs()
			--            info:AddAttribute(EquipDataManager.GetMyEquipsAllAttrs(), false);
		end
		
		-- 仙器 基础属性（锻造属性）
		if(calculateType == HeroController.CalculateAttrType.Equip or calAll or HeroController.CalculateAttrType.WiseEquipDuanZao) then
			self._calAttr[HeroController.CalculateAttrType.WiseEquipDuanZao] = EquipDataManager.GetMyWiseEquipsAllAttrs()
		end
		
		-- 仙器附魔 
		if(calculateType == HeroController.CalculateAttrType.EquipFoMo or calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipFoMo] = EquipDataManager.GetAllEuipsFoMoAttrs()
		end
		
		
		-- 装备精炼
		if(calculateType == HeroController.CalculateAttrType.EquipReine or calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipReine] = RefineDataManager.GetAllRefine()
			--            info:AddAttribute(RefineDataManager.GetAllRefine(), false);
		end
		
		-- 装备附灵
		if(calculateType == HeroController.CalculateAttrType.EquipStrong or calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipStrong] = StrongExpDataManager.GetAllQiangHuaAtt()
			--            info:AddAttribute(StrongExpDataManager.GetAllQiangHuaAtt(), false);
		end
		-- 装备神器属性
		if(calculateType == HeroController.CalculateAttrType.EquipShenqi or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipShenqi] = MouldingDataManager.GetAllSqAtt()
			--            info:AddAttribute(MouldingDataManager.GetAllSqAtt(), false);
		end
		
		-- 新强化
		if(calculateType == HeroController.CalculateAttrType.EquipNewStrong or calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipNewStrong] = NewEquipStrongManager.GetAllEquipStrongAttr()
		end
		
		-- 强化套装属性
		if(calculateType == HeroController.CalculateAttrType.EquipNewStrongSuit or calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipNewStrongSuit] = NewEquipStrongManager.GetCurPlusAttr()
		end
		
		-- 3/5/8 件转变套装属性
		if(calculateType == HeroController.CalculateAttrType.EquipSuit or calculateType == HeroController.CalculateAttrType.Equip or calAll) then
			self._calAttr[HeroController.CalculateAttrType.EquipSuit] = EquipLvDataManager.GetAllSuitAtt();
		end
		
		
		-- 坐骑
		if(calculateType == HeroController.CalculateAttrType.Ride or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Ride] = RideManager.GetAllRideProperty()
			--            info:AddAttribute(RideManager.GetAllRideProperty(), false);
		end
		
		if(calculateType == HeroController.CalculateAttrType.RideFeed or calAll) then
			self._calAttr[HeroController.CalculateAttrType.RideFeed] = RideManager.GetRideFeedAttr()
			
		end
		
		-- 翅膀
		if(calculateType == HeroController.CalculateAttrType.Wing or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Wing] = WingManager.GetCurrentWingData()
			--            info:AddAttribute(WingManager.GetCurrentWingData(), false);
		end
		
		if(calculateType == HeroController.CalculateAttrType.WingFashion or calAll) then
			self._calAttr[HeroController.CalculateAttrType.WingFashion] = WingManager.GetAllFashionAttr()
		end
		
		-- 宝石
		if(calculateType == HeroController.CalculateAttrType.Gem or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Gem] = GemDataManager.GetAllAttrs()
			--            info:AddAttribute(GemDataManager.GetAllAttrs(), false);
		end
		-- 新法宝
		if(calculateType == HeroController.CalculateAttrType.NewTrump or calAll) then
			self._calAttr[HeroController.CalculateAttrType.NewTrump] = NewTrumpManager.GetAllAttrs()
			--            info:AddAttribute(NewTrumpManager.GetAllAttrs(), false)
		end
		
		-- 背包属性
		if(calculateType == HeroController.CalculateAttrType.Bag or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Bag] = BackpackDataManager.GetProperty()
			
			--            info:AddAttribute(BackpackDataManager.GetProperty(), false);
		end
		-- 丹药
		if(calculateType == HeroController.CalculateAttrType.LingYao or calAll) then
			self._calAttr[HeroController.CalculateAttrType.LingYao] = LingYaoDataManager.TryAllHasAtt()
			--            info:AddAttribute(LingYaoDataManager.TryAllHasAtt(), false)
		end
		
		-- 称号
		if(calculateType == HeroController.CalculateAttrType.Title or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Title] = TitleManager.GetAllGetTitleAttr()
			--            info:AddAttribute(TitleManager.GetAllGetTitleAttr(), false)
		end
		-- 境界
		if(calculateType == HeroController.CalculateAttrType.Realm or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Realm] = RealmManager.GetAllAttrs()
		end
		
		-- 法宝
--		if(calculateType == HeroController.CalculateAttrType.Trump or calAll) then
--			self._calAttr[HeroController.CalculateAttrType.Trump] = TrumpManager.GetAllAttrs()
--		end
		-- 阵图
		if(calculateType == HeroController.CalculateAttrType.Formation or calAll) then
			self._calAttr[HeroController.CalculateAttrType.Formation] = FormationManager.GetAllAttrs()
		end
		-- 命星
		if(calculateType == HeroController.CalculateAttrType.Star or calAll) then
            self._calAttr[HeroController.CalculateAttrType.Star] = StarManager.GetAllAttrs()
		end

		if(calculateType == HeroController.CalculateAttrType.PetAdvance or calAll) then
			self._calAttr[HeroController.CalculateAttrType.PetAdvance] = PetManager.GetPetAdvanceAttr()
		end
		
		if(calculateType == HeroController.CalculateAttrType.PetFashion or calAll) then
			self._calAttr[HeroController.CalculateAttrType.PetFashion] = PetManager.GetPetFashionAttr()
		end
		
		for k, v in pairs(self._calAttr) do
			
			info:AddAttribute(v, false)
		end
		
		info:RefreshAttribute(false);
		
		local power = CalculatePower(info, true);
		
		-- 技能附加战斗力
		if(calculateType == HeroController.CalculateAttrType.SkillPower or calAll) then
			self._skillPower = SkillManager.GetSkillPower()
		end
		-- -- 天赋附加战斗力
		-- if(calculateType == HeroController.CalculateAttrType.Talent or calAll) then
		-- 	self._talentPower = SkillManager.GetTalentPower()
		-- end
		
		if(calculateType == HeroController.CalculateAttrType.Mobao or calAll) then
			self._mobaoPower = NewTrumpManager.GetMobaoPower()
		end	
		self._magicPower = RealmManager.GetMagicPower()
        self._formatinPower = FormationManager.GetSkillPower()
		
		power = floor((power + self._skillPower  + self._mobaoPower + self._magicPower + self._formatinPower)
             * PlayerManager.GetPowerRate() / 100);		
		
		PlayerManager.power = power
		
		-- 魔宝
		if(calculateType == HeroController.CalculateAttrType.Mobao or calAll) then
			self._exCalAttr[HeroController.CalculateAttrType.Mobao] = NewTrumpManager.GetMobaoAllAttrs()
		end	
		-- vip
		if(calculateType == HeroController.CalculateAttrType.VIP or calAll) then
			self._exCalAttr[HeroController.CalculateAttrType.VIP] = VIPManager.GetVipAttrs()
		end
		
		if(calculateType == HeroController.CalculateAttrType.Buffer or calAll) then
			-- buff属性
			if(self._buffCtrl) then
				self._exCalAttr[HeroController.CalculateAttrType.Buffer] = self._buffCtrl:GetBuffAllAttributs()
				--                info:AddAttribute(self._buffCtrl:GetBuffAllAttributs(), false);
			end
		end
		-- -- 天赋
		-- if(calculateType == HeroController.CalculateAttrType.Talent or calAll) then
		-- 	self._exCalAttr[HeroController.CalculateAttrType.Talent] = SkillManager.GetTalentAllAttrs()
		 
		-- end
		
		for k, v in pairs(self._exCalAttr) do			
			info:AddAttribute(v, false)
		end
		
		
		info:RefreshAttribute();
		--newAttr:Init(self.info)
		if(self._pet) then
			self._pet.info.move_spd = self.info.move_spd;
		end
	end
	
	if self._mountLangController ~= nil then
		self._mountLangController:_HeroAttChange();
	end
	
	-- 属性更新后发消息通知其他模块更新界面
	MessageManager.Dispatch(PlayerManager, PlayerManager.SELFATTRIBUTECHANGE);
	
	-- 用于测试
--[[    if self._mountLangController ~= nil then
        self._mountLangController:GetAttribute();
    end
    ]]
end

-- 添加buff
function HeroController:AddBuff(caster, id, level, time, overlap)
	if(not self:IsDie()) then
		if(self._buffCtrl == nil) then
			self._buffCtrl = BuffController:New(self);
		end
		--Warning(id .. '-----'.. time)
		--        if id == 218001 then --vip试用卡时间开始,弹出试用信息
		--            ModuleManager.SendNotification(VipTryNotes.USE_VIP_TRY,{ s = 1, t = time / 1000 })
		--        end
		return self._buffCtrl:Add(caster, id, level, time, overlap);
		
	end
	return nil;
end

function HeroController:GetVipTryInfo()
	local bs = self:GetBuffs()
	for k, v in pairs(bs) do
		if v:GetId() == 218001 then
			return {s = 1, t = v:GetCoolTime()}
		end
	end
end

function HeroController:StopCurrentActAndAI()
	
	-- 需要 打断 跟随
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("打断跟随");
		self:StopFollow()
	end
	
	self:StopAutoFight()
	self:StopAutoKill()
	self:StopAttack()
	if(not self:IsDie()) then
		self:StopAction(3);
		self:Stand();
	end
end


-- 死亡
function HeroController:Die()
	
	if(not self:IsDie()) then
		self:RemoveBuffAll(true)
		
		local isFl = self:IsFollowAiCtr();
		if isFl then
			log("死亡打断跟随");
			self.isstopForDie = true;
			self:StopFollow()
		end
		
		if(self.pet) then
			self.pet:SetTarget(nil);
		end
		if(self.puppet) then
			self.puppet:SetTarget(nil);
		end
		
		---------- 死亡需要 下载具 -- 如果 配置 要求 死亡 不清除 载具， 那么就不需要 卸下载具 -------------
		if self._mountController ~= nil then
			local is_end_hp = self._mountController:Is_end_hp();
			if is_end_hp then
				self._mountController:Die();
			end
		end
		
		if self._mountLangController ~= nil then
			local is_end_hp = self._mountLangController:Is_end_hp();
			if is_end_hp then
				self._mountLangController:Die();
			end
			
			---  载具 死亡 , 角色 待机状态， 恢复使用 本身 属性
			self:StopAction(3);
			self:Stand(true);
		else
			-- 没有使用载具的时候，使用角色属性， 所以正常死亡
			self:StopAction(3);
			self:DoAction(DieAction:New());
			
		end
		
		------------------------------------------------
		self.info.hp = 0;
		
	end
	self._blDie = true;
	self:StopAttack();
	self:SetTarget(nil);
	if(GameSceneManager.map) then
		GameSceneManager.map:ResetLastSelectRole()
	end
end

--[[ 获取 已经上了的 载具 id
]]
function HeroController:GetMountId()
	
	if self._mountController ~= nil then
		return self._mountController:GetMountId();
	end
	
	if self._mountLangController ~= nil then
		return self._mountLangController:GetMountId();
	end
	
	return nil;
end

function HeroController:IsOnFlyVehicle()
	return self._mountController ~= nil;
end

function HeroController:Relive()
	--    if (self:IsDie()) then
	self.info.hp = self.info.hp_max;
	self:StopAction(3);
	self._blDie = false;
	self.state = RoleState.Stand
	self:Stand();
	--    end
	if self.isstopForDie == true then
		
		self:StartFollow(self.follow_id, self.follow_type)
		self.isstopForDie = false;
	end
	
end

-- 待机
function HeroController:Stand(isSend)
	local blSend = isSend or true;
	if(not self:IsDie()) then
		if self._mountLangController ~= nil then
			-- 控制 地面载具
			self._mountLangController:Stand();
		else
			-- self ----
			local action = self._action;
			if(action) then
				if(action.canMove and not action:IsFinished()) then
					self:DoAction(SendSkillStandAction:New());
				else
					if(action.actionType ~= ActionType.BLOCK) then
						self:StopAction(2);
						if(blSend) then
							self:DoAction(SendStandAction:New());
						else
							self:DoAction(StandAction:New());
						end
					end
				end
			else
				self:StopAction(3);
				if(blSend) then
					self:DoAction(SendStandAction:New());
				else
					self:DoAction(StandAction:New());
				end
			end
			--
		end
	end
end


function HeroController:MoveToNpc(id, map, pos)
	
	if GameSceneManager.map == nil or GameSceneManager.map._ready == false then
		return;
	end
	
	local isFl = self:IsFollowAiCtr();
	self:StopAutoKill();
	if isFl then
		log("can not to MoveToNpc");
		return;
	end
	
	BusyLoadingPanel.CheckAndStopLoadingPanel();
	
	-- self:MovePath(Vector3.New(-25.65,0.1,-36.75),Vector3.New(-28.15,0.1,-20.75),701001)
	if(not self:IsDie() and self.state ~= RoleState.STILL and self.state ~= RoleState.STUN) then
		-- self:StopAction(3);
		-- logTrace("HeroController:MoveToNpc:id=" .. id);
		if self._mountLangController ~= nil then
			-- 控制 地面载具
			self._mountLangController:MoveToNpc(id, map, pos);
			return;
		end
		
		
		self:DoAction(SendMoveToNpcAction:New(id, map, pos));
	end
end

function HeroController:MoveTo(pt, map, gotoSceneNeedShowLoader)
	-- log("MoveTo" ..(map or ""))
	-- log(pos or "")
	if GameSceneManager.map == nil or GameSceneManager.map._ready == false then
		return;
	end
	
	local isFl = self:IsFollowAiCtr();
	self:StopAutoKill();
	if isFl then
		log("can not to MoveTo");
		return;
	end
	
	BusyLoadingPanel.CheckAndStopLoadingPanel();
	
	-- logTrace("HeroController:MoveTo:to=" .. tostring(pt) .. ",die=" .. tostring(self:IsDie()) .. ",state=" .. self.state)
	if(not self:IsDie() and self.state ~= RoleState.STILL and self.state ~= RoleState.STUN) then
		-- self:StopAction(3);
		-- logTrace("HeroController:MoveTo:map=" .. map .. ",pos=" .. tostring(pt));
		if self._mountLangController ~= nil then
			-- 控制 地面载具
			self._mountLangController:MoveTo(pt, map, gotoSceneNeedShowLoader);
			return;
		end
		
		
		self:DoAction(SendMoveToAction:New(pt, map, gotoSceneNeedShowLoader));
	end
end

function HeroController:MoveToPath(path)
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("can not to MoveTo");
		return;
	end
	
	BusyLoadingPanel.CheckAndStopLoadingPanel();
	if(not self:IsDie() and self.state ~= RoleState.STILL and self.state ~= RoleState.STUN) then
		if self._mountLangController ~= nil then
			-- 控制 地面载具
			self._mountLangController:MoveToPath(path);
			return;
		end
		self:DoAction(SendMoveToPathAction:New(path));
	end
end

-- 只为 跟随 服务， 其他功能不能 调用此接口
function HeroController:MoveToForFollow(pt, map)
	if(not self:IsDie() and self.state ~= RoleState.STILL and self.state ~= RoleState.STUN) then
		
		BusyLoadingPanel.CheckAndStopLoadingPanel();
		
		-- log("--------------------MoveToForFollow------------------------------");
		if self._mountLangController ~= nil then
			self._mountLangController:MoveTo(pt, map, nil);
		else
			self:DoAction(SendMoveToAction:New(pt, map));
		end
		
	end
end

function HeroController:StopActBeforGoToScene()
	if(not self:IsDie()) then
		
		if self._mountLangController ~= nil then
			self._mountLangController:StopAction(3);
		else
			self:StopAction(3);
		end
	end
end

-- 移动路径
function HeroController:MovePath(fromPoint, toPoint, ToMap)
	-- if (fromMap and fromMap ~= GameSceneManager.map.info.id) then
	-- GameSceneManager.GotoScene(fromMap)
	-- end
	-- logTrace(tostring(fromPoint) .. "___" .. tostring(fromPoint).. "___" .. tostring(ToMap))
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("can not to MovePath");
		return;
	end
	
	BusyLoadingPanel.CheckAndStopLoadingPanel();
	
	self:SetPosition(fromPoint)
	self:DoAction(SendMoveToAction:New(toPoint, ToMap))
end
-- 设置攻击boss模式(nil为切换到正常模式), boss 控制器, camParam镜头参数{Y角度,y高,距离}
function HeroController:SetAttackBossMode(boss, camParam)
	self.attackBoss = boss
	self.camParam = camParam
	if boss and camParam then MainCameraController.GetInstance():TrackTarget() end
end
-- 返回boss, 攻击boss模式
function HeroController:GetAttackBoss()
	-- if true then return self.target,{ 25, 3, 13} end
	if self.attackBoss and(self.attackBoss:IsDie() or self.attackBoss._dispose) then
		self:SetAttackBossMode(nil)
	end
	return self.attackBoss, self.camParam
end

-- 移动，角度
function HeroController:MoveToAngle(angle)
	
	local isFl = self:IsFollowAiCtr();
	self:StopAutoKill();
	if isFl then
		
		return;
	end
	
	if(not self:IsDie() and self.state ~= RoleState.STILL and self.state ~= RoleState.STUN) then
		if self:GetAttackBoss() then
			angle = angle + 90 + MainCameraController.transform.eulerAngles.y
		else
			angle = angle + 90 + cameraLensRotation
		end
		-- if angle == self.angle then return end
		self.angle = angle
		
		
		if self._mountLangController ~= nil then
			-- 控制 地面载具
			self._mountLangController:MoveToAngle(angle);
		else
			-- self ----
			local action = self._action;
			local cooperation = self._cooperation;
			if(action) then
				if(action.canMove) then
					if(cooperation and cooperation.__cname == "SendSkillMoveAction") then
						cooperation:SetAngle(angle);
					else
						self:DoAction(SendSkillMoveAction:New(angle));
					end
				else
					if(action.actionType ~= ActionType.BLOCK) then
						if(action.__cname == "SendMoveToAngleAction") then
							action:SetAngle(angle);
						else
							self:StopAction(3);
							self:DoAction(SendMoveToAngleAction:New(angle));
						end
					end
				end
			else
				self:StopAction(3);
				self:DoAction(SendMoveToAngleAction:New(angle));
			end
			----
		end
		
		
	end
	
	
end

--[[-- 普通攻击
function HeroController:Attack(start, autoSearch)
    if (not self:IsDie() and self.state ~= RoleState.SILENT and self.state ~= RoleState.STUN) then
        if self._mountLangController ~= nil then
            -- 控制 地面载具
            self._mountLangController:Attack(start);

        else
            local attkCtrl = self._attkCtrl;
            if (attkCtrl) then
                if (start) then
                    attkCtrl:StartAttack(autoSearch);
                else
                    attkCtrl:StopAttack();
                end
            end
        end
    end
end
]]
-- 使用技能
function HeroController:CastSkill(skill, autoSearch)
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("can not to CastSkill");
		MsgUtils.ShowTips(nil, nil, nil, "跟随状态无法执行此操作");
		return;
	end
	
	if(not self:IsDie() and self.state ~= RoleState.STILL and self.state ~= RoleState.STUN) then
		if self._mountLangController ~= nil then
			-- 控制 地面载具
			self._mountLangController:CastSkill(skill, autoSearch);
		else
			local attkCtrl = self._attkCtrl;
			if(attkCtrl and skill) then
				attkCtrl:CastSkill(skill, autoSearch);
			end
		end
	end
end

function HeroController:StopAttack()
	if self._mountLangController ~= nil then
		-- 控制 地面载具
		self._mountLangController:StopAttack();
	else
		local attkCtrl = self._attkCtrl;
		if(attkCtrl) then
			attkCtrl:StopAttack();
		end
	end
end




function HeroController:_DisposeHandler()
	
	-- 这里不允许调用销毁
	--Warning("不允许 调用   HeroController:_DisposeHandler ");
	HeroCtrProxy.RemoveLister();
	MessageManager.RemoveListener(HeroCtrProxy, HeroCtrProxy.MESSAGE_USEMOUNT_SUCCESS, HeroController.UseMountSuccess);
	
	if(self._autoRestoreCtr) then
		self._autoRestoreCtr:Dispose();
		self._autoRestoreCtr = nil;
	end
	if(self._autoFightCtr) then
		self._autoFightCtr:Dispose();
		self._autoFightCtr = nil;
	end
	if(self._attkCtrl) then
		self._attkCtrl:Dispose();
		self._attkCtrl = nil;
	end
	
	if self._followAiCtr then
		self._followAiCtr:Dispose();
		self._followAiCtr = nil;
	end
	
	self:StopFightStatusTimer();
	if(HeroController._instance == self) then
		HeroController._instance = nil;
	end
end

-- 设置姿态
function HeroController:SetPosture(id)
	if(self.info and self.info.posture ~= id) then
		self.info:SetPosture(id);
		self:CalculateAttribute();
	end
end

-- 进入 飞行载具 载具模式  
--[[  mount_id 载具 id
  path_id  路线 id 在配置表  move_path_prefab.lua
   needSendToServer 是否需要 通知后台 ， 一般情况下 都是  true

  per           飞行载具 进度， 一般可以不填 或者 为  0
]]
function HeroController:OnMountByRid(mount_id, path_id, needSendToServer, per)
	
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("正在跟随，不能 上飞行载具 ");
		return;
	end
	
	if self._mountController ~= nil then
		
		log("已经在飞行载具中， 不能再设置飞行载具");
		return;
	end
	
	if MountManager.login_mount ~= nil then
		if tonumber(MountManager.login_mount.id) == tonumber(mount_id) then
			MountManager.login_mount = nil;
		end
	end
	
	self.movePathCf = ConfigManager.GetMovePath(path_id);
	self:_OnMount(mount_id, self.movePathCf.line_path, self.movePathCf.camer_path, needSendToServer, per);
	
	
	
end

-- 进入 飞行载具 载具模式  
--[[  mount_id     载具id
  pathInfo     载具路线预设名 比如 MountPath/path_mount_99999_01
  pathInfo_c   摄像机路线预设名 比如 MountPath/path_mount_99999_01_c

  needSendToServer 是否需要 通知后台 ， 一般情况下 都是  true

  per           飞行载具 进度， 一般可以不填 或者 为  0

]]
function HeroController:_OnMount(mount_id, pathInfo, pathInfo_c, needSendToServer, per)
	
	mount_id = mount_id + 0;
	
	self:Lock();
	
	self.currMountInfo = {};
	self.currMountInfo.mountInfo = ConfigManager.GetMount(mount_id);
	self.currMountInfo.pathInfo = pathInfo;
	self.currMountInfo.pathInfo_c = pathInfo_c;
	self.currMountInfo.mount_per = per;
	
	if self.currMountInfo.mount_per == nil then
		self.currMountInfo.mount_per = 0;
	end
	
	if needSendToServer then
		HeroCtrProxy.TryUseMount(mount_id);
		
	else
		
		local me = HeroController:GetInstance();
		local heroInfo = me.info;
		local my_id = tonumber(heroInfo.id);
		
		self:UseMountSuccess({mid = mount_id, pid = my_id});
	end
	
end


function HeroController:FMountInitComplete(target)
	
	self._mountController = target;
	
	self._mountController:Start(self);
	self._mountController:MoveToTarget(self.movePathCf.id, self.currMountInfo.mount_per, true);
	
	local m_id = self._mountController:GetMountId();
	self:OnAndInitMountModeComplete(m_id);
	
	--
	self:UpdateNamePanel()
	
end

--  退出 载具 模式
function HeroController:OutMount(notNeedSendToServer)
	
	self:UnLock();
	if self._mountController ~= nil then
		self._mountController = nil;
	end
	
	MainCameraController:GetInstance():LockHero();
	
	if notNeedSendToServer == nil or not notNeedSendToServer then
		
		HeroCtrProxy.TryUnUseMount();
	end
	
	
	self.transform.rotation = Quaternion.Euler(0, 0, 0);
	-- 位置也 设置为靠地面
	local pos = self.transform.position;
	local pt = Vector3(pos.x, pos.y, pos.z);
	MapTerrain.SampleTerrainPositionAndSetPos(self.transform, pt)
	
	--    self.transform.position = MapTerrain.SampleTerrainPosition(pt);
	self:UpdateNamePanel()
	self:ReStand();
end

-- 检测 如果正在飞行载具中的时候 ， 停止飞行载具， 而且不需要更新状态到后台
function HeroController:CheckAndOutMountNyNotSendToServer(notNeedSendToServer, setToBronPoint)
	
	if self._mountController ~= nil then
		
		-- 1  born_x  同步 出生点
		if setToBronPoint then
			self._mountController:TrySendMapBronPointInfo();
		end
		
		-- 2 停止载具
		self._mountController:Stop(notNeedSendToServer);
	end
	
end


--  进入 地面载具模式
--  mount_id 载具 id
--  elseTime 载具 存在时间， 如果设置 为 nil ， 那么就读配置表的时间
--  needSendToServer 是否通知后台
--  hideBtn 是否隐藏卸载按钮.
function HeroController:OnMountLang(mount_id, elseTime, needSendToServer)
	
	local isFl = self:IsFollowAiCtr();
	if isFl then
		log("正在跟随，不能 上战斗载具 ");
		return;
	end
	
	
	-- 同一个场景 可以 多个 载具 测试
	--[[    if self._mountLangController ~= nil then
        log("已经上载具了， 不能再上");
        MsgUtils.ShowTips("当前正处于变身状态，不能再进行变身。");
        return;
    end
  ]]
	mount_id = tonumber(mount_id);
	
	-- log("------- mount_id " .. mount_id);
	self.currMountInfo = {};
	self.currMountInfo.mount_id = mount_id;
	
	self.currMountInfo.elseTime = elseTime;
	
	local tm = ConfigManager.GetMount(mount_id);
	
	
	self.currMountInfo.hideBtn = tm.is_hide_unload;
	
	if MountManager.login_mount ~= nil then
		if tonumber(MountManager.login_mount.id) == tonumber(mount_id) then
			MountManager.login_mount = nil;
		end
	end
	
	if needSendToServer then
		HeroCtrProxy.TryUseMount(self.currMountInfo.mount_id);
	else
		local me = HeroController:GetInstance();
		local heroInfo = me.info;
		local my_id = tonumber(heroInfo.id);
		
		self:UseMountSuccess({mid = self.currMountInfo.mount_id, pid = my_id});
	end
	
end

function HeroController:UseMountSuccess(data)
	
	local m_id = data.mid;
	local pid = tonumber(data.pid);
	
	local me = HeroController:GetInstance();
	local heroInfo = me.info;
	local my_id = tonumber(heroInfo.id);
	
	if pid ~= my_id then
		return;
	end
	
	local mountInfo = ConfigManager.GetMount(m_id);
	
	self:StopAttack();
	
	if mountInfo.type == MountManager.TYPE_F_MOUNT then
		
		if self.currMountInfo.mountInfo == nil then
			log("调用了 OnMountLang 却 使用了 飞行 载具 id " .. m_id);
		end
		
		self:CheckAndPaushLandMount();
		
		
		self._mountController = MountController:New(self.currMountInfo.mountInfo, HeroController.FMountInitComplete, self);
		
	elseif mountInfo.type == MountManager.TYPE_L_MOUNT then
		
		if self.currMountInfo.mount_id == nil then
			log("调用了 OnMountByRid 却 使用了 地面 载具 " .. m_id);
		end
		
		
		if self._mountLangController ~= nil then
			self._mountLangController:Stop(true);
		end
		
		self:StopAction(3);
		self._mountLangController = MountLangController:New(m_id, HeroController.LMountInitComplete, self);
		
		
		-- 战斗载具变化都会影响属性
		self:CalculateAttribute();
		
	end
	
	
	
end

function HeroController:LMountInitComplete(tg)
	self._mountLangController = tg
	
	if(self._mountLangController) then
		self._mountLangController:Start(self, self.currMountInfo.elseTime);
		self._mountLangController.id = self.id;
		
		local lt = self._mountLangController.lmount_elseTime;
		
		-- 移除 坐骑
		-- self._roleCreater:_RemoveRide();
		MessageManager.Dispatch(HeroController, HeroController.MESSAGE_ON_MOUNTLANG, lt);
		
		local m_id = self._mountLangController:GetMountId();
		self:OnAndInitMountModeComplete(m_id);
		
		-- 自动战斗 需要设置 控制类目标
		if self._autoFightCtr ~= nil then
			self._autoFightCtr:SetRole(self._mountLangController);
		end
		
		self:UpdateNamePanel()
		
	end
	
end





--[[载具 初始化完成
]]
function HeroController:OnAndInitMountModeComplete(m_id)
	
	SequenceManager.TriggerEvent(SequenceEventType.Base.VEHICLE_INIT, m_id);
	
end

--[[在跳场景的时候 如果自己已经变身载具 的话， 需要检查载具是否需要取消
]]
function HeroController:CheckOutCurrMountByGotoScene()
	
	if self._mountController ~= nil then
		local cf = self._mountController:GetCfInfo();
		if cf.is_end_leavemap == true then
			self._mountController:Stop();
		end
		
	end
	
	if self._mountLangController ~= nil then
		local cf = self._mountLangController:GetCfInfo();
		if cf.is_end_leavemap == true then
			self._mountLangController:Stop();
		end
	end
end

function HeroController:GetAction()
	
	if self._mountLangController ~= nil then
		return self._mountLangController:GetAction();
	end
	
	return self._action;
end

function HeroController:StopMountLang()
	
	if self._mountLangController ~= nil then
		self._mountLangController:Stop();
	end
	
end


--  退出 载具 模式
function HeroController:OutMountLang(notSendToServer)
	
	if self._mountLangController ~= nil then
		self._mountLangController = nil;
	end
	
	if notSendToServer then
		
	else
		HeroCtrProxy.TryUnUseMount();
	end
	
	
	MessageManager.Dispatch(HeroController, HeroController.MESSAGE_OUT_MOUNTLANG);
	
	-- 战斗载具变化都会影响属性
	self:CalculateAttribute();
	
	
	
	-- 自动战斗 需要设置 控制类目标
	self:StopAttack();
	if self._autoFightCtr ~= nil then
		self._autoFightCtr:SetRole(self);
	end
	
	self:UpdateNamePanel();
	
	self:ReStand();
end

--[[ 获取 角色的 载具属性， 如果返回 不为 nil 的话， 就显示 载具属性， 如果 为 nil 的话， 显示 角色本身属性
]]
function HeroController:GetMountAttribute()
	
	if self._mountLangController ~= nil then
		return self._mountLangController:GetAttribute();
	end
	return nil;
end

-- 玩家或自己需要判断是否有载具
function HeroController:GetInfo()
	local info = self:GetMountAttribute()
	if(info) then
		return info
	end
	return self.info
end


function HeroController:HidePet()
	self._isPetHide = true
	-- if(self.pet) then
	-- 	self.petId = self.pet.id
	-- 	PetProxy.SetPetStatus(self.petId, 0)
	-- end
end

function HeroController:ShowPet()
	self._isPetHide = false
	-- if(self.petId ~= nil) then
	-- 	PetProxy.SetPetStatus(self.petId, 1)
	-- 	self.petId = nil
	-- end
end


--[[function HeroController:SetRideTimer()
    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 1, -1, false);
    self._rideTime = 0
    --    self._timer:Start()
end

function HeroController:_OnTimerHandler()
    if (self:IsOnRide()) then
        self._rideTime = 0
    else
        self._rideTime = self._rideTime + 1
        if (self._rideTime > HeroController.RIDEINTERVAL) then
            self._rideTime = 0
            if (RideManager.isRideUse and GameSceneManager.map.info.ride) then
                RideProxy.SendGetOnRide()
            end
        end
    end
end

function HeroController:ResetRideTime()
    self._rideTime = 0
end

function HeroController:StopRideTimer()
    if (self._timer) then
        self._rideTime = 0
        self._timer:Stop()
    end
end

function HeroController:StartRideTimer()
    if (self._timer and not self._timer.running) then
        self._timer:Start()
    end
end
]]
--[[function HeroController:GetMoveSpeed()
    return self.info.move_spd +((self:IsOnRide()) and(self.info.move_spd * 0.01 * self._roleCreater:GetRideInfo().speed_per) or 0)
end
]]
-- 停止动作，actionType = 1：主动作，2：协同动作，3：全部动作
function HeroController:StopAction(actType)
	local aType = actType or 1;
	-- print(">>>>>>>>>>HeroController:StopAction")
	if(aType == 1) then
		if(self._action) then
			self._action:Stop();
		end
	elseif(actType == 2) then
		if(self._cooperation) then
			self._cooperation:Stop();
		end
	elseif(actType == 3) then
		if(self._action) then
			self._action:Stop();
		end
		if(self._cooperation) then
			self._cooperation:Stop();
		end
	end
end

function HeroController:SetPetId(id)
	self.petId = id
end	


function HeroController:LoadLevelUpEffect()
	local go = Resourcer.Get("Effect/UIEffect", "levelUp", self.transform)
	local ui_levup_fly = Resourcer.Get("Effect/UIEffect", "ui_levup_fly", Scene.instance.uiLayer2D)
	
	if(go) then
		Resourcer.RecycleDelay(go, 1.5, true)
		Resourcer.RecycleDelay(ui_levup_fly, 1.5, true)
	end
end

-- 是否显示灯光阴影
function HeroController:ShowLightShadow(val)
	if(self._roleCreater) then
		self._roleCreater:ShadowVisible(not val)
		self._roleCreater:ProjectorVisible(val)
	end
end
-- 设置灯光阴影方向
function HeroController:SetShadowDirction(val)
	if(self._roleCreater) then
		self._roleCreater:SetShadowDirction(val)
	end
end 