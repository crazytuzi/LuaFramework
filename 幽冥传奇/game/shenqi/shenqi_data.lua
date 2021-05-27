ShenqiData = ShenqiData or BaseClass()
--神器的四个基本属性
Attr = {
	 BuBai = 1, 	--不败
	 RuShan =2 , --如山
	 LiRen = 3, --利刃
	 TuiBian = 4, --蜕变
}
--四个基础属性的加成属性
AttrAdd = {
	[1] = {
		[21] = 1,      --物理防御加成 
		[23] = 1,  
		[25] = 1,      --魔法防御加成
		[27] = 1,  
	},
	[2] = {
		[5] = 1,        --生命值加成
	},
	[3] = {
		[13] = 1, 		--攻击加成
		[15] = 1,
		[17] = 1,
		[19] = 1,
		[9] = 1,
		[11] = 1,
	},
	[4] = BASE_ATTR_TYPES , --基础属性
}
--神器最大等级
ShenQiMaxLevel = 385
--每一阶等级
PerFloorLevel = 11
--属性最大等级
AttrMaxLevel  = 35
--最小可见阶
MinCanSeeFloor = 5

ShenqiData.SHENQI_LEVEL_CHANGE = "shenqi_level_change"
ShenqiData.SHENQI_ATTR_CHANGE = "shenq_attr_change"
ShenqiData.MONEY_CHANGE = "money_change"
function ShenqiData:__init()
	if ShenqiData.Instance ~= nil then
		ErrorLog("[ShenqiData] Attemp to create a singleton twice !")
	end
	ShenqiData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.shenqi_level = 0
	self.shenqi_jieshu = 0
	self.attr_level_list = {}
	-- self.money =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.ChangeMoney, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function ShenqiData:OnBagItemChange()
	RemindManager.Instance:DoRemind(RemindName.ShenQi)
end

function ShenqiData:ChangeMoney()
	local old_money =  self.money
	local new_money =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
	if old_money ~= new_money then
		self.money = new_money
		self:DispatchEvent(ShenqiData.MONEY_CHANGE)
	end
end

function ShenqiData:__delete()
	ShenqiData.Instance = nil
end

-- 神器每一阶的名字和特效
function ShenqiData:SetFloorInfo()
	for k,v in pairs(ArtifactConfig.floor or {})do
		self.floor_info[k] = {}
		if type(v) == "table" then
			self.floor_info[k].name = v.name
			self.floor_info[k].eff_id = v.eff_id
			self.floor_info[k].floor = k
			self.floor_info[k].is_active = false
		end
	end
end

function ShenqiData:GetFloorInfo()
	local show_num = self.shenqi_jieshu + 1
	if self.shenqi_jieshu < MinCanSeeFloor then
		show_num = MinCanSeeFloor
	end

	local pro = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)

	local list = {}
	for jieshu = 1, show_num do
		local cfg = ArtifactConfig.job[pro].soulcfg[(jieshu - 1) * 11 + 1]
		if cfg then
			table.insert(list, cfg)
			if jieshu <= self.shenqi_jieshu then
				list[jieshu].is_active = true
			end
		end
	
	end
	return list
end

function ShenqiData:SetCurDisplayFloor(floor)
	if floor <= 0 then
		floor = 1
	elseif floor > ShenQiMaxLevel / PerFloorLevel then
		floor = ShenQiMaxLevel / PerFloorLevel
	else
		self.cur_diaplay_floor = floor
	end
end

function ShenqiData:GetCurDisplayFloor()
	return self.cur_diaplay_floor or 1
end


function ShenqiData:GetShenqiAttrLevel(attr_type)
	return	self.attr_level_list[attr_type]
end

function ShenqiData:GetMyAllBuffAttrText()
	return self.GetAllBuffAttrText(self.attr_level_list)
end

function ShenqiData:GetMyShenqiFigth()
	return self.GetShenqiFigth(self.shenqi_level, self.attr_level_list)
end

function ShenqiData:SetShenQiInfo(protocol)
	--神器等级
	self.shenqi_level = protocol.level

	--神器阶数 客户端使用
	self.shenqi_jieshu = math.ceil(self.shenqi_level/PerFloorLevel)

	--属性等级
	self.attr_level_list = protocol.attr_list
	self:SetCurDisplayFloor(math.ceil(self.shenqi_level/PerFloorLevel))

	self:DispatchEvent(ShenqiData.SHENQI_LEVEL_CHANGE)
end

function ShenqiData:GetShenQiJieShu()
	return self.shenqi_jieshu
end

function ShenqiData:GetShenQiLevel()
	return self.shenqi_level
end

function ShenqiData:SetUpgradeResult(protocol)
	self.shenqi_level = protocol.level
	self.shenqi_jieshu = math.ceil(self.shenqi_level/PerFloorLevel)

	self:SetCurDisplayFloor(math.ceil(self.shenqi_level/PerFloorLevel))
	self:DispatchEvent(ShenqiData.SHENQI_LEVEL_CHANGE)
end

function ShenqiData:SetAttrUpResult(protocol)
	self.attr_level_list[protocol.type] = protocol.level
	self:DispatchEvent(ShenqiData.SHENQI_ATTR_CHANGE)
end



----数据相关
--当前神器 虚拟装备数据
function ShenqiData:GetVirtualEquipData()
	local cfg = ItemData.Instance:GetItemConfig(self.shenqi_item_id)
	local sq_cfg = self.GetShenQiCfgByLevel(self.shenqi_level)
	if nil == sq_cfg then return end

	if nil == self.shenqi_item_id then
		cfg = CommonStruct.ItemConfig()
		self.shenqi_item_id = ItemData.Instance:AddVirtualItemConfig(cfg)
		cfg.item_id = self.shenqi_item_id
		cfg.id = self.shenqi_item_id
	end

	cfg.name = sq_cfg.name
	cfg.desc = sq_cfg.itemCfg.desc
	cfg.color = sq_cfg.itemCfg.color
	cfg.type = 100006
	cfg.conds = sq_cfg.itemCfg.conds
	cfg.icon = BaseCell.ITEM_EFFSET_OFFSET + sq_cfg.eff_id
	cfg.showQuality = sq_cfg.itemCfg.showQuality
	cfg.staitcAttrs = sq_cfg.attr
	cfg.shenqi_attr = self.GetAllBuffAttrTextList(self.attr_level_list)
	cfg.socre = self:GetMyShenqiFigth()
	return cfg
end

--其他人神器 虚拟装备数据
function ShenqiData:GetOtherVirtualEquipData(role_info)
	-- if ItemData.Instance:GetItemConfig(self.shenqi_item_id) and self.last_level == self.shenqi_level then
	-- 	return ItemData.Instance:GetItemConfig(self.shenqi_item_id)
	-- end

	local level = role_info.shenqi_level
	local add_attr_levels = role_info.shenqi_add_attr_levels
	local prof = role_info[OBJ_ATTR.ACTOR_PROF]

	local sq_cfg = self.GetShenQiCfgByLevel(level, prof)
	if nil == sq_cfg then return end

	local cfg = CommonStruct.ItemConfig()

	cfg.name = sq_cfg.name
	cfg.desc = sq_cfg.itemCfg.desc
	cfg.color = sq_cfg.itemCfg.color
	cfg.type = 100006
	cfg.conds = sq_cfg.itemCfg.conds
	cfg.icon = BaseCell.ITEM_EFFSET_OFFSET + sq_cfg.eff_id
	cfg.showQuality = sq_cfg.itemCfg.showQuality
	cfg.staitcAttrs = sq_cfg.attr
	cfg.shenqi_attr = self.GetAllBuffAttrTextList(add_attr_levels, prof)
	cfg.socre = self.GetShenqiFigth(level, add_attr_levels, prof)
	cfg.pro = prof
	local item_id = ItemData.Instance:AddVirtualItemConfig(cfg)
	cfg.item_id = item_id
	cfg.id = item_id

	return cfg
end

--提醒相关
function ShenqiData:GetHaveNumByCfg(cfg)
	local have_num = 0
	if nil == cfg then return have_num end
	if cfg.type == tagAwardType.qatMoney then
		have_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN)
	else
		have_num = BagData.Instance:GetItemNumInBagById(cfg.id)
	end
	
	return have_num
end

function ShenqiData:GetConsumEnough(cfg)
	local have_num = self:GetHaveNumByCfg(cfg)
	return have_num > cfg.count and 1 or 0
end

function ShenqiData:GetQiHunRemindNum()
	if nil == self.GetShenqiConsume(self.shenqi_level+1) then return 0 end
	return self:GetConsumEnough(self.GetShenqiConsume(self.shenqi_level+1))
end

function ShenqiData:GetAttrRemindNum(type)
	local level = self:GetShenqiAttrLevel(type)
	if nil == self.GetShenqiAttrConsume(type, level+1) then return 0 end
	local consume_cfg = self.GetShenqiAttrConsume(type, level+1)
	return self:GetConsumEnough(consume_cfg)
end

function ShenqiData:GetRemindNum()
	--器魂升级
	if self:GetQiHunRemindNum() > 0 then return 1 end

	--属性升级
	for i,v in ipairs(Attr) do
		if self:GetAttrRemindNum(v) > 0 then return 1 end
	end

	return 0
end





----通用方法------

----配置相关
--特效id
function ShenqiData.GetShenQiCfgByLevel(level, prof)
	local cfg = ArtifactConfig.job[prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)].soulcfg
	return cfg[level] or cfg[1]
end

--消耗配置
function ShenqiData.GetShenqiConsume(level)
	--职业 
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or 0
	local consume_cgf = nil
	if level > 0 and level <= ShenQiMaxLevel then
		local soulcfg = ArtifactConfig.job[prof].soulcfg
		consume_cgf = soulcfg and soulcfg[level].consume or nil
	end

	return consume_cgf and consume_cgf[1]
end

function ShenqiData.GetShenqiAttrConsume(type, level)
	--职业 
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or 0
	local consume_cgf = nil
	if level > 0 and level <= AttrMaxLevel then
		local baseattrs = ArtifactConfig.job[prof].baseattrs
		consume_cgf = baseattrs[type][level] and baseattrs[type][level].consume or nil
	end
	return consume_cgf and consume_cgf[1]
end

--根据神器等级 和加成属性等级 计算战斗力
function ShenqiData.GetShenqiFigth(shenqi_level, add_attr_levels, prof)
	local base_attr = ShenqiData.GetShenqiAttr(shenqi_level, prof)

	if add_attr_levels then
		for i = Attr.BuBai, Attr.TuiBian do
			local attr_list = ShenqiData.GetShenqiAddAttr(i, add_attr_levels[i], prof)
			for k,v in pairs (attr_list) do  
				for k1,v1 in pairs (base_attr) do
					if v.value > 0 and v.type == v1.type then
						v1.value = v1.value + v1.value* v.value/10000  --基础属性+加成属性
					end
				end
			end
		end
	end
	local base_score = CommonDataManager.GetAttrSetScore(base_attr, prof)
	return base_score, base_attr
end

-- 每一级神器属性数据
function ShenqiData.GetShenqiAttr(level, prof)
	--职业 
	local prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attr = {}
	if level > ShenQiMaxLevel then return nil end

	if level > 0 and level <= ShenQiMaxLevel then
		-- 器魂配置
		local attrcfg = ArtifactConfig.job[prof].soulcfg[level].attr
		for k,v in pairs(attrcfg) do
			attr[k] = {}
			attr[k].type  = v.type
			attr[k].value = v.value
		end
	else
		local attrcfg = ArtifactConfig.job[prof].soulcfg[1].attr
		for k,v in pairs (attrcfg) do
			attr[k] = {}
			attr[k].type  = v.type
			attr[k].value = 0
		end
	end
	return attr
end

--四种属性加成数据(类型(不败，如山，利刃，蜕变),等级)
function ShenqiData.GetShenqiAddAttr(attr_type, level, prof)
	--职业
	local prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	--职业要忽略的属性
	local prof_ignore_list = RoleData.ProfIgnoreAttrList(prof)
	-- 器魂配置
	local baseattrs = ArtifactConfig.job[prof].baseattrs
	local value = baseattrs[attr_type][level] and baseattrs[attr_type][level].addplus or 0
	
	local attr_list = {}
	local list  = AttrAdd[attr_type]
	for k,v in pairs (list) do
		if not prof_ignore_list[k] then
			local data = {}
			data.type = k
			data.value = value
			table.insert(attr_list, data)
		end
	end

	return attr_list
end

--获取buff显示文本列表
function ShenqiData.GetAllBuffAttrTextList(add_attr_levels, prof)
	local text_list = nil
	local attr_data = {}
	if nil == add_attr_levels then return text_desc end
	for i=1, 4 do
		attr_data = CommonDataManager.AddAttr(attr_data, ShenqiData.GetShenqiAddAttr(i, add_attr_levels[i], prof))
	end
	for k, v in pairs (attr_data) do
		if nil ~= Language.ShenQi.AttrName[v.type] then
			if v.value > 0 then
				text_list = text_list or {}
				local text_desc = Language.ShenQi.AttrName[v.type] .. v.value  / 100 .. "%"
				table.insert(text_list, text_desc)
			end
		end
	end
	return text_list
end

--获取buff显示文本
function ShenqiData.GetAllBuffAttrText(add_attr_levels, prof)
	local text_desc = nil
	local attr_data = {}
	if nil == add_attr_levels then return text_desc end
	for i=1, 4 do
		attr_data = CommonDataManager.AddAttr(attr_data, ShenqiData.GetShenqiAddAttr(i, add_attr_levels[i], prof))
	end
	for k, v in pairs (attr_data) do
		if nil ~= Language.ShenQi.AttrName[v.type] then
			if v.value > 0 then
				text_desc = text_desc or ""
				text_desc = text_desc ..Language.ShenQi.AttrName[v.type]
				text_desc = text_desc  .. v.value  / 100 .. "%\n"
			end
		end
	end
	return text_desc
end