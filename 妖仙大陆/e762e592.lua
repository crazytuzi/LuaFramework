

local _M = {}
_M.__index = _M
local loader         = require 'Zeus.Logic.loader'
GlobalHooks.Drama = GlobalHooks.Drama or {}
local DramaNode = GlobalHooks.Drama.DramaInstance
local Default_File_List = 
{
	F1 = true,
	F2 = true,
	F4 = true,
	F5 = true,
	F6 = true,
	F7 = true,
	F8 = true,
	F9 = true,
	F10 = true,
	F11 = true,
	F12 = true,
}

local isPlayer = true

local FreeGuideLvLimit = 40

local File_List = GlobalHooks.Drama.File_List

GlobalHooks.Drama.HasRun_List = GlobalHooks.Drama.HasRun_List or {}
local HasRun_List = GlobalHooks.Drama.HasRun_List

local is_debug = false
local is_debug_node = false
local LOG_LEVEL = 0

if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsPlayer or 
	 UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsEditor then
	is_debug = true
	
else
	is_debug = false
	LOG_LEVEL = 0
end




local find_path = {'content','effect','quest_event','test','map_event','.'}
local reload
local error_string = ''
local restore_fun
local dramaInstanceEnv


local function error_msgbox(err,fun)
	if not err or error_string == err then 
		return 
	end
	print('drama error:',err)
	if not is_debug then
		return
	end
	error_string = err
	GlobalHooks.Drama.Stop()
	err = '<![CDATA['..err..']]>'
	local cb = (fun and LuaHelper.Action(fun)) or nil
	GameAlertManager.Instance:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, err,'OK',nil,cb)
end

local function err_func(err)
	print(err)
	GameAlertManager.Instance:ShowNotify(err or '')
end

local function create_tf_func(fun)
	local count = 0
	return function (var,...)
		if var then
			count = count + 1
		elseif count > 0 then
			count = count - 1
		end
		fun(var,count,...)
	end
end

local function create_tf_env(script_name)
	local ret = {}
	
	ret.ShowSideTool = create_tf_func(function (var,count,act)
		if count == 1 and var then
			DramaUIManage.Instance:ShowSideTool(act)
		elseif count == 0 and not var then
			DramaUIManage.Instance:CloseSideTool()
		end
	end)

	ret.HideAllHud = create_tf_func(function (var,count)
		
		if count == 1 and var then
            HudManagerU.Instance:HideAllHud(var);
			
		elseif count == 0 and not var then
            HudManagerU.Instance:HideAllHud(var);
			
		end		
	end)

	ret.HideAllMenu = create_tf_func(function (var,count)
		
		if count == 1 and var then
			MenuMgrU.Instance:HideMenu(var)
		elseif count == 0 and not var then
			MenuMgrU.Instance:HideMenu(var)
		end		
	end) 

	ret.HideSceneCamera = create_tf_func(function (var,count)
		if count == 1 and var then
			local obj = GameObject.Find('/MapNode/CameraMove')
			if obj then
				local al = obj:GetComponent(typeof(UnityEngine.AudioListener))
				if not al then
					al = obj:AddComponent(typeof(UnityEngine.AudioListener))
				end
				al.enabled = true
			end
			GameSceneMgr.Instance:SetSceneCameraActive(false)
		elseif count == 0 and not var then
			GameSceneMgr.Instance:SetSceneCameraActive(true)
			local obj = GameObject.Find('/MapNode/CameraMove')
			if obj then
				local al = obj:GetComponent(typeof(UnityEngine.AudioListener))
				if al then
					al.enabled = false
				end
			end
		end		
	end)

	ret.SetTelescope = create_tf_func(function (var,count)
		if count == 1 and var then
			DramaHelper.SetTelescope(var)
		elseif count == 0 and not var then
			DramaHelper.SetTelescope(var)
		end			
	end)

	ret.SetBlockTouch = create_tf_func(function (var,count)
		if count == 1 and var then
			DramaHelper.SetBlockTouch(var)
		elseif count == 0 and not var then
			DramaHelper.SetBlockTouch(var)
		end
	end)

	ret.HideUGUI = create_tf_func(function (var,count)
		if count == 1 and var then
			DramaHelper.HideUGUI(var)
		elseif count == 0 and not var then
			DramaHelper.HideUGUI(var)
		end
	end)

	ret.HideUGUITextLabel =  create_tf_func(function (var,count)
		if count == 1 and var then
			DramaHelper.HideUGUITextLabel(var)
		elseif count == 0 and not var then
			DramaHelper.HideUGUITextLabel(var)
		end
	end)

	ret.HideUGUIHpBar =  create_tf_func(function (var,count)
		if count == 1 and var then
			DramaHelper.HideAllHPBar(var)
		elseif count == 0 and not var then
			DramaHelper.HideAllHPBar(var)
		end
	end)

	ret.HideMFUI  =  create_tf_func(function (var,count)
		print('HideMFUI', var, count)
		if count == 1 and var then
			XmdsUISystem.Instance.Visible = false
		elseif count == 0 and not var then
			XmdsUISystem.Instance.Visible = true
		end
	end)
	return ret
end

local function IsGuideScript(script_name)
	if script_name then
		if string.sub(script_name,1,5) == 'quest' or 
			string.sub(script_name,1,5) == 'guide' then
			return true
		end
	end

	return false
end

function CheckGuideEnvironment(script_name)
    local isNormal = PublicConst.SceneType.Normal == PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
    if not isNormal then
    	if string.sub(script_name,1,5) == 'quest' or
    		
    		
    		script_name == "guide_daoyou" or
    		script_name == "guide_guild" then
    	    return false
    	end
    end

    local closed = DataMgr.Instance.UserData:GetClientConfig('guide_closed')
    if closed and IsGuideScript(script_name) then
    	return false
    end

    return true
end

function GlobalHooks.Drama.StartCacheGuide()
    local script_name = DataMgr.Instance.UserData:GetCacheGuideClientConfig()
    if string.len(script_name) > 0 then
    	GlobalHooks.Drama.Start(script_name, true)
    end
end

function GlobalHooks.Drama.Start(script_name,...)
	
    if isPlayer == false and string.sub(script_name,1,2) == 'yy' then
        
        DramaHelper.SendDramaEndToBattle(script_name)
        return 
    end
	if not CheckGuideEnvironment(script_name) then
		return
	end
	if not DramaNode then
		reload()
	end
	
	if script_name  then
		if Default_File_List[script_name] or File_List[script_name] then
		 	local ok, ret = xpcall(DramaNode.CreateScript, err_func, script_name, ...)
		  if ok and ret then
		  	
		  	if not restore_fun then
		  		restore_fun = create_tf_env()
		  	end
		  	ret:SetAttribute('__env',restore_fun)
		  	ret:SetRootEvent()
		  	ret:SetLogLevel(LOG_LEVEL)
		  	ret:AddInvalidCB(function ()
		  		EventManager.Fire('Drama.Stop.'..script_name, {})
		  		EventManager.Fire('Drama.Stop',{script_name=script_name})
		  	end)
			end
		end
	elseif is_debug then
		reload()
		local otherEnv = {Start = GlobalHooks.Drama.Start,Stop = GlobalHooks.Drama.Stop}
		local ok, sandbox = loader.loadAndGetEnv("Drama.lua", true, otherEnv)
		if not ok then
			error_msgbox(sandbox)
		else
		 	xpcall(sandbox.Test,err_func)
		end
	end
end 

function GlobalHooks.Drama.Stop(script_name)
	if not DramaNode then
		return
	end
	if script_name then
		local id = DramaNode.FindScriptIDByName(script_name)
		if id then
			DramaNode.StopScript(id)
		end
	else
		DramaNode.StopScript()
	end

	DramaHelper.ShowGuideHand(nil,false)
end

function GlobalHooks.Drama.IsScriptExist(script_name)
	return DramaNode.FindScriptIDByName(script_name) ~= nil
end


local function AddSubScrpt(script_name,...)
	local ok, ret = xpcall(DramaNode.CreateScript, err_func, script_name, ...)
  if ok and ret then
  	ret:SetLogLevel(LOG_LEVEL)
  	ret:SetAttribute('__env',restore_fun)
  	local parent = DramaNode.GetRunningEvent()
		return parent:AddEvent(ret)
	end
end

local function SaveHasRun()
	local script_name = DramaNode.GetRunningEvent():GetRootEvent():GetName()
	HasRun_List[script_name] = true
	
end

local function GetScriptTypeByName(script_name)
	return File_List[script_name] or Default_File_List[script_name]
end

local function updateSanbox(delta)
	if not DramaNode then
		return
	end
	xpcall(DramaNode.Update,err_func,delta)

end


local function LoadInstance(script_name)
	local errMsg 
	for _,v in ipairs(find_path) do
		local ok, ret = loader.loadAndGetEnv(v..'/'..script_name..".lua", true,dramaInstanceEnv)
		if ok then
			print('LoadInstance ok')
			return ret
		elseif ret and ret ~= '' then
			errMsg = ret
			break
		end
	end
	
	if errMsg then
		error(errMsg)
	end	
end


local function RegisterApi()
	if is_debug then	
		if is_debug_node then
			if DramaNode then
				DramaNode.FroceStopScrpt()
			end
			GlobalHooks.Drama.DramaInstance = nil
			package.loaded['Zeus.Logic.drama.DramaNode']  = nil
		end

		package.loaded['Zeus.Logic.drama.DramaGlobalApi'] = nil
		package.loaded['Zeus.Logic.drama.DramaWorldApi']  = nil
		package.loaded['Zeus.Logic.drama.DramaCameraApi'] = nil
		package.loaded['Zeus.Logic.drama.DramaUIApi']     = nil
		package.loaded['Zeus.Logic.drama.DramaQuestApi']  = nil
		package.loaded['Zeus.Logic.drama.DramaSceneApi']  = nil
		package.loaded['Zeus.Logic.drama.DramaNetApi']  = nil
		package.loaded['Zeus.Logic.drama.DramaRectTransformApi']  = nil
		package.loaded['design.file_list'] = nil
	end
	local ok, ret = pcall(require, 'design.file_list')
	if ok then
		GlobalHooks.Drama.File_List = ret
	else
		GlobalHooks.Drama.File_List = {}
	end
	File_List = GlobalHooks.Drama.File_List
	GlobalHooks.Drama.DramaInstance =  GlobalHooks.Drama.DramaInstance or require 'Zeus.Logic.drama.DramaNode'
	DramaNode = GlobalHooks.Drama.DramaInstance
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaGlobalApi')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaWorldApi','World')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaCameraApi','Camera')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaUIApi','UI')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaQuestApi','Quest')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaSceneApi','Scene')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaNetApi','Net')
	DramaNode.RegisterApi(require'Zeus.Logic.drama.DramaRectTransformApi','RectTransform')
	DramaNode.RegisterLoadFunction(LoadInstance)
end

local function load_drama()
	print('reload drama')
	RegisterApi()
	dramaInstanceEnv = 
	{
		SaveHasRun = SaveHasRun,
		StartScript = GlobalHooks.Drama.Start,
		StopScript = GlobalHooks.Drama.Stop,
		AddSubScrpt = AddSubScrpt,
		GetScriptTypeByName = GetScriptTypeByName,
		GetAllScriptNames = DramaNode.GetAllScriptNames,
		IsScriptExist = DramaNode.IsScriptExist,
		FindScriptIDByName = DramaNode.FindScriptIDByName,
		ImageAnchor = ImageAnchor,
		TextAnchor = TextAnchor,
		Vector2 = Vector2,
		Vector3 = Vector3,
		UITAG = GlobalHooks.UITAG,
		IsUnityEditor = UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsEditor,
	}
	local helper_ok, helper = loader.loadAndGetEnv("ApiHelper.lua", true, dramaInstanceEnv)
	if not helper_ok then
		print('load drama helper failed')
		error_msgbox(helper)
	else
		print('load drama helper success')
		dramaInstanceEnv.Helper = helper.CreateHelper(DramaNode.GetApi())
	end
end

local LUA_OBSERVER_KEY = 520
local first_notify = false
local spec_branch = 
{
	quest_4205 = true,
	quest_4207 = true,
	quest_4209 = true
}

local notify_table = 
{
	Notify = function (quest_id,quest_mgr)
		local closed = DataMgr.Instance.UserData:GetClientConfig('guide_closed')
		local area_init_finish = DramaHelper.IsAreaChangeFinish()
		if closed or (not first_notify and not area_init_finish) then
			return 
		end
		local script_name = 'quest_'..quest_id
		local q = quest_mgr:GetQuest(quest_id)
		if XmdsNetManage.Instance.IsNet then 			
			local newState = not first_notify
			
			if not newState or q.PreState ~= q.State then
				GlobalHooks.Drama.Stop(script_name)
				
				if GetScriptTypeByName(script_name) == 1 or 
					GameSceneMgr.Instance.IsFirstEnter or 
					spec_branch[script_name] or 
					not HasRun_List[script_name] or 
					q.PreState ~= q.State then						
						GlobalHooks.Drama.Start(script_name,quest_id,q and GameUtil.TryEnumToInt(q.State) or nil, newState)
				end			
			end
		end
	end,
}

local function StartActivityEffect(eventname,params)
	if params.id == "Activity" then
		local data = GlobalHooks.DB.Find('Schedule',tonumber(params.ActivityId))
		GlobalHooks.Drama.Start('activity_effect',data.SchName,tonumber(params.ActivityId))
    end
end

local function StartFreeGuide( ... )
	local guideClosed = DataMgr.Instance.UserData:GetClientConfig('guide_closed')
	local isAutoFight = DataMgr.Instance.UserData.AutoFight
	local isSeeking = DataMgr.Instance.UserData:IsSeekState()
	local lvLimit = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL) < FreeGuideLvLimit
	local isNormal = PublicConst.SceneType.Normal == PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
	
	if not guideClosed and not isAutoFight and not isSeeking and lvLimit and isNormal then
		GlobalHooks.Drama.Start('guide_freeGuide')
	end
end

local function OnInit(...)
	DramaUIManage.Instance:ResetFreeCount()

	local closed = DataMgr.Instance.UserData:GetClientConfig('guide_closed')
	if XmdsNetManage.Instance.IsNet and not closed then 
		local userdata = DataMgr.Instance.UserData
		local mapId = userdata:GetAttribute(UserData.NotiFyStatus.MAPID)
		GlobalHooks.Drama.Start('map_'..mapId)
		
		
		

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	end
	first_notify = true
	if not DramaNode then
		reload()
	end
	DataMgr.Instance.QuestManager:NotifyAll()
	first_notify = false
end

local function FireEventProxy(...)
	
	if DramaNode then
		DramaNode.SendMessage(...)
	end
end

local function InitFreeGuide()
	
    
    
		  
		  
		  
	   
    
end

local function initial()
	InitFreeGuide()

	AddUpdateEvent('event.drama.update',updateSanbox)
	EventManager.Subscribe('Event.Scene.ChangeFinish',OnInit)
	EventManager.Subscribe('Event.guide.StartFreeGuide',StartFreeGuide)
	EventManager.Subscribe('Event.Activity.AddEffect',StartActivityEffect)
	EventManager.SubscribeGlobalCallBack(FireEventProxy)
	DataMgr.Instance.QuestManager:AttachLuaObserver(LUA_OBSERVER_KEY,notify_table)

end


local function fin()
	RemoveUpdateEvent('event.drama.update')
	DataMgr.Instance.QuestManager:DetachLuaObserver(LUA_OBSERVER_KEY)
end

reload = load_drama
_M.initial = initial
_M.fin = fin

return _M
