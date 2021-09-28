require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"

WildBossMapItem = class("WildBossMapItem", UIComponent);

local enableColor = Color.New(1, 248 / 255, 141 / 255)
local enableOutLineColor = Color.New(216 / 255, 107 / 255, 0, 50 / 255)
local disableColor = Color.New(183 / 255, 183 / 255, 183 / 255)
local disableOutLineColor = Color.New(20 / 255, 28 / 255, 50 / 255, 50 / 255)

function WildBossMapItem:New(transform, mapInfo)
    self = { };
    setmetatable(self, { __index = WildBossMapItem });
    self.mapInfo = mapInfo;
    self._depth = 0
    if (transform) then
        self:Init(transform);
    end
    return self
end

function WildBossMapItem:_Init()
    self:_InitReference();
    self:_InitListener();
end

function WildBossMapItem:AddClickListener(owner, handler)
    self._owner = owner;
    self._handler = handler;
end

function WildBossMapItem:SetData(data)
    if (self.data == nil and data ~= nil) then
        self._txtMapName.depth = self._txtMapName.depth + 10;
        --self._txtMapLevel.depth = self._txtMapLevel.depth + 10;
        self._imgFrameBg.depth = self._imgFrameBg.depth + 10;
        self._imgIcon.depth = self._imgIcon.depth + 10;
        self._imgFlag.depth = self._imgFlag.depth + 10;
        self._txtName.depth = self._txtName.depth + 10;
    elseif (self.data ~= nil and data == nil) then
        self._txtMapName.depth = self._txtMapName.depth - 10;
        --self._txtMapLevel.depth = self._txtMapLevel.depth - 10;
        self._imgFrameBg.depth = self._imgFrameBg.depth - 10;
        self._imgIcon.depth = self._imgIcon.depth - 10;
        self._imgFlag.depth = self._imgFlag.depth - 10;
        self._txtName.depth = self._txtName.depth - 10;
    end

    self.data = data;
    if (data) then
        data.bossInfo = self:_GetBossData(data.mid);
        data.monsterInfo = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER)[data.mid];
        data.mapInfo = self.mapInfo;
        self._imgFrameBg.gameObject:SetActive(true);
        self._imgIcon.gameObject:SetActive(true);
        self._txtName.gameObject:SetActive(true);
        self._imgFlag.gameObject:SetActive(data.st == 1);

        if (data.st == 1) then
            self:_ClearEffect();
        else
            if (self._effect == nil) then
                self._step = 5;
                FixedUpdateBeat:Add(self.Update, self)
            end
        end
        if (data.monsterInfo) then
            self._imgIcon.spriteName = data.monsterInfo.icon_id;
            self._txtName.text = self:_GetBossType(data.monsterInfo) .. data.monsterInfo.name;
            --self._txtMapLevel.text = data.lv ..  LanguageMgr.Get("WildBoss/info/level");
        end
        if (data.bossInfo) then
            if (data.bossInfo.difficulty == 2) then
                self._txtName.color = ColorDataManager.Get_purple()
            elseif (data.bossInfo.difficulty == 3) then
                self._txtName.color = ColorDataManager.Get_golden()
            else
                self._txtName.color = ColorDataManager.Get_white();
            end
        else
            self._txtName.color = ColorDataManager.Get_white();
        end        
    else
        self:_ClearEffect();
        self._imgFrameBg.gameObject:SetActive(false);
        self._imgIcon.gameObject:SetActive(false);
        self._imgFlag.gameObject:SetActive(false);
        self._txtName.gameObject:SetActive(false);
        --self._txtMapLevel.text = self.mapInfo.lev_show;        
    end
end

function WildBossMapItem:Update()
    self._step = self._step - 1
    if (self._step == 0) then
        self._effect = UIUtil.GetUIEffect("ui_trump_active", self._imgIcon.transform, self._imgIcon, -1);
        FixedUpdateBeat:Remove(self.Update, self)
        self._step = nil;
    end
end

function WildBossMapItem:_ClearEffect()
    if (self._step) then
        FixedUpdateBeat:Remove(self.Update, self)
        self._step = nil;
    end
    if (self._effect) then
        Resourcer.Recycle(self._effect, false);
        self._effect = nil
    end
end

function WildBossMapItem:_GetBossType(info)
    if (info) then
        if (info.type == MonsterInfoType.BOSS or info.type == MonsterInfoType.ELITE) then
            return LanguageMgr.Get("WildBoss/mType" .. info.type)
        end
    end
    return "";
end

function WildBossMapItem:_GetBossData(id)
    local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FIELD_MONSTER);
    if (cfg) then
        for i, v in pairs(cfg) do
            if (v.monster_id == id) then
                return v;
            end
        end
    end
    return nil
end

function WildBossMapItem:_InitReference()
    local mapInfo = self.mapInfo;
    local level = PlayerManager.hero.info.level;
    local sp = UIUtil.GetComponent(self._transform, "UISprite")
    sp.spriteName = mapInfo.map_icon;
    Util.SetLocalPos(self._transform, mapInfo.map_icon_x, mapInfo.map_icon_y, 0)

    --    self._transform.localPosition = Vector3(mapInfo.map_icon_x, mapInfo.map_icon_y, 0);

    self._imgMaplevelbg = UIUtil.GetChildByName(self._transform, "UISprite", "imgMaplevelbg");
    self._txtMapName = UIUtil.GetChildByName(self._transform, "UILabel", "txtMapName");
    self._txtMapName.text = mapInfo.name;
    --self._txtMapLevel = UIUtil.GetChildByName(self._transform, "UILabel", "txtMapLevel");    
    --self._txtMapLevel.text = mapInfo.lev_show;    

    if (level < mapInfo.level) then
        ColorDataManager.SetGray(self._imgMaplevelbg)
        self._txtMapName.color = disableColor
        self._txtMapName.effectColor = disableOutLineColor
        --self._txtMapLevel.color = disableColor
        --self._txtMapLevel.effectColor = disableOutLineColor
    else
        ColorDataManager.UnSetGray(self._imgMaplevelbg)
        self._txtMapName.color = enableColor
        self._txtMapName.effectColor = enableOutLineColor
        --self._txtMapLevel.color = enableColor
        --self._txtMapLevel.effectColor = enableOutLineColor
    end

    self._imgFrameBg = UIUtil.GetChildByName(self._transform, "UISprite", "imgFrameBg");
    self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
    self._imgFlag = UIUtil.GetChildByName(self._transform, "UISprite", "imgFlag");
    self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName");
    self._btn = self._gameObject:GetComponent("UIButton")
end



function WildBossMapItem:_InitListener()
    if (self._btn) then
        self._onClickHandler = function(go) self:_OnClickHandler(self) end
        UIUtil.GetComponent(self._btn, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);
    end
end

function WildBossMapItem:_OnClickHandler()
    if (self._owner and self._handler) then
        self._handler(self._owner, self);
    end
end
  
function WildBossMapItem:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function WildBossMapItem:_DisposeListener()
    UIUtil.GetComponent(self._btn, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil
    self._owner = nil;
    self._handler = nil;
end

function WildBossMapItem:_DisposeReference()
    self:_ClearEffect();
    self.mapInfo = nil;
    self.data = nil;
    self._txtMapName = nil;
    --self._txtMapLevel = nil;
    self._imgFrameBg = nil;
    self._imgIcon = nil;
    self._imgFlag = nil;
    self._txtName = nil;
    self._btn = nil;
end