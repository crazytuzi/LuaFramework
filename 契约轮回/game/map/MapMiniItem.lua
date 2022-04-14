--
-- @Author: LaoY
-- @Date:   2018-11-28 14:42:55
--
MapMiniItem = MapMiniItem or class("MapMiniItem", BaseCloneItem)
local MapMiniItem = MapMiniItem

function MapMiniItem:ctor(obj, parent_node, layer)
    MapMiniItem.super.Load(self)
end

function MapMiniItem:dctor()
    if self.level_item then
        self.level_item:destroy()
        self.level_item = nil
    end
end

function MapMiniItem:LoadCallBack()
    self.nodes = {
        "img_bg", "img_bg/text_name", "img_bg/lv_con", "img_bg/img_fly_icon_1"
    }
    self:GetChildren(self.nodes)

    self.img_bg_component = self.img_bg:GetComponent('Image')
    self.text_name_component = self.text_name:GetComponent('Text')

    _, self.name_y = GetLocalPosition(self.text_name)
    self.assetName = "img_bg_nor"

    self:AddEvent()
end

function MapMiniItem:AddEvent()
    local function call_back(target, x, y)
        self:OnClick()
    end
    AddClickEvent(self.img_bg.gameObject, call_back)

    local function call_back()
        -- Notify.ShowText("小飞鞋功能尚未开放")
        local function call_back()
            local object_type = self.data.type
            if object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
                SceneManager:GetInstance():AttackCreepByTypeId(self.data.uid)
            elseif object_type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
                SceneManager:GetInstance():FindNpc(self.data.uid)
            end
        end
        local scene_id = SceneManager:GetInstance():GetSceneId()
        local fly_pos = self.data.coord
        if self.data.type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
            fly_pos = SceneConfigManager:GetInstance():GetNPCFlyPos(self.data.uid)
        end
        SceneControler:GetInstance():UseFlyShoeToPos(scene_id, fly_pos.x, fly_pos.y, false, call_back)
    end
    AddClickEvent(self.img_fly_icon_1.gameObject, call_back)
end

function MapMiniItem:SetCallBack(call_back)
    self.call_back = call_back
end

function MapMiniItem:OnClick()
    if self.data.isCfg then
        if self.call_back then
            self.call_back(self.index)
        end
        GlobalEvent:Brocast(MainEvent.MapTouchIcon, self.data.uid, self.data.coord, false,true,self.data.index)
        return
    end
    if self.call_back then
        self.call_back(self.index)
    end
    GlobalEvent:Brocast(MainEvent.MapTouchIcon, self.data.uid, self.data.coord, false)
end

function MapMiniItem:SetSelectState(index)
    local bo = self.index == index
    self.is_select = bo
    self:SetRes()
end

function MapMiniItem:SetRes()
    local abName = "map_image"
    local assetName = self.is_select and "img_bg_sel" or "img_bg_nor"
    if self.assetName == assetName then
        return
    end
    self.assetName = assetName
    lua_resMgr:SetImageTexture(self, self.img_bg_component, abName, assetName, false)
end

function MapMiniItem:SetData(index, data)
    self.index = index
    self.data = data
    local name_str = ""
    if data.type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
        SetVisible(self.text_lv, false)
        SetLocalPositionY(self.text_name, self.name_y - 10)
        local config = Config.db_npc[data.uid]
        name_str = config and config.name or "Salia"

    else
        SetVisible(self.text_lv, true)
        SetLocalPositionY(self.text_name, self.name_y)
        local config = Config.db_creep[data.id]
        name_str = config and config.name or "Elite Monster"
        name_str = string.format("<color=#e400ff>%s</color>", name_str)
        local temp_lv = config.level or 1

        if self.level_item then
            self.level_item:destroy()
            self.level_item = nil
        end

        local scene_id = SceneManager:GetInstance():GetSceneId()
        local config = Config.db_scene[scene_id]
        if config and config.stype ~= enum.SCENE_STYPE.SCENE_STYPE_THRONE then
            self.level_item = LevelShowItem(self.lv_con)
            self.level_item:SetData(16, temp_lv, "876E50")
        end

        --self.text_lv_component.text = string.format(ConfigLanguage.Common.StirngLevel, str_level)
    end
    self.text_name_component.text = name_str
end