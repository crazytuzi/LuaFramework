require "Core.Module.Common.Panel"
require "Core.Module.Map.View.Item.ArathiMapListItem"

ArathiMapPanel = class("ArathiMapPanel", Panel);
local sin = math.sin(math.rad(45))
local cos = math.cos(math.rad(45))
local rsin = math.sin(math.rad(-45))
local rcos = math.cos(math.rad(-45))
local rad = 45

local CampColor =
{
    [0] = Color.New(255 / 255,255 / 255,255 / 255),
    [1] = Color.New(255 / 255,75 / 255,64 / 255),
    [2] = Color.New(98 / 255,210 / 255,255 / 255)
}
local insert = table.insert

function ArathiMapPanel:New()
    self = { };
    setmetatable(self, { __index = ArathiMapPanel });
    return self
end 

function ArathiMapPanel:_Init()
    self._hero = HeroController:GetInstance()
    self._camp = self._hero.info.camp;
    self:_InitReference();
    self:_InitListener();
    self:UpdateArathiMapPanel()
    self:_InitPoints();
    self:_InitAllPlayers();

    MessageManager.AddListener(PlayerManager, PlayerManager.SELFMOVEEND, ArathiMapPanel._MoveEnd, self)
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_ADD_ROLE, self._AddRoleHandler, self);
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_REMOVE_ROLE, self._RemoveRoleHandler, self);
    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.1, -1, false);
    self._timer:Start();
end



function ArathiMapPanel:_MoveEnd()
    Util.SetLocalPos(self._trsTarget, 65535, 65535, 0)

    --    self._trsTarget.localPosition = Vector3(65535, 65535, 0)
end

function ArathiMapPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._txtMapName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMapName");
    self._imgMap = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgMap");
    self._goNpc = UIUtil.GetChildByName(self._trsContent, "Transform", "trsNpc").gameObject;
    self._goPortal = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPortal").gameObject;
    self._trsPlayer = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPlayer").gameObject;
    self._trsPoint = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPoint").gameObject;
    self._trsTarget = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTarget");
    self._trsHero = UIUtil.GetChildByName(self._trsContent, "Transform", "trsHero");


    UIUtil.AddChild(self._imgMap.transform, self._trsHero)
    UIUtil.AddChild(self._imgMap.transform, self._trsTarget)
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, ArathiMapListItem)
    self._npcs = { }
    self._goNpc:SetActive(false)
    self._goPortal:SetActive(false)
    self._trsPlayer:SetActive(false)
    self._trsPoint:SetActive(false)
    Util.SetLocalPos(self._trsTarget, 65535, 65535, 0)

    --    self._trsTarget.localPosition = Vector3(65535, 65535, 0)
end

function ArathiMapPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickMap = function(go) self:_OnClickMap(self) end
    UIUtil.GetComponent(self._imgMap.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMap);
end

function ArathiMapPanel:_InitPoints()
    local points = GameSceneManager.map.battlefieldPoints;
    self._pointItems = { };
    if (points) then
        for i, v in pairs(points) do
            local info = v.info;
            if (info.type == 1 or info.type == 3 or info.type == 4) then
                local pItem = { };
                local go = NGUITools.AddChild(self._imgMap.gameObject, self._trsPoint);
                local label = UIUtil.GetChildByName(go.transform, "UILabel", "label");
                local image = go:GetComponent("UISprite");
                pItem.go = go;
                pItem.image = image;
                pItem.label = label;
                pItem.camp = info.camp
                pItem.isValid = v:IsValid();
                label.text = info.name
                label.color = ColorDataManager.GetCampColor(info.camp)
                go:SetActive(pItem.isValid);
                Util.SetLocalPos(go, self:TransferWorldToLocal(v.info.position))

                --                go.transform.localPosition = self:TransferWorldToLocal(v.info.position);
                self._pointItems[info.id] = pItem;
            end
        end
    end
end

function ArathiMapPanel:_InitAllPlayers()
    local pls = GameSceneManager.map:GetAllRoles(ControllerType.PLAYER);
    self._players = { };
    self._playerItems = { }
    for i, v in pairs(pls) do
        self:_AddRole(v)
    end
    self:_RefreshList(true);
end

function ArathiMapPanel:_RefreshList(blInit)
    local pls = { };
    for i, v in pairs(self._players) do
        if (v.info.camp == self._camp) then
            insert(pls, v);
        end
    end
    if (blInit) then
        insert(pls, self._hero);
    end
    self._phalanx:Build(table.getCount(pls), 1, pls);
end


function ArathiMapPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MapNotes.CLOSE_ARATHIMAPPANEL)
end

function ArathiMapPanel:_OnClickMap()
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


function ArathiMapPanel:_Dispose()
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFMOVEEND, ArathiMapPanel._MoveEnd)
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_ADD_ROLE, self._AddRoleHandler);
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_REMOVE_ROLE, self._RemoveRoleHandler);
    self:_DisposeListener();
    self:_DisposeReference();
    self._phalanx:Dispose()
    self._phalanx = nil

end

function ArathiMapPanel:_AddRole(role)
    if (role.info.camp == self._camp) then
        local id = role.id;
        local pItem = NGUITools.AddChild(self._imgMap.gameObject, self._trsPlayer);
        local sp = pItem:GetComponent("UISprite");
        sp.spriteName = "camp" .. role.info.camp;
        pItem:SetActive(true)
        self._players[id] = role;
        self._playerItems[id] = pItem;
    end
end

function ArathiMapPanel:_RemoveRole(role)
    local id = role.id;
    self._players[id] = nil;
--    if (self._playerItems[id]) then
    if not IsNil(self._playerItems[id]) then
        GameObject.Destroy(self._playerItems[id])
        self._playerItems[id] = nil;
    end
end

function ArathiMapPanel:_AddRoleHandler(role)
    if (role) then
        if (role.info.camp == self._camp) then
            self:_AddRole(role);
            self:_RefreshList();
        end
    end
end

function ArathiMapPanel:_RemoveRoleHandler(role)
    if (role) then
        self:_RemoveRole(role)
        if (role.info.camp == self._camp) then
            self:_RefreshList();
        end
    end
end


function ArathiMapPanel:TransferLocalToWorld(posRate)
    local result = Vector3(math.round((self._map.info.mapXSize * posRate.x) + self._map.info.offsetX), 0, math.round((self._map.info.mapYSize * posRate.z) + self._map.info.offsetY))
    result = Vector3(result.x * rcos + result.z * rsin, 0, result.z * rcos - result.x * rsin)
    return result
end

function ArathiMapPanel:TransferWorldToLocal(pos)
    local result = Vector3((((pos.x * cos + pos.z * sin) - self._map.info.offsetX) / self._map.info.mapXSize) * self._imgMap.width,
    (((pos.z * cos - pos.x * sin) - self._map.info.offsetY) / self._map.info.mapYSize) * self._imgMap.height, 0)

    return result
end

function ArathiMapPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._imgMap.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMap = nil;
end

function ArathiMapPanel:_DisposeReference()
    self._btn_close = nil;
    if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
    -- self._imgMap.mainTexture = nil
    self._imgMap = nil
    self._hero = nil
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    self._map = nil
    self._npcs = { }
end

function ArathiMapPanel:UpdateArathiMapPanel()
    self._map = GameSceneManager.map
    self._mainTexturePath = "map/" .. self._map.info.minimap;
    self._imgMap.mainTexture = UIUtil.GetTexture(self._mainTexturePath)


    local npcInfoes = GameSceneManager.map:GetCurNpcInfoes()
    local portalInfoes = GameSceneManager.map:GetCurPortalInfoes()

    if (self._map) then
        self._txtMapName.text = self._map.info.name
        for k, v in pairs(npcInfoes) do
            local npcTemp = NGUITools.AddChild(self._imgMap.gameObject, self._goNpc)
            insert(self._npcs, npcTemp)
            self:SetOther(npcTemp, v, false)
        end

        for k, v in pairs(portalInfoes) do
            local portalTemp = NGUITools.AddChild(self._imgMap.gameObject, self._goPortal)
            self:SetOther(portalTemp, v, false)
        end
    end
end

function ArathiMapPanel:_OnUpdata()
    local items = self._phalanx:GetItems();
    for i, v in pairs(items) do
        v.itemLogic:Refresh();
    end

    local points = GameSceneManager.map.battlefieldPoints;
    if (points) then
        for i, v in pairs(points) do
            local info = v.info;
            local pItem = self._pointItems[info.id];
            if (pItem) then
                if (pItem.camp ~= info.camp) then
                    pItem.camp = info.camp;
                    pItem.label.color = ColorDataManager.GetCampColor(info.camp)
                end
                if (pItem.isValid ~= v:IsValid()) then
                    pItem.isValid = v:IsValid();
                    pItem.go:SetActive(pItem.isValid)
                end
            end
        end
    end

    if (self._hero) then
        Util.SetLocalPos(self._trsHero, self:TransferWorldToLocal(self._hero.transform.position))

        --        self._trsHero.localPosition = self:TransferWorldToLocal(self._hero.transform.position)
        self._trsHero.localRotation = Quaternion.Euler(0, 0, - self._hero.transform.eulerAngles.y - rad)
    end
    for i, v in pairs(self._players) do
        local role = self._players[i];
        local item = self._playerItems[i];
        Util.SetLocalPos(item, self:TransferWorldToLocal(role.transform.position))
        --        item.transform.localPosition = self:TransferWorldToLocal(role.transform.position);
    end
end

function ArathiMapPanel:SetOther(go, info, isNpc)
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
