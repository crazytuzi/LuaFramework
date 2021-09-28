require "Core.Module.Common.Panel"
require "Core.Module.AutoFight.AutoFightNotes"
require "Core.Module.AutoFight.View.Item.SelSkillButton"
require "Core.Module.AutoFight.View.DefSkillPanel"
require "Core.Module.AutoFight.View.SelSkillPanel"
require "Core.Module.AutoFight.View.GuaJiSetPanel"
require "Core.Module.AutoFight.View.BaseSetPanel"
require "Core.Module.AutoFight.View.GiftCodePanel"

require "Core.Manager.Item.AutoFightManager"



AutoFightPanel = class("AutoFightPanel", Panel);
function AutoFightPanel:New()
	self = {};
	setmetatable(self, {__index = AutoFightPanel});
	return self
end


function AutoFightPanel:_Init()
	self._isChangled = false;
	self:_InitReference();
	self:_InitListener();
end

function AutoFightPanel:_InitReference()
	
	
	
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	
	local chbs = UIUtil.GetComponentsInChildren(self._trsContent, "UIToggle");
	self.autoGensui = UIUtil.GetChildInComponents(chbs, "autoGensui");
	
	-- 是否 接收陌生人信息
	self.autoRecStMsg = UIUtil.GetChildInComponents(chbs, "autoRecStMsg");
	
	self.guajiSetBt = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "guajiSetBt");
	self.baseSetBt = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "baseSetBt");
	self.giftCodeSetBt = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "giftCodeSetBt");
	
	
	self.guajiSetBtCtr = SQTableButton:New();
	self.guajiSetBtCtr:Init(self.guajiSetBt, 1);
	self.guajiSetBtCtr:SetClickHandler(AutoFightPanel._SQTabelChangeHandler, self);
	
	self.baseSetBtCtr = SQTableButton:New();
	self.baseSetBtCtr:Init(self.baseSetBt, 2);
	self.baseSetBtCtr:SetClickHandler(AutoFightPanel._SQTabelChangeHandler, self);
	
	self.giftCodeSetBtCtr = SQTableButton:New();
	self.giftCodeSetBtCtr:Init(self.giftCodeSetBt, 3);
	self.giftCodeSetBtCtr:SetClickHandler(AutoFightPanel._SQTabelChangeHandler, self);
	
	local guajiSetPanel = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "guajiSetPanel");
	local baseSetPanel = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "baseSetPanel");
	local giftSetPanel = UIUtil.GetChildByName(self._trsContent.gameObject, "Transform", "giftCodePanel");
	
	self._guajiSetPanel = GuaJiSetPanel:New()
	self._guajiSetPanel:Init(guajiSetPanel)
	self._baseSetPanel = BaseSetPanel:New();
	self._baseSetPanel:Init(baseSetPanel)
	self._giftCodePanel = GiftCodePanel:New();
	self._giftCodePanel:Init(giftSetPanel)
	
	self.autoGensui.value = AutoFightManager.autoGensui;
	self.autoRecStMsg.value = AutoFightManager.autoRecStMsg;
	
	
	self.selectIndex = 0;
	self:_SQTabelChangeHandler(1);
end

function AutoFightPanel:_SQTabelChangeHandler(index)
	if self.selectIndex ~= index then
		self.selectIndex = index;
		
		if index == 1 then
			
			self.guajiSetBtCtr:SetSelected(true);
			self.baseSetBtCtr:SetSelected(false);
			self.giftCodeSetBtCtr:SetSelected(false);
			self._guajiSetPanel:SetActive(true);
			self._baseSetPanel:SetActive(false);
			self._giftCodePanel:SetActive(false);
		elseif index == 2 then
			LogHttp.SendOperaLog("系统设置")
			self.guajiSetBtCtr:SetSelected(false);
			self.baseSetBtCtr:SetSelected(true);
			self.giftCodeSetBtCtr:SetSelected(false);
			self._guajiSetPanel:SetActive(false);
			self._baseSetPanel:SetActive(true);
			self._giftCodePanel:SetActive(false);
		else
			LogHttp.SendOperaLog("礼包兑换")			
			self.guajiSetBtCtr:SetSelected(false);
			self.baseSetBtCtr:SetSelected(false);
			self.giftCodeSetBtCtr:SetSelected(true);
			self._guajiSetPanel:SetActive(false);
			self._baseSetPanel:SetActive(false);
			self._giftCodePanel:UpdatePanel();
			self._giftCodePanel:SetActive(true);
		end
		
		SequenceManager.TriggerEvent(SequenceEventType.Guide.AUTO_FIGHT_TAB, index);
	end
end



-- function AutoFightPanel:_OnSelectedDefSkills(skills)
--    if (skills) then
--        for i, v in pairs(skills) do
--            AutoFightManager.skills[i] = v;
--            self._skillBtns[i]:SetSkill(PlayerManager.hero.info:GetSkill(v));
--        end
--        self._isChangled = true;
--    end
-- end

-- function AutoFightPanel:_OnSelectedSkill(skill)
--    if (self._selSkillBtn) then
--        if (skill) then
--            AutoFightManager.skills[self._selSkillBtn.index] = skill.id;
--            self._selSkillBtn:SetSkill(skill);
--        end
--        self._selSkillBtn:Select(false);
--        self._isChangled = true;
--    end
-- end

-- function AutoFightPanel:_SelectSkillButton(go)
--    if (go) then
--        self._selSkillBtn = go;
--        self._selSkillBtn:Select(true);
--        self._selSkillPanel:SetActive(true);
--    end
-- end

function AutoFightPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	
	self._onClickAutoGensui = function(go) self:_OnClickAutoGensui(self) end
	UIUtil.GetComponent(self.autoGensui, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAutoGensui);
	
	self._onClickAutoRecStMsg = function(go) self:_OnClickAutoRecStMsg(self) end
	UIUtil.GetComponent(self.autoRecStMsg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAutoRecStMsg);
	
	
	
	
--    self._onClickBtnRecommend = function(go) self:_OnClickBtnRecommend(self) end
--    UIUtil.GetComponent(self._btnRecommend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRecommend);
--    self._onClickBtnPointArea = function(go) self:_OnClickBtnPointArea(self) end
--    UIUtil.GetComponent(self._btnPointArea, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPointArea);
--    self._onClickBtnAllArea = function(go) self:_OnClickBtnAllArea(self) end
--    UIUtil.GetComponent(self._btnAllArea, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAllArea);
--    self._onClickBtnReliveProps = function(go) self:_OnClickBtnReliveProps(self) end
--    UIUtil.GetComponent(self._btnReliveProps, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReliveProps);
--    self._onClickBtnAwayBoss = function(go) self:_OnClickBtnAwayBoss(self) end
--    UIUtil.GetComponent(self._btnAwayBoss, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAwayBoss);
--    self._onClickBtnRevenge = function(go) self:_OnClickBtnRevenge(self) end
--    UIUtil.GetComponent(self._btnRevenge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRevenge);
--    self._onClickBtnCastMinorSkill = function(go) self:_OnClickBtnCastMinorSkill(self) end
--    UIUtil.GetComponent(self._btnCastMinorSkill, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCastMinorSkill);

--    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
--    self._timer:Start();


--    self._sliRestoreHP_content.width = 300 * AutoFightManager.restoreHP;
--    self._sliRestoreMP_content.width = 300 * AutoFightManager.restoreMP;
end

-- function AutoFightPanel:_OnTimerHandler()
--    if (AutoFightManager.restoreHP ~= self._sliRestoreHP.value) then
--        AutoFightManager.restoreHP = self._sliRestoreHP.value;

--        local pv = math.round(AutoFightManager.restoreHP * 100);
--        self._txtRestoreHP.text = LanguageMgr.Get("AutoFight/AutoFightPanel/hpLabel", { t = pv });

--        -- 更新长度
--        self._sliRestoreHP_content.width = 300 *(pv / 100);
--        self._isChangled = true;
--    end
--    if (AutoFightManager.restoreMP ~= self._sliRestoreMP.value) then
--        AutoFightManager.restoreMP = self._sliRestoreMP.value;

--        local pv = math.round(AutoFightManager.restoreMP * 100);

--        self._txtRestoreMP.text = LanguageMgr.Get("AutoFight/AutoFightPanel/mpLabel", { t = pv });

--        self._sliRestoreMP_content.width = 300 *(pv / 100);
--        self._isChangled = true;
--    end
-- end

function AutoFightPanel:_OnClickBtnClose()
	
	AutoFightManager.Save();
	
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	
	ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTPANEL);
end

function AutoFightPanel:_OnClickAutoGensui()
	
	AutoFightManager.autoGensui = self.autoGensui.value;
	self._isChangled = true;
	AutoFightManager.Save();
	
end

function AutoFightPanel:_OnClickAutoRecStMsg()
	
	AutoFightManager.autoRecStMsg = self.autoRecStMsg.value;
	self._isChangled = true;
	AutoFightManager.Save();
	
end



-- function AutoFightPanel:_OnClickBtnAutoFight()
--    AutoFightManager.Save();
--    PlayerManager.hero:StartAutoFight(AutoFightManager);
--    ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTPANEL);
-- end

-- function AutoFightPanel:_OnClickBtnRecommend()
--    self._defSkillPanel:SetActive(true);
-- end

-- function AutoFightPanel:_OnClickBtnPointArea()
--    AutoFightManager.attackAllArea = self._btnAllArea.value;
--    self._isChangled = true;
-- end

-- function AutoFightPanel:_OnClickBtnAllArea()
--    AutoFightManager.attackAllArea = self._btnAllArea.value;
--    self._isChangled = true;
-- end

-- function AutoFightPanel:_OnClickBtnReliveProps()
--    AutoFightManager.reliveProps = self._btnReliveProps.value;
--    self._isChangled = true;
-- end

-- function AutoFightPanel:_OnClickBtnAwayBoss()
--    AutoFightManager.awayBoss = self._btnAwayBoss.value;
--    self._isChangled = true;
-- end

-- function AutoFightPanel:_OnClickBtnRevenge()
--    AutoFightManager.revenge = self._btnRevenge.value;
--    self._isChangled = true;
-- end

-- function AutoFightPanel:_OnClickBtnCastMinorSkill()
--    AutoFightManager.castMinorSkill = self._btnCastMinorSkill.value;
--    self._isChangled = true;
-- end

function AutoFightPanel:SetData(value)
	
end


function AutoFightPanel:_Dispose()
	if(self._guajiSetPanel) then
		self._guajiSetPanel:Dispose()
		self._guajiSetPanel = nil
	end
	if(self._baseSetPanel) then
		self._baseSetPanel:Dispose()
		self._baseSetPanel = nil
	end
	if(self._giftCodePanel) then
		self._giftCodePanel:Dispose()
		self._giftCodePanel = nil
	end
	self.guajiSetBtCtr:Dispose()
	self.guajiSetBtCtr = nil
	
	self.baseSetBtCtr:Dispose()
	self.baseSetBtCtr = nil;
	
	self.giftCodeSetBtCtr:Dispose()
	self.giftCodeSetBtCtr = nil;
	--    if (self._isChangled) then
	--        AutoFightManager.Save();
	--    end
	--    self._defSkillPanel:Dispose()
	--    self._selSkillPanel:Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
	
	self._btnClose = nil;
	
	
	self.autoGensui = nil;
	
	-- 是否 接收陌生人信息
	self.autoRecStMsg = nil;
	
end

function AutoFightPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	
	
	UIUtil.GetComponent(self.autoGensui, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickAutoGensui = nil;
	
	UIUtil.GetComponent(self.autoRecStMsg, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickAutoRecStMsg = nil;
	
	
	
--    UIUtil.GetComponent(self._btnRecommend, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnRecommend = nil;
--    UIUtil.GetComponent(self._btnPointArea, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnPointArea = nil;

--    UIUtil.GetComponent(self._btnAllArea, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnAllArea = nil;

--    UIUtil.GetComponent(self._btnReliveProps, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnReliveProps = nil;

--    UIUtil.GetComponent(self._btnAwayBoss, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnAwayBoss = nil;

--    UIUtil.GetComponent(self._btnRevenge, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnRevenge = nil;

--    UIUtil.GetComponent(self._btnCastMinorSkill, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickBtnCastMinorSkill = nil;

--    if (self._timer) then
--        self._timer:Stop();
--    end
end

function AutoFightPanel:_DisposeReference()
	self._btnClose = nil;
--    self._btnRecommend = nil;
--    self._btnPointArea = nil;
--    self._btnAllArea = nil;
--    self._btnReliveProps = nil;
--    self._btnAwayBoss = nil;
--    self._onClickBtnRevenge = nil;
--    self._onClickBtnCastMinorSkill = nil;


end
