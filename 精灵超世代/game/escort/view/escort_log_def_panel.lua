-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      护送被掠夺界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortLogDefPanel = EscortLogDefPanel or BaseClass()

local controller = EscortController:getInstance() 
local model = controller:getModel()
local baseinfo_config = Config.EscortData.data_baseinfo 
local string_format = string.format
local role_vo = RoleController:getInstance():getRoleVo()
local game_net = GameNet:getInstance()

function EscortLogDefPanel:__init(parent)
    self.is_init = false 
    self.parent = parent
    self:createRoorWnd()
	self:registerEvent()
end

function EscortLogDefPanel:createRoorWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("escort/escort_log_def_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.root_wnd:getChildByName("desc_label"):setString(TI18N("选择求助后不得再复仇\n对每个掠夺者只有2次复仇"))
    self.root_wnd:getChildByName("atk_label"):setString(TI18N("今日复仇次数:"))
    self.root_wnd:getChildByName("help_label"):setString(TI18N("今日求助次数:"))

    self.atk_value = self.root_wnd:getChildByName("atk_value")
    self.atk_value = self.root_wnd:getChildByName("help_value")

    self.item = self.root_wnd:getChildByName("item")
    self.item:setVisible(false)

    self.empty_tips = self.root_wnd:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("胆敢掠夺冒险者大人的人，世界上不存在！"))

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.root_wnd:getChildByName("atk_label"):setString(TI18N("今日复仇次数:"))
    self.root_wnd:getChildByName("help_label"):setString(TI18N("今日求助次数:"))

    self.atk_value = self.root_wnd:getChildByName("atk_value")
    self.help_value = self.root_wnd:getChildByName("help_value")

    self.desc_label = self.root_wnd:getChildByName("desc_label")
    self.desc_label:setString(TI18N("选择求助后不得再复仇\n对每个掠夺者只有2次复仇"))

	local str = TI18N("选择求助后不得再复仇\n对每个掠夺者只有2次复仇")
	local conifg = Config.EscortData.data_const.single_revenge_limit
	if config then
		str = string_format(TI18N("选择求助后不得再复仇\n对每个掠夺者只有%s次复仇"), config.val)
	end
end

function EscortLogDefPanel:registerEvent()
	if self.update_my_info_event == nil then
		self.update_my_info_event = GlobalEvent:getInstance():Bind(EscortEvent.UpdateEscortMyInfoEvent, function() 
			self:updateMyInfo()
		end)
	end
end

function EscortLogDefPanel:updateMyInfo()
	local max_num_1 = model:getMyMaxCount(EscortConst.times_type.help)
	local max_num_2 = model:getMyMaxCount(EscortConst.times_type.atk_back)
	local cur_num_1 = model:getMyCount(EscortConst.times_type.help)			-- 求助次数
	local cur_num_2 = model:getMyCount(EscortConst.times_type.atk_back)		-- 复仇次数
	cur_num_1 = max_num_1 - cur_num_1
	cur_num_2 = max_num_2 - cur_num_2
	if cur_num_1 < 0 then cur_num_1 = 0 end
	if cur_num_2 < 0 then cur_num_2 = 0 end
	self.help_value:setString(cur_num_1.."/"..max_num_1)
	self.atk_value:setString(cur_num_2.."/"..max_num_2)
end

function EscortLogDefPanel:addToParent(status)
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
    if status == true then
        if self.is_init == false then
            self.is_init = true
			self:updateMyInfo()
            controller:requestLogByType(EscortConst.log_type.def)
        end
    end
end

function EscortLogDefPanel:refreshData(list)
	if list == nil or next(list) == nil then return end
	if self.scroll_view then		-- 只需要刷新数据
		self.scroll_view:resetAddPosition(list)
	end
end 

function EscortLogDefPanel:setData(list)
    if list == nil or next(list) == nil then
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
		if self.empty_tips then
			self.empty_tips:setVisible(true)
		end
	else
		if self.scroll_view == nil then
			local size = self.main_panel:getContentSize()
			local setting = {
				item_class = EscortLogDefItem,
				start_x = 4,
				space_x = 0,
				start_y = 7,
				space_y = 0,
				item_width = 600,
				item_height = 156,
				row = 0,
				col = 1,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.main_panel, nil, nil, nil, size, setting)
		end
		self.scroll_view:setData(list, nil, nil, self.item)
		self.scroll_view:setVisible(true)
		if self.empty_tips then
			self.empty_tips:setVisible(false)
		end
	end
end 

function EscortLogDefPanel:__delete()
	if self.update_my_info_event then
		GlobalEvent:getInstance():UnBind(self.update_my_info_event)
		self.update_my_info_event = nil
	end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      被掠夺单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortLogDefItem = class("EscortLogDefItem", function()
	return ccui.Layout:create()
end)

function EscortLogDefItem:ctor()
	self.is_completed = false
end

function EscortLogDefItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
		self:addChild(self.root_wnd)

        self.root_wnd:getChildByName("item_title"):setString(TI18N("掠夺对象:"))
        self.root_wnd:getChildByName("guild_title"):setString(TI18N("公会:"))
		self.fight_container = self.root_wnd:getChildByName("fight_container")
        self.role_power = self.fight_container:getChildByName("role_power")

        self.role_name = self.root_wnd:getChildByName("role_name")
        self.item_name = self.root_wnd:getChildByName("item_name")
        self.time_label = self.root_wnd:getChildByName("time_label")
		self.guild_value = self.root_wnd:getChildByName("guild_value") 

		self.btn_container = self.root_wnd:getChildByName("btn_container")

        self.atk_btn = self.btn_container:getChildByName("atk_btn")
        self.atk_btn_label = self.atk_btn:getChildByName("label")

		self.cool_time = self.root_wnd:getChildByName("cool_time")

        self.help_btn = self.btn_container:getChildByName("help_btn")
        self.help_btn_label = self.help_btn:getChildByName("label")

		self.vedio_btn = self.root_wnd:getChildByName("vedio_btn")

        self.role_head = PlayerHead.new(PlayerHead.type.circle)
        self.role_head:setPosition(72, 78)
        self.root_wnd:addChild(self.role_head)
        self.role_head:setLev(99)

		self:registerEvent()
	end
end

function EscortLogDefItem:registerEvent()
	self.vedio_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
				BattleController:getInstance():csRecordBattle(self.data.replay_id) 
			end
		end
	end)
	self.atk_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
				controller:requestPlunderInfo(role_vo.rid, role_vo.srv_id, self.data.id, EscortConst.challenge_type.revenge) 
			end
		end
	end)
	self.help_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
				local str = TI18N("求助后将向全会发送公告,若会友击退了掠夺者,你和会友都会获得奖励,是否确定求助?(求助后不能进行复仇)")
				CommonAlert.show(str,TI18N("确定"),function() 
					controller:requestGuildForHelp(self.data.id)
				end,TI18N("取消"))
			end
		end
	end)
end

function EscortLogDefItem:setData(data)
	self.data = data
	if data then
		self.role_head:setHeadRes(data.face)
		self.role_head:setLev(data.lev)
		self.role_power:setString(data.power)
		self.time_label:setString(TimeTool.getYMDHMS(data.time))
		self.role_name:setString(transformNameByServ(data.name, data.srv_id))

		self.fight_container:setPositionX(self.role_name:getPositionX()+self.role_name:getContentSize().width+10)

		if data.guild_name == "" then
			self.guild_value:setString(TI18N("暂无公会"))
		else
			self.guild_value:setString(data.guild_name)
		end

		if data.quality then
			local config = baseinfo_config[data.quality]
			if config then
				local color = EscortConst.quality_color[data.quality]
				if color then
					self.item_name:setTextColor(color)
				end
				self.item_name:setString(config.title)
			end
		end

		if data.atk_ret == 1 then -- 反击成功
			self.cool_time:setVisible(true) 
			self.btn_container:setVisible(false)
			self.cool_time:setString(TI18N("复仇成功"))
		elseif data.atk_ret == 2 then
			self.cool_time:setVisible(true) 
			self.btn_container:setVisible(false)
			self.cool_time:setString(TI18N("复仇失败"))
		else
			local const_config = Config.EscortData.data_const.single_revenge_limit
			if const_config then
				local atk_count = const_config.val - data.atk_count 
				if atk_count < 0 then
					atk_count = 0
				end
				self.atk_btn_label:setString(string_format(TI18N("复仇(%s/%s)"), atk_count, const_config.val))
			end
			-- if role_vo.gid == 0 then
				-- self.help_btn:setVisible(false)
				-- self.atk_btn:setPositionY(78)
			-- else
				-- self.help_btn:setVisible(true)
				-- self.atk_btn:setPositionY(108)
			-- end
			self:timeTicket()
		end
	end
end

function EscortLogDefItem:timeTicket()
	if self.data == nil then return end
	local data = self.data
	if data.help_time <= game_net:getTime() then  --这个标识已经求助完了
		self.btn_container:setVisible(true)
		self.cool_time:setVisible(false) 
	else
		self.btn_container:setVisible(false)
		self.cool_time:setVisible(true) 
		self:setCoolTime()
		if self.time_ticket == nil then
			self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
				self:setCoolTime()
			end, 1)
		end
	end
end

function EscortLogDefItem:setCoolTime()
	if self.data == nil then
		self:clearTimeTicket()
		return
	end
	local _time = self.data.help_time - game_net:getTime() 
	if _time < 0 then
		_time = 0
		self.btn_container:setVisible(true)
		self.cool_time:setVisible(false) 
		self:clearTimeTicket()
	end
	self.cool_time:setString(string_format(TI18N("%s后\n可复仇或求助"), TimeTool.GetMinSecTime(_time)))
end

function EscortLogDefItem:clearTimeTicket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function EscortLogDefItem:suspendAllActions()
	self:clearTimeTicket()
end

function EscortLogDefItem:DeleteMe()
	self:clearTimeTicket()
    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end 