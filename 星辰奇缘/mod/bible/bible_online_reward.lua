BibleOnlineRewardPanel = BibleOnlineRewardPanel or BaseClass(BasePanel)

function BibleOnlineRewardPanel:__init(model, parent)
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

    self.updateListner = function() self:SetTarget() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    -- 抽奖位置的伪乱序
    self.idToPos = {}
    local p = 1
    local cc = 0
    local c = RoleManager.Instance.RoleData.id % 3 + 1
    while (true) do
        cc = cc + 1
        if cc == 1000 then
            Log.Error("算法有问题，好好查查")
            break
        end
        if self.idToPos[c] == nil then
            self.idToPos[c] = p
            p = p + 1
            c = (c + 3) % 8 + 1
            if p == 9 then
                break
            end
        else
            c = c % 8 + 1
        end
    end
end

function BibleOnlineRewardPanel:__delete()
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

function BibleOnlineRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_onlinereward_panel))
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    UIUtils.AddBigbg(t:Find("RotaryTable/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.rotary_table)))
    UIUtils.AddBigbg(t:Find("Rabit"), GameObject.Instantiate(self:GetPrefab(AssetConfig.rotary_rabit)))
    self.desc = GameObject.Instantiate(t:Find("RotaryTable/Ball/Time").gameObject)
    self.desc.name = "Desc"
    UIUtils.AddUIChild(t:Find("RotaryTable").gameObject, self.desc)
    self.desc.transform:GetComponent(Text).text = TI18N("<color='#B1E5F5'>此转盘各项奖励概率均等</color>")
    self.desc.transform:GetComponent(Text).fontSize = 16
    local rect = self.desc:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0.5,0.5)
    rect.anchorMin = Vector2(0.5,0.5)
    self.desc.transform.sizeDelta = Vector2(260,44)
    self.desc.transform.anchoredPosition = Vector2(0,-220)


    local noticeBtn = GameObject("Notice")
    local rect_1 = noticeBtn:AddComponent(RectTransform)
    UIUtils.AddUIChild(t:Find("RotaryTable").gameObject, noticeBtn)
    local img_1 = noticeBtn:AddComponent(Image)
    img_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIconBg1")
    local btn_1 = noticeBtn:AddComponent(Button)
    btn_1.onClick:AddListener(function() TipsManager.Instance.model:ShowChance({gameObject = noticeBtn, chanceId = 210, special = true, isMutil = false}) end)
    rect_1.anchorMax = Vector2(0.5,0.5)
    rect_1.anchorMin = Vector2(0.5,0.5)
    rect_1.pivot = Vector2(0.5,0.5)
    noticeBtn.transform.sizeDelta = Vector2(30,30)
    noticeBtn.transform.anchoredPosition = Vector2(-110,-220)

    local noticeImage = GameObject("image")
    local rect_2 = noticeImage:AddComponent(RectTransform)
    local img_2 = noticeImage:AddComponent(Image)
    img_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIcon3")
    UIUtils.AddUIChild(noticeBtn, noticeImage)
    rect_2.anchorMax = Vector2(1,1)
    rect_2.anchorMin = Vector2(0,0)
    rect_2.pivot = Vector2(0.5,0.5)
    rect_2.offsetMin = Vector2(10, 4)
    rect_2.offsetMax = Vector2(-10, -4)

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

function BibleOnlineRewardPanel:OnInitCompleted()
    self.campaignIds = {}
    for id,v in pairs(DataCampaign.data_list) do
        if tonumber(v.iconid) == self.campaignType and v.index == self.mainType then
            table.insert(self.campaignIds, id)
        end
    end
    table.sort(self.campaignIds, function(a,b) return DataCampaign.data_list[a].group_index < DataCampaign.data_list[a].group_index end)
    self.OnOpenEvent:Fire()
end

function BibleOnlineRewardPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListner)
    self.openList = {}

    self:SetTarget()
    self:Reload()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 300, function() self:OnTime() end)
    end
end

function BibleOnlineRewardPanel:OnHide()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil

        if self.onHideTarget ~= nil then
            print(self.onHideTarget)
            local reward = DataCampaign.data_list[self.onHideTarget].reward[1]
            BaseUtils.dump(reward)
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("获得奖励{item_2, %s, 0, %s}"), tostring(reward[1]), tostring(reward[2])))
        end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self:RemoveListeners()
end

function BibleOnlineRewardPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListner)
end

function BibleOnlineRewardPanel:Reload()
    if self.tweenId ~= nil then
        -- 如果正在转就不要刷新
        return
    end
    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.OnLine])
    local b = false
    for _,id in ipairs(self.campaignIds) do
        local campaignData = DataCampaign.data_list[id]
        local tab = self.itemList[self.idToPos[campaignData.group_index]]
        local status = (CampaignManager.Instance.campaignTab[id] or {}).status
        if tab.data.base_id ~= campaignData.reward[1][1] then
            tab.data:SetBase(DataItem.data_get[campaignData.reward[1][1]])
            tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
            tab.slot:SetNum(campaignData.reward[1][2])
        end
        if campaignData.effect_id == 1 then
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
        -- BaseUtils.dump(CampaignManager.Instance.campaignTree[CampaignEumn.Type.OnLine])
        b = b or (status == CampaignEumn.Status.Finish)
        -- tab.get:SetActive(status == CampaignEumn.Status.Accepted)
        tab.get:SetActive(self.openList[id] ~= nil)
    end

    if b and (self.rewardStamp == 0 or self.tweenId ~= nil) then
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
function BibleOnlineRewardPanel:OnRotary()
    if self.rewardStamp == -1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("所有奖励已领取"))
    elseif self.rewardStamp == 0 then
        if BackpackManager.Instance:GetCurrentGirdNum() > 0 then
            self.openList = {}
            self:Reload()
            for i,id in ipairs(self.campaignIds) do
                if (CampaignManager.Instance.campaignTab[id] or {}).status == CampaignEumn.Status.Finish then
                    CampaignManager.Instance:Send14001(id)

                    local reward = DataCampaign.data_list[id].reward[1]
                    self.openList[id] = 1
                    self:DoRotate(function()
                        -- NoticeManager.Instance:FloatTipsByString(string.format(TI18N("获得奖励{item_2, %s, 0, %s}"), tostring(reward[1]), tostring(reward[2])))
                        OpenServerManager.Instance:OpenRewardPanel({{id = reward[1], num = reward[3]}, TI18N("确定"), 3})
                        self:Reload()
                    end)
                    return
                end
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理背包"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("当前还不可抽奖哦，请稍后再试{face_1,7}"))
    end
end

-- 计算应该“抽”哪个
function BibleOnlineRewardPanel:SetTarget()
    self.target = nil
    self.isDone = true
    for i,id in ipairs(self.campaignIds) do
        local status = (CampaignManager.Instance.campaignTab[id] or {}).status
        self.isDone = self.isDone and (status == CampaignEumn.Status.Accepted)
        if status == CampaignEumn.Status.Finish then
            self.target = DataCampaign.data_list[id].group_index
            self.onHideTarget = id
            break
        end
    end
    self:CalLeftTime()
end

function BibleOnlineRewardPanel:DoRotate(callback)
    self.stopCallback = callback

    if self.effect ~= nil then
        self.effect:SetActive(false)
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.target == nil then
        self.tweenId = Tween.Instance:ValueChange(self.pointer.rotation.eulerAngles.z, self.pointer.rotation.eulerAngles.z + 360, 1, function() self.tweenId = nil self:DoRotate(callback) end, LeanTweenType.Linear, function(value) self:SetPointer(value) end).id
    else
        self:DoRotateStop(self.target, callback)
    end
end

function BibleOnlineRewardPanel:DoRotateStop(i, callback)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    self.tweenId = Tween.Instance:ValueChange(self.pointer.rotation.eulerAngles.z % 360, -22.5 - 80 * 360 - 45 * (self.idToPos[i] - 1), 4, function() self.tweenId = nil if callback ~= nil then callback() end end, LeanTweenType.easeInOutQuad, function(value) self:SetPointer(value) end).id
end

function BibleOnlineRewardPanel:SetPointer(theta)
    self.pointer.anchoredPosition = Vector2(88.8 * math.cos((theta + 90) * math.pi / 180), 88.8 * math.sin((theta + 90) * math.pi / 180))
    self.pointer.localRotation = Quaternion.Euler(0, 0, theta)
end

function BibleOnlineRewardPanel:OnTime()
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
        if time < 0 then time = 0 end
        self.timeText.text = string.format(TI18N("下次抽奖\n%s"), ColorHelper.Fill("#00ff00", BaseUtils.formate_time_gap(time,":",0,BaseUtils.time_formate.HOUR)))
    end
end

function BibleOnlineRewardPanel:CalLeftTime()
    self.rewardStamp = -1                   -- 目标时间戳
    for i,id in ipairs(self.campaignIds) do
        local status = (CampaignManager.Instance.campaignTab[id] or {}).status
        local protoData = CampaignManager.Instance.campaignTab[id] or {target_val = 0, ext_val = 0, value = 0}
        if status == CampaignEumn.Status.Doing then
            local compareSec = 120 - (BaseUtils.BASE_TIME - protoData.ext_val)
            local time = protoData.target_val - (BaseUtils.BASE_TIME - (protoData.ext_val - protoData.value))
            time = math.max(compareSec,time)
            self.rewardStamp = time + BaseUtils.BASE_TIME
            break
        elseif status == CampaignEumn.Status.Finish then
            self.rewardStamp = 0
        end
    end
end

