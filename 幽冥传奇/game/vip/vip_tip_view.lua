------------------------------------------------------------
-- Vip升级提示
------------------------------------------------------------

VipTipView = VipTipView or BaseClass(BaseView)

function VipTipView:__init()
	self.is_any_click_close = true
	self:SetModal(true)

	self.texture_path_list[1] = "res/xui/vip.png"
	self.config_tab = {
		{"vip_ui_cfg", 5, {0}},
	}

end

function VipTipView:__delete()
end

function VipTipView:ReleaseCallBack()

end

function VipTipView:LoadCallBack(index, loaded_times)
	self:CreateVipLevel()

	self.node_t_list["scroll_vip_privilege"].node:setScorllDirection(ScrollDir.Vertical)
	local ph = self.ph_list["ph_vip_privilege"]
	self.vip_privilege = XUI.CreateRichText(0, 0, ph.w, ph.h, false)
	self.vip_privilege:setAnchorPoint(0, 1)

	local inner_conent = self.node_t_list["scroll_vip_privilege"].node:getInnerContainer()
	inner_conent:addChild(self.vip_privilege)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_view_details"].node, BindTool.Bind(self.OnViewDetails, self), true)
end

--显示索引回调
function VipTipView:ShowIndexCallBack(index)
	self:Flush()
end

----------视图函数----------

function VipTipView:OnFlush()
	local vip_lv = VipData.Instance:GetVipLevel()
	self.vip_level:SetNumber(vip_lv)

	local privilege_cfg = VipData.GetVipPrivilegeCfgByLevel(vip_lv)
	RichTextUtil.ParseRichText(self.vip_privilege, privilege_cfg.desc, 20, COLOR3B.OLIVE)
	self.vip_privilege:refreshView()

	local inner_conent = self.node_t_list["scroll_vip_privilege"].node:getInnerContainer()
	local inner_size = self.node_t_list["scroll_vip_privilege"].node:getContentSize()
	local text_size = self.vip_privilege:getInnerContainerSize()
	local ph = self.ph_list["ph_vip_privilege"]
	self.vip_privilege:setPosition(0, text_size.height)
	inner_conent:setContentWH(inner_size.width, text_size.height)

	self.node_t_list["scroll_vip_privilege"].node:jumpToTop()
end

function VipTipView:CreateVipLevel()
	local ph = self.ph_list["ph_vip_lv"]
	local path = ResPath.GetCommon("num_5_")
	local parent = self.node_t_list["layout_vip_tip"].node
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.vip_level = number_bar
	self:AddObj("vip_level")
end

----------end----------

-- 挑战boss按钮点击回调
function VipTipView:OnViewDetails()
	ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
	ViewManager.Instance:CloseViewByDef(ViewDef.VipTip)
end

--------------------