local StoryAIMonster = class("StoryAI", require ("src/layers/story/StoryAI"))

function StoryAIMonster:ctor(storyNode, role)
    require ("src/layers/story/StoryAI").ctor(self, storyNode, role)    
    self.m_type = 1;   --0 soldier; 1 monster; 2 pet
end

function StoryAIMonster:lockTarget()
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

    for k, v in pairs(self.m_storyNode.soldier) do 
        local dis = getDistance(v)
        if dis < curDis then
            curDis = dis
            target = v
        end
    end
 
    if target ~= nil and curDis > self.m_lockRange*self.m_lockRange then
        target = nil      
    end 

    return target
end

return StoryAIMonster;