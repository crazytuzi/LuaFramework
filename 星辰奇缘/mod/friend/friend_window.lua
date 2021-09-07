FriendWindow = FriendWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function FriendWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.friend
    self.name = "FriendWindow"
    self.currpage = nil
    self.cacheMode = CacheMode.Visible
    --self.winLinkType = WinLinkType.Link
    self.holdTime = 10
    self.friendType = FriendType.Local
    self.friendMgr = self.model.friendMgr
    self.groupMgr = FriendGroupManager.Instance
    self.resList = {
        {file = AssetConfig.friend_window, type = AssetType.Main}
        ,{file = AssetConfig.chat_window_res, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
        ,{file = AssetConfig.friendtexture, type = AssetType.Dep}
        --,{file = AssetConfig.no1inworld_textures, type = AssetType.Dep}
        -- ,{file = AssetConfig.basecompress_textures, type = AssetType.Dep}
    }
    self.showcrossgroup = false
    self.isshow = false
    self.newmomentUpdate = function()
        if not BaseUtils.isnull(self.newmomentRed) then
            self.newmomentRed:SetActive(ZoneManager.Instance.newmomentFlag)
        end
    end
end

function FriendWindow:__delete()
    if self.vScroll ~= nil then
        self.vScroll.onValueChanged:RemoveAllListeners()
    end
    self.LeftConGroup = nil
    self.RightConGroup = nil
    if self.clickitem ~= nil then
        self.clickitem.transform:Find("Select").gameObject:SetActive(false)
        self.clickitem = nil
        self.clickdata = nil
    end
    self.model.chatTarget = nil
    self.isshow = false
    self.setting_data = nil
    ZoneManager.Instance.OnNewMomentUpdate:RemoveListener(self.newmomentUpdate)
    for i=1,3 do
        if self["Layout"..i] ~= nil then
            self["Layout"..i]:DeleteMe()
            self["Layout"..i] = nil
        end
    end
    if self.item_list ~= nil then
        for _,v in pairs(self.item_list) do
            if v ~= nil then
                if v ~= self.help then
                    v:DeleteMe()
                else
                    --DestroyImmediate(v)
                end
            end
        end
        self.item_list = nil
    end
    if self.item_list2 ~= nil then
        for _,v in pairs(self.item_list2) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.item_list2 = nil
    end
    if self.currHeadList ~= nil then
        for _,v in pairs(self.currHeadList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.currHeadList = nil
    end
    if self.rLayout4 ~= nil then
        self.rLayout4:DeleteMe()
        self.rLayout4 = nil
    end
    if self.rLayout5 ~= nil then
        self.rLayout5:DeleteMe()
        self.rLayout5 = nil
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    if self.chatPanel ~= nil then
        self.chatPanel:DeleteMe()
        self.chatPanel = nil
    end
    if self.groupchatPanel ~= nil then
        self.groupchatPanel:DeleteMe()
        self.groupchatPanel = nil
    end
    if self.FriendGroupList ~= nil then
        self.FriendGroupList:DeleteMe()
        self.FriendGroupList = nil
    end
    if self.mailPanle ~= nil then
        self.mailPanle:DeleteMe()
        self.mailPanle = nil
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    self:ClearDepAsset()

end

function FriendWindow:InitPanel()
    self.isshow = true
    MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(25, false)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.friend_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.addFriendItem = self.transform:Find("MainCon/LeftCon/AddFriendItem").gameObject
    self.addFriendItem.transform.anchoredPosition = Vector2(0, 95.6)
    self.PlayerItem = self.transform:Find("MainCon/LeftCon/PlayerItem").gameObject
    self.MailItem = self.transform:Find("MainCon/LeftCon/MailItem").gameObject

    self.GroupButton = self.transform:Find("MainCon/LeftCon/GroupButton"):GetComponent(Button)
    self.GroupButtonText = self.transform:Find("MainCon/LeftCon/GroupButton/Text"):GetComponent(Text)
    self.TipsClose = self.transform:Find("MainCon/TipsClose").gameObject
    self.TipsClose:SetActive(false)
    self.TipsClose.transform:GetComponent(Button).onClick:AddListener(function()
        self.TipsClose:SetActive(false)
        self.GroupList:SetActive(false)
    end)
    self.GroupList = self.transform:Find("MainCon/SelectTips").gameObject
    self.GroupList.transform:Find("AllButton"):GetComponent(Button).onClick:AddListener(function()
        self.friendType = FriendType.All
        self:UpdateFriendList()
        self.GroupList:SetActive(false)
        self.TipsClose:SetActive(false)
    end)
    self.GroupList.transform:Find("LocalButton"):GetComponent(Button).onClick:AddListener(function()
        self.friendType = FriendType.Local
        self:UpdateFriendList()
        self.GroupList:SetActive(false)
        self.TipsClose:SetActive(false)
    end)
    self.GroupList.transform:Find("CrossButton"):GetComponent(Button).onClick:AddListener(function()
        self.friendType = FriendType.Cross
        self:UpdateFriendList()
        self.GroupList:SetActive(false)
        self.TipsClose:SetActive(false)
    end)
    self.GroupList.transform:Find("BlackButton"):GetComponent(Button).onClick:AddListener(function()
        self.friendType = FriendType.Black
        self:UpdateFriendList()
        self.GroupList:SetActive(false)
        self.TipsClose:SetActive(false)
    end)
    self.GroupButton.onClick:AddListener(function()
        self.TipsClose:SetActive(not self.GroupList.activeSelf)
        self.GroupList:SetActive(not self.GroupList.activeSelf)
    end)

    self.addFriendMsg = self.transform:Find("MainCon/RightCon/Panel4/AddFriendMsg").gameObject
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.LeftConGroup = {
        [1] = self.transform:Find("MainCon/LeftCon/Con1"),
        [2] = self.transform:Find("MainCon/LeftCon/Con2"),
        [3] = self.transform:Find("MainCon/LeftCon/Con3"),
        [4] = self.transform:Find("MainCon/LeftCon/Con4"),
    }
    -- local setting1 = {
    --     axis = BoxLayoutAxis.Y
    --     ,spacing = 5
    --     ,Left = 8.9
    --     ,Top = 4
    -- }
    local setting11 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.LeftConGroup[1]
    }
    local setting12 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.LeftConGroup[2]
    }
    local setting13 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.LeftConGroup[3]
    }
    local setting14 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.LeftConGroup[4]
    }
    self.Layout1 = LuaBoxLayout.New(self.LeftConGroup[1]:Find("Layout"), setting11)
    self.Layout2 = LuaBoxLayout.New(self.LeftConGroup[2]:Find("Layout"), setting12)
    self.Layout3 = LuaBoxLayout.New(self.LeftConGroup[3]:Find("Layout"), setting13)
    self.Layout4 = LuaBoxLayout.New(self.LeftConGroup[4]:Find("Layout"), setting14)

    self.RightConGroup = {
        [1] = self.transform:Find("MainCon/RightCon/Panel1"),
        [2] = self.transform:Find("MainCon/RightCon/Panel2"),
        [3] = self.transform:Find("MainCon/RightCon/Panel3"),
        [4] = self.transform:Find("MainCon/RightCon/Panel4"),
        [5] = self.transform:Find("MainCon/RightCon/Panel5"),
        [6] = self.transform:Find("MainCon/RightCon/Panel6"),
    }

    self.RightConGroup[2]:Find("InfoPanel").sizeDelta = Vector2(420,50)
    self.info_txt = self.RightConGroup[2]:Find("InfoPanel/Text"):GetComponent(Text)
    self.info_txt.transform.anchoredPosition = Vector2(12,0)
    self.info_txt.transform.sizeDelta = Vector2(375,40)
    -- self.info_txt.alignment = TextAnchor.MiddleLeft
    self.info_txt.text = TI18N("谨防陌生人以加群或加微信 QQ 为名的各种诈骗\n对方言行可疑请点击对方头像进行举报以免损失")


    self.unSelectText = self.RightConGroup[1]:Find("Con/Text"):GetComponent(Text)
    self.noFriend = self.LeftConGroup[2]:Find("NoFriend")
    self.noFriend:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:Close() self.model:OpenPushWindow() end)
    local setting2 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 8.9
        ,Top = 5
    }
    self.rLayout4 = LuaBoxLayout.New(self.RightConGroup[4]:Find("Con/Layout"), setting2)
    self.rLayout5 = LuaBoxLayout.New(self.RightConGroup[5]:Find("Con/Layout"), setting2)

    self.AddFriendButton = self.transform:Find("MainCon/AddFriendButton")
    self.ZoneButton = self.transform:Find("MainCon/HomeButton")
    self.AddBlackButton = self.transform:Find("MainCon/AddBlackButton")


    self.CloseButton = self.transform:Find("CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.AddFriendButton:GetComponent(Button).onClick:AddListener(function() self:Close() self.model:OpenPushWindow() end)
    self.ZoneButton:GetComponent(Button).onClick:AddListener(function() self:OnClickZoneBtn() end)
    self.AddBlackButton:GetComponent(Button).onClick:AddListener(function() self.model:OpenAddBlackPanel() end)
    -- self.TeacherButton:GetComponent(Button).onClick:AddListener(function() self:ShowTeacherWindow() end)

    self.RightConGroup[4]:Find("AddAllButton"):GetComponent(Button).onClick:AddListener(function() self:AcceptAll(true) end)
    self.RightConGroup[4]:Find("DeleteAllButton"):GetComponent(Button).onClick:AddListener(function() self:RefuseAll(true) end)

    self.RightConGroup[5]:Find("AddAllButton"):GetComponent(Button).onClick:AddListener(function() self:AcceptAll() end)
    self.RightConGroup[5]:Find("DeleteAllButton"):GetComponent(Button).onClick:AddListener(function() self:RefuseAll() end)
    self.chatPanel = FriendChatPanel.New(self)
    self.groupchatPanel = GroupChatPanel.New(self)
    self.mailPanle = MailPanel.New(self)
    self.FriendGroupList = FriendGroupList.New(self)

    self:InitTab()
    self.friendMgr.noReadMsg = 0
    self.friendMgr.noReadReq = 0
    MainUIManager.Instance.noticeView:set_friendnotice_num(0)
    MainUIManager.Instance.noticeView:set_chatnotice_num(0)
    self:InitFriendList()
    self:CheckoutRedPoint()
    -- if self.model.chatTarget ~= nil then
    --     self:SelectChatTarget()
    -- end

    self.newmomentRed = self.ZoneButton.transform:Find("Red").gameObject
    self.newmomentRed:SetActive(ZoneManager.Instance.newmomentFlag)
    ZoneManager.Instance.OnNewMomentUpdate:AddListener(self.newmomentUpdate)
    -- 更新跨服好友状态
    self:OnShow()
end

function FriendWindow:ShowTeacherWindow()
    if TeacherManager.Instance.model:IsHasTeahcerStudentRelationShip() == true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {})
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("您尚未加入师门，请先拜师或者收徒"))
    end
end

function FriendWindow:OnShow()
    MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(25, false)
    self:ChangeShow()
    self.isshow = true
    self.friendMgr.noReadMsg = 0
    self.friendMgr.noReadReq = 0
    MainUIManager.Instance.noticeView:set_friendnotice_num(0)
    MainUIManager.Instance.noticeView:set_chatnotice_num(0)
    self.newmomentRed = self.ZoneButton.transform:Find("Red").gameObject
    self.newmomentRed:SetActive(ZoneManager.Instance.newmomentFlag)
    local list = self.friendMgr:GetSortChatlist()
    if (list == nil or next(list) == nil) and self.openArgs == nil then
        self.tabgroup:ChangeTab(2)
    elseif self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    elseif self.model.chatTarget ~= nil or (list ~= nil or next(list) ~= nil) then
        self.tabgroup:ChangeTab(1)

    else
        self.tabgroup:ChangeTab(2)
    end
    if self.model.chatTarget ~= nil then
        self.tabgroup:ChangeTab(1)

        self:SelectChatTarget()
    end
    self:CheckoutRedPoint()
    if FriendManager.Instance.help ~= nil then
        self.tabgroup:ChangeTab(2)
        FriendManager.Instance.help = nil
    end

    self.transform:SetAsLastSibling()
end

function FriendWindow:OnHide()
    self.friendMgr.noReadMsg = 0
    self.friendMgr.noReadReq = 0
    MainUIManager.Instance.noticeView:set_friendnotice_num(0)
    MainUIManager.Instance.noticeView:set_chatnotice_num(0)
    if self.clickitem ~= nil then
        self.clickitem.transform:Find("Select").gameObject:SetActive(false)
        self.clickitem = nil
        self.clickdata = nil
    end
    if self.FriendGroupList.selectObj ~= nil then
        self.FriendGroupList.selectObj:SetActive(false)
        self.FriendGroupList.selectObj = nil
    end
    self.model.chatTarget = nil
    self.groupchatPanel.currChatTarget = nil
    self.isshow = false
end

function FriendWindow:Close()
    self.model:CloseMain()

end

function FriendWindow:InitTab()
    local go = self.transform:Find("MainCon/TabButtonGroup").gameObject
    self.tabbtngo = {}
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end, {noCheckRepeat = true})
    for i=1,4 do
        self.tabbtngo[i] = go.transform:GetChild(i-1)
    end
    local list = self.friendMgr:GetSortChatlist()
    if (list == nil or next(list) == nil) and self.openArgs == nil then
        self.tabgroup:ChangeTab(2)
    elseif self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    elseif self.model.chatTarget ~= nil or (list ~= nil or next(list) ~= nil) then
        self.tabgroup:ChangeTab(1)

    else
        self.tabgroup:ChangeTab(2)
    end
end

function FriendWindow:ChangeShow()
    if self.tabgroup == nil then
        return
    end
    if self.model.chatTarget ~= nil then
        self.tabgroup:ChangeTab(1)

        self:SelectChatTarget()
    elseif self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.tabgroup:ChangeTab(self.openArgs[1])
    end
end

function FriendWindow:OnTabChange(index)
    self.index = index
    if self.LeftConGroup == nil then
        return
    end
    -- self.model.chatTarget = nil
    -- local friendmsgNum = self.friendMgr:GetFriendMsgNum()
    -- local notfriendmsgNum = self.friendMgr:GetNotFriendMsgNum()
    if self.tabgroup ~= nil then
        self.tabgroup:ShowRed(index, false)
    end
    -- self.model.chatTarget = nil
    -- self.model.chatTargetInfo = {}
    self.groupchatPanel.currChatTarget = nil
    self.clickdata = nil
    if not BaseUtils.isnull(self.clickitem) then
        self.clickitem.transform:Find("Select").gameObject:SetActive(false)
        self.clickitem = nil
    end
    if not BaseUtils.isnull(self.FriendGroupList.selectObj) then
        self.FriendGroupList.selectObj:SetActive(false)
        self.FriendGroupList.selectObj = nil
    end
    for i = 1, 4 do
        self.LeftConGroup[i].gameObject:SetActive(false)
    end
    self.LeftConGroup[index].gameObject:SetActive(true)
    if index == 1 then
        self.addFriendItem:SetActive(false)
        self:UpdateCurrFriendList()
        self:CurrFriendOnline()
        self:SwitchRightGroup(1)
        self.unSelectText.text = TI18N("在左侧选择你要聊天的对象")
        self.AddBlackButton.gameObject:SetActive(false)
        self.AddFriendButton.gameObject:SetActive(true)
    elseif index == 2 then
        self.friendType = FriendType.Local
        self:UpdateFriendList()
        self:SwitchRightGroup(1)
    elseif index == 3 then
        self.FriendGroupList:UpdateGroupList()
        self:SwitchRightGroup(1)
        self.addFriendItem.transform.gameObject:SetActive(false)
        self.unSelectText.text = TI18N("在左侧选择你要聊天的群组")
        self.AddBlackButton.gameObject:SetActive(false)
        self.AddFriendButton.gameObject:SetActive(true)
    elseif index == 4 then
        self.addFriendItem:SetActive(false)
        
        if self.LeftConGroup[4]:Find("Layout").childCount == 0 then
            self.mailPanle:UpdateMailList()
        end
        if self.mailPanle.selectItem == nil then
            self.unSelectText.text = TI18N("在左侧选择你要查看的邮件")
            self:SwitchRightGroup(1)
        else
            self:SwitchRightGroup(3)
        end
        self.AddBlackButton.gameObject:SetActive(false)
        self.AddFriendButton.gameObject:SetActive(true)
    end
    self.GroupButton.gameObject:SetActive(index == 2)
    self.GroupList:SetActive(false)
end

function FriendWindow:SwitchRightGroup(index)
    for i = 1, 6 do
        self.RightConGroup[i].gameObject:SetActive(i==index)
    end
end

function FriendWindow:GetClassIcon(classes)
    local sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(classes))
    return sprite
end

function FriendWindow:GetHead(classes, sex)
    if classes == nil or sex == nil then
        return nil
    end
    local name = classes .. "_" .. sex
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    return sprite
end

function FriendWindow:InitFriendList()
    local list = self.friendMgr:GetSortFriendList()
    table.insert(list,1,{ishelp = true})

    self.item_list = {}

    self.item_con = self.LeftConGroup[2]:Find("Layout")

    self.single_item_height = self.PlayerItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.LeftConGroup[2]:GetComponent(RectTransform).sizeDelta.y
    for i=1,8 do
        local go = self.item_con:FindChild(tostring(i)).gameObject
        local item = FriendItem.New(go, self)
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
    self.vScroll = self.LeftConGroup[2]:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)

    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
    --if #list <= 0 then
        --self.noFriend.gameObject:SetActive(true)
   -- else
      --  self.noFriend.gameObject:SetActive(false)
   -- end
    -- self:InitCrossFriendList()
end

function FriendWindow:UpdateFriendList()
    local list = self.friendMgr:GetSortFriendList(self.friendType)
    if self.friendType ~= FriendType.Black then 
        table.insert(list,1,{ishelp = true})
    end
    local parent = self.LeftConGroup[2]:Find("Layout").gameObject
    self:CheckoutRequest()
    --if #list <= 0 then
        --self.noFriend.gameObject:SetActive(true)
    --else
        --self.noFriend.gameObject:SetActive(false)
    --end

    if self.setting_data == nil then
        return
    end
    for k,v in pairs(self.item_list) do
        v.gameObject:SetActive(true)
    end
    local changetype = math.abs(#list - #self.setting_data.data_list) > 1
    self.setting_data.data_list = list
    if changetype then
        BaseUtils.refresh_circular_list(self.setting_data)
    else
        BaseUtils.static_refresh_circular_list(self.setting_data)
    end
    if self.friendType == FriendType.All then
        self.GroupButtonText.text = string.format(TI18N("全部好友（%s/%s）"), tostring(#list), tostring(self.friendMgr.max_num))
        self.unSelectText.text = TI18N("在左侧选择你要聊天的对象")
        self.AddBlackButton.gameObject:SetActive(false)
        self.AddFriendButton.gameObject:SetActive(true)
    elseif self.friendType == FriendType.Local then
        self.GroupButtonText.text = string.format(TI18N("本服好友（%s/%s）"), tostring(#list), tostring(self.friendMgr.max_num-self.friendMgr.max_mix_num))
        self.unSelectText.text = TI18N("在左侧选择你要聊天的对象")
        self.AddBlackButton.gameObject:SetActive(false)
        self.AddFriendButton.gameObject:SetActive(true)
    elseif self.friendType == FriendType.Cross then
        self.GroupButtonText.text = string.format(TI18N("跨服好友（%s/%s）"), tostring(#list), tostring(self.friendMgr.max_mix_num))
        self.unSelectText.text = TI18N("在左侧选择你要聊天的对象")
        self.AddBlackButton.gameObject:SetActive(false)
        self.AddFriendButton.gameObject:SetActive(true)
    elseif self.friendType == FriendType.Black then 
        self.GroupButtonText.text = string.format(TI18N("黑名单（%s）"), tostring(#list))
        self.unSelectText.text = TI18N("点击左侧玩家可进行管理")
        self.AddBlackButton.gameObject:SetActive(true)
        self.AddFriendButton.gameObject:SetActive(false)
    end
    -- self:UpdateCrossFriendList()
end

function FriendWindow:UpdateCurrFriendList()
    if self.LeftConGroup == nil then
        return
    end
    local list = self.friendMgr:GetSortChatlist()
    local parent = self.LeftConGroup[1]:Find("Layout").gameObject
    self.Layout1:ReSet()

    for i=1,parent.transform.childCount do
        parent.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    self.currHeadList = self.currHeadList or {}
    for i,v in ipairs(list) do
        local isgroup = v.owner_rid ~= nil
        local gdata = nil
        if isgroup then
            gdata = FriendGroupManager.Instance:GetGroupData(v.group_id, v.owner_platform, v.group_zone_id)
            BaseUtils.dump(gdata)
        end
        if v.id ~= 0 and (not isgroup or gdata ~= nil) then
            local k = BaseUtils.Key(v.id, v.platform, v.zone_id)
            if v.owner_rid ~= nil then
                k = BaseUtils.Key("_G", v.group_id, v.group_platform, v.group_zone_id)
            end
            local item = parent.transform:Find(k)
            if item == nil then
                item = GameObject.Instantiate(self.PlayerItem)
            else
                item.gameObject:SetActive(false)
            end
            item.gameObject.name = k
            local flag = (self.friendMgr.currHasMsg[k] ~= nil or self.groupMgr.currHasMsg[k] ~= nil) and (not (self.clickitem ~= nil and self.clickitem.gameObject.name == k) or self.isshow == false)
            if flag == false then
                if self.friendMgr.currHasMsg[k] ~= nil then
                    self.friendMgr.currHasMsg[k] = nil
                end
                if self.groupMgr.currHasMsg[k] ~= nil then
                    self.groupMgr.currHasMsg[k] = nil
                end
            end
            item.transform:Find("Red").gameObject:SetActive(flag)
            if v.owner_rid == nil then
                item.transform:Find("Red/Text"):GetComponent(Text).text = tostring(self.friendMgr.currHasMsg[k])
            else
                item.transform:Find("Red/Text"):GetComponent(Text).text = tostring(self.groupMgr.currHasMsg[k])
            end
            if self.friendMgr.friend_List[k] ~= nil then
                v.online = self.friendMgr.friend_List[k].online
            end
            local headdata = {id = v.id, platform = v.platform, zone_id = v.zone_id, classes = v.classes, sex = v.sex}, {isSmall = true}
            if v.owner_rid == nil then
                self:SetPlayerItem(item, v)

            else
                headdata = {id = v.owner_id, platform = v.owner_platform, zone_id = v.owner_zone_id, classes = v.owner_classes, sex = v.owner_sex}, {isSmall = true}
                self:SetGroupItem(item, v)
            end
            self.Layout1:AddCell(item.gameObject)
            if self.currHeadList[i] == nil then
                self.currHeadList[i] = HeadSlot.New()
            end
            self.currHeadList[i].gameObject:SetActive(true)
            self.currHeadList[i]:SetRectParent(item.transform:Find("Headbg"))
            self.currHeadList[i]:SetAll(headdata)
            item.transform:Find("Head").gameObject:SetActive(false)
        else
            if self.currHeadList[i] ~= nil then
                self.currHeadList[i].gameObject:SetActive(false)
            end
        end
    end
end


function FriendWindow:SetPlayerItem(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.classes, data.sex)
    if data.online ~= 0 then
        its:Find("Head"):GetComponent(Image).color = Color(1,1,1)
        -- BaseUtils.SetGrey(its:Find("Head"):GetComponent(Image), false)
        its:Find("name"):GetComponent(Text).color = Color(49/255, 102/255, 173/255)
    else
        -- BaseUtils.SetGrey(its:Find("Head"):GetComponent(Image), true)
        its:Find("Head"):GetComponent(Image).color = Color(0.5, 0.5, 0.5)
        its:Find("name"):GetComponent(Text).color = Color(0.5, 0.5, 0.5)
    end
    local teachermodel = TeacherManager.Instance.model
    local isteacher, teacher_status = teachermodel:IsMyTeacher(data)
    its:Find("label").gameObject:SetActive(isteacher and teacher_status == 1)
    its:Find("LevText"):GetComponent(Text).text = tostring(data.lev)
    its:Find("ClassIcon"):GetComponent(Image).sprite = self:GetClassIcon(data.classes)
    local nameTxt = its:Find("name"):GetComponent(Text)
    nameTxt.text = data.name

    its:Find("name/Mobile").gameObject:SetActive(data.offline_push == 1)
    local nameRect = its:Find("name"):GetComponent(RectTransform)
    nameRect.sizeDelta = Vector2(nameTxt.preferredWidth + 10, 30)

    its:Find("SigText"):GetComponent(Text).text = TI18N("无")
    if data.signature ~= "" then
        its:Find("SigText"):GetComponent(Text).text = data.signature
    end
    its:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("Button"):GetComponent(Button).onClick:AddListener(function() 
        if self.index == 2 and  data.type == 1 then 
            self:CancleBlackFriend(data)
        else
            TipsManager.Instance:ShowPlayer(data) 
        end
    end)
    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener(function() 
        if self.index == 2 and data.type == 1 then 
            self:CancleBlackFriend(data)
        else
            self:OnClickPlayer(item, data) 
        end
    end)
    -- if self.clickdata == data then
    --     item.transform:Find("Select").gameObject:SetActive(true)
    -- else
        item.transform:Find("Select").gameObject:SetActive(self.clickdata ~= nil and self.clickdata.id == data.id and self.clickdata.platform == data.platform and self.clickdata.zone_id == data.zone_id)
    -- end
    -- if self.clickitem == nil then
    --     self:OnClickPlayer(item, data)
    -- end
    its:Find("Mix").gameObject:SetActive(BaseUtils.IsTheSamePlatform(data.platform, data.zone_id) == false)
    local Frame = its:Find("Frame"):GetComponent(Image)
    local frameid = nil
    if data.looks == nil then
        data.looks = {}
    end
    for k,v in pairs(data.looks) do
        if v.looks_type == SceneConstData.looktype_role_frame then
            frameid = v.looks_val
            break
        end
    end
    if frameid ~= nil then
        Frame.sprite = PreloadManager.Instance:GetSprite(AssetConfig.rolelev_frame, tostring(frameid))
        Frame.gameObject:SetActive(true)
    else
        Frame.gameObject:SetActive(false)
    end
end


function FriendWindow:SetGroupItem(item, data)
    local its = item.transform
    local newdata = FriendGroupManager.Instance:GetGroupData(data.group_id, data.owner_platform, data.group_zone_id)
    if newdata == nil then
        return false
    end
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(newdata.owner_classes, newdata.owner_sex)
    its:Find("Head"):GetComponent(Image).color = Color(1,1,1)
    its:Find("name"):GetComponent(Text).color = Color(49/255, 102/255, 173/255)

    its:Find("label").gameObject:SetActive(false)
    its:Find("LevText"):GetComponent(Text).text = tostring(newdata.owner_lev)
    -- its:Find("LevText").gameObject:SetActive(false)
    -- its:Find("levbg").gameObject:SetActive(false)
    its:Find("group").gameObject:SetActive(true)
    its:Find("ClassIcon").gameObject:SetActive(false)
    -- its:Find("ClassIcon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "PlayerTips_friendicon")
    its:Find("name"):GetComponent(Text).text = newdata.name
    its:Find("name").anchoredPosition3D = Vector3(-70, 14, 0)
    its:Find("SigText"):GetComponent(Text).text = TI18N("无")
    if newdata.signature ~= "" then
        its:Find("SigText"):GetComponent(Text).text = newdata.content
    end
    its:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("Button"):GetComponent(Button).onClick:AddListener(function() FriendGroupManager.Instance.model:OpenInfoPanel({newdata.group_id, newdata.owner_platform, newdata.group_zone_id }) end)
    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener(function()
        self.clickdata = data
        self:SwitchRightGroup(6)
        self.groupchatPanel:SetTarget(newdata)
        its.transform:Find("Red").gameObject:SetActive(false)
        -- self.Red:SetActive(false)
        FriendManager.Instance.model:CheckRedPoint()
        if BaseUtils.isnull(self.clickitem) then
            self.clickitem = item
        else
            self.clickitem.transform:Find("Select").gameObject:SetActive(false)
            self.clickitem = item
        end
        self.clickitem.transform:Find("Select").gameObject:SetActive(true)
        self:CheckoutRedPoint()
    end)
    item.transform:Find("Select").gameObject:SetActive(self.clickdata ~= nil and (self.clickdata.owner_rid == newdata.owner_rid and self.clickdata.owner_platform == newdata.owner_platform and self.clickdata.owner_zone_id == newdata.owner_zone_id))
    its:Find("Mix").gameObject:SetActive(false)
    return true
end

function FriendWindow:DeltePlayeritem(uid)
    local item = self.LeftConGroup[2]:Find("Layout"):Find(uid)
    if item ~= nil then
        GameObject.DestroyImmediate(item.gameObject)
    end
end

function FriendWindow:OnClickPlayer(item, data)
    local uid = BaseUtils.Key(data.id, data.platform, data.zone_id)
    if BaseUtils.isnull(self.clickitem) then
        self.clickitem = item
    else
        self.clickitem.transform:Find("Select").gameObject:SetActive(false)
        self.clickitem = item
    end
    self.clickitem.transform:Find("Select").gameObject:SetActive(true)
    self.clickdata = data
    self.chatPanel:SetTarget(data)
    self.friendMgr.currHasMsg[uid] = nil
    item.transform:Find("Red").gameObject:SetActive(false)
    self:SwitchRightGroup(2)
    self:CheckoutRedPoint()
    if self.model.isAutoSend then
        self.chatPanel:AutoSend(self.model.isAutoSend)
        self.model.isAutoSend = nil
    end
end

-- 检查好友请求
function FriendWindow:CheckoutRequest()
    -- local curraddFriendItem = self.LeftConGroup[2]:Find("addFriendItem")
    local curraddFriendItem = self.addFriendItem.transform
    if next(self.friendMgr.request_List) ~= nil then

        if curraddFriendItem == nil and self.friendMgr:GetReqNum() > 0 then
            curraddFriendItem = GameObject.Instantiate(self.addFriendItem)
            curraddFriendItem.gameObject.name = "addFriendItem"
            curraddFriendItem.transform:Find("num"):GetComponent(Text).text = tostring(self.friendMgr:GetReqNum())
            curraddFriendItem.transform:GetComponent(Button).onClick:RemoveAllListeners()
            curraddFriendItem.transform:GetComponent(Button).onClick:AddListener(function() self:ShowRequest() end)
            curraddFriendItem.gameObject:SetActive(true)
            self.LeftConGroup[2].anchoredPosition = Vector2(0, -109.4)
            -- self.Layout2:AddCell(curraddFriendItem.gameObject)
            -- curraddFriendItem.transform:SetAsFirstSibling()
            -- self.Layout2:ReSize()
        elseif self.friendMgr:GetReqNum() > 0 then
            curraddFriendItem.gameObject:SetActive(true)
            self.LeftConGroup[2].anchoredPosition = Vector2(0, -109.4)
            curraddFriendItem.transform:Find("num"):GetComponent(Text).text = tostring(self.friendMgr:GetReqNum())
            curraddFriendItem.transform:GetComponent(Button).onClick:RemoveAllListeners()
            curraddFriendItem.transform:GetComponent(Button).onClick:AddListener(function() self:ShowRequest() end)
            -- self.Layout2:AddCell(curraddFriendItem.gameObject)
            -- curraddFriendItem.transform:SetAsFirstSibling()
            -- self.Layout2:ReSize()
        elseif curraddFriendItem ~= nil then
            self.LeftConGroup[2].anchoredPosition = Vector2(0, -39.4)
            -- GameObject.DestroyImmediate(curraddFriendItem.gameObject)
            curraddFriendItem.gameObject:SetActive(false)
        end
    else
        if curraddFriendItem ~= nil then
            curraddFriendItem.gameObject:SetActive(false)
            self.LeftConGroup[2].anchoredPosition = Vector2(0, -39.4)
            -- GameObject.DestroyImmediate(curraddFriendItem.gameObject)
            -- self.Layout2:ReSize()
        end
    end
    if self.LeftConGroup[2].gameObject.activeSelf == false then
        curraddFriendItem.gameObject:SetActive(false)
    end
    -- self:CheckoutRedPoint()
end

function FriendWindow:ShowRequest()
    -- self:ClearReq()
    local list = self.friendMgr:GetReqList()
    local parent = self.RightConGroup[4]:Find("Con/Layout").gameObject
    self.rLayout4:ReSet()

    self.currHeadList = self.currHeadList or {}

        for k,v in pairs(list) do
            local item = parent.transform:Find(tostring(k))
            if item == nil then
                item = GameObject.Instantiate(self.addFriendMsg)
            else
                item.gameObject:SetActive(false)
            end
            item.gameObject.name = k
            if self.currHeadList[k] == nil then
                self.currHeadList[k] = HeadSlot.New()
            end
            self.currHeadList[k]:SetActive(true)
            self.currHeadList[k]:SetRectParent(item.transform:Find("Headbg"))
            self.currHeadList[k]:HideSlotBg(false, 0.035)
            self.currHeadList[k]:SetAll({id = v.id, platform = v.platform, zone_id = v.zone_id, classes = v.classes, sex = v.sex}, {isSmall = true, clickCallback = function() TipsManager.Instance:ShowPlayer(v) end})
            -- BaseUtils.dump(v)
            self:SetFriendReqItem(item.gameObject, v)
            item.transform:Find("Head"):GetComponent(Image).enabled = false
            item.transform:Find("Headbg"):GetComponent(Image).enabled = false
            self.rLayout4:AddCell(item.gameObject)
        end
    self:SwitchRightGroup(4)
    FriendManager.Instance.hasShow = true
end

function FriendWindow:SetFriendReqItem(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.classes, data.sex)
    its:Find("LevText"):GetComponent(Text).text = tostring(data.lev)
    its:Find("LevText").anchoredPosition = Vector2(-157, 1)
    its:Find("levbg").anchoredPosition = Vector2(-155, 1)
    its:Find("levbg").sizeDelta = Vector2(30, 20)
    its:Find("name"):GetComponent(Text).text = data.name
    its:Find("NoButton"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("NoButton"):GetComponent(Button).onClick:AddListener(function() if self.friendMgr:Require11805(0, data.name, data.id, data.platform, data.zone_id) then self:OnClickReq(item) end end)
    its:Find("YesButton"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("YesButton"):GetComponent(Button).onClick:AddListener(function() if self.friendMgr:Require11805(1, data.name, data.id, data.platform, data.zone_id) then self:OnClickReq(item) end end)
end

-- 群组邀请
function FriendWindow:ShowGroupRequest()
    local list = self.groupMgr:GetReqList()
    local parent = self.RightConGroup[5]:Find("Con/Layout").gameObject
    self.rLayout5:ReSet()

    self.currHeadList = self.currHeadList or {}
    for k,v in pairs(list) do
        local Key = BaseUtils.Key(tostring(v.time), v.role_rid, v.group_rid)
        local item = parent.transform:Find(tostring(Key))
        if item == nil then
            item = GameObject.Instantiate(self.addFriendMsg)
        else
            item.gameObject:SetActive(false)
        end
        item.gameObject.name = Key
        if self.currHeadList[Key] == nil then
            self.currHeadList[Key] = HeadSlot.New()
        end
        self.currHeadList[Key]:SetActive(true)
        self.currHeadList[Key]:SetRectParent(item.transform:Find("Headbg"))
        self.currHeadList[Key]:HideSlotBg(false, 0.035)
        local tipsdata = {id = v.role_rid, platform = v.role_platform, zone_id = v.role_zone_id, classes = v.role_classes, sex = v.role_sex}
        self.currHeadList[Key]:SetAll({id = v.role_rid, platform = v.role_platform, zone_id = v.role_zone_id, classes = v.role_classes, sex = v.role_sex}, {isSmall = true, clickCallback = function() TipsManager.Instance:ShowPlayer(tipsdata) end})
        -- BaseUtils.dump(v)
        self:SetGroupReqItem(item.gameObject, v)
        item.transform:Find("Head"):GetComponent(Image).enabled = false
        item.transform:Find("Headbg"):GetComponent(Image).enabled = false
        self.rLayout5:AddCell(item.gameObject)
    end
    self:SwitchRightGroup(5)
end

function FriendWindow:SetGroupReqItem(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.role_classes, data.role_sex)
    its:Find("LevText"):GetComponent(Text).text = tostring(data.role_lev)
    its:Find("LevText").anchoredPosition = Vector2(-157, 1)
    its:Find("levbg").anchoredPosition = Vector2(-155, 1)
    its:Find("levbg").sizeDelta = Vector2(30, 20)
    its:Find("name"):GetComponent(Text).text = data.role_name
    BaseUtils.dump(data)
    if data.isapply then
        its:Find("Text"):GetComponent(Text).text = string.format(TI18N("请求加入<color='#b031d5'>%s</color>群组"), tostring(data.group_name))
    else
        its:Find("Text"):GetComponent(Text).text = string.format(TI18N("来<color='#b031d5'>%s</color>一起聊天吧"), tostring(data.group_name))
    end
    local clickend = function(itemobj)
        local key = itemobj.gameObject.name
        if self.currHeadList[key] ~= nil then
            self.currHeadList[key]:DeleteMe()
            self.currHeadList[key] = nil
        end
        GameObject.DestroyImmediate(itemobj.gameObject)
        self.rLayout5:ReSize()
        self:CheckoutRedPoint()
    end
    its:Find("NoButton"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("YesButton"):GetComponent(Button).onClick:RemoveAllListeners()
    if data.isapply then
        its:Find("NoButton"):GetComponent(Button).onClick:AddListener(function() if self.groupMgr:Require19014(data.group_rid, data.group_platform, data.group_zone_id, data.role_rid, data.role_platform, data.role_zone_id, 0) then clickend(item) end end)
        its:Find("YesButton"):GetComponent(Button).onClick:AddListener(function() if self.groupMgr:Require19014(data.group_rid, data.group_platform, data.group_zone_id, data.role_rid, data.role_platform, data.role_zone_id, 1) then clickend(item) end end)
    else
        its:Find("NoButton"):GetComponent(Button).onClick:AddListener(function() if self.groupMgr:Require19010(data.group_rid, data.group_platform, data.group_zone_id, data.role_rid, data.role_platform, data.role_zone_id, 0) then clickend(item) end end)
        its:Find("YesButton"):GetComponent(Button).onClick:AddListener(function() if self.groupMgr:Require19010(data.group_rid, data.group_platform, data.group_zone_id, data.role_rid, data.role_platform, data.role_zone_id, 1) then clickend(item) end end)
    end
end

function FriendWindow:OnClickReq(item)
    local key = item.gameObject.name
    if self.currHeadList[key] ~= nil then
        self.currHeadList[key]:DeleteMe()
        self.currHeadList[key] = nil
    end
    GameObject.DestroyImmediate(item.gameObject)
    self.rLayout4:ReSize()
end

function FriendWindow:CheckoutRedPoint()
    local reqnum = self.friendMgr:GetReqNum()
    local mailnum = self.friendMgr:GetUnReadMailNum()
    local guildmailnum = self.friendMgr:GetUnReadGuildMailNum()
    local friendmsgNum = self.friendMgr:GetFriendMsgNum()
    local crossmsgNum = self.friendMgr:GetCrossFriendMsgNum()
    local notfriendmsgNum = self.friendMgr:GetNotFriendMsgNum()
    local announceNum = self.friendMgr:GetUnReadAnnounceMailNum()
    local groupinvite = self.groupMgr:GetInviteNum()
    local groupmsgNum = self.groupMgr:GetNoReadMsgNum()
    if self.tabgroup ~= nil then
        self.tabgroup:ShowRed(4, mailnum >0 or guildmailnum > 0 or announceNum > 0)
        -- if self.tabgroup.currentIndex ~= 2 then
        -- end
        if self.tabgroup.currentIndex ~= 1 then
            self.tabgroup:ShowRed(1, (friendmsgNum > 0 or notfriendmsgNum>0 or groupmsgNum > 0))
        -- self.tabgroup:ShowRed(4, crossmsgNum > 0)
        end
        self.tabgroup:ShowRed(2, reqnum > 0)
        if self.tabgroup.currentIndex ~= 3 then
            self.tabgroup:ShowRed(3, groupinvite > 0 or groupmsgNum > 0)
        end
    end
    if next(self.friendMgr.currHasMsg) ~= nil or groupmsgNum > 0 then
        self:UpdateCurrFriendList()
        self:CurrFriendOnline()
        self:UpdateFriendList()
    end
    self.FriendGroupList:UpdateGroupList()

end

function FriendWindow:ClearReq(isfriend)
    local parent = self.RightConGroup[4]:Find("Con/Layout")
    if not isfriend then
        parent = self.RightConGroup[5]:Find("Con/Layout")
    end
    local childnum = parent.childCount
    local childtable = {}
    for i = 0, childnum-1 do
        local item = parent:GetChild(i)
        if item ~= nil then
            table.insert(childtable, item.gameObject)
        end
    end
    for i,v in ipairs(childtable) do
        v.gameObject:SetActive(false)
    end
end

function FriendWindow:AcceptAll(isfriend)
    if isfriend then
        for k,v in pairs(self.friendMgr.request_List) do
            self.friendMgr:Require11805(1, v.name, v.id, v.platform, v.zone_id)
        end
    else
        for k,v in pairs(self.friendMgr.request_List) do
            self.groupMgr:Require19010(v.role_rid, v.role_platform, v.role_zone_id, v.group_rid, v.group_platform, v.group_zone_id, 1)
        end
    end
    self:ClearReq(isfriend)
end

function FriendWindow:RefuseAll(isfriend)
    if isfriend then
        for k,v in pairs(self.friendMgr.request_List) do
            self.friendMgr:Require11805(0, v.name, v.id, v.platform, v.zone_id)
        end
    else
        for k,v in pairs(self.friendMgr.request_List) do
            self.groupMgr:Require19010(v.role_rid, v.role_platform, v.role_zone_id, v.group_rid, v.group_platform, v.group_zone_id, 0)
        end
    end
    self:ClearReq(isfriend)
end

function FriendWindow:SelectChatTarget()
    local data = self.friendMgr.currchat_List[self.model.chatTarget]
    local item = self.LeftConGroup[1]:Find(string.format("Layout/%s", self.model.chatTarget))
    if data ~= nil and item ~= nil then
        self:OnClickPlayer(item.gameObject, data)
    end
    -- self.model.chatTarget = nil
    -- self.model.chatTargetInfo = {}
end

function FriendWindow:OnClickZoneBtn()
    self.newmomentRed:SetActive(false)
    ZoneManager.Instance:OpenSelfZone()
end
---[[
function FriendWindow:CurrFriendOnline()

    for k,v in pairs(self.Layout1.cellList) do
        local textColor = v.transform:Find("name"):GetComponent(Text).color
        local container = v.transform:Find("Headbg/HeadSlot/Custom/Container")
        if textColor == Color(0.5, 0.5, 0.5) then
            v.transform:Find("Headbg/HeadSlot/Custom/Base"):GetComponent(Image).color = Color(0.5,0.5,0.5)
            for i=1,container.childCount do
                container:GetChild(i-1):GetComponent(Image).color = Color(0.5,0.5,0.5)
            end
        else
            v.transform:Find("Headbg/HeadSlot/Custom/Base"):GetComponent(Image).color = Color(1,1,1)
            for i=1,container.childCount do
                container:GetChild(i-1):GetComponent(Image).color = Color(1,1,1)
            end
        end
    end
end
--]]

function FriendWindow:CancleBlackFriend(data)
    local confirmdata = NoticeConfirmData.New()
    confirmdata.type = ConfirmData.Style.Normal
    confirmdata.content = string.format(TI18N("相逢即是缘分，是否<color='#ffff00'>解除</color><color='#01c0ff'>%s</color>黑名单？"),data.name)
    confirmdata.sureLabel = TI18N("解除黑名")
    confirmdata.cancelLabel = TI18N("不解除")
    confirmdata.sureCallback = function () self.friendMgr:Require11807(data.id, data.platform, data.zone_id) end
    NoticeManager.Instance:ConfirmTips(confirmdata)
end