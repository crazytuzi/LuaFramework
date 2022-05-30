-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竞技场，循环赛和排位赛
-- <br/>Create: 2018-05-11
-- --------------------------------------------------------------------
ArenaController = ArenaController or BaseClass(BaseController)

function ArenaController:config()
    self.model = ArenaModel.New(self)
    self.champion_model = ArenaChampionModel.New()
    self.dispather = GlobalEvent:getInstance()

    self.is_request_loop_challenge = false              -- 是否请求了打开竞技场循环赛面板     
end

function ArenaController:getModel()
    return self.model
end

function ArenaController:getChampionModel()
    return self.champion_model
end

function ArenaController:registerEvents()
end

--==============================--
--desc:请求一些相关数据
--time:2018-06-15 02:17:39
--@return 
--==============================--
function ArenaController:requestInitProtocal()
end

function ArenaController:registerProtocals()
    self:RegisterProtocal(20200, "handle20200")
    self:RegisterProtocal(20201, "handle20201")
    self:RegisterProtocal(20202, "handle20202")
    self:RegisterProtocal(20203, "handle20203")
    self:RegisterProtocal(20206, "handle20206")
    self:RegisterProtocal(20207, "handle20207")
    self:RegisterProtocal(20208, "handle20208") --宝箱模式
    self:RegisterProtocal(20209, "handle20209")
    self:RegisterProtocal(20210, "handle20210")
    self:RegisterProtocal(20220, "handle20220")
    self:RegisterProtocal(20221, "handle20221")
    self:RegisterProtocal(20222, "handle20222")

    self:RegisterProtocal(20223, "handle20223")

    -- 冠军赛
    self:RegisterProtocal(20250, "handle20250")     -- 冠军赛赛程状态数据
    self:RegisterProtocal(20251, "handle20251")     -- 个人排名以及可下注信息
    self:RegisterProtocal(20252, "handle20252")     -- 我的比赛信息 
    self:RegisterProtocal(20253, "handle20253")     -- 竞猜比赛信息 
    self:RegisterProtocal(20254, "handle20254")     -- 押注返货
    self:RegisterProtocal(20255, "handle20255")     -- 我的竞猜列表
    self:RegisterProtocal(20256, "handle20256")     -- 结算展示
    self:RegisterProtocal(20257, "handle20257")     -- 竞猜实时更新
    self:RegisterProtocal(20258, "handle20258")     -- 我的战斗日志
    self:RegisterProtocal(20260, "handle20260")     -- 32强数据
    self:RegisterProtocal(20261, "handle20261")     -- 4强数据
    self:RegisterProtocal(20262, "handle20262")     -- 32强或者4强赛竞猜位置信息
    self:RegisterProtocal(20263, "handle20263")     -- 32强或者4强赛指定位置的信息
    self:RegisterProtocal(20280, "handle20280")     -- 冠军赛前3名信息
    self:RegisterProtocal(20281, "handle20281")     -- 冠军赛排行榜信息

    self:RegisterProtocal(20282, "handle20282")     -- 赛季结算前3

    self:RegisterProtocal(20204, "handle20204")     -- 查看剧情人数据
end

--==============================--
--desc:请求打开竞技场面板,这个时候要判断一下,如果是冠军赛开始阶段,就不要直接进竞技场了,
--否则直接进竞技场吧,这个才是对外打开竞技场的请求,因为这里要判断是否在冠军赛七剑
--time:2018-08-01 08:10:21
--extend:扩展参数,如果是冠军赛,则需要判断具体的
--@return 
--==============================--
function ArenaController:requestOpenArenWindow(extend)
    local data = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
    if data and data.is_lock then
        message(data.desc)
        return
    end
    -- 如果是引导的话,那么这个肯定是进竞技场
    if GuideController:getInstance():isInGuide() then 
        self:requestOpenArenaLoopMathWindow(true)
    else
        if extend == ArenaConst.arena_type.rank then
            self:openArenaChampionMatchWindow(true)
        else
            local base_info = self.champion_model:getBaseInfo()
            if base_info == nil or base_info.step_status ~= ArenaConst.champion_step_status.opened then
                self:requestOpenArenaLoopMathWindow(true)
            else
                self:openArenaEnterWindow(true, ArenaConst.arena_type.rank)
            end
        end
    end
end

--==============================--
--desc:打开循环赛或者冠军赛入口界面
--time:2018-07-31 09:52:04
--@status:
--@index:
--@return 
--==============================--
function ArenaController:openArenaEnterWindow(status, index)
    if status == false then
        if self.enter_window ~= nil then
            self.enter_window:close()
            self.enter_window = nil
        end
    else
        local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
        if build_vo and build_vo.is_lock then
            message(build_vo.desc)
            return
        end

        if self.enter_window == nil then
            self.enter_window = ArenaEnterWindow.New()
        end
        index = index or ArenaConst.arena_type.loop
        if self.enter_window:isOpen() == false then
            self.enter_window:open(index)
        end
    end
end

--==============================--
--desc:请求打开竞技场界面
--time:2018-08-01 08:19:25
--@status:
--@index:
--@return 
--==============================--
function ArenaController:requestOpenArenaLoopMathWindow(status, index)
    if status == true then
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Arena)
    end
end

--==============================--
--desc:打开循环赛界面(这个接口外部只有一个,那就是真正的战斗请求回来之后打开的,也就是mainuicontroller里面打开的)
--time:2018-07-31 09:52:23
--@status:
--@index:
--@return 
--==============================--
function ArenaController:openArenaLoopMathWindow(status, index)
    if status == false then
        if self.loop_match_window ~= nil then
            self.loop_match_window:close()
            self.loop_match_window = nil
        end
    else
        local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
        if build_vo and build_vo.is_lock then
            message(build_vo.desc)
            return
        end

        index = index or ArenaConst.loop_index.challenge 
        if self.loop_match_window == nil then
            self.loop_match_window = ArenaLoopMatchWindow.New()
        end
        if self.loop_match_window:isOpen() == false then
            self.loop_match_window:open(index)
        end
    end
end

--==============================--
--desc:打开冠军赛界面
--time:2018-07-31 09:53:01
--@status:
--@index:
--@return 
--==============================--
function ArenaController:openArenaRankMathWindow(status, index)
	if status == false then
	else
        local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
        if build_vo and build_vo.is_lock then
            message(build_vo.desc)
            return
        end
	end
end

--==============================--
--desc:打开循环赛挑战者信息界面
--time:2018-07-31 09:53:41
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openCheckLoopChallengeRole(status, data)
    if status == false then
        if self.loop_challenge_check_window ~= nil then
            self.loop_challenge_check_window:close()
            self.loop_challenge_check_window = nil
        end
    else
        if data == nil then return end
        if self.loop_challenge_check_window == nil then
            self.loop_challenge_check_window = ArenaLoopChallengeCheckWindow.New()
        end
        self.loop_challenge_check_window:open(data)
    end
end

--==============================--
--desc:打开循环赛buff界面
--time:2018-07-31 09:53:54
--@status:
--@return 
--==============================--
function ArenaController:openLoopChallengeBuffWindow(status)
    if status == false then
        if self.loop_challenge_buff_window ~= nil then
            self.loop_challenge_buff_window:close()
            self.loop_challenge_buff_window = nil
        end
    else
        if self.loop_challenge_buff_window == nil then
            self.loop_challenge_buff_window = ArenaLoopChallengeBuffWindow.New()
        end
        self.loop_challenge_buff_window:open()
    end
end

--==============================--
--desc:打开循环赛胜利结算界面
--time:2018-07-31 09:54:08
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openLoopResultWindow(status, data)
	if status == false then
		if self.loop_result_window ~= nil then
			self.loop_result_window:close()
			self.loop_result_window = nil
		end
	else
        -- 角色数据还没有的时候不处理了
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo == nil then return end;

		if self.loop_result_window == nil then
			self.loop_result_window = ArenaLoopResultWindow.New()
		end
		self.loop_result_window:open(data)
	end
end 

--==============================--
--desc:打开
--time:2018-07-31 05:23:58
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openArenaChampionRankWindow(status, view_type)
    if status == false then
        if self.champion_rank ~= nil then
            self.champion_rank:close()
            self.champion_rank = nil
        end
    else
        if self.champion_rank == nil then
            self.champion_rank = ArenaChampionRankWindow.New(view_type)
        end
        self.champion_rank:open()
    end
end

--==============================--
--desc:打开冠军赛的主界面
--time:2018-07-31 07:20:58
--@status:
--@index:
--@return 
--==============================--
function ArenaController:openArenaChampionMatchWindow(status, index, view_type)
    if status == false then
        if self.champion_window ~= nil then
            self.champion_window:close()
            self.champion_window = nil
        end
    else
        if self.champion_window == nil then
            self.champion_window = ArenaChampionMatchWindow.New(view_type)
        end
        self.champion_window:open(index)
    end
end

function ArenaController:checkChampionWndIsOpen(  )
    if self.champion_window then
        return true
    end
    return false
end

--==============================--
--desc:打开竞猜界面
--time:2018-08-01 10:00:37
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openArenaChampionGuessWindow(status, data, view_type)
    if status == false then
        if self.guess_window ~= nil then
            self.guess_window:close()
            self.guess_window = nil
        end
    else
        if self.guess_window == nil then
            self.guess_window = ArenaChampionGuessWindow.New(view_type)
        end
        self.guess_window:open(data)
    end
end

--==============================--
--desc:打开冠军赛排名奖励面板
--time:2018-08-01 02:04:06
--@status:
--@return 
--==============================--
function ArenaController:openArenaChampionRankAwardsWindow(status, view_type)
    if status == false then
        if self.champion_rank_awards ~= nil then
            self.champion_rank_awards:close()
            self.champion_rank_awards = nil
        end
    else
        if self.champion_rank_awards == nil then
            self.champion_rank_awards = ArenaChampionRankAwardsWindow.New(view_type)
        end
        self.champion_rank_awards:open()
    end
end

--==============================--
--desc:打开我的竞猜界面
--time:2018-08-01 03:04:10
--@status:
--@return 
--==============================--
function ArenaController:openArenaChampionMyGuessWindow(status, view_type)
    if status == false then
        if self.my_guess_window ~= nil then
            self.my_guess_window:close()
            self.my_guess_window = nil
        end
    else
        if self.my_guess_window == nil then
            self.my_guess_window = ArenaChampionMyGuessWindow.New(view_type)
        end
        self.my_guess_window:open()
    end
end

--==============================--
--desc:打开我的日志面板
--time:2018-08-07 09:35:47
--@status:
--@return 
--==============================--
function ArenaController:openArenaChampionMyLogWindow(status, view_type)
	if status == false then
		if self.my_log_window ~= nil then
			self.my_log_window:close()
			self.my_log_window = nil
		end
	else
		if self.my_log_window == nil then
			self.my_log_window = ArenaChampionMyLogWindow.New(view_type)
		end
		self.my_log_window:open()
	end
end 

--==============================--
--desc:冠军赛冠军提示信息界面
--time:2018-08-01 09:44:59
--@status:
--@return 
--==============================--
function ArenaController:openArenaChampionBestInfoWindow(status, data, view_type)
    if status == false then
        if self.best_info_window ~= nil then
            self.best_info_window:close()
            self.best_info_window = nil
        end
    else
        if self.best_info_window == nil then
            self.best_info_window = ArenaChampionBestInfoWindow.New(view_type)
        end
        self.best_info_window:open(data)
    end
end

--==============================--
--desc:冠军赛战况的窗体
--time:2018-08-03 08:40:54
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openArenaChampionReportWindow(status, data, view_type)
    if not status then
        if self.report_window ~= nil then
            self.report_window:close()
            self.report_window = nil
        end
    else
        if self.report_window == nil then
            self.report_window = ArenaChampionReportWindow.New(view_type)
        end
        self.report_window:open(data)
    end
end

--==============================--
--desc:循环赛的个人日志面板
--time:2018-08-03 08:40:54
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openArenaLoopMyLogWindow(status)
    if not status then
        if self.loop_log_window ~= nil then
            self.loop_log_window:close()
            self.loop_log_window = nil
        end
    else
        if self.loop_log_window == nil then
            self.loop_log_window = ArenaLoopMyLogWindow.New()
        end
        self.loop_log_window:open()
    end
end

--==============================--
--desc:冠军赛前3结算
--time:2018-08-03 08:40:54
--@status:
--@data:
--@return 
--==============================--
function ArenaController:openArenaChampionTop3Window(status, data, view_type)
    if not status then
        if self.champion_top3_window ~= nil then
            self.champion_top3_window:close()
            self.champion_top3_window = nil
        end
    else
        if self.champion_top3_window == nil then
            self.champion_top3_window = ArenaChampionTop3Window.New(view_type)
        end
        self.champion_top3_window:open(data)
    end
end

--挑战界面购买
 function ArenaController:openArenaLoopChallengeBuy(status, setting)
    if not status then
        if self.loop_challenge_buy ~= nil then
            self.loop_challenge_buy:close()
            self.loop_challenge_buy = nil
        end
    else
        if self.loop_challenge_buy == nil then
            self.loop_challenge_buy = ArenaLoopChallengeBuy.New()
        end
        self.loop_challenge_buy:open(setting)
    end
end

--==============================--
--desc:引导需要,循环赛的基础面板
--time:2018-07-17 11:06:54
--@return 
--==============================--
function ArenaController:getArenaRoot()
    if self.loop_match_window then
        return self.loop_match_window.root_wnd
    end
end

--挑战宝箱
function ArenaController:sender20208()
    self:SendProtocal(20208, {})
end

--[[
    @desc:个人信息返回
    author:{author}
    time:2018-05-14 11:41:40
    --@data: 
    return
]]
function ArenaController:handle20200(data)
    -- print("*** 协议 **** handle20200 ********")
    self.model:updateMyLoopData(data)
end

--[[
    @desc:今日已经领取的挑战次数奖励,这里要跟00协议做判断是否更新红点处理
    author:{author}
    time:2018-05-14 20:51:46
    --@data: 
    return
]]
function ArenaController:handle20208(data)
    -- print("*** 协议 **** handle20208 ********")
    self.model:updateChallengeTimesAwards(data)
end

--[[
    @desc:请求领取挑战次数奖励
    author:{author}
    time:2018-05-14 20:53:44
    --@num: 
    return
]]
function ArenaController:requestGetChallengeTimesAwards(num)
    local protocal = {}
    protocal.num = num
    self:SendProtocal(20209, protocal)
end

function ArenaController:handle20209(data)
    message(data.msg)
end

--[[
    @desc:请求循环赛挑战列表 
    author:{author}
    time:2018-05-14 11:53:21
    return
]]
function ArenaController:requestChallengeList()
    self:SendProtocal(20201, {})
end

--[[
    @desc:当前的挑战列表,要么推送列表有5条数据，要么只有1条，区分是全部刷新还是更新单条
    author:{author}
    time:2018-05-14 11:54:14
    --@data: 
    return
]]
function ArenaController:handle20201(data)
    self.model:updateLoopChallengeList(data)
end

--[[
    @desc:请求
    author:{author}
    time:2018-05-14 17:33:34
    --@rid:
	--@srv_id: 
    return
]]
function ArenaController:requestLoopChallengeRoleInfo(rid, srv_id)
    if rid == nil or srv_id == nil then return end
    self.loop_challenge_role_rid = rid              -- 记录一下当前请求查看的角色rid和srv_id
    self.loop_challenge_role_srv_id = srv_id
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(20202, protocal)
end

--[[
    @desc:获取挑战玩家信息，协议返回之后打开面板 
    author:{author}
    time:2018-05-14 17:32:26
    --@data: 
    return
]]
function ArenaController:handle20202(data)
    if self.loop_challenge_role_rid ~= data.rid and self.loop_challenge_role_srv_id ~= data.srv_id then return end
    self:openCheckLoopChallengeRole(true, data)
end

--[[
    @desc:请求对循环赛玩家发起挑战
    author:{author}
    time:2018-05-14 17:23:23
    --@rid:
	--@srv_id: 
    return
]]
function ArenaController:requestFightWithLoopChallenge(rid, srv_id, is_auto)
    if rid == nil or srv_id == nil then return end

    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.is_auto = is_auto or 0
    self:SendProtocal(20203, protocal)
end
function ArenaController:handle20203(data)
    message(data.msg)
end

--- 请求循环赛个人日志
function ArenaController:requestMyLoopLogInfo()
    self:SendProtocal(20222, {})
end

function ArenaController:handle20222(data)
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMylogListEvent, data.log_list)
end 

function ArenaController:handle20223(data)
    self.model:updateArenaLoopLogStatus(data.flag)
end

--[[
    @desc:请求刷新挑战列表
    author:{author}
    time:2018-05-14 14:45:55
    return
]]
function ArenaController:requestRefreshChallengeList()
    self:SendProtocal(20206, {})

    -- local my_info = self.model:getMyLoopData()
    -- if my_info == nil then 
    --     message(TI18N("当前数据异常"))
    --     return
    -- end
    -- if my_info.ref_cost == -1 then
    --     message(TI18N("当前刷新次数已满，不能再刷新"))
    --     return
    -- end
    -- local function call_back()
    --     self:SendProtocal(20206, {})
    -- end
    -- if my_info.ref_cost == 0 then
    --     call_back()
    -- else
    --     local msg =
    --         string.format(
    --         TI18N("确定消耗<img src=%s visible=true scale=0.4 />%s刷新当前列表吗？"),
    --         PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold),
    --         my_info.ref_cost
    --     )
    --     CommonAlert.show(msg,TI18N("确定"),call_back,TI18N("取消"),nil,CommonAlert.type.rich)
    -- end
end
function ArenaController:handle20206(data)
    message(data.msg)
end

--[[
    @desc:请求购买跳帧次数
    author:{author}
    time:2018-05-14 16:54:24
    return
]]
function ArenaController:requestBuyChallengeTimes()
    --[[
    local my_info = self.model:getMyLoopData()
    if my_info == nil then
        message(TI18N("当前数据异常"))
        return
    end
    local role_vo = RoleController:getInstance():getRoleVo()
    local buy_num = my_info.buy_combat_num or 0
    local buy_next_num = buy_num + 1
    local buy_config = Config.ArenaData.data_buy[buy_next_num]
    if buy_config == nil then
        message(TI18N("当前已经购买达到上限"))
    else
        if role_vo.vip_lev < buy_config.vip then
            message(string.format(TI18N("提升VIP等级达到%s，可增加一次购买次数！"), buy_config.vip))
        else
            local msg =
                string.format(
                TI18N("确定消耗<img src=%s visible=true scale=0.35 />%s增加一次挑战次数吗？"),
                PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold),
                buy_config.cost
            )
            CommonAlert.show(
                msg,
                TI18N("确定"),
                function()
                    self:SendProtocal(20207, {})
                end,
                TI18N("取消"),
                nil,
                CommonAlert.type.rich
            )
        end
    end
    --]]
end

function ArenaController:sender20207(num)
    local proto = {}
    proto.num = num
    self:SendProtocal(20207, proto)
end
function ArenaController:handle20207(data)
    message(data.msg)
    if data.code == 1 then
        self:openArenaLoopChallengeBuy(false)
        GlobalEvent:getInstance():Fire(ArenaEvent.UpdateArena_Number)
    end
end

--[[
    @desc:战斗计算，收到结算的，就同时请求一下个人信息吧，服务器要求
    author:{author}
    time:2018-05-15 16:06:21
    --@data: 
    return
]]
function ArenaController:handle20210(data)
    -- if data.result == TRUE then
        BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.Arena, data)
    -- else
    --     BattleController:getInstance():openFailFinishView(true, BattleConst.Fight_Type.Arena, data.result)
    -- end 
    GlobalEvent:getInstance():Fire(ArenaEvent.ArenaFightResultEvent)
    self:SendProtocal(20200, {})
end

--[[
    @desc:请求循环赛前三名的数据
    author:{author}
    time:2018-05-15 16:42:20
    return
]]
function ArenaController:requestLoopChallengeStatueList()
    self:SendProtocal(20220, {})
end
function ArenaController:handle20220(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateLoopChallengeStatueList, data.rank_list)
end

--[[
    @desc:请求排行榜循环赛排行榜
    author:{author}
    time:2018-05-17 09:59:24
    return
]]
function ArenaController:requestLoopChalllengeRank()
    self:SendProtocal(20221, {})
end
function ArenaController:handle20221(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateLoopChallengeRank, data)
end

function ArenaController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end


----------------------------------冠军赛数据
-- 冠军赛基础数据
function ArenaController:handle20250(data)
    self.champion_model:updateChampionBaseInfo(data)
    self:requestRoleInfo()

    local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
    if build_vo and build_vo.is_lock then return end

    if data.step_status == ArenaConst.champion_step_status.opened then
        -- 这里时候要判断一下是否有引导,有引导不处理,剧情中也不需要弹
        if GuideController:getInstance():isInGuide() then return end
        if StoryController:getInstance():getModel():isStoryState() then return end 

        -- 可能已经被干掉了,因为引导可能会强制关掉
        if self.alert_window and (self.alert_window.root_wnd == nil or tolua.isnull(self.alert_window.root_wnd)) then
            self.alert_window = nil
        end

        if self.champion_window == nil and self.alert_window == nil then
            -- 这里是弹窗设定,如果竞技场没开启,就不需要弹窗例如
            local function cancel_callback()
                self.alert_window = nil
            end

            local function confirm_callback()
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.champion_call)
                self.alert_window = nil
            end

            if data.round_status == ArenaConst.champion_round_status.guess then -- 每次竞猜都要弹提示
                ActivityController:openSignView(true, ActivitySignType.arena_champion_guess, {timer = true})
                -- local msg = TI18N("冠军赛已经开始，正在进行竞猜阶段。是否前往参与竞猜？")
                -- local extend_msg = TI18N("参与比赛和竞猜玩法")
                -- self.alert_window = CommonAlert.show(msg,TI18N("确定"),confirm_callback,TI18N("取消"),cancel_callback,CommonAlert.type.rich,cancel_callback,{off_y = 43, extend_str = extend_msg, extend_offy = -75, extend_aligment = cc.TEXT_ALIGNMENT_CENTER})
            else
                if not self.had_show_notice then
                    local build_vo = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.arena)
                    if build_vo and build_vo.is_lock then
                        return
                    end
                    ActivityController:openSignView(true, ActivitySignType.arena_champion, {timer = true})
                    self.had_show_notice = true
                    -- local msg = string.format(TI18N("冠军赛-<div fontcolor='#289b14'>%s</div>,即将开始,是否前往参与?"), ArenaConst.getMatchStepDesc(data.step))
                    -- local extend_msg = TI18N("参与比赛和竞猜玩法")
                    -- self.alert_window = CommonAlert.show(msg,TI18N("确定"),confirm_callback,TI18N("取消"),cancel_callback, CommonAlert.type.rich,cancel_callback,{off_y = 43, extend_str = extend_msg, extend_offy = -75, extend_aligment = cc.TEXT_ALIGNMENT_CENTER})
                end
            end
        end
    else
        if self.alert_window ~= nil then
            self.alert_window:close()
            self.alert_window = nil
        end
    end
end

-- 个人基础信息
function ArenaController:requestRoleInfo()
    self:SendProtocal(20251, {})
end
function ArenaController:handle20251(data)
    self.champion_model:setRoleInfo(data)
end

--==============================--
--desc:请求冠军联赛前3名排行
--time:2018-08-03 06:51:18
--@return 
--==============================--
function ArenaController:requestChampionTop3()
    self:SendProtocal(20280, {})
end
-- 更新冠军赛前三
function ArenaController:handle20280(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionTop3Event, data.rank_list) 
end

-- 请求我的比赛信息
function ArenaController:requestMyChampionMatch()
    self:SendProtocal(20252, {})
end

function ArenaController:handle20252(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMyMatchInfoEvent, data)
end

-- 请求竞猜的比赛信息
function ArenaController:requestGuessChampionMatch()
    self:SendProtocal(20253, {})
end

function ArenaController:handle20253(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateGuessMatchInfoEvent, data)
end

--==============================--
--desc:请求押注某一方
--time:2018-08-05 06:48:42
--@bet_type:
--@bet_val:
--@return 
--==============================--
function ArenaController:requestBetTheMatch(bet_type, bet_val)
    local proto = {}
    proto.bet_type = bet_type
    proto.bet_val = bet_val
    self:SendProtocal(20254, proto)
end
function ArenaController:handle20254(data)
    message(data.msg)
    if data.code == TRUE then
        local role_info = self.champion_model:getRoleInfo()
        role_info.can_bet = data.can_bet
        GlobalEvent:getInstance():Fire(ArenaEvent.UpdateRoleInfoBetEvent, data.can_bet, data.bet_type)
        self:openArenaChampionGuessWindow(false)
    end
end

--==============================--
--desc:竞猜的实时更新
--time:2018-08-05 10:51:36
--@data:
--@return 
--==============================--
function ArenaController:handle20257(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateBetMatchValueEvent, data)
end

--==============================--
--desc:请求我的竞猜列表
--time:2018-08-05 10:54:46
--@return 
--==============================--
function ArenaController:requestMyGuessInfo()
    self:SendProtocal(20255, {})
end

function ArenaController:handle20255(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMyGuessListEvent, data.list)
end

--==============================--
--desc:请求冠军赛排行榜数据
--time:2018-08-05 11:36:21
--@return 
--==============================--
function ArenaController:requestChompionRank()
    self:SendProtocal(20281, {})
end

function ArenaController:handle20281(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionRankEvent, data)
end

--==============================--
--desc:请求32强数据
--time:2018-08-06 09:58:07
--@return 
--==============================--
function ArenaController:requestTop32Info()
    self:SendProtocal(20260, {})
end
function ArenaController:handle20260(data)
    GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop32InfoEvent, data.list)
end

--==============================--
--desc:请求4强数据
--time:2018-08-06 02:27:41
--@return 
--==============================--
function ArenaController:requestTop4Info()
    self:SendProtocal(20261, {})
end
function ArenaController:handle20261(data)
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop4InfoEvent, data.pos_list)
end 

-- 请求32强或者4强赛的竞猜位置信息
function ArenaController:requestGuessGroupInfo()
    self:SendProtocal(20262, {})
end
function ArenaController:handle20262(data)
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop324GuessGroupEvent, data.group, data.pos)
end 

--==============================--
--desc:请求43,4强赛指定对战信息
--time:2018-08-06 04:23:23
--@group:
--@pos:
--@return 
--==============================--
function ArenaController:requestGroupPosInfo(group, pos)
    local protocal = {}
    protocal.group = group 
    protocal.pos = pos
    self:SendProtocal(20263, protocal)
end
function ArenaController:handle20263(data) 
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop324GroupPosEvent, data)
end

--==============================--
--desc:请求自己结算展示的
--time:2018-08-06 08:52:16
--@return 
--==============================--
function ArenaController:requestSelfResultInfo()
    self:SendProtocal(20256, {})
end
function ArenaController:handle20256(data)
    self:openArenaChampionBestInfoWindow(true, data) 
end

--==============================--
--desc:我的战斗日志
--time:2018-08-07 09:37:20
--@return 
--==============================--
function ArenaController:requestMyLogInfo()
    self:SendProtocal(20258, {})
end
function ArenaController:handle20258(data)
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMylogListEvent, data.list)
end 

---
function ArenaController:handle20282(data)
    -- 引导中就不要弹了
    if GuideController:getInstance():isInGuide() then return end
    if StoryController:getInstance():getModel():isStoryState() then return end 
    RenderMgr:getInstance():doNextFrame(function() 
        self:openArenaChampionTop3Window(true, data)
    end)
end

function ArenaController:requestRabotInfo(rid, srv_id, pos)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.pos = pos
    self:SendProtocal(20204, protocal);
end

function ArenaController:handle20204(data)
    HeroController:getInstance():openHeroTipsPanel(true, data); 
end