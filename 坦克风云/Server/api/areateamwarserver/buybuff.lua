--[[
    跨服区域战，购买buff：
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
function api_areateamwarserver_buybuff(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            areaWarserver = {},
        },
    }

    -- buff [b1,b2,b3,b4,b5]
    local buff = request.params.buff
    local uid = request.uid
    local zid = getZoneId()
    local bid = request.params.bid
    local aid = request.params.aid
    local group = request.params.group

    if bid == nil or aid == nil or uid == nil or buff == nil or group == nil then
        response.ret = -102
        return response
    end

    local weets = getWeeTs()

    local mAreaWar = require "model.areawarserver"
    mAreaWar.construct(group,bid)

    -- 游戏结束,结束标识返给前端
    local overFlag = mAreaWar.getOverBattleFlag(bid)
    if overFlag then 
        response.data.areaWarserver.over = {
                winner=overFlag,
                battlePointInfo=mAreaWar.getWarPointInfo(bid),
            }
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local userinfo = mAreaWar.getUserData(bid,uid,aid,zid)
    if not userinfo then
        response.ret = -23201
        return response
    end

    local serverWarTeamCfg = getConfig('serverWarLocalCfg')
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
    
    if mAreaWar.updateUserBattleData(userinfo) then
        writeLog('uid='..uid..'--buy buff--'..gemCost,'gemsareacross'..zid)
        response.data.areaWarserver.userinfo = mAreaWar.formatUserDataForClient(userinfo)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end