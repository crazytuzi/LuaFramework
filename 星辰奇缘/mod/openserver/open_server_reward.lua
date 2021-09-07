OpenServerReward = OpenServerReward or BaseClass(BasePanel)

function OpenServerReward:__init(model, parent)
    self.model = model
    self.Mgr = OpenServerManager.Instance
    self.parent = parent
    self.name = "OpenServerReward"

    self.resList = {
        {file = AssetConfig.open_server_reward, type = AssetType.Main}
        , {file = AssetConfig.open_server_reward_bg, type = AssetType.Main}
    }

    self.timeFormat1 = TI18N("%s天%s小时")
    self.timeFormat2 = TI18N("%s小时%s分钟")
    self.timeFormat3 = TI18N("%s分钟%s秒")
    self.timeFormat4 = TI18N("%s秒")
    self.timeFormat5 = TI18N("活动已结束")

    self.endTime = 0
    self.rewardList = {}
    self.reloadListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerReward:__delete()
    self.OnHideEvent:Fire()
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                v.layout:DeleteMe()
                v.btnTextExt:DeleteMe()
                v.imageLoader:DeleteMe()
                for _,gift in pairs(v.itemList) do
                    if gift ~= nil then
                        gift.data:DeleteMe()
                        gift.slot:DeleteMe()
                    end
                end
            end
        end
        self.rewardList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self:AssetClearAll()
end

function OpenServerReward:OnOpen()
    self:RemoveListeners()
    self.Mgr.onUpdateReward:AddListener(self.reloadListener)

    self:Reload()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    end
end

function OpenServerReward:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function OpenServerReward:RemoveListeners()
    self.Mgr.onUpdateReward:RemoveListener(self.reloadListener)
end

function OpenServerReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_reward))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.timeText = t:Find("Time/Text"):GetComponent(Text)
    self.container = t:Find("Mask/Container")
    self.cloner = t:Find("Mask/Cloner").gameObject
    t:Find("Mask/Cloner/Mask/Cloner/Slot").anchoredPosition3D = Vector3(0, 0, 0)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, {cspacing = 5, border = 5}})

    self.cloner:SetActive(false)
    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_reward_bg)))
end

function OpenServerReward:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerReward:Reload()
    local datalist = CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer][CampaignEumn.OpenServerType.Reward].sub

    local cli_end_time = DataCampaign.data_list[datalist[1].id].cli_end_time[1]
    self.endTime = CampaignManager.Instance.open_srv_time + cli_end_time[2] * 86400 + cli_end_time[3]
    -- DataCampLimit.data_get_rewards
    self.layout:ReSet()
    -- for i,v in ipairs(datalist) do
        -- local tab = self.rewardList[i]
        -- if tab == nil then
        --     tab = {}
        --     tab.gameObject = GameObject.Instantiate(self.cloner)
        --     tab.transform = tab.gameObject.transform
        --     tab.image = tab.transform:Find("Reward"):GetComponent(Image)
        --     tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        --     tab.layout = LuaBoxLayout.New(tab.transform:Find("Mask/Container"), {cspacing = 0, border = 10})
        --     tab.cloner = tab.transform:Find("Mask/Cloner").gameObject
        --     tab.itemList = {}
        --     tab.origin = tab.transform:Find("OriginPriceI18N").gameObject
        --     tab.originText = tab.transform:Find("OriginPriceI18N/Price"):GetComponent(Text)
        --     tab.button = tab.transform:Find("Button"):GetComponent(Button)
        --     tab.got = tab.transform:Find("Got")
        --     tab.btnTextExt = MsgItemExt.New(tab.transform:Find("Button/Text"):GetComponent(Text), 110, 16, 18.82)
        --     self.rewardList[i] = tab
        --     tab.cloner:SetActive(false)
        -- end
    --     self.layout:AddCell(tab.gameObject)
    --     local campaignBaseData = DataCampaign.data_list[v.id]

    --     local rewardBase = DataItem.data_get[campaignBaseData.reward[1][1]]
    --     tab.nameText.text = rewardBase.name
    --     tab.layout:ReSet()

    --     if v.status == 2 then
    --         if tab.got ~= nil then
    --             tab.got.gameObject:SetActive(true)
    --         end
    --         tab.origin:SetActive(false)
    --         tab.button.gameObject:SetActive(false)
    --     else
    --         if tab.got ~= nil then
    --             tab.got.gameObject:SetActive(false)
    --         end
    --         tab.origin:SetActive(true)
    --         tab.button.gameObject:SetActive(true)
    --         tab.btnTextExt:SetData(string.format("%s{assets_2, %s}", tostring(campaignBaseData.loss_items[1][2]), tostring(campaignBaseData.loss_items[1][1])))
    --         local size = tab.btnTextExt.contentRect.sizeDelta
    --         tab.btnTextExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
    --         tab.button.onClick:RemoveAllListeners()
    --         tab.button.onClick:AddListener(function() CampaignManager.Instance:Send14001(campaignBaseData.id) end)
    --     end
    --     for j,gift in ipairs(campaignBaseData.rewardgift) do
    --         local tab1 = tab.itemList[j]
    --         if tab1 == nil then
    --             tab1 = {}
    --             tab1.gameObject = GameObject.Instantiate(tab.cloner)
    --             tab1.transform = tab1.gameObject.transform
    --             tab1.nameText = tab1.transform:Find("Name"):GetComponent(Text)
    --             tab1.slot = ItemSlot.New()
    --             tab1.data = ItemData.New()
    --             NumberpadPanel.AddUIChild(tab1.transform:Find("Slot"), tab1.slot.gameObject)
    --             tab.itemList[j] = tab1
    --         end

    --         tab.layout:AddCell(tab1.gameObject)
    --         rewardBase = DataItem.data_get[gift[1]]
    --         tab1.data:SetBase(rewardBase)
    --         tab1.slot:SetAll(tab1.data, {inbag = false, nobutton = true})
    --         tab1.slot:SetNum(gift[2])
    --         tab1.nameText.text = rewardBase.name
    --     end
    --     for i=#campaignBaseData.rewardgift + 1, #tab.itemList do
    --         tab.itemList[i].gameObject:SetActive(false)
    --     end
    -- end
    -- for i=#datalist + 1,#self.rewardList do
    --     self.rewardList[i].gameObject:SetActive(false)
    -- end
    local RewardList = {}
    local lev = RoleManager.Instance.RoleData.lev
    for k,v in pairs(DataCampLimit.data_get_rewards) do
        if v.gain[1][3] == nil or (lev >= v.gain[1][3] and lev <= v.gain[1][4]) then
            table.insert(RewardList, v)
        end
    end
    -- BaseUtils.dump(RewardList, "累啊啊啊啊啊")
    table.sort(RewardList, function(a, b) return a.id<b.id end)
    for i,v in ipairs(RewardList) do

        local tab = self.rewardList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.imageLoader = SingleIconLoader.New(tab.transform:Find("Reward").gameObject)
            tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
            tab.layout = LuaBoxLayout.New(tab.transform:Find("Mask/Container"), {cspacing = 0, border = 10})
            tab.cloner = tab.transform:Find("Mask/Cloner").gameObject
            tab.itemList = {}
            tab.origin = tab.transform:Find("OriginPriceI18N").gameObject
            tab.originText = tab.transform:Find("OriginPriceI18N/Price"):GetComponent(Text)
            tab.button = tab.transform:Find("Button"):GetComponent(Button)
            tab.got = tab.transform:Find("Got")
            tab.btnTextExt = MsgItemExt.New(tab.transform:Find("Button/Text"):GetComponent(Text), 110, 16, 18.82)
            self.rewardList[i] = tab
            tab.cloner:SetActive(false)
        end
        self.layout:AddCell(tab.gameObject)
        local itemdata = DataItem.data_get[v.gain[1][1]]
        tab.imageLoader:SetSprite(SingleIconType.Item, itemdata.icon)
        tab.nameText.text = v.name
        tab.originText.text = tostring(v.price)
        tab.layout:ReSet()
        for j,gift in ipairs(v.gain_client) do
            local tab1 = tab.itemList[j]
            if tab1 == nil then
                tab1 = {}
                tab1.gameObject = GameObject.Instantiate(tab.cloner)
                tab1.transform = tab1.gameObject.transform
                tab1.nameText = tab1.transform:Find("Name"):GetComponent(Text)
                tab1.slot = ItemSlot.New()
                tab1.data = ItemData.New()
                NumberpadPanel.AddUIChild(tab1.transform:Find("Slot"), tab1.slot.gameObject)
                tab.itemList[j] = tab1
            end

            tab.layout:AddCell(tab1.gameObject)
            local rewardBase = DataItem.data_get[gift[1]]
            tab1.data:SetBase(rewardBase)
            tab1.slot:SetAll(tab1.data, {inbag = false, nobutton = true})
            tab1.slot:SetNum(gift[2])
            tab1.nameText.text = rewardBase.name
        end
        if self.model:idBuy(v.id) then
            if tab.got ~= nil then
                tab.got.gameObject:SetActive(true)
            end
            tab.origin:SetActive(false)
            tab.button.gameObject:SetActive(false)
        else
            if tab.got ~= nil then
                tab.got.gameObject:SetActive(false)
            end
            tab.origin:SetActive(true)
            tab.button.gameObject:SetActive(true)
            tab.btnTextExt:SetData(string.format("%s{assets_2, %s}", tostring(v.loss[1][2]), tostring(v.loss[1][1])))
            local size = tab.btnTextExt.contentRect.sizeDelta
            tab.btnTextExt.contentRect.anchoredPosition = Vector2(-size.x / 2, size.y / 2)
            tab.button.onClick:RemoveAllListeners()
            tab.button.onClick:AddListener(function()
                local confirmData = NoticeConfirmData.New()

                confirmData.content = string.format(TI18N("确定花费<color='#ffff00'>%s</color>{assets_2, %s}购买<color='#ffff00'>%s</color>？"), tostring(v.loss[1][2]), tostring(v.loss[1][1]), v.name)
                confirmData.sureCallback = function() OpenServerManager.Instance:send17813(v.id) end
                NoticeManager.Instance:ConfirmTips(confirmData)

            end)
        end
        tab.gameObject:SetActive(true)
    end
end

function OpenServerReward:OnTime()
    local dis = self.endTime - BaseUtils.BASE_TIME
    local d = nil
    local h = nil
    local m = nil
    local s = nil
    d,h,m,s = BaseUtils.time_gap_to_timer(dis)

    if dis < 0 then
        self.timeText.text = self.timeFormat5
    else
        if d > 0 then
            self.timeText.text = string.format(self.timeFormat1, tostring(d), tostring(h))
        elseif h > 0 then
            self.timeText.text = string.format(self.timeFormat2, tostring(h), tostring(m))
        elseif m > 0 then
            self.timeText.text = string.format(self.timeFormat3, tostring(m), tostring(s))
        else
            self.timeText.text = string.format(self.timeFormat4, tostring(m))
        end
    end
end

