--
-- @Author: LaoY
-- @Date:   2018-12-18 17:20:38
--

RewardBackground = RewardBackground or class("RewardBackground", BaseItem)
local RewardBackground = RewardBackground

function RewardBackground:ctor(parent_node, layer, close_call_back,loaded_callback)
    self.abName = "reward"
    self.assetName = "RewardBackground"

    self.close_call_back = close_call_back
    self.loaded_callback = loaded_callback
    self.item_list = {}
    RewardBackground.super.Load(self)
end

function RewardBackground:dctor()
    destroySingle(self.eft)
    for k, item in pairs(self.item_list) do
        item:destroy()
    end
    self.item_list = {}
    self.loaded_callback = nil
end

function RewardBackground:LoadCallBack()
    self.nodes = {
        "bg_con/btn_close", "RewardButton", "btn_con", "img_bg", "bg_con", "bg_con/eft_con","bg_con/img_title_1_1",
    }
    self:GetChildren(self.nodes)
    self:LoadTitleEft()
    if not self.close_call_back then
        SetVisible(self.btn_close, false)
    end
    self.RewardButton_gameobject = self.RewardButton.gameObject
    SetVisible(self.RewardButton, false)

    self.img_bg_component = self.img_bg:GetComponent('Image')

    if self.btn_con_y ~= nil then
        self:SetButtonConPosition(self.btn_con_y)
    end
    if self.img_height ~= nil then
        self:SetBackgroundHeight(self.img_height)
    end
    if self.title_con_y ~= nil then
        self:SetTitlePosition(self.title_con_y)
    end

    self:UpdateInfo()

    self:AddEvent()

    if self.loaded_callback then
        self.loaded_callback()
    end
end

function RewardBackground:LoadTitleEft()
    destroySingle(self.eft)

    --特效有问题 先注释了
    --self.eft = UIEffect(self.eft_con, 10126, false, self.layer)

    --LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_pic.transform, nil, true, canvas_order + 2)
    --LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_img.transform, nil, true, canvas_order + 3)
end

function RewardBackground:AddEvent()
    local function call_back(target, x, y)
        if self.close_call_back then
            self.close_call_back()
        end
    end
    AddClickEvent(self.btn_close.gameObject, call_back)
end

function RewardBackground:SetButtonConPosition(y)
    self.btn_con_y = y
    if self.is_loaded then
        SetLocalPositionY(self.btn_con, y)
    end
end

function RewardBackground:SetBackgroundHeight(height)
    self.img_height = height
    if self.is_loaded then
        SetSizeDeltaY(self.img_bg, height)
    end
end

function RewardBackground:SetTitlePosition(y)
    self.title_con_y = y
    if self.is_loaded then
        SetLocalPositionY(self.bg_con, y)
    end
end

function RewardBackground:UpdateInfo()
    if not self.btn_list then
        return
    end

    local list = self.btn_list
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = RewardButton(self.RewardButton_gameobject, self.btn_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(i, list[i])
    end

    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function RewardBackground:GetRewardButton()
end

function RewardBackground:SetData(data)
    self.btn_list = data
    if self.is_loaded then
        self:UpdateInfo()
    end
end