MagicCityView = MagicCityView or BaseClass(XuiBaseView)

function MagicCityView:__init()
	self.texture_path_list[1] = 'res/xui/strength_fb.png'
	self.texture_path_list[2] = 'res/xui/boss.png'
	self.texture_path_list[3] = 'res/xui/magiccity.png'
	self.texture_path_list[4] = 'res/xui/limit_activity.png'
	-- self.title_img_path = ResPath.GetRole("btn_juese_txt")
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"magic_city_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
	self.cur_index = 1
	self.list_grid = nil 
end

function MagicCityView:__delete()
end

function MagicCityView:ReleaseCallBack()
	if self.list_grid ~= nil then
		self.list_grid:DeleteMe()
		self.list_grid = nil
	end
end

function MagicCityView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateGrid()
		self.node_t_list.btn_open_view.node:addClickEventListener(BindTool.Bind(self.OnOpenView, self))
		self.node_t_list.txt_view_name.node:setString("")
		RichTextUtil.ParseRichText(self.node_t_list.rich_content.node, Language.MagicCity.Desc, 18, COLOR3B.WHITE)
		XUI.SetRichTextVerticalSpace(self.node_t_list.rich_content.node,5)
		
		local effect = RenderUnit.CreateEffect(10, self.node_t_list.btn_open_view.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		if effect then
			effect:setScaleX(0.58)
			effect:setScaleY(0.9)
		end
	end
end

function MagicCityView:OpenCallBack()
	MagicCityCtrl.Instance:SendReqAllOwnerData()
	if #MagicCityCfg.cities == 1 then
		MagicCityCtrl.Instance:SendSingleCheaperData(1)
	elseif #MagicCityCfg.cities > 1 then
		for i = 1, #MagicCityCfg.cities do
			MagicCityCtrl.Instance:SendSingleCheaperData(i)
		end
	end
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MagicCityView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MagicCityView:CreateGrid()
	if self.list_grid == nil then
		local ph = self.ph_list.ph_grid_list
		self.list_grid = ListView.New()
		self.list_grid:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, MagicCityRender, nil, nil, self.ph_list.ph_grid_item)
		self.list_grid:GetView():setAnchorPoint(0, 0)
		self.list_grid:SetMargin(2)
		self.list_grid:SetItemsInterval(5)
		self.list_grid:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_magic_city.node:addChild(self.list_grid:GetView(), 100)
	end
end

function MagicCityView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MagicCityView:OnFlush(param_t, index)
	self:BoolVisibleBtn()
	local data = MagicCityData.Instance:GetMagicData()
	self.list_grid:SetDataList(data)
end

function MagicCityView:OnSwitchChapter(num)
	self:BoolVisibleBtn()
end

function MagicCityView:BoolVisibleBtn()

end

function MagicCityView:OnOpenView()
	ViewManager.Instance:Open(ViewName.MagicCityRankingList)
end

MagicCityRender = MagicCityRender or BaseClass(BaseRender)
function MagicCityRender:__init()
	self:SetShowMagicPlayEff()
end

function MagicCityRender:__delete()
	for k,v in pairs(self.reward_cells) do
		v:DeleteMe()
	end
	self.reward_cells =  {}

	if self.magic_effect then
		self.magic_effect:setStop()
		self.magic_effect = nil 
	end
end

function MagicCityRender:CreateChild()
	BaseRender.CreateChild(self)
 	local ph = self.ph_list.ph_cell
 	self.reward_cells = {}
 	for i = 1, 3 do
 		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 90*(i - 1), ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(cell:GetView(), 103)
		table.insert(self.reward_cells, cell)
 	end
 	self.stars = {}
 	for i = 1, 3 do
		local ph = self.ph_list["ph_star_"..i]
		local file = ResPath.GetCommon("star_0_lock")	
		local bg = XUI.CreateImageView(ph.x+10 , ph.y+10 , file)
		self.view:addChild(bg, 990)
		table.insert(self.stars, bg)
	end

 	XUI.AddClickEventListener(self.node_tree.btn_enter.node, BindTool.Bind1(self.OpenTips, self), true)
end

function MagicCityRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_guanka_name.node:setString(self.data.fuben_name)
	self.node_tree.img_jpg_bg.node:loadTexture(ResPath.GetBigPainting("magic_city_bg"..self.index, true))
	self.node_tree.txt_desc.node:setString(self.data.time <= 0 and string.format(Language.MagicCity.QuicklyTime, Language.MagicCity.ZhanWu) or string.format(Language.MagicCity.QuicklyTime, TimeUtil.FormatSecond(self.data.time, 2)))
	self.node_tree.txt_name.node:setString(self.data.owner_name == "" and string.format(Language.MagicCity.OwnerDesc, Language.MagicCity.ZhanWu) or string.format(Language.MagicCity.OwnerDesc, self.data.owner_name))
	self:LightStar(self.data.star)
	self:BoolClearGuanKaSuccess(self.data.star)
	self:SetLevelShow(self.data.level_limit)
	self:BoolShowEffect(self.index)
	local owner_data = self.data.owner_reward
	for k,v in pairs(self.reward_cells) do
		v:GetView():setVisible(false)
	end
	for k, v in pairs(self.reward_cells) do
		if #owner_data >= k then
			v:GetView():setVisible(true)
		end
	end
	for k, v in pairs(owner_data) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				self.reward_cells[k]:SetData({["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0})
			end
		else
			self.reward_cells[k]:SetData({item_id = v.id, ["num"] = v.count, is_bind = 0})
		end
	end
end

function MagicCityRender:SetLevelShow(level_limit)
	local data = level_limit 
	local txt = ""
	if data[1] == 0 then
		txt = string.format(Language.MagicCity.Level_limit_1,data[2] or 60)
	else
		txt = string.format(Language.MagicCity.Level_limit_2,data[1] or 1)
	end
	self.node_tree.txt_level.node:setString(txt)
end

function MagicCityRender:OpenTips()
	local open_day = OtherData.Instance:GetOpenServerDays()
	if open_day < self.data.openday then
		local txt = string.format(Language.MagicCity.Open_Days, self.data.openday)
		SysMsgCtrl.Instance:FloatingTopRightText(txt)
	else
		if MagicCityData.Instance:CanEnterFuben(self.index) == true then 
			MagicCityCtrl.Instance:OpenTips(self.data)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.MagicCity.Tips_desc)
		end
	end
end

function MagicCityRender:LightStar(star)
	star = star or 0
	for i, v in ipairs(self.stars) do
		if star >= i then
			v:loadTexture(ResPath.GetCommon("star_0_select"))
		else
			v:loadTexture(ResPath.GetCommon("star_0_lock"))
		end
	end
end

function MagicCityRender:BoolClearGuanKaSuccess(star)
	star = star or 0
	local path = star > 0 and ResPath.GetStrenfthFb("easy_stage_can") or ResPath.GetStrenfthFb("easy_stage_no")
	self.node_tree.btn_enter.node:loadTexture(path)
end

function MagicCityRender:CreateSelectEffect()
	-- body
end

function MagicCityRender:BoolShowEffect(index)
	local bool = MagicCityData.Instance:ShowEffect(index)
	if bool == true then
		self.magic_effect:setPosition(150, 325)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(29)
		self.magic_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.magic_effect:setVisible(true)
	else
		self.magic_effect:setVisible(false)
	end
end

function MagicCityRender:SetShowMagicPlayEff()
	if self.magic_effect == nil then
		self.magic_effect = AnimateSprite:create()
		self.view:addChild(self.magic_effect, 999)
	end
end
