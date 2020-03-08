local tbItem = Item:GetClass("Qisexuanxiang")
tbItem.MAPTEMPLATEID = 1
tbItem.POS_X = 2
tbItem.POS_Y = 3

function tbItem:LoadSetting()
    self.tbAllPos = Lib:LoadTabFile("ServerSetting/Activity/QisexuanxiangPos.tab", {nMapTemplateId = 1, nPosX = 1, nPosY = 1})
    assert(self.tbAllPos and #self.tbAllPos > 0, "Qisexuanxiang LoadSetting Fail")
end

if MODULE_GAMESERVER then
    tbItem:LoadSetting()
end

function tbItem:OnCreate(it)
    if MODULE_GAMESERVER then
        self:RandomPos(it)
    end
end

function tbItem:RandomPos(pItem)
    local nPosIdx = MathRandom(#self.tbAllPos)
    local tbInfo = self.tbAllPos[nPosIdx]
    pItem.SetIntValue(self.MAPTEMPLATEID, tbInfo.nMapTemplateId)
    pItem.SetIntValue(self.POS_X, tbInfo.nPosX)
    pItem.SetIntValue(self.POS_Y, tbInfo.nPosY)
end

function tbItem:OnUse(it)
    Activity:OnPlayerEvent(me, "Act_TryUseBaiXingItem", it)
end

function tbItem:CheckCanUse(pItem)
    if not Activity.Qixi:IsInActivityTime() then
        return false, "不在活动时间内"
    end

    -- local nLastCount = me.GetUserValue(Activity.Qixi.Def.SAVE_GROUP, Activity.Qixi.Def.CHANGE_ITEM_TIMES_KEY)
    -- if nLastCount <= 0 then
    --     return nil, "拜星次数已耗尽"
    -- end

    if not TeamMgr:HasTeam() then
        return false, "没有队伍"
    end

    local tbMember = TeamMgr:GetTeamMember()
    if #tbMember ~= 1 then
        return false, "只能两个人拜星"
    end

    local tbHelper = tbMember[1]
    local bRet, szMsg =Activity.Qixi:CommonCheck({me.nSex, me.dwID, me.nLevel}, {tbHelper.nSex, tbHelper.nPlayerID, tbHelper.nLevel})
    if not bRet then
        return false, szMsg
    end

    local nMapId, nX, nY = me.GetWorldPos()
    local nMapTemplateId = pItem.GetIntValue(self.MAPTEMPLATEID)
    local nPosX          = pItem.GetIntValue(self.POS_X)
    local nPosY          = pItem.GetIntValue(self.POS_Y)
    if not IsSameMapId(nMapId, nMapTemplateId) or nX ~= nPosX or nY ~= nPosY then
        Activity.Qixi:OnUseItem(pItem.dwId, nMapTemplateId, nPosX, nPosY)
        return false
    end

    return true
end

function tbItem:OnClientUse(pItem)
    local bRet, szMsg = self:CheckCanUse(pItem)
    if not bRet then
        if szMsg then
            me.CenterMsg(szMsg)
        end
        return 1
    end
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    if Activity.Qixi:IsInActivityTime() then
        return {szFirstName = "使用", fnFirst = "UseItem"}
    end

    if Shop:CanSellWare(me, nItemId, 1) then
        return {szFirstName = "出售", fnFirst = "SellItem"}
    end

end