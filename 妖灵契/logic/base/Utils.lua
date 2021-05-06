module(..., package.seeall)
g_Platform = UnityEngine.Application.platform
g_UniqueID = 0
g_FrameDelta = 1/30
g_SceneName = nil
g_DeviceUID = nil
g_GameRoot = nil
g_IsPlayingCG = false
g_HiderLayer = UnityEngine.LayerMask.NameToLayer("Hide")
g_ResumeLayers = {}
g_PrintFuncs = {
	["table.print"] = table.print,
	["printc"] = printc,
	["print"] = print,
	["printtrace"] = printtrace,
}
g_IsLog = true

--递增不重复id
function GetUniqueID()
	g_UniqueID = g_UniqueID  + 1
	return g_UniqueID
end

function GetGameRoot()
	if not g_GameRoot then
		g_GameRoot = UnityEngine.GameObject.Find("GameRoot/UIRoot")
	end
	return g_GameRoot
end

function GetDeviceUID()
	if not g_DeviceUID then
		g_DeviceUID = UnityEngine.PlayerPrefs.GetString("DeviceUID")
		if g_DeviceUID == "" then
			local id = C_api.Utils.GetDeviceUID()
			UnityEngine.PlayerPrefs.SetString("DeviceUID", id)
			g_DeviceUID = id
		end
	end
	return g_DeviceUID
end

function TimerAssert(sType, cbfunc, delta, delay)
	assert(cbfunc and delta and delay, sType.." args error!!!")
	assert(delta >= 0, sType.." delta must >= 0")
	assert(delay >= 0, sType.." delay must >= 0")
end

function AddTimer(cbfunc, delta, delay)
	TimerAssert("AddTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, true, false)
end

function AddScaledTimer(cbfunc, delta, delay)
	TimerAssert("AddScaledTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, false, false)
end

function AddLateTimer(cbfunc, delta, delay)
	TimerAssert("AddLateTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, true, true)
end

function AddScaledLateTimer(cbfunc, delta, delay)
	TimerAssert("AddScaledLateTimer", cbfunc, delta, delay)
	return g_TimerCtrl:AddTimer(cbfunc, delta, delay, false, true)
end

function DelTimer(timerid)
	assert(timerid ~= nil, "timerid is nil")
	g_TimerCtrl:DelTimer(timerid)
end

function IsNil(o)
	if not o then
		return true
	end
	if type(o) == "userdata" then
		return tostring(o) == "null"
	elseif o.m_GameObject then
		return o:IsDestroy()
	end
	return false
end

function IsExist(t)
	return not IsNil(t)
end

function IsPC()
	return IsWin() or IsEditor()
end

function IsEditor()
	return g_IsEditor
end

function IsWin()
	return g_Platform == 2 or g_Platform == 7
end

function IsIOS()
	return g_Platform == 8
end

function IsAndroid()
	return g_Platform == 11
end

function RandomInt(min, max)
	if (min == max) then
		return min
	else
		return UnityEngine.Random.Range(min, max + 1)
	end
end

function QuitGame(bNow, bLogOut)
	local bSdkQuit = false
	if g_LoginCtrl:IsSdkLogin() then
		if bLogOut then
			g_SdkCtrl:Logout()
		end
		bSdkQuit = g_SdkCtrl:ExitGame()
	end
	if not bSdkQuit then
		local function quit() 
			if g_LoginCtrl:HasLoginRole() then
				netlogin.C2GSLogoutByOneKey()
			end
			UnityEngine.Application.Quit()
		end
		if bNow then
			quit()
		else
			local windowConfirmInfo = {
				msg				= "是否退出游戏？",
				title			= "退出游戏",
				okCallback = quit,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		end
	end
end

function GetActiveSceneName()
	if not g_SceneName then
		g_SceneName = UnityEngine.SceneManager.GetActiveScene().name
	end
	return g_SceneName
end

function NewGuid()
	return C_api.Utils.NewGuid()
end

function GetUrl(url, args)
	if next(args) then
		url = url.."?"
		for k, v in pairs(args) do
			url = url..tostring(k).."="..tostring(v).."&"
		end
	end
	return url
end

function OpenUrl(sUrl)
	UnityEngine.Application.OpenURL(sUrl)
end

function SetWindowTitle(title)
	C_api.Utils.SetWindowTitle(title)
end

function GetChilds(tranform)
	local list = {}
	for i=0, tranform.childCount-1 do
		local child = tranform:GetChild(i)
		table.insert(list, child)
	end
	return list
end

function ArrayToList(array)
	local t = {}
	for i=0, array.Length-1 do
		table.insert(t, array[i])
	end
	return t
end

function ListToArray(list, objtype)
	return tolua.toarray(list, objtype)
end

function GetMaterials(gameObjects)
	return C_api.Utils.GetMaterials(gameObjects)
end

function IsHideObject(obj)
	return g_ResumeLayers[obj:GetInstanceID()] ~= nil
end

function HideObject(obj)
	if not g_ResumeLayers[obj:GetInstanceID()] then
		g_ResumeLayers[obj:GetInstanceID()] = obj:GetLayer()
		obj:SetLayerDeep(g_HiderLayer)
	end
end

function ShowObject(obj)
	local layer = g_ResumeLayers[obj:GetInstanceID()]
	if layer then
		obj:SetLayerDeep(layer)
		g_ResumeLayers[obj:GetInstanceID()] = nil
	end
end

function ScreenShoot(oCam, w, h)
	local texture = UnityEngine.RenderTexture.New(w, h, 16)
	oCam:SetTargetTexture(texture)
	oCam:Render()
	oCam:SetTargetTexture(nil)
	return texture
end

function CreateQRCodeTex(sUrl, iWidth, iHeight, ErrorCorrectionType)
	ErrorCorrectionType = ErrorCorrectionType or enum.ErrorCorrectionType.H
	iHeight = iHeight or iWidth
	local tex = C_api.AntaresQRCodeUtil.Encode(sUrl, iWidth, iHeight, ErrorCorrectionType)
	return tex
end

function HexToColor(sHex)
	local r = tonumber("0x"..string.sub(sHex, 1, 2)) / 255
	local g = tonumber("0x"..string.sub(sHex, 3, 4)) / 255
	local b = tonumber("0x"..string.sub(sHex, 5, 6)) / 255
	local a = tonumber("0x"..string.sub(sHex, 7, 8)) / 255
	return Color.New(r,g,b,a)
end

function IsDevDevice() -- 特殊设备
	local mac = Utils.GetMac()
	if mac == "58:44:98:ee:38:5b" then --测试机
		return true
	-- elseif mac == "88:6a:b1:19:39:62" then
	-- 	return true
	-- elseif mac == "FD:B2:15:26:71:4B" then --模拟器
	-- 	return true
	end
	return false
end

function IsDevUser()
return false
end

function UpdateLogLevel()
	local logflag = IOTools.GetClientData("logflag") or 0
	if logflag == 1 or IsEditor() or IOTools.IsExist(IOTools.GetPersistentDataPath("/test/n1log")) then
		_G.table.print = g_PrintFuncs["table.print"]
		if not CGmConsoleView:GetView() then
			_G.printc = g_PrintFuncs["printc"]
			_G.print = g_PrintFuncs["print"]
		end
		_G.printtrace = g_PrintFuncs["printtrace"]
		C_api.Utils.SetLogLevel(2)
		g_IsLog = true
	else
		local nilfunc = function() end
		_G.table.print = nilfunc
		_G.printc = nilfunc
		_G.print = nilfunc
		_G.printtrace = nilfunc
		C_api.Utils.SetLogLevel(1)
		g_IsLog = false
	end
end

function LoadDataPackage()
	C_api.Utils.LoadDataPackage()
	for k, v in pairs (data) do
		local name = "logic.data."..k
		package.loaded[name] = nil
		data[k] = nil
	end
end

function MD5HashFile(sPath)
	if IOTools.IsExist(sPath) then
		return C_api.MD5Hashing.HashFile(sPath)
	end
end

function MD5HashString(sourceString)
	return C_api.MD5Hashing.HashString(sourceString)
end

function ShowLoading(sText, iTime)
	local oView = CLoadingView:GetView()
	if oView then
		sText = sText or ""
		oView:SetTips(sText)
		oView:SetTextureShow(true)
		if iTime then
			oView:DelayCall(iTime, "SetTextureShow", false)
		end
	end
end

function HideLoading()
	local oView = CLoadingView:GetView()
	if oView then
		oView:SetTextureShow(false)
	end
end

function GetLocalIP()
	return UnityEngine.Network.player.ipAddress
end

function GetMac()
	return C_api.PlatformAPI.getLocalMacAddress()
end

function GetDeviceName()
	return UnityEngine.SystemInfo.deviceName
end

function GetDeviceModel()
	return UnityEngine.SystemInfo.deviceModel
end

function IsScreen1024()
	-- local iAspect = UnityEngine.Screen.width/UnityEngine.Screen.height
	-- return iAspect <= (1024/768)
	return false
end

function IsInEditorMode()
	local editorList = {"editorMagic", "editorBuff", "editorAnim", "editorCamera", "editorLineup", "editorTable"}
	local sScveneName = Utils.GetActiveSceneName()
	for i = 1,#editorList do
		if editorList[i] == sScveneName then
			return true
		end
	end
	return false
end

function IsTypeOf(gameObject, classtype)
	local s = tostring(gameObject)
	return string.find(s, tostring(classtype)) ~= nil
end

function GetCenterServerUrl()
	local csUrl = C_api.Utils.GetCenterServerUrl()
	local url = ""
	if (csUrl == nil) or (csUrl == "") then
		if main.g_AppType  == "bussiness" then
			url = define.Url.Bussiness
		else
			url = define.Url.Release
		end
	else
		url = csUrl
	end
	return url
end

function GetPrintStr(...)
	local args = {}
	local len = select("#", ...)
	for i=1, len do
		local v = select(i, ...)
		table.insert(args, tostring(v))
	end
	local s = table.concat(args, " ")
	return s
end

function UpdateCode(code)
	if code and string.len(code) > 0 then
		printc("更新代码:", string.len(code))
		print(code)
		if Utils.IsEditor() then
			if not IOTools.GetClientData("banupdatecode") then
				local mt = getmetatable(_G)
				setmetatable(_G, {})
				f = loadstring(code)
				if f then
					f()
				else
					printerror("更新代码错误")
				end
				setmetatable(_G, mt)
			end
		else
			local f = loadstring(code)
			if f then
				xxpcall(f)
			else
				printerror("更新代码错误")
			end
		end
	end
end

function DebugCall(f, s)
	local oWatch = g_TimeCtrl:StartWatch()
	local sRet= f() or ""
	local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
	if iElapsedMS > 0 then
		local str = sRet..s.."  "..tostring(iElapsedMS/1000)
		printerror(str)
	end
	-- g_NotifyCtrl:FloatMsg(str)
end

function SetShaderLight(stype)
	local tLight = define.Shadow[stype].light
	UnityEngine.Shader.SetGlobalVector("_WorldShadowDir", Vector4.New(tLight[1], tLight[2], tLight[3], 0))
end

--统计每帧调用次数
local g_TestCnt = 0
local g_LastFrame = 0
function TestCnt(i)
	if UnityEngine.Time.frameCount ~= g_LastFrame then
		if (not i) or (g_TestCnt >= i) then
			printerror("每帧调用次数:", g_TestCnt)
		end
		g_TestCnt = 0
	end 
	g_LastFrame = UnityEngine.Time.frameCount
	g_TestCnt = g_TestCnt + 1
end

function PlayCG(cb)
	local path = Utils.IsPC() and "Movies/cg" or "Movies/cg.mp4"
	local function f()
		g_AudioCtrl:ExitSlience()
		Utils.AddTimer(function() 
			g_IsPlayingCG = false
			end, 0,0)
		if cb then cb() end
	end
	g_AudioCtrl:SetSlience()
	C_api.CGPlayer.PlayCG(path, f)
	g_IsPlayingCG = true
end

function IsPlayingCG(cb)
	return g_IsPlayingCG
end

function GetGameType()
	--用于测试
	if Utils.IsEditor() or main.g_SdkLogin == 0 then
		local sTestType = IOTools.GetClientData("TestGameType") or "ylq"
		return sTestType
	else
		local sType = C_api.SPSDK.GetGameType()
		if not sType or sType == "" then
			sType = "nil"
		end
		return sType
	end
end

function IsYunYingOpen()
	return (g_SdkCtrl:GetChannelId() == "kaopu" and not g_LoginCtrl:IsShenheServer()) or (Utils.IsEditor())
end