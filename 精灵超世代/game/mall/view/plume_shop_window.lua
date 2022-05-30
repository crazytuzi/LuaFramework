-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      圣羽商店
-- <br/>Create: 2019-11-09
-- --------------------------------------------------------------------
local _controller = MallController:getInstance()
local _model = _controller:getModel()
local _welfare_model = WelfareController:getInstance():getModel()
local _table_insert = table.insert
local _string_format = string.format
local _select_color = cc.c4b(0xe6,0xc7,0x96,0xff)
local _normal_color = cc.c4b(0xff,0xf3,0xe0,0xff)
local _shop_config = Config.ExchangeData.data_shop_list

PlumeShopWindow = PlumeShopWindow or BaseClass(BaseView)

function PlumeShopWindow:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/plume_shop_window" 

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("welfareshop", "welfareshop"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("varietystore", "varietystore"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_bg", true), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_top"), type = ResourcesType.single},
	}

	self.role_vo = RoleController:getInstance():getRoleVo()
	self.shop_data = {}
end

function PlumeShopWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
    	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_bg", true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1) 
	self.container_size = self.main_container:getContentSize()
	self.top_panel = self.main_container:getChildByName("top_panel")
	
	self.top_panel:getChildByName("tips_txt"):setString(TI18N("欢迎光临^_^"))

	local tab_view = self.top_panel:getChildByName("tab_view")
	self.tab_objects = {}
	for i = 1, 2 do
		local tab_btn = tab_view:getChildByName("tab_" .. i)
		if tab_btn then
			local object = {}
			object.tab_btn = tab_btn
			object.select = tab_btn:getChildByName("select")
			object.normal = tab_btn:getChildByName("normal")
			object.normal:setVisible(false)
			object.name = tab_btn:getChildByName("name")
			object.name:setTextColor(_select_color)
			local sub_shop_cfg = _shop_config[MallConst.MallType.WelfareHeroShop]
			if i == 2 then
				sub_shop_cfg = _shop_config[MallConst.MallType.WelfareClothShop]
			end
			if sub_shop_cfg then
				object.sub_shop_cfg = sub_shop_cfg
				object.name:setString(sub_shop_cfg.name or "")
				object.open_status = MainuiController:getInstance():checkIsOpenByActivate(sub_shop_cfg.limit)
				if object.open_status == true then
					setChildUnEnabled(false, object.tab_btn)
					object.name:enableOutline(cc.c4b(0x33,0x23,0x1b,0xff), 2)
				else
					setChildUnEnabled(true, object.tab_btn)
					object.name:disableEffect(cc.LabelEffect.OUTLINE)
				end
				if sub_shop_cfg.limit[1] then
					object.close_tips = _string_format(TI18N("人物等级%s开启%s商店"), sub_shop_cfg.limit[1][2] or 0, sub_shop_cfg.name or "")
				end
			end
			_table_insert(self.tab_objects, object)
		end
	end

	local top_sp = self.top_panel:getChildByName("top_sp")
	loadSpriteTexture(top_sp, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_top"), LOADTEXT_TYPE)

	self.cost_item_bid = 35 -- 圣羽商店消耗的物品id
	local item_sp = self.top_panel:getChildByName("item_sp")
	item_sp:setScale(0.35)
	local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
    if item_cfg then
        local icon_res = PathTool.getItemRes(item_cfg.icon)
        loadSpriteTexture(item_sp, icon_res, LOADTEXT_TYPE)
	end
	self.add_btn = self.top_panel:getChildByName("add_btn")

	self.effect_node = self.top_panel:getChildByName("effect_node")
	self.close_btn = self.main_container:getChildByName("close_btn")
	self.btn_rule = self.top_panel:getChildByName("btn_rule")
	self.count_txt = self.top_panel:getChildByName("count_txt")
	self.count_txt:setString(self.role_vo.feather_exchange or 0)

	self:handleEffect(true)

	
	self.bg_img = self.top_panel:getChildByName("image_1")
	self.item_list = self.top_panel:getChildByName("item_list")
	self:adaptationScreen()
    local view_size = self.item_list:getContentSize()
    local setting = {
        start_x = 55,
        space_x = 40,
        start_y = 0,
        space_y = 30,
        item_width = 158,
        item_height = 214,
        row = 1,
        col = 3,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,view_size,setting)
	self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

--设置适配屏幕
function PlumeShopWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(close_btn_y+bottom_y)
    

    local size = self.bg_img:getContentSize()
    local height = (top_y - self.container_size.height) - bottom_y
    self.bg_img:setContentSize(cc.size(size.width, size.height + height))
    local good_cons_size = self.item_list:getContentSize()
    self.item_list:setContentSize(cc.size(good_cons_size.width, good_cons_size.height + height))
end

function PlumeShopWindow:createNewCell()
	local cell = PlumeShopItem.new()
    return cell
end

function PlumeShopWindow:numberOfCells()
	if not self.shop_data then return 0 end
    return #self.shop_data
end

function PlumeShopWindow:updateCellByIndex(cell, index)
	cell.index = index
    local cell_data = self.shop_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
    if index%3 == 1 then
	    cell:createItemBgSprite()
	end
end

function PlumeShopWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.add_btn, handler(self, self.onClickAddBtn), true)

	registerButtonEventListener(self.btn_rule, function (param, sender, event_type)
		local config = Config.HolidayClientData.data_constant
        if config["welfare_shop_rules"] then
	        TipsManager:getInstance():showCommonTips(config["welfare_shop_rules"].desc, sender:getTouchBeganPosition(),nil,nil,500)
	    end
	end, true)

	for i, object in ipairs(self.tab_objects) do
		registerButtonEventListener(object.tab_btn, function ()
			self:onClickTabBtn(i)
		end, true)
	end

	if self.role_assets_event == nil then
        self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key == "lev" then
                self:updateTabBtnStatus()
            elseif key == "feather_exchange" then
            	self.count_txt:setString(self.role_vo.feather_exchange or 0)
            end
        end)
    end
end

function PlumeShopWindow:openRootWnd( )
	self:onClickTabBtn(1)
end

function PlumeShopWindow:onClickAddBtn(  )
	if self.cost_item_bid then
		BackpackController:getInstance():openTipsSource(true, self.cost_item_bid)
	end
end

function PlumeShopWindow:onClickTabBtn(index)
	local object = self.tab_objects[index]
	if not object.open_status then
		message(object.close_tips)
		return
	end
	if self.cur_index == index then return end

	if self.cur_tab ~= nil then
		self.cur_tab.name:setTextColor(_select_color)
		self.cur_tab.select:setVisible(true)
		self.cur_tab.normal:setVisible(false)
	end
	self.cur_index = index
	self.cur_tab = self.tab_objects[index]
	if self.cur_tab ~= nil then
		self.cur_tab.name:setTextColor(_normal_color)
		self.cur_tab.select:setVisible(false)
		self.cur_tab.normal:setVisible(true)
	end

	self.shop_data = _welfare_model:getWelfareShopData(index)
	if self.shop_data then
		self.item_scrollview:reloadData()
	else
		_welfare_model:setWelfareShopData(index)
		self.shop_data = _welfare_model:getWelfareShopData(index)
		if self.shop_data then
			self.item_scrollview:reloadData()
		end
	end
end

-- 更新按钮解锁状态
function PlumeShopWindow:updateTabBtnStatus()
	for i, object in pairs(self.tab_objects) do
		local sub_shop_cfg = object.sub_shop_cfg
		if sub_shop_cfg then
			object.open_status = MainuiController:getInstance():checkIsOpenByActivate(sub_shop_cfg.limit)
			if object.open_status == true then
				setChildUnEnabled(false, object.tab_btn)
				object.name:enableOutline(cc.c4b(0x33,0x23,0x1b,0xff), 2)
			else
				setChildUnEnabled(true, object.tab_btn)
				object.name:disableEffect(cc.LabelEffect.OUTLINE)
			end
		end
	end
end

function PlumeShopWindow:onClickCloseBtn()
	_controller:openPlumeShopWindow(false)
end

function PlumeShopWindow:handleEffect(status)
	if status == true then
		if not tolua.isnull(self.effect_node) and self.role_effect == nil then
			self.role_effect = createEffectSpine(PathTool.getEffectRes(644),cc.p(0,0),cc.p(0, 0.5),true,PlayerAction.action)
			self.effect_node:addChild(self.role_effect)
		end
	else
		if self.role_effect then
			self.role_effect:clearTracks()
			self.role_effect:removeFromParent()
			self.role_effect = nil
		end
	end
end

function PlumeShopWindow:close_callback( )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
	self:handleEffect(false)
	_controller:openPlumeShopWindow(false)
end


------------------------------@ 子项
PlumeShopItem = class("PlumeShopItem", function()
    return ccui.Widget:create()
end)

function PlumeShopItem:ctor()
    self:configUI()
    self:register_event()
end

function PlumeShopItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("mall/varietystore_item"))
	self:addChild(self.root_wnd)
	self.size = cc.size(158, 214)
    self:setContentSize(self.size)

    local container = self.root_wnd:getChildByName("container")
	container:setTouchEnabled(false)
	
	local image_bg = container:getChildByName("image_bg")
	image_bg:loadTexture(PathTool.getResFrame("varietystore","varietystore_1005"), LOADTEXT_TYPE_PLIST)
	image_bg:setPositionY(15)

    local image_zhe = container:getChildByName("image_zhe")
    image_zhe:setVisible(false)
	self.btn_buy = container:getChildByName("btn_buy")
	self.btn_buy:setSwallowTouches(false)

	self.image_buy = container:getChildByName("image_buy")
	self.image_buy:setVisible(false)

	local pos_node = container:getChildByName("pos_node")
	self.item_icon = BackPackItem.new(false, true, false, 0.9, nil, true, false)
    self.item_icon:setAnchorPoint(cc.p(0.5, 0))
    pos_node:addChild(self.item_icon)

	self.price_label = createRichLabel(26, cc.c3b(123,41,0), cc.p(0.5, 0.5), cc.p(self.size.width*0.5, 59))
	container:addChild(self.price_label)
	self.container = container
end
function PlumeShopItem:setData(data)
	self.shop_data = data
	if self.item_grid_bg then
		self.item_grid_bg:setVisible(false)
	end
	if self.item_icon then
		self.item_icon:setBaseData(data.item_bid, data.item_num)
		self.item_icon:setDefaultTip(true)
	end
	
	local pay_item_bid = Config.ItemData.data_assets_label2id[data.pay_type]
	if pay_item_bid then
		local item_config = Config.ItemData.data_get_data(pay_item_bid)
	    if item_config then 
	        local res = PathTool.getItemRes(item_config.icon)
			local price_str = string.format("<img src='%s' scale=0.35 /> %s", res, MoneyTool.GetMoneyString(data.price))
		    self.price_label:setString(price_str)
		end
	end
end
function PlumeShopItem:createItemBgSprite()
	if not self.item_grid_bg then
		self.item_grid_bg = createImage(self.container, PathTool.getResFrame("varietystore","varietystore_1006"), -68, 30, cc.p(0, 1), true, -1, true)
		self.item_grid_bg:setContentSize(cc.size(680, 67))
	end
	self.item_grid_bg:setVisible(true)
end

function PlumeShopItem:register_event()
	registerButtonEventListener(self.btn_buy, function()
		self:btnBuyAward()
    end,true,nil,nil,nil,nil,true)
end

function PlumeShopItem:btnBuyAward()
	if self.shop_data then
		local role_vo = RoleController:getInstance():getRoleVo()
		if self.shop_data.price > role_vo.feather_exchange then
			MallController:getInstance():sender13402(self.shop_data.id, 1)
			return	
		end
		-- local str = _string_format(TI18N("是否购买<div fontColor=#289b14 fontsize= 26>%s</div>"),self.shop_data.item_name)
		local str
		local pay_item_bid = Config.ItemData.data_assets_label2id[self.shop_data.pay_type]
		if pay_item_bid then
			local item_config = Config.ItemData.data_get_data(pay_item_bid)
			local res = PathTool.getItemRes(item_config.icon)
			str = _string_format(TI18N("是否花费 <img src='%s' scale=0.35 />%s 来购买 <div fontColor=#289b14 fontsize= 26> %sX%s</div>"),res,self.shop_data.price,self.shop_data.item_name,self.shop_data.item_num)
		end
		if str then
			local function call_back()
				MallController:getInstance():sender13402(self.shop_data.id, 1)
			end
			CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,nil,26)
		end
	end
end

function PlumeShopItem:DeleteMe()
	if self.item_icon then
		self.item_icon:DeleteMe()
		self.item_icon = nil
	end
    self:removeAllChildren()
    self:removeFromParent()
end