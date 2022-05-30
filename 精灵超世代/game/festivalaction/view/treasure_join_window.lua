--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 参与夺宝购买界面
-- @DateTime:    2019-05-17 11:25:35
-- *******************************
TreasureJoinWindow = TreasureJoinWindow or BaseClass(BaseView)

local controll = FestivalActionController:getInstance()
local model = controll:getModel()
local const_data = Config.HolidaySnatchData.data_const
local join_goods_list = Config.HolidaySnatchData.data_join_goods_list
local string_format = string.format

local color_text = {
	[1] = cc.c4b(0x95,0x53,0x22,0xff),
	[2] = cc.c4b(0xff,0xf6,0xe4,0xff),
}
--夺宝档次数字
local grade_num = {6,30,128}

function TreasureJoinWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "festivalaction/treasure_join_window"
    self.join_number = 0 --默认参与值
    self.join_max_number = 1 --参与最大值
    self.remain_count = 1 --剩余个数
end

function TreasureJoinWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
    main_container:getChildByName("Image_2"):getChildByName("Text_1"):setString(TI18N("参与夺宝"))
    self.btn_close = main_container:getChildByName("btn_close")
    self.bar = main_container:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar:setPercent(0)
    main_container:getChildByName("join_num_text"):setString(TI18N("满足参与人次时，即抽取1人获得奖品"))
    main_container:getChildByName("Text_3"):setString(TI18N("总需："))
    self.total_text = main_container:getChildByName("total_text")
    self.total_text:setString("")
    main_container:getChildByName("Text_3_0"):setString(TI18N("剩余："))
    self.remain_text = main_container:getChildByName("remain_text")
    self.remain_text:setString("")
    self.btn_join = main_container:getChildByName("btn_join")
    self.btn_join:getChildByName("Text_9"):setString(TI18N("立即参与"))
    main_container:getChildByName("time_0"):setString(TI18N("活动剩余："))
    self.time = main_container:getChildByName("time")
    self.time:setString("")
    main_container:getChildByName("Text_10"):setString(TI18N("消耗："))

    local join_bg = main_container:getChildByName("join_bg")
    join_bg:getChildByName("Text_11"):setString(TI18N("参与人次"))
    self.btn_minus = join_bg:getChildByName("btn_minus")
    self.btn_add = join_bg:getChildByName("btn_add")
    self.btn_10 = join_bg:getChildByName("btn_10")
    self.btn_10:getChildByName("Text_12"):setString(grade_num[1])
    self.btn_50 = join_bg:getChildByName("btn_50")
    self.btn_50:getChildByName("Text_12"):setString(grade_num[2])
    self.btn_100 = join_bg:getChildByName("btn_100")
    self.btn_100:getChildByName("Text_12"):setString(grade_num[3])
    self.join_num = join_bg:getChildByName("join_num")
    self.join_num:setString("")

    self.text_Field = join_bg:getChildByName("text_Field")
    local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        	self:inputConsumeNumber()
        elseif eventType == ccui.TextFiledEventType.insert_text then
        	self:inputConsumeNumber()
        elseif eventType == ccui.TextFiledEventType.delete_backward then
        	if self.text_Field:getString() == "" then
        		message(TI18N("亲，参与人次不能为空哦~~~"))
        		return
        	end
        	self:inputConsumeNumber()
        end
    end
    self.text_Field:setPlaceHolderColor(FestivalActionConst.ColorConst[2])
	self.text_Field:setTextColor(FestivalActionConst.ColorConst[2])
    self.text_Field:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.text_Field:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self.text_Field:addEventListener(textFieldEvent)

    self.goods_item = BackPackItem.new(nil,true,nil,1.0,false,true)
    main_container:addChild(self.goods_item)
    self.goods_item:setPosition(cc.p(105, 412))
    
    --人次消耗
	self.join_term = createRichLabel(22, color_text[1], cc.p(0.5,0.5), cc.p(236,99), nil, nil, nil)
	join_bg:addChild(self.join_term)
	
	--参与消耗
	self.consume_term = createRichLabel(22, color_text[2], cc.p(0,0.5), cc.p(235,155), nil, nil, nil)
	main_container:addChild(self.consume_term)
end

--输入框
function TreasureJoinWindow:inputConsumeNumber()
	local input = self.text_Field:getString()
	local input_num = tonumber(self.text_Field:getString())
	if type(input_num) == "number" then
		if input_num >= self.join_max_number then
			message(TI18N("已到达个人购买上限~~~"))
			input_num = self.join_max_number
		end
		if input_num >= self.remain_count then
			message(TI18N("已到达个人购买上限~~~"))
			input_num = self.remain_count
		end
		self.join_number = input_num
		self:consumeCalculat()
	else
		message(TI18N("亲，参与人次只能输入数字哦~~~"))
	end
end

function TreasureJoinWindow:openRootWnd(data, item_data)
	if not data or not item_data then return end
	self.join_item_data = item_data
	self.my_join_count = 0

	if item_data.ext then
		local my_join_list = keyfind('key', 1, item_data.ext) or nil
		if my_join_list then
			self.my_join_count = my_join_list.val or 0
		end
	end

	local join_id = item_data.id or 0
	if join_goods_list[join_id] then
		self.join_max_number = join_goods_list[join_id].limit_role_max - self.my_join_count --个人剩余购买次数
		if self.join_max_number <= 0 then
			self.join_max_number = 0
		end
	end
	--玩家单次消耗的夺宝门票
	if data.award and data.award[1] then
		self.goods_item:setBaseData(data.award[1][1],data.award[1][2])
	end
	if data.expend and data.expend[1] then
		self.consume_icon_num = data.expend[1][1] or 0
		self.consume_num = data.expend[1][2] or 0 --参与一次消耗多少
		local item_config = Config.ItemData.data_get_data(self.consume_icon_num)
		if item_config then
			local res = PathTool.getItemRes(item_config.icon)
			local str = string_format(TI18N("%d <img src=%s visible=true scale=0.30 />/人次"),self.consume_num,res)
			self.join_term:setString(str)
		end
	end

	--门票物品bid
	local const = Config.HolidaySnatchData.data_const
	if const and const.item_ticket and const.item_ticket.val then
		self.item_ticket = const.item_ticket.val
	end

	self.my_join_totle = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.item_ticket)
	self.join_max_number = math.min(self.join_max_number,self.my_join_totle)

	self:consumeCalculat(self.join_number)
	self:setData(item_data)

	local time = model:getCountDownTime()
	model:CountDownTime(self.time, time)
end

-- data:  item 的数据
function TreasureJoinWindow:setData(data)
	local id = data.id or 0
	if join_goods_list and join_goods_list[id] then
		local limit_max = join_goods_list[id].limit_max or 0
		local num = data.num or 0
		self.total_text:setString(limit_max)
		local remain_num = limit_max - num
		if remain_num <= 0 then
			remain_num = 0
		end
		self.remain_count = remain_num

		self.remain_text:setString(remain_num)
		local percent = num / limit_max * 100
		self.bar:setPercent(percent)
	end
end
function TreasureJoinWindow:register_event()
	self:addGlobalEvent(FestivalActionEvent.TreasureMessage, function(data)
		if self.join_item_data and self.join_item_data.pos then
			self:buyReturnMessage(data)
		end
	end)

	registerButtonEventListener(self.background, function()
		controll:openTreasureJoinView(false)
	end,false, 2)
	registerButtonEventListener(self.btn_close, function()
		controll:openTreasureJoinView(false)
	end,true, 2)

	registerButtonEventListener(self.btn_join, function()
		if self.join_number == 0 then
			message("亲，参与次数不能为0哦~~~")
			return
		end
		if self.join_item_data and self.item_ticket then
			if self.item_ticket < (self.join_number*self.consume_num) then
				message(TI18N("亲，门票不够哦~~~"))
			else
				local input = tonumber(self.text_Field:getString())
				if type(input) == "number" then
					local pos = self.join_item_data.pos or 0
					controll:sender25701(pos,input)
				else
					message(TI18N("亲，参与人次只能输入数字哦~~~"))
				end
			end
		end
	end,true, 1)
	registerButtonEventListener(self.btn_minus, function()
		self:minusJoinNumber()
	end,true, 1)
	registerButtonEventListener(self.btn_add, function()
		self:addJoinNumber()
	end,true, 1)
	registerButtonEventListener(self.btn_10, function()
		self:addJoinNumberType(1)
	end,true, 1)
	registerButtonEventListener(self.btn_50, function()
		self:addJoinNumberType(2)
	end,true, 1)
	registerButtonEventListener(self.btn_100, function()
		self:addJoinNumberType(3)
	end,true, 1)
end

--购买返回的信息
function TreasureJoinWindow:buyReturnMessage(data)
	local pos = self.join_item_data.pos
	local item_data
	for i,v in pairs(data.holiday_snatch_info) do
		if v.pos == pos then
			item_data = v
			break
		end
	end
	if item_data then
		if join_goods_list[item_data.id] then
			self:setData(item_data)
		end
	end
end

--
function TreasureJoinWindow:addJoinNumber()
	if self.join_number >= self.join_max_number or self.join_number >= self.remain_count then
		message(TI18N("已到达参与最大值"))
		return
	end
	self.join_number = self.join_number + 1
	if self.join_number >= self.join_max_number then
		self.join_number = self.join_max_number
	end
	self:consumeCalculat(self.join_number)
end
--
function TreasureJoinWindow:addJoinNumberType(num)
	-- if (self.join_number+num) >= self.join_max_number or (self.join_number+num) >= self.remain_count then
	-- 	if (self.join_number+num) >= self.join_max_number then
	-- 		self.join_number = self.join_max_number
	-- 	elseif (self.join_number+num) >= self.remain_count then
	-- 		self.join_number = self.remain_count
	-- 	end
	-- 	self:consumeCalculat(self.join_number)
	-- 	message(TI18N("参与次数不能超过最大值哦~~~"))
	-- 	return
	-- end
	-- if self.join_number >= self.join_max_number or self.join_number >= self.remain_count then
	-- 	message(TI18N("已到达参与最大值"))
	-- 	return
	-- end

	-- self.join_number = self.join_number + num
	-- if self.join_number >= self.join_max_number then
	-- 	self.join_number = self.join_max_number
	-- end

	if grade_num[num] >= self.join_max_number or grade_num[num] >= self.remain_count then
		if grade_num[num] >= self.join_max_number then
			self.join_number = self.join_max_number
		elseif grade_num[num] >= self.remain_count then
			self.join_number = self.remain_count
		end
		self:consumeCalculat(self.join_number)
		message(TI18N("参与次数不能超过最大值哦~~~"))
		return
	end

	self.join_number = grade_num[num]
	self:consumeCalculat(self.join_number)
end
--
function TreasureJoinWindow:minusJoinNumber()
	if self.join_number <= 1 then
		message(TI18N("参与次数不能少于1哦~~~"))
		return
	end
	self.join_number = self.join_number - 1
	if self.join_number <= 1 then
		self.join_number = 1
	end
	self:consumeCalculat(self.join_number)
end
--参与物品消耗计算
function TreasureJoinWindow:consumeCalculat()
	self.text_Field:setString(self.join_number)
	self:showConsume()
end

--显示消耗
function TreasureJoinWindow:showConsume()
	if self.consume_num ~= 0 and self.consume_icon_num ~= 0 then
		local item_config = Config.ItemData.data_get_data(self.consume_icon_num)
		if item_config then
			local res = PathTool.getItemRes(item_config.icon)
			local consume = self.join_number * self.consume_num
			local str = string_format(TI18N("<img src=%s visible=true scale=0.30 /> %s/%s"),res,self.my_join_totle,consume)
			self.consume_term:setString(str)
		end
	end
end

function TreasureJoinWindow:close_callback()
	doStopAllActions(self.time)
	if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end
	controll:openTreasureJoinView(false)
end