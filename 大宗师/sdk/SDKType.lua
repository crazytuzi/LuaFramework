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
-- 日期：15-1-6
--

require("data.data_sdkinfo")

local channelId
function GetChannelID(boundleID)
    if channelId == nil then
		local platform = device.platform
		if device.platform == "android" or ANDROID_DEBUG then
			platform = "android"
		end
        if ChannelID[platform][boundleID] then
            channelId = ChannelID[platform][boundleID]
        end
    end

    
    return channelId or 1
end

local sdktype = nil
function GetSDKType(boundleID)

    if sdktype == nil then
        for k, v in pairs(SDKType) do
            if v == boundleID then
                sdktype = k
                break
            end
        end
    end

    
    return sdktype or "SIMULATOR"
end


