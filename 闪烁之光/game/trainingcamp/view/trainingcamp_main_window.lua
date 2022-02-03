-- --------------------------------------------------------------------
-- 新手训练营关卡挑战布阵界面
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-xx-xx
-- --------------------------------------------------------------------
local _controller = TrainingcampController:getInstance()
local _model = _controller:getModel()
local table_insert = table.insert
local string_format = string.format

TrainingcampMainWindow =  TrainingcampMainWindow or BaseClass(BaseView)

function TrainingcampMainWindow:__init()
    self.win_type = WinType.Full
    self.layout_name = "trainingcamp/trainingcamp_main_window"

    self.show_list = {}
    --英雄对象
    self.hero_item_list = {}
    self.five_hero_vo = {}
    --位置名字
    self.pos_name_list = {}
    --英雄对象位置的矩形区域
    self.pos_rect_list = {}
    --禁止位置
    self.ban_pos_list = {}
    self.cell_width = 119

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("trainingcamp","trainingcamp"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_90"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_91"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_92"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_95", true), type = ResourcesType.single },
	}
end

function TrainingcampMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_95",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.title_panel = self.container:getChildByName("title_panel")
    self.title_name = self.title_panel:getChildByName("title_name")
    self.finish_img = self.title_panel:getChildByName("finish_img")
    self.finish_img:setVisible(false)
    
    self.up_panel = self.container:getChildByName("up_panel")
    self.left_panel = self.up_panel:getChildByName("left_panel")
    self.left_panel:getChildByName("left_name"):setString(TI18N("我方阵容"))
    
    local right_panel = self.up_panel:getChildByName("right_panel")
    right_panel:getChildByName("right_name"):setString(TI18N("训练对手"))
      
    local function _getTeamItem(panel,is_left)
        local item = {}
        item.panel = panel

        --阵法icon
        local form_bg = panel:getChildByName("form_bg")
        item.form_icon = form_bg:getChildByName("form_icon")
        item.form_icon:setScale(1.5)

        --位置
        item.pos_list = {}
        item.hero_item_list = {}
        for i=1,9 do
            local item_bg = panel:getChildByName("item_bg_"..i)
            local x, y = item_bg:getPosition()
            item.pos_list[i] = cc.p(x, y)
        end

        item.role_head = PlayerHead.new(PlayerHead.type.circle)       -- 角色头像
        if is_left == true then
            item.role_head:setPosition(60, 403)
        else
            item.role_head:setPosition(5, -65)
        end
        panel:addChild(item.role_head) 
        return item
    end
    self.up_right_team_info = _getTeamItem(right_panel,false)
    self.up_left_team_info = _getTeamItem(self.left_panel,true)

    --下面5个英雄
    local pos = {2,4,6,7,9}--一开始默认 第一个阵法位置
    for index=1,5 do
        self.hero_item_list[index] = HeroExhibitionItem.new(0.7, false)
        self.hero_item_list[index]:setPosition(self.up_left_team_info.pos_list[pos[index]])
        self.left_panel:addChild(self.hero_item_list[index])
    end

    
    self.down_panel = self.container:getChildByName("down_panel")
    
    self.lay_scrollview = self.down_panel:getChildByName("lay_scrollview")
    local scroll_view_size = self.lay_scrollview:getContentSize()
    local setting = {
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 7,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 119*0.9,               -- 单元的尺寸width
        item_height = 119*0.9,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    
    self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0.5,0.5))

    self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    
    
    self.txt_lab = self.down_panel:getChildByName("txt_lab")
    self.txt_lab_1 = self.down_panel:getChildByName("txt_lab_1")
    self.txt_lab_1:setString("当前无可选英雄")
    self.txt_lab_1:setVisible(false)
    
    --光环icon
    self.halo_btn = self.down_panel:getChildByName("halo_btn")
    self.halo_label = self.halo_btn:getChildByName("label")

    --阵法
    self.form_change_btn = self.down_panel:getChildByName("form_change_btn")
    self.form_change_btn:getChildByName("label"):setString(TI18N("阵法"))
    --阵法icon
    self.form_icon = self.form_change_btn:getChildByName("form_icon")
    self.tips_btn = self.down_panel:getChildByName("tips_btn")
    self.tips_btn:getChildByName("label"):setString(TI18N("提示"))
    self.go_btn = self.down_panel:getChildByName("go_btn")
    self.go_btn:getChildByName("label"):setString(TI18N("挑战"))
    self.close_btn = self.container:getChildByName("close_btn")

    self:adaptationScreen();
    
end

--设置适配屏幕
function TrainingcampMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)

    local tab_y = self.title_panel:getPositionY()
    self.title_panel:setPositionY(top_y - (self.container:getContentSize().height - tab_y))
end

function TrainingcampMainWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.halo_btn, handler(self, self.onClickHaloBtn) ,true, 2)
    registerButtonEventListener(self.form_change_btn, handler(self, self.onClickFormChangeBtn) ,true, 2)
    registerButtonEventListener(self.tips_btn, handler(self, self.onClickTipsBtn) ,true, 1)
    registerButtonEventListener(self.go_btn, handler(self, self.onFightDrama) ,true, 1)
    
    self.long_touch_type = LONG_TOUCH_INIT_TYPE
    for i,item in ipairs(self.hero_item_list) do
        item:addTouchEventListener(function(sender, event_type)
            --播放动作中 和 数据为空
            if self.is_play_item_action then return end
            if self.five_hero_vo[i] == nil then return end
            if event_type == ccui.TouchEventType.began then
                self.touch_began = sender:getTouchBeganPosition()
                self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
            elseif event_type == ccui.TouchEventType.moved then
                if self.long_touch_type == LONG_TOUCH_END_TYPE then
                    --事件触发了就不处理移动事件了
                    return 
                elseif self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    local touch_began = self.touch_began
                    local touch_end = sender:getTouchMovePosition()
                    if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 20 or math.abs(touch_end.y - touch_began.y) > 20) then 
                        --移动大于20了..表示取消长点击效果
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    end 
                end
                self:onClickHeroItemMove(i, sender)
            elseif event_type == ccui.TouchEventType.canceled then
                if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                    --事件触发了就不处理点击事件了
                    if self.move_hero_item then
                        self.move_hero_item:setPosition(-10000, 0)
                    end
                    item:setData(self.five_hero_vo[i])
                    return
                end

                self:onClickHeroItemCanceled(i, sender)
            elseif event_type == ccui.TouchEventType.ended then
                if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                    self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                    --事件触发了就不处理点击事件了
                    if self.move_hero_item then
                        self.move_hero_item:setPosition(-10000, 0)
                    end
                    item:setData(self.five_hero_vo[i])
                    return
                end

                self:onClickHeroItemEnd(i, sender)
            end
        end)
    end

    -- 更新提示界面显示
    self:addGlobalEvent(TrainingcampEvent.Update_Trainingcamp_Tips_Event, function (  )
        if self.data then
            _controller:openTrainingcampTipsWindow(true,self.data)
        end
    end)

    -- 显示提示关闭特效
    self:addGlobalEvent(TrainingcampEvent.Show_Close_Effect_Event, function (  )
        self:showColseEffect(true)
    end)

    -- 是否显示手指特效
    self:addGlobalEvent(TrainingcampEvent.Is_Show_Formation_Event, function ( is_show )
        if self.data.id == 7 and is_show == 0 then --阵法
            self:showGuideEffect(true,self.form_change_btn)
        else
            self:showGuideEffect(false)
        end
    end)
    
    -- 更新界面显示
    self:addGlobalEvent(TrainingcampEvent.Update_Trainingcamp_Data_Event, function (  )
        self:updateFinish()
    end)

end

-- 关闭
function TrainingcampMainWindow:onClickCloseBtn(  )
    _controller:openTrainingcampMainWindow(false)
end

--光环
function TrainingcampMainWindow:onClickHaloBtn()
    BattleController:getInstance():openBattleCampView(true, self.halo_form_id_list)
end

--更换阵法
function TrainingcampMainWindow:onClickFormChangeBtn()
    if not self.formation_type then return end

    if self.data and self.data.id == 7 then
        _controller:send27603(self.data.id)
    end
    
    self:showGuideEffect(false)
    HeroController:getInstance():openFormationSelectPanel(true, self.formation_type, function(formation_type)
        if formation_type and not tolua.isnull(self.root_wnd) then
            self.formation_type = formation_type
            local formation_config = Config.FormationData.data_form_data[self.formation_type]
            if formation_config then
                self:initFormationData(formation_config)
            end
            self:updateFormationIcon()
        end
    end,999)
end

--提示信息
function TrainingcampMainWindow:onClickTipsBtn()
    if self.data then
        _controller:openTrainingcampTipsWindow(true,self.data)
    end
end

--发送布阵
function TrainingcampMainWindow:onFightDrama()
    if self.data == nil then
        return
    end
    local pos_info = {}
    for i,v in pairs(self.five_hero_vo) do
        local d = {}
        d.pos = i
        d.id = v.id
        table_insert(pos_info, d)
    end

    if #pos_info == 0 then
        message(TI18N("请选择关卡英雄"))
        return
    end
    
    _controller:send27601(self.data.id, self.formation_type, pos_info)
    
end

--更新阵法item
function TrainingcampMainWindow:updateFormationIcon()
    if not self.formation_type  then return end

    local res = PathTool.getResFrame("form", "form_icon_"..self.formation_type)
    loadSpriteTexture(self.form_icon, res, LOADTEXT_TYPE_PLIST)
    self:updateFormIcon(self.up_left_team_info, self.formation_type)
end

--点击5个英雄Item move
function TrainingcampMainWindow:onClickHeroItemMove(index, sender)
    --判断是否有移动
    self.is_move_hero = true

    if self.move_hero_item == nil then
        self.move_hero_item = HeroExhibitionItem.new(0.9, false)
        self.left_panel:addChild(self.move_hero_item, 1)
    end
    self.move_hero_item:setData(self.five_hero_vo[index])
    self.hero_item_list[index]:setData(nil)


    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.left_panel:convertToNodeSpace(touch_pos) 
    self.move_hero_item:setPosition(target_pos)
end

--点击5个英雄Item Cancel
function TrainingcampMainWindow:onClickHeroItemCanceled(index, sender)
    self.is_move_hero = false
    if self.move_hero_item then
        --相当于隐藏
        self.move_hero_item:setPosition(-10000, 0)
    end
    
    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.left_panel:convertToNodeSpace(touch_pos)
    for i,rect in ipairs(self.pos_rect_list) do
        if cc.rectContainsPoint( rect, target_pos ) then
            for k,pos in ipairs(self.ban_pos_list) do --禁止位置不可设置
                if i == pos then
                    self.hero_item_list[index]:setData(self.five_hero_vo[index])
                    return
                end
            end

            if i ~= index then
                --转换
                self.hero_item_list[i]:setData(self.five_hero_vo[index])
                local temp_hero_vo = self.five_hero_vo[i]
                self.five_hero_vo[i] = self.five_hero_vo[index]

                if temp_hero_vo ~= nil then
                    self.hero_item_list[index]:setData(temp_hero_vo)
                    self.five_hero_vo[index] = temp_hero_vo
                else
                    self.hero_item_list[index]:setData(nil)
                    self.five_hero_vo[index] = nil
                end

                return
            else
                --点自己是下阵了 
                --这里系统直接执行 self:onClickHeroItemEnd()方法了
            end
        end
    end

    self.hero_item_list[index]:setData(self.five_hero_vo[index])

end

--点击5个英雄Item end
function TrainingcampMainWindow:onClickHeroItemEnd(index, sender)
    if self.move_hero_item then
        --相当于隐藏
        self.move_hero_item:setPosition(-10000, 0)
    end
    --说明是点击了 item 下阵
    if self.list_view then
        local item_list = self.list_view:getActiveCellList() or {}
        for i,item in ipairs(item_list) do
            local hero_vo = item:getData()

            if self.five_hero_vo[index] and hero_vo and hero_vo.bid == self.five_hero_vo[index].bid then
                hero_vo.is_ui_select = false
                item:setSelected(hero_vo.is_ui_select)
                --结束位置 
                local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
                local end_pos = self.left_panel:convertToNodeSpace(world_pos) 
                local x, y =  self.hero_item_list[index]:getPosition()
                self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)

                self.hero_item_list[index]:setData(nil)
                self.five_hero_vo[index] = nil
                self:calculateCampHaloType()
                return
            elseif self.five_hero_vo[index] then
                self.hero_item_list[index]:setData(self.five_hero_vo[index])
            end
        end
        if #item_list<=0 then
            self.hero_item_list[index]:setData(self.five_hero_vo[index])
        end
    end
end


function TrainingcampMainWindow:setData()
    if self.data == nil then
        return
    end

    self.title_name:setString(self.data.name)
    self.txt_lab:setString(self.data.tips)
    self.ban_pos_list = self.data.ban_pos
    
    local res = PathTool.getResFrame("trainingcamp", "trainingcamp_6")
    for i,v in ipairs(self.hero_item_list) do
        for k,pos in ipairs(self.ban_pos_list) do
            if i == pos then
                v:setDefaultHeadByRes(res,1.3)
                break
            end
        end
    end

    local config = Config.UnitData.data_unit(self.data.target_id)
    if config then
        self:updateOrderTeamInfo(config)
    end

    local formation_config = Config.FormationData.data_form_data[1]
    self.formation_type = 1
    if self.data.formation>0 then
        formation_config = Config.FormationData.data_form_data[self.data.formation]
        self.formation_type = self.data.formation 
    end
    self:initFormationData(formation_config)
    self:updateFormationIcon()
    if self.data.flag == 0 then -- 是否可变阵法
        self.form_change_btn:setVisible(false)
    else
        self.form_change_btn:setVisible(true)
    end

    self:updateFinish()
    self:updateHeroList()
    self:calculateCampHaloType()
end

function TrainingcampMainWindow:updateFinish()
    if not self.data or not self.finish_img then
        return
    end
    local isFinish =  _model:IsFinishById(self.data.id)
    self.finish_img:setVisible(isFinish)
end
---------------------------我的队伍信息------------------------------

--创建cell 
function TrainingcampMainWindow:createNewCell()
    local cell = HeroExhibitionItem.new(0.9, true)
    cell.from_type = HeroConst.ExhibitionItemType.eFormFight
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

--获取数据数量
function TrainingcampMainWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function TrainingcampMainWindow:updateCellByIndex(cell, index)
    cell.index = index
    local hero_vo = self.show_list[index]
    
    cell:setData(hero_vo)
end

--点击cell .需要在 createNewCell 设置点击事件
function TrainingcampMainWindow:onCellTouched(cell)
    local index = cell.index
    local hero_vo = self.show_list[index]
    if hero_vo then
        self:selectHero(cell, hero_vo)
    end
end

--创建英雄列表 
function TrainingcampMainWindow:updateHeroList()
    if self.data == nil then return end
    --英雄列表 (默认)
    local hero_array = self.data.partner_id
    local show_list = {}
    for i,v in ipairs(hero_array) do
        local config = Config.UnitData.data_unit(v)
        if config then
            local config2 = Config.UnitData.data_unit(config.monster3)
            if config2 then
                hero_vo = HeroVo.New()
                hero_vo.bid = tonumber(config2.head_icon)
                hero_vo.lev = config2.lev
                hero_vo.star = config2.star
                hero_vo.camp_type = config2.camp_type
                hero_vo.id = v
                hero_vo.is_required = false -- 是否必选不可下阵
                local base_config = Config.PartnerData.data_partner_base[hero_vo.bid]
                if base_config then
                    hero_vo.pos_type = base_config.pos_type
                end
                table_insert(show_list,hero_vo)
            end
        end
    end

    local sort_func = SortTools.tableUpperSorter({"star", "lev"})
    table.sort(show_list, sort_func)
    self.show_list = show_list
    
    if #show_list>0 then
        self.txt_lab_1:setVisible(false)
    else
        self.txt_lab_1:setVisible(true)
    end
    self.list_view:reloadData()

    local required_hero_array = self.data.required_partner
    for i,v in ipairs(required_hero_array) do
        local config = Config.UnitData.data_unit(v[1])
        if config then
            local config2 = Config.UnitData.data_unit(config.monster3)
            if config2 then
                hero_vo = HeroVo.New()
                hero_vo.bid = tonumber(config2.head_icon)
                hero_vo.lev = config2.lev
                hero_vo.star = config2.star
                hero_vo.camp_type = config2.camp_type
                hero_vo.is_required = true -- 是否必选不可下阵
                hero_vo.id = v[1]
                local base_config = Config.PartnerData.data_partner_base[hero_vo.bid]
                if base_config then
                    hero_vo.pos_type = base_config.pos_type
                end

                --新增
                local new_index = v[2]
                if self.hero_item_list and self.hero_item_list[new_index] then
                    self.five_hero_vo[new_index] = hero_vo
                    self.hero_item_list[new_index]:setData(self.five_hero_vo[new_index])
                    self:calculateCampHaloType()
                end
                hero_vo.is_ui_select = true
            end
        end
    end
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo then  
        self.up_left_team_info.role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    end
end

--@hero_vo 英雄数据
function TrainingcampMainWindow:selectHero(item, hero_vo)
    if not hero_vo  then return end
    if not item then return end
    if self.is_play_item_action then return end

    local index = -1
    for k,h_vo in pairs(self.five_hero_vo) do
        if (h_vo.bid == hero_vo.bid)then
            index = k
            break
        end
    end


    if index ~= -1 then
        if self.hero_item_list[index] == nil then return end
        --是选中的 下阵了
        hero_vo.is_ui_select = false
        item:setSelected(hero_vo.is_ui_select)
        --结束位置 
        local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
        local end_pos = self.up_panel:convertToNodeSpace(world_pos) 
        local x, y =  self.hero_item_list[index]:getPosition()

        self:showMoveEffect(cc.p(x,y), end_pos, hero_vo)
        self.hero_item_list[index]:setData(nil)
        self.five_hero_vo[index] = nil
        self:calculateCampHaloType()
    else
        local count = 0
        for i,v in pairs(self.five_hero_vo) do
            count = count + 1
        end
        if count >= 5 then
            message(TI18N("上阵人数已满"))
            return
        end


        for k,h_vo in pairs(self.five_hero_vo) do
            if h_vo.bid == hero_vo.bid then
                message(TI18N("不能同时上阵2个相同英雄"))
                return
            end
        end
        
        --新增
        local new_index = self:getTheBestPos(hero_vo)
        if new_index == nil then
            message(TI18N("没有上阵位置"))
            return
        end

        local world_pos = item:convertToWorldSpace(cc.p(HeroExhibitionItem.Width * 0.5, HeroExhibitionItem.Height * 0.5))    
        local start_pos = self.up_panel:convertToNodeSpace(world_pos) 
        local x, y =  self.hero_item_list[new_index]:getPosition()
        self:showMoveEffect(start_pos, cc.p(x,y), hero_vo, function()
            if self.hero_item_list and self.hero_item_list[new_index] then
                self.five_hero_vo[new_index] = hero_vo
                self.hero_item_list[new_index]:setData(self.five_hero_vo[new_index])
                self:calculateCampHaloType()
            end
        end)
        hero_vo.is_ui_select = true
        item:setSelected(hero_vo.is_ui_select)
    end
end

function TrainingcampMainWindow:getTheBestPos(hero_vo)
    if not self.five_hero_vo then return end
    if hero_vo.pos_type == 1 then
        --1的默认是从1 找到3
    elseif hero_vo.pos_type == 3 then
        local lenght = #self.pos_name_list
        --从3往2往1找
        for i=lenght , 1, -1 do
            if self.five_hero_vo[i] == nil then
                local isOpen = true
                for k,pos in ipairs(self.ban_pos_list) do
                    if i == pos then
                        isOpen = false
                    end
                end
                if isOpen == true then
                    return i    
                end
            end 
        end
    else --中间位置的
        --先找2的
        for i,pos in ipairs(self.pos_name_list) do
            if pos == hero_vo.pos_type then
                if self.five_hero_vo[i] == nil then
                    local isOpen = true
                    for k,pos in ipairs(self.ban_pos_list) do
                        if i == pos then
                            isOpen = false
                        end
                    end
                    if isOpen == true then
                        return i    
                    end
                end 
            end
        end
    end
    --上面没有从1 找到3
    for i,v in ipairs(self.pos_name_list) do
        if self.five_hero_vo[i] == nil then
            local isOpen = true
            for k,pos in ipairs(self.ban_pos_list) do
                if i == pos then
                    isOpen = false
                end
            end
            if isOpen == true then
                return i    
            end
        end 
    end
    return nil
end

function TrainingcampMainWindow:initFormationData(formation_config)
    if not formation_config then return end

    local dic_pos_index = {}
    self.pos_name_list = {}
    self.pos_rect_list = {}
    local width = self.cell_width - 10
    for i,v in ipairs(formation_config.pos) do
        local index = v[1] 
        local pos = v[2] 
        dic_pos_index[pos] = index
        --更新位置
        if self.hero_item_list[index] and self.up_left_team_info then
            self.hero_item_list[index]:setPosition(self.up_left_team_info.pos_list[pos])
        end
        if pos <= 3 then
            self.pos_name_list[index] = 1 --位置 前
        elseif pos > 3 and pos <= 6 then
            self.pos_name_list[index] = 2 --位置 中
        else
            self.pos_name_list[index] = 3 --位置 后
        end

        if self.up_left_team_info then
            local x = self.up_left_team_info.pos_list[pos].x
            local y = self.up_left_team_info.pos_list[pos].y
            local rect = cc.rect( x - width*0.5 ,y - width*0.5 , width, width)
            self.pos_rect_list[index] = rect
        end
    end
end

--显示移动效果
--@start_pos 开始位置 
--@end_pos 结束位置
function TrainingcampMainWindow:showMoveEffect(start_pos, end_pos, hero_vo, callback)
    self.is_play_item_action = true
    if self.move_hero_item == nil then
        self.move_hero_item = HeroExhibitionItem.new(0.9, false)
        self.left_panel:addChild(self.move_hero_item, 1)
    end
    self.move_hero_item:setData(hero_vo)
    self.move_hero_item:setPosition(start_pos)
    local action1 = cc.MoveTo:create(0.2, end_pos)
    local callfunc = cc.CallFunc:create(function()
        if self.move_hero_item then
            self.move_hero_item:setPosition(-10000, 0)
        end
        self.is_play_item_action = false
        if callback then
            callback()
        end
    end)
    self.move_hero_item:runAction(cc.Sequence:create(action1,callfunc))
end


--计算阵型icon
function TrainingcampMainWindow:calculateCampHaloType()
    local dic_camp = {}
    for i,v in pairs(self.five_hero_vo) do
        if v.camp_type ~= nil then
            if dic_camp[v.camp_type] == nil then
                dic_camp[v.camp_type] = 1
            else
                dic_camp[v.camp_type] = dic_camp[v.camp_type] + 1
            end
        end
    end
    if self.halo_icon_load then
        self.halo_icon_load:DeleteMe()
        self.halo_icon_load = nil
    end
    self.halo_form_id_list = BattleController:getInstance():getModel():getFormIdListByCamp(dic_camp)
    local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(self.halo_form_id_list)
    if halo_icon_config then
        local halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
        self.halo_icon_load = loadImageTextureFromCDN(self.halo_btn, halo_res, ResourcesType.single, self.halo_icon_load)
        addCountForCampIcon(self.halo_btn, halo_icon_config.nums)
        self.halo_label:setString("")
    else
        local halo_res = PathTool.getCampGroupIcon(1000)        
        self.halo_icon_load = loadImageTextureFromCDN(self.halo_btn, halo_res, ResourcesType.single, self.halo_icon_load)
        addCountForCampIcon(self.halo_btn)
        self.halo_label:setString(TI18N("属性"))
    end
end
------------------------------敌方队伍信息---------------------------------

--更新敌方信息
function TrainingcampMainWindow:updateOrderTeamInfo(data)
    local up_team_info = self.up_right_team_info
    self.my_team_right_scdata = data
    
    self:updateFormIcon(up_team_info, data.formation[1])
    local pos_info = {}
    local monster = 0
    for i=1,5 do
        local info = data["monster"..i]
        if info then
            table_insert(pos_info, {pos = i,id = info})
            if monster == 0 then
                monster = info
            end
        end
    end
    self:updateHeroInfo(up_team_info, pos_info, data.formation[1])
    
    local config = Config.UnitData.data_unit(monster)
    if config then
        local res = PathTool.getHeadIcon(config.head_icon)
        up_team_info.role_head:setHeadRes(res,true)
    end
end

--更新队伍阵法icon 
--@team_info 结构 对应  self.up_left_team_info self.up_left_team_info 这些
--@formation_type 阵法类型
function TrainingcampMainWindow:updateFormIcon(team_info,formation_type)
    if not team_info then return end
        --阵法
    if formation_type then
        if formation_type < 1 then
            formation_type = 1
        end
        if formation_type > 6 then
            formation_type = 6
        end
        local res = PathTool.getResFrame("elitematch_matching", "elitematch_form_icon_"..formation_type)
        loadSpriteTexture(team_info.form_icon, res, LOADTEXT_TYPE_PLIST)
    end
end

--更新英雄信息
--@team_info 结构 对应  self.up_left_team_info self.up_left_team_info 这些
--@pos_info 队伍信息
--@formation_type 阵法类型
function TrainingcampMainWindow:updateHeroInfo(team_info, pos_info, formation_type)
    if not team_info then return end
    --队伍位置
    local formation_config = Config.FormationData.data_form_data[formation_type]
    if formation_config then
        
        --转换位置信息
        local dic_pos_info = {}
        for k,v in pairs(pos_info) do
            dic_pos_info[v.pos] = v
        end

        for k,item in pairs(team_info.hero_item_list) do
            item:setVisible(false)
        end
        for i,v in ipairs(formation_config.pos) do
            local index = v[1] 
            local pos = v[2] 
            local hero_vo 
            if dic_pos_info[index] then
                local config = Config.UnitData.data_unit(dic_pos_info[index].id)
                if config then
                    hero_vo = HeroVo.New()
                    hero_vo.bid = tonumber(config.head_icon)
                    hero_vo.lev = config.lev
                    hero_vo.star = config.star
                    hero_vo.camp_type = config.camp_type
                end
            end
         
            
            --更新位置
            if team_info.hero_item_list[index] == nil then
                team_info.hero_item_list[index] = HeroExhibitionItem.new(0.7, false)
                team_info.panel:addChild(team_info.hero_item_list[index])
            else
                team_info.hero_item_list[index]:setVisible(true)
            end
            team_info.hero_item_list[index]:setPosition(team_info.pos_list[pos])
            if hero_vo then
                team_info.hero_item_list[index]:setData(hero_vo)
                team_info.hero_item_list[index]:addCallBack(function()
                    HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
                end)
            else
                team_info.hero_item_list[index]:setData(nil)
            end
        end
    end
end

--提示按钮关闭特效
function TrainingcampMainWindow:showColseEffect(bool)
    if bool == true then
        if not self.tips_btn_effect then
            self.tips_btn_effect = createEffectSpine("E27151", cc.p(self.tips_btn:getContentSize().width/2, self.tips_btn:getContentSize().height/2), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.tips_btn:addChild(self.tips_btn_effect, 1)
        else
            self.tips_btn_effect:setAnimation(0, PlayerAction.action, false)
        end
    else
        if self.tips_btn_effect then 
            self.tips_btn_effect:removeFromParent()
            self.tips_btn_effect = nil
        end
    end
end

--引导特效
function TrainingcampMainWindow:showGuideEffect(bool,panel)
    if bool == true then
        if not self.guide_effect_1 then
            if panel then
                self.guide_effect_1 = createEffectSpine(PathTool.getEffectRes(198), cc.p(panel:getContentSize().width/2, panel:getContentSize().height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
                panel:addChild(self.guide_effect_1, 1)    
            end
        else
            self.guide_effect_1:setAnimation(0, PlayerAction.action, true)
        end

        if not self.guide_effect_2 then
            if panel then
                self.guide_effect_2 = createEffectSpine(PathTool.getEffectRes(240), cc.p(panel:getContentSize().width/2, panel:getContentSize().height/2), cc.p(0.5, 0.5), true, PlayerAction.action_1)
                panel:addChild(self.guide_effect_2, 1)    
            end
        else
            self.guide_effect_2:setAnimation(0, PlayerAction.action_1, true)
        end
    else
        if self.guide_effect_1 then 
            self.guide_effect_1:removeFromParent()
            self.guide_effect_1 = nil
        end

        if self.guide_effect_2 then 
            self.guide_effect_2:removeFromParent()
            self.guide_effect_2 = nil
        end
    end
end

function TrainingcampMainWindow:openRootWnd(data)
    self.data = data
    if data then
        _controller:send27602(self.data.id)
    end
    
    self:setData()
end



function TrainingcampMainWindow:close_callback()
    self:showColseEffect(false)
    self:showGuideEffect(false)
    if self.up_right_team_info then
        if self.up_right_team_info.role_head then
            self.up_right_team_info.role_head:DeleteMe()
            self.up_right_team_info.role_head = nil    
        end

        if self.up_right_team_info.hero_item_list then
            for i,v in ipairs(self.up_right_team_info.hero_item_list) do
                v:DeleteMe()
            end 
            self.up_right_team_info.hero_item_list = {}
        end

        self.hero_item_list = {}
        self.up_right_team_info = nil
    end

    if self.up_left_team_info then
        if self.up_left_team_info.role_head then
            self.up_left_team_info.role_head:DeleteMe()
            self.up_left_team_info.role_head = nil    
        end

        if self.up_left_team_info.hero_item_list then
            for i,v in ipairs(self.up_left_team_info.hero_item_list) do
                v:DeleteMe()
            end 
            self.up_left_team_info.hero_item_list = {}
        end

        self.hero_item_list = {}
        self.up_left_team_info = nil
    end

    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
            v:DeleteMe()
        end
        self.hero_item_list = {}
    end

    if self.move_hero_item then
        self.move_hero_item:stopAllActions()
        if self.move_hero_item.DeleteMe then
            self.move_hero_item:DeleteMe()
        end
        self.move_hero_item = nil
    end
    

    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end

    if self.halo_icon_load then
        self.halo_icon_load:DeleteMe()
        self.halo_icon_load = nil
    end

    _controller:openTrainingcampMainWindow(false)
end