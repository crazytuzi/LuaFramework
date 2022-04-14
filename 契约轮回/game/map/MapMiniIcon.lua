--
-- @Author: LaoY
-- @Date:   2018-11-28 15:48:03
--
MapMiniIcon = MapMiniIcon or class("MapMiniIcon", BaseCloneItem)
local MapMiniIcon = MapMiniIcon

function MapMiniIcon:ctor(obj, parent_node, layer)
    MapMiniIcon.super.Load(self)
end

function MapMiniIcon:dctor()
end

function MapMiniIcon:LoadCallBack()
    self.nodes = {
        "icon",
        "text_bg",
        "text_bg/Text"
    }
    self:GetChildren(self.nodes)
    self.icon_component = self.icon:GetComponent("Image")
    self.text_component = self.Text:GetComponent("Text")
    self:AddEvent()
end

function MapMiniIcon:AddEvent()
    local function call_back(target, x, y)
        if self.data.isCfg then
            GlobalEvent:Brocast(MainEvent.MapTouchIcon, self.data.uid, self.data.coord, true,true,self.index)
            return
        end
        
        if self.data.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
            return
        end
        GlobalEvent:Brocast(MainEvent.MapTouchIcon, self.data.uid, self.data.coord, true)
    end
    AddClickEvent(self.icon.gameObject, call_back)
end

function MapMiniIcon:SetRes(res)
    if self.res == res then
        return
    end
    local abName = "map_image"
    self.res = res
    local function call_back(sprite)
        self.icon_component.sprite = sprite
        self.icon_component:SetNativeSize()
        local height = GetSizeDeltaY(self.icon)
        SetLocalPositionY(self.text_bg, height * 0.5 + 18)
    end
    lua_resMgr:SetImageTexture(self, self.icon_component, abName, res, false, call_back)
end

function MapMiniIcon:SelectIcon(id)
    self.is_select = self.data.uid == id
    self:UpdateRes()
end
function MapMiniIcon:SelectCfgIcon(index)
    self.is_select = self.index == index
    self:UpdateRes()
end


function MapMiniIcon:UpdateRes()
    local data = self.data
    if not data then
        return
    end

    if (self.sceneType and self.sceneType == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR) then
        self:UpdateGuildBattleRes(data)
    else
        self:UpdateDungeonsRes(data)
    end
end

function MapMiniIcon:UpdateDungeonsRes(data)
    local res

    if data.type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
        res = self.is_select and "img_npc_icon_sel" or "img_npc_icon"
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL then
        res = "img_door_icon"
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        local config = Config.db_creep[data.uid] or {}
        if config.rarity == enum.CREEP_RARITY.CREEP_RARITY_COMM or config.rarity == enum.CREEP_RARITY.CREEP_RARITY_ELITE then
            res = self.is_select and "img_monster_icon_sel" or "img_monster_icon"
        else
            res = self.is_select and "img_boss_icon_sel" or "img_boss_icon"
        end
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
        res = "img_role_icon"
    end
    self:SetRes(res)
end

function MapMiniIcon:UpdateGuildBattleRes(data)

    local dataModel = FactionBattleModel.GetInstance()

    -----Test---
    --dataModel.CrystalInfo[30301001] = 1
    --dataModel.CrystalInfo[30301002] = 2
    --dataModel.CrystalInfo[30301003] = 0
    --dataModel.CrystalInfo[30301004] = 2
    --dataModel.CrystalInfo[30301005] = 1
    -----end---

    local res

    if data.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        local state = dataModel:GetCrystalState(data.uid) --dataModel.CrystalInfo[data.uid] or 0
        if (state == 1) then
            res = "Crystal_Blue"
        elseif state == 2 then
            res = "Crystal_Red"
        else
            res = "Crystal_Gray"
        end
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_BORN then
        if (data.state == 1) then
            res = "Home_Blue"
        elseif data.state == 2 then
            res = "Home_Red"
        end
    end

    self:SetRes(res)
end

function MapMiniIcon:SetData(data, sceneType,scene_type,index)
    self.data = data
    -- 场景s类型
    self.sceneType = sceneType
    -- 场景类型
    self.scene_type = scene_type

    self.index = index

    if (self.sceneType and self.sceneType == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR) then
        self:RefreshGuildBattleName(data)
    else
        self:RefreshDungeonsName(data)
    end

    self:UpdateRes()
end

function MapMiniIcon:RefreshDungeonsName(data)
    if data.type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
        if self.scene_type == SceneConstant.SceneType.City then
            SetVisible(self.text_bg, true)
            local config = Config.db_npc[data.uid]
            local name_str = string.format("<color=#00FFF5>%s</color>", config and config.name or "")
            self.text_component.text = name_str
        else
            SetVisible(self.text_bg, false)
        end
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL then
        SetVisible(self.text_bg, true)
        local config = Config.db_scene[data.target_scene]
        local name_str = string.format("<color=#ffffff>%s</color>", config and config.name or "")
        self.text_component.text = name_str
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        local config = Config.db_creep[data.uid] or {}
        if config.rarity == enum.CREEP_RARITY.CREEP_RARITY_COMM then
            SetVisible(self.text_bg, true)
            local name_str = string.format("<color=#27ee31>%s</color>", config.name)
            self.text_component.text = name_str
        else
            SetVisible(self.text_bg, true)
            local name_str = string.format("<color=#e400ff>%s</color>", config.name or "Elite")
            self.text_component.text = name_str
        end
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
        SetVisible(self.text_bg, false)
    end
end

function MapMiniIcon:RefreshGuildBattleName(data)

    local config = Config.db_creep[data.uid]
    if (not config) then
        SetVisible(self.text_bg, false)
        return
    end

    if data.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        SetVisible(self.text_bg, true)
        local name_str = string.format("<color=#27ee31>%s</color>", config.name)
        self.text_component.text = name_str
    else
        SetVisible(self.text_bg, false)
    end

end