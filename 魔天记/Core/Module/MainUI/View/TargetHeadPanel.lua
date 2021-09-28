require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.BuffItem"

local battleCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG);

TargetHeadPanel = class("TargetHeadPanel", UIComponent)
 
function TargetHeadPanel:New()
    self = { };
    setmetatable(self, { __index = TargetHeadPanel });
    return self;
end 
  
function TargetHeadPanel:_Init()
    local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
    self._trsContent = trsContent
    self._imgIcon = UIUtil.GetChildByName(trsContent.gameObject, "UISprite", "imgBackground");
    self._txtName = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtName");
    self._txtLevel = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtLevel");    
    self._txtHP = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtHP");
    self._sliderHP = UIUtil.GetChildByName(trsContent.gameObject, "UISlider", "sliderHP");
    self._buffPanel = BuffPanel:New(UIUtil.GetChildByName(self._trsContent, "Transform", "trsBuff"))

    SetUIEnable(self._trsContent, false);
    self._blActive = false;
    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.1, -1, false);
    self._timer:Start();
    self._target = nil;

    self._onToggle = function(go) self:ShowPlayerInfo() end
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggle);
end

function TargetHeadPanel:ShowPlayerInfo()
    if self._target and self._target.__cname == "PlayerController" then
        ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, { pid = self._target.id })
    end
end

function TargetHeadPanel:AlwayHide(blHide)
    if (blHide) then
        SetUIEnable(self._trsContent, false);
        self._timer:Pause(true);
    else
        if (self._blActive) then
            SetUIEnable(self._trsContent, true);
        end
        self._timer:Pause(false)
    end
end

function TargetHeadPanel:_OnUpdata()
    local target = HeroController.GetInstance().target;
    if (target == nil or not self:_IsShowByRole(target)) then
        if (self._blActive) then
            self._blActive = false
            --self._blVested = false            
            SetUIEnable(self._trsContent, false);
            self._target = nil;
            self._buffPanel:SetRole(nil);
        end
        return;
    end

    local info = target.info;
    local attrInfo = target:GetInfo()
    local hpRatio = 1
    if (self._target ~= target) then
        self._target = target        
        self._txtLevel.text = GetLvDes1(info.level);
        -- self._imgIcon.spriteName = info["icon_id"]
        if (target.roleType == ControllerType.PLAYER or target.roleType == ControllerType.HERO) then
            local map = GameSceneManager.map;
            if (map and map.info and map.info.type == InstanceDataManager.MapType.ArathiWar) then
                if (target.info.camp == 1) then
                    self._txtName.text = battleCfg[1].camp1_name;
                else
                    self._txtName.text = battleCfg[1].camp2_name;
                end
            else
                self._txtName.text = info.name;
            end
        else
            self._txtName.text = info.name;
        end
        self._buffPanel:SetRole(target);
    end

    if attrInfo.hp and attrInfo.hp_max then hpRatio = attrInfo.hp / attrInfo.hp_max end
    if (hpRatio ~= self._sliderHP.value) then
        self._sliderHP.value = hpRatio;
    end
    if (info.hp and attrInfo.hp_max) then
        self._txtHP.text = info.hp .. "/" .. info.hp_max;
    end
    if (not self._blActive) then
        self._blActive = true
        SetUIEnable(self._trsContent, true);
    end
    self._buffPanel:Update();
end

function TargetHeadPanel:_IsShowByRole(role)
    if (role and role.roleType == ControllerType.MONSTER) then
        local info = role.info;
        if (info.type == 2 or info.type == 3 or info.type == 4 or info.type == 5 or info.type == 6) then
            return false;
        end
        return true
    end
    return false;
end

function TargetHeadPanel:_Dispose()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._buffPanel) then
        self._buffPanel:Dispose();
        self._buffPanel = nil;
    end
end