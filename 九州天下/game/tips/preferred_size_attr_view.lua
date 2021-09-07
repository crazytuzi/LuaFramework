PreferredSizeAttrView = PreferredSizeAttrView or BaseClass(BaseView)

function PreferredSizeAttrView:__init()
	self.ui_config = {"uis/views/tips/attrtips", "PreferredSizeAttrView"}
	self.play_audio = true
	self.fight_info_view = true
	self.normal_attr_cfg = {}
	self.special_attr_list = {}
	self.special_fight_power = 0
	self:SetMaskBg()
end

function PreferredSizeAttrView:ReleaseCallBack()
	-- 清理变量
	self.total_attr_var_list = nil
	self.fight_power = nil
end

function PreferredSizeAttrView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self.fight_power = self:FindVariable("FightPower")
	self.total_attr_var_list = {}
	for i = 1, 10 do
		self.total_attr_var_list[i] = {
			text = self:FindVariable("Attr"..i),
			is_show = self:FindVariable("ShowAttr"..i),
			icon = self:FindVariable("Icon"..i)
		}
	end
end

function PreferredSizeAttrView:OpenCallBack()
	self:ResetAttrVar()
	self:SetAttrInfo()
end

function PreferredSizeAttrView:CloseCallBack()
end

function PreferredSizeAttrView:OnClickClose()
	self:Close()
end

function PreferredSizeAttrView:SetAttrInfo()
	local attr_list = CommonDataManager.GetAttributteNoUnderline(self.normal_attr_cfg)
	local normal_count = 1
	local attr_var = nil
	local temp_value_str = ""

	for k, v in pairs(attr_list) do
		attr_var = self.total_attr_var_list[normal_count]
		if v > 0 and nil ~= attr_var then
			attr_var.is_show:SetValue(true)
			temp_value_str = string.format(Language.ShenGe.ShowGreenStr, v)
			attr_var.text:SetValue(Language.Common.AttrNameNoUnderline[k]..":"..temp_value_str)
			attr_var.icon:SetAsset(ResPath.GetBaseAttrIcon(k))

			normal_count = normal_count + 1
		end
	end

	for k, v in pairs(self.special_attr_list) do
		attr_var = self.total_attr_var_list[normal_count]
		if nil ~= attr_var and v.show then
			attr_var.is_show:SetValue(v.show)
			attr_var.text:SetValue(v.attr_des)
			attr_var.icon:SetAsset(v.bundle, v.asset)

			normal_count = normal_count + 1
		end
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.fight_power:SetValue(power + self.special_fight_power)
end

function PreferredSizeAttrView:SetNormalAttrCfg(normal_attr_cfg)
	self.normal_attr_cfg = normal_attr_cfg or {}
end

function PreferredSizeAttrView:SetSpecialAttrList(special_attr_list)
	self.special_attr_list = special_attr_list or {}
end

function PreferredSizeAttrView:SetSpecialAttrFightPower(special_fight_power)
	self.special_fight_power = special_fight_power or 0
end

function PreferredSizeAttrView:ResetAttrVar()
	for k, v in pairs(self.total_attr_var_list) do
		v.is_show:SetValue(false)
	end
end