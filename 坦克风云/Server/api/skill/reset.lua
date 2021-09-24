-- 技能点重置
function api_skill_reset(request)
    local response = {ret=-1,msg='error'}
    response.data={}
    
    local uid = request.uid
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    skill = uobjs.getModel('skills')
    
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    local gems=28
    if moduleIsEnabled('nbs')==1 then
        gems=getConfig('skill.resetGem')
    end

    if  not mUserinfo.useGem(gems) then
        response.ret = -109
        return response
    end    
    
    local reward = skill.reset()
    if next(reward) then
        for pid,num in pairs(reward) do
            local flag=mBag.add(pid,num)
            if flag~=true then
                return response
            end
        end
    end
    regEventBeforeSave(uid,'e1')
    
    local mTask = uobjs.getModel('task')
    mTask.check()
    
    regActionLogs(uid,1,{action=13,item='skills',value=gems,params={propNum=mBag.getPropNums('p19'),getNum=returnNum}})
    processEventsBeforeSave()

    if uobjs.save() then  
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.skill = skill.toArray(true)
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = 501
        response.msg = 'save failed'
    end
    
    return response
end	