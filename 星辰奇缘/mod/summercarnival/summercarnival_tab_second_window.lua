-- @author zyh
-- @date 2017年6月19日
SummercarnivalTabSecondWindow = SummercarnivalTabSecondWindow or BaseClass(BaseWindow)

function SummercarnivalTabSecondWindow:__init(model)

    self.model = model
    self.mgr = SummerCarnivalManager.Instance
    self.windowId = WindowConfig.WinID.summercarnival_tab_second_window
    --self.cacheMode = CacheMode.Visible

     self.resList = {
        {file = AssetConfig.campbox_tab_window,type = AssetType.Main, holdTime = 5}
         ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
         ,{file = AssetConfig.campbox_texture,type = AssetType.Dep}
    }
    local depList = {}
    for _,v in pairs(model.classListSecond) do
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

function SummercarnivalTabSecondWindow:InitPanel()
   self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campbox_tab_window))
   self.gameObject.name = "SummercarnivalTabSecondWindow"
   self.transform = self.gameObject.transform
   UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

   self.mainContainer = self.transform:Find("Main").gameObject

   self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
      self.model:CloseTabSecondWindow()
   end)

   self.tabListPanel = self.transform:Find("Main/TabListPanel")
   self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.X, spacing = 0,border = 3})
   self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
   self.tabTemplate:SetActive(false)

   self.titleText = self.transform:Find("Main/Image/Text").transform:GetComponent(Text)

   for i,v in ipairs(self.model.classListSecond) do
      if v~= nil then
         local obj = GameObject.Instantiate(self.tabTemplate)
         self.tabObjList[i] = obj
         obj.name = tostring(i)
         local t = obj.transform
         local content = self.model.classListSecond[i].name
         self.tabRedPoint[i] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         local imgicon = t:Find("Icon"):GetComponent(Image);
         txt.text = content
         obj:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(i) end)
         self.tabLayout:AddCell(obj)


         if v.icon ~= nil then
            imgicon.sprite = self.assetWrapper:GetSprite(v.package,v.icon)
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

function SummercarnivalTabSecondWindow:OnOpen()
  self:RemoveListeners()
  self.mgr.onUpdateTabSecondRedPoint:AddListener(self.redPointListener)
  self:CheckRedPoint()
  self.isInit = false
  if #self.model.classListSecond >1 then
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

function SummercarnivalTabSecondWindow:RemoveListeners()
    self.mgr.onUpdateTabSecondRedPoint:RemoveListener(self.redPointListener)
end


function SummercarnivalTabSecondWindow:SwitchTabs(index)
    if self.currentTabIndex == index and self.isInit == true  then
        return
    end
    self.isInit = true
    if #self.model.classListSecond > 1 then
      if self.txtList[self.currentTabIndex] ~= nil then
        self.txtList[self.currentTabIndex].text = string.format(ColorHelper.TabButton2NormalStr, self.contentList[self.currentTabIndex])
        self.txtList[index].text = string.format(ColorHelper.TabButton2SelectStr, self.contentList[index])
      end
    end

    self:EnableTab(self.currentTabIndex, false)
    self:EnableTab(index, true)
    self:SwitchTabss(index)
end

function SummercarnivalTabSecondWindow:SwitchTabss(index)
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
                local panel = ChildBirthHundredPanel.New(ChildBirthManager.Instance.model, self)
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
            self.titleText.text = TI18N("百花送福")
        elseif index == 2 then
            if self.panelList[index] == nil then
                local panel = CampBoxPanel.New(self.model,self)
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
            self.titleText.text = TI18N("翻翻乐")
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





function SummercarnivalTabSecondWindow:__delete()
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

function SummercarnivalTabSecondWindow:OnHide()
    self:RemoveListeners()
    self.model:HideAllPanel()
end

function SummercarnivalTabSecondWindow:CheckRedPoint()
  -- self.tabRedPoint[1]:SetActive(false)
  -- if CampBoxManager.Instance.redPointDic[CampaignEumn.CampBox.CampBox] == true then
  --   self.tabRedPoint[2]:SetActive(true)
  -- else
  --   self.tabRedPoint[2]:SetActive(false)
  -- end
end


function SummercarnivalTabSecondWindow:EnableTab(main, bool)
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


function SummercarnivalTabSecondWindow:SetTab()
    local panelIdListSecond = self.model.panelIdListSecond
    local num = 0
    local baseTime = BaseUtils.BASE_TIME
    self.tabLayout.cellList = {}
    self.tabLayout.contentSize = 0
    local beginTime = nil
    local endTime = nil

    for i,id in ipairs(panelIdListSecond) do
         local beginTimeData = DataCampaign.data_list[id].cli_start_time[1]
         local endTimeData = DataCampaign.data_list[id].cli_end_time[1]
         beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
         endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})


         if baseTime <= endTime then
            self.tabLayout:AddCell(self.tabObjList[i])
            self.tabObjList[i]:SetActive(true)
         else
            self.tabObjList[i]:SetActive(false)
         end
    end

end

