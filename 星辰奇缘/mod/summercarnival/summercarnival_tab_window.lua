-- @author zyh
-- @date 2017年6月19日
SummercarnivalTabWindow = SummercarnivalTabWindow or BaseClass(BaseWindow)

function SummercarnivalTabWindow:__init(model)

    self.model = model
    self.mgr = SummerCarnivalManager.Instance
    self.windowId = WindowConfig.WinID.summercarnival_tab_window
    --self.cacheMode = CacheMode.Visible

     self.resList = {
        {file = AssetConfig.campbox_tab_window,type = AssetType.Main, holdTime = 5}
         ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
         ,{file = AssetConfig.campbox_texture,type = AssetType.Dep}
    }
    local depList = {}
    for _,v in pairs(model.classList) do
        if v.package ~= nil then
            depList[v.package] = true
        end
    end


    for k,_ in pairs(depList) do
        table.insert(self.resList, {file = k, type = AssetType.Dep})
    end
  self.redPointListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
      self:OnHide()
    end)

    self.currentTabIndex = 0
    self.classIndex = 1

    self.tabObjList = {}
    self.tabRedPoint = {}
    self.txtList = {}
    self.contentList = {}
   self.isInit = false
   self.panelList = {}
   self.lastPanel = nil
end

function SummercarnivalTabWindow:InitPanel()
   self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campbox_tab_window))
   self.gameObject.name = "SummercarnivalTabWindow"
   self.transform = self.gameObject.transform
   UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

   self.mainContainer = self.transform:Find("Main").gameObject

   self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
      self.model:CloseTabWindow()
   end)

   self.tabListPanel = self.transform:Find("Main/TabListPanel")
   self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.X, spacing = 0,border = 3})
   self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
   self.tabTemplate:SetActive(false)

   self.titleText = self.transform:Find("Main/Image/Text").transform:GetComponent(Text)

   for i,v in ipairs(self.model.classList) do
      if v~= nil then
         local obj = GameObject.Instantiate(self.tabTemplate)
         self.tabObjList[i] = obj
         obj.name = tostring(i)
         local t = obj.transform
         local content = self.model.classList[i].name
         self.tabRedPoint[i] = t:Find("RedPoint").gameObject
         self.tabRedPoint[i]:SetActive(false)
         local txt = t:Find("Text"):GetComponent(Text)
         local imgicon = t:Find("Icon"):GetComponent(Image);
         txt.text = content
         obj:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(i) end)
         self.tabLayout:AddCell(obj)


         if v.icon ~= nil then
            if self.model.mainWin ~= nil then
              imgicon.sprite = self.model.mainWin.assetWrapper:GetSprite(v.package,v.icon)
            else
              if self.assetWrapper == nil then
                self.assetWrapper = AssetBatchWrapper.New()
                self.assetWrapper:LoadAssetBundle(v.package)
              else
                imgicon.sprite = self.assetWrapper:GetSprite(v.package,v.icon)
              end
            end
            imgicon.gameObject:SetActive(true)
         else
            imgicon.gameObject:SetActive(false)
         end

         table.insert(self.txtList,txt)
         table.insert(self.contentList,content)
        end
    end

   self.OnOpenEvent:Fire()
 end

function SummercarnivalTabWindow:OnOpen()
  self:RemoveListeners()
  self.mgr.onUpdateTabRedPoint:AddListener(self.redPointListener)
  self:CheckRedPoint()
  self.isInit = false
  if #self.model.classList >1 then
    self:SetTab()
  end


    local index = nil
    if self.openArgs ~= nil then
        index = self.openArgs[1]
        if self.tabObjList[index].activeSelf ~= true then
               for i,v in ipairs(self.tabObjList) do
                  if v.activeSelf == true then
                     self.classIndex = i
                      break
                   end
                end
             index = self.classIndex
        end
    else
        for i,v in ipairs(self.tabObjList) do
          if v.activeSelf == true then
            self.classIndex = i
            break
          end
        end
        index = self.classIndex
    end

  -- if self.classIndex == 4 then
  --       self.model:CloseWindow()
  --       local datalist = {}
  --       for i,v in pairs(ShopManager.Instance.model.datalist[2][17]) do
  --           table.insert(datalist, v)
  --       end

  --       if self.exchangeWin == nil then
  --           self.exchangeWin = MidAutumnExchangeWindow.New(self)
  --       end
  --       self.exchangeWin:Open({datalist = datalist, title = TI18N("宝物盛典"), extString = ""})
  -- else
  --       self:SwitchTabs(index)
  -- end
    self:SwitchTabs(index)

end

function SummercarnivalTabWindow:RemoveListeners()
    self.mgr.onUpdateTabRedPoint:RemoveListener(self.redPointListener)
end


function SummercarnivalTabWindow:SwitchTabs(index)
    if self.currentTabIndex == index and self.isInit == true  then
        return
    end
    self.isInit = true
    if #self.model.classList > 1 then
      if self.txtList[self.currentTabIndex] ~= nil then
        self.txtList[self.currentTabIndex].text = string.format(ColorHelper.TabButton2NormalStr, self.contentList[self.currentTabIndex])
      end
      self.txtList[index].text = string.format(ColorHelper.TabButton2SelectStr, self.contentList[index])
    end
    self:EnableTab(self.currentTabIndex, false)
    self:EnableTab(index, true)
    self:SwitchTabss(index)
end

function SummercarnivalTabWindow:SwitchTabss(index)
    if self.currentTabIndex == index then
      return
    end

    if self.panelList[self.currentTabIndex] ~= nil then
        self.panelList[self.currentTabIndex]:Hiden()
    end
    if index ~= 4 then
        self.currentTabIndex = index
        if index ==1 then
          if self.panelList[index] == nil then
                local panel = ChildBirthFlowerPanel.New(ChildBirthManager.Instance.model, self)
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
            self.titleText.text = TI18N("七彩沙冰")
        elseif index == 2 then
             if self.panelList[index] == nil then
                local panel = ChildBirthHundredPanel.New(ChildBirthManager.Instance.model, self)
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
            self.titleText.text = TI18N("冰动星辰")
        end
    else
        if index == 4 then
            local datalist = { }
            for i, v in pairs(ShopManager.Instance.model.datalist[2][17]) do
                table.insert(datalist, v)
            end

            if self.exchangeWin == nil then
                self.exchangeWin = MidAutumnExchangeWindow.New(self)
            end
            self.exchangeWin:Open( { datalist = datalist, title = TI18N("宝物盛典"), extString = "" })
        end
    end
end





function SummercarnivalTabWindow:__delete()
    self:RemoveListeners()

    if self.panelList ~= nil then
        for i, v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = { }
    end

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function SummercarnivalTabWindow:OnHide()
    self:RemoveListeners()
    self.model:HideAllPanel()
end

function SummercarnivalTabWindow:CheckRedPoint()
  self.tabRedPoint[1]:SetActive(false)
  self.tabRedPoint[2]:SetActive(false)

  -- local baseTime = BaseUtils.BASE_TIME
  -- local campDataBeginTime = DataCampaign.data_list[706].cli_start_time[1]
  -- local campDataEndTime = DataCampaign.data_list[706].cli_end_time[1]
  -- local beginTime = tonumber(os.time{year = campDataBeginTime[1], month = campDataBeginTime[2], day = campDataBeginTime[3], hour = campDataBeginTime[4], min = campDataBeginTime[5], sec = campDataBeginTime[6]})
  -- local endTime = tonumber(os.time{year = campDataEndTime[1], month = campDataEndTime[2], day = campDataEndTime[3], hour = campDataEndTime[4], min = campDataEndTime[5], sec = campDataEndTime[6]})

  if self.mgr.redPointDic[CampaignEumn.SummerCarnival.Festival]  == true and cli_start_time then
     self.campaignData_cli = DataCampaign.data_list[CampaignEumn.SummerCarnival.Flowers]
      if self.campaignData_cli ~= nil then
         self.exchangeBaseId = self.campaignData_cli.loss_items[1][1]
          if self.exchangeBaseId ~= nil then
              if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 0 then
                self.tabRedPoint[2]:SetActive(true)
              end
          end
      end

      self.perNum = 9
      local count = count or (ChildBirthManager.Instance.model.flowerData or {}).count or 0
      if count >= 7 * self.perNum then
          self.tabRedPoint[1]:SetActive(true)
      else
          self.tabRedPoint[1]:SetActive(false)
      end
  end


end


function SummercarnivalTabWindow:EnableTab(main, bool)
    if self.tabObjList[main] ~= nil then
      if bool == true then
          self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
          -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
      else
          self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
          -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
      end
    end
end


function SummercarnivalTabWindow:SetTab()
    -- local panelIdList = self.model.panelIdList
    -- local num = 0
    -- local baseTime = BaseUtils.BASE_TIME
    -- self.tabLayout.cellList = {}
    -- self.tabLayout.contentSize = 0
    -- local beginTime = nil
    -- local endTime = nil

    -- for i,id in ipairs(panelIdList) do
    --      local beginTimeData = DataCampaign.data_list[id].cli_start_time[1]
    --      local endTimeData = DataCampaign.data_list[id].cli_end_time[1]
    --      beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    --      endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})


    --      if baseTime <= endTime then
    --         self.tabLayout:AddCell(self.tabObjList[i])
    --         self.tabObjList[i]:SetActive(true)
    --      else
    --         self.tabObjList[i]:SetActive(false)
    --      end
    -- end

end

