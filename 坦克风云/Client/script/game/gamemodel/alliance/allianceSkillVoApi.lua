allianceSkillVoApi={
    allSkills={}
}

function allianceSkillVoApi:addAllianceSkill(skillTb)
    if SizeOfTable(self.allSkills)==0 then
        for k,v in pairs(allianceSkillCfg) do
            local svo=allianceSkillVo:new();
            if v.sid=="22" or v.sid=="23" then
                svo:initWithData(k,1,0) --城市等级和城市护盾默认是1级
            else
                svo:initWithData(k,0,0)
            end
            self.allSkills[k]=svo
        end
    end
    
    if skillTb~=nil then
        for k,v in pairs(skillTb) do
            local id=tonumber(RemoveFirstChar(k))
            self.allSkills[id].level=tonumber(skillTb[k][1])
            self.allSkills[id].exp=tonumber(skillTb[k][2])
        end
    end

end

function allianceSkillVoApi:update(lvTab)

     for k,v in pairs(lvTab) do
          local sVo=self.allSkills[k-100]
          sVo.level=v
     end
end

function allianceSkillVoApi:getAllSkills()
    return self.allSkills;
end

function allianceSkillVoApi:getSkillLvAndExpAndPerById(id)
    local lvCfg=allianceSkillCfg[tonumber(id)]["expRequire"]
    local percent=100;
    local skillLv=0
    local curExp=0
    local curMaxExp=0
    if lvCfg==nil then
        percent=0
        return skillLv,curExp,curMaxExp,percent
    end

    if tonumber(self.allSkills[id].level)~=allianceVoApi:getSelfAlliance().allianceMaxLevel then
        skillLv=self.allSkills[id].level or 0
        local sid=allianceSkillCfg[tonumber(id)].sid
        if skillLv==0 and (sid=="22" or sid=="23") then --如果是城市等级或者城市护盾科技默认等级为1
            skillLv=1
            self.allSkills[id].level=1
        end
        if tonumber(skillLv)>=1 then
            local skillExp=self.allSkills[id].exp
            curExp=tonumber(skillExp)-tonumber(lvCfg[skillLv])
            curMaxExp=tonumber(lvCfg[skillLv+1])-tonumber(lvCfg[skillLv])
            percent = math.floor(curExp*100/curMaxExp)
        else
            curExp=self.allSkills[id].exp
            curMaxExp=tonumber(lvCfg[1])
            percent = math.floor(curExp*100/curMaxExp)
        end
    end

    return skillLv,curExp,curMaxExp,percent
end

function allianceSkillVoApi:clear()
    if self.allSkills~=nil then
        for k,v in pairs(self.allSkills) do
            self.allSkills[k]=nil
        end
        self.allSkills=nil
    end
    self.allSkills={}
end

function allianceSkillVoApi:getSkillMaxLevel(id)
    local skillLv=0
    -- local allianceMaxLevel=allianceVoApi:getMaxLevel()
    local selfAlliance=allianceVoApi:getSelfAlliance()
    if selfAlliance then
        skillLv=selfAlliance.level
        local maxlevel = math.min(tonumber(allianceSkillCfg[tonumber(id)].maxlevel), allianceVoApi:getMaxLevel())

        if skillLv>=maxlevel then
            skillLv=maxlevel
        end
    end
    return skillLv
end
function allianceSkillVoApi:getSkillMaxExp(id)
    -- local allianceMaxLevel=allianceVoApi:getMaxLevel()
    local maxExp=0
    local selfAlliance=allianceVoApi:getSelfAlliance()
    if selfAlliance then
        local level = math.min(tonumber(allianceSkillCfg[tonumber(id)].maxlevel) + 1, selfAlliance.level + 1)
        -- if level>=allianceVoApi:getMaxLevel() then
        --     level=allianceVoApi:getMaxLevel()
        -- end 
        maxExp=tonumber(allianceSkillCfg[tonumber(id)]["expRequire"][level])
    end
    return maxExp
end
function allianceSkillVoApi:getSkillLevel(id)
    local level=0
    local sid=tonumber(id)
    for k,v in pairs(self.allSkills) do
        if sid and v and sid==tonumber(v.id) then
            level=v.level
        end
    end
    if level>=self:getSkillMaxLevel(id) then
        level=self:getSkillMaxLevel(id)
    end
    return level
end
function allianceSkillVoApi:getSkillExp(id)
    local exp=0
    local sid=tonumber(id)
    for k,v in pairs(self.allSkills) do
        if sid and v and sid==tonumber(v.id) then
            exp=v.exp
        end
    end
    if exp>=self:getSkillMaxExp(sid) then
        exp=self:getSkillMaxExp(sid)
    end
    return exp
end
function allianceSkillVoApi:setSkillExp(id,exp)
    local sid=tonumber(id)
    exp=tonumber(exp)
    for k,v in pairs(self.allSkills) do
        if sid and exp and v and sid==tonumber(v.id) then
            -- if exp>=self:getSkillMaxExp(sid) then
                -- self.allSkills[k].exp=self:getSkillMaxExp(sid)
            -- else
                self.allSkills[k].exp=exp
            -- end
        end
    end
end
function allianceSkillVoApi:setSkillLevel(id,level)
    local sid=tonumber(id)
    level=tonumber(level)
    for k,v in pairs(self.allSkills) do
         if sid and level and v and sid==tonumber(v.id) then
            -- if level >= self:getSkillMaxLevel() then
            --     self.allSkills[k].level=self:getSkillMaxLevel()
            -- else
                self.allSkills[k].level=level
            -- end
         end
    end
end

function allianceSkillVoApi:getGoldRepairRate()
    local rate = 1
    local skillLv = self:getSkillLevel(21)
    if allianceSkillCfg and allianceSkillCfg[21] then
        if allianceSkillCfg[21]["batterValue"] then
            if allianceSkillCfg[21]["batterValue"][skillLv] then
                rate = allianceSkillCfg[21]["batterValue"][skillLv]
            end
        end
    end

    return rate
end