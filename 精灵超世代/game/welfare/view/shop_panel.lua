--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 灵羽商店
-- @DateTime:    2019-08-02 16:55:31
-- *******************************
ShopPanel = class("ShopPanel", function()
	return ccui.Widget:create()
end) 

local shop_config = Config.ExchangeData.data_shop_list
local controller = WelfareController:getInstance()
local model = controller:getModel()
local welfare_shop_id = 50 --圣羽商店
local select_color = Config.ColorData.data_new_color4[1]
local normal_color = Config.ColorData.data_new_color4[6]
function ShopPanel:ctor()
	self.cur_index = nil
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.shop_type_data = {}
	self.shop_item_bid = 1
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("welfareshop", "welfareshop"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("varietystore", "varietystore"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_bg"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_girl"), type = ResourcesType.single},
	}

	self.resources_load = ResourcesLoad.New(true)
	self.resources_load:addAllList(self.res_list, function()
		if self.loadResListCompleted then
			self:loadResListCompleted()
		end
	end)
end
function ShopPanel:loadResListCompleted()
	self:createRootWnd()
    self:register_event()
end
function ShopPanel:createRootWnd()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/shop_panel"))
	self:addChild(self.root_wnd)
	self:setAnchorPoint(0, 0)

	local main_container = self.root_wnd:getChildByName("main_container")
	local image_bg = main_container:getChildByName("image_bg")
	local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "welfare_shop_bg")
	self.load_bg = loadSpriteTextureFromCDN(image_bg, bg_path, ResourcesType.single)

	local image_girl = main_container:getChildByName("welfare_shop_girl_2")
	local girl_path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_shop_girl")
	self.load_girl = loadSpriteTextureFromCDN(image_girl, girl_path, ResourcesType.single)

	main_container:getChildByName("Text_2"):setString(TI18N("欢迎光临^_^"))
	local icon = main_container:getChildByName("icon")

	local config = Config.ItemData.data_get_data(35)
    if config then
        local icon_res = PathTool.getItemRes(config.icon)
        loadSpriteTexture(icon, icon_res, LOADTEXT_TYPE)
        icon:setScale(0.35)
    end
	self.icon_count = main_container:getChildByName("icon_count")
	self.icon_count:setString(self.role_vo.feather_exchange or 0)
	self.btn_resoure = main_container:getChildByName("btn_resoure")

	self.btn_rule = main_container:getChildByName("btn_rule")
	self.good_cons = main_container:getChildByName("good_cons")
    local view_size = cc.size(self.good_cons:getContentSize().width,self.good_cons:getContentSize().height)
    local setting = {
        start_x = 20,
        space_x = 25,
        start_y = 15,
        space_y = 20,
        item_width = ShopItem.width,
        item_height = ShopItem.height,
        row = 1,
        col = 3,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.good_cons,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,view_size,setting)
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    --local effect_node = main_container:getChildByName("effect_node")
    --self.role_effect = createEffectSpine(PathTool.getEffectRes(644),cc.p(0,0),cc.p(0, 0.5),true,"action")
	--effect_node:addChild(self.role_effect)

	local tab_view = main_container:getChildByName("tab_view")
	self.tab_list = {}
	for i=1,2 do
		local tab = {}
		tab.btn = tab_view:getChildByName("tab_"..i)
		tab.select = tab.btn:getChildByName("select")
		tab.normal = tab.btn:getChildByName("normal")
		tab.select:setVisible(false)
		tab.name = tab.btn:getChildByName("name")
		tab.name:setTextColor(normal_color)
		if shop_config[welfare_shop_id+i] then
			tab.name:setString(shop_config[welfare_shop_id+i].name or "")
		end
		tab.index = i
		self.tab_list[i] = tab
	end

	self:setIsBlockTabView()
	self:tabChangeView(1)
end
--根据等级判断是否开启
function ShopPanel:isOpenTabView(id)
	if not self.role_vo then return end
	local status = false
	if shop_config and shop_config[id] then
		status = MainuiController:getInstance():checkIsOpenByActivate(shop_config[id].limit)
	end
	return status
end
function ShopPanel:createNewCell()
	local cell = ShopItem.new()
    return cell
end
function ShopPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
function ShopPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
    --if index%3 == 1 then
	--    cell:createItemBgSprite(-index)
	--end
end

function ShopPanel:tabChangeView(tab_index)
	local is_open = self:isOpenTabView(welfare_shop_id+tab_index)
	if is_open == false then
		message(string.format(TI18N("人物等级%s开启%s商店"),shop_config[welfare_shop_id+tab_index].limit[1][2],shop_config[welfare_shop_id+tab_index].name))
		return
	end
	if self.cur_index == tab_index then return end

	if self.cur_tab ~= nil then
		self.cur_tab.name:setTextColor(normal_color)
		self.cur_tab.name:disableEffect(cc.LabelEffect.SHADOW)
		self.cur_tab.select:setVisible(false)
		self.cur_tab.normal:setVisible(true)
	end
	self.cur_index = tab_index
	self.cur_tab = self.tab_list[tab_index]
	if self.cur_tab ~= nil then
		self.cur_tab.name:setTextColor(select_color)
		self.cur_tab.name:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
		self.cur_tab.select:setVisible(true)
		self.cur_tab.normal:setVisible(false)
	end	

	self.show_list = model:getWelfareShopData(tab_index)
	if self.show_list then
		self.item_scrollview:reloadData()
	else
		model:setWelfareShopData(tab_index)
		self.show_list = model:getWelfareShopData(tab_index)
		if self.show_list then
			self.item_scrollview:reloadData()
		end
	end
end
--判断开启状态
function ShopPanel:setIsBlockTabView()
	if shop_config and shop_config[welfare_shop_id] then
		for i,v in pairs(shop_config[welfare_shop_id].subtype) do
			local index = v - welfare_shop_id
			local is_open = self:isOpenTabView(welfare_shop_id+index)
			if self.tab_list[index] then
			 	if is_open == true then
			 		setChildUnEnabled(false, self.tab_list[index].btn)
					--self.tab_list[index].name:enableOutline(cc.c4b(0x33,0x23,0x1b,0xff), 2)
				else
					setChildUnEnabled(true, self.tab_list[index].btn)
					--self.tab_list[index].name:disableEffect(cc.LabelEffect.OUTLINE)
				end
			end
		end
	end
end
function ShopPanel:register_event()
	registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
		local config = Config.HolidayClientData.data_constant
        if config["welfare_shop_rules"] then
	        TipsManager:getInstance():showCommonTips(config["welfare_shop_rules"].desc, sender:getTouchBeganPosition(),nil,nil,500)
	    end
    end ,false)

	for i,v in pairs(self.tab_list) do
		registerButtonEventListener(v.btn, function()
			self:tabChangeView(v.index)
    	end,false)
	end
	registerButtonEventListener(self.btn_resoure, function()
		local config = Config.ItemData.data_get_data(35)
		if config then
			BackpackController:getInstance():openTipsSource(true, config)
		end
	end,false)


	if self.role_assets_event == nil then
        self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key == "lev" then
                self:setIsBlockTabView()
            elseif key == "feather_exchange" then
            	if self.role_vo ~= nil then
	    			self.icon_count:setString(self.role_vo.feather_exchange or 0)
	    		end
            end
        end)
    end
end

function ShopPanel:setVisibleStatus(status)
	bool = bool or false
	self:setVisible(status)
end

function ShopPanel:DeleteMe()
	--if self.role_effect then
    --    self.role_effect:clearTracks()
    --    self.role_effect:removeFromParent()
    --    self.role_effect = nil
    --end
 	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
 	if self.load_bg then
        self.load_bg:DeleteMe()
        self.load_bg = nil
    end
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
end

--商店子项
ShopItem = class("ShopItem", function()
    return ccui.Widget:create()
end)

function ShopItem:ctor()
    self:configUI()
    self:register_event()
end

ShopItem.width = 188
ShopItem.height = 230
function ShopItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("mall/varietystore_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(ShopItem.width, ShopItem.height))

    local container = self.root_wnd:getChildByName("container")
    container:setTouchEnabled(false)

    local image_zhe = container:getChildByName("image_zhe")
    image_zhe:setVisible(false)
	self.btn_buy = container:getChildByName("btn_buy")
	self.btn_buy:setSwallowTouches(false)

	self.image_buy = container:getChildByName("image_buy")
	self.image_buy:setVisible(false)

	local pos_node = container:getChildByName("pos_node")
	self.item_icon = BackPackItem.new(false, true, false, 0.9, nil, true)
    self.item_icon:setAnchorPoint(cc.p(0.5, 0))
    pos_node:addChild(self.item_icon)

    self.price_label = createRichLabel(26, Config.ColorData.data_new_color4[16], cc.p(0.5, 0.5), cc.p(ShopItem.width*0.5-9, 40))
	container:addChild(self.price_label)
	self.container = container
end
function ShopItem:setData(data)
	self.shop_data = data
	if self.item_icon then
		self.item_icon:setBaseData(data.item_bid, data.item_num)
		self.item_icon:setDefaultTip(true)
	end
	
	local _type = Config.ItemData.data_assets_label2id[data.pay_type]
	if _type then
		local item_config = Config.ItemData.data_get_data(_type)
	    if item_config then 
	        local res = PathTool.getItemRes(item_config.icon)
			local price_str = string.format("<img src='%s' scale=0.35 /> %s", res, MoneyTool.GetMoneyString(data.price))
		    self.price_label:setString(price_str)
		end
	end
end
--function ShopItem:createItemBgSprite(zorder)
--	if not self.item_bg then
--		self.item_bg = createSprite(res, -43, 92, self.container, cc.p(0,1), LOADTEXT_TYPE,zorder)
--		local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "welfare_shop_grid")
--		self.load_item_bg = loadSpriteTextureFromCDN(self.item_bg, bg_path, ResourcesType.single)
--	end
--end

function ShopItem:register_event()
	registerButtonEventListener(self.btn_buy, function()
		self:btnBuyAward()
    end,false,nil,nil,nil,nil,true)
end

function ShopItem:btnBuyAward()
	if self.shop_data then
		local role_vo = RoleController:getInstance():getRoleVo()
		if self.shop_data.price > role_vo.feather_exchange then
			MallController:getInstance():sender13402(self.shop_data.id, 1)
			return	
		end

		-- local data = {}
	 --    data.id = self.shop_data.id --商店物品 id
	 --    data.item_bid = self.shop_data.item_bid	--显示的物品和名字
	 --    data.limit_num = 1--math.floor(role_vo.feather_exchange/self.shop_data.price)	--限购个数（最终显示：限购个数 - 已经购买个数）
	 --    data.has_buy = 0 --已经购买个数
	 --    data.price = self.shop_data.price --购买每一个的价格
	 --    data.pay_type = shop_config[self.shop_data.type].item_bid --支付方式
	 --    data.is_show_limit_label = false
	    -- MallController:getInstance():openMallBuyWindow(true, data)

		local str = string.format(TI18N("是否购买<div fontColor=#289b14 fontsize= 26>%s</div>"),self.shop_data.item_name)
		local function call_back()
			MallController:getInstance():sender13402(self.shop_data.id, 1)
		end
		CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,nil,26)
	end
end

function ShopItem:DeleteMe()
	--if self.load_item_bg then
    --    self.load_item_bg:DeleteMe()
    --    self.load_item_bg = nil
    --end
    self:removeAllChildren()
    self:removeFromParent()
end

