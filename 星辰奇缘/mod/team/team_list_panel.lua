-- -----------------------------
-- 组队列表界面
-- hosr
-- -----------------------------
TeamListPanel = TeamListPanel or BaseClass(BasePanel)

function TeamListPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.parent = self.mainPanel.gameObject.transform
    self.name = "TeamListPanel"
    self.transform = nil
    self.applyBase = nil
    self.requestBase = nil
    self.container = nil
    self.scrollRect = nil

    self.nothing = nil

    self.isInint = false
    self.isOpen = false

    self.applyPool = {}
    self.requestPool = {}
    self.applyTab = {}
    self.requestTab = {}

    self.listener = function() self:Update() end
    self.matchListener = function(list) self:AddMatchTeams(list) end

    self.resList = {
        {file = AssetConfig.teamlist, type = AssetType.Main}
    }
    self.needNum = 0
end

function TeamListPanel:__delete()
    self:OnClose()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function TeamListPanel:OnClose()
    self.mainPanel = nil
    self.transform = nil
    self.applyBase = nil
    self.requestBase = nil
    self.container = nil
    self.scrollRect = nil

    self.nothing = nil

    self.isInint = false
    self.isOpen = false

    self.applyPool = nil
    self.requestPool = nil
    self.applyTab = nil
    self.requestTab = nil
    EventMgr.Instance:RemoveListener(event_name.team_list_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_match_list, self.matchListener)
end

function TeamListPanel:InitPanel()
    if BaseUtils.is_null(self:GetPrefab(AssetConfig.teamlist)) then
        self:OnClose()
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teamlist))
    self.transform = self.gameObject.transform
    self.gameObject.name = "TeamListPanel"
    self.transform:SetParent(self.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -25, 0)
    self.gameObject:SetActive(false)

    self.container = self.transform:Find("Container").gameObject
    self.scrollRect = self.transform.gameObject:GetComponent(ScrollRect)
    self.applyBase = self.transform:Find("ApplyItem").gameObject
    self.applyBase:SetActive(false)
    self.requestBase = self.transform:Find("RequestItem").gameObject
    self.requestBase:SetActive(false)
    self.nothing = self.transform:Find("Nothing").gameObject
    self.nothing:SetActive(false)

    self.isInit = true

    EventMgr.Instance:AddListener(event_name.team_list_update, self.listener)
end

function TeamListPanel:OnInitCompleted()
    self:AfterShow()
end

function TeamListPanel:AfterShow()
    if self.gameObject == nil then
        -- bugly #29784169 hosr 20160722
        return
    end

    self.isOpen = true
    self.gameObject:SetActive(true)

    MainUIManager.Instance.noticeView:set_teamnotice_num(0)

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        TeamManager.Instance:Send11713()
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        TeamManager.Instance:Send11716()
    end
end

function TeamListPanel:Show(arge)
    self.openArgs = arge
    if self.gameObject ~= nil then
        self:OnInitCompleted()
        self.gameObject:SetActive(true)
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function TeamListPanel:Hiden()
    self.isOpen = false
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

-- 参数说明
-- 这里列表会是  邀请列表和申请列表，对应队伍状态
function TeamListPanel:Update()
    self.needNum = 0
    self.order = 0

    self.nothing:SetActive(false)
    --全部更新，把已有对象放到对应对象池里
    for i,v in pairs(self.applyTab) do
        v.gameObject:SetActive(false)
        v.order = 0
        table.insert(self.applyPool, v)
    end
    self.applyTab = {}

    for i,v in pairs(self.requestTab) do
        v.order = 0
        v.gameObject:SetActive(false)
        table.insert(self.requestPool, v)
    end
    self.requestTab = {}

    local list = TeamManager.Instance:GetList()
    for i,v in ipairs(list) do
        local tab = {}
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
            if #self.applyPool > 0 then
                --对象池有可用
                tab = self.applyPool[1]
                table.remove(self.applyPool, 1)
            else
                tab = self:CreateApply()
            end
            self:SetApplyItem(v, tab, false)
            self.applyTab[tab.uniqueid] = tab
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            if #self.requestPool > 0 then
                tab = self.requestPool[1]
                table.remove(self.requestPool, 1)
            else
                tab = self:CreateRequest()
            end
            self:SetRequestItem(v, tab, false)
            self.requestTab[tab.uniqueid] = tab
        end
        self.order = self.order + 1
        tab.order = self.order
    end

    self.needNum = 6 - #list

    -- 补充招募队伍列表
    if self.needNum > 0 then
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
            EventMgr.Instance:AddListener(event_name.team_match_list, self.matchListener)
            TeamManager.Instance:Send11728()
        else
            self:AddMore()
            self:Layout()
        end
    else
        self:Layout()
    end
end

function TeamListPanel:AddMatchTeams(list)
    EventMgr.Instance:RemoveListener(event_name.team_match_list, self.matchListener)

    local len = #list
    len = math.min(len, self.needNum)
    for i = 1, len do
        local v = list[i]
        if self.applyTab[v.uniqueid] == nil then
            local tab = {}
            if #self.applyPool > 0 then
                --对象池有可用
                tab = self.applyPool[1]
                table.remove(self.applyPool, 1)
            else
                tab = self:CreateApply()
            end
            self:SetApplyItem(v, tab, true)
            self.applyTab[tab.uniqueid] = tab

            self.order = self.order + 1
            tab.order = self.order
        end
    end

    self.needNum = self.needNum - len
    -- 不够，继续抽场景的打野队伍补满
    if self.order < 6 then
        self:AddMore()
    end
    self:Layout()
end

-- 取附近队伍或玩家信息
function TeamListPanel:AddMore()
    local addList = {}
    local tab = {}
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        addList = TeamManager.Instance:GetSceneTeam(self.needNum)
        for i,v in ipairs(addList) do
            if self.applyTab[v.uniqueid] == nil then
                if #self.applyPool > 0 then
                    --对象池有可用
                    tab = self.applyPool[1]
                    table.remove(self.applyPool, 1)
                else
                    tab = self:CreateApply()
                end
                self:SetApplyItem(v, tab, true)
                self.applyTab[tab.uniqueid] = tab
                self.order = self.order + 1
                tab.order = self.order
            end
        end
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        addList = TeamManager.Instance:GetSceneMember(self.needNum)
        for i,v in ipairs(addList) do
            if self.requestTab[v.uniqueid] == nil then
                if #self.requestPool > 0 then
                    tab = self.requestPool[1]
                    table.remove(self.requestPool, 1)
                else
                    tab = self:CreateRequest()
                end
                self:SetRequestItem(v, tab, true)
                self.requestTab[tab.uniqueid] = tab
                self.order = self.order + 1
                tab.order = self.order
            end
        end
    end
end

function TeamListPanel:CreateApply()
    local item = GameObject.Instantiate(self.applyBase).gameObject
    item.name = "apply_item"
    item.transform:SetParent(self.container.transform)
    item.transform.localScale = Vector3.one

    local tab = {}
    tab.gameObject = item
    tab.transform = item.transform
    tab.sex_icon = tab.transform:Find("SexIcon"):GetComponent(Image)
    tab.name_txt = tab.transform:Find("Name"):GetComponent(Text)
    tab.button = tab.transform:Find("Button"):GetComponent(Button)
    tab.level_txt = tab.transform:Find("Level"):GetComponent(Text)
    tab.classes_txt = tab.transform:Find("Classes"):GetComponent(Text)
    tab.count_txt = tab.transform:Find("Count"):GetComponent(Text)
    tab.typeTxt = tab.transform:Find("Type/Text"):GetComponent(Text)
    tab.button_txt = tab.button.gameObject.transform:Find("Text"):GetComponent(Text)
    return tab
end

function TeamListPanel:CreateRequest()
    local item = GameObject.Instantiate(self.requestBase).gameObject
    item.name = "request_item"
    item.transform:SetParent(self.container.transform)
    item.transform.localScale = Vector3.one

    local tab = {}
    tab.gameObject = item
    tab.transform = item.transform
    tab.sex_icon = tab.transform:Find("SexIcon"):GetComponent(Image)
    tab.name_txt = tab.transform:Find("Name"):GetComponent(Text)
    tab.ok_button = tab.transform:Find("OkButton"):GetComponent(Button)
    tab.no_button = tab.transform:Find("NoButton"):GetComponent(Button)
    tab.level_txt = tab.transform:Find("Level"):GetComponent(Text)
    tab.classes_txt = tab.transform:Find("Classes"):GetComponent(Text)
    tab.head_img = tab.transform:Find("HeadImg"):GetComponent(Image)
    tab.no_button_txt = tab.no_button.gameObject.transform:Find("Text"):GetComponent(Text)
    return tab
end

function TeamListPanel:SetApplyItem(data, tab, isMore)
    local num = data.member_num or data.team_num
    local rid = data.rid or data.roleid
    local pf = data.platform
    local zid = data.zone_id or data.zoneid
    local temp_item = tab.gameObject
    local type = data.type or 0

    local uniqueid = BaseUtils.get_unique_roleid(rid, zid, pf)
    tab.uniqueid = uniqueid

    tab.name_txt.text = data.name
    tab.level_txt.text = string.format(TI18N("%s级"), data.lev)
    tab.classes_txt.text = KvData.classes_name[data.classes]
    tab.count_txt.text = string.format(TI18N("人数:<color='#4dd52b'>%s/5</color>"), num)
    tab.sex_icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("IconSex%s", data.sex))
    if type == 0 then
        tab.typeTxt.text = TI18N("附近队伍")
    else
        tab.typeTxt.text = DataTeam.data_match[type].type_name
    end

    tab.button.onClick:RemoveAllListeners()
    local txt = tab.button_txt
    if isMore then
        tab.button_txt.text = TI18N("申请入队")
        tab.button.onClick:AddListener(function() TeamManager.Instance:Send11704(rid, pf, zid, 1) txt.text = TI18N("已申请") end)
    else
        tab.button_txt.text = TI18N("接受邀请")
        tab.button.onClick:AddListener(function() TeamManager.Instance:Send11703(rid, pf, zid, 1) txt.text = TI18N("已接受") end)
    end

    return tab
end

function TeamListPanel:SetRequestItem(data, tab, isMore)
    tab.name_txt.text = data.name
    tab.level_txt.text = string.format(TI18N("%s级"), data.lev)
    tab.classes_txt.text = KvData.classes_name[data.classes]
    tab.sex_icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("IconSex%s", data.sex))
    tab.head_img.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", data.classes, data.sex))
    tab.head_img.gameObject:SetActive(true)
    local rid = data.rid or data.roleid
    local pf = data.platform
    local zid = data.zone_id or data.zoneid
    local temp_item = tab.gameObject

    local uniqueid = BaseUtils.get_unique_roleid(rid, zid, pf)
    tab.uniqueid = uniqueid

    tab.ok_button.onClick:RemoveAllListeners()
    tab.no_button.onClick:RemoveAllListeners()

    if isMore then
        tab.ok_button.gameObject:SetActive(false)
        tab.no_button_txt.text = TI18N("邀请")
        local txt = tab.no_button_txt
        tab.no_button.onClick:AddListener(function()
                                            TeamManager.Instance:Send11702(rid, pf, zid, 0)
                                            txt.text = TI18N("<color='#ffff00'>已邀请</color>")
                                          end)
    else
        tab.ok_button.gameObject:SetActive(true)
        tab.no_button_txt.text = TI18N("拒绝")
        tab.ok_button.onClick:AddListener(function() TeamManager.Instance:Send11718(rid, pf, zid, 1) temp_item:SetActive(false) end)
        tab.no_button.onClick:AddListener(function() TeamManager.Instance:Send11718(rid, pf, zid, 0) end)
    end
end

--手动布局
function TeamListPanel:Layout()
    local list = {}
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        -- 队长查看申请列表
        for k,v in pairs(self.requestTab) do
            table.insert(list, v)
        end
    elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
        -- 没队伍的查看邀请列表
        for k,v in pairs(self.applyTab) do
            table.insert(list, v)
        end
    end

    table.sort(list, function(a,b) return a.order < b.order end)

    for i,v in ipairs(list) do
        -- has = true
        local x = (i - 1) % 2 * 343 + 10
        local y = -math.floor((i - 1) / 2) * 85 - 15
        v.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(x, y)
        v.gameObject:SetActive(true)
    end
    if #list > 6 then
        self.container.transform.sizeDelta = Vector2(705,math.ceil((#list)/2)*90)
    else
        self.container.transform.sizeDelta = Vector2(705, 277.5)
    end
    if #list > 0 then
        self.nothing:SetActive(false)
    else
        self.nothing:SetActive(true)
    end
end