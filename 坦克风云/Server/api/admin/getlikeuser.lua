function api_admin_getlikeuser(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        getlikeuser={},
    }
    local page = request.params.page
    if page<=0 then
        response.ret = -102
        return response
    end
    local URL = require "lib.url"
    local nickname = json.decode(URL:url_unescape(request.nickname))
    
    local begin = 100*(page-1)
    local num =50
    if not nickname then
        response.ret = -102
        return response
    end
    
    nickname = "%%"..nickname.."%%"

    local db = getDbo()
    local result = db:getAllRows("select uid,nickname,level,vip from userinfo where nickname like :name limit :bg , :n",{name=nickname,bg=begin,n=num})
    response.data.getlikeuser = result or {}
    response.ret = 0
    response.msg = 'Success'

    return response
end