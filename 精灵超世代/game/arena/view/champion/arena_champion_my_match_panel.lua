-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      我的比赛界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionMyMatchPanel = class("ArenaChampionMyMatchPanel", function()
	return ccui.Layout:create()
end)

local table_insert = table.insert
local string_format = string.format

function ArenaChampionMyMatchPanel:ctor(view_type)
    self.role_list = {}

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end

    self.is_save_form = false

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_champion_my_match_panel"))
	
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd) 

    local container = self.root_wnd:getChildByName("container")
    self.notice_label = container:getChildByName("notice_label")

    self.success_img = container:getChildByName("success_img")      -- 胜利的标志
    self.success_img:setVisible(false)
    self.success_left_pos = cc.p(370,914)
    self.success_right_pos = cc.p(350,493)

    self.my_log_btn = container:getChildByName("my_log_btn")
    self.my_log_btn:getChildByName("label"):setString(TI18N("记录"))

    self.vs = container:getChildByName("vs")
    self.check_btn = container:getChildByName("check_btn")
    self.check_btn:ignoreContentAdaptWithSize(true)
    self.check_btn_label = self.check_btn:getChildByName("label")
    self.check_btn_label:setString("")

    for i=1,2 do
        local tmp_container = container:getChildByName("role_container_"..i)
        if tmp_container then
            object = {}
            object.container = tmp_container
            -- object.form_lev = tmp_container:getChildByName("form_lev")          -- 阵法等级
            object.role_name = tmp_container:getChildByName("role_name")        -- 角色名字
            object.role_lev = tmp_container:getChildByName("role_lev")          -- 角色等级
            object.power = tmp_container:getChildByName("power")          -- 战力
            object.form_bg = tmp_container:getChildByName("form_bg")
            object.form_icon = object.form_bg:getChildByName("form_icon")       -- 阵法图标
            -- object.power = CommonNum.new(20, tmp_container, 99999, - 2, cc.p(0, 0.5))   -- 角色战力
            object.elfin_tree_bg = tmp_container:getChildByName("elfin_tree_bg") -- 精灵古树bg
            object.elfin_tree_lv = tmp_container:getChildByName("elfin_tree_lv") -- 精灵古树等级
            object.elfin_tree_bg:setLocalZOrder(998)
            object.elfin_tree_lv:setLocalZOrder(999)
            object.elfin_tree_lv:setString(TI18N("古树等级：0"))
            object.elfin_list = {}

            if IS_HIDE_ELFIN then
                object.elfin_tree_lv:setVisible(false)
                object.elfin_tree_bg:setVisible(false)
            end
            -- if i == 1 then
            --     object.power:setPosition(168, 342)
            -- else
            --     object.power:setPosition(184, 177)
            -- end
            object.role_head = PlayerHead.new(PlayerHead.type.circle)       -- 角色头像
            object.role_head:setHeadLayerScale(0.8)
            if i == 1 then
                object.role_head:setPosition(86, 418)
            else
                object.role_head:setPosition(102, 140)
            end
            tmp_container:addChild(object.role_head) 
            self.role_list[i] = object
        end
    end
    self.main_panel = container
    self:createLeftPartnerList()
    self:createRightPartnerList()
    self:registerEvent()
end

function ArenaChampionMyMatchPanel:registerEvent()
    for i,object in ipairs(self.role_list) do
        if object.form_bg then
            -- object.form_bg:addTouchEventListener(function(sender, event_type) 
            --     if self.data then
            --         local data_vo = {}
            --         local other_vo = {}
            --         if i == 1 then
            --             data_vo = {self.data.a_formation_type or 1, self.data.a_formation_lev or 0}
            --             other_vo = {self.data.b_formation_type or 1, self.data.b_formation_lev or 0}
            --         else
            --             data_vo = {self.data.b_formation_type or 1, self.data.b_formation_lev or 0}
            --             other_vo = {self.data.a_formation_type or 1, self.data.a_formation_lev or 0}
            --         end            
            --         TipsManager:getInstance():hideTips()
            --         TipsManager:getInstance():showBattleTacticalTips(data_vo, 4, sender) 
            --     end
            -- end)
        end
    end
    self:registerScriptHandler(function(event)
        if "enter" == event then
            self.ui_action = cc.CSLoader:createTimeline(PathTool.getTargetCSB("arena/arena_champion_my_match_panel"))
            self.root_wnd:runAction(self.ui_action)
            self.ui_action:play("ui_start", false)
        elseif "exit" == event then

        end 
    end)
	self.check_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender,event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            local base_info = self.model:getBaseInfo()
            if self.data and base_info then
                if self.data.ret == 0 then
                    if self.view_type == ArenaConst.champion_type.normal then
                        BattleController:getInstance():csRecordBattle(self.data.replay_id)
                    else
                        BattleController:getInstance():csRecordBattle(self.data.replay_id, base_info.srv_id)
                    end
                else
                    ArenaController:getInstance():openArenaChampionReportWindow(true, self.data, self.view_type)
                end
            end
		end
	end)
	self.my_log_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.data then
                ArenaController:getInstance():openArenaChampionMyLogWindow(true, self.view_type)
            end
		end
	end)
end

--==============================--
--desc:
--time:2018-08-04 02:21:38
--@status:
--@return 
--==============================--
function ArenaChampionMyMatchPanel:handleEvent(status)
    if status == true then
        if self.update_my_match_event == nil then
            self.update_my_match_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateMyMatchInfoEvent, function(data) 
                self:updateFightInfo(data)
            end)
        end
        if self.save_fun_form_event == nil then
            self.save_fun_form_event = GlobalEvent:getInstance():Bind(HeroEvent.Update_Save_Form, function(data)
                if not data then return end
                if data.type and data.type == PartnerConst.Fun_Form.ArenaChampion then
                    self.is_save_form = true
                    if self.view_type == ArenaConst.champion_type.normal then
                        self.ctrl:requestMyChampionMatch()
                    else
                        self.ctrl:sender26202()
                    end
                end
            end)
        end
        if self.save_fun_form_event1 == nil then
            self.save_fun_form_event1 = GlobalEvent:getInstance():Bind(ElfinEvent.Elfin_Plan_Save_From_Event, function(data)
                -- if not data then return end
                -- if data.type and data.type == PartnerConst.Fun_Form.ArenaChampion then
                --     if data.team_list and data.team_list[1] then
                --         self:updateLeftElfinInfo(data.team_list[1].sprites)
                --     end
                -- end
                if not data then return end
                if data.type and data.type == PartnerConst.Fun_Form.ArenaChampion then
                    self.is_save_form = true
                    if self.view_type == ArenaConst.champion_type.normal then
                        self.ctrl:requestMyChampionMatch()
                    else
                        self.ctrl:sender26202()
                    end
                end
            end)
        end
    else
        if self.update_my_match_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_my_match_event)
            self.update_my_match_event = nil
        end
        if self.save_fun_form_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.save_fun_form_event)
            self.save_fun_form_event = nil
        end
        if self.save_fun_form_event1 ~= nil then
            GlobalEvent:getInstance():UnBind(self.save_fun_form_event1)
            self.save_fun_form_event1 = nil
        end
    end
end

function ArenaChampionMyMatchPanel:addToParent(status)
	self:setVisible(status)
    self:handleEvent(status)
end

--==============================--
--desc:创建左边的伙伴列表
--time:2018-08-02 11:06:31
--@return 
--==============================--
function ArenaChampionMyMatchPanel:createLeftPartnerList()
    local object = self.role_list[1]
    if object == nil then return end
    object.partner_list = {}
    local scale = 0.7
    local off = 10
    local start_x = 306
    local start_y = 100
    local row = 3
    local item_width = BackPackItem.Width * scale 
    for i=1,9 do
        local _x = start_x - item_width * 0.5 - (item_width + off) * (math.floor((i - 1)/row))
        local _y = start_y + (item_width * 0.5 + ((i - 1) % row) * (item_width + off)) 
        local item = HeroExhibitionItem.new(scale, false, true)
        item:setPosition(_x, _y)
        item:setOpacity(128)
        object.container:addChild(item)
        table_insert(object.partner_list, item) 
    end
end

--==============================--
--desc:创建右边的伙伴列表
--time:2018-08-02 11:22:28
--@return 
--==============================--
function ArenaChampionMyMatchPanel:createRightPartnerList()
	local object = self.role_list[2]
	if object == nil then return end
	object.partner_list = {}
	local scale = 0.7
	local off = 10
	local start_x = 110
	local start_y = 194
	local row = 3
	local item_width = BackPackItem.Width * scale
	for i = 1, 9 do
		local _x = start_x + item_width * 0.5 + (item_width + off) * (math.floor((i - 1) / row))
		local _y = start_y + (item_width * 0.5 + ((i - 1) % row) * (item_width + off))
		local item = HeroExhibitionItem.new(scale, false, true)
		item:setPosition(_x, _y)
        item:setOpacity(128)
		object.container:addChild(item)
		table_insert(object.partner_list, item)
	end
end 

--==============================--
--desc:设置对战数据
--time:2018-08-04 02:39:12
--@data:
--@return 
--==============================--
function ArenaChampionMyMatchPanel:updateFightInfo(data)
    if data == nil then return end
    -- 判断一下是否需要做数据的更新
    if self.data and not self.is_save_form then
        if getNorKey(self.data.step, self.data.round, self.data.replay_id, self.data.a_power, self.data.ret) == getNorKey(data.step, data.round, data.replay_id, data.a_power, data.ret) then
            return
        end
    end
    self.is_save_form = false
    local need_delay = (self.data and self.data.ret ~= data.ret and data.ret ~= 0)  
    self.data = data
    -- 非切换界面更新
    if self.is_change_tab == false then
        local base_info = self.model:getBaseInfo()
        if base_info and base_info.flag == 2 and data.replay_id ~= 0 and getNorKey(base_info.step, base_info.round) == getNorKey(data.step, data.round) then   -- 这个时候要切换观战模式
            if self.view_type == ArenaConst.champion_type.normal then
                BattleController:getInstance():csRecordBattle(data.replay_id)
            else
                BattleController:getInstance():csRecordBattle(data.replay_id, base_info.srv_id)
            end
        end
    end
    self:setBothSidesBaseInfo(need_delay) 
    self:setLeftPartnerInfo()
    self:setRightPartnerInfo()
end

function ArenaChampionMyMatchPanel:updateLeftElfinInfo(sprites)
    if not self.data then return end
    self.data.a_sprites = sprites or {}
    local left_object = self.role_list[1]
    if left_object then
        for i=1,4 do
            local elfin_skill_item = left_object.elfin_list[i]
            if elfin_skill_item then
                self:setElfinSkillItemData(elfin_skill_item, self.data.a_sprites, i)
            end
        end
    end
end

--==============================--
--desc:更新双方的基础数据,姓名,等级阵法之类的
--time:2018-08-04 03:29:47
--@return 
--==============================--
function ArenaChampionMyMatchPanel:setBothSidesBaseInfo(need_delay)
    local base_info = self.model:getBaseInfo()
    if self.data == nil or base_info == nil then return end
    local left_object = self.role_list[1]
    if left_object then
        local res = "res/resource/form/form_form_icon_"..self.data.a_formation_type..".png"
        loadSpriteTexture(left_object.form_icon, res, ccui.TextureResType.localType)
        -- left_object.form_lev:setString(string_format("Lv.%s", self.data.a_formation_lev))
        left_object.role_name:setString(transformNameByServ(self.data.a_name, self.data.a_srv_id))
        left_object.role_lev:setString(string_format("%s级", self.data.a_lev))
        left_object.role_head:setHeadRes(self.data.a_face, false, LOADTEXT_TYPE, self.data.a_face_file, self.data.a_face_update_time)
        -- left_object.power:setNum(self.data.a_power)
        left_object.power:setString(string.format("%s:%d", TI18N("战力"), changeBtValueForPower(self.data.a_power)))
        -- 精灵相关
        if IS_HIDE_ELFIN ~= true then            
            local tree_lv = self.data.a_sprite_lev or 0
            left_object.elfin_tree_lv:setString(TI18N("古树等级：") .. tree_lv)
            for i=1,4 do
                local elfin_skill_item = left_object.elfin_list[i]
                if not elfin_skill_item then
                    elfin_skill_item = SkillItem.new(true, true, true, 0.5, true)
                    local pos_x = 40 + (i-1)*65
                    elfin_skill_item:setPosition(cc.p(pos_x, 38))
                    left_object.container:addChild(elfin_skill_item)
                    left_object.elfin_list[i] = elfin_skill_item
                end
                local is_open = ElfinController:getInstance():getModel():getElfinItemByPos(i)
                self:setElfinSkillItemData(elfin_skill_item, self.data.a_sprites, i, is_open)
            end
        end
    end
    local right_object = self.role_list[2]
    if right_object then
        local res = "res/resource/form/form_form_icon_"..self.data.b_formation_type..".png"
        loadSpriteTexture(right_object.form_icon, res, ccui.TextureResType.localType)
        -- right_object.form_lev:setString(string_format("Lv.%s", self.data.b_formation_lev))
        right_object.role_name:setString(transformNameByServ(self.data.b_name, self.data.b_srv_id))
        right_object.role_lev:setString(string_format("%s级", self.data.b_lev))
        right_object.role_head:setHeadRes(self.data.b_face, false, LOADTEXT_TYPE, self.data.b_face_file, self.data.b_face_update_time)
        -- right_object.power:setNum(self.data.b_power)
        right_object.power:setString(string.format("%s:%d", TI18N("战力"), changeBtValueForPower(self.data.b_power)))
        -- 精灵相关
        if IS_HIDE_ELFIN ~= true then
            local tree_lv = self.data.b_sprite_lev or 0
            right_object.elfin_tree_lv:setString(TI18N("古树等级：") .. tree_lv)
            for i=1,4 do
                local elfin_skill_item = right_object.elfin_list[i]
                if not elfin_skill_item then
                    elfin_skill_item = SkillItem.new(true, true, true, 0.5, true)
                    local pos_x = 180 + (i-1)*65
                    elfin_skill_item:setPosition(cc.p(pos_x, 518))
                    right_object.container:addChild(elfin_skill_item)
                    right_object.elfin_list[i] = elfin_skill_item
                end
                self:setElfinSkillItemData(elfin_skill_item, self.data.b_sprites, i)
            end
        end
    end

    -- 胜利状态
    if self.data.ret == 0 then
        self.success_img:setVisible(false) 
        if self.data.replay_id == 0 then
            self.check_btn:setVisible(false)
            self.vs:setVisible(true)
        else
            self.check_btn:loadTexture(PathTool.getResFrame("commonicon","common_icon_15"), LOADTEXT_TYPE_PLIST)
            self.check_btn:setVisible(true)
            self.check_btn_label:setString(TI18N("观战"))
            self.vs:setVisible(false)
        end 
    else
        local function do_callback()
            if not tolua.isnull(self.success_img) then
                -- if self.data.step == base_info.step and self.data.round == base_info.round and base_info.round_status == ArenaConst.champion_round_status.fight then
                --     self.success_img:setVisible(false)
                -- else 
                --     self.success_img:setVisible(true)
                -- end
                -- self.check_btn:loadTexture(PathTool.getResFrame("arena","arenachampion_1031",false,"arenachampion"), LOADTEXT_TYPE_PLIST)
                self.check_btn:loadTexture(PathTool.getResFrame("commonicon","common_icon_25"), LOADTEXT_TYPE_PLIST)
                self.success_img:setVisible(true)
                self.check_btn:setVisible(true)
                self.check_btn_label:setString(TI18N("查看"))
                self.vs:setVisible(false)
                if self.data.ret == 1 then -- 胜利
                    self.success_img:setPosition(self.success_left_pos)
                else
                    self.success_img:setPosition(self.success_right_pos)
                end
            end
        end
        if need_delay == true then
            delayRun(self.main_panel,1,do_callback)
        else
            do_callback()
        end
    end
end

-- 根据位置获取精灵的bid
function ArenaChampionMyMatchPanel:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function ArenaChampionMyMatchPanel:setElfinSkillItemData( skill_item, sprite_data, pos, is_open)
    local elfin_bid = self:getElfinBidByPos(sprite_data, pos)
    if elfin_bid or is_open ~= nil then
        elfin_bid = elfin_bid or 0
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

--==============================--
--desc:设置左边伙伴的站位
--time:2018-08-04 04:36:08
--@return 
--==============================--
function ArenaChampionMyMatchPanel:setLeftPartnerInfo()
    if self.data == nil then return end
    local config = Config.FormationData.data_form_data[self.data.a_formation_type]
    if not config or not config.pos then return end
    local object = self.role_list[1]
    if object == nil or object.partner_list == nil then return end
    -- 先把所有的格子都透明掉
    for i,item in ipairs(object.partner_list) do
        item:setData()
        -- item:showAddIcon(false)
        item:setOpacity(128)
    end
    local function getVo(pos)
        for i,v in ipairs(self.data.a_plist) do
            if v.pos == pos then
                return v
            end
        end
    end

    -- 根据阵法转换格子位置
    for i, v in pairs(config.pos) do
        if v and v[1] and v[2] then
            local item = object.partner_list[v[2]]
            local vo = getVo(v[1])
            if item then
                item:setOpacity(255)
                item:setData(vo)
            end
        end
    end
end

--==============================--
--desc:更新右边的阵法
--time:2018-08-04 04:42:39
--@return 
--==============================--
function ArenaChampionMyMatchPanel:setRightPartnerInfo()
    if self.data == nil then return end
    local config = Config.FormationData.data_form_data[self.data.b_formation_type]
    if not config or not config.pos then return end
    local object = self.role_list[2]
    if object == nil or object.partner_list == nil then return end
    -- 先把所有的格子都透明掉
    for i,item in ipairs(object.partner_list) do
        item:setData()
        item:setOpacity(128)
    end
    local function getVo(pos)
        for i,v in ipairs(self.data.b_plist) do
            if v.pos == pos then
                return v
            end
        end
    end
    -- 根据阵法转换格子位置
    for i, v in pairs(config.pos) do
        if v and v[1] and v[2] then
            local item = object.partner_list[v[2]]
            local vo = getVo(v[1])
            if item then
                item:setOpacity(255)
                item:setData(vo)
            end
        end
    end
end 

--==============================--
--desc:显示自己是否进入到指定的阶段
--time:2018-08-04 05:45:01
--@return 
--==============================--
function ArenaChampionMyMatchPanel:setChampionMyStepStatusInfo()
    local base_info = self.model:getBaseInfo()
    local role_info = self.model:getRoleInfo()
    if base_info == nil or role_info == nil then return end

    self.notice_label:setVisible(true)
    -- 只要排名大于32,那么就是未进入32强
    if base_info.step == ArenaConst.champion_step.match_64 and role_info.rank > 64 then
        self.notice_label:setString(TI18N("您未进入64强"))
    elseif base_info.step == ArenaConst.champion_step.match_32 and role_info.rank > 32 then
        self.notice_label:setString(TI18N("您未进入32强"))
    else
        if base_info.step == ArenaConst.champion_step.match_64 then
            if base_info.round == 2 and role_info.rank > 32 then
                self.notice_label:setString(TI18N("您未进入32强"))
            elseif base_info.round == 3 and role_info.rank > 16 then
                self.notice_label:setString(TI18N("您未进入16强"))
            else
                self.notice_label:setVisible(false)
            end
        elseif base_info.step == ArenaConst.champion_step.match_32 then
            if base_info.round == 2 and role_info.rank > 16 then
                self.notice_label:setString(TI18N("您未进入16强"))
            elseif base_info.round == 3 and role_info.rank > 8 then
                self.notice_label:setString(TI18N("您未进入8强"))
            else
                self.notice_label:setVisible(false)
            end
        elseif base_info.step == ArenaConst.champion_step.match_8 then
            if base_info.round == 1 and role_info.rank > 8 then   
                self.notice_label:setString(TI18N("您未进8强赛"))
            elseif base_info.round == 2 and role_info.rank > 4 then 
                self.notice_label:setString(TI18N("您未进入半决赛"))
            elseif base_info.round == 3 and role_info.rank > 2 then 
                self.notice_label:setString(TI18N("您未进入决赛"))
            else
                self.notice_label:setVisible(false)
            end
        elseif base_info.step == ArenaConst.champion_step.match_4 then
            if base_info.round == 1 and role_info.rank > 4 then     -- 未进入4强强
                self.notice_label:setString(TI18N("您未进4强赛"))
            elseif base_info.round == 2 and role_info.rank > 2 then -- 未进入决赛
                self.notice_label:setString(TI18N("您未进入决赛"))
            else
                self.notice_label:setVisible(false)
            end
        else
            self.notice_label:setVisible(false)
        end
    end
end

--==============================--
--desc:主界面更新数据或者切换的时候触发
--time:2018-08-04 02:46:38
--@status:true为切换面板
--@return 
--==============================--
function ArenaChampionMyMatchPanel:updateInfo(status)
    local base_info = self.model:getBaseInfo()
    local role_info = self.model:getRoleInfo()
    if base_info == nil or role_info == nil then return end
    self.is_change_tab = status -- 是否是切换面板的,如果是切换面板,在收到20252协议之后,要判断base是2的就要根据20252的录像id进去查看录像
    if status == true or base_info.flag ~= 0 then
	    if self.view_type == ArenaConst.champion_type.normal then
            self.ctrl:requestMyChampionMatch()
        else
            self.ctrl:sender26202()
        end
    end 
    self:setChampionMyStepStatusInfo()
end

function ArenaChampionMyMatchPanel:DeleteMe()
    doStopAllActions(self.main_panel)
    self:handleEvent(false)
    if self.ui_action then
        self.ui_action:clearFrameEventCallFunc()
	end
    for i, object in ipairs(self.role_list) do
        -- if object.power then
        --     object.power:DeleteMe()
        -- end
        if object.role_head then
            object.role_head:DeleteMe()
        end
        if object.partner_list then
            for k,v in pairs(object.partner_list) do
                if v.DeleteMe then
                    v:DeleteMe()
                end
            end
        end
        if object.elfin_list then
            for _,item in pairs(object.elfin_list) do
                item:DeleteMe()
                item = nil
            end
        end
    end
    self.role_list = nil
end 