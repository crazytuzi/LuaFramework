InnerData = InnerData or BaseClass()

InnerData.STAGE_NUM = 10

InnerData.INNER_ATTR = {
	INNER_EXP = 1,				--内功经验(最大值不能超过4294967295), 
	INNER_MAX = 2,   			--最大内功, 
	INNER_RECOVER = 3,			--每次恢复内功,
	BAOJI = 4, 					--暴击力, 
	BAOJI_PER = 5, 				--暴击率(万分比), 
	JIANSHANG = 6, 				--减伤(万分比), 
	JIANSHANG_PER = 7, 			--减伤触发几率(万分比)
}

InnerData.InnerEquipPos = {
	ShaYuDanPos = 0,			-- 砂玉丹
	BloodYaDanPos = 1 ,			-- 血牙丹
	ChiHuangDanPos = 2 ,		-- 炽凰丹
	
	InnerEquipPosMax = 2,			-- 最大内功装备位
}

InnerData.EQUIP_CHANGE = "equip_change"

function InnerData:__init()
	if InnerData.Instance then
		ErrorLog("[InnerData] Attemp to create a singleton twice !")
	end
	InnerData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.equip_list = {}

	-- 装备位置对应的物品类型
	self.equip_slot_to_type = {
		[InnerData.InnerEquipPos.ShaYuDanPos] = ItemData.ItemType.itShaYuDan,
		[InnerData.InnerEquipPos.BloodYaDanPos] = ItemData.ItemType.itBloodYaDan,
		[InnerData.InnerEquipPos.ChiHuangDanPos] = ItemData.ItemType.itChiHuangDan,
	}

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetInnerLevelCanUpRemind, self), RemindName.InnerLevelCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetInnerEquipRemind, self), RemindName.InnerEquip)
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.InnerLevel, BindTool.Bind(self.IsActEquip, self))
end

function InnerData:__delete()
	InnerData.Instance = nil
end

function InnerData:IsActEquip()
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) >= InnerConfig.openAptitude
end

function InnerData:SetEquipNum(slot, num)
	self.equip_list[slot] = num
	self:DispatchEvent(InnerData.EQUIP_CHANGE, {slot = slot, num = num})
end

function InnerData:GetCurAttrBySlot(slot)
	local type_list ={145,147,75}
	local item_type =  type_list[slot+1]

	local list = self:GetAllEquipAttr()

	for k,v in pairs (list) do
		if v.type == item_type then
			return v
		end
	end
	return {["type"] = item_type, ["value"] = 0}
end

function InnerData:GetNextAttrBySlot(slot)
	local type_list ={145,147,75}
	local item_type =  type_list[slot+1]
	local value = 0

	local list = self:GetAllEquipAttr()
	for k,v in pairs (list) do
		if v.type == item_type then
			value = v.value
		end
	end
	value = value + self.GetOneEquipAttr(slot)[1].value
	return {["type"] = item_type, ["value"] = value}
end

-- 在背包中获取可装备的内功装备
function InnerData:GetCanEquipDataInBag(slot)
	if self:GetEquipNum(slot) == self:GetEquipMaxNum(slot) then
		-- 当前位置装备数量已满
		return
	end

	local equip_item_type = self.equip_slot_to_type[slot]
	if equip_item_type then
		for k, v in pairs(BagData.Instance:GetBagItemDataListByType(equip_item_type)) do
			return v
		end
	end
end

function InnerData.GetOneEquipAttr(slot, prof)
	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	return InnerConfig.BaseAptitudeAttrs[prof] and InnerConfig.BaseAptitudeAttrs[prof][slot + 1]
end

function InnerData:GetAllEquipAttr()
	local attrs = {}
	for i = InnerData.InnerEquipPos.ShaYuDanPos, InnerData.InnerEquipPos.InnerEquipPosMax do
		local one_attr = self.GetOneEquipAttr(i)
		local num = self:GetEquipNum(i)
		if num > 0 then
			attrs = CommonDataManager.AddAttr(attrs, CommonDataManager.MulAtt(one_attr, num))
		end
	end
	return attrs
end

function InnerData:GetEquipNum(slot)
	return self.equip_list[slot] or 0
end

function InnerData:GetEquipMaxNum(slot)
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL))
	return cfg and cfg.InjectionLimit or 0
end

function InnerData:GetChongNum()
	return math.floor((RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) - 1) / (InnerData.STAGE_NUM + 1)) + 1
end

function InnerData:IsMaxLevel()
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) % (InnerData.STAGE_NUM + 1) == 0
end

function InnerData:IsNotAct()
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) == 0
end

-- 1 ~ 10
function InnerData:GetStateIsAct(index)
	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	if inner_level == 0 then
		return false
	end
	return inner_level >= ((self:GetChongNum() - 1) * (InnerData.STAGE_NUM + 1) + index + 1)
end

function InnerData:GetInnerAttr()
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL))
	return cfg and cfg.attr or {}
end

function InnerData:GetInnerNextAttr()
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)+1)
	return cfg and cfg.attr or {}
end

--展示属性
function InnerData:GetShowInnerAttr()
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL))

	--暂不显示 151 属性
	if cfg then
		for k,v in pairs(cfg.attr) do
			if v.type == 151 then
				table.remove(cfg.attr, k)
				break
			end
		end
	end
	return cfg and cfg.attr or {}
end

function InnerData:GetShowAllAttrs()
	return CommonDataManager.AddAttr(self:GetShowInnerAttr(), self:GetAllEquipAttr())
end

function InnerData:GetAllAttrs()
	return CommonDataManager.AddAttr(self:GetInnerAttr(), self:GetAllEquipAttr())
end
function InnerData:GetAllNextAttrs()
	return CommonDataManager.AddAttr(self:GetInnerNextAttr(), self:GetAllEquipAttr())
end

function InnerData:GetExpPercent()
	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	if inner_level == 0 then
		return 0
	end
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	local need_consume = cfg and cfg.consumeBlessings or 0
	if need_consume <= 0 then
		return 1
	end
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_EXP) / need_consume
end

function InnerData:GetBindCoinConsumeNum()
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	return cfg and cfg.BindCoin or 0
end

function InnerData.GetInnerCfg(level, prof)
	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local cfg = ConfigManager.Instance:GetServerConfig(string.format("vocation/innerLevelConfig/InnerJob%dLevelCfg", prof))
	return cfg and cfg[1][level]
end

-- 能提升一级提醒
function InnerData:GetInnerLevelCanUpRemind()
	local cfg = InnerData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) + 1)
	if nil == cfg then
		return 0
	end

	local need_consume = cfg.consumeBlessings
	local next_level_left_consume = need_consume - RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_EXP)
	next_level_left_consume = math.max(next_level_left_consume, 0)
	if next_level_left_consume == 0 then
		return 1
	end

	local once_money = cfg.BindCoin
	local once_addexp = InnerConfig.blessings.addValue / InnerConfig.blessings.needMoney * once_money
	local next_level_need_money = math.ceil(next_level_left_consume / once_addexp) * once_money

	return (RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN) >= next_level_need_money) and 1 or 0
end

function InnerData:GetInnerEquipRemind()
	for slot = 0, InnerData.InnerEquipPos.InnerEquipPosMax do
		if nil ~= self:GetCanEquipDataInBag(slot) then
			return 1
		end
	end
	return 0
end
