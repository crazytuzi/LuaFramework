RoleSuitView = RoleSuitView or BaseClass(XuiBaseView)



function RoleSuitView:__init()
	self.texture_path_list[1] = 'res/xui/role.png'
	self.texture_path_list[2] = 'res/xui/equipment.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 17, {0}},
	}
	self:SetIsAnyClickClose(true)
end

function RoleSuitView:__delete()	
end

function RoleSuitView:ReleaseCallBack()

end

function RoleSuitView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
	end
end

function RoleSuitView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RoleSuitView:ShowIndexCallBack(index)
	self:Flush(index)
end

function RoleSuitView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RoleSuitView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "myself" then
			local num = v.index
			local circle = v.circle
			local prof = v.prof
			local data = v.my_data
			self:FlushContent(num, circle, prof, data)
		elseif k == "other" then
			local num = v.index
			local circle = v.circle
			local prof = v.prof
			local data = v.other_data
			self:FlushContent(num, circle, prof, data)
		end
	end
end

function RoleSuitView:FlushContent(num, circle, prof, data)
	local cur_txt = ""
	local next_txt = ""
	local n = 0
	if num >= 3 and num <= 5 then
		n = 3
	elseif  num >= 6 and num <= 8 then
		n = 6
	elseif num >= 9 and num <= 10 then
		n = 9
	else
		n = 0
	end
	local w = 560
	local width = HandleRenderUnit:GetWidth()
	if n == 0 then
		cur_txt = ""
		local txt = {}
		for i = 1, 3 do
			local suit_level = (circle[i*3] == 0 and 0 or circle[i*3]) + 1
			local title_2 = string.format(Language.Role.TiTle_2, data[suit_level] or 0, 3*i)
			txt[i] = string.format(Language.Role.TiTle[i],  "ff0000", Language.Role.Suit_Text[suit_level], title_2 ).."\n"
			local attr = RoleData.Instance:GetGodZhuEquip(3*i, 1)
			local attr_t =  RoleData.Instance:GetGodZhuEquipAttr(attr, prof) or {}
			local value_t = RoleData.FormatRoleAttrStr(attr_t, is_range, nil, prof)
			local value = ""
			for k=1,#value_t do
				value = value.. "  " .. (value_t[k].type_str .. " + ".. value_t[k].value_str).."\n"
			end
			txt[i] = txt[i] ..value
		end
		next_txt = txt[1]..txt[2]..txt[3]
		RichTextUtil.ParseRichText(self.node_t_list.rich_cur_proprty.node, cur_txt)
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_propety.node, next_txt)
		-- h = 250
		-- self.node_t_list.layout_next_desc.node:setVisible(true)
		self.node_t_list.layout_cur_desc.img_cur_proprty.node:setVisible(true)
		self.node_t_list.layout_next_desc.img_next_propety.node:setVisible(false)
		-- self.node_t_list.layout_next_desc.node:setPositionY(h/2+h)
		-- self.node_t_list.btn_close_window.node:setPositionX(w/2 +w)
		-- self.node_t_list.img_point_bg.node:setVisible(false)
	else
		local txt = {}
		for i = 1, 3 do
			local suit_level = (circle[i*3] or 0) + 1
			if data[suit_level] == nil  then
				txt[i] = ""
			else
				local title_2 = string.format(Language.Role.TiTle_2, data[suit_level] or 0, 3*i)
				txt[i] = string.format(Language.Role.TiTle[i],  "ff0000", Language.Role.Suit_Text[suit_level], title_2 ).."\n"
				local attr = RoleData.Instance:GetGodZhuEquip(3*i, suit_level)
				local attr_t =  RoleData.Instance:GetGodZhuEquipAttr(attr, prof) or {}
				local value_t = RoleData.FormatRoleAttrStr(attr_t, is_range, nil, prof)
				local value = ""
				for k=1,#value_t do
					value = value.."  " .. (value_t[k].type_str .. " + ".. value_t[k].value_str).."\n"
				end
				txt[i] = txt[i] ..value
			end
		end
		next_txt = string.format( "%s%s%s", txt[1] or "", txt[2] or "", txt[3] or "")
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_propety.node, next_txt)
		self.node_t_list.layout_cur_desc.img_cur_proprty.node:setVisible(false)	
		if next_txt == "" then
			-- h = 250
			self.node_t_list.layout_next_desc.img_next_propety.node:setVisible(true)
			-- self.node_t_list.layout_cur_desc.node:setVisible(true)
			-- self.node_t_list.layout_cur_desc.node:setPositionY(h/2+h)
			-- self.node_t_list.btn_close_window.node:setPositionX(w/2 +w)
			-- self.node_t_list.img_point_bg.node:setVisible(false)
		else
			self.node_t_list.layout_next_desc.img_next_propety.node:setVisible(false)
			-- h = 500
			-- self.node_t_list.layout_next_desc.node:setVisible(true)
			-- self.node_t_list.layout_cur_desc.node:setVisible(true)
			-- self.node_t_list.btn_close_window.node:setPositionX(w)
			-- self.node_t_list.layout_cur_desc.node:setPositionY(h/2+120)
			-- self.node_t_list.layout_next_desc.node:setPositionY(h/2-120)
			-- self.node_t_list.img_point_bg.node:setVisible(true)
		end
		local txt_1 = {}
		for k, v in pairs(circle) do
			local suit_level = circle[k] == 0 and 1 or circle[k]
			local title_2 = ""
			local color = "55ff00"
			if data[suit_level] < k then
				color = "ff0000"
				title_2 = string.format(Language.Role.TiTle_2, data[suit_level] or 0, k)
			end
			txt_1[k/3] = string.format(Language.Role.TiTle[k/3], color, Language.Role.Suit_Text[circle[k]] or Language.Role.Suit_Text[1], title_2) .. "\n"
			local attr = RoleData.Instance:GetGodZhuEquip(k, (circle[k] == 0 and 1 or circle[k]))
			local attr_t =  RoleData.Instance:GetGodZhuEquipAttr(attr, prof) or {}
			local value_t = RoleData.FormatRoleAttrStr(attr_t, is_range, nil, prof)
			local value = ""
			for k=1,#value_t do
				value = value.."  " .. (value_t[k].type_str .. " + ".. value_t[k].value_str).."\n"
			end
			txt_1[k/3] = txt_1[k/3] ..value
		end
		local cur_txt = string.format( "%s%s%s", txt_1[1] or "", txt_1[2] or "", txt_1[3] or "")
		RichTextUtil.ParseRichText(self.node_t_list.rich_cur_proprty.node, cur_txt)
	end
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_proprty.node,5)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_propety.node,5)
	-- self.node_t_list.img9_itemtips_bg.node:setContentWH(w, 362)
	-- self.node_t_list.img9_bg.node:setContentWH(w - 5, 325)
end