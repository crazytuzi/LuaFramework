-- 跨服军团战提取金币
function api_across_takegems(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local zid = request.zoneid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","dailytask"})
    local mUserinfo = uobjs.getModel('userinfo')


    require "model.amatches"
    local mMatches = model_amatches()
    if mUserinfo.usegems <=0 then
        response.ret=-102
        return response
    end
    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()
    local sevCfg=getConfig("serverWarTeamCfg")
    if next(amMatchinfo) then
        local ts = getClientTs()
        local weets      = getWeeTs()
        local info =json.decode(amMatchinfo.info)
        local start =tonumber(amMatchinfo.st)
        start=start+(sevCfg.preparetime+sevCfg.signuptime)*24*3600
        --报名结束时间
        local endts =start+sevCfg.applyedtime[1]*3600+sevCfg.applyedtime[2]*60
        

        if ts> endts then
            local info,myround,cross=mMatches.getMatchInfo(zid,mUserinfo.alliance,0)
            if myround>0  then
                local endts =weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60+sevCfg.warTime
                local stts = weets+sevCfg.startBattleTs[myround][1]*3600+sevCfg.startBattleTs[myround][2]*60-sevCfg.setTroopsLimit
                if ts < endts  and  ts>stts   then
                    response.ret =-21017
                    return response
                end

            end

        end
    end
    local ouserdata=mMatches.getaMatchUserInfo(mUserinfo.bid,zid,uid,0)
    if type(ouserdata)=='table' and ouserdata.data.userinfo then
        local gems=tonumber(ouserdata.data.userinfo.gems)
        if mUserinfo.usegems>gems  and ouserdata.data.userinfo.gems~=nil then
            -- 日常任务
            local mDailyTask = uobjs.getModel('dailytask')
            mDailyTask.changeTaskNum(7)

            -- 活动
            activity_setopt(uid,'wheelFortune',{value=mUserinfo.usegems-gems},true)
            activity_setopt(uid,'wheelFortune2',{value=mUserinfo.usegems-gems},true)
            activity_setopt(uid,'xiaofeisongli',{value=mUserinfo.usegems-gems})
            activity_setopt(uid,'danrixiaofei',{value=mUserinfo.usegems-gems})
            activity_setopt(uid,'ganenjiehuikui',{action='useGem',num=mUserinfo.usegems-gems})
                            -- 周年庆活动
            activity_setopt(uid,'anniversary',{action='useGem',num=mUserinfo.usegems-gems})
            mUserinfo.usegems=gems
        end

    end

    local acrossserver = require "model.acrossserverin"
    local across = acrossserver.new()
    local userdata=across:getUserDataFromDb(mUserinfo.bid,zid,mUserinfo.alliance,uid)
    local carrygems=0
    if mUserinfo.usegems >0 then
        if userdata then
            carrygems=tonumber(userdata.carrygems or mUserinfo.usegems)-mUserinfo.usegems
        end
        local ret =mUserinfo.addResource({gems=mUserinfo.usegems})
        if not(ret) then
            response.ret=-403
            return response
        end
        response.data.salaries = mUserinfo.usegems

	-- 钻石邮件监听
        recordRequest(uid,'akuafu',{num=mUserinfo.usegems})

        

    end
    mUserinfo.usegems_at =ts



    local senddata = {}
    senddata.bid =mUserinfo.bid
    senddata.aid =mUserinfo.alliance
    senddata.zid =zid
    senddata.uid=uid
    senddata.carrygems =0
    senddata.gems=0
    if carrygems> 0 then 
        senddata.usegems=tonumber(userdata.usegems)+carrygems
    end
    local config = getConfig("config.z"..zid..".across")
    local action  = 'apply'
    if userdata~=nil and next(userdata) then
        action ='update'
    end
    if type(ouserdata)=="table" and next(ouserdata) then
        local sdata={cmd='acrossserver.setuser',params={data=senddata,action=action}}
        local ret=sendGameserver(config.host,config.port,sdata)
        if ret.ret~=0 then
            response.ret=-21021
            return response
        end
    end

    local ret =false
    
    if action=='apply' then
        ret =across:setUserBattleData(senddata)
    else
        ret= across:updateUserBattleData(senddata)
    end
    
    if not ret then
        response.ret=-21012
        return response
    end
    mUserinfo.usegems =0
    mUserinfo.bid =""
    if uobjs.save() then    
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end