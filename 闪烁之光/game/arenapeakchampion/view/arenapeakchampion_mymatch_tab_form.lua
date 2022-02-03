-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      我的赛程
-- <br/> 2019年11月19日
-- --------------------------------------------------------------------
ArenapeakchampionMymatchTabForm = class("ArenapeakchampionMymatchTabForm", function()
    return ccui.Widget:create()
end)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort

function ArenapeakchampionMymatchTabForm:ctor(parent)
    self.parent = parent
    self.role_vo = RoleController:getInstance():getRoleVo()
     self:config()
    self:layoutUI()
    self:registerEvents()
end

function ArenapeakchampionMymatchTabForm:config()

end

function ArenapeakchampionMymatchTabForm:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_mymatch_tab_form")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")
    self.empty_panel = self.root_wnd:getChildByName("empty_panel")
    -- self.container:setSwallowTouches(false)
    local  bg = self.container:getChildByName("bg")
    self.centre_img = bg:getChildByName("centre_img")

    self.vs_img = self.container:getChildByName("vs_img")
    
    loadSpriteTexture(self.centre_img, PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_guessing_centre", false), LOADTEXT_TYPE)

    self.centre_panel = self.container:getChildByName("centre_panel")

    self.win_img = self.centre_panel:getChildByName("win_img")
    local left_play_node = self.centre_panel:getChildByName("left_play_node")
    local left_power_click = self.centre_panel:getChildByName("left_power_click")
    self.left_fight_label = CommonNum.new(20, left_power_click, 0, - 2, cc.p(0.5, 0.5))
    self.left_fight_label:setPosition(103, 28)

    self.left_play_head = PlayerHead.new(PlayerHead.type.circle)
    self.left_play_head:setHeadLayerScale(0.90)
    self.left_play_head:setLev(99)
    left_play_node:addChild(self.left_play_head)

    local right_play_node = self.centre_panel:getChildByName("right_play_node")
    local right_power_click = self.centre_panel:getChildByName("right_power_click")
    self.right_fight_label = CommonNum.new(20, right_power_click, 0, - 2, cc.p(0.5, 0.5))
    self.right_fight_label:setPosition(103, 28)

    self.right_play_head = PlayerHead.new(PlayerHead.type.circle)
    self.right_play_head:setHeadLayerScale(0.90)
    self.right_play_head:setLev(99)
    right_play_node:addChild(self.right_play_head)

    self.left_name = self.centre_panel:getChildByName("left_name")
    self.left_srv_name = self.centre_panel:getChildByName("left_srv_name")
    self.right_name = self.centre_panel:getChildByName("right_name")
    self.right_srv_name = self.centre_panel:getChildByName("right_srv_name")
    self.time_val = self.centre_panel:getChildByName("time_val")
    self.match_value = createRichLabel(22, cc.c4b(0xff,0xd7,0x6b,0xff), cc.p(0.5, 0.5), cc.p(305,327),nil,nil,1000)
    self.centre_panel:addChild(self.match_value)
    
    --回放
    self.fight_btn = self.centre_panel:getChildByName("fight_btn")
    self.fight_btn:getChildByName("label"):setString(TI18N("观战"))
    --数据
    self.from_btn = self.centre_panel:getChildByName("from_btn")
    self.from_btn:getChildByName("label"):setString(TI18N("调整布阵"))

    self.scroll_container = self.container:getChildByName("scroll_container")
end

--事件
function ArenapeakchampionMymatchTabForm:registerEvents()
    registerButtonEventListener(self.fight_btn, function() self:onClickFightBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.from_btn, function() self:onClickFromBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)


       --竞猜信息
    if self.arenapeakchampion_my_match_info_event == nil then
        self.arenapeakchampion_my_match_info_event = GlobalEvent:getInstance():Bind(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MY_MATCH_INFO_EVENT,function ( data )
            if not data then return end
            self:setData(data)
        end)
    end
end

--战斗详情
function ArenapeakchampionMymatchTabForm:onClickFromBtn()
   HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.ArenapeakchampionDef, {}, HeroConst.FormShowType.eFormSave)
end
--回放
function ArenapeakchampionMymatchTabForm:onClickFightBtn()
    if not self.scdata then return end
    controller:openLookFightVedioPanel(self.scdata)
end


--@hero_vo 英雄数据
function ArenapeakchampionMymatchTabForm:setData(data)
    self.scdata = data
    --没有参数资格
    if data.step == 0 then
        self.container:setVisible(false)
        self.empty_panel:setVisible(true)
        self:showEmptyInfo()
        if self.parent then
            self.parent:setTabBtnVisible(false)
        end
        return    
    end

    self.container:setVisible(true)
    self.empty_panel:setVisible(false)
    self:updateCentrePanel()
    local second_data = model:getSecondData(data, nil, 3)

    self.show_list = second_data.arena_replay_infos or {}
    table_sort(self.show_list,function(a, b) return a.order < b.order end)
    self:updateList()
end

function ArenapeakchampionMymatchTabForm:showEmptyInfo()
    commonShowEmptyIcon(self.empty_panel, true, {text = TI18N("")})

    self.fuse_btn_label = createRichLabel(26,cc.c4b(0x64, 0x32, 0x23, 0xff), cc.p(0.5,1),cc.p(360, 555),nil,nil, 550)
    self.fuse_btn_label:setString("您未能参加本次冠军赛可<div fontColor=#1a9222 href=xxx>前往竞猜</div>界面参与竞猜")
    self.empty_panel:addChild(self.fuse_btn_label)

    self.fuse_btn_label:addTouchLinkListener(function(type, value, sender, pos)
        controller:openArenapeakchampionGuessingWindow(true)
         -- MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Arenapeakchampion)
    end, { "click", "href" })
end

--更新中间部分
function ArenapeakchampionMymatchTabForm:updateCentrePanel( )
    if not self.scdata then return end
    self:setHeadInfo(self.left_play_head, self.scdata.a_lev, self.scdata.a_face,self.scdata.a_avatar_id, self.scdata.a_face_file, self.scdata.a_face_update_time)
    self:setHeadInfo(self.right_play_head, self.scdata.b_lev, self.scdata.b_face,self.scdata.b_avatar_id,self.scdata.b_face_file, self.scdata.b_face_update_time)
    self.left_name:setString(self.scdata.a_name)
    self.right_name:setString(self.scdata.b_name)

    local srv_name = getServerName(self.scdata.a_srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    self.left_srv_name:setString(string_format("[%s]",srv_name))

    srv_name = getServerName(self.scdata.b_srv_id)
    if srv_name == "" then
        srv_name = TI18N("异域")
    end
    self.right_srv_name:setString(string_format("[%s]",srv_name))
    
    self.left_fight_label:setNum(self.scdata.a_power)
    self.right_fight_label:setNum(self.scdata.b_power)

    --"结果(0:未打 1:胜利 2:失败)"}
    if self.scdata.ret == 0 then
        self.win_img:setVisible(false)
        --如果是未打..跟外面的竞猜进程一样
        local main_data = model:getMainData()
        if main_data and main_data.round_status == 2 then
            --竞猜
            self.fight_btn:setVisible(false)
            self.vs_img:setVisible(true)
        else
            local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_guessing_19", false, "arenapeak_guessing")
            self.fight_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
            self.fight_btn:getChildByName("label"):setString(TI18N("观战"))
            self.fight_btn:setVisible(true)
            self.vs_img:setVisible(false)
        end
    else
        local res = PathTool.getResFrame("arenapeakchampion", "arenapeakchampion_guessing_19_1", false, "arenapeak_guessing")
        self.fight_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
        self.fight_btn:getChildByName("label"):setString(TI18N("查看"))

        self.vs_img:setVisible(false)
        self.fight_btn:setVisible(true)
        self.win_img:setVisible(true)
        if self.scdata.ret == 1 then --左边胜利
            self.win_img:setPositionX(60)
        else
            self.win_img:setPositionX(564)
        end
    end

    local str, str1 = model:getMacthText( self.scdata.step,  self.scdata.round)
    local match_str = str or ""
    -- if str1 then
    --     match_str = match_str ..string_format("<div fontcolor=#52f559>%s</div>", str1)
    -- end
    self.match_value:setString(match_str)

end

function ArenapeakchampionMymatchTabForm:setHeadInfo(head, lev, face_id, avatar_bid, face_file, face_update_time)
    head:setHeadRes(face_id or 1001, false, LOADTEXT_TYPE, face_file, face_update_time)
    head:setLev(lev or 1)

    if avatar_bid and head.record_res_bid == nil or head.record_res_bid ~= avatar_bid then
        head.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            head:showBg(res, nil, false, vo.offy)
        end
    end
end

function ArenapeakchampionMymatchTabForm:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 606,                -- 单元的尺寸width
            item_height = 280,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end

    self.item_scrollview:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenapeakchampionMymatchTabForm:createNewCell(width, height)
   local cell = ArenapeakchampionFightInfoItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenapeakchampionMymatchTabForm:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenapeakchampionMymatchTabForm:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    if index == 3 then --第三队隐藏
        cell:setData(cell_data, false, true)
    else
        cell:setData(cell_data)
    end
    
end


function ArenapeakchampionMymatchTabForm:setVisibleStatus(bool)
    self:setVisible(bool)
    if bool then
        if not self.is_init then
            self.is_init = true
            controller:sender27702()
        end
    end
end

--移除
function ArenapeakchampionMymatchTabForm:DeleteMe()
    if self.arenapeakchampion_my_match_info_event then
        GlobalEvent:getInstance():UnBind(self.arenapeakchampion_my_match_info_event)
        self.arenapeakchampion_my_match_info_event = nil
    end

    if self.left_fight_label then
        self.left_fight_label:DeleteMe()
        self.left_fight_label = nil
    end
    if self.right_fight_label then
        self.right_fight_label:DeleteMe()
        self.right_fight_label = nil
    end

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
end
