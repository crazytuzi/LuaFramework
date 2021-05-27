TreasureAtticData = TreasureAtticData or BaseClass()

TreasureAtticData.DRAGON_BALL_DATA_CHANGE = "dragon_ball_data_change"

function TreasureAtticData:__init()
	if TreasureAtticData.Instance then
		ErrorLog("[TreasureAtticData] attempt to create singleton twice!")
		return
	end
	TreasureAtticData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.ball_cfg = {
		ConfigManager.Instance:GetServerConfig("JewelPavilion/StarBeads/StarBeads1Config"),
		ConfigManager.Instance:GetServerConfig("JewelPavilion/StarBeads/StarBeads2Config"),
		ConfigManager.Instance:GetServerConfig("JewelPavilion/StarBeads/StarBeads3Config"),
		ConfigManager.Instance:GetServerConfig("JewelPavilion/StarBeads/StarBeads4Config"),
		ConfigManager.Instance:GetServerConfig("JewelPavilion/StarBeads/StarBeads5Config"),
		ConfigManager.Instance:GetServerConfig("JewelPavilion/StarBeads/StarBeads6Config"),
	}

	self.ball_data = {}
	for i = 1, #self.ball_cfg do
		self.ball_data[i] = {phase = 0, level = 0}
	end
	self.old_ball_data = {}
	self.old_ball_data.old_phase = 0

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetBallRemindLevelIndex), RemindName.DragonBallLevelCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetBallRemindPhaseIndex), RemindName.DragonBallPhaseCanUp)
	-- 数据监听
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagDataChange))
	RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_COLOR_STONE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function TreasureAtticData:__delete()
end

function TreasureAtticData:SetDragonBallData(protocol)
	for k, v in ipairs(protocol.info) do
		self.ball_data[k] = v 
	end

	for k, v in ipairs(protocol.info) do
		self.old_ball_data[k] = {}
		self.old_ball_data[k].level = v.level 
		self.old_ball_data[k].phase = v.phase 
	end
	self:DispatchEvent(TreasureAtticData.DRAGON_BALL_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.DragonBallLevelCanUp)
	RemindManager.Instance:DoRemindDelayTime(RemindName.DragonBallPhaseCanUp)
end

function TreasureAtticData:SetDragonBallResult(protocol)
	self.old_ball_data.type_chage = protocol.type + 1
	self.old_ball_data[protocol.type + 1].phase = self.ball_data[protocol.type + 1].phase
	self.old_ball_data[protocol.type + 1].level = self.ball_data[protocol.type + 1].level
	self.ball_data[protocol.type + 1].phase = protocol.phase
	self.ball_data[protocol.type + 1].level = protocol.level

	self:DispatchEvent(TreasureAtticData.DRAGON_BALL_DATA_CHANGE)
end

function TreasureAtticData:GetDragonBallData()
	return self.ball_data
end

function TreasureAtticData:GetDragonOldBallData()
	return self.old_ball_data
end

function TreasureAtticData:GetBallCfg()
	return self.ball_cfg
end

function TreasureAtticData:GetAbsorbAttr(type)
	local attr_cfg = self.ball_cfg[type][1].lvcfg
	local level = math.min(self.ball_data[type].level, #attr_cfg)
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	if nil == attr_cfg then return end -- 如果配置为空,则跳出

	local attr = {}
	if level ~= 0 then
		for k, v in ipairs(attr_cfg[level].attrs) do
			if v.job == prof or v.job == 0 or v.job == nil then
				attr[#attr + 1] = v
			end
		end
	else
		-- 未激活时,获取第一份属性配置并将属性(value)改为0
		for k, v in ipairs(attr_cfg[1].attrs) do
			if v.job == prof or v.job == 0 or v.job == nil then
				attr[#attr + 1] = {type = v.type, job = v.job, value = 0}
			end
		end
	end

	return attr
end

function TreasureAtticData:GetRefiningAttr(type)
	local attr_cfg = self.ball_cfg[type][1].order
	local phase = math.min(self.ball_data[type].phase, #attr_cfg)
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	local attr = {}
	if phase ~= 0 then
		for k, v in ipairs(attr_cfg[phase].attrs) do
			if v.job == prof or v.job == 0 or v.job == nil then
				attr[#attr + 1] = v
			end
		end
	else
		-- 未激活时,获取第一份属性配置并将属性(value)改为0
		for k, v in ipairs(attr_cfg[1].attrs) do
			if v.job == prof or v.job == 0 or v.job == nil then
				attr[#attr + 1] = {type = v.type, job = v.job, value = 0}
			end
		end
	end

	return attr
end

-- 获取套装信息
function TreasureAtticData.GetSuitInfo()
	local data = TreasureAtticData.Instance:GetDragonBallData()
	local ball = {}

	ball.phase = data[1].phase
	ball.level = data[1].level
	for k,v in ipairs(data) do
		if ball.phase > v.phase then
			ball.phase = v.phase
		end
		if ball.level > v.level then
			ball.level = v.level
		end
	end

	local suit_info = {}
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	for k,v in ipairs(DragonBallConfig.plusattrs) do
		if ball.phase >= v.orderNum and ball.level >= v.level then
			suit_info.attr = v.attrs
			suit_info.phase = v.orderNum
			suit_info.level = v.level
			suit_info.index = k
		end
	end

	if suit_info.attr then
		local attr = suit_info.attr
		suit_info.attr = {}
		for k,v in pairs(attr) do
			if v.job == prof or v.job == 0 or v.job == nil then
				suit_info.attr[#suit_info.attr + 1] = v
			end
		end
	else
		suit_info.attr = {}
		for k, v in ipairs(DragonBallConfig.plusattrs[1].attrs) do
			if v.job == prof or v.job == 0 or v.job == nil then
				suit_info.attr[#suit_info.attr + 1] = {type = v.type, job = v.job, value = 0}
			end
		end
		suit_info.phase = 0
		suit_info.level = 0
		suit_info.index = 0
	end

	local suit_next_info = {}
	local cfg = DragonBallConfig.plusattrs[suit_info.index + 1]
	if cfg ~= nil then
		suit_next_info.phase = cfg.orderNum
		suit_next_info.level = cfg.level
		suit_next_info.index = suit_info.index + 1

		suit_next_info.attr = {}
		for k,v in pairs(cfg.attrs) do
			if v.job == prof or v.job == 0 or v.job == nil then
				suit_next_info.attr[#suit_next_info.attr + 1] = v
			end
		end
	end

	return suit_info, suit_next_info
end

----------红点提示----------

function TreasureAtticData.OnBagDataChange()
	local boor = GameCondMgr.Instance:GetValue(ViewDef.TreasureAttic.v_open_cond)
	if not boor then return end
	RemindManager.Instance:DoRemindDelayTime(RemindName.DragonBallLevelCanUp)
	
end

function TreasureAtticData.OnRoleAttrChange()
	local boor = GameCondMgr.Instance:GetValue(ViewDef.TreasureAttic.v_open_cond)
	if not boor then return end
	RemindManager.Instance:DoRemindDelayTime(RemindName.DragonBallPhaseCanUp)
end

-- 获取"龙珠吸收"提醒显示索引 0不显示红点, 1显示红点
function TreasureAtticData.GetBallRemindLevelIndex()
	local index = 0
	for i = 1, #TreasureAtticData.Instance.ball_cfg do
		if TreasureAtticData.GetStarBallRemindIndex(i) > 0 then
			index = 1
			break
		end
	end

	return index
end

-- 获取"龙珠提炼"提醒显示索引 0不显示红点, 1显示红点
function TreasureAtticData.GetBallRemindPhaseIndex()
	local index = 0

	local ball = {}
	ball.phase = TreasureAtticData.Instance.ball_data[1].phase
	ball.type = 1
	for k,v in ipairs(TreasureAtticData.Instance.ball_data) do
		if ball.phase > v.phase then
			ball.phase = v.phase
			ball.type = k
		end
	end

	local item_1 = TreasureAtticData.Instance.ball_cfg[ball.type][1].order[ball.phase + 1]
	if item_1 then
		local item_num_1 = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COLOR_STONE)	-- 获取七彩石数量
		local item_id_1 =  item_1.consume[1].type > 0 and ItemData.GetVirtualItemId(item_1.consume[1].type) or item_1.consume[1].id
		local item_cfg_1 = ItemData.Instance:GetItemConfig(item_id_1)
		local cfg_count_1 = item_1.consume[1].count -- 龙魂消耗配置数量
		index = item_num_1 < cfg_count_1 and index or 1
	end

	return index
end

function TreasureAtticData.GetStarBallRemindIndex(type)
	local index = 0

	if TreasureAtticData.Instance.ball_data[type].phase > 0 then
		local level = TreasureAtticData.Instance.ball_data[type].level
		local item_2 = TreasureAtticData.Instance.ball_cfg[type][1].lvcfg[level + 1]
		if item_2 then
			local item_num_2 = BagData.Instance:GetItemNumInBagById(item_2.consume[1].id, nil)
			local item_cfg_2 = ItemData.Instance:GetItemConfig(item_2.consume[1].id)
			local cfg_count_2 = item_2.consume[1].count
			index = item_num_2 < cfg_count_2 and index or 1
		end
	end

	return index
end

----------end----------