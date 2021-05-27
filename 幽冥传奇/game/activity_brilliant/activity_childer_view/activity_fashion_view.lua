ShiZhuangView = ShiZhuangView or BaseClass(ActBaseView)

function ShiZhuangView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ShiZhuangView:__delete()
	for k,v in pairs(self.fashion_reward_t) do
		v:DeleteMe()
	end
	self.fashion_reward_t = {}

	if nil ~= self.xunbao_cap then
		self.xunbao_cap:DeleteMe()
		self.xunbao_cap = nil
	end
	self.eff = nil
end

function ShiZhuangView:InitView()
	self:CreateEff()
	self.node_t_list.btn_xb_toxunbao.node:addClickEventListener(BindTool.Bind(self.OnClickFashionXunbaoHandler, self))
	self.node_t_list.btn_xb_reward.node:addClickEventListener(BindTool.Bind(self.OnClickFashionRewardHandler, self))

	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.SetSelectCallBack, self, 1))
	XUI.AddClickEventListener(self.node_t_list["btn_2"].node, BindTool.Bind(self.SetSelectCallBack, self, 2))
	XUI.AddClickEventListener(self.node_t_list["btn_3"].node, BindTool.Bind(self.SetSelectCallBack, self, 3))

	XUI.AddRemingTip(self.node_t_list["btn_xb_reward"].node)
	self:CreateXunbaoNum()
	self:SetSelectCallBack(1)
end

function ShiZhuangView:RefreshView(param_list)
	self:FlushFashionShowView(self.select_index)
end

function ShiZhuangView:CreateEff()
	if nil == self.role_display then
		local ph = self.ph_list["ph_eff"]
		local role_display = RoleDisplay.New(self.node_t_list["layout_fashion"].node, 100, false, false, true, true)
		role_display:SetPosition(ph.x, ph.y)
		role_display:SetScale(0.8)
		self.role_display = role_display
		self:AddObj("role_display")
	end

	if nil == self.effect_show1 then
		local ph = self.ph_list["ph_eff"]
	 	local effect_show1 = AnimateSprite:create()
	 	effect_show1:setPosition(ph.x, ph.y)
	 	self.node_t_list["layout_fashion"].node:addChild(effect_show1, 999)
	 	self.effect_show1 = effect_show1
	end
end

function ShiZhuangView:FlushFashionShowView(index)
	index = index or 1
	local act_cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.SHIZ) or {}
	local cfg = act_cfg.config or {}
	local award = cfg.award or {}
	local cur_award = cfg.award[index] or {}
	self.cur_show = cfg.show and cfg.show[index] or {}

	local lq_limit = cfg.params and cfg.params[index] or 0 -- 每次领取礼包消耗的寻宝次数
	local num  = ActivityBrilliantData.Instance.spare_szxb_num or 0 -- 总寻宝次数
	local color = num >= lq_limit and COLORSTR.GREEN or COLORSTR.RED
	local text = string.format(Language.ActivityBrilliant.Text34, color, num, lq_limit)
	RichTextUtil.ParseRichText(self.node_t_list["rich_xunbao_times"].node, text, 20, COLOR3B.GREEN);
	self.node_t_list["rich_xunbao_times"].node:refreshView()
	XUI.RichTextSetCenter(self.node_t_list["rich_xunbao_times"].node)

	self.xunbao_cap:SetNumber(lq_limit)
	self.node_t_list.btn_xb_reward.node:setEnabled(num >= lq_limit)
	self.node_t_list["btn_xb_reward"].node:UpdateReimd(num >= lq_limit)

	self:FlusEff()
	self:FlushFashionRewards()

	for award_index = 1, 3 do
		-- 奖励配置不为空才显示按钮
		local vis = award[award_index] ~= nil
		self.node_t_list["btn_" .. award_index].node:setVisible(vis)
	end
end

function ShiZhuangView:FlushFashionRewards()
	if nil == self.fashion_reward_t then
		self.fashion_reward_t = {}

		for i = 1, 3 do
			local cell = ActBaseCell.New()
			cell:SetIndex(i)
			self.node_t_list.layout_fashion.node:addChild(cell:GetView(), 300)
			table.insert(self.fashion_reward_t, cell)
		end
	end

	local ph = self.ph_list["ph_award_list"]
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SHIZ)
	local awards = act_cfg and act_cfg.config and act_cfg.config.award[self.select_index]
	local interval = 15
	if awards and type(awards) == "table" then
		local cell_count = #awards
		local start_x = ph.x + (ph.w - (BaseCell.SIZE + interval) * cell_count - interval) / 2
		local y = ph.y + (ph.h - BaseCell.SIZE) / 2
		for i,v in ipairs(self.fashion_reward_t) do
			if awards[i] then
				local data = awards[i]
				v:SetData(ItemData.InitItemDataByCfg(data))
				local x = start_x + (BaseCell.SIZE + interval) * (i - 1)
				v:GetView():setPosition(x, y)
			end
			v:SetVisible(awards[i] ~= nil)
		end
	end
end

function ShiZhuangView:CreateXunbaoNum()
	local ph = self.ph_list["ph_xunbao_times"]
	self.xunbao_cap = NumberBar.New()
	self.xunbao_cap:SetRootPath(ResPath.GetActivityBrilliant("act_11_num_"))
	self.xunbao_cap:SetPosition(ph.x, ph.y)
	self.xunbao_cap:SetGravity(NumberBarGravity.Center)
	self.xunbao_cap:SetSpace(-8)
	self.node_t_list.layout_fashion.node:addChild(self.xunbao_cap:GetView(), 300, 300)
end

function ShiZhuangView:CreateNumberBar()
	local ph = self.ph_list.ph_num_day_active
	self.draw_num_bar = NumberBar.New()
	self.draw_num_bar:SetRootPath(ResPath.GetCombind("num_"))
	self.draw_num_bar:SetPosition(415, 353)
	self.draw_num_bar:SetGravity(NumberBarGravity.Left)
	self.node_t_list.layout_fashion.node:addChild(self.draw_num_bar:GetView(), 300, 300)
end

function ShiZhuangView:FlusEff()
	local effect_id = self.cur_show.effect_id or 7
	local effect_type = self.cur_show.effect_type  or 1

	self.role_display:SetVisible(false)
	self.effect_show1:setVisible(false)
	if effect_type == 1 then
		self.effect_show1:setVisible(true)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	else
		self.role_display:SetVisible(true)
		local role_data = self.cur_show.role_model_effect  or {}

		local info = {[OBJ_ATTR.ENTITY_MODEL_ID] = 0, [OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = 0,
	 		[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 0, 	[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = 0,
	 		[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 0}
	 	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	 	local role_model_id = role_data.yifu_model[sex + 1]  or 0
	 	local weaponpos_id = role_data.wuqi_model  or 0 
	 	local wing_model = role_data.wing_model 
	 	info[OBJ_ATTR.ENTITY_MODEL_ID] = role_model_id
	 	info[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]= weaponpos_id
	 	info[OBJ_ATTR.ACTOR_WING_APPEARANCE] = wing_model

	 	self.role_display:SetRoleVo(info)
	end
end

function ShiZhuangView:SetSelectCallBack(index)
	self.select_index = index
	local x, y = self.node_t_list["btn_" .. index].node:getPosition()
	self.node_t_list["img_select"].node:setPosition(x, y)

	self:FlushFashionShowView(index)
	CombinedServerActCtrl.SendSendCombinedInfo(7, index) --请求时装信息
end

function ShiZhuangView:OnClickFashionXunbaoHandler()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
	ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function ShiZhuangView:OnClickFashionRewardHandler()
	local act_id = ACT_ID.SHIZ
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.select_index)
end

