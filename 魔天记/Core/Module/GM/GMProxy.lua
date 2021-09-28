require "Core.Module.Pattern.Proxy"
local json = require "cjson"

GMProxy = Proxy:New();
function GMProxy:OnRegister()


 SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GmCmd, GMProxy.GmCmdResult);

end

function GMProxy:OnRemove()


SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GmCmd, GMProxy.GmCmdResult);
end

function GMProxy.SendGmCmd(content,handler)
    GMProxy.handler = handler;
    SocketClientLua.Get_ins():SendMessage(CmdType.GmCmd, { cmd = content })
end

function GMProxy.GmCmdResult(cmd, data)
    if (data.errCode == nil) then
       
       if(GMProxy.handler ~= nil ) then
          GMProxy.handler();
       end

       GMProxy.handler = nil;

    end
end


function GMProxy.SendProtocol(_cmd, _content) 
    SocketClientLua.Get_ins():SendTestMessage(int64.tonum2(_cmd), _content)
end

