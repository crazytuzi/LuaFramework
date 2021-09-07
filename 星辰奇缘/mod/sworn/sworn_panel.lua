-- @author 黄耀聪
-- @date 2016年10月22日

-- 绑定到师徒界面

SwornPanel = SwornPanel or BaseClass(BasePanel)

function SwornPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SwornPanel"

    self.resList = {
        {file = AssetConfig.sworn_panel, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
        {file = AssetConfig.zone_textures, type = AssetType.Dep},
        {file = AssetConfig.attr_icon,type = AssetType.Dep}
    }

    self.statusListener = function() self:ReloadStatus() self:ReloadTrend() end
    self.checkSwornRedListener = function()
        self:ShowNotifyPoint()
    end
    self.memberList = {}
    self.trendList = {}
    self.skillList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornPanel:__delete()
    self.OnHideEvent:Fire()
    if self.buttonListPanel ~= nil then
        self.buttonListPanel:DeleteMe()
        self.buttonListPanel = nil
    end
    if self.memberList ~= nil then
        for k,v in pairs(self.memberList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.memberList = nil
    end
    if self.trendList ~= nil then
        for _,v in pairs(self.trendList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.trendList = nil
    end
    if self.trendLayout ~= nil then
        self.trendLayout:DeleteMe()
        self.trendLayout = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local left = t:Find("LeftInfo")
    self.headImage = left:Find("Headbg/Head"):GetComponent(Image)
    self.headDefaultObj = left:Find("Headbg/Default").gameObject
    self.cameraBtn = left:Find("Headbg/CameraButton"):GetComponent(Button)
    -- self.nameText = left:Find("NamelevImage/NameText"):GetComponent(Text)
    self.honorText = left:Find("Honor"):GetComponent(Text)
    self.editBtn = left:Find("EditButton"):GetComponent(Button)
    self.scoreText = left:Find("List/Score/Score"):GetComponent(Text)
    self.memberText = left:Find("List/Member/Score"):GetComponent(Text)

    local skillContainer = left:Find("SkillScroll/Container")
    local childCount = skillContainer.childCount
    for i=1,childCount do
        local tab = {}
        tab.transform = skillContainer:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        if i ~= 3 then
            tab.slot = SkillSlot.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Bg"), tab.slot.gameObject)
        end
        tab.btn = tab.gameObject:GetComponent(Button)
        tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
        self.skillList[i] = tab
    end

    self.manageBtn = left:Find("Button"):GetComponent(Button)

    local right = t:Find("RightList")
    self.container = right:Find("ScrollPanel/Container")
    self.cloner = right:Find("ScrollPanel/Container/Item").gameObject
    self.nothing = right:Find("NoneImage").gameObject

    self.newsContainer = right:Find("InfoScroll/Container")
    self.voteBtnRedPoint = right:Find("InfoScroll/Cloner/Button/NotifyPoint").gameObject
    self.voteBtnRedPoint:SetActive(false)
    self.newsCloner = right:Find("InfoScroll/Cloner").gameObject
    self.arrowBtn = right:Find("Arrow"):GetComponent(Button)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 5})
    self.trendLayout = LuaBoxLayout.New(right:Find("InfoScroll/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.trendCloner = right:Find("InfoScroll/Cloner").gameObject
    self.treadNothing = right:Find("InfoScroll/NoneImage").gameObject

    self.tabbedPanel = TabbedPanel.New(self.trendLayout.panel.parent.gameObject, 0, 477)
    self.tabbedPanel.MoveEndEvent:Add(function(currentPage, direction) self.arrowBtn.enabled = true end)

    self.manageBtn.onClick:AddListener(function()
        -- TipsManager.Instance:ShowButton({gameObject = self.manageBtn.gameObject, data = btns})
        self:ShowButtonList()
    end)

    self.arrowBtn.onClick:AddListener(function() self:GoNextPage() end)
    self.editBtn.onClick:AddListener(function() self:OnEdit() end)
    self:ShowNotifyPoint()
end

function SwornPanel:ShowNotifyPoint()
    local state = SwornManager.Instance:CheckRedPointState()
    self.voteBtnRedPoint:SetActive(state)
end

function SwornPanel:ShowButtonList()
    local btns = {{label = TI18N("邀请新人"), callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_friend_choose) end}}

    if #self.model.memberUidList > 2 then
        table.insert(btns, {label = TI18N("请离结拜"), callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_getout) end})
    end

    local willLeave = false
    local roleData = RoleManager.Instance.RoleData
    for i,v in ipairs(self.model.swornData.trends) do
        if type == 4 then
            if roleData.id == v.t_r_id and roleData.platform == v.t_r_platform and roleData.zone_id == v.t_r_zone_id then
                willLeave = true
                break
            end
        end
    end
    if willLeave then
        table.insert(btns, {label = TI18N("取消退出"), callback = function() SwornManager.Instance:send17716(4, roleData.id, roleData.platform, roleData.zone_id, 0) end})
    else
        table.insert(btns, {label = TI18N("退出结拜"), callback = function() self:OnQuit() end})
    end

    if self.buttonListPanel == nil then
        self.buttonListPanel = ButtonListPanel.New(self)
    end
    self.buttonListPanel:Show({pos = Vector2(-265, 61), btnList = btns})
end

function SwornPanel:OnReqOut()
end

function SwornPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornPanel:CloseButtonList()
    if self.buttonListPanel ~= nil then
        self.buttonListPanel:DeleteMe()
        self.buttonListPanel = nil
    end
end

function SwornPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.statusListener)
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.checkSwornRedListener)
    self:ReloadInfo()
    self:ReloadStatus()
    self:ReloadTrend()
    self:ReloadSkill()

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    end

    self:CloseButtonList()
end

function SwornPanel:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function SwornPanel:OnTick()
    if self.trendList ~= nil then
        for _,v in pairs(self.trendList) do
            v:OnTick()
        end
    end
end

function SwornPanel:OnEdit()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_modify_window, {1})
end

function SwornPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.statusListener)
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.checkSwornRedListener)
end

function SwornPanel:ReloadStatus()
    local swornData = self.model.swornData or {}
    self.scoreText.text = tostring(swornData.sworn_val or 0)
    self.memberText.text = string.format("<color='%s'>%s</color>/10", ColorHelper.color[2], tostring(swornData.num or 0))

    self.layout:ReSet()
    local tab = swornData.members or {}

    for i,v in ipairs(tab) do
        if self.memberList[i] == nil then
            self.memberList[i] = SwornMemberItem.New(self.model, GameObject.Instantiate(self.cloner))
        end
        self.memberList[i]:SetData(v, i)
        self.layout:AddCell(self.memberList[i].gameObject)
        self.memberList[i].gameObject:SetActive(true)
    end
    for i=#tab + 1,#self.memberList do
        self.memberList[i].gameObject:SetActive(false)
    end

    self.nothing:SetActive(#tab == 0)

    self.cloner:SetActive(false)
end

function SwornPanel:ReloadInfo()
    local roleData = RoleManager.Instance.RoleData
    self.honorText.text = (self.model.swornData or {}).name or ""
    -- self.nameText.text = roleData.name
    self.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, roleData.classes .. "_" .. roleData.sex)
end

function SwornPanel:ReloadTrend()
    local trendData = (self.model.swornData or {}).trends or {}
    self.trendLayout:ReSet()
    for i,v in ipairs(trendData) do
        if self.trendList[i] == nil then
            local obj = GameObject.Instantiate(self.trendCloner)
            self.trendList[i] = SwornTrendItem.New(self.model, obj)
        end
        self.trendLayout:AddCell(self.trendList[i].gameObject)
        self.trendList[i]:SetData(v, i)
    end
    for i=#trendData + 1, #self.trendList do
        self.trendList[i].data = nil
        self.trendList[i].gameObject:SetActive(false)
    end
    self.trendCloner:SetActive(false)
    self.tabbedPanel:SetPageCount(#self.trendList)
    self.treadNothing:SetActive(#trendData == 0)
    self.arrowBtn.gameObject:SetActive(#trendData > 1)
end

function SwornPanel:GoNextPage()
    if self.tabbedPanel.currentPage < self.tabbedPanel.pageCount then
        self.arrowBtn.enabled = false
        self.tabbedPanel:TurnPage(self.tabbedPanel.currentPage + 1)
    else
        self.tabbedPanel:TurnPage(1)
    end
end

function SwornPanel:OnQuit()
    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("确定要退出<color='#00ff00'>%s</color>吗？\n（24小时内可取消，再考虑一下吧）"), self.model.swornData.name)
    confirmData.sureCallback = function() SwornManager.Instance:send17710(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, 5, "") end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function SwornPanel:ReloadSkill()
    local model = self.model
    for i,v in ipairs(self.skillList) do
        local data = model.skillData[i]
        if i ~= 3 then
            local skillData = DataSkill.data_skill_other[data.id]
            v.slot:SetAll(Skilltype.swornskill, skillData)
            v.nameText.text = skillData.name
            v.btn.onClick:RemoveAllListeners()
            local slot = v.slot
            v.btn.onClick:AddListener(function() slot.button.onClick:Invoke() end)
        else
            v.nameText.text = data.name
            v.btn.onClick:RemoveAllListeners()
            v.btn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = v.gameObject, skillData = data}) end)
        end
    end
end

SwornMemberItem = SwornMemberItem or BaseClass()

function SwornMemberItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    local t = gameObject.transform
    self.transform = t

    self.relationText = t:Find("RelationText"):GetComponent(Text)
    self.classIconImage = t:Find("ClassIcon"):GetComponent(Image)
    self.levText = t:Find("LevText"):GetComponent(Text)
    self.infoText = t:Find("InfoText"):GetComponent(Text)
    self.statusText = t:Find("StateText"):GetComponent(Text)
    self.headImage = t:Find("HeadImageBg/Image"):GetComponent(Image)
    self.bgImage = t:Find("ImageBg"):GetComponent(Image)

    self.editBtn = t:Find("EditButton"):GetComponent(Button)
    self.editBtn.onClick:AddListener(function() self:OnEdit() end)
end

function SwornMemberItem:SetData(data, index)
    if data == nil then
        return
    end
    self.index = index
    self.infoText.text = data.name
    self.classIconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. tostring(data.classes))
    self.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes .. "_" .. data.sex)
    self.levText.text = self.model.swornData.name .. "之" .. self.model.rankList[index] .. tostring(data.name_defined)
    self.relationText.text = self.model.nameTab[data.sex][self.model.myPos][index]
    if self.model.myPos == index then
        self.bgImage.color = Color(20/255,171/255,83/255)
        self.relationText.color = Color(34/255,173/255,98/255)
        self.relationText.text = TI18N("自己")
    else
        self.bgImage.color = Color(209/255,126/255,62/255)
        self.relationText.color = Color(202/255,96/255,13/255)
    end
    self.gameObject:SetActive(true)

    self.editBtn.gameObject:SetActive(index == self.model.myPos)
end

function SwornMemberItem:__delete()
    self.classIconImage.sprite = nil
    self.headImage.sprite = nil
end

function SwornMemberItem:OnEdit()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_modify_window, {2})
end

SwornTrendItem = SwornTrendItem or BaseClass()

function SwornTrendItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    local t = gameObject.transform
    self.transform = t

    self.descText = t:Find("Desc"):GetComponent(Text)
    self.timeText = t:Find("Clock/Time"):GetComponent(Text)
    self.button = t:Find("Button"):GetComponent(Button)
    self.btnImage = t:Find("Button"):GetComponent(Image)
    self.btnText = t:Find("Button/Text"):GetComponent(Text)
    self.redPoint = t:Find("Button/NotifyPoint").gameObject

    self.timeFormat1 = TI18N("%s天%s小时")
    self.timeFormat2 = TI18N("%s小时%s分")
    self.timeFormat3 = TI18N("%s分%s秒")
    self.timeFormat4 = TI18N("%s秒")

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function SwornTrendItem:SetData(data)
    self.data = data
    self.gameObject:SetActive(true)

    if data.type == SwornManager.Instance.trendType.Invite then
        self.descText.text = string.format(TI18N("<color='#2fc823'>%s</color>被<color='#2fc823'>%s</color>邀请加入结拜，正在投票中，表个态吧"), data.r_name, data.name)
        self.btnText.text = TI18N("前往投票")
    elseif data.type == SwornManager.Instance.trendType.Remove then
        self.descText.text = string.format(TI18N("<color='#2fc823'>%s</color>被<color='#2fc823'>%s</color>请离结拜，正在投票中，表个态吧"), data.r_name, data.name)
        self.btnText.text = TI18N("前往投票")
    elseif data.type == SwornManager.Instance.trendType.Rename then
        self.descText.text = string.format(TI18N("<color='#2fc823'>%s</color>修改结拜称号前缀为<color='#ffff00'>%s</color>，正在投票中，表个态吧"), data.r_name, data.rename)
        self.btnText.text = TI18N("前往投票")
    elseif data.type == SwornManager.Instance.trendType.Leave then
        local roleData = RoleManager.Instance.RoleData
        if roleData.id == data.t_r_id and roleData.platform == data.t_r_platform and roleData.zone_id == data.t_r_zone_id then
            self.descText.text = string.format(TI18N("我决定离开<color='#ffff00'>%s</color>结拜,24小时内还可取消，再考虑一下吧"), self.model.swornData.name)
            self.btnText.text = TI18N("取消退出")
        else
            self.descText.text = string.format(TI18N("<color='#2fc823'>%s</color>决定离开<color='#ffff00'>%s</color>结拜,24小时内还可劝阻，找TA聊聊吧"), data.r_name, self.model.swornData.name)
            self.btnText.text = TI18N("找TA聊聊")
        end
    end
end

function SwornTrendItem:OnClick()
    local data = self.data
    if data.type == SwornManager.Instance.trendType.Invite then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_invite_window, self.data)
    elseif data.type == SwornManager.Instance.trendType.Remove then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_invite_window, self.data)
    elseif data.type == SwornManager.Instance.trendType.Rename then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_invite_window, self.data)
    elseif data.type == SwornManager.Instance.trendType.Leave then
        local roleData = RoleManager.Instance.RoleData
        if roleData.id == data.t_r_id and roleData.platform == data.t_r_platform and roleData.zone_id == data.t_r_zone_id then
            SwornManager.Instance:send17716(4, roleData.id, roleData.platform, roleData.zone_id, 0)
        else
            local dat = {id = data.t_r_id, platform = data.t_r_platform, zone_id = data.t_r_zone_id, classes = data.r_classes, sex = data.r_sex, lev = data.r_lev, name = data.r_name}
            FriendManager.Instance:TalkToUnknowMan(dat)
        end
    end
end

function SwornTrendItem:__delete()
    self.btnImage.sprite = nil
end

function SwornTrendItem:OnTick()
    if self.data == nil then
        self.timeText.text = ""
        return
    end
    local d
    local h
    local m
    local s
    if self.data.timeout > BaseUtils.BASE_TIME then
        d,h,m,s = BaseUtils.time_gap_to_timer(self.data.timeout - BaseUtils.BASE_TIME)
        if d > 0 then
            self.timeText.text = string.format(self.timeFormat1, tostring(d), tostring(h))
        elseif h > 0 then
            self.timeText.text = string.format(self.timeFormat2, tostring(h), tostring(m))
        elseif m > 0 then
            self.timeText.text = string.format(self.timeFormat3, tostring(m), tostring(s))
        else
            self.timeText.text = string.format(self.timeFormat4, tostring(s))
        end
    else
        self.timeText.text = ""
    end
end

function SwornTrendItem:SetRed(bool)
    self.redPoint:SetActive(bool == true)
end
