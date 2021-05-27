-- 登录奖励
WelfareLoginRewardView = BaseClass(BaseView)

function WelfareLoginRewardView:__init()
	self.title_img_path = ResPath.GetWord("word_login_reward")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/login_reward.png',
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"welfare_ui_cfg", 4, {0}},
		{"common_ui_cfg", 2, {0}},
	}
end


function WelfareLoginRewardView:ReleaseCallBack()
	self:DeleteLoginView()
end

function WelfareLoginRewardView:LoadCallBack(index, loaded_times)
	XUI.AddRemingTip(self.node_t_list["btn_get_award"].node)
	self:InitRewardList()
	self:InitShowReward()
	
	self:SetDayNumber(LoginRewardData.Instance:GetAddLoginTimes())
	
	if not self.getindex or self.getindex < 1 or self.getindex > #SevenDayAwardCfg then
		self.getindex = 1
	end
	self:SetRewardCellData(self.getindex)
	self:ShowBigReward(self.getindex)
	self:OnFlushBtnState(self.getindex)

	LoginRewardData.Instance:SetHaveRewardCanGetFlag()
	
	XUI.AddClickEventListener(self.node_t_list.btn_get_award.node, BindTool.Bind(self.MyOnClickReceive, self))
	EventProxy.New(LoginRewardData.Instance, self):AddEventListener(LoginRewardData.CHANGE_VIEW_DATA, BindTool.Bind(self.ChangeView, self))
end

function WelfareLoginRewardView:ChangeView()
	self:SetDayNumber(LoginRewardData.Instance:GetAddLoginTimes())
	self:SetRewardListData()
	self:InitShowReward()
	self:OnFlushBtnState()
	LoginRewardData.Instance:SetHaveRewardCanGetFlag()
end

function WelfareLoginRewardView:OpenCallBack()
end

function WelfareLoginRewardView:ShowIndexCallBack(index)
end

function WelfareLoginRewardView:OnFlush(param_t, index)
end



function WelfareLoginRewardView:DeleteLoginView()
	if self.reward_list then
		self.reward_list:DeleteMe()
		self.reward_list = nil
	end
	
	if self.login_day_number then
		self.login_day_number:DeleteMe()
		self.login_day_number = nil
	end
	if self.reward_list_scroll then
		self.reward_list_scroll:DeleteMe()
		self.reward_list_scroll = nil
	end
	-- self.stage_effect = nil
	-- self.big_pic_list = {}
	if self.reward_cell_list ~= nil then 
		for k, v in pairs(self.reward_cell_list) do
			v:DeleteMe()
		end
		self.reward_cell_list = {}
	end
end

function WelfareLoginRewardView:OnFlushLoginRewardView(param_t,index)
	self:InitShowReward()
	self:LoginOnFlush(param_t,index)
	--AudioManager.Instance:PlayOpenCloseUiEffect()
end

function WelfareLoginRewardView:InitRewardList()
	local ph = self.ph_list.ph_list
	local ph_item = self.ph_list.ph_day_reward_start
	self.reward_list = GridScroll.New()
	self.reward_list:Create(ph.x+3, ph.y, ph.w, ph.h, 1, ph_item.w + 15, LoginRewardRender, ScrollDir.Horizontal, false, ph_item)
	self.reward_list:SetSelectCallBack(BindTool.Bind(self.SelectRewardIndex, self))
	self.node_t_list.layout_login_reward.node:addChild(self.reward_list:GetView(), 99)

	local left_btn = self.node_t_list["btn_left"].node
	local right_btn = self.node_t_list["btn_right"].node
	local scrollview = self.reward_list:GetView()
	local view_rect_num, total_num, move_num_once = 6, 7, 6
	self.reward_list_scroll = ScrollView.New()
	self.reward_list_scroll:SetScrollView(scrollview, left_btn, right_btn, view_rect_num, total_num, move_num_once)
	self:SetRewardListData()
end

function WelfareLoginRewardView:SetRewardListData()
	local data = {}
	for i = 1, #SevenDayAwardCfg do
		table.insert(data, {index = i})
	end

	self.reward_list:SetDataList(data)
end

function WelfareLoginRewardView:InitShowReward()
	local max_num = #SevenDayAwardCfg
	local day = LoginRewardData.Instance:GetAddLoginTimes()
	local can_get_index = LoginRewardData.Instance:GetLoginRewardCanGetIndex()
	if nil ~= self.reward_list then
		local index = can_get_index or (day + 1 > max_num and max_num or day + 1)
		self.reward_list:SelectItemByIndex(index)
	end
end

function WelfareLoginRewardView:SetDayNumber(num)
	if self.login_day_number == nil then
		self.login_day_number = NumberBar.New()
		self.login_day_number:SetRootPath(ResPath.GetLoginReward("num_112_"))
		local ph = self.ph_list["ph_login_day"]
		
		self.login_day_number:SetPosition(ph.x, ph.y)
		self.login_day_number:SetSpace(-2)
		self.node_t_list.layout_login_reward.node:addChild(self.login_day_number:GetView(), 900)
	end
	self.login_day_number:SetNumber(num)
end

function WelfareLoginRewardView:MyOnClickReceive()
	WelfareCtrl.GetSevenDaysLoadingRewardsReq(self:MyGetShowIndex())
end

function WelfareLoginRewardView:MyGetShowIndex()
	return self.getindex
end

function WelfareLoginRewardView:SelectRewardIndex(render)
	if nil == render then
		return
	end
	self.getindex = render:GetData().index
	self:ChangeViewData()
	self:SetDayNumber(self.getindex)
	--self:ChangeToIndex(index)
end

function WelfareLoginRewardView:ChangeViewData()
	self:SetRewardCellData(self.getindex)
	self:ShowBigReward(self.getindex)
	self:OnFlushBtnState(self.getindex)
end

function WelfareLoginRewardView:SetRewardCellData(index)
	self.reward_cell_list = self.reward_cell_list or {}
	local reward_data = LoginRewardData.Instance:GetLoginRewardData(index)
	if reward_data then
		for i,v in ipairs(reward_data) do
			if nil == self.reward_cell_list[i] then
				local ph_cell = self.ph_list["ph_cell_" .. i]
				if ph_cell then
					local cell = BaseCell.New()
					cell:GetView():setAnchorPoint(0.5, 0.5)
					cell:SetPosition(ph_cell.x, ph_cell.y)
					cell:SetData(v)
					self.node_t_list.layout_login_reward.node:addChild(cell:GetView(), 20)
					self.reward_cell_list[i] = cell

					local cell_effect = AnimateSprite:create()
					cell_effect:setPosition(ph_cell.w / 2, ph_cell.h / 2)
					cell:GetView():addChild(cell_effect, 300)
					cell_effect:setVisible(false)
					cell.cell_effect = cell_effect

					if v.sp_effect_id and v.sp_effect_id > 0 then
						local path, name = ResPath.GetEffectUiAnimPath(v.sp_effect_id)
						if path and name then
							cell.cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.23, false)
							cell.cell_effect:setVisible(true)
						end
					end
				end
			else
				self.reward_cell_list[i]:SetData(v)
				

				if v.sp_effect_id and v.sp_effect_id > 0 then
					local path, name = ResPath.GetEffectUiAnimPath(v.sp_effect_id)
					if path and name and self.reward_cell_list[i].cell_effect then
						self.reward_cell_list[i].cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
						self.reward_cell_list[i].cell_effect:setVisible(true)
					end
				else
					if self.reward_cell_list[i].cell_effect then
						self.reward_cell_list[i].cell_effect:setVisible(false)
					end
				end

			end
		end

		local reward_flag = LoginRewardData.Instance:GetLoginRewardFlag(index)
		self.node_t_list["btn_get_award"].node:UpdateReimd(reward_flag == 1)
	end
end

-- local login_reward_eff = {
-- 	[1] = 26,
-- 	[2] = 27,
-- 	[3] = 28,
-- 	[4] = 29,
-- 	[5] = 30,
-- 	[6] = 31,
-- 	[7] = 213,
-- 	[8] = 432,
-- 	[9] = 431,
-- 	[10] = 434,
-- 	[11] = 418,
-- 	[12] = 420,
-- 	[13] = 422,
-- 	[14] = 424,
-- 	[15] = 336,
-- }

function WelfareLoginRewardView:ShowBigReward(index)
	-- self.big_pic_list = self.big_pic_list or {}
 --    if self.big_pic_list[index] == nil then
	-- 	self.big_pic_list[index] = {}
	-- 	local ph_word = self.ph_list.ph_big_text
 --        local ph_pic = self.ph_list.ph_big_reward
 --        local word = XUI.CreateImageView(ph_word.x, ph_word.y, ResPath.GetLoginReward("word_big_" .. index), true)
 --        local anim_path, anim_name = ResPath.GetEffectUiAnimPath(login_reward_eff[index] or 415)
 --        local pic = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.10, false)
 
	-- 	pic:setPosition(ph_pic.x, ph_pic.y)
	-- 	self.node_t_list.layout_login_reward.node:addChild(word, 150)
 --        self.node_t_list.layout_login_reward.node:addChild(pic, 150)
		
	-- 	self.big_pic_list[index].word = word
	-- 	self.big_pic_list[index].pic = pic
	-- end
	-- for k,v in pairs(self.big_pic_list) do
	-- 	local visible = k == index
	-- 	if v.word then
	-- 		v.word:setVisible(visible)
	-- 	end
	-- 	if v.word then
	-- 		v.pic:setVisible(visible)
	-- 	end
	-- end
end

function WelfareLoginRewardView:OnFlushBtnState(index)
	if not index or index < 1 or index > #SevenDayAwardCfg then
		index = self:MyGetShowIndex()
	end
	self.node_t_list.btn_get_award.node:setEnabled(LoginRewardData.Instance:GetLoginRewardFlag(index) ~= 2)
end
----------------------------------------------------
-- LoginRewardRender
----------------------------------------------------
LoginRewardRender = LoginRewardRender or BaseClass(BaseRender)
function LoginRewardRender:__init()
	self.is_select = false
end

function LoginRewardRender:__delete()
	self.reward_item = nil
end

function LoginRewardRender:CreateChild()
	BaseRender.CreateChild(self)

	local x, y = 62, 84
	self.reward_item = XUI.CreateImageView(x, y, ResPath.GetLoginReward("login_normal_" .. self.data.index), true)
	self.view:addChild(self.reward_item, 10)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.img_stamp.node:setLocalZOrder(11)
	self:AddClickEventListener(self.click_callback)
	-- self.node_tree.img_reward_name.node:setLocalZOrder(99)

	XUI.AddRemingTip(self.view, nil, nil, 95, 115)
end

function LoginRewardRender:CreateSelectEffect()
	self.select_effect = XUI.CreateImageView(62, 84, ResPath.GetLoginReward("reward_select_bg"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 98)
end

function LoginRewardRender:OnFlush(param_t, index)
	local index = self.data.index
	self.node_tree.img_day_word.node:loadTexture(ResPath.GetLoginReward("word_day_" .. index))
	-- self.node_tree.img_reward_name.node:loadTexture(ResPath.GetLoginReward("word_reward_" .. index))
	local reward_flag = LoginRewardData.Instance:GetLoginRewardFlag(self.data.index)
	self.node_tree.img_stamp.node:setVisible(reward_flag == 2)
	self.view:UpdateReimd(reward_flag == 1)
end