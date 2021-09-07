TowerRewardWindow = TowerRewardWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function TowerRewardWindow:__init(model)
    self.model = model

    self.name = "TowerRewardWindow"
    self.dunMgr = self.model.dunMgr
    self.currselect = nil
    self.resList = {
        {file = AssetConfig.towerreward, type = AssetType.Main}
        ,{file = "textures/dungeon/towerreward.unity3d", type = AssetType.Dep}
    }
    self.TowerName = {
        [1] = TI18N("一层"),
        [2] = TI18N("二层"),
        [3] = TI18N("三层"),
    }
    self.slotList = {}
end



function TowerRewardWindow:__delete()
    for i,v in ipairs(self.slotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slotList = nil

    self:ClearDepAsset()
end

function TowerRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.towerreward))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.Con = self.transform:Find("Main/Con")
    self.StatueText = self.transform:Find("Main/Con/Text"):GetComponent(Text)
    self.bot_btn = self.Con:Find("bot"):GetComponent(Button)
    self.mid_btn = self.Con:Find("mid"):GetComponent(Button)
    self.top_btn = self.Con:Find("top"):GetComponent(Button)
    self.helpCon = self.Con:Find("HelpCon")

    self.slotGroup = {
    [1] = self.Con:Find("SubCon/slot1"),
    [2] = self.Con:Find("SubCon/slot2"),
    [3] = self.Con:Find("SubCon/slot3"),
    [4] = self.Con:Find("SubCon/slot4"),
    }
    self.tabGroup = {
    [1] = self.bot_btn,
    [2] = self.mid_btn,
    [3] = self.top_btn,
    }
    self.bot_btn.onClick:AddListener(function () self:OnBtnTower(1) end)
    self.mid_btn.onClick:AddListener(function () self:OnBtnTower(2) end)
    self.top_btn.onClick:AddListener(function () self:OnBtnTower(3) end)
    self.bot_btn.gameObject.transform:Find("Red").gameObject:SetActive(self.dunMgr.towerRewardList[1] == true)
    self.mid_btn.gameObject.transform:Find("Red").gameObject:SetActive(self.dunMgr.towerRewardList[2] == true)
    self.top_btn.gameObject.transform:Find("Red").gameObject:SetActive(self.dunMgr.towerRewardList[3] == true)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    self.getBtn = self.transform:Find("Main/Con/Button")
    self.notext = self.transform:Find("Main/Con/NoText")
    self.getBtn:GetComponent(Button).onClick:AddListener(function () self:GetReward() end)
    self.Con = self.transform:Find("Main/Con")
    for i = 0, 4 do
        if i == 2 or i == 3 then
            self.Con:GetChild(i).gameObject:SetActive(false)
        else
            self.Con:GetChild(i).anchoredPosition = self.Con:GetChild(i).anchoredPosition + Vector2(63, 0)
        end
    end
    local hasget = false
    for i,v in ipairs(self.dunMgr.towerRewardList) do
        if v then
            hasget = true
        end
    end
    if self.dunMgr.tower_floor ~= 0 and not hasget then
        if self.dunMgr.tower_floor == 3 then
            self:OnBtnTower(1)
        else
            self:OnBtnTower(self.dunMgr.tower_floor)
        end
    else
        if self.dunMgr.towerRewardList[1] and self.currselect == nil then
            self:OnBtnTower(1)
        elseif self.dunMgr.towerRewardList[2] and self.currselect == nil then
            self:OnBtnTower(2)
        -- elseif self.dunMgr.towerRewardList[3] and self.currselect == nil then
        --     self:OnBtnTower(3)
        end
    end
    self.helpCon:Find("Text"):GetComponent(Text).text = TI18N("与<color='#248813'>低于55级</color>并低于自己<color='#248813'>10</color>级的玩家共同完成四场挑战可获得奖励")
    self.dunMgr:Require14305()
    self:SetHelpInfo()
end

function TowerRewardWindow:OnClose()
    self.model:CloseTowerReward()
end

function TowerRewardWindow:OnBtnTower(index)
    self.currbaseData = nil
    local lev = RoleManager.Instance.RoleData.lev
    for i,v in ipairs(DataDungeonTower.data_gain) do
        if v.floor == index and lev>= v.lev_low and lev <= v.lev_high then
            self.currbaseData = v
        end
    end

    if self.currselect == nil or self.currselect ~= index then
        if self.currselect ~= nil then
            self.tabGroup[self.currselect].gameObject.transform:Find("Select").gameObject:SetActive(false)
        end
        self.currselect = index
        if self.tabGroup ~= nil then
            self.tabGroup[self.currselect].gameObject.transform:Find("Select").gameObject:SetActive(true)
        end
        self:OnTabChange(index)
    end

end

function TowerRewardWindow:OnTabChange(index)
    self:Clear()
    if self.currbaseData == nil then
        Log.Error("[塔][Error]塔奖励数据读不到")
        return
    end
    for i,v in ipairs(self.currbaseData.items) do
        local parent = self.slotGroup[i]
        if parent ~= nil then
            local slot = self:AddSlot(v[1], v[3], parent)
            self.slotList[i] = slot
        end
    end
    if index>1 then
        self.transform:Find("Main").sizeDelta = Vector2(466, 312)
    else
        self.transform:Find("Main").sizeDelta = Vector2(466, 446)
    end
    self:SetText()
end

function TowerRewardWindow:DuangEffect(target, callback)
    local second = function () Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one, 0.5, callback, LeanTweenType.easeOutElastic)   end
    local descr1 = Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one*0.7, 0.2, second, LeanTweenType.linear)
end

function TowerRewardWindow:AddSlot(base_id, num, parent)
    local base = DataItem.data_get[base_id]
    local slot = ItemSlot.New()
    local info = ItemData.New()
    info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    slot:SetNum(num)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
    return slot
end

function TowerRewardWindow:Clear()
    for i,v in pairs(self.slotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slotList = {}

    for i,v in ipairs(self.slotGroup) do
        if v.childCount ~= 0 then
            GameObject.DestroyImmediate(v:GetChild(0).gameObject)
        end
    end
end

function TowerRewardWindow:SetText()
    self.killed = 0
    self.is_pass_gain = 0
    local data = self.dunMgr.tower_status_data
    -- BaseUtils.dump(data, "当前数据啊啊啊啊啊啊啊")
    if data == nil then

    else
        for k,v in pairs(data) do
            if v.floor == self.currselect then
                self.killed = #v.unit_list
                self.is_pass_gain = v.is_pass_gain
            end
        end
    end
    if self.killed == 4 then
        self.getBtn.gameObject:SetActive(true)
        self.notext.gameObject:SetActive(false)
        self.StatueText.text = string.format(TI18N("击杀天空之塔<color='#248813'>%s</color>全部4名BOSS可领取宝箱奖励（<color='#248813'>%s/4</color>）： "), self.TowerName[self.currselect], tostring(self.killed))
    else
        self.getBtn.gameObject:SetActive(false)
        self.notext.gameObject:SetActive(true)
        self.StatueText.text = string.format(TI18N("击杀天空之塔<color='#248813'>%s</color>全部4名BOSS可领取宝箱奖励（<color='#c3692c'>%s/4</color>）： "), self.TowerName[self.currselect], tostring(self.killed))
    end
    if self.is_pass_gain == 1 then
        self.getBtn:GetComponent(Image).enabled = false
        self.getBtn:Find("Text"):GetComponent(Text).text = TI18N("已领取")
        self.getBtn:GetComponent(Button).onClick:RemoveAllListeners()
    else
        self.getBtn:GetComponent(Image).enabled = true
        self.getBtn:Find("Text"):GetComponent(Text).text = TI18N("领取奖励")
        self.getBtn:GetComponent(Button).onClick:RemoveAllListeners()
        self.getBtn:GetComponent(Button).onClick:AddListener(function () self:GetReward() end)
    end

end

function TowerRewardWindow:GetReward()
    if self.killed == 4 then
        self.dunMgr:Require14302(self.currselect)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("未满足领取条件"))
    end
    -- self:OnClose()
end

function TowerRewardWindow:SetHelpInfo()
    local gain_data = DataDungeonTower.data_help_gain[1].help_gain
    -- BaseUtils.dump(gain_data,"+++++++++++++++++++++")
    for i,v in ipairs(gain_data) do
        if i <= 4 then
            local slot = self.helpCon:Find(string.format("slot%s", tostring(i)))
            self:AddSlot(v[1], v[2], slot)
        end
    end

end

--466 446
--466 312

function TowerRewardWindow:SetHelpText(num)
    self.helpCon:Find("Text"):GetComponent(Text).text = string.format(TI18N("带<color='#248813'>40-54</color>级玩家（且低于自身10级以上）完成任意<color='#ffff00'>4</color>场战斗可获得奖励（%s/4）"), tostring(num))
end

function TowerRewardWindow:UpdateTowerSelect()
    if self.dunMgr.towerRewardList[1] then
        self:OnBtnTower(1)
    elseif self.dunMgr.towerRewardList[2] then
        self:OnBtnTower(2)
    elseif self.dunMgr.towerRewardList[3] then
        self:OnBtnTower(3)
    end

    if self.bot_btn ~= nil then 
        self.bot_btn.gameObject.transform:Find("Red").gameObject:SetActive(self.dunMgr.towerRewardList[1] == true)
    end

    if self.mid_btn ~= nil then 
        self.mid_btn.gameObject.transform:Find("Red").gameObject:SetActive(self.dunMgr.towerRewardList[2] == true)
    end

    if self.top_btn ~= nil then 
        self.top_btn.gameObject.transform:Find("Red").gameObject:SetActive(self.dunMgr.towerRewardList[3] == true)
    end
end
