FriendChatPanel = FriendChatPanel or BaseClass()

function FriendChatPanel:__init(Mainwin)
    self.Mainwin = Mainwin
    self.friendMgr = self.Mainwin.friendMgr
    self.chatMgr = ChatManager.Instance
    self.model = self.Mainwin.model
    self.transform = self.Mainwin.RightConGroup[2]
    self.currChatTarget = nil
    self.usingGo = {}
    self.cachGo = {}
    self.appendTab = {}
    self.channel = MsgEumn.ChatChannel.Private

    self.inputfield = self.transform:Find("TopPart/TextInput/Input/InputField"):GetComponent(InputField)
    self.chatExtPanel = nil
    local ipf = self.inputfield
    local textcom = self.inputfield.transform:Find("Text"):GetComponent(Text)
    local placeholder = self.inputfield.transform:Find("Placeholder"):GetComponent(Text)
    ipf.textComponent = textcom
    ipf.placeholder = placeholder

    self.txtbg = self.transform:Find("txtbg")
    self.addbutton = self.transform:Find("AddButton")
    self.InfoPanel = self.transform:Find("InfoPanel")

    self.textListener = function(fromId, actionType, text) self:OnTextInput(fromId, actionType, text) end

    if BaseUtils.CustomKeyboard() then
        -- 文字输入框
        self.inputfield.enabled = false
        self.transform:Find("TopPart/TextInput/Input"):GetComponent(Button).onClick:AddListener(function() self:OpenInputDialog() end)
        EventMgr.Instance:AddListener(event_name.input_dialog_callback, self.textListener)
    else
        self.inputfield.enabled = true
    end

    self.VoiceTypeButton = self.transform:Find("TopPart/TextInput/VoiceTypeButton"):GetComponent(Button)
    self.VoiceInput = self.transform:Find("TopPart/VoiceInput")
    self.VoiceInputButton = self.VoiceInput:Find("VoiceInputButton"):GetComponent(CustomEnterExsitButton)
    self.TextTypeButton = self.VoiceInput:Find("TextTypeButton"):GetComponent(Button)

    self.VoiceTypeButton.onClick:AddListener(function() self.VoiceInput.gameObject:SetActive(true) end)
    self.TextTypeButton.onClick:AddListener(function() self.VoiceInput.gameObject:SetActive(false) end)
    self.VoiceInputButton.onDown:AddListener(function() self:DownVoice(MsgEumn.ChatChannel.Private) end)
    self.VoiceInputButton.onUp:AddListener(function() self:UpVoice() end)
    self.VoiceInputButton.onEnter:AddListener(function() self:EnterVoice() end)
    self.VoiceInputButton.onExsit:AddListener(function() self:ExitVoice() end)

    self.LikeText = self.transform:Find("LikeText")
    self.DeleteButton = self.transform:Find("DeleteButton")

    self.SendButton = self.transform:Find("TopPart/SendButton"):GetComponent(Button)
    self.moreButton = self.transform:Find("TopPart/MoreButton"):GetComponent(Button)

    self.moreButton.onClick:AddListener(function() self:ClickMore() end)
    self.SendButton.onClick:AddListener(function() self:SendMsg() end)
    self.container = self.transform:Find("Con/Container").gameObject
    self.baseChatItem = self.transform:Find("ChatItem").gameObject
    self.baseChatItem:SetActive(false)

    local setting2 = {
        axis = BoxLayoutAxis.Y
        ,spacing = 15
        ,border = 6
        ,Left = 8.9
        ,Top = 4
        ,Dir = BoxLayoutDir.Top
        ,scrollRect = self.transform:Find("Con")
    }
    self.Layout = LuaBoxLayout.New(self.container.transform, setting2)
    self.isdirty = false  --是否切换

    self.infoBtn = self.transform:Find("infoButton"):GetComponent(Button)
    self.infoBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1、赠送好友玫瑰可以增加亲密度"),
            TI18N("2、好友之间组队参与<color='#ffff00'>世界boss、天空之塔、段位赛</color>可增加亲密度"),
            TI18N("3、亲密度达到<color='#00ff00'>100点</color>可赠送道具"),
            }})
        end)

    self._OnBigFaceClick = function(args)
        self:OnBigFaceClick(args)
    end

    self.messageSendSuccessListener = function(data) self:MessageSendSuccess(data) end
end

function FriendChatPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.input_dialog_callback, self.textListener)
    FaceManager.Instance.OnBigFaceClick:Remove(self._OnBigFaceClick)
    EventMgr.Instance:RemoveListener(event_name.message_send_success, self.messageSendSuccessListener)
    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
        self.chatExtPanel = nil
    end

    if self.usingGo ~= nil then
        for k,v in pairs(self.usingGo) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.usingGo = nil
    end

    if self.Layout ~= nil then
        self.Layout:DeleteMe()
        self.Layout = nil
    end
end

function FriendChatPanel:show()
    if self.chatData ~= nil then
        if self.isdirty or #self.chatData == 26 then
            -- print("新的")
            self:ReCycle()
            self.Layout:ReSet()
            for i,v in ipairs(self.chatData) do
                local item = self:GetCachGo()
                item.gameObject.name = tostring(i)
                self:SetData(item, v)
                self.Layout:AddCell(item.gameObject)
            end
            self.isdirty = false
        else
            -- print("旧的")
            for i,v in ipairs(self.chatData) do
                if self:IsNew(i) then
                    local item = self:GetCachGo()
                    item.gameObject.name = tostring(i)
                    self:SetData(item, v)
                    self.Layout:AddCell(item.gameObject)
                end
            end
        end
    end

    FaceManager.Instance.OnBigFaceClick:Remove(self._OnBigFaceClick)
    FaceManager.Instance.OnBigFaceClick:Add(self._OnBigFaceClick)
    EventMgr.Instance:RemoveListener(event_name.message_send_success, self.messageSendSuccessListener)
    EventMgr.Instance:AddListener(event_name.message_send_success, self.messageSendSuccessListener)
end

function FriendChatPanel:MsgUpdate()
    self.chatData = self.friendMgr:GetChatLog(self.currChatTarget)
    -- local temp = {}
    -- local length = #self.chatData
    -- for i = length, 1, -1 do
    --     print(i)
    --     table.insert(temp, self.chatData[i])
    -- end
    -- self.chatData = temp
    -- BaseUtils.dump(self.chatData)
    self:show()
end

function FriendChatPanel:SetData(item, data)
    item:Reset()
    item.gameObject:SetActive(true)
    item:SetData(data)
    if data.isself then
        item.transform:Find("MessageBackground"):GetComponent(Image).color = Color(175/255,234/255,1,1)
        -- item.transform:Find("Name"):GetComponent(Text).color = Color(0.55, 0.91, 0.16, 1)
    else
        item.transform:Find("MessageBackground"):GetComponent(Image).color = Color(1, 1, 1, 1)
        -- item.transform:Find("Name"):GetComponent(Text).color = Color(1, 1, 1, 1)
    end

    if item.msgData.elements ~= nil then
        for i,msg in ipairs(item.msgData.elements) do
            if msg.faceId ~= 0 and msg.faceId ~= nil then
                if DataChatFace.data_new_face[msg.faceId] ~= nil and DataChatFace.data_new_face[msg.faceId].type == FaceEumn.FaceType.Big then
                    item.transform:Find("MessageBackground"):GetComponent(Image).color = Color(1,1,1,0)
                end
            end
        end
    end

end



function FriendChatPanel:SetTarget(data)
    if self.currChatTarget == BaseUtils.Key(data.id, data.platform, data.zone_id) then
        return
    end
    self.currChatTarget = BaseUtils.Key(data.id, data.platform, data.zone_id)
    self.targetData = data
    self.model.chatTargetInfo = data
    self.model.chatTarget = self.currChatTarget
    self:SwitchIsFriend()
    self.isdirty = true
    self:MsgUpdate()
    -- print("换人")
end

function FriendChatPanel:SwitchIsFriend()
    if self.friendMgr:IsFriend(self.targetData.id, self.targetData.platform, self.targetData.zone_id) then
        self.InfoPanel.gameObject:SetActive(false)
        self.txtbg.gameObject:SetActive(false)
        self.addbutton.gameObject:SetActive(false)
        if self.targetData.intimacy == nil then
            self.targetData.intimacy = 0
        end
        self.LikeText.gameObject:SetActive(true)
        self.LikeText:GetComponent(Text).text = string.format(TI18N("亲密度：%s"), tostring(self.targetData.intimacy))
        self.DeleteButton.gameObject:SetActive(true)
        self.DeleteButton:GetComponent(Button).onClick:RemoveAllListeners()
        self.DeleteButton:GetComponent(Button).onClick:AddListener(function()
            local data = NoticeConfirmData.New()
                    data.type = ConfirmData.Style.Normal
                    data.content = TI18N("是否清空聊天记录")
                    data.sureLabel = TI18N("确定")
                    data.cancelLabel = TI18N("取消")
                    data.sureCallback = function() self:ClearLog() end
                    NoticeManager.Instance:ConfirmTips(data)
        end)
    else
        self.InfoPanel.gameObject:SetActive(true)
        self.txtbg.gameObject:SetActive(true)
        self.addbutton.gameObject:SetActive(true)
        self.addbutton:GetComponent(Button).onClick:RemoveAllListeners()
        self.addbutton:GetComponent(Button).onClick:AddListener(function() self.friendMgr:AddFriend(self.targetData.id, self.targetData.platform, self.targetData.zone_id) end)
        if self.targetData.intimacy == nil then
            self.targetData.intimacy = 0
        end
        self.LikeText.gameObject:SetActive(false)
        self.LikeText:GetComponent(Text).text = string.format(TI18N("好友度：%s"), tostring(self.targetData.intimacy))
        self.DeleteButton.gameObject:SetActive(false)
    end
end

function FriendChatPanel:SendMsg()
    local role = RoleManager.Instance.RoleData
    if role.lev < 15 then
        NoticeManager.Instance:FloatTipsByString(TI18N("15级开放私聊功能哦，赶快升级吧～"))
        return
    -- elseif not BaseUtils.IsTheSamePlatform(self.targetData.platform, self.targetData.zone_id) then
    --     NoticeManager.Instance:FloatTipsByString("跨服暂不支持私聊")
    --     return
    end
    local msg = self.inputfield.text
    local len = string.len(msg)
    -- if msg == "" then
    --     NoticeManager.Instance:FloatTipsByString("内容不能为空")
    -- else
    --     self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, msg)
    --     self.inputfield.text = ""
    -- end
    if not self:CheckElement() and len>0 then
        msg = string.gsub(msg, "{(%l-_%d.-),(.-)}", "")
        self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, msg)
    end
    -- self.inputfield.text = ""
end

function FriendChatPanel:SendQuest(quest)
    if quest ~= nil then
        self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, quest)
    end
end

--获取复用对象
function FriendChatPanel:GetCachGo()
    local length = #self.cachGo
    if length >0 then
        local go = self.cachGo[length]
        self.cachGo[length] = nil
        table.insert( self.usingGo, go )
        return go
    else
        local go = ChatItem.New(self)
        table.insert( self.usingGo, go )
        return go
    end
    -- print("复用")
    -- print(#self.cachGo)
end

--回收
function FriendChatPanel:ReCycle()
    -- print("回收")
    for i,v in ipairs(self.usingGo) do
        v.gameObject.name = "old"
        v.gameObject:SetActive(false)
        table.insert( self.cachGo, v )
    end
    -- print(#self.cachGo)
    self.usingGo = {}
end

function FriendChatPanel:IsNew(index)
    return self.container.transform:Find(tostring(index)) == nil
end

function FriendChatPanel:ClearLog()
    self.friendMgr:ClearChatLog(self.currChatTarget)
    self.isdirty = true
    self:MsgUpdate()
end

function FriendChatPanel:ClickMore()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Friend)
    end
    self.chatExtPanel:Show()
end

function FriendChatPanel:AppendInputElement(element)
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

    local nowStr = self.inputfield.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        if string.find(nowStr, srcStr) ~= nil then
            local repStr = element.matchString
            nowStr = string.gsub(nowStr, srcStr, repStr, 1)
        else
            nowStr = nowStr .. element.showString
        end
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.inputfield.text = nowStr
end

function FriendChatPanel:CheckElement()
    if #self.appendTab == 0 then
        return false
    end
    local role = RoleManager.Instance.RoleData
    local str = self.inputfield.text
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
                local myPetData = PetManager.Instance:GetPetById(v.id)
                newSendStr = string.format("{pet_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, myPetData.growth_type)
            end
        elseif v.cacheType == MsgEumn.CacheType.Equip then
            local cacheId = ChatManager.Instance.equipCache[v.id]
            if cacheId ~= nil then
                newSendStr = string.format("{item_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, 1)
            end
        elseif v.cacheType == MsgEumn.CacheType.Guard then
            local cacheId = ChatManager.Instance.guardCache[v.id]
            if cacheId ~= nil then
                local myShData = ShouhuManager.Instance.model:get_my_shouhu_data_by_id(v.base_id)
                newSendStr = string.format("{guard_1,%s,%s,%s,%s, %s}", role.platform, role.zone_id, cacheId, v.base_id, myShData.quality)
            end
        elseif v.cacheType == MsgEumn.CacheType.Wing then
            local cacheId = ChatManager.Instance.wingCache[0]
            if cacheId ~= nil then
                newSendStr = string.format("{wing_1,%s,%s,%s,%s,%s,%s,%s,%s}", role.platform, role.zone_id, role.classes, v.grade, v.growth, cacheId, v.base_id, role.name)
            end
        elseif v.cacheType == MsgEumn.CacheType.Ride then
            local cacheId = ChatManager.Instance.rideCache[v.id]
            if cacheId ~= nil then
                local myRideData = RideManager.Instance.model:get_ride_data_by_id(v.base_id)
                newSendStr = string.format("{ride_1,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, myRideData.growth-1)
            end
        elseif v.cacheType == MsgEumn.CacheType.Child then
            local name = string.sub(v.showString, 2, -2)
            local cacheId = ChatManager.Instance.childCache[0]
            if cacheId ~= nil then
                local myChildData = ChildrenManager.Instance:GetChild(v.child_id, role.platform, role.zone_id)
                newSendStr = string.format("{child_1,%s,%s,%s,%s,%s,%s}", role.platform, role.zone_id, cacheId, v.base_id, name, myChildData.growth_type)
            end
        elseif v.cacheType == MsgEumn.CacheType.Talisman then
            local cacheId = ChatManager.Instance.talismanCache[v.id]
            local platform = RoleManager.Instance.RoleData.platform
            local zone_id = RoleManager.Instance.RoleData.zone_id
            newSendStr = string.format("{item_4,%s,%s,%s,%s}", platform, zone_id, v.base_id, cacheId)
        end
        str = string.gsub(str, v.matchString, newSendStr, 1)
    end
    self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, str)
    ChatManager.Instance:AppendHistory(self.inputfield.text)
    self.appendTab = {}
    return true
end

function FriendChatPanel:DownVoice(channel, rid, zone_id, platform)
    -- if not BaseUtils.IsTheSamePlatform(self.targetData.platform, self.targetData.zone_id) then
    --     NoticeManager.Instance:FloatTipsByString("跨服暂不支持私聊")
    --     return true
    -- end
    if self.targetData ~= nil then
        ChatManager.Instance.model:DownVoice(channel, self.targetData.id, self.targetData.zone_id, self.targetData.platform)
    else
        print("没有聊天目标")
        return
    end
end

function FriendChatPanel:UpVoice()
    ChatManager.Instance.model:UpVoice()
end

function FriendChatPanel:ExitVoice()
    ChatManager.Instance.model:ExitVoice()
end

function FriendChatPanel:EnterVoice()
    ChatManager.Instance.model:EnterVoice()
end

-- 打开输入框
function FriendChatPanel:OpenInputDialog()
    self.tempInput = self.inputfield.text
    self.inputfield.text = ""

    local width = 188 * (ctx.ScreenWidth / 960) -- 同上
    local fontSize = BaseUtils.FontSize(18)
    local cpos = BaseUtils.ConvertPosition(self.inputfield.gameObject.transform.position)
    local x = cpos.px
    local y = cpos.py
    SdkManager.Instance:ShowInputDialogWhite(GlobalEumn.InputFormId.FriendChat, GlobalEumn.ShowType.Send, x, y, fontSize, GlobalEumn.GravityType.Left, width, self.tempInput)
end

function FriendChatPanel:OnTextInput(fromId, actionType, text)
    if tonumber(fromId) ~= GlobalEumn.InputFormId.FriendChat then
        return
    end
    -- if tonumber(actionType) == GlobalEumn.InputCallbackType.ClickReturn then
    self.inputfield.text = tostring(text)
    -- end
    if tostring(text) ~= "" then
        if tonumber(actionType) == GlobalEumn.InputCallbackType.ClickReturn then
            -- 点击回车回调
            self:SendMsg()
        elseif tonumber(actionType) == GlobalEumn.InputCallbackType.ClickBlank then
            -- 点击空白回调
        end
    end
end

function FriendChatPanel:AutoSend(type)
    local str = ""
    if type == 1 then
        -- str = string.format(TI18N("%s，我在导师德林处听说了你的风采，可以收我为徒吗{face_1,16}"), self.targetData.name)
    elseif type == 2 then
        str = string.format(TI18N("%s，你今天的功课还没有完成咯，记得做完找我验收，奖励很丰厚呢。"), self.targetData.name)
        self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, str)
    end
end

function FriendChatPanel:OnBigFaceClick(args)
    if args.type == MsgEumn.ExtPanelType.Friend then
        local role = RoleManager.Instance.RoleData
        if role.lev < 15 then
            NoticeManager.Instance:FloatTipsByString(TI18N("15级开放私聊功能哦，赶快升级吧～"))
            return
        end

        self.friendMgr:SendMsg(self.targetData.id, self.targetData.platform, self.targetData.zone_id, args.message)
    end
end

function FriendChatPanel:MessageSendSuccess(data)
    if data.code == 10402 then
        if data.flag == 1 then
            self.inputfield.text = ""
        end 
    end
end
