--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-06 13:56:29
-- @description    : 
		-- 圣殿副本挑战界面
---------------------------------
ElementEctypeWindow = ElementEctypeWindow or BaseClass(BaseView)

local _controller = ElementController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

function ElementEctypeWindow:__init( )
	self.is_full_screen = true
	self.layout_name = "element/element_ectype_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("element", "element"), type = ResourcesType.plist},
	}

	self.count_is_full = false
	self.skill_items = {}
end

function ElementEctypeWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)

	self.con_layout = self.main_container:getChildByName("con_layout")

	self.title_bg = self.con_layout:getChildByName("title_bg")
	self.title_bg:ignoreContentAdaptWithSize(true)
	self.hero_bg = self.con_layout:getChildByName("hero_bg")
	self.hero_bg:ignoreContentAdaptWithSize(true)
	self.icon_type = self.con_layout:getChildByName("icon_type")

	self.close_btn = self.main_container:getChildByName("close_btn")
	self.add_count_btn = self.main_container:getChildByName("add_count_btn")

	self.title_txt = self.con_layout:getChildByName("title_txt")
	self.attr_desc = self.con_layout:getChildByName("attr_desc")
	self.time_txt = self.main_container:getChildByName("time_txt")
	self.count_txt = self.main_container:getChildByName("count_txt")
	self.con_layout:getChildByName("title_attr"):setString(TI18N("属性克制"))
	self.con_layout:getChildByName("title_skill"):setString(TI18N("BOSS特点"))
	self.main_container:getChildByName("title_count"):setString(TI18N("挑战次数:"))

	-- 适配
	local top_off = display.getTop(self.main_container)
	self.offset_y = top_off-CC_DESIGN_RESOLUTION.height
	self.con_layout:setPositionY(self.offset_y)

	local Image_4 = self.main_container:getChildByName("Image_4")
	Image_4:setContentSize(cc.size(Image_4:getContentSize().width, Image_4:getContentSize().height+self.offset_y))

	local Image_3 = Image_4:getChildByName("Image_3")
	Image_3:setPositionY(Image_3:getPositionY() + self.offset_y)

	local item_list = self.con_layout:getChildByName("item_list")
	local list_size = item_list:getContentSize()
	local scroll_view_size = cc.size(list_size.width, list_size.height)
    local setting = {
        --item_class = ElementEctypeItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 720,               -- 单元的尺寸width
        item_height = 132,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(item_list, cc.p(0,-self.offset_y/2) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function ElementEctypeWindow:_createNewCell(  )
	local cell = ElementEctypeItem.new()
    return cell
end

function ElementEctypeWindow:_numberOfCells(  )
	if not self.show_customs_data then return 0 end
    return #self.show_customs_data
end

function ElementEctypeWindow:_updateCellByIndex( cell, index )
	if not self.show_customs_data then return end
    cell.index = index
    local cell_data = self.show_customs_data[index]
    if not cell_data then return end
    local extend_data = {}
    extend_data.customs_id = self.customs_id
    extend_data.ele_type = self.ele_type
    cell:setExtendData(extend_data)
    cell:setData(cell_data)
end

function ElementEctypeWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openElementEctypeWindow(false)
	end, false, 2)

	registerButtonEventListener(self.add_count_btn, handler(self, self._onClickAddCountBtn), true)

	-- 挑战次数
	self:addGlobalEvent(ElementEvent.Update_Element_Count_Event, function (  )
		self.element_data = _model:getElementData()
		self:refreshChallengeCountInfo()
		self:updateLeftBuyCount()
	end)
	-- 最大关卡数更新（保持当前位置）
	self:addGlobalEvent(ElementEvent.Update_Element_Customs_Event, function (  )
		if self.ele_type then
			self.customs_id = _model:getElementCustomsIdByType(self.ele_type)
			self:updateShowCustomsData()
			local start_index = self:getDefaultItemIndex()
			self.item_scrollview:reloadData(start_index)
		end
	end)
end

-- 更新显示数据
function ElementEctypeWindow:updateShowCustomsData(  )
	local customs_cfg = Config.ElementTempleData.data_customs[self.unit_group]
	self.show_customs_data = {}
	if self.customs_id and customs_cfg then
		for i,v in ipairs(customs_cfg) do
			if v.limit_dun_id and v.limit_dun_id <= self.customs_id then
				_table_insert(self.show_customs_data, v)
			end
		end
	end
end

function ElementEctypeWindow:getDefaultItemIndex(  )
	local start_index
	if self.customs_id and self.show_customs_data then
		for i,v in ipairs(self.show_customs_data) do
	    	if v.id == self.customs_id then
	    		start_index = i
	    		break
	    	end
	    end
	end
    return start_index
end

function ElementEctypeWindow:openRootWnd( data )
	self:setData(data)
end

function ElementEctypeWindow:setData( data )
	if not data then return end

	self.ele_type = data.type -- 副本类型id
	self.unit_group = data.group -- 副本组别
	self.customs_id = data.boss_id -- 最大通关id

	self.base_cfg = Config.ElementTempleData.data_base[self.ele_type]
	self.monster_cfg = Config.ElementTempleData.data_monster[self.unit_group]
	self.element_data = _model:getElementData()

	if not self.base_cfg or not self.monster_cfg then return end

	self:updateShowCustomsData()

	if self.ele_res_load then
		self.ele_res_load:DeleteMe()
		self.ele_res_load = nil
	end
	local res_id = self.base_cfg.res_id
	local all_res_list = {}
	_table_insert(all_res_list, {path = PathTool.getPlistImgForDownLoad("bigbg/element", string.format("element_bg_%d", res_id), true), type = ResourcesType.single})
	_table_insert(all_res_list, {path = PathTool.getPlistImgForDownLoad("partner", self.monster_cfg.bust_id), type = ResourcesType.single})
	self.ele_res_load = ResourcesLoad.New()
	self.ele_res_load:addAllList(all_res_list, function()
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/element",string.format("element_bg_%d", res_id), true))
		print("self.monster_cfg.bust_id",self.monster_cfg.bust_id)
    	self.hero_bg:loadTexture(PathTool.getPlistImgForDownLoad("partner",self.monster_cfg.bust_id))
    end)

    -- 标题背景
    --self.title_bg:loadTexture(PathTool.getResFrame("element", "element_title_bg_" .. res_id), LOADTEXT_TYPE_PLIST)

    -- 名称
    self.title_txt:setString(self.base_cfg.name .. "  " .. self.monster_cfg.name)
    -- 属性克制
    self.attr_desc:setString(self.monster_cfg.attr_desc)
    -- 类型图标
    if ElementConst.Icon_Type[self.ele_type] then
    	local icon_res = PathTool.getResFrame("element", ElementConst.Icon_Type[self.ele_type])
    	self.icon_type:loadTexture(icon_res, LOADTEXT_TYPE_PLIST)
    end
    -- 技能图标
    for k,item in pairs(self.skill_items) do
    	item:setVisible(false)
    end
    local start_x = 58
    local space_x = 15
    local scale = 0.7
    for i,skill_id in ipairs(self.monster_cfg.skill_list) do
    	local item = self.skill_items[i]
    	if item == nil then
    		item = SkillItem.new(true,true,true,scale)
    		item:setTipsHideFlag(true)
    		self.main_container:addChild(item)
    		self.skill_items[i] = item
    	end
    	item:setVisible(true)
    	item:setPosition(cc.p(start_x + (i-1)*(space_x+SkillItem.Width*scale), 857+self.offset_y))
    	local skill_cfg = Config.SkillData.data_get_skill(skill_id)
    	if skill_cfg then
    		item:setData(skill_cfg)
    	end
    end

    -- 列表
    local start_index = self:getDefaultItemIndex()
    self.item_scrollview:reloadData(start_index)
	-- 挑战次数
	self:refreshChallengeCountInfo()
	self:updateLeftBuyCount()
end

-- 挑战次数相关
function ElementEctypeWindow:refreshChallengeCountInfo( )
	if self.element_data and next(self.element_data) ~= nil then
		local count_cfg = Config.ElementTempleData.data_const["refresh_number"]
		self.count_txt:setString(self.element_data.num .. "/" .. count_cfg.val)
		self.count_is_full = (self.element_data.num >= count_cfg.val)

		local cur_time = GameNet:getInstance():getTime()
		if self.element_data.refresh_time < cur_time then
			self:setLessTime(0)
			self.time_txt:setVisible(false)
		else
			self:setLessTime(self.element_data.refresh_time - cur_time)
			self.time_txt:setVisible(true)
		end
	end
end

-- 更新今日剩余购买次数
function ElementEctypeWindow:updateLeftBuyCount(  )
    if not self.left_buy_count then
        self.left_buy_count = createRichLabel(18, 1, cc.p(0, 0.5), cc.p(505, 140))
        self.main_container:addChild(self.left_buy_count)
    end
    local left_count = _model:getTodayLeftBuyCount()
	self.left_buy_count:setString(string.format(TI18N("剩余购买次数: </div><div fontcolor=#0cff01 >%d</div>"), left_count))

end

function ElementEctypeWindow:setLessTime( less_time )
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

function ElementEctypeWindow:_onClickAddCountBtn(  )
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

function ElementEctypeWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.ele_res_load then
		self.ele_res_load:DeleteMe()
		self.ele_res_load = nil
	end
	for k,item in pairs(self.skill_items) do
		item:DeleteMe()
		item = nil
	end
	_controller:openElementEctypeWindow(false)
end