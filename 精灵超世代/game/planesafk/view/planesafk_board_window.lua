

---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/09 14:36:26
-- @description: 位面 广告牌
---------------------------------
local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local _string_format = string.format

PlanesafkBoardWindow = PlanesafkBoardWindow or BaseClass(BaseView)

function PlanesafkBoardWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "planes/planes_board_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("planes", "planes_map"), type = ResourcesType.plist},
    }
    self.dic_other_hero = {}
end

function PlanesafkBoardWindow:open_callback( )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 1)

    self.win_title = main_container:getChildByName("win_title")
    self.btn_comfirm = main_container:getChildByName("btn_comfirm")
    self.btn_comfirm_label = self.btn_comfirm:getChildByName("label")

    self.board_sp = main_container:getChildByName("board_sp")
    self.title_txt = main_container:getChildByName("title_txt") -- 标题

    self.main_con_size = main_container:getContentSize()

    self.scroll_container = main_container:getChildByName("scroll_container")
end

function PlanesafkBoardWindow:register_event( )
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.btn_comfirm, handler(self, self.onClickComfirmBtn), true)

    self:addGlobalEvent(PlanesafkEvent.Get_Hero_Live_Event, function(data)
        local list = model:getAllPlanesHeroData()
        self:setListData(list)
    end)

    self:addGlobalEvent(PlanesafkEvent.Look_Other_Hero_Event, function(data)
        if not data then return end
        self.is_ther_send = false
        self.dic_other_hero[data.pos] = data
    end)
end

function PlanesafkBoardWindow:onClickCloseBtn(  )
    controller:openPlanesafkBoardWindow(false)
end

function PlanesafkBoardWindow:onClickComfirmBtn(  )
    if not self.board_id or not self.data then return end
    if self.board_show_type == 2 then return end --年兽活动没有 此事件
    -- 告示牌和升降台无需操作
    if self.board_id == PlanesafkConst.Recover_Id or self.board_id == PlanesafkConst.Revive_Id then
        if self.board_id == PlanesafkConst.Recover_Id and not model:checkIsHaveHpNotFullHero() then -- 回复泉水时，所有宝可梦都是满血
            CommonAlert.show(TI18N("当前所有非阵亡宝可梦均满血，使用回复泉水将不会有效，是否继续？"), TI18N("确认"), function (  )
                controller:sender28600(self.data.line, self.data.index, 1, {} )
            end, TI18N("取消"))
        elseif self.board_id == PlanesafkConst.Revive_Id and not model:checkIsHaveDieHero() then -- 复活时，没有死亡的宝可梦
            CommonAlert.show(TI18N("当前无阵亡宝可梦且存活的宝可梦均满血，使用复活十字架将不会有效，是否继续？"), TI18N("确认"), function (  )
                controller:sender28600(self.data.line, self.data.index, 1, {} )
            end, TI18N("取消"))
        else
            controller:sender28600(self.data.line, self.data.index, 1, {} )
        end
    end
    controller:openPlanesafkBoardWindow(false)
end

--@data 28603单个list结构
function PlanesafkBoardWindow:openRootWnd( id, data , setting)
    self.board_id = id
    self.data = data
    setting = setting or {}
    --广告显示类型: 1 位面的  2 年兽活动
    self.board_show_type = setting.show_type or 1
    self.board_cfg = setting.board_cfg

    self:setData(id)

    local list = model:getAllPlanesHeroData()
    if list == nil or next(list) == nil then
        controller:sender28613()
    else
        self:setListData(list)
    end

    local evt_data = controller:getMapEvtData(self.data.line, self.data.index)
    if evt_data and evt_data.is_black then
        self.btn_comfirm:setVisible(false)
    end
end

function PlanesafkBoardWindow:setListData(list)
    self.hero_list = list or {}
    -- for i,v in ipairs(list) do
    --     if v.hp_per < 100 then
    --         table_insert(self.hero_list, v)
    --     end
    -- end
    local sort_func = SortTools.tableCommonSorter({{"star", true}, {"power", true}, {"partner_id", false}})
    table.sort(self.hero_list, sort_func)

    self:updateList()
end

function PlanesafkBoardWindow:setData(id)
    if not id then return end
    local board_cfg = self.board_cfg
    if board_cfg == nil then
        --避免报错的
        board_cfg = Config.SecretDunData.data_board[id]
    end
    if not board_cfg then return end

    -- 按钮
    if board_cfg.btn_str ~= "" then
        self.btn_comfirm:setVisible(true)
        self.btn_comfirm_label:setString(board_cfg.btn_str)
    else
        self.btn_comfirm:setVisible(false)
    end

    -- 标题
    self.win_title:setString( TI18N(board_cfg.title))

    -- 图片
    if self.board_show_type == 2 then
        local board_res = _string_format("resource/planes/board_img/%s.png", board_cfg.res_id)
        self.board_img_load = loadSpriteTextureFromCDN(self.board_sp, board_res, ResourcesType.single, self.board_img_load)
    else
        local board_res = _string_format("resource/planes/board_img/%s.png", board_cfg.res_id)
        self.board_img_load = loadSpriteTextureFromCDN(self.board_sp, board_res, ResourcesType.single, self.board_img_load)
    end

    -- 标题
    self.title_txt:setString(TI18N(board_cfg.title))

    -- 描述内容一
    if not self.desc_txt_1 then
        self.desc_txt_1 = createRichLabel(24, cc.c4b(149, 83, 34, 255), cc.p(0.5, 1), cc.p(self.main_con_size.width*0.5, 567), 0, 0, self.main_con_size.width - 80)
        self.main_container:addChild(self.desc_txt_1)
    end
    self.desc_txt_1:setString(board_cfg.desc_1)

    -- -- 描述内容二
    -- if not self.desc_txt_2 then
    --     self.desc_txt_2 = createRichLabel(24, cc.c4b(149, 83, 34, 255), cc.p(0.5, 1), cc.p(self.main_con_size.width*0.5, 0), 0, 0, self.main_con_size.width - 100)
    --     self.main_container:addChild(self.desc_txt_2)
    -- end
    -- self.desc_txt_2:setString(board_cfg.desc_2)
    -- local desc_txt_size = self.desc_txt_1:getContentSize()
    -- self.desc_txt_2:setPositionY(420 - desc_txt_size.height - 50)
end

function PlanesafkBoardWindow:updateList()
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
function PlanesafkBoardWindow:createNewCell(width, height)
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
function PlanesafkBoardWindow:numberOfCells()
    if not self.hero_list then return 0 end
    return #self.hero_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PlanesafkBoardWindow:updateCellByIndex(cell, index)
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

function PlanesafkBoardWindow:onCellTouched(cell)
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


function PlanesafkBoardWindow:close_callback( )
    if self.board_img_load then
        self.board_img_load:DeleteMe()
        self.board_img_load = nil
    end
    controller:openPlanesafkBoardWindow(false)
end