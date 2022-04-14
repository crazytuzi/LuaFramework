-- @Author: lwj
-- @Date:   2019-02-18 16:12:08
-- @Last Modified time: 2019-02-18 16:12:11

CandyChatPanel = CandyChatPanel or class("CandyChatPanel", WindowPanel)
local CandyChatPanel = CandyChatPanel

function CandyChatPanel:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyChatPanel"
    self.layer = "UI"
    self.panel_type = 2

    self.is_show_light_decorate = true
    self.model = CandyModel.GetInstance()
    self.single_item_height = 54
    self.isShowModel = true
    self.len = 0
end

function CandyChatPanel:dctor()
end

function CandyChatPanel:Open()
    CandyChatPanel.super.Open(self)
end

function CandyChatPanel:LoadCallBack()
    self.nodes = {
        "leftScroll/Viewport/leftContent/leftRankItem/clickContent/numberThree", "leftScroll/Viewport/leftContent/leftRankItem/clickContent/numberTwo", "leftScroll/Viewport/leftContent/leftRankItem/clickContent/numberOne",
        "leftScroll/Viewport/leftContent/leftRankItem/rankItemContent", "leftScroll/Viewport/leftContent/leftRankItem/rankItemContent/CandyChatRankItem",
        "leftScroll/Viewport/leftContent/leftRankItem",
        "leftScroll/Viewport/leftContent",
        "leftScroll/Viewport/leftContent/leftRankItem/rankItemContent/Title/btn_switch",
        "leftScroll/Viewport/leftContent/leftRankItem/clickContent/CandyTopRankItem",
        "leftScroll/Viewport/leftContent/leftRankItem/clickContent", "btn_to_record/reco_red_con",
        --"leftScroll/Viewport/leftContent/leftRankItem/clickContent/CamPicture",
        --"leftScroll/Viewport/leftContent/leftRankItem/clickContent/CamPicture/Camera",
        "btn_to_rank",
        "btn_to_record",
        "chat_content",
        "emojiContent",
        "btn_short_cut",

        "leftScroll/TitleAndName",
        "leftScroll/TitleAndName/title1",
        "leftScroll/TitleAndName/title3",
        "leftScroll/TitleAndName/name3",
        "leftScroll/TitleAndName/title2",
        "leftScroll/TitleAndName/name2",
        "leftScroll/TitleAndName/name1",
    }
    self:GetChildren(self.nodes)
    self.rankItem_gameObject = self.CandyChatRankItem.gameObject
    self.top_rank_gameObject = self.CandyTopRankItem.gameObject
    self.rank_big_item_rect = GetRectTransform(self.leftRankItem)
    self.left_content_rect = GetRectTransform(self.leftContent)
    self.switch_img = GetImage(self.btn_switch)
    --self.camera = GetCamera(self.Camera)

    self.titleAndNameTable = {{self.title1,self.name1},{self.title2,self.name2},{self.title3,self.name3}}

    self:AddEvent()
    self:InitWinPanel()
    self:InitPanel()
end
function CandyChatPanel:AddEvent()
    local function callback()
        self:ArrowClickEvent(true)
    end
    AddButtonEvent(self.btn_switch.gameObject, callback)

    local function callback()
        self.model.cur_rank_mode = 2
        --self.model:Brocast(CandyEvent.ChangeUpdateChatRankInfoState, false)
        GlobalEvent:Brocast(CandyEvent.RequestCandyRankInfo, 100)
    end
    AddButtonEvent(self.btn_to_rank.gameObject, callback)

    local function callback()
        --self.model:Brocast(CandyEvent.ChangeUpdateChatRankInfoState, false)
        self.model.is_showing_record_rd = false
        self:SetRecoRedDot(false)
        self.model:Brocast(CandyEvent.UpdateRecoBtnRD)
        GlobalEvent:Brocast(CandyEvent.UpdateCandyChatIconRD, false)
        self.model:Brocast(CandyEvent.RequestCandyRecord, 1)
    end
    AddButtonEvent(self.btn_to_record.gameObject, callback)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(CandyChatShortCutPanel):Open()
    end
    AddButtonEvent(self.btn_short_cut.gameObject, callback)

    self.updateRankEvent_id = self.model:AddListener(CandyEvent.UpdateChatRankPanel, handler(self, self.UpdateRankShow))
    self.OpenEmojiViewEvent_id = GlobalEvent:AddListener(ChatEvent.OpenEmojiView, handler(self, self.DealOpenEmojiView))
    self.recieve_other_player_info_event_id = GlobalEvent:AddListener(RoleInfoEvent.QueryOtherRoleGlobal, handler(self, self.AddRoleDataToList))
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    self.update_reco_rd_event_id = self.model:AddListener(CandyEvent.UpdateRecoBtnRD, handler(self, self.UpdateRecoRD))
end

function CandyChatPanel:UpdateRecoRD()
    self:SetRecoRedDot(self.model.is_showing_record_rd)
end

function CandyChatPanel:InitWinPanel()
    self:SetPanelBgImage("iconasset/icon_big_bg_img_book_bg", "img_book_bg")
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("candy_image", "CandyPanel_Title_Img")
    self:SetTitleImgPos(528, 279)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3", true)
    self.is_show_top_cake_decorate = true
end

function CandyChatPanel:InitPanel()
    self:LoadLeftRankItem()
    self:LoadModelItem()
    self.chat_view = CandyChatView(self.chat_content, "UI")
end

function CandyChatPanel:OpenCallBack()
    self:SetRecoRedDot(self.model.is_showing_record_rd)
    self.model:Brocast(CandyEvent.ChangeUpdateChatRankInfoState, true)
    self.model.isOpenningChatPanel = true
    CandyController.GetInstance():SetUpdateLeftCenterState(false)
end

function CandyChatPanel:SetRecoRedDot(isShow)
    if not self.reco_red_dot then
        self.reco_red_dot = RedDot(self.reco_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.reco_red_dot:SetPosition(0, 0)
    self.reco_red_dot:SetRedDotParam(isShow)
end

function CandyChatPanel:ArrowClickEvent(isShowText)
    if self.len > 3 then
        if not isShowText and self.isShowModel then
            return
        end
        local img_name = nil
        local y = 0
        if self.isShowModel or not isShowText then
            self.isShowModel = false
            img_name = "CandyChatPanel_Rank_Btn_Down"
            if self.len < 6 then
                y = (self.len - 3) * self.single_item_height
            else
                y = 162
            end
        else
            self.isShowModel = true
            img_name = "CandyChatPanel_Rank_Btn_Up"
            y = 3
        end
        lua_resMgr:SetImageTexture(self, self.switch_img, "candy_image", img_name, true, nil, false)
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.left_content_rect)
        local time = 0.2
        local moveAction = cc.MoveTo(time, 0, y, 0)
        local function start_callback()
            if not self.isShowModel then
                self:ChangeModelsShow(false)
            end
        end
        local function end_call_back()
            if self.isShowModel then
                self:ChangeModelsShow(true)
            end
        end
        local call_action = cc.CallFunc(end_call_back)
        local call_start_action = cc.CallFunc(start_callback)
        local sys_action = cc.Sequence(call_start_action, moveAction, call_action)
        cc.ActionManager:GetInstance():addAction(sys_action, self.left_content_rect)
    else
        if isShowText then
            Notify.ShowText("No more rankings")
        end
    end
end

function CandyChatPanel:UpdateRankShow(change_list)
    if not self.top_rank_item_list then
        return
    end
    local finalList = self.model:GetChatRankList()
    self.rank_item_list = self.rank_item_list or {}
    self.len = #finalList
    local len = self.len
    if self.len < 3 then
        len = 3
    end
    local expandHeight = (len - 3) * self.single_item_height
    SetSizeDelta(self.rank_big_item_rect, 505, expandHeight + 463)
    SetSizeDelta(self.left_content_rect, 505, expandHeight + 463)
    for i = 1, len do
        local change_data = change_list[i]
        if change_data then
            local item = self.rank_item_list[i]
            if not item then
                item = CandyChatRankItem(self.rankItem_gameObject, self.rankItemContent)
                self.rank_item_list[i] = item
            end
            change_data.index = i
            item:SetData(change_data)
            --前三的点击面板更新
            if i < 4 then
                --local top_item = self.top_rank_item_list[i]
                --if not top_item then
                --    top_item = CandyTopRankItem(self.top_rank_gameObject, self.clickContent)
                --end
                --local data = change_list[i]
                --top_item:SetData(data)
                --self.top_rank_item_list[i] = top_item

            end
        end
    end
    for i = len + 1, #self.rank_item_list do
        local item = self.rank_item_list[i]
        item:SetVisible(false)
    end
    self:LoadModelItem()
    self:ArrowClickEvent(false)
end

function CandyChatPanel:LoadModelItem()
    local list = self.model:GetChatRankList()
    local length = self.len
    if length > 3 then
        length = 3
    end
    local my_id = RoleInfoModel.GetInstance():GetMainRoleId()
    for i = 1, length do
        local id = list[i].id
        if id == my_id then
            local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
            self:AddRoleDataToList(role_data)
        else
            RoleInfoController.GetInstance():RequestRoleQuery(id)
        end
    end
end

function CandyChatPanel:AddRoleDataToList(data)
    if not data then
        return
    end
    local list = self.model:GetChatRankList()
    for i, v in pairs(list) do
        if i > 3 then
            break
        end
        if v.id == data.id then
            self:HandleLoadUIRoleModel(data, v.rank)
        end
    end
end

--处理人物模型在UI上的显示
function CandyChatPanel:HandleLoadUIRoleModel(data, final_index)
    local list = self.model:GetChatRankList()
    self.top_rank_item_list = self.top_rank_item_list or {}
    local item = self.top_rank_item_list[final_index]
    if not item then
        item = CandyTopRankItem(self.top_rank_gameObject, self.clickContent)
        self.top_rank_item_list[final_index] = item
        item:SetTitleAndName(self.titleAndNameTable[final_index][1],self.titleAndNameTable[final_index][2])
    end
    local ser_info = list[final_index]
    ser_info.idx = final_index
    item:SetData(ser_info, data)

end

--控制模型显示
function CandyChatPanel:ChangeModelsShow(flag)
    for i = 1, #self.top_rank_item_list do
        if self.top_rank_item_list[i] then
            SetVisible(self.top_rank_item_list[i], flag)
            self.top_rank_item_list[i]:SetTitleAndNameVisible(not flag)
        end
    end
end

function CandyChatPanel:LoadLeftRankItem()
    local finalList = self.model:GetChatRankList()
    self.rank_item_list = self.rank_item_list or {}
    self.len = #finalList
    local len = self.len
    if self.len < 3 then
        len = 3
    end
    local expandHeight = (len - 3) * self.single_item_height
    SetSizeDelta(self.rank_big_item_rect, 505, expandHeight + 463)
    SetSizeDelta(self.left_content_rect, 505, expandHeight + 463)
    for i = 1, len do
        local item = self.rank_item_list[i]
        if not item then
            item = CandyChatRankItem(self.rankItem_gameObject, self.rankItemContent)
            self.rank_item_list[i] = item
        else
            item:SetVisible(true)
        end
        if not finalList[i] then
            finalList[i] = i
        else
            finalList[i].index = i
        end
        item:SetData(finalList[i])
    end
    for i = len + 1, #self.rank_item_list do
        local item = self.rank_item_list[i]
        item:SetVisible(false)
    end
end

function CandyChatPanel:DealOpenEmojiView(show)
    if not self.gameObject.activeInHierarchy then
        return
    end

    if not self.buttomView then
        self.buttomView = ChatButtomView(self.emojiContent)
    end

    if not show then
        self.buttomView:destroy()
        self.buttomView = nil
    end
end

function CandyChatPanel:CloseCallBack()
    if self.update_reco_rd_event_id then
        GlobalEvent:RemoveListener(self.update_reco_rd_event_id)
        self.update_reco_rd_event_id = nil
    end
    if self.reco_red_dot then
        self.reco_red_dot:destroy()
        self.reco_red_dot = nil
    end
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
    if self.recieve_other_player_info_event_id then
        GlobalEvent:RemoveListener(self.recieve_other_player_info_event_id)
        self.recieve_other_player_info_event_id = nil
    end
    if self.model.isOpenningLeftCenter then
        CandyController.GetInstance():SetUpdateLeftCenterState(true)
    end
    if self.chat_view then
        self.chat_view:destroy()
    end
    self.chat_view = nil
    self.model:Brocast(CandyEvent.ChangeUpdateChatRankInfoState, false)
    self.model.isOpenningChatPanel = false
    for i, v in pairs(self.rank_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rank_item_list = {}

    for i, v in pairs(self.top_rank_item_list) do
        if v then
            v:destroy()
        end
    end
    self.top_rank_item_list = {}

    if self.updateRankEvent_id then
        self.model:RemoveListener(self.updateRankEvent_id)
    end
    self.updateRankEvent_id = nil

    if self.print_event_id then
        GlobalEvent:RemoveListener(self.print_event_id)
    end
    self.print_event_id = nil
    if self.OpenEmojiViewEvent_id then
        GlobalEvent:RemoveListener(self.OpenEmojiViewEvent_id)
    end
    self.OpenEmojiViewEvent_id = nil

    if self.buttomView then
        self.buttomView:destroy()
        self.buttomView = nil
    end
end


