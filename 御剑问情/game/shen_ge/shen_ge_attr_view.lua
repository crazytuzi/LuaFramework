ShenGeAttrView = ShenGeAttrView or BaseClass(BaseView)



function ShenGeAttrView:__init()
	self.ui_config = {"uis/views/shengeview_prefab", "ShenGeAttrView"}
	self.play_audio = true
	self.fight_info_view = true
end

function ShenGeAttrView:ReleaseCallBack()
	-- 清理变量
	self.total_attr_var_list = nil
	self.fight_power = nil
end

function ShenGeAttrView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self.fight_power = self:FindVariable("FightPower")
	self.total_attr_var_list = {}
	for i = 1, 10 do
		self.total_attr_var_list[i] = {text = self:FindVariable("Attr"..i), is_show = self:FindVariable("ShowAttr"..i),
										icon = self:FindVariable("Icon"..i)}
	end
end

function ShenGeAttrView:OpenCallBack()
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local attr_list, other_fight_power = ShenGeData.Instance:GetInlayAttrListAndOtherFightPower(cur_page)
	local value = 0
	local temp_value_str = ""
	for i, v in ipairs(self.total_attr_var_list) do
		value = attr_list[Language.ShenGe.AttrType[i - 1]] and attr_list[Language.ShenGe.AttrType[i - 1]] or 0
		v.is_show:SetValue(value ~= 0)
		if value ~= 0 then
			local color = "<color=#0000f1>%s</color>"
			if i == 9 or i == 10 then
				temp_value_str = string.format(color, (value / 100).."%")
				v.text:SetValue(Language.ShenGe.AttrTypeName[i - 1]..":"..temp_value_str)
			else
				temp_value_str = string.format(color, value)
				v.text:SetValue(Language.ShenGe.AttrTypeName[i - 1]..":"..temp_value_str)
			end
			v.icon:SetAsset(ResPath.GetBaseAttrIcon(Language.ShenGe.AttrType[i - 1]))
		end
	end

	local power = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.fight_power:SetValue(power + other_fight_power)
end

function ShenGeAttrView:CloseCallBack()
end

function ShenGeAttrView:OnClickClose()
	self:Close()
end