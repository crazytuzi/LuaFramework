--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 神装图鉴
-- @DateTime:    2019-04-22 16:56:26
-- *******************************

HeroClothesLustratWindow = HeroClothesLustratWindow or BaseClass(BaseView)
local controller = HeroController:getInstance()
local holy_eqm_list = Config.ItemData.data_holy_eqm_list
local const_list = Config.PartnerHolyEqmData.data_const.handbook_unlock_condition
local table_sort = table.sort
local table_insert = table.insert
function HeroClothesLustratWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big      
    self.view_tag = ViewMgrTag.DIALOGUE_TAG    
    self.layout_name = "hero/hero_clothes_lustrat_window"
    self.tab_view_list = {}
	self.cur_index = nil
	
	self.tab_suit_perfix = {}
    local suir_prefix = Config.PartnerHolyEqmData.data_suit_res_prefix
    for i,v in pairs(suir_prefix) do
        table_insert(self.tab_suit_perfix,v)
    end
    table_sort(self.tab_suit_perfix,function(a,b) return a.id < b.id end)
end

function HeroClothesLustratWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
    self.main_container:getChildByName("title_con"):getChildByName("title_label"):setString(TI18N("神装图鉴"))
    local item_goods = self.main_container:getChildByName("goods")
    local scroll_view_size = item_goods:getContentSize()
    local setting = {
        item_class = HeroClothesLustratItem,      -- 单元类
        start_x = 5,                    -- 第一个单元的X起点
        space_x = 5,                   -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 312,               -- 单元的尺寸width
        item_height = 147,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_goods,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)

    self:createTabList()
end

function HeroClothesLustratWindow:createTabList()
	local tab_view = self.main_container:getChildByName("tab_view")
	tab_view:setScrollBarEnabled(false)
    local count = #self.tab_suit_perfix
    local tab_bg = tab_view:getChildByName("tab_bg")
    tab_bg:setContentSize(cc.size(HeroClothesLustratTab.Width*count+10,54))
    tab_view:setInnerContainerSize(cc.size(HeroClothesLustratTab.Width*count+10,63))

    for i=1,count do
    	self.tab_view_list[i] = HeroClothesLustratTab.new()
    	self.tab_view_list[i]:setPosition(((i-1)*HeroClothesLustratTab.Width)+55,31)
		tab_view:addChild(self.tab_view_list[i])
		self.tab_view_list[i]:setData(i,count,self.tab_suit_perfix[i])
		local function func(index)
			self:tabChangeView(index)
		end
		self.tab_view_list[i]:addCallBack(func)
    end
    self:tabChangeView(1)
end
function HeroClothesLustratWindow:tabChangeView(index)
	index = index or 1
	if self.cur_index == index then return end
	if not self.tab_view_list[index] then return end

	if self.cur_tab ~= nil then
		self.cur_tab:setNormal(false)
		self.cur_tab:setSelect(true)
		self.cur_tab:setName(cc.c4b(0xcf,0xb5,0x93,0xff))
	end
	self.cur_index = index
	self.cur_tab = self.tab_view_list[self.cur_index]
	if self.cur_tab ~= nil then
		self.cur_tab:setNormal(true)
		self.cur_tab:setSelect(false)
		self.cur_tab:setName(cc.c4b(0xff,0xed,0xd6,0xff))
	end
	
	if self.tab_suit_perfix and self.tab_suit_perfix[index] and self.tab_suit_perfix[index].id then
		local temp_list = {}
		local list = {}
		for k,v in pairs(holy_eqm_list) do
			if math.floor(k/100) == self.tab_suit_perfix[index].id then
				for j,g in pairs(v) do
					local config = Config.PartnerHolyEqmData.data_base_info(g.id)
					if config and config.is_show == 1 then
						if const_list and const_list.val then
							for j,b in pairs(const_list.val) do
								local item_config = Config.ItemData.data_get_data(g.id)
								if item_config and b[1] == item_config.eqm_star then
									if HeavenController:getInstance():getModel():checkIsOpenByScore(b[2]) == true then
										local goodvo = GoodsVo.New(item_config.id)
										goodvo.lustr_status = true
										goodvo.sort = item_config.eqm_star
										table_insert(list,goodvo)
									end
									break
								end
							end
						end
					end
				end
			end
		end
		
		local sort_func = SortTools.tableUpperSorter({"sort","base_id"})
		table_sort(list, sort_func)
		self.item_scrollview:setData(list)
	end
	
end

function HeroClothesLustratWindow:register_event()
	registerButtonEventListener(self.background, function()
        controller:openHeroClothesLustratWindow(false)
    end,false, 2)
end
function HeroClothesLustratWindow:openRootWnd()
    
end
function HeroClothesLustratWindow:close_callback()
	if self.tab_view_list then
        for i,v in pairs(self.tab_view_list) do
            v:DeleteMe()
        end
        self.tab_view_list = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	controller:openHeroClothesLustratWindow(false)
end

------------------------------------------
HeroClothesLustratTab = class("HeroClothesLustratTab", function()
    return ccui.Widget:create()
end)
HeroClothesLustratTab.Width = 100
HeroClothesLustratTab.Height = 50
function HeroClothesLustratTab:ctor()
	self:configUI()
	self:register_event()
end

function HeroClothesLustratTab:configUI()
	self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("hero/hero_clothes_lustrat_tab"))
	self.root_wnd:setContentSize(cc.size(HeroClothesLustratTab.Width,HeroClothesLustratTab.Height))
    self:addChild(self.root_wnd)
    self:setTouchEnabled(true)

    self:setContentSize(cc.size(HeroClothesLustratTab.Width,HeroClothesLustratTab.Height))
	
	local main_container = self.root_wnd:getChildByName("main_container")
	
	self.select = main_container:getChildByName("select")
	self.normal = main_container:getChildByName("normal")
    self.normal:setVisible(false)
    self.name = main_container:getChildByName("name")
    self.name:setString("")
end
function HeroClothesLustratTab:setSelect(visible)
	if self.select then
		self.select:setVisible(visible)
	end
end
function HeroClothesLustratTab:setNormal(visible)
	if self.normal then
		self.normal:setVisible(visible)
	end
end
function HeroClothesLustratTab:setName(color)
	if self.name then
		self.name:setTextColor(color)
	end
end

function HeroClothesLustratTab:addCallBack(func)
	self.callback = func
end

function HeroClothesLustratTab:register_event()
	self:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click then
            	playTabButtonSound()
            	if self.callback and self.data_index then
            		self.callback(self.data_index)
            	end
            end
		end
	end)
end

function HeroClothesLustratTab:setData(index, count,data)
	self.data_index = index
	self.select:setFlippedX(false)
	self.normal:setFlippedX(false)
	if index == 1 then
		self.select:loadTexture(PathTool.getResFrame("common","common_2023"), LOADTEXT_TYPE_PLIST)
		self.select:setFlippedX(true)
		self.normal:loadTexture(PathTool.getResFrame("common","common_2021"), LOADTEXT_TYPE_PLIST)
		self.normal:setFlippedX(true)
	elseif index == count then
		self.select:loadTexture(PathTool.getResFrame("common","common_2023"), LOADTEXT_TYPE_PLIST)
		self.normal:loadTexture(PathTool.getResFrame("common","common_2021"), LOADTEXT_TYPE_PLIST)
	end
	if data and data.name then
		local name = string.sub(data.name,1,6) --如果全是中文可以这样处理，如果有中英文就不行
		self.name:setString(name)
	end
end

function HeroClothesLustratTab:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end

------------------------------------------
HeroClothesLustratItem = class("HeroClothesLustratItem", function()
    return ccui.Widget:create()
end)
function HeroClothesLustratItem:ctor()
	self.goods_item = nil
	self:configUI()
	self:register_event()
end

function HeroClothesLustratItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("hero/hero_clothes_lustrat_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(312,147))

    local main_container = self.root_wnd:getChildByName("main_container")
    self.eqm_name = main_container:getChildByName("eqm_name")
    self.eqm_name:setString("")
    self.eqm_spr = main_container:getChildByName("eqm_spr")
    self.eqm_suit = main_container:getChildByName("eqm_suit")
    self.eqm_suit:setString("")

    if not self.goods_item then
	    self.goods_item = BackPackItem.new(nil,true)
	    main_container:addChild(self.goods_item)
	    self.goods_item:setPosition(cc.p(73, 75))
	    self.goods_item:addCallBack(function ()
	    	if self.data then
		        controller:openEquipTips(true, self.data, PartnerConst.EqmTips.other)
		    end
	    end)
	end
end

function HeroClothesLustratItem:register_event()
end

function HeroClothesLustratItem:setData(data)
	if not data then return end
	self.data = data
	if self.goods_item and data.base_id then
		self.goods_item:setBaseData(data.base_id)
		local item_config = Config.ItemData.data_get_data(data.base_id)
		local suit_res_prefix = Config.PartnerHolyEqmData.data_suit_res_prefix
		if item_config then
			self.eqm_name:setString(item_config.name)
            local id = math.floor(item_config.eqm_set/100)
            local config = suit_res_prefix[id]
			if config then
				local name = config.name or ""
				self.eqm_suit:setString(name)
				local res = PathTool.getSuitRes(config.prefix)
				loadSpriteTexture(self.eqm_spr, res, LOADTEXT_TYPE)
			end
		end
	end
end

function HeroClothesLustratItem:DeleteMe()
	if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end

	self:removeAllChildren()
	self:removeFromParent()
end