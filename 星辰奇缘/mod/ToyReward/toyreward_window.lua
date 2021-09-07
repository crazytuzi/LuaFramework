ToyRewardWindow = ToyRewardWindow or BaseClass(BaseWindow)

function ToyRewardWindow:__init(model)
  self.model = model
  self.mgr = ToyRewardManager.Instance
    self.resList = {
        {file = AssetConfig.toyreward_window, type = AssetType.Main}
        ,{file = AssetConfig.toyreward_textures, type = AssetType.Dep}
        ,{file = AssetConfig.leveljumptexture, type = AssetType.Dep}
        ,{file = AssetConfig.toyreward_big_bg, type = AssetType.Main}
        ,{file = string.format(AssetConfig.effect,20412), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect,20413), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.windowId = WindowConfig.WinID.toyreward_window

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
    self.openTweenId = nil
end

function ToyRewardWindow:__delete()
    OpenBetaManager.Instance.onTurnTime:RemoveListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardTenListerner)

    if self.hasReward then
      OpenBetaManager.Instance:send14040()
    end
    self.hasReward = false

    self:EndTime()

    self.topImage = nil

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

    if self.openTweenId ~= nil then
       Tween.Instance:Cancel(self.openTweenId)
       self.openTweenId = nil
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

    if self.toyRewardPanel ~= nil then
        self.toyRewardPanel:DeleteMe()
        self.toyRewardPanel = nil
    end

    if self.topItemLayout ~= nil then
        self.topItemLayout:DeleteMe()
        self.topItemLayout = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end



    self:AssetClearAll()
end

function ToyRewardWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.toyreward_window))
    self.gameObject.name = "ToyRewardWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.closeBtn = t:Find("Main/Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:Close() end)

    self.bigBg = t:Find("Main/Bg/BackBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.toyreward_big_bg))
    UIUtils.AddBigbg(self.bigBg, bigObj)
    bigObj.transform.anchoredPosition = Vector2(0, 4)

    self.topScrollRect = t:Find("Main/Bg/RectScroll")
    self.topScrollRect:GetComponent(ScrollRect).enabled = false
    self.topItemContainer = t:Find("Main/Bg/RectScroll/Container")
    self.topItemTemplate = t:Find("Main/Bg/TopItemSlot")
    self.topItemTemplate.gameObject:SetActive(false)

    self.topItemLayout = LuaBoxLayout.New(self.topItemContainer.gameObject, {axis = BoxLayoutAxis.X, border = 12, cspacing = 30})

    self.topLeftText = t:Find("Main/Bg/Tobbg/LeftText"):GetComponent(Text)
    self.topRightText = t:Find("Main/Bg/Tobbg/RightText"):GetComponent(Text)

    local buttonContainTr = t:Find("Main/Bg/ButtomContain")
    self.bmTopItemSlotTr = buttonContainTr:Find("TopMask/ItemContainer/ItemSlot")

    buttonContainTr:Find("TopMask/TopTab/Text"):GetComponent(Text).text = TI18N("累计5次额外获得")
    self.bmTopText = buttonContainTr:Find("TopMask/ItemContainer/Text"):GetComponent(Text)
    self.bmBmLeftText = buttonContainTr:Find("ButtomMask/LeftItemContainer/Text"):GetComponent(Text)
    self.bmBmRightText = buttonContainTr:Find("ButtomMask/RightItemContainer/Text"):GetComponent(Text)
    -- buttonContainTr:Find("ButtomMask/Text"):GetComponent(Text).text = DataCampaign.data_list[552].cond_desc

    self.buttonOne = t:Find("Main/Bg/ButtonLeft"):GetComponent(Button)
    self.buttonTen = t:Find("Main/Bg/ButtonRight"):GetComponent(Button)
    self.buttonOneImg = t:Find("Main/Bg/ButtonLeft"):GetComponent(Image)
    self.buttonTenImg = t:Find("Main/Bg/ButtonRight"):GetComponent(Image)

    self.timeText = t:Find("Main/Bg/TopContainer/TimeBg/TimeText"):GetComponent(Text)

    self.topImage = t:Find("Main/Bg/TopContainer/LeftTitle"):GetComponent(Image)

    self.wing = t:Find("Main/Bg/WingbBg")
    self.leftWing = t:Find("Main/Bg/WingbBg/LeftWing")
    self.rightWing = t:Find("Main/Bg/WingbBg/RightWing")

    self.buttonOne.onClick:AddListener(function()
        if self.isReward == false then
           self:ButtonClick(ToyRewardEumn.Type.One)
        end
    end)
    self.buttonTen.onClick:AddListener(function()
        if self.isReward == false then
           self:ButtonClick(ToyRewardEumn.Type.Ten)
        end
    end)

    self.toyRewardMachine = t:Find("Main/Bg/RightBackBg")
    self.getIcon = t:Find("Main/Bg/GetIcon")
    self.getIcon.gameObject:SetActive(false)
    self.getIcon.localPosition = Vector3(144, -55, -400)
    self.getIconImage = t:Find("Main/Bg/GetIcon"):GetComponent(Image)
    self.getIconImage.enabled = false

    self.firstEffect = BibleRewardPanel.ShowEffect(20412, self.gameObject.transform, Vector3.one, Vector3(148, -45, -400))
    self.firstEffect:SetActive(false)

    self.secondEffect = BibleRewardPanel.ShowEffect(20413, self.getIcon, Vector3.one, Vector3(0, 0, -400))
    self.secondEffect:SetActive(false)
    self.maskPanel = t:Find("Main/Bg/MaskPanel")
    self.maskPanelImage= self.maskPanel:GetComponent(Image)

    self:OnOpen()
end

function ToyRewardWindow:OnOpen()
    self.wing.gameObject:SetActive(true)
    self.wingLeftDirection = 1
    self.wingRightDirection = 1

    self.leftWing.localRotation = Vector3(0,0,0)
    self.rightWing.localRotation = Vector3(0,0,0)
    self.wing.gameObject:SetActive(true)
    self.isReward = false
    self.getIcon.gameObject:SetActive(false)
    self.toyRewardMachine.gameObject:SetActive(true)

    self.firstEffect:SetActive(false)
    self.secondEffect:SetActive(false)

    self:CalculateTime()

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

    if self.bmTopItemSlot ~= nil then
        self.bmTopItemSlot:DeleteMe()
        self.bmTopItemSlot = nil
    end

    OpenBetaManager.Instance:send14038()
    OpenBetaManager.Instance.onTurnTime:AddListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:AddListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:AddListener(self.GetRewardTenListerner)

    self:RotationLeftWing()
    self:RotationRightWing()
    self:UpdateTopItemList()
    self:UpdateAllData()
end

function ToyRewardWindow:RotationLeftWing()
    self.wingLeftTimerId  = Tween.Instance:ValueChange(-20 * self.wingLeftDirection ,20 * self.wingLeftDirection ,2, nil, LeanTweenType.Linear,function(value) self:RotateLeftWingValueChange(value) end):setLoopPingPong().id
    self.wingLeftDirection  = self.wingLeftDirection  * -1
end

function ToyRewardWindow:RotationRightWing()
    self.wingRightTimerId  = Tween.Instance:ValueChange(20 * self.wingRightDirection ,-20 * self.wingRightDirection ,2, nil, LeanTweenType.Linear,function(value) self:RotateRightWingValueChange(value) end):setLoopPingPong().id
    self.wingRightDirection  = self.wingRightDirection  * -1
end

function ToyRewardWindow:RotateLeftWingValueChange(value)
     self.leftWing.localRotation = Quaternion.Euler(0, 0, value)
end

function ToyRewardWindow:RotateRightWingValueChange(value)
     self.rightWing.localRotation = Quaternion.Euler(0, 0, value)
end

function ToyRewardWindow:UpdateTopItemList()
    local dataList = DataCampTurn.data_item
    -- 处理图片排列P
    local count = 0
    for i = 1, #dataList do
        if dataList[i].type == 3 then
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

function ToyRewardWindow:UpdateAllData()
    self:UpdateHas()

    if self.bmTopItemSlot == nil then
        self.bmTopItemSlot = ItemSlot.New(self.bmTopItemSlotTr.gameObject)
    end

    local topId = DataCampTurn.data_total_reward[3].item_list[1][1]
    local topItemData = DataItem.data_get[topId]
    local topNum = DataCampTurn.data_total_reward[3].item_list[1][3]
    self.bmTopItemSlot:SetAll(topItemData,self.extra)
    self.bmTopItemSlot:SetNum(topNum)
    self.bmTopText.text = DataItem.data_get[topId].name
end

-- 协议14038回调
function ToyRewardWindow:SetRewardTime()
    if OpenBetaManager.Instance.model.turnplateList[3] == nil then
         self.topRightText.text = "0次"
    else
         self.topRightText.text = OpenBetaManager.Instance.model.turnplateList[3].num .. "次"
    end
    self:UpdateHas()
end

function ToyRewardWindow:UpdateHas()
    local count = BackpackManager.Instance:GetItemCount(DataCampTurn.data_turnplate[3].cost[1][1])
    if count > 0 then
        self.topLeftText.text = string.format("1/%s", count)
    else
        self.topLeftText.text = string.format("1/<color='#ff0000'>%s</color>", count)
    end
end

function ToyRewardWindow:ButtonClick(rewardType)
    if self.hasReward then
        return
    end

    self.isReward = true
    if rewardType == ToyRewardEumn.Type.One then
       OpenBetaManager.Instance:send14039(3)
    elseif rewardType == ToyRewardEumn.Type.Ten then
        OpenBetaManager.Instance:send14041(3,10)
    end

    self.rewardType = rewardType
end

-- 协议14039回调
function ToyRewardWindow:GetRewardOne(type,id)
    if id ~= 0 and type == 3 and self.rewardType == ToyRewardEumn.Type.One then
        self.hasReward = true
        self:PlayAnimation(type,id)
    end
end

-- 协议14041回调
function ToyRewardWindow:GetRewardTen(type,id)
    if id ~= 0 and type == 3 and self.rewardType == ToyRewardEumn.Type.Ten then
        self.hasReward = true
        self:PlayAnimation(type,id)
    end
end

function ToyRewardWindow:PlayAnimation(type,id)
    --  if self.wingLeftTimerId ~= nil then
    --     Tween.Instance:Cancel(self.wingLeftTimerId)
    --     self.wingLeftTimerId = nil
    -- end

    -- if self.wingRightTimerId ~= nil then
    --     Tween.Instance:Cancel(self.wingRightTimerId)
    --     self.wingRightTimerId = nil
    -- end

    self.getIcon.gameObject:SetActive(false)
    self.getIconImage.enabled = false
    self.getIcon.localPosition = Vector3(144, -55, -400)

    self:Grey(true)
    self.toyRewardMachine.gameObject:SetActive(false)
    self.firstEffect:SetActive(true)
    self.firstEffectTimerId = LuaTimer.Add(4100, function() self:PlayAnimationNext(type, id) end)
    self.showMaskTimeId = LuaTimer.Add(3200, function() self:ShowBlackMask() end)
end

function ToyRewardWindow:Grey(bool)
    if bool then
        self.buttonOneImg.color = Color.grey
        self.buttonTenImg.color = Color.grey
    else
        self.buttonOneImg.color = Color.white
        self.buttonTenImg.color = Color.white
    end
end

function ToyRewardWindow:ShowBlackMask()
    self:maskAlponeChange(0)
    self.maskPanel.gameObject:SetActive(true)
    self.alponeTimerId  = Tween.Instance:ValueChange(0, 180, 0.5, nil, LeanTweenType.Linear, function(value) self:maskAlponeChange(value) end).id
end

function ToyRewardWindow:PlayAnimationNext(type,id)
   self.maskPanel.gameObject:SetActive(true)
   self.firstEffect:SetActive(false)
   self.toyRewardMachine.gameObject:SetActive(true)

    self.showNum = (BaseUtils.BASE_TIME - 1) % 4 + 1
    self.getIcon.gameObject:SetActive(true)
    self.getIconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures,"egg" .. self.showNum)
    self.getIconImage:SetNativeSize()

   self.secondEffect:SetActive(true)

   Tween.Instance:MoveLocal(self.getIcon.gameObject, Vector3.zero, 0.5, function() self:OpenGetPanel(type,id) end, LeanTweenType.easeOutQuart)
end

function ToyRewardWindow:maskAlponeChange(value)
    local t = value / 255
    local color = Color(0,0,0,t)

    self.maskPanelImage.color = color
end

function ToyRewardWindow:OpenGetPanel(type,id)
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

function ToyRewardWindow:OpenGetOne(type,id)
    if self.toyRewardPanel == nil then
        self.toyRewardPanel = ToyRewardGetPanel.New(self)
    end
    self.toyRewardPanel:Show({self.rewardType,id,self.showNum})
end

function ToyRewardWindow:OpenGetTen(type,id)
    if self.toyRewardPanel == nil then
        self.toyRewardPanel = ToyRewardGetPanel.New(self)
    end
    self.toyRewardPanel:Show({self.rewardType,nil,self.showNum})
end

-- 开蛋界面加载完
function ToyRewardWindow:PanelOpened()
    self.getIconImage.enabled = false
    self.getIcon.gameObject:SetActive(false)
    self.maskPanel.gameObject:SetActive(false)
end

-- 开蛋界面关闭
function ToyRewardWindow:PanelClosed()
    self.hasReward = false
    self.isReward = false
    self:Grey(false)
    -- self:RotationLeftWing()
    -- self:RotationRightWing()
end

function ToyRewardWindow:Close()
    self.model:CloseWin()
end

function ToyRewardWindow:CalculateTime()
    self:EndTime()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    local time = DataCampTurn.data_turnplate[3].day_time[1]
    beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3]})
    endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})

    self.timestamp = 0
    if baseTime < beginTime then
      -- 未开启
        self.timestamp = beginTime - baseTime
        self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage1")
    else
        self.timestamp = endTime - baseTime
        self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage2")
    end

    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function ToyRewardWindow:TimeLoop()
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

function ToyRewardWindow:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end