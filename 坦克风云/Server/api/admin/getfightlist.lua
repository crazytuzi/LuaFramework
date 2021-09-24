function api_admin_getfightlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local num = tonumber(request.params.num) or 0
    local redis = getRedis()
    local key = "z"..getZoneId()..".rank.fc"

    local ret = redis:zrevrange(key,0,num)
    local list = {}
    
    if type(ret) == 'table' then
        for _,v in pairs(ret) do
            local uid = tonumber(v) or 0
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                local item = {}

                table.insert(item,userinfo.uid)
                table.insert(item,userinfo.fc)
                table.insert(item,userinfo.nickname)
                table.insert(item,userinfo.level)
                table.insert(item,userinfo.vip)
                
                table.insert(list,item)
            end        
        end
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.fightlist = list

    return response

end