
--[[
功能: 协议处理类的基类
]]
BaseController= BaseController or BaseClass()

-- 获取单例 	
-- New和不New只是一层一层调用__init和__delete，对于单例没有影响
function BaseController:getInstance()
    if not self.is_init then 
        self.is_init = true
        if nil ~= self["config"] then
            self:config() -- 初始化一些数据
        end
        if nil ~= self["registerEvents"] then
        	self:registerEvents()
        end
        if nil ~= self["registerProtocals"] then
        	self:registerProtocals()
        end
    end
    return self
end

--[[@
	注册协议回调函数
]]
function BaseController:RegisterProtocal(id, func_name)
	ProtoMgr:getInstance():RegisterCmdCallback(id, func_name, self)
end

--[[
	发送协议
	@param id 协议id
	@param data 协议数据内容,直接是一个tab
]]
function BaseController:SendProtocal(id, data)
	if id == nil or id == 0 then
		Debug.info("发送失败, 错误的协议号")
		return
	end
	data = data or {}
	Send(id, data)
end

--[[@
功能：  注册一条错误码回调函数
说明：  一个错误码只能注册一个错误回调函数，对于通用错误码，不需要注册
]]
-- function BaseController:RegisterErrNumCallback(err_num, func_name)
--     local register_func = function()
--         local oper_func = self[func_name]
--         if not oper_func then
--             return
--         end
-- 		oper_func(self)
-- 	end
-- 	SysMsgModel.Instance:RegisterMsgOperate(err_num, register_func)
-- end
