local StoryAISoldier = class("StoryAISoldier", require ("src/layers/story/StoryAI"))

function StoryAISoldier:ctor(storyNode, role)
    require ("src/layers/story/StoryAI").ctor(self, storyNode, role)   
    self.m_lockRange = 20;   --ËøµÐ·¶Î§
end

function StoryAISoldier:lockTarget()
    --Ê¿±øËø¶¨ÆÕÍ¨¹Ö
    local myPos = G_MAINSCENE.map_layer:space2Tile(cc.p(self.m_role:getPosition()))
    local function getDistance(role)
        if role == nil or role:getHP() < 1 then
            return 200000000
        end

        local targetPos = G_MAINSCENE.map_layer:space2Tile(cc.p(role:getPosition()))
        local dis = (myPos.x - targetPos.x)*(myPos.x - targetPos.x) + (myPos.y - targetPos.y)*(myPos.y - targetPos.y)
        return dis
    end

    local curDis = 100000000
    local target = nil
    if self.m_storyNode.monsterTab then
        for k, v in pairs(self.m_storyNode.monsterTab) do 
            for m,n in pairs(v) do
                local dis = getDistance(n)
                if dis < curDis then
                    curDis = dis
                    target = n
                end
            end
        end
    elseif self.m_storyNode.playerTab and self.m_storyNode.playerTab[2] then
        for k, v in pairs(self.m_storyNode.playerTab[2]) do 
            local dis = getDistance(v)
            if dis < curDis then
                curDis = dis
                target = v
            end
        end
    end
    
    --ÅÐ¶Ï¾àÀëÊÇ·ñÔÚËøµÐ·¶Î§ÄÚ
    if target ~= nil and curDis > self.m_lockRange*self.m_lockRange then
        target = nil      
    end 

    return target
end

return StoryAISoldier;