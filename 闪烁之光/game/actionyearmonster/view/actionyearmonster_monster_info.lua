---------------------------------
-- @Author: lwc
-- @Editor: lwc
-- @date 2020年1月8日
-- @description: 对方阵容
---------------------------------
local _controller = ActionyearmonsterController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

ActionyearmonsterMonsterInfo = ActionyearmonsterMonsterInfo or BaseClass(BaseView)

function ActionyearmonsterMonsterInfo:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "actionyearmonster/actionyearmonster_monster_info"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("planes", "planes_map"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("planes", "planes_info"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("planes","big_bg_2"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("planes","big_bg_3"), type = ResourcesType.single},
    }

    self.award_item_list = {}
    self.left_item_list = {}
    self.right_item_list = {}
end

function ActionyearmonsterMonsterInfo:open_callback( )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container, 1)

    self.win_title = main_container:getChildByName("win_title")
    self.win_title:setString(TI18N("守卫"))
    self.tips_txt = main_container:getChildByName("tips_txt")
    self.tips_txt:setVisible(false)
    -- :setString(TI18N("挑战怪物或精英怪胜利后可掉落增强实力的遗物"))
    main_container:getChildByName("award_txt"):setString(TI18N("奖励"))

    local left_bg_1 = main_container:getChildByName("left_bg_1")
    loadSpriteTexture(left_bg_1, PathTool.getPlistImgForDownLoad("planes","big_bg_3"), LOADTEXT_TYPE)
    local right_bg_1 = main_container:getChildByName("right_bg_1")
    loadSpriteTexture(right_bg_1, PathTool.getPlistImgForDownLoad("planes","big_bg_2"), LOADTEXT_TYPE)

    self.btn_fight = main_container:getChildByName("btn_fight")
    self.btn_fight:getChildByName("label"):setString(TI18N("开战"))
    self.btn_embattle = main_container:getChildByName("btn_embattle")
    self.btn_embattle:getChildByName("label"):setString(TI18N("布阵"))
    self.close_btn = main_container:getChildByName("close_btn")

    self.left_name_txt = main_container:getChildByName("name_txt_1")
    self.left_atk_txt = main_container:getChildByName("atk_txt_1")
    self.left_atk_txt:setString(0)
    self.left_role_panel = main_container:getChildByName("panel_role_left")
    self.right_name_txt = main_container:getChildByName("name_txt_2")
    self.right_atk_txt = main_container:getChildByName("atk_txt_2")
    self.right_role_panel = main_container:getChildByName("panel_role_right")

    -- self.left_buff_txt_1 = main_container:getChildByName("left_buff_txt_1")
    -- self.left_buff_txt_2 = main_container:getChildByName("left_buff_txt_2")
    -- self.left_buff_txt_3 = main_container:getChildByName("left_buff_txt_3")
    self.add_atk_txt_1 = main_container:getChildByName("add_atk_txt_1")
    self.add_atk_txt_1:setString(TI18N("战力值+0%"))
    self.add_atk_txt_2 = main_container:getChildByName("add_atk_txt_2")
    self.add_atk_txt_2:setVisible(false)
    -- self.award_tips_txt = main_container:getChildByName("award_tips_txt")

    -- 精灵
    self.left_elfin_item_list = {}
    self.right_elfin_item_list = {}
    self.tree_lv_left = main_container:getChildByName("tree_lv_left")
    self.tree_lv_right = main_container:getChildByName("tree_lv_right")
    self.tree_lv_right:setVisible(false)
    self.left_elfin_panel = main_container:getChildByName("left_elfin_panel")
    self.right_elfin_panel = main_container:getChildByName("right_elfin_panel")

    local panel_size = self.left_role_panel:getContentSize()
    --9位置
    self.left_position_list = {}
    for i=1,9 do
        local item_bg = self.left_role_panel:getChildByName("pos_bg_" .. i)
        local pos_x, pos_y = item_bg:getPosition()
        _table_insert(self.left_position_list, cc.p(pos_x, pos_y))
    end
    self.right_position_list = {}
    for i=1,9 do
        local item_bg = self.right_role_panel:getChildByName("pos_bg_" .. i)
        local pos_x, pos_y = item_bg:getPosition()
        _table_insert(self.right_position_list, cc.p(pos_x, pos_y))
    end

    self.left_role_head = PlayerHead.new(PlayerHead.type.circle)
    self.left_role_head:setPosition(92, 857)
    self.left_role_head:setScale(0.9)
    self.main_container:addChild(self.left_role_head)
    
    self.right_role_head = PlayerHead.new(PlayerHead.type.circle)
    self.right_role_head:setPosition(402, 857)
    self.right_role_head:setScale(0.9)
    self.main_container:addChild(self.right_role_head)

    self.reward_panel = main_container:getChildByName("reward_panel")
    local panel_size = self.reward_panel:getContentSize()
    local scroll_view_size = cc.size(panel_size.width, panel_size.height+10)
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.8,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.8,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.8
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.reward_panel, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setClickEnabled(false)
end

function ActionyearmonsterMonsterInfo:register_event( )
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.btn_fight, handler(self, self.onClickFightBtn), true)
    registerButtonEventListener(self.btn_embattle, handler(self, self.onClickEmbattleBtn), true)

    -- 我方阵容数据
    self:addGlobalEvent(HeroEvent.Update_Fun_Form, function ( data )
        if data and data.type  == PartnerConst.Fun_Form.YearMonster then
            self.form_data = data
            self:setMyFormData()
        end
    end)

    -- 我方精灵数据更新
    self:addGlobalEvent(ElfinEvent.Get_Elfin_Tree_Data_Event, function (  )
        self:updateMyElfinInfo()
    end)

    -- 敌方阵容数据
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Get_Master_Data_Event, function ( data )
        self:setMasterData(data)
    end)
end

function ActionyearmonsterMonsterInfo:onClickCloseBtn(  )
    _controller:openActionyearmonsterMonsterInfo(false)
end

-- 出战
function ActionyearmonsterMonsterInfo:onClickFightBtn(  )
    if not self.form_data or not self.grid_index then return end

    local ext_list = {}
    -- 阵法 ActionyearmonsterConstants.Proto_28203
    _table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._1, val1 = self.form_data.formation_type, val2 = 0})
    -- 神器
    _table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._2, val1 = self.form_data.hallows_id, val2 = 0})
    -- 英雄
    for k,v in pairs(self.form_data.pos_info) do
        -- if (v.flag and v.flag == 1) or (v.data and v.data.flag == 1) then -- 雇佣英雄
        --     _table_insert(ext_list, {type = PlanesConst.Proto_23104._11, val1 = v.pos, val2 = v.id})
        -- else
            _table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._3, val1 = v.pos, val2 = v.id})
        -- end
    end
    _controller:sender28203( self.grid_index, 1, ext_list )
    _controller:openActionyearmonsterMonsterInfo(false)
end

-- 布阵
function ActionyearmonsterMonsterInfo:onClickEmbattleBtn(  )
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.YearMonster, {}, HeroConst.FormShowType.eFormSave)
end

function ActionyearmonsterMonsterInfo:openRootWnd( grid_index )
    self.grid_index = grid_index
    self:updateAwardList()

    HeroController:getInstance():sender11211(PartnerConst.Fun_Form.YearMonster) -- 请求我方阵容数据
    _controller:sender28203(grid_index, 0, {} ) -- 请求敌方阵容数据
end

-- 奖励数据
function ActionyearmonsterMonsterInfo:updateAwardList(  )
    if not self.grid_index then return end
    local evt_vo = _model:getYearEvtVoByGridIndex(self.grid_index)
    if not evt_vo or not evt_vo.config then return end

    -- 标题
    self.win_title:setString(evt_vo.config.name)
    -- 怪物显示事件名称
    if evt_vo.config.type == ActionyearmonsterConstants.Evt_Type.Monster then
        self.right_name_txt:setString(evt_vo.config.name)
    end

    local data_list = evt_vo.config.reward or {}
    local item_list = {}
    for k,v in pairs(data_list) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        _table_insert(item_list, vo)
    end
    self.item_scrollview:setData(item_list)
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            local item_vo = v:getData()
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end

-- 我方阵容数据
function ActionyearmonsterMonsterInfo:setMyFormData( )
    local role_vo = RoleController:getInstance():getRoleVo()
    if not self.form_data or not role_vo then return end
    -- 名称
    self.left_name_txt:setString(role_vo.name)
    -- 头像
    self.left_role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    -- 英雄头像
    self.hero_base_atk_val = 0
    local formation_config = Config.FormationData.data_form_data[self.form_data.formation_type]
    for i=1,5 do
        local role_info = self:getRoleDataByIndex(i, self.form_data.pos_info)
        local role_data
        if role_info then
            -- if role_info.flag and role_info.flag == 1 then
            --     role_data = _model:getPlanesHireHeroData(role_info.id)
            -- else
                role_data = HeroController:getInstance():getModel():getHeroById(role_info.id)
            -- end
        end
        local hero_item = self.left_item_list[i]
        if role_data then
            if hero_item == nil then
                hero_item = self:createHeroItemByIndex(i, self.left_role_panel,true)
                self.left_item_list[i] = hero_item
            else
                hero_item:setVisible(true)
            end
            hero_item:setData(role_data)
            -- if role_data.flag == 1 then
            --     hero_item:showHelpImg(true)
            -- else
            --     hero_item:showHelpImg(false)
            -- end

            -- 位置
            local pos_cfg = formation_config.pos[i]
            if pos_cfg then
                local pos = self.left_position_list[pos_cfg[2]]
                if pos then
                    hero_item:setPosition(pos)
                end
            end

            -- 总战力
            self.hero_base_atk_val = self.hero_base_atk_val + (role_data.power or 0)
        else
            if hero_item then
                hero_item:setVisible(false)
            end
        end
    end

    self.left_atk_txt:setString(self.hero_base_atk_val)
    -- 精灵
    self:updateMyElfinInfo()
end

-- 更新我方精灵显示
function ActionyearmonsterMonsterInfo:updateMyElfinInfo(  )
    local elfin_data = ElfinController:getInstance():getModel():getElfinTreeData()
    if not elfin_data then return end

    self.tree_lv_left:setString(_string_format(TI18N("古树：%d级"), elfin_data.lev or 0))
    -- 精灵
    for i=1,4 do
        local left_elfin_item = self.left_elfin_item_list[i]
        if not left_elfin_item then
            left_elfin_item = SkillItem.new(true, true, true, 0.5, true)
            local pos_x = 28 + (i-1)*68
            left_elfin_item:setPosition(cc.p(pos_x, 24))
            self.left_elfin_panel:addChild(left_elfin_item)
            self.left_elfin_item_list[i] = left_elfin_item
        end
        self:setElfinSkillItemData(left_elfin_item, elfin_data.sprites or {}, i)
    end
end

-- 敌方阵容数据
function ActionyearmonsterMonsterInfo:setMasterData( data )
    if not data then return end
    
    local config = Config.UnitData3.data_unit1(data.unit_id)
    if not config then return end
    
    -- 战力
    self.right_atk_txt:setString(data.power)
    if config.monster3 then
        local monster3_config = Config.UnitData3.data_unit2(config.monster3)
        if monster3_config then
            --英雄头像
            local res = PathTool.getHeadIcon(monster3_config.head_icon)
            self.right_role_head:setHeadRes(res,true)
            -- 名称
            self.right_name_txt:setString(monster3_config.name)
        end
    end
    
    local formation_config = Config.FormationData.data_form_data[config.formation[1]]
    local dic_pos_info = {}
    local monster = 0
    for i=1,5 do
        local info = config["monster"..i]
        if info then
            dic_pos_info[i] = {pos = i,id = info}
        end
    end

    for i,v in ipairs(formation_config.pos) do
        local index = v[1] 
        local pos = v[2] 
        local hero_vo 
        if dic_pos_info[index] then
            local temp_config = Config.UnitData3.data_unit2(dic_pos_info[index].id)
            if temp_config then
                hero_vo = HeroVo.New()
                hero_vo.bid = tonumber(temp_config.head_icon)
                hero_vo.master_head_id = tonumber(temp_config.head_icon)
                hero_vo.lev = data.unit_lev
                hero_vo.star = temp_config.star
                hero_vo.camp_type = temp_config.camp_type
            end
        end
        
     
        
        --更新位置
        if self.right_item_list[index] == nil then
            local hero_item = self:createHeroItemByIndex(index, self.right_role_panel,false)
            self.right_item_list[index] = hero_item
        else
            self.right_item_list[index]:setVisible(true)
        end
        
        local pos = self.right_position_list[v[2]]
        if pos then
            self.right_item_list[index]:setPosition(pos)
        end

        if hero_vo then
            self.right_item_list[index]:setData(hero_vo)
        else
            self.right_item_list[index]:setData(nil)
            self.right_item_list[index]:setVisible(false)
        end
    end

end

-- 根据位置获取精灵的bid
function ActionyearmonsterMonsterInfo:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function ActionyearmonsterMonsterInfo:setElfinSkillItemData( skill_item, sprite_data, pos )
    local elfin_bid = self:getElfinBidByPos(sprite_data, pos)
    if elfin_bid then
        skill_item:showLockIcon(false)
        local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
        if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
            skill_item:setData()
            skill_item:showLevel(false)
        else
            local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
            if skill_cfg then
                skill_item:showLevel(true)
                skill_item:setData(skill_cfg)
            end
        end
    else
        skill_item:setData()
        skill_item:showLevel(false)
        skill_item:showLockIcon(true)
    end
end

-- 根据位置获取我方英雄id
function ActionyearmonsterMonsterInfo:getMyRoleIdByIndex( index, role_list )
    for k,v in pairs(role_list) do
        if v.pos == index then
            return v.id
        end
    end
end

-- 根据位置获取敌方英雄数据
function ActionyearmonsterMonsterInfo:getRoleDataByIndex( index, role_list )
    for k,v in pairs(role_list) do
        if v.pos == index then
            return v
        end
    end
end

--根据位置索引创建一个新的item
function ActionyearmonsterMonsterInfo:createHeroItemByIndex(index, parent,isCanTouch)
    local hero_item = HeroExhibitionItem.new(0.65, isCanTouch, nil, nil ,true)
    hero_item:addCallBack(handler(self, self.onClickHeroItem))
    parent:addChild(hero_item)
    hero_item:setVisible(true)
    return hero_item
end

function ActionyearmonsterMonsterInfo:onClickHeroItem( item, hero_data )
    if not hero_data then return end

    if hero_data.is_master then -- 怪物
        if hero_data.srv_id ~= "" and hero_data.rid and hero_data.partner_id then
            LookController:getInstance():sender11061(hero_data.rid, hero_data.srv_id, hero_data.partner_id)
        else
            message(TI18N("该英雄来自异域，无法查看"))
        end
    -- elseif hero_data.flag == 1 and hero_data.partner_id then -- 我方雇佣英雄
    --     PlanesController:getInstance():sender23116(hero_data.partner_id)
    else -- 我自己的英雄
        HeroController:getInstance():openHeroTipsPanel(true, hero_data)
    end
end

function ActionyearmonsterMonsterInfo:close_callback( )
    if self.left_role_head then
        self.left_role_head:DeleteMe()
        self.left_role_head = nil
    end
    if self.right_role_head then
        self.right_role_head:DeleteMe()
        self.right_role_head = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    for k,item in pairs(self.award_item_list) do
        item:DeleteMe()
        item = nil
    end
    for k,item in pairs(self.right_item_list) do
        item:DeleteMe()
        item = nil
    end
    for k,item in pairs(self.left_item_list) do
        item:DeleteMe()
        item = nil
    end
    for k,item in pairs(self.left_elfin_item_list) do
        item:DeleteMe()
        item = nil
    end
    for k,item in pairs(self.right_elfin_item_list) do
        item:DeleteMe()
        item = nil
    end
    _controller:openActionyearmonsterMonsterInfo(false)
end