require "Core.Module.Pattern.Proxy"
SceneEntityProxy = Proxy:New();
function SceneEntityProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSceneProps, SceneEntityProxy.GetSceneProps)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ScenePropChange, SceneEntityProxy.ScenePropChange)
end

function SceneEntityProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetSceneProps, SceneEntityProxy.GetSceneProps)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ScenePropChange, SceneEntityProxy.ScenePropChange)
end
function SceneEntityProxy.SendGetSceneProps()
    SocketClientLua.Get_ins():SendMessage(CmdType.GetSceneProps)
end
function SceneEntityProxy.SendHoldSceneProp(id, f) -- 0 发起，1 取消
    SocketClientLua.Get_ins():SendMessage(CmdType.HoldSceneProp, { id = id , f = f })
end

function SceneEntityProxy.GetSceneProps(cmd, data)
	if data.errCode then return end
    SceneEntityMgr.SetSceneProps(data)
end
function SceneEntityProxy.ScenePropChange(cmd, data)
	if data.errCode then return end
    SceneEntityMgr.ScenePropChange(data)
end
function SceneEntityProxy.StartCollect(sid)
    if not SceneEntityMgr.HasCollectNum() then
        MsgUtils.ShowTips("SceneEntity/collectedMax")
        return -1
    end
    local id = SceneEntityMgr.GetIdByPointId(sid)
    SceneEntityProxy.SendHoldSceneProp(id, 0)
    SceneEntityMgr.SetCollectId(id)
    return SceneEntityMgr.GetConfigById(id).time_collect
end
function SceneEntityProxy.CancelCollect()
    local collectId = SceneEntityMgr.GetCollectId()
    if not collectId then return end
    SceneEntityProxy.SendHoldSceneProp(collectId, 1)
    SceneEntityMgr.SetCollectId(nil)
end
