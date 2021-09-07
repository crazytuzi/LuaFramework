-- @author 黄耀聪
-- @date 2016年10月22日

-- 动态投票面板

SwornInviteWindow = SwornInviteWindow or BaseClass(BaseWindow)

function SwornInviteWindow:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SwornInviteWindow"

    self.resList = {
        {file = AssetConfig.sworn_invite, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
    }

    self.timeFormat1 = TI18N("%s天%s小时\n后过期")
    self.timeFormat2 = TI18N("%s小时%s分\n后过期")
    self.timeFormat3 = TI18N("%s分%s秒\n后过期")
    self.timeFormat4 = TI18N("%s秒\n后过期")

    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornInviteWindow:__delete()
    self.OnHideEvent:Fire()
    if self.wrongExt ~= nil then
        self.wrongExt:DeleteMe()
        self.wrongExt = nil
    end
    if self.correctExt ~= nil then
        self.correctExt:DeleteMe()
        self.correctExt = nil
    end
    if self.unsureExt ~= nil then
        self.unsureExt:DeleteMe()
        self.unsureExt = nil
    end
    if self.targetExt ~= nil then
        self.targetExt:DeleteMe()
        self.targetExt = nil
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

function SwornInviteWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_invite))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.titleText = main:Find("Title"):GetComponent(Text)
    self.headImage = main:Find("Head/Image"):GetComponent(Image)
    self.nameText = main:Find("Name"):GetComponent(Text)
    self.timeText = main:Find("CountDown/Time"):GetComponent(Text)

    self.layout = LuaBoxLayout.New(main:Find("Status/Scroll/Container"), {axis = BoxLayoutAxis.Y, border = 2, cspacing = 5})
    self.layoutElement1 = self.layout.panel:Find("Title1").gameObject
    self.layoutElement2 = self.layout.panel:Find("Agree").gameObject
    self.layoutElement3 = self.layout.panel:Find("Title2").gameObject
    self.layoutElement4 = self.layout.panel:Find("Corrent").gameObject
    self.layoutElement5 = self.layout.panel:Find("Wrong").gameObject
    self.layoutElement6 = self.layout.panel:Find("Unsure").gameObject

    self.targetText = self.layoutElement1.transform:Find("Text"):GetComponent(Text)
    self.slider = self.layoutElement2.transform:Find("Slider"):GetComponent(Slider)
    self.sliderText = self.layoutElement2.transform:Find("Slider/Text"):GetComponent(Text)
    self.passConditionText = self.layoutElement2.transform:Find("PassCondition"):GetComponent(Text)
    self.correctExt = MsgItemExt.New(self.layoutElement4.transform:Find("Text"):GetComponent(Text), 295, 16, 18)
    self.wrongExt = MsgItemExt.New(self.layoutElement5.transform:Find("Text"):GetComponent(Text), 295, 16, 18)
    self.unsureExt = MsgItemExt.New(self.layoutElement6.transform:Find("Text"):GetComponent(Text), 295, 16, 18)
    self.targetExt = MsgItemExt.New(self.targetText, 324, 16, 18)

    self.disagreeBtn = main:Find("Disagree"):GetComponent(Button)
    self.agreeBtn = main:Find("Agree"):GetComponent(Button)

    self.disagreeBtn.onClick:AddListener(function() self:OnDisagree() end)
    self.agreeBtn.onClick:AddListener(function() self:OnAgree() end)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
end

function SwornInviteWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornInviteWindow:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.sworn_status_change, self.updateListener)
    self.data = self.openArgs

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
    end

    self:Reload()
end

function SwornInviteWindow:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function SwornInviteWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.sworn_status_change, self.updateListener)
end

function SwornInviteWindow:Reload()
    local data = self.data
    self.nameText.text = data.name

    local sender = nil
    for i,v in ipairs(self.model.swornData.members) do
        if data.t_id == v.m_id and data.t_platform == v.m_platform and data.t_zone_id == v.m_zone_id then
            sender = v
            self.headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, sender.classes .. "_" .. sender.sex)
            break
        end
    end

    local s = ""

    if data.type == SwornManager.Instance.trendType.Invite then
        s = string.format(TI18N("邀请新成员结拜:{role_1, %s, %s, %s, %s}"), tostring(data.t_r_id), tostring(data.t_r_platform), tostring(data.t_r_zone_id), tostring(data.r_name))
        self.titleText.text = TI18N("邀请投票")
    elseif data.type == SwornManager.Instance.trendType.Remove then
        s = string.format(TI18N("请离结拜成员:{role_1, %s, %s, %s, %s}, 原因:<color='#00ff00'>%s</color>"), tostring(data.t_r_id), tostring(data.t_r_platform), tostring(data.t_r_zone_id), tostring(data.r_name), data.reason_msg)
        self.titleText.text = TI18N("请离投票")
    elseif data.type == SwornManager.Instance.trendType.Rename then
        s = string.format(TI18N("新称号前缀:<color='#00ff00'>%s</color>"), data.rename)
        self.titleText.text = TI18N("称号投票")
    elseif data.type == SwornManager.Instance.trendType.Leave then
        s = TI18N("我要离开")
        self.titleText.text = TI18N("离开投票")
    end

    self.targetExt:SetData(s)

    self.layout:ReSet()
    for i=1,3 do
        self.layout:AddCell(self["layoutElement" .. i])
    end

    self:ReloadVote()
end

function SwornInviteWindow:ReloadVote()
    local correctTab = {}
    local wrongTab = {}
    local unsureTab = {}

    local voteTab = {}

    local num = self.model.swornData.num
    if num > 2 then
        num = math.ceil(num / 2)
    end
    self.passConditionText.text = string.format(TI18N("(%s人同意即通过)"), tostring(num))

    local data = self.data
    for i,v in ipairs(data.votes) do
        voteTab[BaseUtils.Key(v.platform, v.zone_id, v.rid)] = v
    end
    for _,v in ipairs(self.model.memberUidList) do
        local voteData = voteTab[v]
        if voteData == nil then
            table.insert(unsureTab, self.model.swornData.members[self.model.menberTab[v]].name)
        elseif voteData.flag == 1 then
            table.insert(correctTab, self.model.swornData.members[self.model.menberTab[v]].name)
        elseif voteData.flag == 0 then
            table.insert(wrongTab, self.model.swornData.members[self.model.menberTab[v]].name)
        end
    end

    local s = TI18N("<color='#00ff00'>已同意: </color>")
    if #correctTab > 0 then
        s = s .. string.format(TI18N("<color='#00ff00'>%s</color>"), correctTab[1])
        for i=2,#correctTab do
            s = s .. string.format(TI18N("、<color='#00ff00'>%s</color>"), correctTab[i])
        end
    end
    self.correctExt:SetData(s)
    self.layoutElement4.transform.sizeDelta = Vector2(323.8, self.correctExt.contentRect.sizeDelta.y)
    if #correctTab == 0 then
        self.layoutElement4.gameObject:SetActive(false)
    else
        self.layout:AddCell(self.layoutElement4.gameObject)
    end

    s = TI18N("<color='#ff8800'>不同意: </color>")
    if #wrongTab > 0 then
        s = s .. string.format(TI18N("%s"), wrongTab[1])
        for i=2,#wrongTab do
            s = s .. string.format(TI18N("、%s"), wrongTab[i])
        end
    end
    self.wrongExt:SetData(s)
    self.layoutElement5.transform.sizeDelta = Vector2(323.8, self.wrongExt.contentRect.sizeDelta.y)
    if #wrongTab == 0 then
        self.layoutElement5.gameObject:SetActive(false)
    else
        self.layout:AddCell(self.layoutElement5.gameObject)
    end

    s = TI18N("<color='#ffff00'>未投票: </color>")
    if #unsureTab > 0 then
        s = s .. string.format(TI18N("%s"), unsureTab[1])
        for i=2,#unsureTab do
            s = s .. string.format(TI18N("、%s"), unsureTab[i])
        end
    end
    self.unsureExt:SetData(s)
    self.layoutElement6.transform.sizeDelta = Vector2(323.8, self.unsureExt.contentRect.sizeDelta.y)
    if #unsureTab == 0 then
        self.layoutElement6.gameObject:SetActive(false)
    else
        self.layout:AddCell(self.layoutElement6.gameObject)
    end

    if num > 0 then
        self.slider.value = #correctTab / num
    else
        self.slider.value = 0
    end
    self.sliderText.text = string.format("%s/%s", tostring(#correctTab), tostring(num))
end

function SwornInviteWindow:Update()
    if self.data ~= nil then
        for _,v in pairs(self.model.swornData.trends) do
            if v.type == self.data.type and v.t_r_id == self.data.t_r_id and v.t_r_platform == self.data.t_r_platform and v.t_r_zone_id == self.data.t_r_zone_id then
                self.data = v
                self:Reload()
                break
            end
        end
    end
end

function SwornInviteWindow:OnAgree()
    local data = self.data

    SwornManager.Instance:send17716(data.type, data.t_r_id, data.t_r_platform, data.t_r_zone_id, 1)
    WindowManager.Instance:CloseWindow(self)
end

function SwornInviteWindow:OnDisagree()
    local data = self.data
    SwornManager.Instance:send17716(data.type, data.t_r_id, data.t_r_platform, data.t_r_zone_id, 0)
    WindowManager.Instance:CloseWindow(self)
end

function SwornInviteWindow:OnTick()
    if self.data == nil then
        return
    end
    local d = nil
    local h = nil
    local m = nil
    local s = nil
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

