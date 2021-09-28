require "Core.Module.Pattern.Proxy"

SelectSceneProxy = Proxy:New();

function SelectSceneProxy:OnRegister()

end

function SelectSceneProxy:OnRemove()

end
function SelectSceneProxy:GetSceneLines()
    
end

--返回状态对应图名, 0流畅 1拥挤 2爆满
function SelectSceneProxy.GetStateSprName(st)
    --logTrace(type(st) .. tostring(st) .. type(SceneLineState.fluency) .. tostring(SceneLineState.fluency))
    if st == SceneLineState.fluency then return "serverSt1" end
    if st == SceneLineState.crowd then return "serverSt2" end
    if st == SceneLineState.full then return "serverSt3" end
end
--返回状态对应描述,0流畅 1拥挤 2爆满
function SelectSceneProxy.GetStateDes(st)
    if st == SceneLineState.fluency then return LanguageMgr.Get("SelectScene/SelectSceneState0") end
    if st == SceneLineState.crowd then return LanguageMgr.Get("SelectScene/SelectSceneState1") end
    if st == SceneLineState.full then return LanguageMgr.Get("SelectScene/SelectSceneState2") end
end
--返回状态对应数字描摹,0流畅 1拥挤 2爆满
function SelectSceneProxy.GetStateDesNumber(st,ln)
    local sl = LanguageMgr.Get("SelectScene/SelectSceneLine")
    if st == SceneLineState.fluency then return "[67ff64]" .. ln .. sl end
    if st == SceneLineState.crowd then return "[ffbc48]" .. ln .. sl end
    if st == SceneLineState.full then return "[ff3f42]" .. ln .. sl end
end

--返回场景线列表callBack(lines：[{ln,st:0流畅 1拥挤 2爆满},..]
function SelectSceneProxy.GetSceneLines(callBack)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetSceneLines, function(data) callBack(data) end);
end
--返回当前场景线状态,line：{ln,st}分线
function SelectSceneProxy.GetSceneLine()
    
end
--返回当前场景线状态,line：{ln,st}分线
function SelectSceneProxy.SetSceneLine()
    
end

