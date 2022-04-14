-- 
-- @Author: LaoY
-- @Date:   2018-07-30 21:05:53
-- 

--print = function(...)
	--log(...)
--end
		
DebugManager = DebugManager or class("DebugManager",BaseManager)
local DebugManager = DebugManager

DebugManager.DebugTypeList = {
	All = BitState.State.All,
	Yz 	= BitState.State[1],
	Chk = BitState.State[2],
	Jl = BitState.State[3],
	DL = BitState.State[4],
	YHY = BitState.State[5],
	Test = BitState.State[12],
}

DebugManager.CurDebugType = DebugManager.DebugTypeList.Yz

function DebugManager:ctor()
	DebugManager.Instance = self
	self.bitstate = BitState()
	self.bitstate:Add(DebugManager.CurDebugType)

	if AppConfig.Debug then
		gameMgr:ShowLogFile()
	end
	
	self.error_list = {}
	self:Init()
end

function DebugManager.GetInstance()
	if DebugManager.Instance == nil then
		DebugManager()
	end
	return DebugManager.Instance
end

function DebugManager:Init()
	-- old_print = print

	-- local i = 0

	print = function(...)
		print2(...)
	end

	if not AppConfig.printLog then
		print = function()
		end
		print2 = function()
		end
	end

	local function printNil()

	end
	local function dumpNil()

	end

	 --Yzprint = printNil
	 --Yzdump = dumpNil
	 --Chkprint = printNil
	 --Chkdump = dumpNil

	for k,v in pairs(DebugManager.DebugTypeList) do
		if k ~= "All" then
			local print_func_name = string.format("%sprint",k)
			local dump_func_name = string.format("%sdump",k)
			if self.bitstate:Contain(v) then
				_G[print_func_name] = print
				_G[dump_func_name] = dump
			else
				_G[print_func_name] = printNil
				_G[dump_func_name] = dumpNil
			end
		end
	end
	-- Yzprint('--LaoY DebugManager.lua,line 62-- data=',data)
	-- Chkprint("111111111111111111111111111111")
end

function DebugManager:AddErrorList(errorMessage)
	
end

function DebugManager.SendErrorList(condition, trace)
	if AppConfig.writeLog then
		DebugManager:GetInstance().DebugLog(condition)
		if not DebugManager.GetInstance().error_list[condition] then
			DebugManager.GetInstance().error_list[condition] = 1
			LoginController.GetInstance():RequestSendErrorMessage(condition .. "\n" .. trace .."\n[errr_ref]" .. AppConst.null_map_str)
		end
		if condition and (condition:find("Object reference not set to an instance of an object") or 
			condition:find("attempt to index speed on a nil value") or 
			condition:find("attempt to index gameObject on a nil value")) then
			DebugManager:GetInstance():GC()
			DebugManager:GetInstance().DebugLog("[ref]error ref object \n" .. AppConst.null_map_str)
			-- Yzprint('--LaoY DebugManager.lua,line 103--',AppConfig.DebugRef)
			-- DebugManager:GetInstance():DebugObjectRef()
		else
			DebugManager:GetInstance().DebugLog(string.format("[error_log]%s\n",condition or "",trace or ""))
		end
	end
end


local filter_list = {}
function DebugManager:DebugFilter()
	local str = resMgr:GetFilterFileNamePath()
	local t = json.decode(str)
	
	local info_list = {}
	local size = 0
	local len = #t
	local map = {}
	for i=1,len do
		local info = t[i]
		size = size + info.size
		map[info.abName] = info.size
	end
	local index = #filter_list+1
	local scene_id = SceneManager:GetInstance():GetSceneId()

	local str = string.format("<color=#e08225><color=#00be00>%s time</color> Subcontracting resource size: %02f M,%s time output, scene ID is: %s, client startup time: %02f</color>",ChineseNumber(index),size/1024,index,scene_id,Time.time)
	-- log(str)
	filter_list[index] = {size = size,index = index,scene_id = scene_id,time = Time.time,str = str , map = map}

	-- Notify.ShowText(string.format("<color=#e08225>当前分包资源大小：%02f M</color>",size/1024))
end

function DebugManager:DebugFilterAll()
	self:DebugFilter()
	local len = #filter_list
	log('<color=#e08225>--DebugManager:DebugFilterAll--</color>')
	log(string.format("<color=#e08225>======输出分包%s次========</color>",len))
	for i=1,len do
		local t = filter_list[i]
		log(t.str)

		if i == len and len > 1 then
			local last_map = filter_list[i-1].map
			local map = filter_list[i].map

			log(string.format("<color=#e08225><color=#00be00>第%s次比第%s次</color>新加资源的个数为：<color=#e63232>%s</color></color>",ChineseNumber(i),ChineseNumber(i-1),table.nums(map)-table.nums(last_map)))
			for abName,size in pairs(map) do
				if not last_map[abName] then
					local color = size > 1024 and "e63232" or "e08225"
					log(string.format("<color=#e08225>新加资源：<color=#e63232>%s</color>，大小为：<color=#%s>%s kb</color></color>",abName,color,size))
				end
			end
		end
	end

	Notify.ShowText("Successfully printed")
end

function DebugManager:CheckCls(cls)
	collectgarbage("collect")
	local tab = obj_v_map[cls]
	print('--LaoY DebugManager.lua,line 141--',tab,tab and #tab)
end

function DebugManager:CheckGlobal(object)
	local global_list = LuaMemManager:GetInstance().global_list
	for k,file_name in pairs(global_list) do
		local cls = _G[file_name]
		if obj_v_map[cls] then
			for __,list in pairs(obj_v_map[cls]) do
				for id,tab in pairs(list) do
					self:CheckClsGlobal(object,tab,1,file_name)
				end
			end
		end
	end
end

function DebugManager:CheckGlobal(object,tab,level,name)
	tab = tab or _G
	level = level or 1
	name = name or "_G"
	if level > 10 then
		return
	end
	if level == 1 then
		collectgarbage("collect")
	end
	for k,v in pairs(tab) do
		-- local k_name = name ..".".. tostring(k)
		-- local v_name = name ..".".. tostring(v)
		if k == object then
			DebugLog(string.format("----K---table:%s,level:%s",name,level))
		end

		if v == object then
			DebugLog(string.format("----v---table:%s,level:%s",name,level))
		end

		-- if type(k) == "table" then
		-- 	self:CheckGlobal(object,k,level + 1,k_name)
		-- end

		if type(v) == "table" and (level ~= 1 or obj_v_map[v]) and (k ~= "_class_type" and k ~= "__index") then
			local v_name = name ..".".. tostring(k)
			self:CheckGlobal(object,v,level + 1,v_name)
		end
	end
end

function DebugManager:OutPutRef()
	Util.ClearMemory()
	AppConst.DebugObject = true
end

function DebugManager.IsProtoDebug(proto_id)
	for k,v in pairs(AppConfig.debugProto) do
		if v == proto_id then
			return true
		end
	end
	return false
end

function DebugManager.LoadLog(log)
	if not AppConfig.writeLog or not log then
		return
	end
	YFileUtil.WriteLoadLog("[lua]" .. log)
end

function DebugManager.ProtoLog(proto_id,isSend,log)
	-- if not AppConfig.writeLog or not DebugManager.IsProtoDebug(proto_id) then
	if not AppConfig.writeLog then
		return
	end

	local str = string.format("%s[%s]%s  %s time = %s",isSend and "----" or "++++",proto_id,isSend and "Send" or "Accept",log or "",Time.time)
	YFileUtil.WriteNetLog(str)

	DebugLog(str)
end

function DebugManager.DebugLog(log)
	if not AppConfig.writeLog or not log then
		return
	end
	YFileUtil.WriteDebugLog("[lua]" .. log)
end

function DebugManager:GC()
	if LuaMemManager and LuaMemManager:GetInstance() then
        LuaMemManager:GetInstance():GC()
    else
        Util.ClearMemory()
        -- collectgarbage("collect")
    end

    -- DebugManager:LogMem()
end

function DebugManager:LogMem()
	DebugManager:GC()
	LuaFramework.DebugUtil.logMen()
end

function DebugManager:DebugObjectRef()
	if not AppConfig.DebugRef then
		return
	end

	local null_object_str = AppConst.null_map_str
	print('--LaoY DebugManager.lua,line 274--',AppConst.null_map_str)
	do
		return

	end
	-- local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	-- local time_data = TimeManager:GetTimeDate(os.time())
	-- local time_str = string.format("%s-%s-%s-%02d-%02d-%02d",time_data.year, time_data.month, time_data.day, time_data.hour, time_data.min, time_data.sec)
	-- if not role_id then
	-- 	return
	-- end
	-- local file_name = "a1_" .. role_id .. "_".. time_str .. ".lua"
	-- local path = AvatarManager.local_file_path .. file_name
	-- if io.writefile(path, content) then
	-- 	if PlatformManager:GetInstance():IsMobile() then
	-- 		OssManager:GetInstance():AsyncPutObject(path,file_name)
	-- 	end
	-- end
end