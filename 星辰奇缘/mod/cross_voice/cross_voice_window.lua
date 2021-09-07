-- @author #pwj
-- @date 2018年6月8日,星期五

CrossVoiceWindow = CrossVoiceWindow or BaseClass(BaseWindow)

function CrossVoiceWindow:__init(model)
    self.model = model
    self.name = "CrossVoiceWindow"
    self.windowId = WindowConfig.WinID.CrossVoiceWindow
    self.cacheMode = CacheMode.Visible
    self.resList = {
        {file = AssetConfig.crossvoicewin, type = AssetType.Main}
        ,{file = AssetConfig.crossvoicedecorate, type = AssetType.Dep}
        ,{file = AssetConfig.crossvoicetexture, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self._SetLeftData = function() self:SetLeftData() end
    self._rightSend = function() self:ClearSendData() end

    self.appendTab = {}
    self.LeftItemList = {}
    self.SendPerson = nil
    self.SendMsg = nil
    self.SendItem = nil
end

function CrossVoiceWindow:__delete()
    self.OnHideEvent:Fire()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CrossVoiceWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossvoicewin))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseCrossVoiceWindow() end)

    self.MainCon = self.transform:Find("MainCon")
    self.topBigbg = self.MainCon:Find("TopBigbg"):GetComponent(Image)
    self.topBigbg.sprite = self.assetWrapper:GetSprite(AssetConfig.crossvoicedecorate,"crossvoicedecorate")
    self.topCon = self.MainCon:Find("TopCon")
    self.topNameBtn = self.topCon:Find("NameButton"):GetComponent(Button)
    self.topNameBtn.onClick:AddListener(function() self:OnFriendBtnClick() end)
    self.topNameText = self.topCon:Find("NameButton/Text"):GetComponent(Text)

    self.topNoticeBtn = self.topCon:Find("NoticeButton"):GetComponent(Button)
    self.topNoticeBtn.onClick:AddListener(function() self:OnFriendBtnClick() end)

    self.centerCon = self.MainCon:Find("CenterCon")
    self.centerTempletBtn = self.centerCon:Find("NoticeButton"):GetComponent(Button)
    self.centerTempletBtn.onClick:AddListener(function() self:OnTempletBtnClick() end)
    self.centerFaceBtn = self.centerCon:Find("TempletButton"):GetComponent(Button)
    self.centerFaceBtn.onClick:AddListener(function() self:OnFaceBtnClick() end)

    self.I18NLimitText = self.centerCon:Find("I18NLimitText"):GetComponent(Text)

    self.InputShadow = self.centerCon:Find("InputShadow"):GetComponent(Button)
    self.InputShadow.onClick:AddListener(function() self:OnInputShadow() end)

    self.InputField = self.centerCon:Find("InputField"):GetComponent(InputField)
    self.InputField.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.InputField.onEndEdit:AddListener(function(val) self:OnEndEdit(val) end)
    self.InputFieldText = self.centerCon:Find("InputField/Text"):GetComponent(Text)
    self.InputField.textComponent = self.InputFieldText

    self.BottomCon = self.MainCon:Find("BottomCon")
    self.ContentDecorate = self.BottomCon:Find("Image"):GetComponent(Image)

    self.MsgContainer = self.BottomCon:Find("ScrollLayer/Container")
    self.MsgLayout = LuaBoxLayout.New(self.MsgContainer,{axis = BoxLayoutAxis.Y, cspacing = 2, border = 2})
    --self.MsgItem = self.BottomCon:Find("ScrollLayer/Container/Text")
    self.ContentParent = self.BottomCon:Find("ScrollLayer/Container/Parent")
    self.ContentText = self.BottomCon:Find("ScrollLayer/Container/Parent/Text"):GetComponent(Text)
    self.MsgExt = MsgItemExt.New(self.ContentText, 384, 20, 23)
    self.MsgLayout:AddCell(self.ContentParent.gameObject)
    self.MsgExt:SetData("")

    self.afterCon = self.MainCon:Find("AfterCon")
    self.afterText = self.afterCon:Find("Text"):GetComponent(Text)

    self.afterCon2 = self.MainCon:Find("AfterCon2")
    self.goldAsset = self.afterCon2:Find("gold/asset"):GetComponent(Image)
    self.goldNum = self.afterCon2:Find("gold/Text"):GetComponent(Text)
    self.confirmBtn = self.MainCon:Find("ImgConfirmBtn"):GetComponent(Button)
    self.confirmBtn.onClick:AddListener(function() self:OnConfirmBtnClick() end)

    self.infoBtn = self.MainCon:Find("InfoBtn"):GetComponent(Button)
    self.infoBtn.onClick:AddListener(function() self:OnInfoBtnClick() end)

    self.descText = self.MainCon:Find("DescText"):GetComponent(Text)

    self.leftPanel = self.MainCon:Find("PanelLeft")
    self.LeftContainer = self.leftPanel:Find("ScrollLayer/Container")
    self.LeftLayout = LuaBoxLayout.New(self.LeftContainer,{axis = BoxLayoutAxis.Y, cspacing = 2, border = 2})
    self.leftItem = self.leftPanel:Find("ScrollLayer/Container/Cloner")
    self.leftItem.gameObject:SetActive(false)

end

function CrossVoiceWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CrossVoiceWindow:OnOpen()
    self:AddListeners()
    CrossVoiceManager.Instance.leftItemListChange:AddListener(self._SetLeftData)
    CrossVoiceManager.Instance.rightSendEvent:AddListener(self._rightSend)
    CrossVoiceManager.Instance:Send21000()
    CrossVoiceManager.Instance:Send21003()
    self:AppendInput("")
end

function CrossVoiceWindow:OnHide()
    self:RemoveListeners()
    CrossVoiceManager.Instance.leftItemListChange:RemoveListener(self._SetLeftData)
    CrossVoiceManager.Instance.rightSendEvent:RemoveListener(self._rightSend)
    if self.InputField ~= nil then
        self.InputField.text = ""
    end
    self:ClearSendData()
    self.SendItem = nil
end

function CrossVoiceWindow:AddListeners()
    self:RemoveListeners()
end

function CrossVoiceWindow:RemoveListeners()
end

function CrossVoiceWindow:SetLeftData()
    for i,v in ipairs(self.model.itemList) do
        if self.LeftItemList[i] == nil then
            local item = nil
            item = CrossVoiceItem.New(GameObject.Instantiate(self.leftItem.gameObject),self,i)
            item:update_my_self(v)
            self.LeftItemList[i] = item
            self.LeftLayout:AddCell(item.gameObject)
        else
            self.LeftItemList[i]:update_my_self(v)
        end
    end
    self:ClickLeftItem(1)
end

function CrossVoiceWindow:OnFriendBtnClick()
    local callBack = function(dat) self:SetTopConFriendText(dat)  end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack, 6 , 1})
end


function CrossVoiceWindow:OnTempletBtnClick()
    if self.SendPerson == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择需要传音的在线好友再进行赠言哟"))
        return
    end
    local callback = function(dat) self:SetTempletText(dat)  end
    self.model:OpenCrossVoiceContent({callback})
end


function CrossVoiceWindow:OnFaceBtnClick()
    if self.SendPerson == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择需要传音的在线好友再进行赠言哟"))
        return
    end
    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Other, {parent = self, sendcallback = function() self:AppendContent() end},nil,false)
    end
    self.chatExtPanel:Show()
end

function CrossVoiceWindow:OnConfirmBtnClick()
    local msg = self.InputField.text
    local len = string.len(msg)
    local len2 = string.utf8len(msg)
    if len2 >= 50 then
        NoticeManager.Instance:FloatTipsByString(TI18N("赠言内容已超过50个字符，请重新编辑后再进行发送{face_1,3}"))
        return
    end
    local roleName = RoleManager.Instance.RoleData.name
    local sendmsg = MessageParser.ConvertToTag_Face(msg)
    sendmsg = string.gsub(sendmsg, "\n", "")
    sendmsg = string.gsub(sendmsg, "\t", "")
    if self.SendPerson ~= nil then
        if sendmsg ~= "" and sendmsg ~= nil then
            --send_msg = send_msg.."@"..self.SendPerson.name 3CD8E7
            local send_msg = string.format(TI18N("<color='#ffff00'><color='#3cf6fd'>%s</color>对<color='#3cf6fd'>%s</color>说:%s</color>"), roleName, self.SendPerson.name, sendmsg)
            if BackpackManager.Instance:GetItemCount(self.SendItem.item_id) > 0 then
                CrossVoiceManager.Instance:Send21002(self.SendItem.item_id, send_msg, self.SendPerson.id, self.SendPerson.platform, self.SendPerson.zone_id)
            else
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("是否确认花费{assets_1,%d,%d}发送<color='#ffff00'>%s</color>"), self.SendItem.loss_type, self.SendItem.price, self.SendItem.item_name)
                data.sureLabel = TI18N("确 定")
                data.cancelLabel = TI18N("取 消")
                data.sureCallback = function()
                    CrossVoiceManager.Instance:Send21001(self.SendItem.item_id, send_msg, self.SendPerson.id, self.SendPerson.platform, self.SendPerson.zone_id)
                end
                NoticeManager.Instance:ConfirmTips(data)
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请填充传音内容再进行确认哟{face_1,3}"))
            return
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要传音的在线好友再进行确认"))
        return
    end
end

function CrossVoiceWindow:OnInfoBtnClick()
    TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData ={
            TI18N("1、可通过<color='#7FFF00'>商城购买或快捷购买</color>获得纸鹤传递心声\n2、需要选择<color='#ffff00'>一位好友</color>进行传递噢，纸鹤发送成功后对方将收到一份<color='#ffff00'>惊喜小礼品</color>\n3、可自行<color='#7FFF00'>选择或自行输入</color>传音内容")
        }
    })
end



function CrossVoiceWindow:OnMsgChange(value)
    local len = string.utf8len(value)
    if len <= 50 then
        self.I18NLimitText.text = string.format(TI18N("(还能输入%s个字)"), tostring(50-len))
    else
        self.I18NLimitText.text = TI18N("<color='#ffff00'>内容超过长度限制</color>")
    end
end

function CrossVoiceWindow:AppendInput(str)
    self.InputField.text = self.InputField.text .. str
end

function CrossVoiceWindow:AppendInputElement(element)
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
    self:AppendContent()
end

function CrossVoiceWindow:SetTopConFriendText(data)
    local str = ""
    if data[1] ~= nil then
        str = str..data[1].name
        self.topNameText.text = str
        self.SendPerson = data[1]
        self.InputShadow.gameObject:SetActive(false)
        self:AppendContent()
    end
end

function CrossVoiceWindow:SetTempletText(msg)
    local originStr = self.InputField.text
    --BaseUtils.dump(self.model.System_MsgList,"self.System_MsgList")
    local currStr = nil
    local timer = 0
    for i, v in pairs(self.model.System_MsgList) do
        currStr,timer = string.gsub(originStr, v.context, msg)
        if timer > 0 then break end
    end
    if timer > 0 then
        self.InputField.text = currStr
    else
        self:AppendInput(msg)
    end
    self:AppendContent()
end

function CrossVoiceWindow:ClickLeftItem(index)
    local item = nil
    for i,v in ipairs(self.LeftItemList) do
        if index == i then
            item = v
            v:SetSelected(true)
        else
            v:SetSelected(false)
        end
    end
    self:RefreshRightContent(index)
end

function CrossVoiceWindow:RefreshRightContent(index)
    -- print("点击第"..index.."个")

    local i = index
    if self.LeftItemList == nil or self.LeftItemList[i] == nil then return end
    local data = self.LeftItemList[i].data
    self.SendItem = data

    self.ContentDecorate.transform.anchoredPosition = Vector2(-5.4,7.5)
    self.ContentDecorate.transform.sizeDelta = Vector2(416.8,110)
    local VoiceData = MakeVoiceData.data_get_item_type
    if data.type_id == 51 then
        self.ContentDecorate.sprite = self.assetWrapper:GetSprite(AssetConfig.crossvoicetexture,"TextBg"..VoiceData[data.type_id].pic_id)
    else
        self.ContentDecorate.sprite = PreloadManager.Instance:GetSprite(AssetConfig.crossvoiceimgtexture, "TextBg"..VoiceData[data.type_id].pic_id)
        if data.type_id == 53 then
            self.ContentDecorate.transform.anchoredPosition = Vector2(-7.7,7.5)
            self.ContentDecorate.transform.sizeDelta = Vector2(421.3,110)
        end
    end
    self.goldAsset.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..data.loss_type)
    if BackpackManager.Instance:GetItemCount(data.item_id) > 0 then
        self.goldNum.text = TI18N("0")
    else
        self.goldNum.text = data.price
    end
    self:AppendContent()
end

function CrossVoiceWindow:OnInputShadow()
    if self.SendPerson == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择需要传音的在线好友再进行赠言哟"))
        return
    end
end

function CrossVoiceWindow:AppendContent()
    local str = ""
    if self.SendItem ~= nil and self.SendPerson ~= nil then
        self.SendMsg = self.InputField.text
        self.SendMsg = string.gsub(self.SendMsg, "\n", "")
        self.SendMsg = string.gsub(self.SendMsg, "\t", "")
        local reward = MakeVoiceData.data_get_all_item[self.SendItem.item_id].reward[1]
        if reward == nil then
            str = string.format("送给<color='#ffff00'>%s</color>，并赠言：%s", self.SendPerson.name, self.SendMsg)
        else
            str = string.format("送给<color='#ffff00'>%s</color>{item_2, %s, 1, 1}{assets_2,%s}，并赠言：%s", self.SendPerson.name, reward.item_id, reward.item_id, self.SendMsg)
        end
    end
    self.MsgExt:SetData(str)
    self.ContentParent.sizeDelta = Vector2(self.ContentParent.sizeDelta.x, self.MsgExt.selfHeight)
    self.MsgContainer.transform.sizeDelta = Vector2(self.MsgContainer.transform.sizeDelta.x, self.MsgExt.selfHeight)
end

function CrossVoiceWindow:OnEndEdit(val)
    self:AppendContent()
end

function CrossVoiceWindow:ClearSendData()
   self.SendPerson = nil
   self.SendMsg = nil
   self:SetLeftData()
   self.MsgExt:SetData("")
   if self.InputField ~= nil then
       self.InputField.text = ""
   end
   if self.topNameText ~= nil then
       self.topNameText.text = "点击右侧选择>>"
   end
   self.ContentParent.sizeDelta = Vector2(self.ContentParent.sizeDelta.x, self.MsgExt.selfHeight)
   self.MsgContainer.transform.sizeDelta = Vector2(self.MsgContainer.transform.sizeDelta.x, self.MsgExt.selfHeight)
   self.InputShadow.gameObject:SetActive(true)
end


