-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣器的主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsTaskWindow = HallowsTaskWindow or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local model = HallowsController:getInstance():getModel()

local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort

local hallows_info_config = Config.HallowsData.data_info
local hallows_skill_config = Config.HallowsData.data_skill_up

local hallows_data_task = Config.HallowsData.data_task

function HallowsTaskWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("hallows", "hallows"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_68", true), type = ResourcesType.single}
	}
	self.layout_name = "hallows/hallows_task_window"

	self.is_have = false -- 是否已经拥有
	self.attr_bgs = {}
	self.base_attr_list = {}
	self.all_hallows_id = {} -- 所有神器id(有序，翻页按钮用)
	self.cur_index = 1 		 -- 当前选中的神器在all_hallows_id的下标
end 

function HallowsTaskWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_68", true), LOADTEXT_TYPE)

	local main_panel = self.root_wnd:getChildByName("main_panel")
	self:playEnterAnimatianByObj(main_panel, 1)
	self.task_panel = main_panel:getChildByName("task_panel")
	self.attr_panel = main_panel:getChildByName("attr_panel")
	self.attr_panel:setVisible(false)
	self.attr_panel:getChildByName("desc_label"):setString(TI18N("出战界面选择穿戴激活神器技能和主属性"))
	self.go_battle_btn = self.attr_panel:getChildByName("go_battle_btn")
	local go_battle_label = self.go_battle_btn:getChildByName("label")
	go_battle_label:enableOutline(Config.ColorData.data_color4[263],2)
	go_battle_label:setString(TI18N("去探险"))

	self.trainer_sp = main_panel:getChildByName("trainer_sp")

	local title_bg = main_panel:getChildByName("title_bg")
	self.hallows_name = title_bg:getChildByName("hallows_name")

	self.explain_btn = main_panel:getChildByName("explain_btn")
	self.artifact_btn = main_panel:getChildByName("artifact_btn")
	local artifact_btn_label = self.artifact_btn:getChildByName("label")
	artifact_btn_label:setString(TI18N("失落神器"))
	self.touch_layout = main_panel:getChildByName("touch_layout")

	local progress_container = main_panel:getChildByName("progress_container")
	progress_container:getChildByName("title"):setString(TI18N("当前进度"))
	self.progress = progress_container:getChildByName("progress")
    --self.progress:setScale9Enabled(true)
	self.progress_value = progress_container:getChildByName("value")

	self.left_btn = main_panel:getChildByName("left_btn")
	self.right_btn = main_panel:getChildByName("right_btn")

	self.skill_bg = main_panel:getChildByName("skill_bg")
	self.list_view = self.task_panel:getChildByName("list_view")

	for i=1,2 do
		local attr_bg = self.attr_panel:getChildByName("attr_bg_"  .. i)
		self.attr_bgs[i] = attr_bg
	end

	self.item = main_panel:getChildByName("item")
	self.item:setVisible(false)

	self.main_panel = main_panel

	-- 适配
	local top_off = display.getTop(main_panel)
	title_bg:setPositionY(top_off - 113)
	self.explain_btn:setPositionY(top_off - 113)
end

function HallowsTaskWindow:register_event()
	registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
       	local config = Config.HallowsData.data_const.game_rule
		local pos = sender:getTouchBeganPosition()
		local code = cc.Application:getInstance():getCurrentLanguageCode()
		if code ~= "zh" then
			local x = pos.x
			pos = cc.p(pos.x, 0)
		end
        TipsManager:getInstance():showCommonTips(config.desc, pos,nil,nil,600,true)
    end,true, 1)

	registerButtonEventListener(self.artifact_btn, handler(self, self._onClickBtnArtifact), true)
	registerButtonEventListener(self.go_battle_btn, handler(self, self._onClickBtnGoBattle), true)
	registerButtonEventListener(self.left_btn, handler(self, self._onClickBtnLeft))
	registerButtonEventListener(self.right_btn, handler(self, self._onClickBtnRight))
	registerButtonEventListener(self.touch_layout, handler(self, self._onClickTouchLayout))

	-- 任务变化
	self:addGlobalEvent(HallowsEvent.UpdateHallowsTaskEvent, function() 
		self:updateHallowsTaskInfo()
	end)
	-- 神器数据更新
	self:addGlobalEvent(HallowsEvent.HallowsUpdateEvent, function (id)
		if id == self.hallows_id then
			self:refreshView()
		end
	end)
	-- 激活圣器
	self:addGlobalEvent(HallowsEvent.HallowsActivityEvent, function()
		local hallows_id = model:getCurActivityHallowsId()
		if hallows_id then
			self.hallows_id = hallows_id
			self:initUnlockHallowsData(hallows_id)
			self:refreshView()
		end
	end)
	-- 显示为某一神器（从所有神器预览界面打开）
	self:addGlobalEvent(HallowsEvent.UndateHallowsInfoEvent, function (id)
		if id and self.hallows_id ~= id then
			self.hallows_id = id
			self:initUnlockHallowsData(id)
			self:refreshView()
		end
	end)
end

-- 打开所有神器界面
function HallowsTaskWindow:_onClickBtnArtifact(  )
	controller:openHallowsPreviewWindow(true)
end

-- 去探险
function HallowsTaskWindow:_onClickBtnGoBattle(  )
	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
	controller:openHallowsMainWindow(false)
end

-- 向左翻页
function HallowsTaskWindow:_onClickBtnLeft(  )
	self.cur_index = self.cur_index - 1
	if self.cur_index < 1 then
		self.cur_index = #self.all_hallows_id
	end
	self.hallows_id = self.all_hallows_id[self.cur_index]
	self:refreshView()
end

-- 向右翻页
function HallowsTaskWindow:_onClickBtnRight(  )
	self.cur_index = self.cur_index + 1
	if self.cur_index > #self.all_hallows_id then
		self.cur_index = 1
	end
	self.hallows_id = self.all_hallows_id[self.cur_index]
	self:refreshView()
end

-- 点击神器显示tip
function HallowsTaskWindow:_onClickTouchLayout(  )
	if self.hallows_id then
		local max_vo = model:makeHighestHallowVo(self.hallows_id)
		controller:getInstance():openHallowsTips(true, max_vo)
	end
end


-- 设置已解锁和正在进行的神器数据
function HallowsTaskWindow:initUnlockHallowsData( hallows_id )
	self.all_hallows_id = {}
	local activity_id = model:getCurActivityHallowsId() -- 正在进行中的神器id
	for i,config in ipairs(Config.HallowsData.data_base) do
		if model:getHallowsById(config.id) or config.id == activity_id then
			table_insert(self.all_hallows_id, config.id)
			if hallows_id and config.id == hallows_id then
				self.cur_index = #self.all_hallows_id
			end
		end
	end
	self.left_btn:setVisible(#self.all_hallows_id>1)
	self.right_btn:setVisible(#self.all_hallows_id>1)
end

function HallowsTaskWindow:openRootWnd(hallows_id)
	hallows_id = hallows_id or model:getCurActivityHallowsId()
	if hallows_id then
		self.hallows_id = hallows_id

		self:initUnlockHallowsData(hallows_id)
		self:refreshView()
	end
end

-- 刷新界面
function HallowsTaskWindow:refreshView( )
	self:updateHallowsBaseInfo()
	self:updateHallowsTaskInfo()
	self:updateHallowsSkillInfo()
end

function HallowsTaskWindow:updateHallowsBaseInfo()
	if self.hallows_id == nil then return end
	local hallows_config = Config.HallowsData.data_base[self.hallows_id]
	if hallows_config == nil then return end
	if self.hallows_model_id ~= hallows_config.effect then
		self.hallows_model_id = hallows_config.effect
		--if self.hallows_model then
		--	self.hallows_model:removeFromParent()
		--	self.hallows_model = nil
		--end
		--self.hallows_model = createEffectSpine(self.hallows_model_id,cc.p(354, 775), cc.p(0.5,0.5), true, PlayerAction.action_1)
		--self.main_panel:addChild(self.hallows_model)

		loadSpriteTexture(self.trainer_sp, "resource/hallows/trainer_big_"..self.hallows_id..".png", LOADTEXT_TYPE)
	end
	self.hallows_name:setString(hallows_config.name)

	if model:getHallowsById(self.hallows_id) then
		--setChildUnEnabled(false, self.hallows_model)
		--self.hallows_model:setAnimation(0, PlayerAction.action_2, true)

		setChildUnEnabled(false, self.trainer_sp)
	else
		--setChildUnEnabled(true, self.hallows_model)
		--self.hallows_model:setAnimation(0, PlayerAction.action_1, true)

		setChildUnEnabled(true, self.trainer_sp)
	end
end

function HallowsTaskWindow:updateHallowsTaskInfo()
	if self.hallows_id == nil then return end

	-- 判断是否已获得
	if model:getHallowsById(self.hallows_id) then
		self.attr_panel:setVisible(true)
		self.task_panel:setVisible(false)

		self.progress:setPercent(100)
		self.progress_value:setString(TI18N("已完成"))

		for k,v in pairs(self.base_attr_list) do
			v:setVisible(false)
		end

		local hallows_base = hallows_info_config(getNorKey(self.hallows_id, 1))
		if hallows_base then
			for i,attr in ipairs(hallows_base.attr) do
				if i > 2 then break end -- UI只支持显示两个技能
				local attr_key = attr[1]
				local attr_val = changeBtValueForPower(attr[2], attr_key) or 0
				local attr_name = Config.AttrData.data_key_to_name[attr_key]
				if attr_name then
					local attr_text = self.base_attr_list[i]
					if attr_text == nil then
						attr_text = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
						local attr_bg = self.attr_bgs[i]
						attr_text:setPosition(cc.p(12, 19))
						attr_bg:addChild(attr_text)
						self.base_attr_list[i] = attr_text
					end
					attr_text:setVisible(true)
					local icon = PathTool.getAttrIconByStr(attr_key)
		            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
		            if is_per == true then
		                attr_val = (attr_val/10) .."%"
		            end
		            local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#3d5078> %s%s：</div><div fontcolor=#3d5078>%s</div>", PathTool.getResFrame("common", icon), TI18N("全队"), attr_name, tostring(attr_val))
		            attr_text:setString(attr_str)
				end
			end
		end
	else
		self.attr_panel:setVisible(false)
		self.task_panel:setVisible(true)

		local task_list = model:getHallowsTaskList(self.hallows_id)
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

		if self.scroll_view == nil then
			local size = self.list_view:getContentSize()
			local setting = {
				item_class = HallowsTaskItem,
				start_x = 1,
				space_x = 1,
				start_y = 1,
				space_y = 1,
				item_width = 337,
				item_height = 139,
				row = 0,
				col = 2,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)
			--self.scroll_view:setClickEnabled(false)
		end

		self.scroll_view:setData(task_list, nil, nil, self.item)
	end
end

-- 神器技能
function HallowsTaskWindow:updateHallowsSkillInfo()
	if self.hallows_id == nil then return end
	local hallows_skill = hallows_skill_config(getNorKey(self.hallows_id, 1)) -- 显示1级时的技能
	if hallows_skill and hallows_skill.skill_bid ~= 0 then
		local config = Config.SkillData.data_get_skill(hallows_skill.skill_bid) or {}
		if not self.skill_icon then
			self.skill_icon = SkillItem.new(true,true,true,0.9)
			self.skill_icon:setPosition(cc.p(75, 70))
			self.skill_bg:addChild(self.skill_icon)
		end
		self.skill_icon:setData(config)
		self.skill_icon:setHallowsAtkVal(0)

		if not self.skill_name then
			self.skill_name = createLabel(24,Config.ColorData.data_new_color4[15],nil,135,95,"",self.skill_bg,1,cc.p(0,0))
		end
		self.skill_name:setString(config.name)

		if not self.skill_desc then
			self.skill_desc = createRichLabel(20,Config.ColorData.data_new_color4[1],cc.p(0,1),cc.p(135, 85),5,nil,550)
			self.skill_bg:addChild(self.skill_desc)
		end
		self.skill_desc:setString(string_format(config.des, changeBtValueForPower(config.hallows_atk), 0))
	end
end

function HallowsTaskWindow:close_callback()
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end
	if self.skill_icon then
		self.skill_icon:DeleteMe()
		self.skill_icon = nil
	end
	--if self.hallows_model then
	--	self.hallows_model:clearTracks()
	--	self.hallows_model:removeFromParent()
	--	self.hallows_model = nil
	--end
    controller:openHallowsMainWindow(false)
end




-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      被掠夺单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsTaskItem = class("HallowsTaskItem", function()
	return ccui.Layout:create()
end)

function HallowsTaskItem:ctor()
	self.is_completed = false
end

function HallowsTaskItem:setExtendData(node)
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

		self.get_btn = self.root_wnd:getChildByName("get_btn")
		self.get_btn:getChildByName("label"):setString(TI18N("领取"))

		self.goto_btn = self.root_wnd:getChildByName("goto_btn")
		self.goto_btn:getChildByName("label"):setString(TI18N("前往"))

		self.finish_icon = self.root_wnd:getChildByName("finish_icon")

		self.backpack_item = BackPackItem.new(false, true, false, 0.7, false, true)
		self.backpack_item:setPosition(62, 53)
		self.root_wnd:addChild(self.backpack_item)

		self.task_desc = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(15, 114), nil, nil, 300)
		self.root_wnd:addChild(self.task_desc)

		self:registerEvent()
	end
end

function HallowsTaskItem:registerEvent()
	self.get_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.config then
				controller:requestSubmitHallowsTask(self.data.id)
			end
		end
	end)

	self.goto_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.config then
				TaskController:getInstance():gotoTagertFun(self.config.progress[1], self.config.extra)
    			--controller:openHallowsMainWindow(false)
			end
		end
	end)
end

function HallowsTaskItem:setData(data)
	self.data = data
	if data then
		-- 引导需要
		self.get_btn:setName("get_btn_" .. data.id)
		self.goto_btn:setName("goto_btn_" .. data.id)

		local config = hallows_data_task[data.id]
		if config then
			--BT版战力任务数值特殊转换
			if data.id == 503 then
				self.task_desc:setString(string_format("%s<div fontcolor=#0e7709>(%s/%s)</div>", config.desc, changeBtValueForPower(data.value) or 0, changeBtValueForPower(data.target_val) or 0))
			else
				self.task_desc:setString(string_format("%s<div fontcolor=#0e7709>(%s/%s)</div>", config.desc, data.value or 0, data.target_val or 0))
			end

			local item_list = config.items
			-- 取出第一个物品
			if item_list and item_list[1] then
				self.backpack_item:setBaseData(item_list[1][1], item_list[1][2])
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

function HallowsTaskItem:suspendAllActions()
end

function HallowsTaskItem:DeleteMe()
	if self.backpack_item then
		self.backpack_item:DeleteMe()
	end
	self.backpack_item = nil

	self:removeAllChildren()
	self:removeFromParent()
end 
