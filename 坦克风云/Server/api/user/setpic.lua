function api_user_setpic(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    -- 空值 是默认的
    local uid = tonumber(request.uid)     
    local pic = request.params.pic --头像
    local bid = request.params.bid or '' -- 头像框 
    local aid = request.params.aid or ''--挂件

    if not uid  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('pic', 'changepic') == 0 then
      response.ret = -303
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if pic=='' then pic='p1' end
    -- 头像
    if not mUserinfo.isActpid(pic) then
        response.ret=-102
        return response
    end

    local ret = mUserinfo.changePic(pic)
    if not ret then
        response.ret=-102
        return response
    end

    -- 头像框
    if not mUserinfo.isActpid(bid) then
        response.ret=-102
        return response
    end
    local ret= mUserinfo.setPic(bid,'b')
    if not ret then
        response.ret=-102
        return response
    end

    -- 挂件
    if not mUserinfo.isActpid(aid) then
        response.ret=-102
        return response
    end
    local ret= mUserinfo.setPic(aid,'a')
    if not ret then
        response.ret=-102
        return response
    end


    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()

        response.data.userinfo = mUserinfo.toArray(true)
        response.ret = 0
        response.msg = "success"
    end

    return response
end
