RechargePackPanel = RechargePackPanel or BaseClass(BasePanel)

function RechargePackPanel:__init(model,parent)
	self.model = model
	self.parent = parent
	self.resList = {
      {file = AssetConfig.rechargepack_panel,type = AssetType.Main}
      ,{file = AssetConfig.rechargepack_texture, type = AssetType.Dep}
      ,{file = AssetConfig.newmoon_textures, type = AssetType.Dep}
      ,{file = AssetConfig.rechargepackbigti18n, type = AssetType.Dep}
      --,{file = AssetConfig.doubleeleveni18n, type = AssetType.Main}
      --,{file = AssetConfig.deluxebagti18n, type = AssetType.Main}
      ,{file = AssetConfig.recharge_bgti18n, type = AssetType.Main}
      ,{file = AssetConfig.recharge_bgtextti18n, type = AssetType.Main}

    }

  self.ButtonTextList = {
    TI18N("任意额度")
    ,TI18N("累充128元")
    ,TI18N("累充328元")
  }

  self.OnOpenEvent:AddListener(function()
    self:OnOpen()
  end)

  self.OnHideEvent:AddListener(function()
    self:OnHide()
  end)

  self.tabList = {}
  self.rewardSlot = nil
  self.extra = {inbag = false, nobutton = true}

  self.itemSlotList = {}

  self.isGetReward = 0
  self.updateListner = function() self:ApplyButton() self:SetRedPoint() end
  self.currentselect = 1
  self.effectList = {29640,23283,20053}
end

function RechargePackPanel:__delete()
  if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
  end
  EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListner)
  if self.itemSlotList ~= nil then
    for i,v in ipairs(self.itemSlotList) do
       v:DeleteMe()
    end
    self.itemSlotList = nil
  end
  if self.topItemLayout  ~= nil then
    self.topItemLayout:DeleteMe()
  	self.topItemLayout  = nil
  end

  if self.tabLayout ~=  nil then
    self.tabLayout:DeleteMe()
    self.tabLayout = nil
  end

   if self.getRewardEffect ~= nil then
      self.getRewardEffect:DeleteMe()
  end

  if self.gameObject ~= nil then
      GameObject.DestroyImmediate(self.gameObject)
      self.gameObject = nil
  end
  self.getRewardEffect = nil
  self:AssetClearAll()
end


function RechargePackPanel:InitPanel()
	  self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rechargepack_panel))
    self.gameObject.name = "RechargePackPanel"
    UIUtils.AddUIChild(self.parent.mainContainer.gameObject,self.gameObject)

    self.transform = self.gameObject.transform


    self.bigBg = self.transform:Find("Bg/BackGroundBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.recharge_bgti18n))
    UIUtils.AddBigbg(self.bigBg,bigObj)
    self.bigBg.anchoredPosition = Vector2(5, 0)

    self.bigText = self.transform:Find("Bg/BigTI18N")
    local bigTextObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.recharge_bgtextti18n))
    UIUtils.AddBigbg(self.bigText, bigTextObj)
    self.bigText.anchoredPosition = Vector2(-90, 162)

    self.bigText2 = self.transform:Find("Bg/BigTI18N2"):GetComponent(Image)
    self.bigText2.sprite = self.assetWrapper:GetSprite(AssetConfig.rechargepackbigti18n,"RechargePackBigTi18n2")
    self.bigText2.gameObject:SetActive(false)


    self.tabContainer = self.transform:Find("Bg/TabContainer")
    self.tabContainer.anchoredPosition = Vector2(-62, 33)
    self.tabLayout = LuaBoxLayout.New(self.tabContainer.gameObject,{axis = BoxLayoutAxis.x, spacing = 5, border = 10})

    self.tabTemplateTr = self.transform:Find("Bg/TabTemplate")
    self.tabTemplateTr.gameObject:SetActive(false)

    for i=1,3 do
      if self.tabList[i] == nil then
        local obj = GameObject.Instantiate(self.tabTemplateTr.gameObject)
        self.tabLayout:AddCell(obj)
        self.tabList[i] = obj
        self.tabList[i].transform:Find("TopText"):GetComponent(Text).text = self.ButtonTextList[i]
        self.tabList[i].transform:GetComponent(Button).onClick:AddListener(function()  self:ChangeTab(i) end)
      end
    end

    self.scrollRect = self.transform:Find("Bg/RectScroll"):GetComponent(ScrollRect)
    self.scrollRect.transform.anchoredPosition = Vector2(-97, -36)
    self.scrollRect.transform.sizeDelta = Vector2(441, 84)
    self.scrollRect.onValueChanged:AddListener(function()
        self:OnRectScroll()
    end)


    self.topItemContainer = self.transform:Find("Bg/RectScroll/Container")
    self.topItemLayout = LuaBoxLayout.New(self.topItemContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = 10,border = 7})


    self.countDownText = self.transform:Find("Bg/ButtonPanel/ActiveText"):GetComponent(Text)


    self.activeButton = self.transform:Find("Bg/ActiveButton"):GetComponent(Button)
    self.getRewardEffect = BibleRewardPanel.ShowEffect(20053,self.activeButton.transform,Vector3(2.3, 0.8, 1),Vector3(-70, -19, -400))

    self.activeButton.gameObject:SetActive(false)
    self.activeButton.onClick:AddListener(function() self:ApplyPayButton() end)

    self.hasButton = self.transform:Find("Bg/HasButton"):GetComponent(Button)
    self.hasButton.gameObject:SetActive(false)

    self:OnOpen()
end

function RechargePackPanel:OnHide()
   EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListner)
   if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
  end
end

function RechargePackPanel:OnOpen()
  self:SetRedPoint()
  self:OnRectScroll()
  self.currentselect = 1
  self:ChangeTab(self:PriorityPanel())

  if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
  end
  self.timerId = LuaTimer.Add(0, 1000, function() self:CalculateTime() end)
  EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListner)

end

function RechargePackPanel:RotationBg()
	self.rotationTweenId  = Tween.Instance:ValueChange(0,360,2, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
end

function RechargePackPanel:RotationChange(value)
   self.localRotation = Vector3(0,0,value)
end

function RechargePackPanel:SetItemContainer(index)
	local rewardData = CampaignManager.ItemFilter(DataCampaign.data_list[self.campId+index-1].rewardgift)

  --local rewardData = DataCampaign.data_list[self.campId].rewardgift
  -- local data = rewardData[index]
  local data = rewardData
  local count = 0
  for i,v in ipairs(data) do
      local id = v[1]
      local itemData = DataItem.data_get[id]
      if self.itemSlotList[i] == nil then
        self.itemSlotList[i] = RechargePackItem.New()
        self.topItemLayout:AddCell(self.itemSlotList[i].slot.gameObject)
      end
      --时装选择礼包特殊处理
      if itemData.type == BackpackEumn.ItemType.suitselectgift then
          self.itemSlotList[i].slot.noTips = true
          self.itemSlotList[i].slot:SetSelectSelfCallback(function() TipsManager.Instance.model:OpenSelectSuitPanel({baseid = id, isshow = true}) end)
      end
      self.itemSlotList[i].slot:SetAll(itemData,self.extra)
      self.itemSlotList[i].slot:SetNum(v[2])
      if v[3] == 1 then
          self.itemSlotList[i]:ShowEffect(true,1)
      end
      count = count + 1
  end

  for i,v in pairs (self.itemSlotList) do
    if i > count then
      v.slot.gameObject:SetActive(false)
    else
      v.slot.gameObject:SetActive(true)
    end
  end
  self:ApplyButton()
end


function RechargePackPanel:CalculateTime()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    local beginTimeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[self.campId].cli_end_time[1]
    beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    if beginTime < baseTime  and baseTime < endTime then
       local h = math.floor((endTime - baseTime) / 3600)
       local mm = math.floor(((endTime - baseTime) - (h * 3600)) / 60 )
       local ss = math.floor((endTime - baseTime) - (h * 3600) - (mm * 60))
       self.countDownText.text = TI18N(h .. "时" .. mm .. "分" .. ss .. "秒")
    else
       self.countDownText.text = TI18N("活动未开启")
    end
end

function RechargePackPanel:ApplyPayButton()
  local content = DataCampaign.data_list[self.campId + self.currentselect - 1].content
  if self.isGetReward == 0 then
    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("活动期间%s即可领取哦{face_1,3}"),self.ButtonTextList[self.currentselect]))
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
  elseif self.isGetReward == 1 then
    CampaignManager.Instance:Send14001(DataCampaign.data_list[self.campId + self.currentselect - 1].id)
  end
end


function RechargePackPanel:ApplyButton()
   local data = CampaignManager.Instance.campaignTab[self.campId + self.currentselect - 1]


   if data ~= nil then
      self.isGetReward = data.status
      if self.isGetReward == 0 then
        self.activeButton.gameObject:SetActive(true)
        self.hasButton.gameObject:SetActive(false)
        self.getRewardEffect:SetActive(false)
      elseif self.isGetReward == 1 then
        self.activeButton.gameObject:SetActive(true)
        self.hasButton.gameObject:SetActive(false)
        self.getRewardEffect:SetActive(true)
      elseif self.isGetReward == 2 then
        self.activeButton.gameObject:SetActive(false)
        self.hasButton.gameObject:SetActive(true)
        self.getRewardEffect:SetActive(false)
       end
    else
       self.activeButton.gameObject:SetActive(true)
        self.hasButton.gameObject:SetActive(false)
        self.getRewardEffect:SetActive(false)
    end

end


function RechargePackPanel:ChangeTab(index)
    -- if self.nowTabIndex == num and t == false then
    --     return
    -- end
    local stateList = {false, false, false}
    stateList[index] = true

    if self.tabList[index] ~= nil then
      for k,v in pairs (self.tabList) do
        v.transform:Find("Tab").gameObject:SetActive(not stateList[k])
        v.transform:Find("TabSelect").gameObject:SetActive(stateList[k])
      end
    end

    -- if self.textBgList[myIndex] == nil then
    --     local bigObj = GameObject.Instantiate(self:GetPrefab(string.format(TI18N("prefabs/ui/bigatlas/rechargetexti18n%d.unity3d"),myIndex)))
    --     UIUtils.AddBigbg(self.textBigBg,bigObj)
    --     self.textBgList[myIndex] = bigObj
    -- end
    -- self.textBgList[myIndex].gameObject:SetActive(true)

    -- self:RefreshItem()
    -- self:RefreshData()
    self.currentselect = index
    self:SetItemContainer(index)

end


function RechargePackPanel:SetRedPoint()
  if self.tabList == nil then return  end
  for i=1,3 do
    local data = CampaignManager.Instance.campaignTab[self.campId + i - 1]
    if data ~= nil then
      self.tabList[i].transform:Find("RedPoint").gameObject:SetActive(data.status == 1)
    end
  end
end


function RechargePackPanel:PriorityPanel()
  local panelIndex = 1

  if self.tabList == nil then return 1 end
  for i=1,3 do
    local data = CampaignManager.Instance.campaignTab[self.campId + i - 1]
    if data ~= nil then
        if data.status == 1 or data.status == 0 then
           panelIndex = i
           break
        end
    end
  end

  return panelIndex
end



function RechargePackPanel:OnRectScroll(value)
  local container = self.scrollRect.content

  local left = -container.anchoredPosition.x
  local right = left + self.scrollRect.transform.sizeDelta.x

  for k,v in pairs(self.itemSlotList) do
    local ax = v.slot.transform.anchoredPosition.x
    local sx = v.slot.transform.sizeDelta.x
    local state = nil
    if ax < left or ax + sx > right then
        state = false
    else
      state = true
    end

    if v.slot.transform:FindChild("Effect") ~= nil then
        v.slot.transform:FindChild("Effect").gameObject:SetActive(state)
    end
  end
end
