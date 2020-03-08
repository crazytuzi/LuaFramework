ShengDianAct.MAP_ID = 7002

ShengDianAct.nZLY = -1
ShengDianAct.nLGX = -2
ShengDianAct.tbFakePlayer = {
    [ShengDianAct.nZLY] = {
        dwID = ShengDianAct.nZLY,
        nFaction = 14,
        nPortrait = 212,
        dwKinId = 0,
        szName = "颖宝宝",
        szAccount = "",
        nHonorLevel = 5,
        nHouseState = 0, 
        nMarketStallLimit = 0,
        nLastOnlineTime = 0,
        nBanEndTime = 0,
        nVipLevel = 18,
        nState = 2,
        nNamePrefix = 10,
        nHeadBg = 39,
        nChatBg = 40,
    };
    [ShengDianAct.nLGX] = {
        dwID = ShengDianAct.nLGX,
        nFaction = 13,
        nPortrait = 213,
        dwKinId = 0,
        szName = "林更新",
        szAccount = "",
        nHonorLevel = 5,
        nHouseState = 0, 
        nMarketStallLimit = 0,
        nLastOnlineTime = 0,
        nBanEndTime = 0,
        nVipLevel = 18,
        nState = 2,
        nNamePrefix = 10,
        nHeadBg = 39,
        nChatBg = 40,
    };
}
ShengDianAct.tbVoice = {
    {"Setting/Sound/jhsd_zly.voice", "10月29日，《剑侠情缘手游》年度江湖盛典，2018重磅内容爆料，我在现场等你，一起狂欢，见证江湖新生，不见不散！", 11000},
    {"Setting/Sound/gc_lgx.voice", "我代言的《新剑侠情缘手游》马上就要公测了！双人轻功，绝美江湖，我还为你准备了一份神秘大礼，就藏在游戏里，点击下载，找到我给你的专属大礼！", 13000},
    {"Setting/Sound/xnh_lgx.voice", "少侠，新年好！江湖闯荡又一年，我是林更新，本少东家在此，祝你武艺精进，情缘美满，新年快乐！", 11100},
    {"Setting/Sound/xnh_zly.voice", "少侠新年好！闯荡江湖辛苦了！我是颖宝宝，在此祝少侠你，好运不断，桃花常开，顺风顺水心如意，情缘成双比翼飞！新年快乐！", 12830},
    {"Setting/Sound/dncy_zly.voice", "今天是大年初一，你抢到红包了吗？我这有好多的红包，想要吗？来剑侠情缘手游找我吧！我有一个好鼓好大的红包想要送给你！新年红包收不停！来剑侠情缘手游抢红包！", 14580},
}
ShengDianAct.tbContent = {
}

function ShengDianAct:FormatContent(content)
    if not content then
        return
    end

    if type(content) == "number" then
        content = self.tbContent[content]
    end
    if Lib:IsEmptyStr(content) then
        content = nil
    end
    return content
end

function ShengDianAct:CheckMessageParam(nChannelType, nID, content, nVoiceId)
    if nChannelType ~= ChatMgr.ChannelType.Private and nChannelType ~= ChatMgr.ChannelType.Public then
        return false, "只能在世界或私聊频道发送"
    end

    if nID ~= self.nLGX and nID ~= self.nZLY then
        return false, "没找到代言人"
    end

    content = self:FormatContent(content)
    if not content and not nVoiceId then
        return false, "没有文字及语音"
    end
    if content then
        return true
    end

    if nVoiceId then
        local tbVoiceInfo = self.tbVoice[nVoiceId]
        if not tbVoiceInfo then
            return false, "语音内容异常"
        end
        return true
    end
    return false, "内容参数异常"
end