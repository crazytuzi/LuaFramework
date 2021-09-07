-- @author 黄耀聪
-- @date 2016年10月10日

BackendRankPanel = BackendRankPanel or BaseClass(BasePanel)

function BackendRankPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "BackendRankPanel"
    self.mgr = BackendManager.Instance

    self.resList = {
        {file = AssetConfig.backend_rank_panel, type = AssetType.Main},
        {file = AssetConfig.backend_textures, type = AssetType.Dep},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.top3Item = {}
    self.itemList = {}

    self.timeString = TI18N("活动结束剩余时间:<color='#00ff00'>%s</color>")
    self.timeString2 = TI18N("活动已结束")
    self.timeFormat1 = TI18N("%s天%s小时")
    self.timeFormat2 = TI18N("%s小时%s分")
    self.timeFormat3 = TI18N("%s分%s秒")
    self.timeFormat4 = TI18N("%s秒")

    self.myInfoString = TI18N("我的排名:<color='#ffff00'>%s</color>")
    self.noInfoString = TI18N("暂未上榜")

    self.days = 0
    self.hours = 0
    self.minutes = 0
    self.seconds = 0

    self.tickListener = function() self:OnTime() end
    self.reloadListener = function() self:ReloadList() end
    self.rankListener = function(type) if type == self.type then self:ReloadRank() end end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BackendRankPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nilf
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackendRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backend_rank_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    t.anchoredPosition = Vector2.zero

    self.titleRect = t:Find("Title")
    self.titleText = self.titleRect:GetComponent(Text)
    self.top3Container = t:Find("Top3")
    for i=1,3 do
        local tab = {}
        tab.transform = self.top3Container:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("Head/Name"):GetComponent(Text)
        tab.headImage = tab.transform:Find("Head/Image"):GetComponent(Image)
        tab.transform:Find("Rank"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. i)
        self.top3Item[i] = tab
    end
    self.nothing = self.top3Container:Find("Nothing").gameObject

    self.timeText = t:Find("Info/Time"):GetComponent(Text)
    self.myInfoText = t:Find("Info/MyRank"):GetComponent(Text)
    self.showBtn = t:Find("Info/Button"):GetComponent(Button)

    self.cloner = t:Find("RewardList/Scroll/Cloner").gameObject
    self.layout = LuaBoxLayout.New(t:Find("RewardList/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})

    self.showBtn.onClick:AddListener(function() self:ShowList() end)
end

function BackendRankPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BackendRankPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onTick:AddListener(self.tickListener)
    self.mgr.onRank:AddListener(self.rankListener)
    EventMgr.Instance:AddListener(event_name.backend_campaign_change, self.reloadListener)

    self.campId = self.openArgs.campId
    self.menuId = self.openArgs.menuId

    self.menuData = self.model.backendCampaignTab[self.campId].menu_list[self.menuId]
    self.btnSplitList = StringHelper.Split(self.menuData.button_text, "|")

    if self.menuData.is_button == BackendEumn.ButtonType.Countdown then
        if self.timerId ~= nil then LuaTimer.Delete(self.timerId) end
        self.timerId = LuaTimer.Add(5 * 1000, function() self:ReloadList() end)
    end
    self.type = self.menuData.sec_type
    self.mgr:send14054(self.menuData.sec_type)

    self:OnTime()
    self:ReloadList()
    self:ReloadRank()
    self:ReloadInfo()
end

function BackendRankPanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function BackendRankPanel:RemoveListeners()
    self.mgr.onTick:RemoveListener(self.tickListener)
    self.mgr.onRank:RemoveListener(self.rankListener)
    EventMgr.Instance:RemoveListener(event_name.backend_campaign_change, self.reloadListener)
end

function BackendRankPanel:OnTime()
    local model = self.model
    -- local end_time = self.menuData.end_time

    self.days, self.hours, self.minutes, self.seconds = BaseUtils.time_gap_to_timer(self.menuData.end_time - BaseUtils.BASE_TIME)
    if self.days > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat1, tostring(self.days), tostring(self.hours)))
    elseif self.hours > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat2, tostring(self.hours), tostring(self.minutes)))
    elseif self.hours > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat3, tostring(self.minutes), tostring(self.seconds)))
    elseif self.hours > 0 then
        self.timeText.text = string.format(self.timeString, string.format(self.timeFormat4, tostring(self.seconds)))
    else
        self.timeText.text = self.timeString2
    end
end

function BackendRankPanel:ReloadList()
    local model = self.model
    local datalist = {}
    local menuData = self.menuData
    for _,v in pairs(menuData.camp_list) do
        table.insert(datalist, v)
    end
    table.sort(datalist, function(a,b) return a.n < b.n end)

    self.layout:ReSet()
    local bool = false
    local bool1 = false
    for i,v in ipairs(datalist) do
        local tab = self.itemList[i]
        if tab == nil then
            local obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            tab = BackendTextItem.New(model, obj)
            self.itemList[i] = tab
        end
        self.layout:AddCell(tab.gameObject)
        v.campId = self.campId
        v.menuId = self.menuId
        bool = (bool1 ~= (v.status == 0))
        tab:update_my_self(v, self.btnSplitList, bool)
        bool1 = v.status == 0
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i]:SetActive(false)
    end
    self.cloner:SetActive(false)
end

function BackendRankPanel:ReloadRank()
    local model = self.model
    local rankList = model.rankDataTab[self.menuData.sec_type] or {}
    local width = 0
    local height = self.top3Container.sizeDelta.y
    if #rankList > 0 then
        for i,v in ipairs(self.top3Item) do
            local data = rankList[i]
            if data == nil then
                v.gameObject:SetActive(false)
            else
                v.gameObject:SetActive(true)
                width = width + v.transform.sizeDelta.x
                v.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex)
                v.nameText.text = data.name
            end
        end
        self.nothing:SetActive(false)
    else
        for i,v in ipairs(self.top3Item) do
            v.gameObject:SetActive(false)
        end
        self.nothing:SetActive(true)
    end
    self.top3Container.sizeDelta = Vector2(width, height)

    local roleData = RoleManager.Instance.RoleData
    local myRank = 0
    for i,v in ipairs(rankList) do
        if v.role_id == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            myRank = i
            break
        end
    end
    if myRank > 0 then
        self.myInfoText.text = string.format(self.myInfoString, tostring(myRank))
    else
        self.myInfoText.text = string.format(self.myInfoString, tostring(self.noInfoString))
    end
end

function BackendRankPanel:ShowList()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backend_rank, {menuData = self.menuData})
end

function BackendRankPanel:ReloadInfo()
    local height = self.titleRect.sizeDelta.y
    self.titleText.text = self.menuData.rule_str
    local width = math.ceil(self.titleText.preferredWidth) + 20
    if width < 50 then
        width = 50
    end
    self.titleRect.sizeDelta = Vector2(width, height)
end

