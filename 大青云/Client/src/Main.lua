_G.dofile = function(str)
	error("Err : can not use dofile , Must use _dofile ")
	while true do end;
end
_dofile 'Config.lua'

_dofile 'src/PlatformFacade.lua'
--写入日志
_dofile 'src/core/LogWriter.lua'
--消息文件
_G.ClientMsgPath = "msg/";
_dofile(ClientMsgPath .. "Include.lua");
--配表
_G.ClientConfigPath =  "";
_dofile(ClientConfigPath .. "config/project.lua")
-- core
_dofile 'src/core/Project.lua'
-- resoure path
-- 各个子系统
_dofile 'src/module/Include.lua'
----程序入口
_dofile'src/Application.lua'
--不同平台版本
_dofile'src/version/Include.lua'

Assets:Create();

--判断是否是微端
_G.ismclient = _sys:getGlobal('gtype')=='pc' or _sys.microClient
--

PlatformFacade:Start();
LogManager:Send(60);

--全局设置处理
_sys.mainThreadLog = false;
--
_app.console.show = false
_app.console.block = true
_app.console.bgColor = 0x80000000
_app.console.maxline = 20
--_app.console.toggleKey = _System.KeyDel
_sys.showVersion = false;
_sys.showStat = false;
_sys.downloadLog = false

--全局设置异步加载的方法
_G.currAsyncType = "";
_G.asyncLoad = function(async,type)
	if type == "scene" then
		_sys.asyncLoad = async;
		if async then
			_G.currAsyncType = "";
		else
			_G.currAsyncType = type;
		end
	elseif _G.currAsyncType ~= "scene" then
		_sys.asyncLoad = async;
	end
end

if not _G.isConsoleLog then
	_G.Debug = _G.None
end

------------------------------------------------------以下是Debug模式下的处理----------------------------------------------
if _G.isDebug  or _sys:getGlobal("dMonitor") then
	sysMonitor()
	_debug.monitor = false
end
if _G.isDebug then
	_sys.showStat = true;
	--CMemoryDebug:Create();
end
-------------------------------------------以上是Debug模式下的处理-----------------------------------------

	
-------------------------------------------以下调试信息上线前要干掉-----------------------------------------
--显示状态信息
if isPublic and GetCommandParam("dStat") == 'true' then
	_sys.showStat = true;
end
--报错弹出
if isPublic and _sys:getGlobal("dAlert") then
	_sys:onError(function(error)
		if error == "\n" then return; end
		UILog:AddLog(error);
	end);
end

if isDebug then
	_sys:onError(function(error)
		if error == "\n" then return; end
		UILog:AddLog(error);
		WriteFile(error..'\r\n',nil,".lua","资源加载失败列表");
	end);
end

--下载日志监控
if isPublic and _sys:getGlobal("dDownload") then
	_sys.downloadLog = true;
end
--截图上报
if isPublic and _sys:getGlobal("dScreenReport") then
	_app.screenReportName = 'dqy';
end
-----------------------------------------以上调试信息上线前要干掉--------------------------------------------

--启动游戏
if not CGameApp:Create() then
	Debug('We Create App Error');
end

if _G.isDebug then
	_define()
end


--[[_Archive.beginRecord();
TimerManager:RegisterTimer(function()
	_Archive.endRecord()
	local loginFiles = _Archive:getRecord()
	local str = '';	
	for i,file in ipairs(loginFiles) do
		str = str .. '"'..file ..'",'.. '\r\n';
	end
	print(str);
	WriteLog(LogType.Normal,true,'Record',str);
	-- FTrace(loginFiles)
end, 60000, 1)]]

_G.StepRecord=function(state)
	if _G.isStepRecord then
		local params = {};
		params[1] = 'system';
		params[2] = 'system';
		params[3] = 'record';
		params[4] = tostring(state);
		_G.GMInput['system'].execute(params);
	end
end

_G.SetLoadTaskState = function(isPause,priority)
	priority = priority or 0;
	if isPause then
		if _sys.pauseDownloadTask then
			_sys:pauseDownloadTask(priority)
		end
	else
		if _sys.resumeDownloadTask then
			_sys:resumeDownloadTask(priority);
		end
	end
end

-- _G.StepRecord(true);



