JewelryContentView = JewelryContentView or BaseClass(BaseRender)

local MAX_LEVEL = 10	--每阶10级
function JewelryContentView:__init(instance)
	self.is_activation = false	--是否激活
	self.ring_index = 1
	self.toggles = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function JewelryContentView:__delete()
	if self.attr_t then
		for _,v in pairs(self.attr_t) do
			v:DeleteMe()
		end
		self.attr_t = {}
	end

	if self.attr_t_n then
		for _,v in pairs(self.attr_t_n) do
			v:DeleteMe()
		end
		self.attr_t_n = {}
	end
	
	if self.stuff_cell ~= nil then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function JewelryContentView:LoadCallBack(instance)
	-- self.cur_Level = self:FindVariable("Level1")
	-- self.next_Level = self:FindVariable("Level2")
	self.icon1 = self:FindVariable("Icon1Gray")
	self.icon2 = self:FindVariable("Icon2Gray")
	self.name1 = self:FindVariable("Name1")
	self.name2 = self:FindVariable("Name2")

	self.cur_attr = self:FindObj("AttrCur")
	self.next_attr = self:FindObj("AttrNext")
	self.attr_t = {}
	self.attr_t_n = {}
	for i = 1, 4 do
		local attr = self.cur_attr.transform:FindHard("Attr" .. i)
		if attr then
			table.insert(self.attr_t, JewelryAttrItem.New(attr))
		end
		attr = self.next_attr.transform:FindHard("Attr" .. i)
		if attr then
			table.insert(self.attr_t_n,  JewelryAttrItem.New(attr))
		end
	end
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("Stuff"))
	self.stuff_cost = self:FindVariable("CostStuff")
	self.cur_cap = self:FindVariable("CurPower")
	self.next_cap = self:FindVariable("NextPower")
	self.up_btn_txt = self:FindVariable("UpBtnTxt")
	self.up_btn_gray = self:FindVariable("UpBtnGray")
	self.skill = self:FindVariable("Skill")
	self.skill_text = self:FindVariable("SkillText")
	self.show_skill_tips = self:FindVariable("ShowSkillTips")
	self.skill_level = self:FindVariable("SkillLevel")
	self.skill_dose = self:FindVariable("SkillDose")
	self.skill_activate = self:FindVariable("SkillActivate")
	self.show_next_attr_panel = self:FindVariable("ShowNextAttrPanel")

	self.show_image = self:FindVariable("GouyuImage")

	for i = 1, 2 do
		self.toggles[i] = self:FindObj("ToggleRing" .. i)
		self.toggles[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, i))
	end

	self:ListenEvent("GoGet",BindTool.Bind(self.OnGotoGet, self))
	self:ListenEvent("UpGrade",BindTool.Bind(self.OnUpGrade, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("ClickSkill",BindTool.Bind(self.OnClickSkill, self))
	self:ListenEvent("CloseSkillTips",BindTool.Bind(self.CloseSkillTips, self))

	self.red_point_list = {
		[RemindName.JieZhi] = self:FindVariable("ShowJieZhiRed"),
		[RemindName.GuaZhui] = self:FindVariable("ShowGuaZhuiRed"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function JewelryContentView:OnToggleChange(index, isOn)
	if isOn then
		self.ring_index = index
		self:Flush()
	end
	
end

function JewelryContentView:ShowIndexCallBack(index)
	if self.toggles[index] then
		self.toggles[index].toggle.isOn = true
	end
	self:Flush()
end

function JewelryContentView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function JewelryContentView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "types" then
			if nil ~= v.types and self.toggles[v.types] then
				self.toggles[v.types].toggle.isOn = true
			end
		end
	end
	local level = MojieData.Instance:GetLevelInfo(self.ring_index)
	local max_cfg = MojieData.Instance:GetGuazhuiMaxCfg(self.ring_index)
	local next_level = level + 1
	local is_max_level = false					--是否是最大等级
	local is_one_activation = false				--是否已激活第一次
	if max_cfg and level >= max_cfg.c_level then
		is_max_level = true
		level = max_cfg.c_level
		next_level = max_cfg.c_level
	end
	if level > 0 then
		self.is_activation = true
	end

	local cfg = MojieData.Instance:GetGuazhuiLevelCfg(self.ring_index, level)
	local next_cfg = MojieData.Instance:GetGuazhuiLevelCfg(self.ring_index, next_level)
	if next_cfg then
		if cfg then
			local has_stuff = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			local stuff_format = "<color=#%s>%d</color><color=#503635> / %d</color>"
		    local stuff_color = has_stuff < cfg.stuff_num and "ff0000" or "503635"
			self.stuff_cost:SetValue(string.format(stuff_format, stuff_color, has_stuff, cfg.stuff_num))
			self.stuff_cell:SetData({item_id = cfg.stuff_id, num = 1, is_bind = 0})
		end
		local cur_attr = CommonDataManager.GetAttributteByClass(cfg)
		local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
		local index = 1
		for i,v in ipairs(MojieData.Attr) do
			if next_attr[v] ~= 0 then
				if self.attr_t[index] and Language.Common.AttrName[v] then
					local cur_attr_str = cur_attr[v]
					local next_attr_str = next_attr[v]
					if v == "per_xixue" or v == "per_stun" then
						cur_attr_str = MojieData.Instance:GetAttrRate(cur_attr[v])
						next_attr_str = MojieData.Instance:GetAttrRate(next_attr[v])
					end
					self.attr_t[index]:SetData(Language.Common.AttrName[v] .. "：<color=#503635>" .. (cur_attr_str or 0) .. "</color>")
					self.attr_t_n[index]:SetData(Language.Common.AttrName[v] .. "：<color=#503635>" .. (next_attr_str or 0) .. "</color>")
				end
				index = index + 1
			end
		end
		self.cur_cap:SetValue(CommonDataManager.GetCapabilityCalculation(cur_attr))
		self.next_cap:SetValue(CommonDataManager.GetCapabilityCalculation(next_attr))
		self.up_btn_gray:SetValue(not is_max_level)
		self.up_btn_txt:SetValue(is_max_level and Language.Common.MaxLv or (self.is_activation and Language.Common.Up or Language.Common.Activate))		

		
		self.skill_level:SetValue(cfg.skill_level)
		self.skill_activate:SetValue(cfg.skill_level <= 0 and Language.Mojie.MojieNOActivate or Language.Mojie.MojieActivate)
		local skill_cfg = SkillData.GetSkillinfoConfig(cfg.skill_id)
		if skill_cfg then
			self.skill_text:SetValue(skill_cfg.skill_desc)
			self.skill_dose:SetValue(skill_cfg.skill_desc)
			self.skill:SetAsset(ResPath.GetRoleSkillIcon(skill_cfg.skill_icon))
		end
	end
	self:FlushTogglesData()
end

function JewelryContentView:FlushTogglesData()
	local jiezhi_level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
	local guazhui_level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI)
	local jiezhi_max_cfg = MojieData.Instance:GetGuazhuiMaxCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE)
	local guazhui_max_cfg = MojieData.Instance:GetGuazhuiMaxCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI) 

	local jiezhi_cfg = MojieData.Instance:GetGuazhuiLevelCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_ZHIJIE, jiezhi_level)
	local guazhui_cfg = MojieData.Instance:GetGuazhuiLevelCfg(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GUAZHUI, guazhui_level)
	if jiezhi_cfg and guazhui_cfg then
		self.name1:SetValue(string.format(Language.Mojie.GouyuCurAttr, jiezhi_cfg.name, jiezhi_level))
		self.name2:SetValue(string.format(Language.Mojie.GouyuCurAttr, guazhui_cfg.name, guazhui_level))
	end
	-- self.icon1:SetValue(jiezhi_level > 0)
	-- self.icon2:SetValue(guazhui_level > 0)
	self.icon1:SetValue(true)
	self.icon2:SetValue(true)
end

function JewelryContentView:CloseSkillTips()
	self.show_skill_tips:SetValue(false)
end

function JewelryContentView:OnClickSkill()
	self.show_skill_tips:SetValue(true)
end

function JewelryContentView:OnGotoGet()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
end

function JewelryContentView:OnUpGrade()
	MojieCtrl.Instance:SendGouyuUplevelReq(self.ring_index)
end

function JewelryContentView:OnClickHelp()
	local tip_id = 192
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

JewelryAttrItem = JewelryAttrItem or BaseClass(BaseCell)

function JewelryAttrItem:__init(instance, mother_view)
	self.attr_value = self:FindVariable("AttrValue")
	self.is_show = self:FindVariable("IsShow")
end

function JewelryAttrItem:__delete()

end

function JewelryAttrItem:OnFlush()
	if self.data == nil then return end
	self.attr_value:SetValue(self.data)
	if self.index > 1 then
		self.is_show:SetValue(false)
	end
end