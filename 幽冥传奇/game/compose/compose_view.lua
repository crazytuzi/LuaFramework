require("scripts/game/compose/compose_xf_page")
require("scripts/game/compose/compose_hd_page")
require("scripts/game/compose/compose_bs_page")
require("scripts/game/compose/compose_hz_page")
require("scripts/game/compose/compose_ht_ring_page")
require("scripts/game/compose/compose_mb_ring_page")
require("scripts/game/compose/compose_fh_ring_page")
-- require("scripts/game/compose/compose_xz_page")
require("scripts/game/compose/compose_god_arm_page")
------------------------------------------------------------
-- 神炉View
------------------------------------------------------------
ComposeView = ComposeView or BaseClass(XuiBaseView)

function ComposeView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.compose_new_xf
	self.is_async_load = false
 	self.texture_path_list[1] = 'res/xui/compose.png'
 	self.texture_path_list[2] = 'res/xui/achieve.png'
 	self.texture_path_list[3] = 'res/xui/god_arm.png'
 	
	self.config_tab = { --类dom模式,数组顺序决定渲染顺序
		{"common_ui_cfg", 5, {0}},
		{"common_ui_cfg", 1, {0}},
		{"compose_ui_cfg", 1, {0}},
		{"compose_ui_cfg", 2, {TabIndex.compose_new_xf}},
		{"compose_ui_cfg", 3, {TabIndex.compose_new_hd}},
		{"compose_ui_cfg", 4, {TabIndex.compose_new_bs}},
		{"compose_ui_cfg", 5, {TabIndex.compose_new_hz}},
		{"compose_ui_cfg", 7, {TabIndex.compose_new_mb}},
		{"compose_ui_cfg", 8, {TabIndex.compose_new_ht}},
		{"compose_ui_cfg", 9, {TabIndex.compose_new_fh}},
		-- {"achieve_ui_cfg", 1, {TabIndex.compose_new_xz}},
		-- {"achieve_ui_cfg", 3, {TabIndex.compose_new_xz}},
		{"compose_ui_cfg", 10, {TabIndex.compose_god_arm}},
		{"common_ui_cfg", 2, {0}},
	}
	
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.compose_new_xf] = ComposeXfPage.New()
	self.page_list[TabIndex.compose_new_hd] = ComposeHdPage.New()
	self.page_list[TabIndex.compose_new_bs] = ComposeBsPage.New()
	self.page_list[TabIndex.compose_new_hz] = ComposeHzPage.New()
	self.page_list[TabIndex.compose_new_mb] = ComposeMbPage.New()
	self.page_list[TabIndex.compose_new_ht] = ComposeHtPage.New()
	self.page_list[TabIndex.compose_new_fh] = ComposeFhPage.New()
	-- self.page_list[TabIndex.compose_new_xz] = ComposeXzPage.New()
	self.page_list[TabIndex.compose_god_arm] = ComposeGodArmPage.New()
	self.title_img_path = ResPath.GetCompose("btn_compose_txt")
	self.remind_temp = {}
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
	-- self.tabbar = TabbarTwo.New()
	self.tabbar = TabbarTwo.New(Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar:SetInterval(-3)
	self.tabbar:Init(Language.Compose.TabGrop, {}, true)
	self.tabbar:SetSelectCallback(BindTool.Bind1(self.OnTabChangeHandler, self))
	self.tabbar:SetToggleVisible(TabIndex.compose_god_arm, false)	
end

function ComposeView:__delete()
	self.tabbar:DeleteMe()
	self.tabbar = nil
end

function ComposeView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:Release()
	end
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end
	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.Compose)
end

function ComposeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		ViewManager.Instance:RegsiterTabFunUi(ViewName.Compose, self.tabbar)
	end

	if nil == self.page_list[index] then
		return
	end
	self:FlushTabbar()
	--初始化页面接口
	self.page_list[index]:InitPage(self)
	
end



function ComposeView:OpenCallBack()
	self.tabbar:ChangeToIndex(self.show_index, self.root_node)
	self:BoolShowTabbar()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ComposeView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ComposeView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index, self.root_node)
	self:Flush(index)
end
--接受信息刷新
function ComposeView:OnFlush(param_t, index)
	if nil ~= self.page_list[index] then
		--更新页面接口
		self.page_list[index]:UpdateData(param_t)
	end
	for k, v in pairs(param_t) do
		if k == "all" then
			self:FlushTabbar(index)
		elseif k == "remind" then
			self:FlushTabbar()
		end
	end
end


function ComposeView:OnTabChangeHandler(index)
	self:ChangeToIndex(index)
end


function ComposeView:OnGetUiNode(node_name)
	local node, is_next = XuiBaseView.OnGetUiNode(self, node_name)
	if node then
		return XuiBaseView.OnGetUiNode(self, node_name) 
	end
end

function ComposeView:RemindChange(remind_name, num)
	if remind_name == RemindName.XFUpLv then
		self.remind_temp[TabIndex.compose_new_xf] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.ShieldUpGrade then
		self.remind_temp[TabIndex.compose_new_hd] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.DiamondUpLv then
		self.remind_temp[TabIndex.compose_new_bs] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.SoulBeadUpLv then
		self.remind_temp[TabIndex.compose_new_hz] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.MBRingUpLv then
		self.remind_temp[TabIndex.compose_new_mb] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.FTRingUpLv then
		self.remind_temp[TabIndex.compose_new_ht] = num 
		self:Flush(0, "remind")
	elseif remind_name == RemindName.FHRingUpLv then
		self.remind_temp[TabIndex.compose_new_fh] = num 
		self:Flush(0, "remind")
	-- elseif remind_name == RemindName.AchieveMedal then	
		-- self.remind_temp[TabIndex.compose_new_xz] = num 
		-- self:Flush(0, "remind")
	end 
end

function ComposeView:FlushTabbar()
	for k,v in pairs(self.remind_temp) do
		self.tabbar:SetRemindByIndex(k, v > 0)
	end
end

function ComposeView:BoolShowTabbar()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	self.tabbar:SetToggleVisible(TabIndex.compose_new_mb, self.tabbar:GetToggleVisible(TabIndex.compose_new_mb) and prof == 1)
	self.tabbar:SetToggleVisible(TabIndex.compose_new_ht, self.tabbar:GetToggleVisible(TabIndex.compose_new_ht) and prof ~= 1)
end