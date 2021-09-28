require "Core.Module.Common.Panel"
require "Core.Module.WildBoss.View.Item.WildBossProductItem"
require "Core.Role.ModelCreater.UIMonsterModelCreater" -- MonsterModelCreater

WildBossInfoPanel = class("WildBossInfoPanel", Panel);
function WildBossInfoPanel:New()
	self = {};
	setmetatable(self, {__index = WildBossInfoPanel});
	return self
end

function WildBossInfoPanel:IsPopup()
	return true;
end

function WildBossInfoPanel:GetUIOpenSoundName( )
    return ""
end

function WildBossInfoPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WildBossInfoPanel:_InitReference()
	self.to = self._trsContent.localPosition;
	self.to.x = 640;
	Util.SetLocalPos(self._trsContent, self.to.x + 530, self.to.y, self.to.z)
	
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._btnGo = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGo");
	self._btnBossInfo = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnBossInfo");
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNum");
	self._txtRefreshInfo = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtRefreshInfo");
	self._imgFlag = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgFlag");
	self._trsRoleParent = UIUtil.GetChildByName(self._trsContent, "Transform", "imgRole/roleCamera/trsRoleParent");
	self._starts = {}
	for i = 1, 5 do
		local start = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgStar" .. i);
		self._starts[i] = start;
	end
	self._awards = {};
	for i = 1, 5 do
		local product = UIUtil.GetChildByName(self._trsContent, "Transform", "product" .. i);
		local pItem = WildBossProductItem:New(product);
		self._awards[i] = pItem;
	end
	self._blInited = true;
	self:_Refresh();
-- local txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
-- txtTitle.text = LanguageMgr.Get("WildBoss/rank/title")
end

function WildBossInfoPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	self._onClickBtn_bossInfo = function(go) self:_OnClickBtn_bossInfo(self) end
	UIUtil.GetComponent(self._btnBossInfo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_bossInfo);
	
	self._onClickBtn_go = function(go) self:_OnClickBtn_go(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_go);
end

function WildBossInfoPanel:_OnClickBtn_bossInfo()
	local data = self._data;
	ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM4PANEL, {title = data.bossInfo.name, msg = data.bossInfo.desc});
end

function WildBossInfoPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSINFOPANEL)
end

function WildBossInfoPanel:_OnClickMask()
	self:_OnClickBtn_close();
end

function WildBossInfoPanel:_OnClickBtn_go()
	local data = self._data;
	if(data) then
		local hero = PlayerManager.hero;
		if(hero.info.level >= self._data.mapInfo.level and not hero:IsDie()) then
			hero:StopAction(3);	
			ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
				title = LanguageMgr.Get("common/notice"),
				msg = LanguageMgr.Get("WildBoss/enternotice"),
				ok_Label = LanguageMgr.Get("common/agree"),
				cance_lLabel = LanguageMgr.Get("common/cancle"),
				hander = WildBossInfoPanel.AgreeEnter,			 
				target = self; 
			});
		else
			MsgUtils.ShowTips("WildBossNewPanel/levelNotEnough");
		end
	end
end

function WildBossInfoPanel:AgreeEnter()
	local to = {}
	to.sid = self._data.sid;
	to.ln = self._data.ln;
	to.position = Convert.PointFromServer(self._data.x, self._data.y, self._data.z);
    WildBossProxy.SendCheckLine(to)
	-- GameSceneManager.to = {}
	-- GameSceneManager.to.sid = data.sid;
	-- GameSceneManager.to.ln = data.ln;
	-- GameSceneManager.to.position = Convert.PointFromServer(data.x, data.y, data.z);
end

function WildBossInfoPanel:_Popup()
	--    self._trsContent.localPosition = Vector3.New(to.x + 530, to.y, to.z);
	self.popupTime = 0.2;
	local time = 0;
	local sx = self._trsContent.localPosition.x;
	local stepx = self._trsContent.localPosition.x;
	while time < self.popupTime do
		coroutine.step();
		time = time + Timer.deltaTime;
		stepx = EaseUtil.easeInQuad(0, 1, time / self.popupTime)
		Util.SetLocalPos(self._trsContent, sx -(stepx * 530), self.to.y, self.to.z)		
	--        self._trsContent.localPosition = Vector3.New(sx -(stepx * 530), to.y, to.z);
	end
	Util.SetLocalPos(self._trsContent, self.to.x, self.to.y, self.to.z)
	--    self._trsContent.localPosition = to
	self:_OnOpened();
end

function WildBossInfoPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossInfoPanel:SetData(v)
	self._data = v;
	if(self._blInited) then
		self:_Refresh();
	end
end

function WildBossInfoPanel:_Refresh()
	local data = self._data;
	if(data) then
		local mole = {};
		mole.kind = data.mid;
		if(data.lv) then
			self._txtName.text = data.bossInfo.name .. "  " .. data.lv .. LanguageMgr.Get("WildBoss/info/level")
		else
			self._txtName.text = data.bossInfo.name
		end
		--        if (data.num and data.bossInfo.type == MonsterInfoType.ELITE) then
		--            self._txtNum.text = "("..data.num.k.."/"..data.num.t..")"
		--        else
		--            self._txtNum.text = "";
		--        end
		if(data.bossInfo.difficulty == 1) then
			self._txtName.color = ColorDataManager.Get_white();
		elseif(data.bossInfo.difficulty == 2) then
			self._txtName.color = ColorDataManager.Get_purple()
		else
			self._txtName.color = ColorDataManager.Get_golden()
		end
		self._txtRefreshInfo.text = data.mapInfo.name .. "(" .. data.ln .. LanguageMgr.Get("WildBoss/info/line") .. ")"
		-- self._imgFlag.gameObject:SetActive(data.num.k >= data.num.t);
		self._imgFlag.gameObject:SetActive(data.st == 1);
		
		if(data.bossInfo.model_scale_rate) then
			self._trsRoleParent.localScale = Vector3.one * data.bossInfo.model_scale_rate * 100;
		end
		self._uiAnimationModel = UIAnimationModel:New(mole, self._trsRoleParent, UIMonsterModelCreater);
		
		for i = 1, data.bossInfo.difficulty do
			self._starts[i].gameObject:SetActive(true);
		end
		for i, v in pairs(data.bossInfo.drop) do
			local p = string.split(v, "_");
			self._awards[i]:SetProductId(tonumber(p[1]));
		end
	end
end

function WildBossInfoPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	
	UIUtil.GetComponent(self._btnBossInfo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_bossInfo = nil;
	
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_go = nil
end

function WildBossInfoPanel:_DisposeReference()
	if self._uiAnimationModel then
		self._uiAnimationModel:Dispose();
		self._uiAnimationModel = nil;
	end
	for i, v in pairs(self._starts) do
		self._starts[i] = nil;
	end
	self._starts = nil;
	for i, v in pairs(self._awards) do
		self._awards[i]:Dispose();
		self._awards[i] = nil;
	end
	self._awards = nil;
	-- NGUITools.DestroyChildren(self._trsRoleParent);
	self._trsRoleParent = nil;
	self._btn_close = nil;
	self._btnGo = nil;
	self._btnBossInfo = nil;
	self._txtName = nil;
	self._txtNum = nil;
	self._txtRefreshInfo = nil;
	self._imgFlag = nil;
	
end