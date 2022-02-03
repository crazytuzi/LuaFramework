--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-10 19:16:26
-- @description    : 
		-- 128 元基金
---------------------------------
ActionFundOnePanel = class("ActionFundOnePanel", function()
    return ccui.Widget:create()
end)

local _controller = ActionController:getInstance()
local _model = _controller:getModel()

function ActionFundOnePanel:ctor(bid)
    self.parent = container
    self.fund_bid = bid
    self.cell_data_list = {}
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:configUI()
    self:register_event()
end

function ActionFundOnePanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fund_panel"))
    self.root_wnd:setPosition(-40,-81)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    local image_bg = self.main_container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_fund_bg_1",true), LOADTEXT_TYPE)

    self.desc_txt = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(495, 648), 12, nil, 500)
    self.main_container:addChild(self.desc_txt)

    self.btn_award = self.main_container:getChildByName("btn_award")
    self.btn_award:setPositionY(755)
    local btn_award_label = self.btn_award:getChildByName("label")
    btn_award_label:setString(TI18N("奖励预览"))
    local award_title = self.main_container:getChildByName("award_title")
    award_title:setString(TI18N("部分奖励预览"))

    self.not_buy_panel = self.main_container:getChildByName("not_buy_panel")
    self.not_buy_panel:setVisible(true)
    self.buy_btn = self.not_buy_panel:getChildByName("buy_btn")
    self.buy_btn_label = self.buy_btn:getChildByName("label")

    local bottom_txt = createRichLabel(26, cc.c4b(0xff,0xea,0xb6,0xff), cc.p(0.5, 0.5), cc.p(360, 135), nil, nil, 500)
    local bottom_str = string.format(TI18N("超值基金和豪华基金可同时购买哦"))
    bottom_txt:setString(bottom_str)
    self.not_buy_panel:addChild(bottom_txt)
    
    local top_txt = createRichLabel(26, cc.c4b(0xff,0xea,0xb6,0xff), cc.p(0.5, 0.5), cc.p(565, 550), nil, nil, 500)
    local top_str = string.format(TI18N("至尊月卡用户可激活"))
    top_txt:setString(top_str)
    self.main_container:addChild(top_txt)

    self.buy_panel = self.main_container:getChildByName("buy_panel")
    self.buy_panel:setVisible(false)
    self.buy_panel:getChildByName("title_time"):setString(TI18N("领取时间："))
    self.buy_panel:getChildByName("tips_txt"):setString(TI18N("(每天登陆累计1天，最大30天)"))

    self.total_day_txt = self.buy_panel:getChildByName("total_day_txt")
    self.time_txt = self.buy_panel:getChildByName("txt_time")
    self.get_btn = self.buy_panel:getChildByName("get_btn")
    self.get_btn_label = self.get_btn:getChildByName("label")
    self.get_btn_label:setString(TI18N("领取"))

    self.goods_list = self.main_container:getChildByName("goods_list")
    self:updateScrollviewList()
    self:updateView()
end

function ActionFundOnePanel:updateScrollviewList()
    if self.child_scrollview == nil then
        local scroll_view_size = self.goods_list:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 25,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 10,                     -- y方向的间隔
            item_width = 115,                -- 单元的尺寸width
            item_height = 129,               -- 单元的尺寸height
            row = 0,                         -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            delay = 4,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.child_scrollview = CommonScrollViewSingleLayout.new(self.goods_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.child_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.child_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActionFundOnePanel:createNewCell(width, height)
    local cell = ActionFuncOneItem.new()
	return cell
end

--获取数据数量
function ActionFundOnePanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionFundOnePanel:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

-- 更新整个界面
function ActionFundOnePanel:updateView(  )
    if not self.fund_bid then return end
    local config = Config.MonthFundData.data_fund_data[self.fund_bid]

    if not config then return end

    self.func_config = config
	-- 描述内容
    self.desc_txt:setString(config.desc)
    -- 档次
    self.buy_btn_label:setString(config.val .. TI18N("元"))

    self:setData()
end

-- 设置服务器数据相关UI显示
function ActionFundOnePanel:setData(  )
    local srv_data = _model:getFundSrvDataById(self.fund_bid)

    if not srv_data or next(srv_data) == nil then
        return
    end

    self.srv_data = srv_data

    -- 30天奖励
    local award_list = Config.MonthFundData.data_fund_award[srv_data.group_id] or {}
    local group_award = Config.MonthFundData.data_fund_group[srv_data.group_id] or {}
    -- 部分奖励数据预览
    if group_award then
        local award_data = {}
        for i,day in ipairs(group_award.reward) do
            local show_effect = false
            if group_award.effect_val ~= nil and next(group_award.effect_val) ~= nil then
                for k, v in ipairs(group_award.effect_val) do
                    if v == day then
                        show_effect = true
                        break
                    end
                end
            end
            local day_award = {}
            day_award.day = day
            day_award.award = award_list[day] or {}
            day_award.show_effect = show_effect
            table.insert(award_data, day_award)
        end
        self.cell_data_list = award_data
        self.child_scrollview:reloadData()
    end

    -- 购买状态
    if srv_data.status == 0 or srv_data.status == 3 then
        self.not_buy_panel:setVisible(true)
        self.buy_panel:setVisible(false)
        if srv_data.status == 0 then
            setChildUnEnabled(false, self.buy_btn)
            self.buy_btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
            --self.buy_btn:setTouchEnabled(true)
        else
            setChildUnEnabled(true, self.buy_btn)
            self.buy_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            --self.buy_btn:setTouchEnabled(false)
        end
    elseif srv_data.status == 1 or srv_data.status == 2 then
        self.not_buy_panel:setVisible(false)
        self.buy_panel:setVisible(true)

        -- 当前累计几天
        self.total_day_txt:setString(string.format(TI18N("当前累计：%d天"), srv_data.current_day))
        -- 领取时间
        local begin_time = srv_data.endtime - (30*24*60*60)
        self.time_txt:setString(TimeTool.getMD2(begin_time) .. "~" .. TimeTool.getMD2(srv_data.endtime-1))
        -- 奖励图标
        local award = award_list[srv_data.current_day] or {}
        if award then
            local bid = award[1][1]
            local num = award[1][2]
            if not self.award_node then
                self.award_node = BackPackItem.new(false, true, false, 0.9, false, true)
                self.award_node:setDefaultTip(true,false)
                self.award_node:setPosition(cc.p(108, 104))
                self.buy_panel:addChild(self.award_node)
            end
            self.award_node:setBaseData(bid, num)
        end

        -- 领取按钮状态
        if srv_data.status == 1 then
            setChildUnEnabled(false, self.get_btn)
            self.get_btn:setTouchEnabled(true)
            self.get_btn_label:setString(TI18N("领取"))
            self.get_btn_label:enableOutline(cc.c3b(43, 97, 13), 2)
        else
            setChildUnEnabled(true, self.get_btn)
            self.get_btn:setTouchEnabled(false)
            self.get_btn_label:setString(TI18N("已领取"))
            self.get_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
        end
    end
end

function ActionFundOnePanel:register_event(  )
	registerButtonEventListener(self.buy_btn, handler(self, self._onClickBuyBtn), false)
	registerButtonEventListener(self.get_btn, handler(self, self._onClickGetBtn), false)
	registerButtonEventListener(self.btn_award, handler(self, self._onClickAwardBtn), true)

    if not self.update_fund_data_event  then
        self.update_fund_data_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATA_FUND_DATA_EVENT,function (id)
            if self.fund_bid == id then
                self:setData()
            end
        end)
    end


end

function ActionFundOnePanel:_onClickBuyBtn(  )
	if self.srv_data and self.srv_data.status == 0 and self.func_config then
        local charge_id = self.func_config.charge_id
        local charge_config = Config.ChargeData.data_charge_data[charge_id or 0]
        if charge_config then
            sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name)
        end
    elseif self.srv_data and self.srv_data.status == 3 then
        message(TI18N("请先激活至尊月卡"))
    end
end

function ActionFundOnePanel:_onClickGetBtn(  )
	if self.srv_data and self.srv_data.status == 1 then
        _controller:sender24702(self.srv_data.id)
    end
end

function ActionFundOnePanel:_onClickAwardBtn(  )
	if self.srv_data then
		_controller:openActionFundAwardWindow(true, self.srv_data.group_id, self.fund_bid)
	end
end

function ActionFundOnePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        local srv_data = _model:getFundSrvDataById(self.fund_bid)
        if not srv_data or next(srv_data) == nil then --没有数据时则请求
            _controller:sender24701(self.fund_bid)
        end
        local welfare_data = _model:getFundIsInWelfare()
        if welfare_data ~= nil and next(welfare_data) ~= nil then
            for i,v in ipairs(welfare_data) do
                if v.id == self.fund_bid then
                    WelfareController:getInstance():sender24703(self.fund_bid)
                end
            end
        end
    end
end

function ActionFundOnePanel:DeleteMe(  )
	if self.child_scrollview then
		self.child_scrollview:DeleteMe()
		self.child_scrollview = nil
	end
    if self.award_node then
        self.award_node:DeleteMe()
        self.award_node = nil
    end
    if self.update_fund_data_event then
        GlobalEvent:getInstance():UnBind(self.update_fund_data_event)
        self.update_fund_data_event = nil
    end
end

----------------------@ 子项
ActionFuncOneItem = class("ActionFuncOneItem", function()
    return ccui.Widget:create()
end)

function ActionFuncOneItem:ctor()
	self:configUI()
	self:register_event()
end

function ActionFuncOneItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fund_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(115, 129))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")

    self.txt_time = self.container:getChildByName("txt_time")
end

function ActionFuncOneItem:register_event(  )
	
end

function ActionFuncOneItem:setData( data )
	if not data then return end
    
    local bid = data.award[1][1]
    local num = data.award[1][2]
    if not self.item_node then
        self.item_node = BackPackItem.new(false, true, false, 0.8, false, true)
        self.item_node:setDefaultTip(true,false)
        local container_size = self.container:getContentSize()
        self.item_node:setPosition(cc.p(container_size.width/2, 78))
        self.container:addChild(self.item_node)
    end
    self.item_node:setBaseData(bid, num)
    self.txt_time:setString(string.format(TI18N("累计%d天"), data.day or 1))
    -- 设物品特效
    if self.item_effect == nil then
        if data.show_effect then
            local pos_x = self.item_node:getContentSize().width / 2
            local pos_y = self.item_node:getContentSize().height / 2
            self.item_effect = createEffectSpine(PathTool.getEffectRes(263), cc.p(pos_x, pos_y), cc.p(0.5, 0.5), true, "action1")
            self.item_effect:setScale(1.1)
            self.item_node:addChild(self.item_effect)
        end
    elseif data.show_effect then
        self.item_effect:setVisible(true)
    else
        self.item_effect:setVisible(false)
    end
end

function ActionFuncOneItem:DeleteMe(  )
    if self.item_effect then
        self.item_effect:clearTracks()
        self.item_effect:removeFromParent()
        self.item_effect = nil
    end
    if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end