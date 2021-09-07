-- @author hzf
-- @date 2016年7月29日,星期五

ZoneCitySetPanel = ZoneCitySetPanel or BaseClass(BasePanel)

function ZoneCitySetPanel:__init(model, parent)
    self.Mgr = ZoneManager.Instance
    self.model = model
    self.parent = parent
    self.name = "ZoneCitySetPanel"
    self.appendTab = {}

    self.resList = {
        {file = AssetConfig.cityset_panel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }
    self.LastSuccess = false
    self.lastTry = 0
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ZoneCitySetPanel:__delete()

    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ZoneCitySetPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.cityset_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.region = self.Mgr.myzoneData.region
    self.city = self.Mgr.myzoneData.city
    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.ClosePanel = self.transform:Find("Panel"):GetComponent(Button)
    self.result = self.transform:Find("Main/result"):GetComponent(Text)
    self.GetButton = self.transform:Find("Main/GetButton"):GetComponent(Button)
    self.Toggle = self.transform:Find("Main/Toggle"):GetComponent(Toggle)
    self.Toggle2 = self.transform:Find("Main/Toggle2"):GetComponent(Toggle)
    self.Toggle3 = self.transform:Find("Main/Toggle3"):GetComponent(Toggle)
    self.Toggle4 = self.transform:Find("Main/Toggle4"):GetComponent(Toggle)
    self:SetToggle(self.Mgr.myzoneData.is_shared_region)
    self:SetCity(self.Mgr.myzoneData.region, self.Mgr.myzoneData.city)
    self.GetButton.onClick:AddListener(function()
        self:OnAutoSet()
    end)
    self.CloseButton.onClick:AddListener(function()
        self:Hiden()
    end)
    self.ClosePanel.onClick:AddListener(function()
        self:Hiden()
    end)
    if self.Mgr.myzoneData.region == "" and self.Mgr.myzoneData.city == "" then
        self:OnAutoSet()
    end
end

function ZoneCitySetPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ZoneCitySetPanel:OnOpen()

end

function ZoneCitySetPanel:OnHide()
end

function ZoneCitySetPanel:OnAutoSet()
    if Time.time - self.lastTry < 3 and self.LastSuccess then
        NoticeManager.Instance:FloatTipsByString(TI18N("位置信息已经更新,请稍后再试"))
        return
    end
    self.lastTry = Time.time
    self.LastSuccess = false
    local callback = function( www, str )
        self.JsonData = NormalJson(www)
        print(self.JsonData.table.content.address)
        self.region = self.JsonData.table.content.address_detail.province
        self.city = self.JsonData.table.content.address_detail.city
        self:SetCity(self.JsonData.table.content.address_detail.province, self.JsonData.table.content.address_detail.city)
        self.Mgr:Require11874(self.region, self.city, self.Mgr.myzoneData.is_shared_region)
        self.LastSuccess = true
        self.Mgr.myzoneData.region = self.region
        self.Mgr.myzoneData.city = self.city
    end
    LuaTimer.Add(3000, function()
        if BaseUtils.isnull(self.gameObject) then
            return
        end
        if self.LastSuccess == false then
            NoticeManager.Instance:FloatTipsByString(TI18N("位置查询失败，请立即重试，或稍后再试"))
        end
    end)
    self.Mgr:GetLocation(callback)
end

function ZoneCitySetPanel:OnToggleChange(on)
    if on then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#00ff00'>已允许</color>同城玩家看到我的动态"))
        self.Mgr:Require11874(self.region, self.city, 1)
        self.Mgr.myzoneData.is_shared_region = 1
        -- if self.Mgr.myzoneData.privacy ~= 0 then
        --     self.Toggle.isOn = true
        -- end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#00ff00'>不允许</color>同城玩家看到我的动态"))
        self.Mgr:Require11874(self.region, self.city, 0)
        self.Mgr.myzoneData.is_shared_region = 0
    end
end

function ZoneCitySetPanel:OnToggle2Change(on)
    if on then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#00ff00'>已隐藏</color>我的城市信息"))
        self.Mgr:Require11835(1)
        -- if self.Mgr.myzoneData.is_shared_region == 1 then
        --     self.Toggle.isOn = false
        -- end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#00ff00'>已显示</color>我的城市信息"))
        self.Mgr:Require11835(0)
    end
end

function ZoneCitySetPanel:OnToggle3Change(on)
    if on then
        self.Mgr:Require11898(1)
    else
        self.Mgr:Require11898(0)
    end
end

function ZoneCitySetPanel:OnToggle4Change(on)
    if on then
        self.Mgr:Require11899(1)
    else
        self.Mgr:Require11899(0)
    end
end

function ZoneCitySetPanel:SetToggle(is_shared_region)
    self.Toggle.onValueChanged:RemoveAllListeners()
    self.Toggle.isOn = self.Mgr.myzoneData.is_shared_region == 1
    self.Toggle.onValueChanged:AddListener(function(on) self:OnToggleChange(on) end)
    self.Toggle2.onValueChanged:RemoveAllListeners()
    self.Toggle2.isOn = self.Mgr.myzoneData.privacy == 1
    self.Toggle2.onValueChanged:AddListener(function(on) self:OnToggle2Change(on) end)

    self.Toggle3.onValueChanged:RemoveAllListeners()
    self.Toggle3.isOn = self.Mgr.myzoneData.privacy_zone == 1
    self.Toggle3.onValueChanged:AddListener(function(on) self:OnToggle3Change(on) end)

    self.Toggle4.onValueChanged:RemoveAllListeners()
    self.Toggle4.isOn = self.Mgr.myzoneData.privacy_moments == 1
    self.Toggle4.onValueChanged:AddListener(function(on) self:OnToggle4Change(on) end)
end

function ZoneCitySetPanel:SetCity(region, city)
    if (region == "" and city == "") or region == nil then
        self.result.text = TI18N("未设置")
    else
        self.result.text = string.format("%s%s", region, city)
    end
end