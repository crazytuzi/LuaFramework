local userwarnew = {}

local cacheKeys = {
    -- 初始化地图标志 
    -- 参数:bid 
    -- 返回值:
    initMap = 'userwarnew.initMap%s', 
    
    -- 地图列表 
    -- 参数:bid 
    -- 数据:hash table 
    -- 返回值:{}
    map = 'userwarnew.map%s',
    
    -- 广播组 
    -- 参数:bid 
    -- 数据:hash table 
    -- 返回值:hgetall取出遍历
    radio = 'userwarnew.radio%s',
    
    -- 地块上的用户
    -- 参数:bid , lid
    -- 数据:hash table 
    -- 返回值:hgetall取出遍历
    landUser = 'userwarnew.landuser%s',
    
    -- 爆炸预警 
    -- 参数:bid,lid 
    -- 数据:string 
    -- 返回值:{横竖，{x,y}}
    warning = "userwarnew.warning%s",
    
    -- 地图上所有人数 
    -- 参数:bid 
    -- 数据:string 
    -- 返回值:num
    allSurvival = "userwarnew.allsurvivalnum%s",
    
    -- 战斗列表 
    -- 参数:bid，lid ,round
    -- 数据:set集合
    -- 返回值:smembers取出遍历
    battleList = "userwarnew.battlelist%s",
    
    -- 亡灵列表 
    -- 参数:bid，lid ,round
    -- 数据:set集合
    -- 返回值:smembers取出遍历
    zombieList = "userwarnew.zombielist%s",
    
    -- 每块地上的幸存者数量 活动期间常量 随用户操作动态更新
    -- 参数:bid，lid 
    -- 数据:string 
    -- 返回值 num
    survivalNum = "userwarnew.survivalnum%s",

    -- 每块地上的亡灵数量  活动期间常量 随用户操作动态更新
    -- 参数:bid，lid 
    -- 数据:string -- 返回值 num
    zombieNum = "userwarnew.zombienum%s",

    -- 每块地上的陷阱 
    -- 参数:bid，lid 
    -- 数据:hash table 
    -- 返回值 {陷阱id=设置者id} -- 陷阱id 前缀-uid-time
    trap1 = "userwarnew.trap1%s",
    trap2 = "userwarnew.trap2%s",
    
    -- 幸存者积分排行榜
    survivalRank = "userwarnew.survivalrank%s",
    
    -- 亡灵积分排行榜
    zombieRank = "userwarnew.zombierank%s",
    
    -- 地图爆炸
    blast="userwarnew.blast%s",
    
    -- 成员数据
    hashBidMember = 'userwarnew.members%s', -- bid
    
    -- 每回合抽卡记录
    -- 参数:bid,uid,round
    -- 数据：string
    -- 返回值：json table
    cards = "userwarnew.cards%s",
    
    -- 报名人数统计
    apply = "userwarnew.apply%s",

}

-- 区域战配置
local userWarCfg = getConfig('userWarCfg')    
-- buff对应的战斗属性
local buffAttribute = {
    b1 = {'dmg'},
    b2 = {'maxhp'},
    b3 = {'accuracy'},
    b4 = {'evade'},
    b5 = {'crit'},
    b6 = {'anticrit'},
}
-- 缓存过期时间(秒),默认一周
local expireTs = 604800
local usersData = {}
local function mkKey(...)
    local tmp = {...}
    return table.concat(tmp,'-')
end

-- 生成缓存key
local function mkCacheKey(cacheKey,...)
    local arg = {...}
    if cacheKeys[cacheKey] then
		local str = ''
		for i,v in ipairs(arg) do
		   str = str..'.'..v
		end

        return "z"..tostring(getZoneId())..".".. string.format(cacheKeys[cacheKey],str)
    end
end

local function getDay()
    local zone = getConfig('base.TIMEZONE')
    local weets = getWeeTs()
    weets = weets + zone * 3600
    local day = weets / 86400

    return day
end

-- 生成玩家去那个地块
function userwarnew.getPlace(bid)
    local x_max = userWarCfg.xMaxValue
    local y_max = userWarCfg.yMaxValue

    setRandSeed()
    local x = rand(1,x_max)
    local y = rand(1,y_max)
    
    return x,y
end

-- 获取战争id
-- params positionId 阵地编号
-- return int
function userwarnew.getWarId(positionId)
    local day = getDay()
    local positionId=positionId or 1
    return tonumber(positionId .. day)
end

-- 判断当天是否开启
function userwarnew.isEnable()
    return (getDay()%2) == userWarCfg.openDate
end

-- 获取战场打开状态
-- params int positionId 战场
-- return int 0 开启 其它为状态码
function userwarnew.getWarOpenStatus(positionId,bid)
    if not userwarnew.isEnable() then
        return -4002
    end

    local ts = getClientTs()
    local opents = userwarnew.getWarOpenTs(positionId)

    if ts < opents.st then
        return -4010
    end

    -- 战场已关闭
    if ts >= opents.et then
        return -4011
    end

    return 0
end

function userwarnew.isStart(bid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("stringStartFlag",bid)
    return tonumber(redis:getset(cacheKey,1))
end

-- 获取战场开放时间
-- params int positionId 战场
-- params int warId 战争标识
-- return int | table
function userwarnew.getWarOpenTs(positionId,warId)
    local open = {}
    local weets = getWeeTs()
    
    -- if warId then        
    --     local zone = getConfig('base.TIMEZONE')
    --     local day = tonumber(string.sub(warId,2))       
    --     ptb:e(warId) 
    --     weets = day * 86400 - (3600 * zone)
    -- end

    if userWarCfg.startWarTime then
        open.st = weets + userWarCfg.startWarTime[1] * 3600 + userWarCfg.startWarTime[2] * 60
        open.et = userwarnew.getBattleEndTime()

        return open
    end
end

-- 设置战斗结束标识
function userwarnew.setOverBattleFlag(warId,winner)
    winner = winner or 0
    local overKey = mkCacheKey("userwarBattleOverFlag",warId)
    local redis = getRedis()
    local ret = redis:set(overKey,winner) or redis:set(overKey,winner)
    redis:expire(overKey,expireTs)
end

-- 获取战斗结束标识
function userwarnew.getOverBattleFlag(warId)
    local overKey = mkCacheKey("userwarBattleOverFlag",warId)
    local redis = getRedis()
    local flag = redis:get(overKey)

    return flag
end

-- 从格式化的部队数据中获取设置的部队数据{{'a10001',5},{'a10002',5},}
-- 存的数据是属性加成算好的，需要换成动画能播的格式
local function getTroopsByInitTroopsInfo(initTroopsInfo)
    local troops = {}
    local totalnum = 0

    for k,v in pairs(initTroopsInfo) do
        if (tonumber(v.num) or 0) > 0 then
            table.insert(troops,{v.id,v.num})
            totalnum = totalnum + v.num
        else
            table.insert(troops,{})
        end
    end

    if totalnum <= 0 then
        troops = {}
    end

    return troops
end

-- 从战斗后的部队数据中获取胜余的坦克数量
-- return table, table
local function getDieTroopsByInavlidFleet(fleetinfo,invalidFleet)
    local troops = {}

    for k,v in pairs(fleetinfo) do
        if (v[2] or 0) > 0 then
            local dienum = v[2] - (invalidFleet[k] and invalidFleet[k][2] or 0)

            if dienum > 0 then
                troops[v[1]] = (troops[v[1]] or 0) + dienum
            end
        end
    end

    return troops
end

-- 格式化部队（处理成能战斗的格式，保存的时候是简化了的数据）
-- attField 属性字段
-- troops 部队数据
-- currTroops 当前存活下来的部队，如果有此值，需要将部队的数量和血量按当前数据重新计算
local function formatTroops(attField,troops,currTroops,buff,userBuffs)
    local attTroops = {}
    local attrNumForAttrStr = getConfig("common.attrNumForAttrStr")

    for m,n in pairs(troops) do
        attTroops[m] = {}
        if n[1] then
            for k,v in pairs(attField) do
                if v == 'abilityInfo' then
                    attTroops[m][v] = {    
                        debuff={},  
                        buff={},
                    }
                else
                    attTroops[m][v] = n[k]
                end
            end
        end
    end
    if type(currTroops) == 'table' and #currTroops > 0 then
        for k,v in ipairs(currTroops) do
            if not next(v) or (v[2] or 0) <= 0 then
                attTroops[k] = {}
            else
                attTroops[k].num = v[2]
                attTroops[k].hp = v[2] * attTroops[k].maxhp
            end
        end
    end

    -- 亡者增加的对方buff
    if type(buff) == 'table' then
        for attribute,warBuffLv in pairs(buff) do
            for k,v in pairs(attTroops) do
                if next(v) then                                  
                    attTroops[k][attribute] = attTroops[k][attribute] + warBuffLv
                end
            end
        end
    end
    
        -- 用户探索buff
    if type(userBuffs)=='table'  then
        -- 增益buff
        for buff,lv in pairs(userBuffs.add or {} ) do
            lv = tonumber(lv) or 0
            if lv > 0 and buffAttribute[buff] then
                for _,attribute in ipairs(buffAttribute[buff]) do
                    for k,v in pairs(attTroops) do
                        if v[attribute] then
                            if buff == 'b1' or buff == 'b2' then
                                attTroops[k][attribute] =  attTroops[k][attribute] * (1 + userWarCfg.eventUpBuff.list[buff].per * lv)
                                if attribute == 'maxhp' then
                                    attTroops[k].hp = attTroops[k].num * attTroops[k][attribute]
                                end
                            else
                                attTroops[k][attribute] =  attTroops[k][attribute] + (userWarCfg.eventUpBuff.list[buff].per * lv)
                            end
                        end
                    end
                end
            end
        end
        -- 减益buff
        for buff,lv in pairs(userBuffs.del or {} ) do
            lv = tonumber(lv) or 0
            if lv > 0 and buffAttribute[buff] then
                for _,attribute in ipairs(buffAttribute[buff]) do
                    for k,v in pairs(attTroops) do
                        if v[attribute] then
                            if buff == 'b1' or  buff == 'b2' then
                                attTroops[k][attribute] =  attTroops[k][attribute] * (1 - userWarCfg.eventDownBuff.list[buff].per * lv)
                                if attribute == 'maxhp' then
                                    attTroops[k].hp = attTroops[k].num * attTroops[k][attribute]
                                end
                            else
                                attTroops[k][attribute] =  attTroops[k][attribute] - (userWarCfg.eventDownBuff.list[buff].per * lv)
                                if attTroops[k][attribute]<0 then
                                    attTroops[k][attribute]=0
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    --[[     -- 亡者减少被攻击方的debuff
    if type(Debuff) == 'table' then
        for bfKey,bfVal in pairs(Debuff) do
            local attribute = attrNumForAttrStr[bfKey]
            for k,v in pairs(attTroops) do
                if v[attribute] then
                    if attribute == "dmg" then
                        attTroops[k][attribute] = math.ceil(attTroops[k][attribute] * bfVal)
                    elseif attribute == "maxhp" then
                        attTroops[k][attribute] = math.ceil(attTroops[k][attribute] * bfVal)
                        attTroops[k].hp = math.ceil(attTroops[k].num * attTroops[k][attribute])
                    end
                end
            end
        end
    end
    ]]

    return  attTroops
end

-- 按binfo获取三只部队的信息包含英雄
function userwarnew.getTroopsByBinfo(binfo)
    local troops = {
        {}
    }
    
    local heros = {
        {0,0,0,0,0,0},
    }

    if type(binfo) == 'table' and next(binfo) then
        local idIndex
        local numIndex
        for k,v in pairs(binfo[1]) do
            if v == 'id' then
                idIndex = k
            elseif v == 'num' then
                numIndex = k
            end

            if idIndex and numIndex then 
                break 
            end
        end

        local emptyTroop = {}
        if type(binfo[2]) == 'table' then
            for sn,snVal in pairs(binfo[2]) do
                if  type(binfo[2][sn]) == 'table' and next(binfo[2][sn]) then
                    for k,v in pairs(snVal) do
                        if next(v) then
                            troops[sn][k] = {v[idIndex], (tonumber(v[numIndex]) or 0)}
                        else
                            troops[sn][k] = emptyTroop
                        end
                    end
                end
            end
        end

        if type(binfo[3]) == 'table' then
            for sn,snVal in pairs(binfo[3]) do
                if  type(binfo[3][sn]) == 'table' and next(binfo[3][sn]) then
                    for k,v in pairs(snVal) do
                        if type(v) == 'string' and v ~= "" then
                            local heroIndexInfo = string.split(v,'-')
                            heros[sn][k] = heroIndexInfo[1]
                        end
                    end
                end
            end
        end
    end

    return troops,heros
end

-- log
function userwarnew.writeLog(log)
    writeLog(log,'userwarnew')
end

-- 发奖胜利调用
-- aid 军团id
-- bid 战斗id
-- areaid  报名那个区域类型
-- method  ＝1 发生过战斗 ＝0 未发生
function userwarnew.sendWinReward(aid,bid,areaid,method)
    local redis = getRedis()
    local key="z" .. getZoneId() ..".alliancewarnew.".."bid"..bid.."areaid"..areaid
    local ret =redis:incr(key)
    local title=43
    local winreward=userWarCfg['reward'..areaid]
    local weet=getWeeTs()
    if ret==1 then
        local users={}
        if method==0 then
            local ret =  M_alliance.getalliance{alliancebattle=1,method=1,aid=aid}
            local ents = userWarCfg.signUpTime.finish[1]*3600+userWarCfg.signUpTime.finish[2]*60
            local ents = weet+ents
            if  ret and  ret.data.members then  
                for mk,mv in pairs(ret.data.members) do
                    if tonumber(mv.join_at)<=ents then
                        local tmp={uid=mv.uid}
                        table.insert(users,tmp)
                    end
                end
            end
        else
            local db = getDbo()
            result = db:getAllRows("select uid from  useralliancewar where bid=:bid  and aid=:aid and binfo<>'{}' ", {bid=bid,aid=aid})
            if result then
                users=result
            end
        end
        local item={q=winreward.reward,h=winreward.serverReward}
        for k,v in pairs (users) do
            local uid=tonumber(v.uid)
            if moduleIsEnabled('rewardcenter') then
                local reward = item.h or {1,item.h}
                local ret = sendToRewardCenter(uid,'aw',title,weet,nil,{type=title,bid=bid},reward)
            else
                local ret = MAIL:mailSent(uid,1,uid,'','',title,json.encode{type=title,bid=bid},1,0,2,item)
            end
        end
    end
    redis:expire(key,86400)
end

-- 调用聊天发送
 --[[
    1.chatSystemMessage8="%s与%s即将在%s开始对战。",
    每场战斗开始的时候发送
    2.chatSystemMessage9="%s与%s在%s的战斗结束，%s取得了胜利，开始享受为期%s小时的资源增产Buff。",
    每场战斗胜利的时候发送
    3.chatSystemMessage10="今晚%s，%s与%s将在%s展开残酷的对决。",
    每场军团战报名成功的时候发送
]]
function userwarnew.sendMsg(msgType,params)
    local ts = getClientTs()
    local msg

    if msgType == 1 then
        -- "param":["红色军团名字","蓝色军团名字","战场索引"]}
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage8",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    elseif msgType == 2 then
        -- "param":["红色军团名字","蓝色军团名字","战场索引","获胜军团名字","资源增产Buff持续时间"]
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage9",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    elseif msgType == 5 then
        -- 有一个军团报名军团战的时候
        -- 报名截止的时候
        -- "param":["战场索引","战场开战时间"]
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage26",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    elseif msgType == 4 then
        -- 战斗开始即结束的时候
        -- "param":["战场索引","获胜军团名字","资源增产Buff持续时间"]
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage27",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    else
        -- "param":["战场开战时间","红色军团名字","蓝色军团名字","战场索引"]
        msg = {
            sender=0,
            reciver=0,
            channel=1,            
            sendername="",
            recivername="",
            type="chat",
            content={
                isSystem=1,
                message={
                    key="chatSystemMessage10",
                    param=params,
                },
                ts=ts,
                contentType=3,
                subType=4,
            },
        }
    end

    return sendMessage(msg)
end

local function returnError(title)
    error("save cache fail"..':'..title)
end

-- 每次主动调取getMap接口都将写入广播组 超过5分钟的不推
function userwarnew.joinRadio(bid,uid)
    local cacheKey = mkCacheKey("radio",bid)
    local redis = getRedis()
    
    redis:hset(cacheKey,uid,getClientTs())
    redis:expire(cacheKey,expireTs)
    
    return true
end

-- 获取广播组成员
function userwarnew.getRadioUserList(bid)
    local cacheKey = mkCacheKey("radio",bid)
    local redis = getRedis()
    
    return redis:smembers(cacheKey)
end

-- 每个地块上的所有用户放入缓存
function userwarnew.setLandUser(bid,lid,uid,value)
    --writeLog('setLandUser-st:'..uid..','..json.encode({bid,lid,uid,value}),'setLandUser')
    local cacheKey = mkCacheKey("landUser",bid,lid)
    local redis = getRedis()
    local value = value or 0
    --writeLog('setLandUser-cacheKey:'..uid..','..cacheKey,'setLandUser')
    redis:hset(cacheKey,uid,value)
    redis:expire(cacheKey,expireTs)
    --writeLog('setLandUser-fin:'..uid,'setLandUser')
    
    return true
end

-- 获取一个地块上的所有用户列表
function userwarnew.getLandUserList(bid,lid)
    local cacheKey = mkCacheKey("landUser",bid,lid)
    local redis = getRedis()
    
    return redis:hgetall(cacheKey)
end

-- 从地块上移除一个用户
function userwarnew.delLandUser(bid,lid,uid)
    local cacheKey = mkCacheKey("landUser",bid,lid)
    local redis = getRedis()

    --writeLog('delLandUser-st:'..(bid or 'bid')..','..(lid or 'lid')..','..(uid or 'uid'),'landuserdel')
    redis:hdel(cacheKey,uid)
    --writeLog('delLandUser-et:'..(bid or 'bid')..','..(lid or 'lid')..','..(uid or 'uid'),'landuserdel')
    
    return true
end

-- 获取地块上单一用户的状态
function userwarnew.getLandUser(bid,lid,uid)
    local cacheKey = mkCacheKey("landUser",bid,lid)
    local redis = getRedis()
    
    return redis:hget(cacheKey,uid)
end

function userwarnew.init(bid)
    -- 初始化战场数据 包括所有人数 初始预警
    local redis = getRedis()
    local cacheKey = mkCacheKey("survivalNum",bid)   
    local survivalNum = 0 
end

-- 根据bid读取地图数据
function userwarnew.getMap(bid)
	-- 检测是否已经生成过 没有继续生成 存在则返回当前
    local redis = getRedis()
    local cacheKey = mkCacheKey("map",bid)   
    local map = json.decode(redis:get(cacheKey)) or {}

	-- 没有初始化
    if not next(map) then
        local x = 0
        local y = 0
        local x_max = 5
        local y_max = 6

        for x=1,x_max do
            for y=1,y_max do
                if not map[x] then
                    map[x] = {}
                end

                table.insert(map[x],{0})
            end
        end

        -- 保存生成地图 标记已生成
        userwarnew.saveMap(bid,map)
        --showTable(map)
    end
    
	return map
end

-- 保存整个地图信息
function userwarnew.saveMap(bid,map)
    local redis = getRedis()
    local cacheKey = mkCacheKey("map",bid)   
    local save = redis:set(cacheKey,json.encode(map))
    if save then
        redis:expire(cacheKey,expireTs)
        return true
    else
        returnError('saveMap')
        return false
    end
end

-- 读取预警信息
function userwarnew.getWarning(bid,round)

    local x,y = userwarnew.getRoundBlast(bid,round)
    return x,y
end


-- 从地块战斗列表移除一个成员
function userwarnew.removeBattleList(bid,lid,round,uid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("battleList",bid,lid,round) 
    redis:hget(cacheKey,uid)
    
    return true
end

-- 亡灵列表
function userwarnew.getzombieList(bid,lid,round)
    local redis = getRedis()
    local cacheKey = mkCacheKey("zombieList",bid,lid,uid)
    local count = json.decode(redis:hlen(cacheKey)) or 0
    local list = json.decode(redis:hgetall(cacheKey)) or {}
    
    return count,list
end

-- 从亡灵列表移除一个成员
function userwarnew.removeZombieList(bid,lid,round,uid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("zombieList",bid,lid,round)
    redis:srem(cacheKey,uid)
    
    return true
end

function userwarnew.getBattleListNum(bid,lid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("battleList",bid)   
    local battlelist = json.decode(redis:hlen(cacheKey)) or {}
    
    return battlelist
end

-- 设置地块上的幸存者数量
function userwarnew.setSurvivalNum(bid,lid,num)
    local redis = getRedis()
    local cacheKey = mkCacheKey("survivalNum",bid,lid)   
    local survival_num = redis:get(cacheKey)
    redis:incrby(cacheKey,num)
    
    return survival_num
end

-- 读取地块上的幸存者数量
function userwarnew.getSurvivalNum(bid,lid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("survivalNum",bid,lid)   
    local survival_num = redis:get(cacheKey)
    
    return survival_num
end

-- 设置地块上的亡灵数量
function userwarnew.setZombieNum(bid,lid,num)
    local redis = getRedis()
    local cacheKey = mkCacheKey("zombieNum",bid,lid)   
    local zombieNum_num = redis:get(cacheKey)
    redis:incrby(cacheKey,num)
    
    return zombieNum_num
end

-- 读取地块上的亡灵信息
function userwarnew.getZombieNum(bid,lid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("zombieNum",bid,lid)   
    local zombie_num = redis:get(cacheKey)
    
    return zombie_num
end

-- 初始化生存者数量
function userwarnew.setAllSurvivalNum(bid,num)
    local num = num or 1
    local redis = getRedis()
    local cacheKey = mkCacheKey("allSurvival",bid)   
    redis:set(cacheKey,num)
    
    return true
end

-- 累加生存者数量
function userwarnew.addAllSurvivalNum(bid,num)
    local num = num or 1
    local redis = getRedis()
    local cacheKey = mkCacheKey("allSurvival",bid)   
    redis:incrby(cacheKey,num)
    
    return true
end

-- 读取所有幸存玩家数量
function userwarnew.getAllSurvivalNum(bid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("allSurvival",bid)   

    local num = tonumber(redis:get(cacheKey))
    
    if not num then

        local db = getDbo()
        
        local row = db:getRow("select count(*) as num from userwar where bid = :bid and status = 0 ",{bid=bid})
        if row then
            num = tonumber(row.num)
            userwarnew.setAllSurvivalNum(bid,num)
        end
    end
    
    if not num or num < 0 then
        num = 0
    end
    
    -- 这里以后不用了，因为玩家死亡后数据不立刻入库所以直接操作缓存数据累加
    --[[
    if not num then
        local db = getDbo()
        local row = db:getRow("select count(*) as num from userwar where bid = :bid and status = 0 ",{bid=bid})
        if row then
            num = row.num 
            redis:set(cacheKey,num)
            
            local ts = getClientTs()
            local st = getWeeTs()
            local diff = 0
            
            if ts - st > 0 then
                diff = math.floor((ts - st)/(60))
            end

            -- 下一个5分钟的时间戳
            local nextExpireAt = st + (60) * (diff + 1) 
            redis:expireat(cacheKey,nextExpireAt)
        end
    end
    ]]

    return num
end

-- 设置一个陷阱
function userwarnew.setTrap(bid,lid,round,uid,name,status)
    local ts = getClientTs()
    local stype = tonumber(status) >=1 and 2 or 1
    local redis = getRedis()
    local cacheKey = mkCacheKey("trap"..stype,bid,lid)   
    local save = redis:hset(cacheKey,round..'-'..uid,json.encode({uid,name}))
    
    return save
end

function userwarnew.delTrap(bid,lid,stype,trapKey)
    local ts = getClientTs()
    local redis = getRedis()
    local cacheKey = mkCacheKey("trap"..stype,bid,lid)
    
    --writeLog('delTrap-st','trapdel')
    if trapKey then
        local save = redis:hdel(cacheKey,trapKey)
        --writeLog('delTrap-et','trapdel')
        return save
    else
        --writeLog('delTrap-error'..(cacheKey or 'cacheKey'),'trapdel')
    end
    --writeLog('delTrap-et','trapdel')
    
    return false
end

-- 读取陷阱详情
function userwarnew.getTrap(bid,lid,stype)
    local redis = getRedis()
    local cacheKey = mkCacheKey("trap"..stype,bid,lid)   
    
    local trap_list = redis:hgetall(cacheKey)

    return trap_list
end

function userwarnew.getTrapNum(bid,lid,stype)
    local redis = getRedis()
    local cacheKey = mkCacheKey("trap"..stype,bid,lid)   
    local trap_num = redis:hlen(cacheKey)
    
    return trap_num
end

-- 根据行列返回地块信息
function userwarnew.getWarningInfo(bid,round,x,y,map)
    local mapData = copyTable(map)
    
    if x and y and x ~= 0 and y ~= 0 then
        -- 取出幸存者数量
        local survival_num = userwarnew.getSurvivalNum(bid,x..'-'..y)
        -- 取出亡灵数量
        local zombie_num = userwarnew.getZombieNum(bid,x..'-'..y)
        -- 取出陷阱数量
        local trap1_num = userwarnew.getTrapNum(bid,x..'-'..y,1) or 0
        local trap2_num = userwarnew.getTrapNum(bid,x..'-'..y,2) or 0
        
        if mapData[y][x] then
            mapData[y][x][2] = survival_num or 0
            mapData[y][x][3] = zombie_num or 0
            mapData[y][x][4] = (trap1_num + trap2_num) or 0
        end
    end
    
    return mapData
end

function userwarnew.getRound(warId)
    local ts = getClientTs()
    local openTs = userwarnew.getWarOpenTs(positionId,warId)
    local round = 0

    if ts > openTs.st then
        round = math.ceil((ts - openTs.st) / (userWarCfg.roundTime+userWarCfg.roundAccountTime))
    end
    
    return round,openTs.st,openTs.et
end

function userwarnew.sync(warId)
    local ts = getClientTs()
    local info = {}

    info.round,info.battlest = userwarnew.getRound(warId)

    -- 计算下一回合的开始时间戳
    -- local diff = 0
    -- if ts - info.battlest > 0 then
        -- diff = math.floor((ts - info.battlest)/(userWarCfg.roundTime or 60))
    -- end

    -- info.nextRoundAt = info.battlest + (userWarCfg.roundTime or 60) * (diff + 1) 
    -- if diff == 0 then
        -- info.nextRoundAt = info.battlest
    -- end

    info.survival = userwarnew.getAllSurvivalNum(warId)

    return info
end

-- 每回合结算阶段首先触发爆炸逻辑，然后计算出下回合要爆炸的地块保存预警信息
function userwarnew.boom(bid,round)
    --writeLog('boom st:'..os.time(),'lua_pross')
    --writeLog('--------------------------------- boom '..round..' start ---------------------------------','userwarbattle')
    -- 检测是否有预警没爆炸的地块，取出炸掉
    local db = getDbo()
    local redis = getRedis()
    local cacheKey = mkCacheKey("warning",bid)
	local map = userwarnew.getMap(bid)
	local map_list = {}
    local warning = {}
    local userwarlogLib = require "lib.userwarlog"

    -- 保存新的预警列表
    --writeLog('map:'..json.encode(map),'userwarbattle')
    --writeLog('new boom warning-st:','userwarbattle')
    warning[1],warning[2] = userwarnew.getRoundBlast(bid,round)
    --writeLog('new boom warning-et:'..json.encode(warning),'userwarbattle')

    if map[warning[2]] and map[warning[2]][warning[1]] and tonumber(map[warning[2]][warning[1]][1]) ~= 2 then
        --writeLog('boom start:'..'x='..warning[1]..',y='..warning[2],'userwarbattle')
        -- 已爆炸地块保存
        map[warning[2]][warning[1]][1] = 2
        userwarnew.saveMap(bid,map)

        local lid = warning[1]..'-'..warning[2]
        local userList = userwarnew.getLandUserList(bid,lid) or {}
        --writeLog('boom land userlist:'..json.encode(userList),'userwarbattle')
        for uid,lastRound in pairs(userList) do
            local cobjs = getCacheObjs(uid,1,'boom')
            local userwarData = cobjs.getModel('userwar')
            if userwarData and tonumber(userwarData.status) < 2 then
                --writeLog('boom land die user-st:'..uid,'userwarbattle')
                userwarData.setDie(round)

                if tonumber(userwarData.status) == 2 then
                    --writeLog('boom land die user-die:'..uid,'userwarbattle')
                    userwarnew.usergameover(bid,uid,round)
                    userwarlogLib:setEvent(uid,bid,8,userwarData.status,2,0,0,1,0,{0},round)
                    userwarnew.setZombieNum(bid,lid,-1)
                else
                    --writeLog('boom land die user-rest:'..uid..','..userwarData.status,'userwarbattle')
                    if tonumber(userwarData.status) == 1 then
                        --writeLog('boom land die user-rest1:'..uid,'userwarbattle')
                        userwarData.round1 = round - 1
                    elseif tonumber(userwarData.status) == 0 then
                        --writeLog('boom land die user-rest2:'..uid,'userwarbattle')
                        userwarData.status = 1
                        userwarData.round1 = round - 1
                        userwarData.energy = userWarCfg.energyMax
                        userwarData.buff = {}

                        userwarData.point1=tonumber(userwarData.point1)+userwarData.round1*userWarCfg.survivalPoint
                        userwarData.point=userwarData.point+userwarData.round1*userWarCfg.survivalPoint
                        userwarData.addpoint(userwarData.round1*userWarCfg.survivalPoint,2,tonumber(userwarData.round1))
                        userwarnew.setSurvivalNum(bid,lid,-1)
                        userwarnew.setZombieNum(bid,lid,1)
                    end
                    
                    userwarData.mapx,userwarData.mapy = userwarnew.getNewPlace(map)
                    local newLid = userwarData.mapx..'-'..userwarData.mapy
                    --writeLog('boom land die user-rest:'..uid..','..newLid,'userwarbattle')
                    userwarnew.delLandUser(bid,lid,uid)
                    userwarnew.setLandUser(bid,newLid,uid,round)
                    
                    userwarData.troops = {}
                    
                    cobjs.save()
                    
                    userwarlogLib:setEvent(uid,bid,8,userwarData.status,2,0,0,1,0,{0},round)
                    userwarnew.sendTheLastOfUsReward(bid,uid,round-1)
                    userwarnew.addAllSurvivalNum(bid,-1)
                end
                --writeLog('boom land die user-et:'..uid,'userwarbattle')
            end
        end
    end

    --writeLog('--------------------------------- boom '..round..' end ---------------------------------','userwarbattle')
    --writeLog('boom et:'..os.time(),'lua_pross')
	return warning
end

function userwarnew.sendTheLastOfUsReward(bid,uid,round)
    --writeLog('sendTheLastOfUsReward-st:'..uid..','..json.encode({bid,uid,round}),'lastreward')
    local lastOfUsRewardConfig = userWarCfg.rankReward or {}

    for i,v in pairs(lastOfUsRewardConfig) do
        if v and type(v) == 'table' then
            local range=v.range
            if range then
                if round >= range[1] and round <= range[2] then
                    --writeLog('have reward:'..uid,'lastreward')
                    local sucess = sendToRewardCenter(uid,'usw',bid,userwarnew.getBattleEndTime(),nil,{r=round},(v.serverReward or {'no reward'}))
                    --writeLog('send fin:'..uid..','..i,'lastreward')
                    break
                end
            end
        end
    end
    
    --writeLog('sendTheLastOfUsReward-et:'..uid,'lastreward')
    return true
end

-- 每回合推送数据
function userwarnew.noSelect(bid,round)
    --writeLog('noselect st:'..os.time(),'lua_pross')
    --writeLog('no select-st:'..bid..','..round,'noselect')
    local db = getDbo()
    local redis = getRedis()
	local map = userwarnew.getMap(bid)

    for y_index,y_info in pairs(map) do
        for x_index,x_info in pairs(y_info) do
            if map[y_index] and map[y_index][x_index] then
                if map[y_index][x_index][1] ~= 2 then
                    local lid = x_index..'-'..y_index
                    --writeLog('no select-land:'..json.encode({bid,lid}),'noselect')
                    local userList = userwarnew.getLandUserList(bid,lid) or {}
                    --writeLog('no select-land userList:'..json.encode(userList),'noselect')
                    for uid,lastRound in pairs(userList) do
                        local lastRound = tonumber(lastRound) or 0
                        if lastRound < round then
                            local cobjs = getCacheObjs(uid,1,'noselect')
                            local userwarData = cobjs.getModel('userwar')
                            --writeLog('no select-user data-st:'..uid..','..lastRound..','..json.encode(userwarData.toArray(true)),'noselect')
                            --writeLog('no select-user status:'..uid..','..userwarData.status,'noselect')
                            
                            if userwarData and tonumber(userwarData.status)<2 and tonumber(userwarData.mapx) == x_index and tonumber(userwarData.mapy) == y_index then
                                local userwarlogLib = require "lib.userwarlog"
                                if tonumber(userwarData.status) == 0 then
                                    local cost = userWarCfg['stay1'].cost.energy or 1
                                    local flag = userwarData.useEnergy(cost)
                                    if flag then -- 行动力足够的情况
                                        local die = userwarnew.checkEnergy(bid,round,uid,userwarData.status,userwarData.energy,userwarData)
                                        --writeLog('no select-user die:'..uid..','..die..','..userwarData.status..','..userwarData.energy,'noselect')

                                        userwarlogLib:setEvent(uid,bid,1,userwarData.status,1,cost,0,1,0,{0,die,userwarData.status},round)
                                        if die == 0 then -- 行动后行动力不足要死
                                            local rtype,stype,params = userwarnew.randEvent(bid,lid,uid,userwarData.status,'noselect',round)
                                            --writeLog('no select-rand result:'..rtype..','..stype..','..json.encode(params),'noselect')
                                            userwarlogLib:setRandEvent(uid,bid,round,rtype,stype,userwarData.status,params)
                                        else
                                            userwarnew.setSurvivalNum(bid,lid,-1)
                                            userwarnew.setZombieNum(bid,lid,1)
                                        end

                                        userwarnew.setLandUser(bid,lid,uid,round)
                                        
                                    elseif userwarData.energy <= 0 then
                                        userwarnew.sendTheLastOfUsReward(bid,uid,round-1)
                                        userwarData.setDie(round)
                                        userwarlogLib:setEvent(uid,bid,1,userwarData.status,1,cost,0,1,0,{0,die,userwarData.status},round)
                                        --userwarnew.checkEnergy(bid,round,uid,userwarData.status,userwarData.energy,userwarData)
                                        userwarnew.setLandUser(bid,lid,uid,round)
                                        userwarnew.setSurvivalNum(bid,lid,-1)
                                        userwarnew.setZombieNum(bid,lid,1)
                                    end
                                    userwarData.setCount(bid,'s')
                                    --writeLog('no select-user data-et:'..uid..','..lastRound..','..json.encode(userwarData.toArray(true)),'noselect')
                                    cobjs.save()
                                elseif tonumber(userwarData.status) == 1 then
                                    --writeLog('no select battle-st:'..uid,'noselect')
                                    local cost = userWarCfg.battle.cost.energy or 1
                                    --writeLog('no select battle-cost:'..uid..','..cost..','..userwarData.energy,'noselect')
                                    local flag = userwarData.useEnergy(cost)
                                    if flag then
                                        --writeLog('no select battle-in-st'..uid,'noselect')
                                        userwarlogLib:setEvent(uid,bid,3,userwarData.status,1,cost,0,1,0,{0,lid,0,userwarData.status},round)
                                        userwarnew.action_readyFight(bid,lid,uid,userwarData.status,round)
                                        userwarnew.setLandUser(bid,lid,uid,round)
                                        userwarData.setCount(bid,'b')
                                        --writeLog('no select battle-in-et'..uid,'noselect')
                                        cobjs.save()
                                    elseif tonumber(userwarData.energy) < cost then
                                        userwarData.useEnergy(userwarData.energy)
                                        userwarData.setCount(bid,'b')
                                        userwarlogLib:setEvent(uid,bid,3,userwarData.status,1,cost,0,1,0,{0,lid,0,userwarData.status},round)
                                        userwarlogLib:setEvent(uid,bid,3,2,2,0,0,3,0,{'',1,0,2},round,nil)
                                        userwarnew.usergameover(bid,uid,round)

                                        userwarnew.setZombieNum(bid,lid,-1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    --writeLog('no select-et:'..bid..','..round,'noselect')
    --writeLog('noselect et:'..os.time(),'lua_pross')
    
	return true
end

-- 每回合推送数据
function userwarnew.push(bid,round,warning)
    --writeLog('push st:'..os.time(),'lua_pross')
    --writeLog('--------------------------------- push '..round..' start ---------------------------------','push')
    --writeLog('push params:'..json.encode({bid,round,warning}),'userwarbattle')
    -- 检测是否有预警没爆炸的地块，取出炸掉
    local db = getDbo()
    local redis = getRedis()
	local map = userwarnew.getMap(bid)
    local syncInfo = userwarnew.sync(bid)
    local logs
    local userwarlogLib = require "lib.userwarlog"
    local allLogs = userwarlogLib:getLog()

    for y_index,y_info in pairs(map) do
        for x_index,x_info in pairs(y_info) do
            if map[y_index] and map[y_index][x_index] then
                local lid = x_index..'-'..y_index
                local userList = userwarnew.getLandUserList(bid,lid) or {}
                --writeLog('push userList:'..x_index..'-'..y_index..','..json.encode(userList),'userwarbattle')
                syncInfo.mapData = userwarnew.getWarningInfo(bid,round,x_index,y_index,map)
                for uid,lastRound in pairs(userList) do
                    local lastRound = tonumber(lastRound) or 0
                    if lastRound <= round then
                        local logs={}
                        local tmpuid=tostring(uid)
                        if type(allLogs) == 'table'  and allLogs[tostring(tmpuid)] then
                            logs=allLogs[tostring(tmpuid)]['content']
                        end

                        local sms = {
                            ret = 0,
                            cmd = "userwar.push",
                            msg='success',
                            data = {map = syncInfo,event=logs},
                            zoneid = getZoneId(),
                            ts = getClientTs(),
                        }
                              
                        --writeLog('push user:'..uid,'userwarbattle')
                        local cobjs = getCacheObjs(uid,1,'push')
                        local userwarData = cobjs.getModel('userwar')
                        if userwarData then
                            --writeLog('push lastRound:'..uid..','..lastRound,'userwarbattle')
                            local over
                            if tonumber(userwarData.status) >= 2 or round>=userWarCfg.roundMax then
                                userwarnew.delLandUser(bid,lid,uid)
                                sms.data.over = {userwarData.status,userwarData.bcount,userwarData.round1,userwarData.round2,userwarData.point,userwarData.point1,userwarData.point2}
                            else
                                --writeLog(json.encode(syncInfo),'userwarbattle')
                                --writeLog(json.encode(userwarData.toArray(true)),'userwarbattle')
                                local tmpuser={
                                    userwarData.energy,
                                    userwarData.status,
                                    userwarData.point1,
                                    userwarData.point2,
                                    userwarData.round1,
                                    userwarData.round2,
                                    userwarData.troops or {},
                                    userwarData.buff,
                                    userwarData.support1,
                                    userwarData.support2,
                                    userwarData.support3,
                                    userwarData.mapx,
                                    userwarData.mapy,
                                }
                                sms.data.userwar = tmpuser
                            end
    
                            sendMsgByUid(uid,json.encode(sms))
                        end
                    end
                end
            end
        end
    end
    
    --writeLog('--------------------------------- push '..round..' end ---------------------------------','push')
    --writeLog('push et:'..os.time(),'lua_pross')
    
	return true
end

function userwarnew.getRandValue(config,action)
    local randSeed = {}
    local probability = {}
    local num = 0
    for name,value in pairs(config) do

        if type(value) == 'table' then

            if value[action] then

                num = value[action]
            elseif value['default'] then

                num = value['default']
            else

                num = 1
            end
            
        elseif type(value) == 'number' then
            num = value
        end
        
        for i=1,num do
            table.insert(probability,name)
        end
    end
    setRandSeed()
    local value = probability[rand(1,(#probability or 0))]
    
    return value
end

-- 添加x因素
function userwarnew.addX(bid,lid,config)
    local randEventCfg = {}
    local x = {}
    x.trap1 = (userwarnew.getTrapNum(bid,lid,1) or 0) * 5 -- 地块上的陷阱数量
    x.trap2 = (userwarnew.getTrapNum(bid,lid,2) or 0) * 5 -- 地块上的陷阱数量

    for eid,evalue in pairs(config) do
        if x[eid] then
            for i,v in pairs(evalue) do
                if not randEventCfg[eid] then
                    randEventCfg[eid] = {}
                end

                if type(v) == 'number' and x[eid] > 0 then
                    randEventCfg[eid][i] = x[eid] + v
                else
                    randEventCfg[eid][i] = 0
                end
            end
        else
            randEventCfg[eid] = evalue
        end
    end

	return randEventCfg
end

-- 随机事件触发
function userwarnew.randEvent(bid,lid,uid,status,action,round)
    local userwarlogLib = require "lib.userwarlog"
    --writeLog('a1','rand')

    local randeventConfig = userwarnew.addX(bid,lid,userWarCfg['randEvent'])
    --writeLog('a2','rand')
    local event = userwarnew.getRandValue(randeventConfig,action)
    --writeLog('a3','rand')
    local flag
    local rtype = 100
    local stype = 1
    local params = {}
    local newData
    
    if event == 'battle' then
        if action ~= 'battle1' and action ~= 'battle2' then
            userwarnew.action_readyFight(bid,lid,uid,status,round)
            local cobjs = getCacheObjs(uid,1,'revent')
            local mUserwar = cobjs.getModel('userwar')
            mUserwar.setCount(bid,'b')
            --userwarlogLib:setEvent(uid,bid,3,mUserwar.status,1,cost,0,1,0,{0,lid,0,mUserwar.status},round)
        end
    elseif event == 'trap1' then
        local trapNum = tonumber(userwarnew.getTrapNum(bid,lid,1)) or 0
        if trapNum > 0 then
            local trapList = userwarnew.getTrap(bid,lid,1)

            for tid,tdata in pairs(trapList) do
                local tinfo = json.decode(tdata) or {}
                local setUid = tonumber(tinfo[1]) or 0
                local setName = tinfo[2] or ''
                --writeLog('st-'..','..uid..','..setUid..','..tdata,'trap1')
                if tonumber(uid) ~= setUid then
                    --writeLog('et-'..','..uid..','..setUid..','..type(uid)..','..type(setUid)..','..tdata,'trap1')
                    local randeventConfig = userWarCfg.trap1
                    local probability = randeventConfig.probability
                    --writeLog('trap1-st','rand')
                    local push = false
                    if action ~= 'noselect' then
                        push = true
                    end
                    local buffName = userwarnew.getRandValue(probability,action)
                    --writeLog('trap1-et','rand')
                    local buffVal = userWarCfg.eventDownBuff.list[buffName].per

                    local cobjs = getCacheObjs(uid,1,'revent')
                    local mUserwar = cobjs.getModel('userwar')
                    mUserwar.addBuff('del',buffName,1,'revent')
                    mUserwar.setCount(bid,'de')
                    --cobjs.save()

                    local tuobjs = getCacheObjs(setUid,1,'revent')
                    local tUserwar = tuobjs.getModel('userwar')
                    userwarlogLib:setRandEvent(setUid,bid,round,4,2,tUserwar.status,{mUserwar.name,lid,buffVal},push)
                    rtype = 10
                    stype = 1
                    params = {lid,setName,buffName,buffVal}
                    --writeLog(json.encode({(bid or 'bid'),(lid or 'lid'),(tid or 'tid')}),'trap1error')
                    userwarnew.delTrap(bid,lid,1,tid)
                    break
                end
            end
        else
            local randeventConfig = userWarCfg.eventDownBuff
            local probability = randeventConfig.probability
            --writeLog('trap1f-st','rand')
            local buffName = userwarnew.getRandValue(probability,action)
            --writeLog('trap1f-et','rand')
            local buffVal = randeventConfig.list[buffName].per
            local cobjs = getCacheObjs(uid,1,'revent')
            local mUserwar = cobjs.getModel('userwar')
            mUserwar.addBuff('del',buffName,1)
            mUserwar.setCount(bid,'de')
            --cobjs.save()
            
            rtype = 11
            stype = 1
            params = {buffName,buffVal,status}
        end
    elseif event == 'trap2' then
        local trapNum = tonumber(userwarnew.getTrapNum(bid,lid,2)) or 0
        if trapNum > 0 then
            local trapList = userwarnew.getTrap(bid,lid,2)
            for tid,tdata in pairs(trapList) do
                local tinfo = json.decode(tdata) 
                local setUid = tonumber(tinfo[1]) or 0
                local setName = tinfo[2] or ''
                --writeLog(uid..','..setUid..','..tdata,'trap2')
                if tonumber(uid) ~= setUid then
                    --writeLog('et-'..','..uid..','..setUid..','..type(uid)..','..type(setUid)..','..tdata,'trap2')
                    local randeventConfig = userWarCfg.trap2
                    local probability = randeventConfig.probability
                    --writeLog('trap2-st','rand')
                    local buffName = userwarnew.getRandValue(probability,action)
                    --writeLog('trap2-et','rand')
                    local buffVal = userWarCfg.eventDownBuff.list[buffName].per
                    local push = false
                    if action ~= 'noselect' then
                        push = true
                    end
                    
                    local cobjs = getCacheObjs(uid,1,'revent')
                    local mUserwar = cobjs.getModel('userwar')
                    local tuobjs = getCacheObjs(setUid,1,'revent')
                    local tUserwar = tuobjs.getModel('userwar')
                    mUserwar.addBuff('del',buffName,1)
                    mUserwar.setCount(bid,'de')
                    userwarlogLib:setRandEvent(setUid,bid,round,6,2,tUserwar.status,{mUserwar.name,lid,buffVal},push)
                    userwarnew.delTrap(bid,lid,2,tid)
                    --cobjs.save()
                    
                    rtype = 10
                    stype = 2
                    params = {lid,setName,buffName,buffVal}
                    
                    --writeLog(json.encode({(bid or 'bid'),(lid or 'lid'),(tid or 'tid')}),'trap2error')
                    break
                end
            end
        else
            local randeventConfig = userWarCfg.eventDownBuff
            local probability = randeventConfig.probability
            --writeLog('trap2f-st','rand')
            local buffName = userwarnew.getRandValue(probability,action)
            --writeLog('trap2f-et','rand')
            local buffVal = randeventConfig.list[buffName].per
            local cobjs = getCacheObjs(uid,1,'revent')
            local mUserwar = cobjs.getModel('userwar')
            mUserwar.addBuff('del',buffName,1)
            mUserwar.setCount(bid,'de')
            --cobjs.save()
            
            rtype = 11
            stype = 1
            params = {buffName,buffVal,status}
        end
    elseif event == 'upBuff' then
        local randeventConfig = userWarCfg.eventUpBuff
        local probability = randeventConfig.probability
        --writeLog('upBuff-st','rand')
        local buffName = userwarnew.getRandValue(probability,action)
        --writeLog('upBuff-et','rand')
        local buffVal = randeventConfig.list[buffName].per
        local cobjs = getCacheObjs(uid,1,'revent')
        local mUserwar = cobjs.getModel('userwar')

        mUserwar.addBuff('add',buffName,1)
        mUserwar.setCount(bid,'up')
        --cobjs.save()
        
        rtype = 12
        stype = 1
        params = {buffName,buffVal,status}
    elseif event == 'downBuff' then
        local randeventConfig = userWarCfg.eventDownBuff
        local probability = randeventConfig.probability
        --writeLog('downBuff-st','rand')
        local buffName = userwarnew.getRandValue(probability,action)
        --writeLog('downBuff-et','rand')
        local buffVal = randeventConfig.list[buffName].per
        local cobjs = getCacheObjs(uid,1,'revent')
        local mUserwar = cobjs.getModel('userwar')
        
        mUserwar.addBuff('del',buffName,1)
        mUserwar.setCount(bid,'de')
        --cobjs.save()
        
        rtype = 11
        stype = 1
        params = {buffName,buffVal,status}
    elseif event == 'reward' and action ~= 'noselect' then -- 默认操作不会给实物奖励
        local config = userWarCfg.eventReward
        --writeLog('reward-st','rand')
        local reward = getRewardByPool(config.pool)
        --writeLog('reward-et','rand')
        rtype = 13
        stype = 1

        takeReward(uid,reward)

        params = {formatReward(reward),status}
    elseif event == 'point' then
        local randPointConfig = userWarCfg.randPoint or {1,1}
        setRandSeed()
        --writeLog('point-st','rand')
        local addPoint = rand(randPointConfig[1],randPointConfig[2])
        --writeLog('point-et','rand')
        local cobjs = getCacheObjs(uid,1,'revent')
        local mUserwar = cobjs.getModel('userwar')
        
        --mUserwar.addpoint(addPoint,4,round)
        mUserwar.addPointDirect(mUserwar.status,addPoint,4,round)
        --cobjs.save()
        rtype = 13
        stype = 1
        params = {point=addPoint,status}
    elseif event == 'energy' then
        local randPointConfig = userWarCfg.randPoint or {1,1}
        setRandSeed()
        --local addPoint = rand(randPointConfig[1],randPointConfig[2])
        local cobjs = getCacheObjs(uid,1,'revent')
        local mUserwar = cobjs.getModel('userwar')
        --mUserwar.addpoint(addPoint,4,round)
        local addEnergy = userWarCfg.eventAddEnergy or 2
        mUserwar.addEnergy(addEnergy)
        --cobjs.save()
        rtype = 13
        stype = 2
        params = {addEnergy,status}
    end
    return rtype,stype,params,newData
end

-- 随机抽卡
function userwarnew.randActionCards(bid,uid,round)
    local redis = getRedis()
    local config = userWarCfg.randAction
    local cardsName = userWarCfg.cardsName
    local cacheKey = mkCacheKey("cards",bid,uid,round)
    local cards = json.decode(redis:get(cacheKey)) or {}
    
    if not cards or not next(cards) then
        for i,v in pairs(config) do
            local count = v.num or 1
            local list = copyTable(v.list)
            for i=1,count do
                local actionKey = userwarnew.getRandValue(list)

                for pindex,pval in pairs(list) do
                    if pindex == actionKey then
                        list[pindex] = nil
                    end
                end
                if cardsName[actionKey] then
                    table.insert(cards,cardsName[actionKey])
                end
            end
        end
        
        redis:set(cacheKey,json.encode(cards))
        redis:expire(cacheKey,60)
        
        regSendMsg(uid,'userwar.actioncards',{bid,round,cards})
    end

	return cards
end

-- 行为 移动
function userwarnew.action_move(bid,uid,round,status,x,y,mx,my)
    -- 地块是否可移动
    local redis = getRedis()
    local map = userwarnew.getMap(bid)
    local curr_x = x
    local curr_y = y
    local curr_id = x..'-'..y
    local new_id = mx..'-'..my
    local flag = false

    -- 当前坐标是否合法 目标坐标是否合法 自己坐标是否等于当前坐标
    if map[y] and map[y][x] and map[my] and map[my][mx] and y == curr_y and x == curr_x then
        local pass1 = false
        if map[y][x-1] and x-1 == mx then -- left
            pass1 = true
        elseif map[y][x+1] and x+1 == mx then -- right
            pass1 = true
        elseif x == mx then
            pass1 = true
        end
        
        local pass2 = false
        if map[y-1] and map[y-1][x] and y-1 == my then -- up
            pass2 = true
        elseif map[y+1] and map[y+1][x] and y+1 == my then -- bottom
            pass2 = true
        elseif y == my then
            pass2 = true
        end
        
        if pass1 and pass2 and tonumber(map[my][mx][1]) ~= 2 then
            flag = true
        end

    end

    if flag then
        -- 设置新坐标并保存数据
        userwarnew.setLandUser(bid,new_id,uid,round-1)
        userwarnew.delLandUser(bid,curr_id,uid)

        local sType = status == 0 and 'survivalNum' or 'zombieNum'
        local old_key = mkCacheKey(sType,bid,curr_id)
        local new_key = mkCacheKey(sType,bid,new_id)

        redis:incrby(old_key,-1)
        local old_num = tonumber(redis:get(old_key)) or 0
        if old_num < 0 then
            redis:incrby(old_key,1)
        end
        redis:expire(old_key,expireTs)
        
        redis:incrby(new_key,1)
        redis:expire(new_key,expireTs)
    end
    
    return flag
end

-- 行为 休整停留 增加体力
function userwarnew.action_stay()
    -- 只触发一次随机事件，体力增加放在api接口中
    return true
end

-- 行为 探索 action 奖池 1普通 2高级
function userwarnew.action_discovery(action)
    local config =userWarCfg['discovery'..(action or 1)]
    local probability = config.probability or 0
    
    setRandSeed()
    local randnum = rand(1,100)
    local reward = false

    
    if randnum <= probability  then
        local pointProb = config.pointProb or 0
        local jfrandnum = rand(1,100)

        if jfrandnum <= pointProb then
            reward = 'point'
        else
            reward = getRewardByPool(config.pool)
        end
    end
    
    return reward
end

-- 行为 准备战斗 加入战斗列表中
function userwarnew.action_readyFight(bid,lid,uid,status,round)

    --writeLog('readyFigh:st'..uid..','..json.encode({bid,lid,uid,status,round}),'readyFigh')
    local subKey = tonumber(status) == 0 and 'battleList' or 'zombieList'

    --writeLog('readyFigh:subKey'..uid..','..subKey,'readyFigh')
    local cacheKey = mkCacheKey(subKey,bid,lid,round)
    --writeLog('readyFigh:cachekey'..uid..','..cacheKey,'readyFigh')
    local redis = getRedis()
    
    redis:hset(cacheKey,uid,1)
    redis:expire(cacheKey,expireTs)
    
    return true
end

function userwarnew.action_hide(bid,lid,uid,round)
    local redis = getRedis()
    local cacheKey1 = mkCacheKey('battleList',bid,lid,round)
    local cacheKey2 = mkCacheKey('zombieList',bid,lid,round)
    redis:hdel(cacheKey1,uid)
    redis:hdel(cacheKey2,uid)
    
    return true
end

-- 插入战斗列表
function userwarnew.getbattlelist(bid,lid,round)
    local redis = getRedis()
    local tmpzomkey= mkCacheKey("zombieList",bid,lid,round)
    local tmpuserkey= mkCacheKey('battleList',bid,lid,round)
    local redis = getRedis()
    local zoom=redis:hkeys(tmpzomkey)
    local users=redis:hkeys(tmpuserkey)
    if users==nil then users={} end
    if zoom==nil then  zoom={} end
    local maxcount=0
    if #zoom>#users then
        maxcount=#zoom
    else
        maxcount=#users    
    end
    --writeLog('api_userwar_battle'..round..lid..'zoom*****'..json.encode(zoom),'userwarbattlelist')
    --writeLog('api_userwar_battle'..round..lid..'user*****'..json.encode(users),'userwarbattlelist')
    local list={}
    if maxcount>0 then
        for i=1,maxcount do
            if zoom[i] then
                table.insert(list,tonumber(zoom[i]))
            end
            if users[i] then
                table.insert(list,tonumber(users[i]))
            end
        end
        --redis:del(tmpzomkey)
        --redis:del(tmpuserkey)
        return list
    end
    return {}
end

function userwarnew.setStatus()
    
end

-- 行为 陷阱 污染
function userwarnew.action_setTrap(bid,lid,round,uid,name,status)
    userwarnew.setTrap(bid,lid,round,uid,name,status)
    return true
end

-- 行为 污染
function userwarnew.action_randKill(bid,lid)
    return true
end

-- 战斗 placeBattle
function userwarnew.battlePlayer(attackerBinfo,defenderBinfo,attTroops,defenderTroops,delbuff,auserbuff,duserbuff,alevel,dlevel,aname,dname,zstatus)
    local fleetInfo1 = copyTab(attackerBinfo)
    local fleetInfo2 = copyTab(defenderBinfo)
    local delhp=nil 
    local attbuff=nil
    if type(delbuff)=='table' then
       delhp=delbuff.delhp
       attbuff=delbuff.addbuff
    end
    local initattseq = 1 -- 先手值相同， 防守方先出手
    if tonumber(zstatus) == 1 then
        initattseq = 10 -- 亡者 一定是攻击方,并且先出手
    end

    local aFleetInfo = formatTroops(fleetInfo1[1],fleetInfo1[2][1],attTroops,attbuff,auserbuff)
    local defFleetInfo = formatTroops(fleetInfo2[1],fleetInfo2[2][1],defenderTroops,nil,duserbuff)

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"
    
    
    local report, aInvalidFleet, dInvalidFleet, attSeq, setPoint = {}
    report.d, report.w, aInvalidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,defFleetInfo, initattseq,nil,{delhp=delhp,maxbattleround=userWarCfg.maxbattleround})
    -- writeLog({zstatus=zstatus, aname=aname, dname=dname, initattseq=initattseq, attSeq=attSeq,} , 'userwar')
    local aAliveTroops = getTroopsByInitTroopsInfo(aInvalidFleet)
    local dAliveTroops = getTroopsByInitTroopsInfo(dInvalidFleet)

    local aDieTroops = getDieTroopsByInavlidFleet(aTroops,aAliveTroops)
    local dDieTroops = getDieTroopsByInavlidFleet(dTroops,dAliveTroops)

    report.t = {dTroops,aTroops}
    report.h = {{},{}}

    if attSeq == 1 then
        report.p = {{dname,dlevel,1,seqPoint[2]},{aname,alevel,0,seqPoint[1]}}            
    else
        report.p = {{dname,dlevel,0,seqPoint[2]},{aname,alevel,1,seqPoint[1]}}
    end

    if fleetInfo1[3] and fleetInfo1[3][1] then
        report.h[2] = fleetInfo1[3][1]
    end

    if fleetInfo2[3] and fleetInfo2[3][1] then
        report.h[1] = fleetInfo2[3][1]
    end

    report.se={0, 0}
    if fleetInfo1[4] then
        report.se[2] = fleetInfo1[4]
    end    
    if fleetInfo2[4] then
        report.se[1] = fleetInfo2[4]
    end

    return report, aAliveTroops, dAliveTroops, attSeq, setPoint,aDieTroops,dDieTroops
end

-- 生成爆炸格子顺序
function userwarnew.blast(bid)
    local redis = getRedis()
    local cacheKey = mkCacheKey("blast",bid) 
    local blast=json.decode(redis:get(cacheKey))
    if type(blast)=='table' and next(blast) then
        return blast
    end
    local blast=userwarnew.getblast(blast)
    redis:set(cacheKey,json.encode(blast))
    redis:expire(cacheKey,expireTs)

    return blast

end

-- 生成爆炸格子顺序
function userwarnew.getblast(blast)

    if type(blast)~="table" then  blast={} end
    setRandSeed()
    local x=6
    local y=5
    if xz==nil then
        xz=rand(1,x)
    end
    if yz==nil then
        yz=rand(1,y)
    end
    local allblast={}
    for j=1,y do
        for i=1,x do
            local point=j*10+i
            table.insert(allblast,point)
        end
    end
    if #blast>=userWarCfg.blastcount then

        return blast
    end    
    local once=yz*10+xz
    table.insert(blast,once)
    local list=userwarnew.getrandblast(blast,allblast,x)
    return list
end
-- 生成爆炸格子顺序
function userwarnew.getrandblast(blast,allblast,x)
    local tmpblast={}
    for k,v in pairs(blast) do
        for ak,av in pairs(allblast) do
            if v==av then
                table.remove(allblast,ak)
            end
        end
        local tmp={v+1,v-1,v-10,v+10}
        for tk,tv in pairs (tmp) do
            if tv>=11 and tv%10 <=x then
                table.insert(tmpblast,tv)
            end
        end
    end

    for i=1,#tmpblast do
        local tmpflag=true
        for k,v in pairs(tmpblast) do
            local flag=table.contains(allblast,v)
            if not flag then
                tmpflag=false
                table.remove(tmpblast,k)
                break
            end
        end
        if tmpflag==true then
            break
        end
    end

   
    setRandSeed()
    local index=rand(1,#tmpblast)
    local newblast=tmpblast[index]
    table.insert(blast,newblast)
    if #blast>=userWarCfg.blastcount then
        local tmp={}
        for  i=#blast,1,-1 do
            table.insert(tmp,blast[i])
        end
        return tmp
    else
        return userwarnew.getrandblast(blast,allblast,x)
    end  
   
end


-- 获取本轮是否爆炸
-- bid    战斗id
-- round  轮数
function userwarnew.getRoundBlast(bid,round)
    local status=userWarCfg.blast[tonumber(round)] or 0
    if status==0 then
        return false
    end

    local list=userwarnew.blast(bid)
    if list[status] then
        return list[status]%10,math.floor(list[status]/10)
    end
    return  false
end
--[[
    设置用户的数据到缓存
    用户是唯一的,无需按组区分,取用户缓存数据时也不要按组取
]]
function userwarnew.setUserDataToCache(bid,data)
    local redis = getRedis()
    local memKey = mkCacheKey("hashBidMember",bid)
    local uidKey = mkKey(data.uid)
    redis:hset(memKey,uidKey,json.encode(data))
    redis:expire(memKey,expireTs)
end
function userwarnew.delUserDataFromCache(bid,uid)
    local redis = getRedis()
    local memKey = mkCacheKey("hashBidMember",bid)
    local uidKey = mkKey(uid)
    --writeLog('delUserData-st','userdatadel')
    redis:hdel(memKey,uidKey)
    --writeLog('delUserData-st','userdatadel')
end



-- 从数据库获取单个用户的数据
local function getUserDataFromDb(bid,uid)
    local db = getDbo()
    return db:getRow("select * from userwar where bid=:bid and uid=:uid ",{bid=bid,uid=uid})
end
--[[
    获取参战玩家的数据
    如果是NPC直接返回npc的标准数据
    先取缓存,缓存没有读数据库后添加到缓存
]]
function userwarnew.getUserData(bid,uid)
    local cobjs = getCacheObjs(uid,1)
    local mUserwar = cobjs.getModel('userwar','getUserData')
    
    return mUserwar
    --[[
    local uidKey = mkKey(uid)
    local redis = getRedis()

    local memKey = mkCacheKey("hashBidMember",bid)
    local data = redis:hget(memKey,uidKey)
    if type(data) == 'string' then
        data = json.decode(data)
    end

    local setCache = false
    if not data or not data.binfo then
        data = getUserDataFromDb(bid,uid)
        setCache = true
    end

    if type(data) == 'table' and data.binfo then
        data.pointlog=nil
        if type(data.binfo) ~= 'table' then
            data.binfo = json.decode(data.binfo)
        end
        if type(data.info) ~= 'table' then
            data.info = json.decode(data.info)
        end
        if type(data.buff) ~= 'table' then
            data.buff = json.decode(data.buff)
        end
        if type(data.addpoint) ~= 'table' then
            data.addpoint = json.decode(data.addpoint)
        end
        if setCache then
            userwarnew.setUserDataToCache(bid,data)
        end

        usersData[uidKey] = data
    end
    return data
    ]]
end


-- 如果game over 就把这些人的数据结算
function userwarnew.gameover(bid)
    local db = getDbo()
    local result= db:getAllRows("select uid from userwar where bid=:bid and binfo<>'{}' and status<>2 ",{bid=bid})
    local cmd="userwar.gameover"
    local ackey="userwar.rank"..bid.."status"..0
    local ackey1="userwar.rank"..bid.."status"..1
    --writeLog('gameover start uids'..json.encode(result),'userwarOver')
    if result then
        --writeLog('gameover start uids1'..json.encode(result),'userwarOver')
        for k,v in pairs (result) do
            local uid=tonumber(v.uid)
            local cobjs = getCacheObjs(uid,1,'gameover')
            local mUserwar = cobjs.getModel('userwar')

            if tonumber(mUserwar.round1)==0 and tonumber(mUserwar.status)==0 then
                mUserwar.round1=userWarCfg.roundMax
                local point=tonumber(mUserwar.round1)*userWarCfg.survivalPoint
                mUserwar.point1=tonumber(mUserwar.point1)+point
                mUserwar.point=mUserwar.point+point
                mUserwar.addpoint(point,2,tonumber(mUserwar.round1))
            end
            mUserwar.round2=userWarCfg.roundMax-tonumber(mUserwar.round1)
            mUserwar.binfo={}
            local data = {status=mUserwar.status,count=mUserwar.bcount,round1=mUserwar.round1,round2=mUserwar.round2,point=mUserwar.point,point1=mUserwar.point1,point2=mUserwar.point2}
            if mUserwar.status == 0 then
                userwarnew.sendTheLastOfUsReward(bid,uid,userWarCfg.roundMax)
            end
            if cobjs.save(true)  then 
                --writeLog('end  battle uid  die '..'---uid='..uid,'userwarbattlelist')
                --[[if tonumber(mUserwar.round1)>0 then
                    setFuncRanking(uid,tonumber(mUserwar.point1),tonumber(mUserwar.round1),ackey,100)
                end
                if tonumber(mUserwar.point2)>0 then
                    setFuncRanking(uid,tonumber(mUserwar.point2),0,ackey1,100)
                end]]

                --[[
                --regSendMsg(uid,cmd,data)
                local sms = {
                    ret = 0,
                    cmd = cmd,
                    msg='success',
                    data = data,
                    zoneid = getZoneId(),
                    ts = getClientTs(),
                }
                --print(json.encode(sms))
                sendMsgByUid(uid,json.encode(sms))
                ]]
            end
        end
    end
end

-- 如果game over 就把这个人的数据结算
function userwarnew.usergameover(bid,uid,round)
    local cmd="userwar.gameover"
    local uid=tonumber(uid)
    local cobjs = getCacheObjs(uid,1,'usergameover')
    local cUserwar = cobjs.getModel('userwar')

    if not next(cUserwar.binfo) or type(cUserwar.binfo)~='table' then
        return false
    end
    cUserwar.binfo={}
    cUserwar.round2=round-cUserwar.round1
    cUserwar.status=2
    if cobjs.save(true) then
        --writeLog('uid  die '..round..'---uid='..uid,'userwarbattlelist')
        --[[if tonumber(mUserwar.round1)>0 then
            local ackey="userwar.rank"..bid.."status"..0
            setFuncRanking(uid,tonumber(mUserwar.point1),tonumber(mUserwar.round1),ackey,100)
        end
        if tonumber(mUserwar.point2)>0 then
            local ackey="userwar.rank"..bid.."status"..1
            setFuncRanking(uid,tonumber(mUserwar.point2),0,ackey,100)
        end]]
        
        --[[

        local sms = {
            ret = 0,
            cmd = cmd,
            msg='success',
            data = data,
            zoneid = getZoneId(),
            ts = getClientTs(),
        }
        --print(json.encode(sms))
        sendMsgByUid(uid,json.encode(sms))
        ]]
    end
end

-- 取战斗结束时间
function userwarnew.getBattleEndTime()
    local roundMax = userWarCfg.roundMax or 1
    local startHour = (userWarCfg.startWarTime[1] or 0) * 3600
    local startMin = (userWarCfg.startWarTime[2] or 0) * 60
    local startTime = getWeeTs(getClientTs()) + (startHour + startMin) -- 战斗开始时间
    local roundTime = userWarCfg.roundTime or 0 -- 每回合操作时长
    local roundAccountTime = userWarCfg.roundAccountTime or 0 -- 每回合结算时长
    local endTime = startTime + (roundMax * (roundTime + roundAccountTime))
    
    return endTime
end
                    
-- 更新数据到临时缓存
function userwarnew.upUserCache(bid,uid,params)
    local flag = false
    local userWarData
    --writeLog('upUserCache-st'..uid..','..json.encode({bid,uid,params}),'upUserCache')
    if type(params) == 'table' then
        userWarData = userwarnew.getUserData(bid,uid) or {}
        if userWarData then
            for i,v in pairs(params) do
                userWarData[i] = v
            end        
            --writeLog('upUserCache-save'..uid..','..json.encode(userWarData.toArray(true)),'upUserCache')
            userwarnew.setUserDataToCache(bid,userWarData)
        end
        flag = true
    end
    --writeLog('upUserCache-return'..uid..','..json.encode(userWarData.toArray(true)),'upUserCache')
    return flag,userWarData
end

function userwarnew.getNewPlace(map)
    --local map = userwarnew.getMap()
    local map_list = {}
    
    -- 统计爆炸后剩余的地块
	for y_index,y_value in pairs(map) do
		for x_index,x_value in pairs(y_value) do
			if tonumber(x_value[1]) == 0 then
				table.insert(map_list,{x_index,y_index})
			end
		end
	end

	local total = #map_list or 0
	setRandSeed()
	local index = rand(1,total)
    local x = map_list[index][1] or 0
    local y = map_list[index][2] or 0
    
    return x,y
end

function userwarnew.checkEnergy(bid,round,uid,status,energy,mUserwar)
    local flag = 0
    if status >= 1 and tonumber(energy) <= 0 then
        local uid=tonumber(uid)

        mUserwar.setDie(round)
        userwarnew.usergameover(bid,uid,round)
        flag = 1
    elseif tonumber(energy) <= 0 then
        local uid=tonumber(uid)

        mUserwar.setDie(round)
        userwarnew.sendTheLastOfUsReward(bid,uid,round-1)
        userwarnew.addAllSurvivalNum(bid,-1)
        flag = 1
    end
    
    return flag
end

function userwarnew.ifOver(response,mUserwar)
    response.ret = 0
    response.msg = 'over'
    response.data.over = {status=mUserwar.status,count=mUserwar.bcount,round1=mUserwar.round1,round2=mUserwar.round2,point=mUserwar.point,point1=mUserwar.point1,point2=mUserwar.point2}
    return response
end

function userwarnew.ifCanOper(bid,lid,round,uid)
    local flag = false

    -- if 1==1 then
        -- return true
    -- end
    if round > userWarCfg.roundMax then
        --writeLog('maxerr'..(userWarCfg.roundMax or 'userWarCfg.roundMax')..','..(round or 'round'),'ifcanoper')
        return flag
    else
        local oper = userwarnew.getLandUser(bid,lid,uid) or 0
    
        if tonumber(oper) >= tonumber(round) then
            --writeLog('rerr'..(oper or 'oper')..','..(round or 'round'),'ifcanoper')
            flag = false
        else
            flag = true
        end
    end

    return flag
end

function userwarnew.ifBoom(bid,lid,round)
    local flag = false
    local x,y = userwarnew.getRoundBlast(bid,round)
    if x and y then
        local boomLid = x..'-'..y
        
        if lid == boomLid then
            flag = true
        end
    end
    
    return flag
end

function userwarnew.setApplyNum(bid,num)
    local num = num or 1
    local redis = getRedis()
    local cacheKey = mkCacheKey('apply',bid)
    redis:incrby(cacheKey,num)
end

function userwarnew.getApplyNum(bid)
    local redis = getRedis()
    local cacheKey = mkCacheKey('apply',bid)
    local num = tonumber(redis:get(cacheKey)) or 0
    
    return num
end




return userwarnew