
PlayerInfoModel =BaseClass(LuaModel)

PlayerInfoModel.CheckShowProperty = {
	[31] = true,
	[32] = true,
	[33] = true,
	[34] = true,
	[35] = true,
	[1] = true,
	[3] = true,
	[5] = true,
	[7] = true,
	[9] = true,
	[11] = true,
	[13] = true,
	[15] = true,
	[21] = true,
	[22] = true,
	[23] = true,
	[24] = true,
	[57] = true,
	[55] = true,
}

function PlayerInfoModel:GetInstance()
	if PlayerInfoModel.inst == nil then
		PlayerInfoModel.inst = PlayerInfoModel.New()
	end
	return PlayerInfoModel.inst
end

function PlayerInfoModel:__init()
	self.pkgModel = PkgModel:GetInstance() -- 背包

	self.playerEquipList = {}  --玩家每个坑的装备数据，key = pos  value = vo
	self.playerSkepList = {}  --玩家对应pos所具有的装备
  	self.equipSlotRedTipsList = {} --各个槽位，是否需要显示红点
	self:AddEvent()
end
function PlayerInfoModel:AddEvent()
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.EQUIPINFO_CHANGE, function ()
		self:FillPlayerEquipList()
		self:UpdateEquipSlotRedTipsList()
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.BAG_INITED , function()
		self:FillPlayerEquipList()
		self:UpdateEquipSlotRedTipsList()
	end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) 
		if key == "level" then
			self:UpdateEquipSlotRedTipsList()
		end
	end)
end
function PlayerInfoModel:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	self.handler1 = nil
	GlobalDispatcher:RemoveEventListener(self.handler2)
	self.handler2 = nil
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self.handler3 = nil
end
--获取玩家基础属性(填充固定的属性)
function PlayerInfoModel:GetPlayerBaseProp()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	local result = {}
	for i,id in ipairs(PlayerInfoConst.PlayerBaseProp) do --生命和法力比较特殊，用最大生命和最大法力的数值
		local propItem = {}
		propItem.name = RoleVo.GetPropDefine(id).name
		propItem.value = playerVo[RoleVo.GetPropDefine(id).type]
		if id == 1 then  --生命
			propItem.value = playerVo.hpMax
		end
		if id == 3 then  --法力
			propItem.value = playerVo.mpMax
		end
		if id == 24 then  --移动速度
			propItem.value = propItem.value * 100
		end
		table.insert(result, propItem)
	end

	return result
end

--获取玩家战斗属性（填充固定的属性）
function PlayerInfoModel:GetPlayerBattleProp()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	local result = {}
	for i,id in ipairs(PlayerInfoConst.PlayerBattleProp) do --生命和法力比较特殊，用最大生命和最大法力的数值
		local propItem = {}
		propItem.name = RoleVo.GetPropDefine(id).name
		propItem.value = playerVo[RoleVo.GetPropDefine(id).type]
		table.insert(result,propItem)
	end
	return result
end
--获取玩家特殊属性
function PlayerInfoModel:GetPlayerSpecialProp()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	local result = {}
	for i, id in ipairs(PlayerInfoConst.PlayerSpecialProp) do
		local propItem = {}
		propItem.propId = id
		propItem.name = RoleVo.GetPropDefine(id).name
		propItem.value = playerVo[RoleVo.GetPropDefine(id).type]
		table.insert(result,propItem)
	end
	return result
end
--获取玩家的身上装备信息
function PlayerInfoModel:GetOnEquipInfo()
	return self.pkgModel:GetOnEquips()
end
-- 获取玩家所有装备信息
function PlayerInfoModel:GetAllEquipInfo()
	return self.pkgModel.equipInfos
end

--获取装备等级
function PlayerInfoModel:GetEquipLevel()
	local data = self:GetOnEquipInfo()
	local lv = 0
	if data then
		for i,v in ipairs(data) do
			local cfg = GetCfgData("equipment"):Get(v.bid)
			if cfg then
				lv = lv + cfg.rare
			end
		end
	end
	return lv
end

--填充玩家的装备列表信息  key = pos
function PlayerInfoModel:FillPlayerEquipList()
	self.playerEquipList = {}
	local list = self:GetOnEquipInfo()
	if list then
		for _,info in pairs(list) do
			if info then -- 装备的装配位置不能溢出角色身上的坑
				if info.equipType <= #GoodsVo.EquipTypeName then
					self.playerEquipList[info.equipType] = info
				end
			end
		end
	end
	self:DispatchEvent(PlayerInfoConst.EventName_RefreshPlayerEquipList)
end

function PlayerInfoModel:UpdateEquipSlotRedTipsList()
	self.equipSlotRedTipsList = {}
	--重新取玩家当前的装备数据，初始化槽位红点状态
	for idx , info in pairs(self.playerEquipList) do
		self.equipSlotRedTipsList[info.equipType] = {}
		self.equipSlotRedTipsList[info.equipType].isShow = false
	end

	--更新各个装备槽位红点状态
	local allEquipInfo = PkgModel:GetInstance():GetAllEquipInfos()
	local allEquipInfo2 = PkgModel:GetInstance():GetAllEquipInfos2()

	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	local isNeedShowRed = false
	if playerVo then
		for index , equipInfo in pairs(allEquipInfo) do
			local cfgVal = GetCfgData("equipment"):Get(equipInfo.bid)
			if cfgVal then
				local needJob = cfgVal.needJob or -1
				local needLev = cfgVal.level or -1
				if (needJob == 0) or ((needJob ~= -1 ) and (needJob == playerVo.career)) then
					if needLev <= playerVo.level then
						local isHasPlaced = self:IsPlacedEquipSlot(equipInfo.equipType)
						if isHasPlaced == true then
							--update redTips State
							if (self.equipSlotRedTipsList[equipInfo.equipType] ~= nil) and (self.playerEquipList[equipInfo.equipType] ~= nil) and (self.playerEquipList[equipInfo.equipType].score < equipInfo.score) then
								self.equipSlotRedTipsList[equipInfo.equipType].isShow = true
								isNeedShowRed = true
							end
						else
							--add redTips State
							if self.equipSlotRedTipsList[equipInfo.equipType] == nil then
								self.equipSlotRedTipsList[equipInfo.equipType] = {}
							end
							self.equipSlotRedTipsList[equipInfo.equipType].isShow = true
							isNeedShowRed = true
						end
					end
				end
			end
		end
	end

	GlobalDispatcher:DispatchEvent(EventName.RefershPlayerInfoRedTips)
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.playerInfo , state = isNeedShowRed})
end

--判断某个装备槽位是否已经装备了对应的装备
function PlayerInfoModel:IsPlacedEquipSlot(slotPos)
	local rtnIsPlaced = false
	if slotPos then
		for slotIdx , showState in pairs(self.equipSlotRedTipsList) do
			if slotIdx == slotPos then
				rtnIsPlaced = true
				break
			end
		end
	end
	return rtnIsPlaced
end

function PlayerInfoModel:GetEquipSlotRedTipsList()
	return self.equipSlotRedTipsList
end

function PlayerInfoModel:IsEquipSlotNeedShowRedTips()
	local rtnIsNeed = false
	for idx , info in pairs(self.equipSlotRedTipsList) do
		if info and info.isShow == true then
			rtnIsNeed = true
			break
		end
	end
	return rtnIsNeed
end

--填充玩家对应的部位具有的所有装备
function PlayerInfoModel:FillPlayerEquipSkepListByPos(pos,sort)
	return self.playerSkepList
end

-- 获取指定身上部位装备信息
function PlayerInfoModel:GetPlayerEquipmentVoByPos(pos)
	return self.playerEquipList[pos]
end

function PlayerInfoModel.ParseCheckData(msg)
	local vo = {}
	vo.guid =  msg.guid 
	vo.severNo =  msg.severNo
	vo.playerId =  msg.playerId
	vo.playerName =  msg.playerName
	vo.career =  msg.career
	vo.vipLevel = msg.vipLevel
	vo.playerFamilyId = msg.playerFamilyId
	vo.sortId = msg.familySortId
	vo.familyName = msg.familyName
	vo.guildId = msg.guildId -- 帮派id
	vo.guildName = msg.guildName -- 帮派名称
	vo.furnaceList = msg.furnaceList -- 诛仙阁
	vo.baseProperty = {}
	SerialiseProtobufList( msg.playerPropertyMsg, function (item)
		if PlayerInfoModel.CheckShowProperty[item.propertyId] then
			table.insert(vo.baseProperty, {item.propertyId, item.propertyValue})
		end
		if item.propertyId == 49 then --等级
			vo.level = item.propertyValue
		end
		if item.propertyId == 41 then --战斗力
			vo.battleValue = item.propertyValue
		end
		if item.propertyId == 47 then --武器外形(装备基础ID)
			vo.weaponStyle = item.propertyValue
		end
		if item.propertyId == 48 then --外形
			vo.dressStyle = item.propertyValue
		end
		if item.propertyId == 62 then --翅膀
			vo.wingStyle = item.propertyValue
		end
	end)

	vo.listWakans = {}
	SerialiseProtobufList( msg.listWakans, function (item)
		vo.listWakans[item.posId] = item
	end)

	vo.equipinfoList = {}
	SerialiseProtobufList( msg.listPlayerEquipments, function (item)
		local wakanLevel = nil
		if vo.listWakans[item.equipType] and vo.listWakans[item.equipType].wakanLevel > 0 then
			wakanLevel = vo.listWakans[item.equipType].wakanLevel
		end
		local equipInfo = EquipInfo.New(item, wakanLevel)
		vo.equipinfoList[equipInfo.equipType] = equipInfo
	end)
	return vo
end

function PlayerInfoModel:__delete()
	self:RemoveEvent()
	self.equipSlotRedTipsList = {}
	PlayerInfoModel.inst = nil
end