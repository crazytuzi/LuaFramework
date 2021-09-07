-- @author zyh
-- @date 2017年4月14日
MarchEventPanel = MarchEventPanel or BaseClass(BasePanel)

function MarchEventPanel:__init(model,parent)
	self.model = model
	self.parent = parent
	self.resList = {
      {file = AssetConfig.marchevent_panel, type = AssetType.Main}
      ,{file = AssetConfig.marchevent_texture, type = AssetType.Dep}
      ,{file = AssetConfig.marchevent_bg, type = AssetType.Main}
      ,{file = AssetConfig.marchevent_title, type = AssetType.Main}
      ,{file = AssetConfig.worldlevgiftitem1, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function()
    	self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
    	self:OnHide()
    end)

    self.setting = {
      column = 4
      ,cspacing = 8
      ,rspacing = 8
      ,cellSizeX = 64
      ,cellSizeY = 64
   }

   self.campaignData = nil
   self.extra = {inbag = false, nobutton = true}

   self.rotationTweenId = nil
   self.rotationAngel = 0
   -- self.timerId = nil
   self.rotationBegin = 0
   self.goldBuyNum = 0
   self.effectList = {29821,29825,29828,29844,22205,22207,22208,29928,22441}
   self.ItemList = {}

   self.goodsData = nil

end

function MarchEventPanel:__delete()
  self.OnHideEvent:Fire()

  -- if self.timerCalculateId ~= nil then
  --       LuaTimer.Delete(self.timerCalculateId)
  --       self.timerCalculateId = nil
  --   end
   -- if self.timerId ~= nil then
   --      LuaTimer.Delete(self.timerId)
   --      self.timerId = nil
   --  end
	 -- if self.rotationTweenId ~= nil then
	 -- 	Tween.Instance:Cancel(self.rotationTweenId)
	 -- 	self.rotationTweenId = nil
	 -- end

	 if self.layout ~= nil then
	 	for i,v in ipairs(self.layout) do
	 		v:DeleteMe()
	 	end
	 	self.layout = nil
	 end

	 if self.rewardSlot ~= nil then
	 	self.rewardSlot:DeleteMe()
	 end
     if self.gameObject ~= nil then
         GameObject.DestroyImmediate(self.gameObject)
         self.gameObject = nil
     end

     self:AssetClearAll()
end


function MarchEventPanel:InitPanel()
	  self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marchevent_panel))
    self.gameObject.name = "MarchEventPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.gameObject.transform.anchoredPosition = Vector2(self.gameObject.transform.anchoredPosition.x,-13)


    self.transform = self.gameObject.transform


    self.rewardItemTemplate = self.transform:Find("ItemSlot")

    self.bigBg = self.transform:Find("Bg")
    self.bigBg.anchoredPosition = Vector2(2, 10)
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.marchevent_bg))
    --local titleObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.marchevent_title))
    UIUtils.AddBigbg(self.bigBg,bigObj)

    self.bigTitle = self.transform:Find("BigTitle")
    local title = GameObject.Instantiate(self:GetPrefab(AssetConfig.marchevent_title))
    UIUtils.AddBigbg(self.bigTitle,title)
    -- UIUtils.AddBigbg(self.bigBg,titleObj)
    self.bigTitle.transform.anchoredPosition = Vector2(82, 101)

    self.scrollRect = self.transform:Find("RectScroll"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)
    self.itemContainer = self.transform:Find("RectScroll/Container")
    self.layout = LuaGridLayout.New(self.itemContainer,self.setting)

    self.previewModel = self.transform:Find("PreViewModel")

    -- self.eventTimeText = self.transform:Find("TopPanel/ActiveText"):GetComponent(Text)
    -- self.eventMessageText = self.transform:Find("MidText"):GetComponent(Text)
    self.eventCountDownText = self.transform:Find("BottomPanel/ActiveText"):GetComponent(Text)

    self.rotationBg = self.transform:Find("LeftPanel")
    --AssetConfig.worldlevgiftitem1
    self.rotationBg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.worldlevgiftitem1, "worldlevitemlight1")
    --self.rotationBg:GetComponent(Image).enabled = false

    self.payButton = self.transform:Find("BottomPanel/Button"):GetComponent(Button)
    self.payButton.onClick:AddListener(function() self:OnBuy() end)
    self.payButton.onHold:AddListener(function() self:OnNumberpad() end)
    self.payButton.onDown:AddListener(function() self:OnDown() end)
    self.payButton.onUp:AddListener(function() self:OnUp() end)

    self.numText = self.transform:Find("BottomPanel/Button/Text"):GetComponent(Text)
    self.noticeBtn = self.transform:Find("BottomPanel/Notice"):GetComponent(Button)
    self.staticText = self.transform:Find("BottomPanel/StaticeText"):GetComponent(Text)
    self.payIcon = self.transform:Find("BottomPanel/Button/ImageIcon"):GetComponent(Image)


    local noticeBtn = GameObject("Notice")
    local rect_1 = noticeBtn:AddComponent(RectTransform)
    UIUtils.AddUIChild(self.transform:Find("BottomPanel").gameObject, noticeBtn)
    local img_1 = noticeBtn:AddComponent(Image)
    img_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "InfoIconBg1")
    local btn_1 = noticeBtn:AddComponent(Button)
    btn_1.onClick:AddListener(function() TipsManager.Instance.model:ShowChance({gameObject = noticeBtn, chanceId = 211, special = true, isMutil = false}) end)
    rect_1.anchorMax = Vector2(0.5,0.5)
    rect_1.anchorMin = Vector2(0.5,0.5)
    rect_1.pivot = Vector2(0.5,0.5)
    noticeBtn.transform.sizeDelta = Vector2(30,30)
    noticeBtn.transform.anchoredPosition = Vector2(-378,-200)

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


    self.noticeBtn.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData ={
          TI18N("长按可批量购买")
          }})
    end)

     self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.payButton.gameObject,
        min_result = 1,
        max_by_asset = 50,
        max_result = 50,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) self.goldBuyNum = num  self:OnBuy()  end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }


    self:OnOpen()
    self:SetMarchEventPanel()
    self:SetItemContainer()
end

function MarchEventPanel:OnHide()
  if self.timerCalculateId ~= nil then
        LuaTimer.Delete(self.timerCalculateId)
        self.timerCalculateId = nil
    end
  -- if self.timerId ~= nil then
  --       LuaTimer.Delete(self.timerId)
  --       self.timerId = nil
  --  end
  if self.arrowEffect ~= nil then
        self.arrowEffect.gameObject:SetActive(false)
  end

	if self.rotationTweenId ~= nil then
	 	Tween.Instance:Cancel(self.rotationTweenId)
	 	self.rotationTweenId = nil
	end

  if self.team_effect ~= nil then
    self.team_effect:DeleteMe()
    self.team_effect = nil
  end
end

function MarchEventPanel:OnOpen()
   self.itemContainer.anchoredPosition = Vector2(self.itemContainer.anchoredPosition.x,0)
   self:OnRectScroll({y = 1})
   self.numText.text = DataCampaign.data_list[self.campId].camp_cond_client .. "        购买"
   self.goldBuyNum = 1
   self.rotationBegin = 0
	 self.localRotation = Vector3(0,0,0)
   self:RotationBg()
   self:ApplyTime()
  --  if self.timerId ~= nil then
  --       LuaTimer.Delete(self.timerId)
  --       self.timerId = nil
  --  end
  -- self.timerId = LuaTimer.Add(0, 1000, function() self:CalculateTime() end)
  
  local table_tmpStr = BaseUtils.match_between_symbols(DataCampaign.data_list[self.campId].cond_desc,"{","}")
  table_tmpStr = BaseUtils.split(table_tmpStr[1],",")
  self.goodsData = {tonumber(table_tmpStr[1]), tonumber(table_tmpStr[2])}
  -- BaseUtils.dump(self.goodsData)

end

function MarchEventPanel:RotationBg()
    self:ShowTurnEffect()
	-- self.rotationTweenId  = Tween.Instance:ValueChange(0,360,4, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
end

function MarchEventPanel:RotationChange(value)
   -- self.rotationBg.localRotation = Quaternion.Euler(0, 0, value)
end
function MarchEventPanel:SetMarchEventPanel()
    -- if self.imgLoader == nil then
    --   self.imgLoader = SingleIconLoader.New(self.payIcon.gameObject)
    -- end
    -- self.imgLoader:SetSprite(SingleIconType.Item,23265)


	  local data = self.goodsData
    local itemData = DataItem.data_get[data[1]]
     self.rewardSlot = ItemSlot.New(self.rewardItemTemplate.gameObject)
     self.rewardSlot:SetAll(itemData,self.extra)
     self.rewardSlot:SetNum(data[2])

     local beginTime = DataCampaign.data_list[self.campId].cli_start_time[1]
     local endTime = DataCampaign.data_list[self.campId].cli_end_time[1]
     -- self.eventTimeText.text = TI18N("活动时间：" .. beginTime[1] .. "年" .. beginTime[2] .. "月" .. beginTime[3] .. "日" .. "~" .. endTime[1] .. "年" .. endTime[2] .. "月" .. endTime[3])

     -- local message = DataCampaign.data_list[557].reward_content
     -- self.eventMessageText.text = TI18N(message)

end

function MarchEventPanel:SetItemContainer()
	local data = DataCampaign.data_list[self.campId].rewardgift
  local num = 0
  -------------------
  for i,v in ipairs(data) do
      if #v <=2 then
          num = num + 1
    	    local id = v[1]
    	    local itemData = DataItem.data_get[id]
    	    local rechargePackSlot= RechargePackItem.New()
          --时装选择礼包特殊处理
          if itemData.type == BackpackEumn.ItemType.suitselectgift then
              rechargePackSlot.slot.noTips = true
              rechargePackSlot.slot:SetSelectSelfCallback(function() TipsManager.Instance.model:OpenSelectSuitPanel({baseid = id, isshow = true, type = 1}) end)
          elseif itemData.type == BackpackEumn.ItemType.wingselectgift then
              rechargePackSlot.slot.noTips = true
              rechargePackSlot.slot:SetSelectSelfCallback(function() TipsManager.Instance.model:OpenSelectSuitPanel({baseid = id, isshow = true, type = 2}) end)
          end

    	    rechargePackSlot.slot:SetAll(itemData,self.extra)
          rechargePackSlot.slot:SetNum(v[2])
          for i,v in ipairs(self.effectList) do
             if id == v then
                rechargePackSlot:ShowEffect(true,2)
             end
          end

    	    self.layout:UpdateCellIndex(rechargePackSlot.slot.gameObject,num)
          self.ItemList[num] = rechargePackSlot
      elseif #v > 2 then
          if RoleManager.Instance.RoleData.lev < v[1] or RoleManager.Instance.RoleData.lev > v[2] then

          elseif v[3] ~= 0 and v[3] ~= RoleManager.Instance.RoleData.classes then

          elseif v[4] ~= 2 and v[4] ~= RoleManager.Instance.RoleData.sex then

          else
              num = num + 1
              local id = v[5]
              local itemData = DataItem.data_get[id]
              local rechargePackSlot= RechargePackItem.New()
              --时装选择礼包特殊处理
              if itemData.type == BackpackEumn.ItemType.suitselectgift then
                  rechargePackSlot.slot.noTips = true
                  rechargePackSlot.slot:SetSelectSelfCallback(function() TipsManager.Instance.model:OpenSelectSuitPanel({baseid = id, isshow = true, type = 1}) end)
              elseif itemData.type == BackpackEumn.ItemType.wingselectgift then
                  rechargePackSlot.slot.noTips = true
                  rechargePackSlot.slot:SetSelectSelfCallback(function() TipsManager.Instance.model:OpenSelectSuitPanel({baseid = id, isshow = true, type = 2}) end)
              end
              rechargePackSlot.slot:SetAll(itemData,self.extra)
              rechargePackSlot.slot:SetNum(v[6])
              -- for i,v in ipairs(self.effectList) do
              --    if id == v then
              --      rechargePackSlot:ShowEffect(true,2)
              --    end
              -- end

              if v[7] ~= nil then
                 if v[7] == 1 then
                      rechargePackSlot:ShowEffect(true,2)
                 end
              end

              self.layout:UpdateCellIndex(rechargePackSlot.slot.gameObject,num)
              self.ItemList[num] = rechargePackSlot
          end
       end
    end

end




function MarchEventPanel:OnNumberpad()
    local maxValue = DataItem.data_get[self.goodsData[1]].overlap
    if maxValue > 50 then
        maxValue = 50
    end
    self.numberpadSetting.max_result = maxValue
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function MarchEventPanel:OnBuy()
             local data = self.goodsData
             local name = DataItem.data_get[data[1]].name
             local confirmData = NoticeConfirmData.New()
             confirmData.type = ConfirmData.Style.Normal
             confirmData.content = string.format("是否确认消耗<color='#00ff00'>%s</color>{assets_2,90002}购买<color='#00ff00'>%s</color>个<color='#ffff00'>%s</color>?",self.goldBuyNum* DataCampaign.data_list[self.campId].camp_cond_client,self.goldBuyNum,name)
             confirmData.sureSecond = -1
             confirmData.cancelSecond = -1
             confirmData.sureLabel = TI18N("确认")
             confirmData.cancelLabel = TI18N("取消")
             confirmData.sureCallback = function()
                 -- self.initConfirm = true
                 -- self.frozen:OnClick()
              -- local baseTime = BaseUtils.BASE_TIME
              -- local timeData = DataCampaign.data_list[self.campId].cli_end_time[1]
              -- local endTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
              -- if endTime > baseTime then
              local goodsId = DataCampaign.data_list[self.campId].reward[1][1]
                ShopManager.Instance:send11303(goodsId, self.goldBuyNum)
              -- end

             end
             NoticeManager.Instance:ConfirmTips(confirmData)

end

function MarchEventPanel:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp ~= false then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.payButton.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            if not BaseUtils.is_null(self.arrowEffect.gameObject) then
                self.arrowEffect.gameObject:SetActive(false)
                self.arrowEffect.gameObject:SetActive(true)
            end
        end
    end)
end

function MarchEventPanel:OnUp()
    self.goldBuyNum = 1
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end
end


function MarchEventPanel:OnRectScroll(value)
  local Top = (value.y-1)*(self.scrollRect.content.sizeDelta.y - 135)
  local Bot = Top - 135
  -- BaseUtils.dump(self.ItemList,"大大的坏坏的数据哦")
  for i,v in ipairs(self.ItemList) do
    local ay = v.slot.transform.anchoredPosition.y
    local sy = v.slot.transform.sizeDelta.y

    if ay-sy>Top or ay < Bot then
        v.slot.gameObject:SetActive(false)
    else
        v.slot.gameObject:SetActive(true)
    end
    if v.slot.transform:Find("Effect") ~= nil then
        if ay > Top or ay-sy+2 < Bot then
            v.slot.transform:Find("Effect").gameObject:SetActive(false)
        else
            v.slot.transform:Find("Effect").gameObject:SetActive(true)
        end
    end

  end
end


function MarchEventPanel:ApplyTime()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    -- local time = DataCampaign.data_list[3].time[1]
    local time = DataCampaign.data_list[self.campId]
    beginTime = tonumber(os.time { year = DataCampaign.data_list[self.campId].cli_start_time[1][1], month = DataCampaign.data_list[self.campId].cli_start_time[1][2], day = DataCampaign.data_list[self.campId].cli_start_time[1][3], hour = DataCampaign.data_list[self.campId].cli_start_time[1][4], min = DataCampaign.data_list[self.campId].cli_start_time[1][5], sec = DataCampaign.data_list[self.campId].cli_start_time[1][6] })
    endTime = tonumber(os.time { year = DataCampaign.data_list[self.campId].cli_end_time[1][1], month = DataCampaign.data_list[self.campId].cli_end_time[1][2], day = DataCampaign.data_list[self.campId].cli_end_time[1][3], hour = DataCampaign.data_list[self.campId].cli_end_time[1][4], min = DataCampaign.data_list[self.campId].cli_end_time[1][5], sec = DataCampaign.data_list[self.campId].cli_end_time[1][6] })

    self.timestamp = 0
    if baseTime > endTime then
        -- 结束了,开始时间是第二天
        beginTime = beginTime + 24 * 60 * 60
        -- self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage1")
        self.timestamp = beginTime - baseTime
    elseif baseTime <= endTime and baseTime >= beginTime then
        -- self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage2")
        self.timestamp = endTime - baseTime
    elseif baseTime < beginTime then
        -- self.topImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures, "TextImage1")
        self.timestamp = beginTime - baseTime
    end
    self.timerCalculateId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)

end

function MarchEventPanel:TimeLoop()
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

function MarchEventPanel:EndTime()
    if self.timerCalculateId ~= nil then
        LuaTimer.Delete(self.timerCalculateId)
        self.timerCalculateId = nil
    end
end


function MarchEventPanel:ShowTurnEffect()
    if self.Turneffect == nil then
        self.Turneffect = BibleRewardPanel.ShowEffect(20138, self.rotationBg.transform, Vector3(0.95, 0.95, 1), Vector3(0, 0, -400))
    else
        self.Turneffect:SetActive(false)
        self.Turneffect:SetActive(true)
    end
end

function MarchEventPanel:UpdatePreview()
  --策划Gank两次，不要了
    -- self.teamEffect = BaseUtils.ShowEffect(30227,self.previewModel.transform,Vector3(300,300,300),Vector3(0, 0, -400))
    -- local fun = function(effectView)
    --     local effectObject = effectView.gameObject
    --     effectObject.transform:SetParent(self.previewModel.transform)
    --     effectObject.name = "Effect30227"
    --     effectObject.transform.localScale = Vector3(400,400,400)
    --     effectObject.transform.localPosition = Vector3(0, 0, -400)
    --     effectObject.transform.localRotation = Quaternion.identity

    --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")

    --     BaseUtils.TposeEffectScale(effectObject.transform)
    -- end

    -- self.team_effect = BaseEffectView.New({effectId = 30227, time = nil, callback = fun})


    -- local baseData = DataUnit.data_unit[99983]
    -- local modelData = {type = PreViewType.Npc, skinId = baseData.skin, modelId = baseData.res, animationId = baseData.animation_id, scale = 2, effects = {{effect_id = 30227}}}
    -- self:SetPreview(modelData)
end

-- function MarchEventPanel:SetPreview(modelData)
--     if modelData ~= nil then
--         local callback = function(composite) end
--         if self.previewComp == nil then
--             local setting = {
--                 name = "MarchPreview"
--                 ,layer = "UI"
--                 ,parent = self.previewModel.transform
--                 ,localRot = Quaternion.Euler(0, 0, 0)
--                 ,localPos = Vector3(0, -120, 0)
--                 ,usemask = false
--                 ,sortingOrder = 21
--                 ,nodrag = false
--             }
--             self.previewComp = PreviewmodelComposite.New(callback, setting, modelData)
--         else
--             self.previewComp:Reload(modelData, callback)
--         end
--         self.previewComp:Show()
--     end
-- end

