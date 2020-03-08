
WeatherMgr.MAX_WEATHER_COUNT = 1;	-- 当前支持天气数量

WeatherMgr.nTimeOneDay = 18;		-- 昼夜交替时间（单位：分钟）

WeatherMgr.nNightFogDensity = 0.025;		-- 夜晚雾浓度

WeatherMgr.nChangeDayNightTime = 100;		-- 切换昼夜需要时间（单位：帧   1s = 15帧）

WeatherMgr.tbWeatherFogSetting = {
	Rain = {0.01, 0.025};
}

WeatherMgr.tbAllWeatherSetting = {};

WeatherMgr.tbAllWeatherType = {
	Rain = "雨";	-- 雨天
}

WeatherMgr.tbTimeShowInfo = {"子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"};

function WeatherMgr:LoadSetting()
	local tbTitle = {"nMapTemplateId", "nOffsetTime", "nWeatherCheckTime"};
	local szType = "ddd";

	for i = 1, self.MAX_WEATHER_COUNT do
		szType = szType .. "s";
		table.insert(tbTitle, "szWeatherSetting" .. i);
	end

	self.tbAllWeatherSetting = {};
	local tbFile = LoadTabFile("Setting/Map/WeatherSetting.tab", szType, nil, tbTitle);
	for _, tbRow in pairs(tbFile) do
		assert(not self.tbAllWeatherSetting[tbRow.nMapTemplateId], string.format("Setting/Map/WeatherSetting.tab nMapTemplateId:%s repeated !!", tbRow.nMapTemplateId));

		local tbInfo = {};
		tbInfo.nOffsetTime = tbRow.nOffsetTime;
		tbInfo.nWeatherCheckTime = tbRow.nWeatherCheckTime;

		tbInfo.tbWeather = {};
		for i = 1, self.MAX_WEATHER_COUNT do
			local szWeatherType, nRate, nMinTime, nMaxTime = string.match(tbRow["szWeatherSetting" .. i], "^([^|]+)|(%d+)|(%d+)|(%d+)$");
			if szWeatherType then
				assert(WeatherMgr.tbAllWeatherType[szWeatherType], string.format("Setting/Map/WeatherSetting.tab nMapTemplateId:%s szWeatherType:%s unknown weather type !!", tbRow.nMapTemplateId, szWeatherType));
				nRate = tonumber(nRate);
				nMinTime = tonumber(nMinTime);
				nMaxTime = tonumber(nMaxTime);

				assert(nRate and nMinTime and nMaxTime and nMinTime <= nMaxTime);

				table.insert(tbInfo.tbWeather, {szWeatherType, nRate, nMinTime, nMaxTime});
			end
		end
		self.tbAllWeatherSetting[tbRow.nMapTemplateId] = tbInfo;
	end
end

WeatherMgr:LoadSetting();

function WeatherMgr:CheckIsNight(nMapTemplateId)
	local nTime = self:GetTimeNow(nMapTemplateId);
	return nTime <= 3 or nTime > 9;
end

function WeatherMgr:GetTimeNow(nMapTemplateId)
	local tbWeatherSetting = self.tbAllWeatherSetting[nMapTemplateId] or {nOffsetTime = 0};
	local nOffsetTime = GetTime() + tbWeatherSetting.nOffsetTime * 60;
	local nTimeOneDay = self.nTimeOneDay * 2 * 60;
	local nTime = math.ceil((nOffsetTime % nTimeOneDay) * #self.tbTimeShowInfo / nTimeOneDay);
	nTime = nTime == 0 and #self.tbTimeShowInfo or nTime;

	return nTime, self.tbTimeShowInfo[nTime];
end