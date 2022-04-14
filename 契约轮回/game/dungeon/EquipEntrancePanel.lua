EquipEntrancePanel = EquipEntrancePanel or class("EquipEntrancePanel",BaseItem)
local EquipEntrancePanel = EquipEntrancePanel

function EquipEntrancePanel:ctor(parent_node,layer)
    self.abName = "dungeon"
    self.assetName = "EquipEntrancePanel"
    self.layer = layer

    self.model = DungeonModel:GetInstance()
    self.team_model = TeamModel.GetInstance()
    self.team_events = {}
    EquipEntrancePanel.super.Load(self)
end

function EquipEntrancePanel:dctor()
    if self.left_team_list then
        self.left_team_list:destroy()
        self.left_team_list = nil
    end
    if self.left_team then
        self.left_team:destroy()
        self.left_team = nil
    end
    if self.right_item then
        self.right_item:destroy()
        self.right_item = nil
    end
    if self.team_events then
        self.team_model:RemoveTabListener(self.team_events)
        self.team_events = nil
    end
end

function EquipEntrancePanel:LoadCallBack()
    self.nodes = {
        "left", "right","bg",
    }
    self:GetChildren(self.nodes)
    self.bg = GetImage(self.bg)
    self:AddEvent()
    local res = "dunge_team_big_bg"
    lua_resMgr:SetImageTexture(self,self.bg, "iconasset/icon_big_bg_"..res, res)
    self:UpdateView()
end

function EquipEntrancePanel:AddEvent()
    local function call_back()
        if self.left_team_list then
            self.left_team_list:SetVisible(false)
        end
        if not self.left_team then
            self.left_team = DungeTeamItem(self.left)
        end
        local team_info = self.team_model:GetTeamInfo()
        if team_info then
            local teamsubtarget = Config.db_team_target_sub[team_info.type_id]
            if teamsubtarget then
                local dunge_id = teamsubtarget.dunge_id
                self.model.team_select_dunge = Config.db_dunge[dunge_id]
            end
        end
        self.left_team:SetData(self.data)
        self.left_team:SetVisible(true)
    end
    self.team_events[#self.team_events+1] = self.team_model:AddListener(TeamEvent.UpdateTeamInfo, call_back)

    local function call_back()
        if self.left_team then
             self.left_team:SetVisible(false)
        end
        if self.left_team_list then
            self.left_team_list:SetVisible(false)
        end
        if not self.left_team_list then
            self.left_team_list = DungeTeamListItem(self.left)
        end
        self.left_team_list:SetData(self.data)
        self.left_team_list:SetVisible(true)
    end
    self.team_events[#self.team_events+1] = self.team_model:AddListener(TeamEvent.QuitTeam, call_back)
end

function EquipEntrancePanel:SetData(data, bossid)
    self.data = data
    local default_boss_id = nil
    if self.data then
        local tab = self.model.allEquipDunge
        --装备本
        if self.data == 1 then
            tab = self.model.allEquipDunge
            self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EQUIP
        --宠物本
        elseif self.data == 2 then
            tab = self.model.allPetDunge
            self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_PET
        end
        DungeonCtrl:GetInstance():RequestDungeonPanel(self.dungeon_type)
        local selectedItemIndex = 1
        local level = RoleInfoModel:GetInstance():GetRoleValue("level")
        for i = 1, #tab do
            if bossid then
                if tab[i].id == bossid then
                    selectedItemIndex = i
                end
            else
                if tab[i].level and level >= tonumber(tab[i].level) then
                    selectedItemIndex = i
                    default_boss_id = tab[i].id
                end
            end
        end
        self.model.team_select_dunge = tab[selectedItemIndex]
    end
    self.default_boss_id = default_boss_id
    self:CheckTeamTarget()
    if self.is_loaded then
        self:UpdateView()
    end
end

function EquipEntrancePanel:UpdateView()
    if self.data then
        local team_info = TeamModel.GetInstance():GetTeamInfo()
        if not team_info then
            if not self.left_team_list then
                self.left_team_list = DungeTeamListItem(self.left)
            end
            self.left_team_list:SetData(self.data, self.default_boss_id)
            self.left_team_list:SetVisible(true)
            if self.left_team then
                SetVisible(self.left_team, false)
            end
        else
            if not self.left_team then
                self.left_team = DungeTeamItem(self.left)
            end
            self.left_team:SetData(self.data, self.default_boss_id)
            self.left_team:SetVisible(true)
            if self.left_team_list then
                SetVisible(self.left_team_list, false)
            end
        end

        if not self.right_item then
            self.right_item = DungeCommonInfoItem(self.right)
        end
    end
end

function EquipEntrancePanel:CheckTeamTarget()
    local team_info = self.team_model:GetTeamInfo()
    if not team_info then
        return
    end
    local type_id = team_info.type_id
    local teamsubtarget = Config.db_team_target_sub[type_id]
    if teamsubtarget and teamsubtarget.dunge_id == self.model.team_select_dunge.id then
        return
    end
    local sub = self.team_model:GetSubIDByDungeID(self.model.team_select_dunge.id)
    if sub then
        TeamController.GetInstance():RequestChangeTarget(sub.id)
    end
end
