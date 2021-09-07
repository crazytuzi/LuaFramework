-- @author hzf
-- @date 2016年7月29日,星期五

MomentsSendPanel = MomentsSendPanel or BaseClass(BasePanel)

function MomentsSendPanel:__init(model, parent,TopicId)
    self.Mgr = ZoneManager.Instance
    self.model = model
    self.parent = parent
    self.name = "MomentsSendPanel"
    self.appendTab = {}

    self.TopicId = TopicId    --是否为话题活动日  (0 正常/ 其他数字为活动id)

    self.sendType = 1   --(默认为1)

    self.resList = {
        {file = AssetConfig.moment_send_panel, type = AssetType.Main}
        ,{file = AssetConfig.statusSendtyPanel, type = AssetType.Main}
        ,{file = AssetConfig.anniversary_flower, type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.anniversary_textures, type  =  AssetType.Dep}
    }
    self.photos = {}
    self.thumbphotos = {}
    self.mentions = {}
    
    self.messageSendSuccessListener = function(data) self:MessageSendSuccess(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MomentsSendPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.message_send_success, self.messageSendSuccessListener)

    self.OnHideEvent:Fire()
    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
    end
    if self.photoeditor ~= nil then
        self.photoeditor:DeleteMe()
    end
    if self.friendPanel ~= nil then
        self.friendPanel:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MomentsSendPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_send_panel))

    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    local rect = self.transform:Find("Panel"):GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2(-100, -100)
    rect.offsetMax = Vector2(100, 100)

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.I18NLimitText = self.transform:Find("Main/I18NLimitText"):GetComponent(Text)
    self.InputField = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.InputField.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.InputFieldText = self.transform:Find("Main/InputField/Text"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText

    self.ConsumeNotice = self.transform:Find("Main/I18NConsumeEnergy"):GetComponent(Text)
    self.ConsumeNotice.gameObject:SetActive(false)

    self.PhotoCon = self.transform:Find("Main/PhotoCon")
    self.atText = self.transform:Find("Main/atText"):GetComponent(Text)
    self.FcaeButton = self.transform:Find("Main/FcaeButton"):GetComponent(Button)
    self.FcaeButton.onClick:AddListener(function() self:ClickMore() end)
    self.atButton = self.transform:Find("Main/atButton"):GetComponent(Button)
    self.atButton.onClick:AddListener(function() self:ShowFriendList() end)
    self.addButton = self.transform:Find("Main/PhotoCon/AddButton"):GetComponent(Button)
    self.photoButton = self.transform:Find("Main/PhotoCon/Button"):GetComponent(Button)
    self.SendButton = self.transform:Find("Main/SendButton"):GetComponent(Button)
    self.ClearButton = self.transform:Find("Main/ClearButton"):GetComponent(Button)
    self.TopicBtn = self.transform:Find("Main/TopicButton"):GetComponent(Button)
    self.TopicText = self.transform:Find("Main/TopicButton/I18NText"):GetComponent(Text)

    self.ClearButton.onClick:AddListener(function()
        self:ClearAllMsg()
    end)
    self.TopicData = {}
    if self.TopicId ~= 0 then
        for i,v in pairs(DataFriendWish.data_get_camp_theme) do
            if v.camp_id == self.TopicId then
                self.TopicData = v
            end
        end
        self.TopicText.text = self.TopicData.topic_btn
        self.TopicBtn.gameObject:SetActive(true)
        self.TopicBtn.onClick:AddListener(function() self:OpenTopicNotice() end)
        self.topicNotice = self.transform:Find("Notice")
        self.topicNoticeText = self.topicNotice:Find("bg/Text"):GetComponent(Text)
        self.topicNoticeText.supportRichText = true
        self.topicNoticeText.text = self.TopicData.desc2
        self.topicNotice.gameObject:SetActive(false)
    end
    self.CloseButton.onClick:AddListener(function() self:Hiden() end)
    self.SendButton.onClick:AddListener(function() self:OnSend() end)
    self.photoeditor = MomentsPhotoEditPanel.New(self.model, self)
    self.photoButton.onClick:AddListener(function()
        if not self.model:IsNationalDay() then
            if self.photoeditor ~= nil then
                self.photoeditor:Show()
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("10月1日-10月7日期间朋友圈图片上传功能将进行维护哟{face_1,3}"))
        end
    end)

    self.PhotoImgList = {}
    for i=1, 4 do
        self.PhotoImgList[i] = self.PhotoCon:Find(tostring(i)):GetComponent(Image)
    end

end

function MomentsSendPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MomentsSendPanel:OnOpen()
    EventMgr.Instance:RemoveListener(event_name.message_send_success, self.messageSendSuccessListener)
    EventMgr.Instance:AddListener(event_name.message_send_success, self.messageSendSuccessListener)

    self.photos = {}
    self:UpdatePhoto()
    if self.topicNotice ~= nil then
        self.topicNotice.gameObject:SetActive(false)
    end
    self.sendType = 1
    if self.TopicId ~= 0 then
        self:AnniShowEffect()
    end
end

function MomentsSendPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.message_send_success, self.messageSendSuccessListener)
    --self:ClearAllMsg()
    if self.ClearButton ~= nil then
        self.ClearButton.gameObject:SetActive(false)
    end
    if self.InputField ~= nil then
        self.InputField.text = ""
    end
end

function MomentsSendPanel:AtFriend()
    -- body
end

function MomentsSendPanel:AnniShowEffect()
    if self.SendBtnEffect == nil then
       local fun = function(effectView)
           local effectObject = effectView.gameObject
           effectObject.transform:SetParent(self.TopicBtn.transform)
           effectObject.transform.localScale = Vector3(0.45, 0.6, 1)
           effectObject.transform.localPosition = Vector3(0, 1.7, -400)
           effectObject.transform.localRotation = Quaternion.identity
           Utils.ChangeLayersRecursively(effectObject.transform, "UI")
       end
       self.SendBtnEffect = BaseEffectView.New({effectId = 20107, time = nil, callback = fun})
    else
       self.SendBtnEffect:SetActive(true)
    end
end

function MomentsSendPanel:OnSend()
    local msg = self.InputField.text
    local len = string.len(msg)
    local len2 = string.utf8len(msg)
    if len2 > 140 then
        NoticeManager.Instance:FloatTipsByString(TI18N("消息长度超过限制，请修改"))
        return
    end
    self.ConsumeNotice.gameObject:SetActive(false)

    if not self:CheckElement() and len>0 then
        local send_msg = MessageParser.ConvertToTag_Face(msg)
        if string.utf8len(send_msg) > 140 then
            NoticeManager.Instance:FloatTipsByString(TI18N("内容有点长啊，请省略一下吧"))
            print("太长了"..send_msg)
            return false
        end
        if self.sendType == 2 then
            if next(self.photos) == nil then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("参与%s话题需消耗<color='#ffff00'>10</color>活力，是否确认发表？\n <color='#ffff00'>温馨提示：有图更容易上首页哟^_^</color>"),self.TopicData.theme)
                data.sureLabel = TI18N("确认发表")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    if RoleManager.Instance.RoleData.energy >= 10 then
                        self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
                        -- self.InputField.text = ""
                        -- self.photos = {}
                        -- self.mentions = {}
                        -- self.thumbphotos = {}
                        -- self.photoeditor:Clear()
                        -- self:Hiden()
                    else
                        NoticeManager.Instance:FloatTipsByString("活力不足")
                    end
                end
                NoticeManager.Instance:ConfirmTips(data)
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("参与%s话题需消耗<color='#ffff00'>10</color>活力，是否确认发表？"),self.TopicData.theme)
                data.sureLabel = TI18N("确认发表")
                data.cancelLabel = TI18N("取消")
                data.sureCallback = function()
                    if RoleManager.Instance.RoleData.energy >= 10 then
                        self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
                        -- self.InputField.text = ""
                        -- self.photos = {}
                        -- self.mentions = {}
                        -- self.thumbphotos = {}
                        -- self.photoeditor:Clear()
                        -- self:Hiden()
                    else
                        NoticeManager.Instance:FloatTipsByString("活力不足")
                    end
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        else
            self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
            -- self.InputField.text = ""
            -- self.photos = {}
            -- self.mentions = {}
            -- self.thumbphotos = {}
            -- self.photoeditor:Clear()
            -- self:Hiden()
        end
    elseif len == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("发表一下感言吧"))
        return
    end
end

function MomentsSendPanel:ClickMore()
    --print("哈哈哈哈哈===============222")
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Other, {parent = self, sendcallback = function() self:OnSend() end},nil,false)
    end
    self.chatExtPanel:Show()
end

function MomentsSendPanel:AppendInput(str)
    self.InputField.text = self.InputField.text .. str
end

function MomentsSendPanel:AppendInputElement(element)
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


function MomentsSendPanel:CheckElement()
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
    -- send_msg = string.gsub(send_msg, "%#", "")
    -- send_msg = string.gsub(send_msg, "周年庆", "")
    -- send_msg = string.gsub(send_msg, "%#", "")
    if self.sendType == 2 then
        if next(self.photos) == nil then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("参与%s话题需消耗<color='#ffff00'>10</color>活力，是否确认发表？\n <color='#ffff00'>温馨提示：有图更容易上首页哟^_^</color>"),self.TopicData.theme)
            data.sureLabel = TI18N("确认发表")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                if RoleManager.Instance.RoleData.energy >= 10 then
                    self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
                    -- self.InputField.text = ""
                    -- self.photos = {}
                    -- self.mentions = {}
                    -- self.thumbphotos = {}
                    -- self.photoeditor:Clear()
                    -- self.appendTab = {}
                    -- self:Hiden()
                else
                    NoticeManager.Instance:FloatTipsByString("活力不足")
                end
            end
            NoticeManager.Instance:ConfirmTips(data)
        else
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("参与%s话题需消耗<color='#ffff00'>10</color>活力，是否确认发表？"),self.TopicData.theme)
            data.sureLabel = TI18N("确认发表")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                if RoleManager.Instance.RoleData.energy >= 10 then
                    self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
                    -- self.InputField.text = ""
                    -- self.photos = {}
                    -- self.mentions = {}
                    -- self.thumbphotos = {}
                    -- self.photoeditor:Clear()
                    -- self.appendTab = {}
                    -- self:Hiden()
                else
                    NoticeManager.Instance:FloatTipsByString("活力不足")
                end
            end
            NoticeManager.Instance:ConfirmTips(data)
        end
    else
        self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
        -- self.InputField.text = ""
        -- self.photos = {}
        -- self.mentions = {}
        -- self.thumbphotos = {}
        -- self.photoeditor:Clear()
        -- self.appendTab = {}
        -- self:Hiden()
    end
    --self.Mgr:Require11858(send_msg, self.sendType, self.photos, self.mentions, self.thumbphotos)
    return true
end


function MomentsSendPanel:OnMsgChange(val)
    local len = string.utf8len(val)
    if len <= 140-#self.mentions*20 then
        self.I18NLimitText.text = string.format(TI18N("(还能输入%s个字)"), tostring(140-#self.mentions*20-len))
    else
        self.I18NLimitText.text = TI18N("<color='#ffff00'>内容超过长度限制</color>")
    end
    self.ClearButton.gameObject:SetActive(len > 0)
end

function MomentsSendPanel:AddMentions(List)
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

function MomentsSendPanel:ShowFriendList()
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

function MomentsSendPanel:AddMentionPlayer(data)
    for i,v in ipairs(self.mentions) do
        if v.rid == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
            return false
        end
    end
    table.insert(self.mentions, {rid = data.id, platform = data.platform, zone_id = data.zone_id})
    return true
end

function MomentsSendPanel:UpdatePhoto()
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

function MomentsSendPanel:ClearAllMsg()
    self.ClearButton.gameObject:SetActive(false)
    self.InputField.text = ""
    self.appendTab = {}
    self.mentions = {}
    self.sendType = 1
end

--点击话题按钮  在里面插入#话题# 记录 然后打开下面的提示面板
function MomentsSendPanel:OpenTopicNotice()
    if self.topicNotice.gameObject.activeSelf then
        self.sendType = 1
        self.InputField.text = ""
        self.topicNotice.gameObject:SetActive(false)
        self.ConsumeNotice.gameObject:SetActive(false)
    else
        self.sendType = 2
        self:AppendInput(string.format("#%s#",self.TopicData.theme))
        self.topicNotice.gameObject:SetActive(true)
        self.ConsumeNotice.gameObject:SetActive(true)
    end

    self.ConsumeNotice.text = TI18N("消耗<color='#ffff00'>10</color>活力")
    --self.ConsumeNotice.gameObject:SetActive(true)

    if self.SendBtnEffect ~= nil then
        self.SendBtnEffect:SetActive(false)
    end
end

function MomentsSendPanel:MessageSendSuccess(data)
    if data.code == 11858 then
        if data.flag == 1 then
            self.InputField.text = ""
            self.photos = {}
            self.mentions = {}
            self.thumbphotos = {}
            self.photoeditor:Clear()
            self.appendTab = {}
            self:Hiden()
        end 
    end
end

