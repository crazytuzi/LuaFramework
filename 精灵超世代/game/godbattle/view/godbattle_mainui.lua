-- --------------------------------------------------------------------
-- 众神战场内部的主UI,处于众神战场之中所有的
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GodBattleMainUI = class("GodBattleMainUI", function() 
	return ccui.Widget:create()
end)

local controller = GodbattleController:getInstance()
local model = controller:getModel()

function GodBattleMainUI:ctor(parent)
    self.skill_list = {}
    self.role_data_list = {}
    self.cache_list = {}
    self.cache_key_list = {}
    self.cell_off_y = 3
    self.cell_height = 37

    self.interval_step = 1
    self.is_show = true
    self.touch_time = 0
    self.is_first = true
    self.parent = parent

    self:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self:setAnchorPoint(cc.p(0.5,0.5))
    self:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB( "godbattle/godbattle_mainui"))
	self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.top_container = self.main_container:getChildByName("top_container")
    self.top_container:setPosition(cc.p(SCREEN_WIDTH/2,display.getTop()-88))
    self.time_container = self.top_container:getChildByName("time_container")
    self.time_label = self.time_container:getChildByName("label")
    self.time_label:setString("")

    -- 左侧守卫血量相关
    self.left_progress_container = self.top_container:getChildByName("left_progress_container")
    self.left_value = self.left_progress_container:getChildByName("value")

    -- 右侧守卫血量相关
    self.right_progress_container = self.top_container:getChildByName("right_progress_container")
    self.right_value = self.right_progress_container:getChildByName("value")

    -- 前三排名
    self.info_container = self.top_container:getChildByName("info_container")
    self.my_rank = self.info_container:getChildByName("my_rank")
    self.my_info_btn = self.info_container:getChildByName("my_info_btn")
	self.rank_title = createLabel(20,1,nil,62,40,"",self.info_container)
	self.rank_title:setAnchorPoint(cc.p(0.5,1))
	self.rank_title:setTextColor(cc.c4b(0x0b,0xd0,0xe6,0xff))
    self.rank_title:setString(TI18N("积分排行"))
    self.rank_title:setPosition(self.info_container:getContentSize().width/2, self.info_container:getContentSize().height - 5)
    self.rank_list = {}
    for i = 1, 3 do
        local rank_item = self:createSingleRankItem(i)
        rank_item:setPositionY(self.info_container:getContentSize().height - 40 - (i-1) * 36)
        self.info_container:addChild(rank_item)
        self.rank_list[i] = rank_item
    end

    self.rewards_btn = self.top_container:getChildByName("rewards_btn")
    self.rewards_btn:getChildByName("label"):setString(TI18N("奖励"))
    self.reward_red_point = self.rewards_btn:getChildByName("red_point")
    self.reward_red_point:setVisible((model.red_point and model.red_point > 0))

    self.form_btn = self.top_container:getChildByName("form_btn")
    self.form_btn:getChildByName("label"):setString(TI18N("布阵"))

    -- 下部的显示
    self.bottom_container = self.main_container:getChildByName("bottom_container")
    self.bottom_container:setPositionY(MainuiController:getInstance():getBottomHeight()+display.getBottom())
    
    self.bottom_bg = self.bottom_container:getChildByName("bg")         -- 需要根据不同阵营切换不同资源
    self.bottom_bg:setContentSize(cc.size(SCREEN_WIDTH,105))

    self.info_container = self.bottom_container:getChildByName("info_container")
    self.info_container:setPositionX(display.getLeft())

    self.info_bg = self.info_container:getChildByName("bg")             -- 需要根据不同阵营切换资源
    self.my_info_camp = self.info_container:getChildByName("cur_camp")       -- 我当前的阵营
    self.my_info_score = self.info_container:getChildByName("cur_score")     -- 我当前的积分
    self.my_info_skill = self.info_container:getChildByName("cur_kill_num")  -- 我当前的击杀数
    self.my_info_rank = self.info_container:getChildByName("cur_rank")  -- 我的排名
    self.info_btn = self.info_container:getChildByName("info_btn")

    self.skill_container = self.bottom_container:getChildByName("skill_container")
    self.skill_container:setPositionX(SCREEN_WIDTH)

    local skill, config
    for i=1, 3 do
        skill = self.skill_container:getChildByName("skill_"..i)
        if skill ~= nil then
            skill.index = i
            skill.id = 0
            skill.icon = skill:getChildByName("icon")
            skill.label = skill:getChildByName("label")
            skill.cd_container = skill:getChildByName("cd_container")
            skill.cd_label = skill.cd_container:getChildByName("cd_label")
            skill.surplus_time = 0
            self.skill_list[i] = skill
        end
    end
    self:registerEvent()
end

--排行榜单项
function GodBattleMainUI:createSingleRankItem(i)
	local container = ccui.Layout:create()
	container:setAnchorPoint(cc.p(0,1))
	container:setContentSize(cc.size(184,36))
	local sp = createSprite(PathTool.getResFrame("common","common_300"..i),5,18,container)
	sp:setAnchorPoint(cc.p(0,0.5))
	sp:setScale(0.5)
	container.sp = sp
	local label = createLabel(20,1,nil,55,18,"虚位以待",container)
	label:setAnchorPoint(cc.p(0,0.5))
	label:setTextColor(cc.c4b(0xac,0xf2,0xff,0xff))
	
	local value = createLabel(20,1,nil,275,18,"0",container)
	value:setAnchorPoint(cc.p(0,0.5))
	value:setTextColor(cc.c4b(0xac,0xf2,0xff,0xff))
	container.name = label
    container.value = value
	return  container
end

function GodBattleMainUI:registerEvent()    
    for k,v in pairs(self.skill_list) do
        v:addTouchEventListener(function(sender, event_type)
            customClickAction(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                self:clearTouchTimer() -- 移除
                if os.time() - self.touch_time >= 2 then
                    self:clearTouchTimer()
                else
                    if sender.vo == nil then return end
                    local config = Config.ZsWarData.data_skill[v.id]
                    if sender.vo.num >= config.free and config.loss and config.loss[1] then
                        CommonAlert.show(string.format(TI18N("<div fontcolor=#d95014>%s</div>使用次数已达上限，再次使用需额外消耗<img src=%s visible=true scale=0.35 /><div>%s，是否继续？"), config.name, PathTool.getItemRes(config.loss[1][1]), config.loss[1][2]), TI18N("确定"), function() 
                            controller:requestUseGodBattleSkill(v.id)
                        end, TI18N("取消"), nil, CommonAlert.type.rich)
                    elseif sender.id ~= nil then
                        controller:requestUseGodBattleSkill(v.id)
                    end
                end
            elseif event_type == ccui.TouchEventType.began then
                self.touch_time = os.time()
                self.show_tips = false
                if self.touch_timer == nil then
                    self.touch_timer = GlobalTimeTicket:getInstance():add(function() 
                        if os.time() - self.touch_time >= 2 then
                            self:clearTouchTimer()
                            local skill_config = Config.ZsWarData.data_skill[sender.id]
                            if skill_config ~= nil then
                                local world_pos = sender:convertToWorldSpace(cc.p(0, 1))
                                local pos = cc.p( world_pos.x, world_pos.y + sender:getContentSize().height )
                                TipsManager:getInstance():showCommonTips(skill_config.desc, pos, 20, 3, 230)
                            end
                        end
                    end, 1)
                end
            elseif event_type == ccui.TouchEventType.canceled then
                self:clearTouchTimer()
            end
        end)

        if v.cd_container then
            v.cd_container:addTouchEventListener(function(sender, event_type) 
                if event_type == ccui.TouchEventType.ended then
                    -- message(TI18N("技能CD中"))
                    local skill_config = Config.ZsWarData.data_skill[v.id]
                    if skill_config ~= nil then
                        local world_pos = sender:convertToWorldSpace(cc.p(0, 1))
                        local pos = cc.p( world_pos.x, world_pos.y + sender:getContentSize().height )
                        TipsManager:getInstance():showCommonTips(skill_config.desc, pos, 20, 3, 230)
                    end
                end
            end)
        end
    end

    if self.info_btn then
        self.info_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openGodBattleInfoView(true)
            end
        end)
    end

    if self.my_info_btn then
        self.my_info_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openGodBattleInfoView(true)
            end
        end)
    end

    -- 添加排行榜数据处理
    if self.add_role_event == nil then
        self.add_role_event = GlobalEvent:getInstance():Bind(GodbattleEvent.AddRoleDataEvent, function(type, role_list) 
            self:addRoleInfoList(type,role_list)
        end)
    end

    -- 更新战场总积分
    if self.total_score_event == nil then
        self.total_score_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateTotalScoreEvent, function(data) 
            self:updateTotalScore(data)
        end)
    end

    -- 更新技能数据
    if self.skill_list_event == nil then
        self.skill_list_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateSkillListEvent, function(list)
            self:updateSkillList(list)
        end)
    end

    -- 战场倒计时
    if self.time_count_down_event == nil then
        self.time_count_down_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateTimeCountDown, function(time) 
            self:timeCountDown(time)
        end)
    end

    -- 实时更新个人击杀和积分数据
    if self.update_self_data_event == nil then
        self.update_self_data_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateSelfDataEvent, function(camp, score, win_acc, win_best) 
            self:updateSelfData(camp, score, win_acc, win_best)
        end)
    end

    -- 实时更新个人获得奖励数据
    if self.update_role_awards_event == nil then
        self.update_role_awards_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateRoleAwards, function(list) 
            self:updateRoleAwards(list)
        end)
    end

    -- 聊天面板伸缩的时候
    if self.chat_ui_size_change == nil then
        self.chat_ui_size_change = GlobalEvent:getInstance():Bind(EventId.CHAT_HEIGHT_CHANGE, function() 
            self.bottom_container:setPositionY(MainuiController:getInstance():getBottomHeight()+display.getBottom())
        end)
    end

    -- 更新守卫信息
    if self.add_guard_event == nil then
        self.add_guard_event = GlobalEvent:getInstance():Bind(GodbattleEvent.AddGuardDataEvent, function(type, data_list)
            self:updateGuardListData(type, data_list)
        end)
    end

    -- 布阵
    if self.form_btn then
        self.form_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
            end
        end)
    end

    -- 奖励
    if self.rewards_btn then
        self.rewards_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                GodbattleController:getInstance():openGodBattleRewardsWindow(true)
            end
        end)
    end

    -- 红点更新
    if self.update_reward_red_point_event == nil then
        self.update_reward_red_point_event = GlobalEvent:getInstance():Bind(GodbattleEvent.UpdateRewardRedPoint, function(num)
            self.reward_red_point:setVisible((num and num > 0))
        end)
    end
end


function GodBattleMainUI:open()
    if self:getParent() == nil then
        if not tolua.isnull(self.parent) then
            self.parent:addChild(self)
        end
    else
        self:setVisibleStatus(true)
    end

    self:setScheduleUpdate(true)
end

--==============================--
--desc:创建右侧信息追踪栏
--time:2017-09-15 11:11:40
--@return 
--==============================--
function GodBattleMainUI:addRoleInfoList(type, role_list)
    if role_list == nil or next(role_list) == nil then return end
    if type == GodBattleConstants.update_type.update then
    elseif type == GodBattleConstants.update_type.add or type == GodBattleConstants.update_type.total then
        local tmp_list = {}
        for i,v in ipairs(role_list) do -- 只有没有记录过得数据才需要去创建,这个战场只有增加没有删除操作的
            if self.cache_key_list[getNorKey(v.rid, v.srv_id)] == nil then
                self.cache_key_list[getNorKey(v.rid, v.srv_id)] = v
                table.insert( self.role_data_list, v )
            end
        end
    end
    if type == GodBattleConstants.update_type.total then
        self:updateRoleInfoList()
    end
end

--==============================--
--desc:每20秒更新一次排行榜,先设置自身数据,然后再排序,最后再设置位置,如果还在创建对象这个时候不做排序
--time:2017-09-16 12:06:00
--@return 
--==============================--
function GodBattleMainUI:updateRoleInfoList()
    if self.role_data_list == nil then return end
    local role = RoleController:getInstance():getRoleVo()
    local role_key = getNorKey(role.rid, role.srv_id)
    local sort_func = SortTools.tableUpperSorter({"score", "win_acc"})
    table.sort(self.role_data_list, sort_func)
    for i, v in pairs(self.role_data_list) do
        if getNorKey(v.rid, v.srv_id) == role_key then
            self.my_rank:setString(string.format(TI18N("我的排名：%s"), i))
            self.my_info_rank:setString(string.format(TI18N("当前排名：%s"), i))
        end
        if self.rank_list[i] then
            -- self.rank_list[i].name:setString(v.name)
			self.rank_list[i].name:setString(controller:convertName(v))
            self.rank_list[i].value:setString(v.score)
        end
    end
end

--==============================--
--desc:打开计时器
--time:2017-09-15 11:13:49
--@status:
--@return 
--==============================--
function GodBattleMainUI:setScheduleUpdate(status)
    if status == true then
        if self.queue_timer == nil then
            self.queue_timer = GlobalTimeTicket:getInstance():add(function()
                if self.interval_step > 1200 then
                    self.interval_step = 1
                    self:updateRoleInfoList()
                end
                self.interval_step = self.interval_step + 1
            end, 1/display.DEFAULT_FPS)
        end
    else
        if self.queue_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.queue_timer)
            self.queue_timer = nil
        end
    end
end

--==============================--
--desc:创建对象
--time:2017-09-15 11:31:25
--@data:
--@return 
--==============================--
function GodBattleMainUI:createList(data)
end

--==============================--
--desc:更新双方总积分
--time:2017-09-12 05:35:03
--@data:
--@return 
--==============================--
function GodBattleMainUI:updateTotalScore(data)
    self.left_value:setString(data.score_a or 0)
    self.right_value:setString(data.score_b or 0)
    local group = data.group or 0
    local config = Config.ZsWarData.data_group[group]
    if config then
        self.my_info_camp:setString(string.format(TI18N("当前战场：%s第%s战场"), config.name, data.zone or 0))
    end
end

--==============================--
--desc:更新自己的积分数据
--time:2017-09-15 06:00:23
--@score:
--@win_acc:
--@return 
--==============================--
function GodBattleMainUI:updateSelfData(camp, score, win_acc, win_best)
    if self.camp == nil then
        self.camp = camp
        if camp == GodBattleConstants.camp.god then
            self.bottom_bg:loadTexture(PathTool.getResFrame("godbattle", "godbattle_7"), LOADTEXT_TYPE_PLIST)
            self.info_bg:loadTexture(PathTool.getResFrame("godbattle", "godbattle_5"), LOADTEXT_TYPE_PLIST)
            self.info_bg:setCapInsets(cc.rect(6,12,1,1))
        end
    end
    self.my_info_score:setString(TI18N("当前积分:")..score)
    self.my_info_skill:setString(TI18N("击杀数量:")..win_acc)
end

--==============================--
--desc:更新自己已经获得的奖励数据
--time:2017-09-20 02:54:25
--@list:
--@return 
--==============================--
function GodBattleMainUI:updateRoleAwards(list)
end

--==============================--
--desc:更新守卫信息
--time:2018-09-17 09:54:25
--@list:
--@return 
--==============================--
function GodBattleMainUI:updateGuardListData(type, list)
    -- for i, v in pairs(list) do 
    --     if v.id == GodBattleConstants.camp.god then
    --         self.left_value:setString(v.hp)
    --         self.left_progress:setPercent(v.hp/v.max_hp * 100)
    --     elseif v.id == GodBattleConstants.camp.devil then
    --         self.right_value:setString(v.hp)
    --         self.right_progress:setPercent(v.hp/v.max_hp * 100)
    --     end
    -- end
end

--==============================--
--desc:更新技能信息
--time:2017-09-13 10:27:24
--@skill_list:
--@return 
--==============================--
function GodBattleMainUI:updateSkillList()
    local skill_list = model:getGodBattleSkillList()
    local skill_btn
    local need_count_down = false
    for k,v in pairs(skill_list) do
        skill_btn = self.skill_list[k]
        if skill_btn ~= nil then
            config = Config.ZsWarData.data_skill[v.id]
            if config ~= nil and skill_btn.id ~= v.id then
                skill_btn.label:setString(config.name)
                loadSpriteTexture(skill_btn.icon, PathTool.getSkillRes(config.icon), LOADTEXT_TYPE)
            end
            skill_btn.id = v.id
            skill_btn.vo = v
            skill_btn.surplus_time = v.cdtime - GameNet:getInstance():getTime()
            if skill_btn.surplus_time > 0 then
                if need_count_down == false then
                    need_count_down = true
                end
                if skill_btn.cd_label then
                    skill_btn.cd_label:setString(skill_btn.surplus_time)
                    skill_btn.cd_container:setVisible(true)
                end
            else
                if skill_btn.cd_container then
                    skill_btn.cd_container:setVisible(false )
                end
            end
        end
    end
    self:clearSkillTimer()
    if need_count_down == true then
        if self.skill_timer == nil then
            self.skill_timer = GlobalTimeTicket:getInstance():add(function()
                self:skillCountDownTime()
            end, 1)
        end
    end
end

--==============================--
--desc:倒计时
--time:2017-09-14 06:59:46
--@time:
--@return 
--==============================--
function GodBattleMainUI:timeCountDown(time)
    if time == nil or time <= 0 then
        if self.start_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.start_timer)
            self.start_timer = nil
        end
        if self.start_timer_num ~= nil then
            self.start_timer_num:DeleteMe()
            self.start_timer_num = nil
        end
    else
        self.start_time = time
        if self.start_time > 0 then
            self:setStartTimeNum(self.start_time)
            if self.start_timer == nil then
                self.start_timer = GlobalTimeTicket:getInstance():add(function() 
                    self:countDownStartTime()
                end, 1)
            end
        end
    end
end

function GodBattleMainUI:countDownStartTime()
    self.start_time = self.start_time - 1
    if self.start_time <= 0 then
        self:timeCountDown()
        return
    end
    self:setStartTimeNum(self.start_time)
end

function GodBattleMainUI:setStartTimeNum(num)
    if self.start_timer_num == nil then
        self.start_timer_num = CommonNum.new(3, self.main_container, 0, 0, cc.p(0.5, 0.5))
        self.start_timer_num:setPosition(self.main_container:getContentSize().width*0.5, self.main_container:getContentSize().height*0.5+200)
    end
    self.start_timer_num:setNum(num)
end

--==============================--
--desc:技能倒计时
--time:2017-09-13 10:45:31
--@return 
--==============================--
function GodBattleMainUI:skillCountDownTime()
    local over_timer = 0
    for k,v in pairs(self.skill_list) do
        v.surplus_time = v.surplus_time - 1
        if v.surplus_time <= 0 then
            v.cd_container:setVisible(false)
            over_timer = over_timer + 1
        end
        v.cd_label:setString(v.surplus_time)
    end

    -- 3个技能都不在倒计时,就直接关掉倒计时计时器吧
    if over_timer >= 3 then
        self:clearSkillTimer()
    end
end

--==============================--
--desc:清空技能倒计时
--time:2017-09-13 10:42:57
--@return 
--==============================--
function GodBattleMainUI:clearSkillTimer()
    if self.skill_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.skill_timer)
        self.skill_timer = nil
    end
end

function GodBattleMainUI:setVisibleStatus(status)
    self:setVisible(status)
    
    self:clearTimer()
    self:clearSkillTimer()
    if status == true then
        self:setTimeCountDown()
        if self.is_first == false then
            self:updateSkillList()
        else
            self.is_first = false
        end
    end
end

function GodBattleMainUI:DeleteMe()
    self:clearTimer()
    self:clearSkillTimer()
    self:timeCountDown()
    self:clearTouchTimer()
    self:setScheduleUpdate(false)

    for i,v in pairs(self.cache_list) do 
        if v and v.DeleteMe then 
            v:DeleteMe()
        end
    end

    if self.god_score then
        self.god_score:DeleteMe()
        self.god_score = nil
    end

    if self.devil_score then
        self.devil_score:DeleteMe()
        self.devil_score = nil
    end

    if self.add_role_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.add_role_event)
        self.add_role_event = nil
    end

    if self.total_score_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.total_score_event)
        self.total_score_event = nil
    end

    if self.skill_list_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.skill_list_event)
        self.skill_list_event = nil
    end

    if self.use_default_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.use_default_event)
        self.use_default_event = nil
    end

    if self.time_count_down_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.time_count_down_event)
        self.time_count_down_event = nil
    end

    if self.update_self_data_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_self_data_event)
        self.update_self_data_event = nil
    end

    if self.update_role_awards_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_role_awards_event)
        self.update_role_awards_event = nil
    end
    if self.chat_ui_size_change then
        GlobalEvent:getInstance():UnBind(self.chat_ui_size_change)
        self.chat_ui_size_change = nil
    end
    if self.add_guard_event then
        GlobalEvent:getInstance():UnBind(self.add_guard_event)
        self.add_guard_event = nil
    end
    if self.update_reward_red_point_event then
        GlobalEvent:getInstance():UnBind(self.update_reward_red_point_event)
        self.update_reward_red_point_event = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

--==============================--
--desc:时间
--time:2017-09-13 10:31:27
--@return 
--==============================--
function GodBattleMainUI:setTimeCountDown()
    self.time_info = controller:getTimeInfo()
    if self.time_info == nil or self.time_info.end_time == nil then
        self.time_label:setString("")
    else
        self:clearTimer()

        self.surplus_time = self.time_info.end_time - GameNet:getInstance():getTime()
        if self.surplus_time <= 0 or self.time_info.status == ActionStatus.is_end then
            self.time_label:setString("")
        else
            self:countDownTime()
            if self.timer == nil then
                self.timer = GlobalTimeTicket:getInstance():add(function()
                    self:countDownTime()
                end, 1)
            end
        end
    end
end

function GodBattleMainUI:clearTouchTimer()
    if self.touch_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.touch_timer)
        self.touch_timer = nil
    end
end

function GodBattleMainUI:clearTimer()
	if self.timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.timer)
		self.timer = nil
	end
end

---
function GodBattleMainUI:countDownTime()
	self.surplus_time = self.surplus_time - 1
	if self.surplus_time < 0 then
        self:clearTimer()
        return
	end
    self.time_label:setString(TI18N("剩余时间:")..TimeTool.GetTimeMS(self.surplus_time, true))
end
