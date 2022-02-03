-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄分解 英雄碎片分解信息界面
-- <br/>Create: 2018年11月12日
--
-- --------------------------------------------------------------------
HeroResetOfferPanel = HeroResetOfferPanel or BaseClass(BaseView)

local table_insert = table.insert
local controller = HeroController:getInstance()
local model = controller:getModel()

function HeroResetOfferPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_reset_offer_panel"
end 

function HeroResetOfferPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 2)  
    self.win_title = container:getChildByName("win_title")

    self.dec_val = createRichLabel(24, cc.c4b(0x68, 0x45, 0x2a, 0xff), cc.p(0, 1), cc.p(50,491),12,nil,580)
   
    container:addChild(self.dec_val)
    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("取 消"))
    self.cancel_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("献 祭"))
    self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
    self.list_view = container:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 16,                  -- 第一个单元的X起点
        space_x = 32,                    -- x方向的间隔
        start_y = 6,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 4,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        once_num = 4,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.list_view, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting)

    self.close_btn = container:getChildByName("close_btn")
    self.container = container
end

function HeroResetOfferPanel:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openHeroResetOfferPanel(false) end ,true, 1)
    -- registerButtonEventListener(self.background, function() controller:openHeroResetOfferPanel(false) end ,false, 1)

    registerButtonEventListener(self.cancel_btn, function() controller:openHeroResetOfferPanel(false) end ,true, 2)
    registerButtonEventListener(self.confirm_btn, function() self:onConfirmButton() end ,true, 2)

    -- 
    self:addGlobalEvent(HeroEvent.Hero_Reset_Look_Event, function(data)
        if not data then return end
        self:setData(data.list)
    end)
    -- 
    self:addGlobalEvent(HeroEvent.Hero_Sell_Holy_Equipment_Res_Event, function(data)
        if not data then return end
        self:setData(data.list)
    end)
end

function HeroResetOfferPanel:onConfirmButton()
    controller:openHeroResetOfferPanel(false)

    if self.reset_type == HeroConst.ResetType.eHeroReset then
        self:onHeroComfirm()
    elseif self.reset_type == HeroConst.ResetType.eChipReset then
        self:onChipComfirm()
    elseif self.reset_type == HeroConst.ResetType.eHolyEquipSell then
        self:onHolyEquipComfirm()
    elseif self.reset_type == HeroConst.ResetType.eTenStarChang then
        self:onTenStarChangeComfirm()
    elseif self.reset_type == HeroConst.ResetType.eActionHeroReset or self.reset_type == HeroConst.ResetType.eHeroReturn or self.reset_type == HeroConst.ResetType.eSpriteReturn then
        if self.callback then
            self.callback()
        end  
    elseif self.reset_type == HeroConst.ResetType.eFunriture then
        self:onFurnitureComfirm()
    end
end

function HeroResetOfferPanel:onTenStarChangeComfirm()
    if self.callback then
        self.callback()
    end  
end
--分解英雄确定
function HeroResetOfferPanel:onHeroComfirm()
    if self.is_show_tips then
        local str = TI18N("本次献祭含有5星或以上英雄，是否确认献祭？")
        CommonAlert.show( str, TI18N("确定"), function()
            if self.callback then
                self.callback()
            end    
        end, TI18N("取消"),nil,nil,nil,{timer=10, timer_for=true, off_y = 10, title = TI18N("英雄献祭"), extend_aligment = cc.TEXT_ALIGNMENT_CENTER })
    else
        
        if self.callback then
            self.callback()
        end    
    end
end
--分解碎片确定
function HeroResetOfferPanel:onChipComfirm()
    if self.is_show_tips then
        local str = TI18N("本次献祭的碎片满足召唤英雄要求，献祭后可能会失去召唤的机会，是否继续？")

        local other_args = {}

        other_args.timer = 5
        other_args.timer_for = true
        other_args.off_y = 10
        other_args.title = TI18N("碎片献祭")
        --额外添加的数据
        other_args.extend_aligment = cc.TEXT_ALIGNMENT_CENTER
        --other_args.extend_str = TI18N("<div fontcolor=#249003 href=xxx>前往召唤英雄</div>")
        other_args.extend_size = 22
        other_args.extend_offy = -58
        other_args.extend_type = CommonAlert.type.rich

        local alert = CommonAlert.show( str, TI18N("确定"), function()
            if self.callback then
                self.callback()
            end    
        end, TI18N("取消"),nil,CommonAlert.type.common,nil,other_args)
        if alert.extend_txt then
            alert.extend_txt:addTouchLinkListener(function(type, value, sender, pos)
                BackpackController:getInstance():openMainView(true, BackPackConst.item_tab_type.HERO)
                alert:close()
            end, { "click", "href" })
        end
    else
        
        if self.callback then
            self.callback()
        end    
    end
end

--神装出售
function HeroResetOfferPanel:onHolyEquipComfirm()
    if self.callback then
        self.callback()
    end  
end

-- 家具出售
function HeroResetOfferPanel:onFurnitureComfirm(  )
    if self.callback then
        self.callback()
    end 
end

--@hero_list --类型不同有不同的数据  
--@reset_type --分解类型 1 英雄分解 2 碎片分解  3神装分解 4 10星置换 参考 HeroConst.ResetType
--dec 碎片分解的描述
function HeroResetOfferPanel:openRootWnd(hero_list, is_show_tips, callback, reset_type, dec)
    if not hero_list then return end
    self.is_show_tips = is_show_tips
    self.reset_type = reset_type or HeroConst.ResetType.eHeroReset
    if reset_type == HeroConst.ResetType.eHeroReset then
        --英雄分解
        local  str = TI18N("献祭英雄可获得材料，若英雄有进行升级、进阶、升星培养，也会100%返还所消耗的进阶石、金币和英雄经验。本次献祭所得如下：")
        self.dec_val:setString(str)
        self.win_title:setString(TI18N("英雄献祭"))
        controller:sender11075(hero_list)   
    elseif reset_type == HeroConst.ResetType.eTenStarChang then
        --10星置换
        local str = TI18N("参与置换的5星英雄，若有进行升级培养，会100%返还培养材料（金币、英雄经验、进阶石）及身上装备与符文。本次置换返还所得如下：")
        self.dec_val:setString(str)
        self.win_title:setString(TI18N("英雄置换"))
         self.confirm_btn_label:setString(TI18N("置 换"))
        self:setData(hero_list)
    elseif reset_type == HeroConst.ResetType.eActionHeroReset then
        --活动英雄重生
        local str = TI18N("英雄重生可获得材料，若有进行升级培养，会100%返还培养材料（金币、英雄经验、进阶石）及身上装备与符文。本次置换返还所得如下：")
        local config =  Config.PartnerData.data_partner_const.reborn_desc3
        if config then
            str = config.desc
        end
        self.dec_val:setString(str)
        self.win_title:setString(TI18N("英雄重生"))
         self.confirm_btn_label:setString(TI18N("重 生"))
        self:setData(hero_list)
    elseif reset_type == HeroConst.ResetType.eChipReset then
        --碎片分解
        self.dec_val:setString(dec)
        self:setData(hero_list)
        self.win_title:setString(TI18N("碎片献祭"))
    elseif reset_type == HeroConst.ResetType.eHolyEquipSell then
        --神装出售
        self.dec_val:setString(dec)
        controller:sender11088(hero_list) 
        self.win_title:setString(TI18N("神装出售"))
        self.confirm_btn_label:setString(TI18N("出 售"))
    elseif reset_type == HeroConst.ResetType.eFunriture then
        -- 家具出售
        self.dec_val:setString(dec)
        self.win_title:setString(TI18N("家具出售"))
        self.confirm_btn_label:setString(TI18N("出 售"))
        self:setData(hero_list)
    elseif reset_type == HeroConst.ResetType.eHeroReturn then
        --英雄回退
        local str = TI18N("英雄回退可获得材料，若有进行升级培养，会100%返还培养材料（金币、英雄经验、进阶石）及身上装备与符文。本次置换返还所得如下：")
        local config =  Config.PartnerData.data_partner_const.return_desc3
        if config then
            str = config.desc
        end
        self.dec_val:setString(str)
        self.dec_val:setPositionY(528)
        
        self.win_title:setString(TI18N("英雄回退"))
        self.confirm_btn_label:setString(TI18N("回 退"))

        local data_list = {}
        -- local sort_func = SortTools.tableUpperSorter({"id"})
        -- table.sort(hero_list, sort_func)
        for i,v in ipairs(hero_list) do
            if v.is_partner == 1 then
                local info = {}
                info.bid = v.id
                info.star = v.star
                info.lev = v.lev
                info.show_type = MainuiConst.item_exhibition_type.partner_type
                table_insert(data_list, info)
            else
                table_insert(data_list, {v.id,v.num})
            end
        end

        self:setHeroReturnData(data_list)
    elseif reset_type == HeroConst.ResetType.eSpriteReturn then
        --精灵重生
        local str = TI18N("精灵重生会返还全部奥术之尘与等同于所消耗本体数量的英雄之魂，同时保留1个1级本体")
        self.dec_val:setString(str)
        self.win_title:setString(TI18N("精灵重生"))
        self.confirm_btn_label:setString(TI18N("重 生"))
        local data_list = {}
        for i,v in ipairs(hero_list) do
            local info = {}
            info.id = v[1]
            info.num = v[2]
            table_insert(data_list, info)
        end
        self:setData(data_list)
    end
    self.callback = callback
end

function HeroResetOfferPanel:setData(list)
    if not list then return end
    
    local item_list = {}
    for i,v in ipairs(list) do
        local item = {}
        item.id = v.id
        item.quantity = v.num
        table_insert(item_list, item)
    end

    if #item_list == 0 then
        commonShowEmptyIcon(self.list_view, true, {font_size = 22,scale = 1, text = TI18N("无返还资源")})
        return
    end
    local sort_func = SortTools.tableUpperSorter({"id"})
    -- local sort_func = SortTools.tableUpperSorter({"quality","lev"})
    table.sort(item_list, sort_func)
    self.item_scrollview:setData(item_list, nil, nil, {is_show_tips = true, is_other = false})
end

-- 设置英雄回退信息
function HeroResetOfferPanel:setHeroReturnData(list)
    if not list then return end
    if #list == 0 then
        commonShowEmptyIcon(self.list_view, true, {font_size = 22,scale = 1, text = TI18N("无返还资源")})
        return
    end
    
    local setting = {
        item_class = HeroReturnIconItem,      -- 单元类
        start_x = 16,                  -- 第一个单元的X起点
        space_x = 32,                    -- x方向的间隔
        start_y = 6,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 4,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        once_num = 4,
        need_dynamic = true
    }
    self.item_scrollview:setData(list,nil,setting)
end

function HeroResetOfferPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    controller:openHeroResetOfferPanel(false)
end

-- 常驻英雄回退道具item--------------------------------------------------------------------------------------------
HeroReturnIconItem = class("HeroReturnIconItem", function() 
    return ccui.Widget:create()
end)

function HeroReturnIconItem:ctor()
    self.size = cc.size(119, 119)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self:registerEvent()
end

function HeroReturnIconItem:registerEvent()
    
end

--@config 结构是 Config.PartnerData.data_partner_base
function HeroReturnIconItem:setData(data)
    if data == nil then return end
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
    local item = nil
    if data.show_type ~= nil and data.show_type == MainuiConst.item_exhibition_type.partner_type then
        item = HeroExhibitionItem.new(1, true)
        item:addCallBack(function() 
            -- if v.rid and v.srv_id then
            --     HeroController:getInstance():openHeroTipsPanel(true, v)
            -- else
            --     HeroController:getInstance():openHeroTipsPanelByBid(v.bid)
            -- end
        end)
        item:setPosition(self.size.width/2, self.size.height/2)
        item:setData(data)
        self.root_wnd:addChild(item)
    else
        item = BackPackItem.new(false, true)
        item:setPosition(self.size.width/2, self.size.height/2)
        item:setSwallowTouches(false)
        item:setDefaultTip()
        item:setBaseData(data[1], data[2], true)
        self.root_wnd:addChild(item)
    end
    self.item = item
end

function HeroReturnIconItem:DeleteMe()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end
