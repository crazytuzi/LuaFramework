RebateRewardMainWindow = RebateRewardMainWindow or BaseClass(BaseWindow)


function RebateRewardMainWindow:__init(model)
    self.model = model
    self.name = "RebateRewardMainWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.dragon_boat_festival

    self.resList = {
        {file = AssetConfig.rebatereward_main_window, type = AssetType.Main},
        {file = AssetConfig.rebatereward_texture,type = AssetType.Dep},
        -- {file = AssetConfig.dragonboat_textures, type = AssetType.Dep},
        -- {file = AssetConfig.may_textures, type = AssetType.Dep},
        -- {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    self.tabList = {}
    self.panelIdList = {}
    self.lastIndex = 0

    self.redListener = function() self:CheckRedPoint() end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.setting = {
      	 -- 是否默认选中一个
	       notAutoSelect = true,
	      -- 标签是否支持重复按下监测
	      noCheckRepeat = true,
	      -- 标签等级
	      openLevel = {0, 0, 0, 0},
	      perWidth = 174,
	      perHeight = 60,
	      --是否垂直
	      isVertical = true
     }

     self.tabGroup = nil
     self.redPointList = {}
     self.imgLoaderList = {}

end

function RebateRewardMainWindow:__delete()
    self.OnHideEvent:Fire()

    if self.imgLoaderList ~= nil then
        for k,v in pairs(self.imgLoaderList) do
            v:DeleteMe()
        end
    end

    if self.tabGroup ~= nil then
    	self.tabGroup:DeleteMe()
    	self.tabGroup = nil
    end
    if self.panelIdList ~= nil then
        for _,v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelIdList = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RebateRewardMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rebatereward_main_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)

    -- t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dragonboat_textures, "i18ndragonboattitle")--"TitleI18N1")
    -- t:Find("Main/Title/Image"):GetComponent(Image):SetNativeSize()

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/MainButton").gameObject
    self.baseItem.transform:Find("Notify").gameObject:SetActive(false)
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform



    self:OnOpen()
end
function RebateRewardMainWindow:OnOpen()
    self.openRebateWin = true
    RebateRewardManager.Instance.OnUpdateRedPoint:AddListener(self.redListener)
	self:InitTabList()

    self:CheckRedPoint()
	if self.tabGroup == nil then
    	self.tabGroup = TabGroup.New(self.leftContainer,function(index) self:ChangeTab(index) end,self.setting)
    end

    self.tabGroup:ChangeTab(CampaignEumn.RebateReward.HotShopping)


end
function RebateRewardMainWindow:OnHide()
    RebateRewardManager.Instance.OnUpdateRedPoint:RemoveListener(self.redListener)
	if self.tabGroup ~= nil then
    	self.tabGroup:DeleteMe()
    	self.tabGroup = nil
    end
end


function RebateRewardMainWindow:InitTabList()
	   local temData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.RebateReward]
        local length = 0
	   for index,v in pairs(temData) do
	   	if index ~= "count" then
                length = length + 1
	   		if self.tabList[length] == nil then

	   			self.tabList[length] = {}
	   			local tab = GameObject.Instantiate(self.baseItem)
	   			self.tabList[length].name = DataCampaign.data_list[v.sub[1].id].name
	   			self.tabList[length].index = v.index
	   			self.tabList[length].tab = tab
                    self.tabList[length].icon = self.tabList[length].tab.transform:Find("Icon")
                    self.redPointList[self.tabList[length].index] = self.tabList[length].tab.transform:Find("Notify")
	   			tab.transform:Find("Select/Text"):GetComponent(Text).text = self.tabList[length].name
	   			tab.transform:Find("Normal/Text"):GetComponent(Text).text = self.tabList[length].name
	   			if index == CampaignEumn.RebateReward.HotShopping then
                         self.imgLoaderList[length] = SingleIconLoader.New(self.tabList[length].icon.gameObject)
	   		    	 self.imgLoaderList[length]:SetSprite(SingleIconType.Item,29061)
	   			elseif index == CampaignEumn.RebateReward.RebateRewarded then
	   		    	 self.imgLoaderList[length] = SingleIconLoader.New(self.tabList[length].icon.gameObject)
                         self.imgLoaderList[length]:SetSprite(SingleIconType.Item,90026)
	   		    end

	   		end
	   	end
	   end
	   self.baseItem.gameObject:SetActive(false)

        if #self.tabList > 1 then
	      table.sort(self.tabList,function(a,b)
               if a.index ~= b.index then
                    return a.index < b.index
                else
                    return false
                end
            end)
          self.openwindowid = true
        else
            if self.tabList[1].index == CampaignEumn.RebateReward.RebateRewarded then
                self.openRebateWin = true
            end
        end


        for i,v in ipairs(self.tabList) do
        	v.tab.transform:SetParent(self.leftContainer.transform)
        	v.tab.transform.localScale = Vector3.one
        	v.tab.transform.localPosition = Vector3.zero
        end

end


function RebateRewardMainWindow:ChangeTab(index)
    if self.lastIndex == index then
    	return
    end
    local panel = nil

    if self.tabList[index].index == CampaignEumn.RebateReward.RebateRewarded then
    	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_window)
    else
    	if self.tabList[index].index == CampaignEumn.RebateReward.HotShopping then
            if self.panelIdList[self.tabList[index].index] == nil then
            	DoubleElevenManager.Instance.model.bg = AssetConfig.groupbuybg
    	  	    panel = DoubleElevenGroupBuyPanel.New(DoubleElevenManager.Instance.model,self.rightContainer,self)
	      	    panel.campId = 612
	      	    self.panelIdList[self.tabList[index].index] = panel
	      	end
    	end

        if self.panelIdList[self.tabList[index].index] ~= nil then
            self.panelIdList[self.tabList[index].index]:Show()
        end
    end

    self.lastIndex = index
end


function RebateRewardMainWindow:CheckRedPoint()
        if RebateRewardManager.Instance.redPointDic ~= nil then
            for k,v in pairs(RebateRewardManager.Instance.redPointDic) do
                if v == true then
                    self.redPointList[k].gameObject:SetActive(true)
                else
                    self.redPointList[k].gameObject:SetActive(false)
                end
            end
        end
end
