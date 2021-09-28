require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.ArathiPointState"

local pointCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_POINT);

ArathiWarInfoPanel = class("ArathiWarInfoPanel", UIComponent)

function ArathiWarInfoPanel:New()
	self = {};
	setmetatable(self, {__index = ArathiWarInfoPanel});
	self._isPanleActive = 0;
	return self;
end

function ArathiWarInfoPanel:GetUIOpenSoundName()
	return ""
end

function ArathiWarInfoPanel:_Init()
	local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
	local topContent = UIUtil.GetChildByName(trsContent, "Transform", "topPanel");
	local rightPanel = UIUtil.GetChildByName(trsContent, "Transform", "rightPanel");
	
	self._points = {};
	
	self._btnFunction = UIUtil.GetChildByName(trsContent, "UIButton", "btnFunction");
	self._btnFunctionIcon = UIUtil.GetChildByName(trsContent, "UISprite", "btnFunction/imgIcon");
	self._txtDes = UIUtil.GetChildByName(self._btnFunction, "UILabel", "des")
	self._imgFrame = UIUtil.GetChildByName(topContent, "UIButton", "imgFrame");
	
	self._txtTime = UIUtil.GetChildByName(topContent, "UILabel", "txtTime");
	self._txtCamp1 = UIUtil.GetChildByName(topContent, "UILabel", "txtCamp1");
	self._txtCamp2 = UIUtil.GetChildByName(topContent, "UILabel", "txtCamp2");
	
	for i = 1, 5 do
		local tran = UIUtil.GetChildByName(rightPanel, "Transform", "item" .. i);
		local cfgItem = pointCfg[i + 9];
		local item = ArathiPointState:New();
		item:Init(tran);
		item:SetName(cfgItem.l_name);
		item.id = cfgItem.id;		
		item.position = Convert.PointFromServer(cfgItem.x, cfgItem.y, cfgItem.z);
		self._points[item.id] = item;
	end
	
	self._timer = Timer.New(function(val) self:_OnUpdata(val) end, 0.3, - 1, false);
	
	self._onClickHandler = function() self:_OnClickHandler() end
	UIUtil.GetComponent(self._imgFrame, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);
	
	self._onClickFunctionHandler = function() self:_OnClickFunctionHandler() end
	UIUtil.GetComponent(self._btnFunction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickFunctionHandler);
	self._btnFunction.gameObject:SetActive(false)
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIWARDATA, ArathiWarInfoPanel._OnWarDataHandler, self);
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIRESCHAGE, ArathiWarInfoPanel._OnResChangeHandler, self);
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIMINECHAGE, ArathiWarInfoPanel._OnMinecChangeHandler, self);
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_HEROINPOINTAREA, ArathiWarInfoPanel._OnHeroInPointHandler, self);
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_HEROOUTPOINTAREA, ArathiWarInfoPanel._OnHeroOutPointHandler, self);
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIFIGHTCHAGE, ArathiWarInfoPanel._OnFightStateChangeHandler, self);
	
	
	MessageManager.AddListener(ArathiNotes, ArathiNotes.EVENT_ARATHIOCCUPYMINESTATE, ArathiWarInfoPanel._OnOccupyMinecStateHandler, self);
	
	MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, ArathiWarInfoPanel._SceneStartHandler, self);
end

function ArathiWarInfoPanel:_OnWarDataHandler(data)
	local map = GameSceneManager.map;
	self._startTime = data.st;
	self._endTime = data.et;
	self._sysTime = os.time();
	self._txtCamp1.text = data.wp1;
	self._txtCamp2.text = data.wp2;
	self._txtTime.text = self:_formatTime(data.et);
	if(self._startTime > 0) then
		-- ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDONWNTIMENPANEL, { time = self._startTime, title = "倒计时：" })
	end
	if(data.ml) then
		for i, v in pairs(data.ml) do
			local item = self._points[v.id];
			if(item) then
				item:SetCamp(v.camp);
			end
			if(map) then
				map:SetBattlefieldPointCamp(v.id, v.camp);
			end
		end
	end
end

function ArathiWarInfoPanel:_OnResChangeHandler(data)
	self._txtCamp1.text = data.wp1;
	self._txtCamp2.text = data.wp2;
end

function ArathiWarInfoPanel:_OnMinecChangeHandler(data)
	local item = self._points[data.id];
	local map = GameSceneManager.map;
	if(item) then
		item:SetCamp(data.camp);
	end
	if(map) then
		if(data.camp) then
			map:SetBattlefieldPointCamp(data.id, data.camp);			
		elseif(data.buff) then
			map:SetBattlefieldPointBuff(data.id, data.buff);
end
	end
end

function ArathiWarInfoPanel:_OnHeroInPointHandler(info)
	self._currPointInfo = info;
	if(info and info.camp ~= PlayerManager.hero.info.camp) then
		self._btnFunction.gameObject:SetActive(true);
		if(info.type == 3) then
			self._btnFunctionIcon.spriteName = "arathiOccupy";
			self._txtDes.text = LanguageMgr.Get("ArathiWarInfoPanel/click2")
			
		else
			self._btnFunctionIcon.spriteName = "arathiPick";
			self._txtDes.text = LanguageMgr.Get("ArathiWarInfoPanel/click1")
		end
	else
		self._btnFunction.gameObject:SetActive(false);
	end
end

function ArathiWarInfoPanel:_OnHeroOutPointHandler(info)
	self._currPointInfo = nil;
	self._btnFunction.gameObject:SetActive(false);
end

function ArathiWarInfoPanel:_OnFightStateChangeHandler(data)
	if(data) then
		for k, v in ipairs(data) do
			local item = self._points[v.id];
			if(item) then
				item:SetFightState(v.camp1 and v.camp2);
			end			
		end
	end
end

function ArathiWarInfoPanel:SetActive(active)
	if(self._isPanleActive ~= active) then
		if(active) then
			for i, v in pairs(self._points) do
				v:Reset();
			end
			self._txtCamp1.text = "0";
			self._txtCamp2.text = "0";
			self._txtTime.text = "00:00";
			self._currPointInfo = nil;
			if(not self._timer.running) then
				self._timer:Start();
			end
		else
			self._timer:Stop();
		end
		self._isPanleActive = active;
		-- 子节点设置了锚点 无法用移动位置来隐藏父级
		self._gameObject:SetActive(active);
	end
end

function ArathiWarInfoPanel:_OnUpdata()
	if(self._endTime) then
		local currTime = os.time() - self._sysTime;
		-- if (currTime > self._startTime) then
		if(currTime > self._endTime) then
			self._txtTime.text = self:_formatTime(0);
			self._endTime = nil;
		else
			self._txtTime.text = self:_formatTime(self._endTime - currTime);
		end
		-- end
	end
end

function ArathiWarInfoPanel:_OnClickHandler()
	local data = {};
	data.wp1 = tonumber(self._txtCamp1.text)
	data.wp2 = tonumber(self._txtCamp2.text)
	ModuleManager.SendNotification(ArathiNotes.OPEN_ARATHIWARPANEL, data);
end

function ArathiWarInfoPanel:_OnClickFunctionHandler()
	if(self._currPointInfo) then
		PlayerManager.hero:SetFightStatus(false);
		if(self._currPointInfo.type == 3 or self._currPointInfo.type == 4) then
			self:_StartOccupyMine()
		end
		--        if (self._currPointInfo.type == 3) then
		--            self:_StartOccupyMine()
		--        elseif (self._currPointInfo.type == 4) then
		--            ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDOWNBARNPANEL, {
		--                time = 8,
		--                title = "开启中...",
		--                handler = function() self:_OccupyBuff() end;
		--                suspend = function() return self:_CheckSuspendOccupy() end
		--            } )
		--        end
	end
end

function ArathiWarInfoPanel:_OccupyBuff()
	if(self._currPointInfo) then
		ArathiProxy.OccupyBuff(self._currPointInfo.id);
	end
end

function ArathiWarInfoPanel:_StartOccupyMine()
	if(self._currPointInfo) then
		self._pointCamp = self._currPointInfo.camp
		ArathiProxy.OccupyMine(self._currPointInfo.id, 0);
	end
end

function ArathiWarInfoPanel:_CancelOccupyMine()
	ModuleManager.SendNotification(CountdownNotes.CLOSE_COUNTDOWNBARNPANEL);
	if(self._currPointInfo) then		
		ArathiProxy.OccupyMine(self._currPointInfo.id, 1);
	end
end

local opening = LanguageMgr.Get("ArathiWarInfoPanel/opening")
local holding = LanguageMgr.Get("ArathiWarInfoPanel/holding")

function ArathiWarInfoPanel:_OnOccupyMinecStateHandler(data)
	if(self._currPointInfo and data.f == 0) then
		local titleStr = "";
		if(self._currPointInfo.type == 3) then
			titleStr = holding;
		elseif(self._currPointInfo.type == 4) then
			titleStr = opening;
		end
		ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDOWNBARNPANEL, {
			time = 8.5,
			title = titleStr,
			cancelHandler = function() self:_CancelOccupyMine() end,
			suspend = function() return self:_CheckSuspendOccupy() end
		})
	end
end

function ArathiWarInfoPanel:_CheckSuspendOccupy()
	local hero = PlayerManager.hero;
	if(hero == nil) then
		return true;
	end
	if(hero:IsFightStatus()) then
		return true;
	end
	if(self._currPointInfo) then
		if(self._currPointInfo.type == 3 and(self._pointCamp ~= self._currPointInfo.camp or self._currPointInfo.camp == PlayerManager.hero.info.camp)) then
			return true
		end
	else
		return true;
	end
	local act = hero:GetAction();
	if(act ~= nil and(act.__cname ~= "StandAction" and act.__cname ~= "SendStandAction")) then
		return true
	end
	return false;
end

--    ModuleManager.SendNotification(CountdownNotes.OPEN_COUNTDONWNTIMENPANEL , {
--    time = 20,
--    title = "倒计时：",
--    handler = function() self:_OnClickSignup() end;
--    suspend = function() return self:_CheckTime() end
--    })
function ArathiWarInfoPanel:_formatTime(val)
	local m = math.floor(val) % 60;
	local f = math.floor(math.floor(val) / 60);
	return string.format("%.2d:%.2d", f, m);
end

function ArathiWarInfoPanel:_SceneStartHandler()
	local mInfo = GameSceneManager.map.info;
	if(mInfo.type == InstanceDataManager.MapType.ArathiWar) then
		ArathiProxy.RefreshArathiWarData();
	end
end

function ArathiWarInfoPanel:_Dispose()
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIWARDATA, ArathiWarInfoPanel._OnWarDataHandler);
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIRESCHAGE, ArathiWarInfoPanel._OnResChangeHandler);
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIMINECHAGE, ArathiWarInfoPanel._OnMinecChangeHandler);
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_HEROINPOINTAREA, ArathiWarInfoPanel._OnHeroInPointHandler);
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_HEROOUTPOINTAREA, ArathiWarInfoPanel._OnHeroOutPointHandler);
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIFIGHTCHAGE, ArathiWarInfoPanel._OnFightStateChangeHandler, self);
	
	MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, ArathiWarInfoPanel._SceneStartHandler);
	
	MessageManager.RemoveListener(ArathiNotes, ArathiNotes.EVENT_ARATHIOCCUPYMINESTATE, ArathiWarInfoPanel._OnOccupyMinecStateHandler);
	UIUtil.GetComponent(self._imgFrame, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickHandler = nil;
	UIUtil.GetComponent(self._btnFunction, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickFunctionHandler = nil;
	if(self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
	if(self._points) then
		for i, v in pairs(self._points) do
			v:Dispose();
		end
	end
	self._txtDes.text = nil
	self._points = nil;
end 