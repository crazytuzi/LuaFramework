-- @Author: lwj
-- @Date:   2019-07-18 14:27:23 
-- @Last Modified time: 2019-11-05 11:10:48

OpenHighPanel = OpenHighPanel or class("OpenHighPanel", WindowPanel)
local OpenHighPanel = OpenHighPanel

function OpenHighPanel:ctor()
    self.abName = "openHigh"
    self.assetName = "OpenHighPanel"
    self.layer = "UI"
    self.panel_type = 7
    self.title = "title"

    self.model = OpenHighModel.GetInstance()

end

function OpenHighPanel:dctor()

end

function OpenHighPanel:Open()
    WindowPanel.super.Open(self)
end

function OpenHighPanel:OpenCallBack()
    self.model.is_openning = true
    self:SetTitleImgPos(-307,274.9)
end

function OpenHighPanel:LoadCallBack()
    self:GetAllCf()
    self.nodes = {
        "Top_Scroll/Viewport/top_con", "Top_Scroll/Viewport/top_con/OpenHighTopItem", "view_con", "Sundries/close",
    }
    self:GetChildren(self.nodes)
    self.top_obj = self.OpenHighTopItem.gameObject

    self:AddEvent()
    --  self:InitWinPanel()
    self:InitPanel()
end

function OpenHighPanel:InitWinPanel()
    self:SetPanelBgImage("iconasset/icon_big_bg_img_book_bg", "img_book_bg")
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("openHigh_image", "OpenHigh_Title_Img")
    self:SetTitleImgPos(503, 279)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3")
end

function OpenHighPanel:GetAllCf()
    self.model:CheckActListId()
    local list = self.model.act_id_list
    for i, v in pairs(list) do
        local theme_cf = OperateModel.GetInstance():GetConfig(v)
        self.model:SetThemeCf(theme_cf)
    end
    self.model:GetRewaCf()
end

function OpenHighPanel:AddEvent()
    self.model_event = {}
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.close.gameObject, call_back)

    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.TopItemClick, handler(self, self.HandleTopItemClick))
    self.model_event[#self.model_event + 1] = self.model:AddListener(OpenHighEvent.CloseOpenHighPanel, handler(self, self.Close))
end

function OpenHighPanel:InitPanel()
    self:LoadTopItem()
end

function OpenHighPanel:LoadTopItem()
    local list = self.model:GetOHThemeList()
    self.model.default_sel_theme = list[1].id
    local len = #list
    self.top_item_list = self.top_item_list or {}
    for i = 1, len do
        local item = self.top_item_list[i]
        if not item then
            item = OpenHighTopItem(self.top_obj, self.top_con)
            self.top_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.top_item_list do
        local item = self.top_item_list[i]
        item:SetVisible(false)
    end
end

function OpenHighPanel:HandleTopItemClick(act_id)
    if act_id == 120101 then
        if not self.high_view then
            self.high_view = HighView(self.view_con, "UI")
        end
        self:PopUpChild(self.high_view)
    elseif act_id == 120201 then
        if not self.wedding_view then
            self.wedding_view = WeddingView(self.view_con, "UI")
        end
        self:PopUpChild(self.wedding_view)
    elseif act_id == 120301 then
        if not self.cole_view then
            self.cole_view = WordCollectView(self.view_con, "UI")
        end
        self:PopUpChild(self.cole_view)
    elseif act_id == 120401 then
        if not self.create_club_view then
            self.create_club_view = CreateClubView(self.view_con, "UI")
        end
        self:PopUpChild(self.create_club_view)
    elseif act_id == OperateModel:GetInstance():GetActIdByType(205) then
        if not self.club_fight_view then
            self.club_fight_view = ClubFightView(self.view_con, 'UI')
        end
        self:PopUpChild(self.club_fight_view)
    end
end

function OpenHighPanel:CloseCallBack()
    self.model.is_openning = false
    for i, v in pairs(self.top_item_list) do
        if v then
            v:destroy()
        end
    end
    self.top_item_list = {}
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    if self.high_view then
        self.high_view:destroy()
        self.high_view = nil
    end
    if self.wedding_view then
        self.wedding_view:destroy()
        self.wedding_view = nil
    end
    if self.cole_view then
        self.cole_view:destroy()
        self.cole_view = nil
    end
    if self.create_club_view then
        self.create_club_view:destroy()
        self.create_club_view = nil
    end
    if self.club_fight_view then
        self.club_fight_view:destroy()
        self.club_fight_view = nil
    end
end