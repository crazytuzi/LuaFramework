--[[
	推送消息的管理类
]]
pushController=
{
	appID=nil,			--百度云推送的appID
	channelID=nil,		--百度云推送的channelID
	userID=nil,			--百度云推送服务的用户唯一ID
	moduleTb={},		--各个功能模块的推送开关, format: {0,1,1,0,...}
	--各个功能模块的名字, 与moduleTb一一对应
	moduleNameTb=
	{
		"hour",			--整点推送
		"building",		--建筑升级完成
		"technology",	--科技升级完成
		"troop",		--部队生产完成
		"item",			--道具生产完成
	},
	--兼容旧的推送系统
	oldModuleNameTb=
	{
		"gameSettings_jobDown",			--建造生产完成
		"gameSettings_energyFull",		--能量恢复满
		"gameSettings_pushWhole",		--整点推送
	},
	heartbeat=0,		--心跳tick
	serverUserID=nil,	--后台存储的用户ID
}

--用户登录成功之后调用, 推送服务初始化
function pushController:init()
	if(base.isBackendPushOpen==1)then
		for k,v in pairs(self.moduleNameTb) do
			local localData=CCUserDefault:sharedUserDefault():getStringForKey("pushService_"..v)
			if(localData==nil or localData=="")then
				localData=1
			end
			self.moduleTb[k]=tonumber(localData)
		end
		local tmpTb={}
		tmpTb["action"]="baiduPushBind"
		tmpTb["parms"]={}
		local cjson=G_Json.encode(tmpTb)
		G_accessCPlusFunction(cjson)
	end
end

--初始化成功的回调
function pushController:initSuccess(data)
	if(data.errorCode and data.errorCode==0)then
		self.appID=data.appid
		self.channelID=data.channelId
		self.userID=data.userId
		base:addNeedRefresh(self)
		if(self.serverUserID~=self.userID)then
			local function onRequestEnd(fn,data)
				base:checkServerData(data)
			end
			socketHelper:pushInit(tostring(self:getUserID()),onRequestEnd)
		end
	end
end

--开启某个模块的推送功能
--param type 模块在moduleTb中的index或者是在moduleNameTb中的value, 如果该参数是number那么就是moduleTb中的index, 如果是string那么就是在moduleNameTb中的value, 例如type是1或者building的时候都表示开启建筑推送功能
function pushController:openModule(module)
	local paramType=type(module)
	local name
	if(paramType=="number")then
		self.moduleTb[module]=1
		name=self.moduleNameTb[module]
	elseif(paramType=="string")then
		for k,v in pairs(self.moduleNameTb) do
			if(v==module)then
				self.moduleTb[k]=1
				name=v
				break
			end
		end
	end
	CCUserDefault:sharedUserDefault():setStringForKey("pushService_"..name,"1")
end

--关闭某个模块的推送功能
--param type 模块在moduleTb中的index或者是在moduleNameTb中的value, 如果该参数是number那么就是moduleTb中的index, 如果是string那么就是在moduleNameTb中的value, 例如type是1或者building的时候都表示关闭建筑推送功能
function pushController:closeModule(module)
	local paramType=type(module)
	local name
	if(paramType=="number")then
		self.moduleTb[module]=0
		name=self.moduleNameTb[module]
	elseif(paramType=="string")then
		for k,v in pairs(self.moduleNameTb) do
			if(v==module)then
				self.moduleTb[k]=0
				name=v
				break
			end
		end
	end
	CCUserDefault:sharedUserDefault():setStringForKey("pushService_"..name,"0")
end

--检查某个功能的推送是否打开
--param type 如果是旧版的话，就传oldModuleNameTb中的value，如果是新版的话，与openModule和closeModule相同
--return 推送功能是否开启, true or false
function pushController:checkModule(module)
	local version=self:checkPushServiceVersion()
	if(version==1)then
		local localData=CCUserDefault:sharedUserDefault():getIntegerForKey(module)
		if localData==0 then
			CCUserDefault:sharedUserDefault():setIntegerForKey(module,2)
			return true
		elseif(localData==1)then
			return false
		elseif(localData==2)then
			return true
		end
	else
		local paramType=type(module)
		local name
		local result
		if(paramType=="number")then
			result=self.moduleTb[module]
		elseif(paramType=="string")then
			for k,v in pairs(self.moduleNameTb) do
				if(v==module)then
					result=self.moduleTb[k]
					break
				end
			end
		end
		if(result==0)then
			return false
		else
			return true
		end
	end
	return true
end

function pushController:getAllPushModules()
	local version=self:checkPushServiceVersion()
	if(version==1)then
		return self.oldModuleNameTb
	elseif(version==2)then
		return self.moduleTb,self.moduleNameTb
	end
	return {}
end

--检查推送功能的版本
--return version 1表示最初版, IOS使用设备推送, Android无效; 2表示第二版, 使用百度云推送
function pushController:checkPushServiceVersion()
	if(base.isBackendPushOpen==1 and self.userID~=nil)then
		return 2
	else
		return 1
	end
end

function pushController:setServerUserID(id)
	self.serverUserID=id
end

function pushController:getUserID()
	return self.userID
end

function pushController:getModuleTb()
	return self.moduleTb
end

function pushController:getAppID()
	return self.appID
end

function pushController:getStaticAppID()
	if(statisticsHelper)then
		return statisticsHelper.appid
	else
		return 0
	end
end

function pushController:tick()
	if(self.heartbeat%300==0)then
		self:heartbeatTick()
	end
	self.heartbeat=self.heartbeat+1
end

function pushController:heartbeatTick()
	local staticAppID=self:getStaticAppID()
	if(staticAppID==0)then
		do return end
	end
	local hourOpen=self:checkModule("hour")
	local paramD
	if(hourOpen)then
		paramD=1
	else
		paramD=0
	end
	local paramP
	if(G_isIOS())then
		paramP="ios"
	else
		paramP="android"
	end
	local url=serverCfg.pushMessageUrl.."tank_push/setUserPushInfo.php?c=0&d="..paramD.."&ts="..base.serverTime.."&bindid="..self:getUserID().."&p="..paramP.."&lag="..G_CurLanguageName.."&regdate="..playerVoApi:getRegdate().."&zoneid="..base.curZoneID.."&appid="..staticAppID

	HttpRequestHelper:sendAsynHttpRequest(url,"")
	
end

function pushController:clear()
	base:removeFromNeedRefresh(self)
	self.appID=nil
	self.channelID=nil
	self.userID=nil
	self.moduleTb={}
end