-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队竞技场 后端 锋林 策划 康杰
-- <br/>Create: 2019-09-28
-- --------------------------------------------------------------------
ArenateamController = ArenateamController or BaseClass(BaseController)

function ArenateamController:config()
    self.model = ArenateamModel.New(self)
    self.dispather = GlobalEvent:getInstance()

    -- self:setOpenFunction(func_name, panel_obj, panel_name)
end

function ArenateamController:getModel()
    return self.model
end

function ArenateamController:registerEvents()

    --聊天那边会影响这边的红点
    self.chat_event = GlobalEvent:getInstance():Bind(EventId.CHAT_UDMSG_WORLD, function(channel, is_self, is_login_content)
        if channel and channel == ChatConst.Channel.Team or channel == ChatConst.Channel.Team_Sys then 
            if not is_login_content then
                self.model:setIsChatRedpoint(true)
            end
        end
    end) 

    self.team_info = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_REFRESH_TEAM_INFO_EVENT, function()
        --没保存布阵一
        local my_team_info = self.model:getMyTeamInfo()
        if my_team_info and my_team_info.tid ~= 0 then
            self:sender27221()
        end
    end)

                
end

function ArenateamController:registerProtocals()
    --主界面协议
    self:RegisterProtocal(27220, "handle27220")  --"主界面队伍协议"


    --组队大厅协议
    self:RegisterProtocal(27200, "handle27200")  --"请求队伍信息"
    self:RegisterProtocal(27201, "handle27201")  --"创建队伍"
    self:RegisterProtocal(27202, "handle27202")  --"申请入队"
    self:RegisterProtocal(27203, "handle27203")  --"获取申请入队列表"
    self:RegisterProtocal(27204, "handle27204")  --"回应入队申请"
    self:RegisterProtocal(27205, "handle27205")  --"邀请玩家入队"
    self:RegisterProtocal(27206, "handle27206")  --"获取邀请列表"
    self:RegisterProtocal(27207, "handle27207")  --"回应邀请入队信息"
    self:RegisterProtocal(27208, "handle27208")  --"一键清除邀请信息"

    self:RegisterProtocal(27210, "handle27210")  --"搜索队伍"

    self:RegisterProtocal(27211, "handle27211")  --"退出队伍"
    self:RegisterProtocal(27212, "handle27212")  --"踢出玩家"
    self:RegisterProtocal(27213, "handle27213")  --"移交队长"

    self:RegisterProtocal(27215, "handle27215")  --"登陆红点"
    self:RegisterProtocal(27216, "handle27216")  --"一键申请队伍"


    self:RegisterProtocal(27221, "handle27221")  --"请求我的队伍信息"
    
    self:RegisterProtocal(27222, "handle27222")  --"事件监听"

    self:RegisterProtocal(27223, "handle27223")  --"主界面排行榜"
    self:RegisterProtocal(27224, "handle27224")  --"领取宝箱奖励"

    self:RegisterProtocal(27225, "handle27225")  --"修改队伍设置"
    self:RegisterProtocal(27226, "handle27226")  --"修改名字"
    self:RegisterProtocal(27228, "handle27228")  --"获取推荐玩家"
    self:RegisterProtocal(27229, "handle27229")  --"搜索指定玩家"

    
    self:RegisterProtocal(27240, "handle27240")  --"报名参赛"
    self:RegisterProtocal(27241, "handle27241")  --"取消报名"

    self:RegisterProtocal(27242, "handle27242")  --"保存布阵调整"
    self:RegisterProtocal(27243, "handle27243")  --"请求布阵"


    self:RegisterProtocal(27250, "handle27250")  --"刷新对手"
    self:RegisterProtocal(27251, "handle27251")  --"匹配对手"
    self:RegisterProtocal(27252, "handle27252")  --"挑战对手"
    self:RegisterProtocal(27253, "handle27253")  --"战斗结算"

    self:RegisterProtocal(27255, "handle27255")  --"战报日志"
    self:RegisterProtocal(27256, "handle27256")  --"战报个人日志"

    self:RegisterProtocal(27227, "handle27227")  --"在线推送"
    --
end

function  ArenateamController:checkArenaTeamIsOpen(not_tips)
    return self.model:checkArenaTeamIsOpen(not_tips)
end

--主界面协议
function ArenateamController:sender27220()
    local protocal = {}
    self:SendProtocal(27220, protocal)
end

function ArenateamController:handle27220(data)
    self.model:setMyTeamInfo(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_MAIN_EVENT, data)
end

function ArenateamController:handle27227(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_ONLINE_EVENT, data)
end

--进入组队大厅
function ArenateamController:sender27200()
    local protocal = {}
    self:SendProtocal(27200, protocal)
end

function ArenateamController:handle27200(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_HALL_MAIN_EVENT, data)
end


--创建队伍
function ArenateamController:sender27201(name, limit_lev, limit_power, is_check)
    local protocal = {}
    protocal.name = name
    protocal.limit_lev = limit_lev
    protocal.limit_power = limit_power
    protocal.is_check = is_check

    self:SendProtocal(27201, protocal)
end

function ArenateamController:handle27201(data)
    message(data.msg)
    if data.code == TRUE then
        --创建队伍成功 要打开 我的队伍界面 只要在组队大厅还存在的情况下打开..其他情况不处理
        if self.arenateam_hall_panel then
            self.arenateam_hall_panel:changeSelectedTab(ArenateamConst.TeamHallTabType.eMyTeam)
        end
        if self.arenateam_create_team_panel then
            self:openArenateamCreateTeamPanel(false)
        end
        self:sender27220()
    end
end

--申请入队
function ArenateamController:sender27202(tid, srv_id)
    local protocal = {}
    protocal.tid = tid
    protocal.srv_id = srv_id
    self:SendProtocal(27202, protocal)
end

function ArenateamController:handle27202(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_APPLY_TEAM_EVENT, data)
    end
end

--获取申请入队列表
function ArenateamController:sender27203(tid, srv_id)
    local protocal = {}
    protocal.tid = tid
    protocal.srv_id = srv_id
    self:SendProtocal(27203, protocal)
end

function ArenateamController:handle27203(data)
    if #data.arena_team_member == 0 then 
        self.model:setIsApplayRedpoint(false)
    end
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_APPLY_LIST_EVENT, data)
end

--回应入队申请
function ArenateamController:sender27204(rid, srv_id, _type)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.type = _type
    self:SendProtocal(27204, protocal)
end

function ArenateamController:handle27204(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_ANSWER_APPLY_EVENT, data)
    end
end

--获取邀请列表
function ArenateamController:sender27205(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(27205, protocal)
end

function ArenateamController:handle27205(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_INVITATION_PLAYER_EVENT, data)
    end
end

--获取邀请列表
function ArenateamController:sender27206()
    local protocal = {}
    self:SendProtocal(27206, protocal)
end

function ArenateamController:handle27206(data)
    -- if #data.team_list == 0 then
        self.model:setIsInvitationRedpoint(false)
    -- end
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_INVITATION_LIST_EVENT, data)
end


--回应邀请入队信息
function ArenateamController:sender27207(tid, srv_id, _type)
    local protocal = {}
    protocal.tid = tid
    protocal.srv_id = srv_id
    protocal.type = _type
    self:SendProtocal(27207, protocal)
end

function ArenateamController:handle27207(data)
    message(data.msg)
    if data.code == TRUE then
        self:sender27206()
    end
end

--一键清除
function ArenateamController:sender27208()
    local protocal = {}
    self:SendProtocal(27208, protocal)
end

function ArenateamController:handle27208(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_KEY_CLEAR_EVENT, data)
    end
end


--搜索队伍
function ArenateamController:sender27210(name)
    local protocal = {}
    protocal.name = name
    self:SendProtocal(27210, protocal)
end

function ArenateamController:handle27210(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_SEARCH_TEAM_EVENT, data)
    end
end

--退出队伍
function ArenateamController:sender27211()
    local protocal = {}
    self:SendProtocal(27211, protocal)
end

function ArenateamController:handle27211(data)
    message(data.msg)
    if data.code == TRUE then
        if self.arenateam_hall_panel then
            self:sender27221()
        end
        self:sender27220()
        self.model:setIsApplayRedpoint(false)
    end
end
--踢出玩家
function ArenateamController:sender27212(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(27212, protocal)
end

function ArenateamController:handle27212(data)
    message(data.msg)
    if data.code == TRUE then
        if self.arenateam_delete_player_panel then
            self:openArenateamDeletePlayerPanel(false)
        end
    end
end

--移交队长
function ArenateamController:sender27213(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(27213, protocal)
end

function ArenateamController:handle27213(data)
    message(data.msg)
    if data.code == TRUE then
        if self.arenateam_hall_panel then
            self:sender27221()
        end
        self:sender27220()
    end
end
--红点
function ArenateamController:sender27215(rid, srv_id)
    local protocal = {}
    self:SendProtocal(27215, protocal)
end

function ArenateamController:handle27215(data)
    self.model:updateLoginRedpoint(data)
end

--一键申请队伍
function ArenateamController:sender27216(do_join_list)
    local protocal = {}
    protocal.do_join_list = do_join_list
    self:SendProtocal(27216, protocal)
end

function ArenateamController:handle27216(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_KEY_APPLY_TEAM_EVENT, data)
    end
end

--获取我的队伍信息
function ArenateamController:sender27221()
    local protocal = {}
    self:SendProtocal(27221, protocal)
end

function ArenateamController:handle27221(data)
    self.model:setMyTeamDetailsInfo(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_MY_TEAM_INFO_EVENT, data)
end

--"事件类型(1:加入新队伍 2: 队伍信息变更 3:新的入队申请 4:新的入队邀请 5:被踢出队伍 6:战斗结算)"
function ArenateamController:handle27222(data)
    if data.type == 1 then --加入新队伍
        self:joinNewTeam()
    elseif data.type == 2 then --队伍信息变更
        if self.arenateam_hall_panel then
            self:sender27221()  
        end
        self:sender27220()  
    elseif data.type == 3 then --新的入队申请 
        self:newApply()
    elseif data.type == 4 then --新的入队邀请
        self:newInvitation()
    elseif data.type == 5 then -- :被踢出队伍
        self:leaveTeam()
    elseif data.type == 6 then -- 战斗结算
        self:fightResult()
    end
end

--推送新的入队申请
function ArenateamController:newApply()
    self.model:setIsApplayRedpoint(true)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_APPLY_RED_POINT_EVENT)
end

--推送新的入队邀请
function ArenateamController:newInvitation(data)
    self.model:setIsInvitationRedpoint(true)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_INVITATION_RED_POINT_EVENT)
end

--推送加入新队伍
function ArenateamController:joinNewTeam(data)
    if self.arenateam_main_window then
        self:sender27220()
        if self.arenateam_hall_panel then
            self.arenateam_hall_panel:changeSelectedTab(ArenateamConst.TeamHallTabType.eMyTeam)
        else
            self:openArenateamHallPanel(true, {index = ArenateamConst.TeamHallTabType.eMyTeam})
        end
    end
end

--推送被踢了
function ArenateamController:leaveTeam(data)
    if self.arenateam_add_player_panel then
        self:openArenateamAddPlayerPanel(false)
    end

    if self.arenateam_main_window then
        if self.arenateam_hall_panel then
            self:openArenateamHallPanel(false)
        end
        self:sender27220()
    end
end

--推战斗结束
function ArenateamController:fightResult()
    self.model:setIsReportRedpoint(true)
    if self.arenateam_main_window then
        self:sender27220()
        self:sender27223(1, 100)
    end
end



--"主界面排行榜"
function ArenateamController:sender27223(start_rank, end_rank)
    local protocal = {}
    protocal.start_rank = start_rank
    protocal.end_rank = end_rank
    self:SendProtocal(27223, protocal)
end

function ArenateamController:handle27223(data)
    self.model:updateRankInfo(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_MAIN_RANK_EVENT, data)  
end
--领取奖励
function ArenateamController:sender27224(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(27224, protocal)
end

function ArenateamController:handle27224(data)
    if data.code == TRUE then
        self.model:updateRewardInfo(data.id)
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_RECEIVE_BOX_EVENT, data)
    end
end
--修改队伍设置
function ArenateamController:sender27225(limit_lev, limit_power, is_check)
    local protocal = {}
    protocal.limit_lev = limit_lev
    protocal.limit_power = limit_power
    protocal.is_check = is_check
    self:SendProtocal(27225, protocal)
end

function ArenateamController:handle27225(data)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_TEAM_SET_EVENT, data)
        if self.arenateam_team_set_panel then
            self:openArenateamTeamSetPanel(false) 
        end
    end
end

--修改队伍名字
function ArenateamController:sender27226(name)
    local protocal = {}
    protocal.name = name
    self:SendProtocal(27226, protocal)
end

function ArenateamController:handle27226(data)
    if data.code == TRUE then
        message(TI18N("队伍名修改成功"))
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_CHANGE_NAME_EVENT, data)
    else
        message(data.msg)
    end
end

--获取推荐玩家
function ArenateamController:sender27228()
    local protocal = {}
    self:SendProtocal(27228, protocal)
end

function ArenateamController:handle27228(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_GET_RECOMMEND_INFO_EVENT, data)
end

--搜索指定玩家
function ArenateamController:sender27229(name)
    local protocal = {}
    protocal.name = name
    self:SendProtocal(27229, protocal)
end

function ArenateamController:handle27229(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_SEARCH_PLAYER_EVENT, data)
end

--报名参赛
function ArenateamController:sender27240()
    local protocal = {}
    self:SendProtocal(27240, protocal)
end

function ArenateamController:handle27240(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_JOIN_GAME_EVENT, data)    
    end
end

--取消报名
function ArenateamController:sender27241()
    local protocal = {}
    self:SendProtocal(27241, protocal)
end

function ArenateamController:handle27241(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_LEAVE_GAME_EVENT, data)    
    end
end

--保存布阵调整
function ArenateamController:sender27242(pos_info)
    local protocal = {}
    protocal.pos_info = pos_info
    self:SendProtocal(27242, protocal)
end

function ArenateamController:handle27242(data)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_SAVE_FROM_EVENT, data) 
        self:sender27221()
    else
        message(data.msg)  
    end
end

--三个对玩的布阵信息
function ArenateamController:sender27243()
    local protocal = {}
    self:SendProtocal(27243, protocal)
end

function ArenateamController:handle27243(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_THREE_TEAM_INFO_EVENT, data)    
end

--刷新对手
function ArenateamController:sender27250()
    local protocal = {}
    self:SendProtocal(27250, protocal)
end

function ArenateamController:handle27250(data)
    if data.code == TRUE then
        self.refresh_27250 = true
    end
end
--匹配对手
function ArenateamController:sender27251()
    local protocal = {}
    self:SendProtocal(27251, protocal)
end

function ArenateamController:handle27251(data)
    if self.refresh_27250 then
        self.refresh_27250 = false
        message(TI18N("刷新成功"))
    end
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_MATCH_OTHER_EVENT, data)    
end


--挑战对手
function ArenateamController:sender27252(tid, srv_id, is_auto)
    local protocal = {}
    protocal.tid = tid
    protocal.srv_id = srv_id
    protocal.is_auto = is_auto
    self:SendProtocal(27252, protocal)
end

function ArenateamController:handle27252(data)
    message(data.msg)
    -- GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_MATCH_OTHER_EVENT, data)
end

--战斗结算
function ArenateamController:handle27253(data)
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.Arean_Team, data)   
end

--战报
function ArenateamController:sender27255()
    local protocal = {}
    self:SendProtocal(27255, protocal)
end

function ArenateamController:handle27255(data)
    self.model:setIsReportRedpoint(false)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_MIAIN_REPORT_EVENT, data)
end

--个人战报
function ArenateamController:sender27256(id)
    local protocal = {}
    protocal.id  = id
    self:SendProtocal(27256, protocal)
end

function ArenateamController:handle27256(data)
    GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_SINGLE_REPORT_EVENT, data)
end

--打开组队竞技场主界面
function ArenateamController:openArenateamMainWindow( status, setting )
    if status == true then
        if self.arenateam_main_window == nil then
            self.arenateam_main_window = ArenateamMainWindow.New()
        end
        if self.arenateam_main_window:isOpen() == false then
            self.arenateam_main_window:open(setting)
        end
    else
        if self.arenateam_main_window then
            self.arenateam_main_window:close()
            self.arenateam_main_window = nil
        end
    end
end

--创建队伍
function ArenateamController:openArenateamCreateTeamPanel( status, setting )
    if status == true then
        if self.arenateam_create_team_panel == nil then
            self.arenateam_create_team_panel = ArenateamCreateTeamPanel.New()
        end
        if self.arenateam_create_team_panel:isOpen() == false then
            self.arenateam_create_team_panel:open(setting)
        end
    else
        if self.arenateam_create_team_panel then
            self.arenateam_create_team_panel:close()
            self.arenateam_create_team_panel = nil
        end
    end
end
--组队大厅
function ArenateamController:openArenateamHallPanel( status, setting )
    if status == true then
        if self.arenateam_hall_panel == nil then
            self.arenateam_hall_panel = ArenateamHallPanel.New()
        end
        if self.arenateam_hall_panel:isOpen() == false then
            self.arenateam_hall_panel:open(setting)
        end
    else
        if self.arenateam_hall_panel then
            self.arenateam_hall_panel:close()
            self.arenateam_hall_panel = nil
        end
    end
end
--队伍改名
function ArenateamController:openArenateamChangTeamNamePanel( status, setting )
    if status == true then
        if self.arenateam_chang_team_name_panel == nil then
            self.arenateam_chang_team_name_panel = ArenateamChangTeamNamePanel.New()
        end
        if self.arenateam_chang_team_name_panel:isOpen() == false then
            self.arenateam_chang_team_name_panel:open(setting)
        end
    else
        if self.arenateam_chang_team_name_panel then
            self.arenateam_chang_team_name_panel:close()
            self.arenateam_chang_team_name_panel = nil
        end
    end
end
--修改队伍申请条件
function ArenateamController:openArenateamTeamSetPanel( status, setting )
    if status == true then
        if self.arenateam_team_set_panel == nil then
            self.arenateam_team_set_panel = ArenateamTeamSetPanel.New()
        end
        if self.arenateam_team_set_panel:isOpen() == false then
            self.arenateam_team_set_panel:open(setting)
        end
    else
        if self.arenateam_team_set_panel then
            self.arenateam_team_set_panel:close()
            self.arenateam_team_set_panel = nil
        end
    end
end

--踢除队员
function ArenateamController:openArenateamDeletePlayerPanel( status, setting )
    if status == true then
        if self.arenateam_delete_player_panel == nil then
            self.arenateam_delete_player_panel = ArenateamDeletePlayerPanel.New()
        end
        if self.arenateam_delete_player_panel:isOpen() == false then
            self.arenateam_delete_player_panel:open(setting)
        end
    else
        if self.arenateam_delete_player_panel then
            self.arenateam_delete_player_panel:close()
            self.arenateam_delete_player_panel = nil
        end
    end
end

--添加队员
function ArenateamController:openArenateamAddPlayerPanel( status, setting )
    if status == true then
        if self.arenateam_add_player_panel == nil then
            self.arenateam_add_player_panel = ArenateamAddPlayerPanel.New()
        end
        if self.arenateam_add_player_panel:isOpen() == false then
            self.arenateam_add_player_panel:open(setting)
        end
    else
        if self.arenateam_add_player_panel then
            self.arenateam_add_player_panel:close()
            self.arenateam_add_player_panel = nil
        end
    end
end

--暂时不搞这东西
function ArenateamController:setOpenFunction(func_name, panel_obj, panel_name)
    self[func_name] = function(status, setting) 
        if status == true then
            if self[panel_name] == nil then
                self[panel_name] = panel_obj.New()
            end
            if self[panel_name]:isOpen() == false then
                self[panel_name]:open(setting)
            end
        else
            if self[panel_name] then
                self[panel_name]:close()
                self[panel_name] = nil
            end
        end
    end
end

--布阵
function ArenateamController:openArenateamFormPanel( status, setting )
    if status == true then
        if self.arenateam_form_panel == nil then
            self.arenateam_form_panel = ArenateamFormPanel.New()
        end
        if self.arenateam_form_panel:isOpen() == false then
            self.arenateam_form_panel:open(setting)
        end
    else
        if self.arenateam_form_panel then
            self.arenateam_form_panel:close()
            self.arenateam_form_panel = nil
        end
    end
end

--打开挑战界面 三选一界面
function ArenateamController:openArenateamFightListPanel( status, setting )
    if status == true then
        if self.arenateam_fight_list_panel == nil then
            self.arenateam_fight_list_panel = ArenateamFightListPanel.New()
        end
        if self.arenateam_fight_list_panel:isOpen() == false then
            self.arenateam_fight_list_panel:open(setting)
        end
    else
        if self.arenateam_fight_list_panel then
            self.arenateam_fight_list_panel:close()
            self.arenateam_fight_list_panel = nil
        end
    end
end
--打开挑战界面tips界面
function ArenateamController:openArenateamFightTips( status, setting )
    if status == true then
        if self.arenateam_fight_tips == nil then
            self.arenateam_fight_tips = ArenateamFightTips.New()
        end
        if self.arenateam_fight_tips:isOpen() == false then
            self.arenateam_fight_tips:open(setting)
        end
    else
        if self.arenateam_fight_tips then
            self.arenateam_fight_tips:close()
            self.arenateam_fight_tips = nil
        end
    end
end

--打结算界面
function ArenateamController:openArenateamFightResultPanel( status, data )
    if status == true then
        if self.arenateam_fight_result_panel == nil then
            local data1 = data or {}
            local result = data1.result or 1
            self.arenateam_fight_result_panel = ArenateamFightResultPanel.New(result)
        end
        if self.arenateam_fight_result_panel:isOpen() == false then
            self.arenateam_fight_result_panel:open(data)
        end
    else
        if self.arenateam_fight_result_panel then
            self.arenateam_fight_result_panel:close()
            self.arenateam_fight_result_panel = nil
        end
    end
end

--打开录像记录界面
function ArenateamController:openArenateamFightRecordPanel( status, setting )
    if status == true then
        if self.arenateam_fight_record_panel == nil then
            self.arenateam_fight_record_panel = ArenateamFightRecordPanel.New()
        end
        if self.arenateam_fight_record_panel:isOpen() == false then
            self.arenateam_fight_record_panel:open(setting)
        end
    else
        if self.arenateam_fight_record_panel then
            self.arenateam_fight_record_panel:close()
            self.arenateam_fight_record_panel = nil
        end
    end
end
--打开录像记录界面
function ArenateamController:openArenateamFightVedioPanel( status, setting )
    if status == true then
        if self.arenateam_fight_vedio_panel == nil then
            self.arenateam_fight_vedio_panel = ArenateamFightVedioPanel.New()
        end
        if self.arenateam_fight_vedio_panel:isOpen() == false then
            self.arenateam_fight_vedio_panel:open(setting)
        end
    else
        if self.arenateam_fight_vedio_panel then
            self.arenateam_fight_vedio_panel:close()
            self.arenateam_fight_vedio_panel = nil
        end
    end
end

--打开奖励界面
function ArenateamController:openArenateamBoxRewardPanel( status, setting )
    if status == true then
        if self.arenateam_box_reward_panel == nil then
            self.arenateam_box_reward_panel = ArenateamBoxRewardPanel.New()
        end
        if self.arenateam_box_reward_panel:isOpen() == false then
            self.arenateam_box_reward_panel:open(setting)
        end
    else
        if self.arenateam_box_reward_panel then
            self.arenateam_box_reward_panel:close()
            self.arenateam_box_reward_panel = nil
        end
    end
end
--打开排行界面
function ArenateamController:openArenateamRankRewardPanel( status, setting )
    if status == true then
        if self.arenateam_rank_reward_panel == nil then
            self.arenateam_rank_reward_panel = ArenateamRankRewardPanel.New()
        end
        if self.arenateam_rank_reward_panel:isOpen() == false then
            self.arenateam_rank_reward_panel:open(setting)
        end
    else
        if self.arenateam_rank_reward_panel then
            self.arenateam_rank_reward_panel:close()
            self.arenateam_rank_reward_panel = nil
        end
    end
end
--打开聊天
function ArenateamController:openArenateamChatPanel( status, setting )
    if status == true then
        if self.arenateam_chat_panel == nil then
            self.arenateam_chat_panel = ArenateamChatPanel.New()
        end
        if self.arenateam_chat_panel:isOpen() == false then
            self.arenateam_chat_panel:open(setting)
        end
    else
        if self.arenateam_chat_panel then
            self.arenateam_chat_panel:close()
            self.arenateam_chat_panel = nil
        end
    end
end



function ArenateamController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end