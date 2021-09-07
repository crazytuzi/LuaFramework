BibleRechargePanel = BibleRechargePanel or BaseClass(BasePanel)

function BibleRechargePanel:__init(model,parentPanel)
    self.parentPanel = parentPanel
    self.model = model
    self.name = "BibleRechargePanel"

    self.resList = {
        {file = AssetConfig.bible_rechargepanel, type = AssetType.Main}
        ,{file = AssetConfig.bible_rechargepanel_textures,type = AssetType.Dep}
    }

    self.slot = nil
    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.replyButtonListener = function(dataList) self:GetReward(dataList) end
    self.replyLuckyListener = function() self:SetData() end
    self.replyTopListerer = function() self:SetTopData() end
    self.replyGetReward = function(dataList) self:RotationTimer(dataList) end

    self.extra = {inbag = false, nobutton = true}
    self.possibleReward = nil

    self.rotationTimeId = nil
    self.stopDelayTimeId = nil
    self.nowItemId = 0
    self.rewardList = nil
    self.rewardLength = nil
    self.hasNextRewardLength = 1
    self.lastid = nil
    self.nextid = nil

    self.targetRewardId = 0
    self.hasArriveTarget = true

    self.flashNum = 1
    self.isEnd = true

    self.getRewardEffect = nil

    self.iconEffect = nil
    self.nowBeautifulId = 1
end

function BibleRechargePanel:OnInitCompleted()

end

function BibleRechargePanel:__delete()
    self:RemoveListeners()

    if self.getRewardEffect ~= nil then
      self.getRewardEffect:DeleteMe()
      self.getRewardEffect = nil
    end

    if self.iconEffect ~= nil then
      self.iconEffect:DeleteMe()
      self.iconEffect = nil
    end

    if self.isEnd == false then
      self.isEnd = true
      BibleManager.Instance:send9951()
    end

    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end

    if self.stopDelayTimeId ~= nil then
        LuaTimer.Delete(self.stopDelayTimeId)
        self.stopDelayTimeId = nil
    end


    if self.beatifulId ~= nil then
        LuaTimer.Delete(self.beatifulId)
        self.beatifulId = nil
    end

    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
    end

    if self.itemSlotList ~= nil then
    	for k,v in pairs(self.itemSlotList) do
    		v:DeleteMe()
    	end
    	self.itemSlotList = {}
    end
    self:AssetClearAll()
end

function BibleRechargePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_rechargepanel))
 	self.gameObject.name = self.name
 	UIUtils.AddUIChild(self.parentPanel,self.gameObject)
 	local t = self.gameObject.transform
 	self.transform = t

    self.itemContainerTr = t:Find("Main/Bg/ItemContainer")

    self.addButton = t:Find("Main/Bg/Middle/TopBg/AddButton"):GetComponent(Button)
    self.addButton.onClick:AddListener(function() self:ApplyAddButton() end)

    self.dataText = t:Find("Main/Bg/Middle/DataText"):GetComponent(Text)
    self.dataText.text = TI18N("本期时间：<color='#13fc60'>2017-5-17至2017-7-27</color>")
    self.dataText.gameObject:SetActive(true)


    self.leftButton = t:Find("Main/Bg/Middle/LeftButton"):GetComponent(Button)
    self.leftButton.onClick:AddListener(function() self:ApplyLeftButton() end)
    self.leftBtnText = t:Find("Main/Bg/Middle/LeftButton/Text"):GetComponent(Text)
    self.leftBtnBottomText = t:Find("Main/Bg/Middle/LeftButton/buttonText").gameObject:SetActive(false)
    self.leftBtnText.text = "开一次"

    self.rightButton = t:Find("Main/Bg/Middle/RightButton"):GetComponent(Button)
    self.rightButton.onClick:AddListener(function() self:ApplyRightButton() end)
    self.rightBtnText = t:Find("Main/Bg/Middle/RightButton/Text"):GetComponent(Text)
    self.rightBtnText.text = "五连开"
    self.rightBtnBottomText = t:Find("Main/Bg/Middle/RightButton/buttonText").gameObject:SetActive(false)

    self.noticeBtn = t:Find("Main/Bg/Middle/Notice"):GetComponent(Button)
    t:Find("Main/Bg/Middle/DataText2").gameObject:SetActive(false)
    t:Find("Main/Bg/Middle/DataText").gameObject:SetActive(false)
    self.noticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData ={
            TI18N("1.充值好礼次数可通过<color='#ffff00'>充值</color>获得"),
            TI18N("2.每抽取一次充值好礼，都会增加一定数量的<color='#ffff00'>幸运值</color>"),
            TI18N("3.获得<color='#ffff00'>稀有</color>道具后，幸运值会<color='#ffff00'>重置</color>为0，进行重新累计，稀有道具可重复获得")
          },isChance = true})
        --TipsManager.Instance.model:OpenChancePanel(202)
        TipsManager.Instance.model:ShowChance({chanceId = 202, special = true, isMutil = true})
    end)

    self.topNumText = t:Find("Main/Bg/Middle/TopBg/TopText"):GetComponent(Text)
    self.numText = t:Find("Main/Bg/Middle/NumText"):GetComponent(Text)

    self.luckyScroll = t:Find("Main/Bg/Middle/Slider"):GetComponent(Slider)




 	for i = 1,14 do
 		local itemObj = self.itemContainerTr:GetChild(i - 1).gameObject
 		local itemSlot = BibleRechargeItem.New(itemObj,nil,i,self,self.itemContainerTr)
        self.itemSlotList[i] = itemSlot
 	end

    self:OnOpen()
 end


function BibleRechargePanel:OnOpen()
    BibleManager.Instance:send9949()
    RoleManager.Instance:send10003()
    BibleManager.Instance.redPointDic[1][23] = false
    BibleManager.Instance.onUpdateRedPoint:Fire()



    if self.iconEffect == nil then
        self.iconEffect = BibleRewardPanel.ShowEffect(20381,self.luckyScroll.transform, Vector3(1, 1, 1), Vector3(0,0,-1))
    end
    self.iconEffect:SetActive(true)
    self.nowBeautifulId = 1
    self.nowItemId = 1
    self:AddListeners()
    self:ReloadItemSlotData()
end


function BibleRechargePanel:BeautifualEffect()
    local t = false
    for i = self.nowBeautifulId,#self.itemSlotList do
        if self.itemSlotList[i].type == 2 or self.itemSlotList[i].type == 3 then
            self.itemSlotList[i]:ShowBeautifulEffect(false)
            self.itemSlotList[i]:ShowBeautifulEffect(true)
            self.nowBeautifulId = i
            t = true
            break
        end
    end

    if t == true then
        self.nowBeautifulId = self.nowBeautifulId + 1
        if self.nowBeautifulId > #self.itemSlotList then
          self.nowBeautifulId = 1
        end
    else
       self.nowBeautifulId = 1
    end
end


function BibleRechargePanel:AddListeners()
   BibleManager.Instance.onUpdateRecharge:AddListener(self.replyButtonListener)
   BibleManager.Instance.onUpdateLucky:AddListener(self.replyLuckyListener)
   BibleManager.Instance.onUpdateGetReward:AddListener(self.replyGetReward)
   RoleManager.Instance.recharchUpdate:AddListener(self.replyTopListerer)
   RoleManager.Instance.updateRedPoint:AddListener(BibleManager.Instance.rechargeRedPointListerner)

end


function BibleRechargePanel:RemoveListeners()
   BibleManager.Instance.onUpdateRecharge:RemoveListener(self.replyButtonListener)
   BibleManager.Instance.onUpdateLucky:RemoveListener(self.replyLuckyListener)
   BibleManager.Instance.onUpdateGetReward:RemoveListener(self.replyGetReward)
   RoleManager.Instance.recharchUpdate:RemoveListener(self.replyTopListerer)
   RoleManager.Instance.updateRedPoint:RemoveListener(BibleManager.Instance.rechargeRedPointListerner)
end

function BibleRechargePanel:SetData()
    self.numText.text = BibleManager.Instance.rechargeData.luck
    -- self.luckyScroll.value = BibleManager.Instance.rechargeData.luck / 100
end

function BibleRechargePanel:SetTopData()
    BaseUtils.dump(RoleManager.Instance.RoleData,"dskfjsdkjfksdj")
    self.topNumText.text = "好礼个数:" .. RoleManager.Instance.RoleData.turn
end

function BibleRechargePanel:ReloadItemSlotData()
    local t = 1
    for i,v in ipairs(DataRecharge.data_get_turn) do
        local data = DataRecharge.data_get_turn[i]
        local id = data.item_id
        local itemType = data.type
        local sex = data.sex
        local num = data.num
        local classes = data.classes
        local minLev = data.min_lev
        local maxLev = data.max_lev


        if (RoleManager.Instance.RoleData.sex == sex or sex == 2) and  (RoleManager.Instance.RoleData.classes == classes or classes == 0) then
            if RoleManager.Instance.RoleData.lev >= minLev and RoleManager.Instance.RoleData.lev <=maxLev then
                  -- print(t .. "总的数量" .. id)
                  self.itemSlotList[t]:SetSlot(id,self.extra,itemType)
                  self.itemSlotList[t]:SetData(data)
                  self.itemSlotList[t].slot:SetNum(num)

                  if itemType == 2 then
                     self.itemSlotList[t]:ShowLabel(true,"稀 有")
                     -- self.itemSlotList[t].slot:ShowEffect(true,20223)
                  elseif itemType == 3 then
                     self.itemSlotList[t]:ShowLabel(true,"珍 品")
                     -- self.itemSlotList[t].slot:ShowEffect(true,20223)
                  end
                  self.itemSlotList[t]:ShowDevelop(itemType)
                  t = t + 1
            end
        end

    end

    if self.beatifulId == nil then
      self.beatifulId = LuaTimer.Add(0,3000, function()
                self:BeautifualEffect()
      end)
    end
end

function BibleRechargePanel:OnHide()
   if self.itemSlotList ~= nil then
      for i,v in ipairs(self.itemSlotList) do
          v:Hide()
      end
   end

   if self.beatifulId ~= nil then
        LuaTimer.Delete(self.beatifulId)
        self.beatifulId = nil
   end

   if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
   end

   if self.stopDelayTimeId ~= nil then
      LuaTimer.Delete(self.stopDelayTimeId)
      self.stopDelayTimeId = nil
   end

   self:RemoveListeners()

   if self.isEnd == false then
      self.isEnd = true
      BibleManager.Instance:send9951()
   end
end

function BibleRechargePanel:ApplyAddButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
end

function BibleRechargePanel:ApplyLeftButton()
  if self.isEnd == true then
    if RoleManager.Instance.RoleData.turn == 0 then
           local confirmData = NoticeConfirmData.New()
           confirmData.type = ConfirmData.Style.Normal
           confirmData.content = TI18N("充值一定额度可获得免费次数，是否立即前往?")
           confirmData.sureSecond = -1
           confirmData.cancelSecond = -1
           confirmData.sureLabel = TI18N("立即前往")
           confirmData.cancelLabel = TI18N("取消")
           confirmData.sureCallback = function()
               -- self.initConfirm = true
               -- self.frozen:OnClick()
               WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
           end

            confirmData.cancelCallback = function()
             if self.iconEffect == nil then
                self.iconEffect = BibleRewardPanel.ShowEffect(20381,self.luckyScroll.transform, Vector3(1, 1, 1), Vector3(0,0,-1))
             end
             self.iconEffect:SetActive(true)
            end
           NoticeManager.Instance:ConfirmTips(confirmData)

          if self.iconEffect ~= nil then
              self.iconEffect:SetActive(false)
           end
    else
           BibleManager.Instance.nowNum = 1
           BibleManager.Instance:send9950()
    end
  end
end

function BibleRechargePanel:ApplyRightButton()
  if self.isEnd == true then
    if RoleManager.Instance.RoleData.turn < 5 then
           local confirmData = NoticeConfirmData.New()
           confirmData.type = ConfirmData.Style.Normal
           confirmData.content = TI18N("充值一定额度可获得免费次数，是否立即前往?")
           confirmData.sureSecond = -1
           confirmData.cancelSecond = -1
           confirmData.sureLabel = TI18N("立即前往")
           confirmData.cancelLabel = TI18N("取消")
           confirmData.sureCallback = function()
               -- self.initConfirm = true
               -- self.frozen:OnClick()
               WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
           end
           confirmData.cancelCallback = function()
              if self.iconEffect == nil then
                self.iconEffect = BibleRewardPanel.ShowEffect(20381,self.luckyScroll.transform, Vector3(1, 1, 1), Vector3(0,0,-1))
              end
              self.iconEffect:SetActive(true)
            end
           NoticeManager.Instance:ConfirmTips(confirmData)

           if self.iconEffect ~= nil then
              self.iconEffect:SetActive(false)
           end
    else
           BibleManager.Instance.nowNum = 5
           BibleManager.Instance:send9950()
    end
  end
end


function BibleRechargePanel:RotationTimer(rewardList)
    self.isEnd = false
    self.rewardLength = #self.itemSlotList
    self:SortRewardList(rewardList)
    self:ActiveItemSelect(false)
    if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
    end
    self.rotationTimeId = LuaTimer.Add(0,20, function() self:ChangeItemSelect() end)
end

function BibleRechargePanel:SortRewardList(rewardList)
      self.rewardList = {}
      -- BaseUtils.dump(rewardList,"收到的数据")

      for i,j in ipairs(self.itemSlotList) do
          for k,v in pairs(rewardList) do
              if j.id == DataRecharge.data_get_turn[v.id].item_id then
                 table.insert(self.rewardList,v)
                 self.rewardList[#self.rewardList].index = i
              end
          end
      end

      -- BaseUtils.dump(self.rewardList,"排列好的数据啊哈哈哈哈")
end


function BibleRechargePanel:ChangeItemSelect()
    if self.nowItemId > (self.rewardLength * 3) and self.hasArriveTarget == true then
        if self.hasNextRewardLength <= #self.rewardList then
            if self.nextid == self.rewardList[self.hasNextRewardLength].index then
               self.targetRewardId = self.nowItemId + self.rewardLength
            else
               self.targetRewardId = self.rewardList[self.hasNextRewardLength].index + math.floor(self.nowItemId/self.rewardLength) * self.rewardLength
            end
            self.hasArriveTarget = false
        else
            self:RotationResult()
        end
    end

     -- print(self.nowItemId .. "和" .. self.targetRewardId)
     if self.nowItemId <= (self.rewardLength * 3) or self.nowItemId < self.targetRewardId then

        self.lastid = self.nowItemId % self.rewardLength
        self.nextid = (self.nowItemId + 1) % self.rewardLength

        if self.nowItemId ~= 0 then
           if self.lastid == 0 then
              self.lastid = self.rewardLength
           end
           -- self.itemSlotList[self.lastid]:ShowSelect(false)
           self.itemSlotList[self.lastid]:ShowFlashEffect(false)
        end

        if self.nextid == 0 then
          self.nextid = self.rewardLength
        end

        -- self.itemSlotList[self.nextid]:ShowSelect(true)
        self.itemSlotList[self.nextid]:ShowFlashEffect(true)
        self.nowItemId = self.nowItemId + 1

        if self.hasArriveTarget == false then
           if self.nowItemId == self.targetRewardId then
              self.hasArriveTarget = true
              self.hasNextRewardLength = self.hasNextRewardLength + 1
              if self.rotationTimeId ~= nil then
                  LuaTimer.Delete(self.rotationTimeId)
                  self.rotationTimeId = nil
              end
              self.stopDelayTimeId = LuaTimer.Add(0,400,function() self:FlashItem() end)
           end
        end
     end
end

function BibleRechargePanel:FlashItem()
 if  self.flashNum > 0 then
     -- if self.itemSlotList[self.nextid]:IsActiveSelect() == true then
     --     self.itemSlotList[self.nextid]:ShowSelect(false)
     -- else
     --     self.itemSlotList[self.nextid]:ShowSelect(true)
     -- end
     self.itemSlotList[self.nextid]:ShowFlashEffect(false)
     self.itemSlotList[self.nextid]:ShowFlashMoreEffect(true)
     self.flashNum = self.flashNum - 1
 else
     self.itemSlotList[self.nextid]:ShowFlashMoreEffect(false)
     if self.stopDelayTimeId ~= nil then
        LuaTimer.Delete(self.stopDelayTimeId)
     end
     self.flashNum = 1
     if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
        self.rotationTimeId = nil
     end
     self.rotationTimeId = LuaTimer.Add(0,20, function() self:ChangeItemSelect() end)
 end
end

function BibleRechargePanel:RotationResult()
     if self.rotationTimeId ~= nil then
        LuaTimer.Delete(self.rotationTimeId)
     end
     BibleManager.Instance:send9951()
end


function BibleRechargePanel:ActiveItemSelect(isActive)
     for i,v in ipairs(self.itemSlotList) do
          v:ActiveSelect(isActive)
     end
end


function BibleRechargePanel:GetReward(rewardList)

     self.nowBeautifulId = 1
    if self.iconEffect ~= nil then
      self.iconEffect:SetActive(false)
    end
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end

    if self.beatifulId ~= nil then
        LuaTimer.Delete(self.beatifulId)
        self.beatifulId = nil
    end

    local callBack = function(height) self:CallBack(self.possibleReward,height) end
    local timeCallBack = function() self:SecondCallBack(self.possibleReward) end
    local deleteCallBack = function() self:DeleteCallBack() end


     self.possibleReward:Show({rewardList,5,{[5] = false},"",{0,0,200/255},{0,1000,timeCallBack},callBack,deleteCallBack})

     self.nowBeautifulId = 1
     self.falshNum = 4
     self.nowItemId = 0
     self.hasNextRewardLength = 1
     self.targetRewardId = 0
     self.hasArriveTarget = true
     self:ActiveItemSelect(true)
     self.isEnd = true
end

function BibleRechargePanel:DeleteCallBack()
    if self.getRewardEffect ~= nil then
      self.getRewardEffect:DeleteMe()
      self.getRewardEffect = nil
    end

    if self.beatifulId == nil then
      self.beatifulId = LuaTimer.Add(0,3000, function()
                self:BeautifualEffect()
      end)
    end

     if self.iconEffect ~= nil then
      self.iconEffect:SetActive(true)
    end
end

function BibleRechargePanel:CallBack(table,height)
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

function BibleRechargePanel:SecondCallBack(table)
    if table.countTime <= 0 then
       table:DeleteMe()
    else
       table.confirmText.text = "确定" .. string.format("(%ss)", tostring(table.countTime))
    end
end


function BibleRechargePanel:CheckRedPoint()
    -- if             then
    --    BibleManager.Instance.redPointDic[1][23] = true
    -- end
end



