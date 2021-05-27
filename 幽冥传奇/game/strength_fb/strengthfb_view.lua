
StrenfthFbView = StrenfthFbView or BaseClass(XuiBaseView)

StrenfthFbView.ChestGridCol = 5

function StrenfthFbView:__init()
	self:SetModal(true)
	self.def_index = 1
	--self.is_async_load = false
	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/boss.png"
	self.title_img_path = ResPath.GetStrenfthFb("bg_title")
	self.cur_index = -1
	self.config_tab = {	
		{"common_ui_cfg", 1, {0}},
		{"strengthfb_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	
	self.is_long_click = false
end

function StrenfthFbView:__delete()

end

function StrenfthFbView:ReleaseCallBack()
	if self.chest_grid ~= nil then
		self.chest_grid:DeleteMe()
		self.chest_grid = nil
	end

	if self.chest_effec then
		for k,v in pairs(self.chest_effec) do
			v:setStop()
		end
		self.chest_effec = {}
	end

	if self.delay_flush_time ~= nil  then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil
	end

	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
end

function StrenfthFbView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_left.node:setLocalZOrder(998)
		self.node_t_list.btn_right.node:setLocalZOrder(998)
		XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind1(self.OnSwitchChapterLeft, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind1(self.OnSwitchChapterRihght, self), true)
		--self.node_t_list.btn_left.node:addClickEventListener(BindTool.Bind(self.OnSwitchChapter, self, -1))
		--self.node_t_list.btn_right.node:addClickEventListener(BindTool.Bind(self.OnSwitchChapter, self, 1))
		self.node_t_list.btn_buy_energy.node:addClickEventListener(BindTool.Bind(self.OnTransmit, self))
		self.node_t_list.btn_buy_sweep.node:addClickEventListener(BindTool.Bind(self.OnTransmitShop, self))
		self:SetBtnTouch()
		self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback,self)			--监听物品数据变化
		ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
		self:CreateChestGrid()
		self:SetShowPlayEff()
	end
end

function StrenfthFbView:SetBtnTouch()
	self.chest_pos = {}
	for i = 1, 4 do
		self.node_t_list["btn_chest_"..i].node:setLocalZOrder(998)
		self.node_t_list["btn_chest_"..i].node:setTouchEnabled(true)
		self.node_t_list["btn_chest_"..i].node:setIsHittedScale(false)
		self.node_t_list["btn_chest_"..i].node:addTouchEventListener(BindTool.Bind(self.OnTouchLayout, self, i))
		local x, y = self.node_t_list["btn_chest_"..i].node:getPosition()
		self.chest_pos[i] = {x = x, y = y}
	end
end

function StrenfthFbView:CreateChestGrid()
	if self.chest_grid == nil then
		local ph = self.ph_list.ph_chest_grid
		self.chest_grid = BaseGrid.New()
		local grid_node = self.chest_grid:CreateCells({w = ph.w, h = ph.h, cell_count = 6, col = 6, row = 1, direction = ScrollDir.Horizontal, itemRender = StrenfthFbChestRender, ui_config = self.ph_list.ph_item_1})
		grid_node:setPosition(ph.x, ph.y)
		grid_node:setAnchorPoint(0, 0)
		self.node_t_list.layout_strengthfb.node:addChild(grid_node, 100)
	end
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local consume_level = StrenfthFbData:GetConsumeLevel(StrenfthFbData.Instance:GetClearCurPage())
	if self.cur_index == -1 then
		self.cur_index = StrenfthFbData.Instance:GetClearCurPage() == 1 and 1  or level >= consume_level and StrenfthFbData.Instance:GetClearCurPage() or StrenfthFbData.Instance:GetClearCurPage() -1 
	end
	StrenfthFbCtrl.Instance:SendFubenData(self.cur_index)
	self.chest_grid:SetSelectCallBack(BindTool.Bind(self.SelectChestCallBack, self))
	self.chest_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self:BoolVisibleBtn()
end

function StrenfthFbView:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index
	self:BoolVisibleBtn()
end

function StrenfthFbView:BoolVisibleBtn()
	self.node_t_list.btn_left.node:setVisible(self.cur_index ~= 1)
	self.node_t_list.btn_right.node:setVisible(self.cur_index ~= STRENFTHFB_MAX_GRADE)
end

function StrenfthFbView:OnTransmit()
	ViewManager.Instance:Open(ViewName.Shop, 2)
end

function StrenfthFbView:OnTransmitShop()
	ViewManager.Instance:Open(ViewName.Shop, 1)
end

function StrenfthFbView:SelectChestCallBack(cell)

end

function StrenfthFbView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function StrenfthFbView:OpenCallBack()
	--self:AddMoveAutoClose()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function StrenfthFbView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function StrenfthFbView:ItemDataChangeCallback()
	self:FlushData()
end

function StrenfthFbView:FlushData()
	local item_id = StrenfthFbData.Instance:ReturnId()
	local num = ItemData.Instance:GetItemNumInBagById(item_id, nil)
	self.node_t_list.lbl_energy.node:setString(num)
	local id = AllDayCfg[1] and AllDayCfg[1].Checkpoint[1].sweepconsume[1].id
	local num_2 = ItemData.Instance:GetItemNumInBagById(id, nil)
	self.node_t_list.lbl_sweep.node:setString(num_2)
end

function StrenfthFbView:OnFlush(param_t, index)
	if index == 0 then
		index = self:GetShowIndex()
	end
	local total_data = StrenfthFbData.Instance:GetTotalData()
	local data = total_data[self.cur_index] and total_data[self.cur_index] or {}
	local cur_data = {}
	for i,v in ipairs(data) do
		cur_data[i-1] = v 
	end
	self.chest_grid:SetDataList(cur_data)
	self.node_t_list.img_jpg_bg.node:loadTexture(ResPath.GetBigPainting("strength_fb_bg_"..self.cur_index, true))
	local star = StrenfthFbData.Instance:GetAllStarNum()
	self.node_t_list.lbl_star_num.node:setString(star.."/"..18)
	self.node_t_list.prog9_reward.node:setPercent(star/18*100)
	self:BoolVisibleBtn()
	self:FlushData()
	self:FlushView()
end

function StrenfthFbView:OnTouchLayout(btn_type, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self.is_long_click = false
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
		self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(function ()
			self.is_long_click = true
			StrenfthFbCtrl.Instance:OpenShowRewardView(self.cur_index, btn_type)
		end,0.2)
	elseif event_type == XuiTouchEventType.Moved then
	elseif event_type == XuiTouchEventType.Ended then
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
		if self.is_long_click then
			StrenfthFbCtrl.Instance:CloseTip()
		else
			StrenfthFbCtrl.Instance:GetFubenStarReWard(self.cur_index, btn_type)
		end	
	else	
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end

		if self.is_long_click then
			StrenfthFbCtrl.Instance:CloseTip()
		end	
	end	
end

function StrenfthFbView:OnGetReward(btn_type)
	StrenfthFbCtrl.Instance:GetFubenStarReWard(self.cur_index, btn_type)
end

function StrenfthFbView:OnSwitchChapterLeft( ... )
	self:OnSwitchChapter(-1)
end

function StrenfthFbView:OnSwitchChapterRihght()
	self:OnSwitchChapter(1)
end
-- 切换章节
function StrenfthFbView:OnSwitchChapter(num)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circel_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local try_to_index = self.cur_index + num
	if try_to_index >= 1 and try_to_index <= STRENFTHFB_MAX_GRADE then
		local consume_level, consume_circle = StrenfthFbData.Instance:GetConsumeLevel(try_to_index)
		if num == 1 and level >= consume_level and circel_level >= consume_circle then
			StrenfthFbCtrl.Instance:SendFubenData(try_to_index)
			self.cur_index = try_to_index 
			self.chest_grid:ChangeToPage(self.cur_index)
		elseif num == -1 then
			StrenfthFbCtrl.Instance:SendFubenData(try_to_index)
			self.cur_index = try_to_index 
			self.chest_grid:ChangeToPage(self.cur_index)
		else
			if consume_circle == 0 then
				SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.StrenfthFb.NotBuZou1, consume_level))
			else
				SysMsgCtrl.Instance:FloatingTopRightText(string.format(Language.StrenfthFb.NotBuZou2, consume_circle, consume_level))
			end
		end
	end
	self:BoolVisibleBtn()
	self:FlushView()
end

function StrenfthFbView:FlushView()
	local page = StrenfthFbData.Instance:GetCurPage()
	local stage = StrenfthFbData.Instance:GetGiftState()
	local data = StrenfthFbData.Instance:GetBoolShowEffect(self.cur_index)
	if page == self.cur_index then
		for i, v in ipairs(stage) do
			if self.node_t_list["btn_chest_" .. i] then
				local path =(v.state == 1 and ResPath.GetStrenfthFb("chest_get_"..i) or ResPath.GetStrenfthFb("chest_"..i))
				self.node_t_list["btn_chest_"..i].node:loadTextures(path)
				if v.state == 0 and data[i] == 1 then
					local anim_path, anim_name = ResPath.GetEffectUiAnimPath(29)
					self.chest_effec[i]:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
				else
					self.chest_effec[i]:setStop()
				end
			end
		end
	end
	self.node_t_list.img_page.node:loadTexture(ResPath.GetStrenfthFb("page_"..self.cur_index))
end

--展示特效
function StrenfthFbView:SetShowPlayEff()
	self.chest_effec = {}
	for i = 1, 4 do
		local play_eff = AnimateSprite:create()
		play_eff:setPosition(self.chest_pos[i].x, self.chest_pos[i].y)
		self.node_t_list.layout_strengthfb.node:addChild(play_eff, 999)
		self.chest_effec[i] = play_eff
	end
end

--------------------------------------
-- StrenfthFbChestRender
--------------------------------------
local item_pos_list = {
	{
		[0] = {100, 10}, [1] = {90, 240}, [2] = {220, 240}, [3] = {365, 220}, [4] = {80, 30}, [5] = {-360, 30},
	},
	{
		[0] = {165, 240}, [1] = {160, 40}, [2] = {280, -35}, [3] = {385, 5}, [4] = {120, 200}, [5] = {-290, 240},
	},
	{
		[0] = {165, 240}, [1] = {140, 40}, [2] = {270, 40}, [3] = {385, 20}, [4] = {120, 220}, [5] = {-320, 240},
	},
}

StrenfthFbChestRender = StrenfthFbChestRender or BaseClass(BaseRender)
function StrenfthFbChestRender:__init()
	self.star_list = {}
	self:SetShowPagePlayEff()
end

function StrenfthFbChestRender:__delete()
	if self.play_effect then
		self.play_effect:setStop()
		self.play_effect = nil 
	end
end

function StrenfthFbChestRender:CreateChild()
	BaseRender.CreateChild(self)
	self.star_list = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_star_"..i]
		local file = ResPath.GetCommon("star_0_lock")	
		local bg = XUI.CreateImageView(ph.x+10 , ph.y+10 , file)
		self.node_tree.layout_checkpoint.node:addChild(bg, 990)
		table.insert(self.star_list, bg)
	end

	XUI.AddClickEventListener(self.node_tree.layout_checkpoint.img_stage_bg.node, BindTool.Bind2(self.OnEnterFuben, self, self.index))
end

function StrenfthFbChestRender:OnEnterFuben(index)
	local page = self.data.page
	local n = (index+1)%6 == 0 and 6 or (index+1)%6
	if (self.data.my_time - self.data.time) > 0 then
		StrenfthFbCtrl.Instance:OpenView(page, n, self.data)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.StrenfthFb.NotBuZou)
	end
end

function StrenfthFbChestRender:OnFlush()
	if self.data == nil then return end
	local n = self.index%6
	local pos_t = item_pos_list[self.data.page]
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) --人物等级
	self.node_tree.layout_checkpoint.node:setPosition(pos_t[n][1],pos_t[n][2])
	HtmlTextUtil.SetString(self.node_tree.layout_checkpoint.rich_name.node, self.data.name)
	XUI.RichTextSetCenter(self.node_tree.layout_checkpoint.rich_name.node)
	self:LightStar(self.data.stars)
	self:BoolClearGuanKa(self.data.stars)
	if role_level >= self.data.limit_level then
		self.node_tree.layout_checkpoint.txt_time.node:setString(Language.StrenfthFb.ChestFightTime..(self.data.time.."/"..self.data.my_time))
		self.node_tree.layout_checkpoint.txt_time.node:setColor(COLOR3B.YELLOW)
	else
		self.node_tree.layout_checkpoint.txt_time.node:setString(string.format(Language.StrenfthFb.Limit_level, self.data.limit_level))
		self.node_tree.layout_checkpoint.txt_time.node:setColor(COLOR3B.RED)
	end
	self.node_tree.layout_checkpoint.img_bg_2.node:loadTexture(ResPath.GetStrenfthFb("img_"..self.data.icon))
	if self.data.monster ~= nil then
		local cfg = BossData.GetMosterCfg(self.data.monster)
		if cfg == nil then
			return 
		end
		local monster_id = cfg.icon
		local path = ResPath.GetBossHead("boss_icon_"..monster_id)
		self.node_tree.layout_checkpoint.img_stage_bg.node:loadTexture(path)
		self.node_tree.layout_checkpoint.img_bg_3.node:setVisible(true)
		self.node_tree.layout_checkpoint.rich_name.node:setPositionY(45)
		self.node_tree.layout_checkpoint.txt_time.node:setPositionY(20)
		if self.data.stars > 0 then
			self.node_tree.layout_checkpoint.img_stage_bg.node:setGrey(false)
		else
			self.node_tree.layout_checkpoint.img_stage_bg.node:setGrey(true)
		end
	else
		self.node_tree.layout_checkpoint.rich_name.node:setPositionY(70)
		self.node_tree.layout_checkpoint.txt_time.node:setPositionY(45)
		self.node_tree.layout_checkpoint.img_bg_3.node:setVisible(false)
	end
	local bool = StrenfthFbData.Instance:GetShowEffect(self.data.page)
	local index = StrenfthFbData.Instance:GetClearanceIndex(self.data.page)
	if bool == true then
		if index ~= nil and index - 1 == self.index then
			local pos_t = item_pos_list[self.data.page]
			self.play_effect:setPosition(pos_t[index -1][1] - 20, pos_t[index-1][2]+10)
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(29)
			self.play_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.play_effect:setVisible(true)
		else
			self.play_effect:setVisible(false)
		end
	else
		self.play_effect:setVisible(false)
	end
end

function StrenfthFbChestRender:LightStar(star)
	for i, v in ipairs(self.star_list) do
		if star >= i then
			v:loadTexture(ResPath.GetCommon("star_0_select"))
		else
			v:loadTexture(ResPath.GetCommon("star_0_lock"))
		end
	end
end

function StrenfthFbChestRender:BoolClearGuanKa(stars)
	local path = stars > 0 and ResPath.GetStrenfthFb("easy_stage_can") or ResPath.GetStrenfthFb("easy_stage_no")
	self.node_tree.layout_checkpoint.img_stage_bg.node:loadTexture(path)
end

function StrenfthFbChestRender:CreateSelectEffect()
	
end

function StrenfthFbChestRender:SetShowPagePlayEff()
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view:addChild(self.play_effect, 999)
	end
end