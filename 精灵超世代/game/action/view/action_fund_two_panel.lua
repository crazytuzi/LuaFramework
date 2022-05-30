--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-10 19:16:26
-- @description    : 
		-- 328 元基金
---------------------------------
ActionFundTwoPanel = class("ActionFundTwoPanel", function()
    return ccui.Widget:create()
end)

local _controller = ActionController:getInstance()
local _model = _controller:getModel()

function ActionFundTwoPanel:ctor(bid)
    self.parent = container
    self.fund_bid = bid
    self.cell_data_list = {}
    self.role_vo = RoleController:getInstance():getRoleVo()
    self:configUI()
    self:register_event()
end

function ActionFundTwoPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fund_panel"))
    self.root_wnd:setPosition(-20,-20)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    local image_bg = self.main_container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_fund_bg_2"), LOADTEXT_TYPE)
    local role_img = self.main_container:getChildByName("role_img")
    loadSpriteTexture(role_img, PathTool.getPlistImgForDownLoad("bigbg","bigbg_108"), LOADTEXT_TYPE)

    self.desc_txt = createRichLabel(18, 1, cc.p(0.5, 0.5), cc.p(470, 514), 12, nil, 500)
    self.main_container:addChild(self.desc_txt)

    self.btn_award = self.main_container:getChildByName("btn_award")
    --self.btn_award:setPositionY(755)
    local btn_award_label = self.btn_award:getChildByName("label")
    btn_award_label:setString(TI18N("奖励预览"))
    local award_title = self.main_container:getChildByName("award_title")
    --award_title:setTextColor(cc.c3b(238,228,255))
    award_title:setString(TI18N("部分奖励预览"))

    local Image_3 = self.main_container:getChildByName("Image_3")
    Image_3:loadTexture(PathTool.getResFrame("actionfund","actionfund_1004"), LOADTEXT_TYPE_PLIST)
    --Image_3:setInnerContainerSize(cc.size(29,35,1,1))
    Image_3:setCapInsets(cc.rect(29,75,1,1))

    self.not_buy_panel = self.main_container:getChildByName("not_buy_panel")
    self.not_buy_panel:setVisible(true)
    self.buy_btn = self.not_buy_panel:getChildByName("buy_btn")
    self.buy_btn_label = self.buy_btn:getChildByName("label")
    self.buy_btn_label:setString(TI18N("328元"))
    self.old_price = createRichLabel(20, 1, cc.p(1,0.5), cc.p(600,40), nil, nil, nil)
    self.not_buy_panel:addChild(self.old_price)
    self.price_line = createScale9Sprite(PathTool.getResFrame("welfare", "welfare_40"), 50, 10, LOADTEXT_TYPE_PLIST, self.old_price)
    self.price_line:setAnchorPoint(cc.p(0.5, 0.5))

    local bottom_txt = createRichLabel(18, Config.ColorData.data_new_color4[15], cc.p(0.5, 0.5), cc.p(360, 80), nil, nil, 500)
    local bottom_str = string.format(TI18N("超值基金和豪华基金可同时购买哦"))
    bottom_txt:setString(bottom_str)
    self.not_buy_panel:addChild(bottom_txt)
    
    local top_txt = createRichLabel(18, Config.ColorData.data_new_color4[15], cc.p(0.5, 0.5), cc.p(365, 434), nil, nil, 500)
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

function ActionFundTwoPanel:updateScrollviewList()
    if self.child_scrollview == nil then
        local scroll_view_size = self.goods_list:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 25,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 10,                     -- y方向的间隔
            item_width = 115,                -- 单元的尺寸width
            item_height = 110,               -- 单元的尺寸height
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
function ActionFundTwoPanel:createNewCell(width, height)
    local cell = ActionFuncTwoItem.new()
	return cell
end

--获取数据数量
function ActionFundTwoPanel:numberOfCells()
    if not self.cell_data_list then return 0 end
    return #self.cell_data_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function ActionFundTwoPanel:updateCellByIndex(cell, index)
    if not self.cell_data_list then return end
    cell.index = index
    local cell_data = self.cell_data_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

-- 更新整个界面
function ActionFundTwoPanel:updateView(  )
	if not self.fund_bid then return end
    local config = Config.MonthFundData.data_fund_data[self.fund_bid]

    if not config then return end

    self.func_config = config
    -- 描述内容
    self.desc_txt:setString(config.desc)
    -- 档次
    self.buy_btn_label:setString(string.format(TI18N("%s元"), config.val))
    if config.val2 and config.val2 > 0 then
        local str = string.format("%s%s%s",TI18N("原价:"),GetSymbolByType(),config.val2)
        self.old_price:setString(str)
        self.old_price:setVisible(true)
    else
        self.old_price:setVisible(false)
    end

    self:setData()
end

-- 设置服务器数据相关UI显示
function ActionFundTwoPanel:setData(  )
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
            --self.buy_btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
            self.buy_btn:setTouchEnabled(true)
        else
            setChildUnEnabled(true, self.buy_btn)
            --self.buy_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.buy_btn:setTouchEnabled(false)
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
                self.award_node = BackPackItem.new(false, true, false, 0.6, false, true)
                self.award_node:setDefaultTip(true,false)
                self.award_node:setPosition(cc.p(108, 60))
                self.buy_panel:addChild(self.award_node)
            end
            self.award_node:setBaseData(bid, num)
        end

        -- 领取按钮状态
        if srv_data.status == 1 then
            setChildUnEnabled(false, self.get_btn)
            self.get_btn:setTouchEnabled(true)
            self.get_btn_label:setString(TI18N("领取"))
        else
            setChildUnEnabled(true, self.get_btn)
            self.get_btn:setTouchEnabled(false)
            self.get_btn_label:setString(TI18N("已领取"))
        end
    end
end

function ActionFundTwoPanel:register_event(  )
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

function ActionFundTwoPanel:_onClickBuyBtn(  )
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

function ActionFundTwoPanel:_onClickGetBtn(  )
	if self.srv_data and self.srv_data.status == 1 then
        _controller:sender24702(self.srv_data.id)
    end
end

function ActionFundTwoPanel:_onClickAwardBtn(  )
	if self.srv_data then
        _controller:openActionFundAwardWindow(true, self.srv_data.group_id, self.fund_bid)
    end
end

function ActionFundTwoPanel:setVisibleStatus(bool)
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

function ActionFundTwoPanel:DeleteMe(  )
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
ActionFuncTwoItem = class("ActionFuncTwoItem", function()
    return ccui.Widget:create()
end)

function ActionFuncTwoItem:ctor()
	self:configUI()
	self:register_event()
end

function ActionFuncTwoItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_fund_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(115, 110))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")

    self.txt_time = self.container:getChildByName("txt_time")
end

function ActionFuncTwoItem:register_event(  )
	
end

function ActionFuncTwoItem:setData( data )
	if not data then return end

    self.txt_time:setString(string.format(TI18N("%d天"), data.day or 1))

    local bid = data.award[1][1]
    local num = data.award[1][2]
    if not self.item_node then
        self.item_node = BackPackItem.new(false, true, false, 0.6, false, true)
        self.item_node:setDefaultTip(true,false)
        local container_size = self.container:getContentSize()
        self.item_node:setPosition(cc.p(container_size.width/2, 70))
        self.container:addChild(self.item_node)
    end
    self.item_node:setBaseData(bid, num)
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

function ActionFuncTwoItem:DeleteMe(  )
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