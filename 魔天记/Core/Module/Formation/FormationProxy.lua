require "Core.Module.Pattern.Proxy"

FormationProxy = Proxy:New();
function FormationProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.FormationUpdate, FormationProxy.FormationUpdate)
end

function FormationProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.FormationUpdate, FormationProxy.FormationUpdate)
end
--输入： id:道具id,num：数量;   输出：id:图阵id,lev:等级,exp:经验
function FormationProxy.SendFormationUpdate(id, spId, num)
    SocketClientLua.Get_ins():SendMessage(CmdType.FormationUpdate,{ spId = spId, id = id, num = num })
    --FormationProxy.test(id, spId, num)
end
function FormationProxy.test(id, spId, num)
    FormationManager.UpdateData({id=1,lev=5,exp=55})
end

function FormationProxy.FormationUpdate(cmd, data)
    if data.errCode then return end
    FormationManager.UpdateData(data)
end
