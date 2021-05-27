require("scripts/game/operate_activity/operate_daily_charge")
require("scripts/game/operate_activity/operate_limit_goods")
require("scripts/game/operate_activity/operate_accumulate_charge")
require("scripts/game/operate_activity/operate_accumulate_spend")
require("scripts/game/operate_activity/operate_sports_act")
require("scripts/game/operate_activity/operate_repeat_charge")
require("scripts/game/operate_activity/operate_spend_score")
require("scripts/game/operate_activity/day_num_charge")
require("scripts/game/operate_activity/group_purchase")
require("scripts/game/operate_activity/operate_sports_rank_view")
require("scripts/game/operate_activity/operate_wish_well_page")
require("scripts/game/operate_activity/operate_addup_login_page")
require("scripts/game/operate_activity/operate_yb_wheel_page")
require("scripts/game/operate_activity/operate_pray_tree_page")
require("scripts/game/operate_activity/operate_luck_turn_page")
require("scripts/game/operate_activity/operate_limit_goods_two")
require("scripts/game/operate_activity/operate_jvbao_pen")
require("scripts/game/operate_activity/operate_pray_tree_page_two")
require("scripts/game/operate_activity/treasure_drop_page")
require("scripts/game/operate_activity/secret_key_treasure")
require("scripts/game/operate_activity/lucky_buy")
require("scripts/game/operate_activity/operate_daily_consume")
require("scripts/game/operate_activity/operate_daily_accu_charge")
require("scripts/game/operate_activity/day_num_spend")
require("scripts/game/operate_activity/super_group_purchase")
require("scripts/game/operate_activity/discount_limit_buy")
require("scripts/game/operate_activity/discount_treasure")
require("scripts/game/operate_activity/pindan_qianggou")
require("scripts/game/operate_activity/charge_give_gift")
require("scripts/game/operate_activity/consume_give_gift")
require("scripts/game/operate_activity/time_limit_once_charge")
require("scripts/game/operate_activity/new_charge_rank")
require("scripts/game/operate_activity/new_spend_rank")
require("scripts/game/operate_activity/boss_atk_income")
require("scripts/game/operate_activity/convert_award_page")
require("scripts/game/operate_activity/continuous_login_page")
require("scripts/game/operate_activity/operate_ten_time_explore_give")
require("scripts/game/operate_activity/operate_addup_spend_payback")
require("scripts/game/operate_activity/operate_secret_shop")
require("scripts/game/operate_activity/operate_world_cup_boss")
require("scripts/game/operate_activity/operate_conti_addup_charge")
require("scripts/game/operate_activity/new_repeat_charge")
require("scripts/game/operate_activity/spendscore_exch_payback")
require("scripts/game/operate_activity/operate_conti_addup_charge_new")
require("scripts/game/operate_activity/operate_happy_shopping_shop")

require("scripts/game/operate_activity/spring_festival/spring_addup_login")
require("scripts/game/operate_activity/spring_festival/yb_send_gift")
require("scripts/game/operate_activity/spring_festival/prospery_red_enev")
require("scripts/game/operate_activity/spring_festival/addup_recharge_payback")


------------------------------------------------------------
-- 运营活动View
------------------------------------------------------------
OperateActivityView = OperateActivityView or BaseClass(XuiBaseView)

function OperateActivityView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/limit_activity.png'
	self.texture_path_list[2] = 'res/xui/boss.png'
	self.texture_path_list[3] = 'res/xui/charge.png'
	self.texture_path_list[4] = 'res/xui/combineserveractivity.png'
	self.texture_path_list[5] = 'res/xui/operate_activity.png'
	self.texture_path_list[6] = 'res/xui/vip.png'
	self.texture_path_list[7] = "res/xui/shangcheng.png"
	self.texture_path_list[8] = "res/xui/skill.png"
	self.texture_path_list[9] = "res/xui/welfare.png"
	self.texture_path_list[10] = "res/xui/openserviceacitivity.png"
	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"operate_activity_ui_cfg", 1, {0}},
		{"operate_activity_ui_cfg", 2, {TabIndex.operact_daily_recharge}},
		{"operate_activity_ui_cfg", 3, {TabIndex.operact_limit_time_goods}},
		{"operate_activity_ui_cfg", 4, {TabIndex.operact_accumulate_recharge}},	
		{"operate_activity_ui_cfg", 5, {TabIndex.operact_accumulate_spend}},
		{"operate_activity_ui_cfg", 6, {TabIndex.operact_exp_sports,
										TabIndex.operact_boss_sports,
										TabIndex.operact_blood_sports,
										TabIndex.operact_shield_sports,
										TabIndex.operact_diamond_sports,
										TabIndex.operact_sealbead_sports,
										TabIndex.operact_inject_sports,
										TabIndex.operact_swing_sports,

										TabIndex.operact_daily_exp_sports,
										TabIndex.operact_daily_boss_sports,
										TabIndex.operact_daily_blood_sports,
										TabIndex.operact_daily_shield_sports,
										TabIndex.operact_daily_diamond_sports,
										TabIndex.operact_daily_sealbead_sports,
										TabIndex.operact_daily_inject_sports,
										TabIndex.operact_daily_swing_sports,
										TabIndex.operact_soul_stone_sports,
										TabIndex.operact_daily_soul_stone_sports,
										}},
		{"operate_activity_ui_cfg", 7, {
										TabIndex.operact_exp_sports_rank,
										TabIndex.operact_boss_sports_rank,
										TabIndex.operact_blood_sports_rank,
										TabIndex.operact_shield_sports_rank,
										TabIndex.operact_diamond_sports_rank,
										TabIndex.operact_sealbead_sports_rank,
										TabIndex.operact_inject_sports_rank,
										TabIndex.operact_swing_sports_rank,
										TabIndex.operact_daily_exp_sports_rank,
										TabIndex.operact_daily_boss_sports_rank,
										TabIndex.operact_daily_blood_sports_rank,
										TabIndex.operact_daily_shield_sports_rank,
										TabIndex.operact_daily_diamond_sports_rank,
										TabIndex.operact_daily_sealbead_sports_rank,
										TabIndex.operact_daily_inject_sports_rank,
										TabIndex.operact_daily_swing_sports_rank,
										TabIndex.operact_recharge_rank,
										TabIndex.operact_spend_rank,
										TabIndex.operact_soul_stone_sports_rank,
										TabIndex.operact_daily_soul_stone_sports_rank,
										TabIndex.operact_greate_recharge_rank,					
										TabIndex.operact_greate_spend_rank, 
										TabIndex.operact_blood_sports_rank_2,
										TabIndex.operact_shield_sports_rank_2,
										TabIndex.operact_diamond_sports_rank_2,
										TabIndex.operact_sealbead_sports_rank_2,
										TabIndex.operact_inject_sports_rank_2,
										TabIndex.operact_soul_stone_sports_rank_2,
										}},

		{"operate_activity_ui_cfg", 8, {
										TabIndex.operact_exp_sports,
										TabIndex.operact_boss_sports,
										TabIndex.operact_blood_sports,
										TabIndex.operact_shield_sports,
										TabIndex.operact_diamond_sports,
										TabIndex.operact_sealbead_sports,
										TabIndex.operact_inject_sports,
										TabIndex.operact_swing_sports,
										TabIndex.operact_daily_exp_sports,
										TabIndex.operact_daily_boss_sports,
										TabIndex.operact_daily_blood_sports,
										TabIndex.operact_daily_shield_sports,
										TabIndex.operact_daily_diamond_sports,
										TabIndex.operact_daily_sealbead_sports,
										TabIndex.operact_daily_inject_sports,
										TabIndex.operact_daily_swing_sports,
										TabIndex.operact_soul_stone_sports,
										TabIndex.operact_daily_soul_stone_sports,
										}},
		{"operate_activity_ui_cfg", 9, {TabIndex.operact_repeat_charge}},
		{"operate_activity_ui_cfg", 10, {TabIndex.operact_spend_score}},
		{"operate_activity_ui_cfg", 11, {TabIndex.operact_day_num_charge}},
		{"operate_activity_ui_cfg", 12, {TabIndex.operact_group_purchase}},
		{"operate_activity_ui_cfg", 13, {TabIndex.operact_wish_well}},
		{"operate_activity_ui_cfg", 14, {TabIndex.operact_addup_login}},
		{"operate_activity_ui_cfg", 15, {TabIndex.operact_yb_wheel}},
		{"operate_activity_ui_cfg", 16, {TabIndex.operact_pray_money_tree}},
		{"operate_activity_ui_cfg", 17, {TabIndex.operact_luck_turn}},
		{"operate_activity_ui_cfg", 18, {TabIndex.operact_limit_time_goods_2}},
		{"operate_activity_ui_cfg", 19, {TabIndex.operact_jvbao_pen}},
		{"operate_activity_ui_cfg", 20, {TabIndex.operact_pray_money_tree_2}},
		{"operate_activity_ui_cfg", 21, {TabIndex.operact_treasure_drop}},
		{"operate_activity_ui_cfg", 22, {TabIndex.operact_secret_key_treasure}},
		{"operate_activity_ui_cfg", 23, {TabIndex.operact_lucky_buy}},
		{"operate_activity_ui_cfg", 24, {TabIndex.operact_daily_consume}},
		{"operate_activity_ui_cfg", 25, {TabIndex.operact_daily_charge}},
		{"operate_activity_ui_cfg", 26, {TabIndex.operact_day_num_spend}},
		{"operate_activity_ui_cfg", 27, {TabIndex.operact_super_group_purchase}},
		{"operate_activity_ui_cfg", 28, {TabIndex.operact_discount_limit_buy}},
		{"operate_activity_ui_cfg", 29, {TabIndex.operact_discount_treasure}},
		{"operate_activity_ui_cfg", 30, {TabIndex.operact_pindan_qianggou}},
		{"operate_activity_ui_cfg", 32, {TabIndex.operact_charge_give}},
		{"operate_activity_ui_cfg", 33, {TabIndex.operact_consume_give}},
		{"operate_activity_ui_cfg", 34, {TabIndex.operact_time_limit_once_charge}},
		{"operate_activity_ui_cfg", 35, {TabIndex.operact_new_spend_rank}},
		{"operate_activity_ui_cfg", 36, {TabIndex.operact_new_charge_rank}},
		{"operate_activity_ui_cfg", 37, {TabIndex.operact_boss_atk_income}},
		{"operate_activity_ui_cfg", 38, {TabIndex.operact_convert_award}},
		{"operate_activity_ui_cfg", 39, {TabIndex.operact_continuous_login}},
		{"operate_activity_ui_cfg", 40, {TabIndex.operact_ten_time_expl_give}},
		{"operate_activity_ui_cfg", 41, {TabIndex.operact_addup_spend_payback}},
		{"operate_activity_ui_cfg", 42, {TabIndex.operact_secret_shop}},
		{"operate_activity_ui_cfg", 43, {TabIndex.operact_world_cup_boss}},
		{"operate_activity_ui_cfg", 44, {TabIndex.operact_conti_addup_charge}},
		{"operate_activity_ui_cfg", 45, {TabIndex.operact_new_repeat_charge}},
		{"operate_activity_ui_cfg", 46, {TabIndex.operact_spendscore_exch_payback}},
		{"operate_activity_ui_cfg", 48, {TabIndex.operact_conti_addup_charge_new}},
		{"operate_activity_ui_cfg", 49, {TabIndex.operact_happy_shopping_cart}},

		{"spring_festival_act_ui_cfg", 2, {TabIndex.operact_spring_addup_login}},
		{"spring_festival_act_ui_cfg", 5, {TabIndex.operact_yb_send_gift}},
		{"spring_festival_act_ui_cfg", 6, {TabIndex.operact_prospery_red_enev}},
		{"spring_festival_act_ui_cfg", 7, {TabIndex.operact_addup_recharge_payback}},
	}
	
	-- 页面表
	self.page_list = {}
	self.page_list[TabIndex.operact_daily_recharge] = DailyChargePage.New()								--每日充值
	self.page_list[TabIndex.operact_limit_time_goods] = OperateActLimitGoodsPage.New()					--限时商品
	self.page_list[TabIndex.operact_accumulate_recharge] = OperateActAccumuChargePage.New()				--累计充值
	self.page_list[TabIndex.operact_accumulate_spend] = OperateActAccumuSpendPage.New()					--累计消费

	self.page_list[TabIndex.operact_repeat_charge] = OperateRepeatChargePage.New()						--重复充值
	self.page_list[TabIndex.operact_spend_score] = OperateSpendScorePage.New()							--消费积分
	self.page_list[TabIndex.operact_day_num_charge] = DayNumChargePage.New()							--天数(天)充值
	self.page_list[TabIndex.operact_group_purchase] = GroupPurchasePage.New()							--团购活动

	self.page_list[TabIndex.operact_wish_well] = OperateWishWellPage.New()								--许愿井
	self.page_list[TabIndex.operact_addup_login] = OperateActAddupLoginPage.New()						--累计登陆
	self.page_list[TabIndex.operact_yb_wheel] = OperateActYBWheelPage.New()								--元宝转盘
	self.page_list[TabIndex.operact_pray_money_tree] = OperateActPrayTreePage.New()						--摇钱树
	self.page_list[TabIndex.operact_luck_turn] = OperateActLuckTurnPage.New()							--幸运转盘
	self.page_list[TabIndex.operact_limit_time_goods_2] = OperateActLimitGoodsTwo.New()					--限时商品2
	self.page_list[TabIndex.operact_jvbao_pen] = OperateJvBaoPenPage.New()								--聚宝盆
	self.page_list[TabIndex.operact_pray_money_tree_2] = OperateActPrayTreePageTwo.New()				--摇钱树2
	self.page_list[TabIndex.operact_treasure_drop] = OperateActTreasureDropPage.New()					--天降奇宝
	self.page_list[TabIndex.operact_secret_key_treasure] = OperateActSecretKeyTreasure.New()			--秘钥宝藏
	self.page_list[TabIndex.operact_lucky_buy] = LuckyBuyPage.New()										--幸运购
	self.page_list[TabIndex.operact_daily_consume] = OperateActDailyConsumePage.New()					--每日累计消费
	self.page_list[TabIndex.operact_daily_charge] = OperateActDailyChargePage.New()						--每日累计消费
	self.page_list[TabIndex.operact_day_num_spend] = DayNumSpendPage.New()								--天天消费
	self.page_list[TabIndex.operact_super_group_purchase] = SuperGroupPurchasePage.New()				--超级团购活动
	self.page_list[TabIndex.operact_discount_limit_buy] = DiscountLimitBuyPage.New()					--超值限购
	self.page_list[TabIndex.operact_discount_treasure] = DiscountTreasurePage.New()						--宝物折扣
	self.page_list[TabIndex.operact_pindan_qianggou] = PinDanQiangGouPage.New()							--拼单抢购
	self.page_list[TabIndex.operact_time_limit_once_charge] = OperateActTimeLimitOnceCharge.New()		--限时单笔
	self.page_list[TabIndex.operact_new_charge_rank] = OperateActNewChargeRankPage.New()				--新充值排行
	self.page_list[TabIndex.operact_new_spend_rank] = OperateActNewSpendRankPage.New()					--新消费排行
	self.page_list[TabIndex.operact_boss_atk_income] = OperateActBossAtkIncomePage.New()				--怪物来袭
	self.page_list[TabIndex.operact_convert_award] = ConvertAwardPage.New()								--奖励兑换
	self.page_list[TabIndex.operact_continuous_login] = ContinuousLoginPage.New()						--连续登录

	self.page_list[TabIndex.operact_charge_give] = ChargeGiveGiftPage.New()								--充值送礼
	self.page_list[TabIndex.operact_consume_give] = ConsumeGiveGiftPage.New()							--消费送礼
	self.page_list[TabIndex.operact_ten_time_expl_give] = TenTimeExplGivePage.New()						--寻宝10连抽送奖

	self.page_list[TabIndex.operact_spring_addup_login] = SpringAddupLoginPage.New()					--新春大礼
	self.page_list[TabIndex.operact_yb_send_gift] = SpringYBSendGiftPage.New()							--元宝献礼
	self.page_list[TabIndex.operact_prospery_red_enev] = SpringProsperyRedEnvePage.New()				--旺旺红包
	self.page_list[TabIndex.operact_addup_recharge_payback] = SpringAddupChargePayPage.New()			--累充返利
	self.page_list[TabIndex.operact_addup_spend_payback] = OperAddupSpendPaybackPage.New()				--累消返利
	self.page_list[TabIndex.operact_secret_shop] = OperSecretShopPage.New()								--神秘商店
	self.page_list[TabIndex.operact_world_cup_boss] = OperActWorldCupBossPage.New()						--世界杯BOSS
	self.page_list[TabIndex.operact_conti_addup_charge] = OperActContiAddupChargePage.New()				--连续累充
	self.page_list[TabIndex.operact_new_repeat_charge] = OperateActNewRepeatChargePage.New()			--新重复充值
	self.page_list[TabIndex.operact_spendscore_exch_payback] = OpActSpendscoreExchPaybackPage.New()		--消费积分兑换返利券
	self.page_list[TabIndex.operact_conti_addup_charge_new] = OperActNewContiAddupChargePage.New()		--新连续累充
	self.page_list[TabIndex.operact_happy_shopping_cart] = OperActHappyShoppingPage.New()				--嗨购一车
	
	--------------------------------------竞技类活动----------------------------------------
	self.sports_type_act_page = OperateSportsActPage.New()

	self.selec_index = 1
	self.selec_act_id = 1
	self.remind_temp = {}
end

function OperateActivityView:__delete()

end

function OperateActivityView:ReleaseCallBack()
	-- 清理页面生成信息
	for k, v in pairs(self.page_list) do
		v:DeleteMe()
	end

	if self.sports_type_act_page then
		self.sports_type_act_page:DeleteMe()
	end

	if self.btns_list then
		self.btns_list:DeleteMe()
		self.btns_list = nil
	end

	self:DeleteOperSportsRank()

	if self.del_act_evt then
		GlobalEventSystem:UnBind(self.del_act_evt)
		self.del_act_evt = nil
	end

	if self.add_act_evt then
		GlobalEventSystem:UnBind(self.add_act_evt)
		self.add_act_evt = nil
	end

	self.selec_index = 1
end

function OperateActivityView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateBtnsList()
		self.del_act_evt = GlobalEventSystem:Bind(OperateActivityEventType.DELETE_CLOSE_ACT, BindTool.Bind(self.SetBtnsListData, self))
		self.add_act_evt = GlobalEventSystem:Bind(OperateActivityEventType.ADD_OPEN_ACT, BindTool.Bind(self.SetBtnsListData, self))
	end
	if OperateActivityData.GetOperateActBigType(index) == OperateActivityData.OperateActBigType.SPORTS_TYPE then
		self.sports_type_act_page:InitPage(self)
	end

	if OperateActivityData.GetOperateActBigType(index) == OperateActivityData.OperateActBigType.SPORTS_RANK then
		self:InitOperSportsRank()
	end

	if self.page_list[index] then
		-- 初始化页面接口
		self.page_list[index]:InitPage(self)
	end
	
end

function OperateActivityView:OpenCallBack()
	if self.btns_list then
		self.btns_list:SelectIndex(1)
		self.btns_list:AutoJump()
		-- self:ChangeToIndex(self.selec_index)
	end
end

function OperateActivityView:CloseCallBack()
	
end

function OperateActivityView:ShowIndexCallBack(index)
	self:Flush(index)
end

function OperateActivityView:OnFlush(param_t, index)
	if nil ~= self.page_list[index] then
		-- 更新页面接口
		self.page_list[index]:UpdateData(param_t)
	end
	
	if OperateActivityData.GetOperateActBigType(index) == OperateActivityData.OperateActBigType.SPORTS_TYPE then
		self.sports_type_act_page:UpdateData()
	end

	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushRemind()
		elseif k == "flush_sports_rank" then
			self:FlushRankView(v.act_id)
		elseif k == "flush_remind" then
			self:FlushRemind()
		end
	end

end

function OperateActivityView:CreateBtnsList()
	if nil == self.btns_list then
		local ph = self.ph_list.ph_btns_list
		self.btns_list = ListView.New()
		self.btns_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActBtnRender, nil, nil, self.ph_list.ph_btn_item)
		self.btns_list:SetItemsInterval(5)
		self.btns_list:SetJumpDirection(ListView.Top)
		self.btns_list:SetIsUseStepCalc(false)
		self.btns_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
		self.node_t_list.layout_scroll.node:addChild(self.btns_list:GetView(), 20)
		self:SetBtnsListData()
	end
end

function OperateActivityView:SelectItemCallback(item, index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	self.selec_index = index
	self.selec_act_id = data.act_id
	self:ChangeToIndex(data.act_id)
	self:ReqSportsRankData(data.act_id)
	self:Flush(data.act_id)
end

function OperateActivityView:ReqSportsRankData(act_id)
	if OperateActivityData.GetOperateActBigType(act_id) == OperateActivityData.OperateActBigType.SPORTS_RANK then
		local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(act_id)
		if cmd_id then
			OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, act_id)
		end
	end
end

function OperateActivityView:SetBtnsListData()
	if not self.btns_list then return end
	local btn_data_list = OperateActivityData.Instance:GetCommonShowActList()
	self.btns_list:SetData(btn_data_list)
	if btn_data_list and next(btn_data_list) then
		self.btns_list:SelectIndex(math.min(self.selec_index, #btn_data_list))
	else
		self:Close()
	end
end

function OperateActivityView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name)
	end
end

function OperateActivityView:FlushRemind()
	if not self.btns_list then return end
	local remind_list = OperateActivityData.Instance:GetRemindList()
	for k, v in pairs(self.btns_list:GetAllItems()) do
		if v and v:GetData() then
			local data = v:GetData()
			v:SetRemindVis(remind_list[data.act_id])
		end
	end
end

----------------------------------------------------
-- OperateActBtnRender
----------------------------------------------------
OperateActBtnRender = OperateActBtnRender or BaseClass(BaseRender)
function OperateActBtnRender:__init()
end

function OperateActBtnRender:__delete()	
	self.rect_eff = nil
end

function OperateActBtnRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_remind.node:setVisible(false)
	self.node_tree.lbl_act_name.node:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	-- self.node_tree.img_fight.node:setVisible(false)
end

function OperateActBtnRender:OnFlush()
	if not self.data then return end
	-- PrintTable(self.data)
	if self.data.act_id == 53 and self.rect_eff == nil then
		self.rect_eff = RenderUnit.CreateEffect(10, self.view, 99, frame_interval, loops, x, y)
		-- self.rect_eff:setScaleX(1.5)
	end
	self.node_tree.lbl_act_name.node:setString(self.data.act_name)
	-- self.node_tree.img_remind.node:setVisible(self.data.is_need_remind)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
end

function OperateActBtnRender:SetRemindVis(vis)
	if self.node_tree.img_remind then
		self.node_tree.img_remind.node:setVisible(vis)
	end
end

-- 选择状态改变
function OperateActBtnRender:OnSelectChange(is_select)
	if not self.data then return end
	if is_select and OPERATE_CLICKED_NO_REMIND[self.data.act_id] then
		self:SetRemindVis(false)
		OPERATE_CLICKED_NO_REMIND[self.data.act_id] = math.max(OPERATE_CLICKED_NO_REMIND[self.data.act_id] - 1, 0)
		OperateActivityCtrl.Instance:DoRemindByActID(self.data.act_id)
	end
end

function OperateActBtnRender:CreateSelectEffect()
	if nil == self.node_tree.btn_img then
		self.cache_select = true
		return
	end
	local size =self.node_tree.btn_img.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("btn_106_select"), true, cc.rect(69,24,86,16))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.btn_img.node:addChild(self.select_effect, 99)
end