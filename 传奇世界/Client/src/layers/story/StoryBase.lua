local StoryBase = class("StoryBase", function() return cc.Node:create() end)

local path = "res/story/"

function StoryBase:ctor()
end

function StoryBase:updateState()  
end

function StoryBase:endStroy()
end

function StoryBase:onSkillSend(skillId,targets,targetPos)
end

function StoryBase:isCanMove(monster)
    return true
end

function StoryBase:isMonster(monster)
    return false
end

function StoryBase:canPick()  
    return true
end

function StoryBase:canSelectRole()
    return true
end

function  StoryBase:getNearestMonsterForCollide()   
    return nil
end

function StoryBase:showSkillActiveTips(skill_id)    
end

function StoryBase:isCanTouchMonster()
    return true
end

function StoryBase:isCanUpRide()
    return false
end

function StoryBase:isCanShowTips()
    return false
end

function StoryBase:isFirstStory()
    return false
end

return StoryBase