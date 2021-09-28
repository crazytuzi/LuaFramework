require "Core.Module.Common.UIComponent"
require "Core.Module.Common.TitleItem"

local AutoFightPathCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_AUTO_FIGHT_PATH);

local CheckRadius = 6;

FBNavigationPanel = class("FBNavigationPanel", UIComponent);
local insert = table.insert

function FBNavigationPanel:New()
    self = { };
    setmetatable(self, { __index = FBNavigationPanel });
    return self
end

function FBNavigationPanel:GetUIOpenSoundName( )
    return ""
end

function FBNavigationPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._waitTime = 2;
end

function FBNavigationPanel:_InitReference()
    self._imgArrow = UIUtil.GetChildByName(self._gameObject, "Transform", "imgArrow");
    --self._txtLabel = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtLabel");
    self._timer = Timer.New( function(val) self:_OnTimerHandler(val) end, 0, -1, false);
end

function FBNavigationPanel:_InitListener()
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, self._SceneStartHandler, self);
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END, self._SceneEndHandler, self);
end

function FBNavigationPanel:_SceneStartHandler()
    local mapInfo = GameSceneManager.map.info;
    if (mapInfo) then
        local id = mapInfo.id;
        self:_InitPath(id)

        if (self._path) then
            self._timer:Start();
        end
    end
end

function FBNavigationPanel:_SceneEndHandler()
    self._timer:Stop()
    self:SetActive(false);
end

function FBNavigationPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end
end

function FBNavigationPanel:_DisposeListener()
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, self._SceneStartHandler, self);
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END, self._SceneEndHandler, self);
end

function FBNavigationPanel:_DisposeReference()
    self._imgArrow = nil;
end

function FBNavigationPanel:_OnTimerHandler()    
    if (self._waitTime > 0) then
        self._waitTime = self._waitTime - 0.1;
        return;
    end
    local hero = HeroController.GetInstance();
    local index = self._currIndex;
    if (hero.transform and(not hero:IsDie())) then
        local target = hero.target;
        local tmpIndex = self:_GetNearIndex();
        local heroPos = hero.transform.position;
        local toPos = self._path[index];
        if (tmpIndex < index) then
            index = tmpIndex + 1
            self._currIndex = index;
            toPos = self._path[index];
        else
            if (Vector3.Distance2(heroPos, toPos) < CheckRadius) then
                --self._InPoints[index] = true
                index = index + 1;
                self._currIndex = index;
                toPos = self._path[index];
            end
        end
        --self._txtLabel.text = index;
        if (target == nil or target == hero or target == hero.pet or target == hero.puppet) then
            if (self:_CheckHasMonster()) then
                if (index > 0 and index <= #self._path) then
                    if (self._isActive == false) then
                        self:SetActive(true);
                    end
                else
                    if (self._isActive == true) then
                        self:SetActive(false);
                    end
                end
            else
                if (self._isActive == true) then
                    self:SetActive(false);
                end
            end
        else
            if (self._isActive == true) then
                self:SetActive(false);
            end
        end

        if (self._isActive) then
            local sa = math.atan2(toPos.x - heroPos.x, toPos.z - heroPos.z);
            local topt = Vector3.New();
            topt.z = heroPos.z + 0.5 * math.cos(sa);
            topt.x = heroPos.x + 0.5 * math.sin(sa);  
            topt.y = heroPos.y;          
            local viewHpt = UIUtil.WorldToUI(heroPos);
            local viewTpt = UIUtil.WorldToUI(topt);
            local a = math.atan2(viewTpt.y - viewHpt.y, viewTpt.x - viewHpt.x);
            --Util.SetPos(self._transform,viewHpt.x,viewHpt.y,viewHpt.z)
--            self._transform.position = viewHpt;
            viewHpt.x = 300 * math.cos(a);
            viewHpt.y = 50 + 180 * math.sin(a);
            self._imgArrow.localPosition = viewHpt
            self._imgArrow.rotation = Quaternion.Euler(0, 0,(a * 180.0 / math.pi) -90);

            --Warning(">>>>> 2 > sa:"..sa.." a:"..(a * 180.0 / math.pi))
        end
    else
        if (self._isActive == true) then
            self:SetActive(false);
        end
        self._waitTime = 2;
    end
end

function FBNavigationPanel:_CheckHasMonster()
    local mons = GameSceneManager.map:GetAllRoles(ControllerType.MONSTER);
    local count = table.getCount(mons);
    if (count > 0) then
        local d = 9999999;
        local hero = HeroController.GetInstance();
        local hPT = hero.transform.position
        for i, v in pairs(mons) do
            if (v and v.transform) then
                if Vector3.Distance2(hPT,v.transform.position) < 4 then
                    return false;
                end
            end             
        end
    end
    return true
end

function FBNavigationPanel:_InitPath(id)
    local path = { };
    local i = 1;
    local item = AutoFightPathCfg[id .. "_" .. i];
    local radius = 0;

    while item do
        local pt = Vector3.New(item.pos_x / 100, item.pos_y / 100, item.pos_z / 100);
        pt = MapTerrain.SampleTerrainPosition(pt);
        path[i] = pt
        if (i > 1) then
            local d = Vector3.Distance2(pt, path[i - 1]);
            if (d > radius) then
                radius = d;
            end
        end

--        local ss = Resourcer.Get("Effect", "sssssss")
--        if (ss) then
--            ss.transform.position = MapTerrain.SampleTerrainPosition(pt);
--        end

        i = i + 1;
        item = AutoFightPathCfg[id .. "_" .. i];
    end
    if (#path > 1) then
        insert(path, 1, HeroController.GetInstance().transform.position);
        self._path = path;
        --self._currIndex = self:_GetNearIndex();
        self._currIndex = 2;
        --self._InPoints[1] = true
    else
        self._path = nil;
        -- self._checkRadius = nil;
        -- self._InPoints = nil;
    end
end

function FBNavigationPanel:_GetNearIndex()
    local index = 0;
    if (self._path) then
        local max = 999999999;
        local hero = HeroController.GetInstance();
        if (hero and hero.transform) then
            local rolePt = hero.transform.position;
            for i, v in ipairs(self._path) do
                local d = Vector3.Distance2(rolePt, v);
                if (d < max) then
                    index = i;
                    max = d;
                end
            end
        end
    end
    return index;
end