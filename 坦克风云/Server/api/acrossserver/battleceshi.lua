--[[
    跨服军团战，战斗    

    以bid为单元，每5秒执行一次
        战场分为4组，分别在每天的4个时间段开始执行        
        获取所有参战成员的信息，对应到地图上的每个据点上
        按据点扫描战斗事件，执行战斗
    
    状态说明：
        1是胜利
        2是淘汰

    战斗前检测：
        战斗是否结束，
            a、比分达到上限
            b、有一方轮空，直接胜利，这种情况需要直接验证数据库的数据检测是否真的轮空，防止缓存数据不准
        时间验证，按组获取正确的开战时间，验证是否到开战时间

    结算的情况：
        a、有任意一方轮空
        b、有一方的地图积分达到结算上限
        c、有一方的主基地耐久被打掉
        d、结算战斗的时间到了
        
    注意用户的buff,对战斗的影响
    revive字段表示用户复活的时间

]]
function api_acrossserver_battleceshi(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        err = {},
        afterErr = {},
        over={},
        kill = {},
    }
    
    local ts = getClientTs()
    local params = {
        s = 1,
        t = ts,
        win = 18,
        winzid = 997,
        id1 = 18,
        id2 = 5,
        n2 = 'asssoo',
        n1 = 'kfqyz99702',
        fc1 = 0,
        fc2 = 0,
        z1 = 998,
        z2 = 997,
    }
    local acrossserver = require "model.acrossserver"
    local across = acrossserver.new()

    local memberList = across:getAllianceMemberList('b12561',997,12)
print('memberList')
ptb:p(memberList)

require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    
    local ret = skyladderserver.getAllianceMemberList(2,2,997,12) or {}
    print('ret')
    ptb:p(ret)
    --[[
    require "model.skyladderserver"
    local skyladderserver = model_skyladderserver()
    local base = skyladderserver.getStatus()
    if base and type(base) == 'table' and base.status and tonumber(base.status) == 1 then
        skyladderserver.saveBattleData(base.cubid,'alliance',2,6,params)
        
        local memberList = across:getAllianceMemberList('b12261',params.win,params.winzid)
print('memberList')
ptb:p(memberList)
        if memberList then
            local uidList = {}
            local cfg = getConfig("skyladderCfg")
            local addScore = cfg.allianceToPersonPoint or 0
            for i,v in pairs(memberList) do
                local params = {
                    s = 1, -- 类型1 类型2
                    t = ts, --时间戳
                    id1 = v.uid, -- 自己id
                    n1 = v.nickname, -- 自己名字
                    z1 = v.zid, -- 自己区id
                    pic1 = v.pic, -- 自己pic
                }
                table.insert(uidList,{id=v.uid,n=v.nickname,z=v.zid,p=v.pic})
                skyladderserver.saveRankData(base.cubid,'person',2,v.zid,v.uid,v.nickname,addScore,v.fc,v.pic,params)
            end
            
            skyladderserver.setAllianceMemberList(base.cubid,params.win,uidList)
        end
    end
    ]]
    response.ret = 0
    response.msg = 'Success'
    return response
end
