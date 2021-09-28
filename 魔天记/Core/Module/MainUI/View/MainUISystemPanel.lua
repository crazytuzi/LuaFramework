require "Core.Module.MainUI.View.Item.MainUISystemItem"
MainUISystemPanel = class("MainUISystemPanel");


function MainUISystemPanel:Init(transform)
	self.transform = transform;
	self.expand = false;
	self:_initRef();
	self:_initListener();
end

function MainUISystemPanel:_initRef()
	self._trsSys = UIUtil.GetChildByName(self.transform, "Transform", "trsSys");
	self._trsAct = UIUtil.GetChildByName(self.transform, "Transform", "trsAct");
	self._trsActDef = UIUtil.GetChildByName(self.transform, "Transform", "trsAct2");
	self._trsSysPos = self._trsSys.localPosition;
	
	self._icoTogAct = UIUtil.GetChildByName(self.transform, "UISprite", "togAct");
	self._hasMsg = UIUtil.GetChildByName(self._icoTogAct, "UISprite", "hasMsg");
	
	--self._trsSysPhalanx = UIUtil.GetChildByName(self._trsSys, "Transform", "sysPhalanx");
	self._sysPhalanxInfo = UIUtil.GetChildByName(self._trsSys, "LuaAsynPhalanx", "sysPhalanx");
	self._sysPhalanx = Phalanx:New();
	self._sysPhalanx:Init(self._sysPhalanxInfo, MainUISystemItem);
	
	--self._trsActPhalanx = UIUtil.GetChildByName(self._trsAct, "Transform", "actPhalanx");
	self._actPhalanxInfo1 = UIUtil.GetChildByName(self._trsAct, "LuaAsynPhalanx", "actPhalanx1");
	self._actPhalanxInfo2 = UIUtil.GetChildByName(self._trsAct, "LuaAsynPhalanx", "actPhalanx2");
	self._actPhalanxInfo3 = UIUtil.GetChildByName(self._trsAct, "LuaAsynPhalanx", "actPhalanx3");
	self._actPhalanx1 = Phalanx:New();
	self._actPhalanx1:Init(self._actPhalanxInfo1, MainUISystemItem);
	self._actPhalanx2 = Phalanx:New();
	self._actPhalanx2:Init(self._actPhalanxInfo2, MainUISystemItem);
	self._actPhalanx3 = Phalanx:New();
	self._actPhalanx3:Init(self._actPhalanxInfo3, MainUISystemItem);
	
	--self._trsDefActPhalanx = UIUtil.GetChildByName(self._trsActDef, "Transform", "actPhalanx");
	self._defActPhalanxInfo1 = UIUtil.GetChildByName(self._trsActDef, "LuaAsynPhalanx", "actPhalanx1");
	self._defActPhalanxInfo2 = UIUtil.GetChildByName(self._trsActDef, "LuaAsynPhalanx", "actPhalanx2");
	self._defActPhalanxInfo3 = UIUtil.GetChildByName(self._trsActDef, "LuaAsynPhalanx", "actPhalanx3");

	self._defActPhalanx1 = Phalanx:New();
	self._defActPhalanx1:Init(self._defActPhalanxInfo1, MainUISystemItem);
	self._defActPhalanx2 = Phalanx:New();
	self._defActPhalanx2:Init(self._defActPhalanxInfo2, MainUISystemItem);
	self._defActPhalanx3 = Phalanx:New();
	self._defActPhalanx3:Init(self._defActPhalanxInfo3, MainUISystemItem);

	self._iconState = {}
end

function MainUISystemPanel:InitShow()
	self:UpdateDisplay();
	self:UpdateActMode(MainUIPanel.Mode.HIDE);
end

function MainUISystemPanel:SetHasMsgFlg(val)
	self._hasMsg.enabled = val
end

function MainUISystemPanel:SetHeroHeadPanel(v)
	self._hhp = v
end

function MainUISystemPanel:_initListener()
	
	self._onChgMode = function(go) self:_OnChgMode() end
	UIUtil.GetComponent(self._icoTogAct, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onChgMode);
	if GameConfig.instance.debugFlg then
		UIUtil.GetComponent(self._icoTogAct, "LuaUIEventListener"):RegisterDelegate("OnDoubleClick",
		function() self:OnItemClick(SystemConst.Id.GM) end)
	end
	
	--MessageManager.AddListener(MainUINotes, MainUINotes.EVENT_SYSITEM_CLICK, MainUISystemPanel.OnItemClick, self);
	--MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, MainUISystemPanel.UpdateIcons, self);
	MessageManager.AddListener(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS, MainUISystemPanel.UpdateIcons, self);
	
	self:_UpdateMsgListen()
	if not self._msgTimer then
		self._msgTimer = Timer.New(function()
			if self._sysPhalanx == nil then return end
			local its = self:_GetItems()
			self:UpdateMsgSale(its)
			self:_UpdateMsg(its, SystemConst.Id.XIANMENG, SystemManager.GetHasTong() or GuildDataManager.GetRedPoint())
			self:UpdateMsgImmortalShop(its)
			self:_UpdateMsgs(its)
			self._msgTimer = nil
		end, 5, 1, true):Start()
	end
end

--货币， 物品变化事件
function MainUISystemPanel:_UpdateMsgs(its)
	if self._updateDelay then return end
	self._updateDelay = true
	self._msgTimer = Timer.New(function()
		self._updateDelay = false
		self._msgTimer = nil
	end, 2, 1, true):Start()
	if not its then its = self:_GetItems() end
	--for i = #its, 1, -1 do its[i].itemLogic:SetHasMsgFlg(false) end
	self:UpdateMsgRole(its)
	self:UpdateMsgTrump(its)
	self:UpdateMsgRide(its)
	self:UpdateMsgRecharge(its)
	self:UpdateMsgEqu(its)
	self:UpdateMsgSkill(its)
	self:UpdateMsgRealm(its)
	self:UpdateMsgPartner(its)
	self:UpdateMsgWelfare(its)
	self:UpdateMsgActivity(its);
	self:UpdateMsgWing(its)
	self:UpdateMsgLot(its)
	self:UpdateMsgRechargetAward(its)
	self:UpdateMsgWiseEquip(its);
	self:UpdateMsgFormation(its)
	self:UpdateMsgStar(its)
	
	self:UpdateMsgMidAutumn(its)
	self:_UpdateMsgMenu()
end

--独立事件更新监听
function MainUISystemPanel:_UpdateAllMsg()
	local its = self:_GetItems()
	self:UpdateMsgSale(its)
	--self:UpdateMsgDaysRank(its)
	--self:UpdateMsgXuanBao(its)
	self:UpdateMsgAlliance(its)
	self:UpdateMsgTrumpNew(its)
	self:UpdateMsgImmortalShop(its)
	self:UpdateMsgAppSpite(its)
	self:UpdateMsgAppGift(its)
	self:UpdateMsgDaysTarget(its)
	--self:UpdateMsgLottery(its)
	self:UpdateMsgGroup1(its)
	self:UpdateMsgGroup2(its)
	self:UpdateMsgCloudPurchase(its)
	self:_UpdateMsgs(its)
end
function MainUISystemPanel:UpdateMsgRole(its)	-- 角色
	if not SystemManager.IsOpen(SystemConst.Id.ROLE) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.ROLE, AchievementManager.GetIsAchievementFinish())
	--or FormationManager.HasTips())
end
function MainUISystemPanel:UpdateMsgTrump(its)	-- 法宝
	if not SystemManager.IsOpen(SystemConst.Id.XINFABAO) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.XINFABAO, NewTrumpManager.CanTrumpMsg())
end
function MainUISystemPanel:UpdateMsgTrumpNew()	-- 法宝
	if not SystemManager.IsOpen(SystemConst.Id.XINFABAO) then return end
	self:_UpdateMsg(self:_GetItems(), SystemConst.Id.XINFABAO, NewTrumpManager.CanTrumpMsg())
	self:_UpdateMsgMenu()
end
function MainUISystemPanel:UpdateMsgRide(its)	-- 坐骑
	if not SystemManager.IsOpen(SystemConst.Id.MOUNT) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.MOUNT, RideManager.GetCanActive())
end
function MainUISystemPanel:UpdateMsgRecharge(its)	-- 首充
	if not SystemManager.IsOpen(SystemConst.Id.FIRSTRECHARGEAWARD) then return end
	if not its then its = self:_GetItems() end
	local flg = VIPManager.GetFristRechargeCanGetAward()
	self:_UpdateMsg(its, SystemConst.Id.FIRSTRECHARGEAWARD, flg)
	--self:_UpdateMsg(its, SystemConst.Id.FIRSTRECHARGEAWARD2, flg)
end
function MainUISystemPanel:UpdateMsgEqu(its)	-- 装备
	if not SystemManager.IsOpen(SystemConst.Id.EQUIP) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.EQUIP, EquipDataManager.CheckMainEqBtNeedShowTip())
end
function MainUISystemPanel:UpdateMsgSkill(its)	-- 技能
	if not SystemManager.IsOpen(SystemConst.Id.SKILL) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.SKILL, SkillManager.GetRedPoint())
end
function MainUISystemPanel:UpdateMsgRealm(its)	-- 境界
	if not SystemManager.IsOpen(SystemConst.Id.REALM) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.REALM, RealmManager.CanRealm())
end
function MainUISystemPanel:UpdateMsgPartner(its)	-- 伙伴
	if not SystemManager.IsOpen(SystemConst.Id.PET) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.PET, PetManager.HasMsg())
end
function MainUISystemPanel:UpdateMsgAlliance(its) 	-- 仙盟
	if not SystemManager.IsOpen(SystemConst.Id.XIANMENG) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.XIANMENG, GuildDataManager.GetRedPoint())
end
function MainUISystemPanel:UpdateMsgAllianceNew() 	-- 仙盟
	if not SystemManager.IsOpen(SystemConst.Id.XIANMENG) then return end
	self:_UpdateMsg(self:_GetItems(), SystemConst.Id.XIANMENG, SystemManager.GetHasTong() or GuildDataManager.GetRedPoint())
	self:_UpdateMsgMenu()
end
function MainUISystemPanel:UpdateMsgWing(its)	-- 翅膀
	if not SystemManager.IsOpen(SystemConst.Id.WING) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.WING, WingManager.CanWingAdvance())
end
function MainUISystemPanel:UpdateMsgSale(its)	-- 寄售
	if not SystemManager.IsOpen(SystemConst.Id.SKILL) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.SALE, SaleManager.GetRedPoint())
end
function MainUISystemPanel:UpdateMsgLot(its)-- 仙缘
	if not SystemManager.IsOpen(SystemConst.Id.Lot) then return end
	if not its or type(its) == 'number' then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.Lot, LotProxy.HasMsg())
end
--[[function MainUISystemPanel:UpdateMsgDaysRank(its)-- 开服活动
	if not SystemManager.IsOpen(SystemConst.Id.DAYSRANK) then return end
	if not its then its = self:_GetItems() end
	local b = DaysRankProxy.GetRedPoint();
	self:_UpdateMsg(its, SystemConst.Id.DAYSRANK, b)
	--self:_UpdateMsg(its, SystemConst.Id.DAYSRANK2, b)
end
function MainUISystemPanel:UpdateMsgXuanBao(its)-- 玄宝
	if not SystemManager.IsOpen(SystemConst.Id.XUANBAO) then return end
	if not its then its = self:_GetItems() end
	local b = XuanBaoManager.GetRedPoint();
	self:_UpdateMsg(its, SystemConst.Id.XUANBAO, b)
end
]]
function MainUISystemPanel:UpdateMsgWiseEquip(its)-- 仙器
	if not SystemManager.IsOpen(SystemConst.Id.WiseEquip) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.WiseEquip, EquipDataManager.WiseEquipCanDo())
end

function MainUISystemPanel:UpdateMsgRechargetAward2()-- 单笔充值活动
	self:UpdateMsgRechargetAward()
end
function MainUISystemPanel:UpdateMsgRechargetAward(its)-- 单笔充值活动
	if not SystemManager.IsOpen(SystemConst.Id.RechargeAward) then return end
	if not its then its = self:_GetItems() end
	local f = RechargeAwardProxy.HasTip()
	--Warning("_______" .. tostring( f) .. tostring(#its))
	self:_UpdateMsg(its, SystemConst.Id.RechargeAward, f)
end

function MainUISystemPanel:UpdateMsgWelfare(its)
	if not SystemManager.IsOpen(SystemConst.Id.Weal) then return end
	-- 福利
	if not its then its = self:_GetItems() end
	local flg = SignInProxy.GetcangetChongJiAwards()
	-- 升级
	if not flg then flg = OnlineRewardManager.IsCanGetInLineAward() end
	-- 在线奖励
	if not flg then flg = Login7RewardManager.IsCanGetAward() end
	-- 15 天奖励
	if not flg then flg = SignInManager.GetCanSignToday() end
	-- 签到
	if not flg then flg = VIPManager.CanGetDailyAward() end
	-- 奖励找回
	if not flg then flg = SignInManager.CanRevertAward() end
	-- vip每日礼包
	--Warning(tostring(OnlineRewardManager.IsCanGetInLineAward()) .. tostring(Login7RewardManager.IsCanGetAward()))
	--Warning(tostring(SignInManager.GetCanSignToday()) .. tostring( VIPManager.CanGetDailyAward()))
	--Warning(tostring(SignInProxy.GetcangetChongJiAwards()) .. tostring( SignInManager.CanRevertAward()))
	self:_UpdateMsg(its, SystemConst.Id.Weal, flg)
end

function MainUISystemPanel:UpdateMsgActivity(its)-- 活动信息
	if not SystemManager.IsOpen(SystemConst.Id.ACTIVITY) then return end
	if not its then its = self:_GetItems() end
	local flg = ActivityDataManager.CheckMainMemuShowPoint();
	self:_UpdateMsg(its, SystemConst.Id.ACTIVITY, flg);
	--self:_UpdateMsg(its, SystemConst.Id.ACTIVITY2, flg);
end

function MainUISystemPanel:UpdateMsgDaysTarget(its)-- 七日目标
	if not SystemManager.IsOpen(SystemConst.Id.DaysTarget) then return end
	if not its then its = self:_GetItems() end
	local flg = DaysTargetProxy.GetRedPoint();
	self:_UpdateMsg(its, SystemConst.Id.DaysTarget, flg);
end

function MainUISystemPanel:UpdateMsgImmortalShop(its)-- 摩天商店
	if not SystemManager.IsOpen(SystemConst.Id.ImmortalShop) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.ImmortalShop, ImmortalShopProxy.GetRedPoint())
end
function MainUISystemPanel:UpdateMsgFormation(its)-- 阵图
	if not SystemManager.IsOpen(SystemConst.Id.Formation) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.Formation, FormationManager.HasTips())
end
function MainUISystemPanel:UpdateMsgStar(its)-- 命星
	if not SystemManager.IsOpen(SystemConst.Id.FABAO) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.FABAO, StarManager.HasTips())
end

function MainUISystemPanel:UpdateMsgLottery(its)-- 宝库
	if not SystemManager.IsOpen(SystemConst.Id.LOTTERY) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.LOTTERY, LotteryManager.GetIsFree())
end

function MainUISystemPanel:UpdateMsgAppSpite(its)-- 分包下载
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.APP_DOWN, AppSplitDownProxy.HasAward())
end

function MainUISystemPanel:UpdateMsgAppGift(its)-- 超值
	--Warning(tostring(ActivityGiftsProxy.HasTips())..tostring(SystemManager.IsOpen(SystemConst.Id.ACTIVITY_GIFTS)))
	if not SystemManager.IsOpen(SystemConst.Id.ACTIVITY_GIFTS) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.ACTIVITY_GIFTS, ActivityGiftsProxy.HasTips())
end

function MainUISystemPanel:UpdateMsgMidAutumn(its) --中秋节
	if not SystemManager.IsOpen(SystemConst.Id.MidAutumn) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.MidAutumn, FestivalMgr.HasTips())
end

function MainUISystemPanel:UpdateMsgCloudPurchase(its)
if not SystemManager.IsOpen(SystemConst.Id.CloudPurchase) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.CloudPurchase, CloudPurchaseManager.GetRedPoint())
end

function MainUISystemPanel:UpdateMsgGroup1(its)
	if not SystemManager.IsOpen(SystemConst.Id.Group_1) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.Group_1, SystemManager.GetRedPoint(SystemConst.Id.Group_1))
end

function MainUISystemPanel:UpdateMsgGroup2(its)
	if not SystemManager.IsOpen(SystemConst.Id.Group_2) then return end
	if not its then its = self:_GetItems() end
	self:_UpdateMsg(its, SystemConst.Id.Group_2, SystemManager.GetRedPoint(SystemConst.Id.Group_2))
end

function MainUISystemPanel:_OnMoneyChange()
	local its = self:_GetItems()
	self:UpdateMsgTrumpNew(its)
end

function MainUISystemPanel:_GetItems()
	return self._items
end
function MainUISystemPanel:_UpdateMsg(its, id, flg)
	self._iconState[id] = flg
	--local s = ''
	for i = #its, 1, - 1 do
		v = its[i].itemLogic
		--s = s .. (v and v:GetId() or '-') ..','
		if v and v:GetId() == id then
			v:SetHasMsgFlg(flg)
		end
	end
	--Warning(id..'__'..tostring(flg)..'_____'..s)
end
function MainUISystemPanel:_UpdateMsgListen()
	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, MainUISystemPanel._UpdateMsgs, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_ZHENQI_CHANGE, MainUISystemPanel._UpdateMsgs, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_XIUWEI_CHANGE, MainUISystemPanel._UpdateMsgs, self);
	
	MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG, MainUISystemPanel.UpdateMsgAllianceNew, self);
	MessageManager.AddListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, MainUISystemPanel.UpdateMsgAllianceNew, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE, MainUISystemPanel.UpdateMsgAllianceNew, self);
	MessageManager.AddListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, MainUISystemPanel.UpdateMsgAllianceNew, self);
	MessageManager.AddListener(GuildDataManager, GuildDataManager.HONGBAOREDPOINT, MainUISystemPanel.UpdateMsgAlliance, self);
	
	MessageManager.AddListener(OnlineRewardManager, OnlineRewardManager.MESSAGE_ONLINEREWARD_DATA_CHANGE, MainUISystemPanel.UpdateMsgWelfare, self);
	MessageManager.AddListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_CHANGE, MainUISystemPanel.UpdateMsgActivity, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, MainUISystemPanel._OnMoneyChange, self);
	MessageManager.AddListener(NewTrumpManager, NewTrumpManager.ActiveTrump, MainUISystemPanel.UpdateMsgTrumpNew, self);
	
	MessageManager.AddListener(SaleManager, SaleManager.SALEMONEYCHANGE, MainUISystemPanel.UpdateMsgSale, self);
	MessageManager.AddListener(LotNotes, LotNotes.CHANGE_LOT_INFO, MainUISystemPanel.UpdateMsgLot, self);
	MessageManager.AddListener(DaysRankNotes, DaysRankNotes.ENV_DAYS_AWARD_CHG, MainUISystemPanel.UpdateMsgGroup1, self);
	MessageManager.AddListener(SignInNotes, SignInNotes.UPDATE_SIGNINPANELTIP, MainUISystemPanel.UpdateMsgWelfare, self);	
	MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.WISEEQUIPATTCHANGE, MainUISystemPanel.UpdateMsgWiseEquip, self);	
	MessageManager.AddListener(RechargeAwardNotes, RechargeAwardNotes.RECHARGET_CHANGE, MainUISystemPanel.UpdateMsgRechargetAward2, self)
	MessageManager.AddListener(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG, MainUISystemPanel.UpdateMsgDaysTarget, self)
	MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE, MainUISystemPanel.UpdateMsgImmortalShop, self)
	MessageManager.AddListener(FormationNotes, FormationNotes.FORMATION_CHANGE, MainUISystemPanel.UpdateMsgFormation, self)
	MessageManager.AddListener(MainUINotes, MainUINotes.ARTIFACT_CHANGE, MainUISystemPanel.UpdateMsgRole, self)
	MessageManager.AddListener(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG, MainUISystemPanel.UpdateMsgGroup1, self);
	MessageManager.AddListener(StarNotes, StarNotes.STAR_DATA_CHANGE, MainUISystemPanel.UpdateMsgStar, self)
	MessageManager.AddListener(LotteryManager, LotteryManager.LOTTERY_REDPOINT, MainUISystemPanel.UpdateMsgGroup2, self)	
	MessageManager.AddListener(AppSplitDownNotes, AppSplitDownNotes.APPSPLITDOWN_CHANGE, MainUISystemPanel.UpdateMsgAppSpite, self)
	MessageManager.AddListener(ActivityGiftsNotes, ActivityGiftsNotes.UPDATE_ACTIVITY_GIFT_MSGS, MainUISystemPanel.UpdateMsgAppGift, self)
	MessageManager.AddListener(CloudPurchaseManager, CloudPurchaseManager.RedPointChange, MainUISystemPanel.UpdateMsgCloudPurchase,self)
	MessageManager.AddListener(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE, MainUISystemPanel.UpdateMsgMidAutumn, self)
end
function MainUISystemPanel:_UpdateMsgMenu()
	self:_UpdateMsgHeadMenu()
	self:_UpdateMsgFuncMenu()
end
function MainUISystemPanel:_UpdateMsgHeadMenu()
	local flg = false
	if not self.expand and GameSceneManager.GetMapId() ~= "10012_06" then
		local t = self._sysPhalanx:GetItems()
		for i = #t, 1, - 1 do
			v = t[i]
			flg = self._iconState[v.data.id]
			if flg then break end
		end
	end
	self._hhp:SetHasMsgFlg(flg)
end
function MainUISystemPanel:_UpdateMsgFuncMenu()
	local flg = false
	local t = self.expandAct2 and self._actItems or self._defActItems
	for i = #t, 1, - 1 do
		v = t[i]
		flg = self._iconState[v.data.id]
		if flg then break end
	end
	self:SetHasMsgFlg(flg)
end

function MainUISystemPanel:Dispose()
	self._sysPhalanx:Dispose();
	self._sysPhalanx = nil
	self._actPhalanx1:Dispose();
	self._actPhalanx1 = nil
	self._actPhalanx2:Dispose();
	self._actPhalanx2 = nil
	self._actPhalanx3:Dispose();
	self._actPhalanx3 = nil

	self._defActPhalanx1:Dispose();
	self._defActPhalanx1 = nil
	self._defActPhalanx2:Dispose();
	self._defActPhalanx2 = nil
	self._defActPhalanx3:Dispose();
	self._defActPhalanx3 = nil
	
	UIUtil.GetComponent(self._icoTogAct, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onChgMode = nil;
	
	--MessageManager.RemoveListener(MainUINotes, MainUINotes.EVENT_SYSITEM_CLICK, MainUISystemPanel.OnItemClick);
	--MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, MainUISystemPanel.UpdateIcons);
	MessageManager.RemoveListener(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS, MainUISystemPanel.UpdateIcons);
	
	MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, MainUISystemPanel._UpdateMsgs)
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_ZHENQI_CHANGE, MainUISystemPanel._UpdateMsgs);
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_XIUWEI_CHANGE, MainUISystemPanel._UpdateMsgs);
	
	MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_BEVERTIFY_CHG, MainUISystemPanel.UpdateMsgAllianceNew);
	MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_NTF_LEVELUP, MainUISystemPanel.UpdateMsgAllianceNew);
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE, MainUISystemPanel.UpdateMsgAllianceNew);
	MessageManager.RemoveListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, MainUISystemPanel.UpdateMsgAllianceNew);
	MessageManager.RemoveListener(GuildDataManager, GuildDataManager.HONGBAOREDPOINT, MainUISystemPanel.UpdateMsgAlliance);
	
	MessageManager.RemoveListener(OnlineRewardManager, OnlineRewardManager.MESSAGE_ONLINEREWARD_DATA_CHANGE, MainUISystemPanel.UpdateMsgWelfare);
	MessageManager.RemoveListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_CHANGE, MainUISystemPanel.UpdateMsgActivity);
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, MainUISystemPanel._OnMoneyChange);
	MessageManager.RemoveListener(NewTrumpManager, NewTrumpManager.ActiveTrump, MainUISystemPanel.UpdateMsgTrumpNew);
	
	MessageManager.RemoveListener(SaleManager, SaleManager.SALEMONEYCHANGE, MainUISystemPanel.UpdateMsgSale);
	MessageManager.RemoveListener(LotNotes, LotNotes.CHANGE_LOT_INFO, MainUISystemPanel.UpdateMsgLot)
	MessageManager.RemoveListener(DaysRankNotes, DaysRankNotes.ENV_DAYS_AWARD_CHG, MainUISystemPanel.UpdateMsgGroup1);
	MessageManager.RemoveListener(SignInNotes, SignInNotes.UPDATE_SIGNINPANELTIP, MainUISystemPanel.UpdateMsgWelfare)
	MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.WISEEQUIPATTCHANGE, MainUISystemPanel.UpdateMsgWiseEquip);	
	MessageManager.RemoveListener(RechargeAwardNotes, RechargeAwardNotes.RECHARGET_CHANGE, MainUISystemPanel.UpdateMsgRechargetAward2)
	MessageManager.RemoveListener(DaysTargetNotes, DaysTargetNotes.RSP_AWARD_CHG, MainUISystemPanel.UpdateMsgDaysTarget)
	MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE, MainUISystemPanel.UpdateMsgImmortalShop)
	MessageManager.RemoveListener(FormationNotes, FormationNotes.FORMATION_CHANGE, MainUISystemPanel.UpdateMsgFormation)
	MessageManager.RemoveListener(MainUINotes, MainUINotes.ARTIFACT_CHANGE, MainUISystemPanel.UpdateMsgRole)
	MessageManager.RemoveListener(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG, MainUISystemPanel.UpdateMsgGroup1)
	MessageManager.RemoveListener(StarNotes, StarNotes.STAR_DATA_CHANGE, MainUISystemPanel.UpdateMsgStar)
	MessageManager.RemoveListener(LotteryManager, LotteryManager.LOTTERY_REDPOINT, MainUISystemPanel.UpdateMsgGroup2)		
	MessageManager.RemoveListener(AppSplitDownNotes, AppSplitDownNotes.APPSPLITDOWN_CHANGE, MainUISystemPanel.UpdateMsgAppSpite)
	MessageManager.RemoveListener(ActivityGiftsNotes, ActivityGiftsNotes.UPDATE_ACTIVITY_GIFT_MSGS, MainUISystemPanel.UpdateMsgAppGift)
	MessageManager.RemoveListener(CloudPurchaseManager, CloudPurchaseManager.RedPointChange, MainUISystemPanel.UpdateMsgCloudPurchase,self)
	MessageManager.RemoveListener(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE, MainUISystemPanel.UpdateMsgMidAutumn, self)
	
	if self._msgTimer then
		self._msgTimer:Stop()
		self._msgTimer = nil
	end
end

function MainUISystemPanel:_OnChgMode()
	
	if InstanceDataManager.IsInInstance() == false then
		
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_ACTLIST_TOGGLE);
		
		self.mode = self.mode == MainUIPanel.Mode.SHOW and MainUIPanel.Mode.HIDE or MainUIPanel.Mode.SHOW;
		self:UpdateActMode(self.mode);
		
	end
end

function MainUISystemPanel:UpdateDisplay()
	self.sysList = SystemManager.GetList(SystemConst.Type.SYS);
	self.actList = SystemManager.GetList(SystemConst.Type.ACT);
	--self.actList2 = SystemManager.GetList(SystemConst.Type.ACT2);
	self:UpdateIcons();
end

function MainUISystemPanel:UpdateIcons()
	local syslist = SystemManager.Filter(self.sysList);
	self._sysPhalanx:Build(2, 7, syslist);
	local actList = SystemManager.Filter(self.actList);
	local act1 = {};
	local act2 = {};
	local act3 = {};
	for i, v in ipairs(actList) do 
		if v.rank_num == 1 then
			table.insert(act1, v);
		elseif v.rank_num == 2 then
			table.insert(act2, v);
		elseif v.rank_num == 3 then
			table.insert(act3, v);
		end
	end
	self._actPhalanx1:Build(1, 8, act1);
	self._actPhalanx2:Build(1, 8, act2);
	self._actPhalanx3:Build(1, 8, act3);

	local defActList = SystemManager.Filter(self.actList, function(v) return v.showExt end);
	local dAct1 = {};
	local dAct2 = {};
	local dAct3 = {};
	for i, v in ipairs(defActList) do 
		if v.rank_num == 1 then
			table.insert(dAct1, v);
		elseif v.rank_num == 2 then
			table.insert(dAct2, v);
		elseif v.rank_num == 3 then
			table.insert(dAct3, v);
		end
	end
	self._defActPhalanx1:Build(1, 8, dAct1);
	self._defActPhalanx2:Build(1, 8, dAct2);
	self._defActPhalanx3:Build(1, 8, dAct3);

	local its = {}
	table.AddRange(its, self._sysPhalanx:GetItems())
	
	local actIts = {};
	table.AddRange(actIts, self._actPhalanx1:GetItems());
	table.AddRange(actIts, self._actPhalanx2:GetItems());
	table.AddRange(actIts, self._actPhalanx3:GetItems());
	
	local defActIts = {};
	table.AddRange(defActIts, self._defActPhalanx1:GetItems());
	table.AddRange(defActIts, self._defActPhalanx2:GetItems());
	table.AddRange(defActIts, self._defActPhalanx3:GetItems());

	self._actItems = actIts;
	table.AddRange(its, self._actItems)

	self._defActItems = defActIts;
	table.AddRange(its, self._defActItems)

	self._items = its
	
	for i = #self._items, 1, - 1 do
		self._items[i].itemLogic:SetHasMsgFlg(false)
	end
	self:_UpdateAllMsg()
end

function MainUISystemPanel:UpdateActMode(mode)
	self.mode = mode;
	self.expandAct2 = mode == MainUIPanel.Mode.HIDE
	if self.expandAct2 then
		self._trsAct.gameObject:SetActive(false);
		self._trsActDef.gameObject:SetActive(true);
		self._icoTogAct.spriteName = "actTog2";
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_ACTLIST_HIDE);
	else
		self._trsAct.gameObject:SetActive(true);
		self._trsActDef.gameObject:SetActive(false);
		self._icoTogAct.spriteName = "actTog";
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_ACTLIST_SHOW);
	end
	self._icoTogAct:MakePixelPerfect();
	self:_UpdateMsgFuncMenu()
end

function MainUISystemPanel:SetSysDisplay(mode)
	self.expand = mode == MainUIPanel.Mode.SHOW;
	local pos = self.expand and self._trsSysPos - Vector3(0, 200, 0) or self._trsSysPos;
	Util.SetLocalPos(self._trsSys, pos.x, pos.y, pos.z)
	--    self._trsSys.localPosition = pos;
	self:_UpdateMsgHeadMenu()
end

function MainUISystemPanel:Toggle()
	self.expand = not self.expand;
	if self.expand then
		self:UpdateActMode(MainUIPanel.Mode.HIDE);
		-- log("SHOW_START")
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_SYSLIST_SHOW_START);
	else
		-- log("HIDE_START")
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_SYSLIST_HIDE_START);
	end
	self:DoMove();
	self:_UpdateMsgHeadMenu()
end

function MainUISystemPanel:SysHide()
	self.expand = false;
	-- log("SYSLIST_HIDE_START")
	SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_SYSLIST_HIDE_START);
	self:DoMove();
	self:_UpdateMsgHeadMenu()
end

function MainUISystemPanel:CheckClickGo(go)
	if go.transform.parent and go.transform.parent.parent then
		local p = go.transform.parent.parent;
		if p == self._trsSys
		or p == self._trsAct
		or p == self._trsActDef then
			local sysId = tonumber(go.name);
			self:OnItemClick(sysId);
		end
	end
	if(self.expand) then
		self:SysHide();
	end
end

function MainUISystemPanel:DoMove()
	local pos = self.expand and self._trsSysPos - Vector3(0, 200, 0) or self._trsSysPos;
	local comfun = function() self:DoMoveEnd() end;
	LuaDOTween.OnComplete(LuaDOTween.DOLocalMove(self._trsSys, pos, 0.362), comfun);
end

function MainUISystemPanel:DoMoveEnd()
	if self.expand then
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_SYSLIST_SHOW);
	else
		SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_SYSLIST_HIDE);
	end
end

function MainUISystemPanel:OnItemClick(sysId)
	-- local sysId = cfg.id;
	-- SequenceManager.TriggerEvent(SequenceEventType.Guide.MAINUI_ITEM_CLICK, sysId);
	--  log("-------OnItemClick--------- "..sysId);
	local cfg = SystemManager.GetCfg(sysId);
	
	if cfg.group and #cfg.group > 0 then
		ModuleManager.SendNotification(MainUINotes.OPEN_SYS_EXPAND_PANEL, sysId);
		return;	 
	end
	
	SystemManager.Nav(sysId);
end

function MainUISystemPanel:SetIconActive(active)
	self._icoTogAct.gameObject:SetActive(active)
	self._trsActDef.gameObject:SetActive(active)
end 