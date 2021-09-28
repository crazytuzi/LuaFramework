local StoryShouShaPlayer = class("StoryShouShaPlayer", require ("src/layers/story/StoryAI"))

local pathRecord = require ("src/layers/story/StoryPlayerPaths")

function StoryShouShaPlayer:ctor(storyNode, role, school, teamId)
    require ("src/layers/story/StoryAI").ctor(self, storyNode, role)   
    self.m_lockRange = 20;   --锁敌范围
    if school == 1 then
        self.m_attackRange = 3
    else
        self.m_attackRange = 10
    end
    
    self.m_type = 3
    self.m_school = school
    self.m_camp = teamId
    self.teamId = teamId
    self.m_lockRange = 15 
    self.m_lastAtkTime = 1
    self.m_targetID = nil

    self.m_updateTimeFactor = math.random(1,100)/100
end

function StoryShouShaPlayer:setTargetID(targetID)
    self.m_targetID = targetID
    self.m_lockRole = nil
end

function StoryShouShaPlayer:setDesPos(dstPos)
    self.m_dstPos = dstPos
end

function StoryShouShaPlayer:setCanRandomMove(flg)
    self.m_canRandomMove = flg
end

function StoryShouShaPlayer:setState(state)
    self.m_state = state
end

function StoryShouShaPlayer:getHosTeamID()
    if self.teamId == 1 then
        return 2
    elseif self.teamId == 2 then
        return 1
    else
        return 4
    end
end

function StoryShouShaPlayer:update(dt)
    local function cb(dt)
        if G_MAINSCENE == nil or self.m_bOver or self.m_state == 0 then
            return
        end
        if self.m_role == nil or self.m_role:getHP() < 1 then
            self.m_bOver = true
            return
        end

        if self.m_role:getCurrActionState() == ACTION_STATE_IDLE then
            self.m_isMoveing = false
        end

        self.m_onCollideTime = self.m_onCollideTime - dt
        if self.m_onCollideTime > 0 then
            return
        end
  
        --如果角色死亡, 待机中，攻击中，移动中，返回
        self.m_lastAtkTime = self.m_lastAtkTime - dt
        if self.m_isMoveing == true or self.m_lastAtkTime > 0 then
            return;
        end 

        if self.m_state == 1 then
            self:randomMove()
        end

        --先移动
        if self:isNeedMoveToDstPos() then
            self:moveToDstPos()
            return
        end

        --如果目标死亡，置空
        if self.m_lockRole ~= nil and self.m_lockRole:getHP() < 1 then
            self.m_lockRole = nil
            self.m_role:standed()
        end

        if self.m_state < 2 then
            return
        end
        --锁敌
        if self.m_lockRole == nil then
            self.m_lockRole = self:lockTarget()
            if self.m_lockRole == nil then
                self.m_role:standed()
                if self.m_canRandomMove then
                    self:randomMove()                   
                end
                
                return;
            end        
        end

        --是否需要移动
        if self:isNeedMove() == true then
            self:moveToRole(self.m_lockRole);
            return;
        end

        --攻击中添加随机移动
        -- if self:randomMove() then
        --     return
        -- end
           
        --攻击
        self:attackTarget();
    end

    startTimerAction(G_MAINSCENE.storyNode, self.m_updateTimeFactor, false, function() cb(dt) end)
end

function StoryShouShaPlayer:lockTarget()
    if G_MAINSCENE == nil then
        return nil
    end
    
    if self.m_notLockTarget then
        return nil
    end
        
    local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(self.m_role:getPosition()))
    local function getDistance(role)
        if role == nil or role:getHP() < 1 then
            return 200000000
        end

        local targetPos = G_MAINSCENE.map_layer:space2Tile(cc.p(role:getPosition()))
        local dis = (myPos.x - targetPos.x)*(myPos.x - targetPos.x) + (myPos.y - targetPos.y)*(myPos.y - targetPos.y)
        return dis
    end
    
    if self.m_targetID then
        local target = G_MAINSCENE.map_layer.item_Node:getChildByTag(self.m_targetID)
        if target ~= nil and target:getHP() > 0 then
            local dis = getDistance(target)
            if dis > self.m_lockRange * self.m_lockRange then
                target = nil  
            end 
            
            return target   
        end      
    end 

    local curDis = 100000000
    local target = nil
    local targetTeam = self:getHosTeamID()
    for k, v in pairs(self.m_storyNode.playerTab[targetTeam]) do 
        local dis = getDistance(v)
        if dis < curDis then
            curDis = dis
            target = v
        end
    end

    --判断距离是否在锁敌范围内
    if target ~= nil and curDis > self.m_lockRange*self.m_lockRange then
        target = nil      
    end 

    return target
end

function StoryShouShaPlayer:isNeedMoveToDstPos()
    if self.m_dstPos == nil or G_MAINSCENE == nil then
        return false
    end

    local pos1 = self.m_dstPos
    local pos2 = G_MAINSCENE.map_layer:space2Tile(cc.p(self.m_role:getPosition()))
    if ((pos1.x - pos2.x)*(pos1.x - pos2.x) + (pos1.y - pos2.y)*(pos1.y - pos2.y)) > 0 then
        return true
    end

    self.m_dstPos = nil
    return false
end

function StoryShouShaPlayer:moveToDstPos()
    if self.m_dstPos == nil then
         return
    end
    
    self.m_isMoveing = true;
    local pos = self.m_dstPos
    
    local moveCB = function()
        self.m_isMoveing = false
        if self.m_bDisappearAfterMove then
            self.m_role:setHP(0)
            self.m_role:setVisible(false)
        end
    end

    local paths = G_MAINSCENE.map_layer:moveMonsterByPos(pos, self.m_role, 2, false)
    G_MAINSCENE.map_layer:moveByPaths(paths, self.m_role, self.m_role:getTag(), 0.23, nil, moveCB)
    self.m_dstPos = nil   
end

function StoryShouShaPlayer:randomMove()
    local idx = math.random(1,6)
    if idx < 3 then
         local offset = 2
         local posAdd = { cc.p(-offset, 0), cc.p(-offset, -offset), cc.p(-offset, offset), cc.p(0, -offset), cc.p(0, offset), cc.p(offset, -offset), cc.p(offset, 0), cc.p(offset, offset)}
         local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(self.m_role:getPosition()))
         for i=math.random(1,7), #posAdd do
              local new = cc.p(myPos.x + posAdd[i].x, myPos.y + posAdd[i].y) 
              if not G_MAINSCENE.map_layer:isBlock(new) then
                    self.m_dstPos = new
                    return true
              end
         end
    end

    return false
end

function StoryShouShaPlayer:attackTarget()
    local topNode = self.m_role:getTopNode()
    if topNode and not topNode:isVisible() then
        if self.m_school == 1 then
            startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(1003, self.m_role, {self.m_lockRole}) end)
        elseif self.m_school == 2 then
            startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(2010, self.m_role, {self.m_lockRole}) end)
        else
            startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(3011, self.m_role, {self.m_lockRole}) end)
        end
        self.m_lastAtkTime = 1
    else
        --面向目标
        local dir = self:getDirOfTarget()
        self.m_role:setSpriteDir(dir)   

        --根据不同的职业释放不同的技能
        local idx = math.random(1,2)
        if self.m_school == 1 then
            if idx == 1 then   --刺杀剑术
                self.m_role:attackOneTime(0.35, cc.p(0, 0))            
                CMagicCtrlMgr:getInstance():CreateMagic(1003, 0, self.m_role:getTag(), self.m_lockRole:getTag(), self.m_role:getCurrectDir());
                startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(1003, self.m_role, {self.m_lockRole}) end)
                self.m_lastAtkTime = 1
            else               --烈火剑法
                self.m_role:attackOneTime(0.35, cc.p(0, 0))
               CMagicCtrlMgr:getInstance():CreateMagic(1006, 0, self.m_role:getTag(), self.m_lockRole:getTag(), self.m_role:getCurrectDir());
                startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(1006, self.m_role, {self.m_lockRole}) end)
                self.m_lastAtkTime = 1
           end
        elseif self.m_school == 2 then
            if idx == 1 then   --狂龙紫电
                self.m_role:magicUpToPos(0.4, cc.p(0, 0)) 
                CMagicCtrlMgr:getInstance():CreateMagic(2010, 0, self.m_role:getTag(), self.m_lockRole:getTag(), 0);
                startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(2010, self.m_role, {self.m_lockRole}) end)
                self.m_lastAtkTime = 1
            else               --流行火雨
                self.m_role:magicUpToPos(0.4, cc.p(0, 0))
                G_MAINSCENE.map_layer:playSkillEffect(0.1, 2011, self.m_role, self.m_lockRole, nil, nil)
                local dstPos = cc.p(self.m_lockRole:getPosition())
                startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(2011, self.m_role, {self.m_lockRole}, dstPos) end)
                self.m_lastAtkTime = 1.2
            end
        else
            if idx == 1 then   --幽冥火咒
                self.m_role:magicUpToPos(0.4, cc.p(0, 0))
                CMagicCtrlMgr:getInstance():CreateMagic(3011, 0, self.m_role:getTag(), self.m_lockRole:getTag(), self.m_role:getCurrectDir());             
                startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(3011, self.m_role, {self.m_lockRole}) end)
                self.m_lastAtkTime = 1
            else               --施毒术
                self.m_role:magicUpToPos(0.4, cc.p(0, 0))
                CMagicCtrlMgr:getInstance():CreateMagic(3004, 0, self.m_role:getTag(), self.m_lockRole:getTag(), self.m_role:getCurrectDir());
                startTimerAction(G_MAINSCENE.storyNode, 1, false, function() self.m_storyNode:onPlayerSkill(3004, self.m_role, {self.m_lockRole}) end)
                self.m_lastAtkTime = 1
            end
        end
    end
    
    
end

function StoryShouShaPlayer:fight()
    local sec = math.random(1,3000)*0.001
    startTimerAction(G_MAINSCENE.storyNode, sec, false, function() self.m_state = 2 end)
end

--记录路径
function StoryShouShaPlayer:writePaths()
    if not isWindows() then  
        return
    end

    local pFile =  io.open("kuniu/src/layers/story/StoryPlayerPaths.lua","w")
    if pFile then
        pFile:write("local Paths = { \n")
        
        local items = require("src/config/storyPlayer")
        for j=1, #items do 
            local id = items[j].q_id
            local pathinfo = pathRecord[id]
            if pathinfo then
                local str = "["..id.."] = { "
                for i=1,#pathinfo do
                    str = str.."{x="..pathinfo[i].x..",y="..pathinfo[i].y.."},"
                end
                str = str.." }, \n"
                pFile:write(str)
            end           
        end


        pFile:write("}; \n")
        pFile:write("return Paths \n")
        pFile:close()
    end 
    
end

return StoryShouShaPlayer;