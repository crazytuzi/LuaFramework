
ActBabelTowerView = ActBabelTowerView or BaseClass(BaseView)

function ActBabelTowerView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)

	if	ActBabelTowerView.Instance then
		ErrorLog("[ActBabelTowerView]:Attempt to create singleton twice!")
	end
	self.texture_path_list[1] = 'res/xui/activity_brilliant.png'
	self.config_tab = {
		{"act_babel_tower_ui_cfg", 1, {0}},
		{"act_babel_tower_ui_cfg", 2, {0}},
	}
end

function ActBabelTowerView:__delete()
end

function ActBabelTowerView:ReleaseCallBack()
    if self.tower_spare_time then
		GlobalTimerQuest:CancelQuest(self.tower_spare_time)
		self.tower_spare_time = nil
	end

	if self.tower_cell_list and next(self.tower_cell_list) then
		for k,v in pairs(self.tower_cell_list) do
			for k1,v1 in pairs(v) do
				v1:DeleteMe()
			end
		end
		self.tower_cell_list = {}
	end 

	if self.tower_level_num then
		self.tower_level_num:DeleteMe()
		self.tower_level_num = nil
	end

	if self.draw_record_list then
		self.draw_record_list:DeleteMe()
		self.draw_record_list = nil
	end

	if self.auto_draw_time_quest then
		GlobalTimerQuest:CancelQuest(self.auto_draw_time_quest)
		self.auto_draw_time_quest = nil
	end

	self.select_effect = nil
end


function ActBabelTowerView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.current_index = ActivityBrilliantData.Instance:GetTowerLevel()
		self:CreateTowerCells()
		self:CreateSpareTimer()
		self:CreateSelectEffect()
		self:CreateDrawRecord()
		self:CreateTowerLevelNumber()
		self.draw_count = 0
		XUI.AddClickEventListener(self.node_t_list.btn_draw_one.node, BindTool.Bind(self.OnClickDrawOne, self), false)
		XUI.AddClickEventListener(self.node_t_list.btn_draw_ten.node, BindTool.Bind(self.OnClickDrawTen, self), false)
		XUI.AddClickEventListener(self.node_t_list.btn_draw_fiften.node, BindTool.Bind(self.OnClickDrawFifTen, self), false)
	end
end

function ActBabelTowerView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActBabelTowerView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function ActBabelTowerView:ShowIndexCallBack(index)
	self:Flush()
end

function ActBabelTowerView:OnFlush(param_list, index)
	local cost = ActivityBrilliantData.Instance:GetTowerDrawCost()
	self.node_t_list.lbl_draw_one_cost.node:setString(cost)
	self.current_index = ActivityBrilliantData.Instance:GetTowerLevel()
	self:RefreshSelectEffect()
	self:FlushDrawRecord()
	self:RefreshNextLevel()
	self.tower_level_num:SetNumber(self.current_index)
end

function ActBabelTowerView:OnClickDrawOne()
	self:TowerDrawReq()
	self.draw_count = 0
end

function ActBabelTowerView:OnClickDrawTen()
	if nil == self.auto_draw_time_quest then
		self:UpdateAutoDrawTimer()
	end
end

function ActBabelTowerView:OnClickDrawFifTen()
	if nil == self.auto_draw_time_quest then
		self:UpdateAutoDrawTimerFif()
	end
end

function ActBabelTowerView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TTT)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_act_babel_tower.lbl_64_surplus_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActBabelTowerView:CreateSpareTimer()
	self.tower_spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
end

function ActBabelTowerView:UpdateAutoDrawTimer()
	if nil == self.auto_draw_time_quest then
		self.auto_draw_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TowerDrawReq, self), 0.2)
	end
end

function ActBabelTowerView:UpdateAutoDrawTimerFif()
	if nil == self.auto_draw_time_quest then
		self.auto_draw_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TowerDrawFiftenReq, self), 0.2)
	end
end

function ActBabelTowerView:TowerDrawReq()
	self.draw_count = self.draw_count + 1
	if self.draw_count <= 10 then
		self.current_index = ActivityBrilliantData.Instance:GetTowerLevel()
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.TTT, self.current_index)
		-- self:Flush()
	else
		self:CancelAutoDrawTimer()
		self.draw_count = 0
	end
end

function ActBabelTowerView:TowerDrawFiftenReq()
	self.draw_count = self.draw_count + 1
	if self.draw_count <= 50 then
		self.current_index = ActivityBrilliantData.Instance:GetTowerLevel()
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.TTT, self.current_index)
		-- self:Flush()
	else
		self:CancelAutoDrawTimer()
		self.draw_count = 0
	end
end

--停止定时器
function ActBabelTowerView:CancelAutoDrawTimer()
	if self.auto_draw_time_quest then
		GlobalTimerQuest:CancelQuest(self.auto_draw_time_quest)
	end
	self.auto_draw_time_quest = nil
end

function ActBabelTowerView:CreateTowerCells()
	self.tower_cell_list = {}
	self.ph_cell_list = {}
	self.obtain_img_list = {}
	for i = 1, 6 do
		self.tower_cell_list[i] = {}
		self.ph_cell_list[i] = {}
		for j = 1, 7 - i do
			local ph = self.ph_list["ph_tower_cell_".. i .."_" .. j]
			local cell = ActBaseCell.New()
			cell:SetPosition(ph.x, ph.y)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_act_babel_tower.node:addChild(cell:GetView(), 300)
			table.insert(self.tower_cell_list[i], cell)
			table.insert(self.ph_cell_list[i], ph)
		end
	end

	local obtain_img = nil
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TTT)
	if nil == cfg then return end
	local show_list = cfg.config.showList
	if nil == show_list then return end
	for k,v in pairs(self.tower_cell_list) do
		for k1,v1 in pairs(v) do
			local item_data = {}
			if nil ~= show_list[k] and nil ~= show_list[k][k1] then
				item_data.item_id = show_list[k][k1].id
				item_data.num = show_list[k][k1].count
				item_data.is_bind = show_list[k][k1].bind
				item_data.effectId = show_list[k][k1].effectId
				v1:SetData(item_data)
			else
				v1:SetData({item_id = 522,num = 1,is_bind = 1,})
			end
			if show_list[k][k1].isspecial and show_list[k][k1].isspecial > 0 then
				obtain_img = XUI.CreateImageView(self.ph_cell_list[k][k1].x, self.ph_cell_list[k][k1].y, ResPath.GetCommon("stamp_18"), true)
			end
			-- v1:SetVisible(show_list[k][k1] ~= nil)
		end
		if obtain_img then
			self.node_t_list.layout_act_babel_tower.node:addChild(obtain_img, 999)
			table.insert(self.obtain_img_list, obtain_img)
		end
	end
end

function ActBabelTowerView:CreateSelectEffect()
	local ph_1 = self.ph_cell_list[self.current_index][1]
	local ph_2 = self.ph_cell_list[self.current_index][#self.ph_cell_list[self.current_index]]	
	self.select_effect = XUI.CreateImageViewScale9((ph_1.x + ph_2.x) / 2, (ph_1.y + ph_2.y) / 2, ph_2.x - ph_1.x + ph_1.w + 5, ph_1.h + 5, ResPath.GetCommon("img9_109"), true)
	self.node_t_list.layout_act_babel_tower.node:addChild(self.select_effect, 999)
end

function ActBabelTowerView:RefreshSelectEffect()
	local ph_2 = self.ph_cell_list[self.current_index][#self.ph_cell_list[self.current_index]]
	local ph_1 = self.ph_cell_list[self.current_index][1]
	self.select_effect:setPosition((ph_1.x + ph_2.x) / 2, (ph_1.y + ph_2.y) / 2)
	self.select_effect:setContentWH(ph_2.x - ph_1.x + ph_1.w + 5, ph_1.h + 5)
end

function ActBabelTowerView:RefreshNextLevel()
	for i,v in ipairs(self.obtain_img_list) do
		if i < self.current_index then
			v:loadTexture(ResPath.GetCommon("stamp_17"))
		else 
			v:loadTexture(ResPath.GetCommon("stamp_18"))
		end
	end
end 

function ActBabelTowerView:CreateTowerLevelNumber()
	local ph = self.ph_list.ph_tower_num
	self.tower_level_num = NumberBar.New()
	self.tower_level_num:SetRootPath(ResPath.GetCommon("num_214_"))
	self.tower_level_num:SetPosition(ph.x, ph.y)
	self.node_t_list.layout_act_babel_tower.node:addChild(self.tower_level_num:GetView(), 300, 300)
end

function ActBabelTowerView:CreateDrawRecord()
	if nil == self.draw_record_list then
		local ph = self.ph_list.ph_64_records_list
		self.draw_record_list = ListView.New()
		self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, DrawRecordRender, nil, nil, self.ph_list.ph_draw_record_item)
		self.draw_record_list:GetView():setAnchorPoint(0, 0)
		self.draw_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_act_babel_tower.node:addChild(self.draw_record_list:GetView(), 100)
	end		
end

function ActBabelTowerView:FlushDrawRecord()
	local draw_record = ActivityBrilliantData.Instance:GetDrawRecordList()
	self.draw_record_list:SetDataList(draw_record)
end




DrawRecordRender = DrawRecordRender or BaseClass(BaseRender)
function DrawRecordRender:__init()	
end

function DrawRecordRender:__delete()	
end

function DrawRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function DrawRecordRender:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.index)
	if nil == item_cfg then 
		return 
	end
	local  color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername == self.data.name then
		self.rolename_color = "CCCCCC"
	else
		self.rolename_color = "FFFF00"
	end
	local text = string.format(Language.ActivityBrilliant.ActRecordStr, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.ActivityBrilliant.Text11, color, item_cfg.name, self.data.index)
	RichTextUtil.ParseRichText(self.node_tree.rich_draw_attr.node, text, 18)
end

function DrawRecordRender:CreateSelectEffect()
end