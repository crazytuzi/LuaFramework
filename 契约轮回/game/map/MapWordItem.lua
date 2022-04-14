-- @Author: lwj
-- @Date:   2019-03-11 20:34:29
-- @Last Modified time: 2019-03-11 20:34:31

MapWordItem = MapWordItem or class("MapWordItem", BaseCloneItem)
local MapWordItem = MapWordItem

function MapWordItem:ctor(parent_node, layer)
    MapWordItem.super.Load(self)
end

function MapWordItem:dctor()
    if self.scene_change_end_event_id then
        GlobalEvent:RemoveListener(self.scene_change_end_event_id)
        self.scene_change_end_event_id = nil
    end
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
end

function MapWordItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "icon_bg",
        "icon_bg/icon",
        "name",
        "lv_con",
        "point_icon",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.name = GetText(self.name)
    self.rect_trans = GetRectTransform(self)
    self.scene_icon = GetImage(self.point_icon)
    self.icon_rect = GetRectTransform(self.icon_bg)

    self:AddEvent()
end

function MapWordItem:AddEvent()
    local function callback()
        local isCanTurn = false
        local cur_scene_id = SceneManager:GetInstance():GetSceneId()
        local type = Config.db_scene[cur_scene_id].type
        if cur_scene_id ~= self.data.conData.id then
            if self:CheckIsCanGo(true) then
                if type ~= 1 and type ~= 2 then
                    DungeonModel:GetInstance():ExitScene(handler(self, self.RealExit))
                else
                    isCanTurn = true
                end
            end
        else
            Notify.ShowText("Already in the scene")
        end
        if isCanTurn then
            SceneControler:GetInstance():RequestSceneChange(self.data.conData.id, 2)
            if SceneConfigManager:GetInstance():CheckEnterScene(self.data.conData.id, false) then
                OperationManager:GetInstance():StopAStarMove()
                GlobalEvent:Brocast(MapEvent.CloseMapPanel)
            end
        end
    end
    AddClickEvent(self.scene_icon.gameObject, callback)

    local function callback()
        self:CheckIsInMyScene()
    end
    self.scene_change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, callback)
end

function MapWordItem:DungeonExit()
    DungeonCtrl:GetInstance():RequestLeaveDungeon();
    SceneControler:GetInstance():RequestSceneChange(self.data.conData.id, 2)
    GlobalEvent:Brocast(MapEvent.CloseMapPanel)
end

function MapWordItem:RealExit()
    SceneControler:GetInstance():RequestSceneLeave();
    SceneControler:GetInstance():RequestSceneChange(self.data.conData.id, 2)
    GlobalEvent:Brocast(MapEvent.CloseMapPanel)
end

function MapWordItem:HandleExit(target, x, y)
    --if Dialog.ShowTwo("提示" , "你确定退出副本吗?\n(当前退出会消耗副本次数)" , "确定" , handler(self,self.SendExitDungeon) , nil , "取消" , nil , nil )
    local sceneid = SceneManager:GetInstance():GetSceneId();
    local config = Config.db_scene[sceneid] or {}
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EXP then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COIN then
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EQUIP then
        Dialog.ShowTwo("Tip", "You haven't claimed all dungeon rewards yet,\nleave?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_MELEEWAR then
        Dialog.ShowTwo("Tip", "If you leave brawl battleground now,all points you earned will be cleared.\nExit?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
    elseif config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER then
        Dialog.ShowTwo("Tip", "Leave current scene and go?", "Confirm", handler(self, self.DungeonExit), nil, "Cancel", nil, nil);
        --Dialog.ShowTwo("提示", "你确定退出副本吗?\n(当前退出会消耗副本次数)", "确定", handler(self, self.DungeonExit), nil, "取消", nil, nil)
    else
        local sceneConfig = Config.db_scene[sceneid];
        if sceneConfig then
            Dialog.ShowTwo("Tip", "Are you sure to leave current scene?", "Confirm", handler(self, self.RealExit), nil, "Cancel", nil, nil)
        end
    end
end

function MapWordItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function MapWordItem:UpdateView()
    self:CheckIconPos()
    local pic = self.data.conData.index
    lua_resMgr:SetImageTexture(self, self.scene_icon, "iconasset/icon_worldmap", tostring(pic), false, nil, false)
    self:CheckIsInMyScene()
    self.name.text = self.data.conData.name
    local isCanGo = self:CheckIsCanGo(false)
    if isCanGo then
        --SetVisible(self.lv_limit, false)
        ShaderManager:GetInstance():SetImageNormal(self.scene_icon)
    else
        --图标变灰
        ShaderManager:GetInstance():SetImageGray(self.scene_icon)
        --SetVisible(self.lv_limit, true)
    end
    local tbl = String2Table(self.data.conData.reqs)
    for i, v in pairs(tbl) do
        if v[1] == "level" then
            local temp_lv = v[2]
            --local temp_lv = 480
            --temp_lv = RoleInfoModel.GetInstance():GetLevelShow(temp_lv)
            if self.lv_item then
                self.lv_item:destroy()
                self.lv_item = nil
            end
            self.lv_item = LevelShowItem(self.lv_con)
            self.lv_item:SetData(16, temp_lv, "fff8d4", "5c76ba")

            --self.lv_limit.text = temp_lv .. "j"
            break
        end
    end
end

function MapWordItem:CheckIsCanGo(isNeedShowText)
    local result = false
    if self.data.conData.reqs ~= "{}" then
        local limit_tbl = String2Table(self.data.conData.reqs)
        for i, v in pairs(limit_tbl) do
            if v[1] == "level" then
                local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                if cur_lv < v[2] then
                    if isNeedShowText then
                        Notify.ShowText("Level too low")
                    end
                    result = false
                else
                    result = true
                end
            end
        end
    else
        result = true
    end
    return result
end

function MapWordItem:CheckIsInMyScene()
    local cur_scene_id = SceneManager:GetInstance():GetSceneId()
    if cur_scene_id == self.data.conData.id then
        SetVisible(self.icon_bg, true)
        local sex = RoleInfoModel:GetInstance():GetSex()
        if not self.icon then
            return
        end
        lua_resMgr:SetImageTexture(self, self.icon, "map_image", "map_world_role_icon_" .. sex, true, nil, false)
    else
        SetVisible(self.icon_bg, false)
    end
end

function MapWordItem:CheckIconPos()
    local index = self.data.conData.index
    if index == 4 then
        SetAnchoredPosition(self.icon_rect, -4.7, 47)
    elseif index == 3 then
        SetLocalPositionY(self.icon_bg, 100)
    elseif index == 5 then
        SetAnchoredPosition(self.icon_rect, -4.7, 70)
    elseif index == 6 then
        SetLocalPositionY(self.icon_bg, 65)
    elseif index == 8 then
        SetLocalPositionY(self.icon_bg, 61)
    elseif index == 11 then
        SetLocalPositionY(self.icon_bg, 40)
    elseif index == 13 then
        SetAnchoredPosition(self.icon_rect, -4.7, 42.5)
    end
end