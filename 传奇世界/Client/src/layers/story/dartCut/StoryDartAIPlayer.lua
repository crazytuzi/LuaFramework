local StoryDartAIPlayer = class("StoryDartAIPlayer", require ("src/layers/story/StoryAIPlayer"))

function StoryDartAIPlayer:ctor(storyNode, role, school, dstPos, dstPos2, camp, targetID, isDefender)
    require ("src/layers/story/StoryAIPlayer").ctor(self, storyNode, role, school, dstPos, dstPos2, camp, targetID, isDefender)   
end


function StoryDartAIPlayer:randomMove()
    local idx = math.random(1,10)
    if idx < 2 then
         local posAdd = { cc.p(-2, 0), cc.p(-2, -2), cc.p(-2, 2), cc.p(0, -2), cc.p(0, 2), cc.p(2, -2), cc.p(2, 0), cc.p(2, 2)}
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

return StoryDartAIPlayer