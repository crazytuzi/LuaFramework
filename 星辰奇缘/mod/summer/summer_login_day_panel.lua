--2016/7/18
--zzl
--暑期登录
SummerLoginDayPanel = SummerLoginDayPanel or BaseClass(BasePanel)

function SummerLoginDayPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.summer_day_login_panel, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function(data) self:UpdateSummerDay(data) end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.item_list = {}
end

function SummerLoginDayPanel:__delete()

    for i=1,#self.item_list do
        self.item_list[i]:Release()
    end
    self.item_list = nil

    EventMgr.Instance:RemoveListener(event_name.summer_login_update, self.updateListener)

    self.OnHideEvent:Fire()
    if self.summerLayout ~= nil then
        self.summerLayout:DeleteMe()
        self.summerLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SummerLoginDayPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_day_login_panel))
    self.gameObject.name = "SummerPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.SevenDaysPanel = self.transform:FindChild("SevenDaysPanel")
    self.ScrollCon = self.SevenDaysPanel:FindChild("ScrollCon")
    self.Container = self.ScrollCon:FindChild("Container")

    self.item_list = {}
    for i=1,20 do
        local go = self.Container:FindChild(string.format("Item%s", i)).gameObject
        local item = SummerLoginDayItem.New(go, self, i)
        table.insert(self.item_list, item)
    end

    SummerManager.Instance:request14027()

    EventMgr.Instance:AddListener(event_name.summer_login_update, self.updateListener)
end

function SummerLoginDayPanel:OnOpen()
    -- self:UpdateSummerDay()
    SummerManager.Instance:request14027()
end

function SummerLoginDayPanel:OnHide()

end

function SummerLoginDayPanel:UpdateSummerDay(data)
    self.cur_data = data
    self.buy_keys = {}
    for i=1,#data.buys do
        local b_data = data.buys[i]
        self.buy_keys[b_data.id] = b_data
    end

    local key_days = {}
    for i=1,#data.days do
        key_days[data.days[i].day] = data.days[i]
    end

    local temp_list = BaseUtils.copytab(DataCampLogin.data_base)
    local data_list = {}
    for k, v in pairs(temp_list) do
        if key_days[v.day] ~= nil then
            v.has_get = true
        else
            v.has_get = false
        end
        table.insert(data_list, v)
    end

    table.sort( data_list, function(a,b) return a.day < b.day end )




    -- self.setting_data.data_list = data_list
    -- BaseUtils.refresh_circular_list(self.setting_data)

    for i=1,#data_list do
        local item = self.item_list[i]
        local data = data_list[i]
        item:update_my_self(data, i)
    end
end



