-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-10-08
-- --------------------------------------------------------------------
GuildwarController = GuildwarController or BaseClass(BaseController)

function GuildwarController:config()
    self.model = GuildwarModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildwarController:getModel()
    return self.model
end

function GuildwarController:registerEvents()
	if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                --self:requestInitProtocal()
                if self.role_assets_event == nil then
                    self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "guild_lev" then
                            if value == 0 then -- 退出联盟,清掉数据
                                self.model:config()
                            end
                            self:requestInitProtocal()
                        end
                    end)
                end
            end
        end)
    end

    -- 断线重连的时候
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self.model:clearEnemyCacheData()
        end)
    end
end

-- 登陆时、联盟等级变化时请求
function GuildwarController:requestInitProtocal( )
	self:reqestGuildWarStatus()
    self:requestAwardBoxData() -- 公会宝箱红点用到
end

---------------------@ c2s
-- 请求联盟战详细数据
function GuildwarController:requestGuildWarData(  )
    self:SendProtocal(24200, {})
end

-- 请求敌方单个据点数据
function GuildwarController:requestEnemyPositionData( pos )
    if not pos then return end
    local protocal = {}
    protocal.pos = pos
    self:SendProtocal(24201, protocal)
end

-- 发起战斗
function GuildwarController:requestGuildWarFighting( pos, hp, flag )
    if not pos then return end
    local protocal = {}
    protocal.pos = pos
    protocal.hp = hp
    protocal.flag = flag
    self:SendProtocal(24202, protocal)
end

-- 请求联盟战状态
function GuildwarController:reqestGuildWarStatus( )
    self:SendProtocal(24204, {})
end

-- 请求对战列表数据
function GuildwarController:requestGuildWarBattleList(  )
    self:SendProtocal(24205, {})
end

-- 请求本方联盟战据点数据
function GuildwarController:requestMyGuildPositionData(  )
    self:SendProtocal(24208, {})
end

-- 请求据点防守记录
function GuildwarController:requestPositionDefendData( g_id1, g_sid1, pos )
    local protocal = {}
    protocal.g_id1 = g_id1
    protocal.g_sid1 = g_sid1
    protocal.pos = pos
    self:SendProtocal(24209, protocal)
end

-- 请求战场日志
function GuildwarController:requestBattleLogData(  )
    self:SendProtocal(24212, {})
end

-- 请求联盟战详细排名数据
function GuildwarController:requestGuildWarRankData(  )
    self:SendProtocal(24213, {})
end

-- 请求宝箱数据
function GuildwarController:requestAwardBoxData(  )
    self:SendProtocal(24220, {})
end

-- 请求领取宝箱数据
function GuildwarController:requestGetBoxAward( order )
    local protocal = {}
    protocal.order = order
    self:SendProtocal(24221, protocal)
end

---------------------@ s2c

function GuildwarController:registerProtocals()
    self:RegisterProtocal(24200, "handle24200")     -- 联盟战详细信息
    self:RegisterProtocal(24201, "handle24201")     -- 敌方单个据点信息
    self:RegisterProtocal(24202, "handle24202")     -- 发起战斗
    self:RegisterProtocal(24203, "handle24203")     -- 战斗结果
    self:RegisterProtocal(24204, "handle24204")     -- 联盟战的状态
    self:RegisterProtocal(24205, "handle24205")     -- 对战列表
    self:RegisterProtocal(24206, "handle24206")     -- 据点数据更新(只更新有变化的)
    self:RegisterProtocal(24207, "handle24207")     -- 联盟战基础数据更新（星数、buff等）
    self:RegisterProtocal(24208, "handle24208")     -- 本方联盟战据点数据
    self:RegisterProtocal(24209, "handle24209")     -- 防守记录
    self:RegisterProtocal(24210, "handle24210")     -- 有新的日志产生
    self:RegisterProtocal(24212, "handle24212")     -- 战场日志
    self:RegisterProtocal(24213, "handle24213")     -- 联盟战详细排名
    self:RegisterProtocal(24214, "handle24214")     -- 联盟战结果
    self:RegisterProtocal(24220, "handle24220")     -- 联盟战宝箱数据
    self:RegisterProtocal(24221, "handle24221")     -- 领取联盟战宝箱
    self:RegisterProtocal(24223, "handle24223")     -- 更新单个联盟战宝箱
end

-- 联盟战数据
function GuildwarController:handle24200( data )
    data = data or {}
    if data.count then -- 已挑战次数
        self.model:setGuildWarChallengeCount(data.count)
    end
    if data.result then
        self.model:setGuildWarResult(data.result)
    end
    if data.ranks then
        self.model:setGuildWarTopThreeRank(data.ranks)
    end

    -- 我方联盟基础信息
    local myBaseInfo = {}
    myBaseInfo.gname = data.gname1
    myBaseInfo.hp = data.hp1
    myBaseInfo.buff_lev = data.buff_lev1
    self.model:setMyGuildWarBaseInfo(myBaseInfo)

    -- 敌方联盟数据
    self.model:setEnemyGuildWarData(data)

    GlobalEvent:getInstance():Fire(GuildwarEvent.GuildWarEnemyPositionDataInitEvent)
end

-- 敌方单个据点数据
function GuildwarController:handle24201( data )
    if data and self.attk_position_window then
        self.attk_position_window:setData(data)
    end
end

-- 发起战斗
function GuildwarController:handle24202( data )
    message(data.msg)
    if data.code == TRUE then
        self.model:setGuildWarChallengeCount(data.count)
        GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildwarChallengeCountEvent)
        self:openAttkPositionWindow(false)
        self:openAttkLookWindow(false)
    end
end

-- 挑战据点的战斗结果
function GuildwarController:handle24203( data )
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.GuildWar, data)
end

-- 联盟战状态
function GuildwarController:handle24204( data )
    if data then
        self.model:setGuildWarStatus(data)
        GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildWarStatusEvent, data.status, data.flag)
    end
end

-- 联盟战对阵列表
function GuildwarController:handle24205( data )
    if data and self.battle_list_window then
        self.battle_list_window:setData(data)
    end
end

-- 据点数据更新(本方与对方都走这里，变量更)
function GuildwarController:handle24206( data )
    if data then
        if data.flag and data.flag == TRUE then
            self.model:updateMyGuildWarPositionData(data.defense)
        else
            self.model:updateEnemyGuildWarPositionData(data.defense)
        end
    end
end

-- 联盟战基础数据更新(星数、buff等)
function GuildwarController:handle24207( data )
    if data then
        if data.result then
            self.model:setGuildWarResult(data.result)
        end
        if data.hp and data.buff_lev then
            local myBaseInfo = {}
            myBaseInfo.hp = data.hp
            myBaseInfo.buff_lev = data.buff_lev
            self.model:updateMyGuildWarBaseInfo(myBaseInfo)
        end
        if data.hp2 then
            self.model:updateEnemyGuildWarBaseInfo(data.hp2)
        end
        if data.ranks then
            self.model:setGuildWarTopThreeRank(data.ranks)
        end
        GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildWarBaseInfoEvent)
    end
end

-- 本方据点数据
function GuildwarController:handle24208( data )
    if data then
        self.model:setMyGuildWarPositionData(data.defense)
        self.model:setAvgPower(data.avg_power)
        GlobalEvent:getInstance():Fire(GuildwarEvent.GetGuildWarMyPositionDataEvent)
    end
end

-- 防守记录
function GuildwarController:handle24209( data )
    if data and self.defend_look_window then
        self.defend_look_window:setData(data)
    end
end

-- 有新的日志产生
function GuildwarController:handle24210(  )
    self.model:updateGuildWarRedStatus(GuildConst.red_index.guildwar_log, true, true)
end

-- 战场日志
function GuildwarController:handle24212( data )
    if self.battle_log_window and data then
        self.battle_log_window:setData(data.guild_war_log)
    end
end

-- 联盟战详细排名
function GuildwarController:handle24213( data )
    if data then
        GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildWarRankDataEvent, data.ranks)
    end
end

-- 联盟战结果
function GuildwarController:handle24214( data )
    if data and data.result then
        self.model:setGuildWarResult(data.result)
        GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildWarBaseInfoEvent)
    end
end

-- 联盟战宝箱数据
function GuildwarController:handle24220( data )
    if data then
        self.model:setGuildWarBoxData(data)
        GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateGuildWarBoxDataEvent, data)
    end
end

-- 领取宝箱
function GuildwarController:handle24221( data )
    message(data.msg) 
end

-- 更新单个宝箱数据
function GuildwarController:handle24223( data )
    if data then
        self.model:updateGuildWarBoxData(data)
        -- 判断一下是否为玩家自己领取了宝箱，更新界面领取状态
        if self.role_vo and data.rid == self.role_vo.rid and data.sid == self.role_vo.srv_id then
            GlobalEvent:getInstance():Fire(GuildwarEvent.UpdateMyAwardBoxEvent)
        end
    end
end

-------------------------@ 界面

-- 打开联盟战主界面
function GuildwarController:openMainWindow( status )
	if status == false then
        if self.main_window then
            self.main_window:close()
            self.main_window = nil
        end
    else
        if(FILTER_CHARGE == true) then
            message(TI18N("功能暂未开放，敬请期待"))
            return;
        end

        if self.role_vo == nil or self.role_vo.gid == 0 then 
            message(TI18N("您当前未加入任何公会，加入公会后才能参与该玩法！"))
            return 
        end
        local config = Config.GuildWarData.data_const.limit_lev
        if config == nil then 
            message(TI18N("公会战数据异常!"))
            return
        end
        if self.role_vo.guild_lev < config.val then
            message(TI18N("您所在的公会未达参赛条件，不能参与哦，请努力提高公会等级！"))
            return 
        end
        if self.main_window == nil then
            self.main_window = GuildwarMainWindow.New()
        end
        if self.main_window:isOpen() == false then
            self.main_window:open()
        end
    end
end

-- 打开进攻一览
function GuildwarController:openAttkLookWindow( status )
    if status == false then
        if self.attk_look_window then
            self.attk_look_window:close()
            self.attk_look_window = nil
        end
    else
        if self.attk_look_window == nil then
            self.attk_look_window = GuildwarAttkLookWindow.New()
        end
        if self.attk_look_window:isOpen() == false then
            self.attk_look_window:open()
        end
    end
end

-- 打开防守记录
function GuildwarController:openDefendLookWindow( status, g_id, g_sid, pos )
    if status == false then
        if self.defend_look_window then
            self.defend_look_window:close()
            self.defend_look_window = nil
        end
    else
        if self.defend_look_window == nil then
            self.defend_look_window = GuildwarDefendLookWindow.New()
        end
        if self.defend_look_window:isOpen() == false then
            self.defend_look_window:open(g_id, g_sid, pos)
        end
    end
end

-- 打开对阵列表
function GuildwarController:openBattleListWindow( status )
    if status == false then
        if self.battle_list_window then
            self.battle_list_window:close()
            self.battle_list_window = nil
        end
    else
        if self.battle_list_window == nil then
            self.battle_list_window = GuildwarBattleListWindow.New()
        end
        if self.battle_list_window:isOpen() == false then
            self.battle_list_window:open()
        end
    end
end

-- 打开战场日志
function GuildwarController:openBattleLogWindow( status )
    if status == false then
        if self.battle_log_window then
            self.battle_log_window:close()
            self.battle_log_window = nil
        end
    else
        if self.battle_log_window == nil then
            self.battle_log_window = GuildwarBattleLogWindow.New()
        end
        if self.battle_log_window:isOpen() == false then
            self.battle_log_window:open()
        end
    end
end

-- 打开战绩奖励
function GuildwarController:openGuildWarAwardWindow( status )
    if status == false then
        if self.guildwar_award_window then
            self.guildwar_award_window:close()
            self.guildwar_award_window = nil
        end
    else
        if self.guildwar_award_window == nil then
            self.guildwar_award_window = GuildwarAwardWindow.New()
        end
        if self.guildwar_award_window:isOpen() == false then
            self.guildwar_award_window:open()
        end
    end
end

-- 打开挑战据点界面
function GuildwarController:openAttkPositionWindow( status, pos )
    if status == false then
        if self.attk_position_window then
            self.attk_position_window:close()
            self.attk_position_window = nil
        end
    else
        if self.attk_position_window == nil then
            self.attk_position_window = GuildwarAttkPositionWindow.New()
        end
        if self.attk_position_window:isOpen() == false then
            self.attk_position_window:open(pos)
        end
    end
end

-- 打开战绩排行榜界面
function GuildwarController:openGuildWarRankView( status )
    if status == false then
        if self.guildwar_rank_window then
            self.guildwar_rank_window:close()
            self.guildwar_rank_window = nil
        end
    else
        if self.guildwar_rank_window == nil then
            self.guildwar_rank_window = GuildWarRankWindow.New()
        end
        if self.guildwar_rank_window:isOpen() == false then
            self.guildwar_rank_window:open()
        end
    end
end

-- 判断是否开启联盟战
function GuildwarController:checkIsCanOpenGuildWarWindow(not_tips)
    local isOpen = true
    local limit_lev = Config.GuildWarData.data_const.limit_lev.val
    local config_day = Config.GuildWarData.data_const.limit_open_time -- 开服天数限制
    local role_vo = RoleController:getInstance():getRoleVo()
    local open_srv_day = RoleController:getInstance():getModel():getOpenSrvDay()
    if not role_vo:isHasGuild() then
        if not not_tips then
            message(TI18N("您当前未加入任何公会，加入公会后才能参与该玩法！"))
        end
        isOpen = false
    elseif role_vo.guild_lev < limit_lev then
        if not not_tips then
            message(TI18N("您所在的公会未达参赛条件，不能参与哦，请努力提高公会等级！"))
        end
        isOpen = false
    elseif open_srv_day <= config_day.val then
        if not not_tips then
            message(config_day.desc)
        end
        isOpen = false
    end
    return isOpen , limit_lev
end

-- 打开公会战宝箱奖励
function GuildwarController:openAwardBoxWindow( status )
    if status == true then
        if not self.award_box_win then
            self.award_box_win = GuildwarAwardBoxWindow.New()
        end
        if self.award_box_win:isOpen() == false then
            self.award_box_win:open()
        end
    else
        if self.award_box_win then
            self.award_box_win:close()
            self.award_box_win = nil
        end
    end
end

-- 打开宝箱奖励预览
function GuildwarController:openAwardBoxPreview( status )
    if status == true then
        if not self.award_box_preview then
            self.award_box_preview = GuildwarAwardBoxPreview.New()
        end
        if self.award_box_preview:isOpen() == false then
            self.award_box_preview:open()
        end
    else
        if self.award_box_preview then
            self.award_box_preview:close()
            self.award_box_preview = nil
        end
    end
end

function GuildwarController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end