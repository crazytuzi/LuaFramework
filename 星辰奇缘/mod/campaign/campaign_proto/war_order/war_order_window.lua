-- @author hze
-- @date #2019/08/19#
-- 战令活动
WarOrderWindow = WarOrderWindow or BaseClass(BaseWindow)

function WarOrderWindow:__init(model)
    self.model = model
    self.name = "WarOrderWindow"

    self.mgr = CampaignProtoManager.Instance

    self.windowId = WindowConfig.WinID.warorderwindow

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.war_order_window, type = AssetType.Main}
        ,{file = AssetConfig.war_order_bg, type = AssetType.Main}
        ,{file = AssetConfig.warordertextures, type = AssetType.Dep}
    }

    self.curIndex = 0
    self.panelList = {}

    self.campId = nil

    self._update_top_listener =  function() self:SetTopData() end
    self._update_red_listener = function() self:SetRed() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WarOrderWindow:__delete()
    self.OnHideEvent:Fire()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
    end

    if self.panelList ~= nil then
        for _, panel in pairs(self.panelList) do
            if panel ~= nil then
                panel:DeleteMe()
            end
        end
    end

    self:AssetClearAll()
end

function WarOrderWindow:OnHide()
    self:RemoveListeners()

    self.openArgs = nil
    local panel = self.panelList[self.curIndex]
    if panel ~= nil then
        panel:Hiden()
    end

    self.model.warOrderIndex = self.curIndex
end

function WarOrderWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarOrderWindow:AddListeners()
    self.mgr.updateWarOrderEvent:AddListener(self._update_top_listener)
    self.mgr.updateWarOrderEvent:AddListener(self._update_red_listener)
    self.mgr.updateWarOrderQuestEvent:AddListener(self._update_red_listener)
end

function WarOrderWindow:RemoveListeners()
    self.mgr.updateWarOrderEvent:RemoveListener(self._update_top_listener)
    self.mgr.updateWarOrderEvent:RemoveListener(self._update_red_listener)
    self.mgr.updateWarOrderQuestEvent:RemoveListener(self._update_red_listener)
end

function WarOrderWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_window))
    self.gameObject.name = "WarOrderWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")

    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_bg)))

    self.titleTxt = main:Find("Title/Text"):GetComponent(Text)

    self.closeBtn = main:Find("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnCloseClick() end )

    self.containerTrans = main:Find("Contanier")
    -- self.containerTrans = main:Find("Container")

    self.tabGroupObj = main:Find("TabButtonGroup")

    local tabGroupSetting = {
        notAutoSelect = true,
        openLevel = {0, 30, 25, 25},
        perWidth = 62,
        perHeight = 88,
        isVertical = true,
        noCheckRepeat = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.levTxt = main:Find("Top/Lev"):GetComponent(Text)
    self.timeTxt = main:Find("Top/TimeText"):GetComponent(Text)

    self.sliderValTrans = main:Find("Top/SliderBg/SliderVal")
    self.sliderValTxt = main:Find("Top/SliderBg/ValText"):GetComponent(Text)

    self.tipsBtn = main:Find("Top/TipsBtn"):GetComponent(Button)
    self.tipsBtn.onClick:AddListener(function() self:OnTipsClick() end)
end

function WarOrderWindow:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    local index 
    if self.openArgs and next(self.openArgs) then
        index = self.openArgs.index
        self.campId = self.openArgs.campId
        if index == nil or self.campId == nil then 
            self.campId = self.openArgs[1]
            index = self.openArgs[2]
        end
    end
    self.campaignData = DataCampaign.data_list[self.campId]

    index = index or self.model.warOrderIndex

    self.tabGroup:ChangeTab(index)

    self:SetTitleTxt(self.campaignData.name)
    self:SetCampTimeTxt()


    self.mgr:Send20485()
    self.mgr:Send10261()

    -- self:SetTopData()
    -- self:SetRed()        
end


function WarOrderWindow:OnCloseClick()
    WindowManager.Instance:CloseWindow(self, false)
end

function WarOrderWindow:ChangeTab(index)
   if self.curIndex == index and self.model.warOrderIndex == nil then
        return
    end
    self.model.warOrderIndex = nil
    if self.curIndex ~= nil and self.panelList[self.curIndex] ~= nil then
        self.panelList[self.curIndex]:Hiden()
    end

    -- print("index" .. index)
    local panel = self.panelList[index]

    if panel == nil then
        if index == 1 then
            panel = WarOrderRewardPanel.New(self.model, self.containerTrans)
        elseif index == 2 then
            panel = WarOrderQuestPanel.New(self.model, self.containerTrans)
        elseif index == 3 then
            local datalist = {}
            local strList = StringHelper.Split(self.campaignData.camp_cond_client, ",")
            local exchange_first = tonumber(strList[1])
            local exchange_second = tonumber(strList[2])
            if exchange_first and exchange_second and ShopManager.Instance.model.datalist and ShopManager.Instance.model.datalist[exchange_first] and ShopManager.Instance.model.datalist[exchange_first][exchange_second] then 
                for i, v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
                    table.insert(datalist, v)
                end
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = self.campaignData.reward_title, extString = self.campaignData.content})
            end
        elseif index == 4 then
            panel = WarOrderLevPanel.New(self.model, self.containerTrans)
        else
            panel = WarOrderRewardPanel.New(self.model, self.containerTrans)
        end
        self.panelList[index] = panel
    end

    if panel ~= nil then
        self.curIndex = index
        panel:Show(self.campId)
    end
end

function WarOrderWindow:OnTipsClick()
    local campBaseData = DataCampaign.data_list[self.campId]
    TipsManager.Instance:ShowText({gameObject = self.tipsBtn.gameObject, itemData = {campBaseData.cond_desc}})
end

function WarOrderWindow:SetTitleTxt(str)
    self.titleTxt.text = str
end

function WarOrderWindow:SetCampTimeTxt(str)
    self.timeTxt.text = string.format( "<color='#62f187'>%s</color>", self.model:GetCampaignTimeStr(self.campId, 2))
end

function WarOrderWindow:SetTopData()
    local data = self.model.warOrderData
    if data == nil then 
        return 
    end
    local config = WarOrderConfigHelper.GetCamp(self.campId)
    self.levTxt.text = "Lv." .. (data.lev or 0)
    local val = (data.val or 0) % config.up_val
    self.sliderValTxt.text = string.format( "%s/%s", val, config.up_val)
    self.sliderValTrans.sizeDelta = Vector2((val / config.up_val) * 593, 19)
end

function WarOrderWindow:SetRed()
    self.tabGroup:ShowRed(1, self.model:GetWarOrderRedStatus())
    self.tabGroup:ShowRed(2, self.model:GetWarOrderQuestRedStatus())
end
