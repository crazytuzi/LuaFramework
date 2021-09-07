-- @author hzf
-- @date 2016年7月7日,星期四

EncyclopediaSubPanel = EncyclopediaSubPanel or BaseClass(BasePanel)

function EncyclopediaSubPanel:__init(parent, type, TabList)
    self.model = EncyclopediaManager.Instance.model
    self.parent = parent
    self.name = "EncyclopediaSubPanel"
    self.type = type
    self.TabList = TabList
    self.resList = {
        {file = AssetConfig.encyclopedia_subpanel, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
        {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.childpanel = {}
end

function EncyclopediaSubPanel:__delete()
    self.OnHideEvent:Fire()
    if self.childpanel ~= nil then
        for k,v in pairs(self.childpanel) do
            v:DeleteMe()
        end
    end
    self:AssetClearAll()
end

function EncyclopediaSubPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.encyclopedia_subpanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.tab_base = t:Find("Button").gameObject
    self.tabCon = t:Find("TabButtonGroup")
    self.MainCon = self.transform:Find("Main").gameObject

    for i,v in ipairs(self.TabList) do
        local secondtab = GameObject.Instantiate(self.tab_base)
        secondtab.transform:SetParent(self.tabCon)
        secondtab.transform.localScale = Vector3.one
        secondtab.transform.anchoredPosition = Vector2(118*(i-1), -19)
        self:SetTabBtn(secondtab.transform, v)
        secondtab:SetActive(true)
    end
    self:InitChildPanel()
    self.tabgroup = TabGroup.New(self.tabCon.gameObject, function (tab) self:OnTabChange(tab) end)
end

function EncyclopediaSubPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    else
        self.tabgroup:ChangeTab(1)
    end
end

function EncyclopediaSubPanel:OnOpen()
    self:RemoveListeners()

    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    end
end

function EncyclopediaSubPanel:OnHide()
    self:RemoveListeners()
end

function EncyclopediaSubPanel:RemoveListeners()
end

function EncyclopediaSubPanel:SetTabBtn(btnTrans, name)
    btnTrans:Find("Normal/Text"):GetComponent(Text).text = name
    btnTrans:Find("Select/Text"):GetComponent(Text).text = name
end

function EncyclopediaSubPanel:OnTabChange(index)
    for i,v in ipairs(self.childpanel) do
        if i == index then
            v:Show()
            v.isHiden = false
        else
            v:Hiden()
            v.isHiden = true
        end
    end
end

function EncyclopediaSubPanel:InitChildPanel()
    if self.type == 1 then
        self.childpanel[1] = EncyclopediaEquip.New(self.MainCon)
        self.childpanel[2] = EncyclopediaEquipBuildRebuild.New(self.MainCon)
        self.childpanel[3] = EncyclopediaEquipStongStrength.New(self.MainCon)
        self.childpanel[4] = EncyclopediaEquipRefineOther.New(self.MainCon)
    elseif self.type == 2 then
        self.childpanel[1] = EncyclopediaSkill.New(self.MainCon)
        self.childpanel[2] = EncyclopediaEquipSkill.New(self.MainCon)
        self.childpanel[3] = EncyclopediaWingSkill.New(self.MainCon)
        self.childpanel[4] = EncyclopediaCPSkill.New(self.MainCon)
    elseif self.type == 3 then
        self.childpanel[1] = EncyclopediaPet.New(self.MainCon)
        local lev = RoleManager.Instance.RoleData.lev
        if lev < 75 then
            self.childpanel[2] = EncyclopediaPetLvupAttr.New(self.MainCon)
        else
            self.childpanel[2] = EncyclopediaPetSpirit.New(self.MainCon)
        end
        self.childpanel[3] = EncyclopediaPetWashLearn.New(self.MainCon)
        self.childpanel[4] = EncyclopediaPetUpgradeOther.New(self.MainCon)
    elseif self.type == 4 then
        self.childpanel[1] = TalismanpediaTalisman.New(self.MainCon)
    elseif self.type == 5 then
        self.childpanel[1] = EncyclopediaGuardDesc.New(self.MainCon)
        self.childpanel[2] = EncyclopediaGuard.New(self.MainCon)
    elseif self.type == 6 then
        self.childpanel[1] = EncyclopediaWings.New(self.MainCon)
        -- self.childpanel[2] = EncyclopediaWingsUpgradeReset.New(self.MainCon)
        self.childpanel[2] = EncyclopediaWingSkill.New(self.MainCon)
        -- self.childpanel[3] = EncyclopediaWingsSkillOther.New(self.MainCon)
    elseif self.type == 7 then
        self.childpanel[1] = EncyclopediaCombatDesc.New(self.MainCon)
        self.childpanel[2] = EncyclopediaMedicine.New(self.MainCon)
    elseif self.type == 8 then
        self.childpanel[1] = EncyclopediaRide.New(self.MainCon)
        self.childpanel[2] = EncyclopediaRideBaseInfo.New(self.MainCon)
        self.childpanel[3] = EncyclopediaRideTrans.New(self.MainCon)
        self.childpanel[4] = EncyclopediaRideSkill.New(self.MainCon)
    end
end