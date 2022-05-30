--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-02-20 15:59:19
-- @description    : 
		-- 限时召唤的奖励进度界面
---------------------------------

local _controller = TimesummonController:getInstance()
local _model = _controller:getModel()

TimeSummonProgressView = TimeSummonProgressView or BaseClass(BaseView)

function TimeSummonProgressView:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "action/action_time_summon_progress"

	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("timesummon","timesummon"), type = ResourcesType.plist },
	}

	self.award_item_list = {}  -- 奖励item列表
end

function TimeSummonProgressView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
	self:playEnterAnimatianByObj(self.container, 2)
	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("查看奖励"))

	self.close_btn = container:getChildByName("close_btn")
	self.summon_num_txt = container:getChildByName("title_txt_1")

	self.progress = container:getChildByName("progress")
	self.progress:setScale9Enabled(true)
    --self.progress:setPercent(60)
	
	local time_label = container:getChildByName("time_label")
	time_label:setString(TI18N("限定召唤期间达到指定招募次数可获对应奖励"))
end

function TimeSummonProgressView:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openTimeSummonProgressView(false)
	end, false, 2)
end

function TimeSummonProgressView:openRootWnd( times, camp_id, up_hero_id, reward_list)
	self.cur_times = times
	self.camp_id = camp_id
	self.item_up_hero_id = up_hero_id
	self.reward_list = reward_list
	self:setData()
end

function TimeSummonProgressView:setData(  )
	if not self.cur_times or not self.camp_id then
		return
	end
	self.summon_num_txt:setString(string.format(TI18N("当前已招募次数：%d"), self.cur_times))

	local award_config = Config.RecruitHolidayData.data_award[self.camp_id]
	local status = EliteSummonController:getInstance():getModel():isHolidayHasID(self.camp_id)
	if status then
		award_config = Config.RecruitHolidayEliteData.data_award[self.camp_id]
	end

	local status = EliteSummonController:getInstance():getModel():isHolidayLuckyHasID(self.camp_id)
	if status then
		award_config = Config.RecruitHolidayLuckyData.data_award[self.camp_id]
	end
	local start_x = 100
	local distance_x = 523
	if award_config then
		local max_times = award_config[#award_config].times
		local offset_x = (distance_x - start_x + 60.5)/(#award_config-1)
		for i,v in ipairs(award_config) do
			v.status = false
			if self.reward_list then
				for m,n in pairs(self.reward_list) do
					if v.id == n.id then
						v.status = true 
						break
					end
				end
			end
			local item = self.award_item_list[i]
			if item == nil then
				item = TimeSummonProgressItem.new(self.cur_times, self.item_up_hero_id)
				self.container:addChild(item)
				self.award_item_list[i] = item
			end
			item:setVisible(true)
			item:setData(v)
			local pos_x = start_x + (i-1)*offset_x
			item:setPosition(cc.p(pos_x, 150.5))
		end

		-- 计算进度条
		local last_times = 0
		local progress_width = 523
		local first_off = start_x-60.5 -- 0到第一个的距离
		local percent = 0
		local distance = 0
		for i,v in ipairs(award_config) do
			if i == 1 then
				if self.cur_times <= v.times then
					distance = (self.cur_times/v.times)*first_off
					break
				else
					distance = first_off
				end
			else
				if self.cur_times <= v.times then
					distance = distance + ((self.cur_times-last_times)/(v.times-last_times))*offset_x
					break
				else
					distance = distance + offset_x
				end
			end
			last_times = v.times
		end
		self.progress:setPercent(distance/progress_width*100)
	end
end

function TimeSummonProgressView:close_callback(  )
	for k,item in pairs(self.award_item_list) do
		item:DeleteMe()
		item = nil
	end
	TipsManager:getInstance():hideTips()
	_controller:openTimeSummonProgressView(false)
end

---------------------------@ item
TimeSummonProgressItem = class("TimeSummonProgressItem", function()
    return ccui.Widget:create()
end)

function TimeSummonProgressItem:ctor(cur_times, item_up_hero_id)
	self.cur_times = cur_times
	self.cur_item_up_hero_id = item_up_hero_id
    self:configUI()
    self:register_event()
end

function TimeSummonProgressItem:configUI(  )
	self.size = cc.size(84, 122)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.award_item = BackPackItem.new(true, true, false, 0.7)
    local function source_callback(item)
    	if item and item:getData() and self.item_data and self.item_data.id == 5 then
    		local arard_data = Config.RecruitHolidayLuckyData.data_award
    		if arard_data[self.item_data.camp_id] and arard_data[self.item_data.camp_id][self.item_data.id].self_reward and arard_data[self.item_data.camp_id][self.item_data.id].self_reward[1] then
	    		if self.item_data.status then
	    			TipsManager:getInstance():hideTips()
	    			message(TI18N("你已领取过该奖励"))
	    		else
		    		TipsManager:getInstance():hideTips()
		    		TimesummonController:getInstance():openHeroSelectView(true, self.item_data, self.cur_times)
		    		TimesummonController:getInstance():openTimeSummonProgressView(false)
		    	end
	    	end
    	end
    end
    self.award_item:setDefaultTip(true,nil,source_callback)
    self.award_item:setAnchorPoint(cc.p(0.5, 1))
    self.award_item:setPosition(cc.p(self.size.width/2, self.size.height))
    self.root_wnd:addChild(self.award_item)

    self.times_txt = createLabel(22,cc.c3b(100,50,35),nil,self.size.width/2,-5,"",self.root_wnd,nil,cc.p(0.5, 1))

    local arrow = createSprite(PathTool.getResFrame("timesummon","timesummon_1004"), self.size.width/2, self.size.height-86, self.root_wnd, cc.p(0.5, 1))
    -- local line = createSprite(PathTool.getResFrame("timesummon","timesummon_1005"), self.size.width/2, 0, self.root_wnd, cc.p(0.5,0))
end

function TimeSummonProgressItem:setData( data )
	if not data then return end

	self.item_data = data
	local reward = data.reward
	if reward then
		local bid
		local num
		if data.id == 5 then
			if reward[1] then
				bid = reward[1][1]
				num = reward[1][2]
			else
				if data.self_reward[1] then
					bid = 39093
					num = 0
				end
			end
		else
			bid = reward[1][1]
			num = reward[1][2]
		end

		self.award_item:setBaseData(bid, num)
		if data.status then
			self.award_item:setReceivedIcon(true)
		else
			self.award_item:setReceivedIcon(false)
		end
	end
	self.times_txt:setString(data.times)
end

function TimeSummonProgressItem:register_event(  )
end

function TimeSummonProgressItem:DeleteMe(  )
	if self.award_item then
		self.award_item:DeleteMe()
		self.award_item = nil
	end
	self:removeAllChildren()
    self:removeFromParent()
end