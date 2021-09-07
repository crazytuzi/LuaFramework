MainuiTraceHalloween = MainuiTraceHalloween or BaseClass(BaseTracePanel)

local GameObject = UnityEngine.GameObject

function MainuiTraceHalloween:__init(main)
    self.main = main
    self.isInit = false
    self.currId = nil
    self.task_item = nil
    self.base_taskData = nil

    self.resList = {
        {file = AssetConfig.mainui_trace_halloween, type = AssetType.Main},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
    }

    self.skillId = {
        {base_id = 82180, cd = 60},
        {base_id = 82181, cd = 60},
    }

    self.itemObject = nil
    self.container_transform = nil
    self.button = nil

    self.nameText_List = {}
    self.timesText_List1 = {}
    self.timesText_List2 = {}
    self.scoreText_List = {}
    self.camp_List = {}
    self.isUp = {}
    self.canUseSkill = {}

    self.camp = nil
    self.campText = nil

    -- self._Update = function() self:Update() end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceHalloween:__delete()
    self.OnHideEvent:Fire()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    for i,v in ipairs(self.slotList) do
        if v.arrowEffect ~= nil then
            v.arrowEffect:DeleteMe()
            v.arrowEffect = nil
        end
        if v.slot ~= nil then
            v.slot:DeleteMe()
            v.slot = nil
        end
    end
    self.slotList = nil
end

function MainuiTraceHalloween:Init()
end

function MainuiTraceHalloween:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mainui_trace_halloween))
    self.gameObject.name = "MainuiTraceHalloween"

    self.transform = self.gameObject.transform

    local transform = self.transform
    transform:SetParent(self.main.mainObj.transform)
    transform.localScale = Vector3.one
    transform.anchoredPosition = Vector2(0, -47)

    -- self.itemObject = transform:FindChild("Panel/Rank/Item").gameObject
    -- self.itemObject:SetActive(false)
    transform:Find("Panel/RankTitle").gameObject:SetActive(false)
    transform:Find("Panel/Rank").gameObject:SetActive(false)
    self.container_transform = transform:FindChild("Panel/Rank/Mask/Container")

    self.button = transform:FindChild("Panel/Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:button_click() end)
    self.button:SetActive(false)

    self.nameText_List = {}
    self.timesText_List1 = {}
    self.timesText_List2 = {}
    self.scoreText_List = {}
    self.camp_List = {}
    -- for i=1, 10 do
    --     local item = GameObject.Instantiate(self.itemObject)
    --     UIUtils.AddUIChild(self.container_transform, item)

    --     table.insert(self.nameText_List, item.transform:FindChild("Name"):GetComponent(Text))
    --     table.insert(self.timesText_List1, item.transform:FindChild("Times1"):GetComponent(Text))
    --     table.insert(self.timesText_List2, item.transform:FindChild("Times2"):GetComponent(Text))
    --     table.insert(self.scoreText_List, item.transform:FindChild("Score"):GetComponent(Text))
    --     table.insert(self.camp_List, item.transform:FindChild("Camp"))
    -- end

    self.slotList = {}
    self.skillContainer = transform:Find("Panel/SkillArea")
    for i=1,2 do
        self.slotList[i] = {}
        local slot = SkillSlot.New()
        NumberpadPanel.AddUIChild(self.skillContainer:GetChild(i - 1).gameObject, slot.gameObject)
        local trans = self.skillContainer:GetChild(i - 1)
        local nameText = trans:Find("Name"):GetComponent(Text)
        slot.gameObject.transform:SetAsFirstSibling()
        self.slotList[i].slot = slot
        self.slotList[i].maskImg = trans:Find("Mask"):GetComponent(Image)
        self.slotList[i].timeText = trans:Find("Time"):GetComponent(Text)
        self.slotList[i].nameText = nameText
        self.slotList[i].customButton = trans:GetComponent(CustomButton)

        local j = i
        if i == 1 then
            slot:SetAll(Skilltype.petskill, DataSkill.data_skill_other[self.skillId[i].base_id])
        else
            slot:SetAll(Skilltype.wingskill, DataSkill.data_skill_other[self.skillId[i].base_id])
        end
        self.slotList[i].customButton.onDown:AddListener(function() self:OnDown(j) end)
        self.slotList[i].customButton.onUp:AddListener(function() self:OnUp(j) end)
        self.slotList[i].customButton.onHold:AddListener(function() self:OnHold(j) end)
        self.slotList[i].customButton.onClick:AddListener(function() self:OnClick(j) end)
        nameText.text = DataSkill.data_skill_other[self.skillId[i].base_id].name
    end

    self.camp = transform:FindChild("Panel/Camp")
    self.campText = self.camp.transform:FindChild("CampText"):GetComponent(Text)

    self.isInit = true
end

function MainuiTraceHalloween:OnInitCompleted()
    self:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function MainuiTraceHalloween:OnShow()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 100, function() self:OnTime() end)
    self.gameObject:SetActive(true)
    -- self:Update()
end

function MainuiTraceHalloween:OnHide()
    self.gameObject:SetActive(false)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    for i,v in ipairs(self.slotList) do
        if v.arrowEffect ~= nil then
            v.arrowEffect:SetActive(false)
        end
    end
end

function MainuiTraceHalloween:Update()
    local rank_data = HalloweenManager.Instance.model.rank_list
    local myCamp = 1
    local roleData = RoleManager.Instance.RoleData
    for i=1, #rank_data do
        local data = rank_data[i]
        self.nameText_List[i].text = data.name
        self.timesText_List1[i].text = tostring(data.win)
        self.timesText_List2[i].text = tostring(data.die)
        self.scoreText_List[i].text = tostring(data.score)
        if data.camp == 1 then
            self.camp_List[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "FlagRed")
        else
            self.camp_List[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "FlagBule")
        end

        if roleData.id == data.rid and roleData.platform == data.platform and roleData.zone_id == data.r_zone_id then
            myCamp = data.camp
        end
    end

    if myCamp == 1 then
        self.camp:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "FlagRed")
        self.campText.text = "红方"
    else
        self.camp:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "FlagBule")
        self.campText.text = "蓝方"
    end
end

function MainuiTraceHalloween:button_click()
    HalloweenManager.Instance:Send17802()
end

function MainuiTraceHalloween:OnTime()
    for i,v in ipairs(self.slotList) do
        local dis = ((HalloweenManager.Instance.model.skillStatusList[self.skillId[i].base_id] or {}).timestamp or 0) - BaseUtils.BASE_TIME
        if dis > 0 then
            self.canUseSkill[i] = false
            v.maskImg.fillAmount = dis / self.skillId[i].cd
            v.timeText.gameObject:SetActive(true)
            if dis > 30 then
                v.timeText.text = string.format("<color='#00ff00'>%smin</color>", math.ceil(dis / 60))
            else
                v.timeText.text = string.format("<color='#00ff00'>%s</color>", dis)
            end
        else
            self.canUseSkill[i] = true
            v.maskImg.fillAmount = 0
            v.timeText.gameObject:SetActive(false)
        end
    end
end

function MainuiTraceHalloween:OnHold(index)
    TipsManager.Instance:ShowText({gameObject = self.slotList[index].slot.gameObject, itemData = {DataSkill.data_skill_other[self.skillId[index].base_id].desc}})
end

function MainuiTraceHalloween:ShowHoldEffect(i, bool)
    if bool ~= false then
        if self.slotList[i].arrowEffect == nil then
            self.slotList[i].arrowEffect = BibleRewardPanel.ShowEffect(20009, self.slotList[i].slot.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            self.slotList[i].arrowEffect:SetActive(true)
        end
    else
        if self.slotList[i].arrowEffect ~= nil then
            self.slotList[i].arrowEffect:SetActive(false)
        end
    end
end

function MainuiTraceHalloween:OnDown(index)
    self.isUp[index] = false
    self.canClick = true
    LuaTimer.Add(150, function()
        if self.isUp[index] ~= false then
            return
        end
        self:ShowHoldEffect(index)
        self.canClick = false
    end)
end

function MainuiTraceHalloween:OnUp(index)
    self.isUp[index] = true
    self:ShowHoldEffect(index, false)
end

function MainuiTraceHalloween:OnClick(index)
    if self.canClick == true then
        if self.canUseSkill[index] == true then
            if index == 1 then
                HalloweenManager.Instance:send17834()
            elseif index == 2 then
                HalloweenManager.Instance:send17835()
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("技能冷却中"))
        end
    end
end

