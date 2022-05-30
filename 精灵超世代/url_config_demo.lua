print("url_config @@@@@@@@@@@@@@@@@@@@@@@@@@")

UPDATE_TRY_VERSION_MAX = 0
UPDATE_VERSION_MAX = 0
VerPath = {
    -- ["1"] = {name="pokemon_up_20211029171932_v1", size=7074058},--trunk v.2010
}
VerMergePath = {
}
----------------------- 公共函数 ----------

--add by chenbin
IS_APP_STORE_ENROLL         = false                  --是否为app store提审状态
----------------

--cdn地址-----
CDN_URL = "https://shanshuo-gaobao.oss-accelerate.aliyuncs.com/gamec3bt"
--------------

--配置是否为外网测试,true连接外网，false连接内网
TEST_PUBLIC_SERVER = true

if TEST_PUBLIC_SERVER then
    --外网
    REG_URL = "http://8.134.70.76/api/role.php"
    -- REG_URL = "http://8.134.87.47:43210/Api/Servers/getServerList"
else
    --内网
    REG_URL = "http://8.134.70.76/api/role.php"
end

if IS_APP_STORE_ENROLL then
    NOTICE_URL = "http://47.89.191.172/api/notice.php/getPublicNotice"
else
    NOTICE_URL = "http://8.134.87.47:43210/Api/Notice/getPublicNotice"
end
--DOWN_APK_URL = "http://192.168.1.147:81/index.php/ChannelBag/bag"

-- --------------------------------------------------+
-- 非打包热更新处理
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

-- urlConfig加载完成调用
function webFunc_urlConfigEnd()
end

-- 加载模块完成 初始化instance调用开始时调用
function webFunc_initInstanceStart()
end

-- 加载模块完成 初始化instance调用完成时调用
function webFunc_initInstanceEnd()
end

-- 游戏开时完毕时调用
function webFunc_GameStart()
end

--内网
-- CDN_URL="http://10.5.20.50"

--外网
-- CDN_URL="http://8.134.70.76"
CDN_PATH_BASE = CDN_URL


URL_PATH_ALL = {}
URL_PATH_ALL.demo = {
    update = CDN_URL,
    register = REG_URL,
    voice = "", -- 临时添加，解决chat_help
}
URL_PATH_ALL.other = {
    update = CDN_URL,
    register = REG_URL,
    voice = "",
}
URL_PATH_ALL.get = function(platform)
    local data = URL_PATH_ALL[platform] or URL_PATH_ALL["other"]
    return data
end

-- 登录的时候，请求服务器列表
function get_servers_url(account, platform, channelid, srvid, start, num)
    return string.format("%s?account=%s&platform=%s&chanleId=%s&srvid=%s", URL_PATH.register, account, platform, DEF_CHANNEL or 'dev', srvid)
end

function get_notice_url(days, loginData)
    return NOTICE_URL
end

-- require("cli_log")
