-- --------------------------------------------
-- 求助
-- hosr
-- --------------------------------------------
SosManager =  SosManager or BaseClass(BaseManager)

function SosManager:__init()
    if SosManager.Instance then
        return
    end
    SosManager.Instance = self
    self:InitHandler()

    self.chatShowTab = {}
    self.help_msg = {}
end

function SosManager:InitHandler()
    self:AddNetHandler(16000, self.On16000)
    self:AddNetHandler(16001, self.On16001)
    self:AddNetHandler(16002, self.On16002)
    self:AddNetHandler(16003, self.On16003)
    self:AddNetHandler(16004, self.On16004)
    self:AddNetHandler(16005, self.On16005)
end

function SosManager:RequestInitData()
    self:Send16001()
end

-- 发起求助
function SosManager:Send16000(help_id)
    self:Send(16000, {help_id = help_id})
end

function SosManager:On16000(dat)
    if dat.op_code == 1 then
        SosManager.Instance:Send16004()
    end

    if dat.msg ~= nil and dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

-- 获取已接收的求助消息
function SosManager:Send16001()
    self:Send(16001, {})
end

function SosManager:On16001(dat)
    BaseUtils.dump(dat,"SosManager:On16001(dat)")
    for i,v in ipairs(dat.help_msg) do
        self:AddChatNotice(v)
    end
end

-- 操作求助消息， 目前包含：新增、删除两种操作
function SosManager:Send16002()
    self:Send(16002, {})
end

function SosManager:On16002(dat)
    BaseUtils.dump(dat,"SosManager:On16002(dat)")
    local hasUpdate = false
    local updateCrossarena = false
    for i,v in ipairs(dat.del_help_msg) do
        -- 房间号不为空则代表是跨服约战的特殊类型
        if self.chatShowTab[v.id] ~= nil and self.chatShowTab[v.id].r_crossarena_roomid ~= nil then
            updateCrossarena = true
        end
        self.chatShowTab[v.id] = nil
        hasUpdate = true
    end
    for i,v in ipairs(dat.add_help_msg) do
        if v.digit_array ~= nil then
            for i,vvv in ipairs(v.digit_array) do
                if vvv.digit_key == 1 then
                    --任务ID
                    v.r_taskId = vvv.digit_val
                elseif vvv.digit_key == 2 then
                    --物品ID
                    v.r_itemId = vvv.digit_val
                elseif vvv.digit_key == 3 then
                    --物品数量
                    v.r_itemCnt = vvv.digit_val
                elseif vvv.digit_key == 4 then
                    --奖励经验
                    v.r_rewardExp = vvv.digit_val
                elseif vvv.digit_key == 5 then
                    --性别
                    v.r_sex = vvv.digit_val
                elseif vvv.digit_key == 6 then
                    --职业
                    v.r_classes = vvv.digit_val
                elseif vvv.digit_key == 7 then
                    --等级
                    v.r_lev = vvv.digit_val
                elseif vvv.digit_key == 14 then
                    --跨服约战房间id
                    v.r_crossarena_roomid = vvv.digit_val
                elseif vvv.digit_key == 15 then
                    --跨服约战频道
                    v.r_crossarena_channel = vvv.digit_val
                elseif vvv.digit_key == 16 then
                    --跨服约战招募类型
                    v.r_crossarena_recruittype = vvv.digit_val
                end
            end
        end
        if v.str_array ~= nil then
            for i,vvv in ipairs(v.str_array) do
                if vvv.str_key == 1000 then
                    --提示
                    v.r_tips = vvv.str_val
                elseif vvv.str_key == 1001 then
                    --求助者名称
                    v.r_name = vvv.str_val
                elseif vvv.str_key == 1002 then
                    --单位名称
                    v.r_unitName = vvv.str_val
                end
            end
        end
        if self.chatShowTab[v.id] ~= nil then
            self.chatShowTab[v.id] = nil
            ChatManager.Instance.model:UpdateHelp()

            if v.r_crossarena_channel ~= nil then
                ChatManager.Instance.model:UpdateCrossArena()
            end
        end
        self:AddChatNotice(v)
    end

    if hasUpdate then
        ChatManager.Instance.model:UpdateHelp()

        if updateCrossarena then
            ChatManager.Instance.model:UpdateCrossArena()
        end
    end
end

-- 加入辅助
function SosManager:Send16003(id)
    self:Send(16003, {id = id})
end

function SosManager:On16003(dat)
    if dat.op_code == 1 then
    end

    if dat.msg ~= nil and dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

function SosManager:Send16004()
    self:Send(16004, { })
end

function SosManager:On16004(dat)
    self.help_msg = dat.help_msg
end

function SosManager:Send16005(help_id)
    self:Send(16005, {help_id = help_id})
end

function SosManager:On16005(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

function SosManager:AddChatNotice(data)
    local content = nil
    local questId = nil
    for i,v in ipairs(data.str_array) do
        if v.str_key == SosEumn.StrKey.Default then
            content = v.str_val
        end
    end

    for i,v in ipairs(data.digit_array) do
        if v.digit_key == SosEumn.DigitKey.QuestId then
            questId = v.digit_val
        end
    end

    if content == nil or content == "" then
        return
    end

    local helpData = DataHelp.data_help[data.help_id]
    if helpData == nil then
        return
    end

    local msgData = MessageParser.GetMsgData(content)

    if helpData.type == SosEumn.Type.Guild then
        msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[MsgEumn.ChatChannel.Guild], msgData.showString)
    else
        msgData.showString = msgData.showString
    end

    NoticeManager.Instance.model.calculator:ChangeFoneSize(17)
    local allWidth = NoticeManager.Instance.model.calculator:SimpleGetWidth(msgData.sourceString)
    msgData.allWidth = allWidth
    local chatData = ChatData.New()
    chatData.showType = MsgEumn.ChatShowType.QuestHelp
    chatData.msgData = msgData
    local extra = {helpId = data.help_id, id = data.id}
    if data.digit_array ~= nil then
        extra.digit_array = data.digit_array
    end
    chatData.extraData = extra


    if data.r_id ~= nil then
        chatData.id = data.r_id
    end
    if data.r_platform ~= nil then
        chatData.platform = data.r_platform
    end
    if data.r_zone_id ~= nil then
        chatData.zone_id = data.r_zone_id
    end
    if data.r_sex ~= nil then
        chatData.sex = data.r_sex
    end
    if data.r_lev ~= nil then
        chatData.lev = data.r_lev
    end
    if data.r_classes ~= nil then
        chatData.classes = data.r_classes
    end
    if data.r_name ~= nil then
        chatData.name = data.r_name
    end

    if helpData.type == SosEumn.Type.Friend then
        chatData.prefix = MsgEumn.ChatChannel.Private
        chatData.channel = MsgEumn.ChatChannel.Private
    elseif helpData.type == SosEumn.Type.Guild then
        chatData.prefix = MsgEumn.ChatChannel.Guild
        chatData.channel = MsgEumn.ChatChannel.Guild
    end

    -- 如果数据里面有频道的话，不读配置按照数据里面的来处理
    if data.r_crossarena_channel ~= nil then
        chatData.prefix = data.r_crossarena_channel
        chatData.channel = data.r_crossarena_channel

        -- 有房间号则是跨服约战的特殊类型
        if data.r_crossarena_roomid ~= nil then
            chatData.r_crossarena_roomid = data.r_crossarena_roomid
            chatData.showType = MsgEumn.ChatShowType.CrossArena
        end

        if data.r_crossarena_recruittype ~= nil then
            chatData.r_crossarena_recruittype = data.r_crossarena_recruittype
        end
    end

    self.chatShowTab[data.id] = chatData
    ChatManager.Instance.model:ShowMsg(chatData)
end

function SosManager:RequestInitData()
    self:Send16004()
end