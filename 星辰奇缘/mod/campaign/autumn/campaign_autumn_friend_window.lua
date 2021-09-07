--2017/10/10
--zyh(砍价活动界面)
CampaignAutumnFriendWindow = CampaignAutumnFriendWindow or BaseClass(BaseWindow)

function CampaignAutumnFriendWindow:__init(model)
    self.model = model
    self.mgr = CampaignAutumnFriendWindow.Instance

    self.resList = {
       {file = AssetConfig.campaign_autumn_friend_window,type = AssetType.Main,holdTime = 5}
      ,{file = AssetConfig.campaign_autumn_texture,type = AssetType.Dep}
      ,{file = AssetConfig.FriendBg,type = AssetType.Dep}
    }
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.campaign_autumn_friend_window

    self.refreshData = function() self:RefreshData() end
    self.itemDataList = {}
    self.itemList = {}
end

function CampaignAutumnFriendWindow:__delete()
    self:RemoveListeners()
     if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            v:DeleteMe()
        end
        self.itemList = {}
     end

     if self.itemLayout ~= nil then
        self.itemLayout:DeleteMe()
     end

     if self.FriendBg ~= nil then
        self.FriendBg.sprite = nil
     end

     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
     end
     self:AssetClearAll()

end

function CampaignAutumnFriendWindow:RemoveListeners()
    CampaignAutumnManager.Instance.onRefreshData:RemoveListener(self.refreshData)
end

function CampaignAutumnFriendWindow:AddListeners()
    CampaignAutumnManager.Instance.onRefreshData:AddListener(self.refreshData)
end

function CampaignAutumnFriendWindow:OnHide()
    self:RemoveListeners()
    CampaignAutumnManager.Instance:Send20401(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
end

function CampaignAutumnFriendWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campaign_autumn_friend_window))
    self.gameObject.name = "CampaignAutumnFriendWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    local t = self.gameObject.transform

    self.transform = t

    -- t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    --self.rewardBg.sprite = self.assetWrapper:GetSprite(AssetConfig.RewardBg2,"RewardBg")
    self.FriendBg = t:Find("MainBg"):GetComponent(Image)
    self.FriendBg.sprite = self.assetWrapper:GetSprite(AssetConfig.FriendBg,"FriendBg3")

    self.scrollRectRtr = t:Find("Main/RectScroll"):GetComponent(RectTransform)
    self.itemContainer = t:Find("Main/RectScroll/Container")

    self.itemMsg = t:Find("Main/RectScroll/Text")
    self.itemMsg.gameObject:SetActive(false)



    self.itemLayout = LuaBoxLayout.New(self.itemContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5,border = 2})
    self.itemTemplate = t:Find("Main/RectScroll/Container/Item")
    self.itemTemplate.gameObject:SetActive(false)

    self:OnOpen()
end

function CampaignAutumnFriendWindow:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    CampaignAutumnManager.Instance:Send20400(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
end
function CampaignAutumnFriendWindow:RefreshData()
    self.itemLayout:ReSet()
    for i,v in ipairs(CampaignAutumnManager.Instance.campaignData.log_info) do
       if self.itemList[i] == nil then
          local go = GameObject.Instantiate(self.itemTemplate.gameObject)
          self.itemList[i] = CampaignAutumnFriendItem.New(self,go,self.assetWrapper)
        end
        self.itemList[i].gameObject:SetActive(true)
        self.itemList[i]:SetData(v)
        self.itemLayout:AddCell(self.itemList[i].gameObject)
    end

    if #CampaignAutumnManager.Instance.campaignData.log_info <= 0 then
      self.itemMsg.gameObject:SetActive(true)
    else
      self.itemMsg.gameObject:SetActive(false)
    end

    if  #CampaignAutumnManager.Instance.campaignData.log_info < #self.itemList then
      for i=#CampaignAutumnManager.Instance.campaignData.log_info + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
      end
    end
end



