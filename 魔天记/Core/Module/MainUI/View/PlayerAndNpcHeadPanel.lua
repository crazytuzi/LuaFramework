require "Core.Module.Common.UIComponent"
require "Core.Module.MainUI.View.Item.BuffItem"

local battleCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_CONFIG);

PlayerAndNpcHeadPanel = class("PlayerAndNpcHeadPanel", UIComponent)
 
function PlayerAndNpcHeadPanel:New()
    self = { };
    setmetatable(self, { __index = PlayerAndNpcHeadPanel });
    return self;
end 
  
function PlayerAndNpcHeadPanel:_Init()
    local trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
    self._trsContent = trsContent
    self._imgIcon = UIUtil.GetChildByName(trsContent.gameObject, "UISprite", "imgIcon");
    self._txtName = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtName");
    self._txtLevel = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtLevel");    
    self._txtHP = UIUtil.GetChildByName(trsContent.gameObject, "UILabel", "txtHP");
    self._sliderHP = UIUtil.GetChildByName(trsContent.gameObject, "UISlider", "sliderHP");
    self._buffPanel = BuffPanel:New(UIUtil.GetChildByName(self._trsContent, "Transform", "trsBuff"))   
    self._imgLevelBg = UIUtil.GetChildByName(trsContent,"UISprite","levelBg")
    SetUIEnable(self._trsContent,false);
    self._blActive = false;
    self._timer = Timer.New( function(val) self:_OnUpdata(val) end, 0.1, -1, false);
    self._timer:Start();
    self._target = nil;

    self._onToggle = function(go) self:ShowPlayerInfo() end
    UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggle);
end

function PlayerAndNpcHeadPanel:ShowPlayerInfo()
    if self._target and self._target.__cname == "PlayerController" then
        ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, { pid = self._target.id })
    end
end

function PlayerAndNpcHeadPanel:AlwayHide(blHide)
    if (blHide) then
        SetUIEnable(self._trsContent,false);
        self._timer:Pause(true);
    else
        if (self._blActive) then
            SetUIEnable(self._trsContent,true);
        end
        self._timer:Pause(false)
    end
end

function PlayerAndNpcHeadPanel:_OnUpdata()
    local target = HeroController.GetInstance().target;
    if (target == nil or not self:_IsShowByRole(target)) then
        if (self._blActive) then
            self._blActive = false
            self._blVested = false
            SetUIEnable(self._trsContent,false);
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
        self._blVested = false
        self._txtLevel.text = GetLv(info.level);
      
        self._imgLevelBg.spriteName = info.level <= 400 and "levelBg1" or "levelBg2"
        self._vested = "";
        self._imgIcon.spriteName = info["icon_id"]
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

    if (target.vested and target.vested ~= "") then
        if (self._vested ~= target.vested) then
            self._vested = target.vested
        end
        if (not self._blVested) then
            self._blVested = true;
            self._txtVested.gameObject:SetActive(true);
        end
    else
        if (self._blVested) then
            self._blVested = false;
            -- self._txtVested.text = "";
            self._txtVested.gameObject:SetActive(false);
        end
    end

    if (not self._blActive) then
        self._blActive = true
        SetUIEnable(self._trsContent,true);
    end
    self._buffPanel:Update();
end

function PlayerAndNpcHeadPanel:_IsShowByRole(role)
    if (role) then
        if (role.roleType == ControllerType.MONSTER) then
            return false;
        end
        return true
    end
    return false;
end

function PlayerAndNpcHeadPanel:_Dispose()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (self._buffPanel) then
        self._buffPanel:Dispose();
        self._buffPanel = nil;
    end
end