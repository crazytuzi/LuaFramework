require "Core.Module.Common.UISubPanel";
require "Core.Module.WildBoss.View.Item.WildBossItem"
require "Core.Module.WildBoss.View.Item.WildBossRewardItem"
require "Core.Module.Common.UIAnimationModel"

local WildBossFieldPanel = class("WildBossFieldPanel", UISubPanel);

function WildBossFieldPanel:_InitReference()
	self._index = 1
	self._dynamicPanel = UIUtil.GetChildByName(self._transform, "DynamicPanel")
	self._btn_help = UIUtil.GetChildByName(self._transform, "UIButton", "btn_help");
	
	self._toggleFocus = UIUtil.GetChildByName(self._dynamicPanel, "UIToggle", "checkBox")
	
	self._bossphalanInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollview/phalanx")
	self._bossphalanx = Phalanx:New()
	self._bossphalanx:Init(self._bossphalanInfo, WildBossItem)
	
	self._rewardPhalanxInfo = UIUtil.GetChildByName(self._dynamicPanel, "LuaAsynPhalanx", "phalanx")
	self._rewardPhalanx = Phalanx:New()
	self._rewardPhalanx:Init(self._rewardPhalanxInfo, WildBossRewardItem)
	self._txtTime = UIUtil.GetChildByName(self._dynamicPanel, "UILabel", "txtTime")
	self._txtRequireFight = UIUtil.GetChildByName(self._dynamicPanel, "UILabel", "txtRequireFight")
	
	self._trsRoleParent = UIUtil.GetChildByName(self._dynamicPanel, "imgRole/heroCamera/trsRoleParent");
	self._goRecorder = UIUtil.GetChildByName(self._dynamicPanel, "btnRecorder").gameObject
	self._goEnter = UIUtil.GetChildByName(self._dynamicPanel, "btnEnter").gameObject
	
	self._scrollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollview")
	self._centerOnChild = UIUtil.GetChildByName(self._transform, "UICenterOnChild", "scrollview/phalanx")
	self._cocDelegate = function(go) self:_OnCenterCallBack(go) end
	self._centerOnChild.onCenter = self._cocDelegate;
	
	-- self._centerOnChild.onFinished = self._onfinish
	self._onClickBtn_help = function(go) self:_OnClickBtn_help(self) end
	UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_help);
	self._onClickToggle = function(go) self:_OnClickToggle(self) end
	UIUtil.GetComponent(self._toggleFocus, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	self._onClickRecorder = function(go) self:_OnClickRecorder(self) end
	UIUtil.GetComponent(self._goRecorder, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickRecorder);
	self._onClickEnter = function(go) self:_OnClickEnter(self) end
	UIUtil.GetComponent(self._goEnter, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickEnter);
	
	self._isInit = false
	self._currentGo = nil
end

function WildBossFieldPanel:_DisposeReference()
	UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_help = nil;
	UIUtil.GetComponent(self._toggleFocus, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle = nil;
	UIUtil.GetComponent(self._goRecorder, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickRecorder = nil;
	UIUtil.GetComponent(self._goEnter, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickEnter = nil;
	
	self._btn_help = nil;
	self._trsRoleParent = nil;
	
	self._bossphalanx:Dispose()
	self._bossphalanx = nil
	self._rewardPhalanx:Dispose()
	self._rewardPhalanx = nil
	
	self._cocDelegate = nil;
	if self._centerOnChild and self._centerOnChild.onCenter then
		self._centerOnChild.onCenter:Destroy()
	end
	
	self._currentGo = nil
end

function WildBossFieldPanel:_InitListener()
	MessageManager.AddListener(WildBossNotes, WildBossNotes.EVENT_SELECT_BOSS, WildBossFieldPanel.SetCurrentSelect, self);
end

function WildBossFieldPanel:_DisposeListener()
	MessageManager.RemoveListener(WildBossNotes, WildBossNotes.EVENT_SELECT_BOSS, WildBossFieldPanel.SetCurrentSelect);
end

function WildBossFieldPanel:_OnEnable()
	WildBossProxy.RefreshBossInfos()
end

function WildBossFieldPanel:_OnCenterCallBack(go)
	
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

function WildBossFieldPanel:_OnClickRecorder()
	if(self._currentSelectBoss) then
		WildBossProxy.RefreshBossHeroRank(self._currentSelectBoss.id)
	end
end


function WildBossFieldPanel:_OnClickEnter()
	
	local hero = PlayerManager.hero;
	if(hero.info.level >= self._currentSelectBoss.mapInfo.level and not hero:IsDie()) then
		hero:StopAction(3);	
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
			title = LanguageMgr.Get("common/notice"),
			msg = LanguageMgr.Get("WildBoss/enternotice"),
			ok_Label = LanguageMgr.Get("common/agree"),
			cance_lLabel = LanguageMgr.Get("common/cancle"),
			hander = WildBossFieldPanel.AgreeEnter,			
			target = self;
		});
	else
		MsgUtils.ShowTips("WildBossNewPanel/levelNotEnough");
	end
	
end


function WildBossFieldPanel:AgreeEnter()
	local to = {}
	to.sid = self._currentSelectBoss.map_id;
	to.ln = self._currentSelectBoss.ln;
	to.position = Convert.PointFromServer(self._currentSelectBoss.boss_player_point[1], 0, self._currentSelectBoss.boss_player_point[2]);
	to.moveToPos = Convert.PointFromServer(self._currentSelectBoss.boss_guide_point[1], 0, self._currentSelectBoss.boss_guide_point[2]);
	
	WildBossProxy.SendCheckLine(to)
end

local focus = LanguageMgr.Get("WildBossNewPanel/focus")
local focusTitle = LanguageMgr.Get("WildBossNewPanel/focusTitle")
function WildBossFieldPanel:_OnClickToggle()
	if(self._currentSelectBoss) then
		if(self._toggleFocus.value) then
			ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {title = focusTitle, msg = focus})
		end
		WildBossManager.SaveFocusData(self._currentSelectBoss.id, self._toggleFocus.value)
	end
end

function WildBossFieldPanel:_OnClickBtn_help()
	ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSHELPPANEL)	
end

function WildBossFieldPanel:SetCurrentSelect(boss)	
	if(self._currentSelectBoss == nil or boss.id ~= self._currentSelectBoss.id) then
		self._currentSelectBoss = boss
		self._isInit = true
		self:UpdateBossInfo()
	end
	SequenceManager.TriggerEvent(SequenceEventType.Guide.WILD_BOSS_SELECT, boss.id);
end

function WildBossFieldPanel:UpdatePanel()
	local data = WildBossManager.GetAllWildBossData()
	self._bossphalanx:Build(table.getCount(data), 1, data)
	self._txtTime.text = WildBossManager.GetRoundDes()
	
	if(self._currentSelectBoss == nil) then	
		
		self._bossphalanx:GetItem(self._index).itemLogic:SetToggleActive(true)
		
		self._scrollview:MoveRelative(Vector3.up * 110 *(self._index - 1))
		self._scrollview:UpdatePosition()
	end

	SequenceManager.TriggerEvent(SequenceEventType.Guide.WILD_BOSS_SHOW);
end

function WildBossFieldPanel:SetIndex(index)
	self._index = index or 1
end

local monster = {kind = 0}
function WildBossFieldPanel:UpdateBossInfo()
	
	if(self._currentSelectBoss) then
		
		local isOpen = HeroController.GetInstance().info.level >= self._currentSelectBoss.mapInfo.level
		self._toggleFocus.gameObject:SetActive(isOpen)
		self._txtRequireFight.text = self._currentSelectBoss.rec_fighting .. ""
		self._rewardPhalanx:Build(1, table.getCount(self._currentSelectBoss.rewardItem), self._currentSelectBoss.rewardItem)
		
		self._toggleFocus.value = WildBossManager.IsBossFocus(self._currentSelectBoss.id)	
		monster.kind = self._currentSelectBoss.monster_id
		if(self._uiPetAnimationModel == nil) then
			self._uiPetAnimationModel = UIAnimationModel:New(monster, self._trsRoleParent, MonsterModelCreater)
		else
			self._uiPetAnimationModel:ChangeModel(monster, self._trsRoleParent)
		end
		self._trsRoleParent.localScale = Vector3.one * self._currentSelectBoss.model_scale_rate * 100;
	end
end

return WildBossFieldPanel 