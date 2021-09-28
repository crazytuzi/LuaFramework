require "Core.Module.Common.Panel"
require "Core.Module.Common.UIAnimationModel"
require "Core.Module.PVP.View.Item.PVPPlayerItem"
require "Core.Role.ModelCreater.UIRoleModelCreater"

PVPPanel = class("PVPPanel", Panel);
function PVPPanel:New()
	self = {};
	setmetatable(self, {__index = PVPPanel});
	return self
end


function PVPPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateMyPlayer()
	self:UpdatePVPLimitTime()
	self:UpdatePVPPoint()
end

function PVPPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtPVPPoint = UIUtil.GetChildInComponents(txts, "txtPVPPoint");
	self._txtMyFight = UIUtil.GetChildInComponents(txts, "txtMyFight");
	self._txtMyName = UIUtil.GetChildInComponents(txts, "txtMyName");
	self._txtMyLevel = UIUtil.GetChildInComponents(txts, "txtMyLevel");
	self._txtOtherFight = UIUtil.GetChildInComponents(txts, "txtOtherFight");
	self._txtOtherName = UIUtil.GetChildInComponents(txts, "txtOtherName");
	self._txtOtherLevel = UIUtil.GetChildInComponents(txts, "txtOtherLevel");
	self._txtLimitTime = UIUtil.GetChildInComponents(txts, "txtLimitTime");
	self._txtPVPPoionDes = UIUtil.GetChildInComponents(txts, "pvpPoionDes");
	self._txtPVPPoionDes.text = LanguageMgr.Get("pvp/pvpPanel/PVPPointDes")
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._btnFight = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnFight");
	self._btnBuy = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnBuy");
	self._btnRank = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRank");
	self._btnPVPStore = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnPVPStore");
	self._btnChange = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnChange");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "trs/phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, PVPPlayerItem, true)
	self._myRoleParent = UIUtil.GetChildByName(self._trsContent, "imgRole/heroCamera/trsRoleParent1")
	self._otherRoleParent = UIUtil.GetChildByName(self._trsContent, "imgRole/heroCamera/trsRoleParent2")
	
end

function PVPPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnFight = function(go) self:_OnClickBtnFight(self) end
	UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFight);
	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy(self) end
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
	self._onClickBtnRank = function(go) self:_OnClickBtnRank(self) end
	UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRank);
	self._onClickBtnPVPStore = function(go) self:_OnClickBtnPVPStore(self) end
	UIUtil.GetComponent(self._btnPVPStore, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPVPStore);
	self._onClickBtnChange = function(go) self:_OnClickBtnChange(self) end
	UIUtil.GetComponent(self._btnChange, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnChange);
end

function PVPPanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(PVPNotes.CLOSE_PVPPANEL)
end

function PVPPanel:_OnClickBtnChange()
	PVPProxy.SendGetPVPPlayer()
end

function PVPPanel:_OnClickBtnFight()
	if(PVPManager.GetPVPLimitTime() == 0) then
		MsgUtils.ShowTips("pvp/pvpPanel/timeIsNotEnough");
	else
		PVPProxy.SendPVPFight()
	end
	SequenceManager.TriggerEvent(SequenceEventType.Guide.ARENA_DOFIGHT);
end

function PVPPanel:_OnClickBtnBuy()
	local leftBuyTime = VIPManager.GetArenaNum() - PVPManager.GetPVPBuyTime()
	
	if(leftBuyTime == 0) then
		MsgUtils.ShowTips("pvp/pvpPanel/buyTimeLimit");
	else
		local needMoneyConf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BUYPVPTIME)
		local needMoney = needMoneyConf[PVPManager.GetPVPBuyTime() + 1].need_money
		MsgUtils.UseBDGoldConfirm(needMoney, nil, "pvp/pvpPanel/buyNotice", {m = needMoney, t = leftBuyTime}, PVPProxy.BuyPVPTime, nil, nil
		, "common/ok", "common/cancle", "common/notice")		
		-- if(MoneyDataManager.Get_gold() >= needMoney) then
		-- 	local content = LanguageMgr.Get("pvp/pvpPanel/buyNotice", {m = needMoney, t = leftBuyTime})
		-- 	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
		-- 		title = LanguageMgr.Get("common/notice"),
		-- 		msg = content,
		-- 		ok_Label = LanguageMgr.Get("common/ok"),
		-- 		cance_lLabel = LanguageMgr.Get("common/cancle"),
		-- 		hander = PVPProxy.BuyPVPTime,
		-- 	});
		-- else
		-- 	MoneyDataManager.ShowGoldNotEnoughTip()
		-- end
	end
end

function PVPPanel:_OnClickBtnRank()
	ModuleManager.SendNotification(PVPNotes.OPEN_PVPRANKPANEL)
end

function PVPPanel:_OnClickBtnPVPStore()
	--ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, { type = TShopNotes.Shop_type_pvp });
	--ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_fightScene});
     ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 5 });
end

function PVPPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
	if(self._uiMyAnimationModel ~= nil) then
		self._uiMyAnimationModel:Dispose()
		self._uiMyAnimationModel = nil
	end
	
	if(self._uiOtherAnimationModel ~= nil) then
		self._uiOtherAnimationModel:Dispose()
		self._uiOtherAnimationModel = nil
	end
	
	self._phalanx:Dispose()
end

function PVPPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFight = nil;
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnBuy = nil;
	UIUtil.GetComponent(self._btnRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRank = nil;
	UIUtil.GetComponent(self._btnPVPStore, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnPVPStore = nil;
	UIUtil.GetComponent(self._btnChange, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._OnClickBtnChange = nil;
end

function PVPPanel:_DisposeReference()
	self._btn_close = nil;
	self._btnFight = nil;
	self._btnBuy = nil;
	self._btnRank = nil;
	self._btnPVPStore = nil;
	self._btnChange = nil
end

function PVPPanel:UpdatePVPLimitTime()
	self._txtLimitTime.text = tostring(PVPManager.GetPVPLimitTime())
end

function PVPPanel:UpdatePVPPoint()
	self._txtPVPPoint.text = tostring(PlayerManager.spend)
end
function PVPPanel:UpdateOtherPlayerList()
	local playerDatas = PVPManager.GetPVPPlayerData()
	if(playerDatas) then
		local playerCount = table.getCount(playerDatas)
		self._phalanx:Build(playerCount, 1, playerDatas)
		local rank = PVPManager.GetPVPRank()
		local heroId = HeroController:GetInstance().id
		local index = 1
		-- rank为0时表示没排名
		if(rank == 1) then
			index = 2
			PVPProxy.SetSelectData(playerDatas[index])
		else
			index = 1
			PVPProxy.SetSelectData(playerDatas[index])
		end
		
		self._phalanx:GetItem(index).gameObject:GetComponent("UIToggle").value = true
	end
end

function PVPPanel:UpdateMyPlayer()
	local info = HeroController:GetInstance().info
	local myData = RoleModelCreater.CloneDress(info, true, true, false)
	
	
	if(self._uiMyAnimationModel == nil) then
		self._uiMyAnimationModel = UIAnimationModel:New(myData, self._myRoleParent, UIRoleModelCreater)
	else
		self._uiMyAnimationModel:ChangeModel(myData, self._myRoleParent)
	end
	self._txtMyFight.text = tostring(PlayerManager.GetSelfFightPower())
	self._txtMyLevel.text = GetLvDes(info.level)
	self._txtMyName.text = tostring(info.name)
end

function PVPPanel:UpdateOtherPlayer(data)
	if(self._uiOtherAnimationModel == nil) then
		self._uiOtherAnimationModel = UIAnimationModel:New(data, self._otherRoleParent, UIRoleModelCreater)
	else
		self._uiOtherAnimationModel:ChangeModel(data, self._otherRoleParent)
	end
	self._txtOtherFight.text = tostring(data.power)
	self._txtOtherLevel.text = GetLvDes(data.level)
	self._txtOtherName.text = tostring(data.name)
end
