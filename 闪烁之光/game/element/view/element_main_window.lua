--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-04 21:55:37
-- @description    : 
		-- 元素神殿主界面
---------------------------------
ElementMainWindow = ElementMainWindow or BaseClass(BaseView)

local _controller = ElementController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

function ElementMainWindow:__init(  )
	self.is_full_screen = true
	self.layout_name = "element/element_main_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("element", "element"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg", true), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg/element","element_land_1"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_land_2"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_land_3"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_land_4"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_land_5"), type = ResourcesType.single },
	}

	self.pos_node_list = {}
	self.item_list = {}
	self.land_list = {}
	self.count_is_full = true
end

function ElementMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg",true), LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

	local top_panel = self.main_container:getChildByName("top_panel")
	local bottom_panel = self.main_container:getChildByName("bottom_panel")
	self.bottom_panel = bottom_panel

	local sp_land_1 = self.main_container:getChildByName("sp_land_1")
	loadSpriteTexture(sp_land_1, PathTool.getPlistImgForDownLoad("bigbg/element","element_land_4"), LOADTEXT_TYPE)
	self.land_list[ElementConst.Ele_Type.Light] = sp_land_1
	local sp_land_2 = self.main_container:getChildByName("sp_land_2")
	loadSpriteTexture(sp_land_2, PathTool.getPlistImgForDownLoad("bigbg/element","element_land_5"), LOADTEXT_TYPE)
	self.land_list[ElementConst.Ele_Type.Dark] = sp_land_2
	local sp_land_3 = self.main_container:getChildByName("sp_land_3")
	loadSpriteTexture(sp_land_3, PathTool.getPlistImgForDownLoad("bigbg/element","element_land_3"), LOADTEXT_TYPE)
	self.land_list[ElementConst.Ele_Type.Wind] = sp_land_3
	local sp_land_4 = self.main_container:getChildByName("sp_land_4")
	loadSpriteTexture(sp_land_4, PathTool.getPlistImgForDownLoad("bigbg/element","element_land_1"), LOADTEXT_TYPE)
	self.land_list[ElementConst.Ele_Type.Water] = sp_land_4
	local sp_land_5 = self.main_container:getChildByName("sp_land_5")
	loadSpriteTexture(sp_land_5, PathTool.getPlistImgForDownLoad("bigbg/element","element_land_2"), LOADTEXT_TYPE)
	self.land_list[ElementConst.Ele_Type.Fire] = sp_land_5

	self.btn_rule = top_panel:getChildByName("btn_rule")
	self.btn_rank = top_panel:getChildByName("btn_rank")

	self.close_btn = bottom_panel:getChildByName("close_btn")
	self.add_btn = bottom_panel:getChildByName("add_btn")
	self.count_label = bottom_panel:getChildByName("count_label")
	self.time_txt = bottom_panel:getChildByName("time_txt")
	self.sp_time = bottom_panel:getChildByName("sp_time")
	bottom_panel:getChildByName("count_title"):setString(TI18N("挑战次数:"))

	for i=1,5 do
		local pos_node = self.main_container:getChildByName("pos_node_" .. i)
		if pos_node then
			_table_insert(self.pos_node_list, pos_node)
		end
	end

	-- 适配
	local top_off = display.getTop(self.main_container)
	local bottom_off = display.getBottom(self.main_container)
	top_panel:setPositionY(top_off - 220)
	bottom_panel:setPositionY(bottom_off)
end

function ElementMainWindow:openRootWnd( setting )
	self.setting = setting or {}
	-- 打开界面时判断，如果本地有缓存数据则显示，否则请求数据
	if _model:checkIsHaveElementData() then
		self:setData()
	else
		_controller:sender25000()
	end
end

function ElementMainWindow:setData(  )
	self.element_data = _model:getElementData()
	local open_type = self.setting.open_type
	for i,v in ipairs(self.element_data.list or {}) do
		delayRun(self.main_container, i / display.DEFAULT_FPS, function ( )
			local ele_item = self.item_list[i]
			if not ele_item then
				ele_item = ElementMainItem.new()
				local pos_node = self.pos_node_list[i]
				pos_node:addChild(ele_item)
				self.item_list[i] = ele_item
			end
			ele_item:setVisible(true)
			ele_item:setData(v)
			if open_type and open_type == v.type then
				ele_item:onClickOpen()
			end
		end)
	end

	self:refreshLandStatus()
	self:refreshCountData()
	self:updateLeftBuyCount()
end

-- 刷新大陆置灰状态
function ElementMainWindow:refreshLandStatus(  )
	if not self.element_data then return end
	local cur_time = GameNet:getInstance():getTime()
	for i,eData in ipairs(self.element_data.list or {}) do
		local land_sp = self.land_list[eData.type]
		if land_sp then
			if not eData.endtime or eData.endtime <= 0 or eData.endtime <= cur_time then
				setChildUnEnabled(true, land_sp)
			else
				setChildUnEnabled(false, land_sp)
			end
		end
	end
end

-- 刷新挑战次数相关
function ElementMainWindow:refreshCountData(  )
	if not self.element_data then return end

	local count_cfg = Config.ElementTempleData.data_const["refresh_number"]
	self.count_label:setString(self.element_data.num .. "/" .. count_cfg.val)
	self.count_is_full = (self.element_data.num >= count_cfg.val)

	local cur_time = GameNet:getInstance():getTime()
	if self.element_data.refresh_time < cur_time then
		self:setLessTime(0)
		self.time_txt:setVisible(false)
		self.sp_time:setVisible(false)
	else
		self:setLessTime(self.element_data.refresh_time - cur_time)
		self.time_txt:setVisible(true)
		self.sp_time:setVisible(true)
	end
end

-- 更新今日剩余购买次数
function ElementMainWindow:updateLeftBuyCount(  )
    if not self.left_buy_count then
        self.left_buy_count = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(590, 116))
        self.bottom_panel:addChild(self.left_buy_count)
    end
    local left_count = _model:getTodayLeftBuyCount()
    self.left_buy_count:setString(string.format(TI18N("<div fontcolor=#fff8bf outline=2,#000000>(剩余购买次数:</div><div fontcolor=#39e522 outline=2,#000000>%d</div><div fontcolor=#fff8bf outline=2,#000000>)</div>"), left_count))
end

--设置倒计时
function ElementMainWindow:setLessTime( less_time )
    if tolua.isnull(self.time_txt) then return end
    self.time_txt:stopAllActions()
    if less_time > 0 then
        self.time_txt:setString(TimeTool.GetTimeFormat(less_time))
        self.time_txt:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.time_txt:stopAllActions()
            else
                self.time_txt:setString(TimeTool.GetTimeFormat(less_time))
            end
        end)
        )))
    else
        self.time_txt:setString(TimeTool.GetTimeFormat(less_time))
    end
end

function ElementMainWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openElementMainWindow(false)
	end, false, 2)

	-- 规则说明
	registerButtonEventListener(self.btn_rule, function (  )
		MainuiController:getInstance():openCommonExplainView(true, Config.ElementTempleData.data_explain)
	end)
	-- 排行榜
	registerButtonEventListener(self.btn_rank, function (  )
		_controller:openElementRankWindow(true)
	end)
	-- 增加次数
	registerButtonEventListener(self.add_btn, handler(self, self._onClickAddCountBtn))

	-- 元素神殿数据
	self:addGlobalEvent(ElementEvent.Update_Element_Data_Event, function (  )
		self:setData()
	end)
	
	-- 挑战次数
	self:addGlobalEvent(ElementEvent.Update_Element_Count_Event, function (  )
		self.element_data = _model:getElementData()
		self:refreshCountData()
		self:updateLeftBuyCount()
	end)
end

function ElementMainWindow:_onClickAddCountBtn(  )
	if self.element_data then
		if not self.count_is_full then
			local buy_cfg = Config.ElementTempleData.data_buy_count[self.element_data.buy_num + 1]
			local privilege_status = RoleController:getInstance():getModel():checkPrivilegeStatus(4) -- 特权激活状态
			if buy_cfg or privilege_status == true then
				local role_vo = RoleController:getInstance():getRoleVo()
				if buy_cfg and role_vo.vip_lev >= buy_cfg.vip then
					local str = string.format(TI18N("\n\n\n\n\n\n\n\n               是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数？\n\n\n\n\n\n\n\n\n\n\n\n<div fontsize=22>圣殿挑战特权:每日免费挑战2次，额外购买%d次</div><div href=privilege fontcolor=#289b14>前往激活</div>"), PathTool.getItemRes(3), buy_cfg.cost, Config.ElementTempleData.data_privilege_length or 0)
					if privilege_status == true then
						str = string.format(TI18N("\n\n\n\n\n\n\n\n               是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数？\n\n\n\n\n\n\n\n\n\n\n\n<div fontsize=22>圣殿挑战特权:每日免费挑战2次，额外购买%d次</div><div fontcolor=#289b14>(已激活)</div>"), PathTool.getItemRes(3), buy_cfg.cost, Config.ElementTempleData.data_privilege_length or 0)
					end					
					CommonAlert.show( str, TI18N("确定"), function()
						_controller:sender25003()
			    	end, TI18N("取消"), nil, CommonAlert.type.rich)
			    elseif privilege_status == true then -- 是否激活了特权
					local buy_count = _model:getPrivilegeBuyCount()
					local pri_cost = Config.ElementTempleData.data_privilege[buy_count+1]
					if pri_cost then
						local str = string.format(TI18N("\n\n\n\n\n\n\n\n               是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数？\n\n\n\n\n\n\n\n\n\n\n\n<div fontsize=22>圣殿挑战特权:每日免费挑战2次，额外购买%d次</div><div href=privilege fontcolor=#289b14>前往激活</div>"), PathTool.getItemRes(3), pri_cost, Config.ElementTempleData.data_privilege_length or 0)
						if privilege_status == true then
							str = string.format(TI18N("\n\n\n\n\n\n\n\n               是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数？\n\n\n\n\n\n\n\n\n\n\n\n<div fontsize=22>圣殿挑战特权:每日免费挑战2次，额外购买%d次</div><div fontcolor=#289b14>(已激活)</div>"), PathTool.getItemRes(3), pri_cost, Config.ElementTempleData.data_privilege_length or 0)
						end
						CommonAlert.show( str, TI18N("确定"), function()
							_controller:sender25003()
				    	end, TI18N("取消"), nil, CommonAlert.type.rich)
					else
						--message(TI18N("提升VIP等级可增加购买次数"))
						message(TI18N("购买次数已用完"))
					end
				else
					--message(TI18N("提升VIP等级可增加购买次数"))
					message(TI18N("购买次数已用完"))
				end
			else
				message(TI18N("购买次数已用完"))
			end
		else
			message(TI18N("当前挑战次数已满"))
		end
	end
end

function ElementMainWindow:close_callback(  )
	for k,item in pairs(self.item_list) do
		item:DeleteMe()
		item = nil
	end
	self:setLessTime(0)
	_controller:openElementMainWindow(false)
end

-------------------------@ item
ElementMainItem = class("ElementMainItem", function()
    return ccui.Widget:create()
end)

function ElementMainItem:ctor()
	self:configUI()
	self:register_event()
end

function ElementMainItem:configUI(  )
	self.size = cc.size(150, 150)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("element/element_main_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.ele_icon = container:getChildByName("ele_icon")
    self.ele_icon:ignoreContentAdaptWithSize(true)
    self.ele_name = container:getChildByName("ele_name")
    self.open_time = container:getChildByName("open_time")
    self.sp_head_k_2 = container:getChildByName("sp_head_k_2")
end

function ElementMainItem:register_event(  )
	registerButtonEventListener(self.container, function (  )
		self:onClickOpen()
	end, true)
end

function ElementMainItem:onClickOpen()
	if self._is_open and self.data then
		_model:setRecordOpenType(self.data.type)
		_controller:openElementEctypeWindow(true, self.data)
	elseif self.base_cfg then
		local open_str = TimeTool.getWeekDay(self.base_cfg.open_day)
		message(open_str .. TI18N("开启"))
	end
end

function ElementMainItem:setData( data )
	if not data then return end
	self.data = data
	self.base_cfg = Config.ElementTempleData.data_base[data.type]

	if not self.base_cfg then return end

	-- 建筑
	if self.base_cfg.res_id then
		self.ele_icon:loadTexture(PathTool.getResFrame("element", "element_build_" .. self.base_cfg.res_id), LOADTEXT_TYPE_PLIST)

		-- 建筑资源大小不一致，位置需要微调
		if self.base_cfg.type == ElementConst.Ele_Type.Wind then
			self.ele_icon:setPositionY(135)
		elseif self.base_cfg.type == ElementConst.Ele_Type.Fire then
			self.ele_icon:setPositionY(122)
		end
	end

	self.ele_name:setString(self.base_cfg.name)

	local cur_time = GameNet:getInstance():getTime()
	if not data.endtime or data.endtime <= 0 or data.endtime <= cur_time then -- 没开启
		self._is_open = false
		self.sp_head_k_2:setVisible(true)
		setChildUnEnabled(true, self.ele_icon)
		self:setLessTime(0)
		local open_str = TimeTool.getWeekDay(self.base_cfg.open_day)
		self.open_time:setString(open_str .. TI18N("开启"))
		self.open_time:setTextColor(cc.c3b(255, 93, 93))
		if self.hero_head then
			self.hero_head:setVisible(false)
		end
	else
		setChildUnEnabled(false, self.ele_icon)
		self.open_time:setTextColor(cc.c3b(104,199,75))
		self._is_open = true
		local less_time = data.endtime - cur_time
		self:setLessTime(less_time)
		self.sp_head_k_2:setVisible(false)

		local monster_cfg = Config.ElementTempleData.data_monster[data.group]
		if monster_cfg then
			if not self.hero_head then
				self.hero_head = PlayerHead.new(PlayerHead.type.circle)
				self.hero_head:setAnchorPoint(0.5,0.5)
				self.hero_head:setScale(0.56)
				self.hero_head:showBg()
				self.hero_head:setPosition(cc.p(20, 34))
				self.container:addChild(self.hero_head)
			end
			local head_res = PathTool.getHeadIcon(monster_cfg.head_id)
			self.hero_head:setHeadRes(head_res, true)
		end
	end
end

--设置倒计时
function ElementMainItem:setLessTime( less_time )
    if tolua.isnull(self.open_time) then return end
    self.open_time:stopAllActions()
    if less_time > 0 then
        self.open_time:setString(TimeTool.GetTimeFormat(less_time) .. TI18N("后结束"))
        self.open_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.open_time:stopAllActions()
            else
                self.open_time:setString(TimeTool.GetTimeFormat(less_time) .. TI18N("后结束"))
            end
        end)
        )))
    else
        self.open_time:setString(TimeTool.GetTimeFormat(less_time) .. TI18N("后结束"))
    end
end

function ElementMainItem:DeleteMe(  )
	if self.hero_head then
		self.hero_head:DeleteMe()
		self.hero_head = nil
	end
	self:setLessTime(0)
	self:removeAllChildren()
	self:removeFromParent()
end