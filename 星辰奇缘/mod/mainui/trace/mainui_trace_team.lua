-- --------------------
-- 组队追踪
-- hosr
-- --------------------
MainuiTraceTeam = MainuiTraceTeam or BaseClass(BaseTracePanel)

function MainuiTraceTeam:__init(main)
    self.main = main
    self.isInit = false

    self.teamList = {}

    self.statusName = {
        [0] = "",
        [1] = "",
        [2] = "",
        [3] = TI18N("<color='#00ff12'>暂</color>"),
        [4] = TI18N("<color='#ff0000'>离</color>"),
    }

    self.listener = function() self:LoadTeam() end
    self.matchlistener = function() self:UpdateMatch() end

    self.leaveColor = Color(120/255,120/255,120/255,1)
    self.normalColor = Color(1,1,1,1)

    self.resList = {
        {file = AssetConfig.team_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceTeam:__delete()
    self.OnHideEvent:Fire()
end

function MainuiTraceTeam:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.team_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector3(0, -45, 0)

    self.noteam = self.transform:Find("NoTeam").gameObject
    local transform = self.noteam.transform
    self.noteamTxt = transform:Find("Image/Text"):GetComponent(Text)
    self.createBtn = transform:Find("CreateButton"):GetComponent(Button)
    self.findBtn = transform:Find("FindButton"):GetComponent(Button)
    self.noteam:SetActive(false)

    self.createBtn.onClick:AddListener(function() self:ClickCreate() end)
    self.findBtn.onClick:AddListener(function() self:ClickFind() end)

    self.teamContainer = self.transform:Find("Container").gameObject
    transform = self.teamContainer.transform

    self.matchObj = transform:Find("Matching").gameObject
    self.matchTransform = self.matchObj.transform
    self.matchTxt = self.matchTransform:Find("Text"):GetComponent(Text)
    self.matchTxt.text = ""

    for i=1,5 do
        local item = transform:GetChild(i - 1)
        item.gameObject:SetActive(false)
        local tab = {}
        tab["gameObject"] = item.gameObject
        tab["headImg"] = item:Find("Head/Img"):GetComponent(Image)
        tab["Frame"] = item:Find("Frame"):GetComponent(Image)
        tab["level"] = item:Find("Level"):GetComponent(Text)
        tab["level"].alignment = 4
        tab["levelContainer"] = item:Find("Image")
        NumberpadPanel.AddUIChild(tab["levelContainer"].gameObject, tab["level"].gameObject)
        tab["name"] = item:Find("Name"):GetComponent(Text)
        tab["icon"] = item:Find("Icon"):GetComponent(Image)
        tab["captin"] = item:Find("Captin").gameObject
        tab["state"] = item:Find("State"):GetComponent(Text)
        tab["headImg"].gameObject:SetActive(true)
        tab["stateBgRect"] = item:Find("Image"):GetComponent(RectTransform)
        tab["slot"] = HeadSlot.New()
        tab["slot"]:SetRectParent(item:Find("Head"))
        tab["cross"] = item:Find("Cross").gameObject
        local index = i
        item.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickOne(index) end)

        table.insert(self.teamList, tab)
    end

    self:LoadTeam()

    EventMgr.Instance:AddListener(event_name.team_update, self.listener)
    EventMgr.Instance:AddListener(event_name.team_create, self.listener)
    EventMgr.Instance:AddListener(event_name.team_leave, self.listener)
    EventMgr.Instance:AddListener(event_name.team_update_match, self.matchlistener)

    self.isInit = true
end

function MainuiTraceTeam:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceTeam:OnShow()
end

function MainuiTraceTeam:OnHide()
end

function MainuiTraceTeam:LoadTeam()
    local list = TeamManager.Instance:GetMemberOrderList()
    if #list == 0 then
        self.noteam:SetActive(true)
        self.teamContainer:SetActive(false)
    else
        for i,member in ipairs(list) do
            local tab = self.teamList[i]
            if tab == nil then
                Debug.LogError("队伍超过人数？未初始化？i = "..tostring(i))
                return
            end
            tab["name"].text = member.name
            tab["level"].text = tostring(member.lev)
            tab["levelContainer"].sizeDelta = Vector2(math.ceil(tab["level"].preferredWidth) + 8, 20)
            tab["state"].text = self.statusName[member.status]
            tab["captin"]:SetActive(member.status ==  RoleEumn.TeamStatus.Leader)
            tab["icon"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(member.classes))
            tab["headImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, string.format("%s_%s", member.classes, member.sex))
            tab["gameObject"]:SetActive(true)
            tab["data"] = member
            if member.status == RoleEumn.TeamStatus.Offline then
                tab["headImg"].color = self.leaveColor
            else
                tab["headImg"].color = self.normalColor
            end

            if BaseUtils.IsTheSamePlatform(member.platform, member.zone_id) then
                tab["cross"]:SetActive(false)
            else
                tab["cross"]:SetActive(true)
            end

            -- if member.status == RoleEumn.TeamStatus.Offline or member.status == RoleEumn.TeamStatus.Away then
            --     tab["stateBgRect"].sizeDelta = Vector2(54, 20)
            -- else
            --     tab["stateBgRect"].sizeDelta = Vector2(30, 20)
            -- end

            local uniqueid = BaseUtils.get_unique_roleid(member.rid, member.zone_id, member.platform)
            if uniqueid == TeamManager.Instance.selfUniqueid then
                self.selfObj = tab.gameObject
            end
            tab["Frame"].gameObject:SetActive(false)
            for k,v in pairs(member.looks) do
                if v.looks_type == SceneConstData.looktype_role_frame then
                    tab["Frame"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.rolelev_frame, tostring(v.looks_val))
                    tab["Frame"].gameObject:SetActive(true)
                    break
                end
            end

            local dat = {id = member.rid, platform = member.platform, zone_id = member.zone_id, sex = member.sex, classes = member.classes}
            tab["slot"]:HideSlotBg(true, 0.0625)
            tab["slot"]:SetAll(dat, {isSmall = true})
            tab["slot"]:SetGray(member.status == RoleEumn.TeamStatus.Offline)
        end

        local begin = #list + 1
        for i = begin,5 do
            self.teamList[i].gameObject:SetActive(false)
            self.teamList[i].data = nil
        end
        self.noteam:SetActive(false)
        self.teamContainer:SetActive(true)

        if #list < 5 then
            self.matchTransform.localPosition = Vector3(0, -#list * 60 - 10, 0)
        else
            self.matchObj:SetActive(false)
        end
    end

    self:UpdateMatch()
end

function MainuiTraceTeam:UpdateMatch()
    if TeamManager.Instance.matchStatus == TeamEumn.MatchStatus.None then
        self.noteamTxt.text = TI18N("当前未加入队伍")
        self.matchObj:SetActive(false)
    elseif TeamManager.Instance.matchStatus == TeamEumn.MatchStatus.Recruiting then
        self.noteamTxt.text = TI18N("招募队员中...")
        self:ShowMatchInfo()
        self.matchObj:SetActive(true)
    elseif TeamManager.Instance.matchStatus == TeamEumn.MatchStatus.Matching then
        self.noteamTxt.text = TI18N("匹配队伍中...")
        self.matchObj:SetActive(false)
    end
end

function MainuiTraceTeam:ShowMatchInfo()
    local data = DataTeam.data_match[TeamManager.Instance.TypeData.type]
    if data == nil then
        self.matchTxt.text = TI18N("队员招募中")
    else
        self.matchTxt.text = string.format(TI18N("<color='#ffff00'>%s</color>队员招募中"), data.type_name)
    end
end

function MainuiTraceTeam:ClickOne(index)
    local tab = self.teamList[index]
    if tab.data == nil then
        return
    end
    local member = tab.data
    local uniqueid = BaseUtils.get_unique_roleid(member.rid, member.zone_id, member.platform)
    local btns = {}
    local gameObject = nil
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        -- 队长点击队员，出现召回，委任，剔除
        if uniqueid ~= TeamManager.Instance.selfUniqueid then
            if member.status == RoleEumn.TeamStatus.Away then
                -- 如果暂时才显示召回
                table.insert(btns, {label = TI18N("召唤归队"), callback = function() TeamManager.Instance:Send11709(member.rid, member.platform, member.zone_id) end})
            end
            table.insert(btns, {label = TI18N("查看信息"), callback = function() TipsManager.Instance:ShowPlayer({rid = member.rid, platform = member.platform, zone_id = member.zone_id}) end})

            if TeamManager.Instance.endFightGive then
                table.insert(btns, {label = TI18N("取消委任"), callback = function() TeamManager.Instance:Send11705(member.rid, member.platform, member.zone_id, member.name) end})
            else
                table.insert(btns, {label = TI18N("委任队长"), callback = function() TeamManager.Instance:Send11705(member.rid, member.platform, member.zone_id, member.name) end})
            end

            if TeamManager.Instance.endFightKick then
                table.insert(btns, {label = TI18N("取消踢出"), callback = function() TeamManager.Instance:Send11710(member.rid, member.platform, member.zone_id, member.name) end})
            else
                table.insert(btns, {label = TI18N("踢出队伍"), callback = function() TeamManager.Instance:Send11710(member.rid, member.platform, member.zone_id, member.name) end})
            end
        else
            if TeamManager.Instance.endFightQuit then
                table.insert(btns, {label = TI18N("取消退队"), callback = function() TeamManager.Instance:Send11708() end})
            else
                table.insert(btns, {label = TI18N("退  队"), callback = function() TeamManager.Instance:Send11708() end})
            end
        end
        gameObject = tab.gameObject
    else
        if uniqueid ~= TeamManager.Instance.selfUniqueid then
            table.insert(btns, {label = TI18N("查看信息"), callback = function() TipsManager.Instance:ShowPlayer({rid = member.rid, platform = member.platform, zone_id = member.zone_id}) end})
        end
        -- 不是队长的点任何地方都是自己的操作
        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Away then
            if TeamManager.Instance.endFightBack then
                table.insert(btns, {label = TI18N("取消归队"), callback = function() TeamManager.Instance:Send11707() end})
            else
                table.insert(btns, {label = TI18N("归  队"), callback = function() TeamManager.Instance:Send11707() end})
            end
        elseif TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow then
            table.insert(btns, {label = TI18N("暂  离"), callback = function() TeamManager.Instance:Send11706() end})
        end

        if TeamManager.Instance.endFightChange then
            table.insert(btns, {label = TI18N("取消顶替"), callback = function() TeamManager.Instance:Send11730() end})
        else
            table.insert(btns, {label = TI18N("顶替队长"), callback = function() TeamManager.Instance:Send11730() end})
        end

        if TeamManager.Instance.endFightQuit then
            table.insert(btns, {label = TI18N("取消退队"), callback = function() TeamManager.Instance:Send11708() end})
        else
            table.insert(btns, {label = TI18N("退  队"), callback = function() TeamManager.Instance:Send11708() end})
        end

        -- gameObject = self.selfObj
        gameObject = tab.gameObject
    end
    

    local isDriver = 2 -- 默认不处于共乘状态
    if SceneManager.Instance.sceneElementsModel.self_data ~= nil then 
        isDriver = SceneManager.Instance.sceneElementsModel.self_data.isDriver
    end
    if uniqueid ~= TeamManager.Instance.selfUniqueid then --不能是自己
        if RideManager.Instance.model:CheckIsMultiplayerRide() and (isDriver == 2) and member.status ~=  RoleEumn.TeamStatus.Leader and RoleManager.Instance.RoleData.event ~= RoleEumn.Event.Home and TeamManager.Instance:MyStatus() ~= RoleEumn.TeamStatus.Away then -- 自己正在双人坐骑上/自己没有处于共乘状态/点击的不能是队长/自己不能在家园中
            table.insert(btns, {label = TI18N("邀请共乘"), callback = function() 
                if SceneManager.Instance.sceneElementsModel.self_data.ride == SceneConstData.unitstate_fly then
                    if RideManager.Instance.model:CheckFly() then
                        RideManager.Instance:Send17031(member.rid, member.platform, member.zone_id)
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("你的双人坐骑未支持飞行，请在非飞行状态下共乘"))
                    end
                else
                    RideManager.Instance:Send17031(member.rid, member.platform, member.zone_id) 
                end
            end})                
        end
    else   
        if (isDriver == 0 or isDriver == 1) then  --处于共乘状态(乘客/司机)
            table.insert(btns, {label = TI18N("退出共乘"), callback = function() RideManager.Instance:Send17035() end})          
        end
    end

    if #btns > 0 then
        TipsManager.Instance:ShowButton({gameObject = gameObject, data = btns})
    end
end

function MainuiTraceTeam:ClickFind()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team)
end

function MainuiTraceTeam:ClickCreate()
     TeamManager.Instance:Send11701()
end