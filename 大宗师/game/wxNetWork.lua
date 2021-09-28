 --[[
 --
 -- @authors shan 
 -- @date    2014-05-12 11:31:33
 -- @version 
 --
 --]]

local wxNetWork = class("wxNetWork")

local gnwInstance = require ("utility.GameHTTPNetWork")


--[[
	消息处理
	request : table类型
	callback 消息回调，发送者自己处理接收到的数据
]]
function wxNetWork:MsgHandler( requestMsg, callback )
	local network = gnwInstance.new()
	local msg = {}
	msg.Head = {}
	msg.Head.ReqID = 1
	msg.Head.SNAME = "wx"
	msg.Head.Build = "100"
	msg.Head.PID = 1
	msg.Body = requestMsg or {1,1}
	local function cb( data )
		-- body
		dump(data)
	end
	network:SendData(1,1,1,msg, cb)
end

function wxNetWork:test( ... )
	local network = gnwInstance.new()
	local msg = {}
	msg.Head = {}
	msg.Head.ReqID = 1
	msg.Head.SNAME = "wx"
	msg.Head.Build = "100"
	msg.Head.PID = 1
	msg.Body = {1,1}
	local function cb( data )
		-- body
		dump(data)
	end
	network:SendData(1,1,1,msg, cb)

end




return wxNetWork