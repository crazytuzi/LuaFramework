--  领取军备竞赛的奖励
--  奖励送坦克
function  api_active_getarmsracereward(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
    }


    local uid = request.uid
    local uobjs = getUserObjs(uid)
    local rid =   request.params.rid
       uobjs.load({"userinfo","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')


    local acname = "armsRace"

    -- 状态检测
    local activStatus = mUseractive.getActiveStatus(acname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local cuut =  mUseractive.info[acname].v[rid]  or 0

    local activeCfg = getConfig("active." .. acname.."."..mUseractive.info[acname].cfg )

    if not activeCfg.reward[rid]  then
        response.ret = -1981
        return response
    end

    local reward = {}
    local need = activeCfg.reward[rid].n
    local ts = getClientTs()
    local addid =activeCfg.reward[rid].r
    local troopid ='troops_'..addid
    local addcount =activeCfg.reward[rid].num

    local rate =math.floor(cuut/need)

    if rate <=0 then
        response.ret = -1996
        return response
    end

    addcount=addcount*rate

    reward={[troopid]=addcount}

    if not takeReward(uid,reward) then
        response.ret = -403
        return response
    end

    mUseractive.info[acname].v[rid]=mUseractive.info[acname].v[rid]-need*rate
    regEventBeforeSave(uid,'e1')

    processEventsBeforeSave()
    if uobjs.save() then
        response.ret = 0        
        response.data.reward=formatReward(reward)
        local log ={addid,addcount,ts}
        mUseractive.setlog(uid,log,acname)
        response.msg = 'Success'
        processEventsAfterSave()
    end
    
    return response

end