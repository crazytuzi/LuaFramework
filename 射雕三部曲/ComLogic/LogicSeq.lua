local LogicSeq = class("LogicSeq" , function(data)
    return {
        data = data,            --LogicData

        friend_backup = {},
        enemy_backup = {},

        attackMap_friend = {},
        attackMap_enemy = {},
        lastAttack = nil,
        zhenShouTeamateAttack = true,     -- 标志友方珍兽是否可以行动
        zhenShouEnemyAttack = true,       -- 标志敌方珍兽是否可以行动
        overload = {},
    }
end)

function LogicSeq:ctor( ... )
    for i , v in ld.pairsByKeys(self.data:getHeroList()) do
        if v:getType() == ld.HeroStandType.eTeammate then
            table.insert(self.friend_backup , i)
        else
            table.insert(self.enemy_backup , i)
        end
    end
    table.sort(self.friend_backup , function(x , y)
        return x < y
    end)
    table.sort(self.enemy_backup , function(x , y)
        return x < y
    end)

    -- if not self.data.params.IsPVP then
    --     table.sort(self.enemy_backup , function(x , y)
    --         if (x >=7 and x <= 9) and (y >= 7 and y <= 9) then
    --             return x > y
    --         end
    --         if (x >=10 and x <= 12) and (y >= 10 and y <= 12) then
    --             return x > y
    --         end
    --         return x < y
    --     end)
    -- end
end

function LogicSeq:init( ... )
    -- for i , v in ipairs(self.friend_backup) do
    --     if (not self.overload[v]) or (self.overload[v] == 0) then
    --         table.insert(self.attackMap_friend , v)
    --     else
    --         self.overload[v] = self.overload[v] - 1
    --     end
    -- end
    for i , v in ld.pairsByKeys(self.overload) do
        if v > 0 then
            self.overload[i] = self.overload[i] - 1
        end
    end

    self.attackMap_friend = clone(self.friend_backup)
    self.attackMap_enemy = clone(self.enemy_backup)
    self.lastAttack = nil

    self.zhenShouTeamateAttack = true
    self.zhenShouEnemyAttack = true
end

--判断先手顺序 (true:我方， false:敌方)
function LogicSeq:firstPriority(teamData)
    --先判断先手值
    if teamData.Friend.Fsp ~= teamData.Enemy.Fsp then
        return teamData.Friend.Fsp > teamData.Enemy.Fsp
    end
    --再判断战斗力
    if teamData.Friend.Fap ~= teamData.Enemy.Fap then
        return teamData.Friend.Fap > teamData.Enemy.Fap
    end
    return true
end

function LogicSeq:getEnemy( ... )
    for i , v in ipairs(self.attackMap_enemy) do
        local tmp = v
        table.remove(self.attackMap_enemy , i)
        return tmp
    end
    return nil
end

function LogicSeq:getTeammate( ... )
    for i , v in ipairs(self.attackMap_friend) do
        local tmp = v
        table.remove(self.attackMap_friend , i)
        return tmp
    end
    return nil
end

function LogicSeq:getNext()
    if self.lastAttack == nil then
        if self:firstPriority(self.data.params.TeamData) then
            --我方先手
            return self:getTeammate() or self:getEnemy()
        else
            --敌方先手
            return self:getEnemy() or self:getTeammate()
        end
    else
        if ld.getStandType(self.lastAttack) == ld.HeroStandType.eTeammate then
            --敌方先手
            return self:getEnemy() or self:getTeammate()
        else
            --我方先手
            return self:getTeammate() or self:getEnemy()
        end
    end
end

function LogicSeq:markSuccess(posId)
    self.lastAttack = posId
end

function LogicSeq:getShenShouAttack()
    return self.zhenShouTeamateAttack or self.zhenShouEnemyAttack
end

function LogicSeq:getShenShouTeamAttack()
    return self.zhenShouTeamateAttack
end

function LogicSeq:getShenShouEnemyAttack()
    return self.zhenShouEnemyAttack
end

function LogicSeq:setShenShouTeamAttack()
    self.zhenShouTeamateAttack = false
end

function LogicSeq:setShenShouEnemyAttack()
    self.zhenShouEnemyAttack = false
end

function LogicSeq:markAction(posId)
    if ld.getStandType(posId) == ld.HeroStandType.eTeammate then
        -- for i , v in ipairs(self.attackMap_friend) do
        --     if v == posId then
        --         --找到表示该轮还未普攻，不是过载
        --         self.overload[posId] = self.overload[posId] or 0
        --         self.overload[posId] = self.overload[posId] + 1
        --         return
        --     end
        -- end
        self.overload[posId] = self.overload[posId] or 0
        self.overload[posId] = self.overload[posId] + 1
    end
end

function LogicSeq:checkAction(posId)
    if self.overload[posId] and self.overload[posId] > 0 then
        return false
    end
    return true
end

return LogicSeq