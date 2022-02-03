

-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面英雄列表 
-- <br/> 2019年12月12日
-- --------------------------------------------------------------------
PlanesafkHeroListPanel = PlanesafkHeroListPanel or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function PlanesafkHeroListPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "planes/planes_hero_list_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }
    self.dic_other_hero = {}
end

function PlanesafkHeroListPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("参与英雄列表"))

    self.scroll_container = self.main_container:getChildByName("scroll_container")


    self.bg_tips = self.main_container:getChildByName("bg_tips")
    local config = Config.SecretDunData.data_const.filter_condition
    if config then
        self.bg_tips:setString(config.desc)
    else
        self.bg_tips:setString("")    
    end
    
    self.bg_tips_0 = self.main_container:getChildByName("bg_tips_0")
    -- self.bg_tips_0:setString(TI18N("下面提示语..策划想填啥呢"))    
    self.bg_tips_0:setString(TI18N("雇佣的英雄只可在该玩法中被使用，副本重置后将清空所有雇佣英雄"))    
end

function PlanesafkHeroListPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)


    self:addGlobalEvent(PlanesafkEvent.Get_All_Hero_Event, function()
        local list = model:getAllPlanesHeroData()
        self:setData(list)
    end)

    self:addGlobalEvent(PlanesafkEvent.Look_Other_Hero_Event, function(data)
        if not data then return end
        self.is_ther_send = false
        self.dic_other_hero[data.pos] = data
    end)
end

--关闭
function PlanesafkHeroListPanel:onClickBtnClose()
    controller:openPlanesafkHeroListPanel(false)
end

function PlanesafkHeroListPanel:openRootWnd(setting)
    local list = model:getAllPlanesHeroData()
    if list == nil or next(list) == nil then
        controller:sender28613()
    else
        self:setData(list)
    end
end

function PlanesafkHeroListPanel:setData(list)
    self.hero_list = list or {}
    local sort_func = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"partner_id", false}})
    table_sort(self.hero_list, sort_func)
    self:updateList()
end


function PlanesafkHeroListPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 119,                -- 单元的尺寸width
            item_height = 142,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.hero_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无英雄数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PlanesafkHeroListPanel:createNewCell(width, height)
    -- local height = 122 --高度写死
    local cell = ccui.Widget:create()
    local hero_item = HeroExhibitionItem.new(0.9, true)
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
function PlanesafkHeroListPanel:numberOfCells()
    if not self.hero_list then return 0 end
    return #self.hero_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PlanesafkHeroListPanel:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.hero_list[index]
    if hero_vo then
        
        if hero_vo.flag == 0 then 
            cell.hero_item:showHelpImg(false)
            local hero_data = HeroController:getInstance():getModel():getHeroById(hero_vo.partner_id)
            if hero_data then
                cell.hero_item:setData(hero_data)
            else
                cell.hero_item:setData(hero_vo)    
            end
        else--租借英雄
            cell.hero_item:setData(hero_vo)                
            cell.hero_item:showHelpImg(true)
        end

        cell.hero_item:showProgressbarStatus(true, hero_vo.hp_per, "", {y = -15})
        if hero_vo.hp_per == 0 then --死亡
            cell.hero_item:showStrTips(true, TI18N("已阵亡"))
        else
            cell.hero_item:showStrTips(false)
        end
        
    end
end

function PlanesafkHeroListPanel:onCellTouched(cell)
    index = cell.index
    local hero_vo = self.hero_list[index]
    if hero_vo then
        if hero_vo.flag == 0 then
            local new_hero_vo = HeroController:getInstance():getModel():getHeroById(hero_vo.partner_id)
            if new_hero_vo and next(new_hero_vo) ~= nil then
                HeroController:getInstance():openHeroTipsPanel(true, new_hero_vo)
            else
                message(TI18N("该英雄来自异域，无法查看"))
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


function PlanesafkHeroListPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openPlanesafkHeroListPanel(false)
end
