achievements=
{
    achievementsId={"CgkI6KKywIEbEAIQAA","CgkI6KKywIEbEAIQAQ","CgkI6KKywIEbEAIQAg","CgkI6KKywIEbEAIQAw","CgkI6KKywIEbEAIQBA","CgkI6KKywIEbEAIQBQ","CgkI6KKywIEbEAIQBg","CgkI6KKywIEbEAIQBw","CgkI6KKywIEbEAIQCA","CgkI6KKywIEbEAIQCQ","CgkI6KKywIEbEAIQCg","CgkI6KKywIEbEAIQCw","CgkI6KKywIEbEAIQDA","CgkI6KKywIEbEAIQDQ","CgkI6KKywIEbEAIQDg","CgkI6KKywIEbEAIQDw"},
}

-- 完成新手引导；
-- 达到少尉军衔；  达到上校军衔；   达到上将军衔；   
-- 人物等级达到10级；   人物等级达到30级；   人物等级达到58级； 
-- 第一章获得全部48颗星；    第五章获得全部48颗星；     第十一章获得全部48颗星；
-- 在坦克工厂解锁豹式坦克；   在坦克工厂解锁天启坦克；  在坦克工厂解锁尖啸者火箭车；
-- 全部的五种资源达到1M；  全部的五种资源达到10M；  全部的五种资源达到100M；

function achievements:clearAll()
    for k,v in pairs(self.achievementsId) do
        self:clearIsSendId(k)
    end
end

function achievements:getIsSendId(id)
    local isSend = false
    if CCUserDefault:sharedUserDefault():getIntegerForKey(self.achievementsId[id])==1 then
        isSend = true
    end
    return isSend
end

function achievements:setIsSendId(id)
    CCUserDefault:sharedUserDefault():setIntegerForKey(self.achievementsId[id],1)
end

function achievements:clearIsSendId(id)
    CCUserDefault:sharedUserDefault():setIntegerForKey(self.achievementsId[id],0)
end


function achievements:judgeAchievements()

    --完成新手引导成就
    if newGuidMgr:isNewGuiding()==false and self:getIsSendId(1)==false then
        self:sendAchievementsById(1)
        self:setIsSendId(1)
    end

    -- 达到少尉军衔
    if playerVoApi:getRank()>=6 and self:getIsSendId(2)==false then
        self:sendAchievementsById(2)
        self:setIsSendId(2)
    end

    -- 达到上校军衔
    if playerVoApi:getRank()>=11 and self:getIsSendId(3)==false then
        self:sendAchievementsById(3)
        self:setIsSendId(3)
    end

    -- 达到上将军衔
    if playerVoApi:getRank()>=14 and self:getIsSendId(4)==false then
        self:sendAchievementsById(4)
        self:setIsSendId(4)
    end
    --人物等级达到10级
    if playerVoApi:getPlayerLevel()>=10 and self:getIsSendId(5)==false then
        self:sendAchievementsById(5)
        self:setIsSendId(5)
    end
    --人物等级达到30级
    if playerVoApi:getPlayerLevel()>=30 and self:getIsSendId(6)==false then
        self:sendAchievementsById(6)
        self:setIsSendId(6)
    end
    --人物等级达到58级
    if playerVoApi:getPlayerLevel()>=58 and self:getIsSendId(7)==false then
        self:sendAchievementsById(7)
        self:setIsSendId(7)
    end

    --关卡1 48颗星星
    if checkPointVoApi:getStarById(1)==48 and self:getIsSendId(8)==false then
        self:sendAchievementsById(8)
        self:setIsSendId(8)
    end

    --关卡5 48颗星星
    if checkPointVoApi:getStarById(5)==48 and self:getIsSendId(9)==false then
        self:sendAchievementsById(9)
        self:setIsSendId(9)
    end

    --关卡11 48颗星星
    if checkPointVoApi:getStarById(11)==48 and self:getIsSendId(10)==false then
        self:sendAchievementsById(10)
        self:setIsSendId(10)
    end

    if self:tankLvIsGet(37) and self:getIsSendId(11)==false then
        self:sendAchievementsById(11)
        self:setIsSendId(11)
    end 

    if self:tankLvIsGet(49) and self:getIsSendId(12)==false then
        self:sendAchievementsById(12)
        self:setIsSendId(12)
    end 

    if self:tankLvIsGet(58) and self:getIsSendId(13)==false then
        self:sendAchievementsById(13)
        self:setIsSendId(13)
    end 


    if self:resIsGetLimit(1000000) and self:getIsSendId(14)==false then
        self:sendAchievementsById(14)
        self:setIsSendId(14)
    end

    if self:resIsGetLimit(10000000) and self:getIsSendId(15)==false then
        self:sendAchievementsById(15)
        self:setIsSendId(15)
    end

    if self:resIsGetLimit(100000000) and self:getIsSendId(16)==false then
        self:sendAchievementsById(16)
        self:setIsSendId(16)
    end


    -- 在坦克工厂解锁豹式坦克；   在坦克工厂解锁天启坦克；  在坦克工厂解锁尖啸者火箭车；
-- 全部的五种资源达到1M；  全部的五种资源达到10M；  全部的五种资源达到100M；

end

function achievements:tankLvIsGet(lv)
    local isLimit = false
    local buildingVo1=buildingVoApi:getBuildiingVoByBId(11)
    local buildingVo2=buildingVoApi:getBuildiingVoByBId(12)

    if buildingVo1.level>=lv or buildingVo2.level>=lv then
        isLimit=true
    end
    return isLimit
end


function achievements:resIsGetLimit(num)
   local isLimit = false
   if playerVoApi:getR1()>=num and playerVoApi:getR2()>=num and playerVoApi:getR3()>=num and playerVoApi:getR4()>=num and playerVoApi:getGold()>=num then
        isLimit = true
   end  
   return isLimit
end


function achievements:sendAchievementsById(id)
    local key=self.achievementsId[id]
    local tmpTb={}
    tmpTb["action"]="sendAchievement"
    tmpTb["parms"]={}
    tmpTb["parms"]["key"]=tostring(key)
    local cjson=G_Json.encode(tmpTb)
    G_accessCPlusFunction(cjson)
end








