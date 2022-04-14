--
-- @Author: LaoY
-- @Date:   2018-11-09 17:33:14
--[[
	@des	SDK接口

	/*lua==>java,os 方法*/
	@param1 func_name string 方法名字
	@param2 param 	  string 参数|json
	@return 返回值	  四种方法
			void
			string|json
			int
			bool

	/*java,os==>lua 方法*/
	@param1 params 	string 参数|json
--]]
SDKManager = SDKManager or {}

function SDKManager.CallBack(params)
	if PlatformManager:GetInstance():IsAndroid() then
		PlatformManager:GetInstance():Java2Lua(params)
	elseif PlatformManager:GetInstance():IsIos() then
		PlatformManager:GetInstance():Oc2Lua(params)
	else
		PlatformManager:GetInstance():Java2Lua(params)
	end
end

function SDKManager.CallVoid(func_name,param)
	if string.isempty(param) then
		sdkMgr:CallVoid(func_name)
	else
		sdkMgr:CallVoid(func_name,param)
	end
end

function SDKManager.CallString(func_name,param)
	if string.isempty(param) then
		return sdkMgr:CallString(func_name)
	else
		return sdkMgr:CallString(func_name,param)
	end
end

function SDKManager.CallInt(func_name,param)
	--if string.isempty(param) then
	if string.isempty(param) then
		return sdkMgr:CallInt(func_name)
	else
		return sdkMgr:CallInt(func_name,param)
	end
end

function SDKManager.CallBool(func_name,param)
	if string.isempty(param) then
		return sdkMgr:CallBool(func_name)
	else
		return sdkMgr:CallBool(func_name,param)
	end
end