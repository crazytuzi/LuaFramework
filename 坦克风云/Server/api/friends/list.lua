-- 通信列表

function api_friends_list(request)
    local response = {
        ret=0,
        msg='Success',
        data = {},
    }

    local uid = request.uid

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"friends"})

    local mFriends = uobjs.getModel('friends')

    if next(mFriends.info) then
        local db = getDbo()
        local str=table.concat( mFriends.info, ",")
        local result =db:getAllRows("SELECT uid,nickname,fc,level,rank,pic FROM userinfo WHERE uid in ("..str..")")
        response.data.friends=result
    end

    return response
end