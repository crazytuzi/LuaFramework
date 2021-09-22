--------------------------------------------------------------------------------
-- 游戏内验证登录的一套流程整理：
-- 1.连接Socket  成功|失败
-- 2.刷新用户登录时间及获取ticket 成功|失败
-- 3.验证用户ticket 成功|失败

-- 0.选区服
-- 1.setIpAndPort()
-- 2.doConnect()
-- 3.setLoginUrl()     中控notifyLogin接口 需要serverid，用户loginKey
-- 4.verifyLoginData()
--------------------------------------------------------------------------------
local GameLogin=class("GameLogin")

function GameLogin:ctor ()
	self.errorCallBackFun=nil     	-- 出现异常时的回调方法
	self.progressCallBackFun=nil  	-- 进度提示回调方法
	self.successCallBackFun=nil   	-- 登录验证成功回调方法
	self._ip=nil                  	-- 服务器访问ip
	self._port=nil                	-- 服务器访问端口
	self._url=nil                 	-- 服务器登录验证地址
	self._connected=false 			--
	self._servers=nil             	-- 当前游戏的所有区服信息
	self._centerUrl=nil           	-- 中控后台地址

	self:init()
end
-- 初始化
function GameLogin:init ()
	cc.EventProxy.new(GameSocket)
		:addEventListener(GameMessageCode.EVENT_CONNECT_ON, handler(self, self.onConnected))
		:addEventListener(GameMessageCode.EVENT_AUTHENTICATE, handler(self, self.onAuthenticate))

  	self:setServers()
  	self:setCenterUrl()
end
-- 销毁
function GameLogin:destroy ()
	self._ip=nil
	self._port=nil
	self._url=nil
	self._loginkey=nil
	self._centerUrl=nil
end

function GameLogin:setServers()
  	local servers=nil
  	-- 注释的这部分是SDK部分将区服写入到本地文件 然后lua再读取
	local path=cc.FileUtils:getInstance():getWritablePath().."serverList.json"
	if cc.FileUtils:getInstance():isFileExist(path) then
		local serverStr=cc.FileUtils:getInstance():getStringFromFile(path)
		local jsonStr=string.gsub(serverStr,"\\","")
		servers=GameUtilSenior.decode(jsonStr) or {}
	end
  	if not servers then
	    if device.platform=="windows" then
	      	servers=GAME_TEST_SERVERS
	    end
  	end
  	self._servers=servers
end
function GameLogin:setCenterUrl ()
  	if device.platform=="android" or device.platform=="ios" then
    	self._centerUrl=GameCCBridge.getCenterUrl() --中控服务器返回的区服
  	end
end

-- 获取默认推荐服
function GameLogin:getRecommendServer ()
	local recommendId = nil
	if #self._servers > 0 then   --设置最新的服为推荐服
		for i = 1,#self._servers do
			if recommendId then
				if self._servers[i].serverId > self._servers[recommendId].serverId then
					recommendId = i
				end
			else
				recommendId = i
			end
		end
	end
  	return recommendId
end

function GameLogin:getServers ()
  	return  self._servers
end

-- 获取连接状态
function GameLogin:getConnecteState ()
  	return self._connected
end
-- 设置IP跟PORT
function GameLogin:setIpAndPort (ip,port)
	self._ip=ip
	self._port=port
end
-- 设置登录url信息
function GameLogin:setLoginUrl (url)
  	self._url=url
end

function GameLogin:getServerById (sid)
	local info=nil
	local servers=self._servers
	for i=1,#servers do
		if tonumber(servers[i].id)==tonumber(sid) then
			info=servers[i]
			return info
		end
	end
	return nil
end

function GameLogin:getServerByIndex (index)
	local info=nil
	local servers=self._servers
	if #servers>=tonumber(index) then
		info=servers[index]
		return info
	end
	return nil
end

-- 显示当前登录进度
function GameLogin:showProgressMsg (code,msg)
  	if self.progressCallBackFun then
    	self.progressCallBackFun(code,msg)
  	end
end
-- 弹出错误提示
function GameLogin:showErrorMsg (code,msg)
  	if self.errorCallBackFun then
    	self.errorCallBackFun(code,msg)
  	end
end
-- 获取服信息
-- 设置IP跟PROT信息
function GameLogin:selectServer (serverId,errorFun,proFun,successFun)
	print("------selectServer.serverId = "..serverId)
	if errorFun and type(errorFun)=="function" then
		self.errorCallBackFun=errorFun
	end
	if proFun and type(proFun)=="function" then
		self.progressCallBackFun=proFun
	end
	if successFun and type(successFun)=="function" then
		self.successCallBackFun=successFun
	end

	local info=self:getServerById(serverId);
	if info then
		if tonumber(info.status)==1 or tonumber(info.status)==2 or tonumber(info.status)==3 or tonumber(info.status)==4 then
			local serverName=info['name']
			local socket=string.split(info.socket,":")
			local ip=socket[1]
			local port=socket[2]
			GameBaseLogic.zoneId = info.serverId
			GameBaseLogic.zoneName = info.name
			GameBaseLogic.serverIP = ip
			GameBaseLogic.serverPort = port
			GameBaseLogic.giftUrl = info.giftUrl
			GameBaseLogic.renameUrl = info.renameUrl
			GameBaseLogic.loginUrl=info.loginCallback

			if device.platform=="windows" then
				if not GameBaseLogic.gameKey then GameBaseLogic.gameKey="t1" end
				local params="?sign="..GameBaseLogic.gameKey.."&uname="..GameBaseLogic.gameKey.."&ip=127.0.0.1&platformid=0&deviceId=0"
				url=GameBaseLogic.loginUrl..params
			elseif device.platform=="android" or device.platform=="ios" then
				url=self._centerUrl.."notifyLogin?loginKey="..GameBaseLogic.loginKey.."&serverId="..info.id.."&platformid="..GameCCBridge:getPlatformId().."&deviceId="..GameCCBridge.getDeviceId()
			end
			print("----------url = "..url);
			self._url = url
			self:setIpAndPort(ip,port)

			GameSetting.Data["LastServerId"] = info.id
			GameSetting.save()
			self:doConnect()
		else
			if tonumber(info.status)==0 then
				self:showErrorMsg(-1,"服务器维护中,请稍后进入")
				return
			end
			if tonumber(info.status)==6 then
				self:showErrorMsg(-2,"尚未到开区时间,请稍后进入。开服时间为: "..info.openDateTime)
				return
			end
		end
	else
		self:showErrorMsg(-3,"未找到该服信息,请重新选服")
	end
end

function GameLogin:doConnect ()
	self:showProgressMsg(1,"连接服务器...")
	if not self._ip or not self._port then
		self:showErrorMsg(-1,"无法连接服务器")
		return
	end
	print("---------ip = "..self._ip.."     port = "..self._port)
	GameSocket:connect(self._ip,self._port)
end

function GameLogin:onConnected(event)
  	self._connected=true
  	if GameCCBridge then
		GameCCBridge.doSubmitExtendData(GameCCBridge.TYPE_SELECT_SERVER)
	end
  	self:verifyLoginData()
end

function GameLogin:onConnectedFailed (event)
  	self._connected=false
  	self:showErrorMsg(-1,"连接服务器失败,请检查您的网络状态")
end

function GameLogin:verifyLoginData ()
  	self:showProgressMsg(1,"获取用户...")
  	local message,code=nil
  	local http=cc.XMLHttpRequest:new()
  	http.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
  	http:open("GET", self._url.."&tempostime="..os.time())
  	local function notifyCallBack()
    	local status=http.status
    	if status==200 then
      		local response=http.response
      		if response=="" or not response then
	        	message="服务器无响应"
	        	code=-100
	        	self:showErrorMsg(code,message)
      		else
      			print(response)
	        	local json=string.gsub(GameUtilBase.unicode_to_utf8(response),"\\","")
	        	json=GameUtilSenior.decode(json)
	        	if json.error_code=="1" then
	        		self:showProgressMsg(1,"验证身份...")
	          		GameBaseLogic.gameKey=json.username
	          		GameBaseLogic.gameTicket=json.ticket
	          		GameSocket:Authenticate(101,json.ticket,0,11)
	          		print("---------------GameSocket:Authenticate---->ticket = "..json.ticket)
        		elseif json.error_code=="-15" then
		          	message="没有进入改区服的权限,请联系我们添加白名单"
		          	self:showErrorMsg(-15,message)
	        	else
		          	message="登录验证失败"
		          	code=json.error_code
		          	self:showErrorMsg(code,message)
	        	end
      		end
    	else
			message="连接失败"
			code=-99
			self:showErrorMsg(code,message)
	    end
  	end
  	http:registerScriptHandler(notifyCallBack)
  	http:send()
end

function GameLogin:onAuthenticate( event )
	local code=101
	local msg="验证失败 系统错误"
	code=tonumber(event.result)
	if code==100 then
		msg="认证成功"
		if self.successCallBackFun then
			self.successCallBackFun()
		end
	else
		if code==101 then
			msg="验证失败 系统错误"
		end
		if code==102 then
			msg="验证失败 会话编号错误"
		end
		if code==103 then
			msg="验证失败 请求信息错误"
		end
		if code==104 then
			msg="验证失败 认证类型错误"
		end
		if code==105 then
			msg="验证失败 会话过期"
		end
		if code==1 then
			msg="TICKET验证错误"
		end
		self:showErrorMsg(code,msg)
	end
end


return GameLogin
