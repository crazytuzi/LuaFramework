require "Core.Module.Common.Panel";
local YaoShouBossPanel = class("YaoShouBossPanel", Panel);
local YaoShouBossItem = require "Core.Module.YaoShou.View.YaoShouBossItem";

function YaoShouBossPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function YaoShouBossPanel:_InitReference()
	self._index = 1
	self._trsView = UIUtil.GetChildByName(self._trsContent, "Transform", "trsView/trsField");
	self._dynamicPanel = UIUtil.GetChildByName(self._trsView, "DynamicPanel")
	self._btn_help = UIUtil.GetChildByName(self._trsView, "UIButton", "btn_help");
	
	--self._toggleFocus = UIUtil.GetChildByName(self._dynamicPanel, "UIToggle", "checkBox")
	
	self._bossphalanInfo = UIUtil.GetChildByName(self._trsView, "LuaAsynPhalanx", "scrollview/phalanx")
	self._bossphalanx = Phalanx:New()
	self._bossphalanx:Init(self._bossphalanInfo, YaoShouBossItem)
	
	self._rewardPhalanxInfo = UIUtil.GetChildByName(self._dynamicPanel, "LuaAsynPhalanx", "phalanx")
	--self._rewardPhalanx = Phalanx:New()
	--self._rewardPhalanx:Init(self._rewardPhalanxInfo, PropsItem)
	self._rewards = {};
	for i = 1, 4 do 
		local trs = UIUtil.GetChildByName(self._dynamicPanel, "Transform", "phalanx/item" .. i);
		self._rewards[i] = PropsItem.New();
		self._rewards[i]:Init(trs.gameObject);
	end

	--self._txtTime = UIUtil.GetChildByName(self._dynamicPanel, "UILabel", "txtTime")
	self._txtAward1 = UIUtil.GetChildByName(self._dynamicPanel, "UILabel", "txtAward1")
	self._txtAward2 = UIUtil.GetChildByName(self._dynamicPanel, "UILabel", "txtAward2")
	self._txtRequireFight = UIUtil.GetChildByName(self._dynamicPanel, "UILabel", "txtRequireFight")
	
	self._trsRoleParent = UIUtil.GetChildByName(self._dynamicPanel, "imgRole/heroCamera/trsRoleParent");
	--self._goRecorder = UIUtil.GetChildByName(self._dynamicPanel, "btnRecorder").gameObject
	self._goEnter = UIUtil.GetChildByName(self._dynamicPanel, "btnEnter").gameObject
	
	self._scrollview = UIUtil.GetChildByName(self._trsView, "UIScrollView", "scrollview")
	self._centerOnChild = UIUtil.GetChildByName(self._trsView, "UICenterOnChild", "scrollview/phalanx")
	self._cocDelegate = function(go) self:_OnCenterCallBack(go) end
	self._centerOnChild.onCenter = self._cocDelegate;
	
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._onClickBtn_close = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

	-- self._centerOnChild.onFinished = self._onfinish
	self._onClickBtn_help = function(go) self:_OnClickBtn_help(self) end
	UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_help);
	--self._onClickToggle = function(go) self:_OnClickToggle(self) end
	--UIUtil.GetComponent(self._toggleFocus, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	--self._onClickRecorder = function(go) self:_OnClickRecorder(self) end
	--UIUtil.GetComponent(self._goRecorder, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickRecorder);
	self._onClickEnter = function(go) self:_OnClickEnter(self) end
	UIUtil.GetComponent(self._goEnter, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickEnter);
	
	self._isInit = false
	self._currentGo = nil
end
 
function YaoShouBossPanel:_InitListener()
	MessageManager.AddListener(YaoShouNotes, YaoShouNotes.EVENT_SELECT_BOSS, YaoShouBossPanel.SetCurrentSelect, self);
	MessageManager.AddListener(YaoShouNotes, YaoShouNotes.RSP_INFO, YaoShouBossPanel.OnRspInfo, self);
end
 
function YaoShouBossPanel:_Dispose()	
	self:_DisposeListener();
	self:_DisposeReference();
end

function YaoShouBossPanel:_DisposeListener()
	MessageManager.RemoveListener(YaoShouNotes, YaoShouNotes.EVENT_SELECT_BOSS, YaoShouBossPanel.SetCurrentSelect);
	MessageManager.RemoveListener(YaoShouNotes, YaoShouNotes.RSP_INFO, YaoShouBossPanel.OnRspInfo);
end
 
function YaoShouBossPanel:_DisposeReference()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

	UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_help = nil;
	--UIUtil.GetComponent(self._toggleFocus, "LuaUIEventListener"):RemoveDelegate("OnClick");
	--self._onClickToggle = nil;
	--UIUtil.GetComponent(self._goRecorder, "LuaUIEventListener"):RemoveDelegate("OnClick");
	--self._onClickRecorder = nil;
	UIUtil.GetComponent(self._goEnter, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickEnter = nil;
	
	self._btn_help = nil;
	self._trsRoleParent = nil;
	
	self._bossphalanx:Dispose()
	self._bossphalanx = nil
	--self._rewardPhalanx:Dispose()
	--self._rewardPhalanx = nil

	for i, v in ipairs(self._rewards) do 
		v:Dispose();
	end
	
	self._cocDelegate = nil;
	if self._centerOnChild and self._centerOnChild.onCenter then
		self._centerOnChild.onCenter:Destroy()
	end
	
	self._currentGo = nil
end

function YaoShouBossPanel:_OnClickBtnClose()
	--SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(YaoShouNotes.CLOSE_YAOSHOUPANEL);
end

function YaoShouBossPanel:_OnClickBtn_help()
	ModuleManager.SendNotification(YaoShouNotes.OPEN_YAOSHOU_HELP_PANEL)	
end

function YaoShouBossPanel:_OnClickEnter()
	
	local hero = PlayerManager.hero;
	if(hero.info.level >= self._currentSelectBoss.mapInfo.level and not hero:IsDie()) then
		hero:StopAction(3);	
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
			title = LanguageMgr.Get("common/notice"),
			msg = LanguageMgr.Get("YaoShouBossPanel/enternotice"),
			ok_Label = LanguageMgr.Get("common/agree"),
			cance_lLabel = LanguageMgr.Get("common/cancle"),
			hander = YaoShouBossPanel.AgreeEnter,			
			target = self;
		});
	else
		MsgUtils.ShowTips("YaoShouBossPanel/levelNotEnough");
	end
	
end

function YaoShouBossPanel:AgreeEnter()
	local to = {}
	to.sid = self._currentSelectBoss.boss_born_map;
	to.ln = self._currentSelectBoss.ln;
	to.position = Convert.PointFromServer(self._currentSelectBoss.boss_born_point[1], 0, self._currentSelectBoss.boss_born_point[2]);
	--to.moveToPos = Convert.PointFromServer(self._currentSelectBoss.boss_guide_point[1], 0, self._currentSelectBoss.boss_guide_point[2]);
	
	WildBossProxy.SendCheckLine(to)
end

function YaoShouBossPanel:SetIndex(index)
	self._index = index or 1
end

function YaoShouBossPanel:_Opened()
	YaoShouProxy.ReqInfo();
end

function YaoShouBossPanel:_OnCenterCallBack(go)
	
	if(self._isInit == false) then
		return
	end
	if(self._currentGo == go) then
		return
	end
	
	self._currentGo = go;
	local index = self._bossphalanx:GetItemIndex(go)
	
	self._bossphalanx:GetItem(index).itemLogic:SetToggleActive(true)
end

local _red = "C0392B"
local _green = "77FF47"

function YaoShouBossPanel:OnRspInfo()
	local data = YaoShouManager.GetAllBossData()

	table.sort(data, function(a,b) 
		if a.rt == b.rt then return a.id < b.id end 
			if not a.rt then return false; end
			if not b.rt then return true; end
			return a.rt < b.rt
		end
	);

	self._bossphalanx:Build(#data, 1, data)
	--self._txtTime.text = WildBossManager.GetRoundDes()
	
	if(self._currentSelectBoss == nil) then	
		
		self._bossphalanx:GetItem(self._index).itemLogic:SetToggleActive(true)
		
		self._scrollview:MoveRelative(Vector3.up * 110 *(self._index - 1))
		self._scrollview:UpdatePosition()
	end

	--策划王淼要求的 显示内容后端半变色 2017。9。28 Bug #10311
	local fc = YaoShouManager.GetFCNum();
	self._txtAward1.text = LanguageMgr.Get("YaoShouBossPanel/award1", {val = fc, cc = fc >= 3 and _red or _green})
	
	local kc = YaoShouManager.GetKCNum();
	self._txtAward2.text = LanguageMgr.Get("YaoShouBossPanel/award2", {val = kc, cc = kc >= 3 and _red or _green})
	
end

function YaoShouBossPanel:SetCurrentSelect(boss)	
	if(self._currentSelectBoss == nil or boss.id ~= self._currentSelectBoss.id) then
		self._currentSelectBoss = boss
		self._isInit = true
		self:UpdateBossInfo()
	end
	--SequenceManager.TriggerEvent(SequenceEventType.Guide.WILD_BOSS_SELECT, boss.id);
end

local monster = {kind = 0}
function YaoShouBossPanel:UpdateBossInfo()
	
	if(self._currentSelectBoss) then
		
		--local isOpen = HeroController.GetInstance().info.level >= self._currentSelectBoss.mapInfo.level
		--self._toggleFocus.gameObject:SetActive(isOpen)
		self._txtRequireFight.text = self._currentSelectBoss.rec_fighting;
		--self._rewardPhalanx:Build(1, table.getCount(self._currentSelectBoss.rewardItem), self._currentSelectBoss.rewardItem)
		
		for i = 1, 2 do
			local fItem = self._currentSelectBoss.rewardF[i];
			if fItem then
				local f = ProductInfo:New();
         		f:Init({spId = fItem.id, am = 1});
         		self._rewards[i]:UpdateItem(f);
         	else
         		self._rewards[i]:UpdateItem(nil);
         	end
			
			
			local kItem = self._currentSelectBoss.rewardK[i];
			if kItem then
				local k = ProductInfo:New();
         		k:Init({spId = kItem.id, am = 1});
         		self._rewards[i+2]:UpdateItem(k);
         	else
         		self._rewards[i+2]:UpdateItem(nil);
         	end
		end



		--self._toggleFocus.value = WildBossManager.IsBossFocus(self._currentSelectBoss.id)	
		monster.kind = self._currentSelectBoss.monster_id
		if(self._uiPetAnimationModel == nil) then
			self._uiPetAnimationModel = UIAnimationModel:New(monster, self._trsRoleParent, MonsterModelCreater)
		else
			self._uiPetAnimationModel:ChangeModel(monster, self._trsRoleParent)
		end
		self._trsRoleParent.localScale = Vector3.one * self._currentSelectBoss.model_scale_rate * 100;
		--self._trsRoleParent.localScale = Vector3.one * 1 * 100;
	end
end

return YaoShouBossPanel;