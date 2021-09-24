-- 兑换荣誉勋章
function api_skill_change(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local pid = request.params.pid
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local skill = uobjs.getModel('skills')

    local getPropList=getConfig('skill.getPropList')
    if getPropList[pid]==nil then 
        response.ret=-102
        return response 
    end
    local num=getPropList[pid].getNum
    local ts = getClientTs()
    for k,v in pairs (getPropList[pid]) do
        if k=="costGem" then
            if not mUserinfo.useGem(v) then
                response.ret = -109 
                return response        
            end
            regActionLogs(uid,1,{action=203,item="",value=v,params={buy=pid}})
        end
        if k=="coolDown" then

            if skill.buy_at+v >ts then
                response.ret = -2049
                response.msg = 'require prop'
                return response
            end
            skill.buy_at=ts
        end

        if k=="costProp" then
            if not mBag.usemore(v) then
                response.ret = -1996
                response.msg = 'require prop'
                return response
            end
        end
    end

    if not mBag.add(pid,num) then
        response.ret = -403
        return response
    end
    if uobjs.save() then    
        processEventsAfterSave()
        response.data.bag = mBag.toArray(true)
        response.data.skills = skill.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    end
    return response

end