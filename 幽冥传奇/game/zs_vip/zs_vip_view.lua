ZsVipView = ZsVipView or BaseClass(BaseView)

ZsVipView.MAX_LEVEL = 15
ZsVipView.ENUM_JIE = 3

function ZsVipView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("ZsVip")
	self.texture_path_list = {
		'res/xui/zs_vip.png',
		'res/xui/vip.png',
	}
	self.config_tab = {
		{"zs_vip_ui_cfg", 2, {0}},
		{"zs_vip_ui_cfg", 1, {0}, nil, 999},
	}
	
	self.btn_info = {ViewDef.ZsVip.VipChild, ViewDef.ZsVip.Privilege, ViewDef.ZsVip.Recharge}
	require("scripts/game/zs_vip/zs_gift_view").New(ViewDef.ZsVip.VipChild)
	-- require("scripts/game/zs_vip/zs_vip_child_view").New(ViewDef.ZsVip.VipChild)
	require("scripts/game/zs_vip/zs_privilege_view").New(ViewDef.ZsVip.Privilege)
	require("scripts/game/chongzhi/chongzhi_view").New(ViewDef.ZsVip.Recharge)


	self.page_award_idx = 1
end

function ZsVipView:ReleaseCallBack()
	if self.vip_progress then
		self.vip_progress:DeleteMe()
		self.vip_progress = nil
	end

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function ZsVipView:LoadCallBack(index, loaded_times)
	self.data = ZsVipData.Instance				--数据
	ZsVipData.Instance:AddEventListener(ZsVipData.INFO_CHANGE, function ()
		self:Flush()
		self:ZsVipRemindTabbar()
	end)

	XUI.RichTextSetCenter(self.node_t_list.rich_next_vip.node)
	if self.vip_progress == nil then
		self.vip_progress = ProgressBar.New()
		local x, y = self.node_t_list["prog_bg"].node:getPosition()
		local z = self.node_t_list["prog_bg"].node:getLocalZOrder()
		local prog = XUI.CreateLoadingBar(x, y, ResPath.GetCommon("prog_123_progress"), XUI.IS_PLIST)
		self.node_t_list["layout_vip_top"].node:addChild(prog, (z + 1))
		self.vip_progress:SetView(prog)
		self.vip_progress:SetTotalTime(0)
		self.vip_progress:SetTailEffect(991, nil, true)
		self.vip_progress:SetEffectOffsetX(-20)
		self.vip_progress:SetPercent(0)
		self.node_t_list.lbl_vip_prog.node:setLocalZOrder(100)
	end

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:SetClickItemValidFunc(function(index)
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.tabbar:CreateWithNameList(self:GetRootNode(), -13, 520, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetCommon("toggle_110"), 25, true)

	XUI.AddClickEventListener(self.node_t_list.btn_charge.node, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	end)
	self.node_t_list.img_zs_tip.node:setVisible(false)
	-- XUI.AddClickEventListener(self.node_t_list.img_zs_tip.node, function ()
	-- --	DescTip.Instance:SetContent(Language.DescTip.ZSVipConent, Language.DescTip.ZSVipTitle)
	-- end)
	self:ZsVipRemindTabbar()

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(PrivilegeData.Instance, self):AddEventListener(PrivilegeData.TEQUAN_CHANGE, BindTool.Bind(self.ZsVipRemindTabbar, self))

end

function ZsVipView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function ZsVipView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_CUTTING_LEVEL then
		-- self.node_t_list.lbl_vip_level.node:setString(self.data:GetZsVipLv())
		self:Flush()
	elseif key == OBJ_ATTR.ACTOR_MAX_EXP_L or OBJ_ATTR.ACTOR_MAX_EXP_H then
		self:Flush()
	end
end

function ZsVipView:ShowIndexCallBack()
	self:Flush()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
			return
		end
	end
end

function ZsVipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsVipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsVipView:OnFlush(vo)
	-- 下一级提示
	local lv = self.data:GetZsVipLv()
	-- lv = 24
	local next_need_zs = SVipConfig.SVipGrade[(lv + 1) > ZsVipView.MAX_LEVEL and ZsVipView.MAX_LEVEL or (lv + 1)].needYuanBao
	local txt = ""
	if lv >= ZsVipView.MAX_LEVEL then
		txt = Language.ZsVip.MaxTip
	elseif lv == 0 then
		txt = string.format(Language.ZsVip.chargeTip, next_need_zs - ZsVipData.GetZsVipPoint(), Language.ZsVip.jieshu[1] .. Language.ZsVip.level[1]) 
	else
		local e_lv = (lv + 1) % ZsVipView.ENUM_JIE == 0 and ZsVipView.ENUM_JIE or (lv + 1) % ZsVipView.ENUM_JIE
		txt = string.format(Language.ZsVip.chargeTip, next_need_zs - ZsVipData.GetZsVipPoint(), Language.ZsVip.jieshu[math.ceil((lv + 1) / ZsVipView.ENUM_JIE)] .. Language.ZsVip.level[e_lv]) 
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_vip.node, txt)

	local curr_e_lv = lv % ZsVipView.ENUM_JIE
	if curr_e_lv == 0 and lv > 0 then
		curr_e_lv = ZsVipView.ENUM_JIE
	end

	local show_jieshu = math.ceil(lv / ZsVipView.ENUM_JIE)
	if show_jieshu == 0 then
		show_jieshu = 1
	end
	for i = 1, 3 do
		self.node_t_list["img_lv_" .. i].node:setVisible(i <= curr_e_lv)
		self.node_t_list["img_lv_" .. i].node:loadTexture(ResPath.GetZsVip("vip_icon_" .. show_jieshu))
	end
	self.node_t_list.img_js.node:loadTexture(ResPath.GetZsVip("vip_lv_" .. show_jieshu))

	local text, per = "", 0
	if lv >= ZsVipView.MAX_LEVEL then
		text = "0/0"
		per = 100
	else	
		text = ZsVipData.GetZsVipPoint() .. "/" .. next_need_zs
		per = (ZsVipData.GetZsVipPoint()/next_need_zs) * 100
	end
	self.node_t_list.lbl_vip_prog.node:setString(text)

	self.vip_progress:SetPercent(per)
end

-- 标签栏提醒
function ZsVipView:ZsVipRemindTabbar()
	self.tabbar:SetRemindByIndex(1, ZsVipData.Instance:GetRewardRemind() > 0)
	self.tabbar:SetRemindByIndex(2, PrivilegeData.Instance:GetRemindNum() > 0)
	-- self.wild_tabbar:SetRemindByIndex(4, NewlyBossData.Instance:GetBossRemid(4) > 0)
	-- self.wild_tabbar:SetRemindByIndex(5, NewlyBossData.Instance:GetBossRemid(2) > 0)
end