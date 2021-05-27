DiamondBackData = DiamondBackData or BaseClass()

DiamondBackData.ONE_EQUIP_LIST = "one_equip_list"
DiamondBackData.SUIT_BACK_DATA = "suit_back_data"
DiamondBackData.ONE_FOREVER_BACK = "one_forever_back"
DiamondBackData.BOSS_FIRST_KILL = "boss_first_kill"
DiamondBackData.BACK_RECORD = "back_record"

function DiamondBackData:__init()
	if DiamondBackData.Instance then
		ErrorLog("[DiamondBackData]:Attempt to create singleton twice!")
	end
	DiamondBackData.Instance = self

	self.one_equip_list = {}
	self.suit_back_list = {}
	self.one_forever_list = {}
	self.boss_info = {}
	self.back_record = {}

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.EquipRecycleAll, BindTool.Bind(self.CheckRecycleAllGet, self))
end

function DiamondBackData:__delete()
	DiamondBackData.Instance = nil
end

-- 单件限时首爆
function DiamondBackData:GetOneEquipLimitData(protocol)
	self.one_equip_list = protocol.one_limit_list

	self:DispatchEvent(DiamondBackData.ONE_EQUIP_LIST)
	GameCondMgr.Instance:CheckCondType(GameCondType.EquipRecycleAll)
end

-- 套装限时回收
function DiamondBackData:GetSuitLimitBack(protocol)
	self.suit_back_list = protocol.suit_list

	self:DispatchEvent(DiamondBackData.SUIT_BACK_DATA)
	GameCondMgr.Instance:CheckCondType(GameCondType.EquipRecycleAll)
end

-- 单件永久回收
function DiamondBackData:GetOneForeverBackData(protocol)
	self.one_forever_list = protocol.one_list

	self:DispatchEvent(DiamondBackData.ONE_FOREVER_BACK)
	GameCondMgr.Instance:CheckCondType(GameCondType.EquipRecycleAll)
end

-- BOSS击杀信息
local boss_info = nil -- boss首杀信息缓存
function DiamondBackData:GetBossKillInfo(protocol)
	self.boss_info = protocol.boss_list
	boss_info = nil

	self:DispatchEvent(DiamondBackData.BOSS_FIRST_KILL)
	GameCondMgr.Instance:CheckCondType(GameCondType.EquipRecycleAll)
end

-- 回收记录
function DiamondBackData:GetRecordData(protocol)
	self.back_record = protocol.back_list

	self:DispatchEvent(DiamondBackData.BACK_RECORD)
end

-- 获取单件限时数据
function DiamondBackData:SetOneEquipList()
	local data = {}

	local function sort(a, b)
		if a.equip_result ~= b.equip_result then
			return a.equip_result < b.equip_result
		elseif a.equip_num ~= b.equip_num and (b.equip_num == 0 or a.equip_num == 0) then
			return b.equip_num == 0
		elseif a.equip_index ~= b.equip_index then
			return a.equip_index < b.equip_index
		end
	end

	for k, v in pairs(OneEquipLimitTimeGetCfg.itemList) do
		local num, result = self:GetOneEquipNum(v.ItemId)
		local vo = {
			cfg = v,
			equip_id = k,
			equip_index = v.index,
			equip_num = v.limitCount - num,
			equip_result = result,
		}
		table.insert(data, vo)
	end

	table.sort(data, sort)
	return data
end

function DiamondBackData:GetOneEquipNum(equ_id)
	for k, v in pairs(self.one_equip_list) do
		if v.equ_id == equ_id then
			return v.equ_num, v.suc_result
		end
	end
	return 0, 0
end

-- 获取套装回收信息
function DiamondBackData:GetSuitList()
	local data = {}
	for i, v in ipairs(SuitLimitTimeBackCfg.itemList) do
		local num = self:GetSuitNum(i)
		local vo = {
			cfg = v,
			suit_index = i,
			suit_num = v.limitCount - num,
		}
		table.insert(data, vo)
	end
	return data
end

function DiamondBackData:GetSuitNum(index)
	local list = self.suit_back_list or {}
	local cur_data = list and list[index] or {}

	return cur_data.num or 0
end

-- 获取单件永久回收信息
function DiamondBackData:GetOneForeverList()
	local data = {}

	local function sort(a, b)
		if a.onef_num ~= b.onef_num and a.onef_num == 0 then
			return false
		elseif a.onef_num ~= b.onef_num and b.onef_num == 0 then
			return true
		elseif a.onef_is_back ~= b.onef_is_back then
			return a.onef_is_back > b.onef_is_back
		else
			return a.onef_index < b.onef_index
		end
	end

	for i, v in ipairs(EquipForeverBackCfg.itemList) do
		local num = self:GetOneforeverNum(i)
		local vo = {
			cfg = v,
			onef_num = v.limitCount - num,
			onef_index = i,
			onef_is_back = BagData.Instance:GetItemNumInBagById(v.consume[1].id) > 0 and 1 or 0
		}
		table.insert(data, vo)
	end

	table.sort(data, sort)
	return data
end

-- 是否有该装备
function DiamondBackData:GetEquipIsBagHave(item_id)
	
end

function DiamondBackData:GetOneforeverNum(index)
	local list = self.one_forever_list or {}
	local cur_data = list and list[index] or {}

	return cur_data.num or 0
end

-- 获取boss击杀信息
function DiamondBackData:GetBossKillList()
	local data = {}
	for k, v in pairs(BossFirstKillCfg.BossList) do
		local p_name = self:GetBossKillPlayName(v.bossId)
		local vo = {
			kill_name = p_name,
			cfg = v,
		}
		table.insert(data, vo)
	end
	table.sort(data, function (a,b)
		if a.kill_name ~= b.kill_name and a.kill_name == "" then
			return true
		end
	end)

	return data
end

function DiamondBackData:GetBossKillPlayName(boss_id)
	if nil == boss_info then
		boss_info = {}
		for k, v in pairs(self.boss_info) do
			boss_info[v.boss_id or 0] = v.role_name
		end
	end

	return boss_id and boss_info[boss_id]
end

--回收记录
function DiamondBackData:GetBackRecordList()
	table.sort(self.back_record, function (a,b)
		if a.equ_index ~= b.equ_index then
			return a.equ_index > b.equ_index
		end
	end)
	return self.back_record
end

-- 获取活动开服日期显示
function DiamondBackData:ActOpenStartTime()
	local server_time = TimeCtrl.Instance:GetServerStartTime() or 0
	local open_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local end_time = os.date("*t", server_time + 6*24*60*60)
	
	return open_time, end_time
end

-- 所有档次次数是否全部领完
function DiamondBackData:GetAllNum()

	local data = self:GetOneForeverList()
	for k, v in pairs(data) do
		if v.onef_num > 0 then
			return false
		end
	end
	return true
end

function DiamondBackData:CheckRecycleAllGet(param)
	local bool = true
	if OtherData.Instance:GetOpenServerDays() >= 8 then
		bool = self:GetAllNum() == param
		if bool == false then
			ViewManager.Instance:CloseViewByDef(ViewDef.DiamondBackView)
		end
	end
	
	return bool
end