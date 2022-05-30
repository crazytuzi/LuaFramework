-- --------------------------------------------------------------------
-- 竞技场的挑战界面
-- --------------------------------------------------------------------
ArenaLoopChallengePanel =  class("ArenaLoopChallengePanel", function()
    return ccui.Layout:create()
end)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel() 
local game_net = GameNet:getInstance()
local string_format = string.format
local role_vo = RoleController:getInstance():getRoleVo()
local box_config = Config.ArenaData.data_season_num_reward
local box_reward_length = Config.ArenaData.data_season_num_reward_length
function ArenaLoopChallengePanel:ctor()
    self.refresh_status = 0
    self.free_num = 0 --免费次数
    self.has_num = 0 --拥有个数
    self.had_combat_num = 0
    self.play_effect = {} --宝箱
    self.bool_box_status = {} -- 0：不可领取 1：可领取 2：已领取
    self.arena_skip_count = Config.ArenaData.data_const["arena_skip_count"].val --跳过的次数

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_loop_challenge_panel"))
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.protect_btn = self.root_wnd:getChildByName("protect_btn")
    self.protect_btn:getChildByName("label"):setString(TI18N("防守阵容"))

    self.refresh_btn = self.root_wnd:getChildByName("refresh_btn")
    self.refresh_label = self.refresh_btn:getChildByName("label")
    self.refresh_label:setString(TI18N("刷新"))

    -- local botton_load = self.root_wnd:getChildByName("Sprite_8")
    -- local bg_top = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_4")
    -- if not self.banner_load_botton then
    --     self.banner_load_botton = loadSpriteTextureFromCDN(botton_load, bg_top, ResourcesType.single, self.banner_load_botton)
    -- end

    self.addtimes_btn = self.root_wnd:getChildByName("addtimes_btn")
    local add_times_bg = self.root_wnd:getChildByName("add_times_bg")
    self.add_times_sprite = self.root_wnd:getChildByName("add_times_sprite")
    self.add_times_sprite:setScale(0.5)
    self.text_add_time = self.root_wnd:getChildByName("text_add_time")

    self.my_log_btn = self.root_wnd:getChildByName("my_log_btn")
    self.my_log_btn:getChildByName("label"):setString(TI18N("挑战记录"))
    self.my_log_tips = self.my_log_btn:getChildByName("tips")

    self.challenge_shop = self.root_wnd:getChildByName("challenge_shop")
    self.challenge_shop:getChildByName("label"):setString(TI18N("竞技商店"))

    local score_container = self.root_wnd:getChildByName("score_container")
 
    score_container:getChildByName("title"):setString(TI18N("积分："))
    self.my_score = score_container:getChildByName("score")
    self.rank = score_container:getChildByName("rank")

    self.time_label = score_container:getChildByName("time_label")
    score_container:getChildByName("time_label_0"):setString(TI18N("距离结束:"))
    self.time_label:setString(string_format("%s", "00:00:00"))

    self.change_bg = self.root_wnd:getChildByName("Sprite_6")
    local Text_5 = self.change_bg:getChildByName("Text_5"):setString(TI18N("每周宝箱"))
    local Text_5_x = Text_5:getPositionX()
    local Text_5_size = Text_5:getContentSize()
    self.change_num = self.change_bg:getChildByName("change_num")
    self.change_num:setString("")
    self.change_num:setPositionX(Text_5_x + Text_5_size.width + 10)

    self.btn_jump_fight = self.root_wnd:getChildByName("btn_jump_fight")
    self.check_jump_fight = self.btn_jump_fight:getChildByName("check_jump_fight")
    self.check_jump_fight:setVisible(true)
    local tmp_test = self.root_wnd:getChildByName("Text_1")
    tmp_test:setString(TI18N("跳过战斗"))
    -- tmp_test:setVisible(false)
    -- self.btn_jump_fight:setVisible(false)

    self.box_panel = self.root_wnd:getChildByName("box_panel")
    self.box_bar = self.box_panel:getChildByName("box_bar")
    self.box_bar:setScale9Enabled(true)

    local box_length = self.box_panel:getChildByName("Image_2"):getContentSize().width
    local box_ave_x = box_length / box_reward_length

    self.box_list = {}
    self.box_get_num = {}
    for i = 1, box_reward_length do
        self.box_list[i] = self.box_panel:getChildByName("box_"..i)
        self.box_list[i]:setPositionX(box_ave_x * i)
        local num = self.box_list[i]:getChildByName("num")
        num:setString(box_config[i].num)
        self.box_get_num[i] = box_config[i].num
    end

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    local size = self.scroll_container:getContentSize()
    local setting = {
        item_class = ArenaLoopChallengeItem,
        start_x = 13,
        space_x = 0,
        start_y = 10,
        space_y = 10,
        item_width = 652,
        item_height = 114,
        row = 0,
        col = 1
    }
    self.scroll_view = CommonScrollViewLayout.new(self.scroll_container, cc.p(0, 4), nil, nil, cc.size(size.width, size.height-8), setting)
    self.scroll_view:setClickEnabled(false)

    self:registerEvent()
end

function ArenaLoopChallengePanel:registerEvent()
    registerButtonEventListener(self.refresh_btn, function()
        controller:requestRefreshChallengeList()
    end,true, 1)

    --防御阵型
    registerButtonEventListener(self.protect_btn, function()
        HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.Arena)
    end,true, 1)

    registerButtonEventListener(self.addtimes_btn, function()
        controller:openArenaLoopChallengeBuy(true)
    end,true, 1)

    registerButtonEventListener(self.my_log_btn, function()
        controller:openArenaLoopMyLogWindow(true)
        model:updateArenaLoopLogStatus(FALSE)
    end,true, 1)

    --跳过战斗
    registerButtonEventListener(self.btn_jump_fight, function()
        if self.cur_combat_num then
            if self.cur_combat_num < self.arena_skip_count then
                self.check_jump_fight:setVisible(false)
                message(string.format(TI18N("本赛季中挑战达%d次后可跳过战斗"),self.arena_skip_count))
            else
                if self.check_jump_fight:isVisible() == true then
                    self.check_jump_fight:setVisible(false)
                else
                    self.check_jump_fight:setVisible(true)
                end
                model:setJumpFightStatus(self.check_jump_fight:isVisible())     
            end
        end
    end,true, 1)

    for i,btn in pairs(self.box_list) do
        registerButtonEventListener(btn, function(param,sender, event_type)
            if self.bool_box_status[i] == 1 then
                controller:requestGetChallengeTimesAwards(box_config[i].num)
            else
                self:showRewardItems(box_config[i].items,sender:getTouchBeganPosition(), i)
            end
        end,true, 1)
    end

    registerButtonEventListener(self.challenge_shop, function()
        MallController:getInstance():openMallPanel(true, MallConst.MallType.ArenaShop)
    end,true, 1)

    if self.update_challenge_list == nil then
        self.update_challenge_list = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeList, function()
            self:updateChallengeList()
        end)
    end

    if self.update_challenge_num == nil then
        self.update_challenge_num = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateArena_Number, function()
            local id = Config.ArenaData.data_const.arena_ticketcost.val[1][1]
            local item_config = Config.ItemData.data_get_data(id)
            self.has_num = self.has_num or 0
            loadSpriteTexture(self.add_times_sprite, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
            self.text_add_time:setString(BackpackController:getInstance():getModel():getBackPackItemNumByBid(id))
        end)
    end

    if self.update_challenge_time_num == nil then
        self.update_challenge_time_num = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeTimesList, function(data)
            if not data then return end
            self.cur_combat_num = data.had_combat_num
            if self.cur_combat_num < self.arena_skip_count then
                setChildUnEnabled(true, self.btn_jump_fight)
                self.check_jump_fight:setVisible(false)
            else
                setChildUnEnabled(false, self.btn_jump_fight)
                model:setJumpFightStatus(self.check_jump_fight:isVisible())
            end
            
            local str = string_format(TI18N("( 挑战%d次 )"),data.had_combat_num)  
            self.box_bar:setPercent(self:segmentBarPercent(data.had_combat_num))

            self.change_num:setString(str)
            local change_num_size = self.change_num:getContentSize()
            local change_num_x = self.change_num:getPositionX()
            local change_bg_size = self.change_bg:getContentSize()
            self.change_bg:setContentSize(cc.size(change_num_x + change_num_size.width + 30, change_bg_size.height))
            self.had_combat_num = data.had_combat_num
            for i,v in pairs(box_config) do
                self.bool_box_status[i] = 0
                if v.num <= data.had_combat_num then
                    self.bool_box_status[i] = 1
                    for k,val in pairs(data.num_list) do
                        if val.num == v.num then
                            self.bool_box_status[i] = 2
                        end
                    end
                end
            end
            self:updateTaskList(self.bool_box_status)
        end)
    end
end
--分段处理进度条
function ArenaLoopChallengePanel:segmentBarPercent(num)
    local segmeent = 14.2

    local percent = 1
    if num <= box_config[1].num then
        return num / box_config[1].num * segmeent
    elseif num > box_config[1].num and num <= box_config[2].num then
        percent = 2
    elseif num > box_config[2].num and num <= box_config[3].num then
        percent = 3
    elseif num > box_config[3].num and num <= box_config[4].num then
        percent = 4
    elseif num > box_config[4].num and num <= box_config[5].num then
        percent = 5
    elseif num > box_config[5].num and num <= box_config[6].num then
        percent = 6
    elseif num > box_config[6].num and num <= box_config[7].num then
        percent = 7
    else
        return 100
    end
    local adv = box_config[percent].num - box_config[percent-1].num
    local count = num - box_config[percent-1].num
    local percent_num = segmeent*(percent - 1) + ( count / adv ) * segmeent
    return percent_num
end

function ArenaLoopChallengePanel:updateTaskList(data)
    for i=1, 7 do        
        local action = PlayerAction.action_1
        if data[i] then
            if data[i] == 0 then
                action = PlayerAction.action_1
            elseif data[i] == 1 then
                action = PlayerAction.action_2
            elseif data[i] == 2 then
                action = PlayerAction.action_3
            end
        end
        if self.play_effect[i] then
            self.play_effect[i]:clearTracks()
            self.play_effect[i]:removeFromParent()
            self.play_effect[i] = nil
        end
        local list = {109,109,108,108,110,110,110}
        if not tolua.isnull(self.box_list[i]) and self.play_effect[i] == nil then
            local res_id = PathTool.getEffectRes(list[i])
            self.play_effect[i] = createEffectSpine(res_id, cc.p(self.box_list[i]:getContentSize().width * 0.5, 15), cc.p(0, 0), true, action)
            self.box_list[i]:addChild(self.play_effect[i])
        end
    end
end

function ArenaLoopChallengePanel:showRewardItems(data, pos, touch_pos)
    local size = self.root_wnd:getContentSize()
    if not self.tips_layer then
        self.tips_layer = ccui.Layout:create()
        self.tips_layer:setContentSize(size)
        self.root_wnd:addChild(self.tips_layer)
        self.tips_layer:setTouchEnabled(true)
        registerButtonEventListener(self.tips_layer, function()
            self.tips_bg:removeFromParent()
            self.tips_bg = nil
            self.tips_layer:removeFromParent()
            self.tips_layer = nil
        end,false, 1)
    end
    
    local list = {}
    if not self.tips_bg then
        self.tips_bg = createImage(self.tips_layer, PathTool.getResFrame("common","common_90024"), size.width*0.5, 100, cc.p(0,0), true, 10, true)
        self.tips_bg:setTouchEnabled(true)
    end
    if self.tips_bg then
        self.tips_bg:setContentSize(cc.size(BackPackItem.Width*#data+40,BackPackItem.Height+50))
        local ccp = cc.p(0.5,0)
        local world_pos = self.root_wnd:convertToWorldSpace(cc.p(0,0))
        local offx = 0
        if self.tips_bg:getContentSize().width/2 + pos.x >= world_pos.x + 720 then
            ccp = cc.p(1,0)
        end
        self.tips_bg:setAnchorPoint(ccp)
        self.tips_bg:setPosition(self.box_list[touch_pos]:getPositionX()+10-offx, 108)
    end

    for i,v in pairs(data) do
        if not list[i] then
            list[i] = BackPackItem.new(nil,true,nil,0.8)
            list[i]:setAnchorPoint(cc.p(0,0.5))
            self.tips_bg:addChild(list[i])
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(BackPackItem.Width*(i-1)+30, 90))
            list[i]:setDefaultTip()
            
            self.text_num = createLabel(22,Config.ColorData.data_new_color4[6],nil,60,-25,"",list[i],nil, cc.p(0.5,0.5))
            self.text_num:setString("x"..v[2])
        else
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(BackPackItem.Width*(i-1)+30, 90))
            self.text_num:setString("x"..v[2])
        end
    end
end

function ArenaLoopChallengePanel:addToParent()
    controller:sender20208()
    controller:requestChallengeList()
end

function ArenaLoopChallengePanel:setNodeVisible(status)
    self:setVisible(status)
    self:handleEvent(status)
    if status == true then
        if self.tips_bg then
            self.tips_bg:removeFromParent()
            self.tips_bg = nil
        end
        if self.tips_layer then
            self.tips_layer:removeFromParent()
            self.tips_layer = nil
        end
        self:updateMyLogTips()
    end
end

--- 更新我的挑战记录红点状态
function ArenaLoopChallengePanel:updateMyLogTips()
    if self.my_log_tips == nil then return end
    local status = model:getLoopMatchRedStatus(ArenaConst.red_type.loop_log)
    self.my_log_tips:setVisible(status)
end

function ArenaLoopChallengePanel:handleEvent(status)
    if status == true then
        if self.time_ticket == nil then
            self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
                self:countDownTimeTicket()
            end, 1)
        end
        self:countDownTimeTicket()
    else
        if self.time_ticket ~= nil then
            GlobalTimeTicket:getInstance():remove(self.time_ticket)
            self.time_ticket = nil
        end
    end
end

function ArenaLoopChallengePanel:countDownTimeTicket()
    local data = model:getMyLoopData() 
    if data == nil then
		self:handleEvent(false)
		return
	end
	local less_time = data.end_time - game_net:getTime()
	if less_time >= 0 then
        self.time_label:setString(string_format("%s", TimeTool.GetTimeFormat(less_time)))
	end

    local refresh = data.ref_time - game_net:getTime()
    if refresh >= 0 then
        self.refresh_label:setString(string_format("%s", TimeTool.GetTimeFormat(refresh)))
    else
        if self.refresh_status == 1 then
            self.refresh_status = 0
            setChildUnEnabled(false, self.refresh_btn) 
            self.refresh_btn:setTouchEnabled(true) 
    	    -- self.refresh_label:enableOutline(Config.ColorData.data_color4[264], 2)
            self.refresh_label:setString(TI18N("刷新"))
        end
    end
end

function ArenaLoopChallengePanel:updatePanelInfo(is_event)
    local my_data = model:getMyLoopData()
    if my_data == nil then return end

    local config, _ = model:getZoneConfig()
    self.my_score:setString(my_data.score)
    self.rank:setString(string_format(TI18N("排名: %s"), my_data.rank))

    local id = Config.ArenaData.data_const.arena_ticketcost.val[1][1]
    local item_config = Config.ItemData.data_get_data(id)
    local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(id)
    local num = my_data.can_combat_num + count
    self.has_num = num
    self.free_num = my_data.can_combat_num
    loadSpriteTexture(self.add_times_sprite, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    self.text_add_time:setString(count)

    self:updateChallengeList()

    if self.cup_index ~= config.index then
        self.cup_index = config.index
    end
    -- 不在冷却的时候就直接显示刷新
    local refresh_time = my_data.ref_time - game_net:getTime()
    if refresh_time <= 0 then
        setChildUnEnabled(false, self.refresh_btn) 
        self.refresh_btn:setTouchEnabled(true) 
    	-- self.refresh_label:enableOutline(Config.ColorData.data_color4[264], 2)
        self.refresh_label:setString(TI18N("刷新"))
        self.refresh_status = 0
    else
        self.refresh_label:setString(string_format("%s", TimeTool.GetTimeFormat(refresh_time)))
        setChildUnEnabled(true, self.refresh_btn) 
        self.refresh_btn:setTouchEnabled(false) 
        self.refresh_label:disableEffect()
        self.refresh_status = 1
    end
end

--[[
    @desc:更新整个列表，单条更新就放到各自数据事件中更新
]]
function ArenaLoopChallengePanel:updateChallengeList()
    local list = model:getLoopChallengeList()
    if list ~= nil and next(list) ~= nil then
        local tab = {}
        tab.free_num = self.free_num
        tab.has_num = self.has_num
        self.scroll_view:setData(list,nil,nil,tab)
    end
end

function ArenaLoopChallengePanel:DeleteMe()
    self:handleEvent(false)
    if self.update_challenge_list ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_challenge_list)
        self.update_challenge_list = nil
    end
    if self.update_challenge_time_num ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_challenge_time_num)
        self.update_challenge_time_num = nil
    end
    if self.update_challenge_num ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_challenge_num)
        self.update_challenge_num = nil
    end
    if self.play_effect and next(self.play_effect or {}) ~= nil then
        for i=1, 7 do
            if self.play_effect[i] then
                self.play_effect[i]:clearTracks()
                self.play_effect[i]:removeFromParent()
                self.play_effect[i] = nil
            end
        end
    end
    self.play_effect = {}
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    -- if self.banner_load_botton then
    --     self.banner_load_botton:DeleteMe()
    -- end
    -- self.banner_load_botton = nil
end

-- --------------------------------------------------------------------
-- 挑战赛的单元
-- --------------------------------------------------------------------
ArenaLoopChallengeItem = class("ArenaLoopChallengeItem", function()
    return ccui.Layout:create()
end)

function ArenaLoopChallengeItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_loop_challenge_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.role_name = self.container:getChildByName("role_name")
    self.role_name_x = self.role_name:getPositionX()
    self.role_power = self.container:getChildByName("role_power")
    self.role_score = self.container:getChildByName("role_score")
    self.role_score_0 = self.container:getChildByName("role_score_0")
    self.role_score_0:setString(TI18N("积分："))
    self.role_power_0 = self.container:getChildByName("role_power_0")
    self.role_power_0:setString(TI18N("战力："))
    self.same_guild = self.container:getChildByName("same_guild")
    if self.same_guild then
        self.same_guild:setString(TI18N("（同公会）"))
    end

    self.challenge_btn = self.container:getChildByName("challenge_btn")
    -- self.icon = self.challenge_btn:getChildByName("icon")
    -- self.icon:setScale(0.4)
    -- local item_config = Config.ItemData.data_get_data(Config.ArenaData.data_const.arena_ticketcost.val[1][1])
    -- loadSpriteTexture(self.icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)

    self.challenge_btn_label = createRichLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5, 0.5), cc.p(self.challenge_btn:getContentSize().width*0.5, self.challenge_btn:getContentSize().height*0.5), nil, nil, 180)
    self.challenge_btn:addChild(self.challenge_btn_label)

    self.finish_img = self.container:getChildByName("finish_img")
    self.finish_img:setVisible(false)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.7)
    self.role_head:setPosition(74, self.size.height * 0.5)
    self.container:addChild(self.role_head)
    self:registerEvent()
end

function ArenaLoopChallengeItem:registerEvent()
    registerButtonEventListener(self.challenge_btn, function()
        if self.data ~= nil then
            local status = 0
            if model:getJumpFightStatus() == true then
                status = 1
            end
            controller:requestFightWithLoopChallenge(self.data.rid, self.data.srv_id, status)
        end
    end,true, 1)

    self.role_head:addCallBack(function()
        if self.data ~= nil then
            if self.data.score == 0 then
                message(TI18N("神秘高手不肯透露信息哦!"))
            else
                controller:requestLoopChallengeRoleInfo(self.data.rid, self.data.srv_id)
            end
        end
    end,false)
end

function ArenaLoopChallengeItem:setExtendData(data)
    self.iten_has_num = data.has_num
    self.iten_free_num = data.free_num
end

function ArenaLoopChallengeItem:setData(data)
    local str = ""
    local back_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.ArenaData.data_const.arena_ticketcost.val[1][1])
    if self.iten_free_num >= 1 then
        str = string_format(TI18N("<div shadow=0,-2,2,%s>免费挑战</div>"), Config.ColorData.data_new_color_str[4])
        self.challenge_btn_label:setPositionX(self.challenge_btn:getContentSize().width*0.5)
        -- self.icon:setVisible(false)
    else
        -- self.icon:setVisible(true)
        local item_config = Config.ItemData.data_get_data(Config.ArenaData.data_const.arena_ticketcost.val[1][1])
        local res = PathTool.getItemRes(item_config.icon)
        self.challenge_btn_label:setPositionX(77)
        if back_num >= 1 then
            str = string_format(TI18N("<img src='%s' scale=0.4 /><div shadow=0,-2,2,%s> 1 %s</div>"), res, Config.ColorData.data_new_color_str[4], TI18N("挑战"))
        else
            str = string_format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ba3b3b fontsize=24> 1</div><div shadow=0,-2,2,%s> %s</div>"), res, Config.ColorData.data_new_color_str[4], TI18N("挑战"))
        end
    end
    self.challenge_btn_label:setString(str)
    setBgByLabel(self.challenge_btn_label, self.challenge_btn, 20, -1)

    self.data = data
    if self.data ~= nil then
        self.role_name:setString(self.data.name)
        if self.data.power == 0 then
            self.role_power:setString("???") 
        else
            self.role_power:setString(changeBtValueForPower(self.data.power))
        end
        if self.data.score == 0 then
            self.role_score:setString("???") 
        else
            self.role_score:setString(self.data.score) 
        end
        self.role_head:setHeadRes(self.data.face, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
        if self.data.lev == 0 then
            self.role_head:setLev("??")
        else
            self.role_head:setLev(self.data.lev)
        end
        self.finish_img:setVisible(self.data.status ~= 0)
        self.challenge_btn:setVisible(self.data.status == 0)
        self:changePowerColor()
        
        if self.same_guild then
            if role_vo and role_vo.gid and role_vo.gid ~= 0 and self.data.gid and role_vo.gid == self.data.gid then
                self.same_guild:setVisible(true)
                local size = self.role_name:getContentSize()
                self.same_guild:setPositionX(self.role_name_x + size.width + 5)
            else
                self.same_guild:setVisible(false)
            end
        end
    end
    -- 引导需要
    self.challenge_btn:setTag(1000+data.idx)
end

function ArenaLoopChallengeItem:changePowerColor()
    if role_vo == nil then return end
    if self.data == nil then return end
    if self.data.power  >  (1.2 * role_vo.power) then -- 需要显示红色
        self.role_power:setTextColor(Config.ColorData.data_new_color4[11])
    else
        self.role_power:setTextColor(Config.ColorData.data_new_color4[12])
    end
end

function ArenaLoopChallengeItem:updateSelfInfo(key, value)
    if key == "name" then
        self.role_name:setString(value)
    elseif key == "score" then
        if value == 0 then
            self.role_score:setString("???")
        else
            self.role_score:setString(value)
        end
    elseif key == "power" then
        if value == 0 then
            self.role_power:setString("???")
        else
            self.role_power:setString(changeBtValueForPower(value))
        end
        self:changePowerColor()
    elseif key == "face" then
        self.role_head:setHeadRes(value)
    elseif key == "lev" then
        if value == 0 then
            value = "??"
        end
        self.role_head:setLev(value)
    elseif key == "status" then
        self.finish_img:setVisible(value ~= 0)
        self.challenge_btn:setVisible(value == 0)
    end
end

function ArenaLoopChallengeItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
