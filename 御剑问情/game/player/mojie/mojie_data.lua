MojieData = MojieData or BaseClass(BaseEvent)

MOJIE_MAX_TYPE = 4 --魔戒最大类型
MojieData.Attr = {"gong_ji", "max_hp", "fang_yu", "ming_zhong",  "shan_bi",  "bao_ji", "jian_ren"}
MojieData.MOJIE_EVENT = "mojie_event"	--魔戒信息变化
MojieData.ITEM_ID_T = {[0] = 26703, 26702, 26700, 26701}
MojieData.SKILL_T = {70, 71, 72}
function MojieData:__init()
	if MojieData.Instance then
		print_error("[MojieData] 尝试创建第二个单例模式")
	end
	MojieData.Instance = self
	self.mojie_list = {}
	self.mojie_gift_id = -1
	self.mojie_gift_bag_index = -1
	self:IntiMojieInfo()
	self:AddEvent(MojieData.MOJIE_EVENT)
	self.mojieconfig_auto = ConfigManager.Instance:GetAutoConfig("mojieconfig_auto")
	RemindManager.Instance:Register(RemindName.Mojie, BindTool.Bind(self.GetMojieRemind, self))
end

function MojieData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Mojie)
	
	MojieData.Instance = nil
end

function MojieData:IntiMojieInfo()
	for i = 0, MOJIE_MAX_TYPE - 1 do
		local vo = {}
		vo.item_id = MojieData.ITEM_ID_T[i] or 26703
		vo.mojie_skill_type = 0
		vo.mojie_level = 0
		vo.mojie_skill_id = 0
		vo.mojie_skill_level = 0
		vo.param = CommonStruct.ItemParamData()
		self.mojie_list[i] = vo
	end
end

function MojieData:SetMojieInfo(info)
	for k,v in pairs(info) do
		self.mojie_list[k].mojie_skill_type = v.mojie_skill_type
		self.mojie_list[k].mojie_level = v.mojie_level
		self.mojie_list[k].mojie_skill_id = v.mojie_skill_id
		self.mojie_list[k].mojie_skill_level = v.mojie_skill_level
	end
	self:NotifyEventChange(MojieData.MOJIE_EVENT)
end

function MojieData:GetMojieInfo()
	return self.mojie_list
end

function MojieData.IsMojieSkill(skill_id)
	for k,v in pairs(MojieData.SKILL_T) do
		if v == skill_id then
			return true
		end
	end
	return false
end

function MojieData:GetMojieLevelById(skill_id)
	for k,v in pairs(self.mojie_list) do
		if v.mojie_skill_id == skill_id then
			return v.mojie_level
		end
	end
	return 0
end

function MojieData.IsMojie(item_id)
	for k,v in pairs(MojieData.ITEM_ID_T) do
		if v == item_id then
			return true
		end
	end
	return false
end

function MojieData:GetOneMojieInfo(mojie_type)
	return self.mojie_list[mojie_type]
end


function MojieData:GetMojieInfoBySkillId(skill_id)
	for k,v in pairs(self.mojie_list) do
		if v.mojie_skill_id == skill_id then
			return v
		end
	end
	return nil
end

function MojieData:GetMojieLevel(mojie_type)
	if self.mojie_list[mojie_type] then
		return self.mojie_list[mojie_type].mojie_level, self.mojie_list[mojie_type].mojie_skill_level
	end
	return 0, 0
end

function MojieData:GetMojieCfg(mojie_type, mojie_level)
	for i,v in ipairs(self.mojieconfig_auto.level) do
		if v.mojie_type == mojie_type and v.mojie_level == mojie_level then
			return v
		end
	end
	return nil
end

function MojieData:GetMojieOpenLevel(mojie_type)
	for i,v in ipairs(self.mojieconfig_auto.level) do
		if v.mojie_type == mojie_type and v.has_skill == 1 then
			return v.mojie_level, v.skill_level, v.skill_id, v.mojie_name
		end
	end
	return 0, 0, 0, ""
end

function MojieData:GetMojieName(mojie_type, mojie_level)
	for i,v in ipairs(self.mojieconfig_auto.level) do
		if v.mojie_type == mojie_type and v.mojie_level == mojie_level then
			return v.mojie_name
		end
	end
	return ""
end

function MojieData:GetMojieRemind()
	return self:IsShowMojieRedPoint() and 1 or 0
end

function MojieData:IsShowMojieRedPoint(mojie_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	for i,v in ipairs(self.mojieconfig_auto.level) do
		if mojie_type then
			if ItemData.Instance:GetItemNumInBagById(v.up_level_stuff_id) >= v.up_level_stuff_num and mojie_type == v.mojie_type and
				v.up_level_limit <= level and (self:GetOneMojieInfo(v.mojie_type) and v.mojie_level == self:GetOneMojieInfo(v.mojie_type).mojie_level)
				and self:GetMojieCfg(mojie_type, v.mojie_level + 1) and self:GetOneMojieInfo(v.mojie_type).mojie_skill_id >= 0 then
				return true
			end
		else
			if ItemData.Instance:GetItemNumInBagById(v.up_level_stuff_id) >= v.up_level_stuff_num and self:GetMojieCfg(v.mojie_type, v.mojie_level + 1) and
				v.up_level_limit <= level and (self:GetOneMojieInfo(v.mojie_type) and v.mojie_level == self:GetOneMojieInfo(v.mojie_type).mojie_level)
				and self:GetMojieCfg(v.mojie_type, v.mojie_level + 1) and self:GetOneMojieInfo(v.mojie_type).mojie_skill_id >= 0 then
				return true
			end
		end
	end
	return false
end

function MojieData:SetMojieGiftBagIndex(bag_index)
	self.mojie_gift_bag_index = bag_index
end

function MojieData:GetMojieGiftBagIndex()
	return self.mojie_gift_bag_index
end

function MojieData:SetMojieGiftId(item_id)
	self.mojie_gift_id = item_id
end

function MojieData:GetMojieGiftId()
	return self.mojie_gift_id
end