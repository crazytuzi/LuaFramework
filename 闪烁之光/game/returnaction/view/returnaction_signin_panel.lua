-------------------------------------
-- @Author: xhj
-- @Date:   2019-12-13 11:39:47
-- @Description:   7天回归签到奖励
-------------------------------------
ReturnActionSigninPanel = class("ReturnActionSigninPanel", function()
	return ccui.Widget:create()
end)

local controller = ReturnActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
function ReturnActionSigninPanel:ctor(bid)
	self.holiday_bid = bid
	self:configUI()
	self:register_event()
end

function ReturnActionSigninPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("returnaction/returnaction_task_panel"))
	self.root_wnd:setPosition(-40,-66)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local title_con = main_container:getChildByName("title_con")
    title_con:getChildByName("label_time_key"):setString(TI18N("剩余时间:"))
    self.label_time = title_con:getChildByName("label_time")
    self.label_time:setString("")

    self.desc_txt = title_con:getChildByName("desc_txt")
    self.desc_txt:setPosition(cc.p(100,56))
    self.icon = title_con:getChildByName("icon")
    self.icon_count = title_con:getChildByName("icon_count")
    self.icon_count:setString("")
    self.banner_spr = title_con:getChildByName("title_img")
    local btn_rule = title_con:getChildByName("btn_rule")
    btn_rule:setVisible(false)

	local panel_goods_list = main_container:getChildByName("goods_item")
    local scroll_view_size = panel_goods_list:getContentSize()
    local setting = {
        start_x = 4,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 6,                   -- y方向的间隔
        item_width = 688,               -- 单元的尺寸width
        item_height = 150,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(panel_goods_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(true)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self:setLoadBanner()
    model:setSignConfigData()
    controller:sender27908()
end

function ReturnActionSigninPanel:setLoadBanner()
    local holiday_data = model:getReturnActionData(self.holiday_bid)
    local str = "txt_cn_returnaction3"
    local title = ""
    if holiday_data then
        str = holiday_data.panel_res
        title = holiday_data.tips
    end

    self.desc_txt:setString(title)

	local res = PathTool.getReturnActionRes(str)
	if not self.load_banner then
		self.load_banner = loadSpriteTextureFromCDN(self.banner_spr, res, ResourcesType.single, self.load_banner)
	end
end

function ReturnActionSigninPanel:createNewCell()
    local cell = ReturnActionSigninItem.new()
    return cell
end

function ReturnActionSigninPanel:numberOfCells()
    if not self.sign_data then return 0 end
    return #self.sign_data
end

function ReturnActionSigninPanel:updateCellByIndex(cell, index)
    if not self.sign_data then return end
    cell.index = index
    local cell_data = self.sign_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ReturnActionSigninPanel:register_event()
	if not self.sign_event then
        self.sign_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Sign_Event,function(data)
            if data and self.label_time then
                setCountDownTime(self.label_time,data.endtime - GameNet:getInstance():getTime())    
            end
            
            self:updateSigninServerList()
        end)
    end
end

--刷新奖励列表
function ReturnActionSigninPanel:updateSigninServerList()
    self.sign_data = model:getSignConfigData()
    if self.sign_data then
        for i,v in pairs(self.sign_data) do
            local data = model:getServerSignData(v.day)
            v.status = 0
            if data then
                v.status = data.status
            end
        end
        self:sortItemList(self.sign_data)
        self.item_scrollview:reloadData()
    end
end
function ReturnActionSigninPanel:sortItemList(list)
    local tempsort = {
        [0] = 2,  -- 1 未领取放中间
        [1] = 1,  -- 2 可领取放前面
        [2] = 3,  -- 3 已领取放最后
    }
    local function sortFunc(objA,objB)
        if objA.status ~= objB.status then
            if tempsort[objA.status] and tempsort[objB.status] then
                return tempsort[objA.status] < tempsort[objB.status]
            else
                return false
            end
        else
            return objA.day < objB.day
        end
    end
    table.sort(list, sortFunc)
end

function ReturnActionSigninPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ReturnActionSigninPanel:DeleteMe()
    doStopAllActions(self.label_time)
    if self.load_banner then 
        self.load_banner:DeleteMe()
        self.load_banner = nil
    end
    
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.sign_event then
        GlobalEvent:getInstance():UnBind(self.sign_event)
        self.sign_event = nil
    end
end

----------------------------------------
-- 子item
----------------------------------------
ReturnActionSigninItem = class("ReturnActionSigninItem", function()
    return ccui.Widget:create()
end)

function ReturnActionSigninItem:ctor()
	self.size = cc.size(688, 150)
    self:configUI()
    self:register_event()
end

function ReturnActionSigninItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("returnaction/returnaction_signin_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.btn_get = self.main_container:getChildByName("btn_get")
    self.btn_get:setVisible(false)
    self.btn_get_text = self.btn_get:getChildByName("Text_1")
    self.btn_get_text:setString(TI18N("领取"))
    self.spr_get = self.main_container:getChildByName("spr_get")
    self.spr_get:setVisible(false)

    self.txt_title = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(20, 124), 0, 0, 400)
    self.main_container:addChild(self.txt_title)
    self.txt_title:setString("")

    self.txt_day = createLabel(24, cc.c4b(0x64,0x32,0x23,0xff),nil, 596, 124,nil,self.main_container,nil,cc.p(0.5, 0.5))
    self.txt_day:setString("")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.goods_con:setScrollBarEnabled(false)
end

function ReturnActionSigninItem:register_event()
	registerButtonEventListener(self.btn_get, function()
        if self.data and self.data.day then
            controller:sender27909(self.data.day)
        end
	end, true, 1)
end

function ReturnActionSigninItem:setData(data)
    if not data then return end
    self.data = data
    self.txt_title:setString(string_format(TI18N("累计登陆<div fontcolor=#289b14>%d</div>天"), data.day))
    local cur_day = model:getActionSignCurDay()
    if cur_day >= data.day then
        cur_day = data.day
    end
    self.txt_day:setString(string_format(TI18N("(%d/%d)"),cur_day,data.day))
    if data.status == 0 then
        self.btn_get:setTouchEnabled(false)
        setChildUnEnabled(true, self.btn_get)
    elseif data.status == 1 then
        self.btn_get:setTouchEnabled(true)
        setChildUnEnabled(false, self.btn_get)

    end
    self.btn_get:setVisible(data.status == 0 or data.status == 1)
    self.spr_get:setVisible(data.status == 2)

    local data_list = data.rewards or {}
    local setting = {}
    setting.scale = 0.8
    setting.max_count = 4
    setting.is_center = false
    setting.space_x = 10
    -- setting.show_effect_id = 263
    self.change_item_list = commonShowSingleRowItemList(self.goods_con, self.change_item_list, data_list, setting)
end

function ReturnActionSigninItem:DeleteMe()
    if self.change_item_list then
        for i,v in pairs(self.change_item_list) do
            if v.DeleteMe then
                v:DeleteMe()    
            end
        end
        self.change_item_list = nil
    end
	self:removeAllChildren()
    self:removeFromParent()
end