LuckeyChestWindow = LuckeyChestWindow or BaseClass(BaseWindow)

LuckeyChestWindow.type = 4
LuckeyChestWindow.ItemId = 23226

function LuckeyChestWindow:__init(model)
    self.model = model
    self.name = "LuckeyChestWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.luckey_chest_window, type = AssetType.Main}
        , {file = AssetConfig.luckey_chest_atlas, type = AssetType.Dep}
        , {file = AssetConfig.luckey_chest_big_bg, type = AssetType.Dep}
        , {file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = string.format(AssetConfig.effect, 20354), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.selectBgList = {}
    self.countdownTimerId = nil
    self.animationTimerId = nil
    self.effectTimerId = nil
    self.itemList = {}

    self.timeString1 = TI18N("剩余: <color='#66FF4B'>%s天%s小时</color>")
    self.timeString2 = TI18N("剩余: <color='#66FF4B'>%s小时%s分钟</color>")
    self.timeString3 = TI18N("剩余: <color='#66FF4B'>%s分钟%s秒</color>")
    self.timeString4 = TI18N("剩余: <color='#66FF4B'>%s秒</color>")
    self.timeString5 = TI18N("活动已结束")

    self.onClickClose = function() self:OnClickClose() end
    self.onClickStart = function() self:OnClickStart() end
    self.onTurnResult = function(type, itemId) self:OnTurnResult(type, itemId) end
    self.onUnFrozen = function(data) self:OnUnFrozen(data) end
    self.refresh = function() self:Refresh() end
    self.levelChangeRefresh = function() self:LevelChangeRefresh() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function LuckeyChestWindow:AddEventListener()
    OpenBetaManager.Instance.onTurnResult:AddListener(self.onTurnResult)
    OpenBetaManager.Instance.onUnFrozen:AddListener(self.onUnFrozen)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.refresh)
    EventMgr.Instance:AddListener(event_name.luckey_chest_own_id_change, self.refresh)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelChangeRefresh)
end

function LuckeyChestWindow:__delete()
    self:ReleaseTable("itemList")
    self:DeleteTween("zoomInId")
    self:DeleteTween("zoomOutId")
    self:DeleteTimer("animationTimerId")
    self:DeleteTimer("countdownTimerId")
    self:DeleteTimer("effectTimerId")
    self:ReleaseField("costItemData ")
    self:ReleaseField("costItemSlot")

    self.buttonClose.onClick:RemoveListener(self.onClickClose)
    self.buttonStart.onClick:RemoveListener(self.onClickStart)

    self:RemoveEventListener()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function LuckeyChestWindow:RemoveEventListener()
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.onTurnResult)
    OpenBetaManager.Instance.onUnFrozen:RemoveListener(self.onUnFrozen)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.refresh)
    EventMgr.Instance:RemoveListener(event_name.luckey_chest_own_id_change, self.refresh)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelChangeRefresh)
end

function LuckeyChestWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function LuckeyChestWindow:OnOpen()
    self:AddEventListener()
    self.buttonStart.interactable = true
    self.transitionButtonStart.enabled = true
    self:Refresh()
end

function LuckeyChestWindow:OnHide()
    self:RemoveEventListener()
end

function LuckeyChestWindow:InitPanel()
    CampaignManager.Instance:Send14099()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.luckey_chest_window))
    self.gameObject.name = self.name

    local transform = self.gameObject.transform
    self.transform = transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.luckey_chest_big_bg))
    UIUtils.AddBigbg(transform:Find("Main/Bg"), bigbg)
    bigbg.transform.anchoredPosition3D = Vector2(-268.5, 144)

    self.textCountDown = transform:Find("Main/Time/Text"):GetComponent(Text)
    transform:Find("Main/Tips/Text"):GetComponent(Text).text =TI18N("抽奖<color='#ffff00'>9</color>次即可拿走<color='#ffff00'>所有奖励</color>")

    self:InitRocker()
    self:InitButton()
    self:InitButtonEffect()
    self:InitItemList()
    self:InitCostItem()
    self:InitBgPoint()
    self:InitBgEffect()

    if self.countdownTimerId == nil then
        self.countdownTimerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    end
end

function LuckeyChestWindow:InitRocker()
    local transformRocker = self.transform:Find("Main/Rocker")
    self.rockerBg = transformRocker:Find("RockerBg").gameObject
    self.rockerUp = transformRocker:Find("RockerUp").gameObject
    self.rockerDown = transformRocker:Find("RockerDown").gameObject

    local button = transformRocker.gameObject:GetComponent(CustomButton)
    button.onDown:AddListener(function() self:OnRockerDown() end)
    button.onUp:AddListener(function() self:OnRockerUp() end)
    self.buttonRocker = button
end

function LuckeyChestWindow:InitButton()
    local transform = self.transform

    self.buttonClose = transform:Find("Main/Close"):GetComponent(Button)
    self.buttonClose.onClick:AddListener(self.onClickClose)

    self.buttonStart = transform:Find("Main/ButtonStart").gameObject:GetComponent(Button)
    self.buttonStart.onClick:AddListener(self.onClickStart)
    self.transitionButtonStart = transform:Find("Main/ButtonStart").gameObject:GetComponent(TransitionButton)
end

function LuckeyChestWindow:InitButtonEffect()
    local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20053)))
    self.buttonEffect = effect
    effect.transform:SetParent(self.buttonStart.transform)
    effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform.localScale = Vector3(2.3, 0.8, 1)
    effect.transform.localPosition = Vector3(-73, -19, -400)
end

function LuckeyChestWindow:InitItemList()
    self.itemList = {}
    local transformItemList = self.transform:Find("Main/ItemList")
    local itemIndex = 1
    local roleLevel = RoleManager.Instance.RoleData.lev
    for id, config in ipairs(DataCampTurn.data_item) do
        if config.type == LuckeyChestWindow.type and
            roleLevel >= config.lev_min and
            roleLevel <= config.lev_max then
            table.insert(self.itemList, 
                LuckeyChestItem.New(transformItemList:Find("Item" .. tostring(itemIndex)).gameObject, id, config)
            )
            itemIndex  = itemIndex + 1
        end
    end
end

function LuckeyChestWindow:InitCostItem()
    local transform = self.transform:Find("Main/CostItem")
    transform:Find("Text"):GetComponent(Text).text = TI18N("消耗:")
    local itemData = ItemData.New()
    local base = DataItem.data_get[23226]
    itemData:SetBase(base)
    self.costItemData = itemData
    self.costItemSlot = ItemSlot.New()
    UIUtils.AddUIChild(transform:Find("ItemSlot").gameObject, self.costItemSlot.gameObject)
end

function LuckeyChestWindow:InitBgPoint()
    self.yellowPointList = {}
    self.bluePointList = {}
    local transform = self.transform:Find("Main/BgEffect")
    for i = 1, 22 do
        table.insert(self.yellowPointList, transform:Find(string.format("Line1/Item%s/YellowPoint", i)).gameObject:GetComponent(Image) )
        table.insert(self.bluePointList, transform:Find(string.format("Line1/Item%s/BluePoint", i)).gameObject:GetComponent(Image) )
    end

    for i = 1, 13 do
        table.insert(self.yellowPointList, transform:Find(string.format("Column2/Item%s/YellowPoint", i)).gameObject:GetComponent(Image) )
        table.insert(self.bluePointList, transform:Find(string.format("Column2/Item%s/BluePoint", i)).gameObject:GetComponent(Image) )
    end

    for i = 22, 1, -1 do
        table.insert(self.yellowPointList, transform:Find(string.format("Line2/Item%s/YellowPoint", i)).gameObject:GetComponent(Image) )
        table.insert(self.bluePointList, transform:Find(string.format("Line2/Item%s/BluePoint", i)).gameObject:GetComponent(Image) )
    end

    for i = 13, 1, -1 do
        table.insert(self.yellowPointList, transform:Find(string.format("Column1/Item%s/YellowPoint", i)).gameObject:GetComponent(Image) )
        table.insert(self.bluePointList, transform:Find(string.format("Column1/Item%s/BluePoint", i)).gameObject:GetComponent(Image) )
    end
end

function LuckeyChestWindow:InitBgEffect()
    local transform = self.transform:Find("Main/BgEffect")
    local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20354)))
    self.bgEffect = effect
    effect.transform:SetParent(transform)
    effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, -400)

    if self.effectTimerId == nil then
        self.effectTimerId = LuaTimer.Add(0, 1000, function() self:OnPlayEffect() end)
    end
end


function LuckeyChestWindow:LevelChangeRefresh()
    self:ReleaseTable("itemList")
    self:InitItemList()
    self:Refresh()
end

function LuckeyChestWindow:Refresh()
    self:RefreshButtonEffect()
    local count = BackpackManager.Instance:GetItemCount(LuckeyChestWindow.ItemId)
    local costItemSlot = self.costItemSlot
    local costItemData = self.costItemData
    costItemData.quantity = count
    costItemData.need = 1
    costItemSlot:SetAll(self.costItemData, {inbag = false, nobutton = false})

    local ownList = CampaignManager.Instance.luckeyChestOwnList
    for _, item in ipairs(self.itemList) do
        if ownList ~= nil and ownList[item.id] then
            item:ShowHaveGot(true)
        else
            item:ShowHaveGot(false)
        end
    end
end

function LuckeyChestWindow:RefreshButtonEffect()
    local count = BackpackManager.Instance:GetItemCount(LuckeyChestWindow.ItemId)
    if count == 0 or self.buttonStart.interactable == false then
        self.buttonEffect.gameObject:SetActive(false)
    else
        self.buttonEffect.gameObject:SetActive(true)
    end
end

function LuckeyChestWindow:OnClickClose()
    if self:IsPlayingAnimation() then
        OpenBetaManager.Instance:send14040(LuckeyChestWindow.type)
    end
    self.model:CloseWindow()
end

function LuckeyChestWindow:CanPlay(showNotice)
    if self:IsPlayingAnimation() or self.buttonStart.interactable == false then
        if showNotice then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在抽奖，请等待！"))
        end
        return false
    end
    local count = BackpackManager.Instance:GetItemCount(23226)
    if count == 0 then
        self:OnClickMore()
        NoticeManager.Instance:FloatTipsByString(TI18N("您的<color='#ffff00'>星云彩币</color>不足还不能抽奖哦，参加<color='#ffff00'>花语祝福</color>即刻获得！{face_1,3}"))
        return false
    end

    return true
end

function LuckeyChestWindow:OnClickStart()
    if not self:CanPlay(true) then
        return
    end
    
    self:DoRockDownTween()
    self:Send14039()
end

function LuckeyChestWindow:OnTurnResult(type, configId)
    if configId == 0 then return end--异常不开启
    for index, item in pairs(self.itemList) do
        if configId == item.id then
            self:Play(index)
            return
        end
    end
end

function LuckeyChestWindow:OnUnFrozen(data)
    self.buttonStart.interactable = true
    self.transitionButtonStart.enabled = true
    self:RefreshButtonEffect()
    local itemId = data.item_id[1].item_id
    local num = data.item_id[1].num
    OpenServerManager.Instance:OpenRewardPanel({{id = itemId, num = num}, TI18N("确定"), 3})
end

function LuckeyChestWindow:DoRockDownTween()
    self.rockerDown:SetActive(true)
    self.rockerUp:SetActive(false)
    self:DeleteTween("zoomInId")
    self:DeleteTween("zoomOutId")
    self.zoomInId = Tween.Instance:Scale(self.rockerBg, Vector3(1.1, 1.1, 1), 0.1,
    function() 
        self.zoomInId = nil 
        self:DoRockUpTween()
    end, LeanTweenType.easeOutQuad).id
end

function LuckeyChestWindow:DoRockUpTween()
    self.rockerDown:SetActive(false)
    self.rockerUp:SetActive(true)
    self.zoomOutId = Tween.Instance:Scale(self.rockerBg, Vector3.one, 0.1,
    function() self.zoomOutId = nil end, LeanTweenType.easeOutQuad).id
end

function LuckeyChestWindow:OnRockerDown()
    if not self:CanPlay(true) then
        return
    end
    self.rockerDown:SetActive(true)
    self.rockerUp:SetActive(false)
    self.zoomInId = Tween.Instance:Scale(self.rockerBg, Vector3(1.1, 1.1, 1), 0.2,
    function() self.zoomInId = nil end, LeanTweenType.easeOutQuad).id
end

function LuckeyChestWindow:OnRockerUp()
    if not self:CanPlay(false) then
        return
    end
    self.rockerDown:SetActive(false)
    self.rockerUp:SetActive(true)
    if self.zoomInId ~= nil then
        Tween.Instance:Cancel(self.zoomInId)
        self.zoomInId = nil
    end
    self.zoomOutId = Tween.Instance:Scale(self.rockerBg, Vector3.one, 0.2,
    function() self.zoomOutId = nil end, LeanTweenType.easeOutQuad).id

    self:Send14039()
end

function LuckeyChestWindow:OnClickMore()
    local endTime = DataCampaign.data_list[564].cli_end_time[1]
    local endTimeStamp = os.time({year = endTime[1], month = endTime[2], day = endTime[3],
        hour = endTime[4], min = endTime[5], sec = endTime[6]})
    if os.time() > endTimeStamp then
        NoticeManager.Instance:FloatTipsByString(TI18N("获取更多宝箱活动已结束"))
        return
    end
    TipsManager.Instance:ShowItem({gameObject = self.buttonStart.gameObject, itemData = self.costItemData,
        extra = {nobutton = false, inbag = false}})
end

function LuckeyChestWindow:Play(targetIndex)
    self.targetIndex = targetIndex
    for _, item in pairs(self.itemList) do
        item:ShowSelctBg(false)
    end
    self.count = 0
    self.currentIndex = 1
    self.interval = 3
    self.increase = false
    self.canSelectIndexList = self:GetCanSelectIndexList()
    if #self.canSelectIndexList == 1 then
        OpenBetaManager.Instance:send14040(LuckeyChestWindow.type)
        return
    end

    self.itemList[self.canSelectIndexList[1]]:ShowSelctBg(true)
    if self.animationTimerId == nil then
        self.animationTimerId = LuaTimer.Add(10, 30, function() self:Tick() end)
    end
end


function LuckeyChestWindow:Tick()
    local itemList = self.itemList
    local indexList = self.canSelectIndexList
    self.count = self.count + 1
    if self.count % self.interval == 0 then
        itemList[indexList[self.currentIndex]]:ShowSelctBg(false)
        self.currentIndex = self.currentIndex + 1
        if self.currentIndex > #indexList then self.currentIndex = 1 end
        itemList[indexList[self.currentIndex]]:ShowSelctBg(true)
    end

    if self.count % 9 == 0 then
        if self.increase then
            self.interval = self.interval + 1
        else
            self.interval = self.interval - 1
            if self.interval == 1 then
                self.increase = true
            end
        end
    end

    if self.interval > 3 then
        if indexList[self.currentIndex] == self.targetIndex then
            LuaTimer.Delete(self.animationTimerId)
            self.animationTimerId = nil
            OpenBetaManager.Instance:send14040(LuckeyChestWindow.type)
        end
    end
end

function LuckeyChestWindow:OnTime()
    local end_time = DataCampaign.data_camp_ico[34].end_time[1]
    if end_time == nil then
        self.textCountDown.text = self.timeString5
        return
    end
    end_time = os.time({year = end_time[1], month = end_time[2], day = end_time[3], hour = end_time[4], mimute = end_time[5], second = end_time[6]})
    self.d,self.h,self.m,self.s = BaseUtils.time_gap_to_timer(end_time - BaseUtils.BASE_TIME)

    if self.d ~= 0 then
        self.textCountDown.text = string.format(self.timeString1, self.d, self.h)
    elseif self.h ~= 0 then
        self.textCountDown.text = string.format(self.timeString2, self.h, self.m)
    elseif self.m ~= 0 then
        self.textCountDown.text = string.format(self.timeString3, self.m, self.s)
    elseif self.s ~= 0 then
        self.textCountDown.text = string.format(self.timeString4, self.s)
    else
        self.textCountDown.text = self.timeString5
    end
end

function LuckeyChestWindow:OnPlayEffect()
    self.showBuleFirst = not self.showBuleFirst
    local yellowMod = self.showBuleFirst and 0 or 1
    for index, image in ipairs(self.yellowPointList) do
        if index % 2 == yellowMod then
            image.color = Color(1, 1, 1, 1)
        else
            image.color = Color(1, 1, 1, 0)
        end
    end
    local blueMod = self.showBuleFirst and 1 or 0
    for index, image in ipairs(self.bluePointList) do
        if index % 2 == blueMod then
            image.color = Color(1, 1, 1, 1)
        else
            image.color = Color(1, 1, 1, 0)
        end
    end
end

function LuckeyChestWindow:Send14039()
    OpenBetaManager.Instance:send14039(LuckeyChestWindow.type)
    self.buttonStart.interactable = false
    self.transitionButtonStart.enabled = false
    self:RefreshButtonEffect()
end

function LuckeyChestWindow:IsPlayingAnimation()
    return self.animationTimerId ~= nil
end

function LuckeyChestWindow:GetCanSelectIndexList()
    local indexList = {}
    for index, item in ipairs(self.itemList) do
        if not item.imageHaveGotActive then
            table.insert(indexList, index)
        end
    end
    return indexList
end

function LuckeyChestWindow:DeleteTween(tweenName)
    if self[tweenName] ~= nil then
        Tween.Instance:Cancel(self[tweenName])
        self[tweenName] = nil
    end
end

function LuckeyChestWindow:DeleteTimer(timerName)
    if self[timerName] ~= nil then
        LuaTimer.Delete(self[timerName])
        self[timerName] = nil
    end
end

function LuckeyChestWindow:ReleaseTable(tableName)
    for _, v in pairs(self[tableName]) do
        v:DeleteMe()
    end
    self[tableName] = {}
end

function LuckeyChestWindow:ReleaseField(fieldName)
    if self[fieldName] ~= nil then
        self[fieldName]:DeleteMe()
        self[fieldName] = nil
    end
end