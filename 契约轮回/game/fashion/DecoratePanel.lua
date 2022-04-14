-- @Author: lwj
-- @Date:   2019-11-14 17:27:53 
-- @Last Modified time: 2020-01-10 15:56:56

DecoratePanel = DecoratePanel or class("DecoratePanel", WindowPanel)
local DecoratePanel = DecoratePanel

function DecoratePanel:ctor()
    self.abName = "fashion"
    self.assetName = "DecoratePanel"
    self.layer = "UI"

    self.panel_type = 2
    self.model = FashionModel.GetInstance()
end

function DecoratePanel:dctor()

end

function DecoratePanel:Open(side_idx, defa_id)
    side_idx = side_idx or 1
    if side_idx == 11 or side_idx == 12 then
        self.default_table_index = side_idx == 11 and 2 or 1
    else
        self.default_table_index = side_idx
    end
    if defa_id then
        self.model.defa_deco_id = defa_id
    end
    WindowPanel.Open(self)
end

function DecoratePanel:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)
    self:SetTileTextImage("fashion_image", "Decorate_Title_Img")

    self:AddEvent()
    self:InitPanel()
end

function DecoratePanel:AddEvent()
    local function callback(is_show, idx)
        self:SetIndexRedDotParam(idx, is_show)
    end
    self.add_rd_event_id = GlobalEvent:AddListener(FashionEvent.AddDecoRD, callback)

    local function callback(is_show, index)
        self:SetIndexRedDotParam(index, is_show)
    end
    self.change_side_rd_event_id = GlobalEvent:AddListener(FashionEvent.ChangeDecoSideRD, callback)
end

function DecoratePanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    if index == 1 then
        self.model.openning_index = 12
    else
        self.model.openning_index = 11
    end
    if index == 1 then
        if not self.chatFrame_view then
            self.chatFrame_view = ChatFrameView(self.child_transform, "UI", 12)
        end
        self:PopUpChild(self.chatFrame_view)
    elseif index == 2 then
        if not self.frame_view then
            self.frame_view = IconFrameView(self.child_transform, "UI", 11)
        end
        self:PopUpChild(self.frame_view)
    end
end

function DecoratePanel:InitPanel()
    self:UpdateSideRD()
end

function DecoratePanel:UpdateSideRD()
    for i = 1, 2 do
        local idx
        if i == 1 then
            idx = 12
        elseif i == 2 then
            idx = 11
        end
        local is_show_side_rd = FashionModel.GetInstance():CheckIsShowSideRedDot(idx)
        self:SetIndexRedDotParam(i, is_show_side_rd)
    end
end

function DecoratePanel:CloseCallBack()
    self.model.defa_deco_id = nil
    self.model.is_can_click_dress = true
    self.model.is_can_click_activa = true
    self.model.curItemId = 0
    self.model.cur_icon_id = 0
    self.model.cur_chat_id = 0
    self.model.is_activa = false
    if self.change_side_rd_event_id then
        self.model:RemoveListener(self.change_side_rd_event_id)
        self.change_side_rd_event_id = nil
    end
    if self.add_rd_event_id then
        GlobalEvent:RemoveListener(self.add_rd_event_id)
        self.add_rd_event_id = nil
    end
    if self.frame_view then
        self.frame_view:destroy()
        self.frame_view = nil
    end
    if self.chatFrame_view then
        self.chatFrame_view:destroy()
        self.chatFrame_view = nil
    end
end

