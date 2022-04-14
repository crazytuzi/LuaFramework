-- @Author: lwj
---- @Date:   2019-02-20 16:01:36
-- @Last Modified time: 2019-02-20 16:01:36

CandyChatRankItem = CandyChatRankItem or class("CandyChatRankItem", BaseCloneItem)
local CandyChatRankItem = CandyChatRankItem

function CandyChatRankItem:ctor(parent_node, layer)
    CandyChatRankItem.super.Load(self)
end

function CandyChatRankItem:dctor()
    for i, v in pairs(self.reward_item_list) do
        if v then
            v:destroy()
        end
    end
    self.reward_item_list = {}
end

function CandyChatRankItem:LoadCallBack()
    self.model = CandyModel.GetInstance()
    self.nodes = {
        "icon", "name", "value", "awardContent", "btn_gift", "bg", "normal", "normal/number",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.name = GetText(self.name)
    self.value = GetText(self.value)
    self.bg = GetImage(self.bg)
    self.number = GetText(self.number)
    self:AddEvent()
end

function CandyChatRankItem:AddEvent()
    local function callback()
        self.model.is_open_give_gift = true
        self.model.targetPlayerId = self.data.id
        self.model.targetPlayerName = self.data.name
        self.model:Brocast(CandyEvent.RequestReaminGiveCount)
    end
    AddButtonEvent(self.btn_gift.gameObject, callback)

    --点击出现角色菜单面板
    local function callback()
        local id = RoleInfoModel.GetInstance():GetMainRoleId()
        if type(self.data) == "table" and self.data.id ~= id then
            lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.bg):Open(nil, self.data.id)
        end
    end
    AddClickEvent(self.bg.gameObject, callback)
end

function CandyChatRankItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function CandyChatRankItem:UpdateView()
    local index = nil
    local isHaveData = true
    if type(self.data) == "number" then
        index = self.data
        isHaveData = false
        SetVisible(self.btn_gift, false)
    else
        local id = RoleInfoModel.GetInstance():GetMainRoleId()
        if id == self.data.id then
            SetVisible(self.btn_gift, false)
        else
            SetVisible(self.btn_gift, true)
        end
        index = self.data.index
    end
    if index <= 3 then
        SetVisible(self.icon, true)
        SetVisible(self.normal, false)
        lua_resMgr:SetImageTexture(self, self.icon, "candy_image", "rank_icon_" .. index, true, nil, false)
        lua_resMgr:SetImageTexture(self, self.bg, "candy_image", "CandyChatPanel_RankItem_Bg_" .. index, true, nil, false)
    else
        SetVisible(self.icon, false)
        SetVisible(self.normal, true)
        self.number.text = index
        local picIndex = 4
        if index % 2 == 1 then
            picIndex = 5
        end
        lua_resMgr:SetImageTexture(self, self.bg, "candy_image", "CandyChatPanel_RankItem_Bg_" .. picIndex, true, nil, false)
    end
    local name = '---'
    local pop = '---'
    if isHaveData then
        name = self.data.name
        pop = self.data.pop
    end
    self.name.text = name
    self.value.text = pop
    local award_tbl = self.model:IsCross() and String2Table(Config.db_candyroom_reward[index].cross_reward) or String2Table(Config.db_candyroom_reward[index].reward)
    if not self.reward_item_list then
        self.reward_item_list = {}
        for i = 1, #award_tbl do
            local param = {}
            local operate_param = {}
            
            local item_id = award_tbl[i][1]
            param["item_id"] = item_id
            local final_num = award_tbl[i][2]
            if item_id == enum.ITEM.ITEM_PLAYER_EXP or item_id == enum.ITEM.ITEM_WORLDLV_EXP then
                final_num = GetProcessedExpNum(item_id, final_num)
            end
            param["num"] = final_num

            param["model"] = self.model
            param["can_click"] = true
            param["operate_param"] = operate_param
            param["size"] = { x = 52.5, y = 52.5 }  --图标大小
            param.bind = 0
            local itemIcon = GoodsIconSettorTwo(self.awardContent)
            itemIcon:SetIcon(param)
            self.reward_item_list[#self.reward_item_list + 1] = itemIcon
        end
    end
end