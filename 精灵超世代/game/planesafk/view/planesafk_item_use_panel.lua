-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面道具使用
-- <br/> 2020年2月12日
-- --------------------------------------------------------------------
PlanesafkItemUsePanel = PlanesafkItemUsePanel or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function PlanesafkItemUsePanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "planesafk/planesafk_item_use_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }
    self.dic_other_hero = {}

    self.item_id = 10034
    local config = Config.PlanesData.data_const.planes_forever_rock_itemid
    if config then
        self.item_id = config.val
    end
    
end

function PlanesafkItemUsePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("永恒晶石"))

    self.scroll_container = self.main_container:getChildByName("scroll_container")


    local bg_tips = self.main_container:getChildByName("bg_tips")
    -- local config = Config.SecretDunData.data_const.filter_condition
    -- if config then
    --     self.bg_tips:setString(config.desc)
    -- else
    --     self.bg_tips:setString("")    
    -- end

    local planes_spar_atk_radio = 1300
    local config = Config.PlanesData.data_const.planes_spar_atk_radio
    if config then
        planes_spar_atk_radio = config.val
    end
    local per = (planes_spar_atk_radio - 1000)/10
    self.per = per
    -- self.bg_tips = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 1), cc.p(330, 540), 5, nil, 540)
    -- self.main_container:addChild(self.bg_tips)
    bg_tips:setString(string_format(TI18N("消耗一颗永恒晶石,恢复下列宝可梦全部生命和复活所有已经阵亡的宝可梦,且下一场战斗所有宝可梦攻击力增加%s%%"), per))

    self.bg_tips2 = createRichLabel(22, Config.ColorData.data_new_color4[7], cc.p(0.5, 1), cc.p(339, -20), 5, nil, 600)
    self.main_container:addChild(self.bg_tips2)
    self.bg_tips2:setString(TI18N("攻击力增加效果仅在下一场战斗生效一次"))

    local  buy_panel = self.main_container:getChildByName("buy_panel")
    self.key = buy_panel:getChildByName("key")
    self.key:setString(TI18N("拥有:"))
    
    --写到这里
    self.icon = buy_panel:getChildByName("icon")
    self.label = buy_panel:getChildByName("label")

    local item_config = Config.ItemData.data_get_data(self.item_id)
    if item_config then
        local res = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
    end 
    self:updateCount()

    self.plus_btn = self.main_container:getChildByName("plus_btn")

    self.btn_rule = self.main_container:getChildByName("btn_rule")

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))

    --底部线
    --local line_img = createImage(self.main_container, nil, 0, 0, cc.p(0,0.5), false, 1)
    --line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    --line_img:setAnchorPoint(0.5,0)
    --line_img:setScaleX(0.94)
    --line_img:setPosition(cc.p(self.main_container:getContentSize().width/2, -50))
    --
    --local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_3")
    --self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function PlanesafkItemUsePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.PlanesData.data_const.planes_forever_dock_desc
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,false, 1)

    registerButtonEventListener(self.plus_btn, function(param,sender, event_type)
        if self.item_id then
            BackpackController:getInstance():openTipsSource(true, self.item_id)
        end
    end ,false, 1)

    self:addGlobalEvent(PlanesafkEvent.Get_All_Hero_Event, function()
        local list = model:getAllPlanesHeroData()
        self:setData(list)
    end)

    self:addGlobalEvent(PlanesafkEvent.Look_Other_Hero_Event, function(data)
        if not data then return end
        self.is_ther_send = false
        self.dic_other_hero[data.pos] = data
    end)

    self:addGlobalEvent(PlanesafkEvent.Get_Hero_Live_Event, function(data)
        local list = model:getAllPlanesHeroData()
        self:setData(list)
    end)
    
    self:addGlobalEvent(BackpackEvent.BACKPACK_USE_ITEM_EVENT, function(data)
        -- self:onClickBtnClose()
        -- message(TI18N("在永恒晶石的帮助下，宝可梦恢复了生命力"))
    end)
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            self:updateCount()
        end
    end)
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            self:updateCount()
        end
    end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            self:updateCount()
        end
    end)

  
end

function PlanesafkItemUsePanel:updateCount(  )
    if not self.item_id then return end
    if not self.label then return end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    self.label:setString(count)
end

--关闭
function PlanesafkItemUsePanel:onClickBtnClose()
    controller:openPlanesafkItemUsePanel(false)
end


-- 确定使用
function PlanesafkItemUsePanel:onClickBtnRight()
    if not self.hero_list then return end
    local is_not_have = true
    for i,v in ipairs(self.hero_list) do
        if v.hp_per < 100 then
            is_not_have = false
        end
    end
    if is_not_have then
        message("暂无受伤宝可梦数据")
        return 
    end
    local item_config = Config.ItemData.data_get_data(self.item_id)
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    if count <= 0 then
        BackpackController:getInstance():openTipsSource(true, item_config)
        return
    end

    local function fun() 
        local id = BackpackController:getInstance():getModel():getBackPackItemIDByBid(self.item_id)
        BackpackController:getInstance():sender10515(id, 1)
    end
    
    if item_config then 
        local res = PathTool.getItemRes(item_config.icon)
        local per = self.per or 30
        local str = string_format(TI18N("是否花费一个 <img src='%s' scale=0.4 /> 恢复所有宝可梦生命和复活所有已阵亡的宝可梦,且下一场战斗所有宝可梦攻击力增加%s%%"),res, per)
        CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
    end

end

function PlanesafkItemUsePanel:openRootWnd(setting)
    local list = model:getAllPlanesHeroData()
    if list == nil or next(list) == nil then
        controller:sender28613()
    else
        self:setData(list)
    end
end

function PlanesafkItemUsePanel:setData(list)
    self.hero_list = list or {}
    -- for i,v in ipairs(list) do
    --     if v.hp_per < 100 then
    --         table_insert(self.hero_list, v)
    --     end
    -- end
    local sort_func = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"partner_id", false}})
    table_sort(self.hero_list, sort_func)

    self:updateList()
end


function PlanesafkItemUsePanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 140,                -- 单元的尺寸width
            item_height = 150,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.hero_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无宝可梦数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData(nil ,nil ,true)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PlanesafkItemUsePanel:createNewCell(width, height)
    -- local height = 122 --高度写死
    local cell = ccui.Widget:create()
    local hero_item = HeroExhibitionItem.new(1, true)
    hero_item:setPosition(width * 0.5 , height * 0.5 + 15)
    cell:addChild(hero_item)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0,0)
    cell:setContentSize(cc.size(width, height))
    cell.hero_item = hero_item

    cell.hero_item:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function PlanesafkItemUsePanel:numberOfCells()
    if not self.hero_list then return 0 end
    return #self.hero_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PlanesafkItemUsePanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.hero_list[index]
    if hero_vo then
        cell.hero_item:setData(hero_vo)
        cell.hero_item:showProgressbarStatus(true, hero_vo.hp_per, "", {y = -15})
        if hero_vo.hp_per == 0 then --死亡
            cell.hero_item:showStrTips(true, TI18N("已阵亡"))
        else
            cell.hero_item:showStrTips(false)
        end
        if hero_vo.flag == 0 then 
            cell.hero_item:showHelpImg(false)
        else--租借宝可梦
            cell.hero_item:showHelpImg(true)
        end
    end
end

function PlanesafkItemUsePanel:onCellTouched(cell)
    index = cell.index
    local hero_vo = self.hero_list[index]
    if hero_vo then
        if hero_vo.flag == 0 then
            local new_hero_vo = HeroController:getInstance():getModel():getHeroById(hero_vo.partner_id)
            if new_hero_vo and next(new_hero_vo) ~= nil then
                HeroController:getInstance():openHeroTipsPanel(true, new_hero_vo)
            else
                message(TI18N("该宝可梦来自异域，无法查看"))
            end
        else
            if self.dic_other_hero[hero_vo.partner_id] then
                HeroController:getInstance():openHeroTipsPanel(true, self.dic_other_hero[hero_vo.partner_id])
            else 
                if self.is_ther_send then return end
                self.is_ther_send = true
                controller:sender28623(hero_vo.partner_id)
            end
        end
    end
end


function PlanesafkItemUsePanel:close_callback()
    if self.line_load  then
        self.line_load:DeleteMe()
    end
    self.line_load = nil
    
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil


    controller:openPlanesafkItemUsePanel(false)
end
