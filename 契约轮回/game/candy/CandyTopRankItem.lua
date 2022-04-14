-- @Author: lwj
-- @Date:   2019-02-21 11:55:32
-- @Last Modified time: 2019-02-21 11:55:32

CandyTopRankItem = CandyTopRankItem or class("CandyTopRankItem", BaseCloneItem)
local CandyTopRankItem = CandyTopRankItem

function CandyTopRankItem:ctor(parent_node, layer)
    CandyTopRankItem.super.Load(self)
    self.last_title_id = nil
    --self.layer = layer
end

function CandyTopRankItem:dctor()
    if self.role_model then
        self.role_model:destroy()
        self.role_model = nil
    end
end

function CandyTopRankItem:LoadCallBack()
    self.model = CandyModel.GetInstance()
    self.top_rank_item_start_pos = { 85, -135 }
    self.width = 168
    self.height = 270
    self.nodes = {
        "name", "click", "title", "model_con",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.title = GetImage(self.title)
    self.rect = GetRectTransform(self)

    --self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)

    self.is_show_title = nil
    self.title_ex = nil
    self.name_ex = nil
end

function CandyTopRankItem:AddEvent()
    if type(self.data) == "table" then
        local id = RoleInfoModel.GetInstance():GetMainRoleId()
        if id ~= tostring(self.data.id) then
            local function callback()
                --lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.click):Open(self.data.id)
                lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.click):Open(nil, self.data.id)
            end
            AddClickEvent(self.click.gameObject, callback)
        end
    end
end

function CandyTopRankItem:SetData(data, role_data)
    self.data = data
    self.role_data = role_data or self.role_data
    if self.is_loaded then
        self:UpdateView()
    end
end

function CandyTopRankItem:UpdateView()
    self:LoadRoleModel()
    self.is_show_title = false
    if type(self.data) == "table" then
        self.name.text = self.data.name
        self.name_ex.text = self.data.name
        self:AddEvent()
        if self.data.rank == 1 then
            SetAnchoredPosition(self.rect, self.top_rank_item_start_pos[1] + self.width, self.top_rank_item_start_pos[2])
        elseif self.data.rank == 2 then
            SetAnchoredPosition(self.rect, self.top_rank_item_start_pos[1], self.top_rank_item_start_pos[2] - 10)
        elseif self.data.rank == 3 then
            SetAnchoredPosition(self.rect, self.top_rank_item_start_pos[1] + (self.width * 2), self.top_rank_item_start_pos[2] - 10)
        end
    end

    --读取称号数据
    local cfg = Config.db_candyroom_reward[self.data.rank]
    local reward = cfg.reward
    if self.model:IsCross() then
        reward  = cfg.cross_reward
    end

    reward = String2Table(reward)
    local title_id = reward[2][1]
    
    if title_id ~= 0 then
        self.is_show_title = true
        if not self.last_title_id or title_id ~= self.last_title_id then
            lua_resMgr:SetImageTexture(self, self.title, "iconasset/icon_title", title_id, true, nil, false)
            lua_resMgr:SetImageTexture(self, self.title_ex, "iconasset/icon_title", title_id, true, nil, false)
        end
    end
    SetVisible(self.title,  self.is_show_title)
    self.last_title_id = title_id

    --[[ local x,y,z = GetGlobalPosition(self.title.transform)
    SetGlobalPosition(self.title_ex.transform,x,y,z)
    local x,y,z = GetGlobalPosition(self.name.transform)
    SetGlobalPosition(self.name_ex.transform,x,y,z) ]]
end

function CandyTopRankItem:LoadRoleModel()
    if self.role_model then
        self.role_model:ReLoadModel(self.role_data)
    else
        --local data = GetRoleModelData()
        local config = {trans_x=320, trans_y=320}
        if self.data.rank ~= 1 then
            config = {trans_x=300, trans_y=300, yPos=-102}
        end
        self.role_model = UIRoleCamera(self.model_con, nil, self.role_data, 1, false, self.data.idx, config)
        self.role_model:SetWingVisible(false)
    end
end

function CandyTopRankItem:SetTitleAndName(title,name)
    self.title_ex = GetImage(title)
    self.name_ex = GetText(name)
end

function CandyTopRankItem:SetTitleAndNameVisible(visible)
    SetVisible(self.title_ex,visible)
    SetVisible(self.name_ex,visible)
end


