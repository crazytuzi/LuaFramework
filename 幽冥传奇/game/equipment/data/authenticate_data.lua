--------------------------------------------------------
-- 锻造-鉴定Data
--------------------------------------------------------

AuthenticateData = AuthenticateData or BaseClass()

AuthenticateData.AUTHENTICATE_DATA_CHANGE = "authenticate_data_change"
AuthenticateData.HOOK_CHEAK = "hook_cheak"
AuthenticateData.RESULT = "result"

function AuthenticateData:__init()
	if AuthenticateData.Instance then
		ErrorLog("[AuthenticateData]:Attempt to create singleton twice!")
	end
	AuthenticateData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex, self), RemindName.EquipAuthenticate)
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, self.FlushRemind)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	-- self.game_cond_change = GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self.attr_list = {}
	self.ls_attr_list = {}

	self.lock = {0, 0, 0, 0, 0}

	self.check = {}
	self.attr_cheak = 0
end

function AuthenticateData:__delete()
	AuthenticateData.Instance = nil

	if self.game_cond_change then
		GlobalEventSystem:UnBind(self.game_cond_change)
		self.game_cond_change = nil
	end
end

----------设置----------
-- 获取装备鉴定结果
function AuthenticateData:SetAuthenticateData(protocol)
	self.equip_data[protocol.series+1] = protocol.authenticate

	self:DispatchEvent(AuthenticateData.AUTHENTICATE_DATA_CHANGE)
	self:DispatchEvent(AuthenticateData.RESULT, protocol.authenticate)
end

-- 获取所有装备鉴定结果
function AuthenticateData:SetAllEquipData(protocol)
	self.equip_data = protocol.all_equip

	self:DispatchEvent(AuthenticateData.AUTHENTICATE_DATA_CHANGE)
	self:FlushRemind()
end

function AuthenticateData:GetattrList(index)
	return self.equip_data[index]
end

-- 数据分化
function AuthenticateData:GetDothData(data)
	local data = data or {}
	local old_tiem = {}
	local ls_item = {}

	for k, v in pairs(data) do
		local vo1 = {
			jd_type = v.jd_type,
			attr_type = v.attr_type,
			attr_index = v.attr_index,
		}

		local vo2 = {
			ls_jd_type = v.ls_jd_type,
			ls_attr_type = v.ls_attr_type,
			ls_attr_index = v.ls_attr_index,
		}

		table.insert(old_tiem, vo1)
		table.insert(ls_item, vo2)
	end

	return old_tiem, ls_item
end

-- 获取鉴定装备配置
function AuthenticateData:GetEquipCfg(index)
	return ConfigManager.Instance:GetServerConfig("equipSynthesis/EquipSlotAppsalAttrs/AppsalAttrs" .. index)
end

-- 获取是够锁定
function AuthenticateData:GetIsLock(index, is_lock)

	self.lock[index] = is_lock - 1

	self:DispatchEvent(AuthenticateData.AUTHENTICATE_DATA_CHANGE)
end

function AuthenticateData:LockState()
	return self.lock
end

-- 获取锁了几条属性
function AuthenticateData:GetLockNum()
	local index = 0
	for k, v in pairs(self.lock) do
		if v == 1 then
			index = index + 1
		end
	end

	return index
end

local attr_color = {
	[COLOR3B.GREEN] = {1, 2},
    [COLOR3B.BLUE] = {3, 4},
    [COLOR3B.PURPLE] = {5, 7},
    [COLOR3B.ORANGE] = {8, 10},
}

-- 获取品质颜色
function AuthenticateData:GetAttrColor(type, star)
	local color = COLOR3B.GREEN
	if type == 1 then
		for k, v in pairs(attr_color) do
			if star >= v[1] and star <= v[2] then
				color = k
			end
		end
	elseif type == 2 then
		color = COLOR3B.RED
	elseif type == 3 then
		color = COLOR3B.GOLD
	end

	return color
end

-- 获取属性选择状态
function AuthenticateData:GetAttrCheck(index)
	self.attr_cheak = index
	local vo = {0, 0, 0, 0, 0}
	self.check = {}
	for k, v in pairs(vo) do
		if k == index then
			v = 1
		else
			v = 0
		end
		table.insert(self.check, v)
	end
	self:DispatchEvent(AuthenticateData.HOOK_CHEAK, index)
end

function AuthenticateData:GetHookState()
	return self.check, self.attr_cheak
end

-- 锁定锁定初始化
function AuthenticateData:InitCheck()
	self.lock = {0, 0, 0, 0, 0}
end

-- 精致选中属性初始化
function AuthenticateData:GetHookInit()
	self.attr_cheak = 0
end

-- 获取单个装备的总星级
function AuthenticateData:GetOneEquipStar(index)
	local data = AuthenticateData.Instance:GetattrList(index)
	data = AuthenticateData.Instance:GetDothData(data)

	local index = 0
	for k, v in pairs(data) do
		if v.jd_type ~= 0 and v.attr_type ~= 0 and v.attr_index ~= 0 then
			local n = (v.jd_type - 1) * 10
			index = index + v.attr_index + n
		end
	end

	return index
end

function AuthenticateData:FlushRemind()
	RemindManager.Instance:DoRemindDelayTime(RemindName.EquipAuthenticate)
	RemindManager.Instance:DoRemindDelayTime(REMIND_ACT_LIST[ACT_ID.JBJJ])
end

-- 获取全部装备的星级
function AuthenticateData:GetAllEquipStar()
	local index = 0
	for i = 1, 10 do
		local star = self:GetOneEquipStar(i)
		index = index + star
	end
	return index
end

-- 当前的所有星级处于套装第几阶段
function AuthenticateData:StarSuitIndex()
	local index = 0
	local cont = 0
	local star = AuthenticateData.Instance:GetAllEquipStar()
	for k, v in pairs(SuitPlusConfig[14].list) do
		if star >= v.count then
			index = k
			cont = v.count
		end
	end
	return index, cont
end

-- 获取洗炼星级的套装属性(index=第几阶段)
function AuthenticateData.GetStarSuitAttr(index)
	local cfg = SuitPlusConfig and SuitPlusConfig[14] and SuitPlusConfig[14].list or {}
	local cur_cfg = cfg[index] or {}
	local count = cur_cfg.count or 0
	local attr = cur_cfg.attrs or {}

	return attr, count
end

-- -- 功能开放后,开启红点提示
function AuthenticateData.OnGameCondChange(cond_id, is_all_ok)
	-- local v_open_cond = ViewDef.Equipment.JianDing.v_open_cond or ""
	-- local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	-- if v_open_cond == is_all_ok then
	-- 	-- RemindManager.Instance:RegisterCheckRemind(self.GetRemindIndex, RemindName.EquipAuthenticate)
	-- 	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex, self), RemindName.EquipAuthenticate)
	-- 	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, self.FlushRemind)
	-- 	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

		self:FlushRemind()

		-- if self.game_cond_change then
		-- 	GlobalEventSystem:UnBind(self.game_cond_change)
		-- 	self.game_cond_change = nil
		-- end
	-- end
end

function AuthenticateData:OnBagItemChange(event)
	local consume_id = 2278
	event.CheckAllItemDataByFunc(function (vo)
		if vo.change_type == ITEM_CHANGE_TYPE.LIST or vo.data.item_id == consume_id then
			RemindManager.Instance:DoRemindDelayTime(RemindName.EquipAuthenticate)
		end
	end)
end

function AuthenticateData.GetRemindIndex()
	local has_count = BagData.Instance:GetItemNumInBagById(2278)

	local vis = has_count >= 2 and 1 or 0

	return vis
end
--------------------
