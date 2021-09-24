--搜索玩家

function api_friends_search(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid
    local name = request.params.name 
    if uid == nil or name==nil or name==''  then
        response.ret = -102
        return response
    end

    local db = getDbo()

    local result =db:getAllRows("SELECT uid,nickname,fc,level,rank,pic FROM userinfo WHERE nickname = :name ",{name=name})

    if next(result) then
        response.data.info=result
    end
    return response

end