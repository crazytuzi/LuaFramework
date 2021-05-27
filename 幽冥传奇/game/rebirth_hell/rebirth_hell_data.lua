--------------------------------------------------------
-- 跨服BOSS-轮回地狱数据
--------------------------------------------------------

RebirthHellData = RebirthHellData or BaseClass()

RebirthHellData.REBIRTH_HELL_DATA_CHANGE = "rebirth_hell_data_change"
RebirthHellData.ROTARY_TABLE_DATA_CHANGE = "rotary_table_data_change"
function RebirthHellData:__init()
	if RebirthHellData.Instance then
		ErrorLog("[RebirthHellData]:Attempt to create singleton twice!")
	end
	RebirthHellData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		buy_num = 0,		-- 当天的购买过的次数
		number = 0,			-- 剩余的击杀次数
	}
	self.dial_data = {
		type = 0,
		jackpot = 0,
		number = 0,
		index = 0,
		show_index = 1, 
	}
	self.record_str_t = {}

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.RebirthHellCanLuckyDraw)
end

function RebirthHellData:__delete()
	RebirthHellData.Instance = nil
end

----------设置----------

--设置Data
function RebirthHellData:SetData(protocol)
	self.data.buy_num = protocol.buy_num
	self.data.number = reincarnationHellCfg.maxFreeKillTms - protocol.free_num + protocol.residue_num

	self:DispatchEvent(RebirthHellData.REBIRTH_HELL_DATA_CHANGE)
end

--获取Data
function RebirthHellData:GetData()
	return self.data
end

local RECORD_LEGTH_LIMIT = 30 -- 记录长度限制

--设置转盘数据
function RebirthHellData:SetRotaryTableData(protocol)
	if protocol.type == 3 then
		self.dial_data.number = protocol.number
	else
		self.dial_data.type = protocol.type
		self.dial_data.jackpot = protocol.jackpot
		self.dial_data.show_index = protocol.show_index
		self.dial_data.number = protocol.number
		if protocol.type == 2 then
			self.dial_data.index = protocol.index
		end

		--叠加记录
		if protocol.record_str then
			if nil == next(self.record_str_t) or protocol.type ~= 2 then
				self.record_str_t = Split(protocol.record_str, ";")
			else
				table.insert(self.record_str_t, protocol.record_str)
				if #self.record_str_t > RECORD_LEGTH_LIMIT then
					for i = 1, #self.record_str_t - RECORD_LEGTH_LIMIT do
						table.remove(self.record_str_t, i)
					end
				end
			end
		end
	end
	if IS_ON_CROSSSERVER then
		RemindManager.Instance:DoRemindDelayTime(RemindName.RebirthHellCanLuckyDraw)
	end
	self:DispatchEvent(RebirthHellData.ROTARY_TABLE_DATA_CHANGE)
end

--获取转盘数据
function RebirthHellData:GetRotaryTableData()
	return self.dial_data
end

--获取转盘记录
function RebirthHellData:GetRotaryTableRecord()
	local list = {}
	for k, v in pairs(self.record_str_t) do
		if v then
			local str_t = Split(v, "#")
			--名字#奖励索引#个数
			local vo = {
				name = str_t[1],
				show_index = str_t[2],
				idx = str_t[3],
				num = str_t[4],
			}
			table.insert(list, vo)
		end
	end

	return list
end


--------------------

-- 获取"轮回地狱"需要显示的物品
function RebirthHellData.GetItemData()
	--获取显示配置
	local show_cfg = reincarnationHellCfg.item_list
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1)	-- 获取角色基础职业,默认是战士
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 获取性别

	return show_cfg[prof][sex + 1]
end

-- 获取"幸运转盘"需要显示的物品
function RebirthHellData.GetRotaryTableItemData(index)
	if nil == index then return end
	--获取显示配置
	local show_cfg = CrossWheelCfg.awardPool[index].award
	local data_list = {}
	for i = 1, 10 do
		data_list[i] = ItemData.FormatItemData(show_cfg[i])
		data_list[i].percent = show_cfg[i].percent
	end
	return data_list
end
 
----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function RebirthHellData.GetRemindIndex()
	return RebirthHellData.Instance.dial_data.number
end

----------end----------