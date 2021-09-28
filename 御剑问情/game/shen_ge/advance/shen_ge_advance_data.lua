ShenGeAdvanceData = ShenGeAdvanceData or BaseClass()

function ShenGeAdvanceData:__init()
	ShenGeAdvanceData.Instance = self

	self.cell_info_list = {}
	self.max_level = {}
	self:InitMaxLevel()
	self:InitLimit()
	self:InitStuffID()
	RemindManager.Instance:Register(RemindName.ShenGe_Advance, BindTool.Bind(self.GetRemind, self))
	self.item_data_event = BindTool.Bind(self.ItemDataChange,self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ShenGeAdvanceData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ShenGe_Advance)
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

-------------------更新数据-----------------------
-- 所有的格子信息
function ShenGeAdvanceData:UpdateCellInfoList(protocol)
	self.cell_info_list = protocol.cell_info_list
	self:InitRedList(self.cell_info_list)
end

function ShenGeAdvanceData:UpdateCellByIndex(protocol)
	self.cell_info_list[protocol.grid_id].level = protocol.level
	self.cell_info_list[protocol.grid_id].attr_list = protocol.attr_list
	self:InitRedList(self.cell_info_list)
end

-- ----------------获取数据---------------------
-- 获取一个格子上的所有淬炼信息,可能返回空
function ShenGeAdvanceData:GetCellInfo(index)
	if index == nil or self.cell_info_list[index] == nil then
		index = 0
	end
	return self.cell_info_list[index]
end

-- 获取格子属性
function ShenGeAdvanceData:GetCellAttr(types, level)
	if types == nil or level == nil then
		types = 0
		level = 0
	end
	local cfg = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto").xuantu_cuilian
	for k,v in ipairs(cfg) do
		if types == v.grid_attr and level == v.level then
			if cfg[k + 1] and cfg[k + 1].grid_attr == types then
				self.next_attr_index = k + 1
			else
				self.next_attr_index = nil
			end
			return v
		end
	end
end

function ShenGeAdvanceData:GetNextCell()
	if self.next_attr_index then
		local cfg = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto").xuantu_cuilian
		return cfg[self.next_attr_index]
	else
		return nil
	end
end

function ShenGeAdvanceData:GetResumeStr(cfg)
	local have_num = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
	local name = ItemData.Instance:GetItemName(cfg.stuff_id)
	local str = ""
	if cfg.level == self.max_level[cfg.grid_attr] then
		have_num = ToColorStr(have_num,TEXT_COLOR.BLUE_4)
		str = string.format(Language.Resume.Max, name,have_num)
	else
		if have_num < cfg.stuff_num then
			have_num = ToColorStr(have_num,TEXT_COLOR.RED)
		else
			have_num = ToColorStr(have_num,TEXT_COLOR.BLUE_4)
		end
		str = string.format(Language.Resume.Desc,name,have_num,cfg.stuff_num)
	end
	return str
end

function ShenGeAdvanceData:GetAllGridPower()
	local fight_cfg = {}
	fight_cfg.maxhp = 0
	fight_cfg.gongji = 0
	fight_cfg.fangyu = 0
	for k,v in pairs(self.cell_info_list) do
		local data = ShenGeData.Instance:GetInlayData(0, k)
		if data ~= nil then
			local quyu = math.floor(v.grid_id / 4) + 1
			local cell_attr = self:GetRealAttr(quyu, v.level,v)
			fight_cfg.maxhp = fight_cfg.maxhp + cell_attr.maxhp
			fight_cfg.gongji = fight_cfg.gongji + cell_attr.gongji
			fight_cfg.fangyu = fight_cfg.fangyu + cell_attr.fangyu
		end
	end
	local cap = CommonDataManager.GetCapability(fight_cfg)
	return cap
end

function ShenGeAdvanceData:GetFightByIndex(index)
	local fight_cfg = {maxhp = 0, gongji = 0, fangyu = 0}
	local cfg = self.cell_info_list[index]
	if nil == cfg then
		return fight_cfg
	end
	local data = ShenGeData.Instance:GetInlayData(0, index)
	if data ~= nil then
		local quyu = math.floor(cfg.grid_id / 4) + 1
		local cell_attr = self:GetRealAttr(quyu, cfg.level, cfg)
		fight_cfg.maxhp = fight_cfg.maxhp + cell_attr.maxhp
		fight_cfg.gongji = fight_cfg.gongji + cell_attr.gongji
		fight_cfg.fangyu = fight_cfg.fangyu + cell_attr.fangyu
	end

	return fight_cfg
end

function ShenGeAdvanceData:GetRealAttr(types, level,info)
	if info == nil then
		return
	end
	if types == nil or level == nil then
		types = 0
		level = 0
	end
	local num = 0
	for k,v in pairs(info.attr_list) do
		if v == types then
			num = num + 1
		end
	end
	local cfg = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto").xuantu_cuilian
	for k,v in ipairs(cfg) do
		if types == v.grid_attr and level == v.level then
			local t = TableCopy(v)
			if cfg[k + 1] and cfg[k + 1].grid_attr == types then
				if num ~= 0 then
					t.maxhp = math.floor(t.maxhp + (cfg[k + 1].maxhp - t.maxhp) *(t["picture_attr_per_" .. num]) / 10000)
					t.gongji = math.floor(t.gongji + (cfg[k + 1].gongji - t.gongji) *(t["picture_attr_per_" .. num]) / 10000)
					t.fangyu =	math.floor(t.fangyu + (cfg[k + 1].fangyu - t.fangyu) *(t["picture_attr_per_" .. num]) / 10000)
				end
			end
			return t
		end
	end
end

function ShenGeAdvanceData:GetLimitFlag(index)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local flag = role_vo.level < self.limit_list[index].level
	return flag
end

function ShenGeAdvanceData:GetLimitLevel(index)
	return self.limit_list[index].level
end

function ShenGeAdvanceData:GetRedList()
	return self.red_list
end

function ShenGeAdvanceData:GetOpenList()
	if self.open then
		return self.open
	else
		self:InitOpenList()
		return self.open
	end
end

function ShenGeAdvanceData:GetRemind()
	if not OpenFunData.Instance:CheckIsHide("shen_ge_advance") then
		return 0
	end
	self:FlushRedList()
	if self.red_list == nil then
		return 0
	end
	for k,v in pairs(self.red_list) do
		if v then
			return 1
		end
	end
	return 0
end

function ShenGeAdvanceData:GetIsMaxLevel(index)
	local info = self:GetCellInfo(index)
	local quyu = math.floor((index / 4) + 1)
	if info.level == self.max_level[quyu] then
		return true
	else
		return false
	end
end

----------------处理数据-----------------------
function ShenGeAdvanceData:InitMaxLevel()
	local cfg = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto").xuantu_cuilian
	for i,v in ipairs(cfg) do
		if self.max_level[v.grid_attr] == nil then
			self.max_level[v.grid_attr] = v.level
		end
		if v.level > self.max_level[v.grid_attr] then
			self.max_level[v.grid_attr] = v.level
		end
	end
end

function ShenGeAdvanceData:InitLimit()
	local cfg = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto").xuantu_cuilian_open_limit
	self.limit_list = ListToMap(cfg,"grid_id")
end

function ShenGeAdvanceData:InitOpenList()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 下一批开放的格子索引表
	self.open = {}
	self.min = 0
	for k,v in pairs(self.limit_list) do
		if role_vo.level < v.level then
			local min = v.level - role_vo.level
			if next(self.open) == nil then
				table.insert(self.open, k)
				self.min = min
			elseif min < self.min then
				self.open = {}
				table.insert(self.open, k)
				self.min = min
			end
		end 
	end

end

function ShenGeAdvanceData:InitRedList(info)
	if info == nil or next(info) == nil then
		return
	end
	self.red_list = {}
	for i=0,15 do
		local cell_data = ShenGeData.Instance:GetInlayData(0,i)
		local attr = self:GetCellAttr(math.floor(i/4) + 1,info[i].level)
		local have_num = 0
		if attr then
			have_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)
		else
			have_num = 0
		end
		if cell_data ~= nil and not self:GetLimitFlag(i) and have_num >= attr.stuff_num then
			self.red_list[i] = true
		else
			self.red_list[i] = false
		end
	end
end

function ShenGeAdvanceData:FlushRedList()
	self:InitRedList(self.cell_info_list)
end

	
function ShenGeAdvanceData:ItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	for k,v in pairs(self.stuff_id) do
		if item_id == v then
			RemindManager.Instance:Fire(RemindName.ShenGe_Advance)
		end
	end
end

function ShenGeAdvanceData:InitStuffID()
	local cfg = ConfigManager.Instance:GetAutoConfig("shenge_system_cfg_auto").xuantu_cuilian
	self.stuff_id = {}
	for k,v in pairs(cfg) do
		if next(self.stuff_id) == nil then
			table.insert(self.stuff_id, v.stuff_id)
		else
			for k1,v1 in pairs(self.stuff_id) do
				if v.stuff_id ~= v1 then
					table.insert(self.stuff_id, v.stuff_id)
				end
			end

		end
	end
end