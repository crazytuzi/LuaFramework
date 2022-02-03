--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-02-26 15:16:31
-- @description    : 
		-- 神器幻化
---------------------------------
HallowsMagicWindow = HallowsMagicWindow or BaseClass(BaseView)

local _controller = HallowsController:getInstance()
local _model = HallowsController:getInstance():getModel()
local _string_format = string.format
local _table_insert = table.insert
local _table_sort = table.sort

function HallowsMagicWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "hallows/hallows_magic_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("hallows", "hallows"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_81"), type = ResourcesType.single },
	}

	self.magic_status = HallowsConst.Magic_View_Status.Task
	self.base_attr_list = {}
	self.base_attr_bgs = {}
	self.cur_index = 1 -- 当前选中的幻化标识
	self.magic_id_list = {} -- 按照id从小到大排序的幻化id列表
	
	self:initSortMagicIdList()
end

-- 初始化幻化id列表（按照1.已解锁>可解锁>未解锁,2界面排序id进行排序）
function HallowsMagicWindow:initSortMagicIdList(  )
	local temp_data = {}
	for k,v in pairs(Config.HallowsData.data_magic) do
		local m_data = {}
		m_data.id = v.id
		m_data.sort = v.sort
		m_data.status = _model:getHallowsMagicStatus(v.id)
		_table_insert(temp_data, m_data)
	end
	local function sortFunc( objA, objB )
		if objA.status ~= objB.status then
			return objA.status < objB.status
		else
			return objA.sort < objB.sort
		end
	end
	_table_sort(temp_data, sortFunc)
	for i,v in ipairs(temp_data) do
		_table_insert(self.magic_id_list, v.id)
	end
end

function HallowsMagicWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
	    self:playEnterAnimatianByObj(self.main_container, 1)
	self.main_size = main_container:getContentSize()

	local top_bg = main_container:getChildByName("top_bg")
	top_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_81"), LOADTEXT_TYPE)

	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("神器幻化"))

	local title_bg = main_container:getChildByName("title_bg")
	self.hallows_name = title_bg:getChildByName("hallows_name")

	self.left_btn = main_container:getChildByName("left_btn")
	self.right_btn = main_container:getChildByName("right_btn")

	main_container:getChildByName("lock_title"):setString(TI18N("解锁效果："))

	self.task_panel = main_container:getChildByName("task_panel")
	self.task_panel:setVisible(false)
	self.item_panel = main_container:getChildByName("item_panel")
	self.item_panel:setVisible(false)
	self.open_panel = main_container:getChildByName("open_panel")
	self.open_panel:setVisible(false)

	self.task_panel:getChildByName("progress_title"):setString(TI18N("当前进度"))
	self.progress = self.task_panel:getChildByName("progress")
	self.progress:setScale9Enabled(true)
	self.progress:setPercent(0)
	self.progress_value = self.task_panel:getChildByName("progress_value")
	self.task_list = self.task_panel:getChildByName("task_list")

	self.unlock_btn = self.item_panel:getChildByName("unlock_btn")
	self.unlock_btn:getChildByName("label"):setString(TI18N("解 锁"))
	self.goto_btn = self.item_panel:getChildByName("goto_btn")
	self.goto_btn:setVisible(false)
	self.goto_btn:getChildByName("label"):setString(TI18N("前往获取"))
	self.item_tips = self.item_panel:getChildByName("item_tips")
	--self.item_tips:setString(TI18N("精英大赛获得后自动解锁"))

	self.open_panel:getChildByName("open_title"):setString(TI18N("全神器基础属性"))
	self.magic_tips = self.open_panel:getChildByName("magic_tips")
	self.magic_btn = self.open_panel:getChildByName("magic_btn")
	self.magic_btn:getChildByName("label"):setString(TI18N("幻 化"))
	self.cancel_magic_btn = self.open_panel:getChildByName("cancel_magic_btn")
	self.cancel_magic_btn:getChildByName("label"):setString(TI18N("取消幻化"))
	self.time_txt = self.open_panel:getChildByName("time_txt")
	self.base_attr_bgs = {}
	for i=1,2 do
		local attr_bg = self.open_panel:getChildByName("attr_bg_" .. i)
		if attr_bg then
			_table_insert(self.base_attr_bgs, attr_bg)
		end
	end
end

-- 初始化任务列表
function HallowsMagicWindow:createTaskScrollview(  )
	if self.task_scrollview or not self.task_list then return end

	local bgSize = self.task_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width-10, bgSize.height-10)
    local setting = {
        item_class = HallowsMagicTaskItem,      -- 单元类
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 12,                    -- 第一个单元的Y起点
        space_y = 6,                   -- y方向的间隔
        item_width = 319,               -- 单元的尺寸width
        item_height = 135,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.task_scrollview = CommonScrollViewLayout.new(self.task_list, cc.p(5,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function HallowsMagicWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
	registerButtonEventListener(self.left_btn, handler(self, self._onClickLeftBtn), false)
	registerButtonEventListener(self.right_btn, handler(self, self._onClickRightBtn), false)
	registerButtonEventListener(self.unlock_btn, handler(self, self._onClickUnlockBtn), true)
	registerButtonEventListener(self.goto_btn, handler(self, self._onClickGotoBtn), true)
	registerButtonEventListener(self.magic_btn, handler(self, self._onClickMagicBtn), true)
	registerButtonEventListener(self.cancel_magic_btn, handler(self, self._onClickCancelMagicBtn), true)

	-- 幻化数据更新
	self:addGlobalEvent(HallowsEvent.UpdateHallowsMagicDataEvent, function ( id )
		if self.magic_config and self.magic_config.id == id then
			self:setData(self.hallows_data, id)
		end
	end)
	
	-- 幻化任务数据更新
	self:addGlobalEvent(HallowsEvent.UpdateHallowsMagicTaskEvent, function (  )
		if self.magic_status == HallowsConst.Magic_View_Status.Task then
			self:showHallowsMagicTaskInfo()
		end
	end)
end

-- 向左翻
function HallowsMagicWindow:_onClickLeftBtn(  )
	self.cur_index = self.cur_index - 1
	if self.cur_index < 1 then
		self.cur_index = #self.magic_id_list
	end
	local magic_id = self.magic_id_list[self.cur_index]
	self:setData(self.hallows_data, magic_id)
end

-- 向右翻
function HallowsMagicWindow:_onClickRightBtn(  )
	self.cur_index = self.cur_index + 1
	if self.cur_index > #self.magic_id_list then
		self.cur_index = 1
	end
	local magic_id = self.magic_id_list[self.cur_index]
	self:setData(self.hallows_data, magic_id)
end

--解锁幻化
function HallowsMagicWindow:_onClickUnlockBtn(  )
	if self.magic_config then
		_controller:send24131(self.magic_config.id)
	end
end

-- 前往精英大赛
function HallowsMagicWindow:_onClickGotoBtn(  )
	if self.magic_config then
		local source_cfg = Config.SourceData.data_source_data[self.magic_config.evt_id]
        if source_cfg then
        	if self.magic_config.evt_id == 115 and not ElitematchController:getInstance():getModel():checkElitematchIsOpen() then
        		return
        	end
            BackpackController:getInstance():gotoItemSources(source_cfg.evt_type, source_cfg.extend)
            _controller:openHallowsMagicWindow(false)
			_controller:openHallowsMainWindow(false)
        end
	end
end

-- 幻化
function HallowsMagicWindow:_onClickMagicBtn(  )
	if self.magic_config and self.hallows_data then
		_controller:send24132(self.magic_config.id, self.hallows_data.id, 1)
	end
end

-- 取消幻化
function HallowsMagicWindow:_onClickCancelMagicBtn(  )
	if self.magic_data then
		_controller:send24132(self.magic_data.id, self.magic_data.eqm_hallows, 2)
	end
end

function HallowsMagicWindow:_onClickCloseBtn(  )
	_controller:openHallowsMagicWindow(false)
end

function HallowsMagicWindow:openRootWnd( data, id )
	self:setData(data)
	self.default_id = id
end

function HallowsMagicWindow:setData( data, id )
	self.hallows_data = data or {}
	self.hallows_vo = self.hallows_data.vo
	local magic_id = id or self:getDefaultChosedMagicId()
	self.magic_config = Config.HallowsData.data_magic[magic_id]
	self.magic_data = _model:getHallowsMagicDataById(magic_id)
	
	if self.hallows_vo and self.magic_config then
		self:showHallowsMagicBaseInfo()

		if not self.magic_data or next(self.magic_data) == nil then
			if self.magic_config.is_item == 0 then
				self.magic_status = HallowsConst.Magic_View_Status.Task
			else
				self.magic_status = HallowsConst.Magic_View_Status.Item
			end
		else
			self.magic_status = HallowsConst.Magic_View_Status.Open
		end

		self.task_panel:setVisible(self.magic_status == HallowsConst.Magic_View_Status.Task)
		self.item_panel:setVisible(self.magic_status == HallowsConst.Magic_View_Status.Item)
		self.open_panel:setVisible(self.magic_status == HallowsConst.Magic_View_Status.Open)
		if self.magic_status == HallowsConst.Magic_View_Status.Task then
			self:showHallowsMagicTaskInfo()
		elseif self.magic_status == HallowsConst.Magic_View_Status.Item then
			self:showHallowsMagicItemInfo()
		elseif self.magic_status == HallowsConst.Magic_View_Status.Open then
			self:showHallowsMagicOpenInfo()
		end
	end
end

-- 获取默认选中的幻化id
--[[
1.显示红点的神器幻化
2.幻化到本神器上的
3.已解锁但未幻化的
4.已解锁但幻化到其他神器上的
5.未解锁的
]]
function HallowsMagicWindow:getDefaultChosedMagicId(  )
	if self.default_id then return self.default_id end
	local magic_id = self.magic_id_list[1] or 1
	local temp_index = 0
	for i,id in ipairs(self.magic_id_list) do
		local red_status = _model:checkHallowsMagicIsShowRed(id)
		local magic_data = _model:getHallowsMagicDataById(id)
		if red_status then  -- 有红点
			magic_id = id
			break
		elseif self.hallows_vo.look_id ~= 0 and magic_data.eqm_hallows and magic_data.eqm_hallows == self.hallows_vo.look_id then -- 该皮肤幻化到选中的神器上
			if temp_index < 4 then
				magic_id = id
				temp_index = 4
			end
		elseif next(magic_data) ~= nil and magic_data.eqm_hallows == 0 then -- 已解锁但未幻化到神器上
			if temp_index < 3 then
				magic_id = id
				temp_index = 3
			end
		elseif next(magic_data) ~= nil and magic_data.eqm_hallows ~= 0 then -- 已解锁但幻化到其他神器上
			if temp_index < 2 then
				magic_id = id
				temp_index = 2
			end
		else
			if temp_index < 1 then
				magic_id = id
				temp_index = 1
			end
		end
	end

	for i,v in ipairs(self.magic_id_list) do
		if v == magic_id then
			self.cur_index = i
		end
	end

	return magic_id
end

-- 幻化基础信息
function HallowsMagicWindow:showHallowsMagicBaseInfo(  )
	-- 避免重复刷新
	if self.cur_magic_id and self.cur_magic_id == self.magic_config.id then
		return
	end
	self.cur_magic_id = self.magic_config.id
	-- 幻化名称
	self.hallows_name:setString(self.magic_config.name)
	-- 幻化模型
	if self.hallows_model then
		self.hallows_model:clearTracks()
		self.hallows_model:removeFromParent()
		self.hallows_model = nil
	end
	self.hallows_model = createEffectSpine(self.magic_config.effect, cc.p(self.main_size.width/2, 535), cc.p(0.5,0.5), true, PlayerAction.action_2)
	self.main_container:addChild(self.hallows_model)
	-- 未拥有则置灰
	if _model:checkHallowsMagicIsHave(self.magic_config.id) then
		setChildUnEnabled(false, self.hallows_model)
		self.hallows_model:setAnimation(0, PlayerAction.action_2, true)
	else
		setChildUnEnabled(true, self.hallows_model)
		self.hallows_model:setAnimation(0, PlayerAction.action_1, true)
	end

	-- 解锁效果
	if not self.magic_desc then
		self.magic_desc = createRichLabel(20, cc.c3b(255, 238, 194), cc.p(0.5, 0.5), cc.p(self.main_size.width/2, 445), 10, nil, 400)
		self.main_container:addChild(self.magic_desc)
	end
	self.magic_desc:setString(self.magic_config.desc or "")
end

-- 幻化任务列表
function HallowsMagicWindow:showHallowsMagicTaskInfo(  )
	if not self.task_scrollview then
		self:createTaskScrollview()
	end
	if self.task_scrollview then
		local task_list = _model:getMagicTaskListById(self.magic_config.id)
		if task_list then
			local max_num = tableLen(task_list)
			local cur_num = 0
			for k,v in pairs(task_list) do
				if v.finish == 2 then
					cur_num = cur_num + 1
				end
			end
			local percent = 100 * cur_num / max_num
			self.progress:setPercent(percent)
			self.progress_value:setString(cur_num.."/"..max_num)
		end

		self.task_scrollview:setData(task_list)
	end
end

-- 幻化道具解锁
function HallowsMagicWindow:showHallowsMagicItemInfo(  )
	if not self.magic_config or not self.magic_config.loss[1] then return end

	if not self.magic_item then
		self.magic_item = BackPackItem.new(true, true)
		self.magic_item:setDefaultTip(true, true)
		self.magic_item:setPosition(cc.p(self.main_size.width/2, 230))
		self.item_panel:addChild(self.magic_item)
	end

	local loss_item_bid = self.magic_config.loss[1][1]
	local loss_item_num = self.magic_config.loss[1][2]
	local have_num = BackpackController:getInstance():getModel():getItemNumByBid(loss_item_bid)
	self.magic_item:setBaseData(loss_item_bid)
	self.magic_item:setNeedNum(loss_item_num, have_num)

	-- 是否为自动激活
	if self.magic_config.is_item == 1 then -- 道具解锁，手动激活
		self.unlock_btn:setVisible(true)
	elseif self.magic_config.is_item == 2 then -- 道具解锁，自动激活
		self.unlock_btn:setVisible(false)
	end
	-- 解锁描述
	if not self.magic_config.get_des or self.magic_config.get_des == "" then
		self.item_tips:setVisible(false)
	else
		self.item_tips:setVisible(true)
		self.item_tips:setString(self.magic_config.get_des)
	end
	-- 解锁跳转
	if self.magic_config.evt_id and self.magic_config.evt_id ~= 0 then
		self.goto_btn:setVisible(true)
	else
		self.goto_btn:setVisible(false)
	end
end

-- 幻化已获得
function HallowsMagicWindow:showHallowsMagicOpenInfo(  )
	if not self.magic_config then return end
	-- 基础属性
	for k,v in pairs(self.base_attr_list) do
		v:setVisible(false)
	end
	for i,attr in ipairs(self.magic_config.attr) do
		local attr_key = attr[1]
		local attr_val = attr[2]
		if attr_key and attr_val then
			local attr_name = Config.AttrData.data_key_to_name[attr_key]
			local attr_text = self.base_attr_list[i]
			local attr_bg = self.base_attr_bgs[i]
			if attr_text == nil and attr_bg then
				attr_text = createRichLabel(24, cc.c4b(100,50,35,255), cc.p(0.5, 0.5), cc.p(130, 19.5), nil, nil, 380)
				attr_bg:addChild(attr_text)
				self.base_attr_list[i] = attr_text
			end
			attr_text:setVisible(true)
			local icon = PathTool.getAttrIconByStr(attr_key)
			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
			if is_per == true then
                attr_val = (attr_val/10) .."%"
            end
            local attr_str = _string_format("<img src='%s' scale=1 /> <div fontcolor=#643223> %s：</div><div fontcolor=#643223>%s</div>", PathTool.getResFrame("common", icon), attr_name, tostring(attr_val))
			attr_text:setString(attr_str)
		end
	end

	-- 是否已经有神器幻化
	if self.magic_data.eqm_hallows ~= 0 then
		local hallows_cfg = Config.HallowsData.data_base[self.magic_data.eqm_hallows]
		if hallows_cfg then
			self.magic_tips:setString(_string_format(TI18N("已幻化:%s"), hallows_cfg.name))
			self.magic_tips:setVisible(true)
		end
		-- 幻化对象是否为选中的神器
		if self.magic_data.eqm_hallows == self.hallows_data.id then
			self.magic_btn:setVisible(false)
			self.cancel_magic_btn:setVisible(true)
		else
			self.magic_btn:setVisible(true)
			self.cancel_magic_btn:setVisible(false)
		end
	else
		self.magic_tips:setVisible(false)
		self.magic_btn:setVisible(true)
		self.cancel_magic_btn:setVisible(false)
	end

	-- 到期时间
	if self.magic_data.endtime ~= 0 then
		self.time_txt:setVisible(true)
		local cur_time = GameNet:getInstance():getTime()
		local left_time = self.magic_data.endtime - cur_time
		if left_time < 0 then left_time = 0 end
		self.time_txt:setString(TimeTool.GetTimeFormatDayII(left_time) .. TI18N("后失效"))
		if left_time <= 24*60*60 then --剩余时间小于1天时则进行实时更新 
			self:setLessTime(left_time)
		end
	else
		self.time_txt:setVisible(false)
	end
end

--设置倒计时
function HallowsMagicWindow:setLessTime( less_time )
    if tolua.isnull(self.time_txt) then return end
    self.time_txt:stopAllActions()
    if less_time > 0 then
        self.time_txt:setString(TimeTool.GetTimeFormatDayII(less_time) .. TI18N("后失效"))
        self.time_txt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.time_txt:stopAllActions()
            else
                self.time_txt:setString(TimeTool.GetTimeFormatDayII(less_time) .. TI18N("后失效"))
            end
        end))))
    else
        self.time_txt:setString(TimeTool.GetTimeFormatDayII(less_time) .. TI18N("后失效"))
    end
end

function HallowsMagicWindow:close_callback(  )
	if self.task_scrollview then
		self.task_scrollview:DeleteMe()
		self.task_scrollview = nil
	end
	if self.magic_item then
		self.magic_item:DeleteMe()
		self.magic_item = nil
	end
	if self.hallows_model then
		self.hallows_model:clearTracks()
		self.hallows_model:removeFromParent()
		self.hallows_model = nil
	end
	if not tolua.isnull(self.time_txt) then
		self.time_txt:stopAllActions()
	end
	_controller:openHallowsMagicWindow(false)
end

------------------------@ 任务 item
HallowsMagicTaskItem = class("HallowsMagicTaskItem", function()
    return ccui.Widget:create()
end)

function HallowsMagicTaskItem:ctor()
	self:configUI()
	self:register_event()
end

function HallowsMagicTaskItem:configUI(  )
	self.size = cc.size(319, 135)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("hallows/hallows_magic_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.get_btn = container:getChildByName("get_btn")
    self.get_btn:getChildByName("label"):setString(TI18N("领取"))
    self.goto_btn = container:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):setString(TI18N("前往"))
    self.finish_icon = container:getChildByName("finish_icon")
    self.task_desc = container:getChildByName("task_desc")
end

function HallowsMagicTaskItem:register_event(  )
	registerButtonEventListener(self.get_btn, handler(self, self._onClickGetBtn), true)
	registerButtonEventListener(self.goto_btn, handler(self, self._onClickGotoBtn), true)
end

function HallowsMagicTaskItem:_onClickGetBtn(  )
	if self.config then
		_controller:send24130(self.config.id)
	end
end

function HallowsMagicTaskItem:_onClickGotoBtn(  )
	if self.config then
		TaskController:getInstance():gotoTagertFun(self.config.progress[1], self.config.extra)
	end
end

function HallowsMagicTaskItem:setData( data )
	if not data then return end

	self.data = data
	if data then
		local config = Config.HallowsData.data_magic_task[data.id]
		if config then
			self.task_desc:setString(_string_format("%s(%s/%s)", config.desc, data.value or 0, data.target_val or 0))

			local item_list = config.items
			-- 取出第一个物品
			if item_list and item_list[1] then
				if not self.award_item then
					self.award_item = BackPackItem.new(false, true, false, 0.7, false, true)
					self.award_item:setPosition(cc.p(62, 53))
					self.container:addChild(self.award_item)
				end
				self.award_item:setBaseData(item_list[1][1], item_list[1][2])
			end

			self.config = config
		end

		self.goto_btn:setVisible(false)
		self.get_btn:setVisible(false)
		self.finish_icon:setVisible(false)

		if data.finish == 0 then
			self.goto_btn:setVisible(true)
		elseif data.finish == 1 then
			self.get_btn:setVisible(true)
			addRedPointToNodeByStatus(self.get_btn, true, 5, 5)
		elseif data.finish == 2 then
			self.finish_icon:setVisible(true)
		end
	end
end

function HallowsMagicTaskItem:DeleteMe(  )
	if self.award_item then
		self.award_item:DeleteMe()
		self.award_item = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end