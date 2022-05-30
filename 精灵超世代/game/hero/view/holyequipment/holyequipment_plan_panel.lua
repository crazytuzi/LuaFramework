-------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-05-09 14:08:51
-- @Description:   神装配置方案
-------------------------------
HolyequipmentPlanPanel = HolyequipmentPlanPanel or BaseClass(BaseView)

local _controller = HeroController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert
local _table_sort = table.sort

function HolyequipmentPlanPanel:__init()
    self.is_full_screen = false
    self.layout_name = "hero/hero_holy_equip_plan_panel"
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
    }

    self.plan_data = {}  -- 所有套装数据
    self.cur_hero_item_list = {} -- 当前宝可梦的神装item
end

function HolyequipmentPlanPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
    
    self.main_container:getChildByName("wnd_title"):setString(TI18N("套装管理"))
    self.main_container:getChildByName("txt_cur_cfg"):setString(TI18N("当前配置"))
    self.main_container:getChildByName("txt_plan_list"):setString(TI18N("方案一览"))
    self.main_container:getChildByName("txt_tips"):setString(TI18N("点击方案中的神装部位可编辑方案"))
    self.txt_cur_name = self.main_container:getChildByName("txt_cur_name")
    self.txt_cur_name:setString(TI18N("无方案"))

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.btn_save = self.main_container:getChildByName("btn_save")
    self.btn_save:getChildByName("label"):setString(TI18N("保存为方案"))

    self.btn_disarm = self.main_container:getChildByName("btn_disarm")
    self.btn_disarm:getChildByName("label"):setString(TI18N("一键卸下"))

    self.cost_txt = self.main_container:getChildByName("cost_txt")
    self.cost_txt:setString("")

    local plan_list = self.main_container:getChildByName("plan_list")
    local scroll_view_size = plan_list:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 606,               -- 单元的尺寸width
        item_height = 190,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.plan_scrollview = CommonScrollViewSingleLayout.new(plan_list, cc.p(-4, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.plan_scrollview:setSwallowTouches(false)

    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function HolyequipmentPlanPanel:_createNewCell()
    local cell = HolyequipmentPlanItem.new()
    cell:setExtendData(self.hero_vo)
    return cell
end

function HolyequipmentPlanPanel:_numberOfCells()
    if not self.plan_data then return 0 end
    return #self.plan_data
end

function HolyequipmentPlanPanel:_updateCellByIndex(cell, index)
    if not self.plan_data then return end
    cell.index = index
    local cell_data = self.plan_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HolyequipmentPlanPanel:openRootWnd(hero_vo)
	self.hero_vo = hero_vo

    --刷新当前宝可梦神装方案信息
    self:initCurHeroHolyInfo()

    --获取神装套装信息
    local data = _model:getHolyEquipmentPlanData()
    if data then
        self:updateHolyPlanList(data)
    else
        _controller:sender25220() --申请神装套装信息
    end
end

function HolyequipmentPlanPanel:register_event()
    registerButtonEventListener(self.background, function()
        _controller:openHolyequipmentPlanPanel(false)
    end, true, 2)

    registerButtonEventListener(self.close_btn, function()
        _controller:openHolyequipmentPlanPanel(false)
    end, true, 2)

    registerButtonEventListener(self.btn_save, handler(self, self.onSaveSuitsPlan), true, 1)

    registerButtonEventListener(self.btn_disarm, handler(self, self.onDisarmAllEquip), true, 1)

    self:addGlobalEvent(HeroEvent.Hero_Get_Holy_Equipment_Event, function(list)
        if not list or not self.hero_vo then return end
        for i,v in ipairs(list) do
            if v.partner_id == self.hero_vo.partner_id then
                self:updateCurHeroHolyItemList()
            end
        end
    end)

    self:addGlobalEvent(HeroEvent.Holy_Equipment_Update_Event, function(hero_vo)
        if not hero_vo or not self.hero_vo then return end
        if hero_vo.partner_id == self.hero_vo.partner_id then
            self:updateCurHeroHolyItemList()
        end
    end)

    self:addGlobalEvent(HeroEvent.Hero_Get_Holy_Equipment_Plan_Event, function(data)
        if not data then return end
        local _data = _model:getHolyEquipmentPlanData()
        self:updateHolyPlanList(_data)
    end)

    --购买格子刷新
    self:addGlobalEvent(HeroEvent.Hero_Open_Holy_Equipment_Cell_Event, function(num)
        if not num then return end
        local _data = _model:getHolyEquipmentPlanData()
        self:updateHolyPlanList(_data)
    end)

    
    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        if self.hero_vo then
            for i,v in ipairs(list) do
                if self.hero_vo.partner_id == v.partner_id then
                    _controller:openHolyequipmentPlanPanel(false)
                end
            end
        end
    end)
end

--刷新当前钻石数量
function HolyequipmentPlanPanel:updateCostInfo()
    local gold = 0
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo then
        gold = role_vo.gold
        self.cost_txt:setString(MoneyTool.GetMoneyString(gold))
    end
end

--初始化宝可梦当前装配的方案名
function HolyequipmentPlanPanel:initCurHeroHolyName()
    local name_str = TI18N("无方案")
    if self.plan_data then
        for k,v in pairs(self.plan_data) do
            if v and v.partner_id and v.partner_id == self.hero_vo.partner_id then
                name_str = _string_format(TI18N("已使用方案【%s】"), v.name)
            end
        end
    end
    self.txt_cur_name:setString(name_str)
end

--获取神装装备数据列表
--@list 神装套装列表 {{item_id, partner_id}, ...}
--return {goodsvo, goodsvo, ...}
function HolyequipmentPlanPanel:getEquipList(list)
    if not list then return end
    if #list == 0 then return {} end
    local equip_list = {} --神装数据
    for k,v in ipairs(list) do
        if v.item_id then
            local item_vo
            if v.partner_id == 0 then --在装备背包中
                item_vo = BackpackController:getModel():getBagItemById(BackPackConst.Bag_Code.EQUIPS, v.item_id)
            else --宝可梦已穿戴
                item_vo = _model:getHolyEquipById(v.item_id)
            end
            if item_vo and item_vo.config then
                equip_list[item_vo.config.type] = item_vo
            end
        end
    end
    return equip_list
end

--刷新神装装备方案列表
--@holy_equip_plan 神装套装列表
function HolyequipmentPlanPanel:updateHolyPlanList(holy_equip_plan)
    if not holy_equip_plan then return end

    self.plan_data = {} --所有套装数据
    local cell_num = _model.holy_equip_plan_count --已开启格子数量
    local eqm_config_data = Config.PartnerHolyEqmData.data_holy_suit_manage --格子开启配置条件
    for i=1,cell_num do
        local config_data = eqm_config_data[i]
        if holy_equip_plan[config_data.id] then
            self.plan_data[i] = holy_equip_plan[config_data.id]
            self.plan_data[i].equip_list = self:getEquipList(self.plan_data[i].list)
        else
            self.plan_data[i] = {}   
            self.plan_data[i].name = _string_format(TI18N("方案%s"), i)
            self.plan_data[i].id = config_data.id
        end
        self.plan_data[i].config = config_data
        self.plan_data[i].is_open = 1
    end
    --除了开放的格子信息，额外加载一个待开放的格子
    if cell_num < Config.PartnerHolyEqmData.data_holy_suit_manage_length then
         _table_insert(self.plan_data, eqm_config_data[cell_num + 1])
    end
    _table_sort(self.plan_data, SortTools.KeyLowerSorter("id"))

    self:updateCostInfo()
    self:initCurHeroHolyName()

    self.plan_scrollview:reloadData(nil, nil, true) --保持当前列表位置
end

--刷新当前宝可梦神装方案信息
function HolyequipmentPlanPanel:initCurHeroHolyInfo()
    if not self.hero_vo then return end
    --头像
    if not self.cur_hero_head then
        self.cur_hero_head = HeroExhibitionItem.new(0.8, true, 0, false)
        self.cur_hero_head:setPosition(cc.p(575, 690))
        self.main_container:addChild(self.cur_hero_head)
    end
    self.cur_hero_head:setData(self.hero_vo)

    -- 神装item
    local start_x = 105
    for i,holy_type in ipairs(HeroConst.HolyequipmentPosList) do
        local holy_item = self.cur_hero_item_list[holy_type]
        if not holy_item then
            holy_item = BackPackItem.new(false,true,nil,0.8,false)
            holy_item:addCallBack(function() self:selectHolyByIndex(holy_type) end)
            self.main_container:addChild(holy_item)
            local empty_res = PathTool.getResFrame("hero", HeroConst.HolyEmptyIconName[holy_type])
            local empty_icon = createImage(holy_item:getRoot(), empty_res,60,60, cc.p(0.5,0.5), true, 10, false)
            holy_item.empty_icon = empty_icon
            self.cur_hero_item_list[holy_type] = holy_item
        end
        holy_item:setPosition(cc.p(start_x + (i-1)*(BackPackItem.Width*0.8+15), 690))
    end

    --装备组合套装提示
    if not self.holy_tips_label then
        self.holy_tips_label = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(340, 620), nil, nil, 600)
        self.main_container:addChild(self.holy_tips_label)
    end

    self:updateCurHeroHolyItemList()
end

--选中神装装备打开指定面板
--@holy_type 神装类型  BackPackConst.item_type
function HolyequipmentPlanPanel:selectHolyByIndex(holy_type)
    if not self.hero_vo then return end

    local equip_list = _model:getHeroHolyEquipList(self.hero_vo.partner_id)
    local equip_vo = equip_list[holy_type]
    if equip_vo ~= nil then
        _controller:openEquipTips(true, equip_vo, PartnerConst.EqmTips.partner, self.hero_vo, {}) 
    else
        _controller:openHeroHolyEquipClothPanel(true, holy_type, self.hero_vo.partner_id, {}, {},nil,self.hero_vo)
    end
end

--更新神装item显示
function HolyequipmentPlanPanel:updateCurHeroHolyItemList()
    if not self.hero_vo then return end
    local equip_list = _model:getHeroHolyEquipList(self.hero_vo.partner_id)

    for i,holy_type in ipairs(HeroConst.HolyequipmentPosList) do
        local equip_vo = equip_list[holy_type]
        local holy_item = self.cur_hero_item_list[holy_type]
        if equip_vo then
            holy_item:setData(equip_vo)
            if holy_item.empty_icon then 
                holy_item.empty_icon:setVisible(false)
            end
            holy_item.equip_vo = equip_vo
        else
            holy_item:setData()
            if holy_item.empty_icon then 
                holy_item.empty_icon:setVisible(true)
            end
            holy_item.equip_vo = nil
        end
    end

    -- 激活套装提示
    if self.holy_tips_label then
        local list = _model:getHolyEquipSuitDes(equip_list)
        if next(list) ~= nil then
            local str = TI18N("已激活: ")
            for k,v in ipairs(list) do
                local suit_str = _string_format("<img src='%s' scale=0.8 /> %s ", v.icon_res, v.name)
                str = str..suit_str
            end
            self.holy_tips_label:setString(str)
        else
            self.holy_tips_label:setString(TI18N("暂无组合套装"))
        end
    end
end

--保存为方案
function HolyequipmentPlanPanel:onSaveSuitsPlan()
    if not self.hero_vo then return end
    local equip_list = _model:getHeroHolyEquipList(self.hero_vo.partner_id)
    if next(equip_list) == nil then
        message(TI18N("抱歉，穿戴神装为空不允许保存为方案"))
        return 
    end
    _controller:openHolyequipmentChooseTips(true, self.hero_vo, self.plan_data)
end

--一键卸下神装
function HolyequipmentPlanPanel:onDisarmAllEquip()
    if not self.hero_vo then return end
    local equip_list = _model:getHeroHolyEquipList(self.hero_vo.partner_id)
    if next(equip_list) == nil then
        message(TI18N("暂无穿戴神装"))
        return 
    end
    --卸下成功会推送神装装备信息 神装id填0
    _controller:sender11093(self.hero_vo.partner_id, 0, 0)
end

function HolyequipmentPlanPanel:close_callback()
	if self.plan_scrollview then
        self.plan_scrollview:DeleteMe()
        self.plan_scrollview = nil
    end
    for k,v in pairs(self.cur_hero_item_list) do
        v:DeleteMe()
        v = nil
    end
    _controller:openHolyequipmentPlanPanel(false)
end

-------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-05-09 14:08:51
-- @Description:   神装配置子方案
-------------------------------
HolyequipmentPlanItem = class("HolyequipmentPlanItem", function()
    return ccui.Widget:create()
end)

function HolyequipmentPlanItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function HolyequipmentPlanItem:config()
    self.size = cc.size(606, 190)
    self:setContentSize(self.size)
    
    self.equip_item_list = {} --装备item列表
end

function HolyequipmentPlanItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_holy_equip_plan_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.txt_open_desc = self.main_container:getChildByName("txt_open_desc")
    self.txt_open_desc:setString(TI18N("花费钻石开启此方案"))
    self.txt_title = self.main_container:getChildByName("txt_title")
    self.btn_write = self.main_container:getChildByName("btn_write")
    self.btn_write:setTouchEnabled(true)
    self.btn_load = self.main_container:getChildByName("btn_load")
    self.btn_load:setVisible(false)
    self.btn_load:getChildByName("label"):setString(TI18N("装配"))
    self.btn_open = self.main_container:getChildByName("btn_open")
    local btn_size = self.btn_open:getContentSize()
    self.btn_open_label = createRichLabel(26, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.btn_open:addChild(self.btn_open_label)
end

function HolyequipmentPlanItem:registerEvents()
    registerButtonEventListener(self.btn_write, handler(self, self.onChangePlanName), true, 1)

    registerButtonEventListener(self.btn_load, handler(self, self.onLoadSuitsPlan), true, 1)

    registerButtonEventListener(self.btn_open, handler(self, self.onOpenHolyPlan), true, 1)
end

--修改方案名称
function HolyequipmentPlanItem:onChangePlanName()
    if isQingmingShield and isQingmingShield() then
        return
    end
    local function cancel_callback() end
    local function confirm_callback(str)
        if str == nil or str == "" then
            message(TI18N("方案名称不合法"))
            return
        end
        local text = string.gsub(str, "\n", "")
        if text then
            local list = {}
            if self.data and self.data.list and next(self.data.list) ~= 0 then
                for k,v in ipairs(self.data.list) do
                    if v and v.item_id then
                        table.insert(list, {partner_id = v.partner_id, item_id = v.item_id})
                    end
                end
            end
            _controller:sender25221(self.data.id, self.hero_vo.partner_id, text, list)
            self.alert:close()
            self.alert = nil
        end
    end
    self.alert = CommonAlert.showInputApply("", TI18N("方案名最多6个字"), TI18N("确 定"), 
        confirm_callback, TI18N("取 消"), cancel_callback, true, cancel_callback, 22, CommonAlert.type.rich, FALSE,
        cc.size(307, 50), 6, {off_x=15, off_y=-15})
    local label = createLabel(26,Config.ColorData.data_color4[175],nil,55,75,TI18N("方案名："),self.alert.alert_panel)
end

--给当前宝可梦装配当前方案
function HolyequipmentPlanItem:onLoadSuitsPlan()
    if self.data.partner_id == self.hero_vo.partner_id then
        message("该方案已装配")
        return
    end
    if not self.data.list or next(self.data.list) == nil then
        message("为空的方案不允许装配")
        return
    end
    local holy_data = {}
    holy_data.id = self.data.id
    holy_data.name = self.data.name
    holy_data.hero_vo = self.hero_vo
    holy_data.item_list = {}

    local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_wear_tip, false)
    if not status then
        for k,v in ipairs(self.data.list) do
            --方案已被装配，装配宝可梦非当前宝可梦
            if v.partner_id ~= 0 and v.partner_id ~= self.hero_vo.partner_id  then 
                for _type, equip_vo in pairs(self.data.equip_list) do
                    if equip_vo.id == v.item_id then
                         _table_insert(holy_data.item_list, _type, {item_vo = equip_vo, partner_id = v.partner_id})
                    end
                end 
            end
        end
    end
    --判断该方案中是否有已被其他宝可梦穿戴的神装，有则提示
    if holy_data and next(holy_data.item_list) ~= nil then
        _controller:openHolyequipmentWearTips(true, holy_data)
    else
        _controller:sender25224(self.hero_vo.partner_id, self.data.id) --装配方案
    end
end

--购买方案格子
function HolyequipmentPlanItem:onOpenHolyPlan()
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local cur_gold = role_vo.gold
    local cost = self.data.open_cost
    if cost and cost[1] then
        local bid = cost[1][1]
        local num = cost[1][2]
        if cur_gold >= num then
            local item_config = Config.ItemData.data_get_data(bid)
            local tips_str = string.format(TI18N("是否花费<img src=%s visible=true scale=0.4 />%d开启<div fontColor=#d95014>【%s】</div>？"),PathTool.getItemRes(bid), num, self.data.name)    
            CommonAlert.show(tips_str, TI18N("确定"), function()
                _controller:sender25223() --购买新的格子
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            local pay_config = nil
            local pay_type = cost[1][1]
            if type(pay_type) == 'number' then
                pay_config = Config.ItemData.data_get_data(pay_type)
            else
                pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[pay_type])
            end
            if pay_config then
                if pay_config.id == Config.ItemData.data_assets_label2id.gold then
                    if FILTER_CHARGE then
                        message(TI18N("钻石不足"))
                    else
                        local function fun()
                            VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                            --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                        end
                        local str = string.format(TI18N('%s不足，是否前往充值？'), pay_config.name)
                        CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                    end
                else
                    BackpackController:getInstance():openTipsSource(true, pay_config)
                end
            end
        end
    end
end

function HolyequipmentPlanItem:setExtendData(hero_vo)
    self.hero_vo = hero_vo
end

function HolyequipmentPlanItem:setData(data)
    if not data then return end
    self.data = data

    self.txt_title:setString(_string_format("【%s】", data.name)) -- 名称

    -- 是否开启
    if data.is_open == 0 then
        self.btn_load:setVisible(false)
        self.btn_write:setVisible(false)
        self.btn_open:setVisible(true)
        self.txt_open_desc:setVisible(true)
        if data.open_cost and data.open_cost[1] then
            local bid = data.open_cost[1][1]
            local num = data.open_cost[1][2]
            local item_config = Config.ItemData.data_get_data(bid)
            if item_config then
                self.btn_open_label:setString(_string_format(TI18N("<img src='%s' scale=0.3 /> %d  开启"), PathTool.getItemRes(item_config.icon), num))
            end
        end
        if self.use_hero_label then
            self.use_hero_label:setString(_string_format(TI18N("使用者:无")))
        end
        if self.holy_effect_label then
            self.holy_effect_label:setVisible(false)
        end
        for k,v in pairs(self.equip_item_list) do
            if v then
                v:setVisible(false)
            end
        end
    else
        self.btn_load:setVisible(true)
        self.btn_write:setVisible(true)
        self.btn_open:setVisible(false)
        self.txt_open_desc:setVisible(false)
        --调整按钮位置
        local name_size = self.txt_title:getContentSize()
        self.btn_write:setPositionX(self.txt_title:getPositionX()+name_size.width+10)
        --使用者
        if not self.use_hero_label then
            self.use_hero_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(1, 0.5), cc.p(583, 168))
            self.main_container:addChild(self.use_hero_label)
        end
        --是否有使用者
        if data.partner_id and data.partner_id ~= 0 then
            local hero_vo = _model:getHeroById(data.partner_id)
            if hero_vo then
                self.use_hero_label:setString(_string_format(TI18N("使用者:<div fontcolor=3d5078 href=xxx>%s</div>"), hero_vo.name))
                self.use_hero_label:addTouchLinkListener(function(_type, value, sender, pos)
                    if _type == "href" then
                        _controller:openHeroTipsPanel(true, hero_vo)
                    end
                end, { "click", "href" })
            end
        else
            self.use_hero_label:setString(_string_format(TI18N("使用者:无")))
        end
        --神装
        local start_x = 75
        for i,holy_type in ipairs(HeroConst.HolyequipmentPosList) do
            local holy_item = self.equip_item_list[holy_type]
            if not holy_item then
                holy_item = BackPackItem.new(false, true, nil, 0.8, false, nil, false)
                holy_item:addCallBack(function() self:selectItemHolyByIndex(holy_type) end)
                self.main_container:addChild(holy_item)
                local empty_res = PathTool.getResFrame("hero", HeroConst.HolyEmptyIconName[holy_type])
                local empty_icon = createImage(holy_item:getRoot(), empty_res, 60, 60, cc.p(0.5,0.5), true, 10, false)
                holy_item:setPosition(cc.p(start_x + (i-1)*(BackPackItem.Width*0.8+15), 100))
                holy_item.empty_icon = empty_icon
                self.equip_item_list[holy_type] = holy_item
            else
                holy_item:setVisible(true)    
            end
            if data.equip_list and data.equip_list[holy_type] then
                local equip_vo = data.equip_list[holy_type]
                holy_item:setData(equip_vo)
                if holy_item.empty_icon then 
                    holy_item.empty_icon:setVisible(false)
                end
                holy_item.equip_vo = equip_vo
            else
                holy_item:setData()
                if holy_item.empty_icon then 
                    holy_item.empty_icon:setVisible(true)
                end
                holy_item.equip_vo = nil 
            end
        end
        --激活套装提示
        if not self.holy_effect_label then
            self.holy_effect_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(303, 28), nil, nil, 600)
            self.main_container:addChild(self.holy_effect_label)
        end
        self.holy_effect_label:setVisible(true)
        local list = _model:getHolyEquipSuitDes(data.equip_list)
        if next(list) ~= nil then
            local str = TI18N("已激活: ")
            for k,v in ipairs(list) do
                local suit_str = _string_format("<img src='%s' scale=0.8 /> %s ", v.icon_res, v.name)
                str = str..suit_str
            end
            self.holy_effect_label:setString(str)
        else
            self.holy_effect_label:setString(TI18N("暂无组合套装"))
        end
    end
end

--选中神装方案子装备打开指定面板
--@holy_type 神装类型  BackPackConst.item_type
function HolyequipmentPlanItem:selectItemHolyByIndex(holy_type)
    local partner_id = self.data.partner_id or 0
    local equip_list = self.data.equip_list or {}
    local equip_vo = equip_list[holy_type]
    if equip_vo ~= nil then
        local hero_vo = {}
        if partner_id and partner_id ~= 0 then --装备是否被穿戴
            hero_vo = _model:getHeroById(partner_id)
        end
        _controller:openEquipTips(true, equip_vo, PartnerConst.EqmTips.partner, hero_vo, self.data) 
    else
        _controller:openHeroHolyEquipClothPanel(true, holy_type, partner_id, {}, self.data, HeroConst.EnterType.eHolyPlan,nil,equip_list)
    end
end

function HolyequipmentPlanItem:DeleteMe()
    for k,v in pairs(self.equip_item_list) do
        v:DeleteMe()
        v = nil
    end
end