----------------------------------------------------
---- 协议管理
---- @author whjing2011@gmail.com
------------------------------------------------------

ProtoMgr = ProtoMgr or BaseClass()

function ProtoMgr:getInstance()
    if not self.is_init then 
        self.cmd_callback_table = {} -- 协议回调
		self.net_manager = cc.SmartSocket:getInstance()
        self:LoadMate()
        self.is_init = true
    end
    return self
end

-- 加载协议描述文件
function ProtoMgr:LoadMate()
    local Proto = require("sys.net.proto_mate")
    self.net_manager:loadSendMateData(Proto.send)
    self.net_manager:loadRecvMateData(Proto.recv)
end

-- 判断指定协议是否注册了回调函数
function ProtoMgr:hasReg(cmd)
    return self.cmd_callback_table[cmd] ~= nil 
end

-- 注册协议监听回调函数
function ProtoMgr:RegisterCmdCallback(cmd, func_name, obj)
	func_name = func_name or "handle_"..cmd
    local callback
    if type(obj) == "function" then
        callback = obj
    elseif obj then -- 对象实例
        if not obj[func_name] then
            Debug.error("注册协议出错,不存在的函数调用", cmd, func_name)
            return false
        end
        callback =  function(data)
            obj[func_name](obj, data)
        end
    else 
        local func = _G[func_name] or func_name
        callback = function(data)
            func(data)
        end
    end
    if not self.cmd_callback_table[cmd] then 
        self.cmd_callback_table[cmd] = {}
    end
    self.cmd_callback_table[cmd][func_name] = callback;
end

-- 取消协议监听绑定
function ProtoMgr:UnRegisterCmdCallback(cmd, func_name)
    if not self.cmd_callback_table[cmd] then return end
	func_name = func_name or "handle_"..cmd
    if not self.cmd_callback_table[cmd][func_name] then return end
    self.cmd_callback_table[cmd][func_name] = nil
end

-- 协议回调处理
function ProtoMgr:cmd_callback(cmd, data)
    if not self.cmd_callback_table[cmd] then return end
    local funs = self.cmd_callback_table[cmd]
    for _, fun in pairs(funs) do 
        fun(data)
    end
    data = nil
end
