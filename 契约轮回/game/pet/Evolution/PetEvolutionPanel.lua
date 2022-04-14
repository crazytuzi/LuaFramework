---
--- Created by R2D2.
--- DateTime: 2019/5/5 14:56
---

PetEvolutionPanel = PetEvolutionPanel or class("PetEvolutionPanel", BaseItem)
local this = PetEvolutionPanel

function PetEvolutionPanel:ctor(parent_node, parent_panel)
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetEvolutionPanel"
    self.layer = "UI"

    self.model = PetModel:GetInstance()

    self.events = {}
    self.modelEvents = {}

    self.goodItems = {}

    PetEvolutionPanel.super.Load(self)
end

function PetEvolutionPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)

    if (self.Items) then
        for _, v in pairs(self.Items) do
            v:destroy()
        end
        self.Items = {}
    end

    for _, v in pairs(self.goodItems) do
        v:destroy()
    end
    self.goodItems = {}

    if (self.leftSkill) then
        for _, value in pairs(self.leftSkill) do
            -- body
        end
    end

    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end

    self.leftSkill = self:ClearMyTable(self.leftSkill)
    self.rightSkill = self:ClearMyTable(self.rightSkill)
    self.epLeftList = self:ClearMyTable(self.epLeftList)
    self.epRightList = self:ClearMyTable(self.epRightList)
end

function PetEvolutionPanel:ClearMyTable(tab)
    if (tab) then
        for _, value in pairs(tab) do
            value = nil
        end
        tab = nil
    end

    return nil
end

function PetEvolutionPanel:LoadCallBack()
    self.nodes = {
        "Image3",
        "Image4",
        "Image5",
        "Image6",
        "EP_L",
        "EP_L/L_Ep1",
        "EP_L/L_Ep2",
        "EP_L/L_Ep3",
        "EP_L/L_Ep4",
        "EPArrow",
        "EP_R",
        "EP_R/R_Ep1",
        "EP_R/R_Ep2",
        "EP_R/R_Ep3",
        "EP_R/R_Ep4",
        "NoEp",
        "ItemPrefab",
        "ItemParent",
        "SkillIcon1",
        "SkillIcon1/SkillLevel1",
        "SkillIcon1/SkillTitle1",
        "SkillIcon1/Lock1",
        "SkillIcon1/skillicon1",
        "SkillArrow",
        "SkillIcon2",
        "SkillIcon2/SkillLevel2",
        "SkillIcon2/SkillTitle2",
        "SkillIcon2/Lock2",
        "SkillIcon2/skillicon2",
        "SkillNoEP",
        "SkillUpDesc",
        "GoodParent",
        "EvolutionBtn",
        "NoEvolutionTip",
        "FullEvolution",
        "InActiveBtn",
        "SendBackBtn",
        "Power/PowerValue",
    }

    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.petData and self.gameObject.activeSelf) then
        self:RefreshView()
    end
end

function PetEvolutionPanel:InitUI()
    self.image3 = GetImage(self.Image3)
    self.image4 = GetImage(self.Image4)
    self.image5 = GetImage(self.Image5)
    self.image6 = GetImage(self.Image6)
    self.PowerValue = GetText(self.PowerValue)

    self.epLeftList = {}
    table.insert(self.epLeftList, GetImage(self.L_Ep1))
    table.insert(self.epLeftList, GetImage(self.L_Ep2))
    table.insert(self.epLeftList, GetImage(self.L_Ep3))
    table.insert(self.epLeftList, GetImage(self.L_Ep4))

    self.epRightList = {}
    table.insert(self.epRightList, GetImage(self.R_Ep1))
    table.insert(self.epRightList, GetImage(self.R_Ep2))
    table.insert(self.epRightList, GetImage(self.R_Ep3))
    table.insert(self.epRightList, GetImage(self.R_Ep4))

    self.leftSkill = {
        ["Icon"] = GetImage(self.skillicon1),
        ["Level"] = GetImage(self.SkillLevel1),
        ["Title"] = GetText(self.SkillTitle1),
        ["Lock"] = GetImage(self.Lock1)
    }

    self.rightSkill = {
        ["Icon"] = GetImage(self.skillicon2),
        ["Level"] = GetImage(self.SkillLevel2),
        ["Title"] = GetText(self.SkillTitle2),
        ["Lock"] = GetImage(self.Lock2)
    }

    self.skillUpDescTxt = GetText(self.SkillUpDesc)

    SetVisible(self.ItemPrefab, false)
end

function PetEvolutionPanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_SelectPetEvent, handler(self, self.OnSelectPet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_EvolutionBattlePetEvent, handler(self, self.OnEvolutionPet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_BackEvolutionBattlePetEvent, handler(self, self.OnBackEvolutionPet))
    self.modelEvents[#self.modelEvents + 1] =
        self.model:AddListener(PetEvent.Pet_Model_ChangeBattlePetEvent, handler(self, self.OnChangeBattlePet))

    AddButtonEvent(self.EvolutionBtn.gameObject, handler(self, self.OnEvolutionBtn))
    AddButtonEvent(self.SendBackBtn.gameObject, handler(self, self.OnBackEvolutionBtn))

    local function call_back()
        Notify.ShowText(ConfigLanguage.Pet.NotObtainment)
    end
    AddButtonEvent(self.InActiveBtn.gameObject, call_back)

    local function call_back()
        local s1, _ = self:GetSkillInfo()
        local t = self:GetMainSkillOpenTimes()
        local pos = self.SkillIcon1.transform.position

        local tipView = lua_panelMgr:GetPanelOrCreate(PetSkillTipView)
        local vpPos = LayerManager:UIWorldToViewportPoint(pos.x, pos.y, pos.z)
        tipView:SetData(s1, vpPos, t)
        tipView:Open()
    end
    AddButtonEvent(self.skillicon1.gameObject, call_back)

    local function call_back()
        local _, s2 = self:GetSkillInfo()
        local pos = self.SkillIcon2.transform.position

        tipView = lua_panelMgr:GetPanelOrCreate(PetSkillTipView)
        local vpPos = LayerManager:UIWorldToViewportPoint(pos.x, pos.y, pos.z)
        tipView:SetData(s2, vpPos)
        tipView:Open()
    end
    AddButtonEvent(self.skillicon2.gameObject, call_back)
end

function PetEvolutionPanel:OnSelectPet(petData)
    self.petData = petData
    self:RefreshView()
end

function PetEvolutionPanel:OnEvolutionPet(petData)
    if (self.petData.Config.order == petData.Config.order) then
        self.petData = petData
        Notify.ShowText(ConfigLanguage.Pet.EvolutionSuccess)
        self:RefreshView()
    end
end

function PetEvolutionPanel:OnBackEvolutionPet(petData)
    if (self.petData.Config.order == petData.Config.order) then
        self.petData = petData
        self:RefreshView()
    end
end

function PetEvolutionPanel:OnChangeBattlePet(petData)
    if (self.petData.Config.order == petData.Config.order) then
        self.petData = petData
        self:RefreshView()
    end
end

function PetEvolutionPanel:SetData(petData)
    self.petData = petData

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetEvolutionPanel:OnEvolutionBtn()
    local isCanCost = self:CheckCost(true)

    if (self.reqEvolutionWaitTime) then
        return
    end

    local function call_back()
        self.reqEvolutionTime = false
    end
    GlobalSchedule:StartOnce(call_back, 0.2)

    if (isCanCost) then
        PetController:GetInstance():RequestEvolutionPet(self.petData.Config.order)
    end
end

function PetEvolutionPanel:OnBackEvolutionBtn()
    if self.CurrValue.Extra <= 0 then
        Notify.ShowText(ConfigLanguage.Pet.NotEvolution)
        return
    end

    local items = {}
    for i = 1, self.CurrValue.Extra do
        local cfgKey = self.petData.Config.order .. "@" .. i
        local tempCfg = Config.db_pet_evolution[cfgKey]
        local tab = String2Table(tempCfg.cost)

        for _, v in ipairs(tab) do
            if items[v[1]] then
                items[v[1]] = items[v[1]] + v[2]
            else
                items[v[1]] = v[2]
            end
        end
    end

    local result = {}
    for i, v in pairs(items) do
        local tempItemCfg = Config.db_item[i]
        local name = tempItemCfg.name
        table.insert(result,string.format("<color=#%s>%s * %s</color>", ColorUtil.GetColor(tempItemCfg.color), name, v)
        )
    end

    local backItemStr = table.concat(result, " , ")
    Dialog.ShowTwo(
        "Tip",
        ConfigLanguage.Pet.BackEvolutionTip .. backItemStr,
        "Confirm",
        handler(self, self.RequestBackPet),
        nil,
        "Cancel",
        nil,
        nil
    )
end

function PetEvolutionPanel:RequestBackPet()
    PetController:GetInstance():RequestBackPet(self.petData.Config.order)
end
--------------------------------------更新突破点--------------------------------------
function PetEvolutionPanel:RefreshEpView()
    if (not self.CurrValue.IsHadEvolution) then
        self:EPViewNoneStyle()
    else
        self:RefreshEpList(self.epLeftList, self.CurrValue.EpCount, self.CurrValue.Extra)
        self:RefreshEpList(self.epRightList, self.CurrValue.EpCount, self.CurrValue.NextExtra)

        if (self.CurrValue.EpCount <= self.CurrValue.Extra) then
            self:EPViewFullStyle()
        else
            self:EPViewNormalStyle()
        end
    end
    if self.petData.IsActive then
        self.PowerValue.text = self.petData.Data.pet.power
    else
        self.PowerValue.text = "wwwwwww"
    end
end

function PetEvolutionPanel:RefreshEpList(epList, count, point)
    for i, v in ipairs(epList) do
        if (i <= point) then
            SetVisible(v.gameObject, true)
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint")
        elseif (i <= count) then
            SetVisible(v.gameObject, true)
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Gray")
        else
            SetVisible(v.gameObject, false)
        end
    end
end

function PetEvolutionPanel:EPViewNormalStyle()
    SetAnchoredPosition(self.EP_L, -100, 181)
    SetVisible(self.EP_L.gameObject, true)
    SetVisible(self.EP_R.gameObject, true)
    SetVisible(self.EPArrow.gameObject, true)
    SetVisible(self.NoEp.gameObject, false)
end

function PetEvolutionPanel:EPViewFullStyle()
    SetAnchoredPosition(self.EP_L, 0, 181)
    SetVisible(self.EP_L.gameObject, true)
    SetVisible(self.EP_R.gameObject, false)
    SetVisible(self.EPArrow.gameObject, false)
    SetVisible(self.NoEp.gameObject, false)
end

function PetEvolutionPanel:EPViewNoneStyle()
    SetVisible(self.EP_L.gameObject, false)
    SetVisible(self.EP_R.gameObject, false)
    SetVisible(self.EPArrow.gameObject, false)
    SetVisible(self.NoEp.gameObject, true)
end

--------------------------------------更新属性列表--------------------------------------

function PetEvolutionPanel:RefreshAttrs()
    ---将下一级突破的属性值加到后面
    ---为0即无法突破，相等则判定为达到最大值
    local tab = String2Table(self.CurrValue.CurrCfg.attr)
    local nextTab = self.CurrValue.NextCfg and String2Table(self.CurrValue.NextCfg.attr) or nil
    for i, v in ipairs(tab) do
        table.insert(v, nextTab and nextTab[i][2] or 0)
    end

    self:CreateAttrItem(#tab)

    for i, v in ipairs(tab) do
        self.Items[i]:SetData(v)
        SetVisible(self.Items[i], true)
    end

    for i = #tab + 1, #self.Items do
        SetVisible(self.Items[i], false)
    end
end

function PetEvolutionPanel:CreateAttrItem(count)
    self.Items = self.Items or {}

    if count <= #self.Items then
        return
    end

    for i = #self.Items + 1, count do
        local tempItem = PetEvolutionItemView(newObject(self.ItemPrefab))
        tempItem.transform:SetParent(self.ItemParent)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        table.insert(self.Items, tempItem)
    end
end

--------------------------------------更新技能显示--------------------------------------
function PetEvolutionPanel:RefreshSkill()
    if (not self.CurrValue.IsHadEvolution) then
        self:SkillNoneStyle()
        self.skillUpDescTxt.text = ""
    else
        local s1, s2 = self:GetSkillInfo()

        if (self.CurrValue.EpCount <= self.CurrValue.Extra) then
            self:RefreshSkillItem(self.rightSkill, s2)
            self:SkillFullStyle()
            self.skillUpDescTxt.text = ConfigLanguage.Pet.FullEvolution
        else
            self:RefreshSkillItem(self.leftSkill, s1)
            self:RefreshSkillItem(self.rightSkill, s2)
            self:SkillNormalStyle()
            self.skillUpDescTxt.text = self.CurrValue.CurrCfg.des
        end
    end
end

function PetEvolutionPanel:RefreshSkillItem(skillItem, skillData)
    local cfg = Config.db_skill[skillData[1]]
    local skillType = skillData[3]
    local isLock = skillData[4] == 0

    lua_resMgr:SetImageTexture(self, skillItem.Icon, "iconasset/icon_skill", tostring(cfg.icon), true)
    lua_resMgr:SetImageTexture(self, skillItem.Level, "pet_image", "Roman_" .. skillData[2], true)
    skillItem.Title.text = ConfigLanguage.Pet["SkillTitle" .. skillType]
    skillItem.Lock.enabled = isLock

    if (skillType == 1 and isLock) then
        ShaderManager.GetInstance():SetImageGray(skillItem.Icon)
    else
        ShaderManager.GetInstance():SetImageNormal(skillItem.Icon)
    end
end

function PetEvolutionPanel:GetSkillInfo()
    local tab1 = String2Table(self.CurrValue.CurrCfg.skill)
    local tab2 = nil

    ---如果已到了最大值，则取出上一级的配置，用来比较技能等级
    if (self.CurrValue.Extra >= self.CurrValue.EpCount) then
        local key = self.petData.Config.order .. "@" .. (self.CurrValue.Extra - 1)
        local tempCfg = Config.db_pet_evolution[key]
        tab2 = tab1
        tab1 = String2Table(tempCfg.skill)
    else
        tab2 = String2Table(self.CurrValue.NextCfg.skill)
    end

    local index

    for i, v in ipairs(tab1) do
        local v2 = tab2[i]
        if (v2[2] > v[2]) or (v2[4] > v[4]) then
            index = i
            break
        end
    end

    return tab1[index], tab2[index]
end

function PetEvolutionPanel:SkillNormalStyle()
    SetAnchoredPosition(self.SkillIcon2, 102, -97.3)
    SetVisible(self.SkillIcon1.gameObject, true)
    SetVisible(self.SkillIcon2.gameObject, true)
    SetVisible(self.SkillArrow.gameObject, true)
    SetVisible(self.SkillNoEP.gameObject, false)
    --self.skillUpDescTxt.text = ConfigLanguage.Pet.FullEvolution
end

function PetEvolutionPanel:SkillFullStyle()
    SetAnchoredPosition(self.SkillIcon2, 0, -97.3)
    SetVisible(self.SkillIcon1.gameObject, false)
    SetVisible(self.SkillIcon2.gameObject, true)
    SetVisible(self.SkillArrow.gameObject, false)
    SetVisible(self.SkillNoEP.gameObject, false)
end

function PetEvolutionPanel:SkillNoneStyle()
    SetVisible(self.SkillIcon1.gameObject, false)
    SetVisible(self.SkillIcon2.gameObject, false)
    SetVisible(self.SkillArrow.gameObject, false)
    SetVisible(self.SkillNoEP.gameObject, true)
end

---奥义开放的突破次数
function PetEvolutionPanel:GetMainSkillOpenTimes()
    local key = self.petData.Config.order .. "@" .. (self.petData.Data and self.petData.Data.extra or 0)
    local cfg = Config.db_pet_evolution[key]

    local tabs = {}
    while (cfg) do
        table.insert(tabs, cfg)
        local key = cfg.order
        local times = cfg.times + 1
        cfg = Config.db_pet_evolution[key .. "@" .. times]
    end

    local times = nil
    for _, v in ipairs(tabs) do
        local t = String2Table(v.skill)

        for _, w in ipairs(t) do
            if w[3] == 1 and w[4] == 1 then
                times = v.times
                break
            end
        end
        if (times) then
            break
        end
    end

    return times
end

--------------------------------------更新消耗品显示--------------------------------------
function PetEvolutionPanel:RefreshConsumable()
    local isOverdue = self.petData:CheckOverdue()

    if (not self.petData.IsActive or isOverdue) then
        self:CreateConsumable()
        self:ConsumableInactiveStyle()
        return
    end

    if (not self.CurrValue.IsHadEvolution) then
        self:ConsumableNoneStyle()
    else
        if (self.CurrValue.Extra >= self.CurrValue.EpCount) then
            self:ConsumableFullStyle()
        else
            self:CreateConsumable()
            self:ConsumableNormalStyle()
        end
    end
end

function PetEvolutionPanel:CreateConsumable()
    if (not self.CurrValue.IsHadEvolution) then
        return
    end

    local tab = String2Table(self.CurrValue.NextCfg.cost)
    self.goodItems = self.goodItems or {}

    for i, v in ipairs(tab) do
        local item = self.goodItems[i]
        if (not item) then
            local item = AwardItem(self.GoodParent)
            item:SetNeedData(v[1], v[2])
            item:AddClickTips()
            table.insert(self.goodItems, item)
        else
            SetVisible(self.goodItems[i], true)
            item:SetNeedData(v[1], v[2])
        end
    end

    for i = #tab + 1, #self.goodItems do
        SetVisible(self.goodItems[i], false)
    end
end

function PetEvolutionPanel:ConsumableInactiveStyle()
    self.image3.enabled = true
    self.image4.enabled = true
    self.image5.enabled = false
    self.image6.enabled = false
    SetVisible(self.GoodParent, true)
    SetVisible(self.NoEvolutionTip, false)
    SetVisible(self.FullEvolution, false)
    SetVisible(self.EvolutionBtn, false)
    SetVisible(self.InActiveBtn, true)
    SetVisible(self.SendBackBtn, false)
end

function PetEvolutionPanel:ConsumableNormalStyle()
    self.image3.enabled = true
    self.image4.enabled = true
    self.image5.enabled = false
    self.image6.enabled = false
    SetVisible(self.GoodParent, true)
    SetVisible(self.NoEvolutionTip, false)
    SetVisible(self.FullEvolution, false)
    SetVisible(self.EvolutionBtn, true)
    SetVisible(self.InActiveBtn, false)
    SetVisible(self.SendBackBtn, true)
    SetLocalPositionX(self.SendBackBtn, -72.5)
    if not self.reddot then
        self.reddot = RedDot(self.EvolutionBtn)
        SetLocalPosition(self.reddot.transform, 55, 14)
    end
    if self:CheckCost(false) then
        SetVisible(self.reddot, true)
    else
        SetVisible(self.reddot, false)
    end
end

function PetEvolutionPanel:ConsumableFullStyle()
    self.image3.enabled = false
    self.image4.enabled = false
    self.image5.enabled = true
    self.image6.enabled = true
    SetVisible(self.GoodParent, false)
    SetVisible(self.NoEvolutionTip, false)
    SetVisible(self.FullEvolution, true)
    SetVisible(self.EvolutionBtn, false)
    SetVisible(self.InActiveBtn, false)
    SetVisible(self.SendBackBtn, true)
    SetLocalPositionX(self.SendBackBtn, 0)
end

function PetEvolutionPanel:ConsumableNoneStyle()
    self.image3.enabled = false
    self.image4.enabled = false
    self.image5.enabled = false
    self.image6.enabled = false
    SetVisible(self.GoodParent, false)
    SetVisible(self.NoEvolutionTip, true)
    SetVisible(self.FullEvolution, false)
    SetVisible(self.EvolutionBtn, false)
    SetVisible(self.InActiveBtn, false)
    SetVisible(self.SendBackBtn, false)
end

function PetEvolutionPanel:RefreshView()
    self.CurrValue = self:GetPetCurrValue()

    self:RefreshEpView()
    self:RefreshAttrs()
    self:RefreshSkill()
    self:RefreshConsumable()
end


---检测消耗品是否足够
function PetEvolutionPanel:CheckCost(isNotice)
    local cost = String2Table(self.CurrValue.NextCfg.cost)
    local result = {}
    local isEnough = true

    for _, v in ipairs(cost) do
        local num = BagModel:GetInstance():GetGoldAndItemNumByItemID(v[1])
        if (num < v[2]) then
            local name = Config.db_item[v[1]].name
            table.insert(result, string.format("%s * %s", name, v[2] - num))
            isEnough = false
        end
    end

    if (isNotice and #result > 0) then
        Notify.ShowText("Insufficient:" .. table.concat(result, " , "))
    end

    return isEnough
end

function PetEvolutionPanel:GetPetCurrValue()
    local epCount = self.petData.Config.evolution
    local isHadEvolution = (epCount > 0)

    local extra = self.petData.IsActive and self.petData.Data.extra or 0
    local cfgKey = self.petData.Config.order .. "@" .. extra
    local currCfg = Config.db_pet_evolution[cfgKey]

    if not isHadEvolution then
        return {
            ["IsHadEvolution"] = isHadEvolution,
            ["EpCount"] = epCount,
            ["Extra"] = extra,
            ["CurrCfg"] = currCfg
        }
    end

    local nextExtra = math.min(epCount, extra + 1)
    local nextCfg = nil

    if (extra >= epCount) then
        nextCfg = currCfg
    else
        cfgKey = self.petData.Config.order .. "@" .. nextExtra
        nextCfg = Config.db_pet_evolution[cfgKey]
    end

    return {
        ["IsHadEvolution"] = isHadEvolution,
        ["EpCount"] = epCount,
        ["Extra"] = extra,
        ["NextExtra"] = nextExtra,
        ["CurrCfg"] = currCfg,
        ["NextCfg"] = nextCfg
    }
end
