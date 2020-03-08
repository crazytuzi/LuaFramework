local tbNpc = Npc:GetClass("AdventureBox")

function tbNpc:OnCreate()
    self.tbGainPlayerID = {}
end

function tbNpc:OnDialog()
    for _, nID in pairs(self.tbGainPlayerID) do
        if nID == me.dwID then
            me.CenterMsg("您已领过奖励")
            return
        end
    end

    local tbParams  = Lib:SplitStr(him.szScriptParam, "|")
    local nTime     = tonumber(tbParams[1])
    local nRandItem = tonumber(tbParams[2])
    GeneralProcess:StartProcess(me, nTime * Env.GAME_FPS, tbParams[4] or "开启中", self.EndProcess, self, me.dwID, him.nId, nRandItem)
end

function tbNpc:EndProcess(nPlayerId, nNpcId, nRandItem)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        Log("[AdventureBox EndProcess] Error, Player is nil")
        return
    end
    local pNpc = KNpc.GetById(nNpcId)
    if not pNpc then
        Log("AdventureBox npc had been use")
        return
    end

    table.insert(self.tbGainPlayerID, nPlayerId)

    local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID)
    if #tbMember <= #self.tbGainPlayerID then
        pNpc.Delete()
    end

    local bRet, szMsg, tbAward = Item:GetClass("RandomItemByLevel"):GetAwardByLevel(pPlayer, nRandItem, "AdventureBox")
    if bRet == 0 then
        pPlayer.CenterMsg(szMsg)
    end
end