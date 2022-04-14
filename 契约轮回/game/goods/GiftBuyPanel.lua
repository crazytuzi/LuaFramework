--
-- @Author: LaoY
-- @Date:   2018-12-14 15:30:21
--
GiftBuyPanel = GiftBuyPanel or class("GiftBuyPanel", WindowPanel)
local GiftBuyPanel = GiftBuyPanel

function GiftBuyPanel:ctor()
    self.abName = "goods"
    self.assetName = "GiftBuyPanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

    self.panel_type = 4                                --窗体样式  1 1280*720  2 850*545
    self.show_sidebar = false        --是否显示侧边栏
    self.table_index = nil
    self.model = GoodsModel:GetInstance()
    self.item_list = {}
    self.global_event_list = {}
end

function GiftBuyPanel:dctor()
    if self.global_event_list then
        self.model:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    for k, item in pairs(self.item_list) do
        item:destroy()
    end
    self.item_list = {}
end

function GiftBuyPanel:Open(gift_id, uid, number)
    self.gift_id = gift_id
    self.uid = uid
    self.number = number
    GiftBuyPanel.super.Open(self)
end

function GiftBuyPanel:LoadCallBack()
    self.nodes = {
        "text_old", "scroll", "scroll/Viewport/Content", "btn_sure", "text_cost", "text_cur", "btn_cancel", "img_icon_cur", "img_icon_old", "text_title", "dicount",
        "title",
    }
    self:GetChildren(self.nodes)

    self.text_old_component = self.text_old:GetComponent('UILineText')
    self.text_cur_component = self.text_cur:GetComponent('Text')
    self.text_cur_rect = self.text_cur:GetComponent("RectTransform")
    self.text_cost_component = self.text_cost:GetComponent('Text')
    self.title = GetText(self.title)

    self.text_title_component = self.text_title:GetComponent('Text')

    self.img_icon_old_component = self.img_icon_old:GetComponent('Image')
    self.img_icon_cur_component = self.img_icon_cur:GetComponent('Image')

    self.dicount = GetText(self.dicount)

    -- self:SetTileTextImage(self.abName .. "_image","img_title_gift_1",false)
    self:SetTitleVisible(false)
    SetLocalPosition(self.text_cur_rect, 142, -83)
    SetSizeDelta(self.text_cur_rect, 216, 30)
    self:AddEvent()
end

function GiftBuyPanel:AddEvent()
    local function call_back(target, x, y)
        self:Close()
    end
    AddClickEvent(self.btn_cancel.gameObject, call_back)

    local function call_back(target, x, y)
        if RoleInfoModel:GetInstance():CheckGold(self.cost_number, self.cost_id) then
            -- GoodsController:GetInstance():RequestUseGoods(self.uid,self.number)
            GoodsController:GetInstance():RequestUseGoods(self.uid, self.number)
        end
    end
    AddClickEvent(self.btn_sure.gameObject, call_back)

    local function call_back(item_id)
        if self.gift_id == item_id then
            self:Close()
        end
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(GoodsEvent.UseGiftSuccess, call_back)
end

function GiftBuyPanel:OpenCallBack()
    self:UpdateView()
end

function GiftBuyPanel:UpdateView()
    local gift_config = Config.db_item_gift[self.gift_id]
    if not gift_config then
        return
    end
    self.title.text = gift_config.name
    self.text_title_component.text = gift_config.name

    self.gift_config = gift_config
    local cost_config = String2Table(gift_config.cost)
    local cost_id = cost_config[1]
    if not cost_id then
        return
    end
    self.cost_id = cost_id
    local cost_number = cost_config[2]
    self.cost_number = cost_number

    local item_config = Config.db_item[self.cost_id] or {}
    local cost_str
    if self.gift_config.type == enum.GIFT_TYPE.GIFT_TYPE_FIXED then
        cost_str = string.format("Spend <color=#19c114>%s%s</color> to open the pack to get", cost_number, item_config.name or "")
    else
        cost_str = string.format("Spend <color=#19c114>%s%s</color> to open the pack to randomly get one from the below", cost_number, item_config.name or "")
    end
    self.text_cost_component.text = cost_str

    local space = "      "
    self.text_cur_component.text = string.format("Price：%s<color=#19c114>%s</color>", space, cost_number)
    self:SetCurIcon(self.cost_id)

    local old_cost = String2Table(gift_config.original_cost)
    if not table.isempty(old_cost) then
        local old_cost_id = old_cost[1]
        local old_cost_num = old_cost[2]
        self.text_old_component.text = string.format("Original Price: %s/%s", space .. "  ", old_cost_num)
        self:SetOldIcon(old_cost_id)
    end

    local list = String2Table(gift_config.reward)
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.Content)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        local info = list[i]
        local param = {}
        param["model"] = self.model
        param["item_id"] = info[1]
        param["num"] = info[2]
        param["can_click"] = true
        item:SetIcon(param)
        --item:UpdateIconByItemIdClick(info[1],info[2])
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
    local dis = gift_config.discount / 10
    self.dicount.text = dis
end

function GiftBuyPanel:SetOldIcon(old_icon)
    if self.old_icon == old_icon then
        return
    end
    self.old_icon = old_icon
    GoodIconUtil.GetInstance():CreateIcon(self, self.img_icon_old_component, old_icon, true)
end

function GiftBuyPanel:SetCurIcon(cur_icon)
    if self.cur_icon == cur_icon then
        return
    end
    self.cur_icon = cur_icon
    GoodIconUtil.GetInstance():CreateIcon(self, self.img_icon_cur_component, cur_icon, true)
end

function GiftBuyPanel:CloseCallBack()

end