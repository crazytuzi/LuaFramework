--AI部队的数据模型
AITroopsVo = {}

function AITroopsVo:new()
    local troopVo = {}
    setmetatable(troopVo, self)
    self.__index = self
    return troopVo
end

function AITroopsVo:init(id, data)
    self.id = id --部队id
    self.lv = data[1] or 1 --部队等级
    self.exp = data[2] or 0 --部队当前等级经验
    self.grade = data[3] or 1 --部队阶级
    self.skills = data[4] or {} --部队绑定的技能列表 格式： {{id,level,exp},{s1,1,100},{id,level,exp,可以更换的技能id,洗练次数}}
end

function AITroopsVo:getTroopsStrength()
    return AITroopsVoApi:getTroopsStrength(self.id, self.grade, self.lv, self.skills)
end

function AITroopsVo:getTroopsSkillList()
    return self.skills
end

function AITroopsVo:getSkillByPos(pos)
    local s = self.skills[pos]
    if s then
        local sid = s[1] --技能id
        local lv = s[2] --技能当前等级
        local exp = s[3] --当前等级累计的经验数
        local nextSid = s[4] --技能3可以更换的技能id，前端显示和技能转换后端校验用
        local washTimes = s[5] --如果是技能3的话可以洗练转换，该字段为洗练次数
        if nextSid and nextSid == "" then
            nextSid = nil
        end
        
        return {sid = sid, lv = lv, exp = exp, washTimes = washTimes, nextSid = nextSid}
    end
    return nil
end
