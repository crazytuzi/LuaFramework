FriendView = FriendView or class("FriendView", BaseItem)
local FriendView = FriendView
local tableInsert = table.insert

function FriendView:ctor(parent_node, layer, sub_index)
    self.abName = "mail"
    self.assetName = "FriendView"
    self.layer = layer

    self.model = FriendModel:GetInstance()
    FriendView.super.Load(self)
    self.sub_index = sub_index or self.model.select_role_id
    self.model.select_role_id = sub_index

    self.channel = ChatModel.PrivateChannel
    self.events = {}
    self.localEvents = {}
    self.chat_list = {}
    self.sendGoods = {}
    self.sendGoodsPos = {} --保留物品(表情)发送的位置相关信息
    self.hadSend = {}
    self.height = 0
    self.server_list = {}
end

function FriendView:dctor()
    if self.treemenu then
        self.treemenu:destroy()
    end
    if self.event_id then
        self.model:RemoveListener(self.event_id)
        self.event_id = nil
    end
    if self.event_id2 then
        self.model:RemoveListener(self.event_id2)
        self.event_id2 = nil
    end
    if self.event_id3 then
        GlobalEvent:RemoveListener(self.event_id3)
        self.event_id3 = nil
    end
    if self.event_id4 then
        self.model:RemoveListener(self.event_id4)
        self.event_id4 = nil
    end
    if self.event_id5 then
        GlobalEvent:RemoveListener(self.event_id5)
        self.event_id5 = nil
    end
    if self.event_id6 then
        GlobalEvent:RemoveListener(self.event_id6)
        self.event_id6 = nil
    end

    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end

    for i, v in pairs(self.localEvents) do
        self.model:RemoveListener(v)
    end
    if self.buttomView then
        self.buttomView:destroy()
    end
    for k, v in pairs(self.chat_list) do
        v:destroy()
    end
    if self.countdownitem then
        self.countdownitem:destroy()
        self.countdownitem = nil
    end
end

function FriendView:LoadCallBack()
    self.nodes = {
        "left/leftmenu", "left/addbtn", "left/managebtn", "left/applybtn", "right/nocontent", "right/messages",
        "right/messages/topbg/chating", "right/messages/topbg/online_icon", "right/messages/ScrollView/Viewport/Content",
        "right/messages/InputField/Text", "right/messages/sendbtn", "right/messages/ScrollView", "right/messages/InputField",
        "right/nocontent/nofrinedtips", "right/messages/topbg/title",
        "right/Buttom", "right/messages/facebtn", "right/messages/voicebtn", "right/messages/locationbtn",
        "right/messages/voicebg", "right/messages/voicebg/countdown","right/servers",
        "right/servers/ScrollView/Viewport/ServerContent",
        "right/servers/ScrollView/Viewport/ServerContent/EnemyServerItem",
    }

    self:GetChildren(self.nodes)
    self.chating = GetText(self.chating)
    self.online_icon = GetImage(self.online_icon)
    self.Text = GetText(self.Text)
    self.scrollRect = self.ScrollView:GetComponent('ScrollRect')
    self.rectTra = self.ScrollView:GetComponent('RectTransform')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
    self.InputText = self.InputField:GetComponent('InputField')
    self.nofrinedtips = GetText(self.nofrinedtips)
    self.title = GetText(self.title)
    self.EnemyServerItem_go = self.EnemyServerItem.gameObject
    SetVisible(self.EnemyServerItem_go, false)
    SetVisible(self.messages, false)
    SetVisible(self.nocontent, true)
    SetVisible(self.voicebg, false)
    SetVisible(self.servers, false)

    self:AddEvent()

    self:CreateEmoji()

    local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
    VoiceManager:GetInstance():SetGVoiceAppInfo(roleData.id)
    VoiceManager:GetInstance():ApplyMessageKey()

    FriendController:GetInstance():RequestContact()
end

function FriendView:AddEvent()
    local function call_back()
        self:InitMenu()
    end
    self.event_id = self.model:AddListener(FriendEvent.GetFriendList, call_back)

    self.event_id2 = self.model:AddListener(FriendEvent.UpdateFrinds, call_back)

    local function call_back(firstmenuid, role_id)
        if self.model:IsInBlack(role_id) then
            SetVisible(self.nocontent, true)
            SetVisible(self.messages, false)
            self.nofrinedtips.text = ConfigLanguage.Mail.BlackTips
        else
            SetVisible(self.nocontent, false)
            SetVisible(self.messages, true)
            self.select_role_id = role_id
            self:UpdateMessagesPanel()
        end
        self:UpdateChatTitle(firstmenuid, role_id)
        self.model.select_role_id = role_id
    end
    self.event_id3 = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.__cname, call_back)

    local function call_back(data)
        if data.to_role_id == self.select_role_id or
                (data.to_role_id == RoleInfoModel:GetInstance():GetMainRoleId()
                        and self.select_role_id == data.sender.id) then
            if lua_panelMgr:GetPanelOrCreate(MailPanel):IsShow() then
                self:AddMessage(data)
            end
        end
    end
    self.event_id4 = self.model:AddListener(FriendEvent.UpdateMessage, call_back)

    --[[local function call_back( message, height )
        self:Relayout(height)
    end
    self.event_id5 = GlobalEvent:AddListener(ChatEvent.CreateItemEnd, call_back)--]]

    local function call_back(ClickIndex, is_show)
        if ClickIndex == 5 then
            SetVisible(self.nocontent, false)
            SetVisible(self.messages, false)
            SetVisible(self.servers, true)
            self:UpdateServers()
        else
            SetVisible(self.nocontent, true)
            SetVisible(self.messages, false)
            SetVisible(self.servers, false)
            if ClickIndex == 4 then
                self.nofrinedtips.text = ConfigLanguage.Mail.BlackTips
            else
                self.nofrinedtips.text = ConfigLanguage.Mail.NoFriendTips
            end
        end
    end
    self.event_id6 = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.__cname, call_back)

    local function call_back(target, x, y)
        FriendController:GetInstance():RequestRecommend()
    end
    AddClickEvent(self.addbtn.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(FriendManagePanel):Open()
    end
    AddClickEvent(self.managebtn.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(FriendApplyPanel):Open()
    end
    AddClickEvent(self.applybtn.gameObject, call_back)

    local function call_back(target, x, y)
        self:SendMsg()
    end
    AddClickEvent(self.sendbtn.gameObject, call_back)

    local function call_back()
        GlobalEvent:Brocast(ChatEvent.OpenEmojiView, true)
    end
    AddClickEvent(self.facebtn.gameObject, call_back)

    local function call_back()
        --ChatModel.GetInstance():SendInScenePos(ChatModel.PrivateChannel)
        ChatModel.GetInstance():FriendSendScenePos(self.select_role_id)
    end
    AddClickEvent(self.locationbtn.gameObject, call_back)

    local function call_back()
        self.startVoiceTime = UnityEngine.Time.realtimeSinceStartup
        local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
        self.file_name = role_id .. TimeManager.GetInstance():GetServerTime()
        VoiceManager:GetInstance():StartRecording(self.file_name)
        SetVisible(self.voicebg, true)
        local param = {
            isShowMin = false,
            duration = 0.033,
            formatText = "You can still record %s sec",
            formatTime = "%d",
        }
        if not self.countdownitem then
            self.countdownitem = CountDownText(self.countdown, param)
        else
            self.countdownitem:ActiveText()
        end
        self.countdownitem:StartSechudle(os.time() + 60, handler(self, self.StopRecord))
    end
    AddDownEvent(self.voicebtn.gameObject, call_back)

    local function call_back()
        self:StopRecord()
        if self.countdownitem then
            self.countdownitem:StopSchedule()
        end
    end
    AddUpEvent(self.voicebtn.gameObject, call_back)

    local function call_back(state, file_name, fileid)
        if self.gameObject.activeInHierarchy then
            -- if state then
            local file_id = fileid
            local chat_info = file_id .. "@" .. file_name .. "@" .. self.voice_time
            ChatController.GetInstance():RequestSendChat(self.channel, 2, chat_info, nil, self.select_role_id)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.UploadVoiceState, call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ChatGoodsInfo, handler(self, self.DealChatGoodsInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.OpenEmojiView, handler(self, self.DealOpenEmojiView))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.CreateItemEnd, handler(self, self.DealCreateItemEnd))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickEmoji, handler(self, self.DealClickEmoji))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickGoods, handler(self, self.DealClickGoods))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickCommonLG, handler(self, self.DealClickCommonLG))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickMapPosition, handler(self, self.DealClickMapPosition))
    self.events[#self.events + 1] = GlobalEvent:AddListener(FightEvent.UpdateEnemy, handler(self,self.UpdateMenuAndServer))

    local function call_back(state, filename)
        VoiceManager:GetInstance():PlayRecordedFile(filename)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.DownloadVoiceState, call_back)

    local function call_back(ipt)
        self.sendMsgInfo = ipt
        if ipt == "" then
            self.sendGoodsPos = {}
            self.sendGoods = {}
        end
    end
    self.InputText.onValueChanged:AddListener(call_back)
end

function FriendView:UpdateServers()
    local servers = SiegewarModel.GetInstance():GetEnemies()
    for i=1, #servers do
        local item = self.server_list[i] or EnemyServerItem(self.EnemyServerItem_go, self.ServerContent)
        item:SetData(servers[i])
        self.server_list[i] = item
    end
end

function FriendView:StopRecord()
    local endVoiceTime = UnityEngine.Time.realtimeSinceStartup
    if endVoiceTime - self.startVoiceTime < 1 then
        Notify.ShowText(ConfigLanguage.Mix.TimeNotEnough)
    else
        VoiceManager:GetInstance():StopRecording()
        VoiceManager:GetInstance():UploadRecordedFile(self.file_name)
        self.voice_time = math.ceil(endVoiceTime - self.startVoiceTime)
    end
    SetVisible(self.voicebg, false)
end

--设置物品(表情的名字)
function FriendView:SetGoodsName(good_item)
    self.goods_name = string.sub(self.text_info, good_item.beg_idx, good_item.end_idx)
    if good_item.type == 2 then
        local goodsNameTbl = string.split(self.goods_name, "_")
        self.goods_name = tonumber(goodsNameTbl[2])
    end
end

--good_item 物品(表情)
function FriendView:SetInsertInfo(good_item)
    local function GetGoodPos(good_item)
        for i, v in pairs(self.sendGoodsPos) do
            if v.type == 1 and v.item.uid == good_item.item.uid then
                return v
            end
        end
    end

    if good_item.type == 1 then
        --1为物品，2为表情
        local itemCfg = Config.db_item[good_item.item.id]
        self.pre_insert = string.format("<color=#%s><a href=goods_%s>", ColorUtil.GetColor(itemCfg.color),
                good_item.item.uid)
        self.end_insert = "</a></color>"

        self.goods_name = good_item.goods_name

        local beg_idx, end_idx = string.find(self.InputText.text, self.goods_name, self.offset_idx)
        local goodPos = GetGoodPos(good_item)
        goodPos.pre_insert = self.pre_insert
        goodPos.end_insert = self.end_insert
        goodPos.pre_insert_idx = beg_idx
        goodPos.end_insert_idx = end_idx

    else
        --[[local emojiName = self.model.inlineManagerScp:GetEmojiName(good_item.goods_idx,good_item.goods_name - 1)
        self.pre_insert = string.format("<a=%s#%s>",good_item.goods_idx, emojiName)
        self.end_insert = "</a>"
        self.goods_name = ""]]
    end
end


--拼接信息
--good_item 物品(表情)
--text_info_beg_idx 不是物品(表情)的内容开始位置
--text_info_end_idx 不是物品(表情)的内容结束位置
function FriendView:SpliceMsg(good_item, text_info_beg_idx, text_info_end_idx)
    --截取不是物品的内容(物品之间穿插的内容)
    if good_item.beg_idx ~= 1 then
        self._msg_info = self._msg_info .. string.sub(self.text_info, text_info_beg_idx, text_info_end_idx)
    end

    --拼接
    self._msg_info = self._msg_info .. self.pre_insert
    self._msg_info = self._msg_info .. self.goods_name
    self._msg_info = self._msg_info .. self.end_insert

    if self.text_beg_idx ~= 1 then
        --表示原始内容编辑过
        self.info_beg_idx = self._good_end_idx + 1
        self.last_goods_end_idx = self._good_end_idx + 1
    else
        if good_item.beg_idx == 1 and self._msg_info == "" then
            --只发一个物品，并且编辑过
            self.info_beg_idx = 1  --物品结束下标的下一个
            self.last_goods_end_idx = 1
        else
            self.info_beg_idx = good_item.end_idx + 1  --物品结束下标的下一个
            self.last_goods_end_idx = good_item.end_idx + 1
        end
    end
end

function FriendView:SpliceSendGoodMsg()
    function get_goods(item_name, from)
        item_name = "[" .. item_name .. "]"
        for i = from, #self.sendGoodsPos do
            local item = self.sendGoodsPos[i]
            if item.goods_name == item_name then
                return i, item
            end
        end
    end

    local content = self.InputText.text
    local matches = {}
    for w in string.gmatch(content, "%[(.-)%]") do
        matches[#matches + 1] = w
    end
    local from = 1
    for i = 1, #matches do
        local item_name = matches[i]
        local tmp_from, item = get_goods(item_name, from)
        if item then
            from = tmp_from + 1
            local tmp_name = "【" .. item_name .. "】"
            local item_name = "%[" .. item_name .. "%]"
            local good_item = item.item
            local itemCfg = Config.db_item[good_item.id]
            local send_name = string.format("<color=#%s><a href=goods_%s>%s</a></color>", ColorUtil.GetColor(itemCfg.color),
                    good_item.uid, tmp_name)
            content = string.gsub(content, item_name, send_name)
        end
    end
    return content
end

function FriendView:SpliceSendEmojiMsg2()
    local content = self._msg_info
    local matches = {}
    for w in string.gmatch(content, "e_%d%d") do
        matches[w] = 1
    end
    for w, _ in pairs(matches) do
        content = string.gsub(content, w, "【" .. w .. "】")
    end
    return content
end

function FriendView:SpliceSendEmojiMsg()
    local from_idx = 1
    local emojiTbl = {}

    local pre_insert_idx = 1
    local end_insert_idx = 1

    local strLen = string.len(self._msg_info)
    for i = 1, 100 do
        --100够了，本来只有20个字

        if from_idx + 2 > strLen then
            break
        end

        local beg_idx, end_idx = string.find(self._msg_info, 'e_', from_idx)
        if beg_idx ~= nil then
            local emojiName = string.sub(self._msg_info, beg_idx, beg_idx + 3) --先找大的比如e_10

            local has = self.model.inlineManagerScp:GetContainEmojiName(0, emojiName)
            if not has then
                emojiName = string.sub(self._msg_info, beg_idx, beg_idx + 2) --再找小的比如e_1
                has = self.model.inlineManagerScp:GetContainEmojiName(0, emojiName)

                if has then
                    pre_insert_idx = beg_idx
                    end_insert_idx = beg_idx + 2

                    from_idx = from_idx + 2
                else
                    from_idx = from_idx + 1
                end
            else
                pre_insert_idx = beg_idx
                end_insert_idx = beg_idx + 3

                from_idx = from_idx + 3
            end

            if has then
                local pre_insert = string.format("【%s", emojiName)
                local end_insert = "】"
                emojiTbl[#emojiTbl + 1] = { pre_insert_idx = pre_insert_idx, end_insert_idx = end_insert_idx,
                                            pre_insert = pre_insert, end_insert = end_insert }
            end
        else
            from_idx = from_idx + 1
        end
    end

    local msg = ""
    from_idx = 1
    for i, v in pairs(emojiTbl) do
        --先截取不是物品或者表情的字符
        if v.pre_insert_idx ~= nil and v.pre_insert_idx ~= 1 then
            local _msg = string.sub(self._msg_info, from_idx, v.pre_insert_idx - 1)
            msg = msg .. _msg
        end

        if v.pre_insert ~= nil then
            --插入物品(表情)前缀
            msg = msg .. v.pre_insert
            --拼接物品(表情)后缀
            msg = msg .. v.end_insert

            from_idx = v.end_insert_idx + 1
        end

    end

    if from_idx < string.len(self._msg_info) then
        msg = msg .. string.sub(self._msg_info, from_idx)
    end

    return msg

end



--验证发送的物品
function FriendView:VerificationGoods(good_item)
    self._good_beg_idx = nil
    self._good_end_idx = nil
    self.text_info = string.sub(self.InputText.text, self.text_beg_idx)
    --local itemCfg = Config.db_item[v.item.id]

    self.pre_insert = ""
    self.end_insert = ""
    self:SetGoodsName(good_item)
    --self.goods_name = string.sub(self.text_info,v.beg_idx,v.end_idx)

    if self.goods_name ~= good_item.goods_name then
        --不等 ，就是被编辑过
        self._good_beg_idx, self._good_end_idx = string.find(self.text_info, good_item.goods_name)
        if self._good_beg_idx ~= nil and self._good_end_idx ~= nil then
            self:SetInsertInfo(good_item)
            self.text_beg_idx = self._good_end_idx + 1
            self.offset_idx = self.offset_idx + self.text_beg_idx

            self.info_end_idx = self._good_beg_idx - 1

            self:SpliceMsg(good_item, 1, self.info_end_idx)
        else
            self.deleteGoods[#self.deleteGoods + 1] = good_item.item
            self.goods_name = ""

            self.info_beg_idx = self.last_goods_end_idx
            --text_beg_idx = v.beg_idx
        end
    else
        --相等，找得到
        self:SetInsertInfo(good_item)

        if self.text_beg_idx ~= 1 then
            --表示原始内容编辑过
            self.text_beg_idx = good_item.beg_idx
            self.offset_idx = self.offset_idx + good_item.beg_idx

            self.info_end_idx = self._good_beg_idx - 1
        else
            self.info_end_idx = good_item.beg_idx - 1   --物品的开始下标的前一个
        end

        self:SpliceMsg(good_item, self.info_beg_idx, self.info_end_idx)
        --截取不是物品的内容
    end
end

function FriendView:SetData(data)

end

function FriendView:CreateEmoji()
    --self.model.inlineManager = newObject(self.inlineManager)
    --self.model.inlineManager.transform:SetParent(self.Content)
    --self.model.inlineManagerScp = self.model.inlineManager:GetComponent('InlineManager')
    --self.model.inlineManagerScp:LoadEmoji("asset/chatemoji_asset","e",0,30)


end

function FriendView:CleanEmoji()
    --[[if self.model.inlineManager ~= nil then
        destroyImmediate(self.model.inlineManager.gameObject)
    end--]]
end

function FriendView:DealClickEmoji(emojiName)
    if not self.gameObject.activeInHierarchy then
        return
    end

    local input_len = string.len(self.InputText.text)
    local name_len = string.len(emojiName)

    if input_len + name_len >= 300 then
        Notify.ShowText("Max length exceeded")
        return
    end

    --[[	self.sendGoodsPos[#self.sendGoodsPos+1] = {beg_idx = input_len + 1,end_idx = input_len + name_len,
                                                   type = 2, goods_name = index}--]]

    self.InputText.text = self.InputText.text .. emojiName
end

function FriendView:DealClickGoods(goods)
    if not self.gameObject.activeInHierarchy then
        return
    end

    local canAdd = true
    if table.nums(self.sendGoods) == 0 then
        canAdd = true
    elseif table.nums(self.sendGoods) < 5 then
        for i, v in pairs(self.sendGoods) do
            if v.uid == goods.uid then
                canAdd = false
                break
            end
        end
    else
        Notify.ShowText("Max length exceeded")
        return
    end

    if canAdd then
        table.insert(self.sendGoods, goods)

        local itemCfg = Config.db_item[goods.id]
        local item_name = string.format("[%s]", itemCfg.name)
        --[[local goodsInfo = string.format("<color=#%s><a href=goods_%s>%s</a></color>", ColorUtil.GetColor(itemCfg.color),
                goods.uid, item_name)--]]

        local input_len = string.len(self.InputText.text)
        local name_len = string.len(item_name)

        self.sendGoodsPos[#self.sendGoodsPos + 1] = { type = 1, goods_name = item_name, item = goods }
        self.InputText.text = self.InputText.text .. item_name
    end
end

function FriendView:DealClickCommonLG(info)
    if not self.gameObject.activeInHierarchy then
        return
    end

    self.InputText.text = self.InputText.text .. info
end

function FriendView:DealClickMapPosition(info)
    if not self.gameObject.activeInHierarchy then
        return
    end

    self.InputText.text = self.InputText.text .. info
end

function FriendView:DealChatGoodsInfo(goodsInfo)
    if not self.gameObject.activeInHierarchy then
        return
    end
    --param包含参数
    --cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
    --p_item 服务器给的，服务器没给，只传cfg就好
    --model 管理该tip数据的实例
    --operate_param --操作参数

    local param = {}
    --local code, infoTbl = pcall(loadstring(string.format("do local _=%s return _ end", goodsInfo)))
    local bagId = BagModel.Instance:GetBagIdByUid(goodsInfo.uid)
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    param["item_id"] = goodsInfo.id
    param["p_item"] = goodsInfo
    if enum.ITEM_STYPE.ITEM_STYPE_WEAPON <= goodsInfo.uid and enum.ITEM_STYPE.ITEM_STYPE_LOCK >= goodsInfo.uid then
        param["model"] = BagModel.Instance
    elseif bagId == BagModel.bagId or bagId == BagModel.wareHouseId then
        param["model"] = BagModel.Instance
    elseif bagId == BagModel.beast then
        param["model"] = BeastModel.Instance
    else
        param["model"] = BagModel.Instance
    end

    if Config.db_item[goodsInfo.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or Config.db_item[goodsInfo.id].type ==
            enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        local tipView = EquipTipView(UITransform)
        tipView:ShowTip(param)
    else
        local tipView = GoodsTipView(UITransform)
        tipView:ShowTip(param)
    end
end

function FriendView:DealOpenEmojiView(show)
    if not self.gameObject.activeInHierarchy then
        return
    end

    if self.buttomView == nil then
        self.buttomView = ChatButtomView(self.Buttom)
    end

    if not show then
        self.buttomView:destroy()
        self.buttomView = nil
    end

end

function FriendView:DealCreateItemEnd(chatMsg)
    if not self.gameObject.activeInHierarchy then
        return
    end

    local heigh = 0
    for i, v in pairs(self.chat_list) do
        heigh = heigh + v.height + 5
    end
    if chatMsg.channel_id == self.channel then
        self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x, heigh)
        local y = heigh - self.rectTra.sizeDelta.y
        --if self.model:GetChannelItemsCount(chatMsg.channel_id) >= ChatModel.MaxChatCount then
        local height = 0
        for i, v in pairs(self.chat_list) do
            if v.is_loaded then
                v.itemRectTra.localPosition = Vector3(0, -height, 0)
                v.y = height
                height = height + v.height
            end
        end
        --end


        self.contentRectTra.localPosition = Vector2(self.contentRectTra.anchoredPosition.x, y, 0)
    end

    --[[if chatMsg.channel_id == self.channel and  self.model.inlineManager ~= nil then
        self.model.inlineManager:SetAsLastSibling()
    end--]]
end

function FriendView:UpdateMenuAndServer()
    self:InitMenu()
    self:UpdateServers()
end


--data:第一层菜单数据,数组[[id,name], ... ]
--sub_data:子菜单数据, [[父菜单id]=[[id,name], ...],...]
function FriendView:UpdateView()
    self:InitMenu()
end

function FriendView:InitMenu()
    --[[if self.treemenu then
        self.treemenu:destroy()
    end--]]
    local data = {}
    local sub_data = {}
    --联系人
    local contact_list = self.model:GetContactList()
    local num, total_num = self.model:GetOnlineNum(contact_list)
    self:AddSubData(sub_data, 1, contact_list)
    tableInsert(data, { 1, string.format(ConfigLanguage.Mail.Contact, num, total_num) })
    --好友
    local friend_list = self.model:GetFriendList()
    num, total_num = self.model:GetOnlineNum(friend_list)
    self:AddSubData2(sub_data, 2, friend_list)
    tableInsert(data, { 2, string.format(ConfigLanguage.Mail.FriendList, num, total_num) })
    --敌人
    local enemy_list = self.model:GetEnemyList()
    num, total_num = self.model:GetOnlineNum(enemy_list)
    self:AddSubData(sub_data, 3, enemy_list)
    tableInsert(data, { 3, string.format(ConfigLanguage.Mail.EnemyList, num, total_num) })
    --黑名单
    local black_list = self.model:GetBlackList()
    num, total_num = self.model:GetOnlineNum(black_list)
    self:AddSubData(sub_data, 4, black_list)
    tableInsert(data, { 4, string.format(ConfigLanguage.Mail.BlackList, num, total_num) })
    --敌对
    local enemies = SiegewarModel:GetInstance():GetEnemies()
    num, total_num = 0, 0
    for i=1, #enemies do
        if enemies[i].is_enemy then
            num = num + 1
        end
        total_num = total_num + 1
    end
    self:AddSubData(sub_data, 5, {})
    tableInsert(data, { 5, string.format("Enemy (%s/%s)", num, total_num) })

    if not self.treemenu then
        self.treemenu = FriendTreeMenu(self.leftmenu, nil, self, false, true)
        self.treemenu:SetData(data, sub_data, 0, 2)
    else
        self.treemenu:UpdateData(data, sub_data)
    end

    self.sub_data = sub_data
    self.nofrinedtips.text = ConfigLanguage.Mail.NoFriendTips
    if self.sub_index and self.sub_index ~= 0 then
        if not self.event_default then
            self.event_default = GlobalSchedule:StartOnce(handler(self, self.DelaySelectFirstMenuDefault), 0.09)
        end
    end
end

function FriendView:UpdateShow(sub_index)
    if sub_index ~= 0 then
        self.sub_index = sub_index
        if not self.event_default then
            self.event_default = GlobalSchedule:StartOnce(handler(self, self.DelaySelectFirstMenuDefault), 0.09)
        end
    end
end

function FriendView:AddSubData(sub_data, parent_id, list)
    sub_data[parent_id] = {}
    for _, pfriend in pairs(list) do
        local role_id = pfriend.base.id
        tableInsert(sub_data[parent_id], { role_id, "" })
    end
end

function FriendView:AddSubData2(sub_data, parent_id, list)
    sub_data[parent_id] = {}
    local tmp = {}
    for _, pfriend in pairs(list) do
        tmp[#tmp + 1] = pfriend
    end
    local function sort_friend(a, b)
        local a1 = a.is_online and 1 or 0
        local b1 = b.is_online and 1 or 0
        return a1 > b1
    end
    table.sort(tmp, sort_friend)
    for i = 1, #tmp do
        local pfriend = tmp[i]
        local role_id = pfriend.base.id
        tableInsert(sub_data[parent_id], { role_id, "" })
    end
end

function FriendView:GetFirstIndex()
    for index, sub_item in pairs(self.sub_data) do
        for i = 1, #sub_item do
            if self.sub_index == sub_item[i][1] then
                return index
            end
        end
    end
    return 0
end

function FriendView:DelaySelectFirstMenuDefault()
    GlobalEvent:Brocast(CombineEvent.SelectFstMenuDefault .. self.__cname, self:GetFirstIndex())
    GlobalSchedule:StartOnce(handler(self, self.DelaySelectSecondMenu), 0.09)
end

function FriendView:DelaySelectSecondMenu()
    GlobalEvent:Brocast(CombineEvent.SelectSecMenuDefault .. self.__cname, self.sub_index)
    self.sub_index = 0
end

function FriendView:UpdateMessagesPanel()

    self:CleanEmoji()
    self:CreateEmoji()

    local pfriend = self.model:GetPFriend(self.select_role_id)
    local role = pfriend.base
    local online_img = "friend_online"
    if not pfriend.is_online then
        online_img = "friend_offline"
    end
    lua_resMgr:SetImageTexture(self, self.online_icon, 'mail_image', online_img, true)
    self.chating.text = string.format(ConfigLanguage.Mail.FriendChating, role.name)
    for i = 1, #self.chat_list do
        self.chat_list[i]:destroy()
    end
    self.chat_list = {}
    self.height = 0
    local messages = self.model:GetMessages(self.select_role_id)
    for i = 1, #messages do
        self:AddMessage(messages[i])
    end
    GlobalEvent:Brocast(FriendEvent.UpdateMainChatButton)
end

function FriendView:AddMessage(message)
    self.model:UpdateReadMessage(message)
    local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
    local chatitem
    local count = #self.chat_list
    if count > 20 then
        self.chat_list[1]:destroy()
        table.remove(self.chat_list, 1)
    end
    if message.sender.id == main_role_id then
        chatitem = FriendSelfChatItem(self.Content)
        self.InputText.text = ""
        self.sendGoods = {}
        self.sendGoodsPos = {}
    else
        chatitem = FriendChatItem(self.Content)
    end
    tableInsert(self.chat_list, chatitem)
    chatitem:SetInfo(message, self.scrollRect)
end

function FriendView:Relayout(height)
    self.height = self.height + height
    local y = self.height - self.rectTra.sizeDelta.y
    local spanY = y - self.Content.localPosition.y
    --self:MoveMsgToEnd(spanY, y)
end

function FriendView:MoveMsgToEnd(spanY, y)
    self.moveTime = 0-- spanY / 500

    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.Content.transform)
    local action = cc.MoveTo(self.moveTime, 0, y, 0)
    cc.ActionManager:GetInstance():addAction(action, self.Content)
end

function FriendView:UpdateChatTitle(firstmenuid, role_id)
    local title = ""
    if firstmenuid == 1 then
        if self.model:IsFriend(role_id) then
            title = ConfigLanguage.Mail.FriendChatTitle
        else
            title = ConfigLanguage.Mail.StrangerChatTitle
        end
    elseif firstmenuid == 2 then
        title = ConfigLanguage.Mail.FriendChatTitle
    elseif firstmenuid == 3 then
        title = ConfigLanguage.Mail.EnemyChatTitle
    end
    self.title.text = title
end

function FriendView:SendMsg()
    local text = self.InputText.text
    if string.len(text) >= 300 then
        return Notify.ShowText("Max length exceeded")
    end
    local saiziNum = string.match(text, "Ako(%d)Ako")
    if not self.hadSend[self.channel] or saiziNum then
        self.text_info = self.InputText.text
        self._msg_info = ""
        self.text_beg_idx = 1    --截取发送内容，开始位置。到结束, 为1的话就是发送的内容没有被编辑过
        self.offset_idx = 1      --偏移位置，相对于发送内容，用来从原始内容截取物品
        self.info_beg_idx = 1    --不是物品(表情)内容(文字)的开始位置,被编辑过的话，按照截取后的内容算的
        self.info_end_idx = 0    --不是物品(表情)内容(文字)的结束位置,被编辑过的话，按照截取后的内容算的
        self.last_goods_end_idx = 1
        self.last_goods = nil    --上一个匹配到的物品或者表情
        self._good_beg_idx = nil --原始内容被编辑过，找到的物品(表情)开始位置，被编辑过的话，按照截取后的内容算的
        self._good_end_idx = nil --原始内容被编辑过，找到的物品(表情)结束位置,被编辑过的话，按照截取后的内容算的

        self.pre_insert = ""
        self.end_insert = ""
        self.goods_name = ""


        --self.deleteGoods = {} --编辑过被删除的物品

        --local emojiNameCount = self.model.inlineManagerScps[self.channel]:GetEmojiNums(0)
        --验证发送的物品
        --找到物品，再在物品前面和后面加标签
        --[[for i, v in pairs(self.sendGoodsPos) do
            if v.type == 1 then
                self:VerificationGoods(v)
            end
        end--]]

        self._msg_info = self:SpliceSendGoodMsg()
        --拼接完物品后，再重新找表情
        self._msg_info = self:SpliceSendEmojiMsg2()

        if self._msg_info == "" then
            self._msg_info = string.sub(self.InputText.text, 1)
        end
        text = self._msg_info

        --[[        for i, v in pairs(self.deleteGoods) do
                    table.removebyvalue(self.sendGoods,v)
                end--]]


        if self.InputText.text == "" then
            Notify.ShowText(ConfigLanguage.ChatChn.NotEmpty)
            return
        elseif string.lower(text) == "@out" and AppConfig.Filter then
            resMgr:OutPutFilterFileList()
        elseif string.lower(text) == "@gm" and AppConfig.Debug then
            GlobalEvent:Brocast(InputManager.OpenGmPanel)
            return
        end
        ChatController.GetInstance():RequestSendChat(self.channel, 0, text, self.sendGoods, self.model.select_role_id)

        local cd_time = ChatModel.channel_cd[self.channel] or 0
        if cd_time > 0 then
            self.hadSend[self.channel] = true
            local function call_back()
                self.hadSend[self.channel] = false
            end
            GlobalSchedule:StartOnce(call_back, cd_time)
        end
    else
        local cd_time = ChatModel.channel_cd[self.channel] or 0
        Notify.ShowText(string.format("The talk CD of this channel is %s sec", cd_time))
    end
end


