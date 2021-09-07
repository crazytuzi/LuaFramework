ScoietyEnemyView = ScoietyEnemyView or BaseClass(BaseRender)
function ScoietyEnemyView:__init()
	self.cell_list = {}
end
function ScoietyEnemyView:LoadCallBack()
	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("Content/EnemyList")
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
	self:Flush()
end

function ScoietyEnemyView:OnFlush()
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
	--self.show_image = self:FindVariable("ShowImage")
	self.image_obj = self:FindObj("RoleImage")
	self.raw_image_obj = self:FindObj("RawImage")

	self.image_res = self:FindVariable("ImageRes")
	self.rawimage_res = self:FindVariable("RawImageRes")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function ScrollerEnemyCell:__delete()
	self.avatar_key = 0
end

-- function ScrollerEnemyCell:LoadCallBack(user_id, raw_image_obj, path)
-- 	if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
-- 		return
-- 	end

-- 	if user_id ~= self.data.user_id then
-- 		return
-- 	end

-- 	if path == nil then
-- 		path = AvatarManager.GetFilePath(self.data.user_id, false)
-- 	end
-- 	raw_image_obj.raw_image:LoadSprite(path, function ()
-- 		if user_id ~= self.data.user_id then
-- 			return
-- 		end
-- 		--self.show_image:SetValue(false)
-- 	end)
-- end

function ScrollerEnemyCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.role_name:SetValue(CampData.Instance:GetCampNameByCampType(self.data.camp, true) .. self.data.gamename)


	-- local avatar_key = AvatarManager.Instance:GetAvatarKey(self.data.user_id)
	-- if avatar_key == 0 then
	-- 	self.avatar_key = 0
	-- 	local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
	-- 	self.image_res:SetAsset(bundle, asset)
	-- 	--self.show_image:SetValue(true)
	-- else
	-- 	if avatar_key ~= self.avatar_key then
	-- 		self.avatar_key = avatar_key
	-- 		AvatarManager.Instance:GetAvatar(self.data.user_id, false, BindTool.Bind(self.LoadCallBack, self, self.data.user_id, self.raw_image_obj))
	-- 	end
	-- end

	AvatarManager.Instance:SetAvatarKey(self.data.user_id, self.data.avatar_key_big, self.data.avatar_key_small)
	if self.data.avatar_key_small == 0 then
		self.image_obj.gameObject:SetActive(true)
		self.raw_image_obj.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_obj.image:LoadSprite(bundle, asset)
		self.image_res:SetAsset(bundle, asset)
	else
		local function callback(path)
			if IsNil(self.image_obj.gameObject) or IsNil(self.raw_image_obj.gameObject) then
				return
			end
			if path == nil then
				path = AvatarManager.GetFilePath(self.data.user_id, false)
			end
			self.raw_image_obj.raw_image:LoadSprite(path, function ()
				if self.data.avatar_key_small == 0 then
					self.image_obj.gameObject:SetActive(true)
					self.raw_image_obj.gameObject:SetActive(false)
					return
				end
				self.image_obj.gameObject:SetActive(false)
				self.raw_image_obj.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(self.data.user_id, false, callback)
	end
	
	local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.lev:SetValue(level_des)
	self.hatred:SetValue(self.data.kill_count)
	self.prof:SetValue(Language.Common.ProfName[self.data.prof])
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

	local canel_callback = function ()
		self.enemy_view:SetSelectIndex(0)
		self.root_node.toggle.isOn = false
	end
	
	local click_obj = self.enemy_view.scroller
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.EnemyType, self.data.gamename, click_obj, canel_callback)
end