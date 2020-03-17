
_G.WeatherController = setmetatable({}, {__index = IController})
WeatherController.name = "WeatherController"

WeatherController.mapArea = {} --地图区域表

WeatherController.areaid = nil --当前区域ID

WeatherController.nLastThunderTime = 0 --上次打雷时间
WeatherController.thunderCD = 0 --打雷的间隔
WeatherController.thunder = nil --雷的数据
WeatherController.thunderRandTime = {}
WeatherController.objSkyLight = nil

WeatherController.rain = nil --雨
WeatherController.fog = nil --雾
WeatherController.mmat = nil

function WeatherController:Create()
	for k, v in pairs(t_weather) do
		if not self.mapArea[v.mapid] then
			self.mapArea[v.mapid] = {}
		end
		table.push(self.mapArea[v.mapid], v)
	end
end

function WeatherController:OnCheckMapArea()
	local mapid = MainPlayerController:GetMapId()

	if self.mapArea[mapid] then
		local info = self.mapArea[mapid]
		local myPos = MainPlayerController:GetPos()
		for k, areaCfg in pairs(info) do
			local area = split(areaCfg.area, ",")
			if myPos.x >= toint(area[1]) and myPos.x <= toint(area[3]) and myPos.y >= toint(area[2]) and myPos.y <= toint(area[4]) then
				if self.areaid ~= areaCfg.id then
					self:PlayAreaPfx(areaCfg)
				end
				return
			end
			--- 没在区域 清掉天气效果
			if k == #info then
				self:clearWeatherPfx()
			end
		end
	else
		self:clearWeatherPfx()
		-- 雷需要全程播完 这里不能return
	end
end

function WeatherController:Update(e)
	--- --更新雨的位置
	if self.mmat then
		self.mmat.parent = MainPlayerController:GetPlayer().objAvatar.objNode.transform
		self.mmat.ignoreRotation = true
		if not self.mmap then
			self.mmap = CPlayerMap.objSceneMap:PlayerPfxByMat(self.rain, self.rain, self.mmat)
		else
			self.mmap.transform:set(self.mmat)
		end
	end

	--- 这里处理雷的光效转换
	if self.thunder then
		local curtime = GetCurTime()
		if self.nLastThunderTime == 0 or (self.thunderCD ~= 0 and self.nLastThunderTime + self.thunderCD *1000 < curtime) then
			if not self.areaid then
				self.thunder = nil
				return
			end
			self.nLastThunderTime = GetCurTime()
			-- 这里可以播放音效
		end
		local time = 0
		for k, v in pairs(self.thunder) do
			time = time + v[3]
			if curtime - self.nLastThunderTime <= time then
				if not self.objSkyLight then
					self.objSkyLight = _SkyLight.new()
					self.objSkyLight.direction = _Vector3.new(toint(self.thunderDir[1]), toint(self.thunderDir[2]), toint(self.thunderDir[3]))
				end
				self.objSkyLight.power = v[2]
				self.objSkyLight.color = v[1]
				return
			end
		end
		self.objSkyLight = nil

		self.thunderCD = toint(self.thunderRandTime[1]) + math.random(toint(self.thunderRandTime[2]) - toint(self.thunderRandTime[1]))
	end
end

local splitFunc = function(str)
	local list = {}
	local list1 = split(str, "#")
	for k, v in pairs(list1) do
		local list2 = split(v, ",")
		table.push(list, {list2[1], toint(list2[2]), toint(list2[3])})
	end
	return list
end

function WeatherController:PlayAreaPfx(areaCfg)
	self:clearWeatherPfx()
	self.areaid = areaCfg.id
	if areaCfg.thunder and areaCfg.thunder ~= "" then
		self.thunder = splitFunc(areaCfg.thunder)
		self.thunderDir = split(areaCfg.thunderDir, ",")
		self.thunderRandTime = split(areaCfg.thunderRandTime, ",")
	end
	---直接处理一次性天气
	if areaCfg.rain and areaCfg.rain ~= "" then
		self.rain = areaCfg.rain
		self:PlayRainPfx()
	end
	if areaCfg.fog and areaCfg.fog ~= "" then
		local fogCfg = split(areaCfg.fog, ",")
		self.fog = _Fog.new()
		self.fog.near, self.fog.far, self.fog.color = toint(fogCfg[1]), toint(fogCfg[2]), toint(fogCfg[3])
	end
end

function WeatherController:PlayRainPfx()
	if not self.areaid then return end
	if not self.rain then return end
	local player = MainPlayerController:GetPlayer()
	if not player then return end

	local avatar = player.objAvatar
	if not avatar then return end

	if not self.mmat then self.mmat = _Matrix3D.new() end

	self.mmat.parent = avatar.objNode.transform
	self.mmat.ignoreRotation = true
	self.mmap = CPlayerMap.objSceneMap:PlayerPfxByMat(self.rain, self.rain, self.mmat)
end

function WeatherController:clearWeatherPfx()
	if not self.areaid then return end
	local player = MainPlayerController:GetPlayer()
	if not player then return end

	if self.rain then
		CPlayerMap.objSceneMap:StopPfxByName(self.rain)
		self.rain = nil
		self.mmat = nil
	end
	self.fog = nil
	self.areaid = nil
	--- 直接把雷清掉
	self.thunder = nil
	self.objSkyLight = nil
end