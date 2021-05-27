------------------------------------------------------------
-- VIP
------------------------------------------------------------
VipView = VipView or BaseClass(BaseView)

function VipView:__init()
 	self:SetModal(true)

	self.texture_path_list[1] = "res/xui/vip.png"
	self.config_tab = {
		{"vip_ui_cfg", 1, {0}},
	}
end

function VipView:ReleaseCallBack()
	self.vip_progress = nil
	self.eff = nil
end

function VipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function VipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function VipView:LoadCallBack(index, loaded_times)
	self.node_t_list["btn_left"].node:setRotation(180)

	self:CreateProgress()
	self:CreateVipLevelNum()
	self:CreatePrivilegeDesc()
	self:CreateBossList()

	XUI.AddClickEventListener(self.node_t_list["btn_open_view_1"].node, BindTool.Bind(self.OnClickOpenView, self, 1))
	XUI.AddClickEventListener(self.node_t_list["btn_open_view_2"].node, BindTool.Bind(self.OnClickOpenView, self, 2))
	XUI.AddClickEventListener(self.node_t_list["btn_open_view_3"].node, BindTool.Bind(self.OnClickOpenView, self, 3))
	-- XUI.AddClickEventListener(self.node_t_list["btn_open_view_4"].node, BindTool.Bind(self.OnClickOpenView, self, 4))
	XUI.AddClickEventListener(self.node_t_list["btn_left"].node, BindTool.Bind(self.OnLeft, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_right"].node, BindTool.Bind(self.OnRight, self), true)

	self.node_t_list["btn_open_view_4"].node:setVisible(false)
end

function VipView:OnVipRewardChange()
	
end

function VipView:ShowIndexCallBack(index)
	self.page_index = VipData.Instance:GetVipLevel()
	self.page_index = self.page_index == 0 and 1 or self.page_index
	self.vip_level_num_2:SetNumber(self.page_index)
	self.privilege_desc:ChangeToPage(self.page_index)

	if self.eff then
		self.eff:setVisible(true)
	else
		local ph = self.ph_list["ph_vip_progress"]
		local eff = AnimateSprite:create()
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1184)
		eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		eff:setPosition(ph.x+6, ph.y-7)
		self.node_t_list["layout_vip"].node:addChild(eff, 99)
		self.eff = eff
	end

	self:Flush()
end

function VipView:OnFlush()
	local next_level_info = VipData.Instance:GetNextVipNeedInfo()
	local charge_yuanbao = VipData.Instance.charge_total_yuanbao > next_level_info.need_gold and next_level_info.need_gold or VipData.Instance.charge_total_yuanbao
	self.vip_level_num:SetNumber(VipData.Instance.vip_level)
	self.node_t_list.lbl_vip_prog.node:setString(Language.Vip.Experience .. charge_yuanbao .. "/" .. next_level_info.need_gold)
	self.vip_progress:setPercentage(VipData.Instance.charge_total_yuanbao / next_level_info.need_gold * 100)

	local boss_list_data = VipData.Instance.GetVipBossGuanShowList()
	self.boss_list:SetDataList(boss_list_data)
	local view = self.boss_list:GetView()
	view:jumpToRight() -- 跳至boss_list的最右边
end

----------视图函数----------

function VipView:CreateProgress()
	if self.vip_progress == nil then
		local ph = self.ph_list["ph_vip_progress"]
		local x, y = ph.x, ph.y
		local z = self.node_t_list["img_vip_bg"].node:getLocalZOrder()
		local sprite = XUI.CreateSprite(ResPath.GetVipResPath("img_vip_20"))
		self.vip_progress = cc.ProgressTimer:create(sprite)
		self.vip_progress:setScaleX(-1)
		self.vip_progress:setPosition(x, y)
		self.vip_progress:setType(0)
		self.node_t_list["layout_vip"].node:addChild(self.vip_progress, z+1)
		self.vip_progress:setPercentage(0)
	end
end

function VipView:CreateVipLevelNum()
	if self.vip_level_num == nil then
		local ph = self.ph_list["ph_vip_lv"]
		local number_bar = NumberBar.New()
		number_bar:SetGravity(NumberBarGravity.Left)
		number_bar:SetRootPath(ResPath.GetVipResPath("vip_num_"))
		number_bar:SetPosition(ph.x, ph.y)
		number_bar:SetSpace(-9)
		self.vip_level_num = number_bar
		self.node_t_list["layout_vip"].node:addChild(number_bar:GetView(), 100, 100)
		self:AddObj("vip_level_num")
	end

	if self.vip_level_num_2 == nil then
		local ph = self.ph_list["ph_vip_lv_2"]
		local number_bar = NumberBar.New()
		number_bar:SetGravity(NumberBarGravity.Center)
		number_bar:SetRootPath(ResPath.GetVipResPath("vip_level_num_"))
		number_bar:SetPosition(ph.x, ph.y)
		number_bar:SetSpace(-8)
		self.vip_level_num_2 = number_bar
		self.node_t_list["layout_vip"].node:addChild(number_bar:GetView(), 100, 100)
		self:AddObj("vip_level_num_2")
	end
end

function VipView:CreateBossList()
	if nil == self.boss_list then
		local ph = self.ph_list["ph_vip_boss_list"]
		local ph_item = self.ph_list["ph_vip_boss_item"]
		local parent = self.node_t_list["layout_vip"].node
		local w = ph.w / 4
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, w, self.BossListItem, ScrollDir.Horizontal, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnBossItem, self))
		self.boss_list = grid_scroll
		self:AddObj("boss_list")
	end
end

-- 创建VIP特权说时
function VipView:CreatePrivilegeDesc()
	local ph = self.ph_list["ph_privilege_desc"]
	local ph_item = ph
	local parent = self.node_t_list["layout_vip"].node
	local base_grid = BaseGrid.New()
	base_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.privilege_desc = base_grid
	self:AddObj("privilege_desc")


	local data_list = {}
	local index = 0
	for i,v in ipairs(VipPrivilegesCfg or {}) do
		data_list[index] = v
		index = index + 1
	end
	local base_grid_node = base_grid:Create(ph.x,ph.y, ph.w, ph.h, #VipPrivilegesCfg, 1, 1, self.PrivilegeDescItem, ScrollDir.Horizontal, ph)
	base_grid_node:setPosition(ph.x, ph.y)
	parent:addChild(base_grid_node, 99)
	self.privilege_desc:SetDataList(data_list)

	self.max_page = index
end

function VipView:FlushPageBtn()
	local btn_left_remind = false
	local btn_right_remind = false
	local btn_left = self.node_t_list["btn_left"].node
	local btn_right = self.node_t_list["btn_right"].node

	btn_left:setVisible(self.page_index ~= 1)
	btn_right:setVisible(self.page_index ~= self.max_page)
end

----------end----------

function VipView:OnPageChangeCallBack(grid_render, page_index, prve_page_index)
	self.page_index = page_index
	self.vip_level_num_2:SetNumber(self.page_index)
	self:FlushPageBtn()
end

function VipView:OnClickOpenView(index)
	local view_def
	if index == 1 then
		view_def = ViewDef.GuardEquip
	elseif index == 2 then
		view_def = ViewDef.GuardShop
	elseif index == 3 then
		view_def = ViewDef.NewlyBossView.Wild.Specially
	elseif index == 4 then
		view_def = ViewDef.DiamondPet
	end
	local cond_id = view_def.v_open_cond
	if GameCondMgr.Instance:GetValue(cond_id) then
		ViewManager.Instance:OpenViewByDef(view_def)
	else
		local cond = GameCond[cond_id] or {}
		local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local vip_lv = VipData.Instance:GetVipLevel()
		local role_data = {["RoleLevel"] = role_lv, ["VipLevel"] = vip_lv}
		local cond_list = {{"VipLevel", "VIP%d"}, {"RoleLevel", "等级%d级"}}
		local tip_text = ""
		for i, v in pairs(cond_list) do
			local cond_key = v[1]
			if cond[cond_key] and role_data[cond_key] <= cond[cond_key] then
				tip_text = string.format(v[2], cond[cond_key]) .. tip_text
			end
		end
		tip_text = tip_text .. "开放"
		SysMsgCtrl.Instance:FloatingTopRightText(tip_text)
	end
end


-- Boss列表点击回调
function VipView:OnBossItem(item)
	local index = item:GetIndex()
	local items = self.boss_list:GetItems()
	local next_item = items[index + 1] or item
	local next_item_data = next_item:GetData()
	VipData.Instance:SetSelectVipBossNextData(next_item_data)

	VipData.Instance:SetSelectVipBossData(item:GetData())
	ViewManager.Instance:OpenViewByDef(ViewDef.VipBoss)
end

function VipView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.VipContent, Language.DescTip.VipTitle)
end


function VipView:OnLeft()
	if self.privilege_desc:IsChangePage() then return end -- 正在翻面时跳出
	self.privilege_desc:ChangeToPage(self.page_index - 1)
end

function VipView:OnRight()
	if self.privilege_desc:IsChangePage() then return end -- 正在翻面时跳出
	self.privilege_desc:ChangeToPage(self.page_index + 1)
end


----------------------------------------
-- VipBoss列表渲染
----------------------------------------
VipView.BossListItem = BaseClass(BaseRender)
local BossListItem = VipView.BossListItem
function BossListItem:__init()
	self.guan = nil
	self.eff = nil
end

function BossListItem:__delete()
	if self.guan then
		self.guan:DeleteMe()
		self.guan = nil
	end
	self.eff = nil
end

function BossListItem:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_guan_num"]
	local path = ResPath.GetCommon("num_2_")
	local guan = NumberBar.New()
	guan:Create(ph.x, ph.y, ph.w, ph.h, path)
	guan:SetSpace(-7)
	guan:SetGravity(NumberBarGravity.Center)
	self.view:addChild(guan:GetView(), 99)
	self.guan = guan

	XUI.EnableOutline(self.node_tree["lbl_boss_name"].node)
	XUI.AddClickEventListener(self.node_tree["btn_challenge"].node, BindTool.Bind(self.OnChallenge, self), true)
end

function BossListItem:OnFlush()
	if nil == self.data then return end
	self.guan:SetNumber(self.data.guan)
	self.node_tree["lbl_boss_name"].node:setString(self.data.boss_name)
	self.node_tree["prog9_1"].node:setPercent(self.data.percent)

	-- 变灰处理
	local guan_info = VipData.Instance:GetVipBossGuanInfo()
	local is_grey = self.data.guan <= guan_info.guan_num
	local color = is_grey and COLOR3B.G_W or Str2C3b("f2a62e")
	self.node_tree["img9_prog"].node:setGrey(is_grey)
	self.node_tree["img_boss"].node:setGrey(is_grey)
	self.node_tree["img_bg"].node:setGrey(is_grey)
	self.node_tree["lbl_boss_name"].node:setColor(color)
	self.node_tree["lbl_count_name"].node:setColor(color)
	self.node_tree["lbl_count_name"].node:setColor(color)

	local vip_boss_guan_info =  VipData.Instance:GetVipBossGuanInfo()

	if vip_boss_guan_info.guan_num >= self.data.guan  then
		self.node_tree["img_state"].node:loadTexture(ResPath.GetVipResPath("vip_boss_state_1"))
	elseif (vip_boss_guan_info.guan_num + 1) == self.data.guan and self.data.percent >= 100 then
		self.node_tree["img_state"].node:loadTexture(ResPath.GetVipResPath("vip_boss_state_2"))
	else
		self.node_tree["img_state"].node:loadTexture(ResPath.GetVipResPath("vip_boss_state_3"))
	end

	if self.eff then
		self.eff:setVisible((not is_grey) and self.data.percent >= 100)
	elseif (not is_grey) and self.data.percent >= 100 then
		local x, y = self.node_tree["img_bg"].node:getPosition()
		local z = self.node_tree["img_bg"].node:getLocalZOrder()
		local eff = AnimateSprite:create()
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1099)
		eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
		eff:setPosition(x+7, y)
		self.view:addChild(eff, z)
		self.eff = eff
	end
end

function BossListItem:CreateSelectEffect()
	return
end

function BossListItem:OnChallenge()
	local guan = VipData.Instance:GetVipBossGuanInfo().guan_num + 1
	-- 当前关卡才打开boss信息面板
	if self.data.guan == guan then
		if self.data.percent < 100 then
			local item_id = VipChapterConfig and VipChapterConfig.show_id or 0
			local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
			local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
			TipCtrl.Instance:OpenBuyTip(data)		
		else
			local boss_list_data = VipData.Instance.GetVipBossGuanShowList()
			local next_boss_data = boss_list_data[self.index + 1] or self.data
			VipData.Instance:SetSelectVipBossNextData(next_boss_data)
			VipData.Instance:SetSelectVipBossData(self.data)
		end
		VipCtrl.SentSChallengeVipBoss()
	elseif self.data.guan > guan then
		SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.Vip.VipBossTip, guan))
	end
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
VipView.PrivilegeDescItem = BaseClass(BaseRender)
local PrivilegeDescItem = VipView.PrivilegeDescItem

function PrivilegeDescItem:CreateChild()
	BaseRender.CreateChild(self)
end

function PrivilegeDescItem:OnFlush()
	if nil == self.data then return end
	RichTextUtil.ParseRichText(self.node_tree["rich_privilege_desc"].node, self.data.desc or "", 19,COLOR3B.OLIVE)
end

function PrivilegeDescItem:CreateSelectEffect()
	return
end