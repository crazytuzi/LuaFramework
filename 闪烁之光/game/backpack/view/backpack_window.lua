-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      新背包界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BackPackWindow = BackPackWindow or BaseClass(BaseView)

local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local controller = BackpackController:getInstance()
local model = BackpackController:getInstance():getModel()
local partner_config = Config.PartnerData.data_get_compound_info
function BackPackWindow:__init(sub_type)
    self.is_full_screen = true
    self.layout_name = "backpack/backpack_window"
    self.cur_index = nil
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("backpack","backpack"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_3"), type = ResourcesType.single},
    }
    self.item_render_list   = {}                    -- 当前待创建的物品数据
    self.tab_list           = {}                    -- 当前用于储存标签列表

    self.default_index = sub_type or BackPackConst.item_tab_type.PROPS
    self.min_size           = 30                    -- 背包初始化30个
    self.col_size           = 5
end

function BackPackWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_2",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer, 1)
    self.titleImage = self.mainContainer:getChildByName("title_img")
    self.container = self.mainContainer:getChildByName("container")

    local image_1 = self.container:getChildByName("Image_1_0") --加花纹
    if image_1 then
        local res = PathTool.getPlistImgForDownLoad("bigbg","pattern/pattern_3")
        if res ~= nil then
            local pattern_1 = createSprite(res,image_1:getContentSize().width/2, 55, image_1, cc.p(0.5,0.5),LOADTEXT_TYPE)
            pattern_1:setScaleY(1.5)
        end
    end

    self.quick_sell_btn = self.container:getChildByName("quick_sell_btn")
    self.quick_sell_btn:getChildByName("label"):setString(TI18N("一键出售"))

    self.left_arrow = self.container:getChildByName("left_arrow")
    self.right_arrow = self.container:getChildByName("right_arrow")

    -- 用于点击左右按钮切换
    self.order_index_list = {
        [1] = {order = 1, index = BackPackConst.item_tab_type.EQUIPS},
        [2] = {order = 2, index = BackPackConst.item_tab_type.PROPS},
        [3] = {order = 3, index = BackPackConst.item_tab_type.HERO},
        [4] = {order = 4, index = BackPackConst.item_tab_type.SPECIAL},
        [5] = {order = 5, index = BackPackConst.item_tab_type.ELFIN},
        [6] = {order = 6, index = BackPackConst.item_tab_type.HOLYEQUIPMENT},
    }

    local tab_array = {
        {title = TI18N("装备"), index = BackPackConst.item_tab_type.EQUIPS},
        {title = TI18N("道具"), index = BackPackConst.item_tab_type.PROPS},
        {title = TI18N("碎片"), index = BackPackConst.item_tab_type.HERO},
        {title = TI18N("特殊"), index = BackPackConst.item_tab_type.SPECIAL},
        {title = TI18N("精灵"), index = BackPackConst.item_tab_type.ELFIN},
        {title = TI18N("神装"), index = BackPackConst.item_tab_type.HOLYEQUIPMENT},
    }

    self.tableContainer = self.container:getChildByName("tab_container")
    local bgSize = self.tableContainer:getContentSize()
    local scroll_view_size = cc.size(bgSize.width-80, bgSize.height+5)
    local setting = {
        item_class = CommonTabBtn,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 128,               -- 单元的尺寸width
        item_height = 84,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tab_scrollview = CommonScrollViewLayout.new(self.tableContainer, cc.p(40, 3) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    local tab_setting = {}
    tab_setting.default_index = self.default_index or BackPackConst.item_tab_type.PROPS
    tab_setting.tab_size = cc.size(128, 64)
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
        self:isCompRedPoint()
    end)

    local scroll_view_size = cc.size(620,600)
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 4,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 5,                        -- 行数，作用于水平滚动类型
        col = 5,                         -- 列数，作用于垂直滚动类型
        once_num = 5,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.container, cc.p(54, 85), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    
    -- 引导中不给滑动列表
    if GuideController:getInstance():isInGuide() then
        self.item_scrollview:setClickEnabled(false)
        self.tab_scrollview:setClickEnabled(false)
    end

    self:createTitleEffect()
end

function BackPackWindow:createTitleEffect()
    if MAKELIFEBETTER == true then return end
    if self.title_effect then return end
	self.title_effect = createEffectSpine(PathTool.getEffectRes(640), cc.p(-122, -6), cc.p(0, 0), true)
    self.titleImage:addChild(self.title_effect)
end 

function BackPackWindow:register_event()
    -- 一键出售
    registerButtonEventListener(self.quick_sell_btn, function()
        if self.cur_index == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
            controller:openQuickSellHolyWindow(true)
        elseif self.cur_index == BackPackConst.item_tab_type.EQUIPS then    --装备
            controller:openQuickSellEquipWindow(true)
        elseif self.cur_index == BackPackConst.item_tab_type.HERO then    --英雄碎片
            HeroController:getInstance():openBreakChipWindow(true)
        end
    end, true)

    -- 向左
    registerButtonEventListener(self.left_arrow, function (  )
        self:onClickDirBtn(1)
    end, true)

    -- 向右
    registerButtonEventListener(self.right_arrow, function (  )
        self:onClickDirBtn(2)
    end, true)
    

    -- 初始化或者断线重连的时候会跑出这个更新事件的
    self:addGlobalEvent(BackpackEvent.GET_ALL_DATA, function(bag_code)
        if not self:checkCodeToType(bag_code) then return end
        self:setPanelData(false)
    end)

    -- 增加物品的更新,这里需要判断增加的物品是不是当前标签页类型的,否则不刷新了
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, add_list)
        if not self:checkCodeToType(bag_code) then return end
        if add_list == nil or next(add_list) == nil then return end
        local need_update = false
        for k, item in pairs(add_list) do
            if item.config and item.config.sub_type == self.cur_index then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:setPanelData(false)
        end
    end)

    -- 删除一个物品更新,也需要判断当前标签页类型
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,del_list)
        if not self:checkCodeToType(bag_code) then return end
        if del_list == nil or next(del_list) == nil then return end
        local need_update = false
        for k, item in pairs(del_list) do
            if item.config and item.config.sub_type == self.cur_index then
                need_update = true
                break
            end
        end
        if need_update == true then
            self:setPanelData(false)
        end
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,change_list)
        if self.cur_index == 3 then
            self:isCompRedPoint()
        end
    end)

    self:addGlobalEvent(BackpackEvent.Compose_BackPack_Success, function()
        self:isCompRedPoint()
        self:setPanelData()
    end)

    -- 引导中不给滑动列表
    self:addGlobalEvent(GuideEvent.Update_Guide_Status_Event, function ( in_guide )
        if in_guide then
            self.item_scrollview:setClickEnabled(false)
        else
            self.item_scrollview:setClickEnabled(true)
        end
    end)
end

--==============================--
--desc:打开窗体的入口，这里有指定的标签页
--time:2018-06-03 10:17:36
--@type:
--@return 
--==============================--
function BackPackWindow:openRootWnd()
    --[[type = type or BackPackConst.item_tab_type.PROPS
    self:isCompRedPoint()
    self:changeTabView(type)--]]
end

--判断碎片是否显示红点
function BackPackWindow:isCompRedPoint()
    local item_list = model:getAllBackPackArray(3)
    local status = false
    for i,v in pairs(item_list) do
        if v.quality ~= -1 and v.base_id then
            if partner_config[v.base_id] then
                if v.quantity >= partner_config[v.base_id].num then
                    status = true
                    break
                end
            end
            --神器的时候
            local hallow_list = BackpackController:getModel():getHallowsCompData(v.base_id)
            if hallow_list and next(hallow_list) ~= nil then
                if v.quantity >= hallow_list.num then
                    status = true
                    break
                end
            end
        end
    end

    if self.tab_list[3] then
        self.tab_list[3]:setRedStatus(status) --仅碎片需要红点显示
    end
    -- MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, true)
end

--==============================--
--desc:装备标签页的红点状态
--==============================--
function BackPackWindow:setEquipRedStatus(status)
    -- if status == nil then
    --     status = model:checkEquipsIsFull()
    -- end
    -- if self.equip_status == status then return end
    -- self.equip_status = status
    -- local equip_tab = self.tab_list[BackPackConst.item_tab_type.EQUIPS]
    -- if equip_tab and equip_tab.red_point then
    --     equip_tab.red_point:setVisible(status)
    --     if status == true then
    --         breatheShineAction(equip_tab.red_point)
    --     else
    --         doStopAllActions(equip_tab.red_point)
    --     end
    -- end
end

-- 向左向右切换标签页
function BackPackWindow:onClickDirBtn( dir )
    if not self.cur_order then return end
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
function BackPackWindow:changeTabView(tab_btn)
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

    self:setPanelData(true)
end

--==============================--
--desc:设置当前标签页内的物品内容，这里会自动填充不够一行的物品
--time:2018-06-03 10:16:06
--@show_enter_action:
--@return 
--==============================--
function BackPackWindow:setPanelData()
    if self.cur_index == BackPackConst.item_tab_type.OTHERS then
        self.cur_index = BackPackConst.item_tab_type.EQUIPS
    end

    local item_list = model:getAllBackPackArray(self.cur_index, true)
    self.min_size = tableLen(item_list)
    --背包最小显示数量 写死30
    if self.min_size <= 30 then
        self.min_size = 30
    end

    local min_size = self.min_size
    local item_sum = #item_list
    if item_sum < min_size then
        --补全 剩下 
        for i=1,min_size-item_sum do
            table_insert(item_list, {sort = -1,quality = -1, gemstone_sort = -1, eqm_star = -1, eqm_jie = -1})
        end
    else
        local lacking = 0
        if item_sum % self.col_size ~= 0 then
            lacking = self.col_size - (item_sum % self.col_size)
        end
        if lacking ~= 0 then
            for i=1,lacking do --补全不足一行的
                table_insert(item_list, {sort = -1,quality = -1, gemstone_sort = -1, eqm_star = -1, eqm_jie = -1})
            end
        end
    end

    local show_quick_sell = false --一键出售按钮是否显示
    local sort_func = nil
    if self.cur_index == BackPackConst.item_tab_type.EQUIPS then --装备
        local role_vo = RoleController:getInstance():getRoleVo() --装备一键出售等级限制条件
        local open_lev = Config.PackageData.data_backpack_cost.open_lev
        if open_lev and role_vo.lev >= open_lev.val then
            show_quick_sell = true
        end
        sort_func = SortTools.tableUpperSorter({"quality", "sort"})
    elseif self.cur_index == BackPackConst.item_tab_type.PROPS then --道具
        sort_func = SortTools.tableUpperSorter({"quality", "sort", "base_id"})
    elseif self.cur_index == BackPackConst.item_tab_type.HERO then --英雄
        sort_func = self:getHeroSorFunc()
        show_quick_sell = true
        --英雄碎片需要取消红点
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.backpack, false)
    elseif self.cur_index == BackPackConst.item_tab_type.SPECIAL then --特殊(目前只有符文，星级越大的放前面)
        sort_func = function ( objA, objB ) return objA.quality > objB.quality end
    elseif self.cur_index == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        show_quick_sell = true 
        sort_func = SortTools.tableCommonSorter({{"eqm_star", true},  {"eqm_jie", true}, {"eqm_set", false}, {"sort", true}, {"base_id", true}})
    elseif self.cur_index == BackPackConst.item_tab_type.ELFIN then --精灵
        sort_func = SortTools.tableUpperSorter({"quality", "sort", "base_id"})
    else 
        --执行到这里说明类型出错
        --print("类型出错了:"..self.cur_index)
        return
    end
    
    table_sort(item_list,sort_func)
    
    local ext = {showCheckBox = true, red_point = true, show_use_target = true, is_other = false}
    if self.cur_index == BackPackConst.item_tab_type.HERO then
        --英雄碎片特殊 显示行距加大
        self.item_scrollview:setSpace(30, true)
        ext.is_comp_num = true
    else
        self.item_scrollview:setSpace(10)
        ext.is_comp_num = false
    end

    local function callback(cell, force)
        self:selectedItem(cell)
    end
    self.item_scrollview:setData(item_list, callback, nil, ext)

    -- 一键出售按钮
    self.quick_sell_btn:setVisible(show_quick_sell)
    if self.cur_index == BackPackConst.item_tab_type.HERO then
        self.quick_sell_btn:getChildByName("label"):setString(TI18N("碎片分解"))
    else
        self.quick_sell_btn:getChildByName("label"):setString(TI18N("一键出售"))
    end

end

--获取英雄碎片排序  
function BackPackWindow:getHeroSorFunc()
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
--desc:点击一个背包物品的返回，这里需要显示对应类型的物品tips
--time:2018-06-03 10:15:22
--@cell:
--@force:
--@return 
--==============================--
function BackPackWindow:selectedItem(cell, force)
    if cell and cell:getData() then 
        local vo = cell:getData()
        if vo == nil or vo.config == nil or vo.config.type == nil then return end
        --是装备的话，弹装备tips
        if BackPackConst.checkIsEquip(vo.config.type) then 
            HeroController:getInstance():openEquipTips(true,vo,PartnerConst.EqmTips.backpack)
        elseif BackPackConst.checkIsHeroSkin(vo.config.type) then
            HeroController:getInstance():openHeroSkinTipsPanel(true, vo, PartnerConst.EqmTips.backpack)
        elseif vo.config.type == BackPackConst.item_type.ARTIFACTCHIPS then
            HeroController:getInstance():openArtifactTipsWindow(true, vo, PartnerConst.ArtifactTips.backpack)
        elseif vo.sub_type == 3 then --英雄碎片
            TipsManager:getInstance():showBackPackCompTips(true,vo.base_id)
        elseif BackPackConst.checkIsElfin(vo.config.type) then -- 精灵
            TipsManager:getInstance():showElfinTips(vo.config.id, true) 
        else
            TipsManager:getInstance():showGoodsTips(vo,true) 
        end
    end
end

--==============================--
--desc:关闭窗体时，释放掉的事件等
--time:2018-06-03 10:14:56
--@return 
--==============================--
function BackPackWindow:close_callback()
    controller:openMainView(false, self.cur_index)
    TipsManager:getInstance():showCompChooseTips(false)
    if self.tab_scrollview then
        self.tab_scrollview:DeleteMe()
        self.tab_scrollview = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

--==============================--
--desc:判断当前更新的物品所属的标签页是否是当前的
--time:2018-06-03 10:14:17
--@bag_code:背包类型
--@return 
--==============================--
function BackPackWindow:checkCodeToType(bag_code)
    if self.cur_index == nil then return false end

    if self.cur_index == BackPackConst.item_tab_type.EQUIPS or
       self.cur_index == BackPackConst.item_tab_type.HOLYEQUIPMENT then
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then return false end
    else
        if bag_code == BackPackConst.Bag_Code.EQUIPS then return false end
    end
    return true
end
