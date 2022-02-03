--**********************
--英雄远征
--**********************
HeroExpeditWindow = HeroExpeditWindow or BaseClass(BaseView)

local controller = HeroExpeditController:getInstance()
local map_center = 360  --地图移动的中心点
local sign_info = Config.ExpeditionData.data_sign_info
local point_num = Config.ExpeditionData.data_sign_info_length --个数(宝箱和点)
local box_num = 5 --宝箱个数
function HeroExpeditWindow:__init()
    self.is_full_screen = true
    self.layout_name = "heroexpedit/hero_expedit_window"
    self.res_list = {
    	{path = PathTool.getPlistImgForDownLoad("heroexpedit", "heroexpedit"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/heroexpedit","heroexpedit_bg",true), type = ResourcesType.single },
	}
	self.box_index = 0
	self.model_index = 1 --模式选择
    self.box_list = {} --宝箱
    self.point_list = {} --点
    self.facial_list = {} --表情包
    self.play_effect = {}
end

function HeroExpeditWindow:open_callback()
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
	self.expedit_bg = self.root_wnd:getChildByName("bg")

	self.close_btn = self.main_container:getChildByName("btn_return")
	self.map_layer = self.main_container:getChildByName("map_layer")
	self.btn_employ = self.main_container:getChildByName("btn_employ")
	self.btn_employ:getChildByName("Text_1"):setString(TI18N("好友助阵"))
	self.btn_shop = self.main_container:getChildByName("btn_shop")
	self.btn_shop:getChildByName("Text_1_0"):setString(TI18N("远征商店"))
	self.btn_rule = self.main_container:getChildByName("btn_rule")

	self.get_reward_bg = self.main_container:getChildByName("get_reward_bg")
	self.get_reward_bg:getChildByName("Image_2"):getChildByName("Text_2"):setString(TI18N("今日已获取奖励："))

	local top_panel = self.main_container:getChildByName("top_panel")
	local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
	top_panel:setPositionY(display.getTop()-top_height+12)
	self.expedit_title = top_panel:getChildByName("Text_10")
	self.expedit_title:setString(TI18N("英雄远征"))
	self.model_name_text = {TI18N(" （普通）"),TI18N(" （困难）"),TI18N(" （地狱）")}
	self.model_name = top_panel:getChildByName("model_name")
	self.model_name:setString("")

	self.expedit_reward = {}
	local pos = {72,33}
	for i=1,2 do
		self.expedit_reward[i] = createRichLabel(24, cc.c4b(0xff,0xf6,0xc7,0xff), cc.p(0,0.5), cc.p(0,0), nil, nil, 250)
	    self.get_reward_bg:addChild(self.expedit_reward[i])
	    self.expedit_reward[i]:setPosition(35,pos[i])
	end
end

function HeroExpeditWindow:register_event()
	self:addGlobalEvent(HeroExpeditEvent.HeroExpeditViewEvent,function(data)
		if not data then return end
		self:setExpeditLevelMessage(data)
	end)
	self:addGlobalEvent(HeroExpeditEvent.Get_Box_Event,function(box_id)
		self:checkBoxStatus(2, box_id)
	end)
	self:addGlobalEvent(HeroExpeditEvent.MeHelp_RedPoint_Event,function(data)
		local status = controller:getModel():getHeroSendRedPoint()
		addRedPointToNodeByStatus(self.btn_employ, status)
	end)
	self:addGlobalEvent(HeroExpeditEvent.Expedit_Clear_Event,function(data)
		self:clearGuard(data.guard_id)
	end)
	registerButtonEventListener(self.close_btn, function()
        controller:openHeroExpeditView(false)
    end,true, 2)
	registerButtonEventListener(self.btn_employ, function()
        controller:openEmpolyPanelView(true)
    end,true, 1)
	registerButtonEventListener(self.btn_shop, function()
       	MallController:getInstance():openMallPanel(true, MallConst.MallType.FriendShop)
    end,true, 1)
    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
       	local config = Config.ExpeditionData.data_const.game_rule
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end,true, 1)
    
end
--关卡的状态
function HeroExpeditWindow:setExpeditLevelMessage(data)
	for i,v in pairs(data.rewards) do
		local item_config = Config.ItemData.data_get_data(v.bid)
    	local res = PathTool.getItemRes(item_config.icon)
    	local str = string.format("<img src=%s visible=true scale=0.35 />  %d",res,v.num)
    	self.expedit_reward[i]:setString(str)
	end

	local mode = controller:getModel():getDifferentChoose()
	if mode == 4 then
		self.expedit_title:setPositionX(188)
	else
		self.model_name:setString(self.model_name_text[mode] or "")
	end

	if self.point_list[data.guard_id] then
		setChildUnEnabled(false, self.point_list[data.guard_id])
		local num = data.guard_id or 1
		local box = controller:getModel():getExpeditBoxData()
		local status = false
		--胜利关卡的下一关是否是宝箱的位置
		for i,v in pairs(box) do
			if v == (data.guard_id-1) then
				status = true
				break
			end
		end
		--计算最后两个的状态
		if status == true then
			num = num - 2
		else
			num = num - 1
		end
		if num <= 0 then
			num = 1
		end

		if not self.facial_list[data.guard_id] then
			self.point_list[data.guard_id]:setContentSize(cc.size(38,100))
			self.facial_list[data.guard_id] = createSprite(PathTool.getResFrame("heroexpedit","heroexpedit_8"), 0, 40, self.point_list[data.guard_id], cc.p(0,0), LOADTEXT_TYPE_PLIST, 1)
		else
			if self.facial_list[data.guard_id] then
				loadSpriteTexture(self.facial_list[data.guard_id], PathTool.getResFrame("heroexpedit","heroexpedit_8"))
			end
		end

		if self.facial_list[num] then
			loadSpriteTexture(self.facial_list[num], PathTool.getResFrame("heroexpedit","heroexpedit_7"))
		end
		--最后一关时
		if data.guard_id == (point_num-1) then
			if self.facial_list[data.guard_id] then
				loadSpriteTexture(self.facial_list[data.guard_id], PathTool.getResFrame("heroexpedit","heroexpedit_8"))
			end
		end
	end
	if data.guard_id > point_num then
		if self.facial_list[point_num-1] then
			loadSpriteTexture(self.facial_list[point_num-1], PathTool.getResFrame("heroexpedit","heroexpedit_7"))
		end
	end
	local box_data = controller:getModel():getExpeditBoxData()
	local pos_status = 0
	for i,v in pairs(box_data) do
		if v == data.guard_id-1 then
			pos_status = 1
			for k,val in pairs(data.reward) do
				if val.reward_id == data.guard_id-1 then
					pos_status = 2
					break
				end
			end
		end
	end
	self:checkBoxStatus(pos_status, data.guard_id-1)
end
--宝箱的状态
function HeroExpeditWindow:checkBoxStatus(status,box_num)
	if box_num <= 0 then return end
	local box_data = controller:getModel():getExpeditBoxData()
	local num = 0
	for i, v in pairs(box_data) do
		if v == box_num then
			num = i
			break
		end
	end
	self:updateTaskList(status, num)
end
function HeroExpeditWindow:registerEvent()
	local function onTouchBegin(touch, event)
        self.touch_point = nil
        doStopAllActions(self.expedit_bg)
        return true
    end
    local function onTouchMoved(touch, event)
        self.touch_point = touch:getDelta()
        local pos_x = self:setBorder(self.touch_point.x)
        self.expedit_bg:setPositionX(pos_x)
    end
	local function onTouchEnded(touch, event)

    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.map_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.map_layer)
end
function HeroExpeditWindow:setBorder(x)
	local pos_x = self.expedit_bg:getPositionX() + x
    if pos_x >= self.move_pos then
    	pos_x = self.move_pos
    end
    if pos_x <= map_center - (self.move_pos-map_center) then
    	pos_x = map_center - (self.move_pos-map_center)
    end
	return pos_x
end

function HeroExpeditWindow:updateTaskList(box_data, box_num)
	local action = PlayerAction.action_1
    if box_data == 0 then
        action = PlayerAction.action_1
    elseif box_data == 1 then
        action = PlayerAction.action_2
    elseif box_data == 2 then
        action = PlayerAction.action_3
    end
    if self.play_effect[box_num] then
        self.play_effect[box_num]:clearTracks()
        self.play_effect[box_num]:removeFromParent()
        self.play_effect[box_num] = nil
    end
    if not tolua.isnull(self.box_list[box_num]) and self.play_effect[box_num] == nil then
        local res_id = PathTool.getEffectRes(110)
        self.play_effect[box_num] = createEffectSpine(res_id, cc.p(self.box_list[box_num]:getContentSize().width * 0.5, 15), cc.p(0, 0), true, action)
        self.box_list[box_num]:addChild(self.play_effect[box_num])
    end
end

function HeroExpeditWindow:openRootWnd()
	local expeditData = controller:getModel():getExpeditData()
	if expeditData or next(expeditData) ~= nil then
		self.expedit_bg:ignoreContentAdaptWithSize(true)
		self.expedit_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/heroexpedit","heroexpedit_bg",true), LOADTEXT_TYPE)
		self.move_pos = self.expedit_bg:getContentSize().width * 0.5
		self.expedit_bg:setScale(display.getMaxScale())
		
		expeditData.guard_id = expeditData.guard_id or 1
		self.move_pos = self.move_pos or 540
		if expeditData.guard_id <= 3 then
			self.expedit_bg:setPositionX(self.move_pos)
		end
	end

	local status = controller:getModel():getHeroSendRedPoint()
	addRedPointToNodeByStatus(self.btn_employ, status)

	self:registerEvent()
	self:createBoxOrPoint()
end
--创建宝箱和点
function HeroExpeditWindow:createBoxOrPoint()
	local pos = {{373,760},{721,679},{351,468},{609,250},{902,499}}
	local data = {0,0,0,0,0,0,0}
	local box_data = controller:getModel():getExpeditBoxData()
	local expeditData = controller:getModel():getExpeditData()

	if not expeditData or next(expeditData) == nil then return end
	if next(expeditData) ~= nil then
		for i,v in pairs(box_data) do
			if expeditData.guard_id >= v then
				data[i] = 1
			end
			for k,val in pairs(expeditData.reward) do
				if v == val.reward_id then
					data[i] = 2
				end
			end
		end
	end

	for i=1, point_num do
		delayRun(self.main_container, i*2/60, function()
			if sign_info[i].type == 1 then
				self.point_list[i] = ccui.Layout:create()
				self.point_list[i]:setTouchEnabled(true)
				self.point_list[i]:setAnchorPoint(0.5,0)
				
				self.point_list[i]:setPosition(sign_info[i].pos[1][1], sign_info[i].pos[1][2])
				self.expedit_bg:addChild(self.point_list[i])

				createImage(self.point_list[i], PathTool.getResFrame("heroexpedit","heroexpedit_6"), 0, 0, cc.p(0,0), true, 1, false)
				
				if i == expeditData.guard_id then
					if not self.facial_list[i] then
						self.point_list[i]:setContentSize(cc.size(38,100))
						self.facial_list[i] = createSprite(PathTool.getResFrame("heroexpedit","heroexpedit_8"), 0, 40, self.point_list[i], cc.p(0,0), LOADTEXT_TYPE_PLIST, 1)
					end
				elseif i < expeditData.guard_id then
					if not self.facial_list[i] then
						self.point_list[i]:setContentSize(cc.size(38,100))
						self.facial_list[i] = createSprite(PathTool.getResFrame("heroexpedit","heroexpedit_7"), 0, 40, self.point_list[i], cc.p(0,0), LOADTEXT_TYPE_PLIST, 1)
					end
				else
					setChildUnEnabled(true,self.point_list[i])
					self.point_list[i]:setContentSize(cc.size(38,40))
				end
				registerButtonEventListener(self.point_list[i], function()
		    		controller:sender24401(i)
		    	end,true,1)

			elseif sign_info[i].type == 2 then
				self.box_index = self.box_index + 1
				self.box_list[self.box_index] = ccui.Layout:create()
				self.box_list[self.box_index]:setTouchEnabled(true)
				registerButtonEventListener(self.box_list[self.box_index], function()
		    		if controller:getGrardID() >= i then
		    			controller:sender24402(i)
		    		else
		    			controller:sender24401(i)
		    		end
		    	end,true,1)
				self.box_list[self.box_index]:setContentSize(cc.size(62,44))
				self.box_list[self.box_index]:setAnchorPoint(0.5,0.5)
				self.box_list[self.box_index]:setPosition(sign_info[i].pos[1][1], sign_info[i].pos[1][2])
				self.expedit_bg:addChild(self.box_list[self.box_index])

				self:updateTaskList(data[self.box_index], self.box_index)
			end
		end)
	end
	controller:sender24400()
end
--扫荡后的关卡显示
function HeroExpeditWindow:clearGuard(guard_id)
	guard_id = guard_id or 1
	if (guard_id - 1) < 1 then
		guard_id = 1
	end
	local data = {0,0,0,0,0,0,0}
	local box_data = controller:getModel():getExpeditBoxData()
	for i,v in pairs(box_data) do
		if guard_id >= v then
			data[i] = 1
		end
		self:updateTaskList(data[i], i)
	end

	for i=1, guard_id do
		if self.point_list[i] then
			setChildUnEnabled(false,self.point_list[i])
		end
		if not self.facial_list[i] and self.point_list[i] then
			self.facial_list[i] = createSprite(PathTool.getResFrame("heroexpedit","heroexpedit_7"), 0, 40, self.point_list[i], cc.p(0,0), LOADTEXT_TYPE_PLIST, 1)
		else
			if self.facial_list[i] then
				loadSpriteTexture(self.facial_list[i], PathTool.getResFrame("heroexpedit","heroexpedit_7"))
			end
		end
	end
end

function HeroExpeditWindow:close_callback()
	if self.play_effect and next(self.play_effect or {}) ~= nil then
        for i=1, box_num do
            if self.play_effect[i] then
                self.play_effect[i]:clearTracks()
                self.play_effect[i]:removeFromParent()
                self.play_effect[i] = nil
            end
        end
    end
    self.play_effect = {}
	controller:openHeroExpeditView(false)
end