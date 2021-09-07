-- ------------------------
-- 组队，切换守护
-- hosr
-- ------------------------
TeamChangeGuardPanel = TeamChangeGuardPanel or BaseClass(BasePanel)

function TeamChangeGuardPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = self.mainPanel.main.transform.parent
    self.guardUpdate = true

    self.positionTab = {-80, 60, 190, 325, 80}

    self.guardTab = {}

    self.OnOpenEvent:Add(function() self:UpdataGuard() end)

    self.resList = {
        {file = AssetConfig.teamchangeguard, type = AssetType.Main},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }
end

function TeamChangeGuardPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function TeamChangeGuardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamchangeguard))
    self.transform = self.gameObject.transform
    self.gameObject.name = "TeamChangeGuardPanel"
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

function TeamChangeGuardPanel:OnInitCompleted()
    self:UpdataGuard()
    self.main.transform.localPosition = Vector3(self.positionTab[self.mainPanel.membersArea.currentSelectId], -50, 0)
    self.transform.gameObject:SetActive(true)
end

function TeamChangeGuardPanel:CreateItem()
    local item = GameObject.Instantiate(self.itemBase).gameObject
    item.transform:SetParent(self.container.transform)
    item.transform.localScale = Vector3.one
    local headImg = item.transform:Find("HeadImg"):GetComponent(Image)
    local level_txt = item.transform:Find("Level/Level"):GetComponent(Text)
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

function TeamChangeGuardPanel:InitGuard()
    self:UpdataGuard()
end

function TeamChangeGuardPanel:UpdataGuard()
    for i,v in ipairs(FormationManager.Instance.guardList) do
        local gdata = DataShouhu.data_guard_base_cfg[v.guard_id]
        local tab = self.guardTab[i]
        if tab == nil then
            tab = self:CreateItem()
        end
        tab["data"] = v
        tab["info"] = gdata
        tab["headImg"].sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(gdata.base_id))
        tab["level_txt"].text = tostring(RoleManager.Instance.RoleData.lev)
        tab["classesImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(gdata.classes))
        tab["name_txt"].text = gdata.name
        if v.number ~= 0 then
            tab["state_obj"]:SetActive(true)
        else
            tab["state_obj"]:SetActive(false)
        end
    end

    self:Layout()
end

-- 元素排位
function TeamChangeGuardPanel:Layout()
    table.sort(self.guardTab, function(a,b) return a.data.number > b.data.number end)

    local count = 0
    local crrentGuard = self.mainPanel.membersArea.memberTab[self.mainPanel.membersArea.currentSelectId]["info"]
    for i,tab in ipairs(self.guardTab) do
        if tab["info"].base_id == crrentGuard.base_id or tab["data"].status == 2 then
            tab["gameObject"]:SetActive(false)
        else
            tab["rect"].anchoredPosition = Vector2(0, - count * 80)
            tab["gameObject"]:SetActive(true)
            count = count + 1
        end
    end
    self.containerRect.sizeDelta = Vector2(220, 80 * count)
end

function TeamChangeGuardPanel:Click(tab)
    FormationManager.Instance:Send12905(tab["data"].guard_id , 1, self.openArgs.info.base_id)
    self:Hiden()
end
