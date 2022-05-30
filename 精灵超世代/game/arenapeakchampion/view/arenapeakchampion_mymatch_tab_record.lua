-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      我的比赛记录
-- <br/> 2019年11月13日
-- --------------------------------------------------------------------
ArenapeakchampionMymatchTabRecord = class("ArenapeakchampionMymatchTabRecord", function()
    return ccui.Widget:create()
end)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ArenapeakchampionMymatchTabRecord:ctor(parent)
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
     self:config()
    self:layoutUI()
    self:registerEvents()
    -- self:loadResources()
end

-- function ArenapeakchampionMymatchTabRecord:loadResources()
--     self.res_list = {
--         {path = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_centre", false), type = ResourcesType.single},
--         -- {path = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "txt_cn_arenapeakchampion_guessing_top", false), type = ResourcesType.single},
--         -- {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_92", false), type = ResourcesType.single},
--     } 
--     self.resources_load = ResourcesLoad.New(true) 
--     self.resources_load:addAllList(self.res_list, function()
--         self:config()
--         self:layoutUI()
--         self:registerEvents()
--     end)
-- end

function ArenapeakchampionMymatchTabRecord:config()

end

function ArenapeakchampionMymatchTabRecord:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_mymatch_tab_record")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")
    -- self.container:setSwallowTouches(false)
    self.scroll_container = self.container:getChildByName("scroll_container")
end

--事件
function ArenapeakchampionMymatchTabRecord:registerEvents()
    --我的pk信息
    if self.arenapeakchampion_my_match_log_event == nil then
        self.arenapeakchampion_my_match_log_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MY_MATCH_LOG_EVENT,function ( data )
            if not data then return end
            self:setData(data)
        end)
    end
end

--@hero_vo 宝可梦数据
function ArenapeakchampionMymatchTabRecord:setData(data)
    self.show_list = data.list or {}
    table.sort(self.show_list,function(a, b) return a.id > b.id end)
    self:updateList()
end

function ArenapeakchampionMymatchTabRecord:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 606,                -- 单元的尺寸width
            item_height = 150,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    
    self.item_scrollview:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenapeakchampionMymatchTabRecord:createNewCell(width, height)
   local cell = ArenapeakchampionMymatchTabRecordItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenapeakchampionMymatchTabRecord:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenapeakchampionMymatchTabRecord:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end


function ArenapeakchampionMymatchTabRecord:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        if not self.is_init then
            self.is_init = true
            controller:sender27708()
        end
    end
end

--移除
function ArenapeakchampionMymatchTabRecord:DeleteMe()

    if self.arenapeakchampion_my_match_log_event then
        GlobalEvent:getInstance():UnBind(self.arenapeakchampion_my_match_log_event)
        self.arenapeakchampion_my_match_log_event = nil
    end

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
end


------------------------------------------
-- 子项
ArenapeakchampionMymatchTabRecordItem = class("ArenapeakchampionMymatchTabRecordItem", function()
    return ccui.Widget:create()
end)

function ArenapeakchampionMymatchTabRecordItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ArenapeakchampionMymatchTabRecordItem:configUI( width, height )
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_record_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    local left_role = self.container:getChildByName("left_role")
    self.left_head = PlayerHead.new(PlayerHead.type.circle)
    self.left_head:setHeadLayerScale(0.8)
    left_role:addChild(self.left_head)

    local right_role = self.container:getChildByName("right_role")
    self.right_head = PlayerHead.new(PlayerHead.type.circle)
    self.right_head:setHeadLayerScale(0.8)
    right_role:addChild(self.right_head)

    self.success_img = self.container:getChildByName("success_img")
    --观看
    self.check_fight_btn = self.container:getChildByName("check_fight_btn")
    --名字
    self.left_name = self.container:getChildByName("left_name")
    self.right_name = self.container:getChildByName("right_name")

    self.match_step_label = self.container:getChildByName("match_step_label")
    self.match_step_label:setString("")
    --积分
    self.result_label = self.container:getChildByName("result_label")
    self.line =  self.container:getChildByName("line")
end

function ArenapeakchampionMymatchTabRecordItem:register_event( )
    registerButtonEventListener(self.check_fight_btn, handler(self, self.onClickFightBtn) ,true, 2)
end

function ArenapeakchampionMymatchTabRecordItem:onClickFightBtn()
    if not self.data then return end
    controller:openLookFightVedioPanel(self.data)
end


function ArenapeakchampionMymatchTabRecordItem:setData(data)
    if not data then return end
    self.data = data

    self.left_head:setHeadRes(self.data.a_face, false, LOADTEXT_TYPE, self.data.a_face_file, self.data.a_face_update_time)
    self.right_head:setHeadRes(self.data.b_face, false, LOADTEXT_TYPE, self.data.b_face_file, self.data.b_face_update_time)
    self.left_head:setLev(self.data.a_lev)
    self.right_head:setLev(self.data.b_lev)

    self.left_name:setString(self.data.a_name)
    self.right_name:setString(self.data.b_name)

    if self.data.ret == 0 then
        self.success_img:setVisible(false)
    else
        self.success_img:setVisible(true)
        if self.data.ret == 1 then
            self.success_img:setPositionX(32)
        else
            self.success_img:setPositionX(180)
        end
    end

    local str, str1 = model:getMacthText( self.data.step,  self.data.round)
    self.match_step_label:setString(str or "")
    if self.data.step == 1  then
        --有积分的
        self.match_step_label:setPosition(284, 102)
        self.line:setVisible(true)
        self.result_label:setVisible(true)
        self.result_label:setString(TI18N("获得积分:")..self.data.score)
    else
        self.line:setVisible(false)
        self.result_label:setVisible(false)
        self.match_step_label:setPosition(302, 75)
    end
end


function ArenapeakchampionMymatchTabRecordItem:DeleteMe( )
    if self.left_head then
        self.left_head:DeleteMe()
        self.left_head = nil
    end

    if self.right_head then
        self.right_head:DeleteMe()
        self.right_head = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end