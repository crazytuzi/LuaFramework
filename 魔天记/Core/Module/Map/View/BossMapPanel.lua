require "Core.Module.Common.Panel"
local FieldMapItem = require "Core.Module.Map.View.Item.FieldMapItem"

local BossMapPanel = class("BossMapPanel", Panel);
local sin = math.sin(math.rad(45))
local cos = math.cos(math.rad(45))
local rsin = math.sin(math.rad(-45))
local rcos = math.cos(math.rad(-45))
local redColor = Color.New(1, 75 / 255, 75 / 255)
local greenColor = Color.New(156 / 255, 255, 148 / 255)
local rad = 45
local insert = table.insert

function BossMapPanel:New()
    self = { };
    setmetatable(self, { __index = BossMapPanel });
    return self
end 

function BossMapPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function BossMapPanel:_MoveEnd()
    Util.SetLocalPos(self._trsTarget, 65535, 65535, 0)
end

function BossMapPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._btnWorldMap = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnWorldMap");
    self._txtMapName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMapName");
    self._imgMap = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgMap");
    self._goNpc = UIUtil.GetChildByName(self._trsContent, "Transform", "trsNpc").gameObject;
    self._trsTarget = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTarget")
    self._trsPlayer = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPlayer");
    UIUtil.AddChild(self._imgMap.transform, self._trsPlayer)
    UIUtil.AddChild(self._imgMap.transform, self._trsTarget)

    self.btnGo = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGo");
    self.trsDes = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDes");
    self.txtatt = UIUtil.GetChildByName(self.trsDes, "UILabel", "txtatt");
    self.txtdef = UIUtil.GetChildByName(self.trsDes, "UILabel", "txtdef");
    self.txtexp = UIUtil.GetChildByName(self.trsDes, "UILabel", "txtexp");
    UIUtil.AddChild(self._imgMap.transform, self.trsDes)
    self.btnGo.gameObject:SetActive(false)
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, FieldMapItem)
    self:_MoveEnd()
    Util.SetLocalPos(self.trsDes, 65535, 65535, 0)
end

function BossMapPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickMap = function(go) self:_OnClickMap(self) end
    UIUtil.GetComponent(self._imgMap.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMap);
    self._onClickBtnWorldMap = function(go) self:_OnClickBtnWorldMap(self) end
    UIUtil.GetComponent(self._btnWorldMap, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnWorldMap);
    self._onClickBtnCb = function(go) self:_OnClickBtnCb(self) end
    UIUtil.GetComponent(self.btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCb);
end

function BossMapPanel:_OnClickBtnCb()
    if not MapProxy.selectItem then return end
    self._hero:MoveTo(MapProxy.selectItem.position, self._map.id)
    --Warning(tostring(self._hero:IsAutoFight()) ..  '___' .. tostring(self._map.id))
    MapProxy.SetFightFlg(true)
    ModuleManager.SendNotification(MapNotes.CLOSE_BOSS_MAP_PANEL)
    ModuleManager.SendNotification(ActivityNotes.CLOSE_ACTIVITY)
end

function BossMapPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MapNotes.CLOSE_BOSS_MAP_PANEL)
end

function BossMapPanel:_OnClickBtnWorldMap()
    ModuleManager.SendNotification(MapNotes.OPEN_MAPWORLDPANEL)
end


function BossMapPanel:_OnClickMap()
    BusyLoadingPanel.CheckAndStopLoadingPanel();
    if GameSceneManager.map.info.id ~= self._map.id then return end --不在当前地图
    local pos = self._imgMap.transform:InverseTransformPoint(UICamera.lastWorldPosition)
    local posRate = Vector3(pos.x / self._imgMap.width, 0, pos.y / self._imgMap.height)
    local result = self:TransferLocalToWorld(posRate)
    Util.SetLocalPos(self._trsTarget, pos.x, pos.y, pos.z)
    self._hero:MoveTo(result, self._map.id)
end


function BossMapPanel:_Dispose()
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SELFMOVEEND, BossMapPanel._MoveEnd)

    self:_DisposeListener();
    self:_DisposeReference();
    self._phalanx:Dispose()
    self._phalanx = nil

end


function BossMapPanel:TransferLocalToWorld(posRate)
    local result = Vector3(math.round((self._map.mapXSize * posRate.x) + self._map.offsetX), 0, math.round((self._map.mapYSize * posRate.z) + self._map.offsetY))
    result = Vector3(result.x * rcos + result.z * rsin, 0, result.z * rcos - result.x * rsin)
    return result
end

function BossMapPanel:TransferWorldToLocal(pos)
    local result = Vector3((((pos.x * cos + pos.z * sin) - self._map.offsetX) / self._map.mapXSize) * self._imgMap.width,
    (((pos.z * cos - pos.x * sin) - self._map.offsetY) / self._map.mapYSize) * self._imgMap.height, 0)

    return result
end

function BossMapPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._imgMap.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickMap = nil;
    UIUtil.GetComponent(self._btnWorldMap, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnWorldMap = nil;
    UIUtil.GetComponent(self.btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCb = nil;
end

function BossMapPanel:_DisposeReference()
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
end

function BossMapPanel:SetData(info)
    self:UpdateMapPanel(info)
    MessageManager.AddListener(PlayerManager, PlayerManager.SELFMOVEEND, BossMapPanel._MoveEnd, self)
    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.1, -1, false);
    self._timer:Start();
end
function BossMapPanel:UpdateMapPanel(info)
    self._map = info or MapProxy.GetPlayerField()

    self._mainTexturePath = "map/" .. self._map.minimap;
    local tex = UIUtil.GetTexture(self._mainTexturePath)
    if (tex == nil) then
        self._mainTexturePath = "map/10005"
        tex = UIUtil.GetTexture(self._mainTexturePath)
    end
    self._imgMap.mainTexture = tex

    local monsterInfoes = MapProxy.GetFieldMonsters(self._map.id, ConfigManager.CONFIGNAME_VIP_WILDBOSS)
    local mapItemInfoes = { }
    local selectmonster
    local plev = PlayerManager.GetPlayerLevel()
    for i = #monsterInfoes, 1, -1 do
        local v = monsterInfoes[i]
        v.panel = self
        insert(mapItemInfoes, 1, v)
        if v.type == MonsterInfoType.NORMAL then
            if not selectmonster then selectmonster = v end
            if v.lev <= plev and v.lev > selectmonster.lev then
                selectmonster = v
            end
        end
    end
    if not info and selectmonster then selectmonster.seleted = true end --时常进入才默认选择
    self._phalanx:Build(table.getCount(mapItemInfoes), 1, mapItemInfoes)

    self._hero = HeroController:GetInstance()
    self._txtMapName.text = self._map.name
    for k, v in pairs(monsterInfoes) do
        local npcTemp = NGUITools.AddChild(self._imgMap.gameObject, self._goNpc)
        self:SetOther(npcTemp, v)
    end
end

function BossMapPanel:_OnUpdata()
    if GameSceneManager.map and GameSceneManager.map.info.id ~= self._map.id then return end --不在当前地图
    if (self._hero) then
        Util.SetLocalPos(self._trsPlayer, self:TransferWorldToLocal(self._hero.transform.position))
        self._trsPlayer.localRotation = Quaternion.Euler(0, 0, - self._hero.transform.eulerAngles.y - rad)
    end
end

function BossMapPanel:SetOther(go, info)
    go:SetActive(true)
    Util.SetLocalPos(go, self:TransferWorldToLocal(info.position))
    local label = UIUtil.GetChildByName(go.transform, "UILabel", "Label")
    label.text = info.isBoss and "[ff0000]" .. info.name or "[34e0ff]" .. info.name
end

function BossMapPanel:SelectItem(d)
    MapProxy.selectItem = d
    self.btnGo.gameObject:SetActive(true)
    local att = d.att
    self.txtatt.color = att > PlayerManager.GetSelfFightPower() and redColor or greenColor
    self.txtatt.text = LanguageMgr.Get("map/FieldMapPanel/recAtt",{ n  = att })
    local def = d.def
    if #def > 0 then
        -- local herodef = def[2] == 1 and PlayerManager.GetSelfPhyDef() or PlayerManager.GetSelfMagDef()
        local herodef = PlayerManager.GetSelfPhyDef()
        self.txtdef.color = def[1] > herodef and redColor or greenColor
        self.txtdef.text = LanguageMgr.Get("map/FieldMapPanel/recDef",{ n  = def[1] })
    else
        self.txtdef.color = greenColor
        self.txtdef.text = LanguageMgr.Get("map/FieldMapPanel/recDef",{ n  = 0 })
    end
    self.txtexp.text = LanguageMgr.Get("map/FieldMapPanel/exp",{ n  = d.exp })
    local pos = self:TransferWorldToLocal(d.position)
    Util.SetLocalPos(self.trsDes, pos)
    Util.SetLocalPos(self._trsTarget, pos)
end

return BossMapPanel