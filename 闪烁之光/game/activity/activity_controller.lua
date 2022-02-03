-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-09-01
-- --------------------------------------------------------------------
ActivityController = ActivityController or BaseClass(BaseController)

function ActivityController:config()
    self.model = ActivityModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self._doubleTime = false
    self._firstComein = true
end

function ActivityController:getModel()
    return self.model
end

function ActivityController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self._roleVo = RoleController:getInstance():getRoleVo()
            if self._roleVo ~= nil then
                if self.role_assets_event == nil then
                    self.role_assets_event = self._roleVo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "lev" then
                            self:requestInitProtocal()
                        end
                    end)
                end 
            end
        end)
    end

    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:requestInitProtocal()
        end)
    end
end
function ActivityController:requestInitProtocal()
    --暂时没用到
    local config = Config.DailyplayData.data_limitactivity
    if config[2].is_open == 1 and self._roleVo then
        if self._roleVo.lev >= config[2].activate[1][2] then
            self:SendProtocal(21322, {})
        end
    end
end
function ActivityController:registerProtocals()
    self:RegisterProtocal(21322, "handle21322")   -- 公会副本双倍时间
end
function ActivityController:handle21322(data)
    if not data then return end
    if data.code == 0 then
        self._doubleTime = false
    elseif data.code == 1 then
        self._doubleTime = true
    end
    self._firstComein = self._doubleTime

    local limitRed = false
    local base_info = GuildbossController:getInstance():getModel():getBaseInfo()
    if self._doubleTime == true then
        if base_info and base_info.count then
            if base_info.count > 0 then
                limitRed = true
            end
        end
    end
    GlobalEvent:getInstance():Fire(GuildbossEvent.BossActivityDoubleTime, self._doubleTime)
end

function ActivityController:setFirstComeGuild(status)
    self._firstComein = status
end
function ActivityController:getFirstComeGuild()
    return self._firstComein
end

function ActivityController:getBossActivityDoubleTime()
    return self._doubleTime
end
function ActivityController:openActivityView(bool)
    if bool == true then 
        if not self.activityView then
            self.activityView = ActivityWindow.New()
        end
        self.activityView:open()
    else
        if self.activityView then 
            self.activityView:close()
            self.activityView = nil
        end
    end
end

--- 引导使用
function  ActivityController:getActivityRoot()
    if self.activityView then
        return self.activityView.root_wnd
    end
end

--进入活动名称(1:萌兽寻宝 2:公会Boss狂欢 3:首席争霸 4:众神战场 5:公会战 6:冠军赛)
function ActivityController:switchLimitActivityView(_type)
	if _type == ActivityConst.limit_index.escort then
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Escort)
	elseif _type == ActivityConst.limit_index.union then
        if self:getBossActivityDoubleTime() == false then
            message(TI18N("当前不处于活动时段，请在活动开启后再来哦"))
        else
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildDun)    
        end
	elseif  _type == ActivityConst.limit_index.fightFirst then

	elseif _type == ActivityConst.limit_index.allGod then
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Godbattle)
    elseif _type == ActivityConst.limit_index.guildwar then
        local is_open = GuildwarController:getInstance():checkIsCanOpenGuildWarWindow()
        if is_open == true then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildWar)
        end
    elseif _type == ActivityConst.limit_index.champion then
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.champion_call)
	elseif _type == ActivityConst.limit_index.ladder then
        local is_open = LadderController:getInstance():getModel():getLadderOpenStatus()
        if is_open == true then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LadderWar)
        end
    end
end

-- 通用报名面板
function ActivityController:openSignView(value, id, data)
    if value == false then
        if self.activity_sign_view ~= nil then
            self.activity_sign_view:close()
            self.activity_sign_view = nil
        end
    else
        if self.activity_sign_view == nil then
            self.activity_sign_view = ActivitySignWindow.New()
        end

        if self.activity_sign_view and self.activity_sign_view:isOpen() == false then
            self.activity_sign_view:open(id, data)
        end
    end
end

function ActivityController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
