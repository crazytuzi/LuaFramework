-- @author hzf
-- @date 2016年7月29日,星期五

MomentsCommentPanel = MomentsCommentPanel or BaseClass(BasePanel)

function MomentsCommentPanel:__init(model, parent)
    self.Mgr = ZoneManager.Instance
    self.model = model
    self.parent = parent
    self.appendTab = {}
    self.name = "MomentsCommentPanel"

    self.resList = {
        {file = AssetConfig.moment_recall_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }
    self.photos = {}
    self.mentions = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    -- self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MomentsCommentPanel:__delete()
    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MomentsCommentPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_recall_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.I18NOpText = self.transform:Find("Main/I18NOpText"):GetComponent(Text)
    self.InputField = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.InputFieldText = self.transform:Find("Main/InputField/Text"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText

    self.FcaeButton = self.transform:Find("Main/FcaeButton"):GetComponent(Button)
    self.FcaeButton.onClick:AddListener(function() self:ClickMore() end)
    self.ReportButton = self.transform:Find("Main/ReportButton"):GetComponent(Button)
    self.SendButton = self.transform:Find("Main/SendButton"):GetComponent(Button)

    self.ReportButton.onClick:AddListener(function() self:OnReport() end)
    self.CloseButton.onClick:AddListener(function() self:Hiden() end)
    self.SendButton.onClick:AddListener(function() self:OnSend() end)
end

function MomentsCommentPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MomentsCommentPanel:OnOpen()
    self.data = self.openArgs.data
    self.type = self.openArgs.type
    self.commentdata = self.openArgs.commentdata
    self.targetname = self.openArgs.name
    if self.type == 2 then
        self.I18NOpText.text = string.format(TI18N("回复 %s"), self.targetname)
    else
        self.I18NOpText.text = string.format(TI18N("评论 %s"), self.data.name)
    end
end


function MomentsCommentPanel:OnSend()
    local msg = self.InputField.text
    local len = string.len(msg)
    if len > 50 then
        NoticeManager.Instance:FloatTipsByString(TI18N("消息长度超过限制，请修改"))
        return
    end
    if not self:CheckElement() and len>0 then
        local send_msg = MessageParser.ConvertToTag_Face(msg)
        if self.type == 2 then
            if self.commentdata.commentator_id ~= nil then
                send_msg = string.format("{mention_1,%s,%s,%s,%s}%s", self.targetname, self.commentdata.commentator_id, self.commentdata.commentator_platform, self.commentdata.commentator_zone_id, send_msg)
                self.Mgr:Require11862(self.data.m_id, self.data.m_platform, self.data.m_zone_id, send_msg, {{rid = self.commentdata.commentator_id, platform = self.commentdata.commentator_platform, zone_id = self.commentdata.commentator_zone_id}})
            else
                send_msg = string.format("{mention_1,%s,%s,%s,%s}%s", self.targetname, self.commentdata.role_id, self.commentdata.platform, self.commentdata.zone_id , send_msg)
                self.Mgr:Require11862(self.data.m_id, self.data.m_platform, self.data.m_zone_id, send_msg, {{rid = self.commentdata.role_id, platform = self.commentdata.platform, zone_id = self.commentdata.zone_id}})
            end
        else
            self.Mgr:Require11862(self.data.m_id, self.data.m_platform, self.data.m_zone_id, send_msg, {})
        end
        self:Hiden()
    end
    self.InputField.text = ""
end

function MomentsCommentPanel:ClickMore()
    print("哈哈哈哈哈===============")
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Other, {parent = self, sendcallback = function() self:OnSend() end},nil,false)
    end
    self.chatExtPanel:Show()
end


function MomentsCommentPanel:AppendInputElement(element)
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


function MomentsCommentPanel:CheckElement()
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
    if self.type == 2 then
        send_msg = string.format("{mention_1,%s,%s,%s,%s}%s", self.targetname, self.commentdata.commentator_id, self.commentdata.commentator_platform, self.commentdata.commentator_zone_id, send_msg)
        self.Mgr:Require11862(self.data.m_id, self.data.m_platform, self.data.m_zone_id, send_msg, {{rid = self.commentdata.commentator_id, platform = self.commentdata.commentator_platform, zone_id = self.commentdata.commentator_zone_id}})
    else
        self.Mgr:Require11862(self.data.m_id, self.data.m_platform, self.data.m_zone_id, send_msg, {})
    end
    self:Hiden()
    self.appendTab = {}
    return true
end


function MomentsCommentPanel:OnMsgChange(val)
    local len = string.utf8len(val)
end

function MomentsCommentPanel:OnReport()
    print(self.type)
    if self.type == 1 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("是否<color='#ffff00'>举报</color>%s<color='#ffff00'>本条状态</color>内容？\n（点击大图可举报图片，请勿恶意举报）"), self.data.name)
        data.sureLabel = TI18N("举报内容")
        data.cancelLabel = TI18N("取消")
        data.blueSure = true
        data.greenCancel = true
        data.sureCallback = function()ZoneManager.Instance:Require11869(self.data.m_id, self.data.m_platform, self.data.m_zone_id, 0, self.data.m_id) end
        NoticeManager.Instance:ConfirmTips(data)
    elseif self.type == 2 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("是否<color='#ffff00'>举报</color>%s<color='#ffff00'>本条评论</color>内容？"), self.targetname)
        data.sureLabel = TI18N("举报评论")
        data.cancelLabel = TI18N("取消")
        data.blueSure = true
        data.greenCancel = true
        data.sureCallback = function()ZoneManager.Instance:Require11869(self.data.m_id, self.data.m_platform, self.data.m_zone_id, 1, self.commentdata.id) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end