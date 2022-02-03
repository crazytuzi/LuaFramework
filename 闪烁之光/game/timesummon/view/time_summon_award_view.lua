--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-02-20 15:48:16
-- @description    : 
		-- 限时召唤奖励预览界面
---------------------------------

local _controller = TimesummonController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

TimeSummonAwardView = TimeSummonAwardView or BaseClass(BaseView)

function TimeSummonAwardView:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "action/action_time_summon_award"

	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("timesummon","timesummon"), type = ResourcesType.plist },
	}

	self.up_item_list = {}
	self.probability_list = {}
	self.view_num = 10
end

function TimeSummonAwardView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
	self:playEnterAnimatianByObj(container, 2)
	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("奖励详情"))

	self.time_label = container:getChildByName("time_label")

	self.close_btn = container:getChildByName("close_btn")

	local list_panel = container:getChildByName("list_panel")
	self.scroll_size = list_panel:getContentSize()
	self.desc_scrollview = createScrollView(self.scroll_size.width, self.scroll_size.height, 0, 0, list_panel)
end

function TimeSummonAwardView:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openTimeSummonAwardView(false)
	end, false, 2)
	 	 	
end

function TimeSummonAwardView:openRootWnd( group_id, data, text_elite )
	self.text_elite = text_elite or nil
	self.group_id = group_id
	self.data = data
	self:setData()
end

function TimeSummonAwardView:setData(  )
	if not self.group_id then return end

	local container_height = 0

	local pro_config = Config.RecruitHolidayData.data_probability[self.group_id]
	if self.text_elite == TimesummonConst.ActonInfoType.EliteType then
		pro_config = Config.RecruitHolidayEliteData.data_probability[self.group_id]
	elseif self.text_elite == TimesummonConst.ActonInfoType.ElfinType or self.text_elite == TimesummonConst.ActonInfoType.ElfinType2 then
		pro_config = Config.HolidaySpriteLotteryData.data_probability[self.group_id]
	elseif self.text_elite == TimesummonConst.ActonInfoType.EliteType2 then
		pro_config = Config.RecruitHolidayLuckyData.data_probability[self.group_id]
	end
	local up_con_height = 0

	if self.text_elite ~= TimesummonConst.ActonInfoType.EliteType2 then -- 不等于自选精英召唤
		if pro_config then
			local up_item_data = {}
			if self.text_elite == TimesummonConst.ActonInfoType.ElfinType2 then
				local elfinData =  ElfinController:getInstance():getModel():getElfinSummonData()
				if elfinData and elfinData.lucky_ids ~= nil and next(elfinData.lucky_ids) ~= nil then
					for k,v in pairs(self.data.lucky_ids) do
						_table_insert(up_item_data, {id = v.lucky_sprites_bid, num = 1})
						break
					end
				end
			else
				for i,v in ipairs(pro_config) do
					if v.is_up == 1 then
						_table_insert(up_item_data, v)
					end
				end
			end
			
			-- 本期UP英雄
			if not self.title_bg_1 then
				self.title_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90025"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
				self.title_bg_1:setContentSize(cc.size(610, 44))
				local tempLab = TI18N("本期UP内容")
				if self.text_elite == TimesummonConst.ActonInfoType.ElfinType then
					tempLab = TI18N("本期直升内容")
				elseif self.text_elite == TimesummonConst.ActonInfoType.ElfinType2 then
					tempLab = TI18N("当前许愿精灵")
				end
				local title_txt_1 = createLabel(24, 116, nil, 10, 22, tempLab, self.title_bg_1, nil, cc.p(0, 0.5))
			end
	
			local offset_x = 20
			local num = #up_item_data
			local start_x = self.scroll_size.width * 0.5 - num * (BackPackItem.Width * 0.5 + offset_x*0.5) + (BackPackItem.Width * 0.5 + offset_x*0.5)
			for i,v in ipairs(up_item_data) do
				local item = self.up_item_list[i]
				if item == nil then
					item = BackPackItem.new(true, true)
					item:setDefaultTip(true)
					self.desc_scrollview:addChild(item)
					self.up_item_list[i] = item
				end
				item:setBaseData(v.id, v.num)
				item:setPosition(cc.p(start_x + (i-1) * (BackPackItem.Width + offset_x), 561))--新英雄图标位置
			end
	
			if self.text_elite == TimesummonConst.ActonInfoType.ElfinType2 and num<=0 then
				local title_txt_4 = createLabel(24, cc.c3b(100,50,35), nil, self.title_bg_1:getContentSize().width * 0.5, -70, TI18N("请先将精灵加入许愿池"), self.title_bg_1, nil, cc.p(0.5, 0.5))
			end
	
			up_con_height = 54 + BackPackItem.Height + 16
	
			container_height = up_con_height
		end
	end
	

	-- 描述内容
	local desc_height = 0
	if self.data then
		local summon_cfg = Config.RecruitHolidayData.data_action[self.data.camp_id]
		if self.text_elite == TimesummonConst.ActonInfoType.EliteType then
			summon_cfg = Config.RecruitHolidayEliteData.data_action[self.data.camp_id]
		elseif self.text_elite == TimesummonConst.ActonInfoType.ElfinType or self.text_elite == TimesummonConst.ActonInfoType.ElfinType2 then
			summon_cfg = Config.HolidaySpriteLotteryData.data_action[self.data.camp_id]
		elseif self.text_elite == TimesummonConst.ActonInfoType.EliteType2 then
			summon_cfg = Config.RecruitHolidayLuckyData.data_action[self.data.camp_id]
		end
		if summon_cfg then
			if not self.title_bg_2 then
				self.title_bg_2 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90025"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
				self.title_bg_2:setContentSize(cc.size(610, 44))
				local title_txt_2 = createLabel(24, 116, nil, 10, 22, TI18N("内容详情"), self.title_bg_2, nil, cc.p(0, 0.5))
			end
			if not self.award_desc then
				self.award_desc = createRichLabel(24, cc.c3b(100,50,35), cc.p(0.5, 1), cc.p(self.scroll_size.width*0.5, 430), 10, nil, 580)
				self.desc_scrollview:addChild(self.award_desc)
			end
			self.award_desc:setString(summon_cfg.desc or "")
			local desc_size = self.award_desc:getContentSize()

			desc_height = desc_size.height + 54 + 10
			container_height = container_height + desc_height
		end
	end

		
	local max_height = math.max(self.scroll_size.height, container_height)
	max_height = max_height +  (self.view_num+1)  * 41 
	local begin_pro_y = max_height - up_con_height - desc_height - 54
	-- 概率展示
	local pro_height = 0
	if pro_config then
		if not self.title_bg_3 then
			self.title_bg_3 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90025"), self.scroll_size.width*0.5, 0, cc.p(0.5, 1), true, nil, true)
			self.title_bg_3:setContentSize(cc.size(610, 44))
		end
		local title_txt_3 = createLabel(24, 116, nil, 10, 22, TI18N("概率公示"), self.title_bg_3, nil, cc.p(0, 0.5))
		
		--pro_config == Config.RecruitHolidayEliteData.data_probability[self.group_id]	then  -- 限时召唤
		
		-- image_content:setContentSize(cc.size(107, 34))
		-- image_content:setTouchEnabled(true) -- 限时召唤及精英召唤	
		-- registerButtonEventListener(image_content, function()
		-- 	_controller:openTimeSummonpreviewWindow(true,self.group_id,self.text_elite)
		-- 	end)
		-- local label = createLabel(20, 116, nil, image_content:getContentSize().width * 0.5, 11,TI18N("查看详情"), image_content, nil, cc.p(0.5, 0.5))
		
		if self.text_elite ~= TimesummonConst.ActonInfoType.EliteType2 then
			local image_content = createImage(self.title_bg_3, PathTool.getResFrame("common", "common_1093"), 498, 22, cc.p(0.5,0.5), true, nil, true)--self.title_bg_3:getContentSize().y/2
			local check_label = createRichLabel(22,116, cc.p(0,0.5),cc.p(37, 22))
			check_label:setString(string.format("<div href=xxx>%s</div>", TI18N("查看详情")))
			image_content:addChild(check_label)
			check_label:addTouchLinkListener(function(type, value, sender, pos)
				_controller:openTimeSummonpreviewWindow(true,self.group_id,self.text_elite)
			end, { "click", "href" })
		end
		


		pro_height = 54
		container_height = container_height + 54

		for i,cfg in ipairs(pro_config) do
			if i < (self.view_num + 1) then
			delayRun(self.desc_scrollview, i*2/60, function()
				local pro_txt = self.probability_list[i] 
				if not pro_txt then
					pro_txt = TimeSummonAwardItem.new()--在这里将文本显示方式改变（全部->根据字段判断）
					self.desc_scrollview:addChild(pro_txt)
					self.probability_list[i] = pro_txt
				end
				pro_txt:setData(cfg,self.text_elite)

				pro_height = pro_height + 30 + 10
				container_height = container_height + 30 + 10


				-- local begin_pro_y = max_height - up_con_height - desc_height - 54
				-- for i,txt in ipairs(self.probability_list) do
					local txt_pos_y = begin_pro_y - (i-1)*(30+10)
					self.probability_list[i]:setPosition(cc.p(self.scroll_size.width*0.5, txt_pos_y))
				-- end
			end)
		end
		end
	end

	-- print("#pro_config..... ",#pro_config)
	--max_height = max_height + #pro_config * 41(self.view_num+1) 
	--print(#pro_config)
	--max_height = max_height +  #pro_config* 41 
	--print(max_height)
	self.desc_scrollview:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
	if self.title_bg_1 then
		self.title_bg_1:setPositionY(max_height)
	end
	local up_item_pos_y = max_height - 54 - BackPackItem.Height*0.5 - 4
	for k,item in pairs(self.up_item_list) do
		item:setPositionY(up_item_pos_y)
	end
	if self.title_bg_2 then
		self.title_bg_2:setPositionY(max_height - up_con_height)
	end
	if self.award_desc then
		self.award_desc:setPositionY(max_height - up_con_height - 54)
	end
	if self.title_bg_3 then
		self.title_bg_3:setPositionY(max_height - up_con_height - desc_height)
	end
	
	-- 活动时间
	if self.data then
		if self.text_elite == TimesummonConst.ActonInfoType.ElfinType2 then
			self.time_label:setString("")
		else
			local start_time = TimeTool.getYMD(self.data.start_time)
			local end_time = TimeTool.getYMD(self.data.end_time)
			self.time_label:setString(string.format(TI18N("概率有效期：%s~%s"), start_time, end_time))
		end
		
	end
end

function TimeSummonAwardView:close_callback(  )
	for k,item in pairs(self.up_item_list) do
		item:DeleteMe()
		item = nil
	end
	for k,txt in pairs(self.probability_list) do
		txt:DeleteMe()
		txt = nil
	end
	doStopAllActions(self.desc_scrollview)
	_controller:openTimeSummonAwardView(false)
end

-------------------@ item 
TimeSummonAwardItem = class("TimeSummonAwardItem", function()
    return ccui.Widget:create()
end)

function TimeSummonAwardItem:ctor()
    self:configUI()
    self:register_event()
end

function TimeSummonAwardItem:configUI(  )
	self.size = cc.size(584, 30)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 1))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.star_text = createLabel(24, 1, nil, 0, self.size.height/2, "", self.root_wnd, nil, cc.p(0, 0.5))--星数
    self.name_text = createLabel(24, 1, nil, 160, self.size.height/2, "", self.root_wnd, nil, cc.p(0, 0.5))--名字
    self.type_text = createLabel(24, 1, nil, 320, self.size.height/2, "", self.root_wnd, nil, cc.p(0, 0.5))--类型
    self.num_text = createLabel(24, 1, nil, self.size.width, self.size.height/2, "", self.root_wnd, nil, cc.p(1, 0.5))--概率
end

function TimeSummonAwardItem:register_event(  )
	
end

function TimeSummonAwardItem:setData( data ,type)
	if not data then return end

	self.name_text:setString(data.name)
	
	self.num_text:setString(data.probability .. "%")--概率
	if data.is_up == 1 then
		self.star_text:setString(data.star .. " UP!")
		self.star_text:setTextColor(TimesummonConst.Up_Text_Color)
		self.name_text:setTextColor(TimesummonConst.Up_Text_Color)
		self.type_text:setTextColor(TimesummonConst.Up_Text_Color)
		self.num_text:setTextColor(TimesummonConst.Up_Text_Color)
	else
		self.star_text:setString(data.star)
		self.star_text:setTextColor(TimesummonConst.Not_Up_Text_Color)
		self.name_text:setTextColor(TimesummonConst.Not_Up_Text_Color)
		self.type_text:setTextColor(TimesummonConst.Not_Up_Text_Color)
		self.num_text:setTextColor(TimesummonConst.Not_Up_Text_Color)
	end

	if data.is_chip == 1 then
		self.type_text:setString(TI18N("碎片"))
	else
		if type and (type == TimesummonConst.ActonInfoType.ElfinType or type == TimesummonConst.ActonInfoType.ElfinType2) then
			self.star_text:setString(data.name)
			self.name_text:setString(data.probability .. "%")
			self.num_text:setString("")
		elseif type == TimesummonConst.ActonInfoType.EliteType2 then
			self.type_text:setString("")
		else
			self.type_text:setString(TI18N("英雄"))
		end
	end
end

function TimeSummonAwardItem:DeleteMe(  )
	self:removeAllChildren()
    self:removeFromParent()
end