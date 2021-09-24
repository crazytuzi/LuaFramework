--[[
    军团战，购买buff

    b3 采集专家，会加速采集速度
    1秒时占领此据点，5秒时升为1级，10秒时升为2级此种情况下，要保证积分算的准确
    如果购买buff时结算一次，只能保证积分累加正确，结算战报时无法获得准备数据
    因此需要记下buff的购买/升级时间，结算积分时再按准确值计算
]]
function api_alliancewar_buybuff(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 军团战功能关闭
    if moduleIsEnabled('alliancewar') == 0 then
        response.ret = -4012
        return response
    end

    -- buff [b1,b2,b3,b4] 冶炼专家,指挥专家,采集专家,统计专家
    local buff = request.params.buff
    local uid = tonumber(request.uid)

    if uid == nil or buff == nil then
        response.ret = -102
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","useralliancewar"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUserAllianceWar = uobjs.getModel('useralliancewar')

    local allianceWarCfg = getConfig('allianceWarCfg')
    local gemCost =  allianceWarCfg.buffSkill[buff].cost

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
