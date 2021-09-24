--
function api_user_urlencode(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local message = request.params.message
    local URL = require "lib.url"
    local base64 = require "lib.base64"

    -- local http = require("socket.http")
    -- local myurl = "http://192.168.8.202/tank-server/google/urlencoding.php?message=" .. message
    -- local ret = http.request(myurl)
    -- ret = json.decode(ret)

    response.data.message =  base64.Encrypt( URL:encodeURI(message) ) --ret.data
    response.ret = 0
    return response
end
