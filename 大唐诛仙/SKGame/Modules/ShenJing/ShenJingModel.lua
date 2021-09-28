ShenJingModel = BaseClass(LuaModel)

function ShenJingModel:__init()
	self.huanjingState = 0
	self.huanjingEndTime = 0
	self:InitData()
	self:AddEvent()
end

function ShenJingModel:InitData()
	self.realmData = {} --各个子境的数据
end

function ShenJingModel:SetRealmData()
	local mainPlayerLev = 0
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then mainPlayerLev = mainPlayerVo.level end
	for idx = 1 , #ShenJingConst.OpenLev do
		self.realmData[idx] = {}
		self.realmData[idx].id = idx
		self.realmData[idx].openLev = ShenJingConst.OpenLev[idx] 
		if ShenJingConst.OpenLev[idx] ~= ShenJingConst.OpenState.Close and ShenJingConst.OpenLev[idx] <= mainPlayerLev then
			self.realmData[idx].state = ShenJingConst.OpenState.Open
		else
			self.realmData[idx].state = ShenJingConst.OpenState.Close
		end
	end
end
function ShenJingModel:SetHuanjingInfo( msg )
	self.huanjingState = msg.huanjingState
	self.huanjingEndTime = msg.huanjingEndTime
	self:Fire(ShenJingConst.HuanjingChanged)
end

function ShenJingModel:CleanData()
	self.realmData = nil
end

function ShenJingModel:AddEvent()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.FIRST_ENTER_SCENE , function ()
		self:SetRealmData()
		if self:GetRedTipsData() ~= ShenJingConst.RedTipsState.None then
			local isShow = false
			if self:GetRedTipsData() == ShenJingConst.RedTipsState.Has then isShow = true end
			GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.shenjing , state = isShow})
		end
		GlobalDispatcher:RemoveEventListener(self.handler1)
	end)

	self.handler2 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) 
		if key == "level" then
			self:HandlePlayerLevChange()
		end
	end)
end

function ShenJingModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler2)
end

function ShenJingModel:HandlePlayerLevChange()
	local isHasNewRealm = self:IsHasNewRealm()
	if isHasNewRealm then 
		self:SetRedTipsData(isHasNewRealm)
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.shenjing , state = true})
	end
	self:SetRealmData()
end

function ShenJingModel:IsHasNewRealm()
	local isHasNew = false
	local mainPlayerLev = 0
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then mainPlayerLev = mainPlayerVo.level end

	for idx = 1 , #self.realmData do
		if self.realmData[idx] and 
			self.realmData[idx].state == ShenJingConst.OpenState.Close and
			self.realmData[idx].openLev ~= ShenJingConst.OpenState.Close and
			self.realmData[idx].openLev <= mainPlayerLev  then
			isHasNew = true
			break
		end
	end
	return isHasNew
end

function ShenJingModel:Reset()
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.ROLE_INITED , function()
		self:SetRealmData()
		if self:GetRedTipsData() ~= ShenJingConst.RedTipsState.None then
			local isShow = false
			if self:GetRedTipsData() == ShenJingConst.RedTipsState.Has then isShow = true end
			GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.shenjing , state = isShow})
		end
		GlobalDispatcher:RemoveEventListener(self.handler3)
	end)
end

function ShenJingModel:GetInstance()
	if ShenJingModel.inst == nil then 
		ShenJingModel.inst = ShenJingModel.New()
	end
	return ShenJingModel.inst
end

function ShenJingModel:__delete()
	self:CleanEvent()
	self:CleanData()
	ShenJingModel.inst = nil
end


function ShenJingModel:SetRedTipsData(bl)
	if bl ~= nil then
		local playerId = -1
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		if playerVo then playerId = playerVo.guid end
		if playerId ~= -1 then
			local key = StringFormat("{0}|{1}" , ShenJingConst.RedTipsDataKey , playerId)
			local value = bl == true and ShenJingConst.RedTipsState.Has or ShenJingConst.RedTipsState.HasNo
			DataMgr.WriteData( key, value)
		end
	end
end

function ShenJingModel:GetRedTipsData()
	local playerId = -1
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	if playerVo then playerId = playerVo.guid end
	if playerId ~= -1 then
		local key = StringFormat("{0}|{1}" , ShenJingConst.RedTipsDataKey , playerId)
		return DataMgr.ReadData(key , ShenJingConst.RedTipsState.None)
	end
end