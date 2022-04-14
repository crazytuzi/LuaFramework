-- @Author: lwj
-- @Date:   2019-02-23 15:39:24
-- @Last Modified time: 2019-02-23 15:39:27

CandyGiveGiftPanel = CandyGiveGiftPanel or class("CandyGiveGiftPanel", WindowPanel)
local CandyGiveGiftPanel = CandyGiveGiftPanel

function CandyGiveGiftPanel:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyGiveGiftPanel"
    self.layer = "UI"
    self.panel_type = 6

    self.model = CandyModel.GetInstance()
    self.gift_list = {}
end

function CandyGiveGiftPanel:dctor()
end

function CandyGiveGiftPanel:Open(count)
    self.remain_count = count
    CandyGiveGiftPanel.super.Open(self)
end

function CandyGiveGiftPanel:LoadCallBack()
    self.nodes = {
        "btn_give", "btn_fetch", "top_text", "Num_bg/remain_num", "gift_content/CandyGiftItem", "btn_record", "gift_content",
        "btn_record/reco_red_con",
    }
    self:GetChildren(self.nodes)
    self.top_text = GetText(self.top_text)
    self.remain_num = GetText(self.remain_num)
    self.gift_gameObject = self.CandyGiftItem.gameObject

    self:AddEvent()
    self:InitWinPanel()
    self:InitPanel()
end
function CandyGiveGiftPanel:AddEvent()
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    local function callback()
        if self.remain_count == 0 then
            Notify.ShowText("Not enough attempts")
        else
            self.model:Brocast(CandyEvent.RequestToSerGiveGift)
        end
    end
    AddButtonEvent(self.btn_give.gameObject, callback)

    local function callback()
        self.model.is_showing_record_rd = false
        self:SetRecoRedDot(false)
        self.model:Brocast(CandyEvent.UpdateRecoBtnRD)
        GlobalEvent:Brocast(CandyEvent.UpdateCandyChatIconRD, false)
        self.model:Brocast(CandyEvent.RequestCandyRecord, 1)
    end
    AddButtonEvent(self.btn_record.gameObject, callback)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(CandyBuyPanel):Open(self.remain_count)
    end
    AddButtonEvent(self.btn_fetch.gameObject, callback)

    self.updateremainnum_event_id = self.model:AddListener(CandyEvent.UpdateGiveGiftRemainNum, handler(self, self.UpdateRemainNum))
    self.update_reco_rd_event_id = self.model:AddListener(CandyEvent.UpdateRecoBtnRD, handler(self, self.UpdateRecoRD))
end

function CandyGiveGiftPanel:UpdateRecoRD()
    self:SetRecoRedDot(self.model.is_showing_record_rd)
end

function CandyGiveGiftPanel:InitWinPanel()
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("candy_image", "CandyGiveGift_Title_Img")
    self:SetTitleImgPos(-10, 250)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3", true)
end

function CandyGiveGiftPanel:InitPanel()
    self.target_name = self.model.targetPlayerName
    self:LoadGiftItem()
    self.top_text.text = string.format(ConfigLanguage.Candy.GiveGiftShowText, self.target_name)
    self:CheckRemainText()
end

function CandyGiveGiftPanel:UpdateRemainNum(num)
    self.remain_count = num
    self:CheckRemainText()
end

function CandyGiveGiftPanel:CheckRemainText()
    if self.remain_count == 0 then
        SetColor(self.remain_num, 255, 0, 0, 255)
    else
        SetColor(self.remain_num, 123, 62, 40, 255)
    end
    self.remain_num.text = self.remain_count
end

function CandyGiveGiftPanel:LoadGiftItem()
    local tbl = Config.db_candyroom_gift
    for i = 1, #tbl do
        local data = {}
        local item = CandyGiftItem(self.gift_gameObject, self.gift_content)
        data = tbl[i]
        item:SetData(data)
        self.gift_list[#self.gift_list + 1] = item
    end
end

function CandyGiveGiftPanel:OpenCallBack()
    self:SetRecoRedDot(self.model.is_showing_record_rd)
end

function CandyGiveGiftPanel:CloseCallBack()
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
    for i, v in pairs(self.gift_list) do
        if v then
            v:destroy()
        end
    end
    self.gift_list = {}

    if self.updateremainnum_event_id then
        self.model:RemoveListener(self.updateremainnum_event_id)
    end
    self.updateremainnum_event_id = nil
end

function CandyGiveGiftPanel:SetRecoRedDot(isShow)
    if not self.reco_red_dot then
        self.reco_red_dot = RedDot(self.reco_red_con, nil, RedDot.RedDotType.Nor)
    end
    self.reco_red_dot:SetPosition(0, 0)
    self.reco_red_dot:SetRedDotParam(isShow)
end
