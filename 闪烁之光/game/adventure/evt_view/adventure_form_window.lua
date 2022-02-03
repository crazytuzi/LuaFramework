-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冒险布阵界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureFormWindow = AdventureFormWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort 
local game_net = GameNet:getInstance()
local hero_model = HeroController:getInstance():getModel()

function AdventureFormWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.index = 2
	self.layout_name = "adventure/adventure_form_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("form", "form"), type = ResourcesType.plist},
	}

	self.five_hero_vo = {}			-- 已经选择的伙伴列表
	self.hero_item_list = {}		-- 英雄对象
	self.select_list = {}			-- 上面选中的实例对象
end 

function AdventureFormWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
	main_container:getChildByName("win_title"):setString(TI18N("冒险出战"))

	local top_panel = main_container:getChildByName("top_panel")
	self.lay_scrollview = top_panel:getChildByName("lay_scrollview")
	self.no_vedio_image = top_panel:getChildByName("no_vedio_image")
	self.no_vedio_image:getChildByName("label"):setString(TI18N("暂无该类型英雄"))

	--阵营
    local camp_node = top_panel:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

	local bottom_panel = main_container:getChildByName("bottom_panel")
	for index=1,5 do
        local item = HeroExhibitionItem.new(0.9, false)
        item:setPosition(104 + (index-1)* 128, 229)
        bottom_panel:addChild(item)
		self.hero_item_list[index] = item
    end

	bottom_panel:getChildByName("pos_tips"):setString(TI18N("从列表中选择英雄"))

	self.fight_btn = bottom_panel:getChildByName("fight_btn")
	self.key_up_btn = bottom_panel:getChildByName("key_up_btn")

	self.fight_btn:getChildByName("label"):setString(TI18N("进入冒险"))
	self.key_up_btn:getChildByName("label"):setString(TI18N("一键布阵"))

    self.power_click = bottom_panel:getChildByName("power_click")
    self.fight_label = CommonNum.new(20, self.power_click, 0, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(103, 28)
end

function AdventureFormWindow:register_event()
    registerButtonEventListener(self.background, function()
        controller:openAdventureFormWindow(false)
    end, false, 2)

	--阵营按钮
    for select_camp, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:onClickBtnShowByIndex(select_camp) end ,true, 2)
    end
    registerButtonEventListener(self.key_up_btn, handler(self, self.onClickKeyUpBtn) ,true, 2)
    registerButtonEventListener(self.fight_btn, handler(self, self.onClickSaveBtn) ,true, 2)

	for i,item in ipairs(self.hero_item_list) do
        item:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self:onClickHeroItemEnd(i, sender)
            end
        end)
    end
end

function AdventureFormWindow:openRootWnd(setting)
    local setting = setting or {}
    self.max_floor = setting.max_floor
    self:onClickBtnShowByIndex(0)
end

--显示根据类型 0表示全部
function AdventureFormWindow:onClickBtnShowByIndex(select_camp)
	if self.img_select and self.camp_btn_list[select_camp] then
		local x, y = self.camp_btn_list[select_camp]:getPosition()
		self.img_select:setPosition(x - 0.5, y + 1)
	end
	self:updateHeroList(select_camp)
end 

--==============================--
--desc:创建英雄列表
--time:2019-01-24 02:27:47
--@select_camp:
--@return 
--==============================--
function AdventureFormWindow:updateHeroList(select_camp)
    local select_camp = select_camp or 0
    if select_camp == self.select_camp then 
        return
    end
    if not self.list_view then
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local setting = {
			item_class = HeroExhibitionItem,      -- 单元类
			start_x = 0,                  -- 第一个单元的X起点
			space_x = 8,                    -- x方向的间隔
			start_y = 0,                    -- 第一个单元的Y起点
			space_y = 10,                   -- y方向的间隔
			item_width = 119,               -- 单元的尺寸width
			item_height = 119,              -- 单元的尺寸height
			row = 5,                        -- 行数，作用于水平滚动类型
			col = 5,                         -- 列数，作用于垂直滚动类型
			once_num = 5,
			need_dynamic = true
        }
		self.list_view = CommonScrollViewLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting) 
    end
    self.select_camp = select_camp

	local function clickback(cell, data)
		self:selectHero(cell, data)
	end
    local hero_array = hero_model:getAllHeroArray()
    local show_list = {}
    for j=1,hero_array:GetSize() do
        local hero_vo = hero_array:Get(j-1)
        if select_camp == 0 or (select_camp == hero_vo.camp_type) then
			table_insert(show_list, hero_vo)
        end
    end
	if #show_list > 0 then
		local sort_func = SortTools.tableUpperSorter({"star", "power", "lev", "sort_order"})
		table_sort(show_list, sort_func)
		self.list_view:setData(show_list, clickback, nil, {scale=0.9,from_type=HeroConst.ExhibitionItemType.eAdventure, can_click=true})
        self.no_vedio_image:setVisible(false)
	else
		self.list_view:setData({})
        self.no_vedio_image:setVisible(true)
	end
    self.show_list = show_list
end

--==============================--
--desc:一键上阵
--time:2019-01-24 04:04:22
--@return 
--==============================--
function AdventureFormWindow:onClickKeyUpBtn()
	local count = tableLen(self.five_hero_vo)
	if count >= 5 then
		message(TI18N("上阵人数已满"))
		return
	end
	if self.show_list == nil or next(self.show_list) == nil then
		message(TI18N("当前列表没有可上阵的英雄"))
		return
	end
	for i=1,5 do
		if self.five_hero_vo[i] == nil then
			local hero_vo = self:getFreeHero()
			if hero_vo then
				hero_vo.is_ui_select = true
				self.five_hero_vo[i] = hero_vo
				self.hero_item_list[i]:setData(hero_vo)
				-- 在上面列表中找到这个对象,并且设置选中
				self:setTopSelect(hero_vo, i)
			end
		end
	end
	self:updateFightPower()
end

function AdventureFormWindow:setTopSelect(hero_vo, index)
	if self.list_view == nil then return end
	if self.select_list[index] then return end
	local item_list = self.list_view:getItemList()
	for k,v in pairs(item_list) do
		local data = v:getData()
		if data and data.partner_id == hero_vo.partner_id then
			v:setSelected(hero_vo.is_ui_select)
			self.select_list[index] = v
			break
		end
	end
end

--==============================--
--desc:获取当前不在阵上的英雄
--time:2019-01-24 04:06:18
--@return 
--==============================--
function AdventureFormWindow:getFreeHero()
	for i, hero_vo in ipairs(self.show_list) do
		local is_free = true
        if hero_vo.isResonateHero and hero_vo:isResonateHero() then
            is_free = false
        end
        if is_free == true then
    		for k, data in pairs(self.five_hero_vo) do
    			if hero_vo.partner_id == data.partner_id or hero_vo.bid == data.bid then
    				is_free = false
    				break
    			end
    		end
        end
		if is_free == true then
			return hero_vo
		end
	end
end

--==============================--
--desc:点击上面选中的单位
--time:2019-01-24 03:50:33
--@item:
--@hero_vo:
--@return 
--==============================--
function AdventureFormWindow:selectHero(item, hero_vo)
	if item == nil or hero_vo == nil then return end
	local index = -1
	local partner_id = hero_vo.partner_id
	for k,v in pairs(self.five_hero_vo) do
		if partner_id == v.partner_id then
			index = k
			break
		end
	end
	if index ~= -1 then		-- 下阵
        hero_vo.is_ui_select = false
        item:setSelected(hero_vo.is_ui_select)
        self.hero_item_list[index]:setData(nil)
		self.five_hero_vo[index] = nil
		self.select_list[index] = nil
	else
        if hero_vo.checkResonateHero and hero_vo:checkResonateHero() then
            return 
        end

        local count = 0
        for i,v in pairs(self.five_hero_vo) do
            if v.bid == hero_vo.bid then
                message(TI18N("不能同时上阵2个相同英雄"))
                return
            end
            count = count + 1
        end
        if count >= 5 then
            message(TI18N("上阵人数已满"))
            return
        end
		local new_index = 0
		for i=1,5 do
			if self.five_hero_vo[i] == nil then
				new_index = i
				break
			end
		end
		if new_index == 0 then
            message(TI18N("没有上阵位置"))
            return
		end
		self.five_hero_vo[new_index] = hero_vo
        self.hero_item_list[new_index]:setData(hero_vo)
		self.select_list[new_index] = item
		hero_vo.is_ui_select = true
        item:setSelected(hero_vo.is_ui_select)
	end
	self:updateFightPower()
end

--==============================--
--desc:计算战斗力
--time:2019-01-24 03:54:39
--@return 
--==============================--
function AdventureFormWindow:updateFightPower()
    local power = 0
    for k,v in pairs(self.five_hero_vo) do
        power = power + v.power
    end
    self.fight_label:setNum(power)
end

--==============================--
--desc:点击下面5个英雄
--time:2019-01-24 03:54:49
--@index:
--@sender:
--@return 
--==============================--
function AdventureFormWindow:onClickHeroItemEnd(index, sender)
	local hero_vo = self.five_hero_vo[index]
	if hero_vo == nil then return end
	hero_vo.is_ui_select = false 

    local list = self.list_view:getItemList()
    for i,item in ipairs(list) do
        local data = item:getData()
        if data.partner_id == hero_vo.partner_id then
            item:setSelected(hero_vo.is_ui_select)
        end
    end
	self.five_hero_vo[index] = nil
	self.select_list[index] = nil
    self.hero_item_list[index]:setData(nil)

    self:updateFightPower()
end

--==============================--
--desc:请求进入冒险
--time:2019-01-24 04:25:34
--@return 
--==============================--
function AdventureFormWindow:onClickSaveBtn()
	local plist = {}
	local count = 0
	for k,v in pairs(self.five_hero_vo) do
		table_insert(plist, {id=v.partner_id})
		count = count + 1
	end
	if count == 0 then
		message(TI18N("请设置出战英雄"))
		return
	end
	local hero_array = hero_model:getAllHeroArray()
	local size = hero_array:GetSize() 
	if count < 5 and count < size then			-- 当前还有可上的英雄但是没设置上
		local msg = TI18N("当前上阵英雄不足5个，是否确认以此阵容进入冒险？")
		CommonAlert.show(msg,TI18N("确定"),function() 
			controller:requestSetForm(plist, self.max_floor)
		end, TI18N("取消"))
	else
		controller:requestSetForm(plist, self.max_floor)
	end
end

function AdventureFormWindow:close_callback()
    if self.fight_label then
        self.fight_label:DeleteMe()
    end
    self.fight_label = nil
	
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
            v:DeleteMe()
        end
        self.hero_item_list = nil
    end

     --清空选中状态
    local hero_list = hero_model:getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.is_ui_select = nil
    end
    controller:openAdventureFormWindow(false)
end