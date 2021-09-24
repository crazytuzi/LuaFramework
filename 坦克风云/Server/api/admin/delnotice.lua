function api_admin_delnotice(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    if type(request.params) ~= 'table' then
        response.ret = -102
        return response
    end
    
    local db = getDbo()
    local URL = require "lib.url"
    local id =tonumber(request.params.id) or 0
    local st =tonumber(request.params.st)
    local title =request.params.title
    local ret= 0
    if id >0 then
        ret = db:query("delete from notice  where id in (" .. id .. ")")
    else
        local et =getClientTs()

        ret =db:query("delete from notice  where time_end <"..et)
    end 

    if st~=nil and title~=nil then
        local title = URL:url_unescape(title)
        ret =db:query("delete from notice  where time_st ="..st.." and  title=".."'"..title.."'" )
    end

    if ret and ret > 0 then
        response.ret = 0
        response.msg = 'Success'
    end


    
    return response
end