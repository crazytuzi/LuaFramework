--------------------------------------------------------
-- 装扮data
--------------------------------------------------------

FashionData = FashionData or BaseClass(BaseData)

-- FashionData.Meridians_BLESSING_CHANGE = "Meridians_blessing_change"

function FashionData:__init()
	if FashionData.Instance then
		ErrorLog("[FashionData]:Attempt to create singleton twice!")
	end
	FashionData.Instance = self

	self.total_list = {}
	self.huanwu_list = {}
	self.fashion_list = {}
	self.zhenqi_list = {}

	self.can_show = 1


	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex, self), RemindName.FashionZhenQi)
	-- self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))

	self.resolve_cfg = {} -- 装扮分解配置
	self:InitResolveCfg()
end

function FashionData:__delete()
	FashionData.Instance = nil
end

----------设置----------


-- 初始化"装扮分解"配置
function FashionData:InitResolveCfg()
	local cfg = ItemSynthesisConfig and ItemSynthesisConfig[11] or {}
	local cur_cfg = cfg.list and cfg.list[1] and cfg.list[1].itemList or {}
	for index, v in ipairs(cur_cfg) do
		local item_id = v.consume and v.consume[1] and v.consume[1].id
		if item_id then
			v.index = index -- 增加字段 用于请求分解
			self.resolve_cfg[item_id] = v
		end
	end
end

-- "装扮分解"配置
function FashionData:GetResolveCfg()
	return self.resolve_cfg
end

function FashionData:OnBagItemChange(event)
	local need_flush = false

	for i, v in ipairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			need_flush = true
		else
			local item_type = v.data and v.data.type or -1
			if item_type == ItemData.ItemType.itGenuineQi then
				need_flush = true
			end
		end

		if need_flush then
			RemindManager.Instance:DoRemindDelayTime(RemindName.FashionZhenQi)
			break
		end
	end
end

function FashionData:GetRemindIndex(remind_name)
	local index = 0

	local zhenqi_data = FashionData.Instance:GetZhenqiData() or {}
	local cfg = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.fashion_preview or {}
	local cur_cfg = cfg[3] or {}
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for i, v in ipairs(cur_cfg) do
		local item_id = 0
		if type(v) == "table" and next(v) then
			item_id = v[sex] or v[1]
		elseif type(v) == "number" then
			item_id = v
		end
		
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local cur_zhenqi_data = zhenqi_data[item_id]
		local cur_zhenqi_lv = cur_zhenqi_data and cur_zhenqi_data.zhenqi_lv or 0
		local suit_id = item_cfg.suitId or 0
		local cfg = ImageUpgradeCfg or {}
		local cur_cfg = cfg[suit_id] or {}
		local consume = nil
		if nil == cur_zhenqi_data then
			consume = {id = item_id, count = 1}
		elseif (cur_zhenqi_lv + 1) <= #cur_cfg then
			local cur_consume = cur_cfg[cur_zhenqi_lv + 1] and cur_cfg[cur_zhenqi_lv + 1].consumes or {}
			consume = cur_consume[1]
		end

		if consume then
			local have_num = BagData.Instance:GetItemNumInBagById(consume.id)
			local bool = consume.count and have_num >= consume.count
			if bool then
				index = 1
				break
			end
		end
	end

	return index
end

--------------------

function FashionData:SetAllFashionData(list)
	self.total_list = list 
	self.huanwu_list = {}
	self.fashion_list = {}
	for k, v in pairs(list) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg.type == ItemData.ItemType.itFashion then
			self.fashion_list[v.series] = v
		elseif item_cfg.type == ItemData.ItemType.itWuHuan then
			self.huanwu_list[v.series] = v
		elseif item_cfg.type == ItemData.ItemType.itGenuineQi then
			self.zhenqi_list[v.item_id] = v
			RemindManager.Instance:DoRemindDelayTime(RemindName.FashionZhenQi)
		end
	end

end

function FashionData:SetAddData(item_data)
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	if item_cfg.type == ItemData.ItemType.itFashion then
		self.fashion_list[item_data.series] = item_data
	elseif item_cfg.type == ItemData.ItemType.itWuHuan then
		self.huanwu_list[item_data.series] = item_data
	elseif item_cfg.type == ItemData.ItemType.itGenuineQi then
		self.zhenqi_list[item_data.item_id] = item_data
		RemindManager.Instance:DoRemindDelayTime(RemindName.FashionZhenQi)
	end
	GlobalEventSystem:Fire(NewFashionEvent.FaShionAdd)
end	

function FashionData:SetRecycleData(series)
	self.fashion_list[series] = nil
	self.huanwu_list[series] = nil

	for item_id, item in pairs(self.zhenqi_list) do
		if item.series == series then
			self.zhenqi_list[item_id] = nil
			break
		end
	end

	GlobalEventSystem:Fire(NewFashionEvent.FaShionDelete)
end

function FashionData:SetUpdataData(item_data)
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
	
	if item_cfg and item_cfg.type == ItemData.ItemType.itFashion then
		self.fashion_list[item_data.series] = item_data
	elseif item_cfg and item_cfg.type == ItemData.ItemType.itWuHuan then
		self.huanwu_list[item_data.series] = item_data
	elseif item_cfg and item_cfg.type == ItemData.ItemType.itGenuineQi then
		self.zhenqi_list[item_data.item_id] = item_data
		RemindManager.Instance:DoRemindDelayTime(RemindName.FashionZhenQi)
	end

	GlobalEventSystem:Fire(NewFashionEvent.FaShionUpdate)
end

function FashionData:GetFsahionData()
	return self.fashion_list
end

function FashionData:GetHuanwuData()
	return self.huanwu_list
end

function FashionData:GetZhenqiData()
	return self.zhenqi_list
end

function FashionData:GetFashionDataByItemType(item_type)
	local list = {}
	if item_type == ItemData.ItemType.itFashion then
		list = self.fashion_list
	elseif item_type == ItemData.ItemType.itWuHuan then
		list = self.huanwu_list
	elseif item_type == ItemData.ItemType.itGenuineQi then
		list = self.zhenqi_list
	end

	return list
end

function FashionData:GetHadHuanhuaFashionData()
	for k, v in pairs(self.fashion_list) do
		if v.zhuan_level == 1 then
			return v
		end
	end
	return nil
end

function FashionData:GetHadHuanhuaHuanWuData()
	for k, v in pairs(self.huanwu_list) do
		if v.zhuan_level == 1 then
			return v
		end
	end
	return nil
end

function FashionData:GetHadHuanhuaZhenQiData()
	for k, v in pairs(self.zhenqi_list) do
		if v.zhuan_level == 1 then
			return v
		end
	end
	return nil
end

function FashionData:setShowData(is_show)
	self.can_show = is_show
end

function FashionData:GetShowData()
	return self.can_show
end


function FashionData:GetFashionIsOverTime(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg then
		return false
	end
	if (data.use_time or 0) < TimeCtrl.Instance:GetServerTime() and (data.use_time or 0) > (COMMON_CONSTS.SERVER_TIME_OFFSET + item_cfg.time) then
		return true
	end
	return false
end
