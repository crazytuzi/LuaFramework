-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄重生 100级以下的
-- <br/>Create: 2020年3月26日
--
-- --------------------------------------------------------------------
HeroResetComfirmPanel = HeroResetComfirmPanel or BaseClass(BaseView)

local table_insert = table.insert
local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format

function HeroResetComfirmPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_reset_comfirm_panel"
end 

function HeroResetComfirmPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 2)  
    self.win_title = container:getChildByName("win_title")
    self.win_title:setString(TI18N("重生预览"))

    self.top_val = createRichLabel(26, cc.c4b(0x64, 0x32, 0x23, 0xff), cc.p(0.5, 1), cc.p(337,385),12,nil,580)
    container:addChild(self.top_val)
    self.dec_val = createRichLabel(22, cc.c4b(0x64, 0x32, 0x23, 0xff), cc.p(0.5, 0.5), cc.p(337,140),12,nil,580)
    container:addChild(self.dec_val)
    self.count_label = createRichLabel(22, cc.c4b(0x64, 0x32, 0x23, 0xff), cc.p(0, 1), cc.p(524,88),12,nil,200)
    container:addChild(self.count_label)

    self.hero_item = HeroExhibitionItem.new(1, true)
    self.hero_item:setPosition(123, 258)
    container:addChild(self.hero_item)

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("免费重生"))
    self.list_view = container:getChildByName("list_view")

    self.close_btn = container:getChildByName("close_btn")
    self.container = container

    local line_img = createImage(container, nil, 0, 0, cc.p(0,0.5), false, 1)
    -- line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    line_img:setAnchorPoint(0.5,0)
    line_img:setScaleX(1.8)
    line_img:setPosition(cc.p(container:getContentSize().width/2, 20))

    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_1")
    self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function HeroResetComfirmPanel:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openHeroResetComfirmPanel(false) end ,true, 1)
    registerButtonEventListener(self.background, function() controller:openHeroResetComfirmPanel(false) end ,false, 1)

    registerButtonEventListener(self.confirm_btn, function() self:onConfirmButton() end ,true, 2)
end



function HeroResetComfirmPanel:upateShowList()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.list_view, true, {font_size = 22,scale = 1, text = TI18N("无返还资源")})
        return
    end
    if self.item_scrollview == nil then
        local size = self.list_view:getContentSize()
        local setting = {
            -- item_class = BackPackItem,      -- 单元类
            start_x = 16,                  -- 第一个单元的X起点
            space_x = 32,                    -- x方向的间隔
            start_y = 6,                    -- 第一个单元的Y起点
            space_y = 10,                   -- y方向的间隔
            item_width = 110,               -- 单元的尺寸width
            item_height = 119,              -- 单元的尺寸height
            row = 4,                        -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            once_num = 4,
            need_dynamic = true
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.list_view, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting)
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroResetComfirmPanel:createNewCell(width, height)
    local cell = HeroReturnIconItem1.new(width, height)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroResetComfirmPanel:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroResetComfirmPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if cell_data then
        cell:setData(cell_data)
    end

end

function HeroResetComfirmPanel:onConfirmButton()
    if not self.hero_vo then return end

    local reset_time = self.hero_vo:getAttrByKey("reset_time") or 0
    if reset_time ~= 0 then
        local time = reset_time - GameNet:getInstance():getTime()
        if time > 0 then
            message(TI18N("不要频繁重生同一位英雄哦！"))
            return
        end
    end

    if self.count and self.count <= 0 then
        message(TI18N("今日重生次数已达上限"))
        return
    end

    controller:sender11068(self.hero_vo.partner_id)
    controller:openHeroResetComfirmPanel(false)
end

function HeroResetComfirmPanel:openRootWnd(hero_vo)
    if not hero_vo then return end
    self.hero_vo = hero_vo
    local dic_item_id = {}
    --计算等级返回
    local config = Config.PartnerData.data_partner_lev[hero_vo.lev]
    if config and config.get_item then
        for i,v in ipairs(config.get_item) do
            if dic_item_id[v[1]] == nil then
                dic_item_id[v[1]] = v[2]
            else
                dic_item_id[v[1]] = dic_item_id[v[1]] + v[2]
            end
        end
    end
    --计算进阶返还
    local key = getNorKey(hero_vo.type, hero_vo.break_id, hero_vo.break_lev)
    local break_config = Config.PartnerData.data_partner_brach[key]
    if break_config and break_config.get_item then
        for i,v in ipairs(break_config.get_item) do
            if dic_item_id[v[1]] == nil then
                dic_item_id[v[1]] = v[2]
            else
                dic_item_id[v[1]] = dic_item_id[v[1]] + v[2]
            end
        end
    end
    self.show_list = {}
    local copy_hero_vo = deepCopy(hero_vo)
    copy_hero_vo.lev = 1
    copy_hero_vo.artifact_list = {}
    copy_hero_vo.show_type = MainuiConst.item_exhibition_type.partner_type
    -- table_insert(self.show_list, copy_hero_vo)
    self.hero_item:setData(copy_hero_vo)
    --如果有符文也要显示
    local equip_vo = hero_vo.artifact_list[1]
    if equip_vo then
        table_insert(self.show_list, equip_vo)
    end

    for k,v in pairs(dic_item_id) do
        if v > 0 then
            table_insert(self.show_list, {id = k, quantity = v})
        end
    end
    
    self:upateShowList()
    local top_str = string_format(TI18N("<div fontcolor=#d95014>%s</div>重生为1级,<div fontcolor=#249003>100%%</div>返还<div fontcolor=#249003>升级, 进阶</div>耗材"), hero_vo.name)
    self.top_val:setString(top_str)
    self.dec_val:setString(TI18N("100级或以下的英雄才能重生"))

    self.born_num = 3
    local config = Config.PartnerData.data_partner_const.born_num
    if config then
        self.born_num = config.val
    end
    local reset_count = model:getResetCount() or 0
    self.count = self.born_num - reset_count
    if self.count < 0 then
        self.count = 0
    end
    self.count_label:setString(string_format(TI18N("今日剩余<div fontcolor=#249003>%s</div>次"), self.count))
    self:updateBtnTime()
end

function HeroResetComfirmPanel:updateBtnTime()
    if not self.hero_vo then return end
    if not self.confirm_btn_label then return end
    local reset_time = self.hero_vo:getAttrByKey("reset_time") or 0
    if reset_time ~= 0 then
        local time = reset_time - GameNet:getInstance():getTime()
        if time > 0 then
            commonCountDownTime(self.confirm_btn_label, time, {end_callback = function() self:updateBtnTime()  end})
            setChildUnEnabled(true, self.confirm_btn)
            self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[2], 2)
        else
            self.confirm_btn_label:setString(TI18N("免费重生"))
            if self.count <= 0 then
                setChildUnEnabled(true, self.confirm_btn)
                self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[2], 2)
            else
                setChildUnEnabled(false, self.confirm_btn)
                self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)  
            end
        end
    else
        self.confirm_btn_label:setString(TI18N("免费重生"))
        if self.count <= 0 then
            setChildUnEnabled(true, self.confirm_btn)
            self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[2], 2)
        else
            setChildUnEnabled(false, self.confirm_btn)
            self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)  
        end
    end
end

function HeroResetComfirmPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end

    if self.line_load  then
        self.line_load:DeleteMe()
    end
    self.line_load = nil
    controller:openHeroResetComfirmPanel(false)
end

HeroReturnIconItem1 = class("HeroReturnIconItem1", function() 
    return ccui.Widget:create()
end)

function HeroReturnIconItem1:ctor()
    self.size = cc.size(119, 119)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self:registerEvent()
end

function HeroReturnIconItem1:registerEvent()
    
end

--@config 结构是 Config.PartnerData.data_partner_base
function HeroReturnIconItem1:setData(data)
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
        item = BackPackItem.new(false, false)
        -- item:addCallBack(function() end)
        item:setPosition(self.size.width/2, self.size.height/2)
        item:setSwallowTouches(false)
        item:setData(data, true)
        self.root_wnd:addChild(item)
    end
    self.item = item
end

function HeroReturnIconItem1:DeleteMe()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

