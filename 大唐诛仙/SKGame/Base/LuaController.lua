-- 功能控制器基类
LuaController = BaseClass()

-- 外部构造调用 .New()
	function LuaController:__init()
		self.protos = {}
	end

-- 协议消息
	function LuaController:RegistProtocal(protocal, handleName)
		-- print("[@]注册 ", protocal, "自动 ", handle~=nil)
		if not MessageEnum[protocal] then
			error("协议不对！！"..(protocal or "nil"))
		end
		if handleName then
			if not self[handleName] then
				error(string.format("没有初始化协议处理器: function Ctrl:%s(buffer)",handleName))
			end
			local function handle(buffer)
				self[handleName](self, buffer)
			end
			table.insert(self.protos, protocal)
			Network.RegistProtocal(MessageEnum[protocal], handle)
		else
			if self[protocal] then
				local function handle(buffer)
					self[protocal](self, buffer)
				end
				table.insert(self.protos, protocal)
				Network.RegistProtocal(MessageEnum[protocal], handle)
			else
				error(string.format("没有初始化协议处理器: function Ctrl:%s(buffer)",protocal))
			end
		end
	end
	
	function LuaController:RemoveProtocal( protocal )
		-- log("[@]移除 ".. protocal)
		Network.RemoveProtocal(MessageEnum[protocal]) 
	end

	-- 发送消息 msg: *.proto 中的消息体 如: msg = GC_LS_pb.AskLogin()
	function LuaController:SendMsg( protocal, msg )
		if not protocal or not MessageEnum[protocal] then -- debugFollow()
			error("[LuaController:SendMsg]不存在的消息id口号：".. (protocal or "nil"))
		end
		-- log("[@]发送 ".. protocal .."@".. MessageEnum[protocal])
		Network.SendMsg(msg, MessageEnum[protocal])
	end
	-- 发送空协议
	function LuaController:SendEmptyMsg(pbModule, protocalName)
		self:SendMsg(protocalName, pbModule[protocalName]())
	end
	--[[ 解析收到的协议
		pbMsg: *.proto 中的消息体 如：xxx_pb.MsgName()
		buffer: 服务器返回的protobuffer消息体
		返回: 解析后的具体协议消息
	]]
	function LuaController:ParseMsg( pbMsg, buffer )
		return Network.ParseMsg(pbMsg, buffer)
	end

	function LuaController:ClearInnerEvent( event, handleName )
		if not event then return end
		if self[handleName] then
			event:RemoveEventListener(self[handleName])
		end
		self[handleName] = nil
	end
-- 外部销毁调用 .Destroy()
	function LuaController:__delete()
		if not self.protos then return end
		for i,v in ipairs(self.protos) do
			self:RemoveProtocal( v )
		end
		self.protos = nil
	end