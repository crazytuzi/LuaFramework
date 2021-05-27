-- 特权卡

local ZsPrivilegeView = ZsPrivilegeView or BaseClass(SubView)
function ZsPrivilegeView:__init()
	self.texture_path_list[1] = "res/xui/privilege.png"
	self.config_tab = {
		{"zs_vip_ui_cfg", 5, {0}},
	}
end

function ZsPrivilegeView:__delete()
end


function ZsPrivilegeView:ReleaseCallBack()
	if self.button_list then
		self.button_list:DeleteMe()
		self.button_list = nil
	end

	if self.tuangou_alert then
		self.tuangou_alert:DeleteMe()
		self.tuangou_alert = nil
	end

	self.key_pk_text = nil
end

function ZsPrivilegeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateEffectTitle()
		self:CreateButtonList()
		-- self:InitViewNum()
		-- self:CreateScrollViews()
		XUI.AddClickEventListener(self.node_t_list.layout_btn_tuangou.node, BindTool.Bind(self.OnAllBuyClicked, self), true)
		local cfg = PrivilegeData.GetPrivilegeCfg()
		local price = cfg.group or {0, 0}
		self.node_t_list.lbl_old_gold.node:setString(price[1] .. "元")
		self.node_t_list.lbl_gold.node:setString(price[2] .. "元")

		local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
		local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
		local vis = ios_charge[agent_id] == nil
		self.node_t_list["layout_group_purchase"].node:setVisible(vis)
		self.node_t_list["img_bg"].node:setVisible(not vis) -- 遮挡

		EventProxy.New(PrivilegeData.Instance, self):AddEventListener(PrivilegeData.TEQUAN_CHANGE, BindTool.Bind(self.Flush, self))
	end
end

local title_id = {47, 48, 49}
function ZsPrivilegeView:InitViewNum()
	local pro = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for i=1, 3 do
		--属性
		local cfg = TitleData.GetHeadTitleConfig(title_id[i])
		if nil == cfg then return end
		local text = RoleData.FormatAttrContent(cfg.staitcAttrs, nil, ";", pro)
		local texts = Split(text, ";")
		self.node_t_list['lbl_'.. i .. '_attr'].node:setString(texts[1] .. "  " .. texts[2])
	end
end

function ZsPrivilegeView:CreateButtonList()
	self.button_list = BaseGrid.New()
	local ph = self.ph_list.ph_button_list
	local grid_node = self.button_list:CreateCells({w = ph.w, h = ph.h, itemRender = ButtonItem, direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_item, cell_count = 3, col = 3, row = 1})
	self.node_t_list.layout_privilege.node:addChild(grid_node, 100)
	grid_node:setPosition(ph.x, ph.y)
	grid_node:setAnchorPoint(0.5, 0.5)

	local list = PrivilegeData.Instance:GetPrivilegeInfo()
	self.button_list:SetDataList(list or {})
end

function ZsPrivilegeView:CreateEffectTitle()
	--创建特权特效 401 402 403
	local effect_1 = RenderUnit.CreateEffect(401, self.node_t_list.layout_privilege.node)
	local effect_2 = RenderUnit.CreateEffect(402, self.node_t_list.layout_privilege.node)
	local effect_3 = RenderUnit.CreateEffect(403, self.node_t_list.layout_privilege.node)
	effect_1:setPosition(210, 480)
	effect_2:setPosition(520, 480)
	effect_3:setPosition(820, 480)
end

function ZsPrivilegeView:CreateScrollViews()
	for i=1,3 do
		local ph = self.ph_list["ph_img_list_" .. i]
		local scroll_view = XUI.CreateScrollView(ph.x + 15, ph.y + 30, 300, 170, ScrollDir.Vertical)
		self.node_t_list.layout_privilege.node:addChild(scroll_view, 10, 10)
		local icon = XUI.CreateImageView(0, 0, string.format("res/xui/privilege/privilege_text_%s.png", i), true)
		local size = icon:getContentSize()
		icon:setAnchorPoint(0, 0)
		if i == 1 then
			scroll_view:setPositionY(ph.y + 35)
		elseif i == 3 then
			scroll_view:setPositionY(ph.y + 20)
		end

		local key_pk_text = RichTextUtil.CreateLinkText(Language.Common.Challenge, 18, COLOR3B.GREEN, nil, true)
		local word_height = size.height - 38 + i

 		key_pk_text:setPosition(250, size.height - 55)
		icon:addChild(key_pk_text, 10)
		XUI.AddClickEventListener(key_pk_text, function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Boss.PersonBoss)
			self:Close()
		end, true)

		scroll_view:setInnerContainerSize(size)
		scroll_view:addChild(icon)
		scroll_view:jumpToTop()
	end
end

function ZsPrivilegeView:OnAllBuyClicked()
	if self.tuangou_alert == nil then
		self.tuangou_alert = Alert.New()
	end
	self.tuangou_alert:SetLableString(Language.Privilege.PrivilegeAlertTips[3])
	self.tuangou_alert:SetOkFunc(function ()
		local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
		local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
		local bool = ios_charge[agent_id] == nil
		local index = bool and 0 or 2
		local cfg = PrivilegeData.GetPrivilegeCfg()
		local price = cfg.group or {0, 0}
		local money = price[2 + index]
		ChongzhiCtrl.BuyPrivilege(money)
  	end)
	self.tuangou_alert:Open()
end

function ZsPrivilegeView:OnFlush(param_t, index)
	local list = PrivilegeData.Instance:GetPrivilegeInfo() 
	self.button_list:SetDataList(list or {})

	local cfg = PrivilegeData.GetPrivilegeCfg()
	local price = PrivilegeData.Instance:GetPrivilegePrice()
	-- self.node_t_list.lbl_old_gold.node:setString((price[2] or cfg.allCostYB[2]) .. "元")
	-- self.node_t_list.lbl_gold.node:setString((price[2] or cfg.allCostYB[2]) .. "元")
end

function ZsPrivilegeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsPrivilegeView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


----------------------------------------------------------------------------------------------------
-- 按钮item
----------------------------------------------------------------------------------------------------
ButtonItem = ButtonItem or BaseClass(BaseRender)
function ButtonItem:__init()
	self:AddClickEventListener()
end

function ButtonItem:__delete()
	self:DeleteOnlineTimer()
	
	if self.buy_alert then
		self.buy_alert:DeleteMe()
		self.buy_alert = nil
	end
end

local op_type = {
	goumai = 1,
	xufei = 2,
	lingqu = 3,
}

function ButtonItem:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.layout_charge.btn_goumai.node, BindTool.Bind(self.OnTeQuanClickRender, self, op_type.goumai))
	XUI.AddClickEventListener(self.node_tree.layout_charge_again.btn_xufei.node, BindTool.Bind(self.OnTeQuanClickRender, self, op_type.xufei))
	XUI.AddClickEventListener(self.node_tree.layout_charge_again.btn_lingqu.node, BindTool.Bind(self.OnTeQuanClickRender, self, op_type.lingqu))
	XUI.AddRemingTip(self.node_tree.layout_charge_again.btn_lingqu.node)

	local cfg = PrivilegeData.GetPrivilegeCfg()
	-- self.node_tree.layout_charge_again.lbl_gold.node:setString(cfg.Pros[self:GetIndex() + 1].CostYB[1])

	-- local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
	-- local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
	-- local vis = ios_charge[agent_id] == nil
	-- self.node_t_list["layout_group_purchase"].node:setVisible(vis)
	-- self.node_t_list["img_bg"].node:setVisible(not vis) -- 遮挡

	local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
	local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
	local bool = ios_charge[agent_id] == nil
	local index = bool and 0 or 2
	local cfg = PrivilegeData.GetPrivilegeCfg() or {}
	local cost_yb = cfg.Pros and cfg.Pros[self:GetIndex() + 1] and cfg.Pros[self:GetIndex() + 1].CostYB or {}
	local cost_yb_1 = cost_yb[1 + index] or 0
	local cost_yb_2 = cost_yb[2 + index] or 0
	self.node_tree.layout_charge_again.lbl_xufei_gold.node:setString(cost_yb_2 .. "元")
	self.node_tree.layout_charge.lbl_goumai_gold.node:setString(cost_yb_1 .. "元")
end

function ButtonItem:OnTeQuanClickRender(click_type)
	local idx = self:GetIndex() + 1
	if click_type == op_type.goumai or click_type == op_type.xufei then
		if self.buy_alert == nil then
			self.buy_alert = Alert.New()
		end
		local title = string.format(Language.Privilege.PrivilegeAlertTips[click_type], Language.Privilege.PrivilegeType[idx])
		self.buy_alert:SetLableString(title)
		self.buy_alert:SetOkFunc(function ()
			local agent_id = GLOBAL_CONFIG and GLOBAL_CONFIG.package_info and GLOBAL_CONFIG.package_info.config.agent_id or ""
			local ios_charge = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.ios_charge or {}
			local bool = ios_charge[agent_id] == nil
			local index = bool and 0 or 2
			local cfg = PrivilegeData.GetPrivilegeCfg() or {}
			local cost_yb = cfg.Pros and cfg.Pros[self:GetIndex() + 1] and cfg.Pros[self:GetIndex() + 1].CostYB or {}
			local cost_yb_1 = cost_yb[1 + index] or 0
			local cost_yb_2 = cost_yb[2 + index] or 0
			local money = (self.data[2] and cost_yb_2 or cost_yb_1)
			ChongzhiCtrl.BuyPrivilege(money)
	  	end)
		self.buy_alert:Open()
	else 
		PrivilegeCtrl.Instance.SendPrivilegeReq(2, idx, click_type)
	end
end

--1现是否为贵族  2是否曾经激活贵族 3是否不可购买 4是否不可续费 5是否不可领取 6是否已生效免掉落
function ButtonItem:OnFlush()
	if self.data == nil then return end
	if nil == self.spare_time and self.data[1] then
		self:CreateAboutTimer()
	end

	local time = PrivilegeData.Instance:GetPrivilegeTimeByIdx(self:GetIndex() + 1) - Status.NowTime
	if time <= 0 and self.data[2] then
		self.node_tree.lbl_spare_time.node:setString(Language.Common.DeathLine)
	end

	self.node_tree.img_desc.node:loadTexture(ResPath.GetPrivilege("privilege_text_" .. self:GetIndex() + 1))
	self.node_tree.layout_charge.node:setVisible(not self.data[2])
	self.node_tree.layout_charge_again.node:setVisible(self.data[2])
	self.node_tree.layout_charge_again.btn_lingqu.node:setEnabled(not self.data[5])
	self.node_tree.layout_charge_again.btn_lingqu.node:UpdateReimd(not self.data[5])
end

function ButtonItem:UpdateSpareTime()
	-- 在线时间
	local time = PrivilegeData.Instance:GetPrivilegeTimeByIdx(self:GetIndex() + 1) - Status.NowTime
	if time <= 0 then
		self.node_tree.lbl_spare_time.node:setString(Language.Common.DeathLine)
		self:DeleteOnlineTimer()
		return
	end
	self.node_tree.lbl_spare_time.node:setString(Language.Common.RemainTime..":"..TimeUtil.FormatSecond2Str(time))
end

function ButtonItem:CreateAboutTimer()
	self.spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
	self:UpdateSpareTime()
end

function ButtonItem:DeleteOnlineTimer()
	if self.spare_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_time)
		self.spare_time = nil
	end
end

function ButtonItem:CreateSelectEffect()
end

return ZsPrivilegeView