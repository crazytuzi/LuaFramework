-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      护送雇佣主列表
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortEmployWindow = EscortEmployWindow or BaseClass(BaseView)

local controller = EscortController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()
local string_format = string.format

function EscortEmployWindow:__init()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.layout_name = "escort/escort_employ_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("escort", "escort"), type = ResourcesType.plist},
	}
	self.item_list = {}
end

function EscortEmployWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
	local main_panel = main_container:getChildByName("main_panel") 
	main_panel:getChildByName("win_title"):setString(TI18N("雇佣信息"))
	main_panel:getChildByName("employ_times_title"):setString(TI18N("今日雇佣次数:"))
	main_panel:getChildByName("notice_label"):setString(TI18N("刷新不会降低雇佣兽品质"))

	self.close_btn = main_panel:getChildByName("close_btn")
	self.list_view = main_panel:getChildByName("list_view")
	self.employ_times_value  = main_panel:getChildByName("employ_times_value")

	self.refresh_btn = main_panel:getChildByName("refresh_btn")
	self.auto_refresh_btn = main_panel:getChildByName("auto_refresh_btn")

	self.refresh_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(88,33))
	self.refresh_btn:addChild(self.refresh_btn_label)

	self.auto_refresh_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(88,33))
	self.auto_refresh_btn:addChild(self.auto_refresh_btn_label)

	self.confirm_btn = main_panel:getChildByName("confirm_btn")
	self.confirm_btn:getChildByName("label"):setString(TI18N("我要雇佣"))

	-- 5个对象
	local base_config = Config.EscortData.data_baseinfo 
	for i=1,5 do
		local item = main_container:getChildByName("item_"..i)
		if item then
			local normal = item:getChildByName("normal")
			local select = item:getChildByName("select") 
			local item_name = item:getChildByName("item_name") 
			local awards_title = item:getChildByName("awards_title") 
			local item_status = item:getChildByName("item_status")
			awards_title:setString(TI18N("奖励:"))

			local quality = (i - 1) --品质是从0开始的
			local config = base_config[quality] 

			local object = {}
			object.item = item
			object.normal = normal
			object.select = select
			object.item_name = item_name
			object.quality = quality
			object.config = config
			object.item_status = item_status 
			self.item_list[i] = object
			if config then
				item_name:setString(config.title)
			end
		end
	end
end

function EscortEmployWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				controller:openEscortEmployWindow(false) 
			end
		end)
	end
	if self.confirm_btn then
		self.confirm_btn:addTouchEventListener(function(sender, event_type) 
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local is_double = model:isDoubleTimes() 
				if is_double == false then
					local config = Config.EscortData.data_const.double_time
					local str = ""
					if config then
						str = "("..config.desc..")"
					end
					local msg = TI18N("当前为非双倍奖励时间，继续护送只能获得单倍奖励，是否继续？")
					CommonAlert.show(msg,TI18N("确定"),function() 
						controller:requestEscort()
					end,TI18N("取消"),nil, nil,nil, {extend_str=str,extend_offy=-75,extend_aligment=cc.TEXT_ALIGNMENT_CENTER})
				else
					controller:requestEscort()
				end
			end
		end)
	end
	if self.refresh_btn then
		self.refresh_btn:addTouchEventListener(function(sender, event_type) 
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				controller:requestRefreshEscort(1)
			end
		end)
	end
	if self.auto_refresh_btn then
		self.auto_refresh_btn:addTouchEventListener(function(sender, event_type) 
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				controller:requestRefreshEscort(2)
			end
		end)
	end
	if self.update_myinfo_event == nil then
		self.update_myinfo_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortMyInfoEvent, function()
			local my_info = model:getMyInfo()
			if my_info then
				self:changeQuailty(my_info.quality)
			end
			self:updateMyRefreshTimes()
		end)
	end
end

--==============================--
--desc:更新刷新次数,多少次以内是免费的
--time:2018-09-04 10:47:44
--@return 
--==============================--
function EscortEmployWindow:updateMyRefreshTimes()
	local refresh_times = model:getMyCount(EscortConst.times_type.refresh)  --已刷新次数
	local free_times = model:getMyMaxCount(EscortConst.times_type.refresh)
	if refresh_times < free_times then
		self.refresh_btn_label:setString(string.format("<div fontColor=#ffffff fontsize=24 outline=1,#478425>%s(%s/%s)</div>", TI18N("本次免费"), (free_times-refresh_times), free_times))
	else
		local refresh_config = Config.EscortData.data_const.refresh_cost
		if refresh_config and refresh_config.val then
			if type(refresh_config.val) == "table" then
				local config = refresh_config.val[1]
				if config and #config >= 2 then
					local item_id = config[1]
					local item_num = config[2]
					local item_config = Config.ItemData.data_get_data(item_id)
					if item_config then
						local str = string.format("<img src=%s visible=true scale=0.35 />,<div fontColor=#ffffff fontsize=24 outline=1,#478425>%s %s</div>", PathTool.getItemRes(item_config.icon), item_num, TI18N("刷新"))
						self.refresh_btn_label:setString(str) 
					end
				end
			end
		end
	end
end

function EscortEmployWindow:openRootWnd()
	self:updateMyRefreshTimes()

	local auto_refresh_config = Config.EscortData.data_const.steprefresh_cost  
	if auto_refresh_config and auto_refresh_config.val then
		if type(auto_refresh_config.val) == "table" then
			local config = auto_refresh_config.val[1]
			if config and #config >= 2 then
				local item_id = config[1]
				local item_num = config[2]
				local item_config = Config.ItemData.data_get_data(item_id)
				if item_config then
					local str = string.format("<img src=%s visible=true scale=0.35 />,<div fontColor=#ffffff fontsize=24 outline=1,#478425>%s %s</div>", PathTool.getItemRes(item_config.icon), item_num, TI18N("一键刷橙"))
					self.auto_refresh_btn_label:setString(str) 
				end
			end
		end
	end

	self:initConfig()

	local my_info = model:getMyInfo()
	local quality = 0
	if my_info then
		quality = my_info.quality or 0

		local config_time = model:getMyMaxCount(EscortConst.times_type.escort)
		local num = config_time - model:getMyCount(EscortConst.times_type.escort)
		if num  < 0 then
			num = 0
		end

		self.employ_times_value:setString(num.."/"..config_time)
	end
	self:changeQuailty(quality)
end

--==============================--
--desc:初始化奖励和模型相关数据
--time:2018-09-03 09:44:35
--@return 
--==============================--
function EscortEmployWindow:initConfig()
	for i,object in ipairs(self.item_list) do
		delayRun(self.background, i*4/display.DEFAULT_FPS, function()
			if object.config then
				self:createBaseInfo(object)
			end
		end)
	end
end

--==============================--
--desc:创建基础模型和奖励数据
--time:2018-09-03 09:21:46
--@object:
--@return 
--==============================--
function EscortEmployWindow:createBaseInfo(object)
	if object == nil or object.config == nil or tolua.isnull(object.item) then return end
	local config = object.config
	if object.player == nil then
		object.player = createEffectSpine(config.res, cc.p(100, 15), cc.p(0.5,0.5), true, PlayerAction.action_1)
		object.player:setScale(0.9)
		object.item:addChild(object.player)
	end
	if object.item_list == nil and object.config.quality then
		local awards_config = Config.EscortData.data_rewards(getNorKey(object.config.quality, role_vo.lev))
		if awards_config then
			object.item_list = {}
			local is_double = model:isDoubleTimes() or false
			local num_scale = 1
			if is_double == true then
				num_scale = 2
			end
			for i,v in ipairs(awards_config.award) do	-- 护送奖励
				local item = BackPackItem.new(false, true, false, 0.7, false, true)
				local _x = 217 + (BackPackItem.Width * 0.7 + 10) * (i - 1) + BackPackItem.Width * 0.7 * 0.5
				local _y = 58
				item:setPosition(_x, _y)
				item:setBaseData(v[1], v[2]*num_scale)
				item:setDoubleIcon(is_double)
				object.item:addChild(item)
				table_insert(object.item_list, item)
			end
		end
	end
end

--==============================--
--desc:刷新品质
--time:2018-09-03 08:37:29
--@quality:
--@return 
--==============================--
function EscortEmployWindow:changeQuailty(quality)
	if quality  == nil then return end
	if self.select_object then
		self.select_object.select:setVisible(false)
		self.select_object.normal:setVisible(true)
		self.select_object.item_status:setVisible(false) 
		self.select_object = nil
	end
	for i, object in ipairs(self.item_list) do
		if object and object.quality == quality then
			self.select_object = object
			self.select_object.select:setVisible(true)
		self.select_object.item_status:setVisible(true) 
			self.select_object.normal:setVisible(false)
		end
	end
end

function EscortEmployWindow:close_callback()
	if self.update_myinfo_event then
		GlobalEvent:getInstance():UnBind(self.update_myinfo_event)
		self.update_myinfo_event  = nil
	end
	for i,object in ipairs(self.item_list) do
		if object.item_list then
			for i,item in ipairs(object.item_list) do
				item:DeleteMe()
			end
		end
		if object.player then
			object.player:removeFromParent()
		end
	end
	self.item_list = nil
    controller:openEscortEmployWindow(false)
end

