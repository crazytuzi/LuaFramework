CampBoxPanel = CampBoxPanel or BaseClass(BasePanel)

function CampBoxPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = CampBoxManager.Instance
    self.resList = {
        { file = AssetConfig.campbox_window, type = AssetType.Main }
        ,{ file = AssetConfig.campbox_texture, type = AssetType.Dep }
        ,{ file = AssetConfig.toyreward_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.cambox_big_bg, type = AssetType.Main }
        ,{ file = string.format(AssetConfig.effect, 20395), type = AssetType.Main }
    }


    self.topItemList = { }
    self.leftItemList = { }
    self.rightItemList = { }

    self.timerList = { }
    self.extra = { inbag = false, nobutton = true }

    self.itemData = nil
    self.OnOpenEvent:AddListener( function() self:OnOpen() end)
    self.OnHideEvent:AddListener( function() self:OnHide() end)

    self.onSetItemData = function(data) self:SetItemData(data) end
    self.onSetTextData = function(data) self:SetRightData(data) end
    self.onSetBtnReply = function(data) self:SetBtnReplyData(data) end
    self.btnData = nil
    self.timerId = nil
    self.timerCalculateId = nil
    self.refreshTimerId = nil
    self.openNum = 0
    self.isPlay = false
    self.hasNum = 0
    self.cosNum = 0
    self.costItemId = nil
    self.lastRewardItem = nil
    self.isButtonRefresh = false


end

function CampBoxPanel:__delete()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.refreshTimer ~= nil then
        LuaTimer.Delete(self.refreshTimer);
        self.refreshTimer = nil
    end
    if self.timerCalculateId ~= nil then
        LuaTimer.Delete(self.timerCalculateId)
        self.timerCalculateId = nil
    end

    if self.refreshTimerId ~= nil then
        LuaTimer.Delete(self.refreshTimerId)
        self.refreshTimerId = nil
    end

    if self.topItemList ~= nil then
        for k, v in pairs(self.topItemList) do
            v:DeleteMe()
        end
        self.topItemList = { }
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end

    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end
    if self.rightItemList ~= nil then
        for k, v in pairs(self.rightItemList) do
            v:DeleteMe()
        end
        self.rightItemList = { }
    end

    if self.leftItemList ~= nil then
        for k, v in pairs(self.leftItemList) do
            v:DeleteMe()
        end
        self.leftItemList = { }
    end
    if self.topLayout ~= nil then
        self.topLayout:DeleteMe()
    end

    if self.rightLayout ~= nil then
        self.rightLayout:DeleteMe()
    end

    if self.leftLayout ~= nil then
        self.leftLayout:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CampBoxPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campbox_window))
    self.gameObject.name = "CampBoxPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.gameObject.transform.anchoredPosition = Vector2(self.gameObject.transform.anchoredPosition.x, -24)
    local t = self.gameObject.transform
    self.transform = t

    self.bigBg = self.transform:Find("Bg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.cambox_big_bg))
    UIUtils.AddBigbg(self.bigBg, bigObj)

    self.topContainer = t:Find("Main/TopContainer")
    self.rightContainer = t:Find("Main/RightScrollRect/RightContainer")
    self.leftContainer = t:Find("Main/LeftContainer")
    self.topLayout = LuaBoxLayout.New(self.topContainer.gameObject, { axis = BoxLayoutAxis.X, cspacing = 0, border = 9 })
    self.rightLayout = LuaBoxLayout.New(self.rightContainer.gameObject, { axis = BoxLayoutAxis.Y, cspacing = 0, border = 0 })
    self.topImage = t:Find("Main/NoticeImg"):GetComponent(Image)

    local leftSetting = {
        column = 3
        ,
        cspacing = 12
        ,
        rspacing = 3
        ,
        cellSizeX = 89
        ,
        cellSizeY = 88
    }
    self.leftLayout = LuaGridLayout.New(self.leftContainer, leftSetting)

    self.topItemTemplate = t:Find("Main/TopItemTemplate")
    self.topItemTemplate.gameObject:SetActive(false)
    self.leftItemTemplate = t:Find("Main/LeftItemTemplate")
    self.leftItemTemplate.gameObject:SetActive(false)
    self.rightItemTemplate = t:Find("Main/RightItemTemplate")
    self.rightItemTemplate.gameObject:SetActive(false)

    for i = 1, 9 do
        local gameObject = GameObject.Instantiate(self.topItemTemplate.gameObject)
        local itemSlot = CampBoxTopItem.New(gameObject, nil)
        table.insert(self.topItemList, itemSlot)
        self.topLayout:AddCell(gameObject)
        gameObject:SetActive(false)
    end

    for i = 1, 9 do
        local gameObject = GameObject.Instantiate(self.leftItemTemplate.gameObject)
        local itemSlot = CampBoxLeftItem.New(gameObject, nil, i, self)
        table.insert(self.leftItemList, itemSlot)
        self.leftLayout:UpdateCellIndex(itemSlot.gameObject, i)
        gameObject:SetActive(false)
    end

    for i = 1, 10 do
        local gameObject = GameObject.Instantiate(self.rightItemTemplate.gameObject)
        local itemSlot = CampBoxRightItem.New(gameObject, self)
        table.insert(self.rightItemList, itemSlot)
        self.rightLayout:AddCell(gameObject)
        gameObject:SetActive(false)
    end
    self.leftText1 = t:Find("Main/LeftText1"):GetComponent(Text)
    self.rightText = t:Find("Main/RightText"):GetComponent(Text)
    self.msg1 = MsgItemExt.New(self.rightText, 170, 18, 21)

    self.leftText2 = t:Find("Main/LeftText2"):GetComponent(Text)
    self.msg2 = MsgItemExt.New(self.leftText1, 275, 18, 21)



    self.rewardBtn = t:Find("Main/RightButton"):GetComponent(Button)
    self.rewardBtn.onClick:AddListener( function() self:ApplyBtn() end)

    self.eventCountDownText = t:Find("Main/TimerBg/Text"):GetComponent(Text)
    -- self.bigBg = t:Find("Main/Bg/BackBg")
    -- local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.toyreward_big_bg))
    -- UIUtils.AddBigbg(self.bigBg, bigObj)
    -- bigObj.transform.anchoredPosition = Vector2(0, 4)
    self:OnOpen()
end

function CampBoxPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    self.mgr.isRefreshing = false
    self.mgr.needRefresh = false
    self.mgr:send17865()
    self.mgr:send17864()
    self:ApplyTime()
end

function CampBoxPanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.refreshTimerId ~= nil then
        LuaTimer.Delete(self.refreshTimerId)
        self.refreshTimerId = nil
    end

    if self.timerCalculateId ~= nil then
        LuaTimer.Delete(self.timerCalculateId)
        self.timerCalculateId = nil
    end

    self.isPlay = false
end

function CampBoxPanel:SetItemData(data)
    if self.mgr.isRefreshing then
        return
    end
    if self.mgr.needRefresh then
        self:DoRefresh(data)
    else
        self:RefreshCallBack(data)
    end
end

function CampBoxPanel:RefreshCallBack(data)
    if self.mgr.needRefresh then
        if self.refreshingEffect == nil then
            self.refreshingEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20395)))
            self.refreshingEffect.transform:SetParent(self.transform)
            self.refreshingEffect.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(self.refreshingEffect.transform, "UI")
            self.refreshingEffect.transform.localScale = Vector3(1, 1, 1)
            self.refreshingEffect.transform.localPosition = Vector3(-155, -10, -400)
        end
        self.refreshingEffect.gameObject:SetActive(true)
        if self.refreshTimer ~= nil then
            LuaTimer.Delete(self.refreshTimer);
        end
        self.refreshTimer = LuaTimer.Add(1000,
        function()
            if self.refreshTimer ~= nil then
                LuaTimer.Delete(self.refreshTimer);
                self.refreshTimer = nil
            end
            self.refreshingEffect.gameObject:SetActive(false)
        end )
    end
    self.openNum = #data.pos_list
    self.itemData = data
    local topData = self:SortTopData(data.list)
    self:SetTopData(topData)

    local leftData = self:SortLeftData(data.pos_list)
    self:SetLeftData(leftData)

    self.leftText2.text = string.format("%d/8", self.openNum)
     local str1
    if self.openNum > 2  then
        str1 = TI18N("免费刷新")
    else
        str1 = string.format(TI18N("{assets_2,%s}%s个"), DataCampBox.data_campbox[1].refresh_cost[1][1], DataCampBox.data_campbox[1].refresh_cost[1][2])
    end
    self.msg1:SetData(str1)
    local costList = DataCampBox.data_campboxcost;
    local curCostItem;
    if #costList > 0 then
        if self.openNum < 8 then
            for _, costItem in pairs(costList) do
                if costItem.min <= self.openNum + 1 and self.openNum + 1 <= costItem.max then
                    curCostItem = costItem;
                    break
                end
            end
            if curCostItem ~= nil then
                self.hasNum = BackpackManager.Instance:GetItemCount(curCostItem.cost[1][1])
                self.costNum = curCostItem.cost[1][2]
                self.costItemId = curCostItem.cost[1][1]
                local str2 = string.format(TI18N("{assets_2,%s}%s个，当前剩余：%s个"), curCostItem.cost[1][1], curCostItem.cost[1][2],self.hasNum)
                self.msg2:SetData(str2)
            end
        end
    end
end

function CampBoxPanel:SortTopData(data)
    table.sort(data, function(a, b)
        if a.id ~= b.id then
            return a.id > b.id
        else
            return false
        end
    end )

    return data
end


function CampBoxPanel:SetTopData(topData)
    for i = 1, 9 do
        local CampBox = DataCampBox.data_campboxitem[topData[i].id];
        if CampBox ~= nil then
            local itemData = ItemData.New()
            local dataId = CampBox.item_id
            local num = CampBox.num

            local base = BackpackManager.Instance:GetItemBase(dataId)
            itemData:SetBase(base)
            itemData.show_num = true
            itemData.num = num
            self.topItemList[i]:SetData(itemData, self.extra, nil, num, dataId,CampBox)
            self.topItemList[i]:SetBg(CampBox.special)
            self.topItemList[i].gameObject:SetActive(true)
            if self.openNum == 0 then
                self.topItemList[i]:SetStatus(false)
                self.topItemList[i]:ShowEffect(false)
                self.topItemList[i]:ShowEffect(true)
            else
                self.topItemList[i]:ShowEffect(false)
            end
        end
    end
end

function CampBoxPanel:SortLeftData(data)
    local table = { }

    for k, v in pairs(data) do
        table[v.pos] = v
    end

    return table
end

function CampBoxPanel:SetLeftData(leftData)
    for i = 1, 9 do
        local status = false
        if leftData[i] ~= nil then
            local dataId = DataCampBox.data_campboxitem[leftData[i].id].item_id
            if leftData[i].pos == i then
                status = true
            end
            local num = DataCampBox.data_campboxitem[leftData[i].id].num;
            local itemData = BackpackManager.Instance:GetItemBase(dataId)
            itemData.show_num = true
            itemData.quantity = num
            self.leftItemList[i]:SetData(itemData, self.extra, status, num)

            for k, v in pairs(self.topItemList) do
                if v.itemId == dataId and num == v.num then
                    v:SetStatus(true)
                end
            end
        else
            self.leftItemList[i]:SetStatus(status)
        end
        self.leftItemList[i].gameObject:SetActive(true)
    end
end

function CampBoxPanel:SetRightData(data)
    -- BaseUtils.dump(data,"公告数据")
    if self.rightLayout ~= nil then
        self.rightLayout:DeleteMe()
        self.rightLayout = nil
    end
    if self.rightLayout == nil then
        self.rightLayout = LuaBoxLayout.New(self.rightContainer.gameObject, { axis = BoxLayoutAxis.Y, cspacing = 0, border = 8 })
    end
    for i = 1, #data.list do
        local itemData = BackpackManager.Instance:GetItemBase(data.list[i].item_id)
        local str = string.format(TI18N("%s获得%s*%d"), data.list[i].name, ColorHelper.color_item_name(itemData.quality, itemData.name), data.list[i].num)
        self.rightItemList[i]:SetData(str)
        self.rightLayout:AddCell(self.rightItemList[i].gameObject)
        self.rightItemList[i].gameObject:SetActive(true)
    end

    if #data.list < 10 then
        for i = #data.list, 10 do
            self.rightItemList[i].gameObject:SetActive(false)
        end
    end
end

function CampBoxPanel:AddListeners()
    self.mgr.OnUpdateItemData:AddListener(self.onSetItemData)
    self.mgr.OnUpdateTextData:AddListener(self.onSetTextData)
    self.mgr.OnUpdateItemBtn:AddListener(self.onSetBtnReply)
end

function CampBoxPanel:RemoveListeners()
    self.mgr.OnUpdateItemData:RemoveListener(self.onSetItemData)
    self.mgr.OnUpdateTextData:RemoveListener(self.onSetTextData)
    self.mgr.OnUpdateItemBtn:RemoveListener(self.onSetBtnReply)
end


function CampBoxPanel:ActiveBtnReply()


end

function CampBoxPanel:ApplyReward()
    -- self.firstEffect:SetActive(true)


    local leftItem = self.leftItemList[self.btnData.list[1].pos];
    if leftItem ~= nil then
        local dataId = DataCampBox.data_campboxitem[self.btnData.list[1].id].item_id
        local num = DataCampBox.data_campboxitem[self.btnData.list[1].id].num
        local itemData = BackpackManager.Instance:GetItemBase(dataId)
        itemData.show_num = true
        itemData.quantity = num
        leftItem:SetData(itemData, self.extra, true, num)
        leftItem.ItemSlot.gameObject:SetActive(true)

        leftItem:PlayOpenEffect();
    end
    if self.openNum >= 8 then
        self.mgr.needRefresh = true;
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
        end
        self.timerId = LuaTimer.Add(1500, function() self:RefreshAll() end)
    end
end

function CampBoxPanel:RefreshAll()
    self.mgr:send17865()
    self.mgr:send17864()
end

function CampBoxPanel:SetBtnReplyData(data)
    self.btnData = data
    self:ApplyReward()
end

function CampBoxPanel:ApplyBtn()
    if self.mgr.isRefreshing then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在洗牌，请稍等片刻"))
        return
    end
    local num = self.costNum;
    if self.openNum > 2 then
        num = 0
    end
    if self.hasNum < num then
        local itemData = ItemData.New()
        local gameObject = self.gameObject
        itemData:SetBase(DataItem.data_get[self.costItemId])
        TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData})
        return
    else
         local data = NoticeConfirmData.New()
         data.type = ConfirmData.Style.Normal
         data.content = TI18N("越后面的牌翻到大奖的几率越高，是否刷新？")
         data.sureLabel = TI18N("确定")
         data.cancelLabel = TI18N("取消")
            -- 打开商店第三个标签的第二个Panel
         data.sureCallback = function () self:SureRightButton() end
         NoticeManager.Instance:ConfirmTips(data)
    end
end

function CampBoxPanel:SureRightButton()
    self.mgr:send17867()
    self.isButtonRefresh = true
    self.mgr.needRefresh = true
end




function CampBoxPanel:ApplyTime()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    -- local time = DataCampaign.data_list[3].time[1]
    local time = DataCampBox.data_campbox[1].day_time[1]
    beginTime = tonumber(os.time { year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3] })
    endTime = tonumber(os.time { year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6] })

    self.timestamp = 0
    if baseTime > endTime then
        -- 结束了,开始时间是第二天
        beginTime = beginTime + 24 * 60 * 60
        self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage1")
        self.timestamp = beginTime - baseTime
    elseif baseTime <= endTime and baseTime >= beginTime then
        self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage2")
        self.timestamp = endTime - baseTime
    elseif baseTime < beginTime then
        self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage1")
        self.timestamp = beginTime - baseTime
    end
    self.timerCalculateId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)

end

function CampBoxPanel:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp -(h * 3600)) / 60)
        local ss = math.floor(self.timestamp -(h * 3600) -(mm * 60))
        self.eventCountDownText.text = h .. "时" .. mm .. "分" .. ss .. "秒"
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function CampBoxPanel:EndTime()
    if self.timerCalculateId ~= nil then
        LuaTimer.Delete(self.timerCalculateId)
        self.timerCalculateId = nil
    end
end

function CampBoxPanel:DoRefresh(data)
    self.mgr.isRefreshing = true
    local centerImte = self.leftItemList[5];
    local toPos = Vector3(centerImte.transform.anchoredPosition.x, centerImte.transform.anchoredPosition.y, 0)
    local t = false
    local item = nil
    local time = 0


    if self.isButtonRefresh == false then
        time = 1800
    else
        time = 200
        self.isButtonRefresh = false
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
    end
    self.timerId2 = LuaTimer.Add(time,
    function()

        if self.timerId2 ~= nil then
            LuaTimer.Delete(self.timerId2)
            self.timerId2 = nil
        end
        self:RefreshCallBack(data)
    end )


    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
    end
    self.timerId3 = LuaTimer.Add(time,
    function()

        for index = 1, #self.leftItemList do
            if index ~= 5 then
                item = self.leftItemList[index];
                if item ~= nil then
                   item:PlayRefresEffect(toPos)
                end
            end
        end

        if self.timerId3 ~= nil then
            LuaTimer.Delete(self.timerId3)
            self.timerId3 = nil
        end
    end )
end












