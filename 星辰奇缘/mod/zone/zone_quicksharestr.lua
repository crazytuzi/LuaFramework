-- 朋友圈快速分享文字
-- hzf
-- 2016.08.22

ZoneQuickShareStr = ZoneQuickShareStr or BaseClass(BasePanel)

function ZoneQuickShareStr:__init(setting)
    self.Mgr = ZoneManager.Instance
    self.model = ZoneManager.Instance.model
    self.defaultstr = setting.defaultstr ~= nil and setting.defaultstr or ""
    self.title = setting.title ~= nil and setting.title or ""
    self.hidestr = setting.hidestr ~= nil and setting.hidestr or ""
    self.type = setting.type ~= nil and setting.type or 0
    self.name = "ZoneQuickShareStr"
    self.appendTab = {}
    self.photos = {}
    self.mentions = {}
    self.thumbphotos = {}

    self.resList = {
        {file = AssetConfig.moment_send_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }
    self.mentions = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    -- self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ZoneQuickShareStr:__delete()
    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
    end
    if self.photoeditor ~= nil then
        self.photoeditor:DeleteMe()
    end
    if self.friendPanel ~= nil then
        self.friendPanel:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ZoneQuickShareStr:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_send_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.I18NLimitText = self.transform:Find("Main/I18NLimitText"):GetComponent(Text)
    self.InputField = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.InputField.transform.sizeDelta = Vector2(371, 93)
    self.InputField.transform.anchoredPosition = Vector2(5, -122)
    self.InputField.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.InputFieldText = self.transform:Find("Main/InputField/Text"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText

    if self.title ~= "" then
        self.transform:Find("Main/I18NOpText"):GetComponent(Text).text = self.title
    end
    -- self.PhotoCon = self.transform:Find("Main/PhotoCon")
    self.transform:Find("Main/PhotoCon").gameObject:SetActive(false)
    self.transform:Find("Main/I18NPhotoText").gameObject:SetActive(false)
    self.atText = self.transform:Find("Main/atText"):GetComponent(Text)
    self.FcaeButton = self.transform:Find("Main/FcaeButton"):GetComponent(Button)
    self.FcaeButton.onClick:AddListener(function() self:ClickMore() end)
    self.atButton = self.transform:Find("Main/atButton"):GetComponent(Button)
    self.atButton.onClick:AddListener(function() self:ShowFriendList() end)
    -- self.addButton = self.transform:Find("Main/PhotoCon/AddButton"):GetComponent(Button)
    -- self.photoButton = self.transform:Find("Main/PhotoCon/Button"):GetComponent(Button)
    self.SendButton = self.transform:Find("Main/SendButton"):GetComponent(Button)
    self.ClearButton = self.transform:Find("Main/ClearButton"):GetComponent(Button)
    self.ClearButton.transform.anchoredPosition = Vector2(171.5, -23)
    self.ClearButton.onClick:AddListener(function()
        self:ClearAllMsg()
    end)
    self.CloseButton.onClick:AddListener(function() self:Hiden() end)
    self.SendButton.onClick:AddListener(function() self:OnSend() end)
    -- self.photoeditor = MomentsPhotoEditPanel.New(self.model, self)
    -- self.photoButton.onClick:AddListener(function()
    --     if self.photoeditor ~= nil then
    --         self.photoeditor:Show()
    --     end
    -- end)

    -- self.PhotoImgList = {}
    -- for i=1, 4 do
    --     self.PhotoImgList[i] = self.PhotoCon:Find(tostring(i)):GetComponent(Image)
    -- end
    self.InputField.text = self.defaultstr

end

function ZoneQuickShareStr:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ZoneQuickShareStr:OnOpen()
    self.photos = {}
    -- self:UpdatePhoto()
end

function ZoneQuickShareStr:OnHide()
end

function ZoneQuickShareStr:AtFriend()
    -- body
end

function ZoneQuickShareStr:OnSend()
    local msg = self.InputField.text
    local len = string.len(msg)
    local len2 = string.utf8len(msg)
    if len2 > 140 then
        NoticeManager.Instance:FloatTipsByString(TI18N("消息长度超过限制，请修改"))
        return
    end
    if not self:CheckElement() and len>0 then
        local send_msg = MessageParser.ConvertToTag_Face(msg)
        self:SendMsg(send_msg)
        self.photos = {}
        self.mentions = {}
        self.thumbphotos = {}
        self:Hiden()
    elseif len == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("发表一下感言吧"))
        return
    end
    self.InputField.text = ""
end

function ZoneQuickShareStr:ClickMore()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Other, {parent = self, sendcallback = function() self:OnSend() end})
    end
    self.chatExtPanel:Show()
end


function ZoneQuickShareStr:AppendInputElement(element)
    -- 其他：同类只有一个，如果是自己，则过滤掉
    local delIndex = 0
    local srcStr = ""
    if element.type ~= nil then
        for i,has in ipairs(self.appendTab) do
            if has.type == element.type and element.type ~= MsgEumn.AppendElementType.Face then
                delIndex = i
                srcStr = has.matchString
            end
        end
    end

    local nowStr = self.InputField.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        local repStr = element.matchString
        nowStr = string.gsub(nowStr, srcStr, repStr, 1)
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.InputField.text = nowStr
end


function ZoneQuickShareStr:CheckElement()
    if #self.appendTab == 0 then
        return false
    end
    local role = RoleManager.Instance.RoleData
    local str = self.InputField.text
    for i,v in ipairs(self.appendTab) do
        local newSendStr = v.sendString
        if v.cacheType == MsgEumn.CacheType.Item then
            local cacheId = ChatManager.Instance.itemCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, v.num)
            end
        elseif v.cacheType == MsgEumn.CacheType.Pet then
            local cacheId = ChatManager.Instance.petCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{pet_1,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id)
            end
        elseif v.cacheType == MsgEumn.CacheType.Equip then
            local cacheId = ChatManager.Instance.equipCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, 1)
            end
        elseif v.cacheType == MsgEumn.CacheType.Guard then
            local cacheId = ChatManager.Instance.guardCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{guard_1,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id)
            end
        elseif v.cacheType == MsgEumn.CacheType.Wing then
            local cacheId = ChatManager.Instance.wingCache[0]
            if cacheId ~= nil then
                newSendStr = string.format("{wing_1,%s,%s,%s,%s,%s,%s,%s,%s}", role.platform, role.zone_id, role.classes, v.grade, v.growth, cacheId, v.base_id, role.name)
            end
        elseif v.cacheType == MsgEumn.CacheType.Child then
            local name = string.sub(v.showString, 2, -2)
            local cacheId = ChatManager.Instance.childCache[0]
            if cacheId ~= nil then
                newSendStr = string.format("{child_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, name)
            end
        end
        str = string.gsub(str, v.matchString, newSendStr, 1)
    end
    -- self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, str)
    ChatManager.Instance:AppendHistory(self.InputField.text)
    local send_msg = MessageParser.ConvertToTag_Face(str)
    print(send_msg)
    self:SendMsg(send_msg)
    self.photos = {}
    self.mentions = {}
    self.thumbphotos = {}
    self:Hiden()
    self.appendTab = {}
    return true
end


function ZoneQuickShareStr:OnMsgChange(val)
    local len = string.utf8len(val)
    if len < 140 then
        self.I18NLimitText.text = string.format(TI18N("(还能输入%s个字)"), tostring(140-len))
    else
        self.I18NLimitText.text = TI18N("<color='#ffff00'>内容超过长度限制</color>")
    end
    self.ClearButton.gameObject:SetActive(len > 0)
end

function ZoneQuickShareStr:AddMentions(List)
    for i,v in ipairs(List) do
        if self:AddMentionPlayer(v) then
            local tab = {}
            tab["matchString"] = string.format("%%@%s", v.name)
            tab["showString"] = string.format("@%s", v.name)
            tab["sendString"] = string.format("{mention_1,%s,%s,%s,%s}", v.name, v.id, v.platform, v.zone_id)
            self:AppendInputElement(tab)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("同一个好友只能@一次"))
        end
    end
end

function ZoneQuickShareStr:ShowFriendList()
    if self.friendPanel == nil then
        local setting = {
            ismulti = true,
            callback = function(list) self:AddMentions(list) end,
            list_type = 2
        }
        self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
    end
    self.friendPanel:Show()
end

function ZoneQuickShareStr:AddMentionPlayer(data)
    for i,v in ipairs(self.mentions) do
        if v.rid == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
            return false
        end
    end
    table.insert(self.mentions, {rid = data.id, platform = data.platform, zone_id = data.zone_id})
    return true
end

function ZoneQuickShareStr:UpdatePhoto()
    if #self.photos > 0 then
        for i=1, 4 do
            if self.photos[i] ~= nil then
                local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
                local result = tex2d:LoadImage(self.photos[i])
                if result then
                    self.PhotoImgList[i].sprite = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
                    self.PhotoImgList[i].gameObject:SetActive(true)
                else
                    self.PhotoImgList[i].gameObject:SetActive(false)
                end
            else
                 self.PhotoImgList[i].gameObject:SetActive(false)
            end
        end
        self.addButton.gameObject:SetActive(false)
    else
        for i=1, 4 do
            self.PhotoImgList[i].gameObject:SetActive(false)
        end
        self.addButton.gameObject:SetActive(true)
    end
end

function ZoneQuickShareStr:ClearAllMsg()
    self.ClearButton.gameObject:SetActive(false)
    self.InputField.text = ""
    self.appendTab = {}
    self.mentions = {}
end

function ZoneQuickShareStr:SendMsg(send_msg)
    if self.type == 0 then
        send_msg = string.format("%s%s", self.hidestr, send_msg)
        self.Mgr:Require11858(send_msg, 1, self.photos, self.mentions, self.thumbphotos)
    elseif self.type == 1 then
        send_msg = string.format("%s%s", self.hidestr, send_msg)
        WorldChampionManager.Instance:Require16423(send_msg, self.mentions)
    elseif self.type == 2 then
        local rid = RoleManager.Instance.RoleData.id
        local platform = RoleManager.Instance.RoleData.platform
        local zone_id = RoleManager.Instance.RoleData.zone_id
        send_msg = string.format("{honor_4,%s,%s,%s,%s}%s", 1, rid, platform, zone_id, send_msg)
        self.Mgr:Require11858(send_msg, 1, self.photos, self.mentions, self.thumbphotos)
    elseif self.type == 3 then
        local rid = RoleManager.Instance.RoleData.id
        local platform = RoleManager.Instance.RoleData.platform
        local zone_id = RoleManager.Instance.RoleData.zone_id
        send_msg = string.format("{honor_6,%s,%s,%s,%s}%s", 1, rid, platform, zone_id, send_msg)
        self.Mgr:Require11858(send_msg, 1, self.photos, self.mentions, self.thumbphotos)
    elseif self.type == 4 then
        local rid = RoleManager.Instance.RoleData.id
        local platform = RoleManager.Instance.RoleData.platform
        local zone_id = RoleManager.Instance.RoleData.zone_id

        local badgeList = ""
        for k,v in pairs(WorldChampionManager.Instance.model.badgeData) do
            badgeList = badgeList.."|"..tostring(v)
        end
        local combinationList = ""
        for k,v in pairs(WorldChampionManager.Instance.model.combinationData) do
            combinationList = combinationList.."|"..tostring(v)
        end
        local role = RoleManager.Instance.RoleData
        send_msg = string.format("{noonebadge_1,%s,%s,%s}%s",  badgeList, combinationList , role.classes, send_msg)
        self.Mgr:Require11858(send_msg, 1, self.photos, self.mentions, self.thumbphotos)
    end
end


