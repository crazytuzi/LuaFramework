-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      七天登录活动面板
-- Create: 2018-06-20
-- --------------------------------------------------------------------
ActionSevenLoginWindow = ActionSevenLoginWindow or BaseClass(BaseView)

function ActionSevenLoginWindow:__init()
	self.ctrl = ActionController:getInstance()
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_seven_login_window"    
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("actionsevenlogin","actionsevenlogin"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_bigbg_2"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_seven_bg1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_seven_bg2"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_seven_login_title1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_seven_login_title2"), type = ResourcesType.single },
    } 

    self.day_list = {}
    self.cur_select = nil
    self.cur_index = nil
end

function ActionSevenLoginWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

    self.main_panel = self.main_container:getChildByName("main_panel")
    self.container = self.main_panel:getChildByName("container")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.model_icon = self.main_panel:getChildByName("model_icon")
    self.title = self.main_panel:getChildByName("title")

    self.btn = self.container:getChildByName("btn")
    self.btn:setName("get_btn")
    self.btn:setTitleText(TI18N("领取"))
    self.btn.label = self.btn:getTitleRenderer()
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end
    setChildUnEnabled(false,self.btn)

    self.day_label = self.container:getChildByName("day_label")
    self.day_label:setLocalZOrder(21)
    self.day_bg = self.container:getChildByName("day_bg")
    self.day_bg:setLocalZOrder(20)

    self.seven_con = self.container:getChildByName("seven_con")

    for i=1,7 do
    	local day = self.seven_con:getChildByName("day"..i)
    	local item = LoginItem.new()
    	item:setData(i)
    	day:addChild(item)
    	self.day_list[i] = item
    	--self.day_list[i].status = 1 --不可领取
    	item:addCallBack(function (  )
    		self:selectByIndex(i)
    	end)
    	self.day_list[i]:setStatus(1)
    end

    self.goods_con = self.container:getChildByName("goods_con")
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 10,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        --scale = 0.85
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,2) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    --self:selectByIndex(1)

    self.ctrl:cs21100()
end

function ActionSevenLoginWindow:openRootWnd(  )
	
end

function ActionSevenLoginWindow:selectByIndex( index, force )
	if self.cur_index == index and not force then return end
	self.index = index
	if self.cur_select ~= nil then 
		self.cur_select:setSelect(false)
	end
	self.cur_index = index
	self.cur_select = self.day_list[index]
	self.cur_select:setSelect(true)

	local res = PathTool.getTargetRes("bigbg/action","action_seven_bg1",false,false)
	local res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_seven_login_title1",false,false)
	if index <= 2 then 
		res = PathTool.getTargetRes("bigbg/action","action_seven_bg1",false,false)
		res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_seven_login_title1",false,false)
	else
		res = PathTool.getTargetRes("bigbg/action","action_seven_bg2",false,false)
		res1 = PathTool.getTargetRes("bigbg/action","txt_cn_action_seven_login_title2",false,false)
	end
	loadSpriteTexture(self.model_icon, res, LOADTEXT_TYPE)
	loadSpriteTexture(self.title, res1, LOADTEXT_TYPE)

	self.day_label:setString(TI18N("第")..StringUtil.numToChinese(index)..TI18N("天"))

	local list = {}
	local spec_reward = Config.LoginDaysData.data_day[index].spec_reward
	local effect_list = {}
	if spec_reward then
		for i, v in ipairs(spec_reward) do
			if not effect_list[v] then
				effect_list[v] = {effect_id = v}
			end
		end
	end

	for k,v in pairs(Config.LoginDaysData.data_day[index].rewards) do
		local vo = {}
		vo = deepCopy(Config.ItemData.data_get_data(v[1]))
		if vo then
			vo.show_effect = effect_list[v[1]]
			vo.quantity = v[2]
			table.insert(list,vo)
		end
	end

	if self.day_list[self.index].status == 2 then --可领取
		setChildUnEnabled(false,self.btn)
		if self.btn.label ~= nil then
			self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
		end
	else
		setChildUnEnabled(true,self.btn)
		if self.btn.label ~= nil then
			self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
		end
	end
	if #list > 4 then
		self.item_scrollview:setClickEnabled(true)
	else
		self.item_scrollview:setClickEnabled(false)
	end
	self.item_scrollview:setData(list)
	self.item_scrollview:addEndCallBack(function (  )
		local list = self.item_scrollview:getItemList()
		for k,v in pairs(list) do
			v:setDefaultTip()
			if v.data and v.data.show_effect then
				if v.data.quality >= 4 then
					v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
				else
					v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
				end
			else
				v:showItemEffect(false)
			end

		end
	end)
end

function ActionSevenLoginWindow:register_event(  )
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openSevenLoginWin(false)
			end
		end)
	end

	self.btn:addTouchEventListener(function ( sender,event_type )
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.day_list[self.index] then 
				if self.day_list[self.index].status == 2 then --可领取
					self.ctrl:cs21101(self.index)
					setChildUnEnabled(false,self.btn)
					self.btn.label = self.btn:getTitleRenderer()
					if self.btn.label ~= nil then
				        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
				    end
				elseif self.day_list[self.index].status == 3 then 
					setChildUnEnabled(true,self.btn)
					self.btn.label = self.btn:getTitleRenderer()
				    if self.btn.label ~= nil then
				        self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
				    end
					message(TI18N("已经领取过啦"))
				elseif self.day_list[self.index].status == 1 then 
					setChildUnEnabled(true,self.btn)
					self.btn.label = self.btn:getTitleRenderer()
					if self.btn.label ~= nil then
				        self.btn.label:disableEffect(cc.LabelEffect.OUTLINE)
				    end
					message(TI18N("未到天数"))
				end
			end
		end
	end)

	--七天登录信息
	if self.update_status == nil then
		self.update_status = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_SEVEN_LOGIN_STATUS,function ( data )
			if data.status_list then 
				for k,v in pairs(data.status_list) do
					self.day_list[v.day]:setStatus(v.status)
				end
				self.now_day = math.min(#data.status_list + 1,7)
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
function ActionSevenLoginWindow:getMinGetDay( data )
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


function ActionSevenLoginWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil

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

	self.ctrl:openSevenLoginWin(false)
end


-- --------------------------------------------------------------------
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: shuwen(必填, 后续维护以及修改的人员)
-- @description:
--      七天登录活动单个
-- Create: 2018-06-20
-- --------------------------------------------------------------------
LoginItem = class("LoginItem", function()
    return ccui.Widget:create()
end)

function LoginItem:ctor()
	self:configUI()
	self:register_event()
	self.status = 1
end

function LoginItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_seven_login_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(100,120))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setTouchEnabled(true)
    self.main_container:setSwallowTouches(false)

    local title_bg = self.main_container:getChildByName("title_bg")
    title_bg:setLocalZOrder(21)
    self.title = self.main_container:getChildByName("title")
    self.title:setLocalZOrder(21)
    self.get = self.main_container:getChildByName("get")
    self.get:setVisible(false)

    self.select = self.main_container:getChildByName("select")
    self.select:setVisible(false)
	self.effect = createEffectSpine(PathTool.getEffectRes(257),cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2),cc.p(0.5, 0.5),true,"action")
	self.effect:setVisible(false)
	self.main_container:addChild(self.effect,20)
    self.icon = self.main_container:getChildByName("icon")
end

function LoginItem:register_event(  )
	self.main_container:addTouchEventListener(function(sender, event_type) 
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.callback then
				self:callback()
			end
		end
	end)
end

function LoginItem:setData( index )
    self.title:setString(TI18N("第")..StringUtil.numToChinese(index)..TI18N("天"))
    loadSpriteTexture(self.icon, PathTool.getResFrame("actionsevenlogin","txt_cn_seven_login_item_"..index), LOADTEXT_TYPE_PLIST)

    if index == 2 or index == 3 then 
    	if self.effect2 == nil then
    		self.effect2 = createEffectSpine(PathTool.getEffectRes(258),cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2),cc.p(0.5, 0.5),true,"action")
    		self.main_container:addChild(self.effect2,19)
    	end
    	if self.effect2 then 
    		self.effect2:setVisible(true)
    	end
    else
    	if self.effect2 then 
    		self.effect2:setVisible(false)
    	end
    end
end

function LoginItem:setStatus(status)
	self.status = status
	if self.status == 3 then --已领取
		if self.effect2 and not tolua.isnull(self.effect2) then
			self.effect2:setVisible(false)
		end
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
	else
		if self.effect and not tolua.isnull(self.effect) then
			self.effect:setVisible(false)
		end
	end
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

function LoginItem:setSelect( status )
	if status then 
		self.select:setVisible(true)
	else
		self.select:setVisible(false)
	end
end

function LoginItem:addCallBack( value )
	self.callback =  value
end

function LoginItem:DeleteMe()
	-- if self.goods_item then 
	-- 	self.goods_item:DeleteMe()
	-- 	self.goods_item = nil
	-- end
end