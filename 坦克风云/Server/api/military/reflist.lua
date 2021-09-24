-- 刷新战斗列表

function api_military_reflist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
            userarena={},
        },
    }
    -- 军事演习功能关闭
    local uid = tonumber(request.uid)
   
    if uid <= 0 then
        response.ret = -102
        return response
    end
    if moduleIsEnabled('military')  == 0 then
        response.ret = -10000
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task","userarena"})    
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mUserarena = uobjs.getModel('userarena')

    local arenaCfg = getConfig('arenaCfg')
    local gemCost=arenaCfg.refershPrice[mUserarena.ref_num+1]
    if gemCost==nil then
        gemCost=arenaCfg.refershPrice[#arenaCfg.refershPrice]
    end

    if gemCost>0 then
        if  not mUserinfo.useGem(gemCost) then
            response.ret = -109
             return response
        end
        regActionLogs(uid,1,{action=98,item="",value=gemCost,params={buyNum=mUserarena.ref_num+1}})
    end

    
    mUserarena.ref_num=mUserarena.ref_num+1
    
    local list=mUserarena.getlist(mUserarena.ranking,true)

    if uobjs.save() then  
        response.ret = 0
        response.msg = 'Success'
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.userarena.attacklist=list
        response.data.userarena.ref_num=mUserarena.ref_num
    end
    return response
end