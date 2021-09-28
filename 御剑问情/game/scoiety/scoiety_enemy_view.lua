ScoietyEnemyView = ScoietyEnemyView or BaseClass(BaseRender)
function ScoietyEnemyView:__init()
	-- 生成滚动条
	self.cell_list = {}
	self.scroller_data = {}
	self.scroller = self:FindObj("EnemyList")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local enemy_cell = self.cell_list[cell]
		if enemy_cell == nil then
			enemy_cell = ScrollerEnemyCell.New(cell.gameObject)
			enemy_cell.root_node.toggle.group = self.scroller.toggle_group
			enemy_cell.enemy_view = self
			self.cell_list[cell] = enemy_cell
		end

		enemy_cell:SetIndex(data_index)
		enemy_cell:SetData(self.scroller_data[data_index])
	end

	self:ListenEvent("ClickEmpty",BindTool.Bind(self.ClickEmpty, self))

	self.scroller.scroller.scrollerScrollingChanged = function ()
		ScoietyCtrl.Instance:CloseOperaList()
	end
end

function ScoietyEnemyView:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ScoietyEnemyView:CloseEnemyView()
	self.select_index = nil
end

function ScoietyEnemyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ScoietyEnemyView:GetSelectIndex()
	return self.select_index or 0
end

function ScoietyEnemyView:ClickEmpty()
	ScoietyCtrl.Instance:CloseOperaList()
end

function ScoietyEnemyView:FlushEnemyView()
	self.scroller_data = ScoietyData.Instance:GetEnemyList()
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

----------------------------------------------------------------------------
--ScrollerEnemyCell 		仇人滚动条格子
----------------------------------------------------------------------------

ScrollerEnemyCell = ScrollerEnemyCell or BaseClass(BaseCell)

function ScrollerEnemyCell:__init()
	self.avatar_key = 0
	
	self.role_name = self:FindVariable("Name")
	self.hatred = self:FindVariable("Hatred")
	self.lev = self:FindVariable("Lev")
	self.prof = self:FindVariable("Prof")
	self.zhanli = self:FindVariable("ZhanLi")
	self.gray = self:FindVariable("Gray")

	--头像UI
	self.show_image = self:FindVariable("ShowImage")
	self.raw_image_obj = self:FindObj("RawImage")
	self.image_res = self:FindVariable("ImageRes")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function ScrollerEnemyCell:__delete()
	self.avatar_key = 0
	if self.enemy_view then
		self.enemy_view = nil
	end
end

function ScrollerEnemyCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.role_name:SetValue(self.data.gamename)

	local role_id = self.data.user_id

	local function download_callback(path)
		if nil == self.raw_image_obj or IsNil(self.raw_image_obj.gameObject) then
			return
		end
		if self.data.user_id ~= role_id then
			return
		end
		local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
		self.raw_image_obj.raw_image:LoadSprite(avatar_path,
		function()
			if self.data.user_id ~= role_id then
				return
			end
			self.show_image:SetValue(false)
		end)
	end
	CommonDataManager.NewSetAvatar(role_id, self.show_image, self.image_res, self.raw_image_obj, self.data.sex, self.data.prof, false, download_callback)
	
	local level_des = PlayerData.GetLevelString(self.data.level)
	self.lev:SetValue(level_des)
	self.hatred:SetValue(self.data.kill_count)
	self.prof:SetValue(PlayerData.GetProfNameByType(self.data.prof, self.data.is_online ~= 1))
	self.zhanli:SetValue(self.data.capability)

	if self.data.is_online ~= 1 then
		self.gray:SetValue(true)
	else
		self.gray:SetValue(false)
	end

	-- 刷新选中特效
	local select_index = self.enemy_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function ScrollerEnemyCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.enemy_view:SetSelectIndex(self.index)

	local function canel_callback()
		self.enemy_view:SetSelectIndex(0)
		self.root_node.toggle.isOn = false
	end

	local click_obj = self.enemy_view.scroller
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.EnemyType, self.data.gamename, click_obj, canel_callback)
end