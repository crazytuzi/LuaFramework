-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场 后端 锋林 策划 康杰
-- <br/>Create: 2020-03-18
-- --------------------------------------------------------------------
ArenaManyPeopleController = ArenaManyPeopleController or BaseClass(BaseController)

function ArenaManyPeopleController:config()
    self.model = ArenaManyPeopleModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.is_click_amp = false
    
end

function ArenaManyPeopleController:getModel()
    return self.model
end

function ArenaManyPeopleController:registerEvents()
            
end

function ArenaManyPeopleController:registerProtocals()
    
    --主界面协议
    self:RegisterProtocal(29000, "handle29000")  --"请求队伍信息"
    self:RegisterProtocal(29001, "handle29001")  --"搜索指定玩家"
    self:RegisterProtocal(29002, "handle29002")  --"邀请入队"
    self:RegisterProtocal(29003, "handle29003")  --"获取邀请列表"
    self:RegisterProtocal(29004, "handle29004")  --"回应邀请入队信息"
    self:RegisterProtocal(29005, "handle29005")  --"一键清除邀请信息"
    self:RegisterProtocal(29006, "handle29006")  --"退出队伍"
    self:RegisterProtocal(29007, "handle29007")  --"移交队长"
    self:RegisterProtocal(29008, "handle29008")  --"获取推荐玩家列表"
    self:RegisterProtocal(29009, "handle29009")  --"查看好友列表"
    self:RegisterProtocal(29010, "handle29010")  --"获取已申请列表"
    
    
    self:RegisterProtocal(29016, "handle29016")  --"匹配对手信息"
    self:RegisterProtocal(29017, "handle29017")  --"刷新对手"
    self:RegisterProtocal(29018, "handle29018")  --"确认对手"
    self:RegisterProtocal(29019, "handle29019")  --"发起战斗"
    self:RegisterProtocal(29020, "handle29020")  --"战斗结算"
    self:RegisterProtocal(29021, "handle29021")  --"推送自身布阵变更"
    self:RegisterProtocal(29022, "handle29022")  --"缓存出站顺序"
    
    self:RegisterProtocal(29025, "handle29025")  --"获取排行榜"
    self:RegisterProtocal(29026, "handle29026")  --"日志数据"
    self:RegisterProtocal(29030, "handle29030")  --"购买挑战次数"
    self:RegisterProtocal(29027, "handle29027")  --"战报个人日志"
    self:RegisterProtocal(29031, "handle29031")  --"领取宝箱奖励"
    self:RegisterProtocal(29028, "handle29028")  --"请求日志红点情况"
    
end


--主界面协议
function ArenaManyPeopleController:sender29000()
    local protocal = {}
    self:SendProtocal(29000, protocal)
end

function ArenaManyPeopleController:handle29000(data)
    self.model:setMyTeamInfo(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MAIN_EVENT, data)
    if data.count > 0 and self.is_click_amp == false then
        PromptController:getInstance():getModel():addPromptData({type = PromptTypeConst.AMP_tips})
    else
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.AMP_tips)
    end
end


--获取邀请列表
function ArenaManyPeopleController:sender29002(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(29002, protocal)
end

function ArenaManyPeopleController:handle29002(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_INVITATION_PLAYER_EVENT, data)
    end
end

--获取邀请列表
function ArenaManyPeopleController:sender29003()
    local protocal = {}
    self:SendProtocal(29003, protocal)
end

function ArenaManyPeopleController:handle29003(data)
    self.model:setInvitationInfo(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_INVITATION_LIST_EVENT, data)
end


--回应邀请入队信息
function ArenaManyPeopleController:sender29004(rid, srv_id, _type)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.type = _type
    self:SendProtocal(29004, protocal)
end

function ArenaManyPeopleController:handle29004(data)
    message(data.msg)
    if data.code == TRUE then
        self:sender29003()
    end
end

--一键清除
function ArenaManyPeopleController:sender29005()
    local protocal = {}
    self:SendProtocal(29005, protocal)
end

function ArenaManyPeopleController:handle29005(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_KEY_CLEAR_EVENT, data)
    end
end


--搜索队伍
function ArenaManyPeopleController:sender29001(name)
    local protocal = {}
    protocal.name = name
    self:SendProtocal(29001, protocal)
end

function ArenaManyPeopleController:handle29001(data)
    message(data.msg)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_SEARCH_TEAM_EVENT, data)
end

--退出队伍
function ArenaManyPeopleController:sender29006()
    local protocal = {}
    self:SendProtocal(29006, protocal)
end

function ArenaManyPeopleController:handle29006(data)
    message(data.msg)
    if data.code == TRUE then
        
    end
end


--移交队长
function ArenaManyPeopleController:sender29007(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(29007, protocal)
end

function ArenaManyPeopleController:handle29007(data)
    message(data.msg)
    if data.code == TRUE then
    end
end


--领取奖励
function ArenaManyPeopleController:sender29031(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(29031, protocal)
end

function ArenaManyPeopleController:handle29031(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateRewardInfo(data.id)
        GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_RECEIVE_BOX_EVENT, data)
    end
end


--进入场景
function ArenaManyPeopleController:sender29035()
    local protocal = {}
    self:SendProtocal(29035, protocal)
end


--获取推荐玩家列表
function ArenaManyPeopleController:sender29008()
    local protocal = {}
    self:SendProtocal(29008, protocal)
end

function ArenaManyPeopleController:handle29008(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_GET_RECOMMEND_INFO_EVENT, data)
end

--查看好友列表
function ArenaManyPeopleController:sender29009()
    local protocal = {}
    self:SendProtocal(29009, protocal)
end

function ArenaManyPeopleController:handle29009(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_GET_RECOMMEND_INFO_EVENT, data)
end


--获取已申请列表
function ArenaManyPeopleController:sender29010()
    local protocal = {}
    self:SendProtocal(29010, protocal)
end

function ArenaManyPeopleController:handle29010(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_UPDATE_MENBER_EVENT, data)
end



--确认对手
function ArenaManyPeopleController:sender29018()
    local protocal = {}
    self:SendProtocal(29018, protocal)
end

function ArenaManyPeopleController:handle29018()
end

--刷新对手
function ArenaManyPeopleController:sender29017()
    local protocal = {}
    self:SendProtocal(29017, protocal)
end

function ArenaManyPeopleController:handle29017(data)
    self.model:setHideIndex()
    message(data.msg)
end
--匹配对手
function ArenaManyPeopleController:sender29016()
    local protocal = {}
    self:SendProtocal(29016, protocal)
end

function ArenaManyPeopleController:handle29016(data)
    message(data.msg)
    if data.code == 1 then
        self.model:setMatchInfo(data)
        if data.is_enter == 1 then
            self:openArenaManyPeopleFightTips(true)
        else
            self:openArenaManyPeopleMatchingWindow(true)
        end
        GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MATCH_OTHER_EVENT, data)    
    end
end


--挑战对手
function ArenaManyPeopleController:sender29019(pos_info)
    local protocal = {}
    protocal.pos_info = pos_info
    self:SendProtocal(29019, protocal)
end

function ArenaManyPeopleController:handle29019(data)
    self:openArenaManyPeopleFightTips(false)
    self:openArenaManyPeopleMatchingWindow(false)
    message(data.msg)
end

--缓存出站顺序
function ArenaManyPeopleController:sender29022(pos_info)
    local protocal = {}
    protocal.pos_info = pos_info
    self:SendProtocal(29022, protocal)
end

function ArenaManyPeopleController:handle29022()

end

--战斗结算
function ArenaManyPeopleController:handle29020(data)
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.AreanManyPeople, data)   
    self:openArenaManyPeopleFightTips(false)
    self:openArenaManyPeopleMatchingWindow(false)
end

--推送自身布阵变更
function ArenaManyPeopleController:sender29021()
    local protocal = {}
    self:SendProtocal(29021, protocal)
end

function ArenaManyPeopleController:handle29021(data)
    self.model:updateMyMatchInfo(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MATCH_MY_EVENT)    
end

--获取排行榜
function ArenaManyPeopleController:sender29025(start_num,end_num)
    local protocal = {}
    protocal.start_num = start_num
    protocal.end_num = end_num
    self:SendProtocal(29025, protocal)
end

function ArenaManyPeopleController:handle29025(data)
    self.model:updateMyRank(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MAIN_RANK_EVENT,data)    
end

--购买挑战次数
function ArenaManyPeopleController:sender29030()
    local protocal = {}
    self:SendProtocal(29030, protocal)
end

function ArenaManyPeopleController:handle29030(data)
    if data.code == 1 then
        if self.model:getIsTouchFight() == true then
            self.model:setIsTouchFight(false)
            self:sender29016()
        end
    end
    self.model:updateBuyNum(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_UPDATE_BUYNUM_EVENT,data)    
end

--战报
function ArenaManyPeopleController:sender29026()
    local protocal = {}
    self:SendProtocal(29026, protocal)
end

function ArenaManyPeopleController:handle29026(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MIAIN_REPORT_EVENT, data)
end

--个人战报
function ArenaManyPeopleController:sender29027(id)
    local protocal = {}
    protocal.id  = id
    self:SendProtocal(29027, protocal)
end

function ArenaManyPeopleController:handle29027(data)
    GlobalEvent:getInstance():Fire(ArenaManyPeopleEvent.ARENAMANYPOEPLE_SINGLE_REPORT_EVENT, data)
end

--请求日志红点情况
function ArenaManyPeopleController:sender29028()
    local protocal = {}
    self:SendProtocal(29028, protocal)
end

function ArenaManyPeopleController:handle29028(data)
    if data and data.point == 1 then
        self.model:setIsReportRedpoint(true)
    end
end


--打开多人竞技场主界面
function ArenaManyPeopleController:openArenaManyPeopleMainWindow( status )
    if status == true then
        self.is_click_amp = true
        if self.arenamanypeople_main_window == nil then
            self.arenamanypeople_main_window = ArenaManyPeopleMainWindow.New()
        end
        if self.arenamanypeople_main_window:isOpen() == false then
            self.arenamanypeople_main_window:open()
        end
    else
        if self.arenamanypeople_main_window then
            self.arenamanypeople_main_window:close()
            self.arenamanypeople_main_window = nil
        end
    end
end

--组队大厅
function ArenaManyPeopleController:openArenaManyPeopleHallPanel( status, setting )
    if status == true then
        if self.arenamanypeople_hall_panel == nil then
            self.arenamanypeople_hall_panel = ArenaManyPeopleHallPanel.New()
        end
        if self.arenamanypeople_hall_panel:isOpen() == false then
            self.arenamanypeople_hall_panel:open(setting)
        end
    else
        if self.arenamanypeople_hall_panel then
            self.arenamanypeople_hall_panel:close()
            self.arenamanypeople_hall_panel = nil
        end
    end
end


--打开挑战界面匹配界面
function ArenaManyPeopleController:openArenaManyPeopleMatchingWindow( status, setting )
    if status == true then
        if self.arenamanypeople_match_win == nil then
            self.arenamanypeople_match_win = ArenaManyPeopleMatchingWindow.New()
        end
        if self.arenamanypeople_match_win:isOpen() == false then
            self.arenamanypeople_match_win:open(setting)
        end
    else
        if self.arenamanypeople_match_win then
            self.arenamanypeople_match_win:close()
            self.arenamanypeople_match_win = nil
        end
    end
end

--打结算界面
function ArenaManyPeopleController:openArenaManyPeopleFightResultPanel( status, data )
    if status == true then
        if self.arenamanypeople_fight_result_panel == nil then
            self.arenamanypeople_fight_result_panel = ArenaManyPeopleFightResultPanel.New()
        end
        if self.arenamanypeople_fight_result_panel:isOpen() == false then
            self.arenamanypeople_fight_result_panel:open(data)
        end
    else
        if self.arenamanypeople_fight_result_panel then
            self.arenamanypeople_fight_result_panel:close()
            self.arenamanypeople_fight_result_panel = nil
        end
    end
end

--打开录像记录界面
function ArenaManyPeopleController:openArenaManyPeopleFightRecordPanel( status )
    if status == true then
        if self.arenamanypeople_fight_record_panel == nil then
            self.arenamanypeople_fight_record_panel = ArenaManyPeopleFightRecordPanel.New()
        end
        if self.arenamanypeople_fight_record_panel:isOpen() == false then
            self.arenamanypeople_fight_record_panel:open()
        end
    else
        if self.arenamanypeople_fight_record_panel then
            self.arenamanypeople_fight_record_panel:close()
            self.arenamanypeople_fight_record_panel = nil
        end
    end
end
--打开录像记录界面
function ArenaManyPeopleController:openArenaManyPeopleFightVedioPanel( status, setting )
    if status == true then
        if self.arenamanypeople_fight_vedio_panel == nil then
            self.arenamanypeople_fight_vedio_panel = ArenaManyPeopleFightVedioPanel.New()
        end
        if self.arenamanypeople_fight_vedio_panel:isOpen() == false then
            self.arenamanypeople_fight_vedio_panel:open(setting)
        end
    else
        if self.arenamanypeople_fight_vedio_panel then
            self.arenamanypeople_fight_vedio_panel:close()
            self.arenamanypeople_fight_vedio_panel = nil
        end
    end
end

--打开奖励界面
function ArenaManyPeopleController:openArenaManyPeopleBoxRewardPanel( status )
    if status == true then
        if self.arenamanypeople_box_reward_panel == nil then
            self.arenamanypeople_box_reward_panel = ArenaManyPeopleBoxRewardPanel.New()
        end
        if self.arenamanypeople_box_reward_panel:isOpen() == false then
            self.arenamanypeople_box_reward_panel:open()
        end
    else
        if self.arenamanypeople_box_reward_panel then
            self.arenamanypeople_box_reward_panel:close()
            self.arenamanypeople_box_reward_panel = nil
        end
    end
end
--打开排行界面
function ArenaManyPeopleController:openArenaManyPeopleRankWindow( status, setting )
    if status == true then
        if self.arenamanypeople_rank_reward_panel == nil then
            self.arenamanypeople_rank_reward_panel = ArenaManyPeopleRankWindow.New()
        end
        if self.arenamanypeople_rank_reward_panel:isOpen() == false then
            self.arenamanypeople_rank_reward_panel:open(setting)
        end
    else
        if self.arenamanypeople_rank_reward_panel then
            self.arenamanypeople_rank_reward_panel:close()
            self.arenamanypeople_rank_reward_panel = nil
        end
    end
end

--打开布阵界面
function ArenaManyPeopleController:openArenaManyPeopleFightTips( status )
    if status == true then
        if self.arenamanypeople_fight_tips == nil then
            self.arenamanypeople_fight_tips = ArenaManyPeopleFightTips.New()
        end
        if self.arenamanypeople_fight_tips:isOpen() == false then
            self.arenamanypeople_fight_tips:open()
        end
    else
        if self.arenamanypeople_fight_tips then
            self.arenamanypeople_fight_tips:close()
            self.arenamanypeople_fight_tips = nil
        end
    end
end



function ArenaManyPeopleController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end