require "Core.Module.DramaDirector.DramaProxy"
require "Core.Module.DramaDirector.DramaTimeLine.DramaTimer"
require "Core.Module.DramaDirector.DramaCross.DramaMgr"
-- 剧情管理员
DramaDirector = class("DramaDirector")
DramaDirector.currentDrama = nil
local DRAMA_COOKIE_KEY = "DRAMA_COOKIE_KEY"
DramaEventType = {
    -- 剧情事件类型
    CameraPoint = 1,
    CameraPath = 2,
    CameraShake = 3,
    RoleShow = 21,
    RolePath = 22,
    RoleMove = 23,
    RoleAction = 24,
    DialogSubtitle = 31,
    DialogBubble = 32,
    DialogRole = 33,
    EntityEffect = 41,
    EntityScene = 42,
    TimeScale = 51
    ,
    BornNpc = 61,
    DeleteNpc = 62
    ,
    GiveTrump = 63,
    DeleteTrump = 64
    ,
    GuideStep = 65-- 触发新手事件
}
DramaTriggerType = {
    -- 剧情触发类型
    Passivity = '1',
    InstanceEnd = '2'
}

DramaDirector._running = false
DramaDirector.onComplete = nil 

-- 触发剧情,did剧情id(int), onComplete当剧情结束回调
function DramaDirector.Trigger(did, onComplete)
    --Warning("DramaDirector.Trigger,did=" .. did .. type(did))
    if DramaDirector._running then return end
    DramaDirector.onComplete = onComplete
    DramaDirector.hero = HeroController.GetInstance()
    DramaDirector.camera = MainCameraController.GetInstance()
    local m = GameSceneManager.map
    DramaDirector.inInstance = m and m:IsInstance()
    if m then m:LoadAllModle() end
    DramaDirector.did = did
    if did == 0 then
        DramaDirector.currentDrama = DramaMgr
    else
        DramaDirector.currentDrama = DramaTimer
        if DramaDirector.inInstance then
            -- 副本剧情只走一次
            if Util.HasKey(DRAMA_COOKIE_KEY .. DramaDirector.did .. PlayerManager.playerId) then
                DramaDirector.currentDrama.LogicHandler(did)
                DramaDirector.OnComplete()
                return
            end
        end
    end
    DramaDirector.Init()
    local ft = DramaDirector.currentDrama.FaceTimer
    if ft then
        DramaDirector.camera:ChangeCameraForBlack(
            nil, DramaDirector.Begin, ft[7], ft[1], ft[2], ft[3] )
    else
        DramaDirector.Begin()
    end
end
-- 副本结束检查 触发剧情,iid副本id, data副本结算数据
function DramaDirector.CheckInstanceEnd(iid, data)
    local did = DramaProxy.GetInstanceEndDramaConfig(iid)
    if did then
        DramaDirector.InstaceEndData = data
        DramaDirector.Trigger(did)
        return true
    end
    return false
end
-- 当前是否剧情状态
function DramaDirector.IsRunning()
    return DramaDirector._running
end

-- 初始剧情
function DramaDirector.Init()
    if not DramaDirector.currentDrama then return end
    DramaDirector._running = true
    DramaDirector.InitHero()
    DramaDirector.currentDrama.Init(DramaDirector.did)
    SkillExecuteManage.Clear()
    --PanelManager.HideAllPanels(true)
end
-- 初始主角
function DramaDirector.InitHero(isShowHero)
    isShowHero = isShowHero or false
    if (DramaDirector.hero == nil) then
        DramaDirector.hero = HeroController.GetInstance()
    end
    local h = DramaDirector.hero
    DramaDirector.isAutoFight = h:IsAutoFight()
  
    h:HideRide()
     
    if not isShowHero then
         h:SetRoleNamePanelActive(false)
         h:SetVisible(false)
    end
 
    h:SetPuppetAI(false)
    -- h:PuppetVisible(false)
    h:SetPetAI(false)
    -- h:PetVisible(false)
    h:StopCurrentActAndAI()

--    local map = GameSceneManager.map;
--    if (map == nil or(map and map.info.type ~= InstanceDataManager.MapType.Novice)) then
--        h:RemoveBuffAll()
--    end

    DramaDirector.heroPos = h:GetPos()
    MainUIProxy.SetMainUIOperateEnable(false)
end

-- 还原主角
function DramaDirector.RevertHero(showName, noRevertPos)
    local h = DramaDirector.hero
    if showName then h:SetRoleNamePanelActive(true) end
    if not DramaDirector.InstaceEndData and DramaDirector.isAutoFight then h:StartAutoFight() end
    -- log(tostring(DramaDirector.InstaceEndData ) .. "______" .. tostring(DramaDirector.isAutoFight))
    DramaDirector.isAutoFight = nil
    if not noRevertPos then h:SetPosition(DramaDirector.heroPos) end
    h:ShowRide()
    h:SetVisible(true)
    h:SetPuppetAI(true)
    -- h:PuppetVisible(true)
    h:SetPetAI(true)
    -- h:PetVisible(true)
    MainUIProxy.SetMainUIOperateEnable(true)
end
-- 开始剧情
function DramaDirector.Begin()
    if not DramaDirector._running then return end
    PanelManager.HideAllPanels(true)
    Scene.instance.uiHurtNumParent.gameObject:SetActive(false)
    ModuleManager.SendNotification(DialogNotes.OPEN_SUB_DIALOGPANEL, { "", false })
    DramaDirector.currentDrama.Begin()
end
-- 结束剧情changeToHero转换
function DramaDirector.End(changeToHero, noRevertPos)
    if not DramaDirector.currentDrama then return end
    DramaDirector._ending = true
    changeToHero = false
    ModuleManager.SendNotification(DialogNotes.CLOSE_SUB_DIALOGPANEL)
    local ft = DramaDirector.currentDrama.FaceTimer
    DramaDirector._Ending(changeToHero, noRevertPos)
    if ft then
        DramaDirector.camera:ChangeCameraForBlack(
            nil, nil --function() DramaDirector._Ending(changeToHero, noRevertPos) end
            , ft[8], ft[4], ft[5], ft[6])
    --else DramaDirector._Ending(changeToHero, noRevertPos)
    end
end
function DramaDirector._Ending(changeToHero, noRevertPos)
    if changeToHero then
        DramaDirector.RevertHero(false, noRevertPos)
        DramaDirector.camera:ChangeCameraToHero(1, function()
            DramaDirector.hero:SetRoleNamePanelActive(true)
            DramaDirector.EndHander()
        end )
    else
        DramaDirector.camera:LockHero()
        DramaDirector.RevertHero(true, noRevertPos)
        DramaDirector.EndHander()
    end

    --新手剧情完毕以后
    if DramaDirector.did == 127 then
        GuideManager.StopGuide("GuideNoviceCastTrumpSkill");
    end

end
-- 结束剧情changeToHero转换
function DramaDirector.EndHander()
    DramaDirector._running = false
    PanelManager.RevertAllPanels()
    Scene.instance.uiHurtNumParent.gameObject:SetActive(true)
    if DramaDirector.inInstance and not Util.HasKey(DRAMA_COOKIE_KEY .. DramaDirector.did .. PlayerManager.playerId) then
        Util.SetString(DRAMA_COOKIE_KEY .. DramaDirector.did .. PlayerManager.playerId, "1")
    end
    DramaDirector.OnComplete()
end
function DramaDirector.OnComplete()
    DramaDirector.RefreshMonster()
    DramaDirector._ending = false
    DramaDirector.currentDrama = nil
    if DramaDirector.InstaceEndData then
        if GameSceneManager.map and HeroController.GetInstance() then --切账号
            GameSceneManager.map:CmdInstanceMapResultHandlering(DramaDirector.InstaceEndData)
        end
        DramaDirector.InstaceEndData = nil
    end
    if DramaDirector.onComplete then
        DramaDirector.onComplete()
        DramaDirector.onComplete = nil
    end
end
-- 剧情结束延迟刷怪物
function DramaDirector.RefreshMonster()
    local DramaTimer = DramaDirector.currentDrama
    -- log("DramaDirector.RefreshMonster:" .. tostring(DramaTimer.refreshMonsterTime) .. tostring(DramaTimer.plotId))
    if not DramaTimer.refreshMonsterTime then return end
    local data = { id = DramaTimer.plotId }
    if DramaTimer.refreshMonsterTime == 0 then
        SocketClientLua.Get_ins():SendMessage(CmdType.PlotProgress, data)
    elseif DramaTimer.refreshMonsterTime > 0 then
        DramaDirector.refreshMonsterTimer = DramaDirector.GetTimer(DramaTimer.refreshMonsterTime / 1000, 1, function()
            SocketClientLua.Get_ins():SendMessage(CmdType.PlotProgress, data)
        end )
    end
    DramaTimer.refreshMonsterTime = nil
end
-- 跳过
function DramaDirector.Skip(changeToHero)
    if DramaDirector._ending then return end
    if DramaDirector._running then
        DramaDirector.currentDrama.Clear()
        DramaDirector.End(changeToHero)
    else
        DramaDirector.currentDrama = nil --闪屏切换中,清理已标记
    end
end
-- 清理
function DramaDirector.Clear()
    DramaDirector.Skip(false)
    if DramaDirector.deleteObjs then
        for _, v in ipairs(DramaDirector.deleteObjs) do v:Stop() end
        DramaDirector.deleteObjs = nil
    end
    if DramaDirector.refreshMonsterTimer then
        DramaDirector.refreshMonsterTimer:Stop()
        DramaDirector.refreshMonsterTimer = nil
    end
    DramaTimer.refreshMonsterTime = nil
end


-- 场景快慢镜头特效, duration持续时间,timeScale时间缩放比,onComplete完成回调
function DramaDirector.SceneSlowMotion(duration, timeScale, onComplete)
    PanelManager.HideAllPanels(true)
    DramaDirector.InitHero(true)
    local t = Time.timeScale
    Time.timeScale = timeScale
    Timer.New( function()
        PanelManager.RevertAllPanels()
        DramaDirector.RevertHero(true)
        Time.timeScale = t
        if onComplete then onComplete() end
    end , 3, 1, false):Start()
end

local insert = table.insert
 
-- 剧情延迟duration删除的对象obj
function DramaDirector.DeleteDelay(duration, obj)
    if not DramaDirector.deleteObjs then DramaDirector.deleteObjs = { } end
    local t = Timer.New( function()
        if type(obj) == "table" then
            obj:Dispose()
        else
            if not IsNil(obj) then Resourcer.Recycle(obj, false) end
        end
    end , duration, 1, false)
    t:Start()
    insert(DramaDirector.deleteObjs, t)
end

-- 返回计时器
function DramaDirector.GetTimer(duration, loop, onTime)
    return Timer.New(onTime, duration, loop, false):Start()
end
