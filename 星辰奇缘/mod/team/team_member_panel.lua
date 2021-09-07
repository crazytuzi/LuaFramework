-- -----------------------------
-- 组队成员信息界面
-- hosr
-- -----------------------------
TeamMemberPanel = TeamMemberPanel or BaseClass(BasePanel)

function TeamMemberPanel:__init(mainPanel)
    self.transform =  nil
    self.mainPanel = mainPanel
    self.parent  = self.mainPanel.gameObject.transform
    self.memberTab = {}
    self.memberCount = 0
    -- 记录位置占用情况
    self.memberOkTab = {}
    self.currentSelectId = 0
    self.inChangeMode = false

    self.previewList = {}
    -- 记录是否初始化过
    self.initPreviewList = {}

    self.listener = function() self:OnUpdate() end
    self.formationlistener = function() self:UpdateFormationAttr() end
    self.teampositionlistener = function() self:TeamPositionChange() end
    self.guardpositionlistener = function() self:GuardPositionChange() end

    self.effectPath = "prefabs/effect/20009.unity3d"
    self.effect = nil

    self.resList = {
        {file = AssetConfig.teammember, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main}
    }

    self.posList = {
        Vector2(5, -12),
        Vector2(148, -12),
        Vector2(291, -12),
        Vector2(435, -12),
        Vector2(578, -12),
    }

    self.effectPos = {
        Vector3(-285, 70, -80),
        Vector3(-140, 70, -80),
        Vector3(0, 70, -80),
        Vector3(140, 70, -80),
        Vector3(285, 70, -80),
    }

    self.alpha = Color(1,1,1,190/255)
    self.noalpha = Color(1,1,1,1)

    self.loading = false
    self.isInit = false
end

function TeamMemberPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
    EventMgr.Instance:RemoveListener(event_name.guard_position_change, self.guardpositionlistener)
    EventMgr.Instance:RemoveListener(event_name.formation_update, self.formationlistener)
    EventMgr.Instance:RemoveListener(event_name.team_position_change, self.teampositionlistener)

    for k,v in pairs(self.previewList) do
        v:DeleteMe()
        v = nil
    end
    self.previewList = nil
    self.initPreviewList = nil
    self:OnClose()
end

function TeamMemberPanel:Show(arge)
    if self.loading then
        return
    end

    self.openArgs = arge
    if self.gameObject ~= nil then
        self.loading = false
        self:OnInitCompleted()
        self.gameObject:SetActive(true)
        self.OnOpenEvent:Fire()
    else
        -- 如果有资源则加载资源，否则直接调用初始化接口
        self.loading = true
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAssetBundleBatch()
        else
            self:OnResLoadCompleted()
        end
    end
end

function TeamMemberPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teammember))
    self.transform = self.gameObject.transform

    self.gameObject.name = "TeamMemberPanel"
    self.transform:SetParent(self.parent)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -25, 0)

    for i = 1, 5 do
        local member = self.transform:GetChild(i - 1).gameObject
        member:SetActive(false)
        local id = i
        local tab = {}
        tab["id"] = id
        tab["can_change"] = false
        tab["gameObject"] = member
        tab["transform"] = member.transform
        tab["rect"] = member:GetComponent(RectTransform)
        tab["bg_img"] = member:GetComponent(Image)
        tab["captin"] = member.transform:Find("Captin").gameObject
        tab["classes_icon"] = member.transform:Find("ClassIcon"):GetComponent(Image)
        tab["classes_txt"] = member.transform:Find("CassesTxt"):GetComponent(Text)
        tab["level_txt"] = member.transform:Find("LevelTxt"):GetComponent(Text)
        if i == 2 then  -- 第二个等级字体位置偏了
            member.transform:Find("LevelTxt").anchoredPosition3D = Vector3(-11.7, -112, 0)
        end
        tab["name_txt"] = member.transform:Find("NameTxt"):GetComponent(Text)
        tab["position_txt"] = member.transform:Find("PositionTxt"):GetComponent(Text)
        tab["guard_obj"] = member.transform:Find("IsGuide").gameObject
        tab["black"] = member.transform:Find("Black").gameObject
        tab["formation1"] = member.transform:Find("FormationInfo1").gameObject
        tab["formation2"] = member.transform:Find("FormationInfo2").gameObject
        tab["formation_txt1"] = member.transform:Find("FormationInfo1/Text"):GetComponent(Text)
        tab["formation_img1"] = member.transform:Find("FormationInfo1/Image"):GetComponent(Image)
        tab["formation_txt2"] = member.transform:Find("FormationInfo2/Text"):GetComponent(Text)
        tab["formation_img2"] = member.transform:Find("FormationInfo2/Image"):GetComponent(Image)
        tab["preview"] = member.transform:Find("Preview").gameObject
        tab["rect1"] = tab["formation1"]:GetComponent(RectTransform)
        tab["rect2"] = tab["formation2"]:GetComponent(RectTransform)
        tab["select"] = member.transform:Find("Select").gameObject
        tab["statusObj"] = member.transform:Find("Status").gameObject
        tab["statusTxt"] = member.transform:Find("Status/Text"):GetComponent(Text)
        tab["btn"] = member:GetComponent(CustomButton)

        tab["select"]:SetActive(false)
        tab["formation1"]:SetActive(false)
        tab["formation2"]:SetActive(false)
        tab["formation_txt1"].gameObject:SetActive(false)
        tab["formation_img1"].gameObject:SetActive(false)
        tab["formation_txt2"].gameObject:SetActive(false)
        tab["formation_img2"].gameObject:SetActive(false)
        tab["statusObj"]:SetActive(false)

        tab["btn"].onClick:AddListener(function() self:ClickMember(id) end)
        tab["btn"].onHold:AddListener(function() self:HoldMember(id) end)
        tab["btn"].onDown:AddListener(function() self:DownMember(id) end)
        tab["btn"].onUp:AddListener(function() self:UpMember(id) end)
        table.insert(self.memberTab, tab)
    end

    EventMgr.Instance:AddListener(event_name.team_create, self.listener)
    EventMgr.Instance:AddListener(event_name.team_update, self.listener)
    EventMgr.Instance:AddListener(event_name.team_leave, self.listener)
    EventMgr.Instance:AddListener(event_name.guard_position_change, self.guardpositionlistener)
    EventMgr.Instance:AddListener(event_name.formation_update, self.formationlistener)
    EventMgr.Instance:AddListener(event_name.team_position_change, self.teampositionlistener)

    self:UpdateFormationAttr()

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect:SetActive(false)
    self.effect.name = "HoldEffect"
    self.effect.transform:SetParent(self.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 70, -80)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
end

function TeamMemberPanel:Default(member)
    member["captin"]:SetActive(false)
    member["classes_icon"].gameObject:SetActive(false)
    member["classes_txt"].gameObject:SetActive(false)
    member["level_txt"].gameObject:SetActive(false)
    member["name_txt"].gameObject:SetActive(false)
    member["position_txt"].gameObject:SetActive(true)
    member["guard_obj"]:SetActive(false)
    member["black"]:SetActive(false)
end

function TeamMemberPanel:OnClose()
    EventMgr.Instance:RemoveListener(event_name.team_create, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.team_leave, self.listener)
    EventMgr.Instance:RemoveListener(event_name.guard_position_change, self.guardpositionlistener)
    EventMgr.Instance:RemoveListener(event_name.formation_update, self.formationlistener)
    EventMgr.Instance:RemoveListener(event_name.team_position_change, self.teampositionlistener)
    self.transform =  nil
    self.mainPanel = nil
    self.memberTab = nil
    self.memberCount = 0
    self.memberOkTab = {}
    self.listener = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
    self.isInit = false
end

-- ------------------------------------------------------------------------
-- 没队伍的时候，显示守护上阵情况
-- 有队伍的时候，如果自己是队长，显示队员和守护填充信息，如果不是，显示队员
-- ------------------------------------------------------------------------
function TeamMemberPanel:OnUpdate()
    self:ExitChangeMode()
    self:OnInitCompleted()
end

function TeamMemberPanel:OnInitCompleted()
    self.loading = false
    if self.memberTab == nil then
        return
    end

    for k,v in pairs(self.memberTab) do
        v.gameObject:SetActive(false)
    end
    self.memberCount = 0
    self.memberOkTab = {}
    local mystatus = TeamManager.Instance:MyStatus()
    if TeamManager.Instance:HasTeam() then
        local list = TeamManager.Instance:GetMemberOrderList()
        for i,team in ipairs(list) do
            self.memberCount = self.memberCount + 1
            local member = nil
            if mystatus == RoleEumn.TeamStatus.Leader then
                member = self.memberTab[team.number]
                self.memberOkTab[team.number] = 1
            else
                member = self.memberTab[self.memberCount]
                self.memberOkTab[self.memberCount] = 1
            end
            if team.uniqueid ==  TeamManager.Instance.selfUniqueid then
                member["is_self"] = true
            else
                member["is_self"] = false
            end
            member["is_guard"] = false
            member["info"] = team
            self:SetMemberInfo(member, {number = team.number, name = team.name, classes = team.classes, sex = team.sex, lev = team.lev, is_captin = (team.status == RoleEumn.TeamStatus.Leader)})

            local modelData = {type = PreViewType.Role, classes = team.classes, sex = team.sex, looks = team.looks}
                self:SetPriview(i, modelData)
        end

        if mystatus == RoleEumn.TeamStatus.Leader then
            --队长用守护补充队伍
            self:PutInTeamGuard()
        end
    else
        --第一个放自己,其他放上阵的守护
        self.memberCount = self.memberCount + 1
        local member = self.memberTab[self.memberCount]
        local role = RoleManager.Instance.RoleData
        member["is_self"] = true
        member["is_guard"] = false
        local copyRole = BaseUtils.copytab(role)
        copyRole.number = 1
        member["info"] = copyRole
        self:SetMemberInfo(member, {number = self.memberCount, name = role.name, classes = role.classes, sex = role.sex, lev = role.lev, is_captin = false})
        self.memberOkTab[self.memberCount] = 1

        local looks = {}
        if SceneManager.Instance:MyData() ~= nil then
            looks = SceneManager.Instance:MyData().looks
        end
        local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = looks}
        self:SetPriview(self.memberCount, modelData)

        self:PutInGuard()
    end

    for i = self.memberCount + 1, 5 do
        self.memberTab[i]["gameObject"]:SetActive(false)
    end

    if self.inChangeMode then
        self:ExitChangeMode()
    end

    self.isInit = true
end

--放入守护,没队伍的，取自己的守护信息
function TeamMemberPanel:PutInGuard()
    table.sort(FormationManager.Instance.guardList, function(a,b) return a.number < b.number end)
    local endval = 5 - self.memberCount
    local list = FormationManager.Instance:GetFightGuardList()
    endval = math.min(endval, #list)
    for i = 1, endval do
        local guard = list[i]
        local gdata = DataShouhu.data_guard_base_cfg[guard.guard_id]
        if gdata ~= nil then
            self:PutGuard(gdata)
        end
    end
end

--放入守护,有队伍的取队伍的守护信息
function TeamMemberPanel:PutInTeamGuard()
    local endval = 5 - self.memberCount
    endval = math.min(endval, #FormationManager.Instance.teamGuardList)
    for i = 1, endval do
        local guard_id = FormationManager.Instance.teamGuardList[i].guard_id
        local gdata = DataShouhu.data_guard_base_cfg[guard_id]
        if gdata ~= nil then
            self:PutGuard(gdata)
        end
    end
end

function TeamMemberPanel:PutGuard(argsData)
    local gdata = argsData
    for i=1,#ShouhuManager.Instance.model.my_sh_list do
        if gdata.base_id == ShouhuManager.Instance.model.my_sh_list[i].base_id then
            gdata = ShouhuManager.Instance.model.my_sh_list[i]
            break
        end
    end
    local res_id = gdata.res_id
    local animation_id = gdata.animation_id
    local paste_id = gdata.paste_id
    local wakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", gdata.base_id, gdata.quality)]
    if wakeUpCfgData ~= nil and wakeUpCfgData.model ~= 0 then
        res_id = wakeUpCfgData.model
        paste_id = wakeUpCfgData.skin
        animation_id = wakeUpCfgData.animation
    end

    self.memberCount = self.memberCount + 1
    local member = self.memberTab[self.memberCount]
    member["is_guard"] = true
    member["is_self"] = false
    member["info"] = gdata
    member["id"] = self.memberCount
    self:SetMemberInfo(member, {number = self.memberCount, name = gdata.name, classes = gdata.classes, lev = RoleManager.Instance.RoleData.lev})
    local modelData = {type = PreViewType.Shouhu, skinId = paste_id, modelId = res_id, animationId = animation_id, scale = 1}
    self:SetPriview(self.memberCount, modelData)
end

function TeamMemberPanel:SetMemberInfo(member, info)
    self:Default(member)
    local name = member["name_txt"]
    if member["is_self"] then
        name.text = string.format("<color='#8de92a'>%s</color>", info.name)
    else
        name.text = info.name
    end
    name.gameObject:SetActive(true)

    local classes_txt = member["classes_txt"]
    classes_txt.text = KvData.classes_name[info.classes]
    classes_txt.gameObject:SetActive(true)

    local classes_icon = member["classes_icon"]
    classes_icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(info.classes))
    classes_icon.gameObject:SetActive(true)

    local level_txt = member["level_txt"]
    level_txt.text = string.format(TI18N("%s级"), info.lev)
    level_txt.gameObject:SetActive(true)

    member["position_txt"].text = tostring(info.number)
    member["guard_obj"]:SetActive(member["is_guard"])
    if info.is_captin == true then
        member["captin"]:SetActive(true)
    else
        member["captin"]:SetActive(false)
    end

    if member.info.status == RoleEumn.TeamStatus.Offline then
        member["statusObj"]:SetActive(true)
        member["statusTxt"].text = TI18N("<color='#ff0000'>离线</color>")
    elseif member.info.status == RoleEumn.TeamStatus.Away then
        member["statusObj"]:SetActive(true)
        member["statusTxt"].text = TI18N("<color='#00ff12'>暂离</color>")
    else
        member["statusObj"]:SetActive(false)
        member["statusTxt"].text = ""
    end

    member["gameObject"]:SetActive(true)

    member["btn"].onClick:RemoveAllListeners()
    member["btn"].onHold:RemoveAllListeners()
    member["btn"].onDown:RemoveAllListeners()
    member["btn"].onUp:RemoveAllListeners()

    local id = member["id"]
    member["btn"].onClick:AddListener(function() self:ClickMember(id) end)
    member["btn"].onHold:AddListener(function() self:HoldMember(id) end)
    member["btn"].onDown:AddListener(function() self:DownMember(id) end)
    member["btn"].onUp:AddListener(function() self:UpMember(id) end)
end

function TeamMemberPanel:HoldMember(id)
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
    local member = self.memberTab[id]
    if member["is_guard"] and not self.inChangeMode then
        --点击守护打开守护切换的小面版
        self.currentSelectId = member["id"]
        self.mainPanel:OpenChangeGuard(BaseUtils.copytab(member))
    end
end

function TeamMemberPanel:DownMember(id)
    local func = function()
        if self.effect ~= nil then
            self.effect:SetActive(true)
            self.effect.transform.localPosition = self.effectPos[id]
        end
    end
    if self.effectTime ~= nil then
        LuaTimer.Delete(self.effectTime)
        self.effectTime = nil
    end
    self.effectTime = LuaTimer.Add(200, func)
end

function TeamMemberPanel:UpMember(id)
    if self.effectTime ~= nil then
        LuaTimer.Delete(self.effectTime)
        self.effectTime = nil
    end
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function TeamMemberPanel:ClickMember(id)
    local member = self.memberTab[id]
    if member["is_self"] then
        TeamManager.Instance:Notice(TI18N("这是你自己"))
        self:ExitChangeMode()
        self.mainPanel:ChangeButtonType("normal")
        self.currentSelectId = 0
    else
        if member["can_change"] then
            --进入了交互位置的状态，优先处理
            local currRoleInfo = member.info
            local tab = self.memberTab[self.currentSelectId]
            if self.memberTab == nil or self.memberTab[self.currentSelectId] == nil then
                return
            end
            local lastInfo = self.memberTab[self.currentSelectId].info
            -- 只有同类才能交换
            if tab["is_guard"] and member["is_guard"] then
                -- 守护换守护
                if lastInfo.base_id == currRoleInfo.base_id then
                    self:ExitChangeMode()
                else
                    if TeamManager.Instance:HasTeam() then
                        FormationManager.Instance:Send12904(lastInfo.base_id, currRoleInfo.base_id)
                    else
                        FormationManager.Instance:Send12905(lastInfo.base_id, 1, currRoleInfo.base_id)
                    end
                end
            elseif not tab["is_guard"] and not member["is_guard"] then
                -- 人换人
                FormationManager.Instance:Send12903(currRoleInfo.rid, currRoleInfo.platform, currRoleInfo.zone_id, lastInfo.rid, lastInfo.platform, lastInfo.zone_id)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("玩家和守护无法交换位置"))
                self:ExitChangeMode()
            end
            self.currentSelectId = 0
        else
            if member["id"] == self.currentSelectId then
                --重复点击为取消选中
                self:ExitChangeMode()
                self.mainPanel:ChangeButtonType("normal")
                self.currentSelectId = 0
            else
                self:ExitChangeMode()
                self.currentSelectId = member["id"]
                member["select"]:SetActive(true)
                if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None then
                    --队长才能进入交互位置模式, 玩家和守护不能交换位置
                    local is_guard = member["is_guard"]
                    for i,tab in ipairs(self.memberTab) do
                        if tab["id"] ~= self.currentSelectId and tab["id"] ~= 1 and tab["is_guard"] == is_guard then
                            tab["black"]:SetActive(true)
                            tab["can_change"] = true
                            self.inChangeMode = true
                        else
                            self.mainPanel:ChangeButtonType("normal")
                        end
                    end
                end
                if not member["is_guard"] then
                    self.mainPanel.buttonArea:SelectMember(member)
                    self.mainPanel:ChangeButtonType("option")
                end
            end
        end
    end
end

--退出交互模式
function TeamMemberPanel:ExitChangeMode()
    if self.memberTab == nil then
        self:OnClose()
        return
    end

    for i,tab in ipairs(self.memberTab) do
        tab["black"]:SetActive(false)
        tab["can_change"] = false
        tab["select"]:SetActive(false)
    end

    if self.inChangeMode then
        self.inChangeMode = false
        self.mainPanel:ChangeButtonType("normal")
    end
end

--更新阵法属性显示
function TeamMemberPanel:UpdateFormationAttr()
    if self.memberTab == nil then
        self:OnClose()
        return
    end

    local id = 1
    local lev = 1

    if TeamManager.Instance:HasTeam() then
        id = TeamManager.Instance.TypeData.team_formation
        lev = TeamManager.Instance.TypeData.team_formation_lev
    else
        id = FormationManager.Instance.formationId
        for i,v in ipairs(FormationManager.Instance.formationList) do
            if v.id == id then
                lev = v.lev
            end
        end
    end

    local attrs = {{}, {}, {}, {}, {}}
    local fdata = DataFormation.data_list[string.format("%s_%s", id, lev)]
    if fdata ~= nil then
        attrs = {fdata.attr_1, fdata.attr_2, fdata.attr_3, fdata.attr_4, fdata.attr_5}
    end

    for i,attr in ipairs(attrs) do
        local tab = self.memberTab[i]
        if #attr == 0 then
            tab["formation2"]:SetActive(false)
            tab["formation_txt2"].gameObject:SetActive(false)
            tab["formation_img2"].gameObject:SetActive(false)

            tab["formation1"]:SetActive(true)
            tab["formation_txt1"].gameObject:SetActive(true)
            tab["formation_img1"].gameObject:SetActive(false)

            tab["formation_txt1"].text = TI18N("无加成")
            tab["rect1"].anchoredPosition = Vector2(5, -52)
        elseif #attr == 1 then
            tab["formation1"]:SetActive(true)
            tab["formation2"]:SetActive(false)
            tab["formation_txt1"].gameObject:SetActive(true)
            tab["formation_img1"].gameObject:SetActive(true)
            tab["formation_txt2"].gameObject:SetActive(false)
            tab["formation_img2"].gameObject:SetActive(false)

            tab["formation_txt1"].text = KvData.attr_name_show[attr[1].attr_name]
            if attr[1].val > 0 then
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
            else
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
            end
            tab["rect1"].anchoredPosition = Vector2(0, -52)

        elseif #attr == 2 then
            tab["formation1"]:SetActive(true)
            tab["formation2"]:SetActive(true)
            tab["formation_txt1"].gameObject:SetActive(true)
            tab["formation_img1"].gameObject:SetActive(true)
            tab["formation_txt2"].gameObject:SetActive(true)
            tab["formation_img2"].gameObject:SetActive(true)

            tab["formation_txt1"].text = KvData.attr_name_show[attr[1].attr_name]
            tab["formation_txt2"].text = KvData.attr_name_show[attr[2].attr_name]
            if attr[1].val > 0 then
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
            else
                tab["formation_img1"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
            end
            tab["rect1"].anchoredPosition = Vector2(-28, -52)

            if attr[2].val > 0 then
                tab["formation_img2"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "GreenUp")
            else
                tab["formation_img2"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.teamres, "RedDown")
            end
            tab["rect2"].anchoredPosition = Vector2(31, -52)
        end
    end
end

-- 人物位置改变
function TeamMemberPanel:TeamPositionChange()
    -- 位置改变直接改坐标就好了，不需要刷刷数据,同时更新下对应关系
    local updateList = {}
    for pos,uniqueid in ipairs(TeamManager.Instance.memberOrderList) do
        local tab = self:GetOne(uniqueid)
        tab["id"] = pos

        tab["btn"].onClick:RemoveAllListeners()
        tab["btn"].onHold:RemoveAllListeners()
        tab["btn"].onDown:RemoveAllListeners()
        tab["btn"].onUp:RemoveAllListeners()

        tab["btn"].onClick:AddListener(function() self:ClickMember(pos) end)
        tab["btn"].onHold:AddListener(function() self:HoldMember(pos) end)
        tab["btn"].onDown:AddListener(function() self:DownMember(pos) end)
        tab["btn"].onUp:AddListener(function() self:UpMember(pos) end)
        table.insert(updateList, BaseUtils.copytab(tab))
    end
    for i,tab in ipairs(updateList) do
        self.memberTab[tab["id"]] = tab
        self:SetPosition(tab)
    end

    self:UpdateFormationAttr()

    if self.inChangeMode then
        self:ExitChangeMode()
    end
    self.mainPanel.buttonArea:ShowType("normal")
end

-- 守护位置变改
function TeamMemberPanel:GuardPositionChange()
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        --队长用守护补充队伍
        self.memberCount = #TeamManager.Instance:GetMemberOrderList()
        self:PutInTeamGuard()
    else
        self.memberCount = 1
        self:PutInGuard()
    end

    for i = self.memberCount + 1, 5 do
        self.memberTab[i]["gameObject"]:SetActive(false)
    end

    if self.inChangeMode then
        self:ExitChangeMode()
        self.mainPanel.buttonArea:ShowType("normal")
    end
end

function TeamMemberPanel:SetPosition(tab)
    tab["position_txt"].text = tostring(tab["id"])
    tab["rect"].anchoredPosition = self.posList[tab["id"]]
end

-- 只能根据这个id去取到准确的那个了，因为这时候，位置已经对不上了
function TeamMemberPanel:GetOne(uniqueid)
    for i,tab in ipairs(self.memberTab) do
        if tab.info ~= nil and tab.info["uniqueid"] == uniqueid then
            return tab
        end
    end
    return nil
end

function TeamMemberPanel:UpdateSome(list)
    for i,uniqueid in ipairs(list) do
        local teamData = TeamManager.Instance.memberTab[uniqueid]
        if teamData == nil then
            -- 要删除
            local tab = self:GetOne(uniqueid)
            tab["gameObject"]:SetActive(false)
            self:Default(tab)
        else
            -- 更新或新增
            local tab = self.memberTab[teamData.number]
            if uniqueid ==  TeamManager.Instance.selfUniqueid then
                member["is_self"] = true
            else
                member["is_self"] = false
            end
            member["is_guard"] = false
            member["info"] = teamData
            self:SetMemberInfo(member, {number = team.number, name = teamData.name, classes = teamData.classes, sex = teamData.sex, lev = teamData.lev, is_captin = (teamData.status == RoleEumn.TeamStatus.Leader)})
        end
    end

    for i,tab in ipairs(self.memberTab) do
        self:SetPosition(tab)
    end
end

function TeamMemberPanel:SetPriview(_id, modelData)
    local id = _id
    local callback = function(composite)
        if self.gameObject == nil then
            composite:DeleteMe()
            return
        end
        self.previewList[id] = composite
        self:SetRawImage(id)
    end
    local setting = {
        name = "TeamPreview1"
        ,orthographicSize = 0.5
        ,width = 130
        ,height = 200
        ,offsetY = -0.4
        ,noDrag = true
    }

    modelData.isTransform = true -- 这里需要显示人物变身效果
    -- if self.previewList[id] == nil then
    if self.initPreviewList[id] == nil then
        self.initPreviewList[id] = 1
        PreviewComposite.New(callback, setting, modelData)
    else
        if self.previewList[id] ~= nil then
            self.previewList[id]:Reload(modelData, callback)
        end
    end
end

function TeamMemberPanel:GetOneByNumber(id)
    for _,tab in pairs(self.memberTab) do
        if tab.id == id then
            return tab
        end
    end
end

function TeamMemberPanel:SetRawImage(id)
    local tab = self:GetOneByNumber(id)
    local composite = self.previewList[id]
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(tab.preview.transform)
    rawImage.transform.localPosition = Vector3.zero
    rawImage.transform.localScale = Vector3(1, 1, 1)
    if tab["is_guard"] then
        rawImage:GetComponent(RawImage).color = self.alpha
    else
        rawImage:GetComponent(RawImage).color = self.noalpha
    end
    tab.preview:SetActive(true)
end