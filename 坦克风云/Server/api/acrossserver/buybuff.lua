--[[
    军团跨服战，购买buff：
        b1  冶炼专家 战斗强度（最多10级） 每级提升单位的攻击/血量/防护/击破，每项5%。
        b2  指挥专家  战斗天运（最多10级） 每级提升单位的命中/闪避/暴击/装甲，每项5%。
        b3  统计专家  荣誉加成（最多5级）  战斗中产生的贡献增加10%。
        b4  行军专家  行军速度（最多5级）  每级提升行军速度3%
    
    检测：
        用户是否参加了当前的跨服战
        用户购买的BUFF是否达到了最高等级
        用户的金币是否足够

    用户旧数据处理：
        购买的BUFF时间如果不在今天，将所有的buff数据清空

    消息推送：TODO
]]
function api_acrossserver_buybuff(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            acrossserver = {},
        },
    }

    -- buff [b1,b2,b3,b4,b5]
    local buff = request.params.buff
    local uid = tonumber(request.uid)
    local zid = request.zoneid
    local bid = request.params.bid
    local aid = request.params.aid
    local round = request.params.round

    if bid == nil or aid == nil or uid == nil or buff == nil then
        response.ret = -102
        return response
    end

    local weets = getWeeTs()

    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()
    across:setRedis(bid)

    -- 如果游戏结束，将结束标识返给前端
    if across:getAllianceEndBattleFlag(bid,group) then        
        response.data.acrossserver.over =across:getOverData(bid,group,zid,aid,uid,round)
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local userinfo = across:getUserData(bid,zid,aid,uid)

    -- 本赛区未匹配到你所在的军团信息
    if not userinfo then
        response.ret = -21100
        return response
    end
    
    -- 如果上次购买时间不在今日，直接清空所有历史buff
    if (tonumber(userinfo.buff_at) or 0) < weets then
        userinfo.b1 = 0
        userinfo.b2 = 0
        userinfo.b3 = 0
        userinfo.b4 = 0
    end

    local serverWarTeamCfg = getConfig('serverWarTeamCfg')
    local gemCost =  serverWarTeamCfg.buffSkill[buff].cost

    -- 参数无效
    if not gemCost or gemCost < 1 or not userinfo[buff] then
        response.ret = -102
        return response
    end

    -- buff等级达到最高
    local upLevel = (tonumber(userinfo[buff]) or 0) + 1
    if upLevel > serverWarTeamCfg.buffSkill[buff].maxLv then
        response.ret = -4007
        return response
    end

    -- 金币验证
    if tonumber(userinfo.gems) < gemCost then
        response.ret = -109
        return response
    end

    -- 获取当前提升等级的成功率
    local success = serverWarTeamCfg.buffSkill[buff].probability[upLevel]
    if not success then
        response.ret = -102
        return response
    end

    setRandSeed()
    local randnum = rand(1,100)
    if randnum <= success then
        userinfo[buff] = upLevel
    end

    userinfo.gems = userinfo.gems - gemCost
    userinfo.buff_at = weets

    -- 29 军团战购买buff
    -- regActionLogs(uid,1,{action=29,item=buff,value=gemCost,params={old=upLevel-1,new=mUserAllianceWar[buff]}})

    if across:updateUserBattleData(userinfo) then
        writeLog('uid='..uid..'--buy buff--'..gemCost,'gemsacross'..zid)
        response.data.acrossserver.userinfo = userinfo
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end