-- --------------------------------------------------------------------
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @description:
--      碎片分解
-- <br/>Create: 2019-11-2
--
-- --------------------------------------------------------------------
HeroChipsBreakWindow = HeroChipsBreakWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local partner_config = Config.PartnerData.data_get_compound_info

function HeroChipsBreakWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_reset_chip_window"
    -- self.res_list = {
    --     { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_reset_bg", true), type = ResourcesType.single },
    --     { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_return_bg", true), type = ResourcesType.single },
    --     { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_hero_convert_bg", true), type = ResourcesType.single }
    -- }


    --献祭界面选中的对象列表 [key] =  value 模式
    self.select_count = 0

    --策划写死最多10个
    self.select_max_count = 15
    --当前碎片数量
    self.cur_chip_count = 0
    --策划要求 7星以上不能分解 (策划要求暂时取消)
    -- self.limit_star = 7
    self.setting = {y = -14}
end

function HeroChipsBreakWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel , 2)  
    
    self.disband_container = self.main_panel:getChildByName("disband_container")
    

    self.spine_node = self.disband_container:getChildByName("spine_node")

    self.tip_btn = self.disband_container:getChildByName("tip_btn")
    self.partner_btn = self.disband_container:getChildByName("partner_btn")

    --献祭
    self.disband_btn = self.disband_container:getChildByName("disband_btn")
    self.disband_btn_lable = self.disband_btn:getChildByName("label")
    self.disband_btn_lable:setString(TI18N("分解"))
    -- self.disband_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[264], 2)
    --self.title_img = self.disband_container:getChildByName("title_img")
    self.disband_container:getChildByName("label"):setString(TI18N("碎片分解"))

    self.item_bg_1 = self.disband_container:getChildByName("item_bg_1")
    self.max_btn = self.item_bg_1:getChildByName("max_btn")
    --self.max_btn_label = self.max_btn:getChildByName("label")
    --self.max_btn_label:setString(TI18N("max")) --应该有语言变化

    self.add_btn = self.item_bg_1:getChildByName("add_btn")
    self.add_btn_label = self.add_btn:getChildByName("label")
    self.redu_btn = self.item_bg_1:getChildByName("redu_btn")
    --self.redu_btn_label = self.redu_btn:getChildByName("label")
    self.resolve_count = self.item_bg_1:getChildByName("resolve_count")

    
    --拥有宝可梦数量
    self.lab_have_count = self.disband_container:getChildByName("lab_have_count")
    self.lab_have_count:setString(TI18N("选择一种碎片后，请再选择数量"))


    local camp_node = self.disband_container:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[HeroConst.CampType.eWater] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[HeroConst.CampType.eFire]  = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[HeroConst.CampType.eWind]  = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[HeroConst.CampType.eLight] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[HeroConst.CampType.eDark]  = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

    

    -- self.fuse_btn_label = createRichLabel(22,cc.c3b(36, 144, 3), cc.p(0, 0.5),cc.p(3, 75), nil, nil, 720)
    -- self.fuse_btn_label:setString(string_format("<div fontcolor=#ffffff>%s</div><div href=xxx>%s</div> ", TI18N("该碎片满足召唤宝可梦所需,是否"), TI18N("召唤宝可梦->")))
    -- self.item_bg_1:addChild(self.fuse_btn_label)
    -- self.fuse_btn_label:setVisible(false)
    -- self.fuse_btn_label:addTouchLinkListener(function(type, value, sender, pos)
    --     -- HeroController:getInstance():openHeroUpgradeStarFuseWindow(true, self.hero_vo)
    -- end, { "click", "href" })

    --特效


    --添加可编辑的输入文本
    local res = PathTool.getResFrame("common","common_99998")
    local edit_content = createEditBox(self.item_bg_1, res,cc.size(90,50), nil, 22, nil, 22, "", nil, nil, LOADTEXT_TYPE_PLIST)
    self.edit_content = edit_content
    edit_content:setAnchorPoint(cc.p(0.5,0.5))
    edit_content:setPlaceholderFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setFontColor(cc.c4b(0xff,0xf6,0xe4,0xff))
    edit_content:setPosition(cc.p(114, 27))

    local begin_change_label = false
    local function editBoxTextEventHandle(strEventName,pSender)
        if strEventName == "return" or strEventName == "ended" then
            if begin_change_label then  
                begin_change_label = false
                self.resolve_count:setVisible(true)
                local str = pSender:getText()
                pSender:setText("")  
                if str ~= "" then
                    local num = tonumber(str)
                    if num ~= nil and num > 0 then
                        self:showEditNum(num)
                    else
                        self:showEditNum(0)
                        message(TI18N("请输入数字"))
                    end
                else
                    self:showEditNum(0)
                end 

            end
        elseif strEventName == "began" then
            if not begin_change_label then
                self.resolve_count:setVisible(false)
                begin_change_label = true
            end
        elseif strEventName == "changed" then

        end
    end
    edit_content:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function HeroChipsBreakWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 2)

    registerButtonEventListener(self.tip_btn, function(param,sender, event_type) 
        local config = Config.PartnerData.data_partner_const.game_rule1
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end ,true, 1)
    registerButtonEventListener(self.partner_btn, function() MallController:getInstance():openMallPanel(true,MallConst.MallType.Recovery) end ,true, 2)


    registerButtonEventListener(self.disband_btn, handler(self, self._onClickBtnDisband) ,true, 1)

    registerButtonEventListener(self.max_btn, handler(self, self.onClickBtnMax) ,true, 1)
    registerButtonEventListener(self.add_btn, handler(self, self.onClickBtnAdd) ,true, 1)
    registerButtonEventListener(self.redu_btn, handler(self, self.onClickBtnRedu) ,true, 1)

      --阵营按钮
    for select_camp, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:onClickBtnShowByIndex(select_camp) end ,true, 2)
    end


    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function()
        self.select_count = 0
        self:updateHeroList(self.select_camp, true)
        self.is_send_proto = false
    end)

        -- 增加物品的更新,这里需要判断增加的物品是不是当前标签页类型的,否则不刷新了
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, add_list)
        if bag_code ~= BackPackConst.Bag_Code.BACKPACK then
            return 
        end
        local need_update = false
        for k, item in pairs(add_list) do
            if item.config and item.config.sub_type == BackPackConst.item_tab_type.HERO then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:onClickBtnShowByIndex(self.select_camp, true)
            self.is_send_proto = false
        end
    end)

    -- 删除一个物品更新,也需要判断当前标签页类型
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
        if bag_code ~= BackPackConst.Bag_Code.BACKPACK then
            return 
        end
        if del_list == nil or next(del_list) == nil then return end
        local need_update = false
        for k, item in pairs(del_list) do
            if item.config and item.config.sub_type == BackPackConst.item_tab_type.HERO then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:onClickBtnShowByIndex(self.select_camp, true)
            self.is_send_proto = false
        end
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,change_list)
        if bag_code ~= BackPackConst.Bag_Code.BACKPACK then
            return 
        end
        if change_list == nil or next(change_list) == nil then return end
        local need_update = false
        for k, item in pairs(change_list) do
            if item.config and item.config.sub_type == BackPackConst.item_tab_type.HERO then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:onClickBtnShowByIndex(self.select_camp, true)
            self.is_send_proto = false
        end
    end)

end

function HeroChipsBreakWindow:_onClickBtnClose()
    controller:openBreakChipWindow(false)

end

--最大
function HeroChipsBreakWindow:onClickBtnMax()
    if not self.select_chip_data then return end
    self.cur_chip_count = self.select_chip_data.quantity
    self:updateLabelNum(self.cur_chip_count)
end
--加
function HeroChipsBreakWindow:onClickBtnAdd()
    if not self.select_chip_data then return end
    self.cur_chip_count = self.cur_chip_count + 1
    if self.cur_chip_count > self.select_chip_data.quantity then
        self.cur_chip_count = self.select_chip_data.quantity
    end
    self:updateLabelNum(self.cur_chip_count)
end
--减
function HeroChipsBreakWindow:onClickBtnRedu()
    if not self.select_chip_data then return end
    self.cur_chip_count = self.cur_chip_count - 1
    if self.cur_chip_count < 0 then
        self.cur_chip_count = 0
    end
    self:updateLabelNum(self.cur_chip_count)
end

function HeroChipsBreakWindow:updateLabelNum(count)
    if not self.select_chip_data then 
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(true)  
        self:setTouchEnable_Max(true) 
        self.resolve_count:setString(0)
        self.edit_content:setVisible(false)
        return 
    end
    self:setTouchEnable_Max(false)
    self.edit_content:setVisible(true)
    if count == 0 then
        self:setTouchEnable_Redu(true)
        self:setTouchEnable_Add(false)
    elseif count == self.select_chip_data.quantity then
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(true)
    else
        self:setTouchEnable_Redu(false)
        self:setTouchEnable_Add(false)
    end
    self.resolve_count:setString(count)
end

function HeroChipsBreakWindow:showEditNum(count)
    if not self.select_chip_data then return end
    self.cur_chip_count = count
    if self.cur_chip_count > self.select_chip_data.quantity then
        self.cur_chip_count = self.select_chip_data.quantity
    elseif self.cur_chip_count < 0 then
        self.cur_chip_count = 0
    end
    self:updateLabelNum(self.cur_chip_count)
end


function HeroChipsBreakWindow:setTouchEnable_Add(bool)
    setChildUnEnabled(bool,self.add_btn)
    self.add_btn:setTouchEnabled(not bool)
    --if bool then
    --    self.add_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    --else
    --    self.add_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    --end
end
function HeroChipsBreakWindow:setTouchEnable_Redu(bool)
    setChildUnEnabled(bool,self.redu_btn)
    self.redu_btn:setTouchEnabled(not bool)
    --if bool then
    --    self.redu_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    --else
    --    self.redu_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    --end
end

function HeroChipsBreakWindow:setTouchEnable_Max(bool)
    setChildUnEnabled(bool,self.max_btn)
    self.max_btn:setTouchEnabled(not bool)
    --if bool then
    --    self.max_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    --else
    --    self.max_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    --end
end

--献祭
function HeroChipsBreakWindow:_onClickBtnDisband()
    if self.is_send_proto then return end
    self:disbandChip()

end

--碎片分解
function HeroChipsBreakWindow:disbandChip( )
    if not self.select_chip_data then 
        message(TI18N("没有选中宝可梦碎片"))
        return 
    end
    local config  = self.select_chip_data.config
    local count = self.cur_chip_count or 0
    if count == 0 then
        message(TI18N("没有放入宝可梦碎片"))
        return
    end
    local is_show_tip = self.select_chip_data.sort_order == 1
    local item_list = {}
    for i,v in ipairs(config.value) do
        local id = v[1]
        local num = v[2] or 0
        num = num * count
        if id ~= nil then
            table_insert(item_list, {id = id, num = num})
        end
    end
    local sell_data = {}
    table_insert(sell_data, {id = self.select_chip_data.id, bid = self.select_chip_data.base_id, num = count})
    if #item_list > 0 then
        local color = BackPackConst.getWhiteQualityColorStr(self.select_chip_data.quality)
        local str = string_format(TI18N("本次分解 <div fontcolor=#289b14>%s</div> 个<div fontcolor=%s>【%s】</div>可获得以下资源:"), count, color,config.name)
        controller:openHeroResetOfferPanel(true, item_list, is_show_tip, function()
                self.is_send_proto = true
                delayRun(self.disband_container, 0, function()
                    BackpackController:getInstance():sender10522(BackPackConst.Bag_Code.BACKPACK, sell_data)
                end)
        end, HeroConst.ResetType.eChipReset, str)
    end

end

--显示根据类型 0表示全部
function HeroChipsBreakWindow:onClickBtnShowByIndex(select_camp, reset)
    if self.img_select and self.camp_btn_list[select_camp] then
        local x, y = self.camp_btn_list[select_camp]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    --把已选中的去掉
    self.select_count = 0
    self:updateHeroList(select_camp, reset)

end

function HeroChipsBreakWindow:openRootWnd()
    self.is_send_proto = nil
    self.item_bg_1:setVisible(true)
    self.select_chip_data = nil
    self:onClickBtnShowByIndex(0, true)
    self:updateLabelNum(0)
end


--获取碎片信息
function HeroChipsBreakWindow:getChipListByCamp(select_camp)
    --碎片获取以后优化
    local hero_chip_list = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.HERO) or {}
    local show_list = {}
    local cur_select_chip_data = nil
    for i,v in ipairs(hero_chip_list) do
        local config = v.config
        if config and (select_camp == 0 or select_camp == config.lev) then
            local data = {}
            data.id = v.id
            data.bid = 0 
            data.base_id = config.id
            data.star = config.eqm_jie --星级
            data.camp_type = config.lev --阵营
            data.icon = config.icon --图片
            data.quantity = v.quantity
            data.quality = v.quality
            data.config = config
            local status = BackpackController:getInstance():getModel():checkHeroChipRedPoint(v)
            if status then --可以合成
                data.sort_order = 1
            else
                data.sort_order = 0
            end
            if v.quantity > 0 then
                table_insert(show_list, data)
            end
            --查找已经选中
            if self.select_chip_data and self.select_chip_data.id == data.id then
                cur_select_chip_data = data
            end
        end
    end

    local sort_func = SortTools.tableCommonSorter({{"sort_order", true}, {"quality", true}, {"base_id", false}})
    table_sort(show_list, sort_func)
    return show_list, cur_select_chip_data
end

--创建宝可梦列表 
-- @select_camp 选中阵营
function HeroChipsBreakWindow:updateHeroList(select_camp, reset)
    local select_camp = select_camp or 0
    if not reset and select_camp == self.select_camp then 
        return
    end

    if not self.list_view then
        local scroll_view_size = cc.size(640,330)
        self.hero_setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 128,               -- 单元的尺寸width
            item_height = 122,              -- 单元的尺寸height
            delay = 1,
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }

        local img_box_0 = self.disband_container:getChildByName("img_box_0")
        local x, y = img_box_0:getPosition()
        self.list_view = CommonScrollViewSingleLayout.new(self.disband_container, cc.p(x, y) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, self.hero_setting, cc.p(0.5,0.5))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.select_camp = select_camp
    --碎片献祭
    self.show_list , cur_select_chip_data = self:getChipListByCamp(select_camp)
    
    if cur_select_chip_data == nil then
        self.select_chip_data = nil     
        self.list_view:reloadData(nil, {item_height = 140})
    else
        self.select_chip_data = cur_select_chip_data
        self.list_view:resetCurrentItems()
    end
    self.cur_chip_count = 1
    self:updateLabelNum(1)
    --end
    
    local count = #self.show_list

    
    if count == 0 then
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)
    end 
end
--显示空白
function HeroChipsBreakWindow:showEmptyIcon(bool)
    if not self.empty_con and bool == false then
        return
    end
    
    if not self.empty_con then
        local img_box_0 = self.disband_container:getChildByName("img_box_0")
        local x, y = img_box_0:getPosition()

        local size = cc.size(200, 200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5, 0.5))
        self.empty_con:setPosition(x, y)

        self.disband_container:addChild(self.empty_con, 10)
        local res = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3')
        local bg = createImage(self.empty_con, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), false)
        
        local login_data = LoginController:getInstance():getModel():getLoginData()
        local str
        self.empty_label = createLabel(26, Config.ColorData.data_color4[175], nil, size.width / 2, -10, '', self.empty_con, 0, cc.p(0.5, 0)) 
    end

    self.empty_label:setString(TI18N("暂无该类型宝可梦"))
    self.empty_con:setVisible(bool)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroChipsBreakWindow:createNewCell(width, height)
    local height = 122 --高度写死
    local cell = ccui.Widget:create()
    local hero_item = HeroExhibitionItem.new(0.9, true)
    hero_item:setPosition(width * 0.5 , height * 0.5)
    cell:addChild(hero_item)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell.hero_item = hero_item

    cell.hero_item:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroChipsBreakWindow:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroChipsBreakWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    if hero_vo then
        cell.hero_item:setData(hero_vo)
        if self.select_chip_data and self.select_chip_data.base_id == hero_vo.base_id then
            cell.hero_item:setSelected(true)
        else
            cell.hero_item:setSelected(false)
        end
        cell.hero_item:showLockIcon(false)
        --碎片献祭
        cell.hero_item:setPositionY(70)
        local config = partner_config[hero_vo.base_id] or {}
        local need_count = config.num or 50
        local total_count = hero_vo.quantity or 0
        local label = string_format("%s/%s", total_count, need_count)
        cell.hero_item:showProgressbarStatus(true, total_count * 100/ need_count, label, self.setting)
        cell.hero_item:showChipIcon(true)
        cell.hero_item:setDefaultHead(hero_vo.icon)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroChipsBreakWindow:onCellTouched(cell)
    --if self.is_send_proto then return end
    local index = cell.index
    local hero_vo = self.show_list[index]
    if hero_vo then
        self:selectChip(cell, hero_vo)
    end
end

--选择碎片
function HeroChipsBreakWindow:selectChip(cell, hero_vo)
    if not hero_vo  then return end
    if not cell then return end

    --由于延迟发送的原因.导致刷新会出现选中异常..这里保证所有的选中都被移除
    local list = self.list_view:getActiveCellList()
    for i,v in ipairs(list) do
        v.hero_item:setSelected(false)
    end

    if self.select_chip_data and self.select_chip_data == hero_vo then
        self.select_chip_data = nil
       
    else
        self.select_chip_data = hero_vo
        self.select_chip_cell = cell
        if self.select_chip_cell then
            self.select_chip_cell.hero_item:setSelected(true)
        end
    end
    self.cur_chip_count = 1
    self:updateLabelNum(self.cur_chip_count)
    
end

function HeroChipsBreakWindow:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    --清空选中状态
    local hero_list = model:getHeroList()
    for k, hero_vo in pairs(hero_list) do
        hero_vo.is_ui_select = nil
    end
    doStopAllActions(self.disband_container)
    controller:openBreakChipWindow(false)
end