

--获取成就排行榜信
function api_admin_getachievementlist(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local num = tonumber(request.params.num)
    if num>100 then
        response.ret = -102
        return response
    end

    local sql = string.format("select uid,achvnum from achievement where achvnum >0 order by achvnum desc limit "..num)
    local ret =getDbo():getAllRows(sql)
    local list = {}
    if type(ret) == 'table' then
        for _,v in pairs(ret) do
            local uid = tonumber(v["uid"]) or 0
            if uid>0 then
                local uobjs = getUserObjs(uid,true)
                local userinfo = uobjs.getModel('userinfo')
                local achvnum = v.achvnum
                local item = {}

                table.insert(item,userinfo.uid)
                table.insert(item,userinfo.nickname)                
                table.insert(item,achvnum)
                table.insert(item,userinfo.fc)
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