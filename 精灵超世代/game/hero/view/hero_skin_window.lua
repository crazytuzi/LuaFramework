-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      宝可梦查看立绘界面(废弃 日期 2019年12月6日)
-- <br/> 2018年11月15日
--
-- --------------------------------------------------------------------
HeroSkinWindow = HeroSkinWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local table_sort = table.sort
local string_format = string.format
local table_insert = table.insert

function HeroSkinWindow:__init()
    self.win_type = WinType.Full
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "hero/hero_skin_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "partnerskin"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_draw_bg", true), type = ResourcesType.single}
    }

    --能否点击头像
    self.can_click_btn = true
end

function HeroSkinWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
     self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero","hero_draw_bg",true), LOADTEXT_TYPE)
    self.background:setScale( display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 
    --宝可梦名字
    self.hero_name = self.main_container:getChildByName("hero_name_bg"):getChildByName("hero_name")
    self.hero_name:setString("")
    self.title_name = self.main_container:getChildByName("hero_name_bg"):getChildByName("title_name")
    self.title_name:setString("")
    --宝可梦立绘
    self.hero_draw_icon = self.main_container:getChildByName("hero_draw_icon")
    self.hero_draw_icon_x, self.hero_draw_icon_y = self.hero_draw_icon:getPosition()

    --底部面板
    self.bottom_panel = self.main_container:getChildByName("bottom_panel")

    --宝可梦信息面板
    self.hero_panel = self.bottom_panel:getChildByName("hero_panel")
    self.mode_node = self.hero_panel:getChildByName("model_node")
    self.hero_panel_bg = self.hero_panel:getChildByName("bg")
    self.line = self.hero_panel:getChildByName("line")
    self.name = self.hero_panel:getChildByName("name")
    self.content_scrollview = self.hero_panel:getChildByName("content_scrollview")
    self.content_scrollview:setScrollBarEnabled(false)
    -- self.content_scrollview:setTouchEnabled(false)
    self.content_scrollview_size = self.content_scrollview:getContentSize()

    self.content_text = createRichLabel(20, cc.c4b(0xff,0xf8,0xdb,0xff), cc.p(0.5, 1), cc.p(self.content_scrollview_size.width * 0.5, 0), 10, nil, 380)
    self.content_scrollview:addChild(self.content_text)

    --属性面板
    self.attr_panel = self.bottom_panel:getChildByName("attr_panel")
    local time_key = self.attr_panel:getChildByName("time_key")
    time_key:setString(TI18N("有效时间:"))
    local attr_key = self.attr_panel:getChildByName("attr_key")
    attr_key:setString(TI18N("属性加成:"))

    --时间
    self.time_val = self.attr_panel:getChildByName("time_val")
    self.attr_item_list = {}

    self.show_btn = self.bottom_panel:getChildByName("show_btn")
    self.show_btn_icon = self.show_btn:getChildByName("icon")
    self.left_btn = self.bottom_panel:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("返 回"))
    self.right_btn = self.bottom_panel:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("更 换"))

    self.lay_scrollview = self.bottom_panel:getChildByName("lay_scrollview")

    self:adaptationScreen()
end
--设置适配屏幕
function HeroSkinWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    -- local left_x = display.getLeft(self.main_container)
    -- local right_x = display.getRight(self.main_container)
    --下
    local bottom_panel_y = self.bottom_panel:getPositionY()
    local content_bottom = bottom_panel_y + bottom_y
    self.bottom_panel:setPositionY(content_bottom)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

function HeroSkinWindow:register_event()
    registerButtonEventListener(self.left_btn, function() self:onClosedBtn()  end, true, 2)
    registerButtonEventListener(self.right_btn, function() self:onClickRightBtn() end ,true, 1)

    registerButtonEventListener(self.show_btn, function() self:onClickShowBtn() end ,true, 2)
        
    self:addGlobalEvent(HeroEvent.Hero_Skin_Info_Event, function()
        if not self.select_skin_index then return end
        if not self.skin_data_list then return end
        for i,v in ipairs(self.skin_data_list) do
            if model:isUnlockHeroSkin(v.skin_id) then
                v.is_lock = false
            else
                v.is_lock = true
            end
        end
        if self.use_skin_index ~= nil then
            self:updateSkinList(self.use_skin_index)
            self.use_skin_index = nil
        else
            self:updateSkinList(self.select_skin_index)
        end
    end)

end

function HeroSkinWindow:onClosedBtn()
    controller:openHeroSkinWindow(false)
end

--确定选择当前皮肤做作为显示皮肤
function HeroSkinWindow:onClickRightBtn()
    if not self.hero_vo then return end
    if not self.skin_data_list then return end
    
    local skin_data = self.skin_data_list[self.select_skin_index]
    if skin_data and skin_data.is_skin_data then
        --换成其他皮肤
        if self.hero_vo.use_skin ~= skin_data.skin_id then
            controller:sender11019(self.hero_vo.partner_id, skin_data.skin_id)
        end
    else
        if self.hero_vo.use_skin ~= 0 then
            --换回原来皮肤
            controller:sender11019(self.hero_vo.partner_id, 0)
        end
    end
    self:onClosedBtn()
end
--显示显示
function HeroSkinWindow:onClickShowBtn()
    if not self.hero_vo then return end
    if not self.skin_data_list then return end

    if self.is_show_attr then
        self.is_show_attr = false
        self.attr_panel:setVisible(false)
        self.hero_panel:setVisible(true)
        self:updateHeroInfo(1)
        if self.show_btn_icon then
            self.show_btn_icon:setScale(-1)
        end
    else
        self.is_show_attr = true
        local skin_data = self.skin_data_list[self.select_skin_index]
        self.hero_panel:setVisible(false)
        if skin_data and skin_data.is_skin_data then
            self.attr_panel:setVisible(true)
            self:updateAttrInfo()
        else
            self.attr_panel:setVisible(false)
        end
        if self.show_btn_icon then
            self.show_btn_icon:setScale(1)
        end
    end
end

-- @bid 伙伴id
function HeroSkinWindow:openRootWnd(hero_vo)
    if not hero_vo then return end
    self.hero_vo = hero_vo 

    local bid_config = Config.PartnerSkinData.data_partner_bid_info[self.hero_vo.bid]
    if not bid_config then return end --说明没有该bid的皮肤(数据)

    -- dump(bid_config)
    local partner_config = Config.PartnerData.data_partner_base[self.hero_vo.bid]
    if partner_config then
        self.hero_name:setString(partner_config.name)
    end
    --皮肤数据
    self.skin_data_list = {}

    for skin_id,v in pairs(bid_config) do
        local data = {}
        data.is_skin_data = true -- 表示是皮肤数据
        
        if model:isUnlockHeroSkin(v.skin_id) then
            data.is_lock = false
        else
            data.is_lock = true
        end
        data.skin_id = skin_id
        data.config = Config.PartnerSkinData.data_skin_info[v.skin_id]
        --只拿第一个就可以了
        table_insert(self.skin_data_list, data)
    end
    table_sort(self.skin_data_list, function(a, b) return a.skin_id <b.skin_id end)
    --第一个肯定是本体
    table_insert(self.skin_data_list, 1, self.hero_vo)
    local select_index = 1
    local use_skin = self.hero_vo.use_skin or 0
    if use_skin ~= 0 then
        for i,v in ipairs(self.skin_data_list) do
            if v.skin_id == use_skin then
                select_index = i
            end
        end
    end
    self.is_show_attr = true
    self:updateSkinList(select_index)
end

function HeroSkinWindow:updateSkinList(select_index)
    if self.scroll_view == nil then
        local scroll_view_size = self.lay_scrollview:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 120,
            item_height = 120,
            row = 1,
            col = 1,
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
        local max_count = math.floor(scroll_view_size.width/list_setting.item_width)
        if #self.skin_data_list <= max_count then
            self.scroll_view:setClickEnabled(false)
        end
    end
    local select_index = select_index or 1
    self.scroll_view:reloadData(select_index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroSkinWindow:createNewCell(width, height)
    local cell = BackPackItem.new(true, true)
    cell:setSelfBackground(BackPackConst.quality.orange)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroSkinWindow:numberOfCells()
    if not self.skin_data_list then return 0 end
    return #self.skin_data_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroSkinWindow:updateCellByIndex(cell, index)
    cell.index = index
    local skin_data = self.skin_data_list[index]
    if not skin_data then return end
    local icon_res 

    if skin_data.is_skin_data then
        icon_res = PathTool.getHeadIcon(skin_data.config.head_id)
        cell:setItemIcon(icon_res)
        if skin_data.is_lock then
            cell:setItemIconUnEnabled(true)
        else
            cell:setItemIconUnEnabled(false)
        end
    else
        local key = getNorKey(skin_data.bid, skin_data.star)
        local star_config = Config.PartnerData.data_partner_star(key)
        if star_config then
            icon_res = PathTool.getHeadIcon(star_config.head_id)
            cell:setItemIcon(icon_res)
        end
       
        cell:setItemIconUnEnabled(false)
    end
   

    if self.select_skin_index and self.select_skin_index == index then
        cell:setSelected(true)
    else
        cell:setSelected(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroSkinWindow:onCellTouched(cell)
    if not self.can_click_btn then return end
    if not cell.index then return end
    local index = cell.index
    local skin_data = self.skin_data_list[index]
    if not skin_data then return end

    if skin_data.is_skin_data then
        if skin_data.is_lock then
            self:setLockInfo(skin_data, index)
            return
        end
    end

    if self.select_cell ~= nil then
        self.select_cell:setSelected(false)
    end

    self.select_cell = cell
    self.select_cell:setSelected(true)

    self:updateSelectSkinInfo( index)
end

--更新选中的皮肤信息
function HeroSkinWindow:updateSelectSkinInfo( index)
    if self.select_skin_index and self.select_skin_index == index then return end
    self.select_skin_index = index
    local skin_data = self.skin_data_list[self.select_skin_index]

    local name_str = ""
    --p皮肤的时候
    if skin_data.config then
        name_str = skin_data.config.skin_name
    else
        local config = Config.PartnerData.data_partner_library(skin_data.bid)
        if config then
            name_str = config.title
        end
    end
    self.title_name:setString(name_str)

    if skin_data.is_skin_data then
        --皮肤对象
        self.skin_config = skin_data.config
        if self.is_show_attr then
            self.attr_panel:setVisible(true)
            self:updateAttrInfo()
        else
            self.attr_panel:setVisible(false)
        end
    else
        --宝可梦对象
        self.skin_config = Config.PartnerData.data_partner_library(skin_data.bid)
        self.attr_panel:setVisible(false)
    end

    self:updateDrawInfo()
    if not self.is_show_attr then
        self:updateHeroInfo(2)
    end
end

function HeroSkinWindow:setLockInfo(skin_data, index)
    local dic_item_id = {}
    for i,id in ipairs(skin_data.config.item_id_list) do
        dic_item_id[id] = true
    end

    local have_item = nil
    local have_list = {}
    local list = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.BACKPACK) or {}
    for i,item in pairs(list) do
        if item.config and dic_item_id[item.config.id] then
            --背包上有道具
            local data = {}
            
            if item.config.client_effect[1] and item.config.client_effect[1][2] then
                data.time = item.config.client_effect[1][2]
            else
                data.time = 1
            end
            if data.time == 0 then
                --表示有永久的皮肤 
                have_item = item
                break
            end
            data.item_info = item
            table_insert(have_list, data)
        end
    end
    if have_item then
        --表示有永久的皮肤 
        self:useSkinItemByID(have_item, index)
        return
    end
    if #have_list > 0 then
        table.sort(have_list, function(a, b) return a.time > b.time end)
        self:useSkinItemByID(have_list[1].item_info, index)
    else
        --判断是否有活动id 有直接跳转
        if self:checkValidActionTime(skin_data.config) then
            self:gotoSkinAction(skin_data.config)
            return
        end

        --说明该皮肤不能同商城获取
        if skin_data.config.is_shop == 0 then
            message(TI18N("暂未获取此皮肤，请前往相关活动或玩法中获取！"))
        else
            self:gotoSkinAction(skin_data.config)
        end

    end
end

--使用皮肤道具
function HeroSkinWindow:useSkinItemByID(have_item, index)
    if have_item.config then
        local color = BackPackConst.getWhiteQualityColorStr(have_item.config.quality)
        local str = string_format(TI18N("已拥有解锁道具,是否消耗<div fontcolor=#%s>%s</div>解锁该皮肤？"), color, have_item.config.name)
        local callback = function()
            self.use_skin_index = index
            BackpackController:getInstance():sender10515(have_item.id, 1)
        end
        CommonAlert.show(str, TI18N("确定"), callback, TI18N("取消"),nil, CommonAlert.type.rich, nil, {title = TI18N("解锁皮肤")})
    end
end

function HeroSkinWindow:checkValidActionTime(config)
    if self.is_check_action_time ~= nil then
        return self.is_check_action_time
    end

    self.is_check_action_time = false
    if config and config.action_bid ~= 0 then
        local start_time = 0
        local end_time = 0
        if next(config.action_start_time) ~= nil and next(config.action_end_time) ~= nil then
            local year  = config.action_start_time[1] or 0
            local month = config.action_start_time[2] or 0
            local day   = config.action_start_time[3] or 0
            local hour  = config.action_start_time[4] or 0
            local min   = config.action_start_time[5] or 0
            local sec   = config.action_start_time[6] or 0
            start_time  =  os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}
            year  = config.action_end_time[1] or 0
            month = config.action_end_time[2] or 0
            day   = config.action_end_time[3] or 0
            hour  = config.action_end_time[4] or 0
            min   = config.action_end_time[5] or 0
            sec   = config.action_end_time[6] or 0
            end_time  =  os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}
        end

        if start_time ~= 0 and end_time ~= 0 then
            local cur_time = GameNet:getInstance():getTime()
            if cur_time >= start_time and cur_time <= end_time then
                self.is_check_action_time = true
            end
        else
            self.is_check_action_time = true
        end

        if self.is_check_action_time then
            --是否存在 活动
            self.is_check_action_time = ActionController:getInstance():CheckActionExistByActionBid(config.action_bid)
        end
    end
    return self.is_check_action_time
end

--跳转活动id
function HeroSkinWindow:gotoSkinAction(config)
    local callback = function()
        --优先找皮肤活动
        if self:checkValidActionTime(config) then
            ActionController:getInstance():openActionMainPanel(true, nil, config.action_bid)
            return
        end

        --没有皮肤活动 找活动商城
        local shop_config = Config.ExchangeData.data_shop_list[MallConst.MallType.HeroSkin]
        if shop_config and shop_config.sort ~= 0 then
            MallController:getInstance():openMallPanel(true, MallConst.MallType.HeroSkin)
            return
        end

        --没有活动商城 提示:
        message(TI18N("暂无该皮肤获取途径"))
    end
    
    local str = TI18N("当前暂未拥有该皮肤,是否前往获取？")
    CommonAlert.show(str, TI18N("确定"), callback, TI18N("取消"),nil, nil, nil, {title = TI18N("解锁皮肤")}) 
end

--更新立绘信息
function HeroSkinWindow:updateDrawInfo()
    if not self.skin_config then return end

    local draw_res_id = self.skin_config.draw_res
    if draw_res_id == nil or draw_res_id == "" then
        draw_res_id = self:getDefaultDrawRes()
    end
    if draw_res_id then
        local bg_res = PathTool.getPlistImgForDownLoad("herodraw/herodrawres",draw_res_id, false)
        if self.hero_draw_icon then
            self.item_load = loadSpriteTextureFromCDN(self.hero_draw_icon, bg_res, ResourcesType.single, self.item_load) 
        end
        if self.skin_config.scale == 0 then
            self.hero_draw_icon:setScale(1)
        else
            self.hero_draw_icon:setScale(self.skin_config.scale/100)
        end

        if self.skin_config.draw_offset and next(self.skin_config.draw_offset) ~= nil then
            local x, y = self.hero_draw_icon:getPosition()
            local offset_x = self.skin_config.draw_offset[1][1] or 0
            local offset_y = self.skin_config.draw_offset[1][2] or 0
            self.hero_draw_icon:setPosition(self.hero_draw_icon_x + offset_x, self.hero_draw_icon_y + offset_y) 
        end
    end
end

--显示属性
function HeroSkinWindow:updateAttrInfo()
    if not self.skin_config then return end

    local end_time = model:getHeroSkinInfoBySkinID(self.skin_config.skin_id)
    if end_time then
        if end_time == 0 then
            self.time_val:setString(TI18N("永久"))
            doStopAllActions(self.time_val)
        else
            local time = end_time - GameNet:getInstance():getTime()
            if time <= 0 then 
                self.time_val:setString(TI18N("00:00:00"))    
            else
                commonCountDownTime(self.time_val, time)
            end
        end
    end
    local y = 27
    local width_item = 150
    local offset_x = 10
    local size = cc.size(width_item, 35)

    for i,v in ipairs(self.attr_item_list) do
        v.bg:setVisible(false)
        v.key_label:setVisible(false)
    end

    for i,v in ipairs(self.skin_config.skin_attr) do
        local x = 200 + (i - 1) * (width_item + offset_x)
        if self.attr_item_list[i] == nil then
            self.attr_item_list[i] = self:createAttrItem(x, y, size)
        else
            self.attr_item_list[i].bg:setVisible(true)
            self.attr_item_list[i].key_label:setVisible(true)
        end

        local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
        local attr_str = string.format("<img src='%s' scale=1 /> %s + %s", res, attr_name, attr_val)
        self.attr_item_list[i].key_label:setString(attr_str)
    end
end

--创建属性item
function HeroSkinWindow:createAttrItem(x, y, size)
    local item = {}
    -- local size = cc.size(260, 35)
    local res = PathTool.getResFrame("hero","partner_skin_03")
    item.bg = createImage(self.attr_panel, res, x,y, cc.p(0, 0.5), true, 0, true)
    item.bg:setContentSize(size)
    -- item.bg:setOpacity(128)
    item.bg:setCapInsets(cc.rect(15, 15, 1, 1))
    item.key_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(x + 10  , y), nil, nil, 380)
    self.attr_panel:addChild(item.key_label, 2)
    return item
end

--更新宝可梦信息
--来源位置 1 表示 按show_btn 的   2 表示 按皮肤头像的
function HeroSkinWindow:updateHeroInfo(form_type)
    local skin_data = self.skin_data_list[self.select_skin_index]
    local hero_config
    local skin_id = 0
    local hero_vo = self.skin_data_list[1]
    if skin_data.is_skin_data then
        hero_config = Config.PartnerSkinData.data_hero_info(skin_data.skin_id)
        skin_id = skin_data.config.skin_id
    end
    self:updateSpine(hero_vo, skin_id, form_type)
        
    --说明有传记
    if hero_config then
        self.line:setVisible(true)
        self.name:setVisible(true)
        self.content_scrollview:setVisible(true)
        self.hero_panel_bg:setContentSize(cc.size(712, 237))

        self.name:setString(self.skin_config.skin_name)
        self.content_text:setString(hero_config.content)
        local size = self.content_text:getContentSize()
        if size.height < self.content_scrollview_size.height then
            self.content_scrollview:setTouchEnabled(false)
        end
        local scroll_heigt = math.max(self.content_scrollview_size.height, size.height) 
        self.content_scrollview:setInnerContainerSize(cc.size(self.content_scrollview_size.width, scroll_heigt))
        self.content_text:setPositionY(scroll_heigt - 5)
    else
        self.line:setVisible(false)
        self.name:setVisible(false)
        self.content_scrollview:setVisible(false)
        self.hero_panel_bg:setContentSize(cc.size(285, 237))
    end
end

--更新模型,也是初始化模型
--@is_refresh  是否需要检测
function HeroSkinWindow:updateSpine(hero_vo, skin_id, form_type)
    if self.record_skin_id and self.record_skin_id == skin_id then
        return
    end
    self.record_skin_id = skin_id

    local fun = function()    
        if not self.spine then 
            self.spine = BaseRole.new(BaseRole.type.partner, hero_vo, nil, {scale = 0.45, skin_id = skin_id})
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(0,104))
            self.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            -- self.spine:setScale(1)
            self.mode_node:addChild(self.spine) 
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            self.spine:showShadowUI(true)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        self.can_click_btn = false
        self.spine:setCascade(true)
        if form_type == 2 then
            local action = cc.FadeOut:create(0.2)
            self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                    doStopAllActions(self.spine)
                    self.spine:removeFromParent()
                    self.spine = nil
                    self.can_click_btn = true
                    fun()
            end)))
        else
            -- form_type == 1 表示是show_btn的 不需要隐藏后再显示..而是直接删除显示
            doStopAllActions(self.spine)
            self.spine:removeFromParent()
            self.spine = nil
            self.can_click_btn = true
            fun()
        end
    else
        fun()
    end
end


--获取缺省的模型id
function HeroSkinWindow:getDefaultModeRes()
    local partner_config, star_config = self:getPartnerConfig()
    if partner_config and star_config then
        return star_config.res_id
    end
end

--获取缺省的模型立绘
function HeroSkinWindow:getDefaultDrawRes()
    local partner_config, star_config = self:getPartnerConfig()
    if partner_config then
        return partner_config.draw_res
    end
end

--获取宝可梦对应配置
function HeroSkinWindow:getPartnerConfig()
    if not self.hero_vo then return end
    if self.partner_config == nil then
        self.partner_config = Config.PartnerData.data_partner_base[self.hero_vo.bid]
    end
    if self.partner_config and self.star_config == nil then
        local key = getNorKey(self.partner_config.bid, self.partner_config.init_star)
        self.star_config = Config.PartnerData.data_partner_star(key)
    end
    return self.partner_config, self.star_config
end

function HeroSkinWindow:close_callback()

    doStopAllActions(self.time_val)
    
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    controller:openHeroSkinWindow(false)
end
