-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: XHJ@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场 后端 锋林 策划 康杰
-- <br/>Create: 2020-03-18
-- --------------------------------------------------------------------
ArenaManyPeopleModel = ArenaManyPeopleModel or BaseClass()

function ArenaManyPeopleModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ArenaManyPeopleModel:config()

    --我的队伍信息
    self.my_team_info = nil 
    self.is_touch_fight = false
    self.is_report_red = false
end

--主界面的红点
function ArenaManyPeopleModel:checkArenateamTotalRedPoint()
    local redpoint = false

    if self.my_team_info then 
        --1:开启组队
        if self.my_team_info.state == 1 then
            for i,v in ipairs(self.my_team_info.award_list) do
                if v.status == 1 then
                    redpoint = true
                    break
                end
            end
            
            -- if not redpoint and self.my_team_info.count > 0 then
            --     redpoint = true   
            -- end

            if not redpoint and self.invitation_info and self.invitation_info.team_members and #self.invitation_info.team_members >0 then
                redpoint = true
            end

            if not redpoint then
                redpoint = self.is_report_red 
            end
        end

        GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_ALL_RED_POINT_EVENT)

        if redpoint == nil then
            redpoint = false
        end
    end

    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.arena_many_people, redpoint)

    return redpoint
end

function ArenaManyPeopleModel:setIsReportRedpoint(status)
    self.is_report_red = status
    self:checkArenateamTotalRedPoint()
end

function ArenaManyPeopleModel:getIsReportRedpoint()
    return self.is_report_red
end

function ArenaManyPeopleModel:getMyTeamInfo()
    return self.my_team_info
end

function ArenaManyPeopleModel:setMyTeamInfo(my_team_info)
    self.my_team_info = my_team_info
    self:checkArenateamTotalRedPoint()
end

--刷新购买挑战次数
function ArenaManyPeopleModel:updateBuyNum(data)
    if self.my_team_info and data then
        self.my_team_info.count = data.count
        self.my_team_info.buy_count = data.buy_count
        self:checkArenateamTotalRedPoint()
    end
end

--获取我的信息
function ArenaManyPeopleModel:getMyInfo()
    if self.my_team_info then
        local team_members = self.my_team_info.team_members
        local role_vo = RoleController:getInstance():getRoleVo()
        for i,v in ipairs(team_members) do
            if role_vo and v.rid == role_vo.rid and v.sid == role_vo.srv_id then 
                return v
            end
        end
    end
    return nil
end

--更新我的排行
function ArenaManyPeopleModel:updateMyRank(data)
    if self.my_team_info and data then
        local team_members = self.my_team_info.team_members
        local role_vo = RoleController:getInstance():getRoleVo()
        for i,v in ipairs(team_members) do
            if role_vo and v.rid == role_vo.rid and v.sid == role_vo.srv_id then 
                v.rank = data.rank
                break
            end
        end
    end
end

--保存匹配信息
function ArenaManyPeopleModel:setMatchInfo(data)
    self.match_info = data
end

function ArenaManyPeopleModel:getMatchInfo()
    return self.match_info
end

function ArenaManyPeopleModel:updateMyMatchInfo(data)
    if self.match_info and self.match_info.atk_team_members then
        for k,v in pairs(self.match_info.atk_team_members) do
            if data and v.rid == data.rid and v.sid == data.sid then
                data.pos = v.pos
                self.match_info.atk_team_members[k] = data
                break
            end
        end
    end
end

function ArenaManyPeopleModel:setInvitationInfo(data)
    self.invitation_info = data
    self:checkArenateamTotalRedPoint()
end

function ArenaManyPeopleModel:getInvitationInfo()
    return self.invitation_info
end

function ArenaManyPeopleModel:updateRewardInfo(id)
    if self.my_team_info and id then
        for i,v in ipairs(self.my_team_info.award_list) do
            if v.award_id == id then
                v.status = 2
            end
        end
        self:checkArenateamTotalRedPoint()
    end
end

function ArenaManyPeopleModel:setHideIndex()
    local index = math.random(1, 3)
    self.hide_index = index
end

function ArenaManyPeopleModel:getHideIndex()
    if not self.hide_index then
        self:setHideIndex()
    end
    return self.hide_index
end

function ArenaManyPeopleModel:setIsTouchFight(is_touch)
    self.is_touch_fight = is_touch
end

function ArenaManyPeopleModel:getIsTouchFight()
    return self.is_touch_fight
end

-- 活动是否达到开启条件
function ArenaManyPeopleModel:checkAMPIsOpen(  )
    local is_open = false
    local team_open_lev = Config.HolidayArenaTeamData.data_const.team_open_lev
	local team_open_day = Config.HolidayArenaTeamData.data_const.team_open_day
	local role_vo = RoleController:getInstance():getRoleVo()
	if team_open_lev and team_open_lev.val <= role_vo.lev and team_open_day and team_open_day.val <= role_vo.open_day then
		is_open = true
	end
	return is_open
end

function ArenaManyPeopleModel:__delete()
end