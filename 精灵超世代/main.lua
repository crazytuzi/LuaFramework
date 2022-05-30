print("main start @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")

cc.FileUtils:getInstance():setPopupNotify(false)
-- 设置初始化路径，保证前期lua文件加载
cc.FileUtils:getInstance():addSearchPath("src")
-- 加载配置
require "config_init"
-- 框架初始化了
require "src.cocos.init"

require("src.util.util")

-- 注意 文件(main/config)不能热更


--[[
	包含：
		配置信息获取地址
		日志上报地址
]]
if not pcall(function() require("config") end) then
	require("config_demo")
end

--modified by chenbin:根据热更情况自动处理
if UPDATE_SKIP then
	require "url_config_demo"
	URL_PATH = URL_PATH_ALL.get(PLATFORM_NAME)
end
--------------------------


SCREEN_WIDTH = CC_DESIGN_RESOLUTION.width
SCREEN_HEIGHT = CC_DESIGN_RESOLUTION.height
local main_lua = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
-- 代码根目录
ROOT_DIR = string.gsub(main_lua, "src/main.lua", "")

--设置搜索路径
function setupSearchPaths()
	local lanCode = cc.Application:getInstance():getCurrentLanguageCode()

	-- 优先设置加载路径
	local fu = cc.FileUtils:getInstance()
	local writablePath = fu:getWritablePath()
	fu:setSearchPaths({})
	local fixedPaths = {}

	--可写目录app store审核状态资源 > 包体app store审核状态资源
	if not UPDATE_SKIP then
		if IS_APP_STORE_ENROLL == true then --app store审核状态
			table.insert(fixedPaths, writablePath.."assets/res_appstore/"..lanCode)
			table.insert(fixedPaths, writablePath.."assets/res_appstore/"..lanCode.."/res")
			table.insert(fixedPaths, writablePath.."assets/res_appstore/"..lanCode.."/src")
		end
	end
	if IS_APP_STORE_ENROLL == true then --app store审核状态
		table.insert(fixedPaths, "res_appstore/"..lanCode)
		table.insert(fixedPaths, "res_appstore/"..lanCode.."/res")
		table.insert(fixedPaths, "res_appstore/"..lanCode.."/src")
	end

	--可写目录多语言资源 > 包体多语言资源
	if not UPDATE_SKIP then
		table.insert(fixedPaths, writablePath.."assets/res_localized/"..lanCode)
		table.insert(fixedPaths, writablePath.."assets/res_localized/"..lanCode.."/res")
	end
	table.insert(fixedPaths, "res_localized/"..lanCode)
	table.insert(fixedPaths, "res_localized/"..lanCode.."/res")

	--可写目录普通资源 > 包体目录普通资源
	if not UPDATE_SKIP then
		table.insert(fixedPaths, writablePath.."assets")
		table.insert(fixedPaths, writablePath.."assets/res")
		table.insert(fixedPaths, writablePath.."assets/src")
	end
	table.insert(fixedPaths, "res")
	table.insert(fixedPaths, "src")

	fu:setSearchPaths(fixedPaths)

	--打印可写路径，搜索路径
	local fileUtils = cc.FileUtils:getInstance()
	local writablePath = fileUtils:getWritablePath()
	print("WTF___writablePath_____",writablePath)
	local pp = fileUtils:getSearchPaths()
	dump(pp,"WTF___getSearchPaths____")
	--------
end

-- 关于手机高低配,需要参与的地方有几个..第一个是baserole 这里是模型展示部分 第二个是 battlerole 这里是战斗,第三个是battlehookrole 这里是挂机单位
-- 然后还有skill_act.addSpine 这里是战斗预加载,最后就是centercity.quequeCreateEffect 场景特效加载
-- 通用创建 createSpineByName  和  createEffectSpine

function main()
	print("start main @@@@@@@@@@@@@@@@@@@@@@@@@@")
	collectgarbage("collect")
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	-- 设置搜索路径
	setupSearchPaths()

	--设置好搜索路径后，require多语言文件
	local lanCode = cc.Application:getInstance():getCurrentLanguageCode()
	if IS_APP_STORE_ENROLL == true then --app store审核状态
		local srcLS = string.format("config.auto_config_%s.%s_localizedStringOutput_src@localizedStringOutput_src", lanCode, lanCode)
		require(srcLS)
	else
		local srcLS = string.format("config.auto_config_%s.localizedStringOutput_src@localizedStringOutput_src", lanCode)
		require(srcLS)
	end

	--先设置一下全局速度
	cc.Director:getInstance():getScheduler():setTimeScale(1)
	cc.Director:getInstance():setDisplayStats(CC_SHOW_FPS)
	-- 获取版本信息,做更新判断
	require("sdk_function")

	local file_update = require("file_update"):create()
	FileUpdate_Instance = file_update
	file_update:ver_load_start()
	print("main_finish@@@@@@@@@@@@@")
end

local base = {}
for k, v in pairs(_G) do
	base[k] = true
end
_G["base"] = base

-- 执行main
main()

