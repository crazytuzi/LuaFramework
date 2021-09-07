OpenServerRotary = OpenServerRotary or BaseClass(BasePanel)

function OpenServerRotary:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.bible_onlinereward_panel, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
        {file = AssetConfig.rotary_table, type = AssetType.Main},
        {file = AssetConfig.rotary_rabit, type = AssetType.Main},
    }

    self.openList = nil
    self.itemList = {}
    self.campaignIds = nil
    self.effectMark = nil

    self.updateListner = function(data) if data ~= nil then self:SetTarget(data) end self:CalLeftTime() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerRotary:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
                if v.effect ~= nil then
                    v.effect:DeleteMe()
                end
            end
        end
        self.itemList = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self:AssetClearAll()
end

function OpenServerRotary:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_onlinereward_panel))
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    UIUtils.AddBigbg(t:Find("RotaryTable/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.rotary_table)))
    UIUtils.AddBigbg(t:Find("Rabit"), GameObject.Instantiate(self:GetPrefab(AssetConfig.rotary_rabit)))

    self.timeText = t:Find("RotaryTable/Ball/Time"):GetComponent(Text)
    self.pointer = t:Find("RotaryTable/Pointer")
    self.ball = t:Find("RotaryTable/Ball")
    t:Find("RotaryTable/Ball"):GetComponent(Button).onClick:AddListener(function() self:OnRotary() end)

    local itemCon = t:Find("RotaryTable/Items")
    for i=1,8 do
        local tab = {}
        tab.transform = itemCon:GetChild(i - 1)
        tab.slot = ItemSlot.New()
        tab.data = ItemData.New()
        tab.get = tab.transform:Find("Mask/Get").gameObject
        tab.rare = tab.transform:Find("Mask/Rare").gameObject
        NumberpadPanel.AddUIChild(tab.transform, tab.slot.gameObject)
        tab.transform:GetComponent(Button).onClick:AddListener(function() tab.slot.button.onClick:Invoke() end)
        tab.slot.transform:SetAsFirstSibling()
        tab.rare:SetActive(false)
        self.itemList[i] = tab
    end
end

function OpenServerRotary:OnInitCompleted()
    self.campaignIds = {}
    for id,v in pairs(DataCampaign.data_list) do
        if tonumber(v.iconid) == self.campaignType and v.index == self.mainType then
            table.insert(self.campaignIds, id)
        end
    end
    table.sort(self.campaignIds, function(a,b) return DataCampaign.data_list[a].group_index < DataCampaign.data_list[a].group_index end)
    self.effectMark = BaseUtils.unserialize(DataCampaign.data_list[self.campaignIds[1]].camp_cond_client)
    self.OnOpenEvent:Fire()
end

function OpenServerRotary:OnOpen()
    self:RemoveListeners()
    OpenServerManager.Instance.rotaryEvent:AddListener(self.updateListner)
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListner)
    self.openList = {}

    self:SetTarget()
    self:Reload()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 300, function() self:OnTime(true) end)
    end
end

function OpenServerRotary:OnHide()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil

        if self.target ~= nil then
            local reward = CampaignManager.ItemFilter(DataCampaign.data_list[self.campaignIds[1]].reward)[self.target]
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("获得奖励{item_2, %s, 0, %s}"), tostring(reward[1]), tostring(reward[2])))
        end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self:RemoveListeners()
end

function OpenServerRotary:RemoveListeners()
    OpenServerManager.Instance.rotaryEvent:RemoveListener(self.updateListner)
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListner)
end

function OpenServerRotary:Reload()
    if self.tweenId ~= nil then
        -- 如果正在转就不要刷新
        return
    end
    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.OnLine])
    local b = false
    for i,reward in ipairs(CampaignManager.ItemFilter(DataCampaign.data_list[self.campaignIds[1]].reward)) do
        local tab = self.itemList[i]
        if tab.data.base_id ~= reward[1] then
            tab.data:SetBase(DataItem.data_get[reward[1]])
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
            tab.slot:SetNum(reward[2])
        end
        if self.effectMark[i] == 1 then
            if tab.effect ~= nil then
                tab.effect:SetActive(true)
            else
                tab.effect = BibleRewardPanel.ShowEffect(20223, tab.slot.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            end
        else
            if tab.effect ~= nil then
                tab.effect:SetActive(false)
            end
        end
        tab.get:SetActive(self.openList[i] ~= nil)
    end

    for _,id in ipairs(self.campaignIds) do
        b = b or ((CampaignManager.Instance.campaignTab[id] or {}).status == CampaignEumn.Status.Finish)
    end

    if b and (self.rewardStamp == 0) then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20273, self.ball, Vector3(1, 1, 1), Vector3(0, 0, -400))
        else
            self.effect:SetActive(true)
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end
end

-- 点击抽奖
function OpenServerRotary:OnRotary()
    -- 测试代码
    -- self.rewardStamp = 0
    -- LuaTimer.Add(300, function() self.target = 5 self.openList[5] = 1  end)

    if self.rewardStamp == -1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("所有奖励已领取"))
    elseif self.rewardStamp == 0 then
        if BackpackManager.Instance:GetCurrentGirdNum() > 0 then
            self.openList = {}
            self:Reload()

            -- print("=====================================1")
            -- OpenServerManager.Instance:Send14098()

            for _,id in ipairs(self.campaignIds) do
                if (CampaignManager.Instance.campaignTab[id] or {}).status == CampaignEumn.Status.Finish then
                    CampaignManager.Instance:Send14001(id)
                    break
                end
            end

            local reward = CampaignManager.ItemFilter(DataCampaign.data_list[self.campaignIds[1]].reward)
            self:DoRotate(function()
                if self.target ~= nil then
                    -- NoticeManager.Instance:FloatTipsByString(string.format(TI18N("获得奖励{item_2, %s, 0, %s}"), tostring(reward[self.target][1]), tostring(reward[self.target][2])))
                    OpenServerManager.Instance:OpenRewardPanel({{id = reward[self.target][1], num = reward[self.target][2]}, TI18N("确定"), 3})
                end
                self.target = nil
                self:Reload()
                self:CalLeftTime()
                self:OnTime()
            end)

            -- LuaTimer.Add(1000, function() print("=====================================2") OpenServerManager.Instance:On14098({camp_id = 501, base_id = 90000}) end)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理背包"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("当前还不可抽奖哦，请稍后再试{face_1,7}"))
    end
end

-- 计算应该“抽”哪个
function OpenServerRotary:SetTarget(data)
    data = data or {}
    self.target = nil
    self.isDone = true

    if data.base_id ~= nil then
        self.target = data.base_id
        self.openList[data.base_id] = 1
    end
end

function OpenServerRotary:DoRotate(callback)
    self.stopCallback = callback

    if self.effect ~= nil then
        self.effect:SetActive(false)
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.target == nil then
        self.tweenId = Tween.Instance:ValueChange(self.pointer.rotation.eulerAngles.z, self.pointer.rotation.eulerAngles.z - 360, 1, function() self.tweenId = nil self:DoRotate(callback) end, LeanTweenType.Linear, function(value) self:SetPointer(value) end).id
    else
        self:DoRotateStop(self.target, callback)
    end
end

function OpenServerRotary:DoRotateStop(i, callback)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    self.tweenId = Tween.Instance:ValueChange(self.pointer.rotation.eulerAngles.z, -22.5 - 10 * 360 - 45 * (i - 1), 3.5, function() self.tweenId = nil if callback ~= nil then callback() end end, LeanTweenType.easeInOutQuad, function(value) self:SetPointer(value) end).id
end

function OpenServerRotary:SetPointer(theta)
    self.pointer.anchoredPosition = Vector2(88.8 * math.cos((theta + 90) * math.pi / 180), 88.8 * math.sin((theta + 90) * math.pi / 180))
    self.pointer.localRotation = Quaternion.Euler(0, 0, theta)
end

function OpenServerRotary:OnTime(status)
    if self.tweenId ~= nil then
        self.timeText.text = TI18N("正在抽奖")
    elseif self.rewardStamp == nil then
        self:CalLeftTime()
        self:OnTime()
    elseif self.rewardStamp == -1 then      -- 全完成了
        self.timeText.text = TI18N("已完成")
    elseif self.rewardStamp == 0 then       -- 又一个完成了
        self.timeText.text = TI18N("马上抽奖")
    else                                    -- 倒计时中
        local time = self.rewardStamp - BaseUtils.BASE_TIME
        if time < 0 then
            if status == true then
                self:OnTime(false)
                self:CalLeftTime()
                self:Reload()
            else
                self.timeText.text = string.format(TI18N("下次抽奖\n%s"), ColorHelper.Fill("#00ff00", BaseUtils.formate_time_gap(0,":",0,BaseUtils.time_formate.HOUR)))
            end
        else
            self.timeText.text = string.format(TI18N("下次抽奖\n%s"), ColorHelper.Fill("#00ff00", BaseUtils.formate_time_gap(time,":",0,BaseUtils.time_formate.HOUR)))
        end
    end
end

function OpenServerRotary:CalLeftTime()
    self.rewardStamp = -1                   -- 目标时间戳
    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer][CampaignEumn.OpenServerType.Online])
    for i,id in ipairs(self.campaignIds) do
        local status = (CampaignManager.Instance.campaignTab[id] or {}).status
        local protoData = CampaignManager.Instance.campaignTab[id] or {target_val = 0, ext_val = 0, value = 0, status = CampaignEumn.Status.Doing}
        if status == CampaignEumn.Status.Finish then
            self.rewardStamp = 0
            break
        elseif status == CampaignEumn.Status.Doing then
            local compareSec = 120 - (BaseUtils.BASE_TIME - protoData.ext_val)
            local time = protoData.target_val - (BaseUtils.BASE_TIME - (protoData.ext_val - protoData.value))
            time = math.max(compareSec,time)

            self.rewardStamp = time + BaseUtils.BASE_TIME
            break
        end
    end
end

