require "Core.Module.Common.UIComponent"
require "Core.Module.Common.TitleItem"
RoleNameSimple = class("RoleNameSimple", UIComponent)

local battleCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG);
local DEFAULT_COLOR = Color.New(1, 1, 1, 1);
 -- 宠物筛选
local filterType = { "HeroPetController", "PetController", "HeroPuppetController", "PuppetController" }
local outScreenPos = Vector3(-1000, -1000, 0)
local roleParent

function RoleNameSimple:New(role)
    self = { };
    setmetatable(self, { __index = RoleNameSimple });
    self:_LoadUI();
    self:_SetRole(role);
    return self;
end

function RoleNameSimple:_GetUIPath()
    return ResID.UI_ROLENAMESIMPLE
end
function RoleNameSimple:_LoadUI()
    if not roleParent then roleParent = Scene.instance.uiNameParent end
    local ui = UIUtil.GetUIGameObject(self:_GetUIPath(), roleParent)
    self:Init(ui.transform);
    Util.SetLocalPos(self._transform, outScreenPos.x, outScreenPos.y, outScreenPos.z)
    self._hideing = true
end
function RoleNameSimple:_Init()
    self._txtName = UIUtil.GetComponent(self._gameObject, "UILabel");
end

function RoleNameSimple:_SetRole(role)
    if (role) then
        self._role = role;
        role.namePanel = self;
        self:RefreshRoleName();
        self:RefreshRoleCamp();
        if (table.contains(filterType, self._role.__cname)) then
            if (self._role:GetIsHide()) then
                self._role:SetRoleNamePanelAbsActive(false)
            end
        end
        self._role:SetRoleNamePanelActive(AutoFightManager.GetBaseSettingConfig().showName);
        self:_OnSetRole(role)
    end
end
function RoleNameSimple:_OnSetRole(role)
end

function RoleNameSimple:RefreshRoleCamp()

end

function RoleNameSimple:RefreshRoleName()
    local role = self._role;
    local map = GameSceneManager.map;
    if (role) then
        if role.roleType == ControllerType.MONSTER and role.info.owner and role.info.owner == PlayerManager.playerId then
            self._txtName.text = LanguageMgr.Get("task/escort/name", { a = PlayerManager.GetPlayerInfo().name, b = role.info.name });
        else
            if (map and map.info and map.info.type == InstanceDataManager.MapType.ArathiWar and(role.roleType == ControllerType.PLAYER or role.roleType == ControllerType.HERO)) then
                if (role.info.camp == 1) then
                    self._txtName.text = battleCfg[1].camp1_name;
                else
                    self._txtName.text = battleCfg[1].camp2_name;
                end
            else
                self._txtName.text = role.info.name;
            end
        end
        self:_RefreshNameColor()
        self:_RefreshNamePos()
    end
end
function RoleNameSimple:_RefreshNamePos()
    
end
function RoleNameSimple:_RefreshNameColor()
    if (self._role and self._role.info and self._txtName) then
        local rType = self._role.roleType;
        if (rType == ControllerType.MONSTER) then
            self._txtName.color = ColorDataManager.GetMonsterNameColor();
        elseif (rType == ControllerType.PET or rType == ControllerType.HEORPET) then
            self._txtName.color = ColorDataManager.GetPetNameColor()
        elseif (rType == ControllerType.NPC) then
            self._txtName.color = ColorDataManager.GetNPCNameColor();
        else
            self._txtName.color = DEFAULT_COLOR;
        end
        if TabooProxy.InTaboo() and TabooProxy.CanAttack(self._role) then
            self._txtName.color = ColorDataManager.GetPkRed()
        end
    end
end

function RoleNameSimple:_OnTimerHandler()
    local role = self._role
    if role then
        self:TracePos(role)
   end
end
function RoleNameSimple:TracePos(role)
    if not role.visible then
        if not self._hideing then
            Util.SetLocalPos(self._transform, outScreenPos.x, outScreenPos.y, outScreenPos.z)
            self._hideing = true
        end
    else
        if not self.tempTop then
            self.tempTop = role:HasNamePoint()
            if not self.tempTop then return end
        end
	 
        UIUtil.WorldToUI(self._transform, self.tempTop, 0.4)
        if self._hideing then self._hideing = false end
    end
end

function RoleNameSimple:_Dispose()
    if self._dispose then return end
    self._txtName = nil
    if self._role then
        self._role.namePanel = nil
        self._role = nil
    end
    Resourcer.Recycle(self._gameObject, true)
end
