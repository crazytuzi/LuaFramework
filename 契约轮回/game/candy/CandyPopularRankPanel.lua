-- @Author: lwj
-- @Date:   2019-02-22 16:13:58
-- @Last Modified time: 2019-02-22 16:14:00

CandyPopularRankPanel = CandyPopularRankPanel or class("CandyPopularRankPanel", WindowPanel)
local CandyPopularRankPanel = CandyPopularRankPanel

function CandyPopularRankPanel:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyPopularRankPanel"
    self.layer = "UI"
    self.panel_type = 6

    self.model = CandyModel.GetInstance()
end

function CandyPopularRankPanel:dctor()
end

function CandyPopularRankPanel:Open()
    CandyPopularRankPanel.super.Open(self)
end

function CandyPopularRankPanel:LoadCallBack()
    self.nodes = {
        "rankScroll", "rankScroll/Viewport/rankContent",
        "tip_Text",
        "selfRankItem/special", "selfRankItem/normal/number", "selfRankItem/normal/nor_popu", "selfRankItem/special/name", "selfRankItem/special/popu", "selfRankItem/normal/nor_name", "selfRankItem/special/icon", "selfRankItem/normal",
        "selfRankItem/rewardContent",
    }
    self:GetChildren(self.nodes)
    self.rank_scroll_rect = GetRectTransform(self.rankScroll)
    self.icon = GetImage(self.icon)
    self.pop = GetText(self.popu)
    self.number = GetText(self.number)
    self.name = GetText(self.name)
    self.nor_popu = GetText(self.nor_popu)
    self.nor_name = GetText(self.nor_name)

    self:AddEvent()
    self:InitWinPanel()
    self:InitPanel()
end
function CandyPopularRankPanel:AddEvent()
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    self.updateRank_event_id = self.model:AddListener(CandyEvent.UpdatePopRankPanel, handler(self, self.UpdateViewRank))
end

function CandyPopularRankPanel:InitWinPanel()
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("candy_image", "CandyPopularRank_Title_Img")
    self:SetTitleImgPos(-5, 250)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3", true)
end

function CandyPopularRankPanel:InitPanel()
    local ser_rank_list = self.model:GetPopRankList()
    local num = #ser_rank_list
    if num == 0 then
        SetVisible(self.tip_Text, true)
    else
        if num < 5 then
            num = 5
        end
        SetVisible(self.tip_Text, false)
        local param = {}
        local cellSize = { width = 830, height = 75 }  --列表项宽高
        param["scrollViewTra"] = self.rank_scroll_rect
        param["cellParent"] = self.rankContent
        param["cellSize"] = cellSize
        param["cellClass"] = CandyPopuRankItem
        param["begPos"] = Vector2(0, 0)
        param["spanX"] = 0
        param["spanY"] = 0
        param["createCellCB"] = handler(self, self.SetItemData)
        param["updateCellCB"] = handler(self, self.SetItemData)
        param["cellCount"] = num
        --param["cellCount"] = 100
        self.scrollView = ScrollViewUtil.CreateItems(param)
    end
    self:CheckSelfRank()
end

function CandyPopularRankPanel:CheckSelfRank()
    local data = self.model:GetMyRankData()
    local name_text = nil
    local pop_text = nil
    if data then
        if data.rank <= 3 then
            SetVisible(self.normal, false)
            SetVisible(self.special, true)
            lua_resMgr:SetImageTexture(self, self.icon, "candy_image", "rank_icon_" .. data.rank, true, nil, false)
            name_text = self.name
            pop_text = self.pop
        else
            SetVisible(self.normal, true)
            SetVisible(self.special, false)
            self.number.text = data.rank
            name_text = self.nor_name
            pop_text = self.nor_popu
        end
        name_text.text = data.name
        pop_text.text = data.pop
        local str = Config.db_candyroom_reward[data.rank].reward
        if self.model:IsCross() then
            str = Config.db_candyroom_reward[data.rank].cross_reward
        end
        local tbl = String2Table(str)
        self.reward_item_list = self.reward_item_list or {}
        local len = #tbl
        for i = 1, len do
            local item = self.reward_item_list[i]
            if not item then
                item = AwardItem(self.rewardContent)
                self.reward_item_list[i] = item
                SetLocalScale(item.transform, 0.92, 0.92, 1)
            else
                item:SetVisible(true)
            end
            local item_id = tbl[i][1]
            local final_num = tbl[i][2]
            if item_id == 90010018 then
                final_num = GetProcessedExpNum(item_id, final_num)
            end
            item:SetData(item_id, final_num)
            item:AddClickTips()
        end
        for i = len + 1, #self.reward_item_list do
            local item = self.reward_item_list[i]
            item:SetVisible(false)
        end
    end
end

function CandyPopularRankPanel:UpdateViewRank()
    if not self.scrollView then
        return
    end
    local ranks = self.model:GetPopRankList()
    local showing_item_list = self.scrollView.loadedCellObjs
    local cur_items_num = #showing_item_list
    if #ranks > cur_items_num then
        self.scrollView:ResetContentSize(#ranks)
        showing_item_list = self.scrollView.loadedCellObjs
    end
    for i, v in pairs(showing_item_list) do
        local index = v.__item_index
        local ser_data = ranks[index]
        local isNeedChange = false
        if ser_data then
            if not v.data then
                isNeedChange = true
            elseif v.data.id ~= ser_data.id or v.data.pop ~= ser_data.pop or v.data.name ~= ser_data.name or v.data.rank ~= ser_data.rank then
                isNeedChange = true
            end
        end
        if isNeedChange then
            v:SetData(ser_data)
        end
    end
end

function CandyPopularRankPanel:SetItemData(itemCls)
    local index = itemCls.__item_index
    local ser_rank_list = self.model:GetPopRankList()[index]
    --if ser_rank_list == nil then
    --    ser_rank_list = self.model:GetChatRankList()[1]
    --    ser_rank_list.rank = 4
    --end
    itemCls:SetData(ser_rank_list)
end

function CandyPopularRankPanel:OpenCallBack()
    self.model.isOpenningPopRank = true
    if not self.model.isOpenningChatPanel then
        self.model:Brocast(CandyEvent.ChangeUpdateChatRankInfoState, true)
    end
    CandyController.GetInstance():SetUpdateLeftCenterState(false)
end

function CandyPopularRankPanel:CloseCallBack()
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
    if self.model.isOpenningLeftCenter then
        CandyController.GetInstance():SetUpdateLeftCenterState(true)
    end
    if self.model.isOpenningChatPanel then
        self.model.cur_rank_mode = 1
    else
        self.model:Brocast(CandyEvent.ChangeUpdateChatRankInfoState, false)
    end
    self.model.isOpenningPopRank = false
    --for i, v in pairs(self.rank_item_list) do
    --    if v then
    --        v:destroy()
    --    end
    --end
    --self.rank_item_list = {}

    if self.scrollView ~= nil then
        self.scrollView:OnDestroy()
        self.scrollView = nil
    end
    if self.updateRank_event_id then
        self.model:RemoveListener(self.updateRank_event_id)
    end
    self.updateRank_event_id = nil
end


