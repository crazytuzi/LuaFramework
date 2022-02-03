-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会宝库主界面 后端 国辉 策划 松岳
-- <br/>Create: 2019年9月4日 
GuildmarketplacePutItemWindow = GuildmarketplacePutItemWindow or BaseClass(BaseView)

local controller = GuildmarketplaceController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil

function GuildmarketplacePutItemWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildmarketplace", "guildmarketplace"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("backpack","backpack"), type = ResourcesType.plist }
    }
    self.layout_name = "guildmarketplace/guildmarketplace_put_item_window"

    self.tab_list = {}
    self.dic_item_list = {}
    self.message_label_list = {}
end

function GuildmarketplacePutItemWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildmarketplace", "guildmarketplace_bg", false)
    self.item_load_bg = loadImageTextureFromCDN(self.background, bg_res, ResourcesType.single, self.item_load_bg) 


    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    self.close_btn = self.container:getChildByName("close_btn")

    self.top_panel = self.container:getChildByName("top_panel")


    self.left_arrow = self.top_panel:getChildByName("left_arrow")
    self.right_arrow = self.top_panel:getChildByName("right_arrow")

    -- 用于点击左右按钮切换
    self.order_index_list = {
        [1] = {order = 1, index = BackPackConst.item_tab_type.EQUIPS},
        [2] = {order = 2, index = BackPackConst.item_tab_type.PROPS},
        [3] = {order = 3, index = BackPackConst.item_tab_type.HERO},
        [4] = {order = 4, index = BackPackConst.item_tab_type.SPECIAL},
        -- [5] = {order = 5, index = BackPackConst.item_tab_type.ELFIN},
        -- [6] = {order = 6, index = BackPackConst.item_tab_type.HOLYEQUIPMENT},
    }

    local tab_array = {
        {title = TI18N("装备"), index = BackPackConst.item_tab_type.EQUIPS},
        {title = TI18N("道具"), index = BackPackConst.item_tab_type.PROPS},
        {title = TI18N("碎片"), index = BackPackConst.item_tab_type.HERO},
        {title = TI18N("特殊"), index = BackPackConst.item_tab_type.SPECIAL},
        -- {title = TI18N("精灵"), index = BackPackConst.item_tab_type.ELFIN},
        -- {title = TI18N("神装"), index = BackPackConst.item_tab_type.HOLYEQUIPMENT},
    }

    self.tableContainer = self.top_panel:getChildByName("tab_container")
    local bgSize = self.tableContainer:getContentSize()
    local scroll_view_size = cc.size(bgSize.width-80, bgSize.height+5)
    local setting = {
        item_class = CommonTabBtn,      -- 单元类
        start_x = 12,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 150,               -- 单元的尺寸width
        item_height = 84,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tab_scrollview = CommonScrollViewLayout.new(self.tableContainer, cc.p(40, 3) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.tab_scrollview.scroll_view:setTouchEnabled(false)
    local tab_setting = {}
    tab_setting.default_index = self.default_index or BackPackConst.item_tab_type.PROPS
    tab_setting.tab_size = cc.size(140, 64)
    tab_setting.select_color = Config.ColorData.data_color4[1]
    tab_setting.select_outline = cc.c4b(0x6d,0x35,0x07,0xff)
    tab_setting.normal_color = cc.c4b(0xff,0xe7,0xb4,0xff)
    tab_setting.normal_outline = cc.c4b(0x6d,0x35,0x07,0xff)
    tab_setting.select_res = PathTool.getResFrame("backpack", "backpack_3")
    tab_setting.normal_res = PathTool.getResFrame("backpack", "backpack_2")
    tab_setting.img_rect = cc.rect(47, 40, 0, 0)
    tab_setting.tab_name = "tab_btn_"
    self.tab_scrollview:setData(tab_array, handler(self, self.changeTabView), nil, tab_setting)

    self.tab_scrollview:addEndCallBack(function (  )
        self.tab_list = self.tab_scrollview:getItemList()
    end)

    self.record_img = self.top_panel:getChildByName("record_img")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildmarketplace", "guildmarketplace_record_bg", false)
    self.item_load_record_bg = loadSpriteTextureFromCDN(self.record_img, bg_res, ResourcesType.single, self.item_load_record_bg)

    --看板娘node
    self.spine_node = self.top_panel:getChildByName("spine_node")
    self.spine_node:setPosition(547, -287)
    self.role_spine = createEffectSpine("E24126",cc.p(0,0),cc.p(0.5, 0.5), true, PlayerAction.action_1)
    self.spine_node:addChild(self.role_spine)

    self.lay_srollview = self.top_panel:getChildByName("lay_srollview")
    self.top_panel:getChildByName("record_title"):setString(TI18N("交易记录"))


    self.message_size = cc.size(300, 110)
    self.message_scroll_view = createScrollView(self.message_size.width, self.message_size.height, 38, -136, self.top_panel, ScrollViewDir.vertical) 
    
    self.back_bg_2 = self.top_panel:getChildByName("back_bg_2")

    
    self.Image_3 = self.container:getChildByName("Image_3")
    self.Image_3_0 = self.container:getChildByName("Image_3_0")
    self:adaptationScreen()
end

--设置适配屏幕
function GuildmarketplacePutItemWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    -- local bottom_panel_y = self.bottom_panel:getPositionY()
    -- self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)
    local Image_3_y = self.Image_3:getPositionY()
    self.Image_3:setPositionY(bottom_y + Image_3_y)
    local Image_3_0_y = self.Image_3_0:getPositionY()
    self.Image_3_0:setPositionY(bottom_y + Image_3_0_y)
    

    local back_bg_2_size = self.back_bg_2:getContentSize()
    local height = (top_y - self.container_size.height) - bottom_y
    self.back_bg_2:setContentSize(cc.size(back_bg_2_size.width, back_bg_2_size.height + height))

    local lay_srollview_size = self.lay_srollview:getContentSize()
    self.lay_srollview:setContentSize(cc.size(lay_srollview_size.width, lay_srollview_size.height + height))

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end


function GuildmarketplacePutItemWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
   
        -- 向左
    registerButtonEventListener(self.left_arrow, function (  )
        self:onClickDirBtn(1)
    end, true)

    -- 向右
    registerButtonEventListener(self.right_arrow, function (  )
        self:onClickDirBtn(2)
    end, true)

    self:addGlobalEvent(GuildmarketplaceEvent.GUILD_MARKET_PLACE_MESSAGE_EVENT2, function(message_data)
        self:updateMessageInfo(message_data)
    end)
    -- 删除一个物品更新,红点
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,del_list)
        if not self.dic_item_list then return end
        if not self.cur_index then return end 
        self.dic_item_list[self.cur_index] = nil
        self:setPanelData()
    end)

    -- 删除一个物品更新,红点
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
        if not self.dic_item_list then return end
        if not self.cur_index then return end 
        self.dic_item_list[self.cur_index] = nil
        self:setPanelData()
    end)

end

-- 关闭
function GuildmarketplacePutItemWindow:onClickCloseBtn(  )
    controller:openGuildmarketplacePutItemWindow(false)
end

-- 向左向右切换标签页
function GuildmarketplacePutItemWindow:onClickDirBtn( dir )
    if not self.tab_scrollview then return end
    local cur_order
    if dir == 1 then
        cur_order = self.cur_order - 1
        if cur_order < 1 then
            cur_order = 1
        end
    elseif dir == 2 then
        cur_order = self.cur_order + 1
        if cur_order > 6 then
            cur_order = 6
        end
    end
    if cur_order >= 4 then
        self.tab_scrollview:scrollToPercentHorizontal(100, 0.3)
    else
        self.tab_scrollview:scrollToPercentHorizontal(0, 0.3)
    end
    if self.order_index_list[cur_order] then
        local index = self.order_index_list[cur_order].order
        if self.tab_list[index] then
            self:changeTabView(self.tab_list[index])
        end
    end
end

--==============================--
--desc:切换标签页
--time:2018-06-03 10:16:37
--@index:目标标签页类型
--@return 
--==============================--
function GuildmarketplacePutItemWindow:changeTabView(tab_btn)
    if not tab_btn or tab_btn.index == self.cur_index then return end
    if self.cur_tab ~= nil then
        self.cur_tab:setBtnSelectStatus(false)
    end

    self.cur_tab = tab_btn
    self.cur_index = tab_btn.index
    self.cur_tab:setBtnSelectStatus(true)

    self.cur_order = 1
    for k,v in pairs(self.order_index_list) do
        if v.index == tab_btn.index then
            self.cur_order = v.order
            break
        end
    end
    self:setPanelData()
end


--@ 
function GuildmarketplacePutItemWindow:openRootWnd(setting)
    local setting = setting or {}
    local message_data = setting.message_data or {}
    self:updateMessageInfo(message_data)
end

function GuildmarketplacePutItemWindow:updateMessageInfo( message_data)
    if not message_data then return end
    local record_put_message = {}
    local board_list =  message_data.board_list

    local count = 1
    local max_count = 10
    for i,v in ipairs(board_list) do 
        if v.type == GuildmarketplaceConst.RewardRecordType.ePlay then ----玩家操作类型 
            for i,reward in ipairs(v.reward_list) do
                local item_config = Config.ItemData.data_get_data(reward.base_id)
                if item_config then
                    local color = BackPackConst.getWhiteQualityColorStr(item_config.quality)
                    if v.operation == 1 then --放入
                        local str = string_format(TI18N(" %s放入<div fontcolor=%s>%sx%s</div>"), v.name, color, item_config.name, reward.num)
                        -- local data = self:createLabelData(str)
                        table_insert(record_put_message, str)
                        count = count + 1
                        if count > max_count then break end
                    end
                end
            end
            if count > max_count then break end
        end
    end

    if next(record_put_message) == nil then
        commonShowEmptyIcon(self.message_scroll_view, true, {font_size = 16,scale = 0.4, offset_y = 50, text = TI18N("暂无记录信息")})
        return
    else
        commonShowEmptyIcon(self.message_scroll_view, false)
    end

    self.message_scroll_view:stopAllActions()

    for i,v in ipairs(self.message_label_list) do
        v:setPositionY(-1000)
    end

    local total_height = 0
    local place_y = 5
    self.message_scroll_view:setInnerContainerSize(cc.size(self.message_size.width, self.message_size.height))
    for i,v in ipairs(record_put_message) do
        if i <= 5 and self.message_label_list[i] then
            self.message_label_list[i]:setString(v)
            local size = self.message_label_list[i]:getContentSize()
            local old_height = total_height
            total_height = total_height + size.height + place_y
            self.message_label_list[i]:setPositionY(self.message_size.height - old_height) 
        else
            delayRun(self.message_scroll_view,  i / display.DEFAULT_FPS, function()
                if self.message_label_list[i] == nil then
                    self.message_label_list[i] = createRichLabel(18, cc.c4b(0x86,0x4f,0x35,0xff), cc.p(0,1), cc.p(0, 0), 4, nil, 300)
                    self.message_scroll_view:addChild(self.message_label_list[i])
                end
                self.message_label_list[i]:setString(v)
                local size = self.message_label_list[i]:getContentSize()
                local old_height = total_height
                total_height = total_height + size.height + place_y

                if total_height <= self.message_size.height then
                    self.message_label_list[i]:setPositionY(self.message_size.height - old_height) 
                else
                    self.message_scroll_view:setInnerContainerSize(cc.size(self.message_size.width, total_height))
                    old_height = 0 
                    for k = 1, i do
                        if self.message_label_list[k] then
                            self.message_label_list[k]:setPositionY(total_height - old_height)
                            local size = self.message_label_list[k]:getContentSize()
                            old_height = old_height + size.height + place_y
                        end
                    end
                end
            end)
        end
    end
end

function GuildmarketplacePutItemWindow:createLabelData(str)
    if self.test_lable == nil then
        self.test_lable = createRichLabel(18, cc.c4b(0x86,0x4f,0x35,0xff), cc.p(0,1), cc.p(-1000,0), 4, nil, 300)
        self.top_panel:addChild(self.test_lable)
    end
    str = str or ""
    self.test_lable:setString(str)
    local size = self.test_lable:getContentSize()
    return {str = str, height = size.height}
end

local partner_config = Config.PartnerData.data_get_compound_info
--获取英雄碎片排序  
function GuildmarketplacePutItemWindow:getHeroSorFunc()
    local function checkIsFull( data )
        local is_full = false
        if data.quality ~= -1 and data.base_id then
            if partner_config[data.base_id] then
                if data.quantity >= partner_config[data.base_id].num then
                    is_full = true
                end
            end
        end
        return is_full
    end

    local function sortFunc( objA, objB )
        if checkIsFull(objA) and not checkIsFull(objB) then
            return true
        elseif not checkIsFull(objA) and checkIsFull(objB) then
            return false
        else
            if objA.quality ~= -1 and objA.base_id and objB.quality ~= -1 and objB.base_id then
                if objA.quality == objB.quality then
                    return objA.base_id < objB.base_id
                else
                    return objA.quality > objB.quality
                end
            elseif objA.quality ~= -1 and objA.base_id and objB.quality == -1 then
                return true
            elseif objA.quality == -1 and objB.quality ~= -1 and objB.base_id then
                return false
            else
                return false
            end
        end
    end
    return sortFunc
end
--==============================--
--desc:设置当前标签页内的物品内容，这里会自动填充不够一行的物品
--time:2018-06-03 10:16:06
--@show_enter_action:
--@return 
--==============================--
function GuildmarketplacePutItemWindow:setPanelData()
    if self.cur_index == BackPackConst.item_tab_type.OTHERS then
        self.cur_index = BackPackConst.item_tab_type.EQUIPS
    end

    if self.dic_item_list[self.cur_index] == nil then
        local dic_config = Config.GuildMarketplaceData.data_dic_item_info
        local item_list = BackpackController:getInstance():getModel():getAllBackPackArray(self.cur_index, true)
        self.dic_item_list[self.cur_index] = {}
        for i,v in ipairs(item_list) do
            if dic_config[v.base_id] and dic_config[v.base_id] == 1 then
                table_insert(self.dic_item_list[self.cur_index] , v)
            end
        end
        if self.cur_index == BackPackConst.item_tab_type.EQUIPS then --装备
            sort_func = SortTools.tableUpperSorter({"quality", "sort"})
        elseif self.cur_index == BackPackConst.item_tab_type.PROPS then --道具
            sort_func = SortTools.tableUpperSorter({"quality", "sort", "base_id"})
        elseif self.cur_index == BackPackConst.item_tab_type.HERO then --英雄
            sort_func = self:getHeroSorFunc()
        elseif self.cur_index == BackPackConst.item_tab_type.SPECIAL then --特殊(目前只有符文，星级越大的放前面)
            sort_func = function ( objA, objB ) return objA.quality > objB.quality end
        elseif self.cur_index == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            -- sort_func = SortTools.tableCommonSorter({{"eqm_star", true}, {"eqm_set", false}, {"eqm_jie", true}, {"sort", true}, {"base_id", true}})
        elseif self.cur_index == BackPackConst.item_tab_type.ELFIN then --精灵
            -- sort_func = SortTools.tableUpperSorter({"quality", "sort", "base_id"})
        else 
            --执行到这里说明类型出错
            print("类型出错了:"..self.cur_index)
            return
        end
        table_sort(self.dic_item_list[self.cur_index], sort_func)
    end
    self.show_list = self.dic_item_list[self.cur_index] or {}
    self:updateItemlist()
end

--列表
function GuildmarketplacePutItemWindow:updateItemlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 124,                -- 单元的尺寸width
            item_height = 130,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.scrollview_list:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.scrollview_list:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GuildmarketplacePutItemWindow:createNewCell(width, height)
     local cell = BackPackItem.new(true, true, false, 1)
    cell:setSwallowTouches(false)
    cell:setDefaultTip()
    cell:addBtnCallBack(function() self:onCellTouched(cell) end)
    return cell
end

--获取数据数量
function GuildmarketplacePutItemWindow:numberOfCells()
    local count = #self.show_list
    if count < 20 then --最小得有20个
        count = 20
        if self.lay_srollview then
            local scrollview_size = self.lay_srollview:getContentSize()
            local num = math.floor( scrollview_size.height/130 ) 
            if num*5 >20 then
                count = num*5
            end
        end
    end
    return count
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GuildmarketplacePutItemWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if data then
        cell:setData(data)
    else
        cell:suspendAllActions()
    end
end

function GuildmarketplacePutItemWindow:onCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if data then
        if data.config.type == BackPackConst.item_type.ARTIFACTCHIPS then
            local setting = {}
            setting.is_market_place = true
            HeroController:getInstance():openArtifactTipsWindow(true, data, PartnerConst.ArtifactTips.sell,0,1,false,setting)
        else
            local config = Config.GuildMarketplaceData.data_item_info(data.base_id)
            if config then
                local limit_num = math.floor(data.quantity/config.radio) 
                if limit_num <= 0 then
                    message(TI18N("物品数量不足一组，无法放入"))
                    return
                end
                local setting = {}
                setting.goods_id = data.id
                setting.item_id = data.base_id
                setting.item_count = config.radio --单份数量
                setting.limit_num = limit_num
                if config and next(config.sell) ~= nil then
                    setting.price_item_id = config.sell[1][1] or 1
                    setting.price = config.sell[1][2] or 1
                else
                    setting.price_item_id = 1
                    setting.price = 20
                end
                controller:openGuildmarketplaceBuyItemPanel(true, setting, 2)
            end
        end
    end
end

--@setting
--setting.item_id --道具id (如果不是道具id 未支持)
--setting.name 显示的名字 如果nil 默认道具名字
--setting.shop_type 商店类型 参考 MallConst.MallType 暂时没用
--setting.limit_num 限制数量 
--setting.price 物品价格


function GuildmarketplacePutItemWindow:close_callback(  )
    
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if self.item_load_record_bg then
        self.item_load_record_bg:DeleteMe()
    end
    self.item_load_record_bg = nil

    if self.item_load_chat_bg then
        self.item_load_chat_bg:DeleteMe()
    end
    self.item_load_chat_bg = nil

    if self.item_load1 then
        self.item_load1:DeleteMe()
    end
    self.item_load1 = nil

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
    end
    self.scrollview_list = nil


    controller:openGuildmarketplacePutItemWindow(false)
end
