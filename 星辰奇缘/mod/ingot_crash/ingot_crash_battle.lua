IngotCrashBattle = IngotCrashBattle or BaseClass()

function IngotCrashBattle:__init()
    self.playerList = {nil, nil}    -- 参赛者
    self.nextWinBattle = nil        -- 胜利者比赛
    self.nextLossBattle = nil        -- 失败者比赛
    self.preBattleList = {nil, nil} -- 前两场比赛

    -- 以下两个按钮可能是同一个GameObject
    self.betBtn = nil               -- 下注按钮
    self.watchBtn = nil             -- 观战或者录像按钮
end

function IngotCrashBattle:__delete()
end

function IngotCrashBattle:Init()
end

function IngotCrashBattle:SetSinglePlayer(player, index)
    self.playerList[index] = player

    if #self.playerList == 2 then
    else
        -- 未确定

    end
end

function IngotCrashBattle:SetPlayers(player1, player2)
    self.playerList[1] = player1
    self.playerList[2] = player2
end

function IngotCrashBattle:Analyze()
end
