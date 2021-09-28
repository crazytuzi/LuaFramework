require "Core.Module.Pattern.Proxy"
require "net/CmdType"
require "net/SocketClientLua"

ComposeProxy = Proxy:New();
function ComposeProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ItemCompose, ComposeProxy._RspCompose);
end

function ComposeProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ItemCompose, ComposeProxy._RspCompose);
end

function ComposeProxy.ReqCompose(id, num)
	num = num or -1;
	SocketClientLua.Get_ins():SendMessage(CmdType.ItemCompose, {spId = id, num = num});
end

function ComposeProxy._RspCompose(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end
    MsgUtils.ShowTips("compose/success");
    UISoundManager.PlayUISound(UISoundManager.equip_gem_compose);
end
