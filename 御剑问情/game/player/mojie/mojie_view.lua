MojieView = MojieView or BaseClass(BaseView)

local PASSIVE_TYPE = 73

function MojieView:__init()
	self.ui_config = {"uis/views/player_prefab","MojieView"}
	self.ring_index = 1
	self.skill_id = 0
	self.skill_level = 0
	self.toggles = {}
	self.level_t = {}
	self.mojie_gray_t = {}
end

function MojieView:__delete()

end

function MojieView:ReleaseCallBack()
	self.ring_index = 1
	if self.stuff_cell then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	-- 清理变量和对象
	self.toggles = nil
	self.level_t = nil
	self.mojie_gray_t = nil
	self.red_point_list = nil
	self.cur_attr = nil
	self.next_attr = nil
	self.stuff_cost = nil
	self.skill = nil
	self.skill_txt = nil
	self.cur_cap = nil
	self.next_cap = nil
	self.up_btn_txt = nil
	self.skill_gray = nil
	self.up_btn_gray = nil
	self.show_stuff_panel = nil
	self.show_next_attr_panel = nil
	self.skill_type = nil
	self.skill_effect = nil
end

function MojieView:LoadCallBack()
	self.toggles = {}
	self.level_t = {}
	self.mojie_gray_t = {}
	self.red_point_list = {}
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
	self.skill_effect = self:FindVariable("SkillEffect")

	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("GoGet",
		BindTool.Bind(self.OnGotoGet, self))
	self:ListenEvent("UpGrade",
		BindTool.Bind(self.OnUpGrade, self))
	self:ListenEvent("ClickSkill",
		BindTool.Bind(self.OnClickSkill, self))
	self:ListenEvent("ClickHelp",
		BindTool.Bind(self.OnClickHelp, self))

end

function MojieView:OnToggleChange(index)
	self.ring_index = index
	self:Flush()
end

function MojieView:ShowIndexCallBack(index)
	if self.toggles[index] then
		self.toggles[index].toggle.isOn = true
	end
	self:Flush()
end

function MojieView:OnFlush(param_list)
	local ring_level, skill_level = MojieData.Instance:GetMojieLevel(self.ring_index - 1)
	local ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level)
	if nil == ring_cfg then
		return
	end
	local ring_attr = CommonDataManager.GetAttributteByClass(ring_cfg)
	local n_ring_cfg = MojieData.Instance:GetMojieCfg(self.ring_index - 1, ring_level + 1)
	local n_ring_attr = CommonDataManager.GetAttributteByClass(n_ring_cfg or ring_cfg)

	local index = 1
    for i,v in ipairs(MojieData.Attr) do
        if self.attr_t[index] and Language.Common.AttrName[v] then
            self.attr_t[index]:SetData(Language.Common.AttrName[v] .. "：<color=#0000f1>" .. (ring_attr[v] or 0) .. "</color>")
            self.attr_t_n[index]:SetData(Language.Common.AttrName[v] .. "：<color=#0000f1>" .. (n_ring_attr[v] or 0) .. "</color>")
        end
        index = index + 1
    end
    self.cur_cap:SetValue(CommonDataManager.GetCapability(ring_attr))
    self.next_cap:SetValue(CommonDataManager.GetCapability(n_ring_attr, true, ring_attr))
    if n_ring_cfg then
	    local has_stuff = ItemData.Instance:GetItemNumInBagById(ring_cfg.up_level_stuff_id)
	    local stuff_format = "<color=#%s>%d</color><color=#001828> / %d</color>"
	    local stuff_color = has_stuff < ring_cfg.up_level_stuff_num and "fe3030" or "0000f1"
	    self.stuff_cost:SetValue(string.format(stuff_format, stuff_color, has_stuff, ring_cfg.up_level_stuff_num))
		self.stuff_cell:SetData({item_id = ring_cfg.up_level_stuff_id, num = 1, is_bind = 0})
	end
	self.show_stuff_panel:SetValue(n_ring_cfg ~= nil)
	self.show_next_attr_panel:SetValue(n_ring_cfg ~= nil)

	local has_skill_mjlevel, has_skill_slevel, skill_id, mojie_name =  MojieData.Instance:GetMojieOpenLevel(self.ring_index - 1)
	local skill_cfg = SkillData.GetSkillinfoConfig(skill_id)
	self.skill_id = skill_id
	self.skill_level = skill_level
	if nil ~= skill_cfg then
		self.skill:SetAsset(ResPath.GetRoleSkillIconTwo(skill_cfg.skill_icon))
	end
	if skill_level < has_skill_slevel then
		self.skill_txt:SetValue(string.format(Language.Mojie.MojieSkillOpen, mojie_name, "#0000f1",  has_skill_slevel))
	else
		self.skill_txt:SetValue(Language.Mojie.MojieSkillOpen2)
	end
	local level = self.skill_level == 0 and 1 or self.skill_level
	self.skill_effect:SetValue(SkillData.RepleCfgContent(self.skill_id, level))
	self.up_btn_txt:SetValue(n_ring_cfg == nil and Language.Common.MaxLv2 or (ring_level > 0 and Language.Common.Up or Language.Common.Activate))
	-- self.skill_gray:SetValue(skill_id > 0)
	self.skill_gray:SetValue(ring_level >= has_skill_slevel)
	self.up_btn_gray:SetValue(n_ring_cfg ~= nil)
	for i = 1, 4 do
		self.level_t[i]:SetValue(MojieData.Instance:GetMojieLevel(i - 1) or 0)
		self.mojie_gray_t[i]:SetValue(MojieData.Instance:GetMojieLevel(i - 1) > 0)
		self.red_point_list[i]:SetValue(MojieData.Instance:IsShowMojieRedPoint(i - 1))
	end

	local skill_type = skill_id ~= PASSIVE_TYPE and Language.Common.ZhuDongSkill or Language.Common.BeiDongSkill
	self.skill_type:SetValue(skill_type)
end

function MojieView:OnGotoGet()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.xianjie_boss)
end

function MojieView:OnUpGrade()
	FashionCtrl.SendMojieUplevelReq(self.ring_index - 1)
end

function MojieView:OnClickSkill()
	local level = self.skill_level == 0 and 1 or self.skill_level
	TipsCtrl.Instance:ShowSkillView(self.skill_id, level, self.skill_level > 0)
end

function MojieView:OnClickHelp()
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
end