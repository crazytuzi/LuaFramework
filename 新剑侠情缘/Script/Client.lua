local SdkMgr = luanet.import_type("SdkInterface");
Client.nVersionPrivateMsg = 1;
function Client:CallClientScriptWhithPlayer(szFunc, ...)
	local bRet = pcall(me.CallClientScript, szFunc, me, ...);
	if not bRet then
		Log("CallClientScriptWhithPlayer ERR !!", szFunc, ...);
	end
end

function Client:SetFlag(key, value, nId, bNotSave)
	local tbFlag = Client:GetUserInfo("LocalFlags", nId);
	if value==nil then
		value = true
	end
	tbFlag[key] = value
	if not bNotSave then
		self:SaveUserInfo();
	end
end

function Client:GetFlag(key, nId)
	local tbFlag = Client:GetUserInfo("LocalFlags", nId);
	return tbFlag[key];
end

function Client:ClearFlag(key, nId)
	local tbFlag = Client:GetUserInfo("LocalFlags", nId);
	tbFlag[key] = nil;
	self:SaveUserInfo();
end

function Client:GetUserInfo(szType, nId)
	if not self.tbUserInfo then
		local f = io.open(g_szUserPath .. "User/UserInfo.lua", "r");
		local szFileContent = "return {};";
		if f then
			szFileContent = f:read("*all");
			f:close();
		end

		self.tbTmpEnv = {};
		szFileContent = "setfenv(1, Client.tbTmpEnv); local fnLoad = function () " .. szFileContent .. " end tbUserInfo = fnLoad();";
		local fnFile = loadstring(szFileContent);
		if fnFile then
			fnFile();
		end

		self.tbUserInfo = self.tbTmpEnv.tbUserInfo or {};
	end

	if not nId then
		nId = -1;
		if me and me.dwID then
			nId = me.nLocalServerPlayerId or me.dwID; 					-- 优先本服玩家id,玩家在跨服的话 me.dwID 会变
		end
	end

	self.tbUserInfo[nId] = self.tbUserInfo[nId] or {};
	self.tbUserInfo[nId][szType] = self.tbUserInfo[nId][szType] or {};
	return self.tbUserInfo[nId][szType];
end

function Client:SaveUserInfo()
	local szValue = Lib:Val2Str(self.tbUserInfo);
	local file = io.open(g_szUserPath .. "User/UserInfo.lua", "w+");
	if not file then
		Log("Client:SaveUserInfo ERR ?? file is nil !!" .. g_szUserPath);
		return;
	end

	file:write("return" .. szValue);
	file:close();
end

--因为聊天数据可能比较多，就单独存一个文件了
function Client:GetPrivateMsgData()
	if not self.tbPrivateMsg then
		local f = io.open(g_szUserPath .. "User/UserPrivateMsg.lua", "r");
		local szFileContent = "return {};";
		if f then
			szFileContent = f:read("*all");
			f:close();
		end

		self.tbTmpEnv = {};
		szFileContent = "setfenv(1, Client.tbTmpEnv); local fnLoad = function () " .. szFileContent .. " end tbPrivateMsg = fnLoad();";
		local fnFile = loadstring(szFileContent);
		if fnFile then
			fnFile();
		end

		self.tbPrivateMsg = self.tbTmpEnv.tbPrivateMsg or {};
	end

	local nId = Player:GetMyRoleId(); --使用时肯定已经登录了
	if self.tbPrivateMsg.nVersion ~= Client.nVersionPrivateMsg then
		self.tbPrivateMsg.nVersion = Client.nVersionPrivateMsg;
		Client:CheckInValidPrivateSaveMsg()
	end
	self.tbPrivateMsg[nId] = self.tbPrivateMsg[nId] or {};
	return self.tbPrivateMsg[nId];
end

function Client:CheckInValidPrivateSaveMsg(  )
	local nCurServerId = math.floor(Player:GetMyRoleId() / 2^20)
	for dwRoleId,v in pairs(self.tbPrivateMsg) do
		if type(dwRoleId) == "number" then
			local nRoleServerId = math.floor(dwRoleId / 2^20)
			if nRoleServerId ~= nCurServerId then
				self.tbPrivateMsg[dwRoleId] = nil;
			end
		end
	end
end

function Client:SavePrivateMsgData()
	local szValue = Lib:Val2Str(self.tbPrivateMsg);
	local file = io.open(g_szUserPath .. "User/UserPrivateMsg.lua", "w+");
	if not file then
		Log("Client:SavePrivateMsgData ERR ?? file is nil !!" .. g_szUserPath);
		return;
	end

	file:write("return" .. szValue);
	file:close();
end

function Client:GetDirFileData(szFileName)
	self.tbFileDirData = self.tbFileDirData or {};
	if not self.tbFileDirData[szFileName] then
		local f = io.open(string.format("%sUser/%s.lua", g_szUserPath, szFileName), "r");
		local szFileContent = "return {};";
		if f then
			szFileContent = f:read("*all");
			f:close();
		end

		self.tbTmpEnv = {};
		szFileContent = "setfenv(1, Client.tbTmpEnv); local fnLoad = function () " .. szFileContent .. " end tbTmpData = fnLoad();";
		local fnFile = loadstring(szFileContent);
		if fnFile then
			fnFile();
		end

		self.tbFileDirData[szFileName] = self.tbTmpEnv.tbTmpData or {};
	end

	return self.tbFileDirData[szFileName];
end

function Client:SaveDirFileData(szFileName)
	local szValue = Lib:Val2Str(self.tbFileDirData[szFileName]);
	local file = io.open(string.format("%sUser/%s.lua", g_szUserPath, szFileName), "w+");
	if not file then
		Log("Client:SaveDirFileData ERR ?? file is nil !!" .. szFileName);
		return;
	end

	file:write("return" .. szValue);
	file:close();
end

function Client:GetLocalFileContent(szFileName, szDir)
	local szFileContent = nil;
	local f = io.open((szDir or g_szUserPath) .. szFileName, "r");
	if not f then
		return szFileContent;
	end

	szFileContent = f:read("*all");
	f:close();
	return szFileContent;
end

-- 客户端启动回调
function Client:OnStartup()
	-- 调整 Lua 内存回收频率，更快的回收内存
	collectgarbage("setpause", 80);

	Lib:CallBack({Client.CheckMemorySetting, Client});

	SdkMgr.SetReportIsOpen(Sdk.OPEN_REPORT_DATA);
	Fuben:Load();
	ValueItem:Init();
	OutputTable:AnalyseFubenOutput();
	Task:Setup();
	TeamBattle:Init();
	CardPicker:Init();

	local tbJuanZhouItem = Item:GetClass("JuanZhou");
	Lib:CallBack({tbJuanZhouItem.LoadSetting, tbJuanZhouItem});

	Lib:CallBack({Client.ClearLog, Client});
	Lib:CallBack({Client.ClearImgCache, Client});
	Lib:CallBack({Sdk.OnClientStart, Sdk});
	Lib:CallBack({Map.InitSetting, Map});

	--Lib:CallBack({Sdk.JXServiceConnectFix, Sdk})

	----local file = io.open(g_szUserPath .. "User/LoadResAsync.ddd", "r");
	----if ANDROID and file then
	----	file:close();
	----	Ui.ResourceLoader.s_LuaApi_LoadResAsync = true;
	----else
	----	Ui.ResourceLoader.s_LuaApi_LoadResAsync = false;
	----end
	--Log("[ResourceLoader] set Ui.ResourceLoader.s_LuaApi_LoadResAsync ", Ui.ResourceLoader.s_LuaApi_LoadResAsync and "true" or "false");
end

function Client:CheckMemorySetting()
	local main = luanet.import_type("Main");
	if main.m_nTotalMem <= 1024 then
		Ui.UiManager.m_nMaxUiCount = 0;
		main.m_bLowMemType = true;
		Map.nUnLoadResourceTime = 15;
		self.bLowMemryDevice = true;

		Timer:Register(1, function ()
			Ui.Effect.m_nUseLowEffectFPS = 100;
		end);
	else
		Ui.UiManager.m_nMaxUiCount = 10;  --临时降低Ui数量
	end
end

function Client:IsLowMemryDevice()
	return self.bLowMemryDevice or false;
end

function Client:GetLogPathDescending()	--获取降序(日期从近到远)的日志路径
	local szLogDir = g_szUserPath.."logs/Client"
	if IOS then
		szLogDir = Ui.ToolFunction.LibarayPath.."/logs/Client"
	end
	local tbAllFiles = {}
	local tbRes = TraverseDir(szLogDir)
	for _, szPath in pairs(tbRes) do
		local szFileName = string.match(szPath, "logs/Client/([0-9_]*).log$")
		if szFileName then
			table.insert(tbAllFiles, szPath)
		end
	end
	table.sort(tbAllFiles, function (a, b)
							   return a > b
						   end
		)
	return tbAllFiles
end

function Client:GetLogCreationTime(szLogPath)
	local szFileName = string.match(szLogPath, "logs/Client/([0-9_]*).log$");
	local nTime = 0
	if szFileName then
		local nYear, nMonth, nDay, nHour, nMin, nSec = string.match(szFileName, "^(%d+)_(%d+)_(%d+)_(%d+)_(%d+)_(%d+)$");
		if nYear then
			nYear = tonumber(nYear);
			nMonth = tonumber(nMonth);
			nDay = tonumber(nDay);
			nHour = tonumber(nHour);
			nMin = tonumber(nMin);
			nSec = tonumber(nSec);
			nTime = Lib:GetSecFromNowData({year=nYear, month=nMonth, day=nDay, hour=nHour, min=nMin, sec=nSec});
		end
	end
	return nTime
end

function Client:CombineLatestLog()
	local tbAllFiles = Client:GetLogPathDescending()
	local nNow = GetTime()
	local nIndex = 0
	for nIdx, szLogPath in ipairs(tbAllFiles) do
		if Client:GetLogCreationTime(szLogPath) < nNow then
			nIndex = nIdx
			break
		end
	end
	if nIndex > 0 then
		local szFirstLogPath = tbAllFiles[nIndex]		--一定存在
		local szSecondLogPath = tbAllFiles[nIndex + 1]	--可能不存在
		if not szSecondLogPath then	--不存在就不合并了，直接用第一个日志
			return szFirstLogPath
		end

		local file = io.open(szFirstLogPath, "r")
		local szFirstContent = file:read("*all")
		file:close()

		file = io.open(szSecondLogPath, "r")
		local szSecondContent = file:read("*all")
		file:close()

		local szCombineLogPath = g_szUserPath.."logs/Client/Report.log"
		if IOS then
			szCombineLogPath = Ui.ToolFunction.LibarayPath.."/logs/Client/Report.log"
		end
		file = io.open(szCombineLogPath, "w")
		file:write(szSecondContent)
		file:write("==================================================================\n\r")
		file:write(szFirstContent)
		file:close()
		return szCombineLogPath
	end
	return
end

function Client:ClearLog()
	local tbAllFiles = Client:GetLogPathDescending()
	for i = 21, #tbAllFiles do
		os.remove(tbAllFiles[i]);
		Log("[Client] RemoveLog ", tbAllFiles[i]);
	end
end

function Client:ClearImgCache()
	local nNextClearTime = Client:GetFlag("NextClearImgCache") or 0;
	local nNow = GetTime();
	if nNow < nNextClearTime then
		return;
	end
	Client:SetFlag("NextClearImgCache", nNow + 24 * 3600);

	local szLogDir =  Ui.ToolFunction.LibarayPath .. "/ImgCache";
	local tbRes = TraverseDir(szLogDir);
	for _, szPath in pairs(tbRes) do
		os.remove(szPath);
	end
	Log("[Client] ClearImgCache");
end

-- 每秒一次
function Client:Activate()
	Operation:DealDelayOffline();
	Lib:CallBack({Operation.DealAutoBQAction, Operation});
	Lib:CallBack({WeatherMgr.Activity, WeatherMgr});
	Lib:CallBack({AddictionTip.OnClientActivate, AddictionTip});
	return true;
end

function Client:SetPlayerDir(nDir, nMapTemplateId)
	if not nDir or not nMapTemplateId then
		return;
	end

	me.nSetDirMapTId = nMapTemplateId;
	me.nSetDirDir = nDir;

	self:DoSetPlayerDir();
end

function Client:DoSetPlayerDir(bConfirm)
	if not me.nSetDirMapTId or not me.nSetDirDir then
		return;
	end

	if me.nMapTemplateId ~= me.nSetDirMapTId then
		return;
	end

	if not bConfirm then
		Timer:Register(5, self.DoSetPlayerDir, self, true);
		return;
	end

	me.GetNpc().SetDir(me.nSetDirDir);
	me.nSetDirMapTId = nil;
end

function Client:DoCommand(szCmd)
	Log("GmCmd["..tostring(me and me.szName).."]:", szCmd);

	local fnCmd, szMsg	= loadstring(szCmd, "[GmCmd]");
	if (not fnCmd) then
		Log("Do GmCmd failed:"..szMsg);
	else
		return fnCmd();
	end
end

function Client:GetCurServerInfo()
	local tbLastLoginfo = Client:GetUserInfo("Login", -1)
	local tbMyLogin = tbLastLoginfo[GetAccountName()];

	return SERVER_ID or "", tbMyLogin.szName
end

function Client:GetItem()
	local nItemId = nil
	local nItemCount = nil

	local fnItemCountCallBack = function (szInput)
		nItemCount = tonumber(szInput);
		if not nItemCount then
			return 1
		end
		GMCommand(string.format("me.AddItem(%d,%d)",nItemId, nItemCount))
	end

	local fnItemIdCallBack = function (szInput)
		nItemId = tonumber(szInput);
		if not nItemId then
			return 1
		end
		Ui:OpenWindow("InputBox", "输入道具数量", fnItemCountCallBack)
		return 1
	end
	Ui:OpenWindow("InputBox", "输入道具ID", fnItemIdCallBack)
end

function Client:GMGetImitity()
	local fnImitityCallBack = function (szInput)
		local nImitity = tonumber(szInput);
		if not nImitity then
			return 1
		end
		GMCommand(string.format("GM:ForceTeamSetImitity(%d)", nImitity))
	end
	Ui:OpenWindow("InputBox", "输入亲密度", fnImitityCallBack)
end

function Client:GMGetLoverId(szCmd)
	local fnLoverIdCallBack = function (szInput)
		local dwID = tonumber(szInput);
		if not dwID then
			return 1
		end
		GMCommand(string.format(szCmd or "GM:MakeMarry(%d)", dwID))
	end
	Ui:OpenWindow("InputBox", "输入对方ID", fnLoverIdCallBack)
end

function Client:ReportQQGM()
	local nReportType = nil
	local szReportData = nil

	local fnItemCountCallBack = function (szInput)
		szReportData = szInput;
		if not szReportData or szReportData == "" then
			return 1
		end
		GMCommand(string.format("AssistClient:ReportQQScore(me, %d, %s, 0, 1)", nReportType, szReportData))
	end

	local fnItemIdCallBack = function (szInput)
		nReportType = tonumber(szInput);
		if not nReportType then
			return 1
		end
		Ui:OpenWindow("InputBox", "输入报告数据", fnItemCountCallBack)
		return 1
	end
	Ui:OpenWindow("InputBox", "输入报告类型ID", fnItemIdCallBack)
end

--IOS关闭某些入口
function Client:IsCloseIOSEntry()
	if IOS then
		return Client:GetFlag("CloseIOSEntry")
	end

	return false
end

function Client:IsTssEnable()
	if not Sdk:IsMsdk() then
		return false;
	end

	return true
end

function Client:IsOnlyUseIPv4()
	return false
end

function Client:IsUseAsyncDNS()
	return Client:GetFlag("UseAsyncDNS") and true or false;
end

function Client:SetUseAsyncDNS(bEnable)
	Client:SetFlag("UseAsyncDNS", bEnable);
	ReloadNetConfig();
end

function Client:GMGetTimeFrameLevel()
	local fnCall = function (szInput)
		local nLevel = tonumber(szInput);
		if not nLevel then
			return 1
		end
		GMCommand(string.format("GM:ShowOpenLevelTime(%d)", nLevel))
	end
	Ui:OpenWindow("InputBox", "输入开放等级", fnCall)
end
