-- desc : 设置啤酒节fackbook分享链接
-- user : chenyunhe
function api_admin_setfburl(request)
    local response = {
            ret=-1,
            msg='error',
            data = {},
        }

    local url = tostring(request.params.url)
    local zid = getZoneId()

    local lan = request.params.lan
    if not lan or not url then
        response.ret = -102
        return response
    end

    local urlkey = "facebookshareurl"
    local freeData = getFreeData(urlkey)
    if not freeData then
        freeData = {info={}}
    end

    if type(freeData.info)~='table' then
        freeData.info = {}
    end
   
    freeData.info[lan] = url
    if setFreeData(urlkey, freeData.info) then
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'error'
    end

    return response
end
