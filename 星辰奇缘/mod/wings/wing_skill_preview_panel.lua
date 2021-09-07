-- @author 黄耀聪
-- @date 2016年6月2日

WingSkillPreviewPanel = WingSkillPreviewPanel or BaseClass(BasePanel)

function WingSkillPreviewPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "WingSkillPreviewPanel"
    self.mgr = WingsManager.Instance

    self.resList = {
        {file = AssetConfig.wing_skill_preview, type = AssetType.Main},
        {file = AssetConfig.wing_textures, type = AssetType.Dep},
    }

    self.titleString = TI18N("技能预览")
    self.gradeString = TI18N("%s阶翅膀")
    self.typeDescString = TI18N("技能类型:%s")
    self.typeString = {TI18N("战斗特技"), TI18N("被动加成")}
    self.depleteString = TI18N("怒气消耗:<color=#FFFF00>%s</color>")
    self.nothingString = TI18N("无")
    self.noticeString = TI18N("翅膀特技可在<color=#00FF00>被嘲讽、封印</color>状态下使用")

    self.tabList = {}
    self.skillList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingSkillPreviewPanel:__delete()
    self.OnHideEvent:Fire()

    for i, v in ipairs(self.skillList) do
        v.imageLoader:DeleteMe()
        v = nil
    end
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.gridLayout ~= nil then
        self.gridLayout:DeleteMe()
        self.gridLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WingSkillPreviewPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_skill_preview))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = t

    local main = t:Find("Main")

    self.tabContainer = main:Find("TabArea/TabGroup")
    self.tabCloner = main:Find("TabArea/Button").gameObject

    self.skillListContainer = main:Find("SkillList/ScrollLayer/Container")
    self.skillListContainerRect = self.skillListContainer:GetComponent(RectTransform)
    self.skillCloner = main:Find("SkillList/ScrollLayer/Icon").gameObject
    self.downObj = main:Find("SkillList/Down").gameObject

    local detail = main:Find("Detail")
    self.nameText = detail:Find("Title/Text"):GetComponent(Text)
    self.iconImage = detail:Find("Icon/Image"):GetComponent(Image)
    self.iconLoader = SingleIconLoader.New(self.iconImage.gameObject)
    self.descText = detail:Find("Desc"):GetComponent(Text)
    self.skillTypeText = detail:Find("SkillType"):GetComponent(Text)
    self.depleteText = detail:Find("Deplete"):GetComponent(Text)

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    main:Find("Title/Text"):GetComponent(Text).text = self.titleString

    self.noticeText = detail:Find("Notice/Text"):GetComponent(Text)
    self.noticeText.text = self.noticeString

    self:InitTabGroup()
end

function WingSkillPreviewPanel:OnClose()
    self.mgr:CloseSkillPreview()
end

function WingSkillPreviewPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingSkillPreviewPanel:OnOpen()
    self:RemoveListeners()

    local beginIndex = self.mgr.grade - self.minGrade + 1
    if beginIndex > 0 then
        for i=beginIndex,1,-1 do
            if self.tabGroup.openLevel[i] == 0 then
                self.tabGroup:ChangeTab(i)
                break
            end
        end
    else
        self.tabGroup:ChangeTab(1)
    end
end

function WingSkillPreviewPanel:OnHide()
    self:RemoveListeners()
end

function WingSkillPreviewPanel:RemoveListeners()
end

function WingSkillPreviewPanel:InitTabGroup()
    self.minGrade = 8
    for i=1,self.mgr.top_grade do
        if #self.mgr:GetSkillList(i) > 0 then
            self.minGrade = i
            break
        end
    end

    for i=1,self.mgr.top_grade - self.minGrade + 1 do
        if self.tabList[i] == nil then
            local tab = {}
            tab.obj = GameObject.Instantiate(self.tabCloner)
            tab.obj.name = tostring(i)
            tab.transform = tab.obj.transform
            tab.transform:SetParent(self.tabContainer)
            tab.transform.localScale = Vector3.one
            tab.transform.localPosition = Vector3.zero
            tab.normalText = tab.transform:Find("Normal/Text"):GetComponent(Text)
            tab.selectText = tab.transform:Find("Select/Text"):GetComponent(Text)
            self.tabList[i] = tab
        end
        local tab = self.tabList[i]
        tab.normalText.text = string.format(self.gradeString, BaseUtils.NumToChn(i + self.minGrade - 1))
        tab.selectText.text = string.format(self.gradeString, BaseUtils.NumToChn(i + self.minGrade - 1))
        tab.obj:SetActive(true)
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
    end
    local openLevel = {}
    for i=1, self.mgr.top_grade -self.minGrade + 1 do
        if #self.mgr:GetSkillList(i + self.minGrade - 1) > 0 then
            openLevel[i] = 0
        else
            openLevel[i] = 255
        end
    end
    local tabSetting = {
        notAutoSelect = true,
        perWidth = 117,
        perHeight = 44,
        isVertical = false,
        spacing = 5,
        openLevel = openLevel,
    }
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, tabSetting)
    self.tabGroup:Layout()

    self.tabCloner:SetActive(false)
end

function WingSkillPreviewPanel:ChangeTab(index)
    self:UpdateList(index + self.minGrade - 1)
end

function WingSkillPreviewPanel:UpdateList(grade)
    local skills = self.mgr:GetSkillList(grade)
    local gridSetting = {
        column = 3,
        bordertop = 12,
        borderleft = 8,
        cspacing = 1,
        rspacing = 3,
        cellSizeX = 70,
        cellSizeY = 95,
    }

    if self.gridLayout == nil then
        self.gridLayout = LuaGridLayout.New(self.skillListContainer, gridSetting)
    end
    for i,v in ipairs(skills) do
        if self.skillList[i] == nil then
            local tab = {}
            tab.obj = GameObject.Instantiate(self.skillCloner)
            tab.obj.name = tostring(i)
            self.gridLayout:AddCell(tab.obj)
            tab.transform = tab.obj.transform
            tab.image = tab.transform:Find("Image"):GetComponent(Image)
            tab.imageLoader = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
            tab.select = tab.transform:Find("Select").gameObject
            tab.kuang = tab.transform:Find("Kuang").gameObject
            tab.kuang.transform.sizeDelta = Vector2(72, 72)
            tab.kuang.gameObject:SetActive(true)
            tab.base_id = nil
            tab.btn = tab.image.gameObject:GetComponent(Button)
            tab.tag = tab.transform:Find("Tag").gameObject
            tab.name = tab.transform:Find("Name"):GetComponent(Text)
            self.skillList[i] = tab
            tab.btn.onClick:AddListener(function()
                if self.selectTab ~= nil then
                    self.selectTab.select:SetActive(false)
                end
                self.selectTab = self.skillList[i]
                self:ShowDetail()
            end)
        end
        local tab = self.skillList[i]
        tab.obj:SetActive(true)
        tab.base_id = v
        -- tab.image.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(DataSkill.data_wing_skill[v.."_1"].icon))
        tab.imageLoader:SetSprite(SingleIconType.SkillIcon, tostring(DataSkill.data_wing_skill[v.."_1"].icon))

        local skillData = DataSkill.data_wing_skill[v.."_1"]
        if DataWing.data_skill_energy[v] ~= nil then
            tab.kuang.gameObject:SetActive(true)
        else
            tab.kuang.gameObject:SetActive(false)
        end
        tab.tag:SetActive(skillData.cost_anger > 0)
        tab.name.text = BaseUtils.string_cut_utf8(skillData.name, 4, 3)
        tab.image.gameObject:SetActive(true)
        tab.select:SetActive(false)
    end
    for i=#skills + 1,#self.skillList do
        self.skillList[i].obj:SetActive(false)
    end
    self.skillCloner:SetActive(false)

    if self.selectTab ~= nil then
        self.selectTab.select:SetActive(false)
    end
    self.selectTab = self.skillList[1]

    self:ShowDetail()

    self.downObj:SetActive(#skills > 15)
    -- self.skillListContainerRect.anchorMax = Vector2(0.5, 1)
    -- self.skillListContainerRect.anchorMin = Vector2(0.5, 1)
    local row = math.ceil(#skills / 3)
    self.skillListContainerRect.sizeDelta = Vector2(gridSetting.cellSizeX * 3 + gridSetting.cspacing + gridSetting.borderleft * 2, row * gridSetting.cellSizeY + (row - 1) * gridSetting.rspacing + gridSetting.bordertop)
    self.skillListContainerRect.anchoredPosition = Vector2(0, -5)
end

function WingSkillPreviewPanel:ShowDetail()
    local base_id = nil
    if self.selectTab ~= nil then
        self.selectTab.select:SetActive(true)
        base_id = self.selectTab.base_id
    end

    if base_id == nil then
        self.nameText.text = ""
        self.iconImage.gameObject:SetActive(false)
        self.descText.text = ""
        self.depleteText.text = ""
        self.skillTypeText.text = ""
    else
        local skillData = DataSkill.data_wing_skill[base_id.."_1"]
        self.iconImage.gameObject:SetActive(true)
        -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(skillData.icon))
        self.iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(skillData.icon))

        self.nameText.text = skillData.name
        self.descText.text = skillData.desc

        if skillData.cost_anger > 0 then
            self.depleteText.text = string.format(self.depleteString, tostring(skillData.cost_anger))
            self.skillTypeText.text = string.format(self.typeDescString, self.typeString[1])
        else
            self.depleteText.text = string.format(self.depleteString, self.nothingString)
            self.skillTypeText.text = string.format(self.typeDescString, self.typeString[2])
        end
    end
end
