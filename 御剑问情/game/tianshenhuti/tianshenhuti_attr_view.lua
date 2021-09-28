TianshenhutiAttrView = TianshenhutiAttrView or BaseClass(BaseView)

function TianshenhutiAttrView:__init()
    self.ui_config = {"uis/views/tianshenhutiview_prefab", "TianshenhutiAttrView"}
   	self.play_audio = true
end

function TianshenhutiAttrView:__delete()

end

function TianshenhutiAttrView:CloseCallBack()

end

function TianshenhutiAttrView:ReleaseCallBack()
	self.scroller_rect = nil
	self.cap = nil
	self.base_attr_list = {}
	self.show_tz_t = {}
	self.skilldec_t = {}
	self.tz_name_t = {}
	self.tz_attr_list = {}
end

function TianshenhutiAttrView:LoadCallBack()
	self.scroller_rect = self:FindObj("Scroller")
	self.cap = self:FindVariable("Cap")
	local base_attrs = self:FindObj("BaseAttrs")
	self.base_attr_list = {}
	for i = 1, base_attrs.transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = base_attrs:FindObj("BaseAttr"..i)
	end

	self.show_tz_t = {}
	self.skilldec_t = {}
	self.tz_name_t = {}
	self.tz_attr_list = {}
	for i=1,2 do
		self.show_tz_t[i] = self:FindVariable("ShowTz" .. i)
		self.skilldec_t[i] = self:FindVariable("SkillDec" .. i)
		self.tz_name_t[i] = self:FindVariable("TzName" .. i)
		self.tz_attr_list[i] = {}
		local tz_attrs = self:FindObj("TzAttrs" .. i)
		for j = 1, tz_attrs.transform.childCount do
			self.tz_attr_list[i][#self.tz_attr_list[i] + 1] = tz_attrs:FindObj("TzAttr"..j)
		end
	end
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))
end

function TianshenhutiAttrView:OpenCallBack()
	self:Flush()
end

function TianshenhutiAttrView:OnFlush(param_list)
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	local tsht_data = TianshenhutiData.Instance
	self.cap:SetValue(tsht_data:GetProtectEquipTotalCapability())
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(tsht_data:GetProtectEquipTotalAttr(), true)
	local base_attr_count = 1
	local base_attr_name = CommonStruct.AttributeName()
	for k, v in ipairs(base_attr_name) do
		local value = base_attr_list[v] or 0
		if value > 0 and self.base_attr_list[base_attr_count] then
			local obj = U3DObject(self.base_attr_list[base_attr_count].gameObject)
			local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[v]..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
			base_attr_count = base_attr_count + 1
			local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[v])
			image_obj.image:LoadSprite(asset, name, function()
				image_obj.image:SetNativeSize()
			end)
		elseif self.base_attr_list[base_attr_count] then
			self.base_attr_list[base_attr_count].gameObject:SetActive(false)
		end
	end

	for i = base_attr_count, #self.base_attr_list do
		self.base_attr_list[i].gameObject:SetActive(false)
	end
	local tz_cfgs = tsht_data:GetCurAllTaozhuang()
	for index, note_list in pairs(self.tz_attr_list) do
		local cur_tz_cfg = tz_cfgs[index]
		self.show_tz_t[index]:SetValue(cur_tz_cfg ~= nil)
		if cur_tz_cfg then
			local one_tz_cfg = cur_tz_cfg and tsht_data:GetTzCfg(cur_tz_cfg.level_taozhuang_type, cur_tz_cfg.num) or {}
			self.tz_name_t[index]:SetValue(one_tz_cfg.taozhuang_effect_name or "")
			local all_attr, all_rate_injure = tsht_data:GetTzAllAttr(cur_tz_cfg.level_taozhuang_type, cur_tz_cfg.num)
			base_attr_list = CommonDataManager.GetAttributteNoUnderline(all_attr, true)
			base_attr_count = 1
			for k, v in ipairs(base_attr_name) do
				local value = base_attr_list[v] or 0
				if value > 0 and note_list[base_attr_count] then
					local obj = U3DObject(note_list[base_attr_count].gameObject)
					local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
					note_list[base_attr_count].gameObject:SetActive(true)
					note_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[v]..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
					base_attr_count = base_attr_count + 1
					local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[v])
					image_obj.image:LoadSprite(asset, name, function()
						image_obj.image:SetNativeSize()
					end)
				elseif note_list[base_attr_count] then
					note_list[base_attr_count].gameObject:SetActive(false)
				end
			end

			for i = base_attr_count, #note_list do
				note_list[i].gameObject:SetActive(false)
			end
			if one_tz_cfg.skill_num then
				local skill_cfg = tsht_data:GetSkillByIndex(one_tz_cfg.skill_num)
				if skill_cfg then
					self.skilldec_t[index]:SetValue(string.format(Language.Tianshenhuti.SkillDec, skill_cfg.skill_name, all_rate_injure/100 .. "%"))
				end
			end
		end
	end
end