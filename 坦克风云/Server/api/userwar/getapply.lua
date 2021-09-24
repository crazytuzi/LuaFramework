-- 获取报名信息
function api_userwar_getapply(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid   = request.uid
    
    if moduleIsEnabled('userwar') == 0 then
        response.ret = -4012
        return response
    end

    local cobjs = getCacheObjs(uid,false,'getapply')
    local mUserwar = cobjs.getModel('userwar')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo","hero","troops"})
    local mHero     = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop    = uobjs.getModel('troops') 

    local ts = getClientTs()
    local userWarCfg=getConfig("userWarCfg")

    local userwarnew = require "model.userwarnew"
    local userWarCfg=getConfig("userWarCfg")
    local warId = userwarnew.getWarId()
    if not userwarnew.isEnable() then
       warId=tonumber(warId)-1
    end
    if tostring(mUserwar.bid)~=tostring(warId) then
        mUserwar.reset()
    end
    
    local applyNum = userwarnew.getApplyNum(warId)
    print('applyNum',applyNum)
    
    response.data.userwar = mUserwar.toArray(true)
    response.data.userwar.warId=warId
    response.data.userwar.applynum=applyNum
    response.data.userwar.binfo=nil
    response.data.userwar.pointlog.rc=nil
    response.data.startWarTime=userWarCfg.startWarTime
    response.data.signUpTime=userWarCfg.signUpTime
    response.data.openDate=userWarCfg.openDate
    response.ret = 0 
    response.msg = 'Success'
    
    return response
end