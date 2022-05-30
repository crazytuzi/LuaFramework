-- --------------------------------------------------------------------
-- @author: xhj(必填, 创建模块的人员)
-- @editor: (必填, 后续维护以及修改的人员)
-- @description:
--      八天登录活动面板
-- Create: 2020-02-10
-- --------------------------------------------------------------------
ActionEightLoginWindow = ActionEightLoginWindow or BaseClass(BaseView)

function ActionEightLoginWindow:__init()
	self.ctrl = ActionController:getInstance()
	self.model = self.ctrl:getModel()
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_eight_login_window"    
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actioneightlogin","actioneightlogin"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg2"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg3"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg4"), type = ResourcesType.single },
		{ path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_eight_login_title"), type = ResourcesType.single },
		{ path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_eight_login_title1"), type = ResourcesType.single },
		{ path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_eight_login_title2"), type = ResourcesType.single },
		{ path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_eight_login_title3"), type = ResourcesType.single },
    } 

    self.day_list = {}
    self.cur_index = nil
end

function ActionEightLoginWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.container = self.main_panel:getChildByName("container")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.bg = self.main_panel:getChildByName("bg")
    local res_bg = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg")
	if not self.bg_item_load then
		self.bg_item_load = loadImageTextureFromCDN(self.bg, res_bg, ResourcesType.single, self.bg_item_load)
	end
    self.model_icon = self.main_panel:getChildByName("model_icon")
    self.bg2 = self.main_panel:getChildByName("bg2")
    local res_bg2 = PathTool.getPlistImgForDownLoad("bigbg/action","action_eight_bg4")
	if not self.bg2_item_load then
		self.bg2_item_load = loadImageTextureFromCDN(self.bg2, res_bg2, ResourcesType.single, self.bg2_item_load)
	end
    
	self.title_2 = self.main_panel:getChildByName("title_2")
	
    self.btn = self.container:getChildByName("btn")
    self.btn_label = self.btn:getChildByName("btn_label")
    self.btn_label:setString(TI18N("查看详情"))
	self.btn:setVisible(false)
    self.day_label = self.container:getChildByName("day_label")
    self.day_label:setLocalZOrder(21)

    self.seven_con = self.container:getChildByName("seven_con")

    for i=1,8 do
    	local day = self.seven_con:getChildByName("day"..i)
		local item = EightLoginItem.new()
		item:setData(i)
    	day:addChild(item)
    	self.day_list[i] = item
    	--self.day_list[i].status = 1 --不可领取
		self.day_list[i]:setStatus(1)
		item:addCallBack(function (  )
			print("addCallBack")
			if self.day_list[i] then 
				if self.day_list[i].status == 2 then --可领取
					local temp_data = self.model:getSevenLoginData()
					if temp_data then
						local target = self:getMinGetDay(temp_data.status_list)
						if target < i then
							message(TI18N("请先领取前一档奖励"))
							return
						end
						self.ctrl:cs21101(i)
					end
				elseif self.day_list[i].status == 3 or self.day_list[i].status == 1 then --已领取或未到天数
					self:selectByIndex(i)
					local day_conf = Config.LoginDaysNewData.data_day[i]
					if day_conf and day_conf.rewards then
						local config = Config.ItemData.data_get_data(day_conf.rewards[1][1])
						if BackPackConst.checkIsEquip(config.type) then
							HeroController:getInstance():openEquipTips(true, config)
						else
							TipsManager:getInstance():showGoodsTips(config)
						end
					end
				end
			end
    	end)
    end


    --self:selectByIndex(1)

    self.ctrl:cs21100()
end

function ActionEightLoginWindow:openRootWnd(  )
	
end

function ActionEightLoginWindow:selectByIndex( index, force )
	if self.cur_index == index and not force then return end
	self.cur_index = index
	local temp_y = 774
	local res = PathTool.getTargetRes("bigbg/action","action_eight_bg1",false,false)
	local res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_eight_login_title1",false,false)
	if index <= 2 then 
		--res = PathTool.getTargetRes("bigbg/action","action_eight_bg1",false,false)
		res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_eight_login_title1",false,false)
		--self.btn:setVisible(true)
	elseif index <= 4 then
		--res = PathTool.getTargetRes("bigbg/action","action_eight_bg1",false,false)
		res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_eight_login_title2",false,false)
		--self.btn:setVisible(false)
	else
		--temp_y = 783
		--res = PathTool.getTargetRes("bigbg/action","action_eight_bg1",false,false)
		res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_eight_login_title3",false,false)
		--self.btn:setVisible(true)
	end
	self.model_icon_load = createResourcesLoad(res, ResourcesType.single, function()
		if not tolua.isnull(self.model_icon) then
			loadSpriteTexture(self.model_icon, res, LOADTEXT_TYPE)
		end
	end,self.model_icon_load)
	
	self.title_2_load = createResourcesLoad(res1, ResourcesType.single, function()
		if not tolua.isnull(self.title_2) then
			loadSpriteTexture(self.title_2, res1, LOADTEXT_TYPE)
		end
	end,self.title_2_load)

	self.model_icon:setPositionY(temp_y)
	local day_conf = Config.LoginDaysNewData.data_day[index]
	if day_conf then
		self.day_label:setString(TI18N(day_conf.reward_desc))
	end
	
end

function ActionEightLoginWindow:register_event(  )

	registerButtonEventListener(self.background, function()
		print("self.background")
		self.ctrl:openEightLoginWin(false)
	end, false,2)

	registerButtonEventListener(self.close_btn, function()
		print("self.close_btn")
		self.ctrl:openEightLoginWin(false)
	end, true,2)

	registerButtonEventListener(self.btn, function()
		local id = nil
		if self.cur_index then
			if self.cur_index <= 2 then 
				id = 10501
			elseif self.cur_index <= 4 then
				id = 40506
			elseif self.cur_index <= 8 then
				id = 20508
			end
		end
		if id then
			HeroController:getInstance():openHeroInfoWindowByBidStar(id, 10)
		end
    end ,true, 1)
	

	--七天登录信息
	if self.update_status == nil then
		self.update_status = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVEN_LOGIN_STATUS,function ( data )
			if data.status_list then 
				for k,v in pairs(data.status_list) do
					self.day_list[v.day]:setStatus(v.status)
				end
				self.now_day = math.min(#data.status_list + 1,8)
				local target = self:getMinGetDay(data.status_list)
				self:selectByIndex(target, true)
			end
		end)
	end

	--领取成功
	if self.get_event == nil then 
		self.get_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVEN_LOGIN_REWARDS,function ( data )
			-- if data.day < 7 then 
			-- 	self:selectByIndex(data.day+1)
			-- else
			-- 	self:selectByIndex(7)
			-- end
		end)
	end
end

--最小可领取天数
function ActionEightLoginWindow:getMinGetDay( data )
	local day = self.now_day
	for k,v in pairs(data) do
		if v.day == 1 and v.status == 2 then 
			return 1
		else
			if v.day<day and v.status == 2 then 
				day = v.day
			end
		end
	end
	return day
end

function ActionEightLoginWindow:close_callback()
	if self.bg_item_load then
        self.bg_item_load:DeleteMe()
    end
	self.bg_item_load = nil

	if self.bg2_item_load then
        self.bg2_item_load:DeleteMe()
    end
	self.bg2_item_load = nil

	if self.model_icon_load then 
        self.model_icon_load:DeleteMe()
        self.model_icon_load = nil
	end
	
	if self.title_2_load then 
        self.title_2_load:DeleteMe()
        self.title_2_load = nil
    end

	for k,v in pairs(self.day_list) do
		if v then
			v:DeleteMe()
		end
	end

	self.day_list = nil

	if self.update_status ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_status)
        self.update_status = nil
    end

    if self.get_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.get_event)
        self.get_event = nil
    end

	self.ctrl:openEightLoginWin(false)
end


-- --------------------------------------------------------------------
-- @author: xhj(必填, 创建模块的人员)
-- @editor: (必填, 后续维护以及修改的人员)
-- @description:
--      八天登录活动单个
-- Create: 2020-02-10
-- --------------------------------------------------------------------
EightLoginItem = class("EightLoginItem", function()
    return ccui.Widget:create()
end)

function EightLoginItem:ctor()
	self.ctrl = ActionController:getInstance()
	self.model = self.ctrl:getModel()

	self:configUI()
	self:register_event()
	self.status = 1
	self.day_index = 1
end

function EightLoginItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_eight_login_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(100,120))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setTouchEnabled(true)
    self.main_container:setSwallowTouches(false)

	self.title_bg = self.main_container:getChildByName("title_bg")
	-- self.title_bg:setLocalZOrder(21)
    self.title = self.title_bg:getChildByName("title")
	self.title:setLocalZOrder(22)
	self.title_day = self.main_container:getChildByName("title_day")
	self.title_day:setLocalZOrder(23)
    self.get = self.main_container:getChildByName("get")
	self.get:setVisible(false)
	-- PathTool.getEffectRes(292)
	self.effect = createEffectSpine("E31336",cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2),cc.p(0.5, 0.5),true,"action")
	self.effect:setVisible(false)
	self.main_container:addChild(self.effect,20)
    self.icon = self.main_container:getChildByName("icon")
end

function EightLoginItem:register_event(  )
	self.main_container:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.callback then
				print("EightLoginItem:register_event")
				self:callback()
			end
		end
	end)
end

function EightLoginItem:setData( index )
	if index == 1 then
		self.main_container:setName("get_btn")
	end
	self.day_index = index
	
	
	local day_conf = Config.LoginDaysNewData.data_day[index]
    if day_conf and day_conf.is_spe_day==1 then 
		if self.effect2 == nil then
			-- PathTool.getEffectRes(291)
    		self.effect2 = createEffectSpine("E31335",cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2),cc.p(0.5, 0.5),true,"action")
    		self.main_container:addChild(self.effect2,19)
    	end
    	if self.effect2 then 
    		self.effect2:setVisible(true)
		end
		loadSpriteTexture(self.icon, PathTool.getResFrame("actioneightlogin","action_eight_item_"..index), LOADTEXT_TYPE_PLIST)
		self.icon:setScale(1)
    else
    	if self.effect2 then 
    		self.effect2:setVisible(false)
		end
		if day_conf and day_conf.rewards[1][1] then
			local head_icon = PathTool.getItemRes(day_conf.rewards[1][1], false)
			loadSpriteTexture(self.icon, head_icon, LOADTEXT_TYPE)
		end
		self.icon:setScale(0.8)
	end
	if day_conf then
		self.title:setString(day_conf.desc)
	end
	
end

function EightLoginItem:setTitleLab(status)
	-- self.title_bg:setContentSize(cc.size(61.69,23))
	local data = self.model:getSevenLoginData()
	if data then
		local len = #data.status_list or 1
		if status == 3 or status == 2 then
			doStopAllActions(self.title_day)
			self.title_day:setString(string.format(TI18N("第%s天"), self.day_index))
		elseif len+2 <= self.day_index then
			doStopAllActions(self.title_day)
			self.title_day:setString(string.format(TI18N("%d天后"), self.day_index - len))
		else
			
			-- self.title_bg:setContentSize(cc.size(81.69,23))
			commonCountDownTime(self.title_day, TimeTool.getOneDayLessTime())
		end
	end

end


function EightLoginItem:setStatus(status)
	self.status = status
	if self.status == 3 then --已领取
		-- if self.effect2 and not tolua.isnull(self.effect2) then
		-- 	self.effect2:setVisible(false)
		-- end
		if self.effect and not tolua.isnull(self.effect) then
			self.effect:setVisible(false)
		end
		self.get:setVisible(true)
	else
		self.get:setVisible(false)
	end
	if self.status == 2 then --可领取
		if self.effect and not tolua.isnull(self.effect) then
			self.effect:setVisible(true)
		end
		self.title:setString(TI18N("可领取"))
	else
		if self.effect and not tolua.isnull(self.effect) then
			self.effect:setVisible(false)
		end
		local day_conf = Config.LoginDaysNewData.data_day[self.day_index]
		if day_conf then
			self.title:setString(day_conf.desc)
		end
		
	end

	self:setTitleLab(status)
	-- if self.status == 2 then --可领取
	-- 	if self.effct == nil then
	-- 		self.effect = createEffectSpine(PathTool.getEffectRes(257),cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2),cc.p(0.5, 0.5),true,"action")
    -- 		self.main_container:addChild(self.effect,20)
	-- 	end
	-- 	self.effect:setVisible(true)
	-- else
	-- 	if self.effect then
	-- 		self.effect:setVisible(false)
	-- 	end
	-- end
end


function EightLoginItem:addCallBack( value )
	self.callback =  value
end

function EightLoginItem:DeleteMe()
	doStopAllActions(self.title_day)

	if self.effect then
        self.effect:clearTracks()
        self.effect:removeFromParent()
        self.effect = nil
	end
	
	if self.effect2 then
        self.effect2:clearTracks()
        self.effect2:removeFromParent()
        self.effect2 = nil
    end
	-- if self.goods_item then 
	-- 	self.goods_item:DeleteMe()
	-- 	self.goods_item = nil
	-- end
end