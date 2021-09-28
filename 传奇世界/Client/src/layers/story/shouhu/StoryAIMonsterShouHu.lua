local StoryAIMonsterShouHu = class("StoryAI", require ("src/layers/story/StoryAI"))

function StoryAIMonsterShouHu:ctor(storyNode, role)
    require ("src/layers/story/StoryAI").ctor(self, storyNode, role)    
    self.m_type = 1;   --0 soldier; 1 monster; 2 pet
    self.m_lockRange = 50;
    self.m_attackRange = 2;
    self.m_updateTimeFactor = math.random(1,100)/100
end

function StoryAIMonsterShouHu:update(dt)
    local function cb(dt)
        require ("src/layers/story/StoryAI").update(self,dt)
    end

    startTimerAction(G_MAINSCENE.storyNode, self.m_updateTimeFactor, false, function() cb(dt) end)
end

function StoryAIMonsterShouHu:moveToRole(role)
    if role == nil or G_MAINSCENE == nil then
        return
    end
    
    self.m_isMoveing = true;
    
    --获取目标坐标最近点坐标
    local pos = self:getNearPosOfRole(role)
    pos = G_MAINSCENE.map_layer:space2Tile(pos)
    local paths = G_MAINSCENE.map_layer:moveMonsterByPos(pos, self.m_role, 2, false)
    if self.m_type < 3 then
        G_MAINSCENE.map_layer:moveByPaths(paths, self.m_role, self.m_role:getTag(), 0.6 + math.random(1,3)*0.1, nil, function() self.m_isMoveing = false end)
    else
        G_MAINSCENE.map_layer:moveByPaths(paths, self.m_role, self.m_role:getTag(), 0.6, nil, function() self.m_isMoveing = false end)
    end

end

function StoryAIMonsterShouHu:lockTarget()
    local target = G_ROLE_MAIN
    local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(self.m_role:getPosition()))
    local targetPos = G_MAINSCENE.map_layer:space2Tile(cc.p(target:getPosition()))
    local curDis = (myPos.x - targetPos.x)*(myPos.x - targetPos.x) + (myPos.y - targetPos.y)*(myPos.y - targetPos.y)

    local function getDistance(role)
        if role == nil or role:getHP() < 1 then
            return 200000000
        end

        local targetPos = G_MAINSCENE.map_layer:space2Tile(cc.p(role:getPosition()))
        local dis = (myPos.x - targetPos.x)*(myPos.x - targetPos.x) + (myPos.y - targetPos.y)*(myPos.y - targetPos.y)
        return dis
    end

    for k, v in pairs(self.m_storyNode.playerTab[1]) do 
        local dis = getDistance(v)
        if dis < curDis then
            curDis = dis
            target = v
        end
    end
 
    if target ~= nil and curDis > self.m_lockRange*self.m_lockRange then
        target = nil      
    end 

    if target == nil then
        target = self.m_storyNode.gongzhu
    end

    return target
end

function StoryAIMonsterShouHu:attackTarget()
    local function callback()
        self.m_iCalHurt = false

        --伤害计算
        if self.m_type == 2 then
            self.m_storyNode:onPlayerSkill(9999, self.m_role, {self.m_lockRole})
        elseif self.m_type == 1 then
            self.m_storyNode:onPlayerSkill(9998, self.m_role, {self.m_lockRole})
        else
            self.m_storyNode:onPlayerSkill(9997, self.m_role, {self.m_lockRole})
        end
    end

    --面向目标
    local dir = self:getDirOfTarget()
    self.m_role:setSpriteDir(dir)
    self.m_lastAtkTime = 2
    self.m_role:attackOneTime(0.8 + math.random(1,4)*0.1 , cc.p(0, 0))
    if self.m_iCalHurt ~= true then
        startTimerAction(G_MAINSCENE.storyNode, 1, false, callback)
    end
    self.m_iCalHurt = true
end

function StoryAIMonsterShouHu:getNearPosOfRole(role)
    local pos = cc.p(self.m_role:getPositionX(), self.m_role:getPositionY())
    if role == nil then
        return pos
    end

    local posAdd = { cc.p(-1, 0), cc.p(-1, - 1), cc.p(-1, 1), cc.p(0, - 1), cc.p(0, 1), cc.p(1, - 1), cc.p(1, 0), cc.p(1, 1) }
    local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(role:getPosition()))
    for i=1,20 do
        local j = math.random(1,8)
        local f = math.random(1,self.m_attackRange)
        local new = cc.p(myPos.x + posAdd[j].x*f, myPos.y + posAdd[j].y*f)
        if not G_MAINSCENE.map_layer:isBlock(new) then
            myPos = new
            break
        end
    end

    local ret = G_MAINSCENE.map_layer:tile2Space(myPos)
    return ret
end

return StoryAIMonsterShouHu;