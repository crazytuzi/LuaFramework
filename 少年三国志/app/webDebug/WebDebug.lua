
local WebDebug = class("WebDebug")

--模块列表
local modeList = {"wush",
		"equipment",
		"dress",
		}

--用例结构
-- local wush = { --模块名
--     WushChallenge = { --协议名
--         {msg = {index=33333,},repeatTimes = 1, ret = 0,}, --msg=参数,repeatTimes=重复次数,ret=期望的返回值
--      }
-- }

local TIMEOUT = 5 --超时时间
local LogRowMax = 44 --一行最多显示的字数

function WebDebug:ctor( )
	self._isDebuging = false
	self._sendingMsgList = {}
	self._errorMsgList = {}
	self._receiveTotalCount = 0
	self._totalCount = 0
	self._endCallBack = nil
	self._stepCallBack = nil
	self._curMsgIdCount = 1
	self._msgIdList = {}
	self._timeCount = 0
	self._totalTimeCount = 0
	self._checkType = 1 -- 1为正常检测，2为超时检测
end

function WebDebug:isDebuging( )
	return self._isDebuging
end

--获取模块列表
function WebDebug:getModelList( )
	return modeList
end

--设置在每次发新的协议时的回调
function WebDebug:setStepCallBack(callBack )
	self._stepCallBack = callBack
end

function WebDebug:clearData( )
	self._sendingMsgList = {}
	self._errorMsgList = {}
	self._receiveTotalCount = 0
	self._totalCount = 0
	self._curMsgIdCount = 1
	self._msgIdList = {}
	self._timeCount = 0
	self._totalTimeCount = 0
end

--协议返回
function WebDebug:debug(msg_id,ret )
	if not self._isDebuging then
		return false
	end

	print("debug",msg_id,ret)
	local key = string.gsub(msg_id, "cs.S2C_", "")  
	local list = self._sendingMsgList[key]
	if not list then
		return false
	end
	local data = list[list.receiveCount]
	if data and data.sendData.repeatTimes > 1 and #data.eRet < data.sendData.repeatTimes then
		self._receiveTotalCount = self._receiveTotalCount + 1
		table.insert(data.eRet,#data.eRet+1,ret)
		if #data.eRet == data.sendData.repeatTimes then
			data.receiveTime = self._totalTimeCount
			if self._checkType == 2 then
				self:_sendOne()
			end
		end	
	else
		list.receiveCount = list.receiveCount + 1
		self._receiveTotalCount = self._receiveTotalCount + 1
		data = list[list.receiveCount]
		if data.sendData.repeatTimes == 1 then
			data.receiveTime = self._totalTimeCount
			data.eRet = ret
			if self._checkType == 2 then
				self:_sendOne()
			end
		else
			data.eRet = {ret}
		end
	end
	if self._checkType == 1 then
		self:checkDebugEnd()
	end
	return true

end

function WebDebug:checkDebugEnd( )
	if self._receiveTotalCount >= self._totalCount then
		self:debugEnd()
		if self._sendTimer then
			GlobalFunc.removeTimer(self._sendTimer)
			self._sendTimer = nil
		end
	end
end

function WebDebug:debugEnd( )
	self._isDebuging = false
	if self._endCallBack then
		if self._checkType == 1 then
			self:analyzeResult()
		end
		self._endCallBack(self._errorMsgList)
	end
end

--对结果解析，如含有err=1则表明有协议没返回
function WebDebug:analyzeResult( )

	local lotA = function ( list,data )
		if type(data.eRet) == "table" then
			for i = 1 , #data.eRet do 
				if data.eRet[i] ~= data.sendData.ret[i] then
					table.insert(list,#list+1,data)
				end
			end
		else
			for i = 1 , #data.eRet do 
				if data.eRet[i] ~= data.sendData.ret then
					table.insert(list,#list+1,data)
				end
			end
		end
	end
	local analyzeList = function ( list )
		local errList = {}
		local hasErr = false
		for i = 1 , #list do 
			local v = list[i]
			if v.sendData.repeatTimes > 1 then
				if v.eRet and #v.eRet == v.sendData.repeatTimes then
					lotA(errList,v)
				else
					hasErr = true
				end
			else
				if v.eRet then
					if not (v.eRet == v.sendData.ret or (v.eRet~=1 and v.sendData.ret==0) ) then
						table.insert(errList,#errList+1,v)
					end
				else
					hasErr = true
				end
			end
		end
		if hasErr then
			errList = {}
			local baseDiff = 0
			for i = 1 , #list do 
				local v = list[i]
				dump(v)
				if not v.receiveTime then
					table.insert(errList,#errList+1,v)
				elseif v.receiveTime - v.sendTime > baseDiff + 1 then
					table.insert(errList,#errList+1,v)
					baseDiff = v.receiveTime - v.sendTime
				end
			end
			errList.err = 1
		end
		return errList
	end

	for k , v in pairs(self._sendingMsgList) do 
		local errList = analyzeList(v)
		if not GlobalFunc.table_is_empty(errList) then
			self._errorMsgList[k] = errList
		end
	end
end

--检查所有协议
function WebDebug:startDebugAll( callBack )
	if self._isDebuging then
		return
	end
	self._checkType = 1
	self._isDebuging = true
	self:clearData()
	for k , v in pairs(self:getModelList()) do 
		self:addDebug(v)
	end
	self._endCallBack = callBack
	self:sendStart()
end

--检查指定文件里的协议
function WebDebug:startDebug( name,callBack )
	if self._isDebuging then
		return
	end
	self._checkType = 1
	self._isDebuging = true
	self:clearData()
	self:addDebug(name)
	self._endCallBack = callBack
	self:sendStart()
end

--检查无返回的协议，返回在哪些协议哪些参数的时候无返回
function WebDebug:startTimeOutDebug( name,callBack )
	if self._isDebuging then
		return
	end
	self._checkType = 2
	self._isDebuging = true
	self:clearData()
	self:addDebug(name)
	self._endCallBack = callBack
	self:sendTimeOutStart()
end

function WebDebug:sendStart( )
	if not self._sendTimer then
		if self._stepCallBack then
			self._stepCallBack(self._msgIdList[self._curMsgIdCount])
		end
		self._sendTimer = GlobalFunc.addTimer(0.1, handler(self, self._onSendTimer))
	end
end

function WebDebug:sendTimeOutStart( )
	if not self._sendTimeOutTimer then
		self._sendTimeOutTimer = GlobalFunc.addTimer(1, handler(self, self._onSendTimeOutTimer))
	end
	self:_sendOne()
end

function WebDebug:_onSendTimeOutTimer( )
	self._timeCount = self._timeCount + 1 
	if self._timeCount >= TIMEOUT then
		local name = self._msgIdList[self._curMsgIdCount]
		if name then
			local list = self._sendingMsgList[name]
			local data = list[list.sendCount]
			if data then
				table.insert(self._errorMsgList,#self._errorMsgList+1 ,data)
			end
		end
		self:_sendOne()
	end
end

function WebDebug:_sendOne( )
	self._timeCount = 0
	local name = self._msgIdList[self._curMsgIdCount]
	if name then
		local list = self._sendingMsgList[name]
		list.sendCount = list.sendCount + 1
		local data = list[list.sendCount]
		if data then
			local repeatTimes = data.sendData.repeatTimes or 1
			for i = 1 , repeatTimes do
				self:send(data.id,data.sendData.msg)
			end
		else
			list.sendCount = list.sendCount - 1
			self._curMsgIdCount = self._curMsgIdCount + 1
			self:_sendOne()
		end
	else
		self:debugEnd()
		if self._sendTimeOutTimer then
			GlobalFunc.removeTimer(self._sendTimeOutTimer)
			self._sendTimeOutTimer = nil
		end
	end
end

function WebDebug:_onSendTimer( )
	local name = self._msgIdList[self._curMsgIdCount]
	if name then
		local list = self._sendingMsgList[name]
		list.sendCount = list.sendCount + 1
		local data = list[list.sendCount]
		if data then
			local repeatTimes = data.sendData.repeatTimes or 1
			for i = 1 , repeatTimes do
				self:send(data.id,data.sendData.msg)
			end
			data.sendTime = self._totalTimeCount
		else
			list.sendCount = list.sendCount - 1
			self._curMsgIdCount = self._curMsgIdCount + 1
			if self._stepCallBack then
				self._stepCallBack(self._msgIdList[self._curMsgIdCount])
			end
			self:_onSendTimer()
		end
	elseif self._timeCount < 20 then
		self._timeCount = self._timeCount + 1
	else
		self:debugEnd()
		if self._sendTimer then
			GlobalFunc.removeTimer(self._sendTimer)
			self._sendTimer = nil
		end
	end
	self._totalTimeCount = self._totalTimeCount + 1
end

function WebDebug:addDebug( name )
	local list = require("app.webDebug.settings."..name)
	for k1 , v1 in pairs(list) do
		local count = 0
		local netList = {}
		for k2 , v2 in pairs(v1) do 
			if not rawget(v2,"repeatTimes") then
				v2.repeatTimes = 1
			end
			table.insert(netList,#netList+1,{id=k1,sendData=v2})
			self._totalCount = self._totalCount + v2.repeatTimes
			count = count + v2.repeatTimes
		end
		netList.count = count
		netList.sendCount = 0
		netList.receiveCount = 0
		self._sendingMsgList[k1] = netList
		table.insert(self._msgIdList,#self._msgIdList+1,k1)
	end
end

--发送协议
function WebDebug:send(base_msg_id, msg )
	print("send",base_msg_id)
	dump(msg)
	local msgBuffer = protobuf.encode("cs.C2S_"..base_msg_id, msg) 
	G_NetworkManager:sendMsg(NetMsg_ID["ID_C2S_"..base_msg_id], msgBuffer)
end

--检查所有协议是否有加菊花，返回没有加菊花的协议
function WebDebug:checkJuHua(callBack )
	if self._isDebuging then
		return
	end
	self._isDebuging = true
	self:clearData()
	self._endCallBack = callBack

	local MonitorProtocal = require("app.network.MonitorProtocal")
	local checkAdded = function ( name )
		local sendId = NetMsg_ID["ID_C2S_"..name]
		local recId = NetMsg_ID["ID_S2C_"..name]
		if not MonitorProtocal[sendId] or MonitorProtocal[sendId] ~= recId then
			table.insert(self._errorMsgList,#self._errorMsgList+1 ,name)
		end
	end

	for k , v in pairs(self:getModelList()) do 
		local list = require("app.webDebug.settings."..v)
		for k1 , v1 in pairs(list) do
			checkAdded(k1)
		end
	end
	self:debugEnd()
end

--对协议检查的结果进行解析用于输出显示
function WebDebug.analyzeCheckResult( data )
	local res = {}
        	if data and not GlobalFunc.table_is_empty(data) then
	        	for k , v in pairs(data) do 
	        		table.insert(res,#res+1,"has error in "..k)
	        		if v.err and v.err == 1 then
	        			table.insert(res,#res+1,"有未返回的协议")
	        		else
	        			for k1 , v1 in pairs(v) do 
	        				local str = ""
	        				if v1.sendData.repeatTimes > 1 then
	        					str = str.."real ret="
	        					for kt1 , vt1 in pairs(v1.eRet) do
	        						str = str..vt1..","
	        					end
	        					str = str.."expect ret="
	        					if type(v1.eRet) == "table" then
		        					for kt2 , vt2 in pairs(v1.sendData.ret) do
		        						str = str..vt2..","
		        					end
		        				else
		        					str = str..v1.sendData.ret..","
		        				end
	        					str = str..";msg:{"
		        			else
		        				str = str.."real ret="..v1.eRet..",expect ret="..v1.sendData.ret..";msg:{"
		        			end
		        			for k2 , v2 in pairs(v1.sendData.msg) do 
		        				str = str..k2.."="..v2..","
		        			end
		        			str = str.."}"
	        				-- table.insert(res,#res+1,str)
	        				WebDebug.saftInsert(res,str)
	        			end
	        		end
	        	end
	else
		table.insert(res,#res+1,"nice! no err")
	end
	return res
end

--对无返回的协议检查的结果进行解析用于输出显示
function WebDebug.analyzeEmptyResult( data )
	local res = {}
        	if data and not GlobalFunc.table_is_empty(data) then
        		for k , v in pairs(data) do
        			local str = v.id
        			str = str.." no response when msg:{"
        			for k2 , v2 in pairs(v.sendData.msg) do 
        				str = str..k2.."="..v2..","
        			end
        			str = str.."},repeat:"..v.sendData.repeatTimes
        			-- table.insert(res,#res+1,str)
        			WebDebug.saftInsert(res,str)
        		end
        	else
        		table.insert(res,#res+1,"nice! no err")
        	end
	return res
end

--对检查加菊花的结果进行解析用于输出显示
function WebDebug.analyzeJuHuaResult( data )
	local res = {}
        	if data and not GlobalFunc.table_is_empty(data) then
        		for k , v in pairs(data) do
        			table.insert(res,#res+1,v.."没有加菊花")
        		end
        	else
        		table.insert(res,#res+1,"nice! no err")
        	end
	return res
end

--用于过长的文字换行插入
function WebDebug.saftInsert(list,str )
	if string.len(str) > LogRowMax then
		local str1 = string.sub(str,1,LogRowMax)
		local str2 = string.sub(str,LogRowMax+1,-1)
		table.insert(list,#list+1,str1)
		WebDebug.saftInsert(list,str2)
	else
		table.insert(list,#list+1,str)
	end
end

return WebDebug