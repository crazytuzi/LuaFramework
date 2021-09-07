-- @author hzf
-- @date 2016年8月17日
-- @坐骑技能预览

RideSkillPreviewPanel = RideSkillPreviewPanel or BaseClass(BasePanel)

function RideSkillPreviewPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RideSkillPreviewPanel"
    self.mgr = RideManager.Instance

    self.resList = {
        {file = AssetConfig.ride_skill_preview_panel, type = AssetType.Main},
        {file = AssetConfig.rideattricon, type = AssetType.Dep},
    }

    self.titleString = TI18N("坐骑技能")
    self.gradeString = TI18N("第%s坐骑")
    self.typeDescString = TI18N("特有职业:%s")
    self.typeString = {TI18N("坐骑技能"), TI18N("被动加成")}
    self.depleteString = TI18N("技能序列:第%s技能")
    self.nothingString = TI18N("无")
    self.targetString = TI18N("作用对象:<color='#ffff00'>%s</color>")
    self.noticeString = TI18N("翅膀特技可在<color=#00FF00>被嘲讽、封印</color>状态下使用")

    self.tabList = {}
    self.skillList = {}
    self.attrItemList ={}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RideSkillPreviewPanel:__delete()
    self.OnHideEvent:Fire()
    for i,v in ipairs(self.attrItemList) do
        v.icon.sprite = nil
    end
    for i,v in ipairs(self.skillList) do
        v.image:DeleteMe()
        v = nil
    end
    if self.iconImage ~= nil then
        self.iconImage:DeleteMe()
        self.iconImage = nil
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

function RideSkillPreviewPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ride_skill_preview_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
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
    self.iconImage = SingleIconLoader.New(detail:Find("Icon/Image").gameObject)
    self.descText = detail:Find("Desc"):GetComponent(Text)
    self.skillTypeText = detail:Find("SkillType"):GetComponent(Text)
    self.depleteText = detail:Find("Deplete"):GetComponent(Text)
    self.Targetext = detail:Find("Target"):GetComponent(Text)
    detail:Find("Notice/Text"):GetComponent(Text).text = TI18N("所展示的技能效果为最高等级技能效果")
    detail:Find("Notice").gameObject:SetActive(true)
    detail:Find("Image").gameObject:SetActive(true)
    self.skillTypeText.text = self.typeDescString

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    main:Find("Title/Text"):GetComponent(Text).text = self.titleString

    self.attrItemList = {}
    local len = detail:Find("AttrContainer").childCount
    for i = 1, len do
        local item = detail:Find("AttrContainer"):GetChild(i - 1)
        item.gameObject:SetActive(false)
        local txt = item:GetComponent(Text)
        local icon = item:Find("Icon"):GetComponent(Image)
        table.insert(self.attrItemList, {obj = item.gameObject, txt = txt, icon = icon, rect = item:GetComponent(RectTransform)})
    end
    -- self.noticeText = detail:Find("Notice/Text"):GetComponent(Text)
    -- self.noticeText.text = self.noticeString

    self:InitTabGroup()
end

function RideSkillPreviewPanel:OnClose()
    self.model:CloseRideSkillPreview()
end

function RideSkillPreviewPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RideSkillPreviewPanel:OnOpen()
    self:RemoveListeners()

    self.tabGroup:ChangeTab(1)
end

function RideSkillPreviewPanel:OnHide()
    self:RemoveListeners()
end

function RideSkillPreviewPanel:RemoveListeners()
end

function RideSkillPreviewPanel:InitTabGroup()
    local maxindex = 1
    for i=1,100 do
        if #self.model:get_ride_skill_list(i) == 0 then
            self.minGrade = i
            break
        else
            maxindex = i
        end
    end


    for i=1, maxindex do
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
        tab.normalText.text = string.format(self.gradeString, BaseUtils.NumToChn(i))
        tab.selectText.text = string.format(self.gradeString, BaseUtils.NumToChn(i))
        tab.obj:SetActive(true)
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
    end
    local tabSetting = {
        notAutoSelect = true,
        perWidth = 117,
        perHeight = 44,
        isVertical = false,
        spacing = 5,
    }
    self.tabGroup = TabGroup.New(self.tabContainer.gameObject, function(index) self:ChangeTab(index) end, tabSetting)
    self.tabGroup:Layout()
    -- if self.tabList[3] ~= nil then
    --     self.tabList[3].obj:SetActive(false)
    -- end
    self.tabCloner:SetActive(false)
end

function RideSkillPreviewPanel:ChangeTab(index)
    self:UpdateList(index)
end

function RideSkillPreviewPanel:UpdateList(grade)
    local skills = self.model:get_ride_skill_list(grade)
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
            -- tab.image = tab.transform:Find("Image"):GetComponent(Image)
            tab.image = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
            tab.select = tab.transform:Find("Select").gameObject
            tab.base_id = nil
            tab.base_data = v
            tab.btn = tab.image.gameObject:GetComponent(Button)
            -- tab.tag = tab.transform:Find("Tag").gameObject
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
        tab.base_data = v
        tab.base_id = v.id
        local skillData = DataSkill.data_mount_skill[v.id.."_1"]
        -- tab.image.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(skillData.icon))
        tab.image:SetSprite(SingleIconType.SkillIcon, tostring(skillData.icon))
        -- tab.tag:SetActive(skillData.cost_anger > 0)
        tab.name.text = skillData.name
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

function RideSkillPreviewPanel:ShowDetail()
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
        self.Targetext.text = ""
        self:UpdateAttr()
    else
        local skillData = DataSkill.data_mount_skill[base_id.."_6"]
        self.iconImage.gameObject:SetActive(true)
        -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(skillData.icon))
        self.iconImage:SetSprite(SingleIconType.SkillIcon, tostring(skillData.icon))
        self.nameText.text = skillData.name
        self.descText.text = string.format("%s\n%s", skillData.desc1, skillData.desc2)
        self:UpdateAttr(skillData)
        local skillindex = self.model:get_ride_skill_subindex(base_id)
        self.depleteText.text = string.format(self.depleteString, BaseUtils.NumToChn(skillindex))
        self.Targetext.text = string.format(self.targetString, RideEumn.SkillEffectTypeName[skillData.effect_type])
        if self.selectTab.base_data.classes == 0 then
            self.skillTypeText.text = string.format(self.typeDescString, TI18N("全职业"))
        else
            self.skillTypeText.text = string.format(self.typeDescString, KvData.classes_name[self.selectTab.base_data.classes])
        end
        -- if skillData.cost_anger > 0 then
        --     self.skillTypeText.text = string.format(self.typeDescString, self.typeString[1])
        -- else
        --     self.depleteText.text = string.format(self.depleteString, self.nothingString)
        --     self.skillTypeText.text = string.format(self.typeDescString, self.typeString[2])
        -- end
    end
end



function RideSkillPreviewPanel:UpdateAttr(skillData)
    local h = 0
    local skill = skillData
    if skill ~= nil and skill.desc1_type ~= 0 then
        self.attrItemList[1].txt.text = skill.desc1
        self.attrItemList[1].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc1_type))
        self.attrItemList[1].obj:SetActive(true)
        self.attrItemList[1].rect.sizeDelta = Vector2(255, self.attrItemList[1].txt.preferredHeight)
        self.attrItemList[1].rect.anchoredPosition = Vector2(0, -h)
        h = h + self.attrItemList[1].txt.preferredHeight + 15
    else
        self.attrItemList[1].obj:SetActive(false)
    end

    if skill ~= nil and skill.desc2_type ~= 0 then
        self.attrItemList[2].txt.text = skill.desc2
        self.attrItemList[2].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc2_type))
        self.attrItemList[2].obj:SetActive(true)
        self.attrItemList[2].rect.sizeDelta = Vector2(255, self.attrItemList[2].txt.preferredHeight)
        self.attrItemList[2].rect.anchoredPosition = Vector2(0, -h)
        h = h + self.attrItemList[2].txt.preferredHeight + 15
    else
        self.attrItemList[2].obj:SetActive(false)
    end

    if skill ~= nil and skill.desc3_type ~= 0 then
        self.attrItemList[3].txt.text = skill.desc3
        self.attrItemList[3].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc3_type))
        self.attrItemList[3].obj:SetActive(true)
        self.attrItemList[3].rect.sizeDelta = Vector2(255, self.attrItemList[3].txt.preferredHeight)
        self.attrItemList[3].rect.anchoredPosition = Vector2(0, -h)
        h = h + self.attrItemList[3].txt.preferredHeight + 15
    else
        self.attrItemList[3].obj:SetActive(false)
    end

    if skill ~= nil and skill.desc4_type ~= 0 then
        self.attrItemList[4].txt.text = skill.desc4
        self.attrItemList[4].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc4_type))
        self.attrItemList[4].obj:SetActive(true)
        self.attrItemList[4].rect.sizeDelta = Vector2(255, self.attrItemList[4].txt.preferredHeight)
        self.attrItemList[4].rect.anchoredPosition = Vector2(0, -h)
        h = h + self.attrItemList[4].txt.preferredHeight + 15
    else
        self.attrItemList[4].obj:SetActive(false)
    end
end