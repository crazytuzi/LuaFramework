require "Core.Module.Common.UIComponent"

BaseSetPanel = class("BaseSetPanel", UIComponent);

local sm_instance = SoundManager.instance

function BaseSetPanel:New()
	self = {};
	setmetatable(self, {__index = BaseSetPanel});
	return self
end
function BaseSetPanel:_Init()
	self._isChange = false
	self:_InitReference();
	self:_InitListener();
	self.maxCount = QualitySetting.GetPlayerMax()
	self._txtMaxCount.text = tostring(self.maxCount)
	self._sliderPlayerCount.numberOfSteps = self.maxCount * 2 + 1
	self._sliderVolume.numberOfSteps = 101
	self._sliderVolume2.numberOfSteps = 101
	local playerInfo = PlayerManager.GetPlayerInfo()
	self._txtName.text = playerInfo.name
	self._txtServerName.text = "【" .. LoginManager.GetCurrentServer().name .. "】"
	self._txtLevel.text = GetLv(playerInfo.level)
	self._imgIcon.spriteName = playerInfo.icon_id
	self._imgLevelBg.spriteName = playerInfo.level <= 400 and "levelBg1" or "levelBg2"
	self._imgLevelBg:MakePixelPerfect()
	self:UpdatePanel()
end

function BaseSetPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtVolume = UIUtil.GetChildInComponents(txts, "txtVolume");
	self._txtVolume2 = UIUtil.GetChildInComponents(txts, "txtVolume2");
	self._txtPlayerCount = UIUtil.GetChildInComponents(txts, "txtPlayerCount");
	self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtServerName = UIUtil.GetChildInComponents(txts, "txtServerName");
	self._txtMaxCount = UIUtil.GetChildInComponents(txts, "maxCount")
	self._imgIcon = UIUtil.GetChildByName(self._gameObject, "UISprite", "icon")
	self._btnChangeAccount = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnChangeAccount");
	self._btnChangePlayer = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnChangePlayer");
	self._btnDefaultSet = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnDefaultSet");
	local togs = UIUtil.GetComponentsInChildren(self._gameObject, "UIToggle");
	self._toggle_skillEffect = UIUtil.GetChildInComponents(togs, "toggle_skillEffect");
	self._toggle_wing = UIUtil.GetChildInComponents(togs, "toggle_wing");
	self._toggle_skillShake = UIUtil.GetChildInComponents(togs, "toggle_skillShake");
	self._toggle_pet = UIUtil.GetChildInComponents(togs, "toggle_pet");
	self._toggle_shadow = UIUtil.GetChildInComponents(togs, "toggle_shadow");
	self._toggle_name = UIUtil.GetChildInComponents(togs, "toggle_name");
	self._toggle_trump = UIUtil.GetChildInComponents(togs, "toggle_trump");
	--self._toggle_soundEffect = UIUtil.GetChildInComponents(togs, "toggle_soundEffect");
	--self._toggle_music = UIUtil.GetChildInComponents(togs, "toggle_music");
	self._sliderVolume = UIUtil.GetChildByName(self._gameObject, "UISlider", "leftPanel/slider_volume")
	self._sliderVolume2 = UIUtil.GetChildByName(self._gameObject, "UISlider", "leftPanel/slider_volume2")
	self._sliderPlayerCount = UIUtil.GetChildByName(self._gameObject, "UISlider", "leftPanel/slider_playerCount")
	
	self._imgLevelBg = UIUtil.GetChildByName(self._gameObject, "UISprite", "levelBg")
	self._btnChangeName = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnChangeName")
	self._trsChangeName = UIUtil.GetChildByName(self._gameObject, "Transform", "trsChangeName").gameObject
	self._trsChangeName:SetActive(false)
	
	if(SDKHelper.instance:IsSupportSwitchLogin() == 0) then
		self._btnChangeAccount.gameObject:SetActive(false)
	end
end

function BaseSetPanel:_OnVolumeValueChange()
	self._isChange = true
	self._txtVolume.text = tostring(math.ceil(self._sliderVolume.value * 100))
	self.config.soundVolume = self._sliderVolume.value
	sm_instance.soundVolume = self._sliderVolume.value
	sm_instance.isAudioOpen = self.config.soundVolume ~= 0
end
function BaseSetPanel:_OnVolumeValueChange2()
	self._isChange = true
	self._txtVolume2.text = tostring(math.ceil(self._sliderVolume2.value * 100))
	self.config.musicVolume = self._sliderVolume2.value
	sm_instance.musicVolume = self._sliderVolume2.value
	sm_instance.isMusicOpen = self.config.musicVolume ~= 0
end

function BaseSetPanel:_OnPlayerCountValueChange()
	self._isChange = true
	local count = math.ceil(self._sliderPlayerCount.value * self.maxCount)
	self._txtPlayerCount.text = tostring(count)
	SceneMap.SetMaxPlayCount(count)
	self.config.maxPlayerCount = count
	self.config.maxPlayerSliderValue = self._sliderPlayerCount.value
end

function BaseSetPanel:_InitListener()
	--self._onClickToggleMusic = function(go) self:_OnClickToggleMusic(self) end
	--UIUtil.GetComponent(self._toggle_music, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleMusic);
	--self._onClickToggleSoundEffect = function(go) self:_OnClickToggleSoundEffect(self) end
	--UIUtil.GetComponent(self._toggle_soundEffect, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleSoundEffect);
	self._onClickToggleTrump = function(go) self:_OnClickToggleTrump(self) end
	UIUtil.GetComponent(self._toggle_trump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleTrump);
	
	self._onClickToggleName = function(go) self:_OnClickToggleName(self) end
	UIUtil.GetComponent(self._toggle_name, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleName);
	
	self._onClickToggleShadow = function(go) self:_OnClickToggleShadow(self) end
	UIUtil.GetComponent(self._toggle_shadow, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleShadow);
	
	self._onClickTogglePet = function(go) self:_OnClickTogglePet(self) end
	UIUtil.GetComponent(self._toggle_pet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTogglePet);
	
	self._onClickToggleSkillShake = function(go) self:_OnClickToggleSkillShake(self) end
	UIUtil.GetComponent(self._toggle_skillShake, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleSkillShake);
	
	self._onClickToggleWing = function(go) self:_OnClickToggleWing(self) end
	UIUtil.GetComponent(self._toggle_wing, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleWing);
	
	self._onClickToggleSkillEffect = function(go) self:_OnClickToggleSkillEffect(self) end
	UIUtil.GetComponent(self._toggle_skillEffect, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggleSkillEffect);
	
	self._onClick_btnChangeName = function(go) self:_OnClick_btnChangeName(self) end
	UIUtil.GetComponent(self._btnChangeName, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick_btnChangeName);
	MessageManager.AddListener(AutoFightNotes, AutoFightNotes.ENV_CHANGE_ROLE_NAME, BaseSetPanel._OnChangeRoleName, self);
	
	self._onClickBtnChangeAccount = function(go) self:_OnClickBtnChangeAccount(self) end
	UIUtil.GetComponent(self._btnChangeAccount, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnChangeAccount);
	self._onClickBtnChangePlayer = function(go) self:_OnClickBtnChangePlayer(self) end
	UIUtil.GetComponent(self._btnChangePlayer, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnChangePlayer);
	self._onClickBtnDefaultSet = function(go) self:_OnClickBtnDefaultSet(self) end
	UIUtil.GetComponent(self._btnDefaultSet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDefaultSet);
	
	self._sliderVolumeCallBack = EventDelegate.Callback(
	function()
		self:_OnVolumeValueChange()
	end)
	self._sliderVolumeCallBack2 = EventDelegate.Callback(
	function()
		self:_OnVolumeValueChange2()
	end)
	EventDelegate.Add(self._sliderVolume.onChange, self._sliderVolumeCallBack)
	EventDelegate.Add(self._sliderVolume2.onChange, self._sliderVolumeCallBack2)
	
	self._sliderPlayerCountCallBack = EventDelegate.Callback(
	function()
		self:_OnPlayerCountValueChange()
	end)
	EventDelegate.Add(self._sliderPlayerCount.onChange, self._sliderPlayerCountCallBack)
end

function BaseSetPanel:_OnClickBtnChangeAccount()
	LogHttp.SendOperaLog("更换帐号")
	
	self:Change(0)
end

function BaseSetPanel:_OnClickBtnChangePlayer()
	LogHttp.SendOperaLog("更换角色")
	
	
	self:Change(1)
end

function BaseSetPanel:_OnClickBtnDefaultSet()
	self._isChange = true
	self.config = AutoFightManager.GetDefaultBaseSettingConfig()
	self:SetData()
	AutoFightManager.SaveBaseSettingConfig(self.config)
	--sm_instance.isMusicOpen = self.config.isMusicOpen
	--sm_instance.isAudioOpen = self.config.isAudioOpen
	sm_instance.isMusicOpen = self.config.musicVolume ~= 0
	sm_instance.isAudioOpen = self.config.soundVolume ~= 0
	sm_instance.soundVolume = self.config.soundVolume
	sm_instance.musicVolume = self.config.musicVolume
	--SceneManager.GetIns():SetLightActive(self.config.showShadow)   
	HeroController.GetInstance():ShowLightShadow(self.config.showShadow)
end

--function BaseSetPanel:_OnClickToggleMusic()
--    sm_instance.isMusicOpen = self._toggle_music.value
--    self.config.isMusicOpen = self._toggle_music.value
--end
--function BaseSetPanel:_OnClickToggleSoundEffect()
--    sm_instance.isAudioOpen = self._toggle_soundEffect.value
--    self.config.isAudioOpen = self._toggle_soundEffect.value
--end
function BaseSetPanel:_OnClickToggleTrump()
	self._isChange = true
	self.config.showTrump = self._toggle_trump.value
end

function BaseSetPanel:_OnClickToggleName()
	self._isChange = true
	self.config.showName = self._toggle_name.value
end

function BaseSetPanel:_OnClickToggleShadow()
	self._isChange = true
	local v = self._toggle_shadow.value
	self.config.showShadow = v
	--GameConfig.instance.useLight = v
	--SceneManager.GetIns():SetLightActive(v)
	HeroController.GetInstance():ShowLightShadow(v)
	GameSceneManager.UpdateShowShadow(v)
end

function BaseSetPanel:_OnClickTogglePet()
	self._isChange = true
	self.config.showPet = self._toggle_pet.value
end

function BaseSetPanel:_OnClickToggleSkillShake()
	self._isChange = true
	self.config.showSkillShakeEffect = self._toggle_skillShake.value
end

function BaseSetPanel:_OnClickToggleWing()
	self._isChange = true
	self.config.showWing = self._toggle_wing.value
end

function BaseSetPanel:_OnClickToggleSkillEffect()
	self._isChange = true
	self.config.showSkillEffect = self._toggle_skillEffect.value
end

function BaseSetPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	if self._isChange then
		AutoFightManager.SaveBaseSettingConfig(self.config)
		MessageManager.Dispatch(AutoFightManager, AutoFightManager.BASESETTINGCHANGE, self.config)
	end
end

function BaseSetPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnChangeAccount, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnChangeAccount = nil;
	UIUtil.GetComponent(self._btnChangePlayer, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnChangePlayer = nil;
	UIUtil.GetComponent(self._btnDefaultSet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnDefaultSet = nil;
	
	--UIUtil.GetComponent(self._toggle_music, "LuaUIEventListener"):RemoveDelegate("OnClick");
	--self._onClickToggleMusic = nil
	--UIUtil.GetComponent(self._toggle_soundEffect, "LuaUIEventListener"):RemoveDelegate("OnClick");
	--self._onClickToggleSoundEffect = nil
	UIUtil.GetComponent(self._toggle_trump, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggleTrump = nil
	
	UIUtil.GetComponent(self._toggle_name, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggleName = nil
	
	UIUtil.GetComponent(self._toggle_shadow, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggleShadow = nil
	
	UIUtil.GetComponent(self._toggle_pet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTogglePet = nil
	
	UIUtil.GetComponent(self._toggle_skillShake, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggleSkillShake = nil
	
	UIUtil.GetComponent(self._toggle_wing, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggleWing = nil
	
	UIUtil.GetComponent(self._toggle_skillEffect, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggleSkillEffect = nil
	
	UIUtil.GetComponent(self._btnChangeName, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick_btnChangeName = nil
	MessageManager.RemoveListener(AutoFightNotes, AutoFightNotes.ENV_CHANGE_ROLE_NAME, BaseSetPanel._OnChangeRoleName)
	if self._btnCreate then UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RemoveDelegate("OnClick") end
	self._onClick_btnCreate = nil
	if self._btnCancel then UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnClick") end
	self._onClick_btnCancel = nil
	
	EventDelegate.Remove(self._sliderVolume.onChange, self._sliderVolumeCallBack)
	EventDelegate.Remove(self._sliderVolume2.onChange, self._sliderVolumeCallBack2)
	EventDelegate.Remove(self._sliderPlayerCount.onChange, self._sliderPlayerCountCallBack)
	
end

function BaseSetPanel:_DisposeReference()
	self._btnChangeAccount = nil;
	self._btnChangePlayer = nil;
	self._btnDefaultSet = nil;
	self._toggle_skillEffect = nil;
	self._toggle_wing = nil;
	self._toggle_skillShake = nil;
	self._toggle_pet = nil;
	self._toggle_shadow = nil;
	self._toggle_name = nil;
	self._toggle_trump = nil;
	self._toggle_soundEffect = nil;
	self._toggle_music = nil;
	self._txtVolume = nil;
	self._txtVolume2 = nil;
	self._txtPlayerCount = nil;
	self._txtLevel = nil;
	self._txtName = nil;
	self._txtServerName = nil;
	self._btnChangeName = nil
	self._trsChangeName = nil
	self._btnCreate = nil
	self._btnCancel = nil
	self._inputName = nil
end

function BaseSetPanel:UpdatePanel()
	self.config = ConfigManager.Clone(AutoFightManager.GetBaseSettingConfig())
	self:SetData()
end

function BaseSetPanel:SetData()
	--self._toggle_music.value = self.config.isMusicOpen
	--self._toggle_soundEffect.value = self.config.isAudioOpen
	self._toggle_skillEffect.value = self.config.showSkillEffect
	self._toggle_wing.value = self.config.showWing
	self._toggle_skillShake.value = self.config.showSkillShakeEffect
	self._toggle_pet.value = self.config.showPet
	self._toggle_shadow.value = self.config.showShadow
	self._toggle_name.value = self.config.showName
	self._toggle_trump.value = self.config.showTrump
	self._sliderVolume.value = self.config.soundVolume
	self._sliderVolume2.value = self.config.musicVolume
	self._sliderPlayerCount.value = self.config.maxPlayerSliderValue or(self.config.maxPlayerCount / self.maxCount)
end

function BaseSetPanel:Change(t)
	if(GameConfig.instance.useSdk and t == 0) then
		SDKHelper.instance:SwitchLogin(function() AutoFightProxy.SendExitGame(t) end)
	else
		local notice = ""
		if(t == 0) then
			notice = LanguageMgr.Get("BaseSetPanel/ensureGoBackToSelectServer")
		elseif(t == 1) then
			notice = LanguageMgr.Get("BaseSetPanel/ensureGoBackToSelectPlayer")
		end
		
		ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
			title = LanguageMgr.Get("common/notice"),
			msg = notice,
			ok_Label = LanguageMgr.Get("common/ok"),
			cance_lLabel = LanguageMgr.Get("common/cancle"),
			hander = AutoFightProxy.SendExitGame,
			data = t,
		});
	end
end

function BaseSetPanel:_OnClick_btnChangeName()
	self._trsChangeName:SetActive(true)
	if not self._btnCreate then
		self._btnCreate = UIUtil.GetChildByName(self._trsChangeName, "UIButton", "btnCreate")
		self._btnCancel = UIUtil.GetChildByName(self._trsChangeName, "UIButton", "btnCancel")
		self._inputName = UIUtil.GetChildByName(self._trsChangeName, "UIInput", "inputName")
		self._onClick_btnCreate = function(go) self:_OnClick_btnCreate(self) end
		UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick_btnCreate);
		self._onClick_btnCancel = function(go) self:_OnClick_btnCancel(self) end
		UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick_btnCancel);
	end
end
function BaseSetPanel:_OnClick_btnCreate()
	local n = self._inputName.value
	if #n == 0 then return end	
	local fun = function()
		AutoFightProxy.TryChangeRoleName(n)
	end
	
	MsgUtils.ShowConfirm(self, "BaseSetPanel/changeNameCost", nil, fun)
	
end
function BaseSetPanel:_OnClick_btnCancel()
	self._trsChangeName:SetActive(false)
end
function BaseSetPanel:_OnChangeRoleName()
	self._txtName.text = PlayerManager.GetPlayerInfo().name
	self._trsChangeName:SetActive(false)
end

