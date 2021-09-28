ShenShouSkillTip = ShenShouSkillTip or BaseClass(BaseView)

function ShenShouSkillTip:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","ShenShouSkillTip"}
	self.play_audio = true
end

function ShenShouSkillTip:__delete()

end

function ShenShouSkillTip:ReleaseCallBack()
	self.head_img = nil
	self.skill_name = nil
	self.type_des = nil
	self.skill_dec = nil
	self.data = nil
	self.index = 0
end

function ShenShouSkillTip:LoadCallBack()
	self.head_img = self:FindVariable("HeadImg")
	self.skill_name = self:FindVariable("skill_name")
	self.type_des = self:FindVariable("TypeDes")
	self.skill_dec = self:FindVariable("skilldec")
	self:ListenEvent("OnClickToClose",
		BindTool.Bind(self.OnClickToClose, self))
end

function ShenShouSkillTip:ShowIndexCallBack()
	self:Flush()
end

function ShenShouSkillTip:SetData(index, cell)
	self.index = index
	self.data = cell.data
	self:Flush()
end

function ShenShouSkillTip:OnFlush()
	local skill_cfg = ShenShouData.Instance:GetShenShouSkillCfg(self.data.skill_type, self.data.level)
	if nil == skill_cfg then return end
	self.head_img:SetAsset(ResPath.GetShenShouSkillIcon(skill_cfg.icon_id))
	self.skill_name:SetValue(skill_cfg.name)
	self.type_des:SetValue(skill_cfg.buff)

	local loop = 1
	local value_list = {}
	if skill_cfg then
		for i=1, 7 do
			if skill_cfg["param_" .. i] ~= "" then
				value_list[loop] = skill_cfg["param_" .. i] >= 100 and skill_cfg["param_" .. i] / 100 or skill_cfg["param_" .. i]
				loop = loop + 1
			end
		end
	end

	local desc = string.format(skill_cfg.description, value_list[1], value_list[2], value_list[3], value_list[4], value_list[5], value_list[6], value_list[7])
	self.skill_dec:SetValue(desc)
end

function ShenShouSkillTip:OnClickToClose()
	self:Close()
end