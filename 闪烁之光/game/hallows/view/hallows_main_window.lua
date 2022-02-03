-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣器的主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsMainWindow = HallowsMainWindow or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local model = HallowsController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove
local backpack_model = BackpackController:getInstance():getModel()

local hallows_info_config = Config.HallowsData.data_info
local hallows_skill_config = Config.HallowsData.data_skill_up

function HallowsMainWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("hallows", "hallows"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_68", true), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_1"), type = ResourcesType.single},
	}
	self.layout_name = "hallows/hallows_main_window"

	self.skill_attr_list = {}  -- 技能加成
	self.is_in_advance = false		-- 是否在自动进阶中
	self.hallows_list = {}
	self.hallows_sum = 0
	self.tab_list = {}
	self.attr_bgs = {}
	self.base_attr_list = {}
	self.is_max_hallows_lv = false  -- 神器是否达到最大等级
	self.is_max_skill_lv = false	-- 技能是否达到最大等级
	self.is_max_refine_lv = false 	-- 精炼是否达到最大等级
	self.cur_index = HallowsConst.Tab_Index.uplv
	self.hallows_uplv_cost_bid_1 = 0 -- 选中的神器升级所需消耗1
	self.hallows_uplv_cost_num_1 = 0
	self.hallows_uplv_cost_bid_2 = 0 -- 选中的神器升级所需消耗2
	self.hallows_uplv_cost_num_2 = 0
	self.skill_lvup_cost_bid_1 = 0   -- 选中的神器技能升级所需消耗1
	self.skill_lvup_cost_num_1 = 0
	self.skill_lvup_cost_bid_2 = 0 	 -- 选中的神器技能升级所需消耗2
	self.skill_lvup_cost_num_2 = 0
	self.refine_cost_bid_1 = 0   -- 选中的神器精炼升级所需消耗1
	self.refine_cost_num_1 = 0
	self.refine_cost_bid_2 = 0 	 -- 选中的神器精炼升级所需消耗2
	self.refine_cost_num_2 = 0
	self.is_can_refine_1 = true -- 神器等级是否能够进行精炼
	self.is_can_refine_2 = true -- 材料1是否能够进行精炼
	self.is_can_refine_3 = true -- 材料2是否能够进行精炼

	self.advance_const_config = Config.HallowsData.data_const.id_advanced_props
	self.auto_const_config = Config.HallowsData.data_const.price_advanced_props

	self.role_vo = RoleController:getInstance():getRoleVo() 
end 

function HallowsMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_68", true), LOADTEXT_TYPE)

	local main_panel = self.root_wnd:getChildByName("main_panel")
	self:playEnterAnimatianByObj(main_panel, 1)
	local title_bg = main_panel:getChildByName("title_bg")

	self.skill_bg = main_panel:getChildByName("skill_bg")
	local skill_title = self.skill_bg:getChildByName("skill_title")
	skill_title:setString(TI18N("技能加成"))

	self.bottom_bg = main_panel:getChildByName("bottom_bg") --添加花纹
	if self.bottom_bg then
		local res = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_1")
		if res ~= nil then
			local pattern_1 = createSprite(res, self.bottom_bg:getContentSize().width/2, 15, self.bottom_bg, cc.p(0.5,0.5),LOADTEXT_TYPE)
			pattern_1:setScaleX(2)
			local pattern_2 = createSprite(res, self.bottom_bg:getContentSize().width/2, self.bottom_bg:getContentSize().height - 20, self.bottom_bg, cc.p(0.5,0.5),LOADTEXT_TYPE)
			pattern_2:setScaleX(2)
			pattern_2:setRotation(180)
		end
	end

	self.trace_btn = main_panel:getChildByName("trace_btn")						-- 圣印按钮
	self.trace_btn:getChildByName("label"):setString(TI18N("圣印"))
	self.trace_btn_tips = self.trace_btn:getChildByName("tips")					-- 圣印红点
	self.trace_btn_tips:setVisible(false)
	self.reset_btn = main_panel:getChildByName("reset_btn")
	self.reset_btn:getChildByName("label"):setString(TI18N("重铸"))
	self.reset_btn:setVisible(false)
	self.magic_btn = main_panel:getChildByName("magic_btn")
	self.magic_btn:getChildByName("label"):setString(TI18N("幻化"))
	self.magic_btn_tips = self.magic_btn:getChildByName("tips")
	self.magic_btn_tips:setVisible(false)
	self.artifact_btn = main_panel:getChildByName("artifact_btn")
	local artifact_btn_label = self.artifact_btn:getChildByName("label")
	artifact_btn_label:setString(TI18N("失落神器"))
	self.touch_layout = main_panel:getChildByName("touch_layout")

	-- 幻化功能是否开启
	local role_vo = RoleController:getInstance():getRoleVo()
	local open_cfg = Config.HallowsData.data_const["illusion_open"]
	if open_cfg and open_cfg.val <= role_vo.lev then
		self.magic_btn:setVisible(true)
		self.reset_btn:setPositionX(504)
	else
		self.magic_btn:setVisible(false)
		self.reset_btn:setPositionX(585)
	end

	self.left_btn = main_panel:getChildByName("left_btn")						-- 左移按钮
	self.right_btn = main_panel:getChildByName("right_btn")						-- 右移按钮
	self.explain_btn = main_panel:getChildByName("explain_btn")					-- 说明按钮
	self.hallows_name = title_bg:getChildByName("hallows_name")				-- 圣器名字

	-- 升级
	self.step_container = main_panel:getChildByName("step_container")
	self.step_container:getChildByName("title_attr"):setString(TI18N("全队基础属性"))
	for i=1,2 do
		local attr_bg = self.step_container:getChildByName("attr_bg_" .. i)
		self.attr_bgs[i] = attr_bg
	end
	self.uplv_layout = self.step_container:getChildByName("uplv_layout")
	self.step_progress = self.uplv_layout:getChildByName("progress")							-- 当前经验条
    self.step_progress:setScale9Enabled(true)
	self.step_progress_value = self.uplv_layout:getChildByName("progress_value")				-- 当前经验值
	self.step_advanced_btn = self.uplv_layout:getChildByName("advanced_btn")					-- 进阶一次按钮
	self.step_auto_advanced_btn = self.uplv_layout:getChildByName("auto_advanced_btn")		-- 一键进阶按钮
	self.step_advanced_btn:getChildByName("label"):setString(TI18N("升级"))
	self.step_auto_advanced_btn_label = self.step_auto_advanced_btn:getChildByName("label")
	self.step_auto_advanced_btn_label:setString(TI18N("一键升级"))
	self.step_advanced_btn_tips = self.step_advanced_btn:getChildByName("tips")	 -- 进阶红点
	self.step_advanced_btn_tips:setVisible(false)
	-- 升级消耗
	local lvup_cost_bg = self.uplv_layout:getChildByName("lvup_cost_bg")
	self.lvup_cost_res_1 = lvup_cost_bg:getChildByName("res_icon")
	self.lvup_cost_label_1 = lvup_cost_bg:getChildByName("lvup_cost_label")
	local auto_lvup_cost_bg = self.uplv_layout:getChildByName("auto_lvup_cost_bg")
	self.lvup_cost_res_2 = auto_lvup_cost_bg:getChildByName("res_icon")
	self.lvup_cost_label_2 = auto_lvup_cost_bg:getChildByName("auto_lvup_cost_label")

	-- 技能
	self.skill_container = main_panel:getChildByName("skill_container")
	self.skill_layout = self.skill_container:getChildByName("skill_layout")
	self.skill_lvup_btn = self.skill_layout:getChildByName("skill_lvup_btn")
	self.skill_lvup_btn_label = self.skill_lvup_btn:getChildByName("label")
	self.skill_lvup_btn_label:setString(TI18N("升级"))
	-- 技能升级消耗
	self.skill_cost_bg_1 = self.skill_layout:getChildByName("skill_cost_bg_1")
	self.skill_res_icon_1 = self.skill_cost_bg_1:getChildByName("skill_res_icon_1")
	self.skill_cost_label_1 = self.skill_cost_bg_1:getChildByName("skill_cost_label_1")
	self.skill_cost_bg_2 = self.skill_layout:getChildByName("skill_cost_bg_2")
	self.skill_res_icon_2 = self.skill_cost_bg_2:getChildByName("skill_res_icon_2")
	self.skill_cost_label_2 = self.skill_cost_bg_2:getChildByName("skill_cost_label_2")
	-- 无法升级时的提示
	self.skill_lvup_tips = self.skill_layout:getChildByName("skill_lvup_tips")

	-- 精炼
	self.refine_container = main_panel:getChildByName("refine_container")
	self.refine_layout = self.refine_container:getChildByName("refine_layout")
	self.refine_btn = self.refine_layout:getChildByName("refine_btn")
	self.refine_btn_tips = self.refine_btn:getChildByName("tips")
	self.refine_btn_label = self.refine_btn:getChildByName("label")
	self.refine_btn_label:setString(TI18N("精炼"))
	self.refine_tips = self.refine_layout:getChildByName("refine_tips")
	self.refine_lv_txt_1 = self.refine_layout:getChildByName("refine_lv_txt_1")
	self.refine_lv_txt_2 = self.refine_layout:getChildByName("refine_lv_txt_2")
	self.atk_txt_1 = self.refine_layout:getChildByName("atk_txt_1")
	self.total_atk_txt_1 = self.refine_layout:getChildByName("total_atk_txt_1")
	self.atk_txt_2 = self.refine_layout:getChildByName("atk_txt_2")
	self.total_atk_txt_2 = self.refine_layout:getChildByName("total_atk_txt_2")
	self.refine_layout:getChildByName("atk_title_1"):setString(TI18N("技能伤害增加:"))
	self.refine_layout:getChildByName("atk_title_2"):setString(TI18N("总伤害:"))
	self.refine_layout:getChildByName("atk_title_3"):setString(TI18N("技能伤害增加:"))
	self.refine_layout:getChildByName("atk_title_4"):setString(TI18N("总伤害:"))
	-- 精炼消耗
	self.refine_cost_bg_1 = self.refine_layout:getChildByName("refine_cost_bg_1")
	self.refine_res_icon_1 = self.refine_cost_bg_1:getChildByName("refine_res_icon_1")
	self.refine_cost_label_1 = self.refine_cost_bg_1:getChildByName("refine_cost_label_1")
	self.refine_cost_bg_2 = self.refine_layout:getChildByName("refine_cost_bg_2")
	self.refine_res_icon_2 = self.refine_cost_bg_2:getChildByName("refine_res_icon_2")
	self.refine_cost_label_2 = self.refine_cost_bg_2:getChildByName("refine_cost_label_2")
	-- 精炼达到最大等级
	self.refine_max = self.refine_container:getChildByName("refine_max")
	self.refine_max_lv = self.refine_max:getChildByName("refine_max_lv")
	self.atk_max_txt = self.refine_max:getChildByName("atk_max_txt")
	self.total_atk_txt = self.refine_max:getChildByName("total_atk_txt")
	self.refine_max:getChildByName("atk_max_title_1"):setString(TI18N("技能伤害增加:"))
	self.refine_max:getChildByName("atk_max_title_2"):setString(TI18N("总伤害:"))

	-- 满级
	self.maxlv_layout = main_panel:getChildByName("maxlv_layout")
	self.max_lv_tips = self.maxlv_layout:getChildByName("max_lv_tips")

	local tab_container = main_panel:getChildByName("tab_container")
    for i=1,3 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("升级"))
            elseif i == 2 then
                title:setString(TI18N("技能"))
            elseif i == 3 then
                title:setString(TI18N("精炼"))
            end
			local tips = tab_btn:getChildByName("tips")

			object.tab_btn = tab_btn
			object.select_bg = tab_btn:getChildByName("select_img")
        	object.select_bg:setVisible(false)
			object.label = title
			object.index = i
			object.tips = tips
            self.tab_list[i] = object
        end
    end
    self:updateTabBtnStatus()

	self.main_panel = main_panel

	-- 适配
	local top_off = display.getTop(main_panel)
	title_bg:setPositionY(top_off - 113)
	self.explain_btn:setPositionY(top_off - 113)
end

function HallowsMainWindow:updateTabBtnStatus(  )
	for k,object in pairs(self.tab_list) do
		local is_open = true
		if k == 3 then
			local role_vo = RoleController:getInstance():getRoleVo()
			local open_lv_cfg = Config.HallowsRefineData.data_const["open_lev"]
			if role_vo.lev < open_lv_cfg.val then
				is_open = false
			end
		end
		object.tab_btn:setVisible(is_open)
	end
end

function HallowsMainWindow:checkShowRefineLv(  )
	if not self.refine_is_open and model:getHallowsRefineIsOpen() and self.select_hallows and self.select_hallows.vo then
		local vo = self.select_hallows.vo
		self.refine_is_open = true
		self.hallows_name:setString(string_format(TI18N("%s+%d【精炼+%d级】"), self.select_hallows.name, vo.step, vo.refine_lev))

		local hallows_skill = hallows_skill_config(getNorKey(self.select_hallows.id, vo.skill_lev))
		if hallows_skill and hallows_skill.skill_bid ~= 0 then
			local config = Config.SkillData.data_get_skill(hallows_skill.skill_bid)
			if config then
				self.hallows_skill_name:setString(string_format(TI18N("%s+%d【精炼+%d级】"), config.name, vo.skill_lev, vo.refine_lev))
			end
		end
	end
end

function HallowsMainWindow:register_event()
	self.step_advanced_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			self:changeAutoAdvanceStatus(false)
			if self.select_hallows then
				controller:requestHallowsAdvance(self.select_hallows.id, false) 
			end
		end
	end)
	self.step_auto_advanced_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			local is_in_advance = not self.is_in_advance
			if is_in_advance == true and self.select_hallows then
				controller:requestHallowsAdvance(self.select_hallows.id, false) 
			end
			self:changeAutoAdvanceStatus(is_in_advance)
		end
	end)

	self.left_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended and not self.in_refine_effect then
			playButtonSound2()
			if self.hallows_list and next(self.hallows_list) ~= nil then
				local select_index = self.select_index
				if select_index <= 1 then
					select_index = self.hallows_sum
				else
					select_index = select_index - 1
				end
				self:selectHallowsIndex(select_index)
			end 
		end
	end)
	self.right_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended and not self.in_refine_effect then
			playButtonSound2()
			if self.hallows_list and next(self.hallows_list) ~= nil then
				local select_index = self.select_index
				if select_index >= self.hallows_sum then
					select_index = 1
				else
					select_index = select_index + 1
				end
				self:selectHallowsIndex(select_index)
			end 
		end
	end)
	
	registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
       	local config = Config.HallowsData.data_const.game_rule
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end,true, 1)
	
	registerButtonEventListener(self.refine_btn, function (  )
		if self.select_hallows and not self.in_refine_effect then
			if self.is_can_refine_1 and self.is_can_refine_2 and self.is_can_refine_3 then
				self:handleRefineEffect(true)
			else
				controller:send24135(self.select_hallows.id)
			end
		end
	end, true)

	self.trace_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.select_hallows then
				if self.select_hallows.vo == nil then
					message(TI18N("该圣器暂未激活"))
				else
					local cost_config = Config.HallowsData.data_const.imprint_lowest 
					if cost_config then
						if self.select_hallows.vo.step < cost_config.val then
							message(cost_config.desc)
						else
							controller:openHallowsTraceWindow(true, self.select_hallows)
						end
					end
				end
			end
		end
	end)

	registerButtonEventListener(self.magic_btn, handler(self, self._onClickMagicBtn), true)
	registerButtonEventListener(self.reset_btn, handler(self, self._onClickResetBtn), true)
	registerButtonEventListener(self.skill_lvup_btn, handler(self, self._onClickSkillLvupBtn), true)
	registerButtonEventListener(self.artifact_btn, handler(self, self._onClickBtnArtifact), true)
	registerButtonEventListener(self.touch_layout, handler(self, self._onClickTouchLayout))

	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended and not self.is_in_advance and not self.in_refine_effect then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
    end

    self:addGlobalEvent(HallowsEvent.HallowsUpdateEvent, function ( id, is_refine )
    	self:handleUpdateEvent(id, is_refine)
    end)

    self:addGlobalEvent(HallowsEvent.HallowsAdvanceEvent, function ( id, result )
    	if self.select_hallows  and self.select_hallows.id ~= id then
			self:changeAutoAdvanceStatus(false)
		else
			if result == 0 or result == 1 then		-- 0标识材料之类的不足 1标识升阶了,这两种情况都停掉
				self:changeAutoAdvanceStatus(false)
			end
		end
    end)

    -- 显示为某一神器（从所有神器预览界面打开）
	self:addGlobalEvent(HallowsEvent.UndateHallowsInfoEvent, function (id)
		if self.select_hallows and self.select_hallows.id ~= id then
			local select_index = self:getHallowsIndexById(id)
			self:selectHallowsIndex(select_index)
		end
	end)

	-- 神器红点更新
	self:addGlobalEvent(HallowsEvent.HallowsRedStatus, function ( red_type, setatus )
		if self.select_hallows then
			self:updateTabRedStatus()
		end
	end)

	-- 激活幻化（幻化属性加成需要更新）
	self:addGlobalEvent(HallowsEvent.HallowsMagicActivityEvent, function (  )
		if self.select_hallows then
			self:updateHallowsBaseInfo()
		end
	end)

    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function ( bag_code, item_list )
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
        self:checkNeedUpdateItemNum(item_list)
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function ( bag_code, item_list )
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
        self:checkNeedUpdateItemNum(item_list)
    end)

    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function ( bag_code, item_list )
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
        self:checkNeedUpdateItemNum(item_list)
    end)

    -- 金币、晶石更新
    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
            if key == "coin" then 
                self:updateCostItemNumByBid(1)
            elseif key == "hallow_refine" then
            	self:updateCostItemNumByBid(32)
            elseif key == "lev" then
            	self:updateTabBtnStatus()
            	self:checkShowRefineLv()
            end
        end)
    end
end

-- 点击重铸
function HallowsMainWindow:_onClickResetBtn(  )
	if self.is_in_advance or self.in_refine_effect then return end
	local str = TI18N("重铸后神器将回到初始状态，同时返还除金币外所有资源，是否重铸？")
	CommonAlert.show( str, TI18N("确定"), function()
		if self.select_hallows then
			controller:requestHallowsReset(self.select_hallows.id)
		end
	end, TI18N("取消"), nil, nil, nil, {timer=5})
end

-- 点击幻化
function HallowsMainWindow:_onClickMagicBtn( magic_id )
	if self.select_hallows then
		controller:openHallowsMagicWindow(true, self.select_hallows, magic_id)
	end
end

-- 技能升级
function HallowsMainWindow:_onClickSkillLvupBtn(  )
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo then
		controller:requestHallowsSkillUpgrade(vo.id)
	end
end

-- 失落神器
function HallowsMainWindow:_onClickBtnArtifact(  )
	controller:openHallowsPreviewWindow(true)
end

-- 点击神器显示tip
function HallowsMainWindow:_onClickTouchLayout(  )
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo then
		local max_vo = model:makeHighestHallowVo(vo.id)
		controller:getInstance():openHallowsTips(true, max_vo)
	end
end

-- 切换分页
function HallowsMainWindow:changeSelectedTab( index )
	if self.tab_object ~= nil and self.tab_object.index == index then return end
	if self.tab_object then
		self.tab_object.select_bg:setVisible(false)
		self.tab_object.label:setTextColor(cc.c3b(0xee, 0xd1, 0xaf))
		self.tab_object.label:enableOutline(cc.c4b(0x53, 0x3D, 0x32, 0xff), 2)
		self.tab_object.label:setFontSize(24)
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		self.tab_object.select_bg:setVisible(true)
		self.tab_object.label:setTextColor(cc.c3b(0x60, 0x35, 0x1a))
		self.tab_object.label:disableEffect(cc.LabelEffect.OUTLINE)
		self.tab_object.label:setFontSize(26)
	end

	self.cur_index = index
	self.step_container:setVisible(index == HallowsConst.Tab_Index.uplv)
	self.skill_container:setVisible(index == HallowsConst.Tab_Index.skill)
	self.refine_container:setVisible(index == HallowsConst.Tab_Index.refine)
	self:updateMaxLvTips()
end

function HallowsMainWindow:openRootWnd(hallows_id, index, magic_id)
	-- 根据激活数和id重新排序,
	local config_list = Config.HallowsData.data_base
	self.hallows_list = {}
	self.hallows_sum = Config.HallowsData.data_base_length 
	for k,v in pairs(config_list) do
		local object = {}
		object.id = v.id
		object.name = v.name
		object.effect = v.effect
		object.item_id = v.item_id
		object.open_desc = v.open_desc
		local vo = model:getHallowsById(v.id)
		object.vo = vo
		table_insert(self.hallows_list, object)
	end
	-- 显示列表重新排序
	if next(self.hallows_list) then
        table_sort(self.hallows_list, function(a, b)
        	return a.id < b.id
        end)
    end

	local select_index = self:getDefaultHallowsIndex(hallows_id)
	self:selectHallowsIndex(select_index)

	index = index or HallowsConst.Tab_Index.uplv
	self:changeSelectedTab(index)

	if magic_id and self.select_hallows then
		-- 延迟打开幻化界面
		delayRun(self.main_panel, 0.2, function (  )
			controller:openHallowsMagicWindow(true, self.select_hallows, magic_id)
		end)
	end
end

-- 取出进入界面时默认选中的神器index
function HallowsMainWindow:getDefaultHallowsIndex( hallows_id )
    local temp_hallows_list = deepCopy(self.hallows_list)
	local select_index = 1
	if hallows_id and hallows_id ~= 0 then
		select_index = self:getHallowsIndexById(hallows_id)
	else
		-- 等级最高>进度最高>id越高
		local temp_hallows = {}
		table_sort(temp_hallows_list, function ( a, b )
			return a.vo.step > b.vo.step
		end)
		local max_step = 0
		for i,v in ipairs(temp_hallows_list) do
			if max_step <= v.vo.step then
				max_step = v.vo.step
				table_insert(temp_hallows, v)
			end
		end
		if #temp_hallows == 1 then
			select_index = self:getHallowsIndexById(temp_hallows[1].id)
		else
			local max_lucky = 0
			table_sort(temp_hallows, function ( a, b )
				return a.vo.lucky < b.vo.lucky
			end)
			for i=#temp_hallows,1,-1 do
				local hallows = temp_hallows[i]
				if hallows.vo.lucky >= max_lucky then
					max_lucky = hallows.vo.lucky
				else
					table_remove(temp_hallows, i)
				end
			end
			if #temp_hallows == 1 then
				select_index = self:getHallowsIndexById(temp_hallows[1].id)
			else
				table_sort(temp_hallows, function ( a, b )
					return a.id > b.id
				end)
				select_index = self:getHallowsIndexById(temp_hallows[1].id)
			end
		end
	end
	return select_index
end

-- 根据神器id获取对应的index
function HallowsMainWindow:getHallowsIndexById( id )
	local index = 1
	for k,v in pairs(self.hallows_list) do
		if v.id and v.id == id then
			index = k
		end
	end
	return index
end

-- 选中某一神器
function HallowsMainWindow:selectHallowsIndex(index, force, is_refine)
	if self.select_index == index and not force then return end
	-- 只要是正常切换,就终止掉自动进阶
	if not force then
		self:changeAutoAdvanceStatus(false)
	elseif not is_refine then -- 精炼等级变化不播这个特效
		self:handleEffect(true)
	end
	self.select_index = index
	self.select_hallows = self.hallows_list[index]
	if self.select_hallows == nil then return end

	self.reset_btn:setVisible(self:checkIsShowResetBtn())

	-- 切换神器时需要清掉的数据
	self.is_max_hallows_lv = false  -- 神器是否达到最大等级
	self.is_max_skill_lv = false	-- 技能是否达到最大等级
	self.is_max_refine_lv = false	-- 精炼是否达到最大等级
	self.is_can_refine_1 = true
	self.is_can_refine_2 = true
	self.is_can_refine_3 = true
	self.hallows_uplv_cost_bid_1 = 0 -- 选中的神器升级所需消耗1
	self.hallows_uplv_cost_num_1 = 0
	self.hallows_uplv_cost_bid_2 = 0 -- 选中的神器升级所需消耗2
	self.hallows_uplv_cost_num_2 = 0
	self.skill_lvup_cost_bid_1 = 0   -- 选中的神器技能升级所需消耗1
	self.skill_lvup_cost_num_1 = 0
	self.skill_lvup_cost_bid_2 = 0 	 -- 选中的神器技能升级所需消耗2
	self.skill_lvup_cost_num_2 = 0
	self.refine_cost_bid_1 = 0   -- 选中的神器精炼升级所需消耗1
	self.refine_cost_num_1 = 0
	self.refine_cost_bid_2 = 0 	 -- 选中的神器精炼升级所需消耗2
	self.refine_cost_num_2 = 0

	self:updateHallowsBaseInfo()
	self:updateSkillList()
	self:updateHallowStatusInfo()
	self:updateTabRedStatus()
end

function HallowsMainWindow:handleEffect(status)  
    if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
    else
        if not tolua.isnull(self.hallows_model) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[185], cc.p(20, 50), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.hallows_model:addChild(self.play_effect)
        elseif self.play_effect then
        	self.play_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

-- 精炼特效
function HallowsMainWindow:handleRefineEffect( status )
	if status == false then
		if self.refine_effect then
			self.refine_effect:clearTracks()
			self.refine_effect:removeFromParent()
			self.refine_effect = nil
		end
    else
    	self.in_refine_effect = true
        if not tolua.isnull(self.main_panel) and self.refine_effect == nil then
            self.refine_effect = createEffectSpine(Config.EffectData.data_effect_info[545], cc.p(360, 915), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self._onRefineEffectEnd))
            self.refine_effect:registerSpineEventHandler(handler(self, self._onRefineEffectCallBack), sp.EventType.ANIMATION_EVENT)
            self.main_panel:addChild(self.refine_effect, 99)
        elseif self.refine_effect then
        	self.refine_effect:setToSetupPose()
        	self.refine_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function HallowsMainWindow:_onRefineEffectCallBack( event )
	if event.eventData.name == "appear" then
		if self.select_hallows then
			controller:send24135(self.select_hallows.id)
		end
	end
end

function HallowsMainWindow:_onRefineEffectEnd(  )
	self.in_refine_effect = false
end

--==============================--
--desc:基础信息显示模型、名称、基础属性、技能等
--time:2018-09-27 04:26:35
--@return 
--==============================--
function HallowsMainWindow:updateHallowsBaseInfo()
	if self.select_hallows == nil then return end
	local action = PlayerAction.action_1
	local hallows_effect_id = self.select_hallows.effect
	if self.select_hallows.vo ~= nil then
		-- 判断是否已经幻化
		if self.select_hallows.vo.look_id ~= 0 then
			hallows_effect_id = model:getHallowsEffectByMagicId(self.select_hallows.vo.look_id)
			action = PlayerAction.action_2
		else
			hallows_effect_id = self.select_hallows.effect
			action = PlayerAction.action_2
		end
	end
	if self.hallows_model_id ~= hallows_effect_id then
		self.hallows_model_id = hallows_effect_id
		self:handleEffect(false)
		if self.hallows_model then
			self.hallows_model:clearTracks()
			self.hallows_model:removeFromParent()
			self.hallows_model = nil
		end
		self.cur_hallows_action = action
		self.hallows_model = createEffectSpine(self.hallows_model_id,cc.p(360, 775), cc.p(0.5,0.5), true, action)
		self.main_panel:addChild(self.hallows_model)
	end
	if not self.cur_hallows_action or self.cur_hallows_action ~= action then
		self.cur_hallows_action = action
		self.hallows_model:setAnimation(0, action, true)
	end

	-- 基础属性
	local vo = self.select_hallows.vo
	if vo == nil then return end
	-- 名称
	if model:getHallowsRefineIsOpen() then
		self.refine_is_open = true
		self.hallows_name:setString(string_format(TI18N("%s+%d【精炼+%d级】"), self.select_hallows.name, vo.step, vo.refine_lev))
	else
		self.refine_is_open = false
		self.hallows_name:setString(self.select_hallows.name .. "+" .. vo.step)
	end

	local step_config = hallows_info_config(getNorKey(vo.id, vo.step))
	local next_step_config = hallows_info_config(getNorKey(vo.id, vo.step+1)) or {}

	-- 基础属性
	for k,v in pairs(self.base_attr_list) do
		v:setVisible(false)
	end
	for i,attr in ipairs(step_config.attr) do
		if i > 2 then break end -- UI只支持显示两个技能
		local attr_key = attr[1]
		local attr_val = attr[2] or 0
		local next_attr_val = 0
		-- 取出下一级属性加成，计算临时变量
		if next_step_config.attr then
			for _,v in pairs(next_step_config.attr) do
				if v[1] and v[1] == attr_key then
					next_attr_val = v[2] or 0
				end
			end
		end
		local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if attr_name then
			local attr_text = self.base_attr_list[i]
			if attr_text == nil then
				attr_text = createRichLabel(24, cc.c4b(100,50,35,255), cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
				local attr_bg = self.attr_bgs[i]
				attr_text:setPosition(cc.p(10, 20))
				attr_bg:addChild(attr_text)
				self.base_attr_list[i] = attr_text
			end
			attr_text:setVisible(true)
			local icon = PathTool.getAttrIconByStr(attr_key)
			-- 当前属性值=配置表中的值+进度中的属性值+圣印加成的值
            if next_attr_val > 0 then
            	local ratio_config = Config.HallowsData.data_const["temporary_ratio"] or {}
            	local ratio = ratio_config.val or 800
            	local progress_val = GameMath.round(vo.lucky/step_config.max_lucky*(next_attr_val-attr_val)*(ratio/1000))
            	attr_val = attr_val + progress_val
            end
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            
            local stone_config = Config.HallowsData.data_const["stone_attribute"]
            if vo.seal > 0 and stone_config then
            	local stone_val = 0
            	for _,v in pairs(stone_config.val) do
            		if v[1] and v[1] == attr_key then
            			stone_val = v[2] or 0
            			break
            		end
            	end
            	attr_val = attr_val + stone_val*vo.seal
            end
            if is_per == true then
                attr_val = (attr_val/10) .."%"
            end
            local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#643223> %s：</div><div fontcolor=#643223>%s</div>", PathTool.getResFrame("common", icon), attr_name, tostring(attr_val))
            -- 加上幻化皮肤加成
            if model:checkIsHaveHallowsMagic() then
            	local add_value = model:getHallowsMagicAttrByKey(attr_key)
				if add_value <= 0 then
					add_value = model:getHallowsMagicAttrByKey(attr_key .. "_per")
					attr_str = attr_str .. string_format("<div fontcolor=#249003> +%s</div>", tostring(math.ceil(add_value/1000*attr_val)))
				else
					if is_per then
	            		add_value = (add_value/10) .. "%"
	            	end
	            	attr_str = attr_str .. string_format("<div fontcolor=#249003> +%s</div>", tostring(add_value))
				end
            end
            attr_text:setString(attr_str)
		end
	end

	-- 神器技能
	local hallows_skill = hallows_skill_config(getNorKey(self.select_hallows.id, vo.skill_lev))
	if hallows_skill and hallows_skill.skill_bid ~= 0 then
		local config = Config.SkillData.data_get_skill(hallows_skill.skill_bid)
		if not config or next(config) == nil then
			return
		end
		if not self.hallow_skill_icon then
			self.hallow_skill_icon = SkillItem.new(true,true,true,0.9)
			self.hallow_skill_icon:setPosition(cc.p(75, 245))
			self.skill_container:addChild(self.hallow_skill_icon)
		end
		self.hallow_skill_icon:setData(config)

		if not self.hallows_skill_name then
			self.hallows_skill_name = createLabel(24,cc.c4b(0x9b,0x58,0x25,0xff),nil,135,267,"",self.skill_container,1,cc.p(0,0))
		end
		if model:getHallowsRefineIsOpen() then
			self.refine_is_open = true
			self.hallows_skill_name:setString(string_format(TI18N("%s+%d【精炼+%d级】"), config.name, vo.skill_lev, vo.refine_lev))
		else
			self.refine_is_open = false
			self.hallows_skill_name:setString(string_format(TI18N("%s+%d"), config.name, vo.skill_lev))
		end

		if not self.hallows_skill_desc then
			self.hallows_skill_desc = createRichLabel(22,cc.c4b(0x64,0x32,0x23,0xff),cc.p(0,1),cc.p(135, 250),10,nil,550)
			self.skill_container:addChild(self.hallows_skill_desc)
		end
		local skill_atk_val, refine_atk_val = vo:getHallowsSkillAndRefineAtkVal()
		local total_atk_val = skill_atk_val + refine_atk_val
		self.hallows_skill_desc:setString(string_format(config.des, total_atk_val, refine_atk_val))
		self.hallow_skill_icon:setHallowsAtkVal(refine_atk_val)
	end
end

--==============================--
--desc:创建技能加成
--time:2018-09-26 02:35:12
--@return 
--==============================--
function HallowsMainWindow:updateSkillList()
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo

	local skill_attr_config = Config.HallowsData.data_skill_attr[self.select_hallows.id] or {}
	for k,attr_txt in pairs(self.skill_attr_list) do
		attr_txt:setVisible(false)
	end
	for i,config in ipairs(skill_attr_config) do
		local attr_txt = self.skill_attr_list[i]
		if attr_txt == nil then
			attr_txt = createLabel(20,cc.c3b(157,141,115),nil,0,0,"",self.skill_bg,nil,cc.p(0, 0.5))
			self.skill_attr_list[i] = attr_txt
		end
		attr_txt:setVisible(true)
		attr_txt:setPosition(cc.p(10, 90 - (i-1)*32))
		if vo.skill_lev >= config.lev_limit then
			attr_txt:setTextColor(cc.c3b(247,152,68))
		else
			attr_txt:setTextColor(cc.c3b(157,141,115))
		end
		local attr_str = string.format(TI18N("技能%d级:%s"), config.lev_limit, config.desc)
		attr_txt:setString(attr_str)
	end
end

--==============================--
--desc:设置神器升级与技能状态显示
--time:2018-09-27 04:40:39
--@return 
--==============================--
function HallowsMainWindow:updateHallowStatusInfo()
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo == nil then
		return
	else
		-- 神器是否达到最大等级
		local max_lev = Config.HallowsData.data_max_lev[vo.id] or 100
		if vo.step >= max_lev then
			self.is_max_hallows_lv = true
			self.uplv_layout:setVisible(false)
		else
			self.is_max_hallows_lv = false
			self.uplv_layout:setVisible(true)
		end

		-- 技能是否达到最大等级
		local max_skill_lv = Config.HallowsData.data_skill_max_lev[vo.id] or 10
		local skill_lv = vo.skill_lev
		if skill_lv >= max_skill_lv then
			self.is_max_skill_lv = true
			self.skill_layout:setVisible(false)
		else
			self.is_max_skill_lv = false
			self.skill_layout:setVisible(true)
		end

		-- 精炼是否达到最大等级
		local max_refine_lv = Config.HallowsRefineData.data_max_lev[vo.id] or 9
		if vo.refine_lev >= max_refine_lv then
			self.is_max_refine_lv = true
			self.refine_layout:setVisible(false)
			self.refine_max:setVisible(true)
		else
			self.is_max_refine_lv = false
			self.refine_layout:setVisible(true)
			self.refine_max:setVisible(false)
		end

		-- 更新神器升级与技能显示
		if self.is_max_hallows_lv == false then
			self:updateStepInfo()
		end
		if self.is_max_skill_lv == false then
			self:updateSkillInfo()
		end
		if self.is_max_refine_lv == false then
			self:updateRefineInfo()
		else
			self:updateRefineMaxInfo()
		end
		self:updateMaxLvTips()
	end
end

-- 刷新满级提示语
function HallowsMainWindow:updateMaxLvTips(  )
	if self.cur_index == HallowsConst.Tab_Index.uplv and self.is_max_hallows_lv then
		self.max_lv_tips:setString(TI18N("神器已满级"))
		self.maxlv_layout:setVisible(true)
	elseif self.cur_index == HallowsConst.Tab_Index.skill and self.is_max_skill_lv then
		self.max_lv_tips:setString(TI18N("技能已满级"))
		self.maxlv_layout:setVisible(true)
	elseif self.cur_index == HallowsConst.Tab_Index.refine and self.is_max_refine_lv then
		self.max_lv_tips:setString(TI18N("神器精炼等级达到最高等级"))
		self.maxlv_layout:setVisible(true)
	else
		self.maxlv_layout:setVisible(false)
	end
end

--==============================--
--desc:设置神器升级相关显示
--time:2018-09-27 05:37:59
--@return 
--==============================--
function HallowsMainWindow:updateStepInfo()
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo == nil then return end

	local step_config = hallows_info_config(getNorKey(vo.id, vo.step)) 
	if step_config then
		-- 进度条
		self.step_progress_value:setString(vo.lucky.."/"..step_config.max_lucky)
		self.step_progress:setPercent(100*vo.lucky/step_config.max_lucky)

		-- 神器升级消耗
		local expend_1 = step_config.loss[1]
		local expend_2 = step_config.loss[2]
		if expend_1 then
			local bid = expend_1[1]
			local num = expend_1[2]
			self.hallows_uplv_cost_bid_1 = bid
			self.hallows_uplv_cost_num_1 = num
			self:setCostDataToNode(self.lvup_cost_res_1, self.lvup_cost_label_1, bid, num)
		end
		if expend_2 then
			local bid = expend_2[1]
			local num = expend_2[2]
			self.hallows_uplv_cost_bid_2 = bid
			self.hallows_uplv_cost_num_2 = num
			self:setCostDataToNode(self.lvup_cost_res_2, self.lvup_cost_label_2, bid, num)
		end
	end
end

-- 更新神器技能相关显示
function HallowsMainWindow:updateSkillInfo(  )
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo == nil then return end

	local hallows_skill = hallows_skill_config(getNorKey(self.select_hallows.id, vo.skill_lev))
	if hallows_skill and hallows_skill.skill_bid ~= 0 then
		-- 升级消耗
		if hallows_skill.lev_limit > vo.step then
			self.skill_lvup_tips:setString(string.format(TI18N("神器%d级可继续升级"), hallows_skill.lev_limit))			
			self.skill_lvup_tips:setVisible(true)
			self.skill_cost_bg_1:setVisible(false)
			self.skill_cost_bg_2:setVisible(false)
			setChildUnEnabled(true, self.skill_lvup_btn)
			self.skill_lvup_btn:setTouchEnabled(false)
			self.skill_lvup_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
		else
			setChildUnEnabled(false, self.skill_lvup_btn)
			self.skill_lvup_btn:setTouchEnabled(true)
			self.skill_lvup_btn_label:enableOutline(cc.c4b(0x29,0x4a,0x15,0xff), 2)
			self.skill_lvup_tips:setVisible(false)
			self.skill_cost_bg_1:setVisible(true)
			self.skill_cost_bg_2:setVisible(true)
			local expend_1 = hallows_skill.lose[1]
			local expend_2 = hallows_skill.lose[2]
			if expend_1 then
				local bid = expend_1[1]
				local num = expend_1[2]
				self.skill_lvup_cost_bid_1 = bid
				self.skill_lvup_cost_num_1 = num
				self:setCostDataToNode(self.skill_res_icon_1, self.skill_cost_label_1, bid, num)
			end
			if expend_2 then
				local bid = expend_2[1]
				local num = expend_2[2]
				self.skill_lvup_cost_bid_2 = bid
				self.skill_lvup_cost_num_2 = num
				self:setCostDataToNode(self.skill_res_icon_2, self.skill_cost_label_2, bid, num)
			end
		end
	end
end

-- 更新精炼信息显示
function HallowsMainWindow:updateRefineInfo(  )
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo == nil then return end
	local refine_cfg
	if Config.HallowsRefineData.data_refine[vo.id] then
		refine_cfg = Config.HallowsRefineData.data_refine[vo.id][vo.refine_lev]
	end
	local next_refine_cfg
	if Config.HallowsRefineData.data_refine[vo.id] then
		next_refine_cfg = Config.HallowsRefineData.data_refine[vo.id][vo.refine_lev+1]
	end

	-- 当前技能伤害值
	local skill_atk_val = vo:getHallowsSkillAndRefineAtkVal()

	-- 当前精炼等级信息
	self.refine_lv_txt_1:setString(string_format(TI18N("精炼等级:%d"), vo.refine_lev))
	if refine_cfg then
		self.atk_txt_1:setString(refine_cfg.add_dps)
		self.total_atk_txt_1:setString(refine_cfg.add_dps + skill_atk_val)
	else
		self.atk_txt_1:setString(0)
		self.total_atk_txt_1:setString(skill_atk_val)
	end

	if next_refine_cfg then
		-- 精炼升级消耗
		local expend_1 = next_refine_cfg.expend[1]
		local expend_2 = next_refine_cfg.expend[2]
		if expend_1 then
			local bid = expend_1[1]
			local num = expend_1[2]
			self.refine_cost_bid_1 = bid
			self.refine_cost_num_1 = num
			local is_full = self:setCostDataToNode(self.refine_res_icon_1, self.refine_cost_label_1, bid, num)
			if not is_full then
				self.is_can_refine_2 = false
			end
		end
		if expend_2 then
			local bid = expend_2[1]
			local num = expend_2[2]
			self.refine_cost_bid_2 = bid
			self.refine_cost_num_2 = num
			local is_full = self:setCostDataToNode(self.refine_res_icon_2, self.refine_cost_label_2, bid, num)
			if not is_full then
				self.is_can_refine_3 = false
			end
		end

		-- 精炼按钮状态
		if vo.step >= next_refine_cfg.need_lev then
			self.refine_btn:setTouchEnabled(true)
			setChildUnEnabled(false, self.refine_btn)
			self.refine_btn_label:enableOutline(cc.c4b(43,97,13,255), 2)
			self.refine_tips:setVisible(false)
		else
			self.refine_btn:setTouchEnabled(false)
			setChildUnEnabled(true, self.refine_btn)
			self.refine_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
			self.refine_tips:setString(string_format(TI18N("神器%d级可继续精炼"), next_refine_cfg.need_lev))
			self.refine_tips:setVisible(true)
			self.is_can_refine_1 = false
		end

		-- 下一级精炼等级信息
		self.refine_lv_txt_2:setString(string_format(TI18N("精炼等级:%d"), next_refine_cfg.lev))
		self.atk_txt_2:setString(next_refine_cfg.add_dps)
		self.total_atk_txt_2:setString(next_refine_cfg.add_dps + skill_atk_val)
	end
end

-- 更新最大精炼等级信息显示
function HallowsMainWindow:updateRefineMaxInfo(  )
	if self.select_hallows == nil then return end
	local vo = self.select_hallows.vo
	if vo == nil then return end
	local refine_cfg 
	if Config.HallowsRefineData.data_refine[vo.id] then
		refine_cfg = Config.HallowsRefineData.data_refine[vo.id][vo.refine_lev]
	end
	if not refine_cfg then return end

	self.refine_max_lv:setString(string_format(TI18N("精炼等级:%d"), vo.refine_lev))

	-- 精炼等级伤害
	self.atk_max_txt:setString(refine_cfg.add_dps)

	-- 总伤害
	local skill_atk_val, refine_atk_val = vo:getHallowsSkillAndRefineAtkVal()
	local total_atk_val = skill_atk_val + refine_atk_val
	self.total_atk_txt:setString(total_atk_val)
end

-- 更新tab按钮红点显示
function HallowsMainWindow:updateTabRedStatus(  )
	if self.select_hallows == nil then return end
	local red_hallows_id = model:getRedHallowsId()
	if red_hallows_id and red_hallows_id == self.select_hallows.id then
		for k,tab_object in pairs(self.tab_list) do
			if tab_object.tips and tab_object.index then
				local red_status = false
				if tab_object.index == HallowsConst.Tab_Index.uplv then
					red_status = model:checkRedIsShowByRedType(HallowsConst.Red_Index.hallows_lvup)
				elseif tab_object.index == HallowsConst.Tab_Index.skill then
					red_status = model:checkRedIsShowByRedType(HallowsConst.Red_Index.skill_lvup)
				elseif tab_object.index == HallowsConst.Tab_Index.refine then
					red_status = model:checkRedIsShowByRedType(HallowsConst.Red_Index.refine_lvup)
				end
				tab_object.tips:setVisible(red_status)
			end
		end
		if self.trace_btn_tips then
			local trace_red = model:checkRedIsShowByRedType(HallowsConst.Red_Index.stone_use)
			self.trace_btn_tips:setVisible(trace_red)
		end
		if self.magic_btn_tips then
			local magic_red = model:checkRedIsShowByRedType(HallowsConst.Red_Index.magic_task)
			self.magic_btn_tips:setVisible(magic_red)
		end
	else
		for k,tab_object in pairs(self.tab_list) do
			if tab_object.tips then
				tab_object.tips:setVisible(false)
			end
		end
		if self.trace_btn_tips then
			self.trace_btn_tips:setVisible(false)
		end
		if self.magic_btn_tips then
			self.magic_btn_tips:setVisible(false)
		end
	end
end

-- 显示消耗数据
function HallowsMainWindow:setCostDataToNode( item_icon, item_label, item_bid, item_num )
	local is_full = true -- 材料是否足够
	local item_config = Config.ItemData.data_get_data(item_bid)
	if item_config then
		local res = PathTool.getItemRes(item_config.icon)
		item_icon:loadTexture(res, LOADTEXT_TYPE)
		local count = BackpackController:getInstance():getModel():getItemNumByBid(item_bid)
		item_label:setString(string.format("%s/%s", MoneyTool.GetMoneyString(count, false), MoneyTool.GetMoneyString(item_num, false)))
		if count < item_num then
			item_label:setTextColor(cc.c3b(255, 93, 93))
			is_full = false
		else
			item_label:setTextColor(cc.c3b(255, 246, 228))
		end
	end
	return is_full
end

--==============================--
--desc:消耗物品的数量更新
--time:2018-09-30 10:20:54
--@item_list:
--@return 
--==============================--
function HallowsMainWindow:checkNeedUpdateItemNum(item_list)	
	if item_list == nil or next(item_list) == nil then return end
	for k, v in pairs(item_list) do
		if v.config then
			local bid = v.config.id
			self:updateCostItemNumByBid(bid)
		end
	end
end

function HallowsMainWindow:updateCostItemNumByBid( bid )
	if not bid then return end
	if bid == self.hallows_uplv_cost_bid_1 then
		self:setCostDataToNode(self.lvup_cost_res_1, self.lvup_cost_label_1, bid, self.hallows_uplv_cost_num_1)
	end
	if bid == self.hallows_uplv_cost_bid_2 then
		self:setCostDataToNode(self.lvup_cost_res_2, self.lvup_cost_label_2, bid, self.hallows_uplv_cost_num_2)
	end
	if bid == self.skill_lvup_cost_bid_1 then
		self:setCostDataToNode(self.skill_res_icon_1, self.skill_cost_label_1, bid, self.skill_lvup_cost_num_1)
	end
	if bid == self.skill_lvup_cost_bid_2 then
		self:setCostDataToNode(self.skill_res_icon_2, self.skill_cost_label_2, bid, self.skill_lvup_cost_num_2)
	end
	if bid == self.refine_cost_bid_1 then
		local is_full = self:setCostDataToNode(self.refine_res_icon_1, self.refine_cost_label_1, bid, self.refine_cost_num_1)
		if is_full then
			self.is_can_refine_2 = true
		else
			self.is_can_refine_2 = false
		end
	end
	if bid == self.refine_cost_bid_2 then
		local is_full = self:setCostDataToNode(self.refine_res_icon_2, self.refine_cost_label_2, bid, self.refine_cost_num_2)
		if is_full then
			self.is_can_refine_3 = true
		else
			self.is_can_refine_3 = false
		end
	end
end

--==============================--
--desc:圣器更新处理
--time:2018-09-27 05:33:30
--@id:
--@return 
--==============================--
function HallowsMainWindow:handleUpdateEvent(id, is_refine)
	if id and self.select_hallows and id == self.select_hallows.id then
		self:selectHallowsIndex(self.select_index, true, is_refine)
	end
end

-- 是否显示重铸按钮
function HallowsMainWindow:checkIsShowResetBtn(  )
	local is_show = false
	if self.select_hallows == nil then return is_show end
	local vo = self.select_hallows.vo
	if vo == nil then return is_show end

	if vo.step > 1 or vo.seal > 0 or vo.skill_lev > 1 or vo.refine_lev > 0 then
		is_show = true
	end

	return is_show
end

--==============================--
--desc:自动进阶显示状态
--time:2018-09-27 07:32:12
--@return 
--==============================--
function HallowsMainWindow:changeAutoAdvanceStatus(is_in_advance)
	if is_in_advance == self.is_in_advance then return end
	self.is_in_advance =  is_in_advance
	if self.is_in_advance == true then
		self.step_auto_advanced_btn_label:setString(TI18N("停止"))
		if self.auto_time_ticket == nil then
			self.auto_time_ticket = GlobalTimeTicket:getInstance():add(function()
				if self.is_in_advance == true then
					controller:requestHallowsAdvance(self.select_hallows.id, false)
				end
			end, 0.5)
		end
	else
		self.step_auto_advanced_btn_label:setString(TI18N("一键升级"))
		self:clearAutoTimeticket()
	end
end

function HallowsMainWindow:clearAutoTimeticket()
	if self.auto_time_ticket then
		GlobalTimeTicket:getInstance():remove(self.auto_time_ticket)
		self.auto_time_ticket = nil
	end
end

function HallowsMainWindow:close_callback()
	self:clearAutoTimeticket()
	self:handleEffect(false)
	self:handleRefineEffect(false)
	if self.hallows_model then
		self.hallows_model:clearTracks()
		self.hallows_model:removeFromParent()
		self.hallows_model = nil
	end
	if self.hallow_skill_icon then
		self.hallow_skill_icon:DeleteMe()
		self.hallow_skill_icon = nil
	end
	if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end

    controller:openHallowsMainWindow(false)
end
