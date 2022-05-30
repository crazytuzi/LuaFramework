--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 清明活动
-- @DateTime:    2019-03-28 20:29:34
QingMingPanel = class("QingMingPanel", function()
    return ccui.Widget:create()
end)
local controller = ActionController:getInstance()
local string_format = string.format
function QingMingPanel:ctor(holiday_bid)
	self.holiday_bid = holiday_bid
	self:loadResources()
end

function QingMingPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("festivalaction","festivalaction"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
        	self:loadResListCompleted()
        end
    end)
end
function QingMingPanel:loadResListCompleted()
	self:configUI()
    self:register_event()
end
function QingMingPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("festivalaction/qingming_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local festival_bg = main_container:getChildByName("title_img")
    local res = PathTool.getPlistImgForDownLoad("bigbg/festivalaction", "txt_cn_festival_qingming_panel")
    if not self.festival_bg_load then
        self.festival_bg_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(festival_bg) then
                loadSpriteTexture(festival_bg, res, LOADTEXT_TYPE)
            end
        end,self.festival_bg_load)
    end

    self.btn_tesk = main_container:getChildByName("btn_tesk")
    self.btn_tesk:getChildByName("label"):setString(TI18N("收集活跃值"))
    self.btn_buy = main_container:getChildByName("btn_buy")
    self.btn_buy:getChildByName("label"):setString(TI18N("购买活跃值"))
    self.time = main_container:getChildByName("time")
    local desc_text = main_container:getChildByName("desc_text")
    desc_text:setString(TI18N("完成日常任务获得等量活跃值，累积达到指定数量，可获得奖励"))

    self.day_layer = {}
    for i=1,7 do
    	local tab = {}
    	tab.layer_bg = main_container:getChildByName("day_"..i)

    	tab.item = BackPackItem.new(nil,true,nil,0.8,nil,true)
	    tab.layer_bg:addChild(tab.item)
	    tab.item:setPosition(cc.p(92, 91))
	    tab.item:setIsShowBackground(false)

    	tab.item_num = tab.layer_bg:getChildByName("item_num")
    	tab.item_num:setString("")
    	tab.item_num:setLocalZOrder(10)
    	tab.num = tab.layer_bg:getChildByName("num")
    	tab.get_spr = tab.layer_bg:getChildByName("get_spr")
    	tab.get_spr:setLocalZOrder(11)
    	tab.get_spr:setVisible(false)
    	tab.btn_get = tab.layer_bg:getChildByName("btn_get")
    	self.day_layer[i] = tab
    end

    self.active_degree_text = main_container:getChildByName("active_degree_text")
	controller:cs16603(ActionRankCommonType.qingming)
end
function QingMingPanel:register_event()
	if not self.update_qingming_event then
        self.update_qingming_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if not data then return end
            if data.bid == self.holiday_bid then
            	if data and data.finish then
                	self.active_degree_text:setString(data.finish)
                end
                self:setFixedData(data)
                self:setTeskInfo(data)
                self.qingming_data = data
            end
        end)
    end

	registerButtonEventListener(self.btn_tesk, function()
		StrongerController:getInstance():clickCallBack(129)
	end,true, 1)
	registerButtonEventListener(self.btn_buy, function()
		if self.qingming_data then
			self:setBuyData(self.qingming_data)
		end
	end,true, 1)
	for i,v in pairs(self.day_layer) do
		registerButtonEventListener(v.btn_get,function()
			if self.qingming_data and self.holiday_bid then
				controller:cs16604(self.holiday_bid,self.qingming_data.aim_list[i].aim)
			end
		end,false,1)
	end
end
function QingMingPanel:setFixedData(data)
	if self.qingming_data then return end
	if data and data.args and data.aim_list then
		local start_time,end_time
	    local start_list = keyfind('args_key', 1, data.args) or nil
	    if start_list then
	    	start_time = start_list.args_val
	    end
	    local end_list = keyfind('args_key',2,data.args) or nil
	    if end_list then
	    	end_time = end_list.args_val
	    end
	    if start_time and end_time then
	        local time_str = string_format(TI18N("活动时间：%s 至 %s"),TimeTool.getYMD2(start_time),TimeTool.getYMD2(end_time))
	        self.time:setString(time_str)
	    end
	    for i,v in pairs(data.aim_list) do
	    	local item_config = Config.ItemData.data_get_data(v.item_list[1].bid)
	    	if item_config and self.day_layer[v.aim] and self.day_layer[v.aim].item then
	    		local res = PathTool.getItemRes(item_config.icon)
	    		if item_config.icon == 3 then
	    			self.day_layer[v.aim].item:setScale(0.6)
	    		else
	    			self.day_layer[v.aim].item:setScale(0.75)
	    		end
	    		self.day_layer[v.aim].item:setBaseData(v.item_list[1].bid)
	    		if v.item_list[1].num == 1 then
	    			self.day_layer[v.aim].item_num:setString("")
	    		else
		    		self.day_layer[v.aim].item_num:setString(v.item_list[1].num)
		    	end
	    	end
	    	local tesk_num
			local tesk_list = keyfind('aim_args_key',2,v.aim_args) or nil
			if tesk_list then
				tesk_num = tesk_list.aim_args_val
			end
			if tesk_num and self.day_layer[v.aim] and self.day_layer[v.aim].num then
				self.day_layer[v.aim].num:setString(tesk_num)
			end
	    end
	end
end
function QingMingPanel:setTeskInfo(data)
	if data.aim_list then
		self:stopRoundAction()
		for i,v in pairs(data.aim_list) do
			if v.status == 0 then
				self.day_layer[v.aim].item:setDefaultTip(true)
			elseif v.status == 1 then
				self.day_layer[v.aim].item:setDefaultTip(false)

				local function func()
					if self.holiday_bid then
						controller:cs16604(self.holiday_bid, data.aim_list[i].aim)
					end
				end
				self.day_layer[v.aim].item:addCallBack(func)

				local skewto_1 = cc.RotateTo:create(0.5, 3)
				local skewto_2 = cc.RotateTo:create(0.5, -3)
				local skewto_3 = cc.RotateTo:create(0.25, 0)
				local seq = cc.Sequence:create(skewto_1,skewto_2, skewto_1,skewto_2,skewto_3,cc.DelayTime:create(0.5))
				local repeatForever = cc.RepeatForever:create(seq)
			    self.day_layer[v.aim].layer_bg:runAction(repeatForever)
			elseif v.status == 2 then
				self.day_layer[v.aim].item:setDefaultTip(false)
				self.day_layer[v.aim].get_spr:setVisible(true)
				local skewto = cc.RotateTo:create(0.01, 0)
				self.day_layer[v.aim].layer_bg:runAction(cc.Sequence:create(skewto))
			end
		end
	end
end
function QingMingPanel:stopRoundAction()
	for i,v in pairs(self.day_layer) do
		if v.layer_bg then
			doStopAllActions(v.layer_bg)
		end
	end
end
function QingMingPanel:setBuyData(data)
	local buy_data = {}
	buy_data.bid = data.bid
	buy_data.aim = 0
	buy_data.item_bid = 80221
	buy_data.pay_type = 3
	buy_data.name = "活跃值"
	buy_data.shop_type = MallConst.MallType.FestivalAction
	buy_data.is_show_limit_label = true

	local buy_price,limit_num,has_num,action_price = 0,0,0,0
    --限购次数
    local limit_list = keyfind('args_key',3,data.args) or nil
    if limit_list then
    	limit_num = limit_list.args_val
    end
    buy_data.limit_num = limit_num

	--已经买的次数
	local has_list = keyfind('args_key',4,data.args) or nil
	if has_list then
		has_num = has_list.args_val
	end
	buy_data.has_buy = has_num

	--买一次要用多少钻石
	local buy_list = keyfind('args_key',5,data.args) or nil
    if buy_list then
    	buy_price = buy_list.args_val
    end
    buy_data.price = buy_price

    --买一次得到多少活跃值
	local action_list = keyfind('args_key',6,data.args) or nil
    if action_list then
    	action_price = action_list.args_val
    end
    buy_data.quantity = action_price

    if (buy_data.limit_num - buy_data.has_buy) > 0 then
		MallController:getInstance():openMallBuyWindow(true,buy_data)
	else
		message(TI18N("今日已购完"))
	end
end

function QingMingPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end
function QingMingPanel:DeleteMe()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.festival_bg_load then
        self.festival_bg_load:DeleteMe()
        self.festival_bg_load = nil
    end
    self:stopRoundAction()
    if self.update_qingming_event then
        GlobalEvent:getInstance():UnBind(self.update_qingming_event)
        self.update_qingming_event = nil
    end
end
