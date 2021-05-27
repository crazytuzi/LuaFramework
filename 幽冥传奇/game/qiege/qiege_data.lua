QieGeData = QieGeData or BaseClass()
function QieGeData:__init()
	if QieGeData.Instance then
		ErrorLog("[QieGeData]:Attempt to create singleton twice!")
	end
	QieGeData.Instance = self
	--self.task_config = self:InitQieGeTaskConfig()
	self.qiege_effect_config = self:InitRewardEffectConfig()
	self.qiege_level = 0
	self.sign_data = {}
	self.shenqi_config = self:InitShenBinConfig()
	self.task_config = {}
	--RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum), RemindName.ShenBin)
	--RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.CanDiamondsCreate)
end

function QieGeData:__delete( ... )
	
end


function QieGeData:InitQieGeTaskConfig()
	local data = {}
	for k, v in pairs(CuttingConfig.daytasks) do
		local cur_data = {
			can_get = 1,
			had_skill_count = 0,
			skill_con = v.killCount,
			order = v.order,
			key = k,
			reward = v.awards,
			name = v.name or "",
		}
		table.insert(data, cur_data)
	end
	return data
end

function QieGeData:InitRewardEffectConfig()
	local data = {}
	for k, v in pairs(CuttingConfig.effectCfg) do
		local cur_data = {
			name = v.name,
			need_level = v.cuttinglevel,
			need_boss_num = v.killCount,
			had_skill_count = 0,
			key = k, 
			item_num = 0,
			reward = v.awards,
			desc = v.desc or "",
			condition = v.condition or "",
			id = v.id,
		}
		table.insert(data, cur_data)
	end
	return data
end

function QieGeData:SetAllQieGeData(protocol)
	self.qiege_level = protocol.qiege_level
	local data = bit:d2b(protocol.reweard_sign, true)
	for i=1,#data do
		self.sign_data[i] = data[#data - i + 1]
	end
	self.task_config = {}
	for i, v in ipairs(protocol.qiege_task_list) do
		local task_config = CuttingConfig.daytasks[v.task_id]
		if task_config then
			local cur_data = {
					can_get = 1,
					had_skill_count = v.boss_num,
					skill_con = task_config.killCount,
					order = task_config.order or 1,
					key = v.task_id,
					reward = task_config.awards,
					name = task_config.name or "",
				}
			if cur_data.had_skill_count >= cur_data.skill_con then
				if self.sign_data[v.task_id] == 0 then
					cur_data.can_get = 2
				else
					cur_data.can_get = 0
				end
			else
				cur_data.can_get = 1
			end
			table.insert(self.task_config, cur_data)
		end
	end
	local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
		return function(c, d)
			if c.key ~= d.key then
				if c.can_get ~= d.can_get then
					return c.can_get > d.can_get	
				else
					return c.key < d.key
				end
			end
			return c.key < d.key
		end
	end
	table.sort(self.task_config, sort_list())


	for i, v in ipairs(self.qiege_effect_config) do
		local idata = protocol.qiege_list[v.id]
		if(idata) then
			v.had_skill_count = idata.boss_num
			v.item_num = idata.item_num
		end
	end
	GlobalEventSystem:Fire(QIEGE_EVENT.GetRewardInfo)
end

function QieGeData:SetQieGeResult(protocol)
	self.qiege_level = protocol.qiege_level
	if self.qiege_level == 1 then
		MainuiCtrl.Instance:GetView():GetSmallPart():CheckFuncGuideShow()
	end
	GlobalEventSystem:Fire(QIEGE_EVENT.UpGrade_Result)
end

function QieGeData:GetLevel()
	return self.qiege_level
end


function QieGeData:GetLevelAndStep(level)
	local step = math.floor((level - 1)/10) + 1
	local star =  level == 0 and 0 or  level%10 == 0 and 10 or level%10 
	return step, star
end


function QieGeData:GetTaskConfig()
	return self.task_config
end

function QieGeData:GetQieGeEffectData()
	return self.qiege_effect_config
end

function QieGeData:GetCanGetRewardData()
	return self.sign_data
end


function QieGeData:GetUpGradeConfigLevel(level)
	local config =  ConfigManager.Instance:GetServerConfig("misc/CuttingUpgradeConfig")
	if config[level] then
		return config[level]
	end
	return nil
end

function QieGeData:GetAllCanup()
	if self:GetCanUpQieGe() then
		return true
	end
	if self:QieGeCanGet() then
		return true
	end

	if self:OnQieGeTaskCanGet() then
		return true
	end
	return false
end

function QieGeData:GetCanActiveQieGe()
	return  RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) > CuttingConfig.openLevel and self.qiege_level == 0
end

function QieGeData:GetCanUpQieGe()
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < CuttingConfig.openLevel  then
		return false
	end
	if self.qiege_level == 0 then
		return true
	end
	local config = self:GetUpGradeConfigLevel(self.qiege_level + 1)
	if config then
		local consume = config.consumes
		local num = 0
		for k, v in pairs(consume) do
			local had_num = BagData.Instance:GetItemNumInBagById(v.id, nil)
			if (had_num >= v.count) then
				num = num + 1 
			end
		end
		if num >= #consume then
			return true
		end
	end
	return false
end


function QieGeData:QieGeCanGet( ... )
	for k, v in pairs(self.qiege_effect_config) do
		if v.item_num > 0 then
			return true
		end
	end
	return false
end
--切割任务奖励还可领取
function QieGeData:OnQieGeTaskCanGet()
	for k, v in pairs(self.task_config) do
		if v.can_get == 2 then -- 可领取
			return true  
		end
	end
	return false
end

--神兵操作--====
function QieGeData:InitShenBinConfig()
	local data = {}
	for k, v in pairs(CuttingWeaponConfig) do
		local cur_data = {
			type = v.type,
			need_level = v.cuttinglv or 0,
			effect = v.effect_id,
			level = 0,
			item_id = v.virtualItemId,
			skill_id = v.skillvirtualItemId,
			upgradeconsume = v.upgrade,

		}
		table.insert(data, cur_data)
	end
	return data
end

--==服务器数据==---
function QieGeData:SetQieGeShenBinData(protocol)
	for k, v in pairs(self.shenqi_config) do
		for k1, v1 in pairs(protocol.qiege_shenbin_list) do
			if v.type == v1.index then
				v.level = v1.qiege_shenbin_level
			end
		end
	end
end

function QieGeData:SetUpgradeQieGeShenbinResult(protocol)
	for k, v in pairs(self.shenqi_config) do
		if v.type == protocol.index then
			v.level = protocol.qiege_shenbin_level
		end
	end
	GlobalEventSystem:Fire(QIEGE_EVENT.QieGeShenBinUp)
end


function QieGeData:GetWeaponData()
	return self.shenqi_config
end

function QieGeData:PageIndexPoint(page_index, bool_left)
	local num = bool_left and (page_index - 1) * 3 or page_index*3 + 1

	if bool_left then
	
		for i = 1, num do
			local data = self.shenqi_config[i]
			if data then
				if QieGeData.Instance:GetSingleWeaponUpgrade(data) then
				 return true
				end
			end
			
		end
	else
		for i= #self.shenqi_config, num, -1 do
			local data = self.shenqi_config[i]
			if data then
				if QieGeData.Instance:GetSingleWeaponUpgrade(data) then
					return true
				end
			end
		end
	end
	return false
end

function QieGeData:GetSingleWeaponUpgrade(data)
	if self.qiege_level < data.need_level then --不能激活，不显示红点
		return false
	end
	-- print(">>>>>>>>>>>>")
	local upgradeconsume = data.upgradeconsume
	
	local next_config = upgradeconsume[data.level + 1]
	if next_config then --未达到等级
		local num = 0
		for k, v in pairs(next_config.consume) do
			local had_num = BagData.Instance:GetItemNumInBagById(v.id, nil)
			if had_num >= v.count then
				num = num + 1
			end
		end
		if num >= #next_config.consume then
			return true
		end
	end
	return false
end


function QieGeData:GetShenBinCanUp()
	for k, v in pairs(self.shenqi_config) do
		if self:GetSingleWeaponUpgrade(v) then
			return true
		end
	end
	return false
end

function QieGeData:GetInfoByType(type)
	return self.shenqi_config[type]
end

function QieGeData:GetCuttingShenBinType(level)
	local data = {}
	for k, v in pairs(self.shenqi_config) do
		if level >= v.need_level then
			data = v
		end
	end
	return data
end