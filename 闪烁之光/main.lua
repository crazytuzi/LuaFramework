-- 注意 文件(main/config)不能热更 
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():setSearchPaths({})
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
if cc.Application:getInstance():getTargetPlatform() == 0 then
    cc.FileUtils:getInstance():addSearchPath("../../src")
    cc.FileUtils:getInstance():addSearchPath("../../res")
end

require "config_init" 

if not pcall(function() require("config") end) then
    require("config_demo")
end

require "cocos.init"

SCREEN_WIDTH = CC_DESIGN_RESOLUTION.width
SCREEN_HEIGHT = CC_DESIGN_RESOLUTION.height
local main_lua = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
ROOT_DIR = string.gsub(main_lua, "src/main.lua", "")

-- 关于手机高低配,需要参与的地方有几个..第一个是baserole 这里是模型展示部分 第二个是 battlerole 这里是战斗,第三个是battlehookrole 这里是挂机单位
-- 然后还有skill_act.addSpine 这里是战斗预加载,最后就是centercity.quequeCreateEffect 场景特效加载
-- 通用创建 createSpineByName  和  createEffectSpine 

function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    -- 优先设置加载路径
    cc.FileUtils:getInstance():setSearchPaths({})
    if IS_TEST_STATUS == true then
        cc.FileUtils:getInstance():addSearchPath("res_verifyios")
    end
    if cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") then -- 是否进入优先体验服
        cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."tryver/assets/res")
        cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."tryver/assets/src")
    end
    cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."assets/res")
    cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."assets/src")
    cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."unzip/res")
    cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."unzip/src")
    cc.FileUtils:getInstance():addSearchPath("src/code_config", true)
    cc.FileUtils:getInstance():addSearchPath("res")
    cc.FileUtils:getInstance():addSearchPath("src")
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        cc.FileUtils:getInstance():addSearchPath("../../src/code_config", true)
        cc.FileUtils:getInstance():addSearchPath("../../src")
        cc.FileUtils:getInstance():addSearchPath("../../res")
    end

    --先设置一下全局速度
    cc.Director:getInstance():getScheduler():setTimeScale(1)
    -- 获取版本信息,做更新判断
    require("sdk_function")
    local file_update = require("file_update"):create()
    FileUpdate_Instance = file_update
    file_update:ver_load_start()
end

local base = {}
for k, v in pairs(_G) do 
    base[k] = true
end
_G["base"] = base

main()

