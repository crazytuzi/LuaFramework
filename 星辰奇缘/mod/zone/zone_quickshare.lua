-- 朋友圈快速分享
-- hzf
-- 16.09.08

ZoneQuickShare = ZoneQuickShare or BaseClass(BasePanel)

function ZoneQuickShare:__init(targettransform, str)
    self.Mgr = ZoneManager.Instance
    self.model = ZoneManager.Instance.model
    self.targettransform = targettransform
    self.defaultstr = str
    self.name = "ZoneQuickShare"
    self.appendTab = {}

    self.resList = {
        {file = AssetConfig.moment_quicksend_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.zone_textures, type  =  AssetType.Dep}
    }
    self.photos = {}
    self.thumbphotos = {}
    self.mentions = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    -- self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ZoneQuickShare:__delete()
    self.photos = nil
    self.thumbphotos = nil
    self.PhotoImgList.sprite = nil
    self.bigPhotoImg.sprite = nil
    self.sprite = nil
    if self.screenShot ~= nil then
        GameObject.Destroy(self.screenShot)
    end
    self.screenShot = nil
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

function ZoneQuickShare:InitPanel()
    self:Shot()
end

function ZoneQuickShare:AfterInitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.moment_quicksend_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)

    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.I18NLimitText = self.transform:Find("Main/I18NLimitText"):GetComponent(Text)
    self.InputField = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.InputField.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.InputFieldText = self.transform:Find("Main/InputField/Text"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText

    self.PhotoCon = self.transform:Find("Main/PhotoCon")
    self.FcaeButton = self.transform:Find("Main/FcaeButton"):GetComponent(Button)
    self.FcaeButton.onClick:AddListener(function() self:ClickMore() end)
    self.atButton = self.transform:Find("Main/atButton"):GetComponent(Button)
    self.atButton.onClick:AddListener(function() self:ShowFriendList() end)
    self.photoButton = self.transform:Find("Main/PhotoCon/Button"):GetComponent(Button)
    self.SendButton = self.transform:Find("Main/SendButton"):GetComponent(Button)
    self.ClearButton = self.transform:Find("Main/ClearButton"):GetComponent(Button)
    self.bigPhotoImg = self.transform:Find("BigPhoto/Image"):GetComponent(Image)
    self.bigPhotoBtn = self.transform:Find("BigPhoto"):GetComponent(Button)

    self.bigPhotoBtn.onClick:AddListener(function()
        self.bigPhotoBtn.gameObject:SetActive(false)
    end)
    self.ClearButton.onClick:AddListener(function()
        self:ClearAllMsg()
    end)
    self.CloseButton.onClick:AddListener(function() self:Hiden() end)
    self.SendButton.onClick:AddListener(function() self:OnSend() end)
    self.photoButton.onClick:AddListener(function()
        self.bigPhotoBtn.gameObject:SetActive(true)
    end)

    self.PhotoImgList = self.PhotoCon:Find("1"):GetComponent(Image)
    self.InputField.text = self.defaultstr
    self:UpdatePhoto()
end

function ZoneQuickShare:Shot()
    local pos = ctx.UICamera:WorldToScreenPoint(self.targettransform.position)
    local size = self.targettransform.sizeDelta
    local pivot = self.targettransform.pivot
    local prefsize = math.max(size.x, size.y)
    local rect = Rect(pos.x - size.x * pivot.x, pos.y-size.y*pivot.y, size.x, size.y)
    self.screenShot = Texture2D(rect.width, rect.height, TextureFormat.RGB24,false);
    local c=coroutine.create(function()
        Yield(WaitForEndOfFrame())
        self.screenShot:ReadPixels(rect, 0, 0);
        self.screenShot:Apply();
        local bitarry = self.screenShot:EncodeToJPG()
        print(bitarry.Length)
        if bitarry.Length > 307200 then
            self.screenShot = BaseUtils.ScaleTextureBilinear(self.screenShot, 307200/bitarry.Length)
            bitarry = self.screenShot:EncodeToJPG()
        end
        local thumbtex = BaseUtils.ScaleTextureBilinear(self.screenShot, 0.3)
        local thumbbitarry = thumbtex:EncodeToJPG()
        self.photos = {bitarry}
        self.thumbphotos = {thumbbitarry}
        self.sprite = Sprite.Create(self.screenShot, Rect(0, 0, rect.width, rect.height), Vector2(0.5, 0.5), 1)
        self:AfterInitPanel()
    end)
    coroutine.resume(c)
end

function ZoneQuickShare:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ZoneQuickShare:OnOpen()
    self.photos = {}
    -- self:UpdatePhoto()
end

function ZoneQuickShare:OnSend()
    local msg = self.InputField.text
    local len = string.len(msg)
    local len2 = string.utf8len(msg)
    if len2 > 140 then
        NoticeManager.Instance:FloatTipsByString(TI18N("消息长度超过限制，请修改"))
        return
    end
    if not self:CheckElement() and len>0 then
        local send_msg = MessageParser.ConvertToTag_Face(msg)
        self.Mgr:Require11858(send_msg, 1, self.photos, self.mentions, self.thumbphotos)
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

function ZoneQuickShare:ClickMore()
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Other, {parent = self, sendcallback = function() self:OnSend() end})
    end
    self.chatExtPanel:Show()
end


function ZoneQuickShare:AppendInputElement(element)
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


function ZoneQuickShare:CheckElement()
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
    self.Mgr:Require11858(send_msg, 1, self.photos, self.mentions, self.thumbphotos)
    self.photos = {}
    self.mentions = {}
    self.thumbphotos = {}
    self.photoeditor:Clear()
    self:Hiden()
    self.appendTab = {}
    return true
end


function ZoneQuickShare:OnMsgChange(val)
    local len = string.utf8len(val)
    if len < 140 then
        self.I18NLimitText.text = string.format(TI18N("(还能输入%s个字)"), tostring(140-len))
    else
        self.I18NLimitText.text = TI18N("<color='#ffff00'>内容超过长度限制</color>")
    end
    self.ClearButton.gameObject:SetActive(len > 0)
end

function ZoneQuickShare:AddMentions(List)
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

function ZoneQuickShare:ShowFriendList()
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

function ZoneQuickShare:AddMentionPlayer(data)
    for i,v in ipairs(self.mentions) do
        if v.rid == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
            return false
        end
    end
    table.insert(self.mentions, {rid = data.id, platform = data.platform, zone_id = data.zone_id})
    return true
end

function ZoneQuickShare:UpdatePhoto()
    if self.screenShot.width > self.screenShot.height then
        local scale = self.screenShot.height/self.screenShot.width
        self.bigPhotoImg.transform.sizeDelta = Vector2(400, 400*scale)
        print(self.PhotoImgList.transform.sizeDelta)
        self.PhotoImgList.transform.sizeDelta = Vector2(80, 80*scale)
    else
        local scale = self.screenShot.width/self.screenShot.height
        self.bigPhotoImg.transform.sizeDelta = Vector2(400*scale, 400)
        print(self.PhotoImgList.transform.sizeDelta)
        self.PhotoImgList.transform.sizeDelta = Vector2(80*scale, 80)
    end
    self.PhotoImgList.sprite = self.sprite
    self.bigPhotoImg.sprite = self.sprite
    self.PhotoImgList.gameObject:SetActive(true)
end

function ZoneQuickShare:ClearAllMsg()
    self.ClearButton.gameObject:SetActive(false)
    self.InputField.text = ""
    self.appendTab = {}
    self.mentions = {}
end