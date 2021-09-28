 --
 --
 -- @authors shan 
 -- @date    2014-05-06 17:38:17
 -- @version 
 --


require ("game.MsgConst")
require ("zlib")

ENABLE_GAME_ZLIB = true

local HttpNetWorkBase = class("HttpNetWorkBase")


function HttpNetWorkBase:ctor()
	self.outStringData = nil
	self.cb = nil
	self.network = require("framework.network")
end


--[[--
	send to server
]]
local REQ_NUM = 1
function HttpNetWorkBase:Request()
    -- printf("======== request")

	local function responseCB( data )
	    local request = data["request"]
	    local ok = (data.name == "completed")

        if data.name == "failed" then
            if REQ_NUM > 0 then
                printf("-----  failed:%s", request:getErrorMessage())
                self:Request()
                REQ_NUM = REQ_NUM - 1
                return
            else
                if self.errorcb then
                    self.errorcb()
                end
            end
            -- device.showAlert("请重试ztq","网络错误!","OK")
            -- show_tip_label("网络错误，请重试!")
        end

	    if not ok then
	        -- print(request:getErrorCode(), request:getErrorMessage())
	        return
	    end

		local Rescode = request:getResponseStatusCode()
		if(Rescode ~= 200) then
			device.showAlert("警告","网络错误，请检查您的网络!",{"好的"}, function ()
			end)
            return
		end

		local j = require "framework.json"
		local zipRes = request:getResponseData()--request:getResponseDataLua()

		-- print("zip:" ..zipRes)
		local res,eof,bin,bout
		if(ENABLE_GAME_ZLIB == true) then
			-- uncompress data
		 	res,eof,bin,bout = zlib.inflate()(zipRes)
		 else
		 	res = zipRes
		 end

		-- json decode
		if(res ~= "") then
			codeJson = j.decode(res)

			-- 回调处理
			if self.cb ~= nil then
	    		self.cb(codeJson)
	        end	
		else
			codeJson = ""
		end

	end -- end function


   	local serverURL = self.m_url or ServerInfo["SERVER_URL"]

   	if(GAME_DEBUG == true) then
		local localHost = CCUserDefault:sharedUserDefault():getStringForKey("ip")
		if(localHost ~= nil and localHost ~= "" ) then
			serverURL = "http://" .. localHost
		end
	end
   	--CCHTTPRequest
    local httpRequest = self.network.createHTTPRequest(
    	responseCB , 
    	serverURL, 
    	"POST"
    	)
    httpRequest:setPOSTData(self.outStringData)
    httpRequest:start()

end



--[[--
	@serverID: select server index 
	@requestID: 
	@tableData: the data must be table, it will be encode as json
	@callback: response listener
]]
function HttpNetWorkBase:SendData(playerID, serverID, requestID, tableData , callback, errorcb, url )

	-- 外部可以设置url
	if(url ~= nil) then
		self.m_url = url
	end

	-- 1.网络不好
	if(self.network.isInternetConnectionAvailable() == false) then
		device.showAlert("网络错误，请检查您的网络", "",{"确定"}, function ()
     		if not game.EnterGame then
                os.exit(0);
			end
     	end)
		return
	end

	local msg = {}
	
	-- msg.Head = MSG_HEAD
	-- if (device.platform == "windows") then
	-- 	msg.Head.DID = device.getOpenUDID()--WRUtility:GetDeviceID()
	-- else
	-- 	msg.Head.DID = device.getOpenUDID()
	-- end
		
	-- msg.Head.ReqID = requestID
	-- msg.Head.PID = playerID

	msg.Body = tableData

	msg.Body.v = getlocalversion()

	-- encode json
	local jsonOutPut = require("framework.json")

	if(msg ~= nil) then
		dump(msg)
		local outputStr = jsonOutPut.encode(msg)	    
		self.outStringData = outputStr
	    if( ENABLE_GAME_ZLIB == true) then	    
	    	local xxtea = crypto.encryptXXTEA(outputStr, "!@#asdfD_cdp[")	
	    	self.outStringData = crypto.encodeBase64(xxtea)
	    	-- dump(self.outStringData)
	    	-- local res1,eof1,bin1,bout1
	    	-- res1,eof1,bin1,bout1 = zlib.deflate()(outputStr, "full")
	    	-- self.outStringData = res1
	    	-- dump(outputStr)
	    	-- dump(string.len(self.outStringData))
	   --  	local res,eof,bin,bout
		 	-- res,eof,bin,bout = zlib.inflate()(res1)
		 	-- dump(res)
    	end
    	
	end
	-- set callback
	self.cb = callback
    self.errorcb = errorcb

	-- send Request
    REQ_NUM = 1
	self:Request()
end

function HttpNetWorkBase:disconnect()

end


return HttpNetWorkBase