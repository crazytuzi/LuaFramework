require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.BuffItem"

BossHeadPanel = class("BossHeadPanel", UIComponent)

BossHeadPanel.HPBars = {
	"hp_bar1", "hp_bar2", "hp_bar3", "hp_bar4", "hp_bar5"
}

function BossHeadPanel:New()
	self = {};
	setmetatable(self, {__index = BossHeadPanel});
	return self;
end

function BossHeadPanel:_Init()
	self._hpBarCount = # BossHeadPanel.HPBars
	self._trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
	-- self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgIcon");
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._txtLevel = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtLevel");
	self._txtCurrBar = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtCurrBar");
	self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime");
	self._btnVested = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnVested");
	self._txtHP = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtHP");
	self._sliderHP = UIUtil.GetChildByName(self._trsContent, "UISlider", "sliderHP");
	self._imgCurBar = UIUtil.GetChildByName(self._trsContent, "UISprite", "sliderHP/Foreground");
	self._imgNextBar = UIUtil.GetChildByName(self._trsContent, "UISprite", "sliderHP/NextForeground");
	self._buffPanel = BuffPanel:New(UIUtil.GetChildByName(self._trsContent, "Transform", "trsBuff"))
	
	self._txtTime.gameObject:SetActive(false);
	self._btnVested.gameObject:SetActive(false);
	
	self._onClickVestedHandler = function(go) self:_OnClickVestedHandler(self) end
	UIUtil.GetComponent(self._btnVested, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickVestedHandler);
	SetUIEnable(self._trsContent, false)
	--    self:SetEnable(false)
	--    self._gameObject:SetActive(false);
	self._blActive = false;
	self._blVested = false;
	self._blTime = false;
	self._blAutoListenerBoss = false;
	self._timer = Timer.New(function(val) self:_OnUpdata(val) end, 0.1, - 1, false);
	self._timer:Start();
	self._target = nil;
end

function BossHeadPanel:AutoListenerBoss(blval)
	self._blAutoListenerBoss = blval;
	self._target = nil;
end

function BossHeadPanel:_OnClickVestedHandler()
	local target = HeroController.GetInstance().target;
	if(target and self:_IsShowByRole(target)) then
		WildBossProxy.RefreshBossHurtRank(target.info.id);
	end
end

local downTime = LanguageMgr.Get("downTime/prefix")
function BossHeadPanel:_GetBoss()
	local map = GameSceneManager.map;
	if(map) then
		return map:GetBoss()
	end
	return nil;
end

function BossHeadPanel:_OnUpdata()
	local target = nil;
	if(self._blAutoListenerBoss) then
		if(self._target) then
			target = self._target
		else
			target = self:_GetBoss();
		end
	else
		target = HeroController.GetInstance().target;
	end
	if(target == nil or not self:_IsShowByRole(target)) then
		if(self._blActive) then
			self._blActive = false
			self._blVested = false
			SetUIEnable(self._trsContent, false)
			self._target = nil;
			self._buffPanel:SetRole(nil);
		--            self:SetEnable(false)
		--            self._gameObject:SetActive(false);
		end
		return;
	end
	
	local info = target.info;
	local hpRatio = 1
	if(self._target ~= target) then
		self._target = target
		self._txtLevel.text = GetLvDes1(info.level);
		self._txtName.text = info.name;
		-- self._imgIcon.spriteName = info["icon_id"]
		self._blVested = false;
		self._vested = "";
		self._btnVested.gameObject:SetActive(false);
		self._txtTime.gameObject:SetActive(false);
		self._blTime = false;
		self._barNum = info.bar_num;
		self._currBarNum = - 1;
		self._barRatio = 1 / self._barNum;
		if(self._barNum <= 1) then
			self._barNum = 1
			self._txtCurrBar.text = "";
		end
		self._buffPanel:SetRole(target);
	end
	
	if info.hp and info.hp_max then
		hpRatio = info.hp / info.hp_max
		if(hpRatio > 0) then
			local cb = math.ceil(hpRatio / self._barRatio)
			if(self._currBarNum ~= cb) then
				local bIndex =(cb - 1) % self._hpBarCount + 1
				self._imgCurBar.spriteName = BossHeadPanel.HPBars[bIndex];
				if(cb <= 1) then
					self._imgNextBar.spriteName = "";
				else
					if(bIndex == 1) then
						self._imgNextBar.spriteName = BossHeadPanel.HPBars[self._hpBarCount];
					else
						self._imgNextBar.spriteName = BossHeadPanel.HPBars[bIndex - 1];
					end
				end
				self._currBarNum = cb
				if(self._barNum > 1 and cb >= 1) then
					self._txtCurrBar.text = "x" .. cb;
				else
					self._txtCurrBar.text = "";
				end
			end
		end
		if(info.hp ~= info.hp_max) then
			hpRatio =(hpRatio - math.floor(hpRatio / self._barRatio) * self._barRatio) * self._barNum;
		else
			hpRatio = 1
		end
	end
	if(hpRatio ~= self._sliderHP.value) then
		self._sliderHP.value = hpRatio;
	end
	self._txtHP.text = info.hp .. "/" .. info.hp_max;
	
	if(target.disappearTime) then
		if(not self._blTime) then
			self._txtTime.gameObject:SetActive(true);
			self._blTime = true;
		end
		self._txtTime.text = downTime .. self:_formatTime(target.disappearTime);
	else
		if(self._blTime) then
			self._txtTime.gameObject:SetActive(false);
			self._blTime = false;
		end
	end
	
	if(target.vested and target.vested ~= "") then
		if(self._vested ~= target.vested) then
			self._vested = target.vested
		end
		if(not self._blVested) then
			self._blVested = true;
			self._btnVested.gameObject:SetActive(true);
		end
	else
		if(self._blVested) then
			self._blVested = false;
			self._btnVested.gameObject:SetActive(false);
		end
	end
	
	if(not self._blActive) then
		self._blActive = true
		SetUIEnable(self._trsContent, true)
	--        self:SetEnable(true)
	--        self._gameObject:SetActive(true);
	end
	self._buffPanel:Update();
end

function BossHeadPanel:_GetBar(index)
	if(index > 0 and index <= table.getCount(BossHeadPanel.HPBars)) then
		return BossHeadPanel.HPBars[index]
	end
	return "";
end

function BossHeadPanel:_formatTime(val)
	local m = math.floor(val) % 60;
	local f = math.floor(math.floor(val) / 60);
	return string.format("%.2d:%.2d", f, m);
end

function BossHeadPanel:_IsShowByRole(role)
	if(role and role.info) then
		if(role.roleType == ControllerType.MONSTER) then
			local info = role.info;
			if(info.type == 2 or info.type == 3 or info.type == 4 or info.type == 5 or info.type == 6) then
				return true;
			end
		end
	end
	return false;
end

function BossHeadPanel:_Dispose()
	UIUtil.GetComponent(self._btnVested, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickVestedHandler = nil;
	if(self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
	if(self._buffPanel) then
		self._buffPanel:Dispose();
		self._buffPanel = nil;
	end
end