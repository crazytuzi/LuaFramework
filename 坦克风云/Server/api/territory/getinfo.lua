-- 获取领地信息
function api_territory_getinfo(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local aid = request.params.aid
    local member = request.params.m or false --true 获取个人数据

    if uid == nil or aid == nil  then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')
 
    -- 这个不能改成只读的  有时候可能要判断领地数据 没有的话要给重新赋值
    local mAterritory = getModelObjs("aterritory",aid)

    -- TODO
    -- mAterritory.r1 = 10000000000
    -- mAterritory.r2 = 10000000000
    -- mAterritory.r3 = 10000000000
    -- mAterritory.r4 = 10000000000
    
    -- mAterritory.r6 = 10000000000
    -- mAterritory.r7 = 10000000000

    -- mAterritory.saveData()
    -- os.exit()
  
    if mUserinfo.alliance==0 or mUserinfo.alliance ~= aid then
        response.ret = - 102
        return response
    end

    local allianceBuidCfg = getConfig('allianceBuid')
    if mAterritory.isEmpty() then
        response.data={}
    else
        if member then
            local mAtmember = uobjs.getModel('atmember')
            local task,flag = mAtmember.setTask()
            if flag then
                uobjs.save()
            end
            response.data.member =  mAtmember.toArray(true)

        end
        local task,flag = mAterritory.tasklist()
        if falg then
            mAterritory.saveData()
        end
        response.data.territory = mAterritory.formatedata()
    end

    response.ret = 0
    response.msg = 'Success'

    return response
end
