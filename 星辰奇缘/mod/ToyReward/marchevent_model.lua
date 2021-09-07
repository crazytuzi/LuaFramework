MarchEventModel = MarchEventModel or BaseClass(BaseModel)


function MarchEventModel:__init()
    self.marchWin = nil
    self.openArgs = args
    self.panelList = { }

    -- self.marchEventList = {
    -- [1] = {key = 1, name = TI18N("三月活动"),icon = nil,index = 1},
    -- [2] = {key = 2, name = TI18N("扭蛋抽奖"),icon = nil,index = 2},
    -- [3] = {key = 3, name = TI18N("积分商店"),icon = nil,index = 3},
    -- [4] = {key = 4, name = TI18N("充值礼包"),icon = nil,index = 4},
    --   }


    self.classList = {
        [1] = { name = TI18N("祝福"), icon = "Tab3", package = AssetConfig.marchevent_texture },
        [2] = { name = TI18N("香囊"), icon = "Bag", package = AssetConfig.campaign_icon },
        [3] = { name = TI18N("扭蛋"), icon = "Cake", package = AssetConfig.campaign_icon },
        [4] = { name = TI18N("兑换"), icon = "Bean", package = AssetConfig.campaign_icon },
        [5] = { name = TI18N("扭蛋"), icon = "Icon4", package = AssetConfig.marchevent_texture }
    }

    self.panelIdList =
    {
        [1] = 742,
        [2] = 740,
        [3] = 741,
        [4] = 743,
        [5] = 552
    }
    self.openList = { }
    for i, v in ipairs(self.classList) do
        self.openList[i] = true
    end
end



function MarchEventModel:OpenWindow(args)
    self.openArgs = args
    BaseUtils.dump(args, "MarchEventModel")
    if self.openArgs ~= nil and self.openArgs[1] == 3 then
        if not self:CheckDollsRandom() then
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
            return
        end
    end

    if self.marchWin == nil then
        self.marchWin = MarchEventWindow.New(self)
    end
    self.marchWin:Open(args)
end

function MarchEventModel:CloseWindow()
    WindowManager.Instance:CloseWindow(self.marchWin)
end


function MarchEventModel:CheckTabShow()
    self.openList =
    {
        [1] = self:IsShowMarchEvent(),
        [2] = ValentineManager.Instance:CheckDollsRandom()
    }
    for i = 1, #self.classList do
        if self.openList[i] == nil then
            self.openList[i] = true
        end
    end


    return self.openList
end

function MarchEventModel:IsShowMarchEvent()
    -- local baseTime = BaseUtils.BASE_TIME
    --    local beginTimeData = DataCampaign.data_list[557].cli_start_time[1]
    --    local endTimeData = DataCampaign.data_list[557].cli_end_time[1]
    --    beginTime = tonumber(os.time{year = beginTimeData[1], beginTimeData[2], beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    --    endTime = tonumber(os.time{year = endTimeData[1], endTimeData[2], endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    --    if baseTime > beginTime and baseTime <endTime then
    --         return true
    --    else
    --    	 return false
    --    end
    return true
end


function MarchEventModel:IsShowToyReward()
    -- local baseTime = BaseUtils.BASE_TIME
    --    local beginTimeData = DataCampaign.data_list[551].cli_start_time[1]
    --    local endTimeData = DataCampaign.data_list[551].cli_end_time[1]
    --    beginTime = tonumber(os.time{year = beginTimeData[1], beginTimeData[2], beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    --    endTime = tonumber(os.time{year = endTimeData[1], endTimeData[2], endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    --    if baseTime > beginTime and baseTime <endTime then
    --         return true
    --    else
    --    	 return false
    --    end
    return true
end

function MarchEventModel:AddUIChild(parentObj, childObj)
    local trans = childObj.transform
    trans:SetParent(parentObj.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    trans.localRotation = Quaternion.identity

    local rect = childObj:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    rect.localScale = Vector3.one
    rect.localPosition = Vector3.zero
    rect.anchoredPosition = Vector2.zero
    -- rect.sizeDelta = Vector2(ctx.ScreenWidth, ctx.ScreenHeight)
    childObj:SetActive(true)
end

function MarchEventModel:HideAllPanel()
    if self.panelList ~= nil then
        for k, v in pairs(self.panelList) do
            if v ~= nil then
                v:Hiden()
            end
        end
    end
end

function MarchEventModel:SwitchTabs(index)
    print(index .. "索引")
    if index ~= 4 then
        self:HideAllPanel()
        self.currentTabIndex = index
        if index == 1 then
            if self.panelList[index] == nil then
                local panel = RechargePackPanel.New(self, self.marchWin)
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
        elseif index == 3 then
            if self.panelList[index] == nil then
                local panel = ToyRewardPanel.New(self,self.marchWin)
                panel.campId = self.panelIdList[index]
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
        elseif index == 2 then
            if self.panelList[index] == nil then
                local panel = MarchEventPanel.New(self, self.marchWin)
                self.panelList[index] = panel
            end
            self.panelList[index]:Show()
        end
    else
        if index == 4 then
            local datalist = { }
            for i, v in pairs(ShopManager.Instance.model.datalist[2][22]) do
                table.insert(datalist, v)
            end

            if self.exchangeWin == nil then
                self.exchangeWin = MidAutumnExchangeWindow.New(self)
            end
            self.exchangeWin:Open( { datalist = datalist, title = TI18N("七夕兑换"), extString = "" })
        end
    end

end

function MarchEventModel:__delete()
    if self.marchWin ~= nil then
        self.marchWin:DeleteMe()
    end
end

function MarchEventModel:DeletePanel()
    if self.panelList ~= nil then
        for i, v in pairs(self.panelList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.panelList = { }
    end
end

function MarchEventModel:CheckDollsRandom()
    local isOpen = false
    local valentDatat = CampaignManager.Instance.campaignTree[CampaignEumn.Type.QiXi]
    if valentDatat == nil then
        return false
    end
    for i,item in pairs(valentDatat) do
        if i ~= "count" then
            for i2,item2 in pairs(item.sub) do
                if item2.id == 741 then
                    isOpen = true
                     break
                end
            end
        end
    end
    return isOpen
end

