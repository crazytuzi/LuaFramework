require "Core.Module.Common.UISubPanel";
require "Core.Module.WildBoss.View.Item.WildBossVipTabItem"
require "Core.Module.WildBoss.View.Item.WildBossItem"

local WildBossVipPanel = class("WildBossVipPanel", UISubPanel);

function WildBossVipPanel:_InitReference()

	self._dynamicPanel = UIUtil.GetChildByName(self._transform, "DynamicPanel")
	self._btn_help = UIUtil.GetChildByName(self._transform, "UIButton", "btn_help");
		
	self._toggleFocus = UIUtil.GetChildByName(self._dynamicPanel, "UIToggle", "checkBox")

	self._tabPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "trsToggle/phalanx")
	self._tabPhalanx = Phalanx:New()
	self._tabPhalanx:Init(self._tabPhalanxInfo, WildBossVipTabItem)

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
	self._txtEnter = UIUtil.GetChildByName(self._goEnter, "UILabel", "txtEnter");

	self._scrollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollview")
	self._centerOnChild = UIUtil.GetChildByName(self._transform, "UICenterOnChild", "scrollview/phalanx")
	self._cocDelegate = function(go) self:_OnCenterCallBack(go) end
	self._centerOnChild.onCenter = self._cocDelegate;

	self._onClickBtn_help = function(go) self:_OnClickBtn_help(self) end
	UIUtil.GetComponent(self._btn_help, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_help);
	self._onClickToggle = function(go) self:_OnClickToggle(self) end
	UIUtil.GetComponent(self._toggleFocus, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	self._onClickRecorder = function(go) self:_OnClickRecorder(self) end
	UIUtil.GetComponent(self._goRecorder, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickRecorder);
	self._onClickEnter = function(go) self:_OnClickEnter(self) end
	UIUtil.GetComponent(self._goEnter, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickEnter);

	self._isInit = false
	
end

function WildBossVipPanel:_DisposeReference()
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
	
	if self._uiAnimationModel then
		self._uiAnimationModel:Dispose();
		self._uiAnimationModel = nil;
	end

	self._tabPhalanx:Dispose()
	self._tabPhalanx = nil
	self._bossphalanx:Dispose()
	self._bossphalanx = nil
	self._rewardPhalanx:Dispose()
	self._rewardPhalanx = nil
end

function WildBossVipPanel:_InitListener()
	MessageManager.AddListener(WildBossNotes, WildBossNotes.EVENT_VIP_TAB_CHG, WildBossVipPanel.UpdateTab, self);
	MessageManager.AddListener(WildBossNotes, WildBossNotes.EVENT_SELECT_BOSS, WildBossVipPanel.SetCurrentSelect, self);
	MessageManager.AddListener(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO, WildBossVipPanel.UpdateDisplay, self);
	
end

function WildBossVipPanel:_DisposeListener()
	MessageManager.RemoveListener(WildBossNotes, WildBossNotes.EVENT_VIP_TAB_CHG, WildBossVipPanel.UpdateTab);
	MessageManager.RemoveListener(WildBossNotes, WildBossNotes.EVENT_SELECT_BOSS, WildBossVipPanel.SetCurrentSelect);
	MessageManager.RemoveListener(WildBossNotes, WildBossNotes.RSP_VIP_BOSS_INFO, WildBossVipPanel.UpdateDisplay);
end

function WildBossVipPanel:_OnEnable()
	
	if not self._isInit then
		self:InitDisplay();
		self._isInit = true;
	end
	
	WildBossProxy.ReqVipBossInfo()
end

function WildBossVipPanel:_OnCenterCallBack(go)
	
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

function WildBossVipPanel:_OnClickBtn_help()
	ModuleManager.SendNotification(WildBossNotes.OPEN_WILDBOSSVIPHELPPANEL)	
end

local focus = LanguageMgr.Get("WildBossNewPanel/focus")
local focusTitle = LanguageMgr.Get("WildBossNewPanel/focusTitle")
function WildBossVipPanel:_OnClickToggle()
	if(self._currentSelectBoss) then
		if(self._toggleFocus.value) then
			ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM2PANEL, {title = focusTitle, msg = focus})
		end
		WildBossManager.SaveFocusData(self._currentSelectBoss.id, self._toggleFocus.value)
	end
end

function WildBossVipPanel:_OnClickRecorder()
	if(self._currentSelectBoss) then
		WildBossProxy.ReqHistory(self._currentSelectBoss.id)
	end
end

function WildBossVipPanel:_OnClickEnter()
	
	local hero = PlayerManager.hero;
	if(hero.info.level >= self._currentSelectBoss.mapInfo.level and not hero:IsDie()) then
		hero:StopAction(3);	
		--vip不够时
		if VIPManager.GetSelfVIPLevel() < self._currentSelectBoss.mapInfo.vip_level then
			MsgUtils.UseBDGoldConfirm(200, self, "WildBossNewPanel/payEnter", nil, WildBossVipPanel.AgreeUseGoldEnter, nil, nil, "common/agree", "common/cancle", "common/notice");
		else
			self:AgreeUseGoldEnter();
		end
		
	else
		MsgUtils.ShowTips("WildBossFieldPanel/levelNotEnough");
	end
	
end


function WildBossVipPanel:AgreeUseGoldEnter()
	local to = {}
	to.sid = self._currentSelectBoss.map_id;
	to.ln = self._currentSelectBoss.ln;
	to.position = Convert.PointFromServer(self._currentSelectBoss.boss_player_point[1], 0, self._currentSelectBoss.boss_player_point[2]);
	to.moveToPos = Convert.PointFromServer(self._currentSelectBoss.boss_guide_point[1], 0, self._currentSelectBoss.boss_guide_point[2]);
	
	WildBossProxy.ReqEnterVipMap(to);
	-- GameSceneManager.to = {}
	-- GameSceneManager.to.sid = data.sid;
	-- GameSceneManager.to.ln = data.ln;
	-- GameSceneManager.to.position = Convert.PointFromServer(data.x, data.y, data.z);
end

local _insert = table.insert;
local _sort = table.sort;
local allBossData = {};

function WildBossVipPanel:InitDisplay()
	local types = {};
	allBossData = WildBossManager.GetAllVipBossData();
	for k, v in pairs(allBossData) do
		_insert(types, k)
	end
	self._tabPhalanx:Build(1, #types, types);

	self._tabIndex = 1;

	local lv = PlayerManager.GetPlayerLevel();
	for i, v in ipairs(allBossData) do
		local isbreak = false;
		for idx, boss in ipairs(v) do
			if lv >= boss.rec_level_lower and lv <= boss.rec_level_upper then
				self._tabIndex = i;
				isbreak = true;
				break;
			end
		end
		if isbreak then
			break;
		end
	end

	self:UpdateTab(self._tabIndex);
end

function WildBossVipPanel:UpdateTab(idx)
	local items = self._tabPhalanx:GetItems()
	for i, v in ipairs(items) do
		local item = v.itemLogic;
		item:SetSelected(idx == i);
	end

	local lv = PlayerManager.GetPlayerLevel();
	local data = allBossData[idx] or {};
	_sort(data, WildBossManager.SortBossByLv);

	self._bossphalanx:Build(#data, 1, data);
	--[[
	local idx = self._tmpBossIndex or 1;
	self._tmpBossIndex = nil;
	local first = data[idx];
	if first then
		local fix = self._index - 1 --self._index and 1 - self._index or 0;
		self:SetCurrentSelect(first);
		self._bossphalanx:GetItem(1).itemLogic:SetToggleActive(true)

		panelSpring = UIUtil.GetComponent(self._scrollview.transform, "SpringPanel");
		if panelSpring then
			panelSpring.enabled = false;
		end

		self._scrollview:ResetPosition();
		self._scrollview:MoveRelative(Vector3.up * 110 * fix);
		self._scrollview:UpdatePosition()
	end
	
	if self._index == nil then
		self._scrollview:MoveRelative(Vector3.up * 0);
		self._scrollview:UpdatePosition()
	end
	]]

	self:SetCurrentSelect(data[1]);

end



function WildBossVipPanel:UpdateDisplay()
	--local data = WildBossManager.GetAllWildBossData()
	--self._bossphalanx:Build(table.getCount(data), 1, data)
	self._txtTime.text = WildBossManager.GetVipRoundDes()
	
end

function WildBossVipPanel:UpdateStatus(data)
	local items = self._bossphalanx:GetItems()
	for i, v in ipairs(items) do
		local item = v.itemLogic;
		item:UpdateStatus();
	end
end

function WildBossVipPanel:SetCurrentSelect(boss)
	if(self._currentSelectBoss == nil or boss.id ~= self._currentSelectBoss.id) then

		local items = self._bossphalanx:GetItems();
		for i, v in ipairs(items) do 
			if v.data == boss then
				v.itemLogic._toggle.value = true;
				self._index = i;
				break;
			end
		end

		self._currentSelectBoss = boss
		self._isInit = true
		self:UpdateBossInfo()
	end
end

local monster = {kind = 0}
function WildBossVipPanel:UpdateBossInfo()
	
	if(self._currentSelectBoss) then
		local mapInfo = self._currentSelectBoss.mapInfo;
		local isOpen = HeroController.GetInstance().info.level >= mapInfo.level 
						and VIPManager.GetSelfVIPLevel() >= mapInfo.vip_level;
		self._toggleFocus.gameObject:SetActive(isOpen)
		self._txtRequireFight.text = self._currentSelectBoss.rec_fighting
		self._rewardPhalanx:Build(1, table.getCount(self._currentSelectBoss.rewardItem), self._currentSelectBoss.rewardItem)
		
		self._toggleFocus.value = WildBossManager.IsBossFocus(self._currentSelectBoss.id)	
		monster.kind = self._currentSelectBoss.monster_id
		if(self._uiAnimationModel == nil) then
			self._uiAnimationModel = UIAnimationModel:New(monster, self._trsRoleParent, MonsterModelCreater)
		else
			self._uiAnimationModel:ChangeModel(monster, self._trsRoleParent)
		end
		self._trsRoleParent.localScale = Vector3.one * self._currentSelectBoss.model_scale_rate * 100;

		self._txtEnter.text = LanguageMgr.Get("WildBossNewPanel/vipEnter", {vip = mapInfo.vip_level});
	end
end

return WildBossVipPanel;