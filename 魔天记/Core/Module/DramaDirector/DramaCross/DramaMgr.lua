require "Core.Module.DramaDirector.DramaCross.Crossing"
--剧情管理员
DramaMgr = class("DramaMgr");
DramaMgr.FaceTimer = { 0.5,0.5,0.5, 0.5,0.5,0.5, Color.black,Color.black } --淡入淡出时间
--触发横渡剧情
function DramaMgr:Init(args)
    local mask = LayerMask.GetMask(Layer.Default, Layer.Water,Layer.TransparentFX,Layer.ReceiveShadow, Layer.Hero, Layer.Player)
    DramaDirector.camera:FilterMask(mask)
    DramaMgr._currentDrama = Crossing:New()
    HeroController.GetInstance():SetVisible(true)
end

-- 开始剧情
function DramaMgr:Begin()
    DramaMgr._currentDrama:Begin()
end
-- 结束剧情
function DramaMgr:End()
    DramaDirector.End(true, true)
    DramaDirector.camera:RevertMask()
end
-- 清理
function DramaMgr:Clear()
    DramaDirector.camera:RevertMask()
    DramaMgr._currentDrama:Clear()
    DramaMgr._currentDrama = nil 
end

-- 返回计时器
function DramaMgr:_GetTimer(duration, loop, onTime)
    local t = Timer.New(onTime, duration, loop, false)
    t:Start();
    return t
end;
-- 返回场景坐标信息
function DramaMgr:GetScenePosByID(id)
    --logTrace(""..id);
    local ScenePosCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SCENES_POS);
    return ScenePosCfg[id]
end

function DramaMgr.LogicHandler(did)

end

