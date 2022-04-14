--
-- @Author: chk
-- @Date:   2018-09-04 19:40:29
--
BaseChatView = BaseChatView or class("BaseChatView", BaseItem)
local this = BaseChatView

function BaseChatView:ctor(parent_node, layer)

    self.not_read_msg = 0
    self.channel = nil
    self.sendMsgInfo = ""
    self.model = ChatModel.GetInstance()
    self.roleInfoModel = RoleInfoModel.GetInstance()
    self.roleData = self.roleInfoModel:GetMainRoleData()
    self.startVoiceTime = 0
    self.endVoiceTime = 0
    self.settors = {}
    self.events = {}
    self.localEvents = {}
    self.sendGoods = {}
    self.sendGoodsPos = {} --保留物品(表情)发送的位置相关信息
    self.sendGoodsPosTem = {}
    self.sendMsgTbl = {}
    self.hadSend = {}
    self.tmp_msg = ""
end

function BaseChatView:dctor()
    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end

    for i, v in pairs(self.localEvents) do
        self.model:RemoveListener(v)
    end

    self.localEvents = {}
    self.events = {}
    self.settors = {}
    self.model:DeleteChannelItems(self.channel)
    if self.countdownitem then
        self.countdownitem:destroy()
        self.countdownitem = nil
    end
end

function BaseChatView:LoadCallBack()
    self.nodes = {
        "ScrollView",
        "notRead",
        "cantChatTip",
        "notRead/Info/notReadText",
        "ScrollView/Viewport/Content",
        "bottom",
        "bottom/sendBtn",
        "bottom/faceBtn",
        "bottom/mapBtn",
        "bottom/voiceBtn",
        "bottom/TextInput",
        "voicebg",
        "voicebg/countdown",
    }

    self:GetChildren(self.nodes)

    --self.model.inlineManagers[self.channel] = self.inlineManager
    --self.model.inlineManagerScps[self.channel] = self.model.inlineManagers[self.channel]:GetComponent('InlineManager')
    --self.model.inlineManagerScps[self.channel]:LoadEmoji("asset/chatemoji_asset", "e", 0, 30)

    self.notReadTextTxt = self.notReadText:GetComponent('Text')
    self.scrollRect = self.ScrollView:GetComponent('ScrollRect')
    self.rectTra = self.ScrollView:GetComponent('RectTransform')
    self.contentRectTra = self.Content:GetComponent('RectTransform')
    self.InputText = self.TextInput:GetComponent('InputField')
    self:AddEvent()
    self:LoadItems()
    SetVisible(self.voicebg, false)

    local beg_idx, _end_idx = string.find("abcdef", 'd', 3)
    local end_idx = 3
    self:UpdateButtom()

    if not PlatformManager:IsCN() then
        SetVisible(self.voiceBtn,false)
    end
end

function BaseChatView:OnEnable()
    if self.cantChatTip ~= nil then
        SetVisible(self.cantChatTip.gameObject, false)
        self.model:SetChannelRead(self.channel)
        GlobalEvent:Brocast(ChatEvent.CheckHaveUnRead, self.channel)
    end
    self:UpdateButtom()
end

function BaseChatView:UpdateButtom()
    if ChatController:GetInstance():IsCrossScene() 
      and self.channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_SCENE 
      and self.channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD 
      and self.channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_P2P
      and self.channel ~= enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD then
        SetVisible(self.cantChatTip, true)
        SetVisible(self.bottom, false)
    else
        SetVisible(self.cantChatTip, false)
        SetVisible(self.bottom, true)
    end
end

function BaseChatView:AddEvent()
    AddClickEvent(self.sendBtn.gameObject, handler(self, self.SendMsg))

    --[[local function call_back()
        local heigh = self.model:GetChannelItemsHeight(self.channel)
        local y = heigh - self.rectTra.sizeDelta.y
        local spanY = y - self.contentRectTra.localPosition.y
        self:MoveMsgToEnd(spanY, y)
    end
    AddClickEvent(self.notRead.gameObject, call_back)--]]

    local function call_back()
        GlobalEvent:Brocast(ChatEvent.OpenEmojiView, true)
    end
    AddClickEvent(self.faceBtn.gameObject, call_back)

    --local function call_back()
    --    self.model:SendInScenePos(self.channel)
    --end
    AddClickEvent(self.mapBtn.gameObject, handler(self, self.SendInScenePos))

    local function call_back()
        self.startVoiceTime = UnityEngine.Time.realtimeSinceStartup
        self.file_name = self.roleData.id .. TimeManager.GetInstance():GetServerTime()
        self.model:Brocast(ChatEvent.StopVoiceAnimation)
        SoundManager.GetInstance():SetBackGroundMute(true)
        self.model.is_recording = true
        VoiceManager:GetInstance():StartRecording(self.file_name)
        SetVisible(self.voicebg, true)
        local param = {
            isShowMin = false,
            duration = 0.033,
            formatText = "You can still record %s sec",
            formatTime="%d",
        }
        if not self.countdownitem then
            self.countdownitem = CountDownText(self.countdown, param)
        else
            self.countdownitem:ActiveText()
        end
        self.countdownitem:StartSechudle(os.time()+60, handler(self,self.StopRecord))
    end
    AddDownEvent(self.voiceBtn.gameObject, call_back)

    local function call_back()
        self:StopRecord()
        self.model.is_recording = false
        SoundManager.GetInstance():SetBackGroundMute(false)
        if self.countdownitem then
            self.countdownitem:StopSchedule()
        end
    end
    AddUpEvent(self.voiceBtn.gameObject, call_back)

    local function call_back(state, file_name, fileid)
        if not state then
            return Notify.ShowText("Failed to upload audio message")
        end
        if self.gameObject.activeInHierarchy then
            local file_id = fileid
            local chat_info = file_id .. "@" .. file_name .. "@" .. self.voice_time
            ChatController.GetInstance():RequestSendChat(self.channel, 2, chat_info)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.UploadVoiceState, call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.CreateItemEnd, handler(self, self.DealCreateItemEnd))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.AddMsgItem, handler(self, self.ReceiveMessage))

    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickEmoji, handler(self, self.DealClickEmoji))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickGoods, handler(self, self.DealClickGoods))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickCommonLG, handler(self, self.DealClickCommonLG))
    self.events[#self.events + 1] = GlobalEvent:AddListener(ChatEvent.ClickMapPosition, handler(self, self.DealClickMapPosition))

    local function call_back(state, filename)
        VoiceManager:GetInstance():PlayRecordedFile(filename)
    end
    self.events[#self.events+1] = GlobalEvent:AddListener(EventName.DownloadVoiceState, call_back)

    local function call_back(ipt)
        self.sendMsgInfo = ipt
        if ipt == "" then
            self.sendGoodsPos = {}
            self.sendGoods = {}
        end
    end
    self.InputText.onValueChanged:AddListener(call_back)

    self.scrollRect.onValueChanged:AddListener(handler(self, self.ScrollChange))
end

function BaseChatView:StopRecord()
    local endVoiceTime = UnityEngine.Time.realtimeSinceStartup
    if endVoiceTime - self.startVoiceTime < 1 then
        Notify.ShowText(ConfigLanguage.Mix.TimeNotEnough)
    else
        VoiceManager:GetInstance():StopRecording()
        VoiceManager:GetInstance():UploadRecordedFile(self.file_name, 5000)
        self.voice_time = math.ceil(endVoiceTime - self.startVoiceTime)
    end
    SetVisible(self.voicebg, false)
end

--检查消息是否读了(创建时候调用)
function BaseChatView:CheckMsgNotRead(settor)
    --[[local spanY = (settor.y + 60) - self.contentRectTra.localPosition.y
    if spanY >= 0 and spanY <= self.rectTra.sizeDelta.y then
        settor.is_readed = true
    else
        settor.is_readed = false
        self.not_read_msg = self.not_read_msg + 1

        self:ChangeMsgReaded()
    end--]]
end

function BaseChatView:ChangeMsgReaded()
    --[[for i, v in pairs(self.settors) do
        if not v.is_readed then
            local spanY = (v.y + 60) - self.contentRectTra.localPosition.y
            if spanY >= 0 and spanY <= self.rectTra.sizeDelta.y then
                v.is_readed = true

                self.not_read_msg = self.not_read_msg - 1
                if self.not_read_msg < 0 then
                    self.not_read_msg = 0
                end
            end
        end

        self:SetMsgNotReadInfo()
    end--]]
end

function BaseChatView:ScrollChange()
    --self:ChangeMsgReaded()
end

function BaseChatView:DealClickEmoji(emojiName)
    if not self.gameObject.activeInHierarchy then
        return
    end

    local input_len = string.len(self.InputText.text)
    local name_len = string.len(emojiName)

    if input_len + name_len >= 300 then
        Notify.ShowText("Max length exceeded")
        return
    end
    --[[    self.sendGoodsPos[#self.sendGoodsPos+1] = {beg_idx = input_len + 1,end_idx = input_len + name_len,
                                                   type = 2, goods_name = index}--]]

    self.InputText.text = self.InputText.text .. emojiName
end

function BaseChatView:DealClickGoods(goods)
    if not self.gameObject.activeInHierarchy then
        return
    end

    local canAdd = true
    if table.nums(self.sendGoods) == 0 then
        canAdd = true
    elseif table.nums(self.sendGoods) < 4 then
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

function BaseChatView:DealClickCommonLG(info)
    if not self.gameObject.activeInHierarchy then
        return
    end

    self.InputText.text = self.InputText.text .. info
end

function BaseChatView:DealClickMapPosition(info)
    if not self.gameObject.activeInHierarchy then
        return
    end

    self.InputText.text = self.InputText.text .. info
end

function BaseChatView:SendMsg()
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
        --[[        for i, v in pairs(self.sendGoodsPos) do
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
            -- elseif string.lower(text) == "@out" and AppConfig.Filter then
            --     resMgr:OutPutFilterFileList()
            -- elseif string.lower(text) == "@out_show" and AppConfig.Filter then
            --     DebugManager:GetInstance():DebugFilter()
            -- elseif string.lower(text) == "@out_show_all" and AppConfig.Filter then
            --     DebugManager:GetInstance():DebugFilterAll()
        elseif string.lower(text) == "@gm" and not AppConfig.isOutServer then
            GlobalEvent:Brocast(InputManager.OpenGmPanel)
            return
        end
        ChatController.GetInstance():RequestSendChat(self.channel, 0, text, self.sendGoods)

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

--设置物品(表情的名字)
function BaseChatView:SetGoodsName(good_item)
    self.goods_name = string.sub(self.text_info, good_item.beg_idx, good_item.end_idx)
    if good_item.type == 2 then
        local goodsNameTbl = string.split(self.goods_name, "_")
        self.goods_name = tonumber(goodsNameTbl[2])
    end
end

--找到物品和表情后，设置插入正规表达式
--good_item 物品(表情)
function BaseChatView:SetInsertInfo(good_item)
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
        local beg_idx, end_idx = string.find(self.InputText.text, self.goods_name, self.offset_idx, true)
        local goodPos = GetGoodPos(good_item)
        goodPos.pre_insert = self.pre_insert
        goodPos.end_insert = self.end_insert
        goodPos.pre_insert_idx = beg_idx
        goodPos.end_insert_idx = end_idx

    else
        --[[local emojiName = self.model.inlineManagerScps[self.channel]:GetEmojiName(good_item.goods_idx,good_item.goods_name - 1)
        self.pre_insert = string.format("<a=%s#%s>",good_item.goods_idx, emojiName)
        self.end_insert = "</a>"
        self.goods_name = ""--]]
    end
end


--拼接信息
--good_item 物品(表情)
--text_info_beg_idx 不是物品(表情)的内容开始位置
--text_info_end_idx 不是物品(表情)的内容结束位置
function BaseChatView:SpliceMsg(good_item, text_info_beg_idx, text_info_end_idx)
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


--拼接发送的物品正则表达式
function BaseChatView:SpliceSendGoodMsg()
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

function BaseChatView:SpliceSendEmojiMsg2()
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

function BaseChatView:SpliceSendEmojiMsg()
    local from_idx = 1
    local emojiTbl = {}

    local pre_insert_idx = 1
    local end_insert_idx = 1

    --找表情是表情集中所有的都找一遍(表情可以重复的)
    local strLen = string.len(self._msg_info)
    for i = 1, 100 do
        --100够了，本来只有20个字

        if from_idx + 2 > strLen then
            break
        end

        local beg_idx, end_idx = string.find(self._msg_info, 'e_', from_idx)
        if beg_idx ~= nil then
            local emojiName = string.sub(self._msg_info, beg_idx, beg_idx + 3) --先找大的比如e_10

            --判断是否存在表情
            --local has = self.model.inlineManagerScps[self.channel]:GetContainEmojiName(0,emojiName)
            local has = self.model:IsContainEmojiName(emojiName)
            if not has then
                emojiName = string.sub(self._msg_info, beg_idx, beg_idx + 2) --再找小的比如e_1
                --has = self.model.inlineManagerScps[self.channel]:GetContainEmojiName(0,emojiName)
                has = self.model:IsContainEmojiName(emojiName)

                --找到后，设置在表情的前后位置插入正式表达式
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

            if has and not self:HasInsert(pre_insert_idx, emojiTbl) then
                local pre_insert = string.format("【%s", emojiName)
                local end_insert = "】"
                emojiTbl[#emojiTbl + 1] = { pre_insert_idx = pre_insert_idx, end_insert_idx = end_insert_idx,
                                            pre_insert = pre_insert, end_insert = end_insert }
            end
        else
            --设置重新找表情的位置
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

function BaseChatView:HasInsert(pre_index, t)
    for i = 1, #t do
        if t[i].pre_insert_idx == pre_index then
            return true
        end
    end
    return false
end

function BaseChatView:SetGoodsPos(good_item, text_info_beg_idx, text_info_end_idx)
    --截取不是物品的内容
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

function BaseChatView:SendInScenePos()
    if not self.hadSend[self.channel] then
        self.model:SendInScenePos(self.channel)
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

--设置未读消息的信息
function BaseChatView:SetMsgNotReadInfo()
    --[[if self.not_read_msg > 0 then
        if not self.notRead.gameObject.activeSelf then
            SetVisible(self.notRead, true)
        end

        self.notReadTextTxt.text = self.not_read_msg .. ConfigLanguage.ChatChn.NotRead
    elseif self.notRead.gameObject.activeSelf then
        SetVisible(self.notRead, false)
    end--]]
end

--验证发送的物品
function BaseChatView:VerificationGoods(good_item)
    self._good_beg_idx = nil
    self._good_end_idx = nil
    self.text_info = string.sub(self.InputText.text, self.text_beg_idx) --截取发送内容
    --local itemCfg = Config.db_item[v.item.id]

    self.pre_insert = ""
    self.end_insert = ""
    self:SetGoodsName(good_item)    --根据发送的物品在原始位置，截取物品名字
    --self.goods_name = string.sub(self.text_info,v.beg_idx,v.end_idx)

    if self.goods_name ~= good_item.goods_name then
        --不等 ，就是被编辑过
        self._good_beg_idx, self._good_end_idx = string.find(self.text_info, good_item.goods_name, 1, true) --从截取后的内容，直接找物品名字
        if self._good_beg_idx ~= nil and self._good_end_idx ~= nil then
            --找到了，
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

function BaseChatView:CheckDeleteChat()
    local nums = self.model:GetChannelItemsCount(self.channel)
    if nums >= ChatModel.MaxChatCount then
        local settor = table.remove(self.model:GetChannelItemsByChannel(self.channel), 1)
        settor:destroy()
    end
end

function BaseChatView:CreateChatItem(chatMsg)
    local settor = nil
    if chatMsg.sender then
        if chatMsg.sender.id == self.roleInfoModel:GetMainRoleId() then
            settor = SelfChatItemSettor(self.Content, "Bottom")
            self.InputText.text = ""
            self.sendMsg = ""
            self.sendGoods = {}
            self.sendGoodsPos = {}
        else
            settor = ChatItemSettor(self.Content, "Bottom")
        end
    else
        if chatMsg.channel_id == enum.CHAT_CHANNEL.CHAT_CHANNEL_SYS then
            settor = SysChatItem(self.Content, "Bottom")
        else
            settor = SysChatItem2(self.Content, "Bottom")
        end
    end

    table.insert(self.model:GetChannelItemsByChannel(chatMsg.channel_id), settor)
    self.settors = self.model:GetChannelItemsByChannel(chatMsg.channel_id)
    settor:SetInfo(chatMsg, self.scrollRect)
end

function BaseChatView:DealCreateItemEnd(chatMsg)
    if not self.channel == chatMsg.channel_id then
        return
    end

    local heigh = self.model:GetChannelItemsHeight(chatMsg.channel_id)

    if chatMsg.channel_id == self.channel then
        self.contentRectTra.sizeDelta = Vector2(self.contentRectTra.sizeDelta.x, heigh)
        local y = heigh - self.rectTra.sizeDelta.y
        --if self.model:GetChannelItemsCount(chatMsg.channel_id) >= ChatModel.MaxChatCount then
        local height = 0
        for i, v in pairs(self.model:GetChannelItemsByChannel(chatMsg.channel_id)) do
            if v.is_loaded then
                v.itemRectTra.localPosition = Vector3(0, -height, 0)
                v.y = height
                height = height + v.height
            end
        end
        --end


        if self.rectTra.sizeDelta.y < heigh then
            if self.model.isLockScreen then
                --锁屏了
                --[[if self.model:GetChannelItemsCount(chatMsg.channel_id) >= ChatModel.MaxChatCount then
                    local settor = table.getbyindex(self.model:GetChannelItemsByChannel(chatMsg.channel_id), 2)
                    local contentY = self.contentRectTra.localPosition.y - settor.y
                    if contentY < 0 then
                        contentY = 0
                    end
                    self.contentRectTra.localPosition = Vector2(self.contentRectTra.localPosition.x, contentY, 0)
                end

                local nums = table.nums(self.model:GetChannelItemsByChannel(chatMsg.channel_id))
                local settor = table.getbyindex(self.model:GetChannelItemsByChannel(chatMsg.channel_id), nums)--]]
                --self:CheckMsgNotRead(settor)
            else
                self.contentRectTra.localPosition = Vector2(self.contentRectTra.anchoredPosition.x, y, 0)
                self.not_read_msg = 0
                --SetVisible(self.notRead, true)
            end
        end
    end

    --[[if chatMsg.channel_id == self.channel and self.model.inlineManagers[chatMsg.channel_id] ~= nil then
        self.model.inlineManagers[chatMsg.channel_id]:SetAsLastSibling()
    end--]]
end

function BaseChatView:MoveMsgToEnd(spanY, y)
    self.moveTime = spanY / 500

    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.contentRectTra.transform)
    local action = cc.MoveTo(self.moveTime, 0, y, 0)
    cc.ActionManager:GetInstance():addAction(action, self.Content)
end

function BaseChatView:LoadItems()
    local msgs = self.model.msg_list_by_channel[self.channel] or {}
    for i, v in pairs(msgs) do
        v.isHadSended = true
        self:ReceiveMessage(v)
    end
    GlobalEvent:Brocast(ChatEvent.CheckHaveUnRead, self.channel)
end

function BaseChatView:ReceiveMessage(chatMsg)
    if chatMsg.channel_id == self.channel then
        self:CheckDeleteChat()
        self:CreateChatItem(chatMsg)
        local chat_panel = lua_panelMgr:GetPanel(ChatPanel)
        if chat_panel and chat_panel.isShow then
            chatMsg.is_read = true
        end
    end
end