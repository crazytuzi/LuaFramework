-- ----------------------------------------
-- 消息分发
-- hosr
-- 把消息分发到聊天和消息提示
-- ----------------------------------------
MsgDispatcher = MsgDispatcher or BaseClass()

function MsgDispatcher:__init()
    self.mgr = NoticeManager.Instance
    self.model = self.mgr.model
end

function MsgDispatcher:__delete()
end

function MsgDispatcher:Dispatch(notice)
    -- 根据类型获取该信息的分发情况
    -- BaseUtils.dump(notice, "提示数据")
    local data = DataNotice.data_get_notice_type_data[notice.type]
    local msgData = MessageParser.GetMsgData(notice.msg)
    if notice.type == MsgEumn.NoticeType.NormalDanmaku then
        DanmakuManager.Instance:AddNewMsg(notice.msg)
        return
    end
    -- 消息提示处理
    if data.mid_style_id == MsgEumn.NoticeType.Float then
        self.model:FloatTipsByData(BaseUtils.copytab(msgData))
    elseif data.mid_style_id == MsgEumn.NoticeType.Confirm then
    elseif data.mid_style_id == MsgEumn.NoticeType.Scroll then
        -- 滚动公告
        self.model:ScrollTipsByData(BaseUtils.copytab(notice))
    end

    -- 处理是否有需要分发到聊天显示
    if data.chat_style_id ~= 0 then
        local chatStyle = DataNotice.data_get_notice_style_data[data.chat_style_id]
        if chatStyle ~= nil then
            for i,channel in ipairs(chatStyle.notice_channels) do
                if str ~= "" then
                    local noticeData = ChatData.New()
                    noticeData.channel = channel
                    noticeData.prefix = chatStyle.prefix
                    noticeData.showType = MsgEumn.ChatShowType.System
                    -- -- 添加默认颜色
                    msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[chatStyle.prefix], msgData.showString)
                    noticeData.msgData = msgData
                    ChatManager.Instance.model:ShowMsg(noticeData)
                end
            end
        end
    end

    if data.bottom_style_id ~= 0 then
        notice.msg = MessageParser.NoSpace(notice.msg)
        self.model:BottomHearsay(notice.msg)
    end
end