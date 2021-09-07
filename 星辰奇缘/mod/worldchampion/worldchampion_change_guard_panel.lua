-- ------------------------
-- 组队，切换守护
-- hosr
-- ------------------------
WorldChampionChangeGuardPanel = WorldChampionChangeGuardPanel or BaseClass(BasePanel)

function WorldChampionChangeGuardPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = self.mainPanel.transform.parent
    self.guardUpdate = true

    self.positionTab = {-80, 60, 190, 325, 80}

    self.guardTab = {}

    self.OnOpenEvent:Add(function() self:UpdataGuard() end)

    self.resList = {
        {file = AssetConfig.teamchangeguard, type = AssetType.Main},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }
end

function WorldChampionChangeGuardPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function WorldChampionChangeGuardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamchangeguard))
    self.transform = self.gameObject.transform
    self.gameObject.name = "WorldChampionChangeGuardPanel"
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

function WorldChampionChangeGuardPanel:OnInitCompleted()
    self:UpdataGuard()
    self.transform.gameObject:SetActive(true)
end

function WorldChampionChangeGuardPanel:CreateItem()
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

function WorldChampionChangeGuardPanel:InitGuard()
    self:UpdataGuard()
end

function WorldChampionChangeGuardPanel:UpdataGuard()
    -- BaseUtils.dump(self.openArgs, "WorldChampionChangeGuardPanel:InitGuard()")
    if self.openArgs ~= nil then
        self.base_id = self.openArgs.base_id
        self.callBack = self.openArgs.callBack

        local index = self.openArgs.index
        if index == nil then 
            index = 3
        end
        self.main.transform.localPosition = Vector3(self.positionTab[index], -50, 0)
    else
        self.base_id = nil
        self.callBack = nil
    end

    local list = BaseUtils.copytab(self.mainPanel.mainPanel.leaderGuards)
    local fightGuardsMark = self.mainPanel.mainPanel.fightGuardsMark
    for guardIndex, guardData in ipairs(list) do
        if self.base_id == guardData.base_id then
            table.remove(list, guardIndex)
            break
        end
    end

    local function sortfun(a,b)
        return fightGuardsMark[a.base_id] and not fightGuardsMark[b.base_id]
    end

    table.sort(list, sortfun)
-- BaseUtils.dump(fightGuardsMark, "fightGuardsMark")
-- BaseUtils.dump(list, "list")
    for i,v in ipairs(list) do
        local gdata = DataShouhu.data_guard_base_cfg[v.base_id]
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
        if fightGuardsMark[gdata.base_id] then
            tab["state_obj"]:SetActive(true)
        else
            tab["state_obj"]:SetActive(false)
        end

        tab.gameObject:SetActive(true)
    end

    for i=#list+1, #self.guardTab do
        local tab = self.guardTab[i]
        if tab ~= nil then
            tab.gameObject:SetActive(false)     
        end
    end

    self:Layout()
end

-- 元素排位
function WorldChampionChangeGuardPanel:Layout()
    -- table.sort(self.guardTab, function(a,b) return a.data.base_id > b.data.base_id end)

    local count = 0
    for i,tab in ipairs(self.guardTab) do
        tab["rect"].anchoredPosition = Vector2(0, - count * 80)
        tab["gameObject"]:SetActive(true)
        count = count + 1
    end
    self.containerRect.sizeDelta = Vector2(220, 80 * count)
end

function WorldChampionChangeGuardPanel:Click(tab)
    if self.callBack ~= nil then
        self.callBack(tab["data"].base_id)
    end
    self:Hiden()
end
