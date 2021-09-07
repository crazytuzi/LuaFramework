FriendSelectWindow = FriendSelectWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function FriendSelectWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.FriendSelectWindow
    self.name = "FriendSelectWindow"
    self.friendMgr = self.model.friendMgr
    self.resList = {
        {file = AssetConfig.friendselect, type = AssetType.Main}
        -- ,{file = AssetConfig.infoicon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.chat_window_res, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep}
    }

    -----------------------------------------
    self.Layout = nil
    self.PlayerItem = nil
    self.noFriend = nil

    self.type = 1 -- 1.成就分享 2.结缘 3.极寒试炼求助 4.组队副本邀请 5.传递花语活动 6.传声(单选本服在线)
    self.muti = nil
    self.selectItem = nil
    self.selectData = nil
    -----------------------------------------
end

function FriendSelectWindow:__delete()
    if self.Layout ~= nil then
        self.Layout:DeleteMe()
        self.Layout = nil
    end
    self:ClearDepAsset()
end

function FriendSelectWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.friendselect))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform.localPosition = Vector3(0,0,-400)

    self.CloseButton = self.transform:Find("CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.PlayerItem = self.transform:Find("MainCon/PlayerItem").gameObject
    self.PlayerItem:SetActive(false)

    local setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,scrollRect = self.transform:Find("MainCon/Con")
    }
    self.Layout = LuaBoxLayout.New(self.transform:Find("MainCon/Con/Layout"), setting)

    self.noFriend = self.transform:Find("MainCon/Con/NoFriend").gameObject
    self.noFriend.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:Close() self.model:OpenPushWindow() end)

    self.okButton = self.transform:Find("MainCon/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnClickOkButton() end)

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.callBack = self.openArgs[1]
        if #self.openArgs > 1 then
            self.type = self.openArgs[2]
        end
        if #self.openArgs > 2 then
            self.muti = self.openArgs[3]
        end

    end
    self:UpdatePanel()
    self:UpdateFriendList()
end

function FriendSelectWindow:Close()
    self.model:CloseFriendSelect()
end

function FriendSelectWindow:UpdatePanel()
    if self.type == 3 then
        local rect = self.transform:Find("MainCon/Con"):GetComponent(RectTransform)
        rect.sizeDelta = Vector2(320, 300)
        rect.anchoredPosition =  Vector2(0, 15)
    end
end

function FriendSelectWindow:UpdateFriendList()
    local list = self.friendMgr:GetSortFriendList()
    local parent = self.transform:Find("MainCon/Con/Layout").gameObject
    list = self:processFriendList(list)

    for k,v in ipairs(list) do
        local uid = BaseUtils.Key(v.id, v.platform, v.zone_id)
        local item = parent.transform:Find(uid)
        if item == nil then
            item = GameObject.Instantiate(self.PlayerItem)
        else
            item.gameObject:SetActive(false)
        end
        item.gameObject.name = uid
        local flag = self.friendMgr.currHasMsg[uid] ~= nil and not (self.clickitem ~= nil and self.clickitem.gameObject.name == uid)
        -- and (self.clickitem == nil or self.clickitem.gameObject.name ~= uid)
        if flag == false then
            self.friendMgr.currHasMsg[uid] = nil
        end
        item.transform:Find("Red").gameObject:SetActive(flag)
        item.transform:Find("Red/Text"):GetComponent(Text).text = tostring(self.friendMgr.currHasMsg[uid])
        self:SetPlayerItem(item, v)
        self.Layout:AddCell(item.gameObject)
    end

    self.Layout:ReSize()
end

function FriendSelectWindow:processFriendList(list)
    if self.type == 1 then
        if #list == 0 then
            self.noFriend.gameObject:SetActive(true)
        else
            self.noFriend.gameObject:SetActive(false)
        end
        return list
    elseif self.type == 2 then
        local newList = {}
        for _, value in ipairs(list) do
            if value.intimacy >= 999 and value.sex ~= RoleManager.Instance.RoleData.sex then
                table.insert(newList, value)
            end
        end
        if #newList == 0 then
            self.noFriend.gameObject:SetActive(true)
            self.noFriend.transform:Find("Button").gameObject:SetActive(false)
            self.noFriend.transform:Find("Text"):GetComponent(Text).text = TI18N("你没有亲密度达到999的异性好友")
        else
            self.noFriend.gameObject:SetActive(false)
        end
        return newList
    elseif self.type == 3 then
        local newList = {}
        for _, value in ipairs(list) do
            if value.online == 1 then
                table.insert(newList, value)
            end
        end
        if #newList == 0 then
            self.noFriend.gameObject:SetActive(true)
            self.noFriend.transform:Find("Text"):GetComponent(Text).text = TI18N("你没有在线好友")
        else
            self.noFriend.gameObject:SetActive(false)
        end
        return newList
    elseif self.type == 5 then
        local newList = BaseUtils.copytab(SignDrawManager.Instance.friend_list)
        local templist = {}
        for _, v in ipairs(list) do
            local key_1 = BaseUtils.Key(v.id, v.platform, v.zone_id)
            for __, value in ipairs(newList) do
                local key_2 = BaseUtils.Key(value.id, value.platform, value.zone_id)
                if key_1 == key_2 then
                    table.insert(templist,v)
                end
            end
        end

        if #templist == 0 then
            self.noFriend.gameObject:SetActive(true)
            self.noFriend.transform:Find("Text"):GetComponent(Text).text = TI18N("你没有可传递的好友")
        else
            self.noFriend.gameObject:SetActive(false)
        end
        return templist
    elseif self.type == 6 then
        local newList = {}
        for _, v in ipairs(list) do
            if v.online == 1 and BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
                table.insert(newList, v)
            end
        end
        if #newList == 0 then
            self.noFriend.gameObject:SetActive(true)
            self.noFriend.transform:Find("Text"):GetComponent(Text).text = TI18N("你没有在线好友")
        else
            self.noFriend.gameObject:SetActive(false)
        end
        return newList
    end

    return list
end

function FriendSelectWindow:SetPlayerItem(item, data)
    local its = item.transform
    its:Find("Head"):GetComponent(Image).sprite = self:GetHead(data.classes, data.sex)
    if data.online == 1 then
        its:Find("Head"):GetComponent(Image).color = Color(1,1,1)
        -- BaseUtils.SetGrey(its:Find("Head"):GetComponent(Image), false)
        its:Find("name"):GetComponent(Text).color = Color(1,1,1)
    else
        -- BaseUtils.SetGrey(its:Find("Head"):GetComponent(Image), true)
        its:Find("Head"):GetComponent(Image).color = Color(0.5, 0.5, 0.5)
        its:Find("name"):GetComponent(Text).color = Color(0.5, 0.5, 0.5)
    end
    its:Find("LevText"):GetComponent(Text).text = string.format("<color='#fffff`f'>%s</color>", data.lev)
    its:Find("ClassIcon"):GetComponent(Image).sprite = self:GetClassIcon(data.classes)
    its:Find("name"):GetComponent(Text).text = string.format("<color='#3166ad'>%s</color>", data.name)
    its:Find("SigText"):GetComponent(Text).text = TI18N("无")
    if data.signature ~= "" then
        its:Find("SigText"):GetComponent(Text).text = data.signature
    end
    its:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    its:Find("Button"):GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowPlayer(data) end)
    its:GetComponent(Button).onClick:RemoveAllListeners()
    its:GetComponent(Button).onClick:AddListener(function() self:OnClickPlayer(item, data) end)

    if self.type == 2 then
        its:Find("Icon").gameObject:SetActive(false)
        its:Find("SigText"):GetComponent(Text).text = string.format(TI18N("亲密度:%s"), data.intimacy)
    end
end

function FriendSelectWindow:GetClassIcon(classes)
    local sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(classes))
    return sprite
end

function FriendSelectWindow:GetHead(classes, sex)
    local name = classes .. "_" .. sex
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    return sprite
end

function FriendSelectWindow:OnClickPlayer(item, data)

    if self.type == 1 then
        self.callBack(item, data)
        self:Close()
    elseif self.type == 2 then
        self.callBack(item, data)
        self:Close()
    elseif self.type == 3 then
        local selectObject = item.transform:Find("Select").gameObject
        selectObject:SetActive(not selectObject.activeSelf)
        self.okButton:SetActive(true)
    elseif self.type == 4 then
        self.callBack(item, data)
    elseif self.type == 5 then
        local selectObject = item.transform:Find("Select").gameObject

        if self.lastSelectObject ~= nil then
            self.lastSelectObject:SetActive(false)
        end
        selectObject:SetActive(true)
        self.lastSelectObject = selectObject

        self.okButton:SetActive(true)
    elseif self.type == 6 then
        local selectObject = item.transform:Find("Select").gameObject

        if self.muti ~= nil then
            if self.lastSelectObject ~= nil then
                self.lastSelectObject:SetActive(false)
            end
            selectObject:SetActive(true)
            self.lastSelectObject = selectObject
        else
            selectObject:SetActive(not selectObject.activeSelf)
        end
        self.okButton:SetActive(true)
    end
end

function FriendSelectWindow:OnClickOkButton()
    local selectDataList = {}

    local list = self.friendMgr:GetSortFriendList()
    local parent = self.transform:Find("MainCon/Con/Layout").gameObject
    list = self:processFriendList(list)

    for k,v in ipairs(list) do
        local uid = BaseUtils.Key(v.id, v.platform, v.zone_id)
        local item = parent.transform:Find(uid)
        if item ~= nil and item.transform:Find("Select").gameObject.activeSelf then
            table.insert(selectDataList, v)
        end
    end

    if self.type == 1 then
    elseif self.type == 2 then
    elseif self.type == 3 then
        self.callBack(selectDataList)
        self:Close()
    elseif self.type == 4 then
        self:Close()
    elseif self.type == 5 then
        self.callBack(selectDataList)
        self:Close()
    elseif self.type == 6 then
        self.callBack(selectDataList)
        self:Close()
    end
end
