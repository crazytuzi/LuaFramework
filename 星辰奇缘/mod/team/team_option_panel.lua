-- ---------------------------
-- 组队目标操作
-- hosr
-- ---------------------------
TeamOptionPanel = TeamOptionPanel or BaseClass(BasePanel)

function TeamOptionPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = mainPanel.gameObject
    self.transform = nil
    self.itemBase1 = nil
    self.itemBase2 = nil
    self.container1 = nil
    self.container2 = nil
    self.scrollRect1 = nil
    self.panel = nil
    self.toggleGroup1 = nil
    self.toggleGroup2 = nil
    self.containerRect1 = nil
    self.bgImgRect = nil
    self.levtxtobj = nil

    self.tab1 = {}
    self.tab2 = {}

    self.listener = function() self:Update() end

    self.resList = {
        {file = AssetConfig.teamoption, type = AssetType.Main}
    }

    self.OnHideEvent:Add(function() self:OnHide() end)

    self.optionItemList = {}

    self.currentClickTabId = 0
end

function TeamOptionPanel:OnHide()
    TipsManager.Instance.model:Closetips()
    -- 关闭的时候重新匹配
    -- 先判断等级
    if TeamManager.Instance.matchStatus ~= TeamEumn.MatchStatus.Recruiting or TeamManager.Instance.matchStatus ~= TeamEumn.MatchStatus.Recruiting then
        return
    end
    local func = function()
        TeamManager.Instance.needReMatch = true
        TeamManager.Instance:AutoFind()
    end

    local last = TeamManager.Instance.TempLevelOption
    local now = TeamManager.Instance.LevelOption
    if last ~= now then
        func()
        return
    end

    last = TeamManager.Instance.TempTypeOptions
    now = TeamManager.Instance.TypeOptions
    for k,v in pairs(last) do
        if now[k] == nil or now[k] ~= v then
            func()
            return
        end
    end

    for k,v in pairs(now) do
        if last[k] == nil or last[k] ~= v then
            func()
            return
        end
    end
end

function TeamOptionPanel:__delete()
    self:OnClose()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function TeamOptionPanel:OnClose()
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
end

function TeamOptionPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamoption))
    self.transform = self.gameObject.transform
    self.gameObject.name = "TeamOptionPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.bgImgRect = self.transform:Find("Main/BgImg"):GetComponent(RectTransform)
    self.levtxtobj = self.transform:Find("Main/LevelText").gameObject
    self.levtxtobj:SetActive(false)
    self.itemBase1 = self.transform:Find("Main/ItemBase1").gameObject
    self.itemBase2 = self.transform:Find("Main/ItemBase2").gameObject
    self.scrollRect1 = self.transform:Find("Main/Scroll1"):GetComponent(ScrollRect)
    self.container1 = self.transform:Find("Main/Scroll1/Container1").gameObject
    self.containerRect1 = self.container1:GetComponent(RectTransform)
    self.container2 = self.transform:Find("Main/Container2").gameObject
    self.panel = self.transform:Find("Panel"):GetComponent(Button)
    self.itemBase1:SetActive(false)
    self.itemBase2:SetActive(false)
    self.toggleGroup1 = self.container1:GetComponent(ToggleGroup)
    self.toggleGroup2 = self.container2:GetComponent(ToggleGroup)
    self.container2:SetActive(false)

    self.panel.onClick:AddListener(function() self:Hiden() end)

    local len = self.container2.transform.childCount
    for i = 1, len do
        local levitem = self.container2.transform:GetChild(i - 1).gameObject
        local tab = {}
        local id = i
        tab["gameObject"] = levitem
        tab["id"] = id
        tab["toggle"] = levitem.transform:Find("Toggle"):GetComponent(Toggle)
        tab["toggle"].group = self.toggleGroup2
        tab["toggle"].isOn = false
        tab["label"] = levitem.transform:Find("Toggle/Label"):GetComponent(Text)
        tab["button"] = levitem:GetComponent(Button)
        levitem:SetActive(false)
        table.insert(self.tab2, tab)
    end

    self:UpdateOption()

    EventMgr.Instance:AddListener(event_name.team_create, self.listener)
    EventMgr.Instance:AddListener(event_name.team_leave, self.listener)
end

function TeamOptionPanel:OnInitCompleted()
    self.transform.gameObject:SetActive(true)
    self:Update()
end

function TeamOptionPanel:Show(arge)
    self.openArgs = arge
    if self.gameObject ~= nil then
        self:OnInitCompleted()
        self.gameObject:SetActive(true)

        self.transform:SetSiblingIndex(20)
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function TeamOptionPanel:CreateOption()
    local item = GameObject.Instantiate(self.itemBase1).gameObject
    item.transform:SetParent(self.container1.transform)
    item.transform.localScale = Vector3.one
    item:SetActive(true)

    local tab = {}
    tab["gameObject"] = item
    tab["rect"] = item:GetComponent(RectTransform)
    tab["label"] = item.transform:Find("Toggle/Label"):GetComponent(Text)
    local toggle = item.transform:Find("Toggle"):GetComponent(Toggle)
    tab["toggle"] = toggle
    toggle.isOn = false
    tab["button"] = item:GetComponent(Button)
    -- table.insert(self.optionItemList, tab)
    return tab
end

-- 更新选项显示
function TeamOptionPanel:UpdateOption()
    self.tab1 = {}
    local specialTab = 0

    for i,v in pairs(self.optionItemList) do
        v.button.onClick:RemoveAllListeners()
        v.toggle.onValueChanged:RemoveAllListeners()
        v.gameObject:SetActive(false)
    end

    local map = SceneManager.Instance:CurrentMapId()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Match then
        -- 段位赛
        specialTab = 6
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.Event_fairyland then
        -- 幻境
        specialTab = 6
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.TopCompete then
        -- 巅峰
        specialTab = 6
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.HeroReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.Hero then
        -- 武道会
        specialTab = 6
        -- TeamManager.Instance.FirstToSecond[specialTab].
        -- BaseUtils.dump(TeamManager.Instance.FirstToSecond, "<color=#FF0000>TeamManager.Instance.FirstToSecond</color>")
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.StarChallenge then
        -- 龙王
        specialTab = 15
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ApocalypseLord then
        -- 天启
        specialTab = 16
    elseif map == 41001 or map == 41002 or map == 41003 then
        -- 天空塔
        specialTab = 7
    elseif map == 50001 or map == 50002 or map == 50003 or map == 50011 or map == 50012 or map == 50013 or map == 50021 or map == 50022 or map == 50023 then
        -- 挂机
        specialTab = 0
    elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady or RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then
        --峡谷之巅
        specialTab = 20
    end

    local len = #self.optionItemList
    local list = BaseUtils.copytab(TeamManager.Instance.FirstList)
    for i,data in pairs(list) do
        local tab_id = data.tab_id
        local tab = nil
        -- if i > len then
        --     tab = self:CreateOption()
        --     print("item"..tab_id)
        -- else
        --     tab = self.optionItemList[i]
        -- end
        if self.optionItemList[i] == nil then
            tab = self:CreateOption()
            self.optionItemList[i] = tab
        else
            tab = self.optionItemList[i]
        end

        tab.gameObject.name = "item"..tab_id
        tab.tab_id = tab_id
        tab.label.text = data.tab_name
        tab.toggle.isOn = false
        tab.toggle.onValueChanged:RemoveAllListeners()
        tab.toggle.onValueChanged:AddListener(  function(val)
                                                    if not val then
                                                        TeamManager.Instance.TypeOptions[tab_id] = nil
                                                    end
                                                end)
        tab.button.onClick:RemoveAllListeners()
        tab.button.onClick:AddListener(function() self:ClickToggle1(tab_id) end)
        self.tab1[tab_id] = tab
        if specialTab == 0 or (specialTab ~= 0 and tab_id == specialTab) then
            local role = RoleManager.Instance.RoleData
            if role.lev_break_times > data.lev_break_times then
                tab.gameObject:SetActive(true)
            elseif role.lev_break_times == data.lev_break_times then
                if role.lev >= data.open_lev then
                    if RoleManager.Instance.RoleData.cross_type == 1 and data.cross_open_lev ~= 0 then
                        tab.gameObject:SetActive(true)
                    elseif RoleManager.Instance.RoleData.cross_type == 0 then
                        tab.gameObject:SetActive(true)
                    end
                end
            end
        end
    end

    self.containerRect1.sizeDelta = Vector2(260, 76 * len)
end

function TeamOptionPanel:ClickToggle1(_tab_id)
    -- BaseUtils.dump(AgendaManager.Instance.currLimitList)
    local tab_id = _tab_id
    local tab = self.tab1[tab_id]
    local list = TeamManager.Instance.FirstToSecond[tab_id]
    local firstData = TeamManager.Instance.FirstList[tab_id]
    if list ~= nil then
        --存在二级列表
        local dat = {}
        tab["toggle"].isOn = false
        tab["label"].text = firstData.tab_name
        TeamManager.Instance.TypeOptions[tab_id] = nil
        table.sort(list, function(a,b)
                            if a.open_lev == b.open_lev then
                                return a.id < b.id
                            else
                                return a.open_lev < b.open_lev
                            end
                        end)
        local role = RoleManager.Instance.RoleData
        for i,v in ipairs(list) do
            if role.lev >= v.open_lev
                and (v.open_lev_limit == 0 or (v.open_lev_limit ~= 0 and role.lev <= v.open_lev_limit))
                and (v.act_id == 0 or (v.act_id ~= 0 and AgendaManager.Instance.currLimitList[v.act_id] ~= nil)) then
                local _label = v.type_name
                local id = v.id
                if id >= 100 and id <= 107 then
                    local group = id - 99
                    local series = nil
                    local heroModel = HeroManager.Instance.model
                    local lev = RoleManager.Instance.RoleData.lev

                    if group == heroModel.myInfo.group then
                        _label = _label..string.format("(%s)", HeroManager.Instance.campNames[group])
                        table.insert(dat, {label = _label, callback = function() self:ChooseSecond(tab_id, id) end})
                    end
                else
                    table.insert(dat, {label = _label, callback = function() self:ChooseSecond(tab_id, id) end})
                end
            end
        end
        if #dat > 0 then
            TipsManager.Instance:ShowButton({gameObject = tab.gameObject, data = dat})
        end
    else
        TipsManager.Instance.model:Closetips()
        if tab["toggle"].isOn then
            tab["toggle"].isOn = false
        else
            TeamManager.Instance.TypeOptions[tab_id] = 0
            tab["toggle"].isOn = true
        end
    end
    self.currentClickTabId = firstData.id

    self:ChangeLevelOption()
    self.mainPanel:SetTeamOption()
end

function TeamOptionPanel:ChooseSecond(tab_id, id)
    local second = DataTeam.data_match[id]
    local tab = self.tab1[tab_id]
    tab["label"].text = second.type_name
    tab["toggle"].isOn = true
    TeamManager.Instance.TypeOptions[tab_id] = second.id

    self.currentClickTabId = second.id

    self:ChangeLevelOption()
    self.mainPanel:SetTeamOption()
end

function TeamOptionPanel:ClickToggle2(id)
    local tab = self.tab2[id]
    tab["toggle"].isOn = true
    TeamManager.Instance.LevelOption = tab.flag
    self.mainPanel:SetTeamOption()
end

--队长，单选,隐藏任意
function TeamOptionPanel:Single()
    for i,tab in pairs(self.tab1) do
        -- tab["toggle"].isOn = false
        tab["toggle"].group = self.toggleGroup1
        tab["label"].text = TeamManager.Instance.FirstList[tab.tab_id].tab_name
    end
    self.toggleGroup1.allowSwitchOff = false
end

--无队伍，多选
function TeamOptionPanel:Mutil()
    for i,tab in pairs(self.tab1) do
        tab["toggle"].group = nil
        tab["label"].text = TeamManager.Instance.FirstList[tab.tab_id].tab_name
        -- tab["toggle"].isOn = false
    end
    self.toggleGroup1.allowSwitchOff = false
    TeamManager.Instance.LevelOption = 1
end

function TeamOptionPanel:Update()
    self:UpdateOption()
    -- if TeamManager.Instance:HasTeam() then
    --     self:Single()
    -- else
    --     self:Mutil()
    -- end


    self:Single()
    self:Layout()
    self:DealOption()
    self:ChangeLevelOption()
    self.mainPanel:SetTeamOption()
end

function TeamOptionPanel:DealOption()
    for first,second in pairs(TeamManager.Instance.TypeOptions) do
        if not self.tab1[first]["toggle"].isOn then
            if second == 0 then
                self:ClickToggle1(first)
            else
                self:ChooseSecond(first, second)
            end
        else
            if second == 0 then
                self.currentClickTabId = TeamManager.Instance:FirstTab(first).id
            else
                self.tab1[first]["label"].text = DataTeam.data_match[second].type_name
            end
        end
    end
end

function TeamOptionPanel:Layout()
    local count = 0
    for k,tab in pairs(self.tab1) do
        if tab["gameObject"].activeSelf then
            count = count + 1
            tab["rect"].anchoredPosition = Vector2(0, -58 * (count - 1) - 38)
        end
    end

    self.containerRect1.sizeDelta = Vector2(200, 58 * count)
end

--根据选中的目标id改变等级范围
function TeamOptionPanel:ChangeLevelOption()
    for i,v in ipairs(self.tab2) do
        v.gameObject:SetActive(false)
        v.toggle.isOn = false
    end
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        local data = DataTeam.data_match[self.currentClickTabId]
        if data ~= nil then
            local list = data.lev_recruit
            local isInit = false
            local len = #list
            if #list > 0 then
                self.bgImgRect.sizeDelta = Vector2(435, 340)
                self.levtxtobj:SetActive(true)
                local roleLev = RoleManager.Instance.RoleData.lev

                for i,v in ipairs(list) do
                    local tab = self.tab2[i]
                    tab.flag = v.flag
                    local index = i
                    tab.button.onClick:RemoveAllListeners()
                    tab.button.onClick:AddListener(function() self:ClickToggle2(index) end)
                    tab.gameObject:SetActive(true)
                    if v.flag == 3 then
                        tab.label.text = TI18N("带新人")
                        if roleLev < 50 then
                            -- 带新人，50级以上的队长才显示出来
                            tab.gameObject:SetActive(false)
                            len = len - 1
                        end
                    else
                        if v.lev == TeamEumn.MatchLevType.Fixed then
                            tab.label.text = string.format(TI18N("%s级~%s级"), v.val1, v.val2)
                        elseif v.lev == TeamEumn.MatchLevType.Dynamic then
                            tab.label.text = string.format(TI18N("%s级~%s级"), math.max(18, roleLev + v.val1), math.min(RoleManager.Instance.world_lev + 8, roleLev + v.val2))
                        end
                    end
                    if v.flag == TeamManager.Instance.LevelOption then
                        isInit = true
                        self:ClickToggle2(index)
                    end
                end

                if not isInit then
                    self:ClickToggle2(1)
                end

                if len > 1 then
                    self.container2:SetActive(true)
                    return
                end
            end
        end
    end

    self.bgImgRect.sizeDelta = Vector2(240, 340)
    self.levtxtobj:SetActive(false)
    for i,v in ipairs(self.tab2) do
        v["toggle"].isOn = false
        v["gameObject"]:SetActive(false)
    end
    self.container2:SetActive(false)
    if TeamManager.Instance.LevelOption == 0 then
        TeamManager.Instance.LevelOption = 1
    end
end