-- --------------------------------------------------------------------
-- 
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      奇遇图鉴界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EncounterLibraryWindow = EncounterLibraryWindow or BaseClass(BaseView)

local controller = EncounterController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function EncounterLibraryWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big

    self.is_full_screen = true
    self.layout_name = "encounter/encounter_library_window"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("encounter","encounter"), type = ResourcesType.plist},
        -- { path = PathTool.getPlistImgForDownLoad("backpack","backpack"), type = ResourcesType.plist},
    }

    self.cur_index = nil

end

function EncounterLibraryWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.main_view = self.main_panel:getChildByName("container")
    self.info_panel = self.main_view:getChildByName("info_panel")
    
    
    self.lib_container = self.info_panel:getChildByName("lib_container")
    
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.win_title = self.main_panel:getChildByName("win_title")
    self.Image_2 = self.main_panel:getChildByName("Image_2")
    
    self.win_title:setString(TI18N("物语图鉴"))


    self.tab_container = self.info_panel:getChildByName("tab_container")
    
    local tab_array = {
        {title = TI18N("1-3星"), index = EncounterConst.Star_Type.ThreeStar},
        {title = TI18N("4星"), index = EncounterConst.Star_Type.FourStar},
        {title = TI18N("5星"), index = EncounterConst.Star_Type.FiveStar},
        {title = TI18N("6星"), index = EncounterConst.Star_Type.sixStar},
    }
    
    local scroll_view_size_2 = self.lib_container:getContentSize()
    local setting = {
        start_x = 24,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 2,                   -- y方向的间隔
        item_width = 175,               -- 单元的尺寸width
        item_height = 334,              -- 单元的尺寸height
        col = 3,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.lib_container, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size_2, setting, cc.p(0,0))
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    if not self.sub_tab_list then
        local panel_size = self.tab_container:getContentSize()
        self.sub_tab_list = CommonSubBtnList.new(self.tab_container, cc.p(0.5, 0.5), cc.p(panel_size.width*0.5, panel_size.height*0.5), cc.size(145, 50), handler(self, self._onClickSubTabBtn))
    end
    self.sub_tab_list:setData(tab_array, EncounterConst.Star_Type.ThreeStar)

    -- local bgSize = self.tab_container:getContentSize()
    -- local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    -- local setting = {
    --     item_class = CommonTabBtn,      -- 单元类
    --     start_x = 0,                  -- 第一个单元的X起点
    --     space_x = 5,                    -- x方向的间隔
    --     start_y = 0,                    -- 第一个单元的Y起点
    --     space_y = 0,                   -- y方向的间隔
    --     item_width = 128,               -- 单元的尺寸width
    --     item_height = 84,              -- 单元的尺寸height
    --     row = 1,                        -- 行数，作用于水平滚动类型
    --     col = 0,                         -- 列数，作用于垂直滚动类型
    -- }
    -- self.tab_scrollview = CommonScrollViewLayout.new(self.tab_container, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    -- local tab_setting = {}
    -- tab_setting.default_index = EncounterConst.Star_Type.ThreeStar
    -- tab_setting.tab_size = cc.size(128, 64)
    -- tab_setting.select_color = Config.ColorData.data_color4[1]
    -- tab_setting.select_outline = cc.c4b(0x6d,0x35,0x07,0xff)
    -- tab_setting.normal_color = cc.c4b(0xd3,0xb4,0x9b,0xff)
    -- tab_setting.normal_outline = cc.c4b(0x40,0x22,0x15,0xff)
    -- tab_setting.select_res = PathTool.getResFrame("backpack", "backpack_17")
    -- tab_setting.normal_res = PathTool.getResFrame("backpack", "backpack_16")
    -- tab_setting.img_rect = cc.rect(12, 30, 1, 2)
    -- tab_setting.tab_name = "tab_btn_"
    -- self.tab_scrollview:setData(tab_array, handler(self, self.changeTabView), nil, tab_setting)

end 

--==============================--
--desc:切换标签页
--time:2018-06-03 10:16:37
--@index:目标标签页类型
--@return 
--==============================--
function EncounterLibraryWindow:_onClickSubTabBtn(index)
    if index == self.cur_index then return end
    self.cur_index = index
    self:updateListInfo()

end

function EncounterLibraryWindow:createNewCell(  )
	local cell = EncounterLibraryMainItem.new()
    return cell
end

function EncounterLibraryWindow:numberOfCells(  )
	if not self.encounterDataArr then return 0 end
    return #self.encounterDataArr
end

function EncounterLibraryWindow:updateCellByIndex( cell, index )
	if not self.encounterDataArr then return end
    cell.index = index
    local cell_data = self.encounterDataArr[index]
    cell:setData(cell_data)
end

function EncounterLibraryWindow:register_event()

    registerButtonEventListener(self.background, function (  )  
		controller:openEncounterLibraryWindow(false)
    end, nil, 2)


    registerButtonEventListener(self.close_btn, function (  )
		controller:openEncounterLibraryWindow(false)
    end, true, 2)

    -- 已完成冒险奇遇刷新
    self:addGlobalEvent(EncounterEvent.CHECK_SHOW_LIBRARY_ENCOUNTER, function ( list )
        if #list>0 then
            self:updateListInfo()
        end
    end)

end

function EncounterLibraryWindow:updateListInfo()
    if self.cur_index == nil or self.root_wnd == nil then return end
    local num = EncounterConst.Star_Type_Num[self.cur_index]
    if num == nil then return end

    local star_info_arr = self:getEncounterInfoList(num)
    local sort_func = SortTools.tableLowerSorter({"camp","partner_bid","star","isFinish"})
    table.sort(star_info_arr, sort_func)
    self.encounterDataArr = star_info_arr

    self.item_scrollview:reloadData()

end

-- 获取的星id列表 
function EncounterLibraryWindow:getEncounterInfoList( num )
	local tempArr = {}
    for k,v in pairs(Config.EncounterData.data_encounter_info) do
        if v.camp == nil then
            local base_config = Config.PartnerData.data_partner_base[v.partner_bid]
            if base_config then
                v.camp = base_config.camp_type
            end
        end

        if v.isFinish == nil then
            local isFinish = model:isFinishByid(v.id)
            if isFinish == true then
                v.isFinish = 1
            else
                v.isFinish = 2
            end
        end
        
        
        if num == 3 then
            if v.star <= num then
                table_insert(tempArr,v)  
            end
        else 
            if v.star == num then
                table_insert(tempArr,v)   
            end
        end
	end
	return tempArr
end


function EncounterLibraryWindow:openRootWnd()
    
end


function EncounterLibraryWindow:close_callback()
    controller:openEncounterLibraryWindow(false)
    if self.sub_tab_list then
        self.sub_tab_list:DeleteMe()
        self.sub_tab_list = nil
    end

    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

-- 图鉴item--------------------------------------------------------------------------------------------
EncounterLibraryMainItem = class("EncounterLibraryMainItem", function() 
    return ccui.Layout:create()
end)

function EncounterLibraryMainItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("encounter/encounter_library_item"))
    self.size = self.root_wnd:getContentSize()
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setTouchEnabled(true)
    self:setAnchorPoint(0,0)
    self:setContentSize(self.size)
    self.root_wnd:setPosition(0, 0)

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.icon_panel = self.main_panel:getChildByName("icon_panel")
    self.name = self.main_panel:getChildByName("name")
    self.tips_lab = self.main_panel:getChildByName("tips_lab")
    self.black_bg = self.main_panel:getChildByName("black_bg")
    self.black_bg:setVisible(false)
    self.hero_name_bg = self.main_panel:getChildByName("hero_name_bg")
    self.hero_name = self.main_panel:getChildByName("hero_name")
    
    -- 裁剪
    local node_size = self.icon_panel:getContentSize()
    local draw = createSprite(PathTool.getResFrame("encounter","encounter_1011"),node_size.width/2,node_size.height/2,nil,cc.p(0.5,0.5),LOADTEXT_TYPE_PLIST)
    self.map_cli_node = cc.ClippingNode:create(draw)
    self.map_cli_node:setAnchorPoint(cc.p(0.5,0.5))
    self.map_cli_node:setContentSize(node_size)
    self.map_cli_node:setCascadeOpacityEnabled(true)
    self.map_cli_node:setPosition(node_size.width/2, node_size.height/2)
    self.map_cli_node:setAlphaThreshold(0)

    self.icon_panel:addChild(self.map_cli_node)

    self:registerEvent()
end

function EncounterLibraryMainItem:registerEvent()
    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local isFinish = model:isFinishByid(self.config.id)
            if isFinish == false then 
                message(TI18N("暂未获得该物语"))
                return 
            end
            EncounterController:getInstance():openEncounterWindow(true,self.config.id)    
        end
    end)
end

--@config 结构是 Config.PartnerData.data_partner_base
function EncounterLibraryMainItem:setData(config)
    if not config then return end
    self.config = config
    --heroicon
    if not self.hero_icon then
        self.hero_icon = createSprite(nil, 0, 0, self.map_cli_node, cc.p(0, 0), LOADTEXT_TYPE)
        self.hero_icon:setScale(0.5)
    end
    
    local res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" .. self.config.partner_bid)
    if self.record_res_id == nil or self.record_res_id ~= res_id then
        if self.item_load then 
            self.item_load:DeleteMe()
            self.item_load = nil
        end
        self.record_res_id = res_id
        self.item_load = loadSpriteTextureFromCDN(self.hero_icon, res_id, ResourcesType.single, self.item_load, 60)
    end


    self.name:setString(self.config.name)

    local isFinish = model:isFinishByid(self.config.id)
    local tipsLab = ""
    local base_config = Config.PartnerData.data_partner_base[self.config.partner_bid]
    if base_config then
        if isFinish == false then
            tipsLab = string.format( TI18N("获得%d星%s有几率解锁"),self.config.star, base_config.name)
        else
            self.hero_name:setString(base_config.name)
        end
    end
    self.black_bg:setVisible(isFinish==false)
    self.hero_name_bg:setVisible(isFinish)
    self.hero_name:setVisible(isFinish)
    self.tips_lab:setString(tipsLab)
end

function EncounterLibraryMainItem:DeleteMe()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end