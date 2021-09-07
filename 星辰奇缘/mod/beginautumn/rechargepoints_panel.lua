-- @author zyh
-- @date 2017年7月29日

RechargePointsPanel = RechargePointsPanel or BaseClass(BasePanel)

function RechargePointsPanel:__init(model, parent)

    self.model = model
    self.parent = parent
    self.name = "RechargePointsPanel"

    self.resList = {
        {file = AssetConfig.rechargepointpanel, type = AssetType.Main},
        {file = AssetConfig.beginautum,type = AssetType.Dep},
        {file = AssetConfig.beginautumn_bigbg, type = AssetType.Main},
        -- {file = AssetConfig.masquerade_textures, type = AssetType.Dep},
        -- {file = AssetConfig.sevenday_other_bg,type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateItemStatusListener = function() self:UpdateItemListStatus() end
    self.updateData = function() self:InitData() end

    self.extra = {inbag = false, nobutton = true}

    self.itemList = {}
    self.tweenTimerId = nil
    self.nowDay = -1
    self.initUpdateFun = function() self:UpdateDate() end
    self.isInit = false

    self.campId = nil

    self.rechageIcon = 90044

end

function RechargePointsPanel:__delete()

    self.OnHideEvent:Fire()

    if self.luaLayout ~= nil then
        self.luaLayout:DeleteMe()
        self.luaLayout = nil
    end

    for k,v in pairs(self.itemList) do
        if v.luaLayout ~= nil then
            v.luaLayout:DeleteMe()
            v.luaLayout = nil
        end

        if v.imgLoader ~= nil then
            v.imgLoader:DeleteMe()
            v.imgLoader = nil
        end

        for k2,v2 in pairs(v.itemList) do
            if v2.firstEffect ~= nil then
                v2.firstEffect:DeleteMe()
                v2.firstEffect = nil
            end
        end
    end

    if self.msg1 ~= nil then
        self.msg1:DeleteMe()
        self.msg1 = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RechargePointsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rechargepointpanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t


    self.container = t:Find("ScrollRect/Container")
    self.itemTemplate = t:Find("ScrollRect/Cloner")
    t:Find("ScrollRect/Cloner/Mask").transform.anchoredPosition =Vector2(-12,0)
    t:Find("ScrollRect/Cloner/Mask").transform.sizeDelta = Vector2(269.5,100)

    self.middleText = t:Find("MiddleText"):GetComponent(Text)
    self.middleText.text = string.format("<color='#ffff9a'>%s月%s日-%s月%s日</color>",DataCampaign.data_list[self.campId].cli_start_time[1][2],DataCampaign.data_list[self.campId].cli_start_time[1][3],DataCampaign.data_list[self.campId].cli_end_time[1][2],DataCampaign.data_list[self.campId].cli_end_time[1][3])

    self.leftText = t:Find("Left/LeftText"):GetComponent(Text)
    self.msg1 = MsgItemExt.New(self.leftText,400,18,21)
    self.msg1:SetData(string.format(TI18N("活动期间，充值{assets_2, %s}即可获得等量{assets_2, %s},兑换超值好礼"),90002,self.rechageIcon))
    --(string.format(TI18N("立即返还：<color='#ffff00'>%s</color>{assets_2, }"), tostring(basedata.reward[1][2]), tostring(basedata.reward[1][1])))
    -- self.msg1 = MsgItemExt.New(self.middleText,250,18,21)
    -- self.msg1:SetData()

    self.rightText = t:Find("RightText"):GetComponent(Text)


    self.bigBg = t:Find("Bg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.beginautumn_bigbg))
    UIUtils.AddBigbg(self.bigBg, bigObj)
    bigObj.transform.anchoredPosition = Vector2(0, 0)

    self.scrollRect = self.transform:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function() self:ApplyEffectActive() end)

    self.luaLayout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5})
    self.rechargeButton = t:Find("Top/Button"):GetComponent(Button)
    self.rechargeButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end)


    -- self.tabLayout:AddCell(item)
    self:InitData()
end

function RechargePointsPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RechargePointsPanel:InitData()
    -- 包含了所有货币的列表，获得当前人物的货币资产
    --local chargeList = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.dollar)
    local chargeNum = BeginAutumnManager.Instance.model.dollar
    self.rightText.text = string.format("<color='#00ff00'>%s</color>", chargeNum)
end


function RechargePointsPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    BeginAutumnManager.Instance:send17874()
        -- BeginAutumnManager.Instance:send17846()
    self:InitData()
    self:ApplyEffectActive()
    if self.tweenTimerId == nil then
        self.tweenTimerId = LuaTimer.Add(1000, 3000, function()
               self.rechargeButton.gameObject.transform.localScale = Vector3(1.1,1.1,1)
               Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
            end)
    end


    -- self.updateListener()
end

function RechargePointsPanel:UpdateDate()
    --print("1:" .. self.nowDay .. "2:" .. BeginAutumnManager.Instance.nowDay)
    if BeginAutumnManager.Instance.isInit == false or (BeginAutumnManager.Instance.nowDay~= nil and self.nowDay ~= BeginAutumnManager.Instance.nowDay) then
        self.nowDay = BeginAutumnManager.Instance.nowDay
        self:InitItemList()
        self.itemTemplate.gameObject:SetActive(false)
        BeginAutumnManager.Instance.isInit = true
    else
        self:UpdateItemListStatus()
    end
end
function RechargePointsPanel:InitItemList()
    for k,v in pairs(self.itemList) do
        v.go.gameObject:SetActive(false)
    end

    local myItemData = BeginAutumnManager.Instance:GetGiftList()
    local index = 1

    for i,v in pairs(myItemData) do
        if self.itemList[index] == nil then
            local go = GameObject.Instantiate(self.itemTemplate)
            go.gameObject:SetActive(true)
            self.luaLayout:AddCell(go.gameObject)
            local t = go.transform
            self.itemList[index] = {}
            self.itemList[index].go = go.gameObject
            self.itemList[index].luaLayout = LuaBoxLayout.New(t:Find("Mask/Container").gameObject, {axis = BoxLayoutAxis.X, spacing = 5})
            self.itemList[index].cloner = t:Find("Mask/Cloner")
            self.itemList[index].cloner.gameObject:SetActive(false)
            -- self.itemList[index].rewardImg = t:Find("Reward"):GetComponent(Image)
            self.itemList[index].rewardName = t:Find("Name"):GetComponent(Text)
            self.itemList[index].got = t:Find("Got")
            self.itemList[index].button = t:Find("Button"):GetComponent(Button)
            self.itemList[index].buttonText = t:Find("Button/Text"):GetComponent(Text)
            self.itemList[index].buttonImg = t:Find("Button/Image"):GetComponent(Image)
            self.itemList[index].NumText = t:Find("NumText"):GetComponent(Text)
            self.itemList[index].rewardSlot = ItemSlot.New(t:Find("ItemSlot").gameObject,self.extra)
            self.itemList[index].id = v.id
            self.itemList[index].originPriceI18N = t:Find("OriginPriceI18N").gameObject:SetActive(false)
        end

        -- item.rewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures,tostring(i))
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[v.item_gift_id])
        self.itemList[index].rewardSlot:SetAll(itemData,self.extra)
        self.itemList[index].rewardSlot:ShowBg(false)
        self.itemList[index].rewardSlot.button.onClick:RemoveAllListeners()
        self.itemList[index].go.gameObject:SetActive(true)
        self.itemList[index].rewardName.text = v.item_gift_name
        self.itemList[index].buttonText.text = v.cost
        self.itemList[index].button.onClick:RemoveAllListeners()
        self.itemList[index].button.onClick:AddListener(function() self:ItemButton(v.lev,v.id) end)
        self.itemList[index].imgLoader = SingleIconLoader.New(self.itemList[index].buttonImg.gameObject)
        self.itemList[index].imgLoader:SetSprite(SingleIconType.Item, self.rechageIcon)   --BeginAutumnManager.Instance.todayItemList[v.id].cost[1].item_id

        local hasnum = v.camp_max

        if BeginAutumnManager.Instance.totalList ~= nil and BeginAutumnManager.Instance.totalList[v.id] ~= nil then
            hasnum = v.camp_max - BeginAutumnManager.Instance.totalList[v.id].num
        end

        if hasnum > 0 or v.camp_max == 0 then
            self.itemList[index].got.gameObject:SetActive(false)
            self.itemList[index].button.gameObject:SetActive(true)
            self.itemList[index].NumText.gameObject:SetActive(true)
            if v.camp_max == 0 then
                self.itemList[index].NumText.gameObject:SetActive(false)
            end
        else
            self.itemList[index].got.gameObject:SetActive(true)
            self.itemList[index].button.gameObject:SetActive(false)
            self.itemList[index].NumText.gameObject:SetActive(false)
        end



        self.itemList[index].NumText.text = string.format("<color='#249015'>限兑：%s/%s</color>",hasnum,v.camp_max)


        if self.itemList[index].itemList == nil then
            self.itemList[index].itemList = {}
        end
        local index2 = 1
        for i2,v2 in ipairs(v.item_list) do
            if self.itemList[index].itemList[index2] == nil then
                local go2 = GameObject.Instantiate(self.itemList[index].cloner)
                go2.gameObject:SetActive(true)
                self.itemList[index].luaLayout:AddCell(go2.gameObject)
                local itemGo = go2.transform:Find("ItemSlot")
                self.itemList[index].itemList[index2] = ItemSlot.New(itemGo.gameObject)
            end
            local itemData = ItemData.New()
            itemData:SetBase(DataItem.data_get[v2.item_id])
            self.itemList[index].itemList[index2]:SetAll(itemData,self.extra)
            self.itemList[index].itemList[index2]:SetNum(v2.num)

            if v2.eff == 1 then
                if self.itemList[index].itemList[index2].firstEffect == nil then
                    self.itemList[index].itemList[index2].firstEffect = BibleRewardPanel.ShowEffect(20223,self.itemList[index].itemList[index2].gameObject.transform, Vector3.one, Vector3(0,0, -400))
                end
                self.itemList[index].itemList[index2].firstEffect:SetActive(true)
            else
                if self.itemList[index].itemList[index2].firstEffect ~= nil then
                    self.itemList[index].itemList[index2].firstEffect:SetActive(false)
                end
            end
            index2 = index2 + 1
        end
        index = index + 1




    end
end

function RechargePointsPanel:UpdateItemListStatus()
    for i,v in pairs(self.itemList) do
        local hasnum = BeginAutumnManager.Instance.todayItemList[v.id].camp_max

        if BeginAutumnManager.Instance.totalList ~= nil and BeginAutumnManager.Instance.totalList[v.id] ~= nil then
            hasnum = BeginAutumnManager.Instance.todayItemList[v.id].camp_max - BeginAutumnManager.Instance.totalList[v.id].num
        end

        if hasnum > 0 or BeginAutumnManager.Instance.todayItemList[v.id].camp_max == 0 then
            self.itemList[i].got.gameObject:SetActive(false)
            self.itemList[i].button.gameObject:SetActive(true)
            self.itemList[i].NumText.gameObject:SetActive(true)
            if BeginAutumnManager.Instance.todayItemList[v.id].camp_max == 0 then
                self.itemList[i].NumText.gameObject:SetActive(false)
            end
        else
            self.itemList[i].got.gameObject:SetActive(true)
            self.itemList[i].button.gameObject:SetActive(false)
            self.itemList[i].NumText.gameObject:SetActive(false)
        end



        self.itemList[i].NumText.text = string.format("<color='#249015'>限兑：%s/%s</color>",hasnum,BeginAutumnManager.Instance.todayItemList[v.id].camp_max)
    end

end

function RechargePointsPanel:OnHide()
    self:RemoveListeners()
    if self.tweenTimerId ~= nil then
        LuaTimer.Delete(self.tweenTimerId)
        self.tweenTimerId = nil
    end
end


function RechargePointsPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change,self.updateData)
    EventMgr.Instance:RemoveListener(event_name.cake_exchange_data_update, self.initUpdateFun)
end


function RechargePointsPanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change,self.updateData)
    EventMgr.Instance:AddListener(event_name.cake_exchange_data_update, self.initUpdateFun)
end

function RechargePointsPanel:ItemButton(lev,index)

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("确定花费%s{assets_2,%s}兑换%s？"),BeginAutumnManager.Instance.todayItemList[index].cost,self.rechageIcon,BeginAutumnManager.Instance.todayItemList[index].item_gift_name)
    --data.content = string.format(TI18N("确定花费"))
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function ()
        BeginAutumnManager.Instance:send17846(lev,index)
    end
    NoticeManager.Instance:ConfirmTips(data)

end


function RechargePointsPanel:ApplyEffectActive()
    local Top =  - self.container.anchoredPosition.y
    local Bot = Top - self.scrollRect.transform.sizeDelta.y

    if self.itemList ~= nil then
      for k,v in pairs(self.itemList) do
                local ay = v.go.transform.anchoredPosition.y
                local sy = v.go.transform.sizeDelta.y

                local state = nil
                if Top < ay - 16 or Bot > ay -sy + 16 then
                    state = false
                else
                    state = true
                end

                for k2,v2 in pairs(v.itemList) do
                    if v2.firstEffect ~= nil then
                        v2.firstEffect:SetActive(state)
                    end
                end
        end
    end
end




