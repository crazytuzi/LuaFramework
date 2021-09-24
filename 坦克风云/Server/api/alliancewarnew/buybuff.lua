--[[
    军团战，购买buff

    b3 采集专家，会加速采集速度
    1秒时占领此据点，5秒时升为1级，10秒时升为2级此种情况下，要保证积分算的准确
    如果购买buff时结算一次，只能保证积分累加正确，结算战报时无法获得准备数据
    因此需要记下buff的购买/升级时间，结算积分时再按准确值计算
]]
function api_alliancewarnew_buybuff(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewarnew') == 0 then
        response.ret = -4012
        return response
    end

    -- buff [b1,b2,b3,b4] 冶炼专家,指挥专家,采集专家,统计专家
    local buff = request.params.buff
    local uid = tonumber(request.uid)
    local positionId = tonumber(request.params.positionId)
    if uid == nil or buff == nil or positionId==nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserAllianceWar = uobjs.getModel('useralliancewar')

    local allianceWarCfg = getConfig('allianceWar2Cfg')
    local gemCost =  allianceWarCfg.buffSkill[buff].cost
    local mAllianceWar = require "model.alliancewarnew"

    -- 已结束
    local tmpWarId = mAllianceWar.getWarId(positionId)
    if mAllianceWar.getOverBattleFlag(tmpWarId) then
        response.ret = 0
        response.msg = 'Success'
        response.data.alliancewar = {isover=1}
        return response
    end

    local ts = getClientTs()
    local date  = getWeeTs()
    local ents = allianceWarCfg.signUpTime.finish[1]*3600+allianceWarCfg.signUpTime.finish[2]*60
    if ts <= date+ents  then
        response.ret = -8250
        return response
    end
    local aid=mUserinfo.alliance
    local execRet, code = M_alliance.getapply{uid=uid,aid=aid,date=date,endts=date+ents}
    if not execRet then
        response.ret = code
        return response
    end
    if  execRet.data.targetState==nil or  tonumber(execRet.data.targetState)==0 then
        response.ret = -8251
        return response
    end
    local areaid=tonumber(execRet.data.info.areaid)
    local warId =execRet.data.info.warid
    if tostring(mUserAllianceWar.bid)~=tostring(warId) then
        mUserAllianceWar.reset()
        mUserAllianceWar.bid=warId
    end
    -- 参数无效
    if not gemCost or gemCost < 1 or not mUserAllianceWar[buff] then
        response.ret = -102
        return response
    end

    -- 未加入军团
    if mUserinfo.alliance <= 0 then
        response.ret = -8012
        return response
    end

    -- buff等级达到最高
    local upLevel = (mUserAllianceWar[buff] or 0) + 1
    if upLevel > allianceWarCfg.buffSkill[buff].maxLv then
        response.ret = -4007
        return response
    end

    -- 金币不够
    if not mUserinfo.useGem(gemCost) then
        response.ret = -109 
        return response
    end

    local success = allianceWarCfg.buffSkill[buff].probability[upLevel]
    if not success then
        response.ret = -102
        return response
    end

    setRandSeed()
    local randnum = rand(1,100)
    if randnum <= success then
        mUserAllianceWar.upgradeBuff(buff,upLevel)
    end

    mUserAllianceWar.setTask({t7=1})

    -- 29 军团战购买buff
    regActionLogs(uid,1,{action=29,item=buff,value=gemCost,params={old=upLevel-1,new=mUserAllianceWar[buff]}})

    processEventsBeforeSave()

    if uobjs.save() then
        processEventsAfterSave()
        response.data.useralliancewar = mUserAllianceWar.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end

    return response
end
