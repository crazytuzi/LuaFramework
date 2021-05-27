LevelData  = LevelData or BaseClass()

function LevelData:__init()
	if LevelData.Instance then
		ErrorLog("[LevelData] attempt to create singleton twice!")
		return
	end
	LevelData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	LevelData.AttrEnum = {
		[1] = 5,					-- 最大血增加
		[3] = 9,					-- 最小物理攻击增加
		[4] = 11,					-- 最大物理攻击增加
		[9]= 21,					-- 最小物理防御增加
		[10] = 23,					-- 最大物理防御增加
		[13] = 29,					-- 准确增加
		[14] = 31,					-- 敏捷增加
	}
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.LevelTabbar)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function LevelData:__delete()
	LevelData.Instance = nil

end


function LevelData:GetAttrTypeValueFormat(level)
	local attr_list = {}
	if level > #VocationConfig[1].levelProp then
		return attr_list
	end
	for k,v in pairs(LevelData.AttrEnum) do
		local attr = {
			type = v,
			value = VocationConfig[1].levelProp[level][k],
		}
		table.insert(attr_list, attr)
	end
	return attr_list
end


function LevelData:GetCurLevelItemID(level)
	local item_id = nil
	for k, v in pairs(GradeDanTable) do
		if (not v.not_is_show) then 	--去掉
			if (v.minlevel <= level) and (level < v.maxlevel)then
				item_id = v.item_id
				break
			end
		end
	end
	return item_id
end

function LevelData:GetCurLevelItemTxt(level)
	local item_id = self:GetCurLevelItemID(level)
	local num = BagData.Instance:GetItemNumInBagById(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if level >= #VocationConfig[1].levelProp then
		return Language.Guild.Nothing
	end
	if num > 0 then
		return string.format(Language.Role.LevelDeify.EnoughDengjiDan, item_cfg.name, num)
	else
		return string.format(Language.Role.LevelDeify.NotEnoughDengjiDan, item_cfg.name, num)
	end
end

function LevelData:GetRemindNum(remind_name)
	if remind_name == RemindName.LevelTabbar then
		return self:GetBoolCanUse()
	end
end

function LevelData:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemindDelayTime(RemindName.LevelTabbar)
	end
end

function LevelData:ItemDataListChangeCallback()
	RemindManager.Instance:DoRemindDelayTime(RemindName.LevelTabbar)
end


function LevelData:GetBoolCanUse()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local item_id = self:GetCurLevelItemID(level)
	local num = BagData.Instance:GetItemNumInBagById(item_id)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local limit_level =  GlobalConfig.maxLevel[circle+1] or GlobalConfig.maxLevel[#GlobalConfig.maxLevel]
	if level >= limit_level then
		return 0 
	end
	if level >= #VocationConfig[1].levelProp then
		return 0
	end
	return num > 0 and 1 or 0
end

function LevelData:GetListData( ... )
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for k, v in pairs(LevelTransportToNPC) do
		if level >= v.levelLimit[1] and level <= v.levelLimit[2] then
			return v.list, v.name
		end
	end
end

function LevelData:GetCurIndex( ... )
	local index = 1
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	for k,v in pairs(LevelTransportToNPC) do
		if v[3] <= level and level <= (v[4] or 0 ) then
			index = k
			break 
		end 
	end
	return index
end