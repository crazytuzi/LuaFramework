function api_hchallenge_rewardlist(request)

    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    if not uid then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"hchallenge"})
    local hchallenge = uobjs.getModel('hchallenge')
    response.data = type(hchallenge.reward) == 'table' and hchallenge.reward or {}
    return response
end

