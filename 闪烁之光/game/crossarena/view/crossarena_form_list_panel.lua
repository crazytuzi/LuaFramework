--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-13 14:58:14
-- @description    : 
		-- 跨服竞技场布阵总览
---------------------------------
local _hero_controller = HeroController:getInstance()
local _hero_model = _hero_controller:getModel()
local _table_insert = table.insert

CorssarenaFormListPanel = CorssarenaFormListPanel or BaseClass()

function CorssarenaFormListPanel:__init(parent, super_panel, form_show_type, fun_form_type)
    self.is_init = true
    self.parent = parent
    self.super_panel = super_panel
    self.form_show_type = form_show_type
    self.fun_form_type = fun_form_type
    self.team_panel_list = {}
    self.halo_load_list = {}
    self.is_move_hero = false -- move_item 正在跟随手指移动中
    self.is_show_act = false  -- move_item 是否在移动动作中

    -- 是否可以勾选两队
    self.hide_two_team = CrossarenaController:getInstance():getModel():checkIsCanHideTwoTeam()

    self:createRoorWnd()
    self:registerEvent()
end

function CorssarenaFormListPanel:createRoorWnd(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("crossarena/crossarena_form_list_panel"))
    if not tolua.isnull(self.parent) then
        self.root_wnd:setPosition(cc.p(-5, -138))
        self.parent:addChild(self.root_wnd)
    end

    self.container = self.root_wnd:getChildByName("container")

    local start_x = 78
    for i=1,3 do
    	local team_panel = self.container:getChildByName("team_panel_" .. i)
    	if team_panel then
            local box_name = team_panel:getChildByName("box_name")
    		box_name:setString(TI18N("隐藏"))
    		team_panel:getChildByName("team_name"):setString(TI18N("队伍" .. StringUtil.numToChinese(i)))
    		local object = {}
            object.box_name = box_name
            object.team_panel = team_panel
    		object.halo_btn = team_panel:getChildByName("halo_btn")
            object.formation_type = 1 -- 阵法类型(默认为锋矢阵)
    		object.form_icon = team_panel:getChildByName("form_icon")
    		object.hide_btn = team_panel:getChildByName("hide_btn")
            object.hide_status = false
            if i == 3 then
                object.hide_status = true
            end
            object.hide_btn:setSelected(object.hide_status)
            
    		object.power_txt = team_panel:getChildByName("power_txt")
            object.hallows_id = 0 -- 神器id
            object.hallow_item = BackPackItem.new(false, true, false, 0.6)
            object.hallow_item:addCallBack(function (  )
                self:onClickHallowBtn(object.hallows_id, i)
            end)
            object.hallow_item:showAddIcon(true)
            object.hallow_item:setPosition(cc.p(590, 58))
            team_panel:addChild(object.hallow_item)
            object.hero_item_list = {}
            object.item_rect_list = {} -- 记录一下item的区域
            for k=1,5 do
                local hero_item = HeroExhibitionItem.new(0.7, true, nil, false)
                local pos_x = start_x+(k-1)*(HeroExhibitionItem.Width*0.7+10)
                local pos_y = 52
                hero_item:setPosition(cc.p(pos_x, pos_y))
                team_panel:addChild(hero_item)
                _table_insert(object.hero_item_list, hero_item)
                local world_pos = hero_item:convertToWorldSpace(cc.p(0, 0))
                local node_pos = self.container:convertToNodeSpace(world_pos)
                _table_insert(object.item_rect_list, cc.rect( node_pos.x, node_pos.y, HeroExhibitionItem.Width*0.7, HeroExhibitionItem.Height*0.7))
            end

            if self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
                object.box_name:setVisible(false)
                object.hide_btn:setVisible(false)
                if i == 3 then
                    local str = TI18N("第三队隐藏")
                    object.three_label = createLabel(22,cc.c4b(0x68,0x45,0x2A,0xff),nil,636,124,str,team_panel,nil, cc.p(1, 0.5))
                end
            else
                object.box_name:setVisible(self.form_show_type == HeroConst.FormShowType.eFormSave)
                object.hide_btn:setVisible(self.form_show_type == HeroConst.FormShowType.eFormSave)
            end
    		_table_insert(self.team_panel_list, object)
    	end
    end

    self.change_pos_btn_1 = self.container:getChildByName("change_pos_btn_1")
    self.change_pos_btn_2 = self.container:getChildByName("change_pos_btn_2")
    self.save_btn = self.container:getChildByName("save_btn")
    self.save_btn:getChildByName("label"):setString(TI18N("保存布阵"))
    self.go_fight_btn = self.container:getChildByName("go_fight_btn")
    self.go_fight_btn:getChildByName("label"):setString(TI18N("开战"))

    self.save_btn:setVisible(not (self.form_show_type == HeroConst.FormShowType.eFormFight))
    self.go_fight_btn:setVisible(self.form_show_type == HeroConst.FormShowType.eFormFight)

    self:updateAllTeamInfo()
end

function CorssarenaFormListPanel:registerEvent(  )
	registerButtonEventListener(self.change_pos_btn_1, function (  )
		self:onChangePosBtn(1)
	end, true)

	registerButtonEventListener(self.change_pos_btn_2, function (  )
		self:onChangePosBtn(2)
	end, true)

	registerButtonEventListener(self.save_btn, handler(self, self.onClickSaveBtn), true)

	registerButtonEventListener(self.go_fight_btn, handler(self, self.onClickGoFightBtn), true)

    self.long_touch_type = LONG_TOUCH_INIT_TYPE
	for i,object in ipairs(self.team_panel_list) do
		if object.hide_btn then
			object.hide_btn:addEventListener(function ( sender,event_type )
		        if event_type == ccui.CheckBoxEventType.selected then
		            playButtonSound2()
		            self:onSelectHideBox(i)
		        elseif event_type == ccui.CheckBoxEventType.unselected then 
		            playButtonSound2()
                    if self.hide_two_team then
                        local hide_count = self:getHideTeamCount()
                        if hide_count <= 1 then
                            object.hide_btn:setSelected(true)
                            message(TI18N("无法取消隐藏哦"))
                        else
                            object.hide_status = false
                        end
                    else
                        object.hide_btn:setSelected(true)
                        message(TI18N("无法取消隐藏哦"))
                    end
		        end
		    end)
		end
        if object.hero_item_list then
            for k,item in pairs(object.hero_item_list) do
                item:addTouchEventListener(function(sender, event_type)
                    if self.is_show_act == true then return end
                    local hero_vo = item:getData()
                    if not hero_vo and not self.is_move_hero then return end
                    if event_type == ccui.TouchEventType.began then
                        self.touch_move = false
                        self.is_move_hero = false
                        self.touch_began = sender:getTouchBeganPosition()

                        --长点击逻辑 --by lwc
                        doStopAllActions(self.container)
                        self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
                        delayRun(self.container, 0.6, function ()
                            if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                                if hero_vo then
                                    HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
                                end
                            end
                            self.long_touch_type = LONG_TOUCH_END_TYPE
                        end)
                    elseif event_type == ccui.TouchEventType.moved then
                        if self.long_touch_type == LONG_TOUCH_END_TYPE then
                            --事件触发了就不处理移动事件了
                            return 
                        elseif self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            local touch_began = self.touch_began
                            local touch_move = sender:getTouchMovePosition()
                            if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                                --移动大于20了..表示取消长点击效果
                                doStopAllActions(self.container)
                                self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                            end 
                        end

                        self.touch_move = true
                        self.is_move_hero = true
                        self:onClickHeroItemMove(sender, hero_vo)
                    elseif event_type == ccui.TouchEventType.canceled then
                        if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            doStopAllActions(self.container)
                            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                        elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                            --事件触发了就不处理点击事件了
                            if self.move_hero_item then
                                self.move_hero_item:setPosition(-10000, 0)
                            end
                            if self.move_hero_vo then
                                sender:setData(self.move_hero_vo)
                                self.move_hero_vo = nil
                            end
                            return
                        end
                        self.is_move_hero = false
                        self:onClickHeroItemCanceled(sender)
                    elseif event_type == ccui.TouchEventType.ended then
                        if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            doStopAllActions(self.main_container)
                            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                        elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                            --事件触发了就不处理点击事件了
                            if self.move_hero_item then
                                self.move_hero_item:setPosition(-10000, 0)
                            end
                            if self.move_hero_vo then
                                sender:setData(self.move_hero_vo)
                                self.move_hero_vo = nil
                            end
                            return
                        end

                        self.is_move_hero = false
                        self.touch_end = sender:getTouchEndPosition()
                        local is_click = true
                        if self.touch_began ~= nil then
                            is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
                        end
                        if self.touch_move then
                            if is_click then -- 一定小范围内的移动算作点击
                                self.move_hero_item:setData()
                                self.move_hero_item:setPosition(cc.p(-1000, -1000))
                                if self.move_hero_vo then
                                    sender:setData(self.move_hero_vo)
                                    self.move_hero_vo = nil
                                end
                                self:onClickHeroItem(i, k)
                            else
                                self:onClickHeroItemEnd(sender)
                            end
                        else
                            self:onClickHeroItem(i, k)
                        end
                    end
                end)
            end
        end
	end

    if self.save_crossarena_form_event == nil then
        self.save_crossarena_form_event = GlobalEvent:getInstance():Bind(CrossarenaEvent.Save_Crossarena_Form_Event, function()
            
        end)
    end
end

--设置战斗类型
function CorssarenaFormListPanel:setFunFormType(fun_form_type)
    self.fun_form_type = fun_form_type

    for i,object in ipairs(self.team_panel_list) do
        if self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then
            object.box_name:setVisible(false)
            object.hide_btn:setVisible(false)
            if i == 3 then
                if object.three_label == nil then
                    local str = TI18N("第三队隐藏")
                    object.three_label = createLabel(22,cc.c4b(0x68,0x45,0x2A,0xff),nil,636,124,str,object.team_panel,nil, cc.p(1, 0.5)) 
                else
                    object.three_label:setVisible(true)
                end
            end
        else
            object.box_name:setVisible(self.form_show_type == HeroConst.FormShowType.eFormSave)
            object.hide_btn:setVisible(self.form_show_type == HeroConst.FormShowType.eFormSave)
            if i == 3 and object.three_label then
                object.three_label:setVisible(false)
            end
        end
    end
end


-- 选择了某一个隐藏按钮
function CorssarenaFormListPanel:onSelectHideBox( index )
    if self.hide_two_team == true then
        local hide_count = self:getHideTeamCount()
        -- 如果已经隐藏了两队，那么从1-3，取消隐藏最靠前的队伍
        if hide_count >= 2 then
            for i,object in ipairs(self.team_panel_list) do
                if object.hide_btn and object.hide_status == true then
                    object.hide_status = false
                    object.hide_btn:setSelected(false)
                    break
                end
            end
        end
        for i,object in ipairs(self.team_panel_list) do
            if object.hide_btn and i == index then
                object.hide_status = true
                object.hide_btn:setSelected(true)
            end
        end
    else
        for i,object in ipairs(self.team_panel_list) do
            if object.hide_btn then
                object.hide_status = (index == i)
                object.hide_btn:setSelected(index == i)
            end
        end
    end
end

-- 当前勾选了几队
function CorssarenaFormListPanel:getHideTeamCount(  )
    local hide_count = 0
    for k,object in pairs(self.team_panel_list) do
        if object.hide_status == true then
            hide_count = hide_count + 1
        end
    end
    return hide_count
end

-- 切换位置
function CorssarenaFormListPanel:onChangePosBtn( index )
	if index == 1 then
        local team_object_1 = self.team_panel_list[1]
        local team_object_2 = self.team_panel_list[2]
        if team_object_1 and team_object_2 then
            -- 阵法
            local temp_formation_type = team_object_1.formation_type
            team_object_1.formation_type = team_object_2.formation_type
            team_object_2.formation_type = temp_formation_type

            local temp_old_order = team_object_1.old_order
            team_object_1.old_order = team_object_2.old_order
            team_object_2.old_order = temp_old_order

            -- 神器
            local temp_hallow_id = team_object_1.hallows_id
            team_object_1.hallows_id = team_object_2.hallows_id
            team_object_2.hallows_id = temp_hallow_id

            -- 英雄
            for i=1,5 do
                local hero_item_1 = team_object_1.hero_item_list[i]
                local hero_item_2 = team_object_2.hero_item_list[i]
                local hero_vo_1 = hero_item_1:getData()
                local hero_vo_2 = hero_item_2:getData()
                hero_item_1:setData(hero_vo_2)
                hero_item_2:setData(hero_vo_1)
            end

            self:updateTeamInfo(1, true)
            self:updateTeamInfo(2, true)
        end
	elseif index == 2 then
        local team_object_2 = self.team_panel_list[2]
        local team_object_3 = self.team_panel_list[3]
        if team_object_2 and team_object_3 then
            -- 阵法
            local temp_formation_type = team_object_2.formation_type
            team_object_2.formation_type = team_object_3.formation_type
            team_object_3.formation_type = temp_formation_type

            local temp_old_order = team_object_2.old_order
            team_object_2.old_order = team_object_3.old_order
            team_object_3.old_order = temp_old_order

            -- 神器
            local temp_hallow_id = team_object_2.hallows_id
            team_object_2.hallows_id = team_object_3.hallows_id
            team_object_3.hallows_id = temp_hallow_id

            -- 英雄
            for i=1,5 do
                local hero_item_2 = team_object_2.hero_item_list[i]
                local hero_item_3 = team_object_3.hero_item_list[i]
                local hero_vo_2 = hero_item_2:getData()
                local hero_vo_3 = hero_item_3:getData()
                hero_item_2:setData(hero_vo_3)
                hero_item_3:setData(hero_vo_2)
            end

            self:updateTeamInfo(2, true)
            self:updateTeamInfo(3, true)
        end
	end
end

-- 选择神器
function CorssarenaFormListPanel:onClickHallowBtn( cur_hallow_id, index )
    local dic_equips = {}
    for i,object in ipairs(self.team_panel_list) do
        if object.hallows_id and object.hallows_id ~= 0 then
            dic_equips[object.hallows_id] = i
        end
    end

    _hero_controller:openFormHallowsSelectPanel(true, cur_hallow_id, function(hallows_id, team_index)
        local team_object = self.team_panel_list[team_index]
        if hallows_id and team_object then
            -- 判断一下是否有替换掉其他两个队伍的神器
            for i,object in ipairs(self.team_panel_list) do
                if object.hallows_id == hallows_id then
                    object.hallows_id = 0
                    object.hallow_item:setData()
                    object.hallow_item:showAddIcon(true)
                    break
                end
            end
            if hallows_id == 0 then
                team_object.hallows_id = 0
                team_object.hallow_item:setData()
                team_object.hallow_item:showAddIcon(true)
            else
                -- 更新选中的神器显示
                local hallows_config = Config.HallowsData.data_base[hallows_id]
                if not hallows_config  then return end
                team_object.hallows_id = hallows_id
                team_object.hallow_item:showAddIcon(false)
                local hallows_vo = HallowsController:getInstance():getModel():getHallowsById(hallows_id)
                if hallows_vo and hallows_vo.look_id ~= 0 then
                    local magic_cfg = Config.HallowsData.data_magic[hallows_vo.look_id]
                    if magic_cfg then
                        team_object.hallow_item:setBaseData(magic_cfg.item_id)
                        team_object.hallow_item:setMagicIcon(true)
                    else
                        team_object.hallow_item:setBaseData(hallows_config.item_id)
                        team_object.hallow_item:setMagicIcon(false)
                    end
                else
                    team_object.hallow_item:setBaseData(hallows_config.item_id)
                    team_object.hallow_item:setMagicIcon(false)
                end
            end
        end
    end, dic_equips, index)
end

-- 保存布阵
function CorssarenaFormListPanel:onClickSaveBtn(  )
	local _type = 2
    if self.form_show_type == HeroConst.FormShowType.eFormFight then
        _type = 1
    end
    local team_data_list = self:getData()
    table.remove(team_data_list, 1)
    local temp_num = 0
    for k,v in pairs(team_data_list) do
        if v.pos_info and next(v.pos_info) ~= nil then
            temp_num = temp_num + 1
        end
    end
    if temp_num < 2 then
        message(TI18N("至少需2个队伍有英雄上阵"))
        return
    end




    if self.fun_form_type ~= PartnerConst.Fun_Form.ArenapeakchampionDef then
        -- 是否符合隐藏队伍要求
        local hide_count = self:getHideTeamCount()
        if CrossarenaController:getInstance():getModel():checkIsCanHideTwoTeam() and hide_count ~= 2 then
            local hide_cfg = Config.ArenaClusterData.data_const["second_hide_rank"]
            if hide_cfg then
                message(string.format(TI18N("前%d名的玩家需要隐藏2队哦~"), hide_cfg.val))
            end
            return
        end
        self:setSendUndateEflin(team_data_list)
        CrossarenaController:getInstance():sender25604( _type, team_data_list )
        -- HeroController:getInstance():openFormGoFightPanel(false)
    else
        for i,v in ipairs(team_data_list) do
            v.is_hidden = nil
        end
        self:setSendUndateEflin(team_data_list)
        ArenapeakchampionController:getInstance():sender27725(team_data_list)
    end
end

function CorssarenaFormListPanel:setSendUndateEflin(team_data_list)
    team_data_list = team_data_list or {}
    local elfin_team_list = {}
    for i,v in ipairs(team_data_list) do
        if v.old_order == nil then
            _table_insert(elfin_team_list, {team = v.order, old_team = v.order})
        else
            _table_insert(elfin_team_list, {team = v.order, old_team = v.old_order})
        end
        v.old_order = nil
    end

    for k,v in pairs(self.team_panel_list) do
        v.old_order = nil
    end
    ElfinController:getInstance():send26564(self.fun_form_type, elfin_team_list)
end

-- 出战
function CorssarenaFormListPanel:onClickGoFightBtn(  )
    if self.fun_form_type == PartnerConst.Fun_Form.ArenapeakchampionDef then return end

	local _type = 2
    if self.form_show_type == HeroConst.FormShowType.eFormFight then
        _type = 1
    end
    local team_data_list = self:getData()
    table.remove(team_data_list, 1)
    local temp_num = 0
    for k,v in pairs(team_data_list) do
        if v.pos_info and next(v.pos_info) ~= nil then
            temp_num = temp_num + 1
        end
    end
    if temp_num < 2 then
        message(TI18N("至少需2个队伍有英雄上阵"))
        return
    end
    self:setSendUndateEflin(team_data_list)
    CrossarenaController:getInstance():sender25604( _type, team_data_list )
end

function CorssarenaFormListPanel:setData( data )
    if not data then return end
	self.team_data_list = data

    for index,object in ipairs(self.team_panel_list) do
        local team_data = self:getTeamDataByIndex(index)
        if team_data then
            -- 给每个item设置站位数据(站位数据是固定的)
            for i,item in ipairs(object.hero_item_list) do
                local pos = i -- self:getFormPosByIndex(team_data.formation_type, i)
                item:setExtendData({scale = 0.7, can_click = true, pos_id = pos})
            end
            -- 英雄数据
            if object.hero_item_list then
                local function _getHeroInfoByPos( pos )
                    for _,info in pairs(team_data.pos_info) do
                        if info.pos == pos then
                            return info
                        end
                    end
                end
                for pos,hero_item in ipairs(object.hero_item_list) do
                    local hero_info = _getHeroInfoByPos(pos)
                    if hero_info then
                        local hero_vo = _hero_model:getHeroById(hero_info.id)
                        if hero_vo then
                            hero_item:setData(hero_vo)
                        end
                    else
                        local hero_vo = hero_item:getData()
                        if hero_vo then
                            hero_vo.is_ui_select = false
                        end
                        hero_item:setData()
                    end
                end
            end
            -- 是否隐藏
            object.hide_status = (team_data.is_hidden == 1)
            -- 神器id
            object.hallows_id = team_data.hallows_id
            -- 阵法类型
            object.formation_type = team_data.formation_type
            --记录旧位置
            object.old_order = team_data.old_order

            self:updateTeamInfo(index, true)
        else
            -- 给每个item设置站位数据(站位数据是固定的)
            for i,item in ipairs(object.hero_item_list) do
                local pos = i -- self:getFormPosByIndex(object.formation_type, i)
                item:setExtendData({scale = 0.7, can_click = true, pos_id = pos})
            end
        end
    end
end

-- 根据队伍编号获取队伍数据
function CorssarenaFormListPanel:getTeamDataByIndex( index )
    for k,v in pairs(self.team_data_list or {}) do
        if v.order == index then
            return v
        end
    end
end

-- 根据阵法类型和index，获取对应的位置
function CorssarenaFormListPanel:getFormPosByIndex( form_type, index )
    local pos = 1
    local formation_config = Config.FormationData.data_form_data[form_type]
    if formation_config then
        for k,v in pairs(formation_config.pos) do
            if v[1] == index then
                pos = v[2]
                break
            end
        end
    end
    return pos
end

function CorssarenaFormListPanel:getData(  )
    local data_list = {}
    for index,object in ipairs(self.team_panel_list) do
        local team_data = {}
        team_data.order = index
        team_data.old_order = object.old_order or index
        team_data.formation_type = object.formation_type
        team_data.hallows_id = object.hallows_id
        if object.hide_status == true then
            team_data.is_hidden = 1
        else
            team_data.is_hidden = 0
        end
        team_data.pos_info = {}
        for i,hero_item in ipairs(object.hero_item_list) do
            local hero_vo = hero_item:getData()
            local extend = hero_item:getExtendData()
            if hero_vo and extend.pos_id then

                _table_insert(team_data.pos_info, {pos = extend.pos_id, id = hero_vo.partner_id})
            end
        end
        _table_insert(data_list, team_data)
    end
    _table_insert(data_list, 1, {})
    return data_list
end

-- 英雄列表选择了一位英雄
function CorssarenaFormListPanel:onSelectHero( item, hero_vo )
    if self.is_show_act == true or self.is_move_hero == true then return end
    if hero_vo.is_ui_select == true then
        hero_vo.is_ui_select = false
        self:cancelSelectHeroItem(hero_vo.partner_id, item)
    else
        local change_index = self:setEmptyHeroItem(hero_vo, item)
        if change_index then
            hero_vo.is_ui_select = true
            item:setSelected(true)
        end
    end
end

function CorssarenaFormListPanel:cancelSelectHeroItem( partner_id, super_hero_item )
    for i,object in ipairs(self.team_panel_list) do
        if object.hero_item_list then
            for _,item in ipairs(object.hero_item_list) do
                local hero_vo = item:getData()
                if hero_vo and hero_vo.partner_id == partner_id then
                    hero_vo.is_ui_select = false
                    item:setData()
                    if not self.move_hero_item then
                        self.move_hero_item = HeroExhibitionItem.new(0.7, false)
                        self.container:addChild(self.move_hero_item)
                    end
                    self.move_hero_item:setData(hero_vo)
                    local world_pos = item:convertToWorldSpace(cc.p(0, 0))
                    local target_pos = self.container:convertToNodeSpace(world_pos)
                    local super_world_pos = super_hero_item:convertToWorldSpace(cc.p(0, 0))
                    local item_pos = self.container:convertToNodeSpace(super_world_pos)
                    self.is_show_act = true
                    self.move_hero_item:setPosition(cc.p(target_pos.x+HeroExhibitionItem.Width*0.7/2, target_pos.y+HeroExhibitionItem.Height*0.7/2))
                    local act_1 = cc.MoveTo:create(CrossarenaConst.Form_Act_Time, cc.p(item_pos.x+HeroExhibitionItem.Width/2, item_pos.y+HeroExhibitionItem.Height/2))
                    local call_back = function (  )
                        self.move_hero_item:setData()
                        self.move_hero_item:setPosition(cc.p(-1000, -1000))
                        if super_hero_item then
                            super_hero_item:setSelected(false)
                        end
                        self:updateTeamInfo(i)
                        self.is_show_act = false
                    end
                    self.move_hero_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
                    return
                end
            end
        end
    end
end

-- 取出第一个空位置
function CorssarenaFormListPanel:setEmptyHeroItem( data, super_hero_item )
    if self:checkIsHaveTwoSameHeroInAllTeam(data) then return end
    for i,object in ipairs(self.team_panel_list) do
        if object.hero_item_list and not self:checkIsHaveSameHeroInOneTeam(i, data, true) then
            for _,item in ipairs(object.hero_item_list) do
                local hero_vo = item:getData()
                if not hero_vo then
                    if not self.move_hero_item then
                        self.move_hero_item = HeroExhibitionItem.new(0.7, false)
                        self.container:addChild(self.move_hero_item)
                    end
                    self.move_hero_item:setData(data)
                    local world_pos = item:convertToWorldSpace(cc.p(0, 0))
                    local target_pos = self.container:convertToNodeSpace(world_pos)
                    local super_world_pos = super_hero_item:convertToWorldSpace(cc.p(0, 0))
                    local item_pos = self.container:convertToNodeSpace(super_world_pos)
                    self.is_show_act = true
                    self.move_hero_item:setPosition(cc.p(item_pos.x+HeroExhibitionItem.Width/2, item_pos.y+HeroExhibitionItem.Height/2))
                    local act_1 = cc.MoveTo:create(CrossarenaConst.Form_Act_Time, cc.p(target_pos.x+HeroExhibitionItem.Width*0.7/2, target_pos.y+HeroExhibitionItem.Height*0.7/2))
                    local call_back = function (  )
                        self.move_hero_item:setData()
                        self.move_hero_item:setPosition(cc.p(-1000, -1000))
                        if item then
                            item:setData(data)
                        end
                        self:updateTeamInfo(i)
                        self.is_show_act = false
                    end
                    self.move_hero_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
                    return i
                end
            end
        end
    end
    -- 能走到这里，就一定是同队伍有同类英雄
    message(TI18N("同队伍不能上阵同类英雄"))
end

-- 判断某一队伍中是否有同类英雄
function CorssarenaFormListPanel:checkIsHaveSameHeroInOneTeam( team_index, hero_vo, no_tips )
    local is_have = false
    local team_object = self.team_panel_list[team_index]
    if team_object then
        for k,item in pairs(team_object.hero_item_list) do
            local data = item:getData()
            if data and data.bid == hero_vo.bid then
                is_have = true
                break
            end
        end
    end
    if is_have and not no_tips then
        message(TI18N("同队伍不能上阵同类英雄"))
    end
    return is_have
end

-- 判读全部队伍中是否有超过2个的同类英雄
function CorssarenaFormListPanel:checkIsHaveTwoSameHeroInAllTeam( hero_vo, no_tips )
    local is_have = false
    local have_num = 0
    for _,team_object in pairs(self.team_panel_list) do
        for k,item in pairs(team_object.hero_item_list) do
            local data = item:getData()
            if data and data.bid == hero_vo.bid then
                have_num = have_num + 1
                if have_num >= 2 then
                    is_have = true
                    break
                end
            end
        end
        if is_have then
            break
        end
    end
    if is_have and not no_tips then
        message(TI18N("不能同时上阵3个同类英雄"))
    end
    return is_have
end

-- 点击英雄
function CorssarenaFormListPanel:onClickHeroItem( team_index, hero_index )
    if self.team_panel_list and self.team_panel_list[team_index] then
        local hero_item_list = self.team_panel_list[team_index].hero_item_list or {}
        local hero_item = hero_item_list[hero_index]
        if hero_item then
            local hero_vo = hero_item:getData()
            if hero_vo then
                hero_vo.is_ui_select = false
                hero_item:setData()
                self:updateTeamInfo(team_index)
                if self.super_panel then
                    local super_hero_item = self.super_panel:getCellHeroItemByPartnerId(hero_vo.partner_id)
                    if super_hero_item then
                        self.is_show_act = true
                        if not self.move_hero_item then
                            self.move_hero_item = HeroExhibitionItem.new(0.7, false)
                            self.container:addChild(self.move_hero_item)
                        end
                        self.move_hero_item:setData(hero_vo)
                        local world_pos = hero_item:convertToWorldSpace(cc.p(0, 0))
                        local item_pos = self.container:convertToNodeSpace(world_pos)
                        self.move_hero_item:setPosition(cc.p(item_pos.x+HeroExhibitionItem.Width*0.7/2, item_pos.y+HeroExhibitionItem.Height*0.7/2))
                        local super_world_pos = super_hero_item:convertToWorldSpace(cc.p(0, 0))
                        local target_pos = self.container:convertToNodeSpace(super_world_pos)
                        local act_1 = cc.MoveTo:create(CrossarenaConst.Form_Act_Time, cc.p(target_pos.x+HeroExhibitionItem.Width/2, target_pos.y+HeroExhibitionItem.Height/2))
                        local call_back = function (  )
                            self.move_hero_item:setData()
                            self.move_hero_item:setPosition(cc.p(-1000, -1000))
                            super_hero_item:setSelected(false)
                            self.is_show_act = false
                        end
                        self.move_hero_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
                    end
                end
            end
        end
    end
end

-- 更新三支队伍的战力、阵营信息
function CorssarenaFormListPanel:updateAllTeamInfo(  )
    for index=1,3 do
        self:updateTeamInfo(index)
    end
end

-- 更新某一队伍的信息 is_all 为true时才会更新勾选框和神器
function CorssarenaFormListPanel:updateTeamInfo( index, is_all )
    local team_object = self.team_panel_list[index]
    if not team_object then return end

    -- 战力
    local power_num = 0
    local dic_camp = {}
    for k,item in pairs(team_object.hero_item_list) do
        local hero_vo = item:getData()
        if hero_vo then
            power_num = power_num + (hero_vo.power or 0)
            if hero_vo.camp_type then
                if dic_camp[hero_vo.camp_type] == nil then
                    dic_camp[hero_vo.camp_type] = 1
                else
                    dic_camp[hero_vo.camp_type] = dic_camp[hero_vo.camp_type] + 1
                end
            end
        end
    end
    local is_pvp = _hero_model:isGuildPvpFrom(self.fun_form_type)
    local pvp_power = 0
    if is_pvp then
        local list = {}
        for k,item in pairs(team_object.hero_item_list) do
            local hero_vo = item:getData()
            if hero_vo then
                if hero_vo.type and hero_vo.type ~= 0 then
                    table.insert(list, hero_vo.type)
                end
            end
        end
        pvp_power = GuildskillController:getInstance():getModel():getPvpPowerByCareerlist(list)
    end
    
    if is_pvp and power_num > 0 and pvp_power > 0 then
        if team_object.pvp_arrow == nil  then
            team_object.pvp_arrow = createImage(team_object.team_panel, PathTool.getResFrame("common","common_1086"), 282, 125, cc.p(0.5,0.5), true)
            team_object.pvp_arrow:setScale(0.8)
        else
            team_object.pvp_arrow:setVisible(true)
        end

         if team_object.show_pvp_tips == nil then
            team_object.show_pvp_tips = createLabel(18, cc.c3b(0x24,0x90,0x03), nil, 84, 125, TI18N("(公会pvp)"), team_object.team_panel, nil, cc.p(0, 0.5))
        else
            team_object.show_pvp_tips:setVisible(true) 
        end
        power_num = power_num + pvp_power 
    else
        if team_object.pvp_arrow then
            team_object.pvp_arrow:setVisible(false)
        end
        if team_object.show_pvp_tips then
            team_object.show_pvp_tips:setVisible(false)
        end
    end
    team_object.power_txt:setString(power_num)

    if is_pvp and team_object.show_pvp_tips then
        --设置战力后需要重新显示一下新的位置
        local size = team_object.power_txt:getContentSize()
        local x = team_object.power_txt:getPositionX()
        team_object.show_pvp_tips:setPositionX(x + size.width + 5) 
    end

    local form_id_list = BattleController:getInstance():getModel():getFormIdListByCamp(dic_camp)
    local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(form_id_list)
    if halo_icon_config then
        local halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
        self.halo_load_list[index] = loadImageTextureFromCDN(team_object.halo_btn, halo_res, ResourcesType.single, self.halo_load_list[index])
        addCountForCampIcon(team_object.halo_btn, halo_icon_config.nums)
    else
        local halo_res = PathTool.getCampGroupIcon(1000)
        self.halo_load_list[index] = loadImageTextureFromCDN(team_object.halo_btn, halo_res, ResourcesType.single, self.halo_load_list[index])
        addCountForCampIcon(team_object.halo_btn)
    end

    if is_all == true then
        -- 隐藏勾选框
        if team_object.hide_btn then
            team_object.hide_btn:setSelected(team_object.hide_status or false)
        end

        -- 阵法类型
        if team_object.formation_type ~= 0 then
            local form_res = PathTool.getResFrame("form", "form_icon_"..team_object.formation_type)
            loadSpriteTexture(team_object.form_icon, form_res, LOADTEXT_TYPE_PLIST)
        end

        -- 神器
        local hallows_config = Config.HallowsData.data_base[team_object.hallows_id]
        if hallows_config then
            team_object.hallow_item:showAddIcon(false)
            local hallows_vo = HallowsController:getInstance():getModel():getHallowsById(team_object.hallows_id)
            if hallows_vo and hallows_vo.look_id ~= 0 then
                local magic_cfg = Config.HallowsData.data_magic[hallows_vo.look_id]
                if magic_cfg then
                    team_object.hallow_item:setBaseData(magic_cfg.item_id)
                    team_object.hallow_item:setMagicIcon(true)
                else
                    team_object.hallow_item:setBaseData(hallows_config.item_id)
                    team_object.hallow_item:setMagicIcon(false)
                end
            else
                team_object.hallow_item:setBaseData(hallows_config.item_id)
                team_object.hallow_item:setMagicIcon(false)
            end
        else
            team_object.hallow_item:setData()
            team_object.hallow_item:showAddIcon(true)
        end
    end
end

-- 移动英雄item
function CorssarenaFormListPanel:onClickHeroItemMove( sender, hero_vo )
    if not self.move_hero_item then
        self.move_hero_item = HeroExhibitionItem.new(0.7, false)
        self.container:addChild(self.move_hero_item)
    end
    if not self.move_hero_vo and hero_vo then
        self.move_hero_vo = hero_vo
        sender:setData()
        self.move_hero_item:setData(hero_vo)
    end

    local touch_pos = sender:getTouchMovePosition()
    local target_pos = self.container:convertToNodeSpace(touch_pos)
    self.move_hero_item:setPosition(target_pos)
end

function CorssarenaFormListPanel:onClickHeroItemCanceled( sender )
    if self.move_hero_item and self.move_hero_vo then
        local touch_pos = sender:getTouchMovePosition()
        local target_pos = self.container:convertToNodeSpace(touch_pos) 

        local is_have = false
        for i,object in ipairs(self.team_panel_list) do
            for index,rect in ipairs(object.item_rect_list) do
                if cc.rectContainsPoint( rect, target_pos ) then
                    local hero_item = object.hero_item_list[index]
                    if hero_item and not self:checkIsHaveSameHeroInOneTeam(i, self.move_hero_vo) then
                        is_have = true
                        self.is_show_act = true
                        local world_pos = hero_item:convertToWorldSpace(cc.p(0, 0))
                        local item_pos = self.container:convertToNodeSpace(world_pos) 
                        local act_1 = cc.MoveTo:create(CrossarenaConst.Form_Act_Time, cc.p(item_pos.x+41.5, item_pos.y+41.5))
                        local call_back = function (  )
                            self.move_hero_item:setData()
                            self.move_hero_item:setPosition(cc.p(-1000, -1000))
                            local hero_vo = hero_item:getData()
                            sender:setData(hero_vo)
                            hero_item:setData(self.move_hero_vo)
                            self.move_hero_vo = nil
                            self:updateAllTeamInfo()
                            self.is_show_act = false
                        end
                        self.move_hero_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
                    end
                    break
                end
            end
            if is_have then
                break
            end
        end
        if not is_have then
            self:onClickHeroItemEnd(sender)
        end
    end
end

function CorssarenaFormListPanel:onClickHeroItemEnd( sender )
    if self.move_hero_item then
        self.is_show_act = true
        local world_pos = sender:convertToWorldSpace(cc.p(0, 0))
        local target_pos = self.container:convertToNodeSpace(world_pos) 
        local act_1 = cc.MoveTo:create(CrossarenaConst.Form_Act_Time, cc.p(target_pos.x+41.5, target_pos.y+41.5))
        local call_back = function (  )
            self.move_hero_item:setData()
            self.move_hero_item:setPosition(cc.p(-1000, -1000))
            if self.move_hero_vo then
                sender:setData(self.move_hero_vo)
                self.move_hero_vo = nil
            end
            self.is_show_act = false
        end
        self.move_hero_item:runAction(cc.Sequence:create(act_1, cc.CallFunc:create(call_back)))
    end
end

function CorssarenaFormListPanel:__delete(  )
    if self.form_show_type == HeroConst.FormShowType.eFormFight then
        local team_data_list = self:getData()
        table.remove(team_data_list, 1)
        local temp_num = 0
        for k,v in pairs(team_data_list) do
            if v.pos_info and next(v.pos_info) ~= nil then
                temp_num = temp_num + 1
            end
        end
        if temp_num >= 2 then
            GlobalEvent:getInstance():Fire(CrossarenaEvent.Close_Form_Panle_Event, team_data_list)
        end
    end
	for k,object in pairs(self.team_panel_list) do
        if object.hero_item_list then
            for _,item in pairs(object.hero_item_list) do
                item:DeleteMe()
                item = nil
            end
            object.hero_item_list = {}
        end
        if object.hallow_item then
            object.hallow_item:DeleteMe()
            object.hallow_item = nil
        end
    end
    for k,load in pairs(self.halo_load_list) do
        load:DeleteMe()
        load = nil
    end

    if self.save_crossarena_form_event then
        GlobalEvent:getInstance():UnBind(self.save_crossarena_form_event)
        self.save_crossarena_form_event = nil
    end
    if self.move_hero_item then
        self.move_hero_item:DeleteMe()
        self.move_hero_item = nil
    end
end