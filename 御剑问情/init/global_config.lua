GLOBAL_CONFIG = {
	client_time = 0,					-- 更新数据时的客户端时间

	param_list = {						-- 参数列表
		client_ip = "",					-- 客户端外网IP
		config_url = "",				-- 配置获取地址(备用)
		update_url = "",				-- 资源更新地址
		update_url2 = "",				-- 资源更新地址(备用)
		upload_url = "",				-- 头像语音上传地址
		report_url = "",				-- 日志上报地址
		report_url2 = "",				-- 日志上报地址(新版)
		verify_url = "",				-- 登录验证URL
		verify_url2 = "",				-- 登录验证URL(备用)
		event_url = "",					-- 事件上报地址
		gift_fetch_url = "",			-- 礼包领取地址
		gift_query_url = "",			-- 礼包查询地址
		wc_gift_query_url = "",			-- 微信礼包查询地址
		qq_gift_fetch_url = "",			-- QQ礼包领取地址
		qq_gift_query_url = "",			-- QQ礼包查询地址
		gm_report_url = "",				-- 联系GM上报地址
		is_enforce_cfg = 0,				-- 是否强制使用安卓配置（0没有返回，1安卓，2苹果）
		is_audit_android = 0,			-- 安卓审核标记(0不是审核版本, 1是审核)
		ios_shield = "",				-- IOS审核时需要屏蔽的模块(用#隔开)
		ui_skin_color = "",				-- UI皮肤颜色
		switch_list = {
			update_package = false,		-- 开关 - 安装包更新
			update_assets = false,		-- 开关 - 资源更新
			audit_version = false,		-- 开关 - IOS审核版本
			log_print = false,			-- 开关 - 打印日志到控制台
			error_screen = false,		-- 开关 - 打印错误日志到屏幕
			countly_report = true,		-- 开关 - 推送日志到后台
			open_chongzhi = true,		-- 开关 - 开启充值
			open_gm = true,				-- 开关 - 开启GM
			active_code = false,		-- 开关 - 激活码登录
			wechat_gift = false,		-- 开关 - 微信礼包
			qqvip_gift = true,			-- 开关 - QQ礼包
			gamewp = false,             -- 开关 - Web支付
			show_3dlogin = true,		-- 开关 - 是否显示3D登陆页
			show_loading_effect = false,-- 开关 - 是否显示加载页特效
		},
	},

	server_info = {						-- 服务器列表
		last_server = 0,				-- 上一次登录的服务器ID
		server_time = 0,				-- 服务器当前时间 (用于对时)
		server_offset = 0,				-- 服偏移值
		server_list = {
			{
				id = 1,					-- 服务器ID
				name = "",				-- 服务器名字
				ip = "",				-- 登录服务器IP
				port = 0,				-- 登录服务器端口
				open_time = 0,			-- 服务器开服时间
				ahead_time = 0,			-- 提前开放登录时间(秒)
				pause_time = 0,			-- 维护结束时间
				flag = 0,				-- 服务器标记 (1: 火爆 2: 新服 3: 即将开服 4: 测试 5: 维护)
				avatar = 0,				-- 头像ID (未实现)
				role_name = "",			-- 角色名字 (未实现)
				role_level = 0			-- 角色等级 (未实现)
			}
		}
	},

	version_info = {					-- 最新 版本信息
		package_info = {				-- 安装包信息
			version = 0,				-- 安装包版本
			name = "",					-- 安装包文件名
			desc = "",					-- 安装包描述
			url = "",					-- 安装包下载地址
			size = 0,					-- 安装包大小
			md5 = "" 					-- 安装包MD5
		},

		assets_info = {					-- 游戏资源信息
			version = 0,				-- 资源版本号
			file_list = {
				path = "",				-- 资源文件列表
				size = 0				-- 资源文件列表大小
			}
		},

		update_data = ""				-- 更新初始化代码
	},

	package_info = {					-- 本地 安装包信息 (从安装文件获取, 无法修改)
		version = 0,					-- 安装包版本
		vername = "",					-- 安装包版本名
		config = {
			agent_id = "",				-- 平台(渠道)ID
			init_urls = {},				-- PHP配置获取地址
			report_url = "",			-- 日志上报地址
		}
	},

	assets_info = {						-- 本地 游戏资源信息
		version = 0,					-- 资源版本号
		file_list = {
			path = "",					-- 资源文件列表
			size = 0					-- 资源文件列表大小
		}
	},
}

local init_urls = nil
local init_urls_text = ChannelAgent.GetInitUrl()
local agent_id = ChannelAgent.GetChannelID()
if init_urls_text == nil or init_urls_text == "" then
	init_urls = {"http://192.168.9.30:8014/init-query.php"}
else
	init_urls = string.split(init_urls_text, ',')
end

if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsPlayer then
	local file = io.open(UnityEngine.Application.streamingAssetsPath .. '/win_agent.txt')
	if nil ~= file then
		local content = file:read('*all')
		content = string.sub(content, 2, -1)
		file:close()

		content = mime.unb64(content)
		local params = string.split(content, ",")
		agent_id = params[1]
		init_urls = {params[2]}
	end

end

-- init_urls = {"http://192.168.9.60:8000/init-query.php"}
-- init_urls = {"http://cls.ug05.youyannet.com/adm/query.php"}
-- init_urls = {"http://cls.ug01.youyannet.com/its/query.php"}
-- init_urls = {"http://cls.ug01.youyannet.com/axy/query.php"}
-- init_urls = {"http://cls.ug01.youyannet.com/ayx/query.php"}

-- init_urls = {"http://cls.ug14.youyannet.com/dev/query.php"}
-- agent_id = "dev"

GLOBAL_CONFIG.package_info.version = UnityEngine.Application.version
GLOBAL_CONFIG.package_info.config.init_urls = init_urls
GLOBAL_CONFIG.package_info.config.agent_id = agent_id
GLOBAL_CONFIG.assets_info.version = AssetManager.LoadVersion()