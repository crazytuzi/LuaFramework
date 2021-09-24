protocolController={
	requestArr=nil, --请求队列
    -- isSending=false, --当前是否在发送请求状态
    delay=3, --请求延迟时间
    ctime=-1, --计数器
    addRequestListener=nil, --添加请求队列的监听器
}

function protocolController:init()
	local function addRequestMsg(event,data)
        if data then
        	local cmd=data.cmd
        	local params=data.params or {}
        	local callback=data.callback
        	if cmd then
        		self:addRequest(cmd,params,callback)
        	end
        end
    end
    self.addRequestListener=addRequestMsg
    eventDispatcher:addEventListener("protocolController.addRequest",addRequestMsg)

    if base.dnews==1 and dailyNewsVoApi then
    	local cmd,params,callback=dailyNewsVoApi:getDailyNewsRequest()
    	self:addRequest(cmd,params,callback)
    end

    if base.plane==1 then
    	local cmd,params,callback=planeVoApi:getPlaneRequest(function() goldMineVoApi:setRefreshGemsFlag(true) end)
    	self:addRequest(cmd,params,callback)
    end
end

function protocolController:addRequest(cmd,params,callback,func)
	if self.requestArr==nil then
		self.requestArr={}
	end
	if func then
		table.insert(self.requestArr,func)
	else
		table.insert(self.requestArr,{cmd,params,callback})
	end
end

function protocolController:removeRequest()
	if self.requestArr and self.requestArr[1] then
		table.remove(self.requestArr,1)
	end
end

function protocolController:realRequest()
	if self.requestArr and self.requestArr[1] then
		if type(self.requestArr[1])=="function" then
			self.requestArr[1]()
		else
			local cmd=self.requestArr[1][1]
			local params=self.requestArr[1][2]
			local callback=self.requestArr[1][3]
			-- print("cmd==",cmd)
			-- G_dayin(params)
			-- print(callback)
			socketHelper:request(cmd,params,callback)
		end
	end
end

function protocolController:tick()
	if self.requestArr and self.requestArr[1] then
		if self.ctime==-1 or (self.ctime>=self.delay) then
			self:realRequest()
			self:removeRequest()
			self.ctime=0
		else
			self.ctime=self.ctime+1
		end
	else
		self.ctime=-1
	end
end

function protocolController:clear()
	self.requestArr=nil
    self.ctime=-1
    eventDispatcher:removeEventListener("protocolController.addRequest",self.addRequestListener)
    self.addRequestListener=nil
	-- self.isSending=false
end