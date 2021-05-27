FbJySceneTip = FbJySceneTip or BaseClass(BaseView)

FbJySceneTip.TOP_TIP_FUBEN = {
	-- [FubenZongGuanCfg.fubens[5].fbid] = true,	--经验副本
}

function FbJySceneTip:__init()
	if FbJySceneTip.Instance then
		ErrorLog("not regisn twice")
	end
	FbJySceneTip.Instance = self

	self.texture_path_list = {
		"res/xui/fuben.png"
	}

	self.config_tab = {
		{"itemtip_ui_cfg", 13, {0}}
	}

	self.view = nil
	self.is_async_load = false

end

function FbJySceneTip:__delete()
end

function FbJySceneTip:ReleaseCallBack()
	if self.view then
		self.view:DeletView()
	end
	self.view = nil
end

function FbJySceneTip:OpenCallBack()
	self.event = GlobalEventSystem:Bind(OtherEventType.CAILIAO_INFO_CHANGE, function (fuben_event_id)
		--闯关成功后自动退出
		if fuben_event_id == 4 then
			GlobalTimerQuest:AddDelayTimer(function ()
				FubenCtrl.OutFubenReq(FubenZongGuanCfg.fubens[5].fbid)
				DungeonCtrl.SendLuckTurnbleReq(1, 5)
				self:Close()
			end, 0.5)
		end
	end)

	if self.view then
		self.view.SetDefultShow() 
		self.view.Update({monster = 0})
	end
end

function FbJySceneTip:CloseCallBack()
	GlobalEventSystem:UnBind(self.event)
end

function FbJySceneTip:LoadCallBack()
	self.view = self:CreateJYFBView()
end

function FbJySceneTip:ShowEXPFubenTip(tag, data)
	if nil == self.view then
		self:Open()
	end

	if tag == "exit" then
		self.view.ShowEnd()
	elseif tag == "open" then
		self:Open()
	elseif tag == "update" and nil ~= data then
		self.view.Update(data)
	end
end

function FbJySceneTip:OnFlush()
end

--经验副本
function FbJySceneTip:CreateJYFBView()
	local view = {}
	--顶部提示
	local top_tip_view = CLFBSceneTopTipRender.New()
	top_tip_view:SetUiConfig(self.ph_list.ph_top_tip_item, true)
	top_tip_view:SetAnchorPoint(0.5, 0.5)
	top_tip_view:SetPosition(280, 560)
	self.node_t_list.layout_jy_fuben_lingqu.node:addChild(top_tip_view:GetView())
	-- 设置点击穿透
	self.root_node:setTouchEnabled(false)

	--结束提示
	local end_tip_view = CLFBSceneEndTipRender.New()
	end_tip_view:SetUiConfig(self.ph_list.ph_jyfb_end, true)
	end_tip_view:SetAnchorPoint(0.5, 0.5)
	end_tip_view:SetPosition(280, 300)
	end_tip_view:SetVisible(false)
	self.node_t_list.layout_jy_fuben_lingqu.node:addChild(end_tip_view:GetView())

	function view.ShowEnd()
		self.root_node:setTouchEnabled(true)
		end_tip_view:SetVisible(true)
		top_tip_view:SetVisible(false)
	end

	function view.Update(data)
		top_tip_view:SetData(data)
	end

	function view.SetDefultShow() 
		end_tip_view:SetVisible(false)
		top_tip_view:SetVisible(true)
	end

	function view.DeletView() 
		if top_tip_view then
			top_tip_view:DeleteMe()
		end
	end

	--初始化
	view.Update({monster = 0})
	return view
end





------------------------------------------------
-- 进入场景时的顶部提示 如怪物数量，奖励等
-- @材料副本

CLFBSceneTopTipRender = CLFBSceneTopTipRender or BaseClass(BaseRender)
function CLFBSceneTopTipRender:__init()
	
end

function CLFBSceneTopTipRender:__delete()
	if self.fanli_cap ~= nil then
		self.fanli_cap:DeleteMe()
		self.fanli_cap = nil
	end
end

function CLFBSceneTopTipRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateFanliNum()
	self.cfg = FubenZongGuanCfg.fubens[5]
	-- XUI.RichTextSetCenter(self.node_tree.rich_kill_num.node)

	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(self.ph_list.ph_item_cell.x, self.ph_list.ph_item_cell.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local item = self.cfg.award[circle][1][1]
		self.cell:SetData({item_id = item.id, num = 1, is_bind = item.bind})
	end	
end

function CLFBSceneTopTipRender:OnFlush()
	if nil == self.data then return end
	--怪物数量刷新  
	local str = "{wordcolor;1eff00;%s}{wordcolor;FFCC00;/%s}"
	local content = string.format(str, self.data.monster, self.cfg.monsterMaxCount)
	RichTextUtil.ParseRichText(self.node_tree.rich_kill_num.node, content, 24)

	--经验数量
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local exp = self.cfg.award[circle][1][1].count / self.cfg.monsterMaxCount * self.data.monster
	self.Exp_numberbar:SetNumber(exp)
end


function CLFBSceneTopTipRender:CreateFanliNum()
	local cap_x, cap_y = self.node_tree.img_num_exp.node:getPosition()
	self.Exp_numberbar = NumberBar.New()
	self.Exp_numberbar:SetRootPath(ResPath.GetScene("zdl_y_"))
	self.Exp_numberbar:GetView():setColor(COLOR3B.GREEN)
	self.Exp_numberbar:SetPosition(cap_x + 35, cap_y-25)
	self.Exp_numberbar:SetSpace(-8)
	self.Exp_numberbar:SetGravity(NumberBarGravity.Center)
	self.view:addChild(self.Exp_numberbar:GetView(), 300, 300)
end


CLFBSceneEndTipRender = CLFBSceneEndTipRender or BaseClass(BaseRender)
function CLFBSceneEndTipRender:__init()
	
end

function CLFBSceneEndTipRender:__delete()
	if self.Exp_numberbar ~= nil then
		self.Exp_numberbar:DeleteMe()
		self.Exp_numberbar = nil
	end
end

function CLFBSceneEndTipRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cfg = FubenZongGuanCfg.fubens[5]
	self:CreateFanliNum()
	XUI.AddClickEventListener(self.node_tree.btn_close.node, function ()
		FbJySceneTip.Instance:Close()
	end)

	XUI.AddClickEventListener(self.node_tree.btn_lingqu_exp.node, function ()
		FubenCtrl.OutFubenReq(FubenZongGuanCfg.fubens[5].fbid)
		ViewManager:OpenViewByDef(ViewDef.Dungeon.Experience)
		FbJySceneTip.Instance:Close()
	end, true)
end

function CLFBSceneEndTipRender:OnFlush()
end

function CLFBSceneEndTipRender:CreateFanliNum()
	local cap_x, cap_y = self.node_tree.img_title.node:getPosition()
	self.Exp_numberbar = NumberBar.New()
	self.Exp_numberbar:SetRootPath(ResPath.GetScene("zdl_y_"))
	self.Exp_numberbar:GetView():setColor(COLOR3B.GREEN)
	self.Exp_numberbar:SetPosition(cap_x - 20, cap_y - 150)
	self.Exp_numberbar:SetSpace(-8)
	self.Exp_numberbar:SetGravity(NumberBarGravity.Center)
	self.view:addChild(self.Exp_numberbar:GetView(), 300, 300)


	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local exp = self.cfg.award[circle][1][1].count
	self.Exp_numberbar:SetNumber(exp)
end



--------------------------------------------------
-- 副本结束时的 奖励领取item

FbAwardSelecRender = FbAwardSelecRender or BaseClass(BaseRender)
function FbAwardSelecRender:__init()
	
end

function FbAwardSelecRender:__delete()
    if self.alert_window then
		self.alert_window:DeleteMe()
  		self.alert_window = nil
	end	
end

function FbAwardSelecRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.btn_lingqu.node:setPositionX(95)
	self.node_tree.img_gold.node:setPositionX(50)
	XUI.AddClickEventListener(self.node_tree.btn_lingqu.node, function ()
		local playergold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		if playergold < self.data.gold then
            self:OpenTipView()
			-- SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughGold)
		else
			DungeonCtrl.ExpFubenAwardReq(self.data.index)
		end
		
	end, true)
end

function FbAwardSelecRender:OpenTipView()
	if self.alert_window == nil then
		self.alert_window = Alert.New()
		self.alert_window:SetOkString(Language.Common.BtnRechargeText)
		self.alert_window:SetLableString(Language.Common.RechargeAlertText)
		self.alert_window:SetOkFunc(BindTool.Bind(self.OnChargeRightNow, self))
	end
	self.alert_window:Open()
end

--充值
function FbAwardSelecRender:OnChargeRightNow()
    ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function FbAwardSelecRender:CreateSelectEffect()
end

function FbAwardSelecRender:OnFlush()
	if nil == self.data then return end
	local item = ItemData.Instance:GetItemConfig(self.data.id)
	self.node_tree.lbl_exp_num.node:setString(item.name .. ":" .. self.data.exp_num)
	self.node_tree.img_times.node:loadTexture(ResPath.GetFuben("img_times_" .. self.data.index))
    if 3 == self.data.index then
        RenderUnit.CreateEffect(23, self.node_tree.btn_lingqu.node, 1)
    end

	if self.data.gold > 0 then
		self.node_tree.lbl_lingqu_tip.node:setString(self.data.gold)
	else
		self.node_tree.lbl_lingqu_tip.node:setString("(免费)")
	end
	self.node_tree.img_gold.node:setVisible(self.data.gold > 0)
end