-- @author zyh
-- @date 2017年8月26日
CampaignSecondaryTopWindow = CampaignSecondaryTopWindow or BaseClass(BaseWindow)

function CampaignSecondaryTopWindow:__init(model)

    self.model = model
    self.windowId = WindowConfig.WinID.campaign_secondarytopwin
    --self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.campbox_tab_window,type = AssetType.Main, holdTime = 5}
         ,{file = AssetConfig.marchevent_texture, type = AssetType.Dep}
         ,{file = AssetConfig.campaign_icon,type = AssetType.Dep}
         ,{file = AssetConfig.dropicon,type = AssetType.Dep}
    }
    -- local depList = {}
    -- for _,v in pairs(model.classList) do
    --     if v.package ~= nil then
    --         depList[v.package] = true
    --     end
    -- end


    -- for k,_ in pairs(depList) do
    --     table.insert(self.resList, {file = k, type = AssetType.Dep})
    -- end
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
    self.myttt = false


    self.classList = {}
    self.panelList = {}
    self.lastIndex = 0
    self.isInit = false
    self.lastGroupIndex = 0
end

function CampaignSecondaryTopWindow:InitPanel()
   self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campbox_tab_window))
   self.gameObject.name = "CampaignSecondaryTopWindow"
   self.transform = self.gameObject.transform
   UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

   self.mainContainer = self.transform:Find("Main").gameObject

   self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
      WindowManager.Instance:CloseWindow(self)
   end)

   self.tabListPanel = self.transform:Find("Main/TabListPanel")
   self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
   self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.X, spacing = 0,border = 5})
   self.tabTemplate:SetActive(false)

   self.titlText = self.transform:Find("Main/Image/Text"):GetComponent(Text)

   self.OnOpenEvent:Fire()
 end

function CampaignSecondaryTopWindow:OnOpen()
    self.lastGroupIndex = 0
    self.tabRedPoint = {}
    self.secondaryIconType = self.openArgs[1]
    self.secondaryIconId = self.openArgs[2]
    self.openId = self.openArgs[3]
    self:InitClassList()
    self:Layout()
    self.isInit = false

    if  self.openId ~= nil then
        self:SwitchTabs(self.openId)
    else
        self:SwitchTabs(self.classList[1].id)
    end
    self:CheckRedPoint()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.camp_red_change,self.redPointListener)
end

function CampaignSecondaryTopWindow:InitClassList()
    self.classList = {}
    local classesIndex = 1
    local myIndex = DataCampaign.data_list[self.secondaryIconId].index
    if self.myttt == true then
        table.remove(CampaignManager.Instance.campaignTree[tonumber(self.secondaryIconType)][2].sub,5)
    end
    -- BaseUtils.dump(CampaignManager.Instance.campaignTree[tonumber(self.secondaryIconType)],"lalallalal")
    for key,main in pairs(CampaignManager.Instance.campaignTree[tonumber(self.secondaryIconType)]) do
        if key == myIndex then
            for k,v in pairs(main.sub) do
                if v.id ~= self.secondaryIconId then
                    self.classList[classesIndex] = {}
                    local iconid = DataCampaign.data_list[v.id].cond_type
                    if self.model.campShowSpriteFuncTab[iconid] ~= nil then
                        self.classList[classesIndex].spriteFun = self.model.campShowSpriteFuncTab[iconid]
                    else
                        self.model.campShowSpriteFuncTab[iconid] = {package = AssetConfig.dropicon,name = tostring(DataCampaign.data_list[v.id].dropicon_id)}
                        self.classList[classesIndex].spriteFun = self.model.campShowSpriteFuncTab[iconid]
                    end
                    self.classList[classesIndex].id = v.id
                    self.classList[classesIndex].index = DataCampaign.data_list[v.id].index
                    self.classList[classesIndex].group_index = DataCampaign.data_list[v.id].group_index
                    self.classList[classesIndex].name = DataCampaign.data_list[v.id].name
                    self.classList[classesIndex].cond_type = DataCampaign.data_list[v.id].cond_type
                    self.classList[classesIndex].shopId = DataCampaign.data_list[v.id].shop_id
                    classesIndex = classesIndex + 1
                end
            end
        end
    end

     table.sort(self.classList,function(a,b)
               if a.group_index ~= b.group_index then
                    return a.group_index < b.group_index
                else
                    return a.id < b.id
                end
            end)

end


function CampaignSecondaryTopWindow:Layout()

    for i,v in ipairs(self.classList) do
      if v ~= nil and self.lastGroupIndex ~= v.group_index then
         self.lastGroupIndex = v.group_index
         if self.tabObjList[i] == nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            self.tabLayout:AddCell(obj)
         end
         self.tabObjList[i].gameObject:SetActive(true)
         self.tabObjList[i].name = tostring(i)
         local t = self.tabObjList[i].transform
         local content = v.name
         self.tabRedPoint[v.id] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         txt.text = content
         self.tabObjList[i]:GetComponent(Button).onClick:RemoveAllListeners()
         self.tabObjList[i]:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(v.id) end)

         if v.spriteFun ~= nil then
            local tab = v.spriteFun
            t:Find("Text").anchoredPosition = Vector2(16,0)
            if type(v.spriteFun) == "table" then
                local sprite = self.assetWrapper:GetSprite(tab.package,tab.name)
                if sprite == nil then
                    sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon))
                end
                t:Find("Icon"):GetComponent(Image).sprite  = sprite
            end
            t:Find("Icon").gameObject:SetActive(true)
         else
            t:Find("Text").anchoredPosition = Vector2(0,0)
            t:Find("Icon").gameObject:SetActive(false)
         end
         -- if v.cond_type == 25 then
         --    local icon = t:Find("Icon").gameObject:GetComponent(RectTransform)
         --    icon.localScale = Vector3(1.2, 1.2, 1)
         --    icon.localPosition = Vector3(26, 3, 0)
         -- end

         self.txtList[i] = txt
         self.contentList[i] = content
        end
    end

    if #self.tabObjList > #self.classList then
        for i=#self.classList + 1,#self.tabObjList do
            self.tabObjList[i].gameObject:SetActive(false)
        end
    end
end

function CampaignSecondaryTopWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.camp_red_change,self.redPointListener)
end


function CampaignSecondaryTopWindow:SwitchTabs(id)

    local index = nil
    for k,v in pairs(self.classList) do
        if v.id == id then
            index = k
            break
        end
    end
    if self.currentTabIndex == index and self.isInit == true  then
        return
    end
    self.isInit = true
    self.txtList[self.currentTabIndex].text = string.format(ColorHelper.TabButton2NormalStr, self.contentList[self.currentTabIndex])
    self.txtList[index].text = string.format(ColorHelper.TabButton2SelectStr, self.contentList[index])
    self:EnableTab(self.currentTabIndex, false)
    self:EnableTab(index, true)
    self:ChangePanel(index)
    self.currentTabIndex = index
end

function CampaignSecondaryTopWindow:ChangePanel(index)

    if self.lastIndex == index then
        return
    end

    local type = self.classList[index].cond_type
    local id = self.classList[index].id
    if self.panelList[self.lastIndex] ~= nil then
        self.panelList[self.lastIndex]:Hiden()
    end
    self.lastIndex = index
    local panelId = nil
    if self.panelList[index] == nil then
        if type == CampaignEumn.ShowType.FlowerOpen then
            panelId = ChildBirthFlowerPanel.New(ChildBirthManager.Instance.model, self)
            panelId.campId = id
        elseif type == CampaignEumn.ShowType.FlowerHundred then
            panelId = ChildBirthHundredPanel.New(ChildBirthManager.Instance.model, self)
            panelId.campId = id
        elseif type == CampaignEumn.ShowType.ValentineActiveFirst then
            panelId = RechargePackPanel.New(self.model, self)
            panelId.campId = id
        elseif type == CampaignEumn.ShowType.MarchEvent then
            panelId = MarchEventPanel.New(self.model, self)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.ArborShake then
            panelId = ArborDayShakePanel.New(ArborDayShakeManager.Instance.model, self)
            panelId.campId = id
        end

        self.panelList[index] = panelId
    end

    if self.panelList[index] ~= nil then
        self.panelList[index]:Show()
    end
    self.titlText.text = DataCampaign.data_list[id].content
end


function CampaignSecondaryTopWindow:__delete()
    self:RemoveListeners()

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    for k,v in pairs(self.panelList) do
        v:DeleteMe()
    end
    self.panelList = {}

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CampaignSecondaryTopWindow:OnHide()
    self:RemoveListeners()
    self.model:HideAllPanel()
end

function CampaignSecondaryTopWindow:CheckRedPoint()

    local redPointDic = self.model.redPointList
    local bool = nil
    for k,v in pairs(self.tabRedPoint) do
        if redPointDic[k] ~= nil then
            if redPointDic[k] == true then
                self.tabRedPoint[k].gameObject:SetActive(true)
            else
                self.tabRedPoint[k].gameObject:SetActive(false)
            end
        else
            self.tabRedPoint[k].gameObject:SetActive(false)
        end
    end
end


function CampaignSecondaryTopWindow:EnableTab(main, bool)

    if bool == true then
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Select")
    else
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
        -- SingleIconManager.Instance:SetImgSprite(SingleIconType.Item,self.tabObjList[main].transform:Find("Bg").gameObject,"TabButton1Normal")
    end
end





-- function CampaignSecondaryTopWindow:SetTab()

--   ---------------------------这里的代码可以简化的
--     local panelIdList = self.model.panelIdList
--     local num = 0
--     local baseTime = BaseUtils.BASE_TIME
--     self.tabLayout.cellList = {}
--     self.tabLayout.contentSize = 0
--     local beginTime = nil
--     local endTime = nil

--     for i,id in ipairs(panelIdList) do
--          local beginTimeData = DataCampaign.data_list[id].cli_start_time[1]
--          local endTimeData = DataCampaign.data_list[id].cli_end_time[1]
--          beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
--          endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})


--          if baseTime <= endTime then
--             self.tabLayout:AddCell(self.tabObjList[i])
--             self.tabObjList[i]:SetActive(true)
--          else
--             self.tabObjList[i]:SetActive(false)
--          end
--     end
--     -- local beginTimeData = DataCampaign.data_list[551].cli_start_time[1]
--     -- local endTimeData = DataCampaign.data_list[551].cli_end_time[1]
--     -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
--     -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})


--     -- if baseTime <= endTime then
--     --    self.tabLayout:AddCell(self.tabObjList[1])
--     --    self.tabObjList[1]:SetActive(true)
--     -- else
--     --    self.tabObjList[1]:SetActive(false)
--     -- end


--     -- beginTimeData = DataCampaign.data_list[585].cli_start_time[1]
--     -- endTimeData = DataCampaign.data_list[585].cli_end_time[1]
--     -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
--     -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

--     -- if baseTime <= endTime then
--     --    self.tabLayout:AddCell(self.tabObjList[2])
--     --    self.tabObjList[2]:SetActive(true)
--     -- else
--     --    self.tabObjList[2]:SetActive(false)
--     -- end


--     -- beginTimeData = DataCampaign.data_list[552].cli_start_time[1]
--     -- endTimeData = DataCampaign.data_list[552].cli_end_time[1]
--     -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
--     -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

--     -- if baseTime <= endTime then
--     --    self.tabLayout:AddCell(self.tabObjList[3])
--     --    self.tabObjList[3]:SetActive(true)
--     -- else
--     --    self.tabObjList[3]:SetActive(false)
--     -- end


--     -- beginTimeData = DataCampaign.data_list[557].cli_start_time[1]
--     -- endTimeData = DataCampaign.data_list[557].cli_end_time[1]
--     -- beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
--     -- endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

--     -- if baseTime <= endTime then
--     --    self.tabLayout:AddCell(self.tabObjList[4])
--     --    self.tabObjList[4]:SetActive(true)
--     -- else
--     --    self.tabObjList[4]:SetActive(false)
--     -- end

-- end

