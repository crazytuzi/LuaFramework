-- 军团协助的列表


function api_alliance_helplist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }
    
    if moduleIsEnabled('alliancehelp') == 0 then
        response.ret = -180
        return response
    end
    local uid = tonumber(request.uid)     
    local maxid = request.params.maxid or 0
    local minid = request.params.minid or 0
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    if mUserinfo.alliance <=0 then
        response.ret = -102
        return response
    end
    ALLIANCEHELP = require "lib.alliancehelp"
    local ts=getClientTs() 
    local limit=80
    local flag=true
    local pagerow=20
    local list={}
    local next=0
    for i=1,5 do
        local alist=ALLIANCEHELP:getlistbyaid(mUserinfo.alliance,maxid,minid,ts,limit,uid)
        for k,v in pairs (alist) do
            local users=json.decode(v.list) or {}
            local flag=table.contains(users,tostring(uid))
            if not flag  then
                if #list< pagerow then
                    v.list=users
                    v.info=json.decode(v.info)
                    table.insert(list,v)
                else
                    next=1
                    flag=false
                end
            end
            maxeid=tonumber(v.id)
        end
        if #alist <limit or  not flag then
            break
        end 
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.helplist=list
    response.data.next=next
    return response

end