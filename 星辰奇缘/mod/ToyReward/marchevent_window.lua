-- @author zyh
-- @date 2017年4月14日
MarchEventWindow = MarchEventWindow or BaseClass(BaseWindow)

function MarchEventWindow:__init(model)

	self.model = model
	self.mgr = MarchEventManager.Instance
	self.windowId = WindowConfig.WinID.marchevent_window
	--self.cacheMode = CacheMode.Visible

     self.resList = {
        {file = AssetConfig.marchevent_window,type = AssetType.Main, holdTime = 5}
         ,{file = AssetConfig.marchevent_texture, type = AssetType.Dep}
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

	self.currentTabIndex = 1
	self.classIndex = 1

	self.tabObjList = {}
	self.tabRedPoint = {}
	self.txtList = {}
	self.contentList = {}
  self.isInit = false
end

function MarchEventWindow:InitPanel()
   self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marchevent_window))
   self.gameObject.name = "MarchEventWindow"
   self.transform = self.gameObject.transform
   UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

   self.mainContainer = self.transform:Find("Main").gameObject

   self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
   	  self.model:CloseWindow()
   end)

   self.tabListPanel = self.transform:Find("Main/TabListPanel")
   self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
   self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
   self.tabTemplate:SetActive(false)

   for i,v in ipairs(self.model.classList) do
   	  if v~= nil then
   	  	 local obj = GameObject.Instantiate(self.tabTemplate)
   	  	 self.tabObjList[i] = obj
   	  	 obj.name = tostring(i)
   	  	 local t = obj.transform
   	  	 local content = self.model.classList[i].name
   	  	 self.tabRedPoint[i] = t:Find("RedPoint").gameObject
   	  	 local txt = t:Find("Text"):GetComponent(Text)
   	  	 txt.text = content
   	  	 obj:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(i) end)
   	  	 self.tabLayout:AddCell(obj)

   	  	 if v.icon ~= nil then
   	  	 	t:Find("Text").anchoredPosition = Vector2(-3.4,8.7200001)
   	  	 	t:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(v.package,v.icon)
   	  	 	t:Find("Icon").gameObject:SetActive(true)
          t:Find("Icon").anchoredPosition = Vector2(-2,28)
   	  	 else
   	  	    t:Find("Text").anchoredPosition = Vector2(-3.4,21)
   	  	    t:Find("Icon").gameObject:SetActive(false)
   	  	 end

   	  	 table.insert(self.txtList,txt)
   	  	 table.insert(self.contentList,content)
   	  	end
   	end

   self.OnOpenEvent:Fire()
 end

function MarchEventWindow:OnOpen()
  self.isInit = false
  self:SetTab()
  self.mgr:CheckRedPoint()
	self.mgr.onUpdateRedPoint:AddListener(self.redPointListener)
	self.mgr.onUpdateRedPoint:Fire()

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

  if self.classIndex == 4 then
        self.model:CloseWindow()
        local datalist = {}
        for i,v in pairs(ShopManager.Instance.model.datalist[2][17]) do
            table.insert(datalist, v)
        end

        if self.exchangeWin == nil then
            self.exchangeWin = MidAutumnExchangeWindow.New(self)
        end
        self.exchangeWin:Open({datalist = datalist, title = TI18N("宝物盛典"), extString = ""})
  else
	    self:SwitchTabs(index)
  end

end

function MarchEventWindow:RemoveListeners()
	self.mgr.onUpdateRedPoint:RemoveListener(self.redPointListener)
end


function MarchEventWindow:SwitchTabs(index)
	if self.currentTabIndex == index and self.isInit == true  then
		return
	end
    self.isInit = true
    self.txtList[self.currentTabIndex].text = string.format(ColorHelper.TabButton1NormalStr, self.contentList[self.currentTabIndex])
    self.txtList[index].text = string.format(ColorHelper.TabButton1SelectStr, self.contentList[index])
    self:EnableTab(self.currentTabIndex, false)
    self:EnableTab(index, true)
    self.model:SwitchTabs(index)
    self.currentTabIndex = index
end





function MarchEventWindow:__delete()
    self:RemoveListeners()
    self.model:DeletePanel()

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

function MarchEventWindow:OnHide()
    self:RemoveListeners()
    self.model:HideAllPanel()
end

function MarchEventWindow:CheckRedPoint()

	local redPointDic = MarchEventManager.Instance.redPointDic
	local bool = nil
	local openLevel = self.model:CheckTabShow()

	for k,v in pairs(redPointDic) do
		bool = false
		bool = bool or (v and openLevel[k] == true)


		self.tabRedPoint[k]:SetActive(bool)
	end

	MarchEventManager.Instance:CheckMainUIIconRedPoint()
end


function MarchEventWindow:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end


function MarchEventWindow:SetTab()

  ---------------------------这里的代码可以简化的
    local panelIdList = self.model.panelIdList
    local num = 0
    local baseTime = BaseUtils.BASE_TIME
    self.tabLayout.cellList = {}
    self.tabLayout.contentSize = 0
    local beginTime = nil
    local endTime = nil

    for i,id in ipairs(panelIdList) do
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
    -- local beginTimeData = DataCampaign.data_list[551].cli_start_time[1]
    -- local endTimeData = DataCampaign.data_list[551].cli_end_time[1]
    -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})


    -- if baseTime <= endTime then
    --    self.tabLayout:AddCell(self.tabObjList[1])
    --    self.tabObjList[1]:SetActive(true)
    -- else
    --    self.tabObjList[1]:SetActive(false)
    -- end


    -- beginTimeData = DataCampaign.data_list[585].cli_start_time[1]
    -- endTimeData = DataCampaign.data_list[585].cli_end_time[1]
    -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    -- if baseTime <= endTime then
    --    self.tabLayout:AddCell(self.tabObjList[2])
    --    self.tabObjList[2]:SetActive(true)
    -- else
    --    self.tabObjList[2]:SetActive(false)
    -- end


    -- beginTimeData = DataCampaign.data_list[552].cli_start_time[1]
    -- endTimeData = DataCampaign.data_list[552].cli_end_time[1]
    -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    -- if baseTime <= endTime then
    --    self.tabLayout:AddCell(self.tabObjList[3])
    --    self.tabObjList[3]:SetActive(true)
    -- else
    --    self.tabObjList[3]:SetActive(false)
    -- end


    -- beginTimeData = DataCampaign.data_list[557].cli_start_time[1]
    -- endTimeData = DataCampaign.data_list[557].cli_end_time[1]
    -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    -- if baseTime <= endTime then
    --    self.tabLayout:AddCell(self.tabObjList[4])
    --    self.tabObjList[4]:SetActive(true)
    -- else
    --    self.tabObjList[4]:SetActive(false)
    -- end

end

