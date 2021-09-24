function getMyHonorsRanking(uid)
    local redis = getRedis()
 
    local key = "z"..getZoneId()..".rank.honors"
    
    local list = {}
    local result = redis:zrevrank(key,uid)
    result = tonumber(result)
    if result then result = result + 1 end
    return result or 0
end

-- 设置荣誉
function setHonorsRanking(uid,score)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.honors"
    
    local list = {}
    local result = redis:zadd(key,score,uid)

    activity_setopt(uid,'personalHonor',{score=score},true)

    result = tonumber(result) or 0
    
    return result
end

function getHonorsRanking(page)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.honors"
    
    page = tonumber(page) or 1
    if page < 1 then page = 1 end
    if page > 5 then page = 5 end
    local start = (page - 1) * 20
    
    local list = {}
    local result = redis:zrevrange(key,start,start+19,'withscores')
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local item = {}
            if type(item) == "table" and next(result) then
                item.uid = v[1]
                item.rank = start+k
                item.score = v[2]
                table.insert(list,item)
            end
        end
    end
    return list
end

function refreshHonorsRanking()
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.honors"
    
    local result = db:getAllRows("select uid,nickname,level,reputation from userinfo ORDER BY reputation DESC")
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            redis:zadd(key,v.reputation,v.uid)
        end 
    end
end

function getMyFcRanking(uid)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.fc"
    
    local list = {}
    local result = redis:zrevrank(key,uid)
    result = tonumber(result)
    if result then result = result + 1 end
    return result or 0
end

function setFcRanking(uid,score)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.fc"
    
    local list = {}
    local result = redis:zadd(key,score,uid)

    activity_setopt(uid,'fightRank',{score=score},true)
    
    
    result = tonumber(result) or 0    
    return result
end

-- 异星矿场排行榜
-- uid 
-- score  --个人的总积分 调alien model 下setMineCount方法,model.m_count是最终值
-- aid    -- 军团id
-- count  -- 这次个人加的积分 
function setAlienRanking(uid,score,aid,count)
    local redis = getRedis()
    local weeTs = getWeeTs()
    local zid   = getZoneId()
    if score>1000 then
        local key = "z"..zid..".rank.alienMine."..weeTs
        local result = redis:zadd(key,score,uid)
        redis:expire(key,432000)
        result = tonumber(result) or 0  
    end  
    if aid~=nil and aid>0 and count>0  then
        local alliancekey= "z"..zid..".rank.alienMineAlliance.aid."..aid.."ts"..weeTs
        local newscore =tonumber(redis:incrby(alliancekey,count))
        redis:expire(alliancekey,24*3600)
        local akey = "z"..zid..".rank.alienMineAlliance."..weeTs
        if newscore>0 then
            local result = redis:zadd(akey,newscore,aid)
            redis:expire(akey,432000)
        end
    end
    return result
end
-- 获取矿场的排名排行榜
function getAlienMineRanking(limit)

    local redis = getRedis()
    local weeTs = getWeeTs()
    local key = "z"..getZoneId()..".rank.alienMine."..weeTs
    local list = {}
    local result = redis:zrevrange(key,0,limit,'withscores')
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local item = {}
            if type(item) == "table" and next(result) then
                item.id = v[1]
                item.rank = k
                item.score = v[2]
                table.insert(list,item)
            end
        end
    end
    return list
end
-- 获取矿场的排名排行榜
function getAlienMineAllinceRanking(limit)

    local redis = getRedis()
    local weeTs = getWeeTs()
    local key = "z"..getZoneId()..".rank.alienMineAlliance."..weeTs
    local list = {}
    local aidlist={}
    local result = redis:zrevrange(key,0,limit,'withscores')
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local item = {}
            if type(item) == "table" and next(result) then
                item.id = v[1]
                item.rank =k
                item.score = v[2]
                table.insert(list,item)
                table.insert(aidlist,tonumber(item.id))
            end
        end
    end
    return list,aidlist
end

function getFcRanking(page)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.fc"
    
    page = tonumber(page) or 1
    if page < 1 then page = 1 end
    if page > 5 then page = 5 end
    local start = (page - 1) * 20
    
    local list = {}
    local result = redis:zrevrange(key,start,start+19,'withscores')
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local item = {}
            if type(item) == "table" and next(result) then
                item.uid = v[1]
                item.rank = start+k
                item.score = v[2]
                table.insert(list,item)
            end
        end
    end
    return list
end


function setArenaRanking(uid,rank)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.arena"
    
    local list = {}
    local result = redis:zadd(key,rank,uid)
    result = tonumber(result) or 0    
    return result
   
end

function getArenaRanking()
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.arena"
     
    local list = {}
    local result = redis:zrange(key,0,99,'withscores')
    if type(result) == "table" and next(result) then
        list=result
    end
    return list
end
--获取军事演习前top  取count个人
function getArenaTopRank(top,count)
    local list = {} 
    local db = getDbo()
    local result = db:getAllRows("select uid,ranking from userarena WHERE ranking>0 and ranking <="..top .." order by ranking ASC LIMIT "..count )
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            
            local item = {tonumber(v.uid),k}
            table.insert(list,item)
          
        end 
    end
    return list
end

function getArenaRankingtoMysql()
    -- body
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.arena"
    local list = {}    
    local result = db:getAllRows("select uid,ranking from userarena WHERE ranking>0 and ranking<101 ")
    redis:del(key)  
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            redis:zadd(key,tonumber(v.ranking),tonumber(v.uid))
            local item = {tonumber(v.uid),tonumber(v.ranking)}
            table.insert(list,item)
        end 
    end

    return list
end

function refreshFcRanking()
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.fc"
    
    local result = db:getAllRows("select uid,nickname,level,fc from userinfo ORDER BY fc DESC")
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            redis:zadd(key,v.fc,v.uid)
        end 
    end
end

function getMyChallengeRanking(uid)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.challenge"
    
    local list = {}
    local result = redis:zrevrank(key,uid)
    result = tonumber(result)
    if result then result = result + 1 end
    return result or 0
end

function setChallengeRanking(uid,score,score_at)
    local atNum = (2000000000 - score_at) / 1000000000
    if atNum >= 1 then atNum = 0.9 end

    local score1 = score + atNum

    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.challenge"
    
    local list = {}
    local result = redis:zadd(key,score1,uid)
    activity_setopt(uid,'personalCheckPoint',{score=score},true)
    
    result = tonumber(result) or 0
    return result
end

local function getIntPart(x)
    x = tonumber(x) or 0
    local y = math.ceil(x)
    if x <= 0 then
       return y
    end

    if y == x then
       x = y
    else
       x = y - 1
    end

    return x
end

function getChallengeRanking(page)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.challenge"
    
    page = tonumber(page) or 1
    if page < 1 then page = 1 end
    if page > 5 then page = 5 end
    local start = (page - 1) * 20
    
    local list = {}
    local result = redis:zrevrange(key,start,start+19,'withscores')
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local item = {}
            if type(item) == "table" and next(result) then
                item.uid = v[1]
                item.rank = start+k
                item.score = getIntPart(v[2])
                table.insert(list,item)
            end
        end
    end
    return list
end

function refreshChallengeRanking()
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.challenge"
    
    local result = db:getAllRows("select u.uid,u.nickname,u.level,c.star,c.star_at from userinfo AS u LEFT JOIN challenge AS c ON(u.uid=c.uid) WHERE c.star>=0 ORDER BY c.star DESC")
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local atNum = (2000000000 - v.star_at) / 1000000000
            if atNum >= 1 then atNum = 0.9 end
            local score1 = v.star + atNum

            if score1 > 0 then
                redis:zadd(key,score1,v.uid)
            end
        end 
    end
end

-- 等级 ------------------------------------------------

function setLevelRanking(uid,score)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.level"
    
    local result = redis:zadd(key,score,uid)
    result = tonumber(result) or 0    
    return result
end

function getLevelRanking(users)
    local list = {}

     if type(users) ~= "table" then
        return list
    end

    local redis = getRedis()
    
    local key = "z"..getZoneId()..".rank.level"
    
    for _,v in ipairs(users) do
        list[v] = (redis:zrevrank(key,v) or 10000) + 1
    end
    
    return list
end

function refreshLevelRanking()
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.level"
    
    local result = db:getAllRows("select uid,nickname,level,fc from userinfo ORDER BY fc DESC")
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            redis:zadd(key,v.level,v.uid)
        end 
    end
end


-- 活动 大转盘排行 ------------------------------------------------
function setWheelFortuneRanking(uid,score)
    local result
    local key = "z"..getZoneId()..".ac.rank.wheelFortune"

    local redis = getRedis()
    
    redis:watch(key)
    redis:multi()
    redis:zadd(key,score,uid)       
    redis:expire(key,432000)
    result = redis:exec()

    local count = redis:zcard(key)
    if count > 10 then
        redis:zremrangebyrank(key,0,count-11)
    end
    
    return result
end

function getWheelFortuneRanking()
    local key = "z"..getZoneId()..".ac.rank.wheelFortune"

    local list = {}

    local redis = getRedis()
    local result = redis:zrevrange(key,0,-1,'withscores')

    if type(result) == 'table' then
        list = result
    end
    
    return list
end


-- 活动通用排行榜
function setActiveRanking(uid,score,activeName,maxLenth,st,et)
    if not score or not st or not activeName or not uid then
        return false
    end

    local result
    local key = "z"..getZoneId()..".ac.rank."..st.."."..activeName
    local ts = getClientTs()

    local redis = getRedis()
    local data = redis:get(key)
    data = data and json.decode(data)

    if type(data) ~= 'table' then
        data = {{uid,score,ts}}
    else     
        local inRank = false

        for k,v in ipairs(data) do
            if type(v) == 'table' then
                if v[1] == uid then
                    data[k] = {uid,score,ts}
                    inRank = true
                    break
                end
            end
        end

        if not inRank then
            table.insert(data,{uid,score,ts})
        end

        local rankLength = #data
        local maxLenth = maxLenth or  10
        local delStart = maxLenth + 1

        table.sort(data,function(a,b)
                if type(a) == 'table' and type(b) == 'table' then
                    if tonumber(a[2]) > tonumber(b[2]) then
                        return true
                    elseif tonumber(a[2]) == tonumber(b[2]) then
                        return tonumber(a[3]) < tonumber(b[3])
                    end
                end
            end)

        if  rankLength > maxLenth then
            for i=delStart,rankLength do
                table.remove(data,delStart)
            end
        end
    end
    
    local ranklist = json.encode(data)
    local result = redis:set(key,ranklist)
    writeActiveRankLog(ranklist,activeName,st) -- 排行榜记录日志

    local activeTs = (et or 0) - (ts or 0)
    if activeTs < 0 then activeTs = 0 end

    redis:expire(key,432000 + activeTs)

    return result
end

--获取排行榜
function getActiveRanking(activeName,st)
    local key = "z"..getZoneId()..".ac.rank."..st.."."..activeName
    local list = {}

    local redis = getRedis()
    local result = redis:get(key)
    
    if result then
        list = json.decode(result) or {}
    end
    
    if type(list) ~= 'table' then
        list = {}
    end

    if result==nil then
        list=readRankfile(activeName,st)
        if type(list)=='table' then
            redis:set(key,json.encode(list))
            redis:expire(key,432000)
        end
    end
    
    table.sort(list,function(a,b)
        if type(a) == 'table' and type(b) == 'table' then
            if tonumber(a[2]) > tonumber(b[2]) then
                return true
            elseif tonumber(a[2]) == tonumber(b[2]) then
                return tonumber(a[3]) < tonumber(b[3])
            end
        end
    end)

    return list
end


-- 功能通用排行榜
-- uid
-- score 积分
-- round  轮数  亡者传0
--activeName  key 
-- maxLenth  排行榜长度
function setFuncRanking(uid,score,round,activeName,maxLenth)
    if not score or not activeName or not uid then
        return false
    end
    
    local result
    local key = "z"..getZoneId()..".rank."..activeName
    local ts = getClientTs()

    local redis = getRedis()
    local data = redis:get(key)
    data = data and json.decode(data)
    local tmp={}
    if round>=1 then
        tmp={uid,round,score}
    else
        tmp={uid,score,ts}
    end
    if type(data) ~= 'table' then
        data = {tmp}
    else     
        local inRank = false

        for k,v in ipairs(data) do
            if type(v) == 'table' then
                if v[1] == uid then
                    data[k] = tmp
                    inRank = true
                    break
                end
            end
        end

        if not inRank then
            table.insert(data,tmp)
        end

        local rankLength = #data
        local maxLenth = maxLenth or  10
        local delStart = maxLenth + 1

        table.sort(data,function(a,b)
                if type(a) == 'table' and type(b) == 'table' then

                    if round<=0 then
                        if tonumber(a[2]) > tonumber(b[2]) then
                            return true
                        elseif tonumber(a[2]) == tonumber(b[2]) then
                            return tonumber(a[3]) < tonumber(b[3])
                        end
                    else
                        if tonumber(a[2]) > tonumber(b[2]) then
                            return true
                        elseif tonumber(a[2]) == tonumber(b[2]) then
                            return tonumber(a[3]) > tonumber(b[3])
                        end
                    end
                end
            end)

        if  rankLength > maxLenth then
            for i=delStart,rankLength do
                table.remove(data,delStart)
            end
        end
    end
    local ranklist=json.encode(data)
    local result = redis:set(key,ranklist)
    redis:expire(key,432000)

    return result
end

--获取排行榜
function getFuncRanking(activeName)

    local key = "z"..getZoneId()..".rank."..activeName
    local list = {}

    local redis = getRedis()
    local result = redis:get(key)
    if result~=nil then
        list = json.decode(result)
    else
        return result    
    end 
    
    if type(list) ~= 'table' then
        list = {}
    end


    return list
end


---军衔前100的人
function setNewRankRanking(uid,score)
    if not score or not uid then
        return false
    end
    local redis = getRedis()
    local result
    local key = "z"..getZoneId()..".dayUserNewRank.All"
    
    local result = redis:zadd(key,score,uid)
    result = tonumber(result) or 0    
    --把当前最小的积分存起来
    local pointkey = "z"..getZoneId()..".minUserNewRankPoint"
    local point = redis:get(pointkey)
    if point==nil or  tonumber(point)>score then
        point=score
        redis:set(pointkey,point)
    end
    return result
end


--获取排行榜
function getNewRankRanking(start,ends)
    local redis = getRedis()
    
    local key = "z"..getZoneId()..".dayUserNewRank.All"
        
    local list = {}
    local result = redis:zrevrange(key,start,ends,'withscores')

    if result==nil or not next(result) then
        --local x = 1
        local db = getDbo()
        local cuuturt = getWeeTs()+108000
        local rankCfg =getConfig("rankCfg")
        result = db:getAllRows("select uid,rp,rpt,urt from  userinfo where rp >=:rp and level>=:level ORDER BY rp DESC , rpt ASC LIMIT 200",{rp=rankCfg.minRankPointRanking,level=rankCfg.minlevelRanking})
        if next(result) then
            for k,v in pairs(result) do
                local uid = tonumber(v.uid) 
                local urt = tonumber(v.urt)
                local rp = tonumber(v.rp)
                if urt<cuuturt-86400 then
                    
                    local rpt = tonumber(v.rpt)
                    
                    if rp>rankCfg.minPoint then
                        rp=rp-math.ceil(((rp-rankCfg.minPoint)*rankCfg.pointDecrease)*((cuuturt-86400-urt)/86400))
                    end
                end
                setNewRankRanking(uid,rp)
            end

        end
        result = redis:zrevrange(key,start,ends,'withscores')
    end    

    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            local item = {}
            if type(item) == "table" and next(result) then
                item.uid = v[1]
                item.rank = start+k
                item.score = v[2]
                table.insert(list,item)
            end
        end
    end
    return list

end

-- 活动装备探索物资排行榜
function setEquipSearchRanking(uid,score,st)
    local result
    local key = "z"..getZoneId()..".ac.rank.equipSearch." ..  st
    local ts = getClientTs()

    local redis = getRedis()
    local data = redis:get(key)
    data = data and json.decode(data)

    if type(data) ~= 'table' then
        data = {{uid,score,ts}}
    else     
        local inRank = false

        for k,v in ipairs(data) do
            if type(v) == 'table' then
                if v[1] == uid then
                    if score <= v[2] then
                        return true
                    end

                    data[k] = {uid,score,ts}
                    inRank = true
                    break
                end
            end
        end

        if not inRank then
            table.insert(data,{uid,score,ts})
        end

        local rankLength = #data
        local maxLenth = 10
        local delStart = maxLenth + 1

        table.sort(data,function(a,b)
                if type(a) == 'table' and type(b) == 'table' then
                    if tonumber(a[2]) > tonumber(b[2]) then
                        return true
                    elseif tonumber(a[2]) == tonumber(b[2]) then
                        return tonumber(a[3]) < tonumber(b[3])
                    end
                end
            end)

        if  rankLength > maxLenth then
            for i=delStart,rankLength do
                table.remove(data,delStart)
            end
        end
    end
    
    local result = redis:set(key,json.encode(data))
    redis:expire(key,432000)

    return result
end

function getEquipSearchRanking(st)
    local key = "z"..getZoneId()..".ac.rank.equipSearch." .. st

    local list = {}

    local redis = getRedis()
    local result = redis:get(key)
    
    if result then
        list = json.decode(result) or {}
    end
    
    if type(list) ~= 'table' then
        list = {}
    end

    table.sort(list,function(a,b)
        if type(a) == 'table' and type(b) == 'table' then
            if tonumber(a[2]) > tonumber(b[2]) then
                return true
            elseif tonumber(a[2]) == tonumber(b[2]) then
                return tonumber(a[3]) < tonumber(b[3])
            end
        end
    end)

    return list
end

function delEquipSearchRanking(st)
    local key = "z"..getZoneId()..".ac.rank.equipSearch." .. st
    local redis = getRedis()
    local result = redis:del(key)

    return result
end

-- 活动装备探索物资排行榜
-- st 活动起始时间
function setEquipSearchIIRanking(uid,score,st,et)
    local result
    local key = "z"..getZoneId()..".ac.rank.equipSearch." ..  st
    local ts = getClientTs()

    local redis = getRedis()
    local data = redis:get(key)
    data = data and json.decode(data)

    if type(data) ~= 'table' then
        data = {{uid,score,ts}}
    else     
        local inRank = false

        for k,v in ipairs(data) do
            if type(v) == 'table' then
                if v[1] == uid then
                    if score <= v[2] then
                        return true
                    end

                    data[k] = {uid,score,ts}
                    inRank = true
                    break
                end
            end
        end

        if not inRank then
            table.insert(data,{uid,score,ts})
        end

        local rankLength = #data
        local maxLenth = 10
        local delStart = maxLenth + 1

        table.sort(data,function(a,b)
                if type(a) == 'table' and type(b) == 'table' then
                    if tonumber(a[2]) > tonumber(b[2]) then
                        return true
                    elseif tonumber(a[2]) == tonumber(b[2]) then
                        return tonumber(a[3]) < tonumber(b[3])
                    end
                end
            end)

        if  rankLength > maxLenth then
            for i=delStart,rankLength do
                table.remove(data,delStart)
            end
        end
    end
    
    local result = redis:set(key,json.encode(data))
    redis:expireat(key,et+172000)

    return result
end

-- st 活动起始时间
function getEquipSearchIIRanking(st)
    local key = "z"..getZoneId()..".ac.rank.equipSearch." .. st

    local list = {}

    local redis = getRedis()
    local result = redis:get(key)
    
    if result then
        list = json.decode(result) or {}
    end
    
    if type(list) ~= 'table' then
        list = {}
    end

    table.sort(list,function(a,b)
        if type(a) == 'table' and type(b) == 'table' then
            if tonumber(a[2]) > tonumber(b[2]) then
                return true
            elseif tonumber(a[2]) == tonumber(b[2]) then
                return tonumber(a[3]) < tonumber(b[3])
            end
        end
    end)

    return list
end

function setRanking(rankingName,uid,score,maxLength)
    assert(rankingName and uid and score,"need ranking name")
    local redis = getRedis()

    local key = "z"..getZoneId().."."..rankingName
    local ts = getClientTs()
    local data = redis:get(key)
    data = data and json.decode(data)
    score = tonumber(score)
    if type(data) ~= 'table' then
        data = {{uid,score,ts}}
    else
        local foundIndex
        local foundPos = false
        local posIndex
        for k,v in ipairs(data) do
            if type(v) == 'table' then

                if not foundPos then
                    if v[2]<score then
                        foundPos = true
                        posIndex = k
                    end
                end

                if tostring(v[1]) == tostring(uid) then
                    foundIndex = k
                end
            end
        end

        if foundIndex then
            table.remove(data,foundIndex)
            if not posIndex then
                table.insert(data,{uid,score,ts})
            else
                if foundIndex<posIndex then
                    posIndex = posIndex-1
                end
                table.insert(data,posIndex,{uid,score,ts})
            end
        else
            if posIndex then
                table.insert(data,posIndex,{uid,score,ts})
            else
                table.insert(data,{uid,score,ts})
            end
        end

        local rankLength = #data
        local maxLength = maxLength or  #data

        if  rankLength > maxLength then
            local delNum = rankLength - maxLength
            while delNum>0 do
                table.remove(data,#data)
                delNum = delNum-1
            end
        end
    end
    local list=json.encode(data)
    local result = redis:set(key,list)
   
    return result
end

--获取排行榜
function getRanking(rankingName,page,num)

    local key = "z"..getZoneId().."."..rankingName
    local list = {}

    local redis = getRedis()
    local result = redis:get(key)

    if result then
        list = json.decode(result) or {}
    end

    if type(list) ~= 'table' then
        list = {}
    end
    local startIndex = 1
    local endIndex = #list

    if page then 
        startIndex = (page-1)*num+1
        endIndex = page*num
    end

    if startIndex>#list then
        startIndex =#list
    end
    if endIndex>#list then
        endIndex = #list
    end

    local returnList = {}
    if startIndex ==0 then
        return returnList
    end
    
    if startIndex<=endIndex then
        for i= startIndex,endIndex do
            local item = {}
            item.uid = list[i][1]
            item.rank = i
            item.score = list[i][2]
            table.insert(returnList,item)
        end
    end
    return returnList
end

function getMySwChallengeRanking(uid)
    local rankingList = getRanking("rank.swchallenge")
    for k,v in ipairs(rankingList) do
        if tostring(v.uid) == tostring(uid) then
            return k
       end
    end
    return 0
end

function setSwChallengeRanking(uid,score)
    local result = setRanking("rank.swchallenge",uid,score,200)

    result = tonumber(result) or 0
    return result
end

function getSwChallengeRanking(page)
    return getRanking("rank.swchallenge",page,20)
end

function refreshSwChallengeRanking()
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.swchallenge"
    
    local result = db:getAllRows("select uid,maxpos,maxpostime from swchallenge order by maxpos desc,maxpostime")
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            setSwChallengeRanking(v.uid,v.maxpos)
        end 
    end
end

function getRechargeCompetitionRankList(activeInfo,activeCfg)
    local giftCenterUrl = getConfig("config.z".. getZoneId() ..".giftCenterUrl")
    local postdata = {
        st=activeInfo.st,
        et=activeInfo.et,
        zoneids=json.encode(activeCfg.zoneids),
        rankLimit=activeCfg.ranklimit,
        rankMixValue=activeCfg.rankMixValue,
    }

    postdata = formPostData(postdata)

    local http = require("socket.http")
    http.TIMEOUT= 3
    local respbody, code = http.request(giftCenterUrl.."rechargeCompetition",postdata)
    -- print('------',giftCenterUrl.."rechargeCompetition",postdata)

    if tonumber(code) == 200 then     
        local result = json.decode(respbody)
        if type(result) == 'table' and result.ret == 0 then
            return result.data
        end
    end

    writeLog('rechargeCompetition:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'))
end

-- 设置没人每天参加排行榜的积分
function setNewsUidRankingScore(uid,subtype,value)
    -- 开关判断
    if not switchIsEnabled('dnews') then
        return false
    end
    local weeTs = getWeeTs()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank."..subtype..weeTs.."uid."..uid
    local count=0
    local daily = getConfig('dailyNewsCfg.dailyList.'..subtype)
    if daily then
        local tmpcondition=0
        if value~=nil and value>0 then
            count=redis:incrby(key,value)
        else
            count=redis:incr(key)
        end
        redis:expire(key,86400)
        if daily.condition1~=nil and daily.condition1>0 then
            tmpcondition=daily.condition1
        end
        if tonumber(count)>=tmpcondition then
            setNewsRanking(uid,count,subtype)
        end
    end
end

--  每日捷报设置排行榜
-- 玩家的uid
-- 玩家的积分或者是次数
-- 所有游戏中的系统
function setNewsRanking(uid,score,subtype)
    local redis = getRedis()
    local weeTs = getWeeTs()
    local key = "z"..getZoneId()..".rank."..subtype..weeTs
    
    local list = {}
    local result = redis:zadd(key,score,uid)
    result = tonumber(result) or 0    
    redis:expire(key,345600)
    return result
end

function getNewsRanking(limit,subtype)

    local redis = getRedis()
    local weeTs = getWeeTs()
    local key = "z"..getZoneId()..".rank."..subtype..weeTs
    local list = {}
    local result = redis:zrevrange(key,0,limit-1,'withscores')
    return result
end

-- 获得军团战力排名
function getMyARanking(aid)
    local redis = getRedis()
    local key = "r_alliance.rank"
    local list = {}
    local result = redis:zrevrank(key,aid)
    result = tonumber(result)
    if result then result = result + 1 end
    return result or 0
end

-- 刷新成就榜
function refreshAchievementRanking()
    local db = getDbo()
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.achievement"

    local list = {}
    local result = db:getAllRows("select uid,achvnum,achvat from achievement where achvnum > 0 ORDER BY achvnum DESC , achvat Asc limit 100")
    if type(result) == "table" and next(result) then
        for k,v in pairs(result) do
            if k <= 10 then
                table.insert(list,v)
            end
            redis:hset(key,v.uid,k)
        end
    end

    if next(list) then
        local tb = {}

        for k,v in pairs(list) do
            local uid = tonumber(v.uid)
            if uid and uid > 0 then
                local userinfo = getUserObjs(uid,true).getModel('userinfo')
                
                tb[k] = {
                    0, -- 点赞数
                    uid,
                    userinfo.nickname,
                    userinfo.rank,
                    userinfo.level,
                    userinfo.fc,
                    userinfo.pic,
                    userinfo.apic,
                    userinfo.bpic,
                    tonumber(v.achvnum),  -- 完成数量
                    tonumber(v.achvat), -- 完成时间
                }

            end
        end

        key = "z"..getZoneId()..".rank.achievement.list"
        redis:set(key,json.encode(tb))
    end
end

function getAchievementRankingList()
    local result = getRedis():get("z"..getZoneId()..".rank.achievement.list")
    return result and json.decode(result) or {}
end

function getMyAchievementRanking(uid)
    local key = "z"..getZoneId()..".rank.achievement"
    return tonumber(getRedis():hget(key,uid))
end

