--------------------------------------------------------------------------------------
-- 文件名:	CDebugCfg.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-12-15 11:24
-- 版  本:	1.0
-- 描  述:	
-- 应  用:    关于一些调试信息的处理
---------------------------------------------------------------------------------------

--配置表
g_Cfg = {
    Update      = false,
	Debug 		= false,   			--是不是调试版本
	ParseCsv 	= false,   			--是否解析csv脚本
	LogToFile 	= true,             --是否写日志文件
	ShowFps 	= false,			    --是否显示帧率
	fFps 		= 1.0/30,			--设置帧率
	PlayVideo 	= true,			--是否播视频 win32无效
    Csv_Platform = 1,               -- 0 IOS, 1 android
    BattleTeach = true,             --战斗教学是否开启 在win32有效。在iOS  android 强制开启。
}

--[[
enum TargetPlatform
{
    kTargetWindows,
    kTargetLinux,
    kTargetMacOS,
    kTargetAndroid,
    kTargetIphone,
    kTargetIpad,
    kTargetBlackBerry,
    kTargetNaCl,
    kTargetEmscripten,
    kTargetTizen,
    kTargetWinRT,
    kTargetWP8
};
]]
g_Cfg.Platform = CCApplication:sharedApplication():getTargetPlatform() --平台信息
UI_TEX_TYPE_PLIST = 0
--全局句柄
g_pDirector = CCDirector:sharedDirector()

if g_OnExitGame then
    g_writepath = CCFileUtils:sharedFileUtils():getWritablePath()
else
    g_writepath = CCFileUtils:sharedFileUtils():getSDCardPath()
end
local szDir = nil
if(g_writepath == "")then
	g_writepath = CCFileUtils:sharedFileUtils():getWritablePath()
	szDir = string.format("无SDCard, 日志文件路径为：%s", g_writepath)
	
else
	szDir = string.format("SDCard存储路径为:%s \n 系统路径为：%s", g_writepath, CCFileUtils:sharedFileUtils():getWritablePath())
end
g_logPath = g_writepath
g_writepath = g_writepath.."XXZUpdateFile/"

--写文件操作
local function writefile(path, content)
    local file = io.open(path, "ab")
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

--获取系统时间
local function getCurTime()
    local tbDate = os.date("*t")
    local strDate = string.format("【%d-%.2d-%.2d %.2d:%.2d:%.2d】",
         tbDate.year, tbDate.month, tbDate.day, tbDate.hour, tbDate.min, tbDate.sec)
    return strDate
end

--创建日志文件
local logFileName = nil
local function createLogFile()
    if(not logFileName)then
        local tbData = os.date("*t")
        logFileName = string.format("%s%d-%.2d-%.2d.log", g_logPath, tbData.year, tbData.month, tbData.day)
        local nCurTime = os.time() - 4*24*3600 --只保存三天的日志
        tbData = os.date("*t", nCurTime)
        local oldlogfile = string.format("%s%d-%.2d-%.2d.log", g_logPath, tbData.year, tbData.month, tbData.day)
        os.remove(oldlogfile)
    end
end

--日志写文件
local function logToFile(strText)
    createLogFile()
    writefile(logFileName, getCurTime()..strText)
end

local function LogPrint(strLog) 
	logToFile(strLog.."\n")
end

if g_Cfg.Platform  == kTargetWindows then--window下要处理很多事情
    function WindowProc(wParam, lParam) end
else
	g_Cfg.LogToFile =  g_Cfg.LogToFile or CCFileUtils:sharedFileUtils():isFileExist(g_writepath.."XXZ.dat")
end

local openCClog = g_Cfg.LogToFile
if openCClog  then
    local localprint = print
	cclog = function(...)  
		local strLog = string.format(...)
		if g_Cfg.LogToFile then
			LogPrint(strLog) 
		end
		localprint(strLog) 
	end

    print = function(strLog)  
		if g_Cfg.LogToFile then
			LogPrint(strLog) 
		end
		localprint(strLog) 
    end
else
	cclog      = function(v) return " "  end
	print      = function(v) return " "  end
    lua2str    = function(v) return " "  end
    echoj      = function(v) return " "  end
end

	
if g_Cfg.ParseCsv and (g_Cfg.Platform == kTargetWindows) then --只在win32 上加载表格
	g_LoadFile("LuaParseCsv/run")
end

g_pDirector:setDisplayStats(g_Cfg.ShowFps)

--设置帧率
g_pDirector:setAnimationInterval(g_Cfg.fFps)

