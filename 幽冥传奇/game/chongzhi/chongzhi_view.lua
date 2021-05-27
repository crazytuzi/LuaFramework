
local ChongzhiView = ChongzhiView or BaseClass(SubView)
local ChongzhiItemRender = ChongzhiItemRender or BaseClass(BaseRender)

function ChongzhiView:__init()

	-- if	ChongzhiView.Instance then
	-- 	ErrorLog("[ChongzhiView]:Attempt to create singleton twice!")
	-- end

	--平台需求修改充值界面
	local texture_name = 'res/xui/vip.png'
	local ui_config_name = 'zs_vip_ui_cfg'
	local is_ios = PLATFORM == cc.PLATFORM_OS_IPHONE or PLATFORM == cc.PLATFORM_OS_IPAD
	
	--test
	-- local is_ios = true
	-- IS_AUDIT_VERSION = true

	-- if IS_AUDIT_VERSION and is_ios then
	-- 	texture_name = 'res/xui/recharge_ios_audit.png'
	-- 	ui_config_name = "chongzhi_ios_audit_ui_cfg"
	-- end

	-- self:SetIsAnyClickClose(true)
	-- self:SetModal(true)
	self.def_index = 1
	self.texture_path_list[1] = texture_name
	self.config_tab = {
		-- {ui_config_name, 1, {0}},
		{ui_config_name, 4, {0}},
		-- {"chongzhi_ui_cfg", 3, {0}},
	}
	self.def_index = 1

	self.grid_scroll_list = nil
end

function ChongzhiView:__delete()
end

function ChongzhiView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.rich_give_bind_gold_time = RichTextUtil.ParseRichText(nil, "", 20, COLOR3B.YELLOW,
			548, 524, 600, 30)
		self.node_t_list.layout_chongzhi.node:addChild(self.rich_give_bind_gold_time, 9)
		self:SetGiveBindGoldRich()

		
	end
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function ChongzhiView:ReleaseCallBack()
	if self.grid_scroll_list then
		self.grid_scroll_list:DeleteMe()
		self.grid_scroll_list = nil
	end
	self.rich_give_bind_gold_time = nil
end

function ChongzhiView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ChongzhiCtrl.Instance:ReqRechargeConfig()
	local is_open_double = ChongzhiData.Instance:GetIsOpenDouble()
	if is_open_double == 1 then
		ChongzhiCtrl.Instance:SendDoubleInfo()
	end
	self.current_index = 1
	self.give_bind_gold_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetGiveBindGoldRich, self), 1)
end

function ChongzhiView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
	if self.give_bind_gold_timer then
		GlobalTimerQuest:CancelQuest(self.give_bind_gold_timer)
		self.give_bind_gold_timer = nil
	end
end

function ChongzhiView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChongzhiView:OnFlush(param_list, index)
	for k, v in pairs(param_list) do
		if k == "all" then
			self:UpdateGridScroll()
			self:FlushMoney()
		elseif k == "money" then
			self:FlushMoney()
		end
	end
end

function ChongzhiView:SetGiveBindGoldRich()
	-- local left_day = OpenServiceAcitivityData.Instance:GetBindGoldLeftDay()
	-- if left_day >= 0 then
	-- 	local server_time = TimeCtrl.Instance:GetServerTime()
	-- 	local date_t = Split(os.date("%w-%H-%M-%S", server_time), "-")
	-- 	local left_date_t = TimeUtil.Format2TableDHMS(86400 - date_t[2] * 3600 - date_t[3] * 60 - date_t[4])
	-- 	local left_hour = left_date_t.hour
	-- 	local left_min = left_date_t.min
	-- 	local left_sec = left_date_t.s
	-- 	RichTextUtil.ParseRichText(self.rich_give_bind_gold_time, string.format(Language.Common.GiveBindGoldLeftTime, left_day, left_hour, left_min, left_sec))
	-- else
		RichTextUtil.ParseRichText(self.rich_give_bind_gold_time, "")
		GlobalTimerQuest:CancelQuest(self.give_bind_gold_timer)
	-- end
end

function ChongzhiView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_GOLD  then
		self:Flush(0, "money")
		if ChongzhiData.Instance:GetIsOpenDouble() == 1 then
			local recharge_cfg = ChongzhiData.Instance:GetRechargeCfg()
			local show_double = true
			for k,v in pairs(recharge_cfg) do
				if math.floor(v.gold) == tonumber(vo.value - vo.old_value) then
					local times = ChongzhiData.Instance:GetMaxTimes()
					if v.show_double >= times then
						show_double = false
					else
						show_double = true
					end
				end
			end
			if show_double == true then
				ChongzhiCtrl.Instance:SendDoubleInfo()
			end
		end
	end
end

function ChongzhiView:UpdateGridScroll()
	if nil == self.node_t_list.layout_chongzhi then
		return
	end

	if nil == self.grid_scroll_list then
		local ph = self.ph_list.ph_items_list
		local ph_item = self.ph_list.ph_item_info_panel
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, ph_item.h, ChongzhiItemRender, ScrollDir.Vertical, false, ph_item)
		self.grid_scroll_list = grid_scroll
		self.node_t_list.layout_chongzhi.node:addChild(grid_scroll:GetView(), 100)
	end
	self.grid_scroll_list:SetDataList(ChongzhiData.Instance:GetRechargeCfg())
	self.grid_scroll_list:JumpToTop()
end

function ChongzhiView:FlushMoney()
	-- local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
end

------------------------------------------------------
-- ChongzhiItemRender
------------------------------------------------------
function ChongzhiItemRender:__init()
end

function ChongzhiItemRender:__delete()
	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end
	self.effect = nil
end

function ChongzhiItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end

	-- OpenServiceAcitivityData.Instance:GetTabIndexTimeVisible()

	-- self.img_first_charge = XUI.CreateImageView(142, 107, ResPath.GetRechargePath("give_img"), true)
	-- self.view:addChild(self.img_first_charge, 10)
	-- self.img_first_charge:setVisible(false)

	-- self.stamp_first_charge = XUI.CreateImageView(33, 208, ResPath.GetCommon("stamp_first_charge"), true)
	-- self.view:addChild(self.stamp_first_charge, 10)
	-- self.stamp_first_charge:setVisible(false)

	self.rich_give_bind_gold = RichTextUtil.ParseRichText(nil, "", 19, COLOR3B.YELLOW,
		142, 107 - 27, 200, 30)
	XUI.RichTextSetCenter(self.rich_give_bind_gold)
	self.view:addChild(self.rich_give_bind_gold, 11)

	self.effect=AnimateSprite:create()
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(404)
	self.effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	if nil~=self.effect then
		self.effect:setPosition(200,110)
		self.view:addChild(self.effect, 101,101)
	end

	local ph = self.ph_list["ph_money"]
	local number = NumberBar.New()
	number:Create(ph.x, ph.y, ph.w, ph.h, ResPath.GetCommon("num_1_"))
	number:SetGravity(NumberBarGravity.Center)
	number:SetHasPlus(true)
	number:SetSpace(-5)
	self.view:addChild(number:GetView(), 20)
	self.money = number
end

function ChongzhiItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
	ChongzhiCtrl.Recharge(self.data.money)
end

function ChongzhiItemRender:OnFlush()
	if nil == self.data then
		return
	end

	-- local left_day = OpenServiceAcitivityData.Instance:GetBindGoldLeftDay()
	-- local can_get_bind_gold = (left_day >= 0) and not OpenServiceAcitivityData.Instance:IsHaveChargeNum(self.data.gold)
	-- self.img_first_charge:setVisible(can_get_bind_gold)
	-- self.stamp_first_charge:setVisible(can_get_bind_gold)
	-- self.rich_give_bind_gold:setVisible(can_get_bind_gold)
	-- if can_get_bind_gold then
	-- 	RichTextUtil.ParseRichText(self.rich_give_bind_gold, self.data.gold, 19, COLOR3B.YELLOW)
	-- end

	self.node_tree.lbl_gold_num.node:setString(self.data.gold .. Language.Common.Diamond)
	XUI.EnableOutline(self.node_tree["lbl_gold_num"].node)
	local money_str = self.data.money_type or Language.Common.MoneyTypeStr[0]
	self.money:SetNumber(self.data.money)
	
	if ChongzhiData.Instance:GetIsOpenDouble() == 1 then
		local times = ChongzhiData.Instance:GetMaxTimes()
		self.effect:setVisible(self.data.show_double < times)
		if self.data.show_double < times then
			self.node_tree.lbl_double_times.node:setString(string.format(Language.ChongZhi.RebateTimes,times - self.data.show_double))
			XUI.EnableOutline(self.node_tree["lbl_double_times"].node)
		else
			self.node_tree.lbl_double_times.node:setString(" ")
		end
	else
		self.effect:setVisible(false)
		self.node_tree.lbl_double_times.node:setString(" ")
	end

	local index = self.index > 8 and 8 or self.index
	self.node_tree["img_bg"].node:loadTexture(ResPath.GetVipResPath("img_recharge_" .. index))
end

function ChongzhiItemRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end

return ChongzhiView