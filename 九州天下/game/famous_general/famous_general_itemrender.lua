-------------------------------- 名将头像Item
GeneralHeadRender = GeneralHeadRender or BaseClass(BaseCell)
function GeneralHeadRender:__init()
	self.name = self:FindVariable("Name")
	self.head_icon = self:FindVariable("Head")
	self.can_up = self:FindVariable("CanUp")
	self.show_hl = self:FindVariable("ShowHl")
	self.is_active = self:FindVariable("IsActive")
	self.quality = self:FindVariable("Quality")
	self.btn_active = self:FindObj("BtnActive")
	self.can_wash = self:FindVariable("IsWashRedPoint")

	self:ListenEvent("OnClickUp", BindTool.Bind(self.OnClickUp, self))
end

function GeneralHeadRender:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end

function GeneralHeadRender:SetParent(parent)
	self.parent = parent
end

function GeneralHeadRender:OnFlush()
	if not self.data or not next(self.data) then return end
		
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id) or {}
	local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id or 0)
	self.head_icon:SetAsset(bundle, asset)
	self:FlushHL()
	self.name:SetValue(self.data.name)
	self.is_active:SetValue(FamousGeneralData.Instance:CheckGeneralIsActive(self.data.seq))
	self.quality:SetAsset(ResPath.GetQualityIcon(self.data.color))
	self:CurSelectTab(self.tab_index)
end

function GeneralHeadRender:OnClickUp()
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_LEVEL_UP, self.data.seq)
	if self.parent then
		self.parent:OnClickRoleListCell(self.index, self.data)
	end
end

function GeneralHeadRender:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function GeneralHeadRender:FlushHL()
	local cue_select = self.parent:GetSelectIndex()
	self.show_hl:SetValue(cue_select == self.index)
end

function GeneralHeadRender:GetBtnActive()
	return self.btn_active
end

--当前选择的标签
function GeneralHeadRender:CurSelectTab(tab_index)
	self.tab_index = tab_index
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	local cur_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(self.data.seq)
	if not other_cfg or not cur_info then return end
	local up_num = ItemData.Instance:GetItemNumInBagById(self.data.item_id)
	local wash_att_num = ItemData.Instance:GetItemNumInBagById(self.data.wash_attr_item_id)
	local wash_point_limit = FamousGeneralData.Instance:GetWashPointLimitByIndexAndLevel(self.data.seq + 1, cur_info.level)
	if tab_index == 1 then
		self.can_up:SetValue(up_num >= 1 and cur_info.level < other_cfg.max_level)
		self.can_wash:SetValue(false)
	else
		self.can_up:SetValue(false)
		local falg = 0
		if cur_info.wash_attr_points then
			local check_num = 0
			for k,v in pairs(cur_info.wash_attr_points) do
				if v >= wash_point_limit[FamousGeneralData.PotentialLimit[k + 1]] then
					check_num = check_num + 1
				end
			end

			if check_num < 3 then
				falg = 1
			end
		end
		self.can_wash:SetValue(cur_info.level > 0 and wash_att_num >= 1 and falg == 1)
	end
end

-------------------------------- 技能Item
GeneralSkillRender = GeneralSkillRender or BaseClass(BaseCell)
function GeneralSkillRender:__init()
	self.name = self:FindVariable("Name")
	self.skill_icon = self:FindVariable("Head")
	self.show_hl = self:FindVariable("Show_Hl")
	self.is_active = self:FindVariable("IsActive")
end

function GeneralSkillRender:OnFlush()
	if not self.data or not next(self.data) then return end
	if self.data.skill_id then
		self:FlushRoleSkill()
	else
		self:FlushPassiveSkill()
	end
end

function GeneralSkillRender:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end

function GeneralSkillRender:SetParent(parent)
	self.parent = parent
end

function GeneralSkillRender:FlushHL()
	local cur_select = self.parent:GetSelectSkillIndex()
	self.show_hl:SetValue(cur_select == self.index)
end

function GeneralSkillRender:FlushRoleSkill()
	local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill[self.data.skill_id]
	if not skill_cfg or not next(skill_cfg) then return end
	self.name:SetValue(skill_cfg.skill_name)
	self.skill_icon:SetAsset(ResPath.GetFamousGeneral("Skill_" .. self.data.skill_id))
	local cur_select = self.parent:GetSelectSeq()
	self.is_active:SetValue(FamousGeneralData.Instance:CheckGeneralIsActive(cur_select - 1))
end

function GeneralSkillRender:FlushPassiveSkill()
	self.name:SetValue(self.data.skill_name or "")
	self.skill_icon:SetAsset(ResPath.GetFamousGeneral("Skill_" .. self.data.icon_id))
	local cur_select = self.parent:GetSelectSeq()
	if self.index == 0 then				-- 变身技
		self.is_active:SetValue(FamousGeneralData.Instance:CheckGeneralIsActive(cur_select - 1))
	else
		self.is_active:SetValue(FamousGeneralData.Instance:CheckSpecialSkillIsActive(self.data.active_skill_type))
	end
end

---------------------------------组合Item 
ComboItemRender = ComboItemRender or BaseClass(BaseCell)
function ComboItemRender:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("IsSelect")
	self.name_icon = self:FindVariable("NameIcon")
end

function ComboItemRender:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", handler)
end

function ComboItemRender:SetParent(parent)
	self.parent = parent
end

function ComboItemRender:OnFlush()
	if not self.data then return end
	local bundle, asset = ResPath.GetFamousGeneral("combo_" .. self.index - 1)
	self.icon:SetAsset(bundle, asset)
	self.name:SetValue(self.data.zuhe_name)
	local name_bundel, name_asset = ResPath.GetFamousGeneral("name_" .. self.index - 1)
	self.name_icon:SetAsset(name_bundel, name_asset)
end

function ComboItemRender:FlushHL()
	local cur_select = self.parent:GetSelectSeq()
	self.show_hl:SetValue(cur_select == (self.index - 1))
end

---------------------------组合display
GeneralDisplayRender = GeneralDisplayRender or BaseClass(BaseCell)
function GeneralDisplayRender:__init()
	self.name = self:FindVariable("name")
	self.show_display = self:FindVariable("ShowDisplay")

	self.display = self:FindObj("Display")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)
end

function GeneralDisplayRender:__delete()
	self.model:DeleteMe()
	self.model = nil
end

function GeneralDisplayRender:OnFlush()
	local cur_cfg = FamousGeneralData.Instance:GetSingleDataBySeq(tonumber(self.data))
	if not cur_cfg or not next(cur_cfg) then return end
	self.show_display:SetValue(FamousGeneralData.Instance:CheckGeneralIsActive(tonumber(self.data)))
	self.name:SetValue(ToColorStr(cur_cfg.name, ITEM_COLOR[cur_cfg.color]))
	if FamousGeneralData.Instance:CheckGeneralIsActive(tonumber(self.data)) then 
		self.model:SetModelScale(Vector3(0.4, 0.4, 0.4))
		local bundle, asset = ResPath.GetMingJiangRes(cur_cfg.image_id)
		self.model:SetMainAsset(bundle, asset)
	end
end