DeifyData  = DeifyData or BaseClass()

DeifyData.DEIFY_LEVEL_CHANGE = "deify_level_change"
function DeifyData:__init()
	if DeifyData.Instance then
		ErrorLog("[DeifyData] attempt to create singleton twice!")
		return
	end
	DeifyData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		level = 0,          -- 封神基础等级(从服务端发送过来的等级)
		phase = 1,          -- 封神阶数
		child_level = 0     -- 封神等级
	}
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.OfficeUpGrade)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

end

--[RemindName.OfficeUpGrade] = {RemindGroupName.RoleView, RemindGroupName.OfficeTabbar},

function DeifyData:__delete()
	DeifyData.Instance = nil

end


function DeifyData:GetAttrTypeValueFormat(level)
	local attr_list = {}
	for k,v in pairs(DeifyData.AttrEnum) do
		local attr = {
			type = v,
			value = VocationConfig[1].levelProp[level][k],
		}
		table.insert(attr_list, attr)
	end
	return attr_list
end

function DeifyData:GetNeedLevelTxt()
	if not (office_cfg.level_list[self:GetLevel()]) then return end
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local needlv = office_cfg.level_list[self:GetLevel() + 1] and office_cfg.level_list[self:GetLevel() + 1].needlv or 0
	if level > needlv then
		return string.format("{wordcolor;1bc22a;%d级}", needlv)
	else
		return string.format("{wordcolor;c91818;%d级}", needlv)
	end
end

--获取拥有神灵的数量和当前升级的数量
function DeifyData:GetHasCountAndNeedCount()
	if 1 > self:GetLevel() then
		return 0, 0
	end
	local item = office_cfg.level_list[self:GetLevel()+1] and office_cfg.level_list[self:GetLevel()+1].consume[1] or {}
	local item_id = item.id or 0
	local item_type = item.type or 0
	local need_num = item.count or 0
	local has_num = BagData.GetConsumesCount(item_id, item_type) or 0
	return has_num, need_num
end

--
function DeifyData:GetConsumTxt()
	local has_num, need_num = self:GetHasCountAndNeedCount()
	local consum_txt =  has_num > need_num and "{wordcolor;1bc22a;%d/%d}" or "{wordcolor;c91818;%d/%d}"
	return string.format(consum_txt, has_num, need_num)
end

---------封神数据----------

function DeifyData:SetOfficeResults(protocol)
	self.data.level = protocol.level
	if self.data.level == 1 then
		MainuiCtrl.Instance:GetView():GetSmallPart():CheckFuncGuideShow()
	end
	-- 算出封神等级和封神阶数
	self.data.child_level = (protocol.level - 1) % 11
	self.data.phase = (protocol.level - 1 - self.data.child_level) / 11 + 1 -- 封神阶数

	if protocol.index == 3 then
		self:DispatchEvent(DeifyData.DEIFY_LEVEL_CHANGE)
	elseif protocol.index == 2 then
		self:DispatchEvent(DeifyData.DEIFY_LEVEL_CHANGE)
		--RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeCanUp) -- 激活时无物品消耗变化,修正红点提示

		RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeUpGrade)
	end
end

-- 获取封神数据 .level总等级 .phase封神阶数 .child_level封神等级
function DeifyData:GetData()
	return self.data
end

-- 获取封神基础等级
function DeifyData:GetLevel()
	return self.data.level
end

-- 获取封神阶数
function DeifyData:GetPhase()
	return self.data.phase
end

-- 获取当前封神等级
function DeifyData:GetChildLevel()
	return self.data.child_level
end

----------end----------

----------红点提示----------

function DeifyData.OnBagDataChange()
	--RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeCanUp)
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function DeifyData:GetRemindIndex()
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < office_cfg.activated_level then
		return 0
	end
	local level = DeifyData.Instance:GetLevel()
	if level >= #office_cfg.level_list then return 0 end

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local needlv = office_cfg.level_list[level + 1] and office_cfg.level_list[level + 1].needlv or 0
	if role_level < needlv then --等级不足不显示红点
		return 0
	end
	local item = office_cfg.level_list[level + 1].consume[1] -- 获取声望卷配置
	local item_num = BagData.GetConsumesCount(item.id, item.type) or 0

	local index = item_num >= item.count and 1 or 0
	return index
end


function DeifyData:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT or vo.key == OBJ_ATTR.CREATURE_LEVEL then
		RemindManager.Instance:DoRemindDelayTime(RemindName.OfficeUpGrade)
	end
end

--封神提示
function DeifyData:GetRemindNum(remind_name)
	if remind_name == RemindName.OfficeUpGrade then
		return self:GetRemindIndex()
	end
end


----------end----------