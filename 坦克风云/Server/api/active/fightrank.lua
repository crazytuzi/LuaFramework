function api_active_fightrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local pageend = tonumber(request.params.eIndex) or 20
    local start = tonumber(request.params.sIndex) or 0
    if uid == nil  then
        response.ret = -102
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"useractive"})
    local mUseractive =uobjs.getModel("useractive");

    local list,mylist =mUseractive.getfightRank(start,pageend,uid)
    response.ret=0
    response.ranklist=list 
    response.msg = 'Success'
    response.mylist=mylist
    return response 

end
     





