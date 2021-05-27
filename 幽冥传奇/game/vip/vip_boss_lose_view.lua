--------------------------------------------------------
-- VipBoss战斗失败  配置 
--------------------------------------------------------

VipBossLoseView = VipBossLoseView or BaseClass(BaseView)

function VipBossLoseView:__init()
	self.texture_path_list[1] = 'res/xui/vip.png'
	self:SetModal(true)
	self.config_tab = {
		{"vip_ui_cfg", 4, {0}}
	}
end

function VipBossLoseView:__delete()
end

--释放回调
function VipBossLoseView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
end

--加载回调
function VipBossLoseView:LoadCallBack(index, loaded_times)
	self:InitTexts()
	self:InitTextBtn()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_btn_1"].node, BindTool.Bind(self.OnBtn, self), true)

	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function VipBossLoseView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function VipBossLoseView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function VipBossLoseView:ShowIndexCallBack(index)

end
----------视图函数----------

function VipBossLoseView:InitTexts()
	local text
	local text_list = Language.Vip.VipBossLoseText or {}
	text = text_list[1] or ""
	self.node_t_list["lbl_text_1"].node:setString(text)
	text = text_list[2] or ""
	self.node_t_list["lbl_text_2"].node:setString(text)
	text = text_list[3] or ""
	self.node_t_list["lbl_text_3"].node:setString(text)
	text = text_list[4] or ""
	self.node_t_list["lbl_text_4"].node:setString(text)
end

function VipBossLoseView:InitTextBtn()
	local ph, text_btn
	ph = self.ph_list["ph_text_btn_1"]
	text_btn = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_vip_boss_lose"].node:addChild(text_btn, 9)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 1), true)

	ph = self.ph_list["ph_text_btn_2"]
	text_btn = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_vip_boss_lose"].node:addChild(text_btn, 9)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 2), true)

	ph = self.ph_list["ph_text_btn_3"]
	text_btn = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_vip_boss_lose"].node:addChild(text_btn, 9)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 3), true)

	ph = self.ph_list["ph_text_btn_4"]
	text_btn = RichTextUtil.CreateLinkText(Language.Common.GoTo, 19, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_vip_boss_lose"].node:addChild(text_btn, 9)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 4), true)
end

----------end----------

function VipBossLoseView:OnBtn()
	self:Close()
end

function VipBossLoseView:OnTextBtn(index)
	if index == 1 then
		ViewManager.Instance:OpenViewByDef(ViewDef.Boss)
		ViewManager.Instance:CloseViewByDef(ViewDef.VipBossLose)
	elseif index == 2 then
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
		ViewManager.Instance:CloseViewByDef(ViewDef.VipBossLose)
	elseif index == 3 then
		ViewManager.Instance:OpenViewByDef(ViewDef.OpenSerVeGift.SaleGift)
		ViewManager.Instance:CloseViewByDef(ViewDef.VipBossLose)
	elseif index == 4 then
		ViewManager.Instance:OpenViewByDef(ViewDef.ChargeFirst)
		ViewManager.Instance:CloseViewByDef(ViewDef.VipBossLose)
	end
end

--------------------
