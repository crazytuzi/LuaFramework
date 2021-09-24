function api_hchallenge_list(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    -- 攻防双方id
    local uid = request.uid
    local minSid = request.params.minsid
    local maxSid = request.params.maxsid
    
    if uid == nil or minSid < 1 or maxSid < minSid then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"hchallenge"})
    local hchallenge = uobjs.getModel('hchallenge')

    response.data.hchallenge = hchallenge.getChallengeDataBySid(minSid,maxSid)
    response.ret = 0
    response.msg = 'Success'    

    return response
end
