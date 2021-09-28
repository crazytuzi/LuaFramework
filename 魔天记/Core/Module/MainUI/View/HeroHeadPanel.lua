require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.BuffPanel"

HeroHeadPanel = class("HeroHeadPanel", UIComponent)
HeroHeadPanel.PKTYPECOOLTIME = 10;
function HeroHeadPanel:New()
	self = {};
	setmetatable(self, {__index = HeroHeadPanel});
	return self;
end

function HeroHeadPanel:_Init()
	local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
	self._blShow = false
	
	self.trsMode1 = UIUtil.GetChildByName(trsContent, "Transform", "trsMode1");
	self.trsMode2 = UIUtil.GetChildByName(trsContent, "Transform", "trsMode2");
	self.txtTime = UIUtil.GetChildByName(self.trsMode1, "UILabel", "SysInfo/txtTime");
	self.imgSignal = UIUtil.GetChildByName(self.trsMode1, "UISprite", "SysInfo/imgSignal");
	self.imgPower = UIUtil.GetChildByName(self.trsMode1, "UISprite", "SysInfo/imgPower");
	self._imgBg1 = UIUtil.GetChildByName(self.trsMode1, "UISprite", "imgBackground")
	self._imgBg2 = UIUtil.GetChildByName(self.trsMode2, "UISprite", "imgBackground2")
	
	self._buffPanel = BuffPanel:New(UIUtil.GetChildByName(trsContent, "Transform", "trsMode1/trsBuff"))
	
	
	self._imgIcon = UIUtil.GetChildByName(trsContent.gameObject, "UISprite", "imgIcon");
	self._hasMsg = UIUtil.GetChildByName(self._imgIcon, "UISprite", "hasMsg");
	self.gensuiIcon = UIUtil.GetChildByName(trsContent.gameObject, "UISprite", "gensuiIcon");
	
	-- self._imgCareer = UIUtil.GetChildByName(trsContent.gameObject, "UISprite", "imgCareer");
	-- self._txtName = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtName");
	self._txtLevel = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtLevel");
	
	self._txtFight = UIUtil.GetChildByName(self.trsMode1, "UILabel", "txtFight");
	self._txtHP = UIUtil.GetChildByName(self.trsMode1, "UILabel", "txtHP");
	self._txtMP = UIUtil.GetChildByName(self.trsMode1, "UILabel", "txtMP");
	self._sliderHP = UIUtil.GetChildByName(self.trsMode1, "UISlider", "sliderHP");
	self._sliderMP = UIUtil.GetChildByName(self.trsMode1, "UISlider", "sliderMP");
	
	self._btnPkType = UIUtil.GetChildByName(self.trsMode1, "UIButton", "btn_pkType");
	self._txtPkType = UIUtil.GetChildByName(self._btnPkType, "UILabel", "Label");
	self._imgPkType = UIUtil.GetComponent(self._btnPkType, "UISprite");
	
	self._txtVip = UIUtil.GetChildByName(self.trsMode1, "UILabel", "txtVip");
	self._txtVipTips = UIUtil.GetChildByName(self._txtVip, "UISprite", "imgMsg");
	self._icoMore = UIUtil.GetChildByName(self.trsMode1, "UISprite", "icoMore");
	self._txtVipTry = UIUtil.GetChildByName(self._txtVip, "UILabel", "viptrybg/txtVipTry");
	
	self._onClickVip = function(go) self:_OnClickVip() end
	UIUtil.GetComponent(self._txtVip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickVip);
	self._onClickMore = function(go) self:_OnClickMore() end
	UIUtil.GetComponent(self._icoMore, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMore);
	self._onClickPKTypeHandler = function(go) self:_OnClickPKTypeHandler(self) end
	UIUtil.GetComponent(self._btnPkType, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickPKTypeHandler);
	
	self._hpSprite = UIUtil.GetChildByName(self.trsMode2, "UISprite", "hpSprite");
	
	self._myis_leaderIcon = UIUtil.GetChildByName(trsContent.gameObject, "Transform", "myis_leaderIcon");
	self._myis_leaderIcon.gameObject:SetActive(false);
	
	self.mode = HeroHeadPanel.mode1;
	self.trsMode2.gameObject:SetActive(false);
	self.gensuiIcon.gameObject:SetActive(false);
	
	
	local hero = HeroController.GetInstance();
	local info = hero.info;
	self._buffPanel:SetRole(hero);
	if(info) then
		self._imgIcon.spriteName = info.icon_id;
		self._pkType = info.pkType;
		-- self._imgCareer.spriteName = "career_" .. info.kind;
		-- self._txtName.text = info.name;
		self:_LevelChange(info.level)
		self:_PkDataChange();
	end
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, HeroHeadPanel._LevelChange, self)
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfHpChange, HeroHeadPanel._HpSliderChange, self)
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfMpChange, HeroHeadPanel._MpSliderChange, self)
	MessageManager.AddListener(PlayerManager, PlayerManager.SELFATTRIBUTECHANGE, HeroHeadPanel._AttrChange, self);
	MessageManager.AddListener(PlayerManager, PlayerManager.SELFFIGHTCHANGE, HeroHeadPanel._PowerChange, self);
	MessageManager.AddListener(PlayerManager, PlayerManager.PKDataChange, HeroHeadPanel._PkDataChange, self);
	MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, HeroHeadPanel.PartDataChangeHandler, self);
	MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, HeroHeadPanel.SceneChange, self);
	MessageManager.AddListener(VIPManager, VIPManager.VipChange, HeroHeadPanel.VipDataChange, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, HeroHeadPanel.VipDataChange, self);
	UpdateBeat:Add(self.OnUpdate, self);
	
	self:PartDataChangeHandler()
	self:VipDataChange();
	self:InitSysInfo()
	
	self:VipTry(VIPManager.VipTryCheck())
end

function HeroHeadPanel:SetHasMsgFlg(val)
	self._hasMsg.enabled = val
end


function HeroHeadPanel:OnUpdate()	
	self._buffPanel:Update()
	if self.updateFightPower then
		local power = tonumber(self._txtFight.text);
		if power == self.fightPower then
			self.updateFightPower = false;
		else
			local val = math.max(math.abs((self.fightPower - power) / 10), 1);
			if self.fightPower > power then
				power = math.ceil(power + val);
			else
				power = math.ceil(power - val);
			end
			self._txtFight.text = power;
		end
	end
end

-- {"l":[{"pid":"20100796","t":0},{"pid":"20100832","t":1}]}
function HeroHeadPanel:GensuiMenberChange(list)
	
	local info = HeroController.GetInstance().info;
	self.gensuiIcon.gameObject:SetActive(false);
	
	local my_id = info.id + 0;
	
	local len = table.getn(list);
	for i = 1, len do
		local pid = list[i].pid + 0;
		local t = list[i].t;
		
		if my_id == pid then
			if t == 1 then
				self.gensuiIcon.gameObject:SetActive(true);
			end
			return;
		end
	end
end

function HeroHeadPanel:PartDataChangeHandler()
	
	local data = PartData.GetMyTeam();
	if data ~= nil then
		
		local myHero = HeroController.GetInstance();
		local mydata = PartData.FindMyTeammateData(myHero.info.id);
		
		
		if mydata ~= nil and mydata.p == 1 then
			self._myis_leaderIcon.gameObject:SetActive(true);
			return;
		end
	end
	
	self._myis_leaderIcon.gameObject:SetActive(false);
	
end

function HeroHeadPanel:_HpSliderChange()
	local info = HeroController.GetInstance():GetInfo()
	self._txtHP.text = info.hp .. "/" .. info.hp_max;
	
	local progress = info.hp / info.hp_max;
	self._sliderHP.value = progress;
	self._hpSprite.fillAmount = progress;
end

function HeroHeadPanel:_MpSliderChange(curMp)
	local info = HeroController.GetInstance():GetInfo()
	self._txtMP.text = info.mp .. "/" .. info.mp_max;
	self._sliderMP.value = info.mp / info.mp_max;
end

function HeroHeadPanel:_LevelChange()
	local info = PlayerManager.GetPlayerInfo()
	
	if(self._txtLevel) then
		self._txtLevel.text = GetLv(info.level);
	end
	
	self._imgBg1.spriteName = info.level > 400 and "myRoleBg_new" or "myRoleBg"
	self._imgBg2.spriteName = info.level > 400 and "myRoleBg2_new" or "myRoleBg2"
	
	self:UpdateIcons();
	self:_PkDataChange();
	self:_HpSliderChange(info.hp)
	self:_MpSliderChange(info.mp)
	self:_PowerChange()
end

function HeroHeadPanel:_AttrChange()
	local info = PlayerManager.GetPlayerInfo()
	self:_HpSliderChange(info.hp)
	self:_MpSliderChange(info.mp)
end

function HeroHeadPanel:_PowerChange()
	local power = PlayerManager.GetSelfFightPower();
	local map = GameSceneManager.map;
	if(map) then
		local mapType = map.info.type
		if(mapType == InstanceDataManager.MapType.Novice) then
			power = 999999;
		end
	end
	if self.fightPower == nil then
		self._txtFight.text = power;
	elseif self.fightPower ~= power then
		self.updateFightPower = true;
	end
	self.fightPower = power;
end

function HeroHeadPanel:_PkDataChange()
	if(self._btnPkType) then
		local info = HeroController.GetInstance().info;
		if(info and info.level >= 20) then
			self._imgPkType.spriteName = "btnPkTypeH" ..(info.pkType + 1);
			self._btnPkType.normalSprite = "btnPkTypeH" ..(info.pkType + 1);
			if(info.pkType == 3 and info.pkState == 2) then				
				-- self._btnPkType.isEnabled = false;
			else
				if(self._pkType ~= info.pkType) then
					-- self._btnPkType.isEnabled = false;
					self._pkType = info.pkType
				else
					-- self._btnPkType.isEnabled = true;
				end
			end
			self._txtPkType.text = LanguageMgr.Get("PVP/pkType1" .. info.pkType);
			self._btnPkType.gameObject:SetActive(true);
			self._blShow = true
		else
			self._btnPkType.gameObject:SetActive(false);
			self._blShow = false
		end
		self:UpdatePKStatus();
	end
end

function HeroHeadPanel:VipDataChange()
	self._txtVip.text = VIPManager.GetVIPShowLevel();
	--self._txtVipTips.enabled = VIPManager.HasVipTips()
end

function HeroHeadPanel:SceneChange()
	self:UpdatePKStatus();
	self:_PowerChange();
	self:UpdateIcons();
end

function HeroHeadPanel:_OnClickPKTypeHandler()
	local info = HeroController.GetInstance().info;
	if(info and info.level >= 20) then
		local map = GameSceneManager.map;
		if(map) then
			if(map.info.type == InstanceDataManager.MapType.WorldBoss) then
				MsgUtils.ShowTips("PVP/pkTypeWoldBossMsg");
				return;
			end
			local monsters = GameSceneManager.map:GetAllRoles(ControllerType.MONSTER);
			for i, v in pairs(monsters) do
				if(v and v.info and v.info.slaughter) then
					MsgUtils.ShowTips("PVP/pkTypeWildBossMsg");
					return;
				end
			end
		end
		ModuleManager.SendNotification(ChoosePKTypeNotes.OPEN_CHOOSEPKTYPE);
	end
end

function HeroHeadPanel:_OnClickVip()
	ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 4})
end

function HeroHeadPanel:_OnClickMore()
	ModuleManager.SendNotification(PromoteNotes.OPEN_PROMOTE);
end

function HeroHeadPanel:_Dispose()
	
	UpdateBeat:Remove(self.OnUpdate, self);
	
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, HeroHeadPanel._LevelChange)
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfHpChange, HeroHeadPanel._HpSliderChange)
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfMpChange, HeroHeadPanel._MpSliderChange)
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFATTRIBUTECHANGE, HeroHeadPanel._AttrChange);
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFFIGHTCHANGE, HeroHeadPanel._PowerChange);
	MessageManager.RemoveListener(PlayerManager, PlayerManager.PKDataChange, HeroHeadPanel._PkDataChange);
	MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, HeroHeadPanel.PartDataChangeHandler);
	MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, HeroHeadPanel.SceneChange);
	MessageManager.RemoveListener(VIPManager, VIPManager.VipChange, HeroHeadPanel.VipDataChange);
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, HeroHeadPanel.VipDataChange);
	UIUtil.GetComponent(self._txtVip, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickVip = nil;
	UIUtil.GetComponent(self._icoMore, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickMore = nil;
	UIUtil.GetComponent(self._btnPkType, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickPKTypeHandler = nil;
	
	self._buffPanel:Dispose()
	self._buffPanel = nil;
	self:ClearTime()
end

function HeroHeadPanel:Toggle()
	self.mode = self.mode == MainUIPanel.Mode.SHOW and MainUIPanel.Mode.HIDE or MainUIPanel.Mode.SHOW;
	self:UpdateMode();
end

function HeroHeadPanel:Hide()
	self.mode = MainUIPanel.Mode.HIDE
	self:UpdateMode();
end

function HeroHeadPanel:SetDisplay(mode)
	self.mode = mode;
	self:UpdateMode();
end

function HeroHeadPanel:UpdateMode()
	self.trsMode1.gameObject:SetActive(self.mode == MainUIPanel.Mode.HIDE);
	self.trsMode2.gameObject:SetActive(self.mode == MainUIPanel.Mode.SHOW);
end

function HeroHeadPanel:UpdateIcons()
	local map = GameSceneManager.map;
	if(map) then
		local mapType = map.info.type
		if(SystemManager.IsOpen(SystemConst.Id.VIP)) then
			if mapType == InstanceDataManager.MapType.Novice then
				self._txtVip.gameObject:SetActive(false);
				self._icoMore.gameObject:SetActive(false);
			else
				self._txtVip.gameObject:SetActive(true);
				self._icoMore.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.STRONG));
			end			
		else
			self._txtVip.gameObject:SetActive(false);
			if mapType == InstanceDataManager.MapType.Novice then			
				self._icoMore.gameObject:SetActive(false);
			else			 
				self._icoMore.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.STRONG));
			end		
		end
		
	else
	
		self._txtVip.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.VIP));
		self._icoMore.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.STRONG));
	end
end

function HeroHeadPanel:UpdatePKStatus()
	if(self._btnPkType) then
		local map = GameSceneManager.map;
		if(map) then
			local mapType = map.info.type
			self._btnPkType.gameObject:SetActive(mapType ~= InstanceDataManager.MapType.Novice and self._blShow)
		end
	end
end

local helper = SDKHelper.instance
local loger = LogHelp.instance
local socket = SocketClientLua.Get_ins().socket
local GetDate = os.date
local Floor = math.floor
local Clamp = math.clamp
local UpdateTimeRate = 60
local UpdateSignalRate = 3
local UpdatePowerRate = 3 --60
local timer
local _updateTime = 0
local _updateSignal = 0
local _updatePower = 0
function HeroHeadPanel:InitSysInfo()
	self:ClearTime()
	local onTime = function() self:OnTime() end
	timer = Timer.New(onTime, 1, - 1, false):Start()
	--Warning("InitSysInfo,___" .. tonumber(GetDate("%S")))
	self:OnTime()
	_updateTime = UpdateTimeRate - tonumber(GetDate("%S"))
end
function HeroHeadPanel:OnTime()
	if _updateTime == 0 then self:UpdateTime() end
	if _updateSignal == 0 then self:UpdateSignal() end
	if _updatePower == 0 then self:UpdatePower() end
	_updateTime = _updateTime - 1
	_updateSignal = _updateSignal - 1
	_updatePower = _updatePower - 1
end
function HeroHeadPanel:UpdateTime()
	_updateTime = UpdateTimeRate
	--Warning("UpdateTime,___" .. GetDate("%H:%M"))
	self.txtTime.text = GetDate("%H:%M")
end
function HeroHeadPanel:UpdateSignal()
	_updateSignal = UpdateSignalRate
	local stat = loger:GetNetworkState()
	--Warning(tostring(LogHelp.instance:GetNetworkState()) .. "_" .. tostring(Util.IsWifi))
	local l = 1
	if stat == "wifi" then
		local s = - 1 --helper:GetSignalStrength()
		if s == - 1 then
			local d = socket.netDelay
			if d < 50 then l = 4
			elseif d < 70 then l = 3
			elseif d < 100 then l = 2
			end
		else
			l = Floor(s + 1)
		end
	elseif stat == "notReachable" or stat == "no network" or stat == "notConnect" or stat == "unknow" then
		l = 1
	else
		l = 0
	end
	--Warning("UpdateSignal,___" .. s .. "___" .. l.. "___" .. socket.netDelay)
	self.imgSignal.spriteName = "signal" .. l
end
function HeroHeadPanel:UpdatePower()
	_updatePower = UpdatePowerRate
	local s = helper:GetBatteryLevel()
	local l = 1
	if s > 90 then l = 4
	elseif s > 50 then l = 3
	elseif s > 10 then l = 2
	elseif s == - 1 then l = 4
	end
	--Warning("UpdatePower,___" .. s .. "___" .. l)
	self.imgPower.spriteName = "power" .. l
end
function HeroHeadPanel:ClearTime()
	if timer then timer:Stop() timer = nil end
	if self._viptimer then self._viptimer:Stop() self._viptimer = nil end
end
--vip������,{s:��ʼ1,0����,tʣ��ʱ��(��)}
function HeroHeadPanel:VipTry(bd)
	if not bd then return end
	local isStart = bd.s == 1
	if isStart then self:_StartVipTry(bd)
	else self:_EndVipTry() end
end
function HeroHeadPanel:_StartVipTry(bd)
	if not self._viptimer then
		self._viptimer = Timer.New(function() self:_UpdateVipTry() end, 1, - 1)
		self._viptimer:Start()
	end
	self._txtVipTry.transform.parent.gameObject:SetActive(true)
	self:_UpdateVipTry()	
end
function HeroHeadPanel:_EndVipTry()
	self._txtVipTry.transform.parent.gameObject:SetActive(false)
	if self._viptimer then self._viptimer:Stop() self._viptimer = nil end
end
function HeroHeadPanel:_UpdateVipTry()
	local val = VIPManager.GetVIPDownTime()
	local m = math.floor(val) % 60
	local f = math.floor(val / 60)
	local t = string.format("%.2d:%.2d", f, m)
	--Warning(tostring(self.val) .. '----' .. tostring(self._txtVipTry))
	self._txtVipTry.text = LanguageMgr.Get("Mall/vip/vipTryInfo", {t = t})
	if val < 0 then self:_EndVipTry() end
end

