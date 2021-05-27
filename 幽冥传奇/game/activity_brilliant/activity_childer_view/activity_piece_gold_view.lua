PieceGoldView = PieceGoldView or BaseClass(ActBaseView)

function PieceGoldView:__init(view, parent, act_id)
    self:LoadView(parent)
end

function PieceGoldView:__delete()
    if self.payward_list then
        self.payward_list:DeleteMe()
        self.payward_list = nil
    end
end

function PieceGoldView:InitView()
    self:CreatePayScroll()
end

function PieceGoldView:CreatePayScroll()
    if nil == self.payward_list then
        local ph = self.ph_list.ph_pay_list
        self.payward_list = GridScroll.New()
        self.payward_list:Create(ph.x,ph.y,ph.w,ph.h,1,100,GoldRender,ScrollDir.Vertical,false,self.ph_list.ph_pay_item)
        self.node_t_list.layout_piece_gold.node:addChild(self.payward_list:GetView(), 100)
    end

end

function PieceGoldView:RefreshView(param_list)
    local rate_list = ActivityBrilliantData.Instance:GetGoldPayList()
    local num_count = ActivityBrilliantData.Instance:GetActDaily()
    self.payward_list:SetDataList(rate_list)
    self.node_t_list.lbl_paypiece_num.node:setString(num_count)
    self.payward_list:JumpToTop()
end

GoldRender = GoldRender or BaseClass(BaseRender)
function GoldRender:__init()
end

function GoldRender:__delete()
    if self.cell_auth_list then
        self.cell_auth_list:DeleteMe()
        self.cell_auth_list = nil
    end
end

function GoldRender:CreateChild()
    BaseRender.CreateChild(self)
    if nil == self.cell_auth_list then
        local ph = self.ph_list.ph_award_list
        self.cell_auth_list = ListView.New()
        self.cell_auth_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
        self.cell_auth_list:GetView():setAnchorPoint(0, 0)
        self.cell_auth_list:SetItemsInterval(15)
        self.view:addChild(self.cell_auth_list:GetView(), 10)
    end
end

function GoldRender:OnFlush()
    local data_list = {}
    local num_count = ActivityBrilliantData.Instance:GetActDaily()
	for k, v in pairs(self.data.awards) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
    end
    self.cell_auth_list:SetData(data_list)
    self.node_tree.lbl_pecice_num.node:setString(self.data.numbers .. Language.Activity.Wing)
    local color = num_count >= self.data.numbers and COLOR3B.GREEN or COLOR3B.RED
    self.node_tree.lbl_count.node:setString("(" .. num_count .. "/" .. self.data.numbers .. ")")
    self.node_tree.lbl_count.node:setColor(color)
    XUI.AddClickEventListener(self.node_tree.btn_award_lingqu.node, BindTool.Bind(self.OnClickGetWardBtn, self, self.data.index), false)
    if self.data.numbers > num_count then
        self.node_tree.img_state.node:setVisible(true)
        self.node_tree.img_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
        self.node_tree.btn_award_lingqu.node:setVisible(false)
        self.node_tree.img_flag.node:setVisible(false)
    else
        if self.data.sign == 1 then
            self.node_tree.img_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
            self.node_tree.img_state.node:setVisible(true)
            self.node_tree.btn_award_lingqu.node:setVisible(false)
            self.node_tree.img_flag.node:setVisible(false)
        else
            if self.data.sign == 0 then
                self.node_tree.img_state.node:setVisible(false)
                self.node_tree.btn_award_lingqu.node:setVisible(true)
                self.node_tree.img_flag.node:setVisible(true)
                self.node_tree.btn_award_lingqu.node:setEnabled(true)
            end
        end
    end
   
end

function GoldRender:OnClickGetWardBtn(index)
    ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.XFJL, index)
end




