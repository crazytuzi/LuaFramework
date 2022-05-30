--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-15 01:17:36
-- @description    : 
		-- 跨服竞技场 角色tips
---------------------------------
local _controller = CrossarenaController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

CrossarenaRoleTips = CrossarenaRoleTips or BaseClass(BaseView)

function CrossarenaRoleTips:__init( )
	self.win_type = WinType.Big
	self.layout_name = "crossarena/crossarena_role_tips"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false

    self.res_list = {
    }

	self.atk_txt_list = {}
    self.hero_item_list = {}

    self.my_atk_txt_list = {}
    self.my_hero_item_list = {}

    self.skip_cfg = Config.ArenaClusterData.data_const["arena_skip_count"]
end

function CrossarenaRoleTips:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)

    self.btn_challenge = self.container:getChildByName("btn_challenge")
    local btn_size = self.btn_challenge:getContentSize()
    self.btn_challenge_label = createRichLabel(26, Config.ColorData.data_new_color4[1], cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.btn_challenge_label:setString(TI18N("挑战"))
    self.btn_challenge:addChild(self.btn_challenge_label)

    self.ticket_bid = Config.ArenaClusterData.data_const["arena_ticket"].val
    local item_config = Config.ItemData.data_get_data(self.ticket_bid) 
    if item_config then
        self.btn_challenge_label:setString(_string_format(TI18N("<img src='%s' scale=0.4 />3 挑战"), PathTool.getItemRes(item_config.icon)))
    end

    self.txt_name = self.container:getChildByName("txt_name")
    self.txt_level = self.container:getChildByName("txt_level")
    self.txt_score = self.container:getChildByName("txt_score")

    self.txt_my_name = self.container:getChildByName("txt_my_name")
    self.txt_my_level = self.container:getChildByName("txt_my_level")
    self.txt_my_score = self.container:getChildByName("txt_my_score")

    self.skip_battle_btn = self.container:getChildByName("skip_battle_btn")
    local is_auto = _model:getCrossarenaAutoBattle()
    self.skip_battle_btn:setSelected(is_auto == 1)
    self.skip_battle_btn:getChildByName("name"):setString(TI18N("跳过战斗"))

    self.btn_form = self.container:getChildByName("btn_form")
    self.btn_form:getChildByName("label"):setString(TI18N("调整布阵"))
    self.change_pos_btn_1 = self.container:getChildByName("change_pos_btn_1")
    self.change_pos_btn_2 = self.container:getChildByName("change_pos_btn_2")

    for i=1,3 do
    	local title_team = self.container:getChildByName("title_team_" .. i)
    	if title_team then
    		title_team:setString(TI18N("队伍") .. StringUtil.numToChinese(i))
    	end
    	local txt_atk = self.container:getChildByName("txt_atk_" .. i)
    	if txt_atk then
    		_table_insert(self.atk_txt_list, txt_atk)
    	end

        local title_my_team = self.container:getChildByName("title_my_team_" .. i)
        if title_my_team then
            title_my_team:setString(TI18N("队伍") .. StringUtil.numToChinese(i))
        end
        local txt_my_atk = self.container:getChildByName("txt_my_atk_" .. i)
        if txt_my_atk then
            _table_insert(self.my_atk_txt_list, txt_my_atk)
        end
    end

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setAnchorPoint(cc.p(0.5, 0.5))
    self.role_head:setPosition(cc.p(85, 931 + 130))
    self.role_head:setHeadLayerScale(0.6)
    self.container:addChild(self.role_head)

    self.my_role_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_role_head:setAnchorPoint(cc.p(0.5, 0.5))
    self.my_role_head:setPosition(cc.p(85, 466+50))
    self.my_role_head:setHeadLayerScale(0.6)

    self.container:addChild(self.my_role_head)
end

function CrossarenaRoleTips:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openCrossarenaRoleTips(false)
	end, false, 2)

    registerButtonEventListener(self.btn_form, function (  )
        if self.data and self.data.rid and self.data.srv_id then
            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.CrossArena, {rid = self.data.rid, srv_id = self.data.srv_id}, HeroConst.FormShowType.eFormFight)
        end
    end, true)

    registerButtonEventListener(self.btn_challenge, function (  )
        if self.data and self.data.rid and self.data.srv_id then
            CrossarenaController:getInstance():sender25606(self.data.rid, self.data.srv_id)
            _controller:openCrossarenaRoleTips(false)
        end
    end, true)

    registerButtonEventListener(self.change_pos_btn_1, function (  )
        self:changeTeamDataOrder(1)
    end, true)

    registerButtonEventListener(self.change_pos_btn_2, function (  )
        self:changeTeamDataOrder(2)
    end, true)

    self.skip_battle_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            if self.skip_cfg and self.skip_cfg.val <= _model:getCrossarenaChallengeNum() then
                _model:setCrossarenaAutoBattle(1)
            else
                if self.skip_cfg then
                    message(self.skip_cfg.desc)
                end
                self.skip_battle_btn:setSelected(false)
            end
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            _model:setCrossarenaAutoBattle(0)
        end
    end)

    -- 我的进攻阵容数据
    self:addGlobalEvent(CrossarenaEvent.Update_Form_Data_Event, function ( data )
        if data and data.type == 1 then
            self:updateMyselfInfo(deepCopy(data.formations), true)
        end
    end)

    -- 阵容数据变化
    self:addGlobalEvent(CrossarenaEvent.Close_Form_Panle_Event, function ( team_list )
        if team_list then
            _controller:sender25604( 1, team_list )
            self:updateMyselfInfo(team_list)
        end
    end)
end

function CrossarenaRoleTips:openRootWnd( data )
	self:setData(data)

    -- 请求我的阵法数据
    _controller:sender25605(1)
end

function CrossarenaRoleTips:setData( data )
	if not data then return end

	self.data = data

    -- 头像
    self.role_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
    --头像框
    local avatar_cfg = Config.AvatarData.data_avatar[data.avatar_id or 0]
    if avatar_cfg then
        local res_id = avatar_cfg.res_id or 1 
        local res = PathTool.getTargetRes("headcircle","txt_cn_headcircle_"..res_id)
        self.role_head:showBg(res,nil,false,avatar_cfg.offy)
    end
    self.role_head:setLev(data.lev)
    self.role_head:setSex(data.sex, cc.p(70,4))

    -- 名称
    self.txt_name:setString(transformNameByServ(data.name, data.srv_id))

    -- 等级
    self.txt_level:setString(_string_format(TI18N("%d级"), data.lev))

    -- 积分
    self.txt_score:setString(_string_format(TI18N("积分:%d"), data.score))

    -- 队伍
    local team_list = data.order_list or {}
    table.sort(team_list, SortTools.KeyLowerSorter("order"))
    for i,team_data in ipairs(team_list) do
        -- 战力
        local akt_txt = self.atk_txt_list[i]
        if akt_txt then
            if team_data.is_hidden == 1 then
                akt_txt:setString("???")
            else
                akt_txt:setString(team_data.power or 0)
            end
        end
        -- 宝可梦
        if team_data.is_hidden == 1 or not team_data.p_list or next(team_data.p_list) == nil then
            for n=1,5 do
                delayRun(self.container, n*2 / display.DEFAULT_FPS, function (  )
                    local hero_item = HeroExhibitionItem.new(0.7, true)
                    hero_item:setPosition(cc.p(230+(n-1)*(HeroExhibitionItem.Width*0.7+10), 940 - (i-1)*110))
                    self.container:addChild(hero_item)
                    _table_insert(self.hero_item_list, hero_item)

                    if team_data.is_hidden == 1 then
                        hero_item:showUnknownIcon(true)
                    end
                end)
            end
        elseif team_data.p_list then
            table.sort(team_data.p_list, SortTools.KeyLowerSorter("pos"))
            for n=1,5 do
                delayRun(self.container, n*2 / display.DEFAULT_FPS, function (  )
                    local hero_data = team_data.p_list[n]
                    local hero_item = HeroExhibitionItem.new(0.7, true)
                    hero_item:addCallBack(function (  )
                        if hero_data and hero_data.rid and hero_data.srv_id and team_data.order and hero_data.pos then
                            _controller:sender25603( hero_data.rid, hero_data.srv_id, team_data.order, hero_data.pos )
                        end
                    end)
                    hero_item:setPosition(cc.p(230+(n-1)*(HeroExhibitionItem.Width*0.7+10), 940 - (i-1)*110))
                    self.container:addChild(hero_item)
                    _table_insert(self.hero_item_list, hero_item)

                    if hero_data then
                        local hero_vo = HeroVo.New()
                        hero_vo.bid = hero_data.bid
                        hero_vo.lev = hero_data.lev
                        hero_vo.star = hero_data.star
                        hero_vo.use_skin = hero_data.use_skin
                        hero_item:setData(hero_vo)
                    end
                end)
            end
        end
    end

    -- 玩家自己的角色信息
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo then
        -- 头像
        self.my_role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
        -- 角色名
        self.txt_my_name:setString(role_vo.name .. TI18N("(我)"))

        -- 等级
        self.txt_my_level:setString(role_vo.lev .. TI18N("级"))

        -- 积分
        local my_score = _model:getMyCrossarenaScore()
        self.txt_my_score:setString(_string_format(TI18N("积分:%d"), my_score))
    end
end

-- 玩家自己的阵容数据
function CrossarenaRoleTips:updateMyselfInfo( team_list, force )
    if not team_list then return end

    table.sort(team_list, SortTools.KeyLowerSorter("order"))
    self.team_list = team_list

    for k,item in pairs(self.my_hero_item_list) do
        item:setVisible(false)
    end
    for i,team_data in ipairs(team_list) do
        local hero_power = 0
        -- 宝可梦
        local pos_info = team_data.pos_info or {}
        table.sort(pos_info, SortTools.KeyLowerSorter("pos"))
        for n=1,5 do
            local delay_time = 0
            if force then
                delay_time = n*2 / display.DEFAULT_FPS
            end
            delayRun(self.container, delay_time, function (  )
                local index = i*10+n
                local hero_data = pos_info[n]
                if hero_data then
                    local hero_vo = HeroController:getInstance():getModel():getHeroById(hero_data.id)
                    local hero_item = self.my_hero_item_list[index]
                    if hero_item == nil then
                        hero_item = HeroExhibitionItem.new(0.7, true)
                        self.container:addChild(hero_item)
                        self.my_hero_item_list[index] = hero_item
                    end
                    hero_item:addCallBack(function (  )
                        if hero_vo then
                            HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
                        end
                    end)
                    hero_item:setPosition(cc.p(230+(n-1)*(HeroExhibitionItem.Width*0.7+10), 400 - (i-1)*110))
                    
                    if hero_vo then
                        hero_power = hero_power + (hero_vo.power or 0)
                        hero_item:setVisible(true)
                        hero_item:setData(hero_vo)
                    end
                end
                if n == 5 then
                    -- 战力
                    local akt_txt = self.my_atk_txt_list[i]
                    if akt_txt then
                        akt_txt:setString(hero_power)
                    end
                end
            end)
        end
    end
end

-- 切换阵容
function CrossarenaRoleTips:changeTeamDataOrder( flag )
    if not self.team_list then return end
    local elfin_team_list = {}
    if flag == 1 then -- 队伍一和队伍二换位置
        for k,team_data in pairs(self.team_list) do
            if team_data.order == 1 then
                team_data.order = 2
                _table_insert(elfin_team_list, {team = team_data.order, old_team = 1})
            elseif team_data.order == 2 then
                team_data.order = 1
                _table_insert(elfin_team_list, {team = team_data.order, old_team = 2})
            else
                _table_insert(elfin_team_list, {team = team_data.order, old_team = team_data.order})
            end
        end
    else -- 队伍二和队伍三换位置
        for k,team_data in pairs(self.team_list) do
            if team_data.order == 2 then
                team_data.order = 3
                _table_insert(elfin_team_list, {team = team_data.order, old_team = 2})
            elseif team_data.order == 3 then
                team_data.order = 2
                _table_insert(elfin_team_list, {team = team_data.order, old_team = 3})
            else
                _table_insert(elfin_team_list, {team = team_data.order, old_team = team_data.order})
            end
        end
    end

    ElfinController:getInstance():send26564(PartnerConst.Fun_Form.CrossArena, elfin_team_list)
    _controller:sender25604(1, self.team_list)
    self:updateMyselfInfo(self.team_list)
end

function CrossarenaRoleTips:close_callback(  )
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
    if self.my_role_head then
        self.my_role_head:DeleteMe()
        self.my_role_head = nil
    end
    for k,item in pairs(self.hero_item_list) do
        item:DeleteMe()
        item = nil
    end
    for k,item in pairs(self.my_hero_item_list) do
        item:DeleteMe()
        item = nil
    end
	_controller:openCrossarenaRoleTips(false)
end