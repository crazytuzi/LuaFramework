require "Core.Module.Common.Panel"
require "Core.Module.Map.View.Item.MapItem"

MapPanel = class("MapPanel", Panel);
local sin = math.sin(math.rad(45))
local cos = math.cos(math.rad(45))
local rsin = math.sin(math.rad(-45))
local rcos = math.cos(math.rad(-45))
local rad = 45
local insert = table.insert

function MapPanel:New()
    self = { };
    setmetatable(self, { __index = MapPanel });
    return self
end 

function MapPanel:_Init()
    self:_InitReference();
    self:_InitListener();

    self._cb.value = MapProxy.showNpc
    self:UpdateMapPanel()
    MessageManager.AddListener(PlayerManager, PlayerManager.SELFMOVEEND, MapPanel._MoveEnd, self)

    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.1, -1, false);
    self._timer:Start();
end

function MapPanel:_MoveEnd()
    Util.SetLocalPos(self._trsTarget, 65535, 65535, 0)

    --    self._trsTarget.localPosition = Vector3(65535, 65535, 0)
end

function MapPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnWorldMap = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnWorldMap");
    self._txtMapName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMapName");
    self._imgMap = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgMap");
    self._goNpc = UIUtil.GetChildByName(self._trsContent, "Transform", "trsNpc").gameObject;
    self._goPortal = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPortal").gameObject;
    self._trsTarget = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTarget")
    self._trsPlayer = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPlayer");
    self._cb = UIUtil.GetChildByName(self._trsContent, "UIToggle", "checkBox");
    UIUtil.AddChild(self._imgMap.transform, self._trsPlayer)
    UIUtil.AddChild(self._imgMap.transform, self._trsTarget)
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, MapItem)
    self._npcs = { }
    self._goNpc:SetActive(false)
    self._goPortal:SetActive(false)
    Util.SetLocalPos(self._trsTarget, 65535, 65535, 0)

    --    self._trsTarget.localPosition = Vector3(65535, 65535, 0)

    local map = GameSceneManager.map;
    local mapType = map.info.type
    -- self._btnWorldMap.isEnabled = (mapType ~= InstanceDataManager.MapType.Novice);
end

function MapPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickMap = function(go) self:_OnClickMap(self) end
    UIUtil.GetComponent(self._imgMap.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMap);
    self._onClickBtnWorldMap = function(go) self:_OnClickBtnWorldMap(self) end
    UIUtil.GetComponent(self._btnWorldMap, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnWorldMap);
    self._onClickBtnCb = function(go) self:_OnClickBtnCb(self) end
    UIUtil.GetComponent(self._cb, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCb);
end

function MapPanel:_OnClickBtnCb()
    MapProxy.showNpc = not MapProxy.showNpc
    self._cb.value = MapProxy.showNpc
    for k, v in pairs(self._npcs) do
        v:SetActive(MapProxy.showNpc)
    end
end

function MapPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MapNotes.CLOSE_MAPPANEL)
end

function MapPanel:_OnClickBtnWorldMap()
    ModuleManager.SendNotification(MapNotes.OPEN_MAPWORLDPANEL)
end

-- function MapPanel:_OnClickBtnBackToMainCity()
--    if (self._map.info.city_id ~= 0) then
--        if (self._map.info.city_id == self._map.info.id) then
--            log("已经在主程内")
--        else
--            GameSceneManager.GotoScene(self._map.info.city_id)
--            ModuleManager.SendNotification(MapNotes.CLOSE_MAPPANEL)
--        end
--    end
-- end

function MapPanel:_OnClickMap()


    BusyLoadingPanel.CheckAndStopLoadingPanel();


    local pos = self._imgMap.transform:InverseTransformPoint(UICamera.lastWorldPosition)
    local posRate = Vector3(pos.x / self._imgMap.width, 0, pos.y / self._imgMap.height)

    local result = self:TransferLocalToWorld(posRate)
    -- tangpingA星会找最近的位置 if (GameSceneManager.mpaTerrain:IsWalkable(result)) then
    Util.SetLocalPos(self._trsTarget, pos.x, pos.y, pos.z)

    --    self._trsTarget.localPosition = pos
    HeroController:GetInstance():MoveTo(result, GameSceneManager.map.info.id)
    -- else
    --    self._trsTarget.localPosition = Vector3(65535, 65535, 0)
    -- end



end


function MapPanel:_Dispose()
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFMOVEEND, MapPanel._MoveEnd)

    self:_DisposeListener();
    self:_DisposeReference();
    self._phalanx:Dispose()
    self._phalanx = nil

end


function MapPanel:TransferLocalToWorld(posRate)
    local result = Vector3(math.round((self._map.info.mapXSize * posRate.x) + self._map.info.offsetX), 0, math.round((self._map.info.mapYSize * posRate.z) + self._map.info.offsetY))
    result = Vector3(result.x * rcos + result.z * rsin, 0, result.z * rcos - result.x * rsin)
    return result
end

function MapPanel:TransferWorldToLocal(pos)
    local result = Vector3((((pos.x * cos + pos.z * sin) - self._map.info.offsetX) / self._map.info.mapXSize) * self._imgMap.width,
    (((pos.z * cos - pos.x * sin) - self._map.info.offsetY) / self._map.info.mapYSize) * self._imgMap.height, 0)

    return result
end

function MapPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._imgMap.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMap = nil;
    UIUtil.GetComponent(self._btnWorldMap, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnWorldMap = nil;
    UIUtil.GetComponent(self._cb, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCb = nil;
end

function MapPanel:_DisposeReference()
    self._btn_close = nil;
    if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
    -- self._imgMap.mainTexture = nil
    self._imgMap = nil
    self._btnWorldMap = nil;
    self._hero = nil
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    self._map = nil
    self._npcs = { }
end

function MapPanel:UpdateMapPanel()
    self._map = GameSceneManager.map
    self._mainTexturePath = "map/" .. self._map.info.minimap;
    local tex = UIUtil.GetTexture(self._mainTexturePath)
    if (tex == nil) then
        self._mainTexturePath = "map/10005"
        tex = UIUtil.GetTexture(self._mainTexturePath)
    end
    self._imgMap.mainTexture = tex

    local npcInfoes = GameSceneManager.map:GetCurNpcInfoes()
    local portalInfoes = GameSceneManager.map:GetCurPortalInfoes()
    local monsterInfoes = GameSceneManager.map:GetCurMonsterInfoes()
    local scenePropInfoes = GameSceneManager.map:GetCurScenePropInfos()
    local mapItemInfoes = { }
    for k, v in ipairs(npcInfoes) do
        insert(mapItemInfoes, v)
    end

    for k, v in ipairs(monsterInfoes) do
        insert(mapItemInfoes, v)
    end
    for k, v in ipairs(scenePropInfoes) do
        insert(mapItemInfoes, v)
    end

    self._phalanx:Build(table.getCount(mapItemInfoes), 1, mapItemInfoes)

    self._hero = HeroController:GetInstance()
    if (self._map) then
        self._txtMapName.text = self._map.info.name
        for k, v in pairs(npcInfoes) do
            local npcTemp = NGUITools.AddChild(self._imgMap.gameObject, self._goNpc)
            insert(self._npcs, npcTemp)
            self:SetOther(npcTemp, v, true)
        end

        for k, v in pairs(portalInfoes) do
            local portalTemp = NGUITools.AddChild(self._imgMap.gameObject, self._goPortal)
            self:SetOther(portalTemp, v, false)
        end

        for k, v in pairs(scenePropInfoes) do
            local npcTemp = NGUITools.AddChild(self._imgMap.gameObject, self._goNpc)
            insert(self._npcs, npcTemp)
            self:SetOther(npcTemp, v, true)
        end
    end
end

function MapPanel:_OnUpdata()
    if (self._hero) then
        Util.SetLocalPos(self._trsPlayer, self:TransferWorldToLocal(self._hero.transform.position))

        --        self._trsPlayer.localPosition = self:TransferWorldToLocal(self._hero.transform.position)
        self._trsPlayer.localRotation = Quaternion.Euler(0, 0, - self._hero.transform.eulerAngles.y - rad)
    end
end

function MapPanel:SetOther(go, info, isNpc)
    if (isNpc) then
        go:SetActive(MapProxy.showNpc)
    else
        go:SetActive(true)
    end
        Util.SetLocalPos(go, self:TransferWorldToLocal(info.position))

--    go.transform.localPosition = self:TransferWorldToLocal(info.position)
    local label = UIUtil.GetChildByName(go.transform, "UILabel", "Label")
    label.text = info.name
end
