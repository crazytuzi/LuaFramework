--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 神装商店
-- @DateTime:    2019-04-23 09:45:39
-- *******************************
SuitShopMainWindow = SuitShopMainWindow or BaseClass(BaseView)
local controller = SuitShopController:getInstance()
local hero_ctl = HeroController:getInstance()

local heaven_model = HeavenController:getInstance():getModel()

local mall_controller = MallController:getInstance()

local suit_shop_list = Config.ExchangeData.data_shop_exchage_suit
local table_sort = table.sort
local table_insert = table.insert

--策划要求在神装商店可以买 这个一个道具 都要特殊处理
SuitShopMainWindow.buy_item_id = 10030

function SuitShopMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big      
    self.view_tag = ViewMgrTag.DIALOGUE_TAG    
    self.layout_name = "suitshop/suitshop_window"
    self.cur_index = nil
    self.role_vo = RoleController:getInstance():getRoleVo()

    --dic_buy_info[itemid] = ext
    self.dic_buy_info = {}

    self.tab_suit_perfix = {}
    local suir_prefix = Config.PartnerHolyEqmData.data_suit_res_prefix
    local const_list = Config.PartnerHolyEqmData.data_const.shop_unlock_condition
    for i,v in pairs(suir_prefix) do
        if const_list and const_list.val then
            for k,j in pairs(const_list.val) do
                if v.id == j[1] then
                    if HeavenController:getInstance():getModel():checkIsOpenByScore(j[2]) == true then
                        table_insert(self.tab_suit_perfix,v)
                    end
                    break
                end
            end
        end
    end
    table_sort(self.tab_suit_perfix,function(a,b) return a.id < b.id end)
end

function SuitShopMainWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_container:getChildByName("title_con"):getChildByName("title_label"):setString(TI18N("神装商店"))
    self.main_container:getChildByName("Text_2"):setString(TI18N("购买后随机获得随机品阶的同名神装"))
    self.totle_diam = self.main_container:getChildByName("totle_diam")
    self.totle_diam:setString(MoneyTool.GetMoneyString(self.role_vo.holy_eqm_coin))
    self.sprite = self.main_container:getChildByName("Sprite_1") 

    local shop_config = Config.ExchangeData.data_shop_list[MallConst.MallType.SuitShop]
    if shop_config then
        local config = Config.ItemData.data_get_data(shop_config.item_bid)
        if config then
            local head_icon = PathTool.getItemRes(config.icon, false)
            loadSpriteTexture(self.sprite, head_icon, LOADTEXT_TYPE)
        end
    end
    
end


function SuitShopMainWindow:register_event()
	if self.role_vo then
        if self.updata_suit_event == nil then
            self.updata_suit_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
            	if key == "holy_eqm_coin" then
            		self.totle_diam:setString(MoneyTool.GetMoneyString(self.role_vo.holy_eqm_coin))
            	end
        	end)
        end
    end

     --主信息
    self:addGlobalEvent(MallEvent.Open_View_Event, function(data)
        if not data then return end
        for i,info in ipairs(data.item_list) do
            for k,v in pairs(info.ext) do
                if v.key == 1 then
                    self.dic_buy_info[info.item_id] = v.val
                end
            end
        end
        self:createTabList()
    end)     

    --购买信息返回
    self:addGlobalEvent(MallEvent.Buy_Success_Event, function(data)
        if not data then return end
        for k,v in pairs(data.ext) do
            if v.key == 1 then
                self.dic_buy_info[data.eid] = v.val
            end
        end
        if self.item_scrollview then
            self.item_scrollview:resetCurrentItems()
        end
    end)

	registerButtonEventListener(self.background, function()
        controller:openSuitShopMainView(false)
    end,false, 2)
end


function SuitShopMainWindow:openRootWnd()
    MallController:getInstance():sender13401(MallConst.MallType.SuitShop)
end


function SuitShopMainWindow:createTabList()
    if self.tab_view_list == nil  then
        self.tab_view_list = {}
        local tab_view = self.main_container:getChildByName("tab_view")
        tab_view:setScrollBarEnabled(false)
        local count = #self.tab_suit_perfix
        local posx = (self.main_container:getContentSize().width - SuitShopTab.Width*count+10)/2
        if posx < 39 then
            posx = 39
        else
            tab_view:setContentSize(cc.size(SuitShopTab.Width*count+10,63))
        end
        tab_view:setPositionX(posx)
        local tab_bg = tab_view:getChildByName("tab_bg")
        tab_bg:setContentSize(cc.size(SuitShopTab.Width*count+10,54))
        tab_view:setInnerContainerSize(cc.size(SuitShopTab.Width*count+10,63))

        for i=1,count do
            self.tab_view_list[i] = SuitShopTab.new()
            self.tab_view_list[i]:setPosition(((i-1)*SuitShopTab.Width)+55,31)
            tab_view:addChild(self.tab_view_list[i])

            self.tab_view_list[i]:setData(i,count,self.tab_suit_perfix[i])
            self.tab_view_list[i]:addCallBack(function() self:tabChangeView(i) end)
        end
    end
    self:tabChangeView(1)
end
function SuitShopMainWindow:tabChangeView(index)
    local index = index or 1
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

    self:updateList(index)
end


function SuitShopMainWindow:updateList(index)
    if self.item_scrollview == nil then
        local item_goods = self.main_container:getChildByName("goods")
        local scroll_view_size = item_goods:getContentSize()
        local setting = {
            -- item_class = SuitShopItem,      -- 单元类
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
        self.item_scrollview = CommonScrollViewSingleLayout.new(item_goods,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if self.tab_suit_perfix and self.tab_suit_perfix[index] and self.tab_suit_perfix[index].id then
        if suit_shop_list[self.tab_suit_perfix[index].id] then
            self.show_list = {}
            for i,v in pairs(suit_shop_list[self.tab_suit_perfix[index].id]) do
                local status = heaven_model:checkIsOpenByScore(v.show_condit)
                if status == true then
                    table_insert(self.show_list,v)
                end
            end
            table_sort(self.show_list,function(a,b) return a.order > b.order end)
            self.item_scrollview:reloadData()
        end
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function SuitShopMainWindow:createNewCell(width, height)
   local cell = SuitShopItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function SuitShopMainWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function SuitShopMainWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    local config = cell_data.config
    cell:setData(cell_data)
    if cell_data.id == SuitShopMainWindow.buy_item_id then
        local has_buy = self.dic_buy_info[cell_data.id] or 0
        cell:showLimitCount(true, has_buy, cell_data.limit_day)
    else
        cell:showLimitCount(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function SuitShopMainWindow:onCellTouched(cell)
    if not cell.index then return end
    local cell_data = self.show_list[cell.index]
    if not cell_data then return end
    
    local item_id = Config.ItemData.data_assets_label2id.holy_eqm_coin
    if cell_data.id == SuitShopMainWindow.buy_item_id then
        local data = {}
        data.id = cell_data.id
        data.item_bid = cell_data.item_bid
        data.limit_num = cell_data.limit_day --只处理每日限购
        data.has_buy = self.dic_buy_info[cell_data.id] or 0
        data.price = cell_data.price
        data.pay_type = item_id
        data.shop_type = MallConst.MallType.SuitShop
        data.is_show_limit_label = true
        mall_controller:openMallBuyWindow(true, data)
    else
        local function func()
            MallController:getInstance():sender13402(cell_data.id,1)
        end
       
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string.format("是否消耗 <img src='%s' scale=0.3 />%s 购买商品?", iconsrc, cell_data.price)
        CommonAlert.show(str, TI18N("确定"), func, TI18N("取消"),nil, CommonAlert.type.rich)
    end

end

function SuitShopMainWindow:close_callback()
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
    if self.role_vo then
        if self.updata_suit_event then
            self.role_vo:UnBind(self.updata_suit_event)
            self.updata_suit_event = nil
        end
        self.role_vo = nil
    end
	controller:openSuitShopMainView(false)
end

------------------------------------------
SuitShopTab = class("SuitShopTab", function()
    return ccui.Widget:create()
end)
SuitShopTab.Width = 100
SuitShopTab.Height = 50
function SuitShopTab:ctor()
	self:configUI()
	self:register_event()
end

function SuitShopTab:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("hero/hero_clothes_lustrat_tab"))
    self:addChild(self.root_wnd)
    self:setTouchEnabled(true)
    self:setContentSize(cc.size(SuitShopTab.Width,SuitShopTab.Height))

    local main_container = self.root_wnd:getChildByName("main_container")
    self.select = main_container:getChildByName("select")
    self.normal = main_container:getChildByName("normal")
    self.normal:setVisible(false)
    self.name = main_container:getChildByName("name")
    self.name:setString("")
end
function SuitShopTab:setSelect(visible)
	if self.select then
		self.select:setVisible(visible)
	end
end
function SuitShopTab:setNormal(visible)
	if self.normal then
		self.normal:setVisible(visible)
	end
end
function SuitShopTab:setName(color)
	if self.name then
		self.name:setTextColor(color)
	end
end

function SuitShopTab:addCallBack(func)
	self.callback = func
end

function SuitShopTab:register_event()
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

function SuitShopTab:setData(index,count,data)
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

function SuitShopTab:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end

------------------------------------------
SuitShopItem = class("SuitShopItem", function()
    return ccui.Widget:create()
end)
function SuitShopItem:ctor()
	self.goods_item = nil
	self:configUI()
	self:register_event()
end

function SuitShopItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("suitshop/suitshop_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(312,147))
    self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.sprite = self.main_container:getChildByName("Sprite_1") 

    local shop_config = Config.ExchangeData.data_shop_list[MallConst.MallType.SuitShop]
    if shop_config then
        local config = Config.ItemData.data_get_data(shop_config.item_bid)
        if config then
            local head_icon = PathTool.getItemRes(config.icon, false)
            loadSpriteTexture(self.sprite, head_icon, LOADTEXT_TYPE)
        end
    end
    
    self.name = self.main_container:getChildByName("name")
    self.name:setString("")
    self.diam_count = self.main_container:getChildByName("diam_count")
    self.diam_count:setString("")

    self.item_mask = self.main_container:getChildByName("item_mask")
    self.item_mask:setVisible(false)
    self.condit = self.main_container:getChildByName("condit")
    self.condit:setVisible(false)
    
    local item_node = self.main_container:getChildByName("item_node")
    if not self.goods_item then
	    self.goods_item = BackPackItem.new(nil,true)
        self.goods_item:setSwallowTouches(true)
	    item_node:addChild(self.goods_item)
	    self.goods_item:setDefaultTip()
	end
end

function SuitShopItem:register_event()
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
            	playButtonSound2() 
                if self.callback then
                    self.callback()
                end
            end
		end
	end)
end

function SuitShopItem:addCallBack(callback)
    self.callback = callback
end

function SuitShopItem:setData(data)
	if not data then return end
	self.suit_shop_data = data

	local status = heaven_model:checkIsOpenByScore(data.buy_condit)
	--不能购买的时候
	if status == false then
		self.item_mask:setVisible(true)
        self.condit:setVisible(true)
		self:setTouchEnabled(false)
		self.condit:setString(data.pass_name)
		self.goods_item:setDefaultTip(false)
	else
		self.item_mask:setVisible(false)
        self.condit:setVisible(false)
		self:setTouchEnabled(true)
		self.goods_item:setDefaultTip(true)
	end 

	if self.goods_item then
        self.goods_item:setBaseData(data.id)
        if data.id ~= SuitShopMainWindow.buy_item_id then
            self.goods_item:setSuitShopStar(true,data.show_star)
        else
            self.goods_item:setSuitShopStar(false)
        end
	end

	self.condit:setString(data.pass_name)
	self.name:setString(data.item_name)
	self.diam_count:setString(data.price)
end

function SuitShopItem:showLimitCount(status, has_buy, limit_num)
    if status then
        if self.limit_tips == nil then
            self.limit_tips = createRichLabel(20, 175, cc.p(0,0.5), cc.p(136,35))
            self.main_container:addChild(self.limit_tips)
        else
            self.limit_tips:setVisible(true)
        end
        self.limit_tips:setString(string.format(TI18N("每日限购<div fontcolor=#249003>%s/%s</div>个"), has_buy, limit_num))
    else
        if self.limit_tips then
           self.limit_tips:setVisible(false) 
        end
    end
end

function SuitShopItem:DeleteMe()
	if self.goods_item then 
       self.goods_item:DeleteMe()
       self.goods_item = nil
    end

	self:removeAllChildren()
	self:removeFromParent()
end