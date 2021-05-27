MainuiSbkActGuide = MainuiSbkActGuide or BaseClass()
MainuiSbkActGuide.Size = cc.size(280, 240)


function MainuiSbkActGuide:__init()
	self.mt_layout_root = nil
	self.img_arrow_left = nil
	self.img_arrow_right = nil
	self.count_down_timer = nil
	self.show_data = nil
	self.paimin_list = {}

	-- GlobalEventSystem:Bind(MainUIEventType.MAINUI_FUNNOTE_VISIBLE,BindTool.Bind(self.OnFunNoteVisibleChange, self))
end

function MainuiSbkActGuide:__delete()
	self.mt_layout_root = nil
	self.img_arrow_left = nil
	self.img_arrow_right = nil

	for _,v in pairs(self.paimin_list) do
		v:DeleteMe()
	end	
	self.paimin_list = nil
end

function MainuiSbkActGuide:Init(mt_layout_root)
	local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	local y = MainuiFbActGuide.Size.height - 30
	self.global_y = screen_h - 210
	self.mt_layout_root = MainuiMultiLayout.CreateMultiLayout(0, self.global_y, cc.p(0, 1), MainuiFbActGuide.Size, mt_layout_root, 0)

	self.img_arrow_left = XUI.CreateImageView(266, y-2, ResPath.GetMainui("task_arrow_left1"), true)
	self.img_arrow_left:setHittedScale(1.03)
	self.mt_layout_root:TextureLayout():addChild(self.img_arrow_left,3)
	XUI.AddClickEventListener(self.img_arrow_left, BindTool.Bind(self.OnClickArrawLeft, self), true)

	self.img_arrow_right = XUI.CreateImageView(322, y-2, ResPath.GetMainui("task_arrow_left1"), true)
	self.img_arrow_right:setScaleX(-1)
	self.img_arrow_right:setVisible(false)
	self.mt_layout_root:TextureLayout():addChild(self.img_arrow_right,2)
	XUI.AddClickEventListener(self.img_arrow_right, BindTool.Bind(self.OnClickArrawRight, self), true)

	self.guide_title_bg = XUI.CreateImageViewScale9(0, y-1, 290.5, 47, ResPath.GetMainui("task_btn_bg3"), true)
	self.guide_title_bg:setAnchorPoint(0, 0.5)
	self.mt_layout_root:TextureLayout():addChild(self.guide_title_bg)

	self.guide_title_text = XUI.CreateText(112, y , 112, 0, cc.TEXT_ALIGNMENT_CENTER,"",nil,nil,nil)
	self.guide_title_text:setAnchorPoint(0.5, 0.5)
	self.guide_title_text:setString(Language.WangChengZhengBa.TabGrop[1])
	self.guide_title_text:setFontName(COMMON_CONSTS.FONT)
	self.guide_title_text:setFontSize(24)
	self.guide_title_text:setColor(COLOR3B.WHITE)
	self.mt_layout_root:TextLayout():addChild(self.guide_title_text)


	local list_size = cc.size(MainuiFbActGuide.Size.width, MainuiFbActGuide.Size.height - 88)
	y = MainuiFbActGuide.Size.height - 54
	local task_h_shift = 65
	self.img_list_bg = XUI.CreateImageViewScale9(0, y+1, list_size.width - 9, list_size.height, ResPath.GetMainui("task_bg"), true)
	self.img_list_bg:setAnchorPoint(0, 1)
	self.img_list_bg.base_size = list_size
	self.img_list_bg.task_h_shift = task_h_shift
	self.mt_layout_root:TextureLayout():addChild(self.img_list_bg)

	self.remin_time_txt = XUI.CreateText(55, y-10, 100, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.YELLOW)
	self.remin_time_txt:setString(Language.Common.RemainTime .. ":")
	self.mt_layout_root:TextureLayout():addChild(self.remin_time_txt)

	self.remin_time = XUI.CreateText(150, y-10, 80, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.WHITE)
	self.mt_layout_root:TextureLayout():addChild(self.remin_time)

	local temp_title = XUI.CreateText(55, y-35, 100, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.YELLOW)
	temp_title:setString(Language.WangChengZhengBa.CurZhanLing)
	self.mt_layout_root:TextureLayout():addChild(temp_title)

	self.win_guild_name_text = XUI.CreateText(200, y-35, 200, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20, COLOR3B.WHITE)
	self.win_guild_name_text:setString("")
	self.mt_layout_root:TextureLayout():addChild(self.win_guild_name_text)

	self.rich_text = XUI.CreateRichText(0, MainuiFbActGuide.Size.height - 110, list_size.width, list_size.height)
	self.rich_text:setAnchorPoint(0, 1)
	self.rich_text:setMaxLine(20)
	self.mt_layout_root:TextureLayout():addChild(self.rich_text)

	
	for i = 1,5 do 
		local cell = GuildRankCell.New()

		self.paimin_list[i] = cell
		cell:SetPosition(0,MainuiFbActGuide.Size.height - 125 - i * 20)
		self.mt_layout_root:TextureLayout():addChild(cell:GetView())

		--cell:SetData({index = i,guild_name = "左手一个慢动作",jifen = "123456"}) -- 测试数据
	end	

	-- local desc = "{wordcolor;ffcc00;%25s%12s}{newline}"
	-- desc = string.format(desc,Language.WangChengZhengBa.GuildRank,Language.WangChengZhengBa.JiFen)
	-- RichTextUtil.ParseRichText(self.rich_text,desc)
	
end	


function MainuiSbkActGuide:OnClickArrawLeft()
	self.mt_layout_root:MoveTo(0.3, - MainuiFbActGuide.Size.width, self.mt_layout_root:getPositionY())
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnMoveComoplete, self), 0.3)
end

function MainuiSbkActGuide:OnClickArrawRight()
	self.mt_layout_root:MoveTo(0.3, 0, self.mt_layout_root:getPositionY())
	self.img_arrow_right:setVisible(false)
end

function MainuiSbkActGuide:OnMoveComoplete()
	self.img_arrow_right:setVisible(true)
end

function MainuiSbkActGuide:SetVisible(vis)
	if self.mt_layout_root then
		self.mt_layout_root:setVisible(vis)
	end
end

function MainuiSbkActGuide:CleanData()
	self:DelCountDownTimer()
	self.rich_text:removeAllElements()

	self.win_guild_name_text:setString("")
	for i =  1,#self.paimin_list do
		self.paimin_list[i]:SetData(nil) 
	end
end	

function MainuiSbkActGuide:UpdateData(v)
	
	self.show_data = v

	self:DelCountDownTimer()
	if self.show_data.remain_time > 0 then
		self:CreateCountDownTimer()
	end	

	self.win_guild_name_text:setString(v.cur_guild_name or "")

	self.rich_text:removeAllElements()
	local desc = "{wordcolor;ffcc00;%25s%12s}{newline}"
	desc = string.format(desc,Language.WangChengZhengBa.GuildRank,Language.WangChengZhengBa.JiFen)
	RichTextUtil.ParseRichText(self.rich_text,desc)



	if v.other_guild_list then
		list = v.other_guild_list
		local len = #list 
		if len > 3 then
			len = 3
		end	
		for i = 1,  len do
			local info = list[i]
			info.index = i
			self.paimin_list[i]:SetData(info) 
		end	
		for i = len + 1,#self.paimin_list do
			self.paimin_list[i]:SetData(nil) 
		end	
		
	end	
	

	
end	


function MainuiSbkActGuide:CreateCountDownTimer()
	if not self.count_down_timer then
		self.count_down_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetRestTime, self, -1), 1)
	end
end


function MainuiSbkActGuide:DelCountDownTimer()
	if self.count_down_timer then
		GlobalTimerQuest:CancelQuest(self.count_down_timer)
		self.count_down_timer = nil
	end
end

function MainuiSbkActGuide:SetRestTime(changeNum)
	
	self.show_data.remain_time = self.show_data.remain_time + changeNum

	if self.show_data.remain_time >= 0 then
		local remTime = TimeUtil.FormatSecond(self.show_data.remain_time, 2)
		self.remin_time:setString(remTime)
	else
		self:DelCountDownTimer()
	end
end

function MainuiSbkActGuide:OnFunNoteVisibleChange(visible)
	if visible then
		self.mt_layout_root:setPosition(self.mt_layout_root:getPositionX(),self.global_y - 100)
	else
		self.mt_layout_root:setPosition(self.mt_layout_root:getPositionX(),self.global_y)
	end	
end	


-------------------排名cell----------------------
GuildRankCell = GuildRankCell or BaseClass(BaseRender)

function GuildRankCell:__init()
	self.index_text = nil
	self.name_text = nil
	self.jifen_text = nil
	self:CreateElement()

	self:SetContentSize(270,45)
end	

function GuildRankCell:__delete()
	self.name_text = nil
	self.jifen_text = nil
end	


function GuildRankCell:SetData(data)
	self.data = data
	if data then
		self.index_text:setString(data.index)
		self.name_text:setString(data.guild_name)
		self.jifen_text:setString(data.jifen)
	else
		self.index_text:setString("")
		self.name_text:setString("")
		self.jifen_text:setString("")
	end
	--PrintTable(data)
end

function GuildRankCell:CreateElement()
	local size = self.view:getContentSize()
	self.index_text = XUI.CreateText(8,size.height * 0.5,50,0,cc.TEXT_ALIGNMENT_LEFT," ")
	self.index_text:setAnchorPoint(0,0.5)
	self.view:addChild(self.index_text)
	self.name_text = XUI.CreateText(50,size.height * 0.5,180,0,cc.TEXT_ALIGNMENT_LEFT," ")
	self.name_text:setAnchorPoint(0,0.5)
	self.view:addChild(self.name_text)
	self.jifen_text = XUI.CreateText(210,size.height * 0.5,100,0,cc.TEXT_ALIGNMENT_LEFT," ")
	self.jifen_text:setAnchorPoint(0,0.5)
	self.view:addChild(self.jifen_text)
end	