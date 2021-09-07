Marry_InviteView = Marry_InviteView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_InviteView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_invite_window
    self.name = "Marry_InviteView"
    self.resList = {
        {file = AssetConfig.marry_invite_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }

    -----------------------------------------
    self.invitePanel = nil

    self.input_field = nil
    self.timeText = nil
    self.Button = nil
    self.toggle = nil

    self.maleHead = nil
    self.femaleHead = nil
    self.maleText = nil
    self.femaleText = nil

    self.PlayerItem_Invite = nil
    self.Layout_Invite = nil
    self.noFriends = nil

    self.time_text = nil
    self.time_count = 0
    self.timer_id = nil

    self.inviteCount = 0
    -----------------------------------------
    self.requestPanel = nil

    self.PlayerItem_Request = nil
    self.Layout_Request = nil

    -----------------------------------------
    self.currentIndex = 1

    self.oneKeyType = 1
    -----------------------------------------

    self._updateInvite = function() self:UpdateInvite() self:UpdateFriend_Invite() end
end

function Marry_InviteView:__delete()
    if self.timer_id ~= nil then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = nil
    end
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    EventMgr.Instance:RemoveListener(event_name.lover_data, self._updateInvite)
    self:ClearDepAsset()
end

function Marry_InviteView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_invite_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.invitePanel = self.transform:FindChild("Main/Invite_Panel").gameObject
    self.requestPanel = self.transform:FindChild("Main/Request_Panel").gameObject

    self.tabGroupObj = self.transform:FindChild("Main/TabButtonGroup")

    local tabGroupSetting = {
        notAutoSelect = true,
        perWidth = 62,
        perHeight = 118,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)

    self:InitInvite()
    self:InitRequest()

    EventMgr.Instance:AddListener(event_name.lover_data, self._updateInvite)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.currentIndex = self.openArgs[1]
    end
    self.tabGroup.noCheckRepeat = true
    self.tabGroup:ChangeTab(self.currentIndex)
    self.tabGroup.noCheckRepeat = false
end

function Marry_InviteView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_invite_window)
end

function Marry_InviteView:ChangeTab(index)
    if index == 1 then
        self.invitePanel:SetActive(true)
        self.requestPanel:SetActive(false)
        self:UpdateInvite()
        self.time_count = 120
        self.timer_id = LuaTimer.Add(0, 1000, function() self:timeUpdate() end)
    elseif index == 2 then
        self.invitePanel:SetActive(false)
        self.requestPanel:SetActive(true)
        self:UpdateRequest()
        if self.timer_id ~= nil then
            LuaTimer.Delete(self.timer_id)
            self.timer_id = nil
        end
    end
end

--------------------------------------------
--------------------------------------------
-- 邀请部分
--------------------------------------------
--------------------------------------------
function Marry_InviteView:InitInvite()
    self.maleHead = self.transform:FindChild("Main/Invite_Panel/Panel/MaleHead/Head"):GetComponent(Image)
    self.femaleHead = self.transform:FindChild("Main/Invite_Panel/Panel/FemaleHead/Head"):GetComponent(Image)

    self.maleText = self.transform:FindChild("Main/Invite_Panel/Panel/MaleText"):GetComponent(Text)
    self.femaleText = self.transform:FindChild("Main/Invite_Panel/Panel/FemaleText"):GetComponent(Text)

    self.timeText = self.transform:FindChild("Main/Invite_Panel/Panel/TimeText"):GetComponent(Text)

    self.input_field = self.transform:FindChild("Main/Invite_Panel/Panel/InputCon/InputField"):GetComponent(InputField)
    self.input_field.textComponent = self.input_field.gameObject.transform:FindChild("Text"):GetComponent(Text)
    self.input_field.lineType = InputField.LineType.MultiLineSubmit
    self.input_field.text = TI18N("我们结缘啦，诚邀你前来见证我们的幸福哦！")

    self.Button = self.transform:FindChild("Main/Invite_Panel/Panel/Button"):GetComponent(Button)
    self.Button.onClick:AddListener(function() self:ButtonClick() end)

    self.GuildButton = self.transform:FindChild("Main/Invite_Panel/Panel/GuildButton"):GetComponent(Button)
    self.GuildButton.onClick:AddListener(function() self:GuildButtonClick() end)

    self.transform:FindChild("Main/Invite_Panel/OnekeyButton"):GetComponent(Button).onClick:AddListener(function() self:OnekeyButtonClick() end)

    self.toggle = self.transform:FindChild("Main/Invite_Panel/Toggle"):GetComponent(Toggle)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/Invite_Panel/Mask")
    }
    self.Layout_Invite = LuaBoxLayout.New(self.transform:Find("Main/Invite_Panel/Mask/SoltPanel").gameObject, setting)

    self.PlayerItem_Invite = self.transform:Find("Main/Invite_Panel/PlayerItem").gameObject
    self.noFriends = self.transform:Find("Main/Invite_Panel/Mask/NoFriends").gameObject

    self.transform:Find("Main/Invite_Panel/Mask/NoFriends/Button"):GetComponent(Button).onClick:AddListener(function() FriendManager.Instance.model:OpenPushWindow() end)

    MarryManager.Instance:Send15014()
end

function Marry_InviteView:UpdateInvite()
    local roleData = RoleManager.Instance.RoleData
    local loverData = MarryManager.Instance.loverData
	if roleData.sex == 1 then
        self.maleHead.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_1", roleData.classes))
        self.maleText.text = roleData.name
        if loverData ~= nil then
            self.femaleHead.sprite =  self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_0", loverData.classes))
            self.femaleText.text = loverData.name
        end
    else
        self.femaleHead.sprite =  self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_0", roleData.classes))
        self.femaleText.text = roleData.name
        if loverData ~= nil then
            self.maleHead.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_1", loverData.classes))
            self.maleText.text = loverData.name
        end
    end

    self.timeText.text = string.format("%s:%s", os.date("%H"), os.date("%M"))

    self.toggle.isOn = false

    self.toggle.gameObject:SetActive(false)

    -- self:UpdateFriend_Invite()
end

function Marry_InviteView:UpdateFriend_Invite()
    if self.model.inside_List_Loading then return end

    self.list = {}
    local list = FriendManager.Instance:GetSortFriendList()
    local roledata = RoleManager.Instance.RoleData
    local serverId = BaseUtils.GetServerId(roledata)
    for _, value in pairs(list) do
        if value.online == 1 and serverId == BaseUtils.GetServerId(value) then
            self.list[BaseUtils.Key(value.id, value.platform, value.zone_id)] = value
        end
    end
    if GuildManager.Instance.model.guild_member_list ~= nil then
        for _, value in pairs(GuildManager.Instance.model.guild_member_list) do
            if value.Status == 1 and value.Post ~= 0 then
                self.list[BaseUtils.Key(value.Rid, value.PlatForm, value.ZoneId)]= {
                    id = value.Rid
                    , platform = value.PlatForm
                    , zone_id = value.ZoneId
                    , classes = value.Classes
                    , sex = value.Sex
                    , lev = value.Lev
                    , online = value.Status
                    , name = value.Name
                }
            end
        end
    end

    if self.list[BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id)] ~= nil then
        self.list[BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id)] = nil -- 删除配偶
    end
    if self.list[BaseUtils.Key(roledata.lover_id, roledata.lover_platform, roledata.lover_zone_id)] ~= nil then
        self.list[BaseUtils.Key(roledata.lover_id, roledata.lover_platform, roledata.lover_zone_id)] = nil -- 删除配偶
    end
    for _, value in pairs(self.model.inside_List) do
        self.list[BaseUtils.Key(value.id, value.platform, value.zone_id)] = nil
        -- print(string.format("在场景里面了 %s %s %s", value.id, value.platform, value.zone_id))
    end

    local parent = self.transform:Find("Main/Invite_Panel/Mask/SoltPanel").gameObject
    for k,v in pairs(self.list) do
        local uid = k
        local item = parent.transform:Find(uid)
        if item == nil then
            item = GameObject.Instantiate(self.PlayerItem_Invite)
        else
            item.gameObject:SetActive(false)
        end
        item.gameObject.name = uid

        self:SetPlayerItem_Invite(item, v)
        self.Layout_Invite:AddCell(item.gameObject)
    end

    self.Layout_Invite:ReSize()

    self.noFriends:SetActive(true)
    for k,v in pairs(self.list) do
        self.noFriends:SetActive(false)
        break
    end
end

function Marry_InviteView:timeUpdate()
    self.transform:FindChild("Main/Invite_Panel/Panel/Button/Text"):GetComponent(Text).text = string.format(TI18N("确定(%s)"), self.time_count)
    self.time_count = self.time_count - 1
    if self.time_count == 0 then
        self:ButtonClick()
    end
end

function Marry_InviteView:SetPlayerItem_Invite(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.classes, data.sex)
    -- if data.online == 1 then
    --     its:Find("Head"):GetComponent(Image).color = Color(1,1,1)
    --     -- BaseUtils.SetGrey(its:Find("Head"):GetComponent(Image), false)
    --     its:Find("name"):GetComponent(Text).color = Color(1,1,1)
    -- else
    --     -- BaseUtils.SetGrey(its:Find("Head"):GetComponent(Image), true)
    --     its:Find("Head"):GetComponent(Image).color = Color(0.5, 0.5, 0.5)
    --     its:Find("name"):GetComponent(Text).color = Color(0.5, 0.5, 0.5)
    -- end
    its:Find("LevText"):GetComponent(Text).text = tostring(data.lev)
    its:Find("ClassIcon"):GetComponent(Image).sprite = self:GetClassIcon(data.classes)
    its:Find("name"):GetComponent(Text).text = data.name

    local toggle = its:Find("Toggle"):GetComponent(Toggle)
    toggle.isOn = true
    toggle.onValueChanged:AddListener(function(on) self:ontogglechange(on) end)
end

function Marry_InviteView:ontogglechange(on)
    if on then
        self.inviteCount = self.inviteCount + 1
    else
        self.inviteCount = self.inviteCount - 1
    end
    -- print(self.inviteCount)
end

function Marry_InviteView:OnekeyButtonClick()
    local parent = self.transform:Find("Main/Invite_Panel/Mask/SoltPanel").gameObject

    if self.oneKeyType == 1 then
        local index = 0
        for k,v in pairs(self.list) do
            local uid = k
            local item = parent.transform:Find(uid)
            -- if item ~= nil and index <= 30 then
            if item ~= nil then
                item:Find("Toggle"):GetComponent(Toggle).isOn = true
                index = index + 1
            end
        end
        self.oneKeyType = 2
        self.transform:FindChild("Main/Invite_Panel/OnekeyButton/Text"):GetComponent(Text).text = TI18N("一键取消")
    else
        for k,v in pairs(self.list) do
            local uid = k
            local item = parent.transform:Find(uid)
            if item ~= nil then
                item:Find("Toggle"):GetComponent(Toggle).isOn = false
            end
        end
        self.oneKeyType = 1
        self.transform:FindChild("Main/Invite_Panel/OnekeyButton/Text"):GetComponent(Text).text = TI18N("一键全选")
    end
end

function Marry_InviteView:ButtonClick()
    local type = 1
    if self.toggle.isOn == false then type = 0 end
    local msg = self.input_field.text

    local list = {}
    local parent = self.transform:Find("Main/Invite_Panel/Mask/SoltPanel").gameObject
    for k,v in pairs(self.list) do
        local uid = k
        local item = parent.transform:Find(uid)
        if item ~= nil then
            if item:Find("Toggle"):GetComponent(Toggle).isOn then
                table.insert(list, { rid = v.id, platform = v.platform, zone_id = v.zone_id})
            end
        end
    end

    -- if #list > 30 then
    --     NoticeManager.Instance:FloatTipsByString("最多只能邀请30人")
    -- else
        MarryManager.Instance:Send15004(type, list, msg)
    -- end

    self:Close()
end

function Marry_InviteView:GuildButtonClick()
    MarryManager.Instance:Send15022()
    BaseUtils.SetGrey(self.GuildButton.gameObject:GetComponent(Image), true)
end

--------------------------------------------
--------------------------------------------
-- 申请部分
--------------------------------------------
--------------------------------------------
function Marry_InviteView:InitRequest()
    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("Main/Request_Panel/Mask")
    }
    self.Layout_Request = LuaBoxLayout.New(self.transform:Find("Main/Request_Panel/Mask/SoltPanel"), setting)

    self.PlayerItem_Request = self.transform:Find("Main/Request_Panel/PlayerItem").gameObject
end

function Marry_InviteView:UpdateRequest()
    local roleData = RoleManager.Instance.RoleData
    local loverData = MarryManager.Instance.loverData


    self:UpdateFriend_Request()
end

function Marry_InviteView:UpdateFriend_Request()
    self.list = {}
    for _, value in pairs(MarryManager.Instance.model.requestData) do
        self.list[BaseUtils.Key(value.id, value.platform, value.zone_id)] = value
    end

    local parent = self.transform:Find("Main/Request_Panel/Mask/SoltPanel").gameObject
    for k,v in pairs(self.list) do
        local uid = k
        local item = parent.transform:Find(uid)
        if item == nil then
            item = GameObject.Instantiate(self.PlayerItem_Request)
        else
            item.gameObject:SetActive(false)
        end
        item.gameObject.name = uid

        self:SetPlayerItem_Request(item, v)
        self.Layout_Request:AddCell(item.gameObject)
    end

    self.Layout_Request:ReSize()
end


function Marry_InviteView:SetPlayerItem_Request(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.classes, data.sex)
    -- if data.online == 1 then
    --     its:Find("Head"):GetComponent(Image).color = Color(1,1,1)
    --     its:Find("name"):GetComponent(Text).color = Color(1,1,1)
    -- else
    --     its:Find("Head"):GetComponent(Image).color = Color(0.5, 0.5, 0.5)
    --     its:Find("name"):GetComponent(Text).color = Color(0.5, 0.5, 0.5)
    -- end
    its:Find("LevText"):GetComponent(Text).text = tostring(data.lev)
    its:Find("ClassText"):GetComponent(Text).text = KvData.classes_name[data.classes]
    its:Find("name"):GetComponent(Text).text = data.name

    local okButton = its:Find("OkButton"):GetComponent(Button)
    okButton.onClick:AddListener(function() self:OkButtonClick(its, { rid = data.id, platform = data.platform, zone_id = data.zone_id}) end)

    local noButton = its:Find("NoButton"):GetComponent(Button)
    noButton.onClick:AddListener(function() self:NoButtonClick(its, { rid = data.id, platform = data.platform, zone_id = data.zone_id}) end)
end

function Marry_InviteView:OkButtonClick(its, data)
    its:Find("OkButton").gameObject:SetActive(false)
    its:Find("NoButton").gameObject:SetActive(false)
    its:Find("descText").gameObject:SetActive(true)
    its:Find("descText"):GetComponent(Text).text = TI18N("已同意")
    MarryManager.Instance:Send15005(1, {data})

    MarryManager.Instance.model.requestData[BaseUtils.Key(data.rid, data.platform, data.zone_id)] = nil
    EventMgr.Instance:Fire(event_name.marry_data_update)
end

function Marry_InviteView:NoButtonClick(its, data)
    its:Find("OkButton").gameObject:SetActive(false)
    its:Find("NoButton").gameObject:SetActive(false)
    its:Find("descText").gameObject:SetActive(true)
    its:Find("descText"):GetComponent(Text).text = TI18N("已拒绝")
    MarryManager.Instance:Send15005(2, {data})

    MarryManager.Instance.model.requestData[BaseUtils.Key(data.rid, data.platform, data.zone_id)] = nil
    EventMgr.Instance:Fire(event_name.marry_data_update)
end

-------------------------------------------
-------------------------------------------
-------------------------------------------
-------------------------------------------
function Marry_InviteView:GetClassIcon(classes)
    local sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(classes))
    return sprite
end

function Marry_InviteView:GetHead(classes, sex)
    local name = classes .. "_" .. sex
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    return sprite
end