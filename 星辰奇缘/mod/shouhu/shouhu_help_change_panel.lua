-- ------------------------
-- 组队，切换守护
-- hosr
-- ------------------------
ShouhuHelpChangePanel = ShouhuHelpChangePanel or BaseClass(BasePanel)

function ShouhuHelpChangePanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = self.mainPanel.transform
    self.guardUpdate = true

    self.positionTab = {{275, 14}, {144, -35}, {81, 14}, {159, 14}, {102, -16}, {277, -16}}

    self.guardTab = {}

    self.OnOpenEvent:Add(function() self:UpdataGuard() end)

    self.resList = {
        {file = AssetConfig.shouhu_help_change_panel, type = AssetType.Main},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }
end

function ShouhuHelpChangePanel:__delete()
    if self.guardTab ~= nil then
        for i=1,#self.guardTab do
            local tab = self.guardTab[i]
            tab["headImg"].sprite = nil
            tab["classesImg"].sprite = nil
        end
    end

    self:GuideEnd()

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ShouhuHelpChangePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_help_change_panel))
    self.transform = self.gameObject.transform
    self.gameObject.name = "ShouhuHelpChangePanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.gameObject:SetActive(false)
    local panel = self.transform:Find("Panel").gameObject
    panel:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    self.main = self.transform:Find("Main").gameObject
    self.scrollRect = self.transform:Find("Main/Scroll"):GetComponent(ScrollRect)
    self.container = self.transform:Find("Main/Scroll/Container").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.itemBase = self.transform:Find("Main/Scroll/ItemBase").gameObject
    self.itemBase:SetActive(false)
end

function ShouhuHelpChangePanel:OnInitCompleted()
    self:UpdataGuard()
    self.transform.gameObject:SetActive(true)
end

function ShouhuHelpChangePanel:CreateItem()
    local item = GameObject.Instantiate(self.itemBase).gameObject
    item.transform:SetParent(self.container.transform)
    item.transform.localScale = Vector3.one
    local headImg = item.transform:Find("HeadImg"):GetComponent(Image)
    local level_txt = item.transform:Find("Level"):GetComponent(Text)
    local classesImg = item.transform:Find("ClassesImg"):GetComponent(Image)
    local name_txt = item.transform:Find("Name"):GetComponent(Text)
    local state_obj = item.transform:Find("State").gameObject

    local tab = {}
    tab["gameObject"] = item
    tab["data"] = v
    tab["rect"] = item:GetComponent(RectTransform)
    tab["headImg"] = headImg
    tab["level_txt"] = level_txt
    tab["classesImg"] = classesImg
    tab["name_txt"] = name_txt
    tab["state_obj"] = state_obj
    table.insert(self.guardTab, tab)
    tab["headImg"].gameObject:SetActive(true)
    item:GetComponent(Button).onClick:AddListener(function() self:Click(tab) end)
    return tab
end

function ShouhuHelpChangePanel:InitGuard()
    self:UpdataGuard()
end

function ShouhuHelpChangePanel:UpdataGuard()
    --更新显示位置
    local pos_index = self.openArgs.index
    local _type = self.openArgs.type
    local pos = self.positionTab[pos_index]
    self.main.transform.localPosition = Vector3(pos[1], pos[2], 0)

    self.show_list = {}
    for k,v in ipairs(ShouhuManager.Instance.model.my_sh_list) do
        if (v.war_id == 0 or v.war_id == nil) and v.guard_fight_state ~= ShouhuManager.Instance.model.guard_fight_state.field then
            table.insert(self.show_list, v)
        elseif (v.war_id == 0 or v.war_id == nil) and _type ~= nil then
            table.insert(self.show_list, v)
        end
    end

    for i=1,#self.guardTab do
        local tab = self.guardTab[i]
        tab["gameObject"]:SetActive(false)
    end

    for i=1,#self.show_list do
        local v = self.show_list[i]
        local tab = self.guardTab[i]
        if tab == nil then
            tab = self:CreateItem()
        end
        tab["data"] = v
        tab["info"] = v
        tab["headImg"].sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(v.avatar_id))
        tab["level_txt"].text = ""
        tab["classesImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(v.classes))
        tab["name_txt"].text = v.name
        tab["gameObject"]:SetActive(true)
    end

    self:Layout()
end

-- 元素排位
function ShouhuHelpChangePanel:Layout()
    local count = 0
    for i=1,#self.guardTab do
        local tab = self.guardTab[i]
        local newY = count * -80
        tab["rect"].anchoredPosition = Vector2(0, newY)
        count = count + 1
    end
    self.containerRect.sizeDelta = Vector2(220, 80 * count)

    self:GuideEnd()
    if ShouhuManager.Instance:CheckHelpGuide() then
        self:Guide()
    end
end

function ShouhuHelpChangePanel:Click(tab)
    local pos_index = self.openArgs.index
    ShouhuManager.Instance:request10905(pos_index, tab["data"].base_id)
    DramaManager.Instance:Send11023(DramaEumn.OnceGuideType.GuardHelp)
    self:Hiden()
end

function ShouhuHelpChangePanel:Guide()
    if self.guideScript == nil then
        self.guideScript = GuideGuardHelpChoose.New(self)
    end
    self.guideScript:Show()
end

function ShouhuHelpChangePanel:GuideEnd()
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end