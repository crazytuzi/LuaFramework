-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队竞技场 后端 锋林 策划 康杰
-- <br/>Create: 2019-09-28
-- --------------------------------------------------------------------
ArenateamModel = ArenateamModel or BaseClass()

function ArenateamModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ArenateamModel:config()

    --我的队伍信息
    self.my_team_info = nil 

    --我的详细队伍信息
    self.my_team_details_info = nil
end

--主界面的红点
function ArenateamModel:checkArenateamTotalRedPoint( need_check)
    local redpoint = false

    if self.my_team_info then 
        --1:开启组队  2:开启挑战 
        if self.my_team_info.state == 1 or self.my_team_info.state == 2 then
            for i,v in ipairs(self.my_team_info.award_list) do
                if v.status == 1 then
                    redpoint = true
                    break
                end
            end

            -- if self.login_data then
                if not redpoint then
                    redpoint = self.is_report_red 
                end

                if not redpoint then
                    --队员数量不满足红点
                    if self.my_team_info and #self.my_team_info.team_members < 3 then
                        redpoint = self.is_apply_red
                    end
                end

                if not redpoint then
                    redpoint = self.is_invitation_red
                end

                if not redpoint then
                    redpoint = self.is_chat_red
                end
            -- end
        elseif self.my_team_info.state == 4 or self.my_team_info.state == 3 then --结算期 和 排行展示时期
            --结算期只需要判断 宝箱和战报红点
            for i,v in ipairs(self.my_team_info.award_list) do
                if v.status == 1 then
                    redpoint = true
                    break
                end
            end

            if not redpoint then
                redpoint = self.is_report_red 
            end
        end

        if need_check then
            GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_ALL_RED_POINT_EVENT)
            MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.ladder, {bid = CrossgroundConst.Red_Type.Arenateam, status = redpoint})
        end

        if redpoint == nil then
            redpoint = false
        end
    end
    return redpoint
end

function ArenateamModel:updateLoginRedpoint(data)
    if not data then return end
    self.login_data = data

    for i,v in ipairs(data.point) do
        if v.type == 1 then --战报红点
            self.is_report_red = (v.state == 1)
        elseif v.type == 2 then --申请红点
            self.is_apply_red = (v.state == 1)
        elseif v.type == 3 then --被邀请红点
            self.is_invitation_red = (v.state == 1)
        elseif v.type == 4 then --新的聊天
            self.is_chat_red = (v.state == 1)
        end
    end
    self:checkArenateamTotalRedPoint(true)
end

--设置红点类型

function ArenateamModel:setIsReportRedpoint(status)
    self.is_report_red = status
    self:checkArenateamTotalRedPoint(true)
end

function ArenateamModel:setIsApplayRedpoint(status)
    self.is_apply_red = status
    self:checkArenateamTotalRedPoint(true)
end

function ArenateamModel:setIsInvitationRedpoint(status)
    self.is_invitation_red = status
    self:checkArenateamTotalRedPoint(true)
end

function ArenateamModel:setIsChatRedpoint(status)
    self.is_chat_red = status
    self:checkArenateamTotalRedPoint(true)
end

function ArenateamModel:getMyTeamInfo()
    return self.my_team_info
end

function ArenateamModel:setMyTeamInfo(my_team_info)
    self.my_team_info = my_team_info
    self:checkArenateamTotalRedPoint(true)
end

function ArenateamModel:updateRewardInfo(id)
    if self.my_team_info and id then
        for i,v in ipairs(self.my_team_info.award_list) do
            if v.award_id == id then
                v.status = 2
            end
        end
        self:checkArenateamTotalRedPoint(true)
    end
end

function ArenateamModel:setMyTeamDetailsInfo(data)
    if data.tid == 0 then
        self.my_team_details_info = nil
    else
        self.my_team_details_info = data
    end
end

function ArenateamModel:getMyTeamDetailsInfo()
    return self.my_team_details_info
end

--是否已有队伍
function ArenateamModel:isHaveTeam()
    if self.my_team_info and self.my_team_info.tid ~= 0 then
         return true
    end
    return false
end

function ArenateamModel:updateRankInfo(data)
    self.rank_data = data
end
function ArenateamModel:getRankData()
    return self.rank_data
end

function ArenateamModel:checkArenaTeamIsOpen(not_tips)
    local role_lv_cfg = Config.ArenaTeamData.data_const["open_lev"]
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo and role_lv_cfg and role_vo.lev < role_lv_cfg.val then
        if not not_tips then
            message(role_lv_cfg.desc)
        end
        return false, 1 ,role_lv_cfg.desc
    end
    return true
end

--判断玩家是否是队长
function ArenateamModel:isLeader()
    if self.my_team_info then
        local team_members = self.my_team_info.team_members
        for i,v in ipairs(team_members) do
            for _,data in ipairs(v.ext) do
                if data.extra_key == 1 and data.extra_val == 1 then
                    local role_vo = RoleController:getInstance():getRoleVo()
                    if role_vo and v.rid == role_vo.rid and v.sid == role_vo.srv_id then 
                        --是队长
                        return true
                    end
                end
            end
        end
    end
    return false
end

function ArenateamModel:getTimeStep()
    if self.time_step then
        return self.time_step
    end
    return 0
end

function ArenateamModel:startTimeTicket()
    if self.refresh_cd == nil then
        self.refresh_cd = 10
        local config = Config.ArenaTeamData.data_const.refresh_cd
        if config then 
            self.refresh_cd = config.val
        end
    end
    self.time_step = self.refresh_cd
    local _callback = function()
        self.time_step = self.time_step - 1
        GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_TIMER_EVENT, self.time_step)
        if self.time_step <= 0 then
            self:clearTimeTicket()
        end
    end

    self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 1)
end


function ArenateamModel:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

function ArenateamModel:__delete()
end