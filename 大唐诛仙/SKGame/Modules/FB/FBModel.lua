-- 副本model
FBModel = BaseClass(LuaModel)

function FBModel:GetInstance()
	if not FBModel.inst then
		FBModel.inst = FBModel.New()
	end
	return FBModel.inst
end

function FBModel:__init()
	self:InitData()
	self:InitEvent()
end

function FBModel:InitEvent()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) 
		if key == "level" then
			self:HandlePlayerLevChange()
		end
	end)

	self.handler2 =  GlobalDispatcher:AddEventListener(EventName.FIRST_ENTER_SCENE , function() 
		-- if self:GetRedTipsData() ~= FBConst.RedTipsState.None then
		-- 	local isShow = false
		-- 	if self:GetRedTipsData() == FBConst.RedTipsState.Has then isShow = true end
		-- 	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.copy , state = isShow})
		-- end
		GlobalDispatcher:RemoveEventListener(self.handler2)
	end)
end

function FBModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function FBModel:Reset()
	self.fbList = {} --副本列表
	self.fbOpenList = {}  --开启的副本列表，服务器发来的,只存mapid
	self:FillFbList()
	self:SortList()	

	self.handler3 =  GlobalDispatcher:AddEventListener(EventName.ROLE_INITED , function() 
		if self:GetRedTipsData() ~= FBConst.RedTipsState.None then
			-- local isShow = false
			-- if self:GetRedTipsData() == FBConst.RedTipsState.Has then isShow = true end
			-- GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.copy , state = isShow})
		end
		GlobalDispatcher:RemoveEventListener(self.handler3)
	end)
end

function FBModel:InitData()
	self.fbList = {} --副本列表
	self.fbOpenList = {}  --开启的副本列表，服务器发来的,只存mapid
	self:FillFbList()
	self:SortList()
end

function FBModel:CheckPush(fbType)
	local need = false
	for _, v in ipairs(FBConst.TypeList) do
		if fbType == v then
			need = true
			break
		end
	end
	return need
end

-- 读配置表并初始化vo
function FBModel:FillFbList()
	local cfg = GetCfgData("mapManger")
	local fbTempList = {}
	if not cfg then return end
	for k, v in pairs(cfg) do
		if type(v) ~= "function" then 
			if v.mapType == SceneConst.MapType.Copy and self:CheckPush(v.openTask) then
				table.insert(fbTempList, v)
			end
		end
	end
	for i = 1, #fbTempList do
		local fbId = fbTempList[i].map_id
		local fbCfg = cfg:Get(fbId)
		local cfgVo = {}
		cfgVo.mapId = fbId--副本id
		cfgVo.isOpen = false --是否开启状态
		cfgVo.openLevel = fbCfg.openLevel --开启等级
		cfgVo.mapType = fbCfg.mapType  --地图类型
		cfgVo.mapName = fbCfg.map_name --副本名字
		cfgVo.mapResId = fbCfg.mapresid  --副本资源id
		cfgVo.mapDes = fbCfg.mapDes   --副本描述
		cfgVo.mapIcon = fbCfg.mapIcon --副本背景图标   
		cfgVo.playernum = fbCfg.playernum   --人数要求
		cfgVo.lifeTime = fbCfg.lifeTime	--开启总时间
		cfgVo.waitingTime = fbCfg.waitingTime  --等待时间
		cfgVo.openTask = fbCfg.openTask -- 副本类型
		cfgVo.enterCount = 0 -- 进入剩余次数
		cfgVo.state = FBConst.OpenState.NotOpen --副本状态
		cfgVo.endTime = 0 --副本结束时间 ( to delete )
		cfgVo.lv = fbCfg.lv
		local fbVo = FBVo.New(cfgVo)
		table.insert(self.fbList, fbVo)
	end
end

function FBModel:GetList(idx)
	--return self.fbList or {}
	local list = {}
	for _, v in ipairs(self.fbList) do
		if v.lv == idx + 1 then
			table.insert(list, v)
		end
	end
	return list
end

function FBModel:SortList()
	table.sort(self.fbList, function(v1, v2)
		local open1 = v1:GetValue("isOpen")
		local open2 = v2:GetValue("isOpen")
		if open1 then
			if open2 then
				return v1:GetValue("openLevel") < v2:GetValue("openLevel")
			else
				return true
			end
		else
			if open2 then
				return false
			else
				return v1:GetValue("openLevel") < v2:GetValue("openLevel")
			end
		end
	end)
end

function FBModel:GetFBVoByMapId(id)
	local mapId = id or SceneModel:GetInstance().sceneId
	if self.fbList then 
		for _, v in pairs(self.fbList) do
			if mapId == v.mapId then 
				return v
			end
		end
	end
	return nil
end

function FBModel:CleanData()
	--self.resetRedTipsFlag = false
	self.fbList = nil
	self.fbOpenList = nil
end

function FBModel:__delete()
	self:CleanEvent()
	self:CleanData()
	FBModel.inst = nil
end

-- 更新单个副本信息
function FBModel:RefreshOneFbData(data)
	if not data then return end
	local mapId = data.mapId
	for _, vo in ipairs(self.fbList) do
		if vo and vo:GetValue("mapId") and mapId and vo:GetValue("mapId") == mapId then
			vo:SetValue("enterCount", data.enterCount)
			vo:SetValue("isOpen", true)
		end
	end
end

-- s2c更新所有副本状态和进入次数
function FBModel:RefreshFbList(msg)
	if (not msg) or (not msg.intancePanelMsgs) then return end
	for _, v in pairs(msg.intancePanelMsgs) do
		self:RefreshOneFbData(v)
	end
	self:SortList()
	self:DispatchEvent(FBConst.E_FBListRefresh)
end

-- 检测今日进入总次数是否已用完
function FBModel:CheckEnterTimes()
	local total = self:GetTotalTimes()
	local cur = self:GetCurEnterTimes()
	if cur >= total then
		return false
	else
		return true
	end
end

function FBModel:GetTotalTimes()
	local total = 0
	local cfg = GetCfgData("constant"):Get(23)
	if cfg then
		total = cfg.value
	end
	local vipID = "vip" .. VipModel:GetInstance():GetPlayerVipLV()
	local addNumCfgData = GetCfgData("vipPrivilege"):Get(14)[vipID] or 0
	total = total + addNumCfgData
	return total
end
--当前已进入次数
function FBModel:GetCurEnterTimes()
	local cur = 0
	for _, vo in ipairs(self.fbList) do
		if vo and vo:GetValue("isOpen") and vo:GetValue("mapId") and vo:GetValue("enterCount") then
			local enterCount = vo:GetValue("enterCount") or 0
			local mapId = vo:GetValue("mapId")
			local mapcfg = GetCfgData("mapManger"):Get(mapId)
			local maxCount = mapcfg.maxCount
			cur = cur + (maxCount - enterCount)
		end
	end
	return cur
end
-- 单个副本次数
-- x为当前副本剩余挑战次数，y为副本可挑战总次数
function FBModel:GetOneFBTimes(mapId)
	local x, y = 0, 0
	local vo = self:GetFBVoByMapId(mapId)
	if vo then
		x = vo.enterCount
		local mapcfg = GetCfgData("mapManger"):Get(mapId)
		y = mapcfg.maxCount
	end
	return x, y
end

-- 检测所前往副本是否需要读条
function FBModel:CheckNeedTransfer(mapId)
	-- local mapcfg = GetCfgData("mapManger"):Get(mapId)
	-- local openTask = mapcfg.openTask or 0
	-- if openTask == 41 or openTask == 42 or openTask == 43 then
	-- 	return true
	-- elseif openTask == 0 or openTask == 44 then
	-- 	return false
	-- end
	-- return false
	return true
end

function FBModel:HandlePlayerLevChange()
	-- local isHasNewFB = self:IsHasNewFB()
	-- if isHasNewFB then
	-- 	self:SetRedTipsData(isHasNewFB)
	-- 	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.copy , state = true})
	-- end
end

function FBModel:IsHasNewFB()
	local isHasNewFB = false
	local mainPlayerLev = 0
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then mainPlayerLev = mainPlayerVo.level end

	for idx , fbInfo in pairs(self.fbList) do
		if fbInfo.isOpen == false then
			if fbInfo.openLevel <= mainPlayerLev then
				isHasNewFB = true
				break
			end
		end
	end
	return isHasNewFB
end

function FBModel:SetRedTipsData(bl)
	if bl ~= nil then
		local playerId = -1
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		if playerVo then playerId = playerVo.guid end
		if playerId ~= -1 then
			local key = StringFormat("{0}|{1}" , FBConst.RedTipsDataKey , playerId)
			local value = bl == true and FBConst.RedTipsState.Has or FBConst.RedTipsState.HasNo
			DataMgr.WriteData( key, value)
		end
	end
end

function FBModel:GetRedTipsData()
	local playerId = -1
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	if playerVo then playerId = playerVo.guid end
	if playerId ~= -1 then
		local key = StringFormat("{0}|{1}" , FBConst.RedTipsDataKey , playerId)
		return DataMgr.ReadData(key , FBConst.RedTipsState.None)
	end
end