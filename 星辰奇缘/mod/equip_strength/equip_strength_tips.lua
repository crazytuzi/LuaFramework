-- 强化光环预览tips
-- ljh 20161223

EquipStrengthTips = EquipStrengthTips or BaseClass(BasePanel)

function EquipStrengthTips:__init(parent)
    self.parent = parent
    self.model = EquipStrengthManager.Instance.model
    self.resList = {
        {file = AssetConfig.strengthpreviewtips, type = AssetType.Main},
        -- {file = AssetConfig.rolebg, type = AssetType.Dep},
    }

    self.setting = {
        name = "EquipStrengthTips"
        ,orthographicSize = 1.1
        ,width = 682
        ,height = 600
        ,offsetY = -0.3
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil

    self.txtList = {}
end

function EquipStrengthTips:__delete()
	if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

	GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function EquipStrengthTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strengthpreviewtips))
    self.gameObject.name = "EquipStrengthTips"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.transform.parent.parent.gameObject, self.gameObject)

    self.transform:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.infoPanelObj = self.transform:Find("InfoPanel").gameObject
    self.infoPanelRect = self.infoPanelObj:GetComponent(RectTransform)
    self.infoPanelObj:SetActive(false)

    self.previewObj = self.transform:Find("PreviewPanel").gameObject
    self.previewRect = self.previewObj:GetComponent(RectTransform)
    self.previewObj:SetActive(false)

    -- self.transform:Find("PreviewPanel/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")
    self.transform:Find("PreviewPanel/Bg").gameObject:SetActive(false)
    self.rawImg = self.transform:Find("PreviewPanel/Preview").gameObject
    self.rawImg:SetActive(false)

    self.previewText = self.transform:Find("PreviewPanel/TitleText"):GetComponent(Text)
    self.name = self.transform:Find("PreviewPanel/Name/Text"):GetComponent(Text)
    self.name.text = TI18N("光环名称")

    self.normal = self.transform:Find("InfoPanel/Normal").gameObject
    self.attrText1 = self.transform:Find("InfoPanel/Normal/ArrtText1"):GetComponent(Text)
    self.attrText2 = self.transform:Find("InfoPanel/Normal/ArrtText2"):GetComponent(Text)

    self.max = self.transform:Find("InfoPanel/Max").gameObject
    self.maxTxt = self.max:GetComponent(Text)

    self.min = self.transform:Find("InfoPanel/Min").gameObject
    self.minTxt = self.min:GetComponent(Text)

    self.titleText = self.transform:Find("InfoPanel/Panel/TitleText"):GetComponent(Text)
    self.infoPanel = self.transform:Find("InfoPanel/Panel")

    for i = 1, 8 do
        local index = i
        local item = self.infoPanel:FindChild(string.format("DescText%s", index))
        item:GetComponent(Button).onClick:AddListener(function() self:ClickOneTxt(index) end)
        table.insert(self.txtList, item:FindChild("Text"):GetComponent(Text))
    end

    self:Update()
end

function EquipStrengthTips:Close()
	self.parent:HideStrengthTips()
end

function EquipStrengthTips:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function EquipStrengthTips:SetRawImage(composite)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self:SetPosition()
    self.previewComp.tpose.transform.localRotation = Quaternion.identity
    self.previewComp.tpose.transform:Rotate(Vector3(-15, 0, 0))
    self.rawImg:SetActive(true)
end

--根据模型包围盒计算中心点
function EquipStrengthTips:SetPosition()
    self.previewComp.tpose.transform.position = Vector3(self.previewComp.nextX, -0.4, 0)
end

function EquipStrengthTips:Update()
    self:UpdateInfo()

	local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks, showHalo = true}

    local base = DataBacksmith.data_halo[string.format("15_%s", RoleManager.Instance.RoleData.classes)]
    if base ~= nil then
        table.insert(modelData.looks, {looks_val = base.halo_id, looks_str = "", looks_mode = 0, looks_type = SceneConstData.lookstype_halo})
        self.name.text = base.name
    end

	self.previewText.text = TI18N("全身强化<color='#ffff00'>+15</color>后获得")

    if EquipStrengthManager.Instance.model.strength_lev == EquipStrengthManager.Instance.model.max_strength_lev then
        self:NotAll13()
    elseif EquipStrengthManager.Instance.model.strength_lev >= 13 then
        self:All13()
        self:LoadPreview(modelData)
    else
        self:NotAll13()
    end
end

function EquipStrengthTips:NotAll13()
    self.infoPanelRect.anchoredPosition = Vector3.zero
    self.infoPanelObj:SetActive(true)
    self.previewObj:SetActive(false)
end

function EquipStrengthTips:All13()
    self.infoPanelRect.anchoredPosition = Vector3(-142, 0, 0)
    self.previewRect.anchoredPosition = Vector3(208, 0, 0)
    self.infoPanelObj:SetActive(true)
    self.previewObj:SetActive(true)
end

function EquipStrengthTips:UpdateInfo()
    local now_strength_lev = EquipStrengthManager.Instance.model.strength_lev
    local next_strength_lev = now_strength_lev + 1
    local nowdata = DataEqm.data_enchant_suit[now_strength_lev]
    local nextdata = DataEqm.data_enchant_suit[next_strength_lev]
    local str = string.format(TI18N("强化<color='#ffff00'>+%s</color>套装属性:\n"), now_strength_lev)
    if nowdata == nil then
        self.minTxt.text = string.format(TI18N("下级可激活套装属性\n穿上8件<color='#00ff00'>+7</color>装备即可激活以下效果:\n%s"), self:GetAttrStr(nextdata))
        self.min:SetActive(true)
        self.normal:SetActive(false)
        self.max:SetActive(false)
    elseif nextdata == nil then
        self.min:SetActive(false)
        self.normal:SetActive(false)
        self.max:SetActive(true)
        self.maxTxt.text = string.format(TI18N("<color='#D681EF'>已达到最高套装等级</color>\n%s"), self:GetAttrStr(nowdata))
    else
        self.min:SetActive(false)
        self.normal:SetActive(true)
        self.max:SetActive(false)

        self.attrText1.text = string.format(TI18N("强化<color='#00ff00'>+%s</color>装属性:\n%s"), now_strength_lev, self:GetAttrStr(nowdata))
        self.attrText2.text = TI18N("下级套装属性:\n") .. self:GetAttrStr(nextdata, true)
    end

    local tempNum = 0
    for index,v in pairs(BackpackManager.Instance.equipDic) do
        local txt = self.txtList[index]
        if v.enchant >= next_strength_lev or nextdata == nil then
            txt.text = string.format("<color='#00ff00'>%s</color>", BackpackEumn.GetEquipNameByType(v.type))
            tempNum = tempNum + 1
        else
            txt.text = BackpackEumn.GetEquipNameByType(v.type)
        end
    end

    local color = "#ff0000"
    if tempNum == 8 then
        color = "#00ff00"
    end
    if nextdata == nil then
        self.titleText.text = string.format(TI18N("已达到最高等级(<color='%s'>%s</color>/8)"), color, tempNum)
    else
        self.titleText.text = string.format(TI18N("下级强化进度：(<color='%s'>%s</color>/8)"), color, tempNum)
    end
end

function EquipStrengthTips:ClickOneTxt(index)
    local equip = BackpackManager.Instance.equipDic[index]
    if equip ~= nil then
        EquipStrengthManager.Instance.model.strength_data = {type = equip.type}
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.eqmadvance, {4})
    self:Close()
end

function EquipStrengthTips:GetAttrStr(data, gray)
    local attrs = data.attr
    local skills = data.skill_prac
    local str = ""

    local color = "#00ff00"
    if gray then
        color = "#808080"
    end

    for i,v in ipairs(attrs) do
        str = str .. string.format("<color='%s'>%s +%s</color>\n", color, KvData.attr_name[v.attr_name], v.val)
    end

    for i,v in ipairs(skills) do
        local id = tonumber(v[1])
        local add = tonumber(v[2])
        local sdata = DataSkillPrac.data_skill[id]
        str = str .. string.format("<color='%s'>%s +%s</color>\n", color, sdata.name, add)
    end
    return str
end