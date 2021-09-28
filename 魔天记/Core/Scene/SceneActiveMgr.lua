require "Core.Info.MonsterInfo";
require "Core.Module.Friend.controlls.PartData"
require "Core.Role.Controller.AbsController";
-- 场景角色管理
SceneActiveMgr = class("SceneActiveMgr");
SceneActiveMgr.instance = nil
SceneActiveType = {
    -- 场景活动对象类型
    SCENE_EFFECT = 1;-- 场景自带特效
    NPC = 4;-- 场景角色,npc
    MONSTER = 5;-- 场景角色,怪
    PLAYER = 6;-- 场景角色,玩家
    PET = 7;-- 场景角色,宠物
    OBJ = 8;-- 场景物件
}
local MaxPlayer = QualitySetting.GetPlayerMax();
local MaxMonster = QualitySetting.GetMonsterMax();
local player = { };
local playerInCamera = { };
local npc = { };
local npcInCamera = { };
local _timer;
local insertt = table.insert;
local pairst = ipairs;
local removet = table.remove;
local sortt = table.sort;
local contains = function(t, e)
    for i = #t, 1, -1 do
        if t[i] == e then return true end
    end
    return false
end
local heroGuild

-- 标识组节点的名字开头, 下面子节点将作为独立单位处理
local group = "Group_";
-- 与美术约定场景效果父节点名
local effectParentNames = { "Effect" }-- , "Animation" };
-- 增加需要场景优化的效果,unitParent效果父节点
local function _AddActives(unitParent, typet)
    local gs = { };
    local strFind = string.find
    for j = unitParent.childCount - 1, 0, -1 do
        local unit = unitParent:GetChild(j);
        if (strFind(unit.name, group) == 1) then
            for k = unit.childCount - 1, 0, -1 do
                insertt(gs, unit:GetChild(k).gameObject);
            end
        else
            insertt(gs, unit.gameObject);
        end
    end
    CameraActiveMgr.AddActives(gs, typet, false)
end
-- 初始化场景
function SceneActiveMgr:InitScene()
    CameraActiveMgr.InitScene();
    for k, v in pairst(effectParentNames) do
        local go = GameObject.Find(v);
        if (go ~= nil) then _AddActives(go.transform, SceneActiveType.SCENE_EFFECT) end
    end
    _checkFrameCount = 0;
    if (not _timer.running) then
        _timer:Start()
    end
end
local function _SetTimer()
    if (_timer == nil) then
        _timer = Timer.New(SceneActiveMgr.Update, 0.3, -1, false);
    end
end
-- 清理
function SceneActiveMgr:Clear()
    CameraActiveMgr.Clear();
    player = { };
    npc = { };
    playerInCamera = { }
    npcInCamera = { }
    if (_timer) then _timer:Stop() end
end
function SceneActiveMgr:New()
    self = { };
    setmetatable(self, { __index = SceneActiveMgr });
    _SetTimer();
    SceneActiveMgr.instance = self
    SceneActiveMgr.Start()
    CameraActiveMgr.SetHandler(SceneActiveType.PLAYER, SceneActiveMgr._ActivePlayer)
    CameraActiveMgr.SetHandler(SceneActiveType.MONSTER, SceneActiveMgr._ActiveMonster)
    return self;
end
function SceneActiveMgr._ActivePlayer(go, v)
    if v then insertt(playerInCamera, go) end
    -- Warning(tostring(go.name) .. '__' .. tostring(v) .. '---' .. #playerInCamera)
end
function SceneActiveMgr._ActiveMonster(go, v)
    if v then insertt(npcInCamera, go) end
    -- Warning(tostring(go.name) .. '__' .. tostring(v) .. '---' .. #npcInCamera)
end

-- 场景活动对象增删       
function SceneActiveMgr:AddPlayer(r, go)
    if (contains(player, r)) then return end
    insertt(player, r);
    CameraActiveMgr.AddActive(go, SceneActiveType.PLAYER, true)
end
function SceneActiveMgr:AddPlayerPet(r, go)
    --CameraActiveMgr.AddActive(go, SceneActiveType.PET, true)
end
function SceneActiveMgr:AddNpc(r, go)
    --    if ( contains (npc, r)) then return end
    --    insertt(npc, r);
    CameraActiveMgr.AddActive(go, SceneActiveType.NPC, false)
end
function SceneActiveMgr:AddMonster(r, go)
    if (contains(npc, r)) then return end
    insertt(npc, r);
    CameraActiveMgr.AddActive(go, SceneActiveType.MONSTER, true)
end
function SceneActiveMgr:AddObj(r, go)
    CameraActiveMgr.AddActive(go, SceneActiveType.OBJ, false)
end
local function _RemoveForList(ls, id)
    for i = #ls, 1, -1 do
        local v = ls[i]
        if v.info == nil then
            removet(ls, i)
            if v.gameObject then CameraActiveMgr.RemoveActive(v.gameObject) end
        elseif v.info.id == id then
            removet(ls, i)
            if v.gameObject then CameraActiveMgr.RemoveActive(v.gameObject) end
            return v
        end
    end
end

function SceneActiveMgr:Remove(id)
    local r = _RemoveForList(npc, id)
    if not r then r = _RemoveForList(player, id) end
    if r then
        CameraActiveMgr.RemoveActive(r.gameObject)
    end
end

function SceneActiveMgr:SetAttackMe(r)
    r.attackHero = true
end

-- 场景活动对象筛选显示 ,过滤ls表中在sortFunc排序max后面的角色
function SceneActiveMgr._SortRoles(ls, sortFunc)
    -- sortt(ls, sortFunc)
    local len = #ls
    for i = 1, len - 1 do
        local r = ls[i]
        for k = i + 1, len do
            local r2 = ls[k]
            if sortFunc(r2, r) then
                ls[i] = r2
                ls[k] = r
                r = r2
            end
        end
    end
end
-- 判断是否 是我的队友
local IsMyTeammate = PartData.IsMyTeammate
local function HandlerSort(ls, roleInCamera, user)
    for i = #ls, 1, -1 do
        local r = ls[i]
        local f = contains(roleInCamera, r.gameObject)
        r.inScreen = f
        if user then
            r.isMyTeam = IsMyTeammate(r.id)
            r.isMyGuild = GuildDataManager.IsSameGuild(r.info.tgn, heroGuild)
            r.isMyFriend = FriendDataManager.IsFriend(r.id)
        end
    end
end
-- A、夫妻、师徒关系,队友,当前攻击我的角色,当前我攻击的角色,同帮会成员,好友,其他普通玩家
local function SortPlayer(r, r2)
    if r.inScreen ~= r2.inScreen then return r.inScreen end
    -- 相机内
    local fr = r.isMyTeam
    local fr2 = r2.isMyTeam
    if fr ~= fr2 then return fr end
    -- 队友
    if r.attackHero ~= r2.attackHero then return r.attackHero == true end
    -- 攻击我
    if r.heroTarget then return true end
    -- 我攻击
    fr = r.isMyGuild
    fr2 = r2.isMyGuild
    if fr ~= fr2 then return fr end
    -- 帮友
    fr = r.isMyFriend
    fr2 = r2.isMyFriend
    if fr ~= fr2 then return fr end
    -- 好友
    return false
end
function SceneActiveMgr._FilterPlayer(ls, max)
    local len = #ls
    for i = 1, len do
        local r = ls[i]
        local v = i <= max
        r:SetVisible(v)
        r.attackHero = false
        r.heroTarget = false
        if r.pet then r.pet:SetVisible(v) end
        if r.puppet then r.puppet:SetVisible(v) end
    end
end
-- 当前攻击我的角色,当前我攻击的角色,3 BOSS,pnc,2 elite,3 monster
local function SortNpc(r, r2)
    if r.inScreen ~= r2.inScreen then return r.inScreen end
    -- 相机内
    if r.attackHero ~= r2.attackHero then return r.attackHero == true end
    -- 攻击我
    if r.heroTarget then return true end
    -- 我攻击
    return r.info.type > r2.info.type
    -- boss,elite,monster
end
function SceneActiveMgr._FilterNpc(ls, max)
    local len = #ls
    for i = 1, len do
        local r = ls[i]
        local v = i <= max
        r.attackHero = false
        r.heroTarget = false
        r:SetVisible(v)
    end
    --    if len > 0 then
    --        local s = ''
    --        for i = 1, len do if ls[i].visible then s = s .. ',' .. ls[i]:GetGo().name end end
    --        if s ~= '' then Error(s) end
    --    end
end
function SceneActiveMgr.Start()
    SceneActiveMgr._run = true
end
function SceneActiveMgr.Stop()
    SceneActiveMgr._run = false
end
function SceneActiveMgr.EnableType(t, able)
    CameraActiveMgr.EnableType(t, able)
end

function SceneActiveMgr.Update()
    if not SceneActiveMgr._run then return end

    -- CameraActiveMgr.Update(SceneActiveType.MONSTER);
    -- CameraActiveMgr.Update(SceneActiveType.PLAYER);
    -- CameraActiveMgr.Update(SceneActiveType.PET);
    -- CameraActiveMgr.Update(SceneActiveType.SCENE_EFFECT);
    -- CameraActiveMgr.Update(SceneActiveType.NPC);
    -- CameraActiveMgr.Update(SceneActiveType.OBJ);
    CameraActiveMgr.UpdateAll()

    local ht = HeroController.GetInstance():GetTarget()
    if ht then ht.heroTarget = true end
    local hi = PlayerManager.GetPlayerInfo()
    heroGuild = hi and hi.tgn or nil
    HandlerSort(player, playerInCamera, true)
    SceneActiveMgr._SortRoles(player, SortPlayer)
    SceneActiveMgr._FilterPlayer(player, MaxPlayer)
    HandlerSort(npc, npcInCamera)
    SceneActiveMgr._SortRoles(npc, SortNpc)
    SceneActiveMgr._FilterNpc(npc, MaxMonster)
    playerInCamera = { }
    npcInCamera = { }
end

function SceneActiveMgr.SetMaxPlayerCount(v)
    v = v or MaxPlayer
    MaxPlayer = v
end
function SceneActiveMgr.SetMaxMonsterCount(v)
    v = v or MaxMonster
    MaxPlayer = v
end