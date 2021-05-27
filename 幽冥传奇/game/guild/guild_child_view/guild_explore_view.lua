GuildExploreView = GuildExploreView or BaseClass(XuiBaseView)

function GuildExploreView:__init()
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"guild_ui_cfg", 14, {0}},
	}
	self:SetIsAnyClickClose(true)
	
end

function GuildExploreView:__Delete()

end

function GuildExploreView:ReleaseCallBack()
	if self.explore_grid ~= nil then
		self.explore_grid:DeleteMe()
		self.explore_grid = nil
	end
end

function GuildExploreView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateChestGrid()
		-- RichTextUtil.ParseRichText(self.node_t_list.rich_txt_content.node, Language.Guild.Exit_Desc,20, COLOR3B.OLIVE)
		-- XUI.AddClickEventListener(self.node_t_list.btn_colse.node, BindTool.Bind(self.CloseWindow, self))
		-- XUI.AddClickEventListener(self.node_t_list.btn_exit_tip.node, BindTool.Bind(self.ExitSociety, self))
	end
end

function GuildExploreView:CreateChestGrid()
	if self.explore_grid == nil then
		local data = GuildData.Instance:GetGuildExploreData()
		self.explore_grid = BaseGrid.New()
		local ph = self.ph_list.ph_grid_list
		local grid_node = self.explore_grid:CreateCells({w = ph.w, h = ph.h, cell_count=#data, col=#data, row=1, itemRender = BossExploreItemRender, direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_list_item})
		self.node_t_list.layout_transure_explore.node:addChild(grid_node, 10)
		grid_node:setPosition(ph.x, ph.y)
		local cur_data = {}
		local index = 0
		for k,v in pairs(data) do
			cur_data[index] = v
			index = index + 1
		end
		self.explore_grid:SetDataList(cur_data)
	end
	
end

function GuildExploreView:CloseWindow()
	self:Close()
end

function GuildExploreView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildExploreView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GuildExploreView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildExploreView:OnFlush(param_t, index)
	
end

BossExploreItemRender = BossExploreItemRender or BaseClass(BaseRender)
function BossExploreItemRender:__init()
	
end

function BossExploreItemRender:__delete()
	if self.treasure_cell ~= nil then
		for k,v in pairs(self.treasure_cell) do
			v:DeleteMe()
		end
		self.treasure_cell = {}
	end
end

function BossExploreItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.treasure_cell = {}
	for i=1,2 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.view:addChild(cell:GetView(), 103)
		table.insert(self.treasure_cell, cell)
	end

	self.node_tree.img_jpg_bg.node:loadTexture(ResPath.GetBigPainting("guild_bg_"..(5+self.data.pos), true))
	XUI.AddClickEventListener(self.node_tree.btn_enter.node, BindTool.Bind(self.EnterFubenExplore, self))
end

function BossExploreItemRender:EnterFubenExplore()
	GuildCtrl.Instance:ReqEnterExplorepage(self.data.pos)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function BossExploreItemRender:OnFlush()
	if self.data == nil then return end 
	local can_enter = GuildData.Instance:GetCanEnerTime()
	XUI.SetButtonEnabled(self.node_tree.btn_enter.node, can_enter > 0)
	self.node_tree.txt_name.node:setString(self.data.name)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	--local cur_level = circle_level*CIRCLEMAXLEVEl + level
	local color = "ff0000"
	if level >= self.data.enterLevelLimit[2] and circle_level >= self.data.enterLevelLimit[1]  then
		color = "00ff00"
	end
	local txt = string.format(Language.Guild.ExploreEnterLevel, color, self.data.enterLevelLimit[2])
	RichTextUtil.ParseRichText(self.node_tree.txt_need.node, txt)
	XUI.RichTextSetCenter(self.node_tree.txt_need.node)
	for k, v in pairs(self.treasure_cell) do
		v:GetView():setVisible(false)
	end
	for k,v in pairs(self.data.awards) do
		if self.treasure_cell[k] ~= nil then
			self.treasure_cell[k]:GetView():setVisible(true)
			if v.id == 0 then
				local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
				if virtual_item_id then
					self.treasure_cell[k]:SetData({["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0})
				end
			else
				self.treasure_cell[k]:SetData({["item_id"] = v.id, ["num"] = v.count, is_bind = 0})
			end 
		end
	end
end