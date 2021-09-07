--作者:hzf
--03/17/2017 11:07:28
--功能:公会拍卖主界面

GuildAuctionWindow = GuildAuctionWindow or BaseClass(BaseWindow)
function GuildAuctionWindow:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.guildauctionwindow, type = AssetType.Main},
        {file = AssetConfig.guildauctiontexture, type = AssetType.Dep},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
	}
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
    self.assetListener = function()
        self:OnAssetsUpdate()
    end
    self.updateListener = function()
        self:ReloadList()
    end
    self.oneupdateListener = function(data)
        self:UpdateSingleItem(data)
    end
    self.TypeListData = {0, 147, 148, 149, 150}
    self.TypeNameData = {TI18N("所有部位"), TI18N("指环"), TI18N("面具"), TI18N("斗篷"), TI18N("纹章")}
    self.setBtn = {}
    self.typeBtn = {}
    self.hasInit = false

end

function GuildAuctionWindow:__delete()
    self:RemoveListeners()
    if self.item_list ~= nil then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    self:AssetClearAll()
end

function GuildAuctionWindow:OnHide()
end

function GuildAuctionWindow:OnOpen()
    GuildAuctionManager.Instance:send19701()
end

function GuildAuctionWindow:AddListeners()
    GuildAuctionManager.Instance.OnGoodsUpdate:Add(self.updateListener)
    GuildAuctionManager.Instance.OnOldGoodsUpdate:Add(self.updateListener)
    GuildAuctionManager.Instance.OnOneGoodsUpdate:Add(self.oneupdateListener)
end

function GuildAuctionWindow:RemoveListeners()
    GuildAuctionManager.Instance.OnGoodsUpdate:Remove(self.updateListener)
    GuildAuctionManager.Instance.OnOldGoodsUpdate:Remove(self.updateListener)
    GuildAuctionManager.Instance.OnOneGoodsUpdate:Remove(self.oneupdateListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetListener)
end

function GuildAuctionWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildauctionwindow))
    self.gameObject.name = "GuildAuctionWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.Panel = self.transform:Find("Panel")
    self.Main = self.transform:Find("Main")
    self.Title = self.transform:Find("Main/Title")
    self.TitleText = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self.model:CloseWindow()
    end)
    self.TabButtonGroup = self.transform:Find("Main/TabButtonGroup").gameObject
    self.ListPanel = self.transform:Find("Main/ListPanel")
    self.MaskCon = self.transform:Find("Main/ListPanel/MaskCon")
    self.ScrollLayer = self.transform:Find("Main/ListPanel/MaskCon/ScrollLayer")
    self.Container = self.transform:Find("Main/ListPanel/MaskCon/ScrollLayer/Container")

    self.UnOpen = self.transform:Find("Main/ListPanel/UnOpen").gameObject
    self.TextCurrentGetMoney = self.transform:Find("Main/CurrentGetMoney/TextCurr"):GetComponent(Text)
    self.CurrentMoney = self.transform:Find("Main/CurrentMoney")
    self.TextCurr = self.transform:Find("Main/CurrentMoney/TextCurr"):GetComponent(Text)
    -- self.icon = self.transform:Find("Main/CurrentMoney/TextCurr/icon")
    self.DescText = self.transform:Find("Main/DescText"):GetComponent(Text)
    self.DescText.text = TI18N("每天20:00前掉落的装备，将于当天20:00-23:00开放竞拍")
    -- self.icon = self.transform:Find("Main/DescText/icon")
    self.Toggle = self.transform:Find("Main/Toggle"):GetComponent(Toggle)
    self.Toggle.isOn = PlayerPrefs.GetInt("AuctionNotice") ~= 0
    self.Toggle.onValueChanged:AddListener(function(val)
        self:OnToggleChange(val)
    end)
    self.ReFreshButton = self.transform:Find("Main/ReFreshButton"):GetComponent(Button)
    self.ReFreshButton.gameObject:SetActive(false)

    self.AllToggle = self.transform:Find("Main/AllToggle"):GetComponent(Toggle)
    self.AllToggle.isOn = PlayerPrefs.GetInt("AuctionFilter") ~= 1
    self.AllToggle.onValueChanged:AddListener(function(val)
        self:OnAllToggle(val)
    end)
    self.AllToggleLabel = self.transform:Find("Main/AllToggle/Label"):GetComponent(Text)
    self.AllToggleLabel.text = TI18N("全部显示")

    self.FilterToggle = self.transform:Find("Main/FilterToggle"):GetComponent(Toggle)
    self.FilterToggle.isOn = PlayerPrefs.GetInt("AuctionFilter") == 1
    self.FilterToggle.onValueChanged:AddListener(function(val)
        self:OnFilterToggle(val)
    end)
    self.FilterToggleLabel = self.transform:Find("Main/FilterToggle/Label"):GetComponent(Text)
    self.FilterToggleLabel.text = TI18N("过滤显示")

    self.SetButton = self.transform:Find("Main/SetButton"):GetComponent(Button)
    self.SetButton.onClick:AddListener(function()
        self.TipsClose.gameObject:SetActive(true)
        self.SetList.gameObject:SetActive(true)
        self.TypeList.gameObject:SetActive(false)
    end)
    self.SetButtonIcon = self.transform:Find("Main/SetButton/Icon")
    self.SetButtonName = self.transform:Find("Main/SetButton/Name"):GetComponent(Text)
    self.SetButtonName.text = self.model:GetFilterStr()

    self.TypeButton = self.transform:Find("Main/TypeButton"):GetComponent(Button)
    self.TypeButton.onClick:AddListener(function()
        self.TipsClose.gameObject:SetActive(true)
        self.SetList.gameObject:SetActive(false)
        self.TypeList.gameObject:SetActive(true)
    end)
    self.TypeButtonIcon = self.transform:Find("Main/TypeButton/Icon")
    self.TypeButtonName = self.transform:Find("Main/TypeButton/Name"):GetComponent(Text)

    self.TipsClose = self.transform:Find("Main/TipsClose"):GetComponent(Button)
    self.TipsClose.onClick:AddListener(function()
        self.TipsClose.gameObject:SetActive(false)
        self.SetList.gameObject:SetActive(false)
        self.TypeList.gameObject:SetActive(false)
    end)
    self.SetList = self.transform:Find("Main/SetList")
    self.Mask = self.transform:Find("Main/SetList/Mask")
    self.SetListList = self.transform:Find("Main/SetList/Mask/List")

    self.TypeList = self.transform:Find("Main/TypeList")
    self.Mask = self.transform:Find("Main/TypeList/Mask")
    self.TypeListList = self.transform:Find("Main/TypeList/Mask/List")

    self.TipsSelectButton = self.transform:Find("Main/TipsSelectButton").gameObject
    self.TipsSelectButton:SetActive(false)
    -- self.Toggle = self.transform:Find("Main/TipsSelectButton/Toggle"):GetComponent(Toggle)
    -- self.Background = self.transform:Find("Main/TipsSelectButton/Toggle/Background")
    -- self.Checkmark = self.transform:Find("Main/TipsSelectButton/Toggle/Background/Checkmark")
    -- self.Text = self.transform:Find("Main/TipsSelectButton/Toggle/Text"):GetComponent(Text)

    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetListener)
    self.hideButton = self.transform:Find("Main/hideButton"):GetComponent(Button)
    self.hideButton.onClick:AddListener(function()
        local has = RoleManager.Instance.RoleData.brother
        TipsManager.Instance:ShowText({
            gameObject = self.hideButton.gameObject,
            itemData = {
                TI18N("1、<color='#00ff00'>公会拍卖</color>将竞拍<color='#00ff00'>英雄副本</color>掉落的所有珍稀宝物"),
                TI18N("2、每天20:00前掉落的装备，将于<color='#00ff00'>20:00-23:00</color>开放竞拍，周日<color='#00ff00'>22:00</color>结算所有拍卖品，周日<color='#00ff00'>23:00</color>发放分红"),
                TI18N("3、拍卖所得兄弟币的50%将分红给公会成员，按照本周英雄副本参与情况进行分配"),
                TI18N("4、剩余50%将转化为公会资金，助力公会繁荣发展"),
                TI18N("5、流拍宝物将按照底价算入拍卖所得"),
            }
        }
        )
    end)

    self.oncesprite = self.assetWrapper:GetSprite(AssetConfig.guildauctiontexture, "I18Ngauctiononce")
    self.buysprite = self.assetWrapper:GetSprite(AssetConfig.guildauctiontexture, "I18Ngauctionbuy")
    self.nobuysprite = self.assetWrapper:GetSprite(AssetConfig.guildauctiontexture, "I18Nguildauctionfailed")
    self:InitList()
    self:InitFilter()
    self:OnAssetsUpdate()

    self:AddListeners()
    GuildAuctionManager.Instance:send19701()

    self.tabgroup = TabGroup.New(self.TabButtonGroup, function (tab) self:OnTabChange(tab) end)
end

function GuildAuctionWindow:InitList()
    -- local list = self.data
    local temp = GuildAuctionManager.Instance.itemList
    local list = temp
    if self.index == 2 then
        list = GuildAuctionManager.Instance.olditemList
    else
        self:SetMyReward(list)
    end
    list = self:DoFilter(list)
    list = self:SortData(list)
    self.item_list = {}
    self.item_con = self.Container
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.single_item_height = self.Container:GetChild(0):GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = 336
    for i=1,8 do
        local go = self.item_con:GetChild(i-1).gameObject
        local item = GuildAuctionItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll = self.ScrollLayer:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function(data)
        -- BaseUtils.dump(data)
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
    if #list <= 0 then
        self.UnOpen.gameObject:SetActive(true)
    else
        self.UnOpen.gameObject:SetActive(false)
    end
end

function GuildAuctionWindow:ReloadList()
    local temp = GuildAuctionManager.Instance.itemList
    local list = temp
    if self.index == 2 then
        list = GuildAuctionManager.Instance.olditemList
    else
        self:SetMyReward(list)
    end
    list = self:DoFilter(list)
    list = self:SortData(list)
    if #list <= 0 then
        self.UnOpen:SetActive(true)
    else
        self.UnOpen:SetActive(false)
    end

    if self.setting_data == nil then
        return
    end
    for k,v in pairs(self.item_list) do
        v.gameObject:SetActive(true)
    end
    self.setting_data.data_list = list
    -- if changetype then
        BaseUtils.refresh_circular_list(self.setting_data)
    -- else
        -- BaseUtils.static_refresh_circular_list(self.setting_data)
    -- end
end

function GuildAuctionWindow:OnRefresh()
    -- body
end

function GuildAuctionWindow:OnAssetsUpdate()
    self.TextCurr.text = tostring(RoleManager.Instance.RoleData.brother)
end

function GuildAuctionWindow:OnTabChange(index)
    self.index = index
    if index == 2 then
        GuildAuctionManager.Instance:send19707()
    end
    self:ReloadList()
end

function GuildAuctionWindow:SortData(data)
    local list = data
    local sortfunc = function(a, b)
        if b == nil then
            return false
        end
        local al = GuildAuctionManager.Instance.likeList[a.id] ~= nil
        local bl = GuildAuctionManager.Instance.likeList[b.id] ~= nil
        if a.status == 0 and b.status ~= 0 then
            return true
        elseif a.status ~= 0 and b.status == 0 then
            return false
        elseif al and not bl then
            return true
        elseif bl and not al then
            return false
        elseif a.start_time < b.start_time then
            return true
        elseif a.start_time > b.start_time then
            return false
        else
            local acraft = DataGuildAuction.data_list[a.item_id].craft
            local bcraft = DataGuildAuction.data_list[b.item_id].craft
            if acraft > bcraft then
                return true
            elseif acraft < bcraft then
                return false
            else
                local aitem_type = DataGuildAuction.data_list[a.item_id].item_type
                local bitem_type = DataGuildAuction.data_list[b.item_id].item_type
                if aitem_type ~= bitem_type then
                    return aitem_type < bitem_type
                else
                    return a.id < b.id
                end
            end
        end
    end
    table.sort(list, sortfunc)
    return list
end

function GuildAuctionWindow:UpdateSingleItem(data)
    if self.setting_data == nil or self.setting_data.data_list == nil then
        return
    end
    local oldkey = nil
    for k,v in pairs(self.setting_data.data_list) do
        if v.id == data.id then
            oldkey = k
        end
    end
    self.setting_data.data_list[oldkey] = data
    for i,v in ipairs(self.item_list) do
        if v.data ~= nil and v.data.id == data.id then
            v:update_my_self(data)
        end
    end
end


function GuildAuctionWindow:OnToggleChange(isOn)
    if isOn then
        PlayerPrefs.SetInt("AuctionNotice", 1)
        NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>开启</color>公会拍卖提醒"))
    else
        PlayerPrefs.SetInt("AuctionNotice", 0)
        NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>关闭</color>公会拍卖提醒"))
    end
    GuildAuctionManager.Instance.OnGoodsUpdate:Fire()
end

function GuildAuctionWindow:InitFilter()
    local SetList = {}
    table.insert(SetList, 0)
    for k,v in pairs(DataTalisman.data_set) do
        table.insert(SetList, v.set_id)
    end
    table.sort(SetList, function(a, b)
        return a < b
    end)
    local SetH = 0
    self.setBtn = {}
    for k,v in ipairs(SetList) do
        local go = GameObject.Instantiate(self.TipsSelectButton)
        go:SetActive(true)
        local transform = go.transform
        local m_Toggle = transform:Find("Toggle"):GetComponent(Toggle)
        local m_Text = transform:Find("Toggle/Text"):GetComponent(Text)
        m_Toggle.isOn = self.model:HasFilter("set_id", v)
        if v == 0 then
            m_Text.text = TI18N("全部套装")
        else
            m_Text.text = DataTalisman.data_set[v].set_name
        end
        transform:GetComponent(Button).onClick:AddListener(function()
            if self.model:HasFilter("set_id", v) then
                self.model:RemoveFilter("set_id", v)
                self.model:RemoveFilter("set_id", 0)
                self.setBtn[1].m_Toggle.isOn = false
                if v == 0 then
                    self.model.filter["set_id"] = {}
                    for _,btn in pairs(self.setBtn) do
                        btn.m_Toggle.isOn = false
                    end
                end
            else
                self.model:InsertFilter("set_id", v)
                if v == 0 then
                    for _,btn in pairs(self.setBtn) do
                        btn.m_Toggle.isOn = true
                    end
                    for _,set_id in pairs(SetList) do
                        self.model:InsertFilter("set_id", set_id)
                    end
                else
                    if #self.model.filter["set_id"] == #SetList - 1 then
                        self.setBtn[1].m_Toggle.isOn = true
                        self.model:InsertFilter("set_id", 0)
                    end
                end
                self.FilterToggle.isOn = true
            end
            m_Toggle.isOn = self.model:HasFilter("set_id", v)
            self.SetButtonName.text = self.model:GetFilterStr()
            self:ReloadList()
        end)
        table.insert(self.setBtn, {transform = transform, m_Toggle = m_Toggle})
        transform:SetParent(self.SetListList)
        transform.localScale = Vector3.one
        transform.anchoredPosition3D = Vector3(0, -SetH-23.2, 0)
        SetH = SetH + 50
    end
    self.SetListList.sizeDelta = Vector2(200, SetH)

    local TypeH = 0
    self.typeBtn = {}
    for k,v in ipairs(self.TypeListData) do
        local go = GameObject.Instantiate(self.TipsSelectButton)
        go:SetActive(true)
        local transform = go.transform
        local m_Toggle = transform:Find("Toggle"):GetComponent(Toggle)
        local m_Text = transform:Find("Toggle/Text"):GetComponent(Text)
        m_Toggle.isOn = self.model:HasFilter("type", v)
        m_Text.text = self.TypeNameData[k]
        -- transform:GetComponent(Button).onClick:AddListener(function()
        --     if self.model:HasFilter("type", v) then
        --         self.model:RemoveFilter("type", v)
        --         self.model:RemoveFilter("type", 0)
        --         self.typeBtn[1].m_Toggle.isOn = false
        --         if v == 0 then
        --             self.model.filter["type"] = {}
        --             for _,btn in pairs(self.typeBtn) do
        --                 btn.m_Toggle.isOn = false
        --             end
        --         end
        --     else
        --         self.model:InsertFilter("type", v)
        --         if v == 0 then
        --             for _,btn in pairs(self.typeBtn) do
        --                 btn.m_Toggle.isOn = true
        --             end
        --             for _,m_type in pairs(self.TypeListData) do
        --                 self.model:InsertFilter("type", m_type)
        --             end
        --         else
        --             if #self.model.filter["type"] == #self.TypeListData - 1 then
        --                 self.typeBtn[1].m_Toggle.isOn = true
        --                 self.model:InsertFilter("type", 0)
        --             end
        --         end
        --         self.FilterToggle.isOn = true
        --     end
        --     m_Toggle.isOn = self.model:HasFilter("type", v)
        --     self.SetButtonName.text = self.model:GetFilterStr()
        --     self:ReloadList()
        -- end)
        table.insert(self.typeBtn, {transform = transform, m_Toggle = m_Toggle})
        transform:SetParent(self.TypeListList)
        transform.localScale = Vector3.one
        transform.anchoredPosition3D = Vector3(0, -TypeH-23.2, 0)
        TypeH = TypeH + 50
    end
    self.TypeListList.sizeDelta = Vector2(200, TypeH)
end

function GuildAuctionWindow:MatchFilter(data)
    local fullmatch = true
    for k,v in pairs(self.model.filter) do
        local submatch = false
        if next(v) ~= nil then
            for _,filter in pairs(v) do
                if DataTalisman.data_get[data.item_id][k] == filter or filter == 0 or k == "type" then
                    submatch = true
                end
            end
        end
        fullmatch = fullmatch and submatch
    end
    return fullmatch
end

function GuildAuctionWindow:DoFilter(data)
    if PlayerPrefs.GetInt("AuctionFilter") ~= 1 then
        return data
    end
    local temp = {}
    for _,dat in pairs(data) do
        if self:MatchFilter(dat) then
            table.insert(temp, dat)
        end
    end
    return temp
end

function GuildAuctionWindow:OnAllToggle(isOn)
        -- print("OnAllToggle")
    if isOn ~= (PlayerPrefs.GetInt("AuctionFilter") ~= 1) then
        if isOn then
            PlayerPrefs.SetInt("AuctionFilter", 0)
        else
            PlayerPrefs.SetInt("AuctionFilter", 1)
        end
        self.FilterToggle.isOn = PlayerPrefs.GetInt("AuctionFilter") == 1
        self:ReloadList()
    end
end

function GuildAuctionWindow:OnFilterToggle(isOn)
        -- print("OnFilterToggle")
    if isOn ~= (PlayerPrefs.GetInt("AuctionFilter") == 1) then
        if isOn then
            PlayerPrefs.SetInt("AuctionFilter", 1)
        else
            PlayerPrefs.SetInt("AuctionFilter", 0)
        end
        self.AllToggle.isOn = PlayerPrefs.GetInt("AuctionFilter") ~= 1
        self:ReloadList()
    end
end

function GuildAuctionWindow:SetMyReward(data)
    local count = 0
    for k,v in pairs(data) do
        if v.current_price ~= 0 then
            count = count + v.current_price
        else
            local cfg = DataGuildAuction.data_list[v.item_id]
            if cfg ~= nil then
                count = count + cfg.min_price
            end
        end
    end
    self.TextCurrentGetMoney.text = tostring(math.ceil(count/2))
end
