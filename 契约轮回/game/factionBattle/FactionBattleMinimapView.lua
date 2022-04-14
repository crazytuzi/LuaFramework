---
--- Created by  R2D2
--- DateTime: 2019/02/15 19:39
---

FactionBattleMinimapView = FactionBattleMinimapView or class("FactionBattleMinimapView", BaseItem)
local this = FactionBattleMinimapView

function FactionBattleMinimapView:ctor(parent_node, layer)
    self.abName = "factionbattle"
    self.assetName = "FactionBattleMinimapView"
    self.layer = layer

    self.events = {}
    self.dataModel = FactionBattleModel.GetInstance()
    self.object_list = {}
    FactionBattleMinimapView.super.Load(self)
    self.scene_data = SceneManager:GetInstance():GetSceneInfo()
end

function FactionBattleMinimapView:dctor()

    GlobalEvent:RemoveTabListener(self.events)
    for k, item in pairs(self.object_list) do
        item:destroy()
    end
    self.object_list = {}
end

function FactionBattleMinimapView:LoadCallBack()
    self.nodes = {
        "miniMap/HelpBtn",
        "miniMap/map",
        "miniMap/map/mapIcon",
        "miniMap/map/MapImage",
        "miniMap/Team1", "miniMap/Team2", "miniMap/Slider/Num2", "miniMap/Slider/Num1",
        "miniMap/Slider", "miniMap/Slider/Fg","miniMap/des",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function FactionBattleMinimapView:InitUI()
    self.mapImage = self.MapImage:GetComponent("Image")
    self.blueNum = GetText(self.Team1)
    self.redNum = GetText(self.Team2)
    self.blueScore = GetText(self.Num1)
    self.redScore = GetText(self.Num2)

    self.SliderLength = self.Slider.sizeDelta.x

    SetVisible(self.mapIcon, false)

    local parent_x, parent_y = GetLocalPosition(self.map)
    local x, y = GetLocalPosition(self.MapImage)
    self.mini_map_pos = { x = parent_x + x + ScreenWidth * 0.5, y = parent_y + y + ScreenHeight * 0.5 }

    self.res_width = GetSizeDeltaX(self.map)
    self.res_height = GetSizeDeltaY(self.map)

    self:SetData()

    self.main_role_item = FactionBattleMinimapIcon(self.mapIcon.gameObject, self.map)
    self.main_role_item:SetData({ type = enum.ACTOR_TYPE.ACTOR_TYPE_ROLE })
    self:UpdateRolePosition()

    --self.des
    local cfg = Config.db_game["guildwar_score_max"].val
    local score = String2Table(cfg)[1]
    self.des.text  = string.format("Requirement: %s pts",score)
end

function FactionBattleMinimapView:AddEvent()

    local function helpTip ()
    --ShowHelpTip(HelpConfig.FactionBattle.minimapTip)
        ShowHelpTip(HelpConfig.FactionBattle.description, true)
    end
    AddClickEvent(self.HelpBtn.gameObject, helpTip)

    self.events = self.events or {}

    local function call_back(x, y, block_pos_x, block_pos_y)
        self:UpdateRolePosition(x, y)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(SceneEvent.MainRolePos, call_back)

    local function call_back(id, pos, is_find_way)
        if not self.touch_icon_pos then
            self.touch_icon_pos = {}
        end
        self.touch_icon_id = id
        self.touch_icon_pos.x = pos.x
        self.touch_icon_pos.y = pos.y
        local item = self.object_list[id]
        if not item then
            return
        end

        if is_find_way then
            self:MoveToPosition()
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.MapTouchIcon, call_back)
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionBattleEvent.FactionBattle_BattleDataEvent, handler(self, self.OnBattleData))

end

---获取战区信息回调
function FactionBattleMinimapView:OnBattleData()
    self:CheckHomeIcon()
    self:RefreshNum()
    self:RefreshCrystal()
end

function FactionBattleMinimapView:CheckHomeIcon()
    if (not self.spawnList) then
        self.spawnList = self.dataModel:GetSpawnList()
        --for i, v in pairs(self.dataModel.BattleInfo) do
        --    local t = {}
        --    t.uid = enum.ACTOR_TYPE.ACTOR_TYPE_BORN * 100 + i
        --    t.type = enum.ACTOR_TYPE.ACTOR_TYPE_BORN
        --    t.state = i
        --    t.coord = {}
        --    t.coord.x = v.coord.x
        --    t.coord.y = v.coord.y
        --
        --    table.insert(self.spawnList, t)
        --end
        self:UpdateObject(self.spawnList)
        --local item = FactionBattleMinimapIcon(self.mapIcon.gameObject, self.map)
        --local x, y = self:ChangeScenePosToMiniPos(  self.dataModel.BattleInfo[1].coord.x,self.dataModel.BattleInfo[1].coord.y)
        --item:SetPosition(x, y)
        --self.HomeIcon = item
    end
end

function FactionBattleMinimapView:RefreshNum()
    local num1, score1, num2, score2 = self.dataModel:GetBattleNum()
    self.blueNum.text = tostring(num1) .. "People"
    self.redNum.text = tostring(num2).. "People"
    self.blueScore.text = tostring(score1)
    self.redScore.text = tostring(score2)

    self:RefreshSlider(score1, score2)
end

function FactionBattleMinimapView:RefreshSlider(score1, score2)
    local v1, v2 = 0, 0

    if (score1 == score2) then
        v1 = 0.5
        v2 = 0.5
    else
        local sum = score1 + score2
        v1 = math.max(score1 / sum, 0.1)
        v2 = math.max(score2 / sum, 0.1)

        if (v1 == 0.1) then
            v2 = 0.9
        end

        if (v2 == 0.1) then
            v1 = 0.9
        end
    end

    v1 = v1 * self.SliderLength
    v2 = v2 * self.SliderLength

    SetSizeDeltaX(self.Num1, math.max(v2, self.blueScore.preferredWidth))
    SetSizeDeltaX(self.Fg, v2)
    SetSizeDeltaX(self.Num2, math.max(v1, self.redScore.preferredWidth))
end

function FactionBattleMinimapView:RefreshCrystal()
    for _, v in pairs(self.object_list) do
        if (v.data.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP) then
            v:RefreshState( self.dataModel:GetCrystalState(v.data.uid)) --self.dataModel.CrystalInfo[v.data.uid] or 0)
        end
    end
end

function FactionBattleMinimapView:SetData(scene_id)
    scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
    if self.scene_id == scene_id then
        return
    end
    if not self.is_loaded then
        return
    end
    self.scene_id = scene_id

    local config = SceneConfigManager:GetInstance():GetSceneConfig(scene_id)
    self.scene_width = config.SceneMap.scene_width
    self.scene_height = config.SceneMap.scene_height

    local sceneConfig = Config.db_scene[scene_id]
    local monster_list = SceneConfigManager:GetInstance():GetMonsterList(scene_id)

    self.sceneType = sceneConfig.stype
    self.monster_list = monster_list

    self:UpdateObjectList()
   -- SetSizeDelta(self.MapImage, self.mini_res_width, self.mini_res_height)
    --self:LoadMiniRes(scene_id)
end

function FactionBattleMinimapView:LoadMiniRes(res)
    if self.res == res then
        return
    end
    self.res = res
    local function call_back(sprite)
        self.mapImage.sprite = sprite
        SetSizeDelta(self.MapImage, self.mini_res_width, self.mini_res_height)
    end
    lua_resMgr:SetImageTexture(self, self.mapImage, "iconasset/icon_minimap_" .. res, tostring(res), true, call_back)
end

function FactionBattleMinimapView:UpdateObjectList()
    --240 176
    local widht_rate = self.scene_width / 240
    local height_rate = self.scene_height / 176
    self.widht_rate = self.scene_width / 240
    self.height_rate = self.scene_width / 176
    self.is_adaption_width = widht_rate < height_rate
    self.adaption_rate = math.max(widht_rate, height_rate)
    self.mini_res_width = self.scene_width / self.adaption_rate
    self.mini_res_height = self.scene_height / self.adaption_rate

    self:UpdateObject(self.monster_list)
end

function FactionBattleMinimapView:UpdateObject(object_list)
    for i = 1, #object_list do
        local data = object_list[i]
        local item = self.object_list[data.uid]
        if not item then
            item = FactionBattleMinimapIcon(self.mapIcon.gameObject, self.map)
            local x, y = self:ChangeScenePosToMiniPos(data.coord.x, data.coord.y)
            item:SetPosition(x, y)
            self.object_list[data.uid] = item
        end
        item:SetData(data)
    end
    if self.main_role_item then
        self.main_role_item.transform:SetAsLastSibling()
    end
end

function FactionBattleMinimapView:ChangeScenePosToMiniPos(x, y)
    if not self.adaption_rate or not self.mini_res_width or not self.mini_res_height then
        return x, y
    end
    local new_x = x / self.widht_rate - 240 * 0.5
    local new_y = y / self.height_rate - 176 * 0.5
    return new_x, new_y
end

function FactionBattleMinimapView:UpdateRolePosition(x, y)
    if not self.main_role_item then
        return
    end
    if not x or not y then
        local main_role = SceneManager:GetInstance():GetMainRole()
        local pos = main_role:GetPosition()
        x = pos.x
        y = pos.y
    end
    if not self.main_role_pos then
        self.main_role_pos = { x = x, y = y }
    else
        self.main_role_pos.x = x
        self.main_role_pos.y = y
    end
    x, y = self:ChangeScenePosToMiniPos(x, y)
    self.main_role_item:SetPosition(x, y)
end

function FactionBattleMinimapView:MoveToPosition()
    if not self.touch_icon_pos then
        return
    end
    local item = self.object_list[self.touch_icon_id]
    local touch_icon_id = self.touch_icon_id
    local object_type
    if item then
        object_type = item.data.type
    end
    local callback
    local dis_range
    if object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        dis_range = 100
        callback = function()
            local creep_object = SceneManager:GetInstance():GetCreepByTypeId(touch_icon_id)
            if creep_object then
                creep_object:OnClick()
            end
        end
    elseif object_type == enum.ACTOR_TYPE.ACTOR_TYPE_NPC then
        callback = function()
            local npc_object = SceneManager:GetInstance():GetObject(touch_icon_id)
            if npc_object then
                npc_object:OnClick()
            end
        end
        dis_range = SceneConstant.NPCRange * 0.5
    end
    local end_pos = { x = self.touch_icon_pos.x, y = self.touch_icon_pos.y }
    OperationManager:GetInstance():TryMoveToPosition(self.scene_id, nil, end_pos, callback, dis_range)
end