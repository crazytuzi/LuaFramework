MagicalComeView = MagicalComeView or BaseClass(ActBaseView)

function MagicalComeView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function MagicalComeView:__delete()

end

function MagicalComeView:InitView()
	-- self.node_t_list.btn_xunbao.node:addClickEventListener(BindTool.Bind(self.OnClickGoXBHandler, self))
	self:CreateActRechgeList()
end

function MagicalComeView:RefreshView(param_list)
	-- local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SBJL)
	-- if data and data.config then 
	-- 	local cfg = data.config
	-- 	self.node_t_list.img_des.node:loadTexture(ResPath.GetActivityBrilliant("act_67_des_"..cfg.des_id))
	-- 	local ph = self.ph_list.ph_act_eff
	-- 	local effect_id = cfg.effect_id or 414
	-- 	local act_effect = RenderUnit.CreateEffect(effect_id, self.node_t_list.layout_magical_come.node, 999)
	-- 	act_effect:setPosition(ph.x, ph.y)
	-- end
	self.act_67_list:SetDataList(ActivityBrilliantData.Instance:GetFanliData())

end

function MagicalComeView:CreateActRechgeList()
	local ph = self.ph_list.ph_act_67_list
	self.act_67_list = ListView.New()  -- 创建ListView
	self.act_67_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActRechgeRender, nil, nil, self.ph_list.ph_act_67_render)
	self.act_67_list:GetView():setAnchorPoint(0.5, 0.5)
	self.act_67_list:SetMargin(2)
	self.act_67_list:SetItemsInterval(5)
	self.act_67_list:SetJumpDirection(ListView.TOP)
	self.node_t_list.layout_magical_come.node:addChild(self.act_67_list:GetView(), 10)
	self:AddObj("act_67_list")
end

-- function MagicalComeView:UpdateSpareTime(time)
-- 	local now_time = TimeCtrl.Instance:GetServerTime()
-- 	local str = TimeUtil.FormatSecond2Str(time - now_time)
-- 	self.node_t_list.lbl_act_time.node:setString(str)
-- end

-- function MagicalComeView:OnClickGoXBHandler()
-- 	ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
-- 	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
-- end

ActRechgeRender = ActRechgeRender or BaseClass(BaseRender)
function ActRechgeRender:__init()
	self.save_data = {}
end

function ActRechgeRender:__delete()
	if nil ~= self.beishu_num then
		self.beishu_num:DeleteMe()
		self.beishu_num = nil
	end

	if nil ~= self.zuanshi_num then
		self.zuanshi_num:DeleteMe()
		self.zuanshi_num = nil
	end
end

function ActRechgeRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_rechge.node, BindTool.Bind(self.OnClickChongzhi, self), true)
	-- XUI.AddClickEventListener(self.node_tree.btn_find_pre.node, BindTool.Bind(self.OnClickFindNowHandle, self, 2), true)

	-- self:AddObj("task_award_list")
	self:CreateBeishuNum()
end

function ActRechgeRender:CreateBeishuNum()
	-- 倍数数字创建
	local ph = self.ph_list["ph_beishu_num"]
	self.beishu_num = NumberBar.New()
	self.beishu_num:SetRootPath(ResPath.GetActivityBrilliant("act_67_num_"))
	self.beishu_num:SetPosition(ph.x, ph.y)
	self.beishu_num:SetGravity(NumberBarGravity.Left)
	-- self.beishu_num:SetSpace(-8)
	self.view:addChild(self.beishu_num:GetView(), 300, 300)

	-- 钻石数字创建
	ph = self.ph_list["ph_gold_num"]
	self.zuanshi_num = NumberBar.New()
	self.zuanshi_num:SetRootPath(ResPath.GetActivityBrilliant("act_67_gold_"))
	self.zuanshi_num:SetPosition(ph.x+35, ph.y)
	self.zuanshi_num:SetGravity(NumberBarGravity.Right)
	self.zuanshi_num:SetSpace(3)
	self.view:addChild(self.zuanshi_num:GetView(), 300, 300)
end

function ActRechgeRender:OnClickChongzhi()
	local re_type = string.format("%d|%d", self.data.act_id, self.data.cmd_id)
	ChongzhiCtrl.ActivityCharge(self.data.rmb_num, re_type)
end

function ActRechgeRender:OnFlush()
	if nil == self.data then return end

	self.beishu_num:SetNumber(self.data.beishu)
	self.zuanshi_num:SetNumber(self.data.zs_num)
	self.node_tree.is_complete.node:setVisible(self.data.is_falg)
	local text = string.format("充值%s元", self.data.rmb_num)
	self.node_tree.btn_rechge.node:setTitleText(text)
	self.node_tree.btn_rechge.node:setVisible(not self.data.is_falg)
	self.node_tree.lbl_remind_time.node:setString(string.format("剩余次数：%d", self.data.remind_num))
end

function ActRechgeRender:CreateSelectEffect()
end