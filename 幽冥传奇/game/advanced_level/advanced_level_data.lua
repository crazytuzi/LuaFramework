AdvancedLevelData  = AdvancedLevelData or BaseClass()


AdvancedLevelData.InnerEquipPos = {
	ShaYuDanPos = 0,			-- 砂玉丹
	BloodYaDanPos = 1 ,			-- 血牙丹
	ChiHuangDanPos = 2 ,		-- 炽凰丹
	
	InnerEquipPosMax = 2,			-- 最大内功装备位
}

AdvancedLevelData.Property = {
	[1] = {5,39},
	[2] = {9,11,21,23},
	[3] = {102,144},
	[4] = {173,178}
}

AdvancedLevelData.EffectList = {
	[1] = 1198,
	[2] = 1197,
	[3] = 1201,
	[4] = 1202,
	[5] = 1200,
	[6] = 1199,
}

CREST_SLOT_CFG_LIST = {
	require("scripts/config/server/config/bossArms/bossArmsAttr/warriorArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/marsArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/kingArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/monarchArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/guangArms"),
	require("scripts/config/server/config/bossArms/bossArmsAttr/bingArms"),
}

function AdvancedLevelData:__init()
	if AdvancedLevelData.Instance then
		ErrorLog("[AdvancedLevelData] attempt to create singleton twice!")
		return
	end
	AdvancedLevelData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.equip_list = {}

	self.crest_info = {}

	self.shengshou_level = 0
end

function AdvancedLevelData:__delete()
	AdvancedLevelData.Instance = nil

end


function AdvancedLevelData:CanGetStepByLevel(inner_level)
	local level = inner_level%10
	local step = (inner_level - level) / 10 + 1
	if inner_level > 0 and level == 0 then
		step = step - 1
	end

	return step,level
end


function AdvancedLevelData:GetInnerAttr()
	local cfg = AdvancedLevelData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL))
	return cfg and cfg.attr or {}
end

function AdvancedLevelData:GetInnerNextAttr()
	local cfg = AdvancedLevelData.GetInnerCfg(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)+1)
	return cfg and cfg.attr or {}
end

function AdvancedLevelData.GetInnerCfg(level, prof)
	prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local cfg = ConfigManager.Instance:GetServerConfig(string.format("vocation/innerLevelConfig/InnerJob%dLevelCfg", prof))
	return cfg and cfg[1][level]
end


function AdvancedLevelData:SetEquipNum(index, num)
	self.equip_list[index] = num 
	GlobalEventSystem:Fire(JINJIE_EVENT.NOSHU_CHANGE)
end


function AdvancedLevelData:GetHadNumByIndex(index)
	return self.equip_list[index]
end


function AdvancedLevelData.GetOneEquipAttr(index, num)
	local prof =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local one_attrs =  InnerConfig.BaseAptitudeAttrs[prof] and InnerConfig.BaseAptitudeAttrs[prof][index]
	
	local attrs = {}
	attrs = CommonDataManager.AddAttr(attrs, CommonDataManager.MulAtt(one_attrs, num))
	return attrs
end

--魔书可升级

function AdvancedLevelData:GetMoshuCanUp()
	if ViewManager.Instance:CanOpen(ViewDef.Advanced.Moshu) then
		local inner_level  = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
		local next_cfg = AdvancedLevelData.GetInnerCfg(inner_level + 1)
		if next_cfg == nil then  --达到最高级的情况
			return  0 
		end
		for k,v in pairs(next_cfg.consume) do
			local num = 0
			if v.type > 0 then
				num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STONE)
			else
				num = BagData.Instance:GetItemNumInBagById(v.id)
			end
			if num >= v.count then
				return 1
			end
		end
	end
	return 0
end

--资质丹可使用
function AdvancedLevelData:GetCanGuangliang()

	if ViewManager.Instance:CanOpen(ViewDef.Advanced.Moshu) then 
		local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL) < InnerConfig.openAptitude then
			return 0
		end
		local next_cfg = AdvancedLevelData.GetInnerCfg(inner_level)
		for k, v in pairs(InnerConfig.ConsumeId) do
			local num = BagData.Instance:GetItemNumInBagById(v)  --背包中有该物品ID的物品即可
			if num > 0 and next_cfg.InjectionLimit > (self:GetHadNumByIndex(k - 1) or 0)  then
				return 1
			end
		end
	end
	return  0 
end


--元素

function AdvancedLevelData:SetCrestInfo(protocol)
	self.crest_info = protocol.crest_info
end

function AdvancedLevelData:SetUpCrestSlotResult(protocol)
	if self.crest_info[protocol.crest_slot] then
		self.crest_info[protocol.crest_slot] = protocol.slot_level
	end
	GlobalEventSystem:Fire(JINJIE_EVENT.YUSU_UP_CHANGE, protocol.crest_slot, protocol.slot_level)
end

function AdvancedLevelData:GetYuanSuSingleData(slot)
	return self.crest_info[slot]
end

function AdvancedLevelData:GetAttrBySlot(slot, level)
	local cfg = CREST_SLOT_CFG_LIST[slot][1]
	local attr_data = {}
	if cfg then
		 attr_data = cfg.attr[level] or {}

		 if nil == attr_data[1] then 
			local attr_list = TableCopy(cfg.attr[1])
			for k,v in pairs(attr_list) do
				v.value = 0
				table.insert(attr_data, v)
			end
		end
	end
	return attr_data
end

--得到所有属性
function AdvancedLevelData:GetCurAllAttr()
	local attr_data = {}
	for k,v in pairs(self.crest_info) do
		attr_data = CommonDataManager.AddAttr(attr_data, self:GetAttrBySlot(k, v))
	end
	return attr_data
end


--得到消耗
function AdvancedLevelData:GetConsumeBySlotAndLevel(slot, level)
	local cfg = bossArmsUpgradeCfg.consumes[slot]
	if cfg then
		local cur_cfg = cfg[level]
		if cur_cfg then
			return cur_cfg[1]
		end
	end
	return nil
end

--得到单个元素是否可升级
function AdvancedLevelData:GetSingleCanUp(slot, next_level)
	local consume  = self:GetConsumeBySlotAndLevel(slot, next_level)
	if consume == nil then
		return false
	end
	local num = BagData.Instance:GetItemNumInBagById(consume.id)
	if num >= consume.count then
		return true
	end
	return false
end

--得到当前技能数据
function AdvancedLevelData:GetSkillLevelAndSkillId()
	local data = {}
	for k, v in ipairs(bossArmsUpgradeCfg.levelskill) do
		local num = 0 
		for k1, v1 in pairs(self.crest_info) do
			if v1 >= v.level then
				num = num + 1
			end 
		end
		if num >= #self.crest_info then
			data = v
		end
	end
	return data
end

--得到技能配置数据
function AdvancedLevelData:GetCfgSkillLevel(level)
	return bossArmsUpgradeCfg.levelskill[level]
end

function AdvancedLevelData:GetCanUpYuansu()
	if ViewManager.Instance:CanOpen(ViewDef.Advanced.YuanSu) then --元素未开放无红点
		for k,v in pairs(self.crest_info) do
			if self:GetSingleCanUp(k, v + 1) then
				return 1
			end
		end
	end
	return 0
end


---圣兽升级
 function AdvancedLevelData:SetMeridiansResult(protocol)
 	self.shengshou_level = protocol.level
 	GlobalEventSystem:Fire(JINJIE_EVENT.SHENGSHOU_UP_ENENT)
 end

 function AdvancedLevelData:GetCurLevel()
 	return self.shengshou_level
 end


 function AdvancedLevelData:GetConsumeBylevel(next_level)
 	local consume = MeridiansCfg.upgrade[next_level]
 	if consume == nil then
 		return nil 
 	end
 	return consume.consumes
 end

 function AdvancedLevelData:GetIsCanUp()
 	if ViewManager.Instance:CanOpen(ViewDef.Advanced.ShengShou) then -- 圣兽未开放红点
	 	local next_level = self.shengshou_level + 1
	 	local cfg = self:GetConsumeBylevel(next_level)
	 	if cfg == nil then
	 		return 0
	 	end
	 	local consume_count = cfg[1].count
	 	local had_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ENERGY)
	 	if had_num >= consume_count then
	 		return 1
	 	end
	end
 	return 0 
 end


function AdvancedLevelData:GetSelectIndex()
	local index = (self.shengshou_level + 1)%4 == 0 and 4 or (self.shengshou_level + 1)%4
	return index
end


function AdvancedLevelData:GetLevelListShow()
	local level_list = {}
	for i= 1, 4 do
		level_list[i] = {
			level = 0, 		--默认是0级
			index = i,
		}
	end
	local discuss = self.shengshou_level/4 
	local remainder  = self.shengshou_level%4
	for i = 1, 4 do
		level_list[i].level = discuss
	end

	for i = 1, remainder do
		level_list[i].level = level_list[i].level + 1
	end
	return level_list
end



function AdvancedLevelData:GetCurAttrListByIndex(index)
	local attr = MeridiansCfg.attrs[self.shengshou_level]

	if attr == nil then
		attr = {}
		local attr1 = MeridiansCfg.attrs[1]
		for k, v in pairs(attr1) do
			local data = {}
			data.type = v.type
			data.value = v.value
			table.insert(attr, data)
		end
	end
	local attr3 = AdvancedLevelData.Property[index]
	local cur_attr = {}
	for k, v in pairs(attr3) do
		for k1, v1 in pairs(attr) do
			if v == v1.type then
				table.insert(cur_attr, v1)
			end
		end
	end
	return cur_attr
end


