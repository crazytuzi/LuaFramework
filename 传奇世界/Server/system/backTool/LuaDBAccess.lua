--[[LuaDBAccess.lua

Exported API:

Example:

--]]

require "base.class"
require "event.EventFactory"
require "event.EventManager"

local logger = Logger.getLogger()

local spId={
	UpdateTask              = "sp_UpdateTask",
	AddTask                 = "sp_AddTask",
	AddTaskHis				= "sp_AddTask_his",
	AddHistoryActivity		= "sp_AddActivity_his",
	RemoveTask				= "sp_RemoveTask",
}

local DoActionQueue = {}
local DBContext = {}
local CallbackContext ={}
local evtManger= EventManager.getInstance();
local evtFct=EventFactory.getInstance();

--------------------------------------------------------------------------------

LuaDBAccess = {}
--------------------------------------------------------------------------------

function testDBA()
	local params={{}}
	params[1]["roleID"]      = 222
	params[1]["roleName"]     = "s"
	params[1]["costTime"]     = 1232
	params[1]["ingotVal"]     = 88
	params[1]["optionType"]     = "d"
	params[1]["optionVal"]     = "f"
	params[1]["serverID"]     = 323	

	params[1]["spName"]      = 'sp_WriteIngotConsume'
	params[1]["dataBase"]    = 5
	params[1]["sort"]        = "roleID,roleName,costTime,ingotVal,optionType,optionVal,serverID"
	local operationID = apiEntry.exeSP(params, true)
end

function doFuncByDBID(v)
	local doAction
	local map={
	[spId.UpdateExpendableAttri]="materialID",
	[spId.UpdateEquip]="equipID",
	[spId.UpdateEquipAttri]="equipID",
	[spId.UpdatePack]="itemID",
	[spId.UpdateStorage]="itemID",
	}
	if not v or not v['params'] or not v['params'][1]
		or not v['function'] or not map[v['function'] ]
			or not v['undbInstance']
	then
		return false
	end
	v['params'][1][map[v['function'] ] ]=v['undbInstance']:getSerialID()
	if (v['params'][1][map[v['function'] ] ]~=-1) then
		doAction=true
		v['function']=0
		return doAction
	end
end

--写入物品实例的SerialID
function LuaDBAccess.onExeSP(operationID,recordResult,result)
	local recordList={}
	if result==0 then
		for i,v in pairs(recordResult) do
			local t=tolua.cast(v, "CLuaArray")
			local record=CLuaArray:getResult(t)
			recordList[i]=record
		end
	end

	recordList._result = result
	recordList._operationID = operationID
	

	if CallbackContext then
		if CallbackContext[operationID] then
			CallbackContext[operationID](recordList)
			CallbackContext[operationID]=nil
		end
	end


	if recordList[1] then
		if DBContext and DBContext[operationID] then
			for i,v in pairs(DBContext[operationID]) do
				if recordList[1][1] and recordList[1][1][getDBIDNameByObjName(i)] then
					v:setSerialID(recordList[1][1][getDBIDNameByObjName(i)])
					logger:debug(i.." runtimeId %d "..getDBIDNameByObjName(i).." %d",v:getSerialID(),recordList[1][1][getDBIDNameByObjName(i)])
				end
				DBContext[operationID]=nil
			end

		end
		if (table.size(DoActionQueue)>0) then
			local doAction =false
			for i,v in pairs(DoActionQueue) do
				if v['function']==spId.UpdateAddiAttri then
					for k,m in pairs(v['params']) do
						m['addiId']=v['undbInstance']['addProp']:getSerialID()
					end

					if v['undbInstance'][v["objname"]] then
						v['params'][1]['nvalue']=v['undbInstance'][v['objname']]:getSerialID()
					end
					if v['params'][1]['nvalue']~=-1 and v['params'][1]['addiId']~=-1 then
					--	logger:debug(v["objname"].." %d addPro %d",v['params'][1]['nvalue'],v['params'][1]['addiId'])
						doAction=true
						v['function']=0
					end
				else
					doAction = doFuncByDBID(v)
				end
				if  doAction then
					--logger:debug("call sp functionId %s  DoActionQueue size %d ",toString(v['params']),table.size(DoActionQueue))
					local operationID = apiEntry.exeSP(v['params'])
					DBContext[operationID]={[v['objname']]=v['obj']}
					DoActionQueue[i]=nil
					doAction =false
				end
			end
		end
		recordList=nil
	end
end

function LuaDBAccess.callDBSQL(params,callback)
	local operationID = apiEntry.exeSP(params)

	if type(callback)=="function" then
		CallbackContext[operationID]=callback
	end
	return operationID
end


function LuaDBAccess.callDB(params,callback,level)
	local operationID = apiEntry.exeSP(params,callback==nil,level)
	if type(callback)=="function" then
		CallbackContext[operationID]=callback
	end
	return operationID
end

--进一步封装上面的LuaDBAccess.callDB,不需要关系params的组装形式
--为保证参数顺序,inputParams格式为{{argName1,argValue1},{argName2,argValue2},...}
function LuaDBAccess.callSP(spName,inputParams,callback,level)
	local params={{}}
	params[1]["spName"]=spName
	params[1]["dataBase"]=3
	local sorts=""
	for _,arg in pairs(inputParams or table.empty) do
		params[1][arg[1]]=arg[2]
		sorts=sorts..arg[1]..","
	end
	if (string.len(sorts)>2) then
		sorts=string.sub(sorts,1,string.len(sorts)-1)
		params[1]["sort"]=sorts
	end
	return LuaDBAccess.callDB(params,callback,level)
end
