--2017/10/10
--zyh
CampaignAutumnHelpWindow = CampaignAutumnHelpWindow or BaseClass(BaseWindow)

function CampaignAutumnHelpWindow:__init(model)
    self.model = model

    self.resList = {
       {file = AssetConfig.campaign_autumn_help_window,type = AssetType.Main,holdTime = 5}
      ,{file = AssetConfig.AutumnHelpBg,type = AssetType.Dep}
      ,{file = AssetConfig.campaign_autumn_texture,type = AssetType.Dep}
      ,{file = AssetConfig.RewardBg2,type = AssetType.Dep}
      ,{file = AssetConfig.big_reward,type = AssetType.Dep}
    }
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.campaign_autumn_help_window

    self.refreshData = function() self:RefreshData() end
    self.itemDataList = {}
    self.itemList = {}
    self.hasBrain = false
    self.maxDisCount = 100
    self.repeatFire = false
end

function CampaignAutumnHelpWindow:__delete()
    self:OnHide()

    if self.msg1 ~= nil then
      self.msg1:DeleteMe()
      self.msg1 = nil
    end

    if self.itemList ~= nil then
      for i,v in ipairs(self.itemList) do
          v:DeleteMe()
      end
      self.itemList = {}
    end

     if self.itemLayout ~= nil then
        self.itemLayout:DeleteMe()
     end

     if self.AutumnHelpBg ~= nil then
        self.AutumnHelpBg.sprite = nil
     end

     if self.rewardBg ~= nil then
        self.rewardBg.sprite = nil
     end

     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
     end
     self:AssetClearAll()

end

function CampaignAutumnHelpWindow:RemoveListeners()
  CampaignAutumnManager.Instance.onRefreshOtherData:RemoveListener(self.refreshData)
end

function CampaignAutumnHelpWindow:AddListeners()
  CampaignAutumnManager.Instance.onRefreshOtherData:AddListener(self.refreshData)
end

function CampaignAutumnHelpWindow:OnHide()
    self:RemoveListeners()
    self.repeatFire = false
    if self.effTimerId ~= nil then
      LuaTimer.Delete(self.effTimerId)
       self.effTimerId = nil
    end

    if self.repeatTimeId ~= nil then
      LuaTimer.Delete(self.repeatTimeId)
      self.repeatTimeId = nil
    end
    CampaignAutumnManager.Instance:Send20401(self.myOpenArgs.rid,self.myOpenArgs.platform,self.myOpenArgs.zone_id)
end

function CampaignAutumnHelpWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaign_autumn_help_window))
    self.gameObject.name = "CampaignAutumnHelpWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    local t = self.gameObject.transform

    self.transform = t
    -- t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.AutumnHelpBg = t:Find("Main/Bg"):GetComponent(Image)
    self.AutumnHelpBg.sprite = self.assetWrapper:GetSprite(AssetConfig.AutumnHelpBg,"AutumnHelpBg")
    t:Find("Main/Bg"):GetComponent(Image).type = Image.Type.Sliced

    t:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.scrollRectRtr = t:Find("Main/RectScroll"):GetComponent(RectTransform)
    self.itemContainer = t:Find("Main/RectScroll/Container")
    self.rewardBg = t:Find("Main/ReWardBg"):GetComponent(Image)
    t:Find("Main/ReWardBg").gameObject:SetActive(false)
    self.rewardBg.sprite = self.assetWrapper:GetSprite(AssetConfig.RewardBg2,"RewardBg")
    t:Find("Main/ReWardBg").gameObject:SetActive(true)
    self.rewardImg = t:Find("Main/ReWardBg/RewardButton"):GetComponent(Image)
    self.rewardDisImg = t:Find("Main/ReWardBg/DisCountImg"):GetComponent(Image)
    self.rewardDisCount = t:Find("Main/ReWardBg/DisCountImg/Text"):GetComponent(Text)



    self.noticeText = t:Find("Main/NoticeText"):GetComponent(Text)
    self.msg1 = MsgItemExt.New(self.noticeText,360,18,21)

    self.oldPriceText = t:Find("Main/PriceBg/OldPrice"):GetComponent(Text)


    self.itemLayout = LuaBoxLayout.New(self.itemContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5,border = 2})
    self.itemTemplate = t:Find("Main/RectScroll/Container/Item")
    self.itemTemplate.gameObject:SetActive(false)

    self.brainButton = t:Find("Main/BrainButton"):GetComponent(Button)
    self.brainButton.onClick:AddListener(function() self:ApplyBrainButton() end)

    self.brainImg = t:Find("Main/BrainButton"):GetComponent(Image)


    self.brainText = t:Find("Main/BrainButton/Text"):GetComponent(Text)

    self.rewardNameText =  t:Find("Main/TitleBg/RewardName"):GetComponent(Text)

    self:OnOpen()
end

function CampaignAutumnHelpWindow:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if self.openArgs ~= nil then
      self.myOpenArgs = self.openArgs
    end
    CampaignAutumnManager.Instance:Send20400(self.myOpenArgs.rid,self.myOpenArgs.platform,self.myOpenArgs.zone_id)
    self.repeatTimeId = LuaTimer.Add(3000, function() 
        if self.repeatFire == false then
            CampaignAutumnManager.Instance:Send20400(self.myOpenArgs.rid,self.myOpenArgs.platform,self.myOpenArgs.zone_id)
        end
    end)
    

    self.effTimerId = LuaTimer.Add(1000, 3000, function()
        self.brainButton.gameObject.transform.localScale = Vector3(1.1,1.1,1)
        Tween.Instance:Scale(self.brainButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    end)
    
    
end

function CampaignAutumnHelpWindow:ApplyBrainButton()
    if self.hasBrain == false then
      CampaignAutumnManager.Instance:Send20402(self.myOpenArgs.rid,self.myOpenArgs.platform,self.myOpenArgs.zone_id,self.myOpenArgs.name)
    elseif self.hasBrain == true then
      WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {self.myOpenArgs.campId})
    end
end

function CampaignAutumnHelpWindow:RefreshData()
    self.repeatFire = true  --不用重新发送
    self.itemLayout:ReSet()
    self.brainText.text = "帮TA砍价"
    self.brainImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    self.brainText.color = ColorHelper.DefaultButton3
    self.hasBrain = false

    for k,v in pairs(CampaignAutumnManager.Instance.campaignOtherData.price_info) do
        if v.type == 1 then
            -- print("aaaa"..v.item_id)
            --local id = DataItem.data_get[v.item_id].icon
            self.rewardImg.sprite = self.assetWrapper:GetSprite(AssetConfig.campaign_autumn_texture,tostring(CampCutPriceData.data_get_gift_info[v.item_id].res_id))
            self.rewardNameText.text = DataItem.data_get[v.item_id].name

            local ddesc = string.format("经过各位勇士的相助后，当前价格为<color='#b031d5'>%s</color>{assets_2, 90002}，你也来帮助Ta砍一刀吧！",v.price)
            self.msg1:SetData(ddesc)
            self.oldPriceText.text = string.format("原价:<color='248813'>%s</color>",v.old_price)
            local disCount = 0
            if v.price >= v.old_price then
              self.rewardDisImg.gameObject:SetActive(false)
            else
              disCount = math.floor((v.price/v.old_price)*10)
              self.rewardDisCount.text = disCount .. "折"
              self.rewardDisImg.gameObject:SetActive(true)
            end

        end
    end

    for i,v in ipairs(CampaignAutumnManager.Instance.campaignOtherData.log_info) do
       if self.itemList[i] == nil then
          local go = GameObject.Instantiate(self.itemTemplate.gameObject)
          self.itemList[i] = CampaignAutumnHelpItem.New(self,go,self.assetWrapper)
        end
        self.itemList[i].gameObject:SetActive(true)
        self.itemList[i]:SetData(v)
        self.itemLayout:AddCell(self.itemList[i].gameObject)
    end

    if CampaignAutumnManager.Instance.campaignOtherData.can_help == 0 then
        self.brainText.text = "我要参加"
        self.brainImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        self.brainText.color = ColorHelper.DefaultButton2
        self.hasBrain = true
    end

    if  #CampaignAutumnManager.Instance.campaignOtherData.log_info < #self.itemList then
      for i=#CampaignAutumnManager.Instance.campaignOtherData.log_info + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
      end
    end


end



