local tbNpc = Npc:GetClass("ClientCookGatherNpc")

function tbNpc:OnDialog()
    if not Furniture.Cook:IsOpened(me) then
        me.CenterMsg("功能尚未开启")
        return
    end

    if not Furniture.Cook:CheckGatherConsume(me, him.nTemplateId) then
        local nConsumeItemId = Furniture.Cook:GetGatherConsumeItemId(him.nTemplateId)
        local tbInfo = Furniture.Cook:GetMaterialInfo(nConsumeItemId)
        me.CenterMsg(string.format("%s不足", tbInfo.szName))
        return
    end
    GeneralProcess:StartProcessUniq(me, 6 * Env.GAME_FPS, him.nId, "采集中...", self.EndProcess, self, him.nId)
end

function tbNpc:EndProcess(nNpcId)
    local pNpc = KNpc.GetById(nNpcId)
    if not pNpc or pNpc.IsDelayDelete() then
        Dialog:CenterMsg(pPlayer, "已被其他人抢先采走啦")
        return
    end

    if not Furniture.Cook:CheckGatherConsume(me, pNpc.nTemplateId) then
        me.CenterMsg("消耗道具不足")
        return
    end

    RemoteServer.CookReq("ClientGather", pNpc.nTemplateId, pNpc.nIdx)
    pNpc.Delete()
end