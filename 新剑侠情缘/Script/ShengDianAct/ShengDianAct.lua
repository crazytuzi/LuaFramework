function ShengDianAct:GetFakePlayer(nID)
    if self.tbFakePlayer[nID] then
        self.tbFakePlayer[nID].nLevel = self.tbFakePlayer[nID].nLevel or TimeFrame:GetMaxLevel()
        return self.tbFakePlayer[nID]
    end
end

function ShengDianAct:SendMessage(nChannelType, nID, content, nVoiceId)
    local bRet = self:CheckMessageParam(nChannelType, nID, content, nVoiceId, nLevel)
    if not bRet then
        return
    end

    local tbPlayer = self:GetFakePlayer(nID)
    local szMsg = ""
    local tbLink = nil
    content = self:FormatContent(content)
    if content then
        szMsg = content
    elseif nVoiceId then
        local tbVoiceInfo = self.tbVoice[nVoiceId]
        szMsg = tbVoiceInfo[2]
        tbLink = {nLinkType = ChatMgr.LinkType.ClientVoice, szClientVoice = tbVoiceInfo[1], nClientVoiceTime = tbVoiceInfo[3]}
        --不支持一个时间多个相同的语音，会导致动画不正确
        tbLink.nClientVoiceID = GetTime()
    else
        return
    end
    if nChannelType == ChatMgr.ChannelType.Public then
        ChatMgr:OnChannelMessage(ChatMgr.ChannelType.Public, tbPlayer.dwID, tbPlayer.szName, tbPlayer.nFaction, tbPlayer.nPortrait, tbPlayer.nLevel, szMsg, 0, 0, 0, tbPlayer.nNamePrefix, tbPlayer.nHeadBg, tbPlayer.nChatBg, tbLink)
    else
        ChatMgr:OnPrivateMessage(tbPlayer.dwID, GetTime(), szMsg, 0, 0, 0, tbPlayer.nHeadBg, tbPlayer.nChatBg, tbLink)
    end
    if nChannelType == ChatMgr.ChannelType.Private then
        ChatMgr:OnSynChatRoleBaseInfo({tbPlayer})
    end
end

function ShengDianAct:OnMapLoaded(nMapTemplateID)
    if nMapTemplateID ~= self.MAP_ID then
        return
    end
    Ui:OpenWindow("QYHLeavePanel", "ShengDianAct")
end

function ShengDianAct:OnLeave(nMapTemplateID)
    if nMapTemplateID ~= self.MAP_ID then
        return
    end
    Ui:CloseWindow("QYHLeavePanel")
end
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, ShengDianAct.OnMapLoaded, ShengDianAct)
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, ShengDianAct.OnLeave, ShengDianAct)