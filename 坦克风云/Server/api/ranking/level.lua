function api_ranking_level(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local users = request.params.users
        
    local list = {}
    for k,v in pairs(getLevelRanking(users)) do
        local uid = tonumber(k) or 0
        if uid>0 then
            local uobjs = getUserObjs(uid,true)
            local userinfo = uobjs.getModel('userinfo')
            local item = {}

            table.insert(item,userinfo.uid)
            table.insert(item,userinfo.nickname)
            table.insert(item,userinfo.level)
            table.insert(item,v)
            
            table.insert(list,item)
        end        
    end
    response.data.ranking = list
    response.ret = 0	    
    response.msg = 'Success'
    
    return response
end
