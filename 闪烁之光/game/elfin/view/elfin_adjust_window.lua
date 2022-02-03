--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-23 16:49:18
-- @description    : 
		-- 精灵调整
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_remove = table.remove
local _table_sort = table.sort
local _string_format = string.format

ElfinAdjustWindow = ElfinAdjustWindow or BaseClass(BaseView)

function ElfinAdjustWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_adjust_window"

	self.elfin_skill_list = {}
	self.item_rect_list = {}
end

function ElfinAdjustWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container, 1)

	local win_title = main_container:getChildByName("win_title")
	win_title:setString(TI18N("快捷调整"))

    self.left_btn = main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("方案管理"))

    self.right_btn = main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("保 存"))

	-- self.save_btn = main_container:getChildByName("save_btn")
	-- self.save_btn:getChildByName("label"):setString(TI18N("保存"))

	self.tips_txt = createRichLabel(22, 274, cc.p(0.5, 0.5), cc.p(338, 288), nil, nil, 500)
	self.tips_txt:setString(TI18N("按住精灵技能进行<div fontcolor=#d23232>拖动</div>，调整施法顺序"))
	main_container:addChild(self.tips_txt)

	local lay_scrollview = main_container:getChildByName("lay_scrollview")
	local scroll_view_size = lay_scrollview:getContentSize()
    local list_setting = {
        start_x = 15,
        space_x = 25,
        start_y = 8,
        space_y = 50,
        item_width = BackPackItem.Width,
        item_height = BackPackItem.Height,
        row = 0,
        col = 4,
        need_dynamic = true,
        inner_hight_offset = 50
    }
    self.list_view = CommonScrollViewSingleLayout.new(lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
end

function ElfinAdjustWindow:createNewCell(  )
	local cell = BackPackItem.new(false, false, false)
	cell:setTouchEnabled(true)
	cell:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
			doStopAllActions(self.main_container)
            self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
            delayRun(self.main_container, 0.6, function ()
                if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    local elfin_vo = sender:getData()
                    local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_vo.base_id)
                    if elfin_cfg then
                    	local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                		if skill_cfg then
                			TipsManager:getInstance():showSkillTips(skill_cfg, false, false, false)
                		end
                    end
                end
                self.long_touch_type = LONG_TOUCH_END_TYPE
            end)
		elseif event_type == ccui.TouchEventType.moved then
			if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                local touch_began = self.touch_began
                local touch_move = sender:getTouchMovePosition()
                if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                    --移动大于20了..表示取消长点击效果
                    doStopAllActions(self.main_container)
                    self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                end 
            end
		elseif event_type == ccui.TouchEventType.canceled then
			if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                doStopAllActions(self.main_container)
                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
            end
		elseif event_type == ccui.TouchEventType.ended then
			if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                doStopAllActions(self.main_container)
                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
            elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                --事件触发了就不处理点击事件了
                return
            end
            self:onCellTouched(sender)
		end
	end)
    return cell
end

function ElfinAdjustWindow:numberOfCells(  )
	if not self.all_elfin_data then return 0 end
	return #self.all_elfin_data
end

function ElfinAdjustWindow:updateCellByIndex( cell, index )
	cell.index = index
    local item_data = self.all_elfin_data[index]
    if item_data then
    	cell:setData(item_data)
    	cell:showItemQualityName(true)
    	cell:setSelfNum(item_data.quantity or 0)
    	if item_data.is_select == true then
    		cell:IsGetStatus(true)
    	else
    		cell:IsGetStatus(false)
    	end
    end
end

function ElfinAdjustWindow:onCellTouched( cell )
	if not cell then return end
	local item_vo = cell:getData()
	if not item_vo then return end
	local cur_elfin_cfg = Config.SpriteData.data_elfin_data(item_vo.base_id)
	if item_vo.is_select == true then
		item_vo.is_select = false
		cell:IsGetStatus(false)
		for k,v in pairs(self.chose_elfin_list) do
			if v.item_bid == item_vo.base_id then
				v.item_bid = 0
				break
			end
		end
		self:updateSkillList()
	elseif cur_elfin_cfg then
		-- 先判断是否有空位、同类型的精灵
		local is_have_pos = false
		local is_same_type = false
		for k,v in pairs(self.chose_elfin_list) do
			if v.item_bid == 0 then
				is_have_pos = true
			else
				local elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
				if cur_elfin_cfg and elfin_cfg and cur_elfin_cfg.sprite_type == elfin_cfg.sprite_type then
					is_same_type = true
				end
			end
		end
		if not is_have_pos then
			message(TI18N("上阵精灵已满"))
			return
		end
		if is_same_type == true then
			message(TI18N("不能上阵两个同类型精灵"))
			return
		end

		item_vo.is_select = true
		cell:IsGetStatus(true)
		for i,v in ipairs(self.chose_elfin_list) do
			if v.item_bid == 0 then
				v.item_bid = item_vo.base_id
				break
			end
		end
		self:updateSkillList()
	end
end

function ElfinAdjustWindow:register_event(  )
	registerButtonEventListener(self.background, function() self:onCloseBtn() end, false, 2)

    registerButtonEventListener(self.right_btn, handler(self, self.onClickSaveBtn), true)
	registerButtonEventListener(self.left_btn, handler(self, self.onClickLeftBtn), true)
end

function ElfinAdjustWindow:onCloseBtn()
    _controller:openElfinAdjustWindow(false)
end

--打开方案管理
function ElfinAdjustWindow:onClickLeftBtn(  )
    local setting = {}
    setting.cur_plan_data = _model:getElfinTreeData()
    _controller:openElfinFightPlanPanel(true, setting)
    self:onCloseBtn()
end

function ElfinAdjustWindow:onClickSaveBtn(  )
    if self.callback then
        self.callback(self.chose_elfin_list)
    else
        if self.chose_elfin_list and next(self.chose_elfin_list) ~= nil then
            _controller:sender26514(self.chose_elfin_list)
        end    
    end
	_controller:openElfinAdjustWindow(false)
end

--setting.from_type 来及类型  1 古树打开  2 
--setting.callback  回调函数 如果无 表示保存古树的 如果有 相应callback
--setting.sprites 当前的已选择的的精灵列表 结构参考 古树协议26510 的sprites 结构 如果无 则拿古树那边的
--setting.dic_filter_item_id 需要过滤 精灵id dic_filter_item_id[item_id] = 数量
function ElfinAdjustWindow:openRootWnd(setting)
    self.setting = setting or {}
    self.from_type = self.setting.from_type or 1
    self.callback = self.setting.callback
    self.sprites = self.setting.sprites
    self.dic_filter_item_id = self.setting.dic_filter_item_id or {}
    
	self:setData()
    self:updateSkillList()

    if self.from_type ~= 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setPositionX(338)
    end
end

function ElfinAdjustWindow:setData(  )
	-- 背包中所有的精灵
	local elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
	-- 古树中上阵的精灵
	local elfin_bid_list = _model:getElfinTreeElfinList()

    --需要显示的精灵
    local show_bid_list 
    if self.from_type == 1 then
        show_bid_list = elfin_bid_list
    else
        show_bid_list = self.sprites or {}
    end

	self.chose_elfin_list = deepCopy(show_bid_list)
	_table_sort(self.chose_elfin_list, SortTools.KeyLowerSorter("pos"))

    --已选的精灵
    local dic_item_id = {}
    for i,v in ipairs(show_bid_list) do
        if v.item_bid ~= 0 then
            dic_item_id[v.item_bid] = 1
        end
    end
    --古树上的精灵
    local dic_elfin_item_id = {}
    for i,v in ipairs(elfin_bid_list) do
        if v.item_bid ~= 0 then
            dic_elfin_item_id[v.item_bid] = 1
        end
    end
    --计算 需要加上古树的精灵 和 需要减去的精灵
    self.all_elfin_data = {}
    for _,v in pairs(elfin_data) do
        local vo = deepCopy(v)
        if dic_elfin_item_id[vo.base_id] then --加上古树的精灵
            vo.quantity = vo.quantity + dic_elfin_item_id[vo.base_id]
            dic_elfin_item_id[vo.base_id] = nil
        end
        if dic_item_id[vo.base_id] then --设置已选精灵
            vo.is_select = true
        end
        if self.dic_filter_item_id[vo.base_id] then --过滤精灵
            vo.quantity = vo.quantity - self.dic_filter_item_id[vo.base_id]
        end
        if vo.quantity > 0 then
            _table_insert(self.all_elfin_data, vo)
        end
    end
    --古树的精灵可能需要新创建
    for item_bid,val in pairs(dic_elfin_item_id) do
        if self.dic_filter_item_id[item_bid] == nil then --如果过滤不是空的..说明古树上面的也被其他地方用了
            local goodvo = GoodsVo.New(item_bid)
            goodvo.quantity = 1
            if dic_item_id[item_bid] then --设置已选精灵
                goodvo.is_select = true
            end
            _table_insert(self.all_elfin_data, goodvo)
        end
    end

    if #self.all_elfin_data > 0 then
        local function sortFunc( objA, objB )
            if objA.eqm_jie ~= objB.eqm_jie then
                return objA.eqm_jie > objB.eqm_jie
            elseif objA.quality ~= objB.quality then
                return objA.quality > objB.quality
            else
                return objA.base_id > objB.base_id
            end
        end
        _table_sort(self.all_elfin_data, sortFunc)
        commonShowEmptyIcon(self.list_view, false)
        self.list_view:reloadData()
    else
        commonShowEmptyIcon(self.list_view, true, {text = TI18N("一个精灵都没有噢，快去孵化获取吧~")})
    end
end

-- 更新底部四个精灵技能图标
function ElfinAdjustWindow:updateSkillList(  )
	local cd_order = 0

	for i=1,4 do
		local elfin_bid = self:getTreeElfinBidByPos(i)
		local skill_item = self.elfin_skill_list[i]

        if not skill_item then
            skill_item = SkillItem.new(true, false, true, 0.9, true)
            skill_item:setTouchEnabled(true)
            skill_item.elfin_pos = i
            self.main_container:addChild(skill_item)
            skill_item:setPosition(cc.p(126+(i-1)*139, 202))
            self.elfin_skill_list[i] = skill_item

            -- 记录一下解锁的技能icon的区域
            if elfin_bid then
            	local world_pos = skill_item:convertToWorldSpace(cc.p(0, 0))
	            local node_pos = self.main_container:convertToNodeSpace(world_pos)
	            self.item_rect_list[i] = cc.rect( node_pos.x, node_pos.y, SkillItem.Width*0.9, SkillItem.Height*0.9)

	            skill_item:addTouchEventListener(function ( sender, event_type )
                    self:onClickSkillItem(sender, event_type, i)
	            end)
            else
                skill_item:setClickInfo({click = true})
            end
        end

        local item_bid = _model:getElfinItemByPos(i)
        if item_bid then
            elfin_bid = elfin_bid or 0
			skill_item.elfin_bid = elfin_bid
            skill_item:showLockIcon(false)
            local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
            if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
                skill_item.cd_order = 0
                skill_item:setData()
                skill_item:showLevel(false)
                skill_item:showName(false)
            else
                local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                if skill_cfg then
                    skill_item:showLevel(true)
                    skill_item:setData(skill_cfg)
                    skill_item:showName(true,skill_cfg.name,nil,20,true,cc.c4b(0xff,0xf0,0xd2,0xff),PathTool.getResFrame("elfin","elfin_1022"),cc.size(110,26))
                    if skill_cfg.type == "active_skill" then -- 主动技能
                        cd_order = cd_order + 1
                        skill_item.cd_order = cd_order
                    end
                end
            end
        else
            -- 未解锁精灵位置
            skill_item.elfin_bid = 0
            skill_item.cd_order = 0
            skill_item:setData()
            skill_item:showLevel(false)
            skill_item:showName(false)
            local need_step = Config.SpriteData.data_tree_limit[i]
            if need_step then
                skill_item:showLockIcon(true, nil, _string_format(TI18N("古树达到%s阶解锁"), StringUtil.numToChinese(need_step)))
            else
                skill_item:showLockIcon(true)
            end
           
        end
	end
end

function ElfinAdjustWindow:onClickSkillItem( sender, event_type )
	if self.is_show_act then return end
	if event_type == ccui.TouchEventType.began then
		self.cur_touch_skill_pos = sender.elfin_pos
		self.touch_move = false
		self.touch_began = sender:getTouchBeganPosition()
		local skill_data = sender:getData()
		if skill_data and next(skill_data) ~= nil then
			self.is_can_move = true
			-- 长按
			doStopAllActions(self.main_container)
	        self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
	        delayRun(self.main_container, 0.6, function ()
	            if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
	                local skill_cfg = sender:getData()
	                if skill_cfg and next(skill_cfg) ~= nil then
	                	TipsManager:getInstance():showSkillTips(skill_cfg, false, false, false, sender.cd_order or 0)
	                end
	            end
	            self.long_touch_type = LONG_TOUCH_END_TYPE
	        end)
		else
			self.is_can_move = false
		end
	elseif event_type == ccui.TouchEventType.moved then
		self.touch_move = true
		self:onClickSkillItemMove(sender)
		if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
            local touch_began = self.touch_began
            local touch_move = sender:getTouchMovePosition()
            if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                --移动大于20了..表示取消长点击效果
                doStopAllActions(self.main_container)
                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
            end 
        end
	elseif event_type == ccui.TouchEventType.canceled then
		self:onClickSkillItemCanceled(sender)
		if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
            doStopAllActions(self.main_container)
            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
        end
	elseif event_type == ccui.TouchEventType.ended then
		if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
            doStopAllActions(self.main_container)
            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
        elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
        	if self.move_skill_item and self.move_skill_item:isVisible() then
        		self.move_skill_item:setVisible(false)
        	end
        	self:updateSkillList()
        	return
        end

		self.touch_end = sender:getTouchEndPosition()
        local is_click = true
        if self.touch_began ~= nil then
            is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
        end
                    
        if self.touch_move and not is_click then
        	self:onClickSkillItemEnd(sender)
        else
        	if self.move_skill_item and self.move_skill_item:isVisible() then
        		self.move_skill_item:setVisible(false)
        	end
        	if sender.elfin_pos then
        		for k,v in pairs(self.chose_elfin_list) do
                	if v.pos == sender.elfin_pos then
                		for _,vo in pairs(self.all_elfin_data) do
		        			if vo.base_id == v.item_bid then
		        				vo.is_select = false
		        				break
		        			end
		        		end
                		v.item_bid = 0
                		break
                	end
                end
        		self.list_view:reloadData(nil, nil, true)
        		self:updateSkillList()
        	end
        end
	end
end

-- 移动技能item
function ElfinAdjustWindow:onClickSkillItemMove( sender )
	if not self.is_can_move then return end

    if not self.move_skill_item then
        self.move_skill_item = SkillItem.new(true, true, true, 0.9, true)
        self.main_container:addChild(self.move_skill_item)
    end
    self.move_skill_item:setVisible(true)
    self.move_skill_item:showLevel(true)

    local skill_data = sender:getData()
    if skill_data and next(skill_data) ~= nil then
    	self.move_skill_item:setData(skill_data)
    	self.move_skill_item.elfin_bid = sender.elfin_bid
    end

    sender:setData()
    sender:showLevel(false)
    sender.elfin_bid = 0
    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.main_container:convertToNodeSpace(touch_pos)
    self.move_skill_item:setPosition(target_pos)
end

function ElfinAdjustWindow:onClickSkillItemCanceled( sender )
	if not self.is_can_move or not self.move_skill_item then return end

	local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.main_container:convertToNodeSpace(touch_pos) 

    local is_have = false
    for index,rect in pairs(self.item_rect_list) do
    	if cc.rectContainsPoint( rect, target_pos ) then
    		local skill_item = self.elfin_skill_list[index]
    		if skill_item then
    			self.is_show_act = true
    			local world_pos = skill_item:convertToWorldSpace(cc.p(0, 0))
                local item_pos = self.main_container:convertToNodeSpace(world_pos)
                local act_1 = cc.MoveTo:create(0.1, cc.p(item_pos.x+53.5, item_pos.y+53.5))
                local call_back = function (  )
                    self.move_skill_item:setVisible(false)
                    local new_elfin_bid = self.move_skill_item.elfin_bid
                    local old_elfin_bid = skill_item.elfin_bid
                    for k,v in pairs(self.chose_elfin_list) do
                    	if sender and v.pos == sender.elfin_pos then
                    		v.item_bid = old_elfin_bid or 0
                    	elseif v.pos == index and new_elfin_bid then
                    		v.item_bid = new_elfin_bid
                    	end
                    end
                    self:updateSkillList()
                    self.is_show_act = false
                end
                self.move_skill_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
    			is_have = true
    		end
    		break
    	end
    end

    if not is_have then
    	self:onClickSkillItemEnd(sender)
    end
end

function ElfinAdjustWindow:onClickSkillItemEnd(sender)
	if self.move_skill_item then
        self.is_show_act = true
        local world_pos = sender:convertToWorldSpace(cc.p(0, 0))
        local target_pos = self.main_container:convertToNodeSpace(world_pos) 
        local act_1 = cc.MoveTo:create(0.1, cc.p(target_pos.x+53.5, target_pos.y+53.5))
        local call_back = function (  )
            self.move_skill_item:setVisible(false)
            self:updateSkillList()
            self.is_show_act = false
        end
        self.move_skill_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
    end
end

-- 根据位置获取对应精灵的id
function ElfinAdjustWindow:getTreeElfinBidByPos( pos )
    if not self.chose_elfin_list then return end

    local elfin_bid
    for k,v in pairs(self.chose_elfin_list) do
        if v.pos == pos then
            elfin_bid = v.item_bid
            break
        end
    end
    return elfin_bid
end

function ElfinAdjustWindow:close_callback(  )
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end
	for k,item in pairs(self.elfin_skill_list) do
		item:DeleteMe()
		item = nil
	end
	if self.move_skill_item then
		self.move_skill_item:DeleteMe()
		self.move_skill_item = nil
	end
	_controller:openElfinAdjustWindow(false)
end