--------------------------------------------------------
-- VipBoss战斗胜利  配置 
--------------------------------------------------------

VipBossWinView = VipBossWinView or BaseClass(BaseView)

function VipBossWinView:__init()
	self.texture_path_list[1] = 'res/xui/vip.png'
	self:SetModal(true)
	self.config_tab = {
		{"vip_ui_cfg", 3, {0}}
	}

	self.cell_list = {}
end

function VipBossWinView:__delete()
end

--释放回调
function VipBossWinView:ReleaseCallBack()
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end
end

--加载回调
function VipBossWinView:LoadCallBack(index, loaded_times)
	self:CreateCellList()

	local size = self.node_t_list["layout_vip_boss_win"].node:getContentSize()
	local eff = AnimateSprite:create()
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1124)
	eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	eff:setPosition(size.width / 2, size.height + 75)
	eff:setAnchorPoint(0.5, 1)
	self.node_t_list["layout_vip_boss_win"].node:addChild(eff, 0)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_btn_1"].node, BindTool.Bind(self.OnBtn, self), true)


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

--显示索引回调
function VipBossWinView:ShowIndexCallBack(index)
	self.time = 10
	self.node_t_list["lbl_time"].node:setString(string.format("(%d)s", self.time))

	local func = function()
		self.time = self.time - 1
		if self:IsOpen() and self.node_t_list["lbl_time"] then
			self.node_t_list["lbl_time"].node:setString(string.format("(%d)s", self.time))
			if self.time <= 0 then
				-- 退出副本
				local fuben_id = FubenData.Instance:GetFubenId()
				FubenCtrl.OutFubenReq(fuben_id)


				GlobalTimerQuest:CancelQuest(self.timer)
				self.timer = nil
				
				ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
				ViewManager.Instance:CloseViewByDef(ViewDef.VipBossWin)
			end
		else
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end
	self.timer = GlobalTimerQuest:AddRunQuest(func, 1)

	self.next_boss_data = VipData.Instance:GetSelectVipBossNextData()
	local select_boss_data = VipData.Instance:GetSelectVipBossData()
		
	if select_boss_data ~= self.next_boss_data then
		self.node_t_list["layout_next_boss"].node:setVisible(true)
		self.node_t_list["img_all_complete"].node:setVisible(false)

		local name = self.next_boss_data.boss_name or ""
		self.node_t_list["lbl_boss_name"].node:setString(name)
		XUI.EnableOutline(self.node_t_list["lbl_boss_name"].node)

		local power = self.next_boss_data.power or 0
		local role_power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER)
		local bool = role_power >= power
		local color = bool and COLOR3B.GREEN or COLOR3B.RED
		self.node_t_list["lbl_power"].node:setColor(color)
		self.node_t_list["lbl_power"].node:setString(Language.Vip.VipBossPower .. power)

		self:FlushCellList()
	else
		self.node_t_list["layout_next_boss"].node:setVisible(false)
		self.node_t_list["img_all_complete"].node:setVisible(true)
	end
end

----------视图函数----------

function VipBossWinView:CreateCellList()
	local ph = self.ph_list["ph_cell_list"]
	local ph_item = self.ph_list["ph_cell_item"]
	local parent = self.node_t_list["layout_next_boss"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, self.CellListItem, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
end

function VipBossWinView:FlushCellList()
	local show_list = self.next_boss_data.show or {}
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	self.cell_list:SetCenter()
end

----------end----------

-- 挑战boss按钮点击回调
function VipBossWinView:OnBtn()
	self.time = 0
	GlobalTimerQuest:EndQuest(self.timer)
	self.timer = nil
end

--------------------

----------------------------------------
-- cell_list 渲染
----------------------------------------
VipBossWinView.CellListItem = BaseClass(BaseRender)
local CellListItem = VipBossWinView.CellListItem
function CellListItem:__init()
	--self.item_cell = nil
end

function CellListItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function CellListItem:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_cell"]
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	self.view:addChild(cell:GetView(), 2)
	self.cell = cell
end

function CellListItem:OnFlush()
	if nil == self.data then return end
	local item_name = ItemData.Instance:GetItemName(self.data.item_id or 1)
	self.node_tree["lbl_item_name"].node:setString(item_name)
	self.cell:SetData(self.data)
	self.cell:SetBindIconVisible(false)
end

function CellListItem:CreateSelectEffect()
	return
end

function CellListItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end