require "Core.Module.Common.UIComponent"
require "Core.Module.Common.UIEffect"


SkillButton = class("SkillButton", UIComponent)

function SkillButton:New()
	self = {};
	setmetatable(self, {__index = SkillButton});
	return self;
end

function SkillButton:Init(transform, isSkill)
	if(isSkill ~= nil) then
		self._isSkill = isSkill
	else
		self._isSkill = true
	end
	
	self.super.Init(self, transform, isSkill)
end

function SkillButton:_Init()
	self._imgCoolBg = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgCoolBg");
	self._imgCool = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgCool");
	self._imgDelayCool = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgDelayCool");
	self._imgIcon = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgIcon");
	self._txtTimer = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTimer");
	self._txtLink = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtLink");
	self._imgFrame = UIUtil.GetComponent(self._gameObject, "UISprite");
	self._button = UIUtil.GetComponent(self._gameObject, "UIButton");
	self._icoLock = UIUtil.GetChildByName(self._gameObject, "UISprite", "icoLock");
	self._txtLock = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtLock");
	
	self._effect = UIEffect:New()
	if(self._isSkill) then
		self._effect:Init(self._transform, self._imgCool, 4, "ui_button_click")
	else
		self._effect:Init(self._transform, self._imgIcon, 4, "ui_button_click2")		
	end
	if self._txtTimer then
		self._txtTimer.text = "";
	end
	
	self.needSetBt = false;
	
	if(self._imgIcon == nil) then
		self._imgIcon = self._imgFrame;
		self.needSetBt = true;
	end
	
	if self._imgCoolBg then
		self._imgCoolBg.gameObject:SetActive(false);
	end
	if self._imgCool then
		self._imgCool.gameObject:SetActive(false);
	end
	if self._imgDelayCool then
		self._imgDelayCool.fillAmount = 0
	end
	
	if self._icoLock then
		self._icoLock.alpha = 0;
	end
	
	self._currCoolEffTime = - 1
	self._grayTime = 0
	self._grayTotalTime = 0
	
	self._onPress = function(go, isPress) self:_OnPress(self, isPress) end
	self._onClick = function(go) self:_OnClick(self) end
	UIUtil.GetComponent(self._button, "LuaUIEventListener"):RegisterDelegate("OnPress", self._onPress);
	UIUtil.GetComponent(self._button, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
	
	self._isCooling = false;
	self._timer = Timer.New(function(val) self:_OnUpdata(val) end, 0.1, - 1, false);
	self._timer:Start();
end

function SkillButton:AddPressListener(func)
	self._pressCallback = func;
end

function SkillButton:AddClickListener(func)
	self._clickCallback = func;
end

function SkillButton:_OnUpdata()
	local skill = self._skill;
	if(skill) then
		if(skill:IsCooling()) then
			self._imgCoolBg.fillAmount = 1
			local cd = skill.cdTime;
			local currTime = skill:CurrCoolTime();
			if(currTime < 1000) then
				self._txtTimer.text = math.ceil(currTime / 1000);
			else
				self._txtTimer.text = math.round(currTime / 1000);
			end
			self._imgCool.fillAmount = currTime / cd;
			if(not self._isCooling) then
				self._txtTimer.gameObject:SetActive(true);
				self._imgCoolBg.gameObject:SetActive(true);
				self._imgCool.gameObject:SetActive(true);
				self._imgDelayCool.fillAmount = 0;
				self._isCooling = true;
				-- self._button.isEnabled = false;
			end
		else
			if(skill:IsSeries() and skill.skill_type ~= 1) then
				local delayCooTime = skill:DelayCooTime();
				if(delayCooTime > 0) then
					self._imgDelayCool.fillAmount = delayCooTime / skill.link_time
				end
			end
			if(self._isCooling) then
				self._txtTimer.gameObject:SetActive(false);
				self._imgCoolBg.gameObject:SetActive(false);
				self._imgCool.gameObject:SetActive(false);
				self._isCooling = false;
				-- self._button.isEnabled = true;
				if(self._coolEff == nil) then
					self._coolEff = UIUtil.GetUIEffect("ui_cd_finish", self._gameObject.transform, self._imgIcon);
					--UIUtil.AddEffectAnchor(self._coolEff, self._imgIcon, 1);
				else
					--UIUtil.SetEffectOrder(self._coolEff, self._imgFrame);
				end
				if(not self._coolEff.activeSelf) then
					self._coolEff:SetActive(true);
				end
				
				self._currCoolEffTime = UIUtil.GetParticleSystemLength(self._coolEff.transform);
				UIUtil.PlayParticleSystem(self._coolEff)
			end
		end
		
		if(self._coolEff and self._currCoolEffTime ~= - 1) then
			self._currCoolEffTime = self._currCoolEffTime - Time.fixedDeltaTime
			if(self._currCoolEffTime < 0) then
				if(self._coolEff.activeSelf) then
					self._coolEff:SetActive(false);
				end
				
			end
		end
		
		if(self._grayTime > 0) then
			self._imgCoolBg.gameObject:SetActive(true)
			self._grayTime = self._grayTime - Time.deltaTime
			if(not skill:IsCooling()) then
				self._imgCoolBg.fillAmount = self._grayTime / self._grayTotalTime		
			end
		elseif self._grayTime < 0 then
			self._button.isEnabled = true
			if(not skill:IsCooling()) then
				self._imgCoolBg.fillAmount = 0
			end
			
			self._grayTime = 0
		end
	end
end

function SkillButton:SetGray(data)
	if(self._skill == nil) then return end
	if(self._skill.id ~= data.id) then
		self._button.isEnabled = false
		
		-- if data.break_time == 0 then			
		-- 	self._grayTime = data.sum_time * 0.001
		-- else
		-- 	self._grayTime = data.break_time * 0.001
		-- end		
		self._grayTime = 0.5
		
		self._grayTotalTime = self._grayTime
	end
end


function SkillButton:OnPress(isPress)
	self:_OnPress(self, isPress);
end

function SkillButton:_OnPress(go, isPress)
	
	self._isPress = isPress
	if(self._pressCallback) then
		self._pressCallback(isPress, self._skill);
	end
end

function SkillButton:Upspring()
	if(not self._isPress) then
		self:_OnPress(nil, false);
	end
end

function SkillButton:_OnClick(go)
	
	self._effect:Play()
	
	
	if(self._clickCallback) then
		self._clickCallback(self._skill);
	end
end

function SkillButton:_Dispose()
	if(self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
	UIUtil.GetComponent(self._button, "LuaUIEventListener"):RemoveDelegate("OnPress");
	UIUtil.GetComponent(self._button, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onPress = nil;
	self._onClick = nil;
	self._pressCallback = nil
	self._clickCallback = nil
	if self._coolEff then
		Resourcer.Recycle(self._coolEff, false);
	end
	self._coolEff = nil
	self._imgCoolBg = nil
	self._imgCool = nil
	self._imgDelayCool = nil;
	self._imgIcon = nil
	self._txtTimer = nil
	self._txtLink = nil
	self._imgFrame = nil
	self._button = nil	
	
	self._effect:Dispose()
	self._effect = nil
	
end

function SkillButton:GetSkill()
	return self._skill;
end

function SkillButton:SetSkillIndex(idx)
	self._skillIdx = idx;
	local hero = HeroController.GetInstance();
	local heroInfo = hero.info;
	local skill = nil;
	if(not hero:IsOnLMount()) then
		skill = heroInfo:GetSkillByIndex(idx);
	else
		skill = HeroController.GetInstance()._mountLangController.info:GetSkillByIndex(idx);
	end
	
	if(skill) then
		local osk = skill
		local refSkill = SkillManager.RefSkillId(skill.id);
		if(refSkill ~= skill.id) then
			skill = heroInfo:GetSkill(refSkill)
			if(skill == nil) then
				skill = heroInfo:AddSkill(refSkill, osk.skill_lv)
			else
				skill:SetLevel(osk.skill_lv);
			end
		end
	end
	
	
	
	local careerCfg = ConfigManager.GetCareerByKind(heroInfo.kind);
	local defSkillReqLv = careerCfg.skillslot_open;
	local oLv = defSkillReqLv[idx]
	
	if self._icoLock then
		self._icoLock.alpha = heroInfo.level < oLv and 1 or 0;
	end
	if(heroInfo.level < oLv) then
		if(skill) then
			skill:StopCool()
		end
		self:SetSkill(nil);
		self._txtTimer.gameObject:SetActive(false);
		self._imgCoolBg.gameObject:SetActive(false);
		self._imgCool.gameObject:SetActive(false);
	else
		self:SetSkill(skill);
	end
	
	if self._txtLock then
		if heroInfo.level < defSkillReqLv[idx] then
			self._txtLock.text = LanguageMgr.Get("Friend/HeroInfoPanelItem/label1", {n = defSkillReqLv[idx]});
		else
			self._txtLock.text = "";
		end
	end
end

function SkillButton:PlayUnlockEff()
	local effect = self._transform:Find("ui_skill_unlock");
	if effect == nil then
		effect = UIUtil.GetUIEffect("ui_skill_unlock", self._transform, self._imgFrame, 10);
	else
		effect.gameObject:SetActive(false);
		effect.gameObject:SetActive(true);
	end
end


function SkillButton:SetSkill(skill)
	
	if(self._skill ~= skill) then
		self._skill = skill;
		if(skill) then
			
			if self.needSetBt then
				self._button.normalSprite = skill.icon_id .. "";
			else
				self._imgIcon.spriteName = skill.icon_id;
			end
			
			
			if(self._txtLink) then
				self._txtLink.gameObject:SetActive(skill:IsSeries());
			end
			
		else
			self._imgIcon.spriteName = "";
			if(self._txtLink) then
				self._txtLink.gameObject:SetActive(false);
			end
			
		end
	end
	-- http://192.168.0.8:3000/issues/2856  策划 邀请 没技能的时候，连底图都隐藏
	local b = HeroController.GetInstance():IsOnLMount();
	
	if b then
		self._gameObject:SetActive(skill ~= nil);
		
	else
		if self._skillIdx then			
			self._gameObject:SetActive(true);
		else
			self._gameObject:SetActive(skill ~= nil);
		end
	end
	
end
