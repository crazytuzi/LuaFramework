BeautySkill = BeautySkill or BaseClass(BaseRender)

function BeautySkill:__init(instance)
	self.types = 0
	self.index = 0

	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.show_open_level = self:FindVariable("ShowOpenLevel")
	self.show_skill = self:FindVariable("ShowSkill")
	self.open_level = self:FindVariable("OpenLevel")
	self.icon = self:FindVariable("Icon")
	self.show_lock = self:FindVariable("ShowLock")
	self.show_arrow = self:FindVariable("ShowArrow")

	self:ListenEvent("OnSkill", BindTool.Bind(self.OnSkillItem, self))
end

function BeautySkill:__delete()

end

function BeautySkill:OnFlush()
	if nil == self.data then return end
	local slot_info =  BeautyData.Instance:GetXianjieSlotCfg(self.index - 1)
	local skill_cfg = BeautyData.Instance:GetBeautyXinjiSkillCfg(self.data.seq)
	if skill_cfg then
		self.name:SetValue(skill_cfg.name)
	end
	self.icon:SetAsset(ResPath.GetItemIcon(skill_cfg.kill_icon))
	self.open_level:SetValue(slot_info.active_need_level)
	self.level:SetValue(self.data.level)
	self.show_open_level:SetValue(GameVoManager.Instance:GetMainRoleVo().level < slot_info.active_need_level)
	self.show_skill:SetValue(self.data.level > 0)
	self.show_lock:SetValue(self.data.is_lock == 1)

	local skill_data = BeautyData.Instance:GetXinjiTypeInfo(self.types)
	local skill = skill_data.skill_list[self.index]
	local skill_info_cfg = BeautyData.Instance:GetCurLevelXinjiSkillCfg(skill.seq, skill.level)
	if skill_info_cfg then
		self.show_arrow:SetValue(ItemData.Instance:GetItemNumInBagById(skill_info_cfg.item) > 1 and self.data.level > 0)
	end
end

function BeautySkill:SetData(types, data)
	if nil == data then return end
	self.types = types
	self.data = data
	self:Flush()
end

function BeautySkill:SetIndex(index)
	self.index = index
end

function BeautySkill:OnSkillItem()
	if nil == self.data then return end
	BeautyCtrl.Instance:ShowSkliiUplevel(self.types, self.index)
end