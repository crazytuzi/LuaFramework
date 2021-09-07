ToyRewardPanel = ToyRewardPanel or BaseClass(BasePanel)

function ToyRewardPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = ToyRewardManager.Instance
    self.resList = {
        {file = AssetConfig.toyreward_panel, type = AssetType.Main}
        -- ,{file = AssetConfig.base_textures, type = AssetType.Dep}
        ,{file = AssetConfig.toyreward_textures, type = AssetType.Dep}
        ,{file = AssetConfig.leveljumptexture, type = AssetType.Dep}
        ,{file = AssetConfig.toyreward_big_bg, type = AssetType.Main}
        ,{file = AssetConfig.toyreward_big, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect,20330), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect,20332), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    BaseUtils.dump(self.resList)

    self.topItemData = {}
    self.topItemList = {}
    self.extra = {inbag = false, nobutton = true}

    self.SetRewardTimeListerner = function(data) self:SetRewardTime(data) end
    self.GetRewardOneListerner = function(type,id) self:GetRewardOne(type,id) end
    self.GetRewardTenListerner = function(type,id) self:GetRewardTen(type,id) end

    self.timerId = nil
    self.timerEffectId = nil
    self.firstEffectTimerId = nil
    self.secondEffecttimerId = nil
    self.thirdEffecttimerId = nil

    self.wingLeftTimerId = nil
    self.wingRightTimerId = nil

    self.wingLeftDirection = 1
    self.wingRightDirection = 1

    self.firstEffect = nil
    self.secondEffect = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.isReward = false
    self.showNum = nil
    self.hasReward = false

    self.alponeTimerId = nil
    self.slotList = {}
    self.nameList = {}

    self.getPanelTweenId = nil
    self.campId = nil

    self.imgLoaderOne = nil
    self.imgLoaderTwo = nil
end

function ToyRewardPanel:__delete()
    OpenBetaManager.Instance.onTurnTime:RemoveListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardTenListerner)

    if self.hasReward then
        OpenBetaManager.Instance:send14040()
    end
    self.hasReward = false

    self:EndTime()


    for i,v in ipairs(self.slotList) do
        v:DeleteMe()
    end
    self.slotList = nil

    self.nameList = nil




    if self.bmBmExt ~= nil then
        self.bmBmExt:DeleteMe()
        self.bmBmExt = nil
    end
    if self.showMaskTimeId ~= nil then
        LuaTimer.Delete(self.showMaskTimeId)
        self.showMaskTimeId = nil
    end

    if self.timerEffectId ~= nil then
        LuaTimer.Delete(self.timerEffectId)
        self.timerEffectId = nil
    end

    if self.firstEffectTimerId ~= nil then
        LuaTimer.Delete(self.firstEffectTimerId)
        self.firstEffectTimerId = nil
    end

     if self.secondEffecttimerId ~= nil then
        LuaTimer.Delete(self.secondEffecttimerId)
        self.secondEffecttimerId = nil
    end

     if self.thirdEffecttimerId ~= nil then
        LuaTimer.Delete(self.thirdEffecttimerId)
        self.thirdEffecttimerId = nil
    end

    if self.alponeTimerId ~= nil then
        Tween.Instance:Cancel(self.alponeTimerId)
        self.alponeTimerId = nil
    end

    if self.getPanelTweenId ~= nil then
        Tween.Instance:Cancel(self.getPanelTweenId)
        self.getPanelTweenId = nil
    end

    if self.wingLeftTimerId ~= nil then
        Tween.Instance:Cancel(self.wingLeftTimerId)
        self.wingLeftTimerId = nil
    end

    if self.wingRightTimerId ~= nil then
        Tween.Instance:Cancel(self.wingRightTimerId)
        self.wingRightTimerId = nil
    end

    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

    if self.secondEffect ~= nil then
        self.secondEffect:DeleteMe()
        self.secondEffect = nil
    end

    if self.topItemList ~= nil then
        for i,v in ipairs(self.topItemList) do
          v:DeleteMe()
        end
    end

    if self.topItemLayout ~= nil then
        self.topItemLayout:DeleteMe()
        self.topItemLayout = nil
    end

    if self.imgLoaderOne ~= nil then
        self.imgLoaderOne:DeleteMe()
        self.imgLoaderOne = nil
    end

     if self.imgLoaderTwo ~= nil then
        self.imgLoaderTwo:DeleteMe()
        self.imgLoaderTwo = nil
    end

    self.getIconImage.sprite = nil
    self.topImage.sprite = nil

    self.bigImage.sprite =nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function ToyRewardPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.toyreward_panel))
    self.gameObject.name = "ToyRewardPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -8, 0)

    local t = self.gameObject.transform

    self.bigBg = t:Find("BackBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.toyreward_big_bg))
    UIUtils.AddBigbg(self.bigBg, bigObj)
    bigObj.transform.anchoredPosition = Vector2(0, 4)

    self.topScrollRect = t:Find("RectScroll")
    self.topScrollRect:GetComponent(ScrollRect).enabled = false
    self.topItemContainer = t:Find("RectScroll/Container")
    self.topItemTemplate = t:Find("TopItemSlot")
    self.topItemTemplate.gameObject:SetActive(false)

    self.topItemLayout = LuaBoxLayout.New(self.topItemContainer.gameObject, {axis = BoxLayoutAxis.X, border = 12, cspacing = 30})

    self.topLeftText = t:Find("Tobbg/LeftText"):GetComponent(Text)
    self.topRightText = t:Find("Tobbg/RightText"):GetComponent(Text)
    if self.imgLoaderOne == nil then
        local go =  t:Find("Tobbg/Icon").gameObject
        self.imgLoaderOne = SingleIconLoader.New(go)
    end

    local buttonContainTr = t:Find("ButtomContain")
    for i = 1, 2 do
        local slot = ItemSlot.New()
        local item = buttonContainTr:Find(string.format("TopMask/ItemContainer%s",i))
        UIUtils.AddUIChild(item.gameObject, slot.gameObject)
        table.insert(self.slotList, slot)
        table.insert(self.nameList, item:Find("Text"):GetComponent(Text))
    end
    buttonContainTr:Find("TopMask/TopTab/Text"):GetComponent(Text).text = TI18N("每天前10次可获")

    self.buttonOne = t:Find("ButtonLeft"):GetComponent(Button)
    self.buttonTen = t:Find("ButtonRight"):GetComponent(Button)
    self.buttonOneImg = t:Find("ButtonLeft"):GetComponent(Image)
    self.buttonTenImg = t:Find("ButtonRight"):GetComponent(Image)

    self.timeText = t:Find("TopContainer/TimeBg/TimeText"):GetComponent(Text)
    self.topImage = t:Find("TopContainer/LeftTitle"):GetComponent(Image)

    self.wing = t:Find("WingbBg")
    self.leftWing = t:Find("WingbBg/LeftWing")
    self.rightWing = t:Find("WingbBg/RightWing")

    self.buttonOne.onClick:AddListener(function() self:ButtonClick(ToyRewardEumn.Type.One) end)
    self.buttonTen.onClick:AddListener(function() self:ButtonClick(ToyRewardEumn.Type.Ten) end)

    self.toyRewardMachine = t:Find("RightBackBg")
    self.bigImage = self.toyRewardMachine:Find("ToyMachine"):GetComponent(Image)
    self.bigImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_big, "ToyRewardMachine")


    self.getIcon = t:Find("GetIcon")
    self.getIcon.gameObject:SetActive(false)
    self.getIcon.localPosition = Vector3(144, -55, -400)
    self.getIconImage = t:Find("GetIcon"):GetComponent(Image)
    self.getIconImage.enabled = false

    self.firstEffect = BibleRewardPanel.ShowEffect(20330, self.gameObject.transform, Vector3.one, Vector3(148, -45, -400))
    self.firstEffect:SetActive(false)

    self.secondEffect = BibleRewardPanel.ShowEffect(20332, self.getIcon, Vector3.one, Vector3(0, 0, -400))
    self.secondEffect:SetActive(false)
    self.maskPanel = t:Find("MaskPanel")
    self.maskPanelImage= self.maskPanel:GetComponent(Image)


    self.bmBmExt = MsgItemExt.New(t:Find("MsgText"):GetComponent(Text), 237, 17, 27)
    self.bmBmExt:SetData(DataCampaign.data_list[self.campId].cond_desc)

    self:OnOpen()
end

function ToyRewardPanel:OnHide()
    self:Clear()
    if self.hasReward then
        OpenBetaManager.Instance:send14040()
    end
    self.hasReward = false
end

function ToyRewardPanel:Clear()
    self:EndTime()

    if not BaseUtils.is_null(self.firstEffect) then
        self.firstEffect.gameObject:SetActive(false)
    end

    if not BaseUtils.is_null(self.secondEffect) then
        self.secondEffect.gameObject:SetActive(false)
    end

    OpenBetaManager.Instance.onTurnTime:RemoveListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardTenListerner)

    if self.showMaskTimeId ~= nil then
        LuaTimer.Delete(self.showMaskTimeId)
        self.showMaskTimeId = nil
    end

    if self.timerEffectId ~= nil then
        LuaTimer.Delete(self.timerEffectId)
        self.timerEffectId = nil
    end

    if self.firstEffectTimerId ~= nil then
        LuaTimer.Delete(self.firstEffectTimerId)
        self.firstEffectTimerId = nil
    end

     if self.secondEffecttimerId ~= nil then
        LuaTimer.Delete(self.secondEffecttimerId)
        self.secondEffecttimerId = nil
    end

     if self.thirdEffecttimerId ~= nil then
        LuaTimer.Delete(self.thirdEffecttimerId)
        self.thirdEffecttimerId = nil
    end

    if self.alponeTimerId ~= nil then
        Tween.Instance:Cancel(self.alponeTimerId)
        self.alponeTimerId = nil
    end

    if self.wingLeftTimerId ~= nil then
        Tween.Instance:Cancel(self.wingLeftTimerId)
        self.wingLeftTimerId = nil
    end

    if self.wingRightTimerId ~= nil then
        Tween.Instance:Cancel(self.wingRightTimerId)
        self.wingRightTimerId = nil
    end

     if self.getPanelTweenId ~= nil then
        Tween.Instance:Cancel(self.getPanelTweenId)
        self.getPanelTweenId = nil
    end
end

function ToyRewardPanel:OnOpen()
    self:Clear()
    self:Grey(false)

    print(self.campId)
    self.toyId = tonumber(DataCampaign.data_list[self.campId].camp_cond_client)
    self.costId = DataCampTurn.data_turnplate[self.toyId].cost[1][1]
    self.imgLoaderOne:SetSprite(SingleIconType.Item, DataItem.data_get[self.costId].icon)

    self.wing.gameObject:SetActive(true)
    self.wingLeftDirection = 1
    self.wingRightDirection = 1

    self.leftWing.localRotation = Quaternion.Euler(0, 0, 0)
    self.rightWing.localRotation = Quaternion.Euler(0, 0, 0)
    self.wing.gameObject:SetActive(true)
    self.isReward = false
    self.getIcon.gameObject:SetActive(false)
    self.maskPanel.gameObject:SetActive(false)
    self.toyRewardMachine.gameObject:SetActive(true)

    self.firstEffect:SetActive(false)
    self.secondEffect:SetActive(false)

    self:CalculateTime()

    OpenBetaManager.Instance:send14038()
    OpenBetaManager.Instance.onTurnTime:AddListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:AddListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:AddListener(self.GetRewardTenListerner)

    self:RotationLeftWing()
    self:RotationRightWing()
    self:UpdateTopItemList()
    self:UpdateAllData()
end

function ToyRewardPanel:RotationLeftWing()
    if self.wingLeftTimerId ~= nil then
        Tween.Instance:Cancel(self.wingLeftTimerId)
        self.wingLeftTimerId = nil
    end
    self.wingLeftTimerId  = Tween.Instance:ValueChange(-20 * self.wingLeftDirection ,20 * self.wingLeftDirection ,2, nil, LeanTweenType.Linear,function(value) self:RotateLeftWingValueChange(value) end):setLoopPingPong().id
    self.wingLeftDirection  = self.wingLeftDirection  * -1
end

function ToyRewardPanel:RotationRightWing()
    if self.wingRightTimerId ~= nil then
        Tween.Instance:Cancel(self.wingRightTimerId)
        self.wingRightTimerId = nil
    end
    self.wingRightTimerId  = Tween.Instance:ValueChange(20 * self.wingRightDirection ,-20 * self.wingRightDirection ,2, nil, LeanTweenType.Linear,function(value) self:RotateRightWingValueChange(value) end):setLoopPingPong().id
    self.wingRightDirection  = self.wingRightDirection  * -1
end

function ToyRewardPanel:RotateLeftWingValueChange(value)
     self.leftWing.localRotation = Quaternion.Euler(0, 0, value)
end

function ToyRewardPanel:RotateRightWingValueChange(value)
     self.rightWing.localRotation = Quaternion.Euler(0, 0, value)
end

function ToyRewardPanel:UpdateTopItemList()
    local dataList = DataCampTurn.data_item
    -- 处理图片排列P
    local count = 0
    for i = 1, #dataList do
        if dataList[i].type == self.toyId then
            if count == 9 then
                break
            end
            count = count + 1
            local slot = nil
            local Id = dataList[i].item_id
            local itemData = DataItem.data_get[Id]
            if self.topItemList[i] == nil then
                local template = GameObject.Instantiate(self.topItemTemplate.gameObject)
                slot = ToyRewardItem.New(template)
                slot.ItemSlot:SetAll(itemData,self.extra)
                slot:SetQualityInBag(itemData.quality)
                self.topItemLayout:AddCell(slot.ItemSlot.gameObject)
                self.topItemList[i] = slot
            else
                slot = self.topItemList[i]
                slot.ItemSlot.gameObject:SetActive(true)
                slot.ItemSlot:SetAll(itemData,self.extra)
                slot:SetQualityInBag(itemData.quality)
            end
        end
    end
 end

function ToyRewardPanel:UpdateAllData()
    self:UpdateHas()

    local roleLev = RoleManager.Instance.RoleData.lev
    local rewardList = DataCampTurn.data_total_reward[self.toyId].item_list
    local count = 0
    for i,v in ipairs(rewardList) do
        local topId = tonumber(v[1])
        local bind = tonumber(v[2])
        local topNum = tonumber(v[3])
        local minLev = tonumber(v[4])
        local maxLev = tonumber(v[5])

        if (roleLev >= minLev and roleLev <= maxLev) or (minLev == 0 and maxLev == 0) then
            count = count + 1
            local topItemData = DataItem.data_get[topId]
            local slot = self.slotList[count]
            if slot ~= nil then
                slot:SetAll(topItemData, self.extra)
                slot:SetNum(topNum)
                self.nameList[count].text = DataItem.data_get[topId].name
            end
        end
    end
end

-- 协议14038回调
function ToyRewardPanel:SetRewardTime()
    if OpenBetaManager.Instance.model.turnplateList[self.toyId] == nil then
        self.topRightText.text = "0次"
    else
        self.topRightText.text = OpenBetaManager.Instance.model.turnplateList[self.toyId].num .. "次"
    end
    self:UpdateHas()
end

function ToyRewardPanel:UpdateHas()
    local count = BackpackManager.Instance:GetItemCount(DataCampTurn.data_turnplate[self.toyId].cost[1][1])
    if count > 0 then
        self.topLeftText.text = string.format("%s/1", count)
    else
        self.topLeftText.text = string.format("<color='#ff0000'>%s</color>/1", count)
    end
end

function ToyRewardPanel:ButtonClick(rewardType)
    if self.hasReward then
        return
    end

    local count = BackpackManager.Instance:GetItemCount(self.costId)
    local enough = false
    if rewardType == ToyRewardEumn.Type.One then
        enough = (count >= 1)
    elseif rewardType == ToyRewardEumn.Type.Ten then
        enough = (count >= 10)
    end

    if not enough then
        self.hasReward = false
        local itemData = ItemData.New()
        local gameObject = self.topRightText.gameObject
        itemData:SetBase(DataItem.data_get[self.costId])
        TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData})
    end

    if rewardType == ToyRewardEumn.Type.One then
        OpenBetaManager.Instance:send14039(tonumber(DataCampaign.data_list[self.campId].camp_cond_client))
    elseif rewardType == ToyRewardEumn.Type.Ten then
        OpenBetaManager.Instance:send14041(tonumber(DataCampaign.data_list[self.campId].camp_cond_client), 10)
    end

    self.rewardType = rewardType
end

-- 协议14039回调
function ToyRewardPanel:GetRewardOne(type,id)
    if id ~= 0 and type == self.toyId and self.rewardType == ToyRewardEumn.Type.One then
        self.hasReward = true
        self:PlayAnimation(type,id)
    end
end

-- 协议14041回调
function ToyRewardPanel:GetRewardTen(type,id)
    if id ~= 0 and type == self.toyId and self.rewardType == ToyRewardEumn.Type.Ten then
        self.hasReward = true
        self:PlayAnimation(type,id)
    end
end

function ToyRewardPanel:PlayAnimation(type,id)
    self.getIcon.gameObject:SetActive(false)
    self.getIconImage.enabled = false
    self.getIcon.localPosition = Vector3(144, -55, -400)

    self:Grey(true)
    self.toyRewardMachine.gameObject:SetActive(false)
    self.firstEffect:SetActive(true)
    self.firstEffectTimerId = LuaTimer.Add(4100, function() self:PlayAnimationNext(type, id) end)
    self.showMaskTimeId = LuaTimer.Add(3200, function() self:ShowBlackMask() end)
end

function ToyRewardPanel:Grey(bool)
    if bool then
        self.buttonOneImg.color = Color.grey
        self.buttonTenImg.color = Color.grey
    else
        self.buttonOneImg.color = Color.white
        self.buttonTenImg.color = Color.white
    end
end

function ToyRewardPanel:ShowBlackMask()
    self:maskAlponeChange(0)
    self.maskPanel.gameObject:SetActive(true)
    self.alponeTimerId  = Tween.Instance:ValueChange(0, 180, 0.5, nil, LeanTweenType.Linear, function(value) self:maskAlponeChange(value) end).id
end

function ToyRewardPanel:PlayAnimationNext(type,id)
   self.maskPanel.gameObject:SetActive(true)
   self.firstEffect:SetActive(false)
   self.toyRewardMachine.gameObject:SetActive(true)

    self.showNum = (BaseUtils.BASE_TIME - 1) % 4 + 1
    self.getIcon.gameObject:SetActive(true)
    self.getIconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures,"egg" .. self.showNum)
    self.getIconImage:SetNativeSize()

   self.secondEffect:SetActive(true)

   self.getPanelTweenId = Tween.Instance:MoveLocal(self.getIcon.gameObject, Vector3.zero, 0.5, function() self:OpenGetPanel(type,id) end, LeanTweenType.easeOutQuart).id
end

function ToyRewardPanel:maskAlponeChange(value)
    local t = value / 255
    local color = Color(0,0,0,t)

    self.maskPanelImage.color = color
end

function ToyRewardPanel:OpenGetPanel(type,id)
    self.getIconImage.enabled = true
    if self.alponeTimerId ~= nil then
        Tween.Instance:Cancel(self.alponeTimerId)
        self.alponeTimerId = nil
    end
    if self.rewardType == ToyRewardEumn.Type.One then
        self:OpenGetOne(type,id)
    elseif self.rewardType == ToyRewardEumn.Type.Ten then
        self:OpenGetTen(type,id)
    end
end

function ToyRewardPanel:OpenGetOne(type,id)
    if self.toyRewardPanel == nil then
        self.toyRewardPanel = ToyRewardGetPanel.New(self)
    end
    self.toyRewardPanel:Show({self.rewardType,id,self.showNum})
end

function ToyRewardPanel:OpenGetTen(type,id)
    if self.toyRewardPanel == nil then
        self.toyRewardPanel = ToyRewardGetPanel.New(self)
    end
    self.toyRewardPanel:Show({self.rewardType,nil,self.showNum})
end

-- 开蛋界面加载完
function ToyRewardPanel:PanelOpened()
    self.getIconImage.enabled = false
    self.getIcon.gameObject:SetActive(false)
    self.maskPanel.gameObject:SetActive(false)
end

-- 开蛋界面关闭
function ToyRewardPanel:PanelClosed()
    self.hasReward = false
    self.isReward = false
    self:Grey(false)
    -- self:RotationLeftWing()
    -- self:RotationRightWing()
end

function ToyRewardPanel:CalculateTime()
    self:EndTime()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    local time = DataCampTurn.data_turnplate[self.toyId].day_time[1]
    beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3]})
    endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})

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

    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function ToyRewardPanel:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        self.timeText.text = h .. "时" .. mm .. "分" .. ss .. "秒"
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function ToyRewardPanel:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end