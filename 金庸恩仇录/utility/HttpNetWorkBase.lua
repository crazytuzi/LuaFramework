require("game.MsgConst")
require("zlib")
require("utility.Func")

ENABLE_GAME_ZLIB = true

local REQ_NUM = 1

local HttpNetWorkBase = class("HttpNetWorkBase")

function HttpNetWorkBase:ctor()
	self.outStringData = nil
	self.cb = nil
	self.network = require("framework.network")
end

function HttpNetWorkBase:Request()
	printf("======== request")
	local function responseCB(data)
		local request = data.request
		local ok = data.name == "completed"
		if data.name == "failed" then
			if REQ_NUM > 0 then
				printf("-----  failed:%s", request:getErrorMessage())
				self:Request()
				REQ_NUM = REQ_NUM - 1
				return
			elseif self.errorcb then
				self.errorcb()
			end
		end
		if not ok then
			return
		end
		--dump("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
		--dump(request)
		--dump("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
		local Rescode = request:getResponseStatusCode()
		if Rescode ~= 200 then
			if self.errorcb then
				self.errorcb()
			end
			show_tip_label(common:getLanguageString("@wangluocw"))
			return
		end
		local j = require("framework.json")
		local zipRes = request:getResponseData()
		local res, eof, bin, bout
		if ENABLE_GAME_ZLIB == true then
			res, eof, bin, bout = zlib.inflate()(zipRes)
		else
			res = zipRes
		end
		if res ~= "" then
			codeJson = j.decode(res)
			if self.cb ~= nil then
				if GAME_DEBUG == true then
					printInfo("vvvvvvvvvvvvvvvvvvvvvvvvvvvvRequestvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
					dump(self.outStringData)
					--dump(codeJson, "", 10)
					printInfo("^^^^^^^^^^^^^^^^^^^^^^^^^^^^Request^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
				end
				self.cb(codeJson)
			end
		else
			codeJson = ""
		end
	end
	
	local serverURL = self.m_url or NewServerInfo.SERVER_URL
	if device.platform == "windows" or device.platform == "mac" then
		local localHost = CCUserDefault:sharedUserDefault():getStringForKey("ip")
		if localHost ~= nil and localHost ~= "" then
			serverURL = "http://" .. localHost
		end
	end
	local httpRequest = self.network.createHTTPRequest(responseCB, serverURL, "POST")
	httpRequest:setPOSTData(self.outStringData)
	httpRequest:start()
end


function HttpNetWorkBase:SendData(playerID, serverID, requestID, tableData, callback, errorcb, url)
	if url ~= nil then
		self.m_url = url
	end
	if self.network.isInternetConnectionAvailable() == false then
		if errorcb then
			errorcb()
		else
			show_tip_label(common:getLanguageString("@wangluocw"))
		end
		return
	end
	local msg = {}
	msg.Body = tableData
	msg.Body.v = getlocalversion()
	local jsonOutPut = require("framework.json")
	if msg ~= nil then
		if GAME_DEBUG == true then
			printInfo("vvvvvvvvvvvvvvvvvvvvvvvvvvvvSendvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
			dump(msg)
			printInfo("^^^^^^^^^^^^^^^^^^^^^^^^^^^^Send^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
		end
		--dump(msg)
		local outputStr = jsonOutPut.encode(msg)
		self.outStringData = outputStr
		if ENABLE_GAME_ZLIB == true then
			--local xxtea = crypto.encryptXXTEA(outputStr, "!@#asdfD_cdp[")
			--self.outStringData = crypto.encodeBase64(xxtea)
		end
	end
	self.cb = callback
	self.errorcb = errorcb
	REQ_NUM = 1
	self:Request()
	
end

function HttpNetWorkBase:disconnect()
	
end

return HttpNetWorkBase