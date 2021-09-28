--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-9-2
--

MSG_HEAD = MSG_HEAD or {

    name = "wx",
    build = "appstore",
    version = "100",
    pid = "",
    did = ""

}

NetworkHelper = {}

local network = require("framework.network")
local json = require("framework.json")

local function request(param)

    local _listener = param.listener
    local _url      = param.url
    local _action   = param.action or "POST"
    local _data     = param.data
    local _timeout = param.timeout or 10

--    printf(_url)
    local reqst = network.createHTTPRequest(_listener, _url, _action)
    reqst:setTimeout(_timeout)
    if _action == "POST" then
        dump(_data)
        reqst:setPOSTData(_data)
    elseif _action == "GET" then

    else
        assert(false, "request action error!!")
    end
    reqst:start()
    return reqst
end

function NetworkHelper.download(url, listener, action)

    if network.isLocalWiFiAvailable() ~= true then
        show_tip_label("您当前正在使用无线网络下载，请注意流量使用情况")
    end

    request({
        url = url,
        listener = listener,
        action = action,
        timeout = 20 * 60
    })
end

function NetworkHelper.request(url, param, listener, action, bNoTip)
    -- 1.网络不好
    if(network.isInternetConnectionAvailable() == false) and (network.isLocalWiFiAvailable() == false) then
        printf("3G和WIFI网络不好")
        device.showAlert("无法连接到网络，请检查您的网络", "",{"确定"}, function ()
            os.exit(0);
        end)
        return
    end

    local msg = {}
    msg.Head = MSG_HEAD
    if (device.platform == "windows") then
        msg.Head.DID = device.getOpenUDID()
    else
        msg.Head.DID = device.getOpenUDID()
    end

    msg.Head.ReqID = 1
    msg.Head.PID = ""
    msg.Body = param
    -- dump(msg.Body)
    dump(string.urldecode(tostring(msg.Body.info)))

    local num = 2
    local callback
    callback = function (event)

        if event.name == "completed" then
            if bNoTip ~= true then
                local request = event.request
                if(request:getResponseStatusCode() ~= 200) then
                    device.showAlert("提示","网络连接异常",{"OK"}, function ()
                    end)
                else
                    if listener then
                        local res = request:getResponseData()
                        listener(json.decode(res))
                    end
                end
            end
        elseif event.name == "failed" then
            if num > 0 then
                request({
                    url = url,
                    listener = callback,
                    action = action or "POST",
                    data = json.encode(msg)
                })
            elseif num == 0 then
                if bNoTip then

                else
                    show_tip_label("网络连接异常，请检查你的网络")
                end
            end
            num = num - 1
        end
    end

    if action == "GET" then
--        http://118.192.71.89:4100/?a=list&v=1102
        url = url .. "?"
        for k, v in pairs(param) do
            url = string.format("%s&%s=%s", url, k, v)
        end
        local i, j = string.find(url, "/?&")
        if i then
            url = string.sub(url, 1, j - 1) .. string.sub(url, j + 1)
        end
        print(url)
    end

    request({
        url = url,
        listener = callback,
        action = action or "POST",
        data = json.encode(msg)
    })

end



return NetworkHelper

