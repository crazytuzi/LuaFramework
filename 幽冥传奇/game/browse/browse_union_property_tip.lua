BrowseUnionPropertyUnionViewSimple = BrowseUnionPropertyUnionViewSimple or BaseClass(XuiBaseView)

function BrowseUnionPropertyUnionViewSimple:__init()
	self:SetModal(true)
	self.config_tab = {
		{"itemtip_ui_cfg", 20, {0}},
	}
	self.cur_type = nil
end

function BrowseUnionPropertyUnionViewSimple:__delete()

end

function BrowseUnionPropertyUnionViewSimple:ReleaseCallBack()
	
end

function BrowseUnionPropertyUnionViewSimple:SetData(type)
	self.cur_type = type
	self:Flush(index)
end

function BrowseUnionPropertyUnionViewSimple:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		
	end
end

function BrowseUnionPropertyUnionViewSimple:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BrowseUnionPropertyUnionViewSimple:ShowIndexCallBack(index)
	self:Flush(index)
end

function BrowseUnionPropertyUnionViewSimple:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BrowseUnionPropertyUnionViewSimple:CreateRoleInfoWidget()
	
end

function BrowseUnionPropertyUnionViewSimple:OnFlush(param_list, index)
	--print("3333333333333", self.cur_type)
	if self.cur_type ~= nil then
		local lv = BrowseData.Instance:GetInfoUnionData(self.cur_type)
		local txt = ""
		local attr_content = ""
		local color = COLOR3B.RED
		if lv == 0 or lv == nil then
			txt = Language.Role.Not_Active
			attr_content = string.format("{wordcolor;ffaa00;%s}", Language.Common.ZanWu)
			color = COLOR3B.RED
		else
			txt = string.format(Language.Boss.UnionPlayerDesc[self.cur_type], lv)
			local propety_data = UnionPropertyData.Instance:GetProperty(self.cur_type, lv)
			local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			local attr = RoleData.Instance:GetGodZhuEquipAttr(propety_data, prof)
			attr_content = RoleData.FormatAttrContent(attr, {value_str_color = COLOR3B.GREEN})
			color = COLOR3B.GREEN
		end
		RichTextUtil.ParseRichText(self.node_t_list.txt_cue_level.node, txt, 20, color)
		RichTextUtil.ParseRichText(self.node_t_list.rich_property.node, attr_content, 20, COLOR3B.WHITE)
		XUI.RichTextSetCenter(self.node_t_list.txt_cue_level.node)
		XUI.RichTextSetCenter(self.node_t_list.rich_property.node)
	end
end