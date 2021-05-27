XuYuanChiView = XuYuanChiView or BaseClass(ActBaseView)

function XuYuanChiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function XuYuanChiView:__delete()
	if nil ~= self.reward_57_cell_list then
    	for k,v in pairs(self.reward_57_cell_list) do
    		v:DeleteMe()
  		end
    	self.reward_57_cell_list = nil
    end

    if self.reward_57_cell then
    	self.reward_57_cell:DeleteMe()
    end
    self.reward_57_cell = nil

	if nil ~= self.activity_57_list then
		self.activity_57_list:DeleteMe()
		self.activity_57_list = nil
	end	

	self.box_effect = nil
end

function XuYuanChiView:InitView()
	self:CreateXuYuanChiList()
	self:CreateBoxSignCell()
	self.node_t_list.btn_uplevel_57.node:addClickEventListener(BindTool.Bind(self.OnClickXYCHandler, self))
	self.node_t_list.btn_57_lingqu.node:addClickEventListener(BindTool.Bind(self.OnClickXYCLingQuHandler, self))
	for i = 1, 4 do	
		self.node_t_list["btn_box_" .. i].node:addClickEventListener(BindTool.Bind(self.OnClickXYCBoxHandler, self, i))
	end
	self:OnClickXYCBoxHandler(1)
end

function XuYuanChiView:RefreshView(param_list)
	local level = ActivityBrilliantData.Instance:GetActivityGridLevel()
	self:FlushRewardCell(level, self.selecl_tag)
	self:FlushBoxSignCell(level)
	self.node_t_list.lbl_hope_num.node:setString(ActivityBrilliantData.Instance:GetRedHopeNum())
	self.node_t_list.img_level_text.node:loadTexture(ResPath.GetActivityBrilliant("act_56_text_" .. level))
	self.activity_57_list:SetDataList(ActivityBrilliantData.Instance:GetActivityGridData())
end

function XuYuanChiView:OnClickXYCBoxHandler(tag)
	local level = ActivityBrilliantData.Instance:GetActivityGridLevel()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XYC)
	self.node_t_list.lbl_get_reward_tip.node:setString(string.format(Language.ActivityBrilliant.XYCText1, cfg.config.pool[level][tag].count))
	self.selecl_tag = tag
	self:FlushBtnEnable(level)
	if nil == self.box_effect then
		self.box_effect = XUI.CreateImageView(63, 590, ResPath.GetCommon("img9_156"))
		self.box_effect:setScale(1.3)
		self.node_t_list.layout_xuyuanchi.node:addChild(self.box_effect, 30)
	else
		self.box_effect:setPosition(63 + 140 * (tag - 1), 590)
	end
end

function XuYuanChiView:OnClickXYCLingQuHandler()
	local level = ActivityBrilliantData.Instance:GetActivityGridLevel()
	local act_id = ACT_ID.XYC
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.selecl_tag, level)
end

function XuYuanChiView:OnClickXYCHandler()
	local act_id = ACT_ID.XYC
	local level = ActivityBrilliantData.Instance:GetActivityGridLevel()
   	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, level, 0)
end

function XuYuanChiView:CreateBoxSignCell()
	self.sign_img_list = {}
	for i = 1, 4 do
		local img = XUI.CreateImageView(45, 30, ResPath.GetCommon("stamp_1"))
		self.node_t_list["btn_box_" .. i].node:addChild(img, 300)
		table.insert(self.sign_img_list, img)
	end

	self.remind_img_list = {}
	for i = 1, 4 do
		local img = XUI.CreateImageView(60, 60, ResPath.GetMainui("remind_flag"), true)
		self.node_t_list["btn_box_" .. i].node:addChild(img, 999)
		table.insert(self.remind_img_list, img)
	end
end

function XuYuanChiView:FlushBtnEnable(level)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XYC)
	for i = 1, 4 do
		local is_lingqu = ActivityBrilliantData.Instance:GetSignByIndexXYC(i + (level - 1) * 4)
		local can_lingqu = ActivityBrilliantData.Instance:GetRedHopeNum() >= cfg.config.pool[level][i].count
		if self.selecl_tag == i then
			self.node_t_list.btn_57_lingqu.node:setEnabled(is_lingqu == 0 and can_lingqu)
		end
	end
end

function XuYuanChiView:FlushBoxSignCell(level)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XYC)
	for k,v in pairs(self.sign_img_list) do
		local is_lingqu = ActivityBrilliantData.Instance:GetSignByIndexXYC(k + (level - 1) * 4)
		v:setVisible(is_lingqu == 1)
	end

	for k,v in pairs(self.remind_img_list) do
		local is_lingqu = ActivityBrilliantData.Instance:GetSignByIndexXYC(k + (level - 1) * 4)
		local can_lingqu = ActivityBrilliantData.Instance:GetRedHopeNum() >= cfg.config.pool[level][k].count
		v:setVisible(is_lingqu == 0 and can_lingqu)
	end
	self:FlushBtnEnable(level)
end

function XuYuanChiView:FlushRewardCell(level, tag)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.XYC)
	if nil == self.reward_57_cell then
		self.reward_57_cell = ActBaseCell.New()
		local ph = self.ph_list.ph_up_cell
		self.reward_57_cell:SetPosition(ph.x, ph.y)
		self.reward_57_cell:SetIndex(i)
		self.reward_57_cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_xuyuanchi.node:addChild(self.reward_57_cell:GetView(), 300)
	end

	if nil == self.reward_57_cell_list then
		self.reward_57_cell_list = {}
		for i=1,4 do 
			local cell = ActBaseCell.New()
			local ph = self.ph_list["ph_57_reward_cell_"..i]
			cell:SetPosition(ph.x, ph.y)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_xuyuanchi.node:addChild(cell:GetView(), 300)
			table.insert(self.reward_57_cell_list, cell)
		end
	end

	local data_1 = cfg.config.uppoolaward[level].award[1]
	self.reward_57_cell:SetData({item_id = data_1.id, num = data_1.count, is_bind = data_1.bind, effectId = data_1.effectId})

	local data_2 =  cfg.config.pool[level][tag].award
	for k,v in pairs(self.reward_57_cell_list) do
		local item_data = {}
		if nil ~= data_2[k] then
			item_data.item_id = data_2[k].id
			item_data.num = data_2[k].count
			item_data.is_bind = data_2[k].bind
			item_data.effectId = data_2[k].effectId
			v:SetData(item_data)
		else
			v:SetData(nil)
		end
		v:SetVisible(data_2[k] ~= nil)
	end

	for i = 1, 4 do
		self.node_t_list["lbl_red_num_" .. i].node:setString(string.format(Language.ActivityBrilliant.XYCText2, cfg.config.pool[level][i].count))
	end
end

function XuYuanChiView:CreateXuYuanChiList()
	local ph = self.ph_list.ph_active_list
	self.activity_57_list = ListView.New()
	self.activity_57_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ActXuYuanChiRender, nil, nil, self.ph_list.ph_active_list_render)
	self.activity_57_list:SetItemsInterval(6)
	self.activity_57_list:GetView():setAnchorPoint(0.5, 0.5)
	self.activity_57_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_xuyuanchi.node:addChild(self.activity_57_list:GetView(), 300)
end
------------------------------------------
-- ActXuYuanChiRender
------------------------------------------
ActXuYuanChiRender = ActXuYuanChiRender or BaseClass(BaseRender)
function ActXuYuanChiRender:__init()
	
end

function ActXuYuanChiRender:__delete()
	
end

function ActXuYuanChiRender:CreateChild()
	BaseRender.CreateChild(self)

	self.node_tree.btn_opt.node:addClickEventListener(BindTool.Bind(self.OnClickOpenBtn, self))
end

function ActXuYuanChiRender:OnFlush()
	if self.data == nil then return end

	self.node_tree.lbl_name.node:setString(self.data.title or "")

	local limit_time = self.data.limitTimes or 0
	local time = self.data.finish_num
	local lblColor = COLOR3B.WHITE
	if time >= limit_time then
	lblColor = COLOR3B.GRAY
	self.node_tree.btn_opt.node:setVisible(false)
	end
	self.node_tree.lbl_times.node:setString(string.format("%d/%d", time, limit_time))

	self.node_tree.lbl_degree.node:setString(self.data.score or "")
	self:SetTextColor(lblColor)
	self:SetBtnTitleText()
end

function ActXuYuanChiRender:SetTextColor(color)
	self.node_tree.lbl_name.node:setColor(color)
	self.node_tree.lbl_times.node:setColor(color)
	self.node_tree.lbl_degree.node:setColor(color)
	self.node_tree.btn_opt.node:setTitleColor(color)
end

function ActXuYuanChiRender:SetBtnTitleText()
	if self.data == nil or self.data.open_type == nil then return end
	local str = Language.ActiveDegree.ActivityBtnText[self.data.open_type + 1] or ""
	self.node_tree.btn_opt.node:setTitleText(str)
end

function ActXuYuanChiRender:CreateSelectEffect()
	
end

function ActXuYuanChiRender:OnClickOpenBtn()
	if self.data == nil or self.data.open_type == nil or self.data.open_tag == nil then return end
	
	if self.data.open_type == 0 then
		if type(self.data.open_tag) ~= "string" then return end
		local tag_t = Split(self.data.open_tag, "#")
		if tag_t[1] and ViewDef[tag_t[1]] then
			if ViewDef[tag_t[1]] == "Guild" then
				local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
				local is_join_guild = guild_id > 0
				if not is_join_guild then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
					return
				end
			end
			ViewManager.Instance:OpenViewByDef(ViewDef[tag_t[1]], tag_t[2] and TabIndex[tag_t[2]] or nil)
			-- ActivityBrilliantCtrl.Instance:CloseMyView()
			ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
		end
	else
		if type(self.data.open_tag) ~= "number" then return end
		-- ActivityBrilliantCtrl.Instance:CloseMyView()
		ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
		local id = ActivityBrilliantData.Instance:GetNpcQuicklyTransportId(self.data.open_tag)
		if nil == id then return end
		Scene.SendQuicklyTransportReq(id)
	end
end

