-- ------------------------------
-- 孩子选择职业界面
-- hosr
-- ------------------------------
ChildrenChooseClassesPanel = ChildrenChooseClassesPanel or BaseClass(BasePanel)

function ChildrenChooseClassesPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.child_choose_classes, type = AssetType.Main}
		,{file = AssetConfig.classesnamei18n, type = AssetType.Dep}
	}

	self.btnList = {}
	self.skillList = {}
	self.arrowList = {}
	self.currIndex = 0
	self.classes = 0
	self.currList = {}
	self.currSkillIndex = 0

	self.list = {
		[ChildrenEumn.ClassesType.Phy] = {1,3},
		[ChildrenEumn.ClassesType.Mag] = {2,6},
		[ChildrenEumn.ClassesType.Aid] = {4,5},
	}

	self.OnOpenEvent:Add(function() self:OnShow() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
end

function ChildrenChooseClassesPanel:__delete()
	for i,v in ipairs(self.skillList) do
		v:DeleteMe()
	end
	self.skillList = nil

	for i,v in ipairs(self.btnList) do
		v:DeleteMe()
	end
	self.btnList = nil
end

function ChildrenChooseClassesPanel:Close()
	self.model:CloseChooseClasses()
end

function ChildrenChooseClassesPanel:OnShow()
	self.child = ChildrenManager.Instance:GetChildhood()
	self:Update()
end

function ChildrenChooseClassesPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.child_choose_classes))
	self.gameObject.name = "ChildrenChangeTypePanel"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
	self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

	self.desc = self.transform:Find("Main/Bg/Desc"):GetComponent(Text)
	local btn = self.transform:Find("Main/ChangeBtn")
	btn:GetComponent(Button).onClick:AddListener(function() self:OnChange() end)
	self.btntxt = btn:Find("Text"):GetComponent(Text)

	local skills = self.transform:Find("Main/Skills")
	for i = 1, 3 do
		local skill = skills:GetChild(i - 1)
        local slot = SkillSlot.New()
        UIUtils.AddUIChild(skill.gameObject, slot.gameObject)
        slot.noTips = true
        local index = i
        slot.click_self_call_back = function() self:ClickSkill(index) end
        table.insert(self.skillList, slot)
        local arrow = skill:Find("Arrow").gameObject
        arrow:SetActive(false)
        table.insert(self.arrowList, arrow)
	end

	for i = 1, 3 do
		local index = i
		local item = ChildChossesClassesItem.New(self.transform:Find("Main/Button" .. index).gameObject, self, index)
		table.insert(self.btnList, item)
	end

	self:OnShow()
end

function ChildrenChooseClassesPanel:OnChange()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("职业选择对孩子非常重要，确定后将<color='#ffff00'>无法更改</color>")
    data.sureLabel = string.format(TI18N("确定(%s)"), KvData.classes_name[self.classes])
    data.cancelLabel = TI18N("考虑一下")
    data.sureCallback = function() self:Sure() end
    NoticeManager.Instance:ConfirmTips(data)
end

function ChildrenChooseClassesPanel:ClickItem(index)
	if self.currIndex ~= 0 then
		self.btnList[self.currIndex]:Select(false)
	end
	self.currIndex = index
	self.classes = self.currList[self.currIndex]
	self.btntxt.text = string.format(TI18N("成为小%s"), KvData.classes_name[self.classes])
	self:UpdateRight()
end

function ChildrenChooseClassesPanel:Update()
	self.currList = self.list[self.child.classes_type]
	for i,v in ipairs(self.currList) do
		local btn = self.btnList[i]
		local index = i
		btn:SetData(v, index)
	end
	self.btnList[1]:ClickSelf()
end

function ChildrenChooseClassesPanel:UpdateRight()
	local base_id = ChildrenEumn.BaseId[string.format("%s_%s", self.classes, self.child.sex)]
	local baseData = DataChild.data_child[base_id]
	for i,slot in ipairs(self.skillList) do
		local skill_id = baseData.classes_skills[i][1]
		local skillData = DataSkill.data_child_skill[skill_id]
		slot:SetAll(Skilltype.roleskill, skillData, {classes = self.classes})
		slot:ShowLevel(false)
		slot.noTips = true
	end

	-- if self.currSkillIndex == 0 then
	self:ClickSkill(1)
	-- end
end

function ChildrenChooseClassesPanel:ClickSkill(index)
	if self.currSkillIndex ~= 0 then
		self.arrowList[self.currSkillIndex]:SetActive(false)
	end
	self.currSkillIndex = index
	self.arrowList[self.currSkillIndex]:SetActive(true)
	local skill = self.skillList[self.currSkillIndex].skillData
	self.desc.text = string.format("<color='%s'>%s</color>\n%s", ColorHelper.color[3], skill.name, skill.desc)
end

function ChildrenChooseClassesPanel:Sure()
    ChildrenManager.Instance:Require18621(self.child.child_id, self.child.platform, self.child.zone_id, self.classes)
	self:Close()
end