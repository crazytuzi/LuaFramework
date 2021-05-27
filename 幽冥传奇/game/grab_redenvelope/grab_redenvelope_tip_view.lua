GrabRedEnvelopeTipView = GrabRedEnvelopeTipView or BaseClass(BaseView)
function GrabRedEnvelopeTipView:__init( ... )
	self.texture_path_list[1] = 'res/xui/grap_red_envlope.png'
	self.is_any_click_close = true
	--new_fashion_ui_cfg
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"grop_godenvlope_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
end

function GrabRedEnvelopeTipView:__delete( ... )
	-- body
end

function GrabRedEnvelopeTipView:ReleaseCallBack( ... )
	if self.numbar_zs then
		self.numbar_zs:DeleteMe()
		self.numbar_zs = nil
	end

	if self.need_number then
		self.need_number:DeleteMe()
		self.need_number = nil
	end

	if self.grap_red_envlope then
		GlobalEventSystem:UnBind(self.grap_red_envlope)
		self.grap_red_envlope = nil
	end

	if self.recharge_change then
		GlobalEventSystem:UnBind(self.recharge_change)
		 self.recharge_change = nil
	end
end

function GrabRedEnvelopeTipView:LoadCallBack( ... )
	self:GetNumber()
	XUI.AddClickEventListener(self.node_t_list.btn_get.node, BindTool.Bind1(self.OnSureGet, self))

	self.grap_red_envlope = GlobalEventSystem:Bind(GRAP_REDENVELOPE_EVENT.GetGrapRedEnvlope,BindTool.Bind1(self.FlushShow,self))
	self.recharge_change = GlobalEventSystem:Bind(OtherEventType.TODAY_CHARGE_GOLD_CHANGE, BindTool.Bind1(self.FlushShow,self))
end

function GrabRedEnvelopeTipView:OpenCallBack( ... )
	-- body
end

function GrabRedEnvelopeTipView:CloseCallBack( ... )
	-- body
end

function GrabRedEnvelopeTipView:GetNumber( ... )
	if nil == self.numbar_zs then
		local ph = self.ph_list["ph_get_number"]
		self.numbar_zs = NumberBar.New()
		self.numbar_zs:SetRootPath(ResPath.GetGrapRedEnvlopePath("num_119_"))
		self.numbar_zs:SetPosition(ph.x + 20, ph.y -8)
		self.numbar_zs:SetGravity(NumberBarGravity.Center)
		self.node_t_list["layout_get_reward"].node:addChild(self.numbar_zs:GetView(), 300, 300)
	end
	---self.numbar_zs:SetNumber(10000)

	if nil == self.need_number then
		local ph = self.ph_list["ph_number2"]
		self.need_number = NumberBar.New()
		self.need_number:SetRootPath(ResPath.GetGrapRedEnvlopePath("num_120_"))
		self.need_number:SetPosition(ph.x + 50, ph.y)
		self.need_number:SetGravity(NumberBarGravity.Center)
		self.node_t_list["layout_get_reward"].node:addChild(self.need_number:GetView(), 300, 300)
	end
end

function GrabRedEnvelopeTipView:ShowIndexCallBack()
	self:Flush(index)
end

function GrabRedEnvelopeTipView:FlushShow()
	local had_money = GrabRedEnvelopeData.Instance:GetGrapRedEnvlope()
	local level = GrabRedEnvelopeData.Instance:GetCurLevel() or 0
	local money = (not ChargeRewardData.Instance:IsShouChong()) and GrabRedEnvelopeData.Instance:GetCanGetZuanSHi() or had_money
	if GrabRedEnvelopeData.Instance:GetIsFirstCharge() == 1 then
  		money = GrabRedEnvelopeData.Instance:GetCanGetZuanSHi()
  	end
	self.numbar_zs:SetNumber(money)

	local vis =  GrabRedEnvelopeData.Instance:GetIsShowMoney(level) and true or false
	self.node_t_list.img_had.node:setVisible(vis)
	local vis2 = not vis

	local need_num = GrabRedEnvelopeData.Instance:GetNeedNumber()
	self.need_number:SetNumber(need_num)
	self.need_number:SetVisible(vis2)

	self.node_t_list.img_show_desc2.node:setVisible(vis2)
	self.node_t_list.img_show_desc1.node:setVisible(vis)
end

function GrabRedEnvelopeTipView:OnFlush()
	self:FlushShow()
end


function GrabRedEnvelopeTipView:OnSureGet()
	if GrabRedEnvelopeData.Instance:GetIsFirstCharge() == 1 then
		GrabRedEnvelopeCtrl.Instance:SendGetRewardReq()
		GrabRedEnvelopeCtrl.Instance:SendGrapRedEnvlopeReq()
	else
		local need_num = GrabRedEnvelopeData.Instance:GetNeedNum()
		if  need_num> 0 then
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		else
			GrabRedEnvelopeCtrl.Instance:SendGetRewardReq()
			GrabRedEnvelopeCtrl.Instance:SendGrapRedEnvlopeReq()
			--GrabRedEnvelopeCtrl.Instance:SendGrapRedEnvlopeReq()
		end
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.GrapRobRedEnvelopeTip)
end