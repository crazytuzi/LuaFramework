-- --------------------------------------------------------------------
-- 竖版商城
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      商城主页面
-- <br/>Create: 2019年4月30日
-- --------------------------------------------------------------------
MallWindow2 = MallWindow2 or BaseClass(BaseView)

local controller = MallController:getInstance()
local table_insert = table.insert
local table_sort = table.sort

function MallWindow2:__init()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/mall_window_2"       	
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("mall","mall"), type = ResourcesType.plist },
    }
    --开启条件信息字段
    self.open_key_list = {
        [MallConst.MallType.GodShop]        =  "open_gold_lev", --道具商店
        [MallConst.MallType.Recovery]       =  "open_hero_soul_lev", --神格商店
        [MallConst.MallType.ScoreShop]      =  "open_point_lev", --积分商店
        [MallConst.MallType.SkillShop]      =  "open_skill_lev", --技能商店
    }
    self.tab_array = {}
    --商店类型 对应 索引
    self.dicShopTypeIndex = {}
    self.dicSecondMenuIndex = {}
    local config_list = Config.ExchangeData.data_shop_list
    if config_list then
        for k,config in pairs(config_list) do
            if config.sort > 0 then
                local is_show = true
                if config.id == MallConst.MallType.HeroSkin then
                    --策划要求英雄皮肤开启不达到开启条件不显示
                    for i,v in ipairs(config.limit) do
                        if v[1] == "lev" then
                            local role_vo = RoleController:getInstance():getRoleVo()
                            if role_vo and role_vo.lev < v[2] then
                                is_show = false        
                            end
                        end
                    end
                end
                if is_show then
                    local data = {}
                    data.config = config
                    data.shop_type = config.id
                    data.index = config.sort
                    data.status = true
                    data.subtype = config.subtype
                    data.can_touch = self:checkBtnIsOpen(data.shop_type)
                    local cost_config = Config.ExchangeData.data_shop_exchage_cost[self.open_key_list[data.shop_type]]
                    if cost_config then
                        data.notice = string.format(TI18N("%s级开启"), cost_config.val)
                    else
                        data.notice = TI18N("暂未解锁")
                    end
                    table_insert(self.tab_array, data)
                end
            end
        end
        table_sort( self.tab_array, function(a, b) return a.index < b.index end)
    end

    for i,v in ipairs(self.tab_array) do
        if #v.subtype > 0 then
            for _, second_shop_type in ipairs(v.subtype) do
                self.dicSecondMenuIndex[second_shop_type] = i
            end
        end
        self.dicShopTypeIndex[v.shop_type] = i
    end

    self.tab_list = {}
    self.cur_tab = nil
    --当前选中的商店索引
    self.cur_index = nil
    --当前选中的商店类型
    self.cur_shop_type = nil
    self.data_list = {}
end

function MallWindow2:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1) 

    self.main_panel = self.mainContainer:getChildByName("main_panel")

    self.tableContainer = self.main_panel:getChildByName("tab_container")

    self.container = self.main_panel:getChildByName("container")

    self.btn = self.container:getChildByName("btn")
    self.btn_label = createRichLabel(24,1,cc.p(0.5,0.5),cc.p(self.btn:getContentSize().width/2,self.btn:getContentSize().height/2))
    self.btn_label:setString(TI18N("刷新"))
    self.btn:addChild(self.btn_label)
    self.btn:setVisible(false)
    self.coin = self.container:getChildByName("coin")
    self.count = self.container:getChildByName("count")
    self.add_btn = self.container:getChildByName("add_btn")
    self.add_btn:setVisible(false)

    self.tips_btn = self.container:getChildByName('tips_btn')
    self.tips_btn:setVisible(false)
    self.time = createRichLabel(22,58,cc.p(0,0.5),cc.p(480,self.count:getPositionY() + 15))
    self.container:addChild(self.time)
    self.time:setVisible(false)
    self.time_down_text = createRichLabel(22,58,cc.p(0,0.5),cc.p(480,self.count:getPositionY()-15))
    self.container:addChild(self.time_down_text)
    self.time_down_text:setVisible(false)
    self.scrollCon = self.container:getChildByName("scrollCon")

    self.good_cons = self.container:getChildByName("good_cons")
 
    self.winTitle = self.main_panel:getChildByName("win_title")
    self.winTitle:setString(TI18N("商城"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
end


function MallWindow2:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openMallPanel(false) end ,true, 2)

    if self.add_btn then 
        self.add_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local item_bid = Config.ExchangeData.data_shop_list[self.cur_shop_type].item_bid
                local data = Config.ItemData.data_get_data(item_bid)
                BackpackController:getInstance():openTipsSource( true,data )
            end
        end)
    end

    registerButtonEventListener(self.btn, function()
        if self.cur_shop_type == MallConst.MallType.Recovery then
            local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["soul_reset_cost"]
            local bid,num
            if asset_cfg then
                bid = asset_cfg.val[1][1]
                num = asset_cfg.val[1][2]
            end
            if bid and num then
                local str = string.format(TI18N("是否消耗<img src=%s scale=0.3 visible=true /><div>%s</div>进行重置？"),PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
                local function fun()
                    controller:sender13405(self.cur_shop_type)
                end
                CommonAlert.show(str,TI18N("确认"),fun,TI18N("取消"),nil,CommonAlert.type.rich)
            end
        elseif self.cur_shop_type == MallConst.MallType.SkillShop then
            controller:sender13405(MallConst.MallType.SkillShop) 
        end
    end,true, 1)

    --获取商品已购买次数(限于购买过的有限购的商品)
    if not self.update_have_count then
        self.update_have_count = GlobalEvent:getInstance():Bind(MallEvent.Open_View_Event,function ( data )
            if not data then return end
            --目前只有道具商店用这个协议
            local list = self:initGodShopData(data.type, data)
            if list ~= nil then
                data.item_list = list
                self.data_list[data.type] = data
                if self.cur_shop_type == data.type then
                    self:updateDataList()
                end
            end
        end)
    end

    --获取神秘商店物品列表
    if not self.update_list then
        self.update_list = GlobalEvent:getInstance():Bind(MallEvent.Get_Buy_list,function ( data )
            if not data then return end
            self.data_list[data.type] = data
            for i,v in ipairs(data.item_list) do
                v.shop_type = data.type
            end
            if data.type == self.cur_shop_type then
                self:setResetCount(data)
                if self.cur_shop_type == MallConst.MallType.SkillShop then
                    self:setLessTime(self.data_list[self.cur_shop_type].refresh_time - GameNet:getInstance():getTime())
                end
                self:updateDataList()
            end
        end)
    end

    if self.role_vo then
        if self.role_update_lev_event == nil then
            self.role_update_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
                if key == "lev" then
                    --等级发生改变
                    for i,v in ipairs(self.tab_array) do
                        v.can_touch = self:checkBtnIsOpen(v.id)
                    end
                    if self.tab_btn_list_view then
                        self.tab_btn_list_view:resetCurrentItems()
                    end
                else
                    local config = Config.ExchangeData.data_shop_list[self.cur_shop_type]
                    if config then
                        local item_bid = config.item_bid
                        if Config.ItemData.data_assets_id2label[item_bid] == key then
                            self.count:setString(MoneyTool.GetMoneyString(self.role_vo[Config.ItemData.data_assets_id2label[item_bid]]))
                        end
                       
                    end
                end
            end)
        end
    end

    --到时候刷新了--旧的东西确定后端不退了
    -- if self.refresh_event == nil then 
    --     self.refresh_event = GlobalEvent:getInstance():Bind(MallEvent.Frash_tips_event,function (  )
    --         if self.cur_shop_type == MallConst.MallType.SkillShop or self.cur_shop_type == MallConst.MallType.Recovery then
    --             controller:sender13403(self.cur_shop_type)
    --         end
    --     end)
    -- end

    registerButtonEventListener(self.tips_btn, function() self:onClickTips(self.tips_btn) end ,true, 2)
   

    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_list)
       if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            if self.cur_shop_type == MallConst.MallType.SkillShop then
                local item_bid = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop].item_bid
                for i,item in pairs(temp_list) do
                    if item.base_id == item_bid then
                        self:updateIconInfo(item_bid)
                        break
                    end
                end
            end
        end
    end)

    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_list)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            if self.cur_shop_type == MallConst.MallType.SkillShop then
                local item_bid = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop].item_bid
                for i,item in pairs(temp_list) do
                    if item.base_id == item_bid then
                        self:updateIconInfo(item_bid)
                        break
                    end
                end
            end
        end
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            if self.cur_shop_type == MallConst.MallType.SkillShop then
                local item_bid = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop].item_bid
                for i,item in pairs(temp_list) do
                    if item.base_id == item_bid then
                        self:updateIconInfo(item_bid)
                        break
                    end
                end
            end
        end
    end)
end

function MallWindow2:onClickTips(sender)
    local str = ""
    if self.cur_shop_type == MallConst.MallType.Recovery then
        if Config.ExchangeData.data_shop_exchage_cost["hero_soul_instruction"] and Config.ExchangeData.data_shop_exchage_cost["hero_soul_instruction"].desc then
            str = Config.ExchangeData.data_shop_exchage_cost["hero_soul_instruction"].desc
        end
    elseif self.cur_shop_type == MallConst.MallType.SkillShop then
        if Config.ExchangeData.data_shop_exchage_cost['secret_instruction'] and Config.ExchangeData.data_shop_exchage_cost['secret_instruction'].desc then
            str = Config.ExchangeData.data_shop_exchage_cost['secret_instruction'].desc
        end
    end
    TipsManager:getInstance():showCommonTips(str,sender:getTouchBeganPosition())
end


--页签滚动列表
function MallWindow2:updateTabBtnList(index)
    if not self.tab_array then return end

    if not self.tab_btn_list_view then
        local size = self.tableContainer:getContentSize()
        local count = self:numberOfCellsTabBtn()
        local item_width = 125
        local item_height = 100
        local position_data_list 
        if count <= 4  then
            position_data_list = {}
            local s_x = 5 --(size.width - count * item_width) * 0.5
            local y = item_height * 0.5
            for i=1,count do
                local x = s_x + item_width * 0.5 + (i -1) * item_width
                position_data_list[i] = cc.p(x, y)
            end
        end
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = item_width,               -- 单元的尺寸width
            item_height = item_height,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            -- col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }


        self.tab_btn_list_view = CommonScrollViewSingleLayout.new(self.tableContainer, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))

        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.createNewCellTabBtn), ScrollViewFuncType.CreateNewCell) --创建cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsTabBtn), ScrollViewFuncType.NumberOfCells) --获取数量
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexTabBtn), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedTabBtn), ScrollViewFuncType.OnCellTouched) --更新cell

        if count <= 4  then
            self.tab_btn_list_view:setClickEnabled(false)
        end
    end
    local index = index or 1
    self.tab_btn_list_view:reloadData(index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function MallWindow2:createNewCellTabBtn(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/mall_tab_btn_2"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(cc.p(0.5, 0.5))
    cell:setContentSize(cc.size(width, height))
    cell.tab_btn = cell.root_wnd:getChildByName("tab_btn")
    cell.normal_img = cell.tab_btn:getChildByName("unselect_bg")
    cell.select_img = cell.tab_btn:getChildByName("select_bg")
    cell.select_img:setVisible(false)
    -- cell.setOntouch
    cell.tab_btn:setSwallowTouches(false)
    cell.label = cell.tab_btn:getChildByName("title")
    cell.label:setTextColor(cc.c4b(0xcf,0xb5,0x93,0xff))

    --红点. 暂时没有红点 先隐藏
    cell.red_point = cell.tab_btn:getChildByName("tab_tips")
    cell.red_num = cell.tab_btn:getChildByName("red_num")
    cell.red_point:setVisible(false)
    cell.red_num:setVisible(false)

    registerButtonEventListener(cell.tab_btn, function() self:onCellTouchedTabBtn(cell) end, false, 2, nil, nil, nil, true)
    -- --回收用
    -- cell.DeleteMe = function() 
    -- end
    return cell
end

--获取数据数量
function MallWindow2:numberOfCellsTabBtn()
    if not self.tab_array then return 0 end
    return #self.tab_array
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function MallWindow2:updateCellByIndexTabBtn(cell, index)
    cell.index = index
    local tab_data = self.tab_array[index]
    if tab_data then
        cell.label:setString(tab_data.config.name)
        if self.cur_index == index then
            cell.select_img:setVisible(true)
        else
            cell.select_img:setVisible(false)
        end

        --先不处理.都是1级开启的 省点
        -- if tab_data.can_touch then
        --     cell.label:enableOutline(cc.c4b(0x2a, 0x16, 0x0e, 0xff), 2)
        --     setChildUnEnabled(false, cell.tab_btn)
        -- else 
        --     cell.label:disableEffect(cc.LabelEffect.OUTLINE)
        --     setChildUnEnabled(true, cell.tab_btn)
        -- end
    end
end

--index :数据的索引
function MallWindow2:onCellTouchedTabBtn(cell)
    local index = cell.index
    local tab_data = self.tab_array[index]
    if tab_data then
        --点击需要判断
        if tab_data.can_touch then
            self:changeTabView(index, true)
        else
            message(TI18N(tab_data.notice))
        end
    end
end

function MallWindow2:changeTabView(index, check_repeat_click)
    if not index then return end
    if check_repeat_click and self.cur_index == index then return end
    local tab_data = self.tab_array[index]
    if not tab_data then return end

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xcf,0xb5,0x93,0xff))
        end
        self.cur_tab.select_img:setVisible(false)
    end

    self.cur_index = index
    self.cur_shop_type = tab_data.shop_type

    self.cur_tab =  self.tab_btn_list_view:getCellByIndex(self.cur_index)

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xff,0xed,0xd6,0xff))
        end
        self.cur_tab.select_img:setVisible(true)
    end

    self.tips_btn:setVisible(false)
    self.time:setVisible(false)
    self.time_down_text:setVisible(false)
    self.add_btn:setVisible(false)

    --是否有 子标签
    if #tab_data.config.subtype > 0 then
        local subtype = tab_data.config.subtype
        if not self.son_panel then
            self.son_panel = MallSonPanel.new()
            self.container:addChild(self.son_panel)
        else
            self.son_panel:setVisibleStatus(true)
        end
        self.son_panel:setList(subtype)
        if self.init_shop_type then
            self.son_panel:openById(self.init_shop_type)
            self.init_shop_type = nil
        else
            self.son_panel:openById(subtype[1])    
        end
        self.scrollCon:setVisible(false)
        self.good_cons:setVisible(false)
        self.btn:setVisible(false)
        self.coin:setVisible(false)
        self.count:setVisible(false)
    else
        self.scrollCon:setVisible(true)
        self.good_cons:setVisible(true)
        self.coin:setVisible(true)
        self.count:setVisible(true)

        
        if self.cur_shop_type == MallConst.MallType.Recovery then
            --神格商店 
            if not self.data_list[self.cur_shop_type] then
                controller:sender13403(self.cur_shop_type)
            else
                self:setResetCount(self.data_list[self.cur_shop_type])
            end
            self.btn:setVisible(true)
            self.tips_btn:setVisible(true)
        elseif self.cur_shop_type == MallConst.MallType.SkillShop then
            --技能商店 
            if not self.data_list[self.cur_shop_type] then
                controller:sender13403(self.cur_shop_type)
            else
                local time = self.data_list[self.cur_shop_type].refresh_time - GameNet:getInstance():getTime()
                if time > 0 then
                    self:setLessTime(time)
                else
                    self:setTimeFormatString(0)
                    controller:sender13403(MallConst.MallType.SkillShop)
                end
                self:setResetCount(self.data_list[self.cur_shop_type])
            end

            self.btn:setVisible(true)
        else
            -- self.cur_shop_type == MallConst.MallType.GodShop 
            -- self.cur_shop_type == MallConst.MallType.HeroSkin
            --道具商店 皮肤商店 (属于没有刷新需求的一类)
            if not self.data_list[self.cur_shop_type] then
                controller:sender13401(self.cur_shop_type)
            end

            self.btn:setVisible(false)
        end

        if self.data_list[self.cur_shop_type] then
            self:updateDataList()
        end

        local item_bid = tab_data.config.item_bid
        if self.record_item_bid == nil or self.record_item_bid ~= item_bid then
            self.record_item_bid = item_bid
            loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(item_bid).icon), LOADTEXT_TYPE)
        end
        self:updateIconInfo(item_bid)

        if self.son_panel then
            self.son_panel:setVisibleStatus(false)
        end
    end
end


function MallWindow2:openRootWnd(shop_type,sub_index)
    controller:setFirstLogin(false)

	local shop_type = shop_type or MallConst.MallType.GodShop
    local index = self.dicShopTypeIndex[shop_type]
    if index == nil then
        --一级菜单没有 找二级菜单的
        index = self.dicSecondMenuIndex[shop_type]
        if index == nil then
            index = 1
        else
            self.init_shop_type = shop_type --二级菜单的时候需要
        end
    end

    self:updateTabBtnList(index)
end

function MallWindow2:updateDataList()
    if not self.cur_shop_type then return end
    if not self.data_list[self.cur_shop_type] then return end

    if not self.item_scrollview then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 1,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 4,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = 306,               -- 单元的尺寸width
            item_height = 143,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 2,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.good_cons, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0,0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.show_list = self.data_list[self.cur_shop_type].item_list
    self.item_scrollview:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.good_cons, true, {font_size = 22,scale = 1})
    else
        commonShowEmptyIcon(self.good_cons, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function MallWindow2:createNewCell(width, height)
    local cell = MallItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

--获取数据数量
function MallWindow2:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function MallWindow2:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    cell:setData(cell_data)
end

--点击cell .需要在 createNewCell 设置点击事件
function MallWindow2:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    if cell_data then
        -- self:selectHero(cell, cell_data)
        if cell_data.has_buy == nil then
            if cell_data.ext and cell_data.ext[1] then
                cell_data.has_buy = cell_data.ext[1].val
            else
                cell_data.has_buy = 0
            end
        end

        cell_data.shop_type = self.cur_shop_type
        controller:openMallBuyWindow(true, cell_data)
    end
end


--判断是否开启按钮
function MallWindow2:checkBtnIsOpen(_type)
    if not self.role_vo then return false end
    local cost_config = Config.ExchangeData.data_shop_exchage_cost[self.open_key_list[_type]]

    if cost_config then
        --目前四个商城都跟角色等级 判定开启条件的..不用额外判断 直接写了
        if self.role_vo.lev >= cost_config.val then
            return true
        end
    else
        --没有配置默认开启
        return true
    end
    return false
end



--设置倒计时
function MallWindow2:setLessTime( less_time )
    if tolua.isnull(self.time) then return end
    self.time:setVisible(true)
    self.time:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.time:stopAllActions()
                if self.cur_index == 4 then
                    controller:sender13403(MallConst.MallType.SkillShop)
                end
            else
                self:setTimeFormatString(less_time)
            end
        end)
        )))
    else
        self:setTimeFormatString(less_time)
    end
end

function MallWindow2:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time:setString(string.format(TI18N("免费刷新: <div fontcolor=#249003>%s</div>"),TimeTool.GetTimeFormat(time)))
    else
        self.time:setString("免费刷新: <div fontcolor=#249003>00:00:00</div>")
    end
end



function MallWindow2:updateIconInfo(item_bid)
    if not item_bid then return end
    self.count:setString(MoneyTool.GetMoneyString(BackpackController:getInstance():getModel():getItemNumByBid(item_bid)))
end

function MallWindow2:setResetCount(data)
    if not data then return end
    local free_count = data.free_count or 0
    local btn_str = TI18N("免费刷新")
    if self.cur_shop_type == MallConst.MallType.Recovery then --神格
        if free_count <= 0 then
            local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["soul_reset_cost"]
            if asset_cfg then
                local bid = asset_cfg.val[1][1]
                local num = asset_cfg.val[1][2]
                btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#6c2b00>%s重置</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
            end
        end
    elseif self.cur_shop_type == MallConst.MallType.SkillShop then --技能
        if free_count <= 0 then
            local  config = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop]
            if config then
                local cost_list = config.cost_list
                local bid = cost_list[1][1]
                local num = cost_list[1][2]
                btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#6c2b00>%s刷新</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
            end
        else
            local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["skill_refresh_free"] 
            if asset_cfg then
                btn_str = string.format("<div outline=2,#6c2b00>%s(%s/%s)</div>", TI18N("免费刷新"), free_count, asset_cfg.val)
            end
        end
        self.time_down_text:setVisible(true)
        local config = Config.ExchangeData.data_shop_exchage_cost.skill_refresh_number
        local max_count = 0 
        if config then
            max_count = config.val
        end
        local count = data.count or 0
        local text = string.format("%s:%s/%s", TI18N("刷新次数"), count, max_count)
        self.time_down_text:setString(text)
    end
    self.btn_label:setString(btn_str)
    self.btn:setContentSize(cc.size(self.btn_label:getContentSize().width+25,self.btn:getContentSize().height))
    self.btn_label:setPositionX(self.btn:getContentSize().width*0.5)
end

--初始化道具商店列表
function MallWindow2:initGodShopData(shop_type, data)
	local config_list 

    if shop_type == MallConst.MallType.GodShop then
        config_list = Config.ExchangeData.data_shop_exchage_gold
    elseif shop_type == MallConst.MallType.HeroSkin then
        config_list = Config.ExchangeData.data_shop_exchage_skin
    else
        return nil
    end

	local list = {}
    local dic_buys = {}
    for i,v in ipairs(data.item_list) do
        if v.ext[1] and v.ext[1].val then
            dic_buys[v.item_id] = v.ext[1].val
        else
            dic_buys[v.item_id] = 0
        end
    end

    for k,config in pairs(config_list) do
        local data = deepCopy(config)
        if dic_buys[config.id] then
            data.has_buy = dic_buys[config.id]
        else
            data.has_buy = 0
        end
        table_insert(list, data)
    end
    table.sort( list, function(a, b) return a.order < b.order end )
	return list
end

function MallWindow2:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    
    if self.son_panel then
        self.son_panel:DeleteMe()
    end

    if self.update_have_count then 
        GlobalEvent:getInstance():UnBind(self.update_have_count)
        self.update_have_count = nil
    end

    if self.update_list then 
        GlobalEvent:getInstance():UnBind(self.update_list)
        self.update_list = nil
    end

    if self.role_vo then
        if self.role_update_lev_event then
            self.role_vo:UnBind(self.role_update_lev_event)
            self.role_update_lev_event = nil
        end
        self.role_vo = nil
    end

    if self.refresh_event then 
        GlobalEvent:getInstance():UnBind(self.refresh_event)
        self.refresh_event = nil
    end

    if self.buy_success_event then 
        GlobalEvent:getInstance():UnBind(self.buy_success_event)
        self.buy_success_event = nil
    end

    if self.buy_success_shenmi then 
        GlobalEvent:getInstance():UnBind(self.buy_success_shenmi)
        self.buy_success_shenmi = nil
    end

    controller:openMallPanel(false)
end