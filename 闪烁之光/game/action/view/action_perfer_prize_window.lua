--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 优惠劵
-- @DateTime:    2019-09-01 10:00:26
-- *******************************
ActionPerferPrizeWindow = ActionPerferPrizeWindow or BaseClass(BaseView)

local controller = ActionController:getInstance()
local table_sort = table.sort
function ActionPerferPrizeWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_perfer_prize_window"
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg/preferprize", "txt_cn_preferprize_1"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg/preferprize", "preferprize_bg_1"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg/preferprize", "preferprize_bg_2"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("preferprize","preferprize"), type = ResourcesType.plist}
	}
end
function ActionPerferPrizeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.container, 2)
	local image_top = main_container:getChildByName("image_top")
    local url_png = controller:getModel():getPerferDownLoadPng()
    if url_png then
        download_perfer_png(url_png,function(code, filepath)
            if not tolua.isnull(image_top) then
                if code == 0 then
                    loadSpriteTexture(image_top, filepath, LOADTEXT_TYPE)
                end

                local size = image_top:getContentSize()
                local scaleX = 631/size.width
                local scaleY = 246/size.height
                image_top:setScale(scaleX,scaleY)
            end
        end)
    else
        local res = PathTool.getPlistImgForDownLoad("bigbg/preferprize", "txt_cn_preferprize_1")
        if not self.image_top_load then
            self.image_top_load = loadSpriteTextureFromCDN(image_top, res, ResourcesType.single, self.image_top_load)
        end
    end

    self.text_loading = main_container:getChildByName("text_loading")
    self.text_loading:setString(TI18N("数据加载中......"))
    self.touch_url = main_container:getChildByName("touch_url")
    local image_button = main_container:getChildByName("image_button")
	local res = PathTool.getPlistImgForDownLoad("bigbg/preferprize", "preferprize_bg_1")
    if not self.image_button_load then
        self.image_button_load = loadSpriteTextureFromCDN(image_button, res, ResourcesType.single, self.image_button_load)
    end

    self.btn_close = main_container:getChildByName("btn_close")

    self.item_scroll = main_container:getChildByName("item_scroll")
    local view_size = self.item_scroll:getContentSize()
    local setting = {
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 0,
        item_width = 583,
        item_height = 148,
        row = 1,
        col = 1,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_scroll,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,view_size,setting)
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    sdkPerfer_prize()
end

function ActionPerferPrizeWindow:createNewCell()
	local cell = ActionPerferPeizeItem.new()
    return cell
end
function ActionPerferPrizeWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
function ActionPerferPrizeWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ActionPerferPrizeWindow:openRootWnd()
end

--[[
--排序
is_use  1  已使用    is_use 0  rec_ts 有值去使用    rec_ts 为空未达成
]]
function ActionPerferPrizeWindow:sortItem()
    for i,v in pairs(self.show_list) do
        if v.is_use == "1" then
            v.status = 2
        else
            if v.rec_ts == "" then
                v.status = 1
            elseif v.rec_ts ~= "" then
                v.status = 0
            end        
        end
    end
    local func_sort = SortTools.tableLowerSorter({"status"})
    table_sort(self.show_list, func_sort)

    local function price_sort(a,b)
        if a.status == b.status then
            local a_reduce = tonumber(a.reduce)
            local b_reduce = tonumber(b.reduce)
            if a_reduce > b_reduce then
                return false
            else
                return true
            end
        else
            return a.status < b.status
        end
    end
    table_sort(self.show_list, price_sort)
end

function ActionPerferPrizeWindow:setPerferData()
    self.show_list = controller:getModel():getSavePerferData()
    self.text_loading:setVisible(false)
    if next(self.show_list) ~= nil then
        self:sortItem()
        commonShowEmptyIcon(self.item_scroll, false)
        if self.item_scrollview then
            self.item_scrollview:reloadData()
        end
    else
        commonShowEmptyIcon(self.item_scroll, true, {text = TI18N("暂无可用优惠券")})
    end
end

function ActionPerferPrizeWindow:register_event()
    self:addGlobalEvent(ActionEvent.ACTION_PERFER_GET_DATA_EVENT, function()
        self:setPerferData()
    end)

	registerButtonEventListener(self.background, function()
		controller:openActionPerferPrizeWindow(false)
	end, false,2)
	registerButtonEventListener(self.btn_close, function()
		controller:openActionPerferPrizeWindow(false)
	end, false,2)
    registerButtonEventListener(self.touch_url, function()
        self:jumpActionDescUrl()
    end, false)
end

function ActionPerferPrizeWindow:jumpActionDescUrl()
    local url = controller:getModel():getPerferJumpurl()
    if url then
        if not IS_IOS_PLATFORM then
            sdkCallFunc("openUrl", url)
        end
    end
end

function ActionPerferPrizeWindow:close_callback()
	if self.image_top_load then
		self.image_top_load:DeleteMe()
		self.image_top_load = nil
	end
	if self.image_button_load then
		self.image_button_load:DeleteMe()
		self.image_button_load = nil
	end
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	controller:openActionPerferPrizeWindow(false)
end
--**************---
ActionPerferPeizeItem = class("ActionPerferPeizeItem", function()
    return ccui.Widget:create()
end)

function ActionPerferPeizeItem:ctor()
    self:configUI()
    self:register_event()
end

function ActionPerferPeizeItem:configUI()
	self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("action/action_perfer_prize_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(583,148))
    local main_container = self.root_wnd:getChildByName("main_container")
    local image_item = main_container:getChildByName("image_item")
	local res = PathTool.getPlistImgForDownLoad("bigbg/preferprize", "preferprize_bg_2")
    if not self.image_item_load then
        self.image_item_load = loadSpriteTextureFromCDN(image_item, res, ResourcesType.single, self.image_item_load)
    end

    self.new_tag = main_container:getChildByName("new_tag")
    self.new_tag:setVisible(false)
    self.sprite_get = main_container:getChildByName("sprite_get")
    self.sprite_get:setVisible(false)
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto_label = self.btn_goto:getChildByName("Text_6")
    self.btn_goto_label:setString("")

    self.price = main_container:getChildByName("price")
    self.price:setString("")
    self.txt_action_1 = main_container:getChildByName("txt_action_1")
    self.txt_action_1:setString("")
    self.txt_action_2 = main_container:getChildByName("txt_action_2")
    self.txt_action_2:setString("")
    self.desc = main_container:getChildByName("desc")
    self.desc:setString("")
    self.time = main_container:getChildByName("time")
    self.time:setString("")
end
function ActionPerferPeizeItem:setData(data)
    if data.is_use == "1" then
        self.btn_goto_label:setString(TI18N("已使用"))
        setChildUnEnabled(true, self.btn_goto)
        self.btn_goto:setTouchEnabled(false)
    else
        if data.rec_ts == "" then
            self.btn_goto_label:setString(TI18N("未达成"))
            setChildUnEnabled(true, self.btn_goto)
            self.btn_goto:setTouchEnabled(false)
        else
            self.btn_goto_label:setString(TI18N("去使用"))
            setChildUnEnabled(false, self.btn_goto)
            self.btn_goto:setTouchEnabled(true) 
        end
    end
    
    local reduce = data.reduce or 0
    self.price:setString("￥"..reduce)
    self.txt_action_1:setString(data.name)
    self.txt_action_2:setString(data.name)
    self.desc:setString(data.rec_condition)
    self.time:setString(TimeTool.getYMD(data.start_ts).." - "..TimeTool.getYMD(data.end_ts))
    self.time:setColor(cc.c3b(211,211,211))
end
function ActionPerferPeizeItem:register_event()
	registerButtonEventListener(self.btn_goto, function()
        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
	end, true)
end

function ActionPerferPeizeItem:DeleteMe()
	if self.image_item_load then
		self.image_item_load:DeleteMe()
		self.image_item_load = nil
	end
    self:removeAllChildren()
    self:removeFromParent()
end
