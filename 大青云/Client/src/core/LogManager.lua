--[[
客户端日志
lizhuangzhuang
2015年3月25日17:16:33
]]

--[[ 参数定义：
uid:用户id
sid:服务器id
platform:平台
browser:浏览器
net:.Net版本
os:操作系统
step:节点id
tp:用户类型

tp定义:
1:有插件
2:无插件
3:有微端
4:无微端(改类型理论上没有)

节点定义:
页面
10 进入游戏欢迎页
20 点击开始游戏
30 加载游戏index页面成功(微端解析登录串自动登录成功)
引擎
40 loader加载成功，开始下载foa， sg=3(loader进度0%~10%)
42 加载fob， sg=4(loader进度10%~40%)
44 加载foc、fod， sg=5(loader进度40%~100%)
50 第一次资源加载完成，进入游戏，sg=6
游戏
60 客户端程序启动成功
70 请求连接服务器
80 连接服务器成功
90 请求登录验证
100 登录验证成功
110 新用户请求创角角色
120 新用户创角角色成功
130 老用户请求进入游戏
140 服务器返回玩家进入场景,二包开始加载
141 第二次资源加载(10%)
142 第二次资源加载(20%)
143 第二次资源加载(30%)
144 第二次资源加载(40%)
145 第二次资源加载(50%)
146 第二次资源加载(60%)
147 第二次资源加载(70%)
148 第二次资源加载(80%)
149 第二次资源加载(90%)
150 第二次资源加载完成并进入游戏
]]

_G.LogManager = {};


LogManager.reportUrl = nil;
LogManager.tp = 0;
LogManager.net = "";
LogManager.i = "";
--发送日志
--@param step 日志节点
function LogManager:Send(step)
	if not self.reportUrl then return; end
	if self.reportUrl == "" then return; end
	local url = self.reportUrl .. "&step=" .. step .. "&i=".. self.i .. "&tp=" .. self.tp .. "&net=" .. self.net;
	_sys:httpReport(url);
	print("LogManager:Send(step):" .. url);
end