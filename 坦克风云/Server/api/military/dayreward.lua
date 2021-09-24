
--  军演每天的奖励
function api_military_dayreward(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }
    
    if moduleIsEnabled('he')  == 0 then
        response.ret = -102
        return response
    end


    local uid = request.uid
    local pid = request.params.pid
   
    if uid <= 0 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task","userarena"})    
    require "model.achallenge"
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local muserarena = uobjs.getModel('userarena')
    local ts = getClientTs()
    local pointReward = getConfig('arenaCfg.pointReward')

    if pointReward[pid]==nil or type(pointReward[pid])~='table' then
        response.ret=-102
        return response
    end

    if type(muserarena.info.dr)~='table' then  muserarena.info.dr={}  end
    if muserarena.score<pointReward[pid].point then
        response.ret=-1981
        return response
    end

    local flag=table.contains(muserarena.info.dr, pid)
    if  flag then
        response.ret=-1976
        return response
    end

    local ret = takeReward(uid,pointReward[pid].serverReward)
    
    if not ret then
        response.ret=-403
        return response
    end

    table.insert(muserarena.info.dr,pid)
    if uobjs.save() then  
        response.ret = 0
        response.msg = 'Success'
    end

    
    return response 

end