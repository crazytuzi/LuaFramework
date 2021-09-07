TurntabelRechargePanel = TurntabelRechargePanel or BaseClass(BasePanel)

function TurntabelRechargePanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "TurntabelRechargePanel"

    self.resList = {
        {file = AssetConfig.turntable_recharge_panel, type = AssetType.Main}
        ,{file = AssetConfig.turntablerecharge_textures,type = AssetType.Dep}
        ,{file = AssetConfig.turntable_recharge_bg,type = AssetType.Main}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }
-----

    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.extra = {inbag = false, nobutton = true}
    self.possibleReward = nil

    self.rotationTimeId = nil
    self.rewardIndex = nil
    self.rewardLength = nil
    self.nowIndex = 0

    self.isEnd = true
    self.tabItemList = {}
    self.activeTabItemList = {}
    self.boxObjList = {}
    self.isOpen =false
    self.isInit = false
    self.chooseDay = 0
    self.campId = nil

    self.refreshListener = function() self:RefreshItemList() end
    self.boxGetListener = function(id) self:AcceptBoxReward(id) end
    self.startRotationListener = function(index) self:StartRotationTimer(index) end
    self.showRotationListerner = function(data) self:ShowRotationReward(data) end
end

function TurntabelRechargePanel:OnInitCompleted()

end

function TurntabelRechargePanel:__delete()
    self:RemoveListeners()

    self:EndTime()
    if self.middleLoader ~= nil then
        self.middleLoader:DeleteMe()
    end

    if self.isEnd == false then
      self.isEnd = true
      -- BibleManager.Instance:send9951()
    end

    if self.getRewardEffect ~= nil then
      self.getRewardEffect:DeleteMe()
      self.getRewardEffect = nil
    end

    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end

    if self.bufferTimeId ~= nil then
        LuaTimer.Delete(self.bufferTimeId)
        self.bufferTimeId = nil
    end

    if self.stopDelayTimeId ~= nil then
      LuaTimer.Delete(self.stopDelayTimeId)
      self.stopDelayTimeId = nil
   end

    if self.itemSlotList ~= nil then
        for k,v in pairs(self.itemSlotList) do
            v:DeleteMe()
        end
        self.itemSlotList = {}
    end
    self:AssetClearAll()
end

function TurntabelRechargePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.turntable_recharge_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent,self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.itemContainerTr = t:Find("Main/ItemContainer")
    self.itemContainerTr.anchoredPosition = Vector2(-107,55)
    self.middleButton = t:Find("Main/LuckDrawBtn"):GetComponent(Button)
    self.middleButton.onClick:AddListener(function() self:ApplyMiddleButton() end)
    self.middleButton.transform.anchoredPosition = Vector2(-106,55)
    self.middleText = t:Find("Main/LuckDrawBtn/Text"):GetComponent(Text)
    self.middleImgObj = t:Find("Main/LuckDrawBtn/RewardImage")
    self.middleLoader = SingleIconLoader.New(self.middleImgObj.gameObject)

    self.topText = t:Find("Main/NoticeText"):GetComponent(Text)

    t:Find("Main/RechargeButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3}) end)


    self.tabContainerTr = t:Find("Main/TabListPanel")

    self.boxContainerTr = t:Find("Main/Bottom")
    self.bigBg = t:Find("Main/BigBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.turntable_recharge_bg))
    UIUtils.AddBigbg(self.bigBg, bigObj)
    self.noticeBtn = t:Find("Main/Notice"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData ={
            TI18N("1.每日累充到相应档位，可获得<color='#7FFF00'>乐抽券</color>与物品奖励"),
            TI18N("2.消耗一张乐抽券可进行一次抽奖"),
            TI18N("3.幸运转盘奖励<color='#7FFF00'>每天0点刷新</color>，每日的抽奖券只可参与<color='#ffff00'>当天</color>的幸运转盘"),
            }})
    end)

    self.slider = t:Find("Main/Slider"):GetComponent(Slider)
    self.sliderText = t:Find("Main/Slider/Text"):GetComponent(Text)

    self.clockText = t:Find("Main/clockBg/Text"):GetComponent(Text)

    for i = 1,8 do
        local itemObj = self.itemContainerTr:GetChild(i - 1).gameObject
        local itemSlot = TurnTableRechargeItem.New(itemObj,nil,i,self,self.itemContainerTr)
        self.itemSlotList[i] = itemSlot
    end

    for i = 1,5 do
        local box = {}
        box.itemObj = self.boxContainerTr:GetChild(i - 1).gameObject
        box.redPoint = box.itemObj.transform:Find("RedPoint")
        box.iconImg = box.itemObj.transform:Find("Icon"):GetComponent(Image)
        table.insert(self.boxObjList,box)
    end

    for i = 1,3 do
        local tab = {}
        tab.itemObj = self.tabContainerTr:GetChild(i - 1).gameObject
        tab.btn = tab.itemObj.gameObject:GetComponent(Button)
        tab.icon1 = tab.itemObj.transform:Find("Bg1")
        tab.icon2 = tab.itemObj.transform:Find("Bg2")
        tab.icon3 = tab.itemObj.transform:Find("Bg3")
        table.insert(self.tabItemList,tab)
    end

    for i,v in ipairs(self.tabItemList) do
        v.itemObj.gameObject:SetActive(false)
    end

    self:OnOpen()
 end


function TurntabelRechargePanel:OnOpen()

    self:AddListeners()
    self.isOpen = false
    self:InitTabList()
    self:CalculateTime()
end

function TurntabelRechargePanel:InitTabList()
    -- self.activeTabItemList = {}
    -- local baseTime = BaseUtils.BASE_TIME
    -- local timeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    -- local beginTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    -- local distance = baseTime - beginTime
    -- local d = tonumber(os.date("%d",distance))
    -- for i,v in ipairs(self.tabItemList) do
    --     if i > d + 1 then
    --         v.icon1.gameObject:SetActive(false)
    --         v.icon2.gameObject:SetActive(false)
    --         v.icon3.gameObject:SetActive(true)
    --     else
    --         v.icon1.gameObject:SetActive(true)
    --         v.icon2.gameObject:SetActive(false)
    --         v.icon3.gameObject:SetActive(false)
    --        table.insert(self.activeTabItemList,v)
    --     end
    -- end


    local baseTime = BaseUtils.BASE_TIME
    local timeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local beginTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    local distance = baseTime - beginTime
    local d = math.floor(distance/86400)

    if d < 0 or d > 3 then
        d = 0
    end
    TurntabelRechargeManager.Instance:Send17883(d + 1)
    self.chooseDay = d + 1
end

function TurntabelRechargePanel:ApplyBoxBtn(id,index)
    if self.isEnd == true then
      if TurntabelRechargeManager.Instance.boxRewardList[index].need_point > TurntabelRechargeManager.Instance.regPoint then
            if self.possibleReward == nil then
                self.possibleReward = SevenLoginTipsPanel.New(self)
            end
            self.possibleReward:Show({TurntabelRechargeManager.Instance.boxRewardList[index].box_reward,5,{nil,nil,150,123},"充值可直接获得以下道具"})
        else
            TurntabelRechargeManager.Instance:Send17886(TurntabelRechargeManager.Instance.days,id)
        end
    end
end

function TurntabelRechargePanel:ApplyTabBtn(index)
    for i,v in ipairs(self.activeTabItemList) do
         if i == index then
            self.chooseDay = index
            v.icon1.gameObject:SetActive(false)
            v.icon2.gameObject:SetActive(true)
            v.icon3.gameObject:SetActive(false)
        else
            v.icon1.gameObject:SetActive(true)
            v.icon2.gameObject:SetActive(false)
            v.icon3.gameObject:SetActive(false)
        end
    end
    TurntabelRechargeManager.Instance:Send17883(self.chooseDay)

end

function TurntabelRechargePanel:AcceptBoxReward(id)
    if self.possibleReward == nil then
            self.possibleReward = SevenLoginTipsPanel.New(self)
    end
    local callBack = function(height) self:CallBack(self.possibleReward,height) end
    local timeCallBack = function() self:SecondCallBack(self.possibleReward) end
    local deleteCallBack = function() self:DeleteCallBack() end
    local myId = nil
    for k,v in pairs(TurntabelRechargeManager.Instance.boxRewardList) do
        if v.box_id == id then
            myId = k
        end
    end
    self.possibleReward:Show({TurntabelRechargeManager.Instance.boxRewardList[myId].box_reward,5,{[5] = false},"",{0,0,200/255},{0,1000,timeCallBack},callBack,deleteCallBack})
end


function TurntabelRechargePanel:AddListeners()
    TurntabelRechargeManager.Instance.onRefreshItem:AddListener(self.refreshListener)
    TurntabelRechargeManager.Instance.onGetBoxReward:AddListener(self.boxGetListener)
    TurntabelRechargeManager.Instance.onStartRotation:AddListener(self.startRotationListener)
    TurntabelRechargeManager.Instance.onShowRotation:AddListener(self.showRotationListerner)
end


function TurntabelRechargePanel:RemoveListeners()
    TurntabelRechargeManager.Instance.onRefreshItem:RemoveListener(self.refreshListener)
    TurntabelRechargeManager.Instance.onGetBoxReward:RemoveListener(self.boxGetListener)
    TurntabelRechargeManager.Instance.onStartRotation:RemoveListener(self.startRotationListener)
    TurntabelRechargeManager.Instance.onShowRotation:RemoveListener(self.showRotationListerner)
end


function TurntabelRechargePanel:ReloadItemSlotData()
    for i,v in ipairs(self.itemSlotList) do
        v:ShowEffect(false)
    end
end

function TurntabelRechargePanel:OnHide()
    self:RemoveListeners()
    self:EndTime()
    if self.itemSlotList ~= nil then
        for k,v in pairs(self.itemSlotList) do
            v:ShowFlashEffect(false)
            v:ShowFlashMoreEffect(false)
        end
    end

   if self.bufferTimeId ~= nil then
        LuaTimer.Delete(self.bufferTimeId)
        self.bufferTimeId = nil
    end

   if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
   end

   if self.stopDelayTimeId ~= nil then
      LuaTimer.Delete(self.stopDelayTimeId)
      self.stopDelayTimeId = nil
   end


   if self.isEnd == false then
      self.isEnd = true
       TurntabelRechargeManager.Instance:Send17885(self.chooseDay)
   end
end


function TurntabelRechargePanel:ApplyMiddleButton()
    if self.isEnd == true and self.isInit == true then
        if  BackpackManager.Instance:GetItemCount(TurntabelRechargeManager.Instance.totalItemList.random_cost[1].item_id) <= 0 then
            local itemData = ItemData.New()
            itemData:SetBase(DataItem.data_get[TurntabelRechargeManager.Instance.totalItemList.random_cost[1].item_id])
            TipsManager.Instance:ShowItem({gameObject = self.middleButton.gameObject, itemData = itemData})
        end
        TurntabelRechargeManager.Instance:Send17884(self.chooseDay)
        self.animationTimes = 0
    end
end


function TurntabelRechargePanel:StartRotationTimer(index)
    self.animationTimes = 0
    self.rewardLength = #self.activateItemList
    self.startTimer = 180 / self.rewardLength
    for i,v in ipairs(self.activateItemList) do
        if self.itemSlotList[index] == v then
            self.rewardIndex = i
        end
    end
    self:RotationTimer()
end
function TurntabelRechargePanel:RotationTimer()
    self.isEnd = false
    if #self.activateItemList > 1 then
        math.randomseed(tostring(os.time()):reverse():sub(1,6))
        self.addNum = math.random(10,12)
        local targetRewardIndex = self.rewardIndex % self.rewardLength
        if self.rewardIndex > 0 and targetRewardIndex == 0 then
            targetRewardIndex = 8
        end

        self.tweenStartIndex = ((self.rewardIndex + self.rewardLength*10) - self.addNum) % (self.rewardLength)

        self.rotationTimeId = LuaTimer.Add(0,self.startTimer, function()
               self:ChangeItemSelect()
       end)
    else
        TurntabelRechargeManager.Instance:Send17885(self.chooseDay)
    end
end

function TurntabelRechargePanel:RefreshItemList()

    self.activateItemList = {}
    for i,v in ipairs(TurntabelRechargeManager.Instance.rotationItemList) do
        if self.itemSlotList[i] then
            self.itemSlotList[i]:SetActivate(v.is_random)
            self.itemSlotList[i]:SetSlot(v.item_id,self.extra,v.num)
            self.itemSlotList[i]:ShowBeautifulEffect(v.is_effet)
            if v.is_random == 0 then
                table.insert(self.activateItemList,self.itemSlotList[i])
            end
        end
    end
    local distanceValue = 0
    local initFirst = false
    for i,v in ipairs(self.boxObjList) do
        local btn = v.itemObj.transform:GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() self:ApplyBoxBtn(TurntabelRechargeManager.Instance.boxRewardList[i].box_id,i) end)

        if TurntabelRechargeManager.Instance.boxRewardList[i].is_reward == 0 then
            if TurntabelRechargeManager.Instance.boxRewardList[i].need_point > TurntabelRechargeManager.Instance.regPoint then
                if initFirst == false then
                    initFirst = true
                    distanceValue = TurntabelRechargeManager.Instance.boxRewardList[i].need_point - TurntabelRechargeManager.Instance.regPoint
                end
                v.redPoint.gameObject:SetActive(false)
            else
                v.redPoint.gameObject:SetActive(true)
            end
            v.iconImg.color = Color.white
        elseif TurntabelRechargeManager.Instance.boxRewardList[i].is_reward == 1 then
            v.redPoint.gameObject:SetActive(false)
            v.iconImg.color = Color.grey
        end

    end

    for i,v in ipairs(self.tabItemList) do
        v.btn.onClick:RemoveAllListeners()
        v.btn.onClick:AddListener(function() self:ApplyTabBtn(i) end)
    end

    self.slider.value = TurntabelRechargeManager.Instance.regPoint/TurntabelRechargeManager.Instance.boxRewardList[5].need_point
    self.sliderText.text = string.format("%s/%s",TurntabelRechargeManager.Instance.regPoint,TurntabelRechargeManager.Instance.boxRewardList[5].need_point)


    self.middleLoader:SetSprite(SingleIconType.Item,DataItem.data_get[TurntabelRechargeManager.Instance.totalItemList.random_cost[1].item_id].icon)
    self.middleImgObj.gameObject:SetActive(true)
    self.middleText.text =  BackpackManager.Instance:GetItemCount(TurntabelRechargeManager.Instance.totalItemList.random_cost[1].item_id)

    self.topText.text = string.format("已充值<color='#7FFF00'>%s</color>元\n离下宝箱还差<color='#7FFF00'>%s</color>元",TurntabelRechargeManager.Instance.regPoint/10,distanceValue/10)
    if self.isOpen == false then
        self:ApplyTabBtn(1)
        self.isOpen = true
    end

    self.isInit = true


end

function TurntabelRechargePanel:ChangeItemSelect()
    if self.animationTimes < self.rewardLength* 3 + self.tweenStartIndex then
        self.animationTimes = self.animationTimes + 1
        self.nowIndex = self.animationTimes % (self.rewardLength)
        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end

        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end

        if self.activateItemList[self.nowIndex] ~= nil then
            self.activateItemList[self.nowIndex]:ShowFlashEffect(true)
        end

        if self.activateItemList[lastEffectIndex] ~= nil then
            self.activateItemList[lastEffectIndex]:ShowFlashEffect(false)
        end
    else
        if self.rotationTimeId ~= nil then
            LuaTimer.Delete(self.rotationTimeId)
            self.rotationTimeId = nil
        end
        local tweenTime = self.startTimer
        self.lastTweenIndex = 0
        self.bufferTimeId = LuaTimer.Add(self.startTimer, function()
               self.bufferTimeId = nil
               self:ValueChange()
       end)
   end

end

function TurntabelRechargePanel:ValueChange()

    if self.addNum >= 1 then

        if self.addNum >=1 then
            self.addNum = self.addNum - 1
            self.lastTweenIndex = self.lastTweenIndex + 1
            self.animationTimes = self.animationTimes + 1
            self.nowIndex = self.animationTimes % (self.rewardLength)
        end


        if self.nowIndex == 0 and self.animationTimes > 0 then
            self.nowIndex = self.rewardLength
        end

        local lastEffectIndex = (self.animationTimes - 1) % (self.rewardLength)
        if lastEffectIndex == 0 and (self.animationTimes - 1) > 0 then
            lastEffectIndex = self.rewardLength
        end



        if self.activateItemList[self.nowIndex] ~= nil then
            self.activateItemList[self.nowIndex]:ShowFlashEffect(true)
        end

        if self.activateItemList[lastEffectIndex] ~= nil then
            self.activateItemList[lastEffectIndex]:ShowFlashEffect(false)
        end

         if self.addNum < 1 then
            self:TweenEnd()
            return
        end


            local time = math.pow(self.lastTweenIndex,2.53) + self.startTimer
            self.bufferId = LuaTimer.Add(time, function()
                       self.bufferId = nil
                       self:ValueChange()
            end)



    end

end

function TurntabelRechargePanel:TweenEnd()
    self.stopDelayTimeId = LuaTimer.Add(400,function() self.stopDelayTimeId = nil self:FlashItem() end)
end

function TurntabelRechargePanel:FlashItem()
    self.activateItemList[self.nowIndex]:ShowFlashEffect(false)
    self.activateItemList[self.nowIndex]:ShowFlashMoreEffect(false)
    self.activateItemList[self.nowIndex]:ShowFlashMoreEffect(true)
    self.endActiveEffect = self.activateItemList[self.nowIndex]
    TurntabelRechargeManager.Instance:Send17885(self.chooseDay)
end

function TurntabelRechargePanel:ShowRotationReward(data)
    self.stopDelayTimeId = LuaTimer.Add(300,function() self.stopDelayTimeId = nil self:GetReward(data) end)
end

function TurntabelRechargePanel:GetReward(data)
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end
    local callBack = function(height) self:CallBack(self.possibleReward,height) end
    local timeCallBack = function() self:SecondCallBack(self.possibleReward) end
    local deleteCallBack = function() self:DeleteCallBack() end
    self.possibleReward:Show({data,5,{[5] = false},"",{0,0,200/255},{0,1000,timeCallBack},callBack,deleteCallBack})
    self.isEnd = true
end

function TurntabelRechargePanel:SecondCallBack(table)
    if table.countTime <= 0 then
       table:DeleteMe()
    else
       table.confirmText.text = "确定" .. string.format("(%ss)", tostring(table.countTime))
    end
end

function TurntabelRechargePanel:CallBack(table,height)
    local gameObject = GameObject.Instantiate(table.componentContainer:Find("Button").gameObject)
    table:SetParent(table.objParent,gameObject)
    table.confirmBtn = gameObject.transform:GetComponent("Button")
    table.confirmBtn.onClick:AddListener(function() table:DeleteMe() end)
    table.confirmText = gameObject.transform:Find("Text"):GetComponent(Text)
    table.countTime = 10

    if self.getRewardEffect == nil then
        self.getRewardEffect = BibleRewardPanel.ShowEffect(20298,table.objParent.transform, Vector3(1, 1, 1), Vector3(0,(height / 2) - 20, -2))
    end
    self.getRewardEffect:SetActive(true)

    local rectTransform = gameObject.transform:GetComponent(RectTransform)
    rectTransform.anchoredPosition = Vector2(0,- table.containerHeight / 2 + 20)
end



function TurntabelRechargePanel:DeleteCallBack()

    if self.getRewardEffect ~= nil then
      self.getRewardEffect:DeleteMe()
      self.getRewardEffect = nil
    end
    if self.endActiveEffect ~= nil then
        self.endActiveEffect:ShowFlashMoreEffect(false)
    end
end

function TurntabelRechargePanel:CalculateTime()
    self:EndTime()
    local baseTime = BaseUtils.BASE_TIME
    local h = tonumber(os.date("%H", baseTime))
    local m = tonumber(os.date("%M", baseTime))
    local s = tonumber(os.date("%S", baseTime))

    self.timestamp = 86400 -(h*3600 + m*60 + s)

    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function TurntabelRechargePanel:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        self.clockText.text = h .. "时" .. mm .. "分" .. ss .. "秒"
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function TurntabelRechargePanel:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end
-- function TurntabelRechargePanel:GetReward(rewardList)

--      self.nowBeautifulId = 1
--     if self.possibleReward == nil then
--         self.possibleReward = SevenLoginTipsPanel.New(self)
--     end

--     if self.beatifulId ~= nil then
--         LuaTimer.Delete(self.beatifulId)
--         self.beatifulId = nil
--     end

--     local callBack = function(height) self:CallBack(self.possibleReward,height) end
--     local timeCallBack = function() self:SecondCallBack(self.possibleReward) end
--     local deleteCallBack = function() self:DeleteCallBack() end


--      self.possibleReward:Show({rewardList,5,{[5] = false},"",{0,0,200/255},{0,1000,timeCallBack},callBack,deleteCallBack})

--      self.nowBeautifulId = 1
--      self.falshNum = 4
--      self.nowItemId = 0
--      self.hasNextRewardLength = 1
--      self.targetRewardId = 0
--      self.hasArriveTarget = true
--      self:Vector3(0, 32, -400)(true)
--      self.isEnd = true
-- end





