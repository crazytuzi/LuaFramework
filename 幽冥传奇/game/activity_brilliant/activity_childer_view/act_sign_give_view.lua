SignGiveView = SignGiveView or BaseClass(ActBaseView)

function SignGiveView:__init(view, parent, act_id)
    self:LoadView(parent)
end

function SignGiveView:__delete()
    if self.act_sign_list then
        self.act_sign_list:DeleteMe()
        self.act_sign_list = nil
    end

    if self.cell_auth_list then
        self.cell_auth_list:DeleteMe()
        self.cell_auth_list = nil
    end
end

function SignGiveView:InitView()
    self.item_index = 1
    self:CreateSignList()
    XUI.AddClickEventListener(self.node_t_list.btn_lq_reward.node, BindTool.Bind(self.OnClickGetWardBtn, self), false)
end

function SignGiveView:OnClickGetWardBtn()
    ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.DLJS, self.item_index)
end

function SignGiveView:CreateSignList()
    local ph = self.ph_list.ph_sign_list
    self.act_sign_list = ListView.New()
    self.act_sign_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActDLJSRender, nil, false, self.ph_list.ph_sign_item)
    self.act_sign_list:SetItemsInterval(-2)
    -- self.act_sign_list:SetJumpDirection(ListView.Top)
    self.act_sign_list:SetSelectCallBack(BindTool.Bind(self.SelectActivityTypeCallback, self))
    self.node_t_list.layout_sign_give.node:addChild(self.act_sign_list:GetView(), 100)
    
    if nil == self.cell_auth_list then
        local ph = self.ph_list.ph_award_list
        self.cell_auth_list = ListView.New()
        self.cell_auth_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
        self.cell_auth_list:GetView():setAnchorPoint(0, 0)
        self.cell_auth_list:SetItemsInterval(15)
        self.node_t_list.layout_sign_give.node:addChild(self.cell_auth_list:GetView(), 10)
    end
end

function SignGiveView:SelectActivityTypeCallback(item)
    local data = item:GetData()
   
    self.item_index = item:GetIndex()
    self:FlushRewardData(self.item_index, data)
end

function SignGiveView:RefreshView(param_list)
    local rate_list = ActivityBrilliantData.Instance:GetDLJSData()
    local item_index = ActivityBrilliantData.Instance:GetDLJSRewardIndex()
    self.item_index = item_index
    self.act_sign_list:SetDataList(rate_list) 
    self.act_sign_list:SetCenter()
    self:FlushRewardData(item_index, rate_list[item_index])
    
end

-- 刷新选择数据
function SignGiveView:FlushRewardData(index, data)
    self.act_sign_list:ChangeToIndex(index)
    local is_lq = ActivityBrilliantData.Instance:GetDLJSRewardSign(index)
    self.node_t_list.img_day.node:loadTexture(ResPath.GetActivityBrilliant("act_2_day_" .. index))
    self.node_t_list.img_is_lq.node:setVisible(is_lq == 1)
    self.node_t_list.btn_lq_reward.node:setEnabled(index <= data.dl_day)
    self.node_t_list.btn_lq_reward.node:setVisible(is_lq == 0)

    local data_list = {}
    for k, v in pairs(data.award) do
     if type(v) == "table" then
         table.insert(data_list, ItemData.FormatItemData(v))
     end
    end
    self.cell_auth_list:SetData(data_list)
end

ActDLJSRender = ActDLJSRender or BaseClass(BaseRender)
function ActDLJSRender:__init()
end

function ActDLJSRender:__delete()

end

function ActDLJSRender:CreateChild()
    BaseRender.CreateChild(self)
    
    self.node_tree.img_arrow.node:setVisible(self.index ~= 1)
    self.node_tree.img_day.node:loadTexture(ResPath.GetAct_84_93("img_day_" .. self.index))
    
end

function ActDLJSRender:OnFlush()
    if nil == self.data then return end
    
   self.node_tree.img_94_bg.node:setGrey(self.data.is_lq == 1)

   if self.cache_select and self.is_select then
        self.cache_select = false
        self:CreateSelectEffect()
    end
end

-- 创建选中特效
function ActDLJSRender:CreateSelectEffect()
    if nil == self.node_tree.img_94_bg then
        self.cache_select = true
        return
    end
    local size = self.node_tree.img_94_bg.node:getContentSize()
    self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetAct_84_93("act94_bg_3"), true)
    if nil == self.select_effect then
        ErrorLog("BaseRender:CreateSelectEffect fail")
        return
    end
    self.node_tree.img_94_bg.node:addChild(self.select_effect, 998)
end