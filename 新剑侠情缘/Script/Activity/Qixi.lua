local tbAct    = Activity:GetUiSetting("Qixi")
tbAct.szUiName = "Qixi"
tbAct.szTitle  = "七夕节"

Activity.Qixi = Activity.Qixi or {}
local Qixi = Activity.Qixi

function Qixi:OnUseItem(nItemId, nMapTemplateId, nPosX, nPosY)
    local pItem = KItem.GetItemObj(nItemId)
    if not pItem then
        return
    end

    local function fnOnArive()
        RemoteServer.UseItem(nItemId)
        Ui:CloseWindow("QuickUseItem")
    end
    AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnOnArive)
    local tbMapSetting = Map:GetMapSetting(nMapTemplateId)
    me.CenterMsg(string.format("拜星地点位于[FFFE0D]%s(%s, %s)[-]，正在前往", tbMapSetting.MapName, math.floor(nPosX * Map.nShowPosScale), math.floor(nPosY * Map.nShowPosScale)))

    if TeamMgr:HasTeam() then
        local szLocaltion = string.format("你们感知到，如果到达<%s(%d,%d)>处能点燃玄香拜星，达成美好愿望！", tbMapSetting.MapName, nPosX*Map.nShowPosScale, nPosY*Map.nShowPosScale)
        local tbRandomPos = {-100, 100}
        nPosX = nPosX + tbRandomPos[MathRandom(2)]
        nPosY = nPosY + tbRandomPos[MathRandom(2)]
        ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {nMapTemplateId, nPosX, nPosY, nMapTemplateId})
        ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szLocaltion)
    end

    Ui:CloseWindow("ItemTips")
    Ui:CloseWindow("ItemBox")
end

function Qixi:BeginBaiXing(nHelperNpcId)
    Ui:OpenWindow("QixiPoemPanel")
    Ui:OpenWindow("QixiAnimationPanel")
    Ui:OpenWindow("ChuangGongPanel", nil, nil, nil, nil, nil, true)
    Ui:CloseWindow("TopButton")
    Ui:CloseWindow("ItemTips")
    Ui:CloseWindow("ItemBox")
    Ui:CloseWindow("HomeScreenTask")
    Ui.Effect.ShowAllRepresentObj(0)
    Ui.Effect.ShowNpcRepresentObj(me.GetNpc().nId, true)
    Ui.Effect.ShowNpcRepresentObj(nHelperNpcId, true)

    self.nBaixingTimes = self.Def.BAIXING_EXT_TIMES
    Timer:Register(Env.GAME_FPS * self.Def.BAIXING_EXT_INTERVAL, self.ContinueBaiXing, self)
end

function Qixi:ContinueBaiXing()
    local nPercent = (self.Def.BAIXING_EXT_TIMES - self.nBaixingTimes)/self.Def.BAIXING_EXT_TIMES
    self.nBaixingTimes = self.nBaixingTimes - 1
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHUAN_GONG_SEND_ONE, nPercent)
    return nPercent < 1
end

function Qixi:CloseBaiXing()
    Ui:OpenWindow("TopButton")
    Ui:OpenWindow("HomeScreenTask")
    Ui:CloseWindow("QixiAnimationPanel")
    Ui:CloseWindow("QixiPoemPanel")
    Ui:CloseWindow("ChuangGongPanel")
    Ui:ShowBlackMsg("七色玄香燃毕,在沁人心脾的美景里,心有所感")
    Ui.Effect.ShowAllRepresentObj(1)
end