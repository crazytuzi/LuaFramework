-- @Author: lwj
-- @Date:   2019-02-22 16:35:22
-- @Last Modified time: 2019-02-22 16:35:27

CandyPopuRankItem = CandyPopuRankItem or class("v", BaseItem)
local CandyPopuRankItem = CandyPopuRankItem

function CandyPopuRankItem:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyPopuRankItem"
    self.layer = layer

    BaseItem.Load(self)
    self.model = CandyModel.GetInstance()
end

function CandyPopuRankItem:dctor()
    for i, v in pairs(self.reward_item_list) do
        if v then
            v:destroy()
        end
    end
    self.reward_item_list = {}
end

function CandyPopuRankItem:LoadCallBack()
    self.nodes = {
        "rewardContent", "bg", "normal/nor_popu", "special/icon", "btn_gift", "special/name", "normal/nor_name", "normal/number", "special/popu", "normal", "special",
    }
    self:GetChildren(self.nodes)
    self.bg = GetImage(self.bg)
    self.icon = GetImage(self.icon)
    self.number = GetText(self.number)
    self.popu = GetText(self.popu)
    self.name = GetText(self.name)
    self.nor_popu = GetText(self.nor_popu)
    self.nor_name = GetText(self.nor_name)

    self:AddEvent()
    if self.is_loaded then
        self:UpdateView()
    end
end

function CandyPopuRankItem:AddEvent()
    local function callback()
        self.model.is_open_give_gift = true
        self.model.targetPlayerId = self.data.id
        self.model.targetPlayerName = self.data.name
        self.model:Brocast(CandyEvent.RequestReaminGiveCount)
    end
    AddButtonEvent(self.btn_gift.gameObject, callback)

    local function callback()
        local id = RoleInfoModel.GetInstance():GetMainRoleId()
        if type(self.data) == "table" and self.data.id ~= id then
            --lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.bg):Open(self.data.id)
            lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.bg):Open(nil, self.data.id)
        end
    end
    AddClickEvent(self.bg.gameObject, callback)
end

function CandyPopuRankItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function CandyPopuRankItem:UpdateView()
    self.name_text = nil
    self.pop_text = nil
    self.pic = 1
    self.rank = nil
    if self.data then
        local id = RoleInfoModel.GetInstance():GetMainRoleId()
        if id == self.data.id then
            SetVisible(self.btn_gift, false)
        else
            SetVisible(self.btn_gift, true)
        end
        if self.data.rank <= 3 then
            self:SetItemShow(true, true)
        else
            self:SetItemShow(true, false)
        end
        self.name_text.text = self.data.name
        self.pop_text.text = self.data.pop
        self.rank = self.data.rank
    else
        if self.__item_index <= 3 then
            self:SetItemShow(false, true)
            self.name.text = "---"
            self.popu.text = "---"
        else
            self:SetItemShow(false, false)
            self.nor_name.text = "---"
            self.nor_popu.text = "---"
        end
        self.number.text = self.__item_index
        self.rank = self.__item_index
        SetVisible(self.btn_gift, false)
    end
    lua_resMgr:SetImageTexture(self, self.bg, "candy_image", "CandyChatPanel_RankItem_Bg_" .. self.pic, true, nil, false)
    local str = Config.db_candyroom_reward[self.rank].reward
    if self.model:IsCross() then
        str = Config.db_candyroom_reward[self.rank].cross_reward
    end
    local tbl = String2Table(str)
    self.reward_item_list = self.reward_item_list or {}
    local len = #tbl
    for i = 1, len do
        local item = self.reward_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewardContent)
            self.reward_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local param = {}
        local operate_param = {}

        local item_id = tbl[i][1]
        param["item_id"] = item_id
        local final_num = tbl[i][2]
        if item_id == enum.ITEM.ITEM_PLAYER_EXP or item_id == enum.ITEM.ITEM_WORLDLV_EXP then
            final_num = GetProcessedExpNum(item_id, final_num)
        end
        param["num"] = final_num
        
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 70, y = 70 }  --图标大小
        param.bind = 0
        item:SetIcon(param)
    end
    for i = len + 1, #self.reward_item_list do
        local item = self.reward_item_list[i]
        item:SetVisible(false)
    end
end

function CandyPopuRankItem:SetItemShow(isHaveData, isTopThree)
    local index = nil
    if isHaveData then
        index = self.data.rank
    else
        index = self.__item_index
    end
    if isTopThree then
        self.pic = index
        SetVisible(self.normal, false)
        SetVisible(self.special, true)
        lua_resMgr:SetImageTexture(self, self.icon, "candy_image", "rank_icon_" .. index, true, nil, false)
        self.name_text = self.name
        self.pop_text = self.popu
    else
        SetVisible(self.normal, true)
        SetVisible(self.special, false)
        self.number.text = index
        self.name_text = self.nor_name
        self.pop_text = self.nor_popu
        if index % 2 == 1 then
            self.pic = 5
        else
            self.pic = 4
        end
    end
end

