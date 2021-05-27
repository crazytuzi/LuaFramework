SingleChargeView = SingleChargeView or BaseClass(ActBaseView)

function SingleChargeView:__init(view, parent, act_id)
    self:LoadView(parent)
end

function SingleChargeView:__delete()
    if self.grid_single_charge_scroll_list then
        self.grid_single_charge_scroll_list:DeleteMe()
        self.grid_single_charge_scroll_list = nil
    end
end

function SingleChargeView:InitView()
    self:CreateSingleChargeGridScroll()
end

function SingleChargeView:RefreshView(param_list)
    local data = ActivityBrilliantData.Instance
    --设置列表数据
    self.grid_single_charge_scroll_list:SetDataList(data:GetSinglechargeItemList())
    --跳至顶部
    self.grid_single_charge_scroll_list:JumpToTop()
end


--创建列表
function SingleChargeView:CreateSingleChargeGridScroll()
    if nil == self.node_t_list.layout_single_charge then
        return
    end
    if nil == self.grid_single_charge_scroll_list then
        local ph = self.ph_list.ph_single_charge_list
        local ph_item = self.ph_list.ph_single_charge_item
        --创建滚动列表
        self.grid_single_charge_scroll_list = GridScroll.New()
        --设置列表的位置，SingleChargeItemRender：item格式，方向
        self.grid_single_charge_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 2, SingleChargeItemRender, ScrollDir.Vertical, false, ph_item)
       --将列表添加到当前面板中
        self.node_t_list.layout_single_charge.node:addChild(self.grid_single_charge_scroll_list:GetView(), 100)
    end
end