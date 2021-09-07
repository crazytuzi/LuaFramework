RechargePackagePanel = RechargePackagePanel or BaseClass(BasePanel)

function RechargePackagePanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "RechargePackagePanel"
    self.mgr = RechargePackageManager.Instance
    self.imgLoader = {}
    self.resList = {
        {file = AssetConfig.recharge_package_panel, type = AssetType.Main}
        ,{file = AssetConfig.rechargepack_texture,type = AssetType.Dep}
        ,{file = AssetConfig.beginautum,type = AssetType.Dep}
        ,{file = AssetConfig.textures_campaign,type = AssetType.Dep}
    }
    self.dataListener1 = function () self:SetData(1) self:UpdatePreview() end
    self.dataListener2 = function () self:SetData(2) end
    self.dataListener3 = function () self:SetData(3) end
    self.previewListener = function() self:UpdatePreview() end
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RechargePackagePanel:__delete()
    self:RemoveListeners()
    self:EndTime()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.possibleReward = nil
    end

    if self.imgLoader ~= nil then
        for k,v in pairs(self.imgLoader) do
            v:DeleteMe()
        end
        self.imgLoader = {}
    end
    self:AssetClearAll()
end

function RechargePackagePanel:OnHide()
    self:RemoveListeners()
    self:EndTime()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function RechargePackagePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.recharge_package_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent,self.gameObject)
    UIUtils.AddBigbg(t:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    self.preview = t:Find("Preview").gameObject
    self.clockText = self.gameObject.transform:Find("TimeTxt").gameObject:GetComponent(Text)
    self.descText = t:Find("Desc").gameObject:GetComponent("Text")
    self.descText.text = ""
    self.preview:SetActive(false)
    self:OnOpen()
 end


function RechargePackagePanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    self:CalculateTime()

    for i=1,3 do
        self:SetData(i)
        self.mgr:Send17888(i)
    end
    if self.mgr.datalist[1] ~= nil then
        self:UpdatePreview()
    end
end

function RechargePackagePanel:SetData(index)
    local i = index
    local t = self.gameObject.transform
    local pack = t:Find("Pack"..i)
    local data = self.mgr.datalist[i]
    if data ~= nil then
        pack:Find("Text").gameObject:GetComponent(Text).text = data.gift_name
        pack:Find("OriPriceTxt/Image").gameObject:SetActive(false)
        pack:Find("OriPriceTxt/Price").gameObject:GetComponent(Text).text = string.format(TI18N("￥%s"), data.old_price/10)
        pack:Find("OriPriceTxt/Price").anchoredPosition = Vector2(50, 0)
        --pack:Find("CurPriceTxt").gameObject:GetComponent(Text).text = string.format("%s%s",TI18N("现价：￥"),data.now_price/10)

        local iconId = DataItem.data_get[data.show_item[1].item_id].icon
        if self.imgLoader[i] == nil then
            local go = pack:Find("Item/Icon").gameObject
            self.imgLoader[i] = SingleIconLoader.New(go)
        end
        self.imgLoader[i]:SetSprite(SingleIconType.Item, iconId)

        local btn = pack:Find("Item"):GetComponent(Button)
        btn.onClick:RemoveAllListeners()
        btn.onClick:AddListener(function() self:ApplyBoxBtn(i) end)

        if data.max_times - data.times > 1 then
            pack:Find("NumBg").gameObject:SetActive(true)
            pack:Find("SoldOut").gameObject:SetActive(false)
            pack:Find("NumBg/Num").gameObject:GetComponent(Text).text = data.max_times - data.times
        else
            pack:Find("NumBg").gameObject:SetActive(false)
            if data.max_times - data.times == 0 then
                pack:Find("SoldOut").gameObject:SetActive(true)
            else
                pack:Find("SoldOut").gameObject:SetActive(false)
            end
        end
        if self.mgr.curdays < i then
            pack:Find("Button").gameObject:SetActive(false)
            pack:Find("LeftDay").gameObject:SetActive(true)
            pack:Find("LeftDay").gameObject:GetComponent(Text).text = string.format(TI18N("%s日后可购买"),i-self.mgr.curdays)
        else
            pack:Find("LeftDay").gameObject:SetActive(false)
            local buyBtn = pack:Find("Button").gameObject:GetComponent(Button)
            buyBtn.gameObject:SetActive(true)
            buyBtn.onClick:RemoveAllListeners()
            if data.max_times - data.times == 0 then
                pack:Find("Button/Text").gameObject:GetComponent(Text).text = TI18N("已购买")
                buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            else
                pack:Find("Button/Text").gameObject:GetComponent(Text).text = TI18N("购买")
                 buyBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                buyBtn.onClick:AddListener(function() self:OnClickBuy(data.now_price/10) end)
            end
        end

        -- pack:Find("Item"):GetComponent(Image).enabled = false
        if index == 3 then
            self.descText.text = string.format(TI18N("购买<color='#d681f1'>%s</color>可获得"), data.gift_name)
            pack:Find("Item"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, "worldlevitemlight2")
        else
            pack:Find("Item"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, "worldlevitemlight1")
        end
    end
end


function RechargePackagePanel:AddListeners()
    EventMgr.Instance:AddListener(event_name.role_looks_change, self.previewListener)
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.previewListener)
    self.mgr.onRecharge[1]:AddListener(self.dataListener1)
    self.mgr.onRecharge[2]:AddListener(self.dataListener2)
    self.mgr.onRecharge[3]:AddListener(self.dataListener3)
    self.mgr.onChangeDay:AddListener(function (curdays) self:SetData(curdays) end)
end


function RechargePackagePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_looks_change, self.previewListener)
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.previewListener)
    self.mgr.onRecharge[1]:RemoveListener(self.dataListener1)
    self.mgr.onRecharge[2]:RemoveListener(self.dataListener2)
    self.mgr.onRecharge[3]:RemoveListener(self.dataListener3)
    self.mgr.onChangeDay:RemoveListener(function (curdays) self:SetData(curdays) end)
end

function RechargePackagePanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function RechargePackagePanel:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "BackpackRole"
        ,orthographicSize = 0.7
        ,width = 300
        ,height = 300
        ,offsetY = -0.4
    }

    local myData = SceneManager.Instance:MyData()
    local unitData = BaseUtils.copytab(myData)
    local kvLooks = {}
    local roledata = RoleManager.Instance.RoleData
    for _,v in pairs(unitData.looks) do
        kvLooks[v.looks_type] = v
    end
    --BaseUtils.dump(kvLooks,"时装")
    self.has_belt = false
    kvLooks[6] = nil
    for k,v in pairs(self.mgr.datalist[1].fashion) do
        local fashionData = DataFashion.data_base[v.partt_val]
        if fashionData ~= nil then
            if (fashionData.classes == 0 or roledata.classes == fashionData.classes) and (fashionData.sex == 2 or roledata.sex == fashionData.sex) then
                kvLooks[fashionData.type] = {looks_str = "", looks_val = fashionData.model_id, looks_mode = fashionData.texture_id, looks_type = fashionData.type}
                if fashionData.type == SceneConstData.lookstype_belt then
                    self.has_belt = true
                end
            end
        else
            local wingData = DataWing.data_base[v.partt_val]
            kvLooks[SceneConstData.looktype_wing] = {looks_str = "", looks_val = wingData.wing_id, looks_mode = 0, looks_type = SceneConstData.looktype_wing}
        end
    end
    --BaseUtils.dump(kvLooks,"外观")
    self.temp_looks = {}
    for k,v in pairs(kvLooks) do
        table.insert(self.temp_looks, v)
    end

    local roledata = RoleManager.Instance.RoleData
    local modelData = {type = PreViewType.Role, classes = roledata.classes, sex = roledata.sex, looks = self.temp_looks}
    self.modleData = modelData
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
        self.previewComp:Show()
    end
end


function RechargePackagePanel:CalculateTime()
    self:EndTime()
    local baseTime = BaseUtils.BASE_TIME
    local timeData = DataCampaign.data_list[self.campId].cli_end_time[1]
    local endTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    self.timestamp = endTime - baseTime
    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function RechargePackagePanel:TimeLoop()
    if self.timestamp > 0 then
        local h = math.modf(self.timestamp / 3600)
        local m = math.modf((self.timestamp - h * 3600) / 60)
        local s = math.modf(self.timestamp - h * 3600 - m * 60)
        self.clockText.text = string.format("%s%s%s%s%s%s",h,TI18N("时"),m,TI18N("分"),s,TI18N("秒"))
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function RechargePackagePanel:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function RechargePackagePanel:OnClickBuy(price)
    if SdkManager.Instance:RunSdk() then
        -- SdkManager.Instance:ShowChargeView(string.format("StardustRomance3K%s0", tostring(price)), price, price * 10,"5")
        SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(tonumber(price)*10), price, price * 10,"5")
    end
end

function RechargePackagePanel:ApplyBoxBtn(index)
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end
    self.possibleReward:Show({self.mgr.datalist[index].reward,3,{150,120,100,120},"购买礼包可获得以下道具"})
end
