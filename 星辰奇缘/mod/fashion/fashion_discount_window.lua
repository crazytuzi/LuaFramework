-- @author pwj
-- @date 2018年1月6日,星期六

FashionDiscountWindow = FashionDiscountWindow or BaseClass(BaseWindow)

function FashionDiscountWindow:__init(model)
    self.model = model
    self.name = "FashionDiscountWindow"
    self.windowId = WindowConfig.WinID.fashion_discount_window
    self.cacheMode = CacheMode.Visible
    self.resList = {
        {file = AssetConfig.fashion_discount_window, type = AssetType.Main}
        ,{file = AssetConfig.fashion_discount_title2, type = AssetType.Main}
        ,{file = AssetConfig.fashion_discount_bigbg, type = AssetType.Main}
        ,{file = AssetConfig.fashion_discount_texture, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.updateItemListener = function() self:ApplySexBtn() end

    self.fashionDiscountItemList = {}
    self.CurrSex = 0
end

function FashionDiscountWindow:__delete()
    self.OnHideEvent:Fire()

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    if self.fashionDiscountItemList ~= nil then
        for k,v in pairs(self.fashionDiscountItemList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.fashionDiscountItemList = nil
    end

    if self.bottom1 ~= nil then
        BaseUtils.ReleaseImage(self.bottom1)
    end
    if self.bottom2 ~= nil then
        BaseUtils.ReleaseImage(self.bottom2)
    end
    if self.bottom3 ~= nil then
        BaseUtils.ReleaseImage(self.bottom3)
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FashionDiscountWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_discount_window))
    self.gameObject.name = "FashionDiscountWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("MainCon/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_discount_bigbg))
    UIUtils.AddBigbg(self.transform:Find("MainCon/BigBg"), bigbg)

    local title2 = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_discount_title2))
    UIUtils.AddBigbg(self.transform:Find("MainCon/Title2"), title2)
    self.transform:Find("MainCon/Title2").anchoredPosition = Vector2(-188,159)
    
    self.bottom1 = self.transform:Find("MainCon/BottomBg1"):GetComponent(Image)
    self.bottom2 = self.transform:Find("MainCon/BottomBg2"):GetComponent(Image)
    self.bottom3 = self.transform:Find("MainCon/BottomBg3"):GetComponent(Image)

    self.bottom1.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_discount_texture, "BottomBg")
    self.bottom2.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_discount_texture, "BottomBg")
    self.bottom3.sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_discount_texture, "BottomBg")


    self.fashionScrollRect = self.transform:Find("MainCon/FashionScrollRect")
    self.fashionContainer = self.transform:Find("MainCon/FashionScrollRect/FashionContainer")
    self.fashionItem = self.transform:Find("MainCon/FashionScrollRect/FashionContainer/FashionItem")
    self.fashionItem.gameObject:SetActive(false)

    self.timeTxt = self.transform:Find("MainCon/DelayTime/timetxt"):GetComponent(Text)
    self.timeTxt.text = TI18N("折扣出售倒计时:")

    self.time = self.transform:Find("MainCon/DelayTime/time"):GetComponent(Text)

    self.GirlButton = self.transform:Find("MainCon/ToggleSex/BtnGirl")
    self.GirlButton:GetComponent(Button).onClick:AddListener(self.updateItemListener)

    self.BoyButton = self.transform:Find("MainCon/ToggleSex/BtnBoy")
    self.BoyButton:GetComponent(Button).onClick:AddListener(self.updateItemListener)

    self.BoyButton.gameObject:SetActive(false)
    self.GirlButton.gameObject:SetActive(false)

    self.tabLayout = LuaBoxLayout.New(self.fashionContainer.gameObject, {axis = BoxLayoutAxis.X,  cspacing = 58,border = 22})  --cspacing = -40,border = -120

    for i = 1,3 do 
        if self.fashionDiscountItemList[i] == nil then
           local go = GameObject.Instantiate(self.fashionItem.gameObject)
           local DiscountItem = FashionDiscountItem.New(go,self,i)
           self.fashionDiscountItemList[i] = DiscountItem
           self.tabLayout:AddCell(go)
        end    

    end

    self.RoleSex = RoleManager.Instance.RoleData.sex
    self.CurrSex = self.RoleSex

end

function FashionDiscountWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FashionDiscountWindow:OnOpen()
    self:AddListeners()

    self.campArgs = self.openArgs or self.campArgs

    self.campId = self.campArgs.campId

    self:SetSexData()
    self:SetData()

    self:calculateTime()
    
end

function FashionDiscountWindow:OnHide()
    self:RemoveListeners()
end

function FashionDiscountWindow:AddListeners()
    self:RemoveListeners()
end

function FashionDiscountWindow:RemoveListeners()
end

function FashionDiscountWindow:OnClose()   
    self.model:CloseMainWindow()
end

function FashionDiscountWindow:SetData()   
    local fashiondata = nil 
    if self.CurrSex == self.RoleSex then
        fashiondata = self.model.fashionList[1]   --（性别相同时装）
    else
        fashiondata = self.model.fashionList[2]   --（性别不同时装）
    end
    
    for i,v in ipairs (self.fashionDiscountItemList) do
         if fashiondata[i] ~= nil then
             v:SetData(fashiondata[i][1])
             v.gameObject:SetActive(true)
             v:OnOpen()
         else
            v.gameObject:SetActive(false)
         end
    end
end
function FashionDiscountWindow:calculateTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.timerId = LuaTimer.Add(0,1000,function() self:ShowDelayTime() end)
end

function FashionDiscountWindow:ShowDelayTime()
    local nowTime = BaseUtils.BASE_TIME

    local beginTimeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[self.campId].cli_end_time[1]

    local beginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    local endTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    if nowTime > beginTime and nowTime < endTime then
        local h = math.floor((endTime - nowTime) / 3600)
        local mm = math.floor(((endTime - nowTime) - (h * 3600)) / 60)
        local ss = math.floor((endTime - nowTime) - (h * 3600) - (mm * 60))
        if h >= 0 and h <= 9 then
            h = "0"..h
        end
        if mm >= 0 and mm <= 9 then
            mm = "0"..mm
        end
        if ss >= 0 and ss <= 9 then
            ss = "0"..ss
        end
        self.time.text = TI18N(h .. ":" .. mm .. ":" .. ss)
    else 
        self.time.text = TI18N("活动未开启")
    end


end

function FashionDiscountWindow:ApplyNormalStatus()
    -- for i,v in ipairs (self.fashionDiscountItemList) do
    --     if v ~= nil then
    --         v:ApplyNormal()
    --     end
    -- end
end

function FashionDiscountWindow:ApplySexBtn()
    if self.CurrSex == 0 then
        self.CurrSex = 1
    elseif self.CurrSex == 1 then
        self.CurrSex = 0
    end
    self:SetSexData()
    self:SetData()
end

function FashionDiscountWindow:SetSexData()
    if self.CurrSex == 0 then
        self.BoyButton.gameObject:SetActive(true)
        self.GirlButton.gameObject:SetActive(false)
    elseif self.CurrSex == 1 then
        self.BoyButton.gameObject:SetActive(false)
        self.GirlButton.gameObject:SetActive(true)
    end
end

