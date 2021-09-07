MojieContentView = MojieContentView or BaseClass(BaseRender)

local PASSIVE_TYPE = 73

function MojieContentView:__init(instance)
	self.ring_index = 1
	self.skill_id = 0
	self.skill_level = 0
	self.toggles = {}
	self.mojie_gray_t = {}
	self.level_t = {}
	self.red_point_list = {}
end

function MojieContentView:__delete()
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
end

function MojieContentView:LoadCallBack(instance)
	for i = 1, 4 do
		self.toggles[i] = self:FindObj("ToggleRing" .. i)
		self.toggles[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, i))
		self.level_t[i] = self:FindVariable("Level" .. i)
		self.mojie_gray_t[i] = self:FindVariable("Mojie" .. i .."Gray")
		self.red_point_list[i] = self:FindVariable("ShowRedPoint"..i)
	end
	self.cur_attr = self:FindObj("AttrCur")
	self.next_attr = self:FindObj("AttrNext")
	self.attr_t = {}
	self.attr_t_n = {}
	for i = 1, 3 do
		local attr = self.cur_attr.transform:FindHard("Attr" .. i)
		if attr then
			table.insert(self.attr_t, MojieAttrItem.New(attr))
		end
		attr = self.next_attr.transform:FindHard("Attr" .. i)
		if attr then
			table.insert(self.attr_t_n,  MojieAttrItem.New(attr))
		end
	end
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("Stuff"))

	self.stuff_cost = self:FindVariable("CostStuff")
	self.skill = self:FindVariable("Skill")
	self.skill_txt = self:FindVariable("SkillTxt")
	self.cur_cap = self:FindVariable("CurPower")
	self.next_cap = self:FindVariable("NextPower")
	self.up_btn_txt = self:FindVariable("UpBtnTxt")
	self.skill_gray = self:FindVariable("SkillGray")
	self.up_btn_gray = self:FindVariable("UpBtnGray")
	self.show_stuff_panel = self:FindVariable("ShowStuffPanel")
	self.show_next_attr_panel = self:FindVariable("ShowNextAttrPanel")
	self.skill_type = self:FindVariable("SkillType")
	self.show_skill_tips = self:FindVariable("ShowSkillTips")
	self.skill_level = self:FindVariable("SkillLevel")
	self.skill_dose = self:FindVariable("SkillDose")
	self.skill_activate = self:FindVariable("SkillActivate")

	self:ListenEvent("GoGet",BindTool.Bind(self.OnGotoGet, self))
	self:ListenEvent("UpGrade",BindTool.Bind(self.OnUpGrade, self))
	self:ListenEvent("ClickSkill",BindTool.Bind(self.OnClickSkill, self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("CloseSkillTips",BindTool.Bind(self.CloseSkillTips, self))
	self:Flush()
end

function MojieContentView:ReleaseCallBack()
	self.ring_index = 1
end

function MojieContentView:ResetIndex()
	self.ring_index = 1
end

function MojieContentView:CloseCallBack()

end

function MojieContentView:OnToggleChange(index)
	self.ring_index = index
	self:Flush()
end

function MojieContentView:ShowIndexCallBack(index)
	if self.toggles[index] then
		self.toggles[index].toggle.isOn = true
	end
	self:Flush()
end

function MojieContentView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "types" then
			if nil ~= v.types and self.toggles[v.types] then
				self.toggles[v.types].toggle.isOn = true
			end
		else
			if self.toggles[self.ring_index] then
				self.toggles[self.ring_index].toggle.isOn = true
			end
		end
	end

	local ring_level, skill_level = MojieData.Instance:GetMojieLevel(self.ring_index - 1)
	local ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level)
	self.skill_level:SetValue(skill_level)
	if nil == ring_cfg then
		return
	end
	local ring_attr = CommonDataManager.GetAttributteByClass(ring_cfg)
	local n_ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level + 1)
	local n_ring_attr = CommonDataManager.GetAttributteByClass(n_ring_cfg or ring_cfg)
	local index = 1
    for i,v in ipairs(MojieData.Attr) do
    	if n_ring_attr[v] ~= 0 then
	    	if self.attr_t[index] and Language.Common.AttrName[v] then
				self.attr_t[index]:SetData(Language.Common.AttrName[v] .. "：<color=#503635>" .. (ring_attr[v] or 0) .. "</color>")
				self.attr_t_n[index]:SetData(Language.Common.AttrName[v] .. "：<color=#503635>" .. (n_ring_attr[v] or 0) .. "</color>")
			end
			index = index + 1
    	end
    end
    self.cur_cap:SetValue(CommonDataManager.GetCapabilityCalculation(ring_attr))
    self.next_cap:SetValue(CommonDataManager.GetCapabilityCalculation(n_ring_attr))
    if n_ring_cfg then
	    local has_stuff = ItemData.Instance:GetItemNumInBagById(ring_cfg.up_level_stuff_id)
	    local stuff_format = "<color=#%s>%d</color><color=#503635> / %d</color>"
	    local stuff_color = has_stuff < ring_cfg.up_level_stuff_num and "ff0000" or "503635"
	    self.stuff_cost:SetValue(string.format(stuff_format, stuff_color, has_stuff, ring_cfg.up_level_stuff_num))
		self.stuff_cell:SetData({item_id = ring_cfg.up_level_stuff_id, num = 1, is_bind = 0})
	end
	self.show_stuff_panel:SetValue(n_ring_cfg ~= nil)
	self.show_next_attr_panel:SetValue(n_ring_cfg ~= nil)

	local has_skill_mjlevel, has_skill_slevel, skill_id, mojie_name =  MojieData.Instance:GetMojieOpenLevel(self.ring_index - 1)
	self.skill:SetAsset(ResPath.GetPlayerImage("mojie_skill_" .. skill_id))
	if skill_level < has_skill_slevel then
		self.skill_txt:SetValue(string.format(Language.Mojie.MojieSkillOpen, mojie_name, "#ff0000",  has_skill_mjlevel))
	else
		self.skill_txt:SetValue(Language.Mojie.MojieSkillOpen2)
	end
	self.up_btn_txt:SetValue(n_ring_cfg == nil and Language.Common.MaxLv or (ring_level > 0 and Language.Common.Up or Language.Common.Activate))
	self.skill_gray:SetValue(skill_level > 0)
	self.up_btn_gray:SetValue(n_ring_cfg ~= nil)
	for i = 1, 4 do
		self.level_t[i]:SetValue(MojieData.Instance:GetMojieLevel(i - 1) or 0)
		-- self.mojie_gray_t[i]:SetValue(MojieData.Instance:GetMojieLevel(i - 1) > 0)
		self.mojie_gray_t[i]:SetValue(true)
		self.red_point_list[i]:SetValue(MojieData.Instance:IsShowMojieRedPoint(i - 1))
	end

	local skill_cfg = MojieData.Instance:GetMojieSkillCfg(skill_id, skill_level > 0 and skill_level or 1)
	if skill_cfg then
		self.skill_type:SetValue(skill_cfg.skill_name)
		self.skill_dose:SetValue(skill_cfg.description)
		self.skill_activate:SetValue(skill_level < has_skill_slevel and Language.Mojie.MojieNOActivate or Language.Mojie.MojieActivate)
	end
end

function MojieContentView:OnGotoGet()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
end

function MojieContentView:OnUpGrade()
	MojieCtrl.SendMojieUplevelReq(self.ring_index - 1)
end

function MojieContentView:OnClickSkill()
	self.show_skill_tips:SetValue(true)
end

function MojieContentView:CloseSkillTips()
	self.show_skill_tips:SetValue(false)
end

function MojieContentView:OnClickHelp()
	local tip_id = 5
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
	-- TipsCtrl.Instance:ShowHelpTipView(Language.Mojie.MojieDetial)
end

MojieAttrItem = MojieAttrItem or BaseClass(BaseCell)

function MojieAttrItem:__init(instance, mother_view)
	self.attr_value = self:FindVariable("AttrValue")
	self.is_show = self:FindVariable("IsShow")
end

function MojieAttrItem:__delete()

end

function MojieAttrItem:OnFlush()
	if self.data == nil then return end
	self.attr_value:SetValue(self.data)
	if self.index > 1 then
		self.is_show:SetValue(false)
	end
end