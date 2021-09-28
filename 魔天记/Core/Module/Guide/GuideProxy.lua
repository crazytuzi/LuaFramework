require "Core.Module.Pattern.Proxy"

GuideProxy = Proxy:New();
function GuideProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SaveGuide, GuideProxy._RspSaveGuide);
end

function GuideProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SaveGuide, GuideProxy._RspSaveGuide);
end

GuideProxy.tmpId = 0;
GuideProxy.tmpSt = 0;
function GuideProxy.ReqNew(id)
	GuideProxy.tmpId = id;
	GuideProxy.tmpSt = 1;
	GuideManager.SetGuideSt(GuideProxy.tmpId, GuideProxy.tmpSt);
	SocketClientLua.Get_ins():SendMessage(CmdType.SaveGuide, {id = id, st = 1});
end

function GuideProxy.ReqDo(id)
	GuideProxy.tmpId = id;
	GuideProxy.tmpSt = 2;
	GuideManager.SetGuideSt(GuideProxy.tmpId, GuideProxy.tmpSt);
	SocketClientLua.Get_ins():SendMessage(CmdType.SaveGuide, {id = id, st = 2});
end

function GuideProxy.ReqFinish(id)
	GuideProxy.tmpId = id;
	GuideProxy.tmpSt = 3;
	GuideManager.SetGuideSt(GuideProxy.tmpId, GuideProxy.tmpSt);
	SocketClientLua.Get_ins():SendMessage(CmdType.SaveGuide, {id = id, st = 3});
end

function GuideProxy.ReqError(id)
	GuideProxy.tmpId = id;
	GuideProxy.tmpSt = 4;
	GuideManager.SetGuideSt(GuideProxy.tmpId, GuideProxy.tmpSt);
	SocketClientLua.Get_ins():SendMessage(CmdType.SaveGuide, {id = id, st = 4});
end

function GuideProxy.ReqStop(id)
	GuideProxy.tmpId = id;
	GuideProxy.tmpSt = 5;
	GuideManager.SetGuideSt(GuideProxy.tmpId, GuideProxy.tmpSt);
	SocketClientLua.Get_ins():SendMessage(CmdType.SaveGuide, {id = id, st = 5});
end

function GuideProxy._RspSaveGuide(cmd, data)
	if(data == nil or data.errCode ~= nil) then
        return;
    end

    --GuideManager.SetGuideSt(GuideProxy.tmpId, GuideProxy.tmpSt);
end
