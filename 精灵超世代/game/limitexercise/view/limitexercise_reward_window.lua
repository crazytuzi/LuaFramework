--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 试炼之境查看奖励
-- @DateTime:    2019-05-30 19:19:05
-- *******************************
LimitExerciseRewardWindow = LimitExerciseRewardWindow or BaseClass(BaseView)

local controller = LimitExerciseController:getInstance()
local lev_reward_list = Config.HolidayBossNewData.data_lev_reward_list
local length = Config.HolidayBossNewData.data_lev_reward_list_length
local string_format = string.format
local table_sort = table.sort
function LimitExerciseRewardWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "limitexercise/reward_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("limitexercise","limitexercise"), type = ResourcesType.plist }
    }
end

function LimitExerciseRewardWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2) 
    main_container:getChildByName("Image_2"):getChildByName("Text_1"):setString(TI18N("奖励详情"))
    self.name = main_container:getChildByName("name")
    self.name:setString("")
    self.btn_left = main_container:getChildByName("btn_left")
    self.btn_right = main_container:getChildByName("btn_right")
    local txt2 = main_container:getChildByName("Text_3")
    txt2:setString(TI18N("通关boss关卡即可升级结算奖励，完成所有关卡可直接获得\n当期奖励。若未完成所有关卡，奖励会在本期结束时邮件发放"))
    local real_label = txt2:getVirtualRenderer()
   	if real_label then
        real_label:setLineSpacing(10)
    end

    local goods_con = main_container:getChildByName("item_scrollview")
	local scroll_view_size = goods_con:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 598,               -- 单元的尺寸width
        item_height = 144,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(goods_con, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(true)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createAreaChangeCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfAreaChangeCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateAreaChangeCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
  	
    self.btn_close = main_container:getChildByName("btn_close")
end
function LimitExerciseRewardWindow:createAreaChangeCell()
	local cell = LimitExerciseRewardItem.new()
    return cell
end

function LimitExerciseRewardWindow:numberOfAreaChangeCells()
	if not self.item_list then return 0 end
    return #self.item_list
end
function LimitExerciseRewardWindow:updateAreaChangeCellByIndex(cell, index)
	if not self.item_list then return end
    local cell_data = self.item_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end
function LimitExerciseRewardWindow:openRootWnd()
	self.cur_index = controller:getModel():getCurrentDiff()
	self:dropItem(self.cur_index)
end
--物品 --难度id
function LimitExerciseRewardWindow:dropItem(id)
	id = id or 1
	if id >= (length+1) then
		self.cur_index = length
		message(TI18N("已经是最大等级啦~~~~"))
		return
	end
	if id <= 0 then
		self.cur_index = 1
		message(TI18N("已经是最小等级啦~~~~"))
		return
	end

	self.name:setString(TI18N("难度 ")..id)
	if id >= length then
		id = length
	end
	if id <= 0 then
		id = 1
	end
	if not lev_reward_list[id] then return end
	self.item_list = {}
	self.item_list = lev_reward_list[id]
	table_sort(self.item_list,function(a,b) return a.order_id < b.order_id end)
	self.item_scrollview:reloadData()
end

function LimitExerciseRewardWindow:show_add()
	self.cur_index = self.cur_index + 1
	self:dropItem(self.cur_index)
end
function LimitExerciseRewardWindow:show_minus()
	self.cur_index = self.cur_index - 1
	self:dropItem(self.cur_index)
end

function LimitExerciseRewardWindow:register_event()
	registerButtonEventListener(self.background, function()
    	controller:openLimitExerciseRewardView(false)
    end ,false, 2)
    registerButtonEventListener(self.btn_close, function()
    	controller:openLimitExerciseRewardView(false)
    end ,true, 2)

    registerButtonEventListener(self.btn_left, function()
    	self:show_minus()
    end ,true, 1)
    registerButtonEventListener(self.btn_right, function()
    	self:show_add()
    end ,true, 1)
end
function LimitExerciseRewardWindow:close_callback()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	controller:openLimitExerciseRewardView(false)
end

--******************************
--奖励子项
LimitExerciseRewardItem = class("LimitExerciseRewardItem", function()
    return ccui.Widget:create()
end)

function LimitExerciseRewardItem:ctor()
    self:configUI()
    self:register_event()
end

function LimitExerciseRewardItem:configUI()
	self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("limitexercise/reward_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(598,144))
    local main_container = self.root_wnd:getChildByName("main_container")
    self.settle_text = main_container:getChildByName("Image_1_0"):getChildByName("Text_2")
    self.settle_text:setString("")
    main_container:getChildByName("Image_1"):getChildByName("Text_1"):setString(TI18N("额外可能掉落"))
    self.item_1 = main_container:getChildByName("item_1")
    self.item_1:setScrollBarEnabled(false)
    self.item_2 = main_container:getChildByName("item_2")
    self.item_2:setScrollBarEnabled(false)
    self.box_spr = main_container:getChildByName("box_spr")
end
function LimitExerciseRewardItem:setData(data)
	if not data then return end
	self.data = data
	local sort_id = data.sort_id or 1
   	loadSpriteTexture(self.box_spr,PathTool.getResFrame("limitexercise","limitexercise_box"..sort_id),LOADTEXT_TYPE_PLIST)

	self.settle_text:setString(string_format(TI18N("通关第%d关后结算奖励"),data.order_id))
	self:settleItem(data.reward)
	self:extraItem(data.show_reward)
end
--结算奖励
function LimitExerciseRewardItem:settleItem(settle)
    local setting = {}
    setting.scale = 0.6
    setting.max_count = 3
    setting.is_center = true
    setting.show_effect_id = 263
    self.item_settle_list = commonShowSingleRowItemList(self.item_1, self.item_settle_list, settle, setting)
end

--额外奖励
function LimitExerciseRewardItem:extraItem(extra)
	local setting = {}
    setting.scale = 0.6
    setting.max_count = 2
    setting.is_center = true
    setting.show_effect_id = 263
    self.item_extra_list = commonShowSingleRowItemList(self.item_2, self.item_extra_list, extra, setting)
end

function LimitExerciseRewardItem:register_event()
end

function LimitExerciseRewardItem:DeleteMe()
	if self.item_settle_list then
        for i,v in pairs(self.item_settle_list) do
            v:DeleteMe()
        end
        self.item_settle_list = nil
    end
    if self.item_extra_list then
        for i,v in pairs(self.item_extra_list) do
            v:DeleteMe()
        end
        self.item_extra_list = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end