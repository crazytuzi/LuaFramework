function WeatherMgr:Activity()
	if not self.nMapTemplateId or not self.tbAllWeatherSetting[self.nMapTemplateId] then
		return;
	end

	local nTimeNow = GetTime();
	if nTimeNow % 10 == 1 or not self.tbAllWeatherSetting[self.nMapTemplateId] then
		self:ActivatePer10Sec(nTimeNow);
	end
end

function WeatherMgr:ActivatePer10Sec(nTimeNow)
	local bNeedNotify = false;
	local bIsNight = WeatherMgr:CheckIsNight(self.nMapTemplateId);
	if bIsNight ~= self.bIsNight then
		self.bIsNight = bIsNight;
		self:SetDayNightState(bIsNight);
		bNeedNotify = true;
	end

	if self.nWeatherEndTime and nTimeNow >= self.nWeatherEndTime then
		self:SetWeatherState(false);
		self.nWeatherEndTime = nil;
		self.szWeatherType = nil;
		bNeedNotify = true;
	end

	local nTime = WeatherMgr:GetTimeNow(self.nMapTemplateId);
	self.nShowTime = self.nShowTime or 0;
	if nTime ~= self.nShowTime then
		self.nShowTime = nTime;
		bNeedNotify = true;
	end

	if bNeedNotify then
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEATHER_CHANGE);
	end
end

function WeatherMgr:OnMapLoaded(nMapTemplateId)
	self.nMapTemplateId = nMapTemplateId;
	self.nMapId = me.nMapId;
	if self.nActivateTimerId then
		Timer:Close(self.nActivateTimerId);
		self.nActivateTimerId = nil;
	end

	if not self.tbAllWeatherSetting[nMapTemplateId] then
		return;
	end

	if self.bIsInSwitchDayNight then
		self.bIsInSwitchDayNight = false;
	end

	if self.nChangeFogTimer then
		Timer:Close(self.nChangeFogTimer);
		self.nChangeFogTimer = nil;
	end

	local nTimeNow = GetTime();
	self.bIsNight = WeatherMgr:CheckIsNight(self.nMapTemplateId);
	self:SetDayNightState(WeatherMgr:CheckIsNight(nMapTemplateId), 1);

	self.nWeatherEndTime = nil;
	self.szWeatherType = nil;

	if self.tbCacheWeather then
		Timer:Register(Env.GAME_FPS * 1.5, function ()
			if not self.tbCacheWeather then
				return;
			end

			if self.tbCacheWeather[1] == me.nMapId and self.tbCacheWeather[3] > nTimeNow then
				self:ChangeWeather(nMapTemplateId, self.tbCacheWeather[2], self.tbCacheWeather[3]);
				UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEATHER_CHANGE);
				self.tbCacheWeather = nil;
			end
		end)

	end
end

function WeatherMgr:ChangeFog(nEnd, nFrame)
	self.nEndFogDensity = nEnd;
	if self.bIsInSwitchDayNight then
		return;
	end

	Ui.ToolFunction.SetFogColor(3 / 255, 8 / 255, 34 / 255);

	self.bIsInSwitchDayNight = true;
	self.nChangeFogMapId = Map.nMapId;
	local nStart = Ui.ToolFunction.GetFogDensity();
	self.nCurrentFrame = 0;
	if self.nChangeFogTimer then
		Timer:Close(self.nChangeFogTimer);
	end

	self.nChangeFogTimer = Timer:Register(1, function ()
		self.nCurrentFrame = self.nCurrentFrame + 1;
		if self.nChangeFogMapId ~= Map.nMapId or self.nCurrentFrame > nFrame then
			self.nCurrentFrame = nil;
			self.nChangeFogTimer = nil;
			self.nEndFogDensity = nil;
			self.bIsInSwitchDayNight = false;
			if self.tbCacheChangeWeather then
				self:ChangeWeather(unpack(self.tbCacheChangeWeather));
				self.tbCacheChangeWeather = nil;
			end
			return;
		end

		local nCurrent = nStart + (self.nEndFogDensity - nStart) * self.nCurrentFrame / nFrame;
		Ui.ToolFunction.ChangeFog(nCurrent);
		return true;
	end)
end

function WeatherMgr:OnSyncWeatherInfo(nMapId, szWeatherType, nWeatherEndTime)
	Log(">>>>> WeatherMgr:OnSyncWeatherInfo", me.nMapId, nMapId, self.nMapId or "nil", szWeatherType, nWeatherEndTime);
	if me.nMapId ~= nMapId or not self.nMapId or self.nMapId ~= nMapId then
		self.tbCacheWeather = {nMapId, szWeatherType, nWeatherEndTime};
		Log(">>> WeatherMgr:OnSyncWeatherInfo Cache.");
		return;
	end

	self:ChangeWeather(me.nMapTemplateId, szWeatherType, nWeatherEndTime);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_WEATHER_CHANGE);
end

function WeatherMgr:ChangeWeather(nMapTemplateId, szWeatherType, nWeatherEndTime)
	if nMapTemplateId ~= self.nMapTemplateId or not WeatherMgr.tbAllWeatherType[szWeatherType] or nWeatherEndTime <= GetTime() then
		return;
	end

	if self.bIsInSwitchDayNight then
		self.tbCacheChangeWeather = {szWeatherType, nWeatherEndTime};
		return;
	end

	self.szWeatherType = szWeatherType;
	self.nWeatherEndTime = nWeatherEndTime;
	self:SetWeatherState(true);
	self.tbCacheChangeWeather = nil;
end

function WeatherMgr:GetWeatherFogDensity(bIsNight, bWeatherNotActive)
	if not bWeatherNotActive and self.szWeatherType and WeatherMgr.tbWeatherFogSetting[self.szWeatherType] then
		local tbFogInfo = WeatherMgr.tbWeatherFogSetting[self.szWeatherType];
		return bIsNight and tbFogInfo[2] or tbFogInfo[1];
	end

	return bIsNight and WeatherMgr.nNightFogDensity or 0;
end

function WeatherMgr:SetDayNightState(bIsNight, nTime)
	if self.bWeatherSkip then
		return;
	end

	local nFog = WeatherMgr:GetWeatherFogDensity(bIsNight);
	self:ChangeFog(nFog, nTime or WeatherMgr.nChangeDayNightTime);
end

function WeatherMgr:ChangeWeather_Null()
	local bIsNight = WeatherMgr:CheckIsNight(self.nMapTemplateId);
	local nFog = bIsNight and WeatherMgr.nNightFogDensity or 0;
	self:ChangeFog(nFog, 1);
end

function WeatherMgr:ChangeWeather_Rain(bActive)
	local nFog = self:GetWeatherFogDensity(self.bIsNight, not bActive);
	self:ChangeFog(nFog, 1);
	Ui.CameraMgr.SetChildActive("xiayu", bActive and true or false);
end

function WeatherMgr:SetWeatherState(bActive)
	if self.bWeatherSkip then
		return;
	end

	self["ChangeWeather_" .. self.szWeatherType](self, bActive);
end

function WeatherMgr:SkipWeather(bSkip)
	self.bWeatherSkip = bSkip;

	if bSkip then
		self:ChangeWeather_Rain(false);
		self:ChangeFog(0, 1);
	else
		if self.szWeatherType and self.nWeatherEndTime and self.nWeatherEndTime > GetTime() then
			self["ChangeWeather_" .. self.szWeatherType](self, true);
		end

		self:SetDayNightState(self.bIsNight, 1);
	end
end

function WeatherMgr:OnLogin()
	local _, nX, nY = me.GetWorldPos();
	local bHouseMap, bInHouseRange = House:CheckInHouseRange(me.nMapTemplateId, nX, nY);
	if not bHouseMap then
		return;
	end

	self:SkipWeather(bInHouseRange and true or false);
end

function WeatherMgr:OnLeaveMap(nMapTemplateId)
	if not Map:IsHouseMap(nMapTemplateId) then
		return;
	end
	self:SkipWeather(false);
end

function WeatherMgr:OnPlayerTrap(nMapTemplateId, szTrapName)
	if not Map:IsHouseMap(nMapTemplateId) then
		return;
	end

	if szTrapName ~= "Out_sn" and szTrapName ~= "Out_ty" then
		return;
	end

	Timer:Register(10, function ()
		WeatherMgr:OnSyncSwitchPlace();
	end)
end

function WeatherMgr:OnSyncSwitchPlace()
	local tbHouseSetting = House:GetHouseSetting(me.nMapTemplateId);
	if not tbHouseSetting then
		return;
	end

	local nMapId, nX, nY = me.GetWorldPos();
	local bSkip = false;
	if House:CheckInRange({nX, nY}, tbHouseSetting.tbHouseRange) then
		bSkip = true;
	end
	self:SkipWeather(bSkip);
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_PLAYER_SET_POS, WeatherMgr.OnSyncSwitchPlace, WeatherMgr);