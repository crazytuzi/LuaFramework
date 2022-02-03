-- --------------------------------------------------------------------
-- 我要变强面板
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
StrongerPanel = class("StrongerPanel", function()
    return ccui.Widget:create()
end)

function StrongerPanel:ctor(partner_id)
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()

	self.cur_hero_item = nil
	self.partner_id = partner_id or 0  -- 默认选中的英雄

	self:configUI()
	self:register_event()
end

function StrongerPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("stronger/stronger_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    local title_role = self.main_container:getChildByName("title_role")
    title_role:setString(TI18N("我的阵容"))

    local info_bg = self.main_container:getChildByName("info_bg")
    local now_hero = info_bg:getChildByName("now_hero")
    now_hero:setString(TI18N("当前英雄："))
    self.now_hero_val = info_bg:getChildByName("now_hero_val")
    local title = info_bg:getChildByName("title")
    title:setString(TI18N("评分/本服最高"))

    self.loadingbar = info_bg:getChildByName("loadingbar")
    self.loadingbar:setScale9Enabled(true)
    self.loadingbar_exp = info_bg:getChildByName("loadingbar_exp")

    self.hero_con = self.main_container:getChildByName("hero_con")
    local hero_con_size = self.hero_con:getContentSize()
    local scroll_view_size1 = cc.size(hero_con_size.width, hero_con_size.height+40)
    local scale = 0.8
    local setting_1 = {
        item_class = HeroExhibitionItem,      -- 单元类
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 12,                    -- x方向的间隔
        start_y = 20,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = HeroExhibitionItem.Width*scale,               -- 单元的尺寸width
        item_height = HeroExhibitionItem.Height*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = scale,
    }
    self.hero_scroll = CommonScrollViewLayout.new(self.hero_con, cc.p(0,-20) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size1, setting_1)
    self.hero_scroll:setSwallowTouches(false)
    self.hero_scroll:setBounceEnabled(false)

    self.scroll_con = self.main_container:getChildByName("scroll_con")
    local scroll_view_size2 = self.scroll_con:getContentSize()
    local setting_2 = {
        item_class = StrongerPanelItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 8,                   -- y方向的间隔
        item_width = 617,               -- 单元的尺寸width
        item_height = 142,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scroll = CommonScrollViewLayout.new(self.scroll_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size2, setting_2)
    self.item_scroll:setSwallowTouches(false)
    
    self:createHeroList()
end

function StrongerPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

--创建英雄列表
function StrongerPanel:createHeroList(  )
	--只显示上阵英雄
	local list = HeroController:getInstance():getModel():getMyPosList()
	local show_list = {}
	for k,v in pairs(list) do
		local hero_vo = HeroController:getInstance():getModel():getHeroById(v.id)
		if self.partner_id == 0 and #show_list == 0 then -- 没有默认选中的英雄则选中第一个
			self.partner_id = hero_vo.partner_id
		end
		table.insert(show_list,hero_vo)
	end

	local extendData = {scale = 0.8, can_click = true, click_delay = 0.5, from_type = HeroConst.ExhibitionItemType.eStronger}
    self.hero_scroll:setData(show_list, function(item, hero_vo) self:_onClickHero(item ,hero_vo) end, nil, extendData)
    self.hero_scroll:addEndCallBack(function (  )
        local list = self.hero_scroll:getItemList()
        for k,v in pairs(list) do
            local data = v:getData()
            if data.partner_id == self.partner_id then
            	self:_onClickHero(v, data)
            	break
            end
        end
    end)
end

-- 点击英雄头像
function StrongerPanel:_onClickHero( item ,hero_vo )
	if hero_vo.is_ui_select == true then return end
	if self.cur_hero_item then
		local data = self.cur_hero_item:getData()
		data.is_ui_select = false
		self.cur_hero_item:setBoxSelected(false)
	end
	hero_vo.is_ui_select = true
	item:setBoxSelected(true)
	self.cur_hero_item = item

	-- 请求伙伴变强相关数据
	self.ctrl:sender11070(hero_vo.partner_id)
end

-- 刷新为某个英雄的相关数据
function StrongerPanel:refreshViewByHero( hero_vo )
	self.now_hero_val:setString(hero_vo.name)
	local total_val, max_val = self.model:getTotalAndMaxValByBid(hero_vo.bid)
	local percent = (total_val/max_val)*100
	self.loadingbar:setPercent(percent)
	self.loadingbar_exp:setString(total_val.."/"..max_val)

	self:refreshItemList(hero_vo.bid)
end

function StrongerPanel:getCurHero(  )
	return self.cur_hero_item
end

function StrongerPanel:refreshItemList( bid )
	local list_data = {}
	for k,v in pairs(Config.StrongerData.data_stronger_two) do
		local is_open = true
		for _,lData in pairs(v.limit) do
			local open_status = self.model:checkStrongItemIsOpen(lData)
			if open_status == false then
				is_open = false
			end
		end
		if is_open then
			local data = deepCopy(v)
			data.score_val, data.max_val = self.model:getStrongerValByBid(bid, v.id)
			table.insert(list_data, data)
		end
	end
	table.sort(list_data,SortTools.KeyLowerSorter("sort"))
	
	self.item_scroll:setData(list_data)
end

function StrongerPanel:register_event()
	if not self.partner_stronger_event  then
		self.partner_stronger_event = GlobalEvent:getInstance():Bind(StrongerEvent.UPDATE_SCROE,function (data)
			if self.cur_hero_item then
				local cur_hero_vo = self.cur_hero_item:getData()
				if cur_hero_vo.bid == data.partner_bid then
					self:refreshViewByHero(cur_hero_vo)
				end
			end
		end)
	end
end

function StrongerPanel:DeleteMe()
	if self.hero_scroll then
		self.hero_scroll:DeleteMe()
		self.hero_scroll = nil
	end
	if self.item_scroll then
		self.item_scroll:DeleteMe()
		self.item_scroll = nil
	end

	if self.partner_stronger_event then
        GlobalEvent:getInstance():UnBind(self.partner_stronger_event)
        self.partner_stronger_event = nil
    end

	--清空选中状态
    local hero_list = HeroController:getInstance():getModel():getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.is_ui_select = nil
    end
end

-----------------------------------@ item
StrongerPanelItem = class("StrongerPanelItem", function()
    return ccui.Widget:create()
end)

function StrongerPanelItem:ctor()
	self.ctrl = StrongerController:getInstance()
	self:configUI()
	self:register_event()
end

function StrongerPanelItem:configUI(  )
	self.size = cc.size(617, 142)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("stronger/stronger_panel_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("main_container")

    local score_title = container:getChildByName("score_title")
    score_title:setString(TI18N("评分/本服最高"))

    self.name_label = container:getChildByName("name")
    self.desc_label = container:getChildByName("desc_label")
    self.goods_icon = container:getChildByName("goods_icon")

    self.loadingbar = container:getChildByName("loadingbar")
    self.loadingbar:setScale9Enabled(true)
    self.loadingbar_exp = container:getChildByName("loadingbar_exp")

    self.go_btn = container:getChildByName("go_btn")
    self.go_btn:getChildByName("label"):setString(TI18N("前往"))
end

function StrongerPanelItem:register_event(  )
	registerButtonEventListener(self.go_btn, handler(self, self._onClickGoBtn), true)
end

function StrongerPanelItem:_onClickGoBtn(  )
	if self.data and self.data.evt_type then 
		self.ctrl:clickCallBack(self.data.evt_type)
	end
end

function StrongerPanelItem:setData( data )
	if data then
		-- 引导需要
		if data._index then
			self.go_btn:setName("go_btn_" .. data._index)
		end

		self.data = data
		self.name_label:setString(data.name)

		local res = PathTool.getStrongerIconRes(data.icon)
		loadSpriteTexture(self.goods_icon,res,LOADTEXT_TYPE)

		self.desc_label:setString(data.desc)

		local percent = (data.score_val/data.max_val)*100
		self.loadingbar:setPercent(percent)
		self.loadingbar_exp:setString(data.score_val .. "/" .. data.max_val)
	end
end

function StrongerPanelItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end