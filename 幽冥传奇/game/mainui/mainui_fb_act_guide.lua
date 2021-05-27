
--副本、活动导航
MainuiFbActGuide = MainuiFbActGuide or BaseClass()
FB_ACT_GUIDE_BTN_TYPE_ENUM ={
	1,	-- 退出
	2,	-- 单倍领奖
	3,	-- 双倍领奖
	4, 	-- 排行榜
	5, 	-- 押镖自动寻路
	6,  -- 答题面板
	7,  -- 放弃押镖
	8,  -- 星空下一层
	9,
	10, -- 选择BOSS
	-- 11,
}
--奖励倍率 1-单倍领奖，2-双倍领奖
FB_ACT_GUIDE_FETCH_AWARD_RATE = {
	1,
	2,
}

-- 额外信息显示类型
FB_ACT_GUIDE_EXTR_INFO_SHOW_TYPE = {
	DoubleFetch = 1,			--双倍领取
}

MainuiFbActGuide.BossHomeSize = {
		height = 100,
		width = 80,
	}
MainuiFbActGuide.Size = {
							height = 280,
							width = 300,
						}
MainuiFbActGuide.AwardItemSize = {
									height = 75,
									width = 100,
								}
function MainuiFbActGuide:__init()
	self.mt_layout_root = nil
	self.img_arrow_left = nil
	self.img_arrow_right = nil
	self.img_list_bg = nil
	self.guide_title_text = nil
	self.guide_title_bg = nil
	self.rich_text = nil
	self.award_list = {}
	self.btns_list = {}
	self.show_data = nil
	self.count_down_timer = nil
	self.star_list = nil 
	self.show_bosshome_data = nil
	self.show_bosstemple_data = nil
	self.cd_exit_btn = nil 
	self.mt_layout_root3 = nil
	-- GlobalEventSystem:Bind(MainUIEventType.MAINUI_FUNNOTE_VISIBLE,BindTool.Bind(self.OnFunNoteVisibleChange, self))
end

function MainuiFbActGuide:__delete()
	self.mt_layout_root = nil
	self.img_arrow_left = nil
	self.img_arrow_right = nil
	self.img_list_bg = nil
	self.guide_title_text = nil
	self.guide_title_bg = nil
	self.rich_text = nil
	if next (self.award_list) then
		for k, v in pairs(self.award_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.award_list = {}
	end 
	self.btns_list = {}
	self.show_data = nil
	self.star_list = nil
	self.stars_list = {}
	if self.alert_window ~= nil then
		self.alert_window:DeleteMe()
		self.alert_window = nil 
	end
	if self.alert_escort_window ~= nil then
		self.alert_escort_window:DeleteMe()
		self.alert_escort_window = nil 
	end
	if self.cd_exit_btn then
		self.cd_exit_btn:DeleteMe()
		self.cd_exit_btn = nil 
	end
	if self.number_bar_level ~= nil then
		self.number_bar_level:DeleteMe()
		self.number_bar_level = nil 
	end
end

function MainuiFbActGuide:Init(mt_layout_root)
	local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	local y = MainuiFbActGuide.Size.height - 30

	self.global_offset = 0
	self.global_y = screen_h - 220
	self.mt_layout_root = MainuiMultiLayout.CreateMultiLayout(0, self.global_y, cc.p(0, 1), MainuiFbActGuide.Size, mt_layout_root, 0)

	self.img_arrow_left = XUI.CreateImageView(300, y-2, ResPath.GetMainui("task_arrow_left1"), true)
	self.img_arrow_left:setHittedScale(1.03)
	self.mt_layout_root:TextureLayout():addChild(self.img_arrow_left, 3)
	XUI.AddClickEventListener(self.img_arrow_left, BindTool.Bind(self.OnClickArrawLeft, self), true)

	self.img_arrow_right = XUI.CreateImageView(344, y-2, ResPath.GetMainui("task_arrow_left1"), true)
	self.img_arrow_right:setScaleX(-1)
	self.img_arrow_right:setVisible(false)
	self.mt_layout_root:TextureLayout():addChild(self.img_arrow_right, 2)
	XUI.AddClickEventListener(self.img_arrow_right, BindTool.Bind(self.OnClickArrawRight, self), true)

	self.guide_title_bg = XUI.CreateImageViewScale9(0, y-1, 290.5, 47, ResPath.GetMainui("task_btn_bg3"), true)
	self.guide_title_bg:setAnchorPoint(0, 0.5)
	self.mt_layout_root:TextureLayout():addChild(self.guide_title_bg)
	self.guide_title_text = XUI.CreateText(112, y, 130, 0, cc.TEXT_ALIGNMENT_CENTER,"",nil,nil,nil)
	self.guide_title_text:setAnchorPoint(0.5, 0.5)
	self.guide_title_text:setString("")
	self.guide_title_text:setFontName(COMMON_CONSTS.FONT)
	self.guide_title_text:setFontSize(24)
	self.guide_title_text:setColor(COLOR3B.WHITE)
	self.mt_layout_root:TextLayout():addChild(self.guide_title_text)

	local list_size = cc.size(MainuiFbActGuide.Size.width, MainuiFbActGuide.Size.height - 60)
	y = MainuiFbActGuide.Size.height - 54
	local task_h_shift = 65
	self.img_list_bg = XUI.CreateImageViewScale9(0, y+1, list_size.width - 9, 5, ResPath.GetMainui("task_bg"), true)
	self.img_list_bg:setAnchorPoint(0, 1)
	self.img_list_bg.base_size = list_size
	self.img_list_bg.task_h_shift = task_h_shift
	self.mt_layout_root:TextureLayout():addChild(self.img_list_bg)

	self.remin_time_title = XUI.CreateText(63, y-25, 115, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.YELLOW, v_alignment)
	self.mt_layout_root:TextureLayout():addChild(self.remin_time_title)

	self.remin_time = XUI.CreateText(145, y-25, 80, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.GREEN, v_alignment)
	self.mt_layout_root:TextureLayout():addChild(self.remin_time)

	-- self.btn_exit = XUI.CreateImageView(240, y-35, ResPath.GetMainui("btn_exit"),true)
	-- self.mt_layout_root:TextLayout():addChild(self.btn_exit)
	-- self.btn_exit:setVisible(false)
	-- XUI.AddClickEventListener(self.btn_exit, BindTool.Bind(self.ExitFuben, self), true)

	self.img_bg = XUI.CreateImageViewScale9(110, y-20, 210, 22, ResPath.GetCommon("prog_106"), true)
	self.mt_layout_root:TextureLayout():addChild(self.img_bg,996)
	self.img_bg:setVisible(false)
	self.stars_list = {}
	local pos = {{26, y-20},{77.5, y-20},{132,y-20}}
	for i = 1, 3 do
		local file = ResPath.GetCommon("star_0_select")	
		local start = XUI.CreateImageView(pos[i][1], pos[i][2], file)
		self.mt_layout_root:TextureLayout():addChild(start, 999)
		start:setVisible(false)
		table.insert(self.stars_list, start)
	end
	self.prog9_bar = XUI.CreateLoadingBar(110, y-20, ResPath.GetCommon("prog_106_progress"), true, nil, true, 178, 13)
	self.prog9_bar:setPercent(100)
	self.mt_layout_root:TextureLayout():addChild(self.prog9_bar, 997)
	self.prog9_bar:setVisible(false)

	self.rich_text = XUI.CreateRichText(5, MainuiFbActGuide.Size.height, list_size.width - 20, MainuiFbActGuide.Size.height)
	self.rich_text:setAnchorPoint(0, 1)
	self.rich_text:setMaxLine(20)
	XUI.SetRichTextVerticalSpace(self.rich_text, 2)
	self.mt_layout_root:TextureLayout():addChild(self.rich_text)

	self.btn_info_txt = XUI.CreateText(200, 0, 100, 0, cc.TEXT_ALIGNMENT_CENTER, "", nil, 18, COLOR3B.YELLOW, v_alignment)
	self.mt_layout_root:TextureLayout():addChild(self.btn_info_txt)

	self.mt_layout_root2 =  MainuiMultiLayout.CreateMultiLayout(305, screen_h - 160, cc.p(0, 1), MainuiFbActGuide.BossHomeSize, mt_layout_root, 0)
	self.mt_layout_root2:setVisible(false)
	self.mt_layout_root3 = mt_layout_root
end

function MainuiFbActGuide:CreateLevelNumBar(x,y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetBablePath("num_"))
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-10)
	return number_bar
end

function MainuiFbActGuide:OnFunNoteVisibleChange(visible)
	if visible then
		self.global_offset = -100
	else
		self.global_offset = 0
	end	
	self.mt_layout_root:setPosition(self.mt_layout_root:getPositionX(),self.global_y + self.global_offset)
end	

function MainuiFbActGuide:InitShowData(data)
	self.show_data = data
	self:DelCountDownTimer()
	if self.show_data.remainTitle ~= "" then
		self:CreateCountDownTimer()
		self.remin_time:setVisible(true)
	else
		self.remin_time:setVisible(false)
	end
	self:InitContent()
end

function MainuiFbActGuide:InitBossHomeShowData(data)
	self.show_bosshome_data = data
	self.mt_layout_root2:setVisible(true)
	if self.cd_exit_btn == nil then
		self.cd_exit_btn = MainUiIcon:CreateMainuiIcon3(self.mt_layout_root2, "54")
		self.cd_exit_btn:AddClickEventListener(BindTool.Bind(self.OnExitBossHome,self))
	end
	self.cd_exit_btn:SetPosition(40,0)
	self.cd_exit_btn:SetVisible(true)
	if data.panel_type == ActivePanelType.TypeTwo then
		self.cd_exit_btn:SetPosition(22,0)
		if self.show_data.actId == ActiveFbID.BabelFight then
			local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
			if self.number_bar_level == nil then
				self.number_bar_level = self:CreateLevelNumBar(screen_w/2 , screen_h/2 + 275, 28, 62)
				self.mt_layout_root3:TextureLayout():addChild(self.number_bar_level:GetView(),101)
			end
			self.number_bar_level:SetVisible(false)
			self.number_bar_level:GetView():setAnchorPoint(0.5, 0.5)
			self.number_bar_level:SetGravity(NumberBarGravity.Center)
			self.number_bar_level:SetHasMinus(false)
		end
	end
	self.cd_exit_btn:SetEndTime(data.remainTime)
	self.cd_exit_btn:SetBgBottomPath(ResPath.GetMainui("icon_text_bg"))
	self.cd_exit_btn:SetBottomContentColor(COLOR3B.RED)
end
function MainuiFbActGuide:CleanData()
	self.mt_layout_root:MoveTo(0, 0, self.mt_layout_root:getPositionY())
	self.img_arrow_right:setVisible(false)
	if self.right_client_ser_rest_time_evt then
		GlobalEventSystem:UnBind(self.right_client_ser_rest_time_evt)
		self.right_client_ser_rest_time_evt = nil
	end
	self:DelCountDownTimer()
	self.show_data = nil
	self.guide_title_text:setString("")
	self.remin_time:setString("")
	self.btn_info_txt:setString("")
	self.rich_text:removeAllElements()
	if self.desert_kill_prog_txt and self.desert_kill_prog_bar and self.desert_progress_bg then
		self.desert_kill_prog_txt:removeFromParent()
		self.desert_kill_prog_txt = nil
		self.desert_kill_prog_bar:removeFromParent()
		self.desert_kill_prog_bar = nil
		self.desert_progress_bg:removeFromParent()
		self.desert_progress_bg = nil
	end

	if next (self.award_list) then
		for k, v in pairs(self.award_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
		end
		self.award_list = {}
	end
	for k, v in pairs(self.btns_list) do
		if v.btn then
			v.btn:removeFromParent()
		end
	end
	self.btns_list = {}

	if self.arrow_point then
		self.arrow_point:removeFromParent()
		self.arrow_point = nil
	end
	if self.cd_exit_btn ~= nil then
		self.cd_exit_btn:SetBottomContent("")
		self.cd_exit_btn:SetVisible(false)
	end
	if self.number_bar_level then
		self.number_bar_level:SetVisible(false)
	end
	self.mt_layout_root2:setVisible(false)
end

function MainuiFbActGuide:InitContent()
	-- PrintTable(self.show_data)
	if not self.show_data or not next(self.show_data) then return end
	if not self.right_client_ser_rest_time_evt then
		self.right_client_ser_rest_time_evt = GlobalEventSystem:Bind(OtherEventType.ACT_FUBEN_REST_TIME, BindTool.Bind(self.RightClienAndSerRestTime, self))
	end
	-- print("类型：ID：", self.show_data.type, self.show_data.actId)
	local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	if  self.show_data.type == 1 and self.show_data.actId == ActiveFbID.StrengthFb or  
		self.show_data.type == 1 and self.show_data.actId == ActiveFbID.MagicCity or 
		self.show_data.type == 1 and self.show_data.actId == ActiveFbID.TeamBoss then

		self.prog9_bar:setVisible(true)
		self.img_bg:setVisible(true)
		self.rich_text:setPosition(5, MainuiFbActGuide.Size.height - 115)
		self.remin_time_title:setPositionY(MainuiFbActGuide.Size.height - 100)
		self.remin_time:setPositionY(MainuiFbActGuide.Size.height - 100)
		self.img_list_bg:setOpacity(120)
		for i,v in ipairs(self.stars_list) do
			v:setVisible(true)
		end
		if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.MagicCity then
			local pos_t = MagicCityData.Instance:GetStarPercent(self.show_data.page) 
			local data = {28, 28, 38}
			for i, v in ipairs(self.stars_list) do
				v:setPositionX(pos_t[i]*182+data[i])
			end
		elseif  self.show_data.type == 1 and self.show_data.actId == ActiveFbID.TeamBoss then
			local data = {32, 32, 32}
			local pos_t = StrenfthFbData.Instance:GetStarPercent(self.show_data.page)
			for i, v in ipairs(self.stars_list) do
				v:setPositionX(pos_t[i]*182+data[i])
			end
		end
		self.img_list_bg.task_h_shift = 65
		if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.StrengthFb then
			self.img_list_bg:setOpacity(250)
			self.img_list_bg.task_h_shift = 20
		end

	else
		self.img_list_bg:setOpacity(255)
		for i,v in ipairs(self.stars_list) do
			v:setVisible(false)
		end
		self.remin_time_title:setPositionY(MainuiFbActGuide.Size.height - 70)
		self.remin_time:setPositionY(MainuiFbActGuide.Size.height - 70)
		self.rich_text:setPosition(5, MainuiFbActGuide.Size.height - 80)
		self.prog9_bar:setVisible(false)
		self.img_bg:setVisible(false)
		self.img_list_bg.task_h_shift = 55
	end
	self.mt_layout_root:setPositionY(self.global_y + self.global_offset)
	if self.show_data.actId == ActiveFbID.BabelFight then
		self.img_list_bg.task_h_shift = 20
	end
	local text = ""
	text = self.show_data.title
	if text == "" then
		text = Language.Fuben.FbOrAct[self.show_data.type]
	end
	self.guide_title_text:setString(text)
	self:SetRestTimeText(self.show_data.remainTime - TimeCtrl.Instance:GetServerTime())
	self:FlushOther(self.show_data.remainTime - TimeCtrl.Instance:GetServerTime())
	self:FlushMagicCityOther(self.show_data.remainTime - TimeCtrl.Instance:GetServerTime())
	self:FlushTeamBossOther(self.show_data.remainTime - TimeCtrl.Instance:GetServerTime())
	self:SetRemainTitleText()
	self.all_h = 0
	self.rich_text:removeAllElements()
	self:AddTextToRichText(nil)
	self.rich_text:refreshView()
	local inner_h = self.rich_text:getInnerContainerSize().height
	self.all_h = inner_h + self.img_list_bg.task_h_shift + 40
	if self:CreateAwards() then
		self.all_h = self.all_h + MainuiFbActGuide.AwardItemSize.height + 10
	end

	if self.show_data.actId == ActiveFbID.DesertKillGod or self.show_data.actId == ActiveFbID.TeamBoss then
		self.all_h = self.all_h + 20
	end
	local w = MainuiFbActGuide.Size.width - 9
	local pos_x = 266
	if #self.show_data.btnsTypeT >= 3 then
		w = MainuiFbActGuide.Size.width + 25
		pos_x = 300
	end
	self.img_arrow_left:setPositionX(pos_x)
	self.guide_title_bg:setContentWH(w, 47)
	self.img_list_bg:setContentWH(w, self.all_h)
	self:CreateBtns()
	self:SetDesertKillProgPartsPosY()
end

function MainuiFbActGuide:AdjustSizeAndLayout()
	self.rich_text:refreshView()
	local inner_h = self.rich_text:getInnerContainerSize().height
	self.all_h = inner_h + self.img_list_bg.task_h_shift + 40
	if self:CreateAwards() then
		self.all_h = self.all_h + MainuiFbActGuide.AwardItemSize.height + 10
	end

	if self.show_data.actId == ActiveFbID.DesertKillGod or self.show_data.actId == ActiveFbID.TeamBoss then
		self.all_h = self.all_h + 20
	end

	self.img_list_bg:setContentWH(MainuiFbActGuide.Size.width - 9, self.all_h)
	self:AdjustBtnsPos()
end

function MainuiFbActGuide:FlushContent(param_t)
	if not param_t or not next(param_t) then return end
	self.rich_text:removeAllElements()
	if not self.show_data then return end
	self.show_data.state = param_t.state
	-- print("活动状态：", self.show_data.state)
	if self:IsBtnNeedChange(param_t.btnsTypeT) then
		self.show_data.btnsTypeT = param_t.btnsTypeT
		self:CreateBtns()
	end
	self:AddTextToRichText(param_t.contentList)
	if self.show_data.type == 1 and (self.show_data.actId == 1 or self.show_data.actId == 2) then
		for k, v in pairs(self.btns_list) do
			if v.btn and self.arrow_point and v.btnType == FB_ACT_GUIDE_BTN_TYPE_ENUM[1] then
				self.arrow_point:setVisible(self.show_data.state == 2)
			end
		end
	end
	-- self:SetDesertKillProgPartsPosY()
end

function MainuiFbActGuide:SetRemainTitleText()
	local txt = self.show_data.remainTitle
	self.remin_time_title:setString(self.show_data.remainTitle)
	
end

function MainuiFbActGuide:SetRestTimeText(remin_time)
	local model = 2
	if remin_time >= 3600 then
		model = 3
	end
	local remTime = TimeUtil.FormatSecond(remin_time, model)
	self.remin_time:setString(remTime)
end

function MainuiFbActGuide:AddTextToRichText(flushContent)
	local content = self.show_data.contentTitle
	if content ~= "" then
		content = string.format(Language.Mainui.FubenActGuideTitle, content)
	end
	local content_2 = ""
	if flushContent then
		for k, v in pairs(flushContent) do
			self.show_data.contentList[k] = v
		end
		if self.show_data.actId == ActiveFbID.Escort then
			for k, v in ipairs(self.show_data.contentList) do
				if not flushContent[k] then
					table.remove(self.show_data.contentList, k)
				end
			end
		end
	end
	for k, v in ipairs(self.show_data.contentList) do
		if self.show_data.contentTitle ~= "" then
			if v ~= "" then
				content_2 = content_2 .. "  " .. v .. "\n"
			end
		else
			-- 荒漠杀神特殊
			if self.show_data.actId == ActiveFbID.DesertKillGod then
				if k ~= #self.show_data.contentList then
					if v ~= "" then
						content_2 = content_2 .. v .. "\n"
					end
				else
					self:SetDesertKillProgInfo(v)
				end
			else
				if v ~= "" then
					content_2 = content_2 .. v .. "\n"
				end
			end
		end
	end
	content = content .. content_2
	local content_3 = ""
	if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.MagicCity then
		content_3 = content_3 ..Language.MagicCity.Guilde_Title
		content_3 = string.format(Language.Mainui.FubenActGuideTitle, content_3)
		content_3 = "  " .. Language.MagicCity.Content[self.show_data.page].."\n"
	end

	if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.XuKongShiLian then
		content_3 = content_3 ..Language.Fuben.FirstTongGuan
		content_3 = string.format(Language.Mainui.FubenActGuideTitle, content_3)
	end
	if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.GuildShouWeiBoss then
		content_3 = content_3 ..Language.Fuben.TipsDesc
		content_3 = string.format(Language.Mainui.FubenActGuideTitle, content_3)
	end
	content = content .. content_3

	local content_4 = self.show_data.awardTitle
	if content_4 ~= "" then
		content_4 = "{color;ffff00;" .. content_4 .. "}"
	end
	content = content .. content_4
	local content_5 = ""
	if self.show_data.actId == ActiveFbID.LeiTaiBoss then
		content_5 = Language.Tip.SelectBoss
	end
	content = content .. content_5
	local content_6 = ""
	if self.show_data.actId == ActiveFbID.ShiMuSaoZhu then
		content_6 = Language.Tip.ShiMuSaoZhu
	end
	content = content .. content_6
	RichTextUtil.ParseRichText(self.rich_text, content)
	-- self:SetDesertKillProgPartsPosY()
	if self.show_data.actId == ActiveFbID.Escort and flushContent and next(flushContent) then
		self:AdjustSizeAndLayout()
	end
end

-- 设置荒漠杀神采集积分进度信息
function MainuiFbActGuide:SetDesertKillProgInfo(info)
	if not info then return end
	if not self.desert_kill_prog_txt then
		local img9_bg_size = self.img_list_bg:getContentSize()
		self.desert_kill_prog_txt = XUI.CreateText(img9_bg_size.width / 2, 0, 200, 0, cc.TEXT_ALIGNMENT_CENTER, "", nil, 18, COLOR3B.WHITE, v_alignment)
		self.mt_layout_root:TextureLayout():addChild(self.desert_kill_prog_txt, 1001)
		self.desert_progress_bg = XUI.CreateImageViewScale9(img9_bg_size.width / 2, 0, 212, 19, ResPath.GetCommon("prog_106"), true, cc.rect(23, 5, 18, 9))
		self.mt_layout_root:TextureLayout():addChild(self.desert_progress_bg)
		self.desert_kill_prog_bar = XUI.CreateLoadingBar(img9_bg_size.width / 2, 0, ResPath.GetCommon("prog_106_progress"), true, nil, true, 178, 13)
		self.mt_layout_root:TextureLayout():addChild(self.desert_kill_prog_bar, 1000)
	end
	
	local prog_info_tbl = Split(info, "/")
	if not next(prog_info_tbl) then
		self.desert_kill_prog_txt:setString("")
		self.desert_kill_prog_bar:setVisible(false)
		self.desert_progress_bg:setVisible(false)
		return
	end
	self.desert_kill_prog_txt:setString(info)	
	self.desert_kill_prog_bar:setVisible(true)
	self.desert_progress_bg:setVisible(true)
	self.desert_kill_prog_bar:setPercent(tonumber(prog_info_tbl[1]) / tonumber(prog_info_tbl[2]) * 100)
end

function MainuiFbActGuide:SetDesertKillProgPartsPosY()
	if self.desert_kill_prog_txt and self.desert_kill_prog_bar then
		self.rich_text:refreshView()
		local inner_h = self.rich_text:getInnerContainerSize().height
		local img9_bg_size = self.img_list_bg:getContentSize()
		self.desert_kill_prog_txt:setPositionY(MainuiFbActGuide.Size.height - img9_bg_size.height + 12)
		self.desert_kill_prog_bar:setPositionY(MainuiFbActGuide.Size.height - img9_bg_size.height + 12)
		self.desert_progress_bg:setPositionY(MainuiFbActGuide.Size.height - img9_bg_size.height + 12)
	end
end

function MainuiFbActGuide:StarChange(star)
	for i, v in ipairs(self.stars_list) do
		if star >= i then
			v:loadTexture(ResPath.GetCommon("star_0_select"))
		else
			v:loadTexture(ResPath.GetCommon("star_0_lock"))
		end
	end
end

function MainuiFbActGuide:FlushOther(remin_time)
	if self.show_data and self.show_data.state == 1 then
		local time = StrenfthFbData.Instance:GetTimeCfg(self.show_data.page)
		self.prog9_bar:setPercent(remin_time/time*100)
		local star = StrenfthFbData.Instance:GetStarNum(self.show_data.page, remin_time)
		self:StarChange(star)
	end
end

function MainuiFbActGuide:FlushMagicCityOther(remin_time)
	if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.MagicCity then
		local time = MagicCityData.Instance:GetTime(self.show_data.page) or 1
		self.prog9_bar:setPercent(remin_time/time*100)
		local star = MagicCityData.Instance:GetstarNum(self.show_data.page, remin_time)
		self:StarChange(star)
	end
end

function MainuiFbActGuide:FlushTeamBossOther(remin_time)
	if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.TeamBoss then
		local time = BossSportData.Instance:GetBossToTalTime(self.show_data.page) or 1
		self.prog9_bar:setPercent(remin_time/time*100)
		local star = BossSportData.Instance:GetTeamBossStar(self.show_data.page, remin_time)
		self:StarChange(star)
	end
end

function MainuiFbActGuide:TimeCountDown(changeNum)
	if not self.show_data then
		self:DelCountDownTimer() 
		return
	end
	-- self.show_data.remainTime = self.show_data.remainTime + changeNum
	local time = self.show_data.remainTime - TimeCtrl.Instance:GetServerTime()
	if self.show_data.actId == ActiveFbID.BabelFight and time <= 30 then
		if self.number_bar_level then
			self.number_bar_level:SetVisible(true)
			self.number_bar_level:SetNumber(time)

			local scale_to = cc.ScaleTo:create(0.3, 1.3)
			local delay_time = cc.DelayTime:create(0.4)
			local scale_to_1 = cc.ScaleTo:create(0.3, 1)
			local scale = cc.Sequence:create(scale_to, scale_to_1,delay_time)
			self.number_bar_level:GetView():runAction(cc.RepeatForever:create(scale))
		end
	end
	if time > 0 then
		self:SetRestTimeText(time)
		if self.show_data.page > 0 then
			self:FlushOther(time)
			self:FlushMagicCityOther(time)
			self:FlushTeamBossOther(time)
		end
		-- self.rich_text:removeAllElements()
		-- self:AddTextToRichText(nil)
	else
		if self.number_bar_level then
			self.number_bar_level:SetVisible(false)
		end
		self:DelCountDownTimer()
	end
end

-- 纠正客户端和服务端剩余时间误差
function MainuiFbActGuide:RightClienAndSerRestTime(id, rest_time)
	if not self.show_data then
		if self.right_client_ser_rest_time_evt then
			GlobalEventSystem:UnBind(self.right_client_ser_rest_time_evt)
			self.right_client_ser_rest_time_evt = nil
		end
		return
	end
	self.show_data.remainTime = rest_time
end

function MainuiFbActGuide:IsHaveTime()
	return self.show_data.remainTime > 0
end

function MainuiFbActGuide:CreateCountDownTimer()
	if not self.count_down_timer then
		self.count_down_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimeCountDown, self, -1), 1)
	end
end

function MainuiFbActGuide:DelCountDownTimer()
	if self.count_down_timer then
		GlobalTimerQuest:CancelQuest(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function MainuiFbActGuide:CreateAwards()
	if not self.show_data or not next(self.show_data.awardList) then return end
	local inner_h = self.rich_text:getInnerContainerSize().height
	local height = 0
	if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.StrengthFb or 
		self.show_data.type == 1 and self.show_data.actId == ActiveFbID.MagicCity or 
		self.show_data.type == 1 and self.show_data.actId == ActiveFbID.TeamBoss then
		height = -inner_h + 60
	else
		height = -inner_h + 103
	end
	local awardsCnt = #self.show_data.awardList
	local margin = 15
	local gap = (MainuiFbActGuide.Size.width - 2 * margin) / awardsCnt
	if next (self.award_list) then
		for k, v in pairs(self.award_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
		end
		self.award_list = {}
	end
	for i, v in ipairs(self.show_data.awardList) do
		if nil == self.award_list[i] then
			self.award_list[i] = FbActGuideRewardRender.New()
			self.award_list[i]:SetPosition(margin + (i -1) * gap, height)
			self.mt_layout_root:TextureLayout():addChild(self.award_list[i]:GetView(), 100)
			self.award_list[i]:SetData(v)
		end
	end
	return self.award_list
end

function MainuiFbActGuide:CreateBtns()
	if not self.show_data then 
		return
	end
	-- print("类型：ID：", self.show_data.type, self.show_data.actId)
	-- if self.show_data.type == 1 and self.show_data.actId == ActiveFbID.StrengthFb or
	-- 	self.show_data.type == 1 and self.show_data.actId == ActiveFbID.MagicCity or
	-- 	self.show_data.type == 1 and self.show_data.actId == ActiveFbID.TeamBoss then
	-- 	self.btn_exit:setVisible(true)
	-- elseif self.show_data.actId ~= 5 then
	-- 	self.btn_exit:setVisible(false)
		for k, v in pairs(self.btns_list) do
			if v.btn then
				v.btn:removeFromParent()
				v = nil
			end
		end
		self.btns_list = {}
		local margin = 20
		local btnHalfWidth = 47
		local img9_bg_size = self.img_list_bg:getContentSize()
		local btnCnt = #self.show_data.btnsTypeT
		local gap = (MainuiFbActGuide.Size.width - 2 * margin) / btnCnt
		if btnCnt >= 3 then
			gap = MainuiFbActGuide.Size.width / btnCnt + 5
			btnHalfWidth = 37
		end
		for i, v in ipairs(self.show_data.btnsTypeT) do
			local path = ResPath.GetCommon("btn_101")
			if nil == self.btns_list[i] then
				local btn = nil
				if btnCnt == 1 then
					btn = XUI.CreateButton(MainuiFbActGuide.Size.width / 2, MainuiFbActGuide.Size.height - img9_bg_size.height - 25, 0, 0, false, path, path)
				else
					btn = XUI.CreateButton((margin + btnHalfWidth) + (i - 1) * gap, MainuiFbActGuide.Size.height - img9_bg_size.height - 25, 0, 0, false, path, path)
					self.btn_info_txt:setPosition(198, btn:getPositionY() + 35)
				end
				local btnText = ""
				local btnExtrInfoCfg = FubenData.GetCommonActFbBtnExtrInfoCfg(v.btnParam)
				if btnExtrInfoCfg and btnExtrInfoCfg.showType == FB_ACT_GUIDE_EXTR_INFO_SHOW_TYPE.DoubleFetch then
					local extrInfo = string.format(Language.Fuben.BtnExtraInfo[btnExtrInfoCfg.showConsume.type], btnExtrInfoCfg.showConsume.count)
					self.btn_info_txt:setString(extrInfo)
				end
				if v.btnType == FB_ACT_GUIDE_BTN_TYPE_ENUM[1] then
					if self.show_data.actId ~= 0 then
						local btn_eff = self:CreateHandPointEff(btn, res_id, scaleX, scaleY, is_def_vis)
						btn.eff = btn_eff
					end
					btnText = string.format(Language.Fuben.BtnsTexts[1], Language.Fuben.FbOrAct[self.show_data.type])
				else
					if v.btnType == FB_ACT_GUIDE_BTN_TYPE_ENUM[3] then
						local btn_eff = self:CreateBtnRectEff(btn, res_id, scaleX, scaleY, true)
						btn.eff = btn_eff
					end
					local txt = Language.Fuben.BtnsTexts[self.show_data.btnsTypeT[i].btnType]
					if self.show_data.actId == ActiveFbID.OreFight then
						if i == 3 then
							txt = Language.Fuben.BtnsTexts[11]
						end
					end
					btnText = txt
				end
				btn:setTitleText(btnText)
				btn:setTitleFontSize(18)
				btn:setTitleFontName(COMMON_CONSTS.FONT)
				btn:setTitleColor(COLOR3B.WHITE)
				XUI.AddClickEventListener(btn, BindTool.Bind(self.OnOpratBtnClick, self, self.show_data.btnsTypeT[i].btnType, self.show_data.type), true)
				self.mt_layout_root:TextureLayout():addChild(btn, 100)
				self.btns_list[i] = {btn = btn, btnType = v.btnType}
			end
		end
	-- end
end

function MainuiFbActGuide:AdjustBtnsPos()
	local margin = 20
	local btnHalfWidth = 47
	local img9_bg_size = self.img_list_bg:getContentSize()
	local btnCnt = #self.show_data.btnsTypeT
	local gap = (MainuiFbActGuide.Size.width - 2 * margin) / btnCnt
	if btnCnt >= 3 then
		gap = MainuiFbActGuide.Size.width / btnCnt
	end
	for i, v in ipairs(self.btns_list) do
		local btn = v.btn	
		if btnCnt == 1 then
			btn:setPosition(MainuiFbActGuide.Size.width / 2, MainuiFbActGuide.Size.height - img9_bg_size.height - 25)
		else
			btn:setPosition((margin + btnHalfWidth) + (i - 1) * gap, MainuiFbActGuide.Size.height - img9_bg_size.height - 25)
			self.btn_info_txt:setPosition(198, btn:getPositionY() + 35)
		end
	end
end

-- 创建按钮特效
function MainuiFbActGuide:CreateHandPointEff(btn, res_id, scaleX, scaleY, is_def_vis)
	local btn_pos_x, btn_pos_y = btn:getPositionX(), btn:getPositionY()
	if nil == self.arrow_point then	
		self.arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("figer_point"))
		self.arrow_point:setAnchorPoint(0, 1)
		self.mt_layout_root:TextureLayout():addChild(self.arrow_point, 101)

		self.arrow_point:loadTexture(ResPath.GetGuide("figer_point"))
		local callback = cc.CallFunc:create(function()
			self.arrow_point:loadTexture(ResPath.GetGuide("figer_point1"))
		end)
		local callback1 = cc.CallFunc:create(function()
			self.arrow_point:loadTexture(ResPath.GetGuide("figer_point"))
		end)
		self.arrow_point:setVisible(is_def_vis)
		self.arrow_point:setPosition(btn_pos_x, btn_pos_y)
		local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5),callback,cc.DelayTime:create(0.5),callback1))
		self.arrow_point:runAction(action)
	end
	
end

function MainuiFbActGuide:CreateBtnRectEff(parent, res_id, scaleX, scaleY, is_def_vis)
	if not parent then return end
	local btn_eff = RenderUnit.CreateEffect(res_id or 909, parent, zorder, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, x, y)
	if btn_eff then
		btn_eff:setScaleX(scaleX or 0.35)
		btn_eff:setScaleY(scaleY or 0.6)
		btn_eff:setVisible(is_def_vis)
	end

	return btn_eff
end

function MainuiFbActGuide:IsBtnNeedChange(newBtnTypeT)
	if #self.show_data.btnsTypeT ~= #newBtnTypeT then
		return true
	elseif #self.show_data.btnsTypeT > 0 and #newBtnTypeT > 0 then
		for k, v in pairs(newBtnTypeT) do
			if v ~= self.show_data.btnsTypeT[k] then
				return true
			end
		end
	end

	return false
end

-- 操作按钮（退出、领取等）
function MainuiFbActGuide:OnOpratBtnClick(type, sceneType)
	-- PrintTable(self.show_data)
	if type == FB_ACT_GUIDE_BTN_TYPE_ENUM[1] then
		self:CreateAlertView(sceneType)
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[2] then
		Scene.Instance:FbActFetchAwardReq(FB_ACT_GUIDE_FETCH_AWARD_RATE[1])
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[3] then
		Scene.Instance:FbActFetchAwardReq(FB_ACT_GUIDE_FETCH_AWARD_RATE[2])
	elseif type  == FB_ACT_GUIDE_BTN_TYPE_ENUM[4] then
		if self.show_data.actId == 13 then
			ViewManager.Instance:Open(ViewName.BossBattleInjureRank)
			ViewManager.Instance:FlushView(ViewName.BossBattleInjureRank)
		elseif self.show_data.actId == 41 then
			ViewManager.Instance:Open(ViewName.CrossUnionScoreRank)
			ViewManager.Instance:FlushView(ViewName.CrossUnionScoreRank)
		elseif self.show_data.actId == 14 then
			MagicCityCtrl.Instance:ReqRankinglistData(4)
			ViewManager.Instance:Open(ViewName.CombineserverArenaRank)
			ViewManager.Instance:FlushView(ViewName.CombineserverArenaRank)
		elseif self.show_data.actId == 15 then
			MagicCityCtrl.Instance:ReqRankinglistData(5)
			ViewManager.Instance:Open(ViewName.CombineserverArenaRank)
			ViewManager.Instance:FlushView(ViewName.CombineserverArenaRank)
		elseif self.show_data.actId == 43 then	
			ViewManager.Instance:Open(ViewName.SupplyContentionScoreView)
		end
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[5] then -- 押镖自动寻路
		local data = EscortConfig.EscortDest
		Scene.Instance:GetMainRole():LeaveFor(data.sceneid, data.x, data.y, MoveEndType.NpcTask, data.npcid)
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[6] then -- 打开答题面板
		ActivityCtrl.Instance:ReqApplyAnswer(self.show_data.page, 0, ANSWER_OPRETE_TYPE.OPEN_PANEL, 0)
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[7] then -- 放弃押镖
		self:CreateGiveUpEscort()
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[8] then -- 星宫下一层
		if self.show_data.actId == ActiveFbID.OreFight then
			local cfg = CrossUnionWarCfg.unionTeams[self.show_data.page]
			Scene.Instance:GetMainRole():LeaveFor(Scene.Instance:GetSceneId(), cfg.EnterPos[2], cfg.EnterPos[3], MoveEndType.NpcTask, cfg.npcId,2)
		else
			Scene.Instance:GetMainRole():LeaveFor(Scene.Instance:GetSceneId(), 23, 45, MoveEndType.NpcTask, 102,1)
		end
	elseif type == FB_ACT_GUIDE_BTN_TYPE_ENUM[10] then -- 选择BOSS
		ViewManager.Instance:Open(ViewName.LeiTaiBossChioce)
	end
end

function MainuiFbActGuide:CreateGiveUpEscort()
	if self.alert_escort_window == nil then
		self.alert_escort_window = Alert.New()
	end
	self.alert_escort_window:SetLableString(Language.Tip.EscortDesc)
	self.alert_escort_window:SetOkFunc(function()
			EscortCtrl.Instance:OnAbandonEscort()
		end)
	self.alert_escort_window:Open()
end


function MainuiFbActGuide:CreateAlertView(sceneType)
	if nil == self.alert_window then
		self.alert_window = Alert.New()
	end
	local des = string.format(Language.Mainui.Bool_Exit, self.show_data.title)
	self.alert_window:SetLableString(des)
	self.alert_window:SetOkFunc(function()
			Scene.Instance:QuitActiveFubenReq(sceneType)
		end)
	self.alert_window:Open()	
end


function MainuiFbActGuide:ExitFuben()
	Scene.Instance:QuitActiveFubenReq(1)
end

function MainuiFbActGuide:OnClickArrawLeft()
	local w = 0
	if #self.show_data.btnsTypeT >= 3 then
		w = -20
	end
	self.mt_layout_root:MoveTo(0.1, - MainuiFbActGuide.Size.width -20, self.mt_layout_root:getPositionY())
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnMoveComoplete, self), 0.1)
end

function MainuiFbActGuide:OnClickArrawRight()
	self.mt_layout_root:MoveTo(0.1, 0, self.mt_layout_root:getPositionY())
	self.img_arrow_right:setVisible(false)
end

function MainuiFbActGuide:OnMoveComoplete()
	self.img_arrow_right:setVisible(true)
	--self.img_arrow_right:setPositionX(100)
end


function MainuiFbActGuide:SetVisible(vis)
	if self.mt_layout_root then
		self.mt_layout_root:setVisible(vis)
	end
end

function MainuiFbActGuide:OnExitBossHome()
	if self.show_bosshome_data ~= nil then
		Scene.Instance:QuitActiveFubenReq(self.show_bosshome_data.type)
	end
end
function MainuiFbActGuide:OnExitBossTemple()
	if self.show_bosstemple_data ~= nil then
		Scene.Instance:QuitActiveFubenReq(self.show_bosstemple_data.type)
	end
end



------------------------------------------------------------------------
FbActGuideRewardRender = FbActGuideRewardRender or BaseClass(BaseRender)
function FbActGuideRewardRender:__init()
	self.view:setContentWH(MainuiFbActGuide.AwardItemSize.width, MainuiFbActGuide.AwardItemSize.height)
	self.item_cell = nil
	-- self.view:setBackGroundColor(COLOR3B.BLUE)
end

function FbActGuideRewardRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function FbActGuideRewardRender:CreateChild()
	BaseRender.CreateChild(self)

	self.item_cell =  BaseCell.New()
	self.item_cell:SetPosition(55, 65)
	self.item_cell:GetView():setAnchorPoint(0.5, 0.5)
	self.item_cell:GetView():setScale(0.7)
	self.view:addChild(self.item_cell:GetView())

	self.text_count = XUI.CreateText(55, 30, 100, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.GREEN)
	self.view:addChild(self.text_count)
end

function FbActGuideRewardRender:OnFlush()
	if nil == self.data then
		return
	end
	local cnt = ItemData.Instance:CalcuSpecialExpVal(self.data) and ItemData.Instance:CalcuSpecialExpVal(self.data) or self.data.count
	if cnt > 0 then
		self.text_count:setString("x".. cnt)
	else
		self.text_count:setString("")
	end
	self.item_cell:SetData({["item_id"] = self.data.item_id, ["num"] = 0, is_bind = is_bind})
end