-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼控制器
-- <br/>Create: 2018-08-15
-- --------------------------------------------------------------------
Endless_trailController = Endless_trailController or BaseClass(BaseController)

function Endless_trailController:config()
    self.model = Endless_trailModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.cache_buff_data = nil
end

function Endless_trailController:getModel()
    return self.model
end

function Endless_trailController:registerEvents()
    --[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                self:requestInitProtocal(true)

                if self.role_assets_event == nil then
                    self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "lev" then
                            self:requestInitProtocal()
                        elseif key == "open_day" then
                            self:requestInitProtocal()
                        end
                    end)
                end 
            end
        end)
    end --]]

    if self.battle_enter_event == nil then
        self.battle_enter_event = GlobalEvent:getInstance():Bind(SceneEvent.ENTER_FIGHT, function(combat_type)
            if combat_type == BattleConst.Fight_Type.Endless then
                self:openEndlessBattleView(true)
            end
        end)
    end
    -- 如果是竞技场退出战斗的话，并且也是存在当前请求打开竞技场面板的情况下，则打开竞技场面板
    if self.battle_exit_event == nil then
        self.battle_exit_event = GlobalEvent:getInstance():Bind(SceneEvent.EXIT_FIGHT, function(combat_type)
            self:openEndlessBattleView(false)
            if combat_type == BattleConst.Fight_Type.Endless then
                self:openEndlessBuffView(false)
            end
        end)
    end 
end

--==============================--
--desc:
--time:2018-09-06 04:15:42
--@return 
--==============================--
function Endless_trailController:checkIsOpen(show_desc)
    local open_config = Config.EndlessData.data_const.open_lev
    if open_config == nil then return false end
    local is_open = MainuiController:getInstance():checkIsOpenByActivate(open_config.val)
    if show_desc == true and is_open == false then
        message(open_config.desc)
    end
    return is_open
end

function Endless_trailController:checkNewEndLessIsOpen(show_desc)
    local open_config = Config.EndlessData.data_const.endless_new_limit
    if open_config == nil then return false end

    local open_lev = Config.EndlessData.data_const.endless_new_limit_lev
    if open_lev == nil then return false end
    
    local is_open = false
    local base_data = self.model:getEndlessData()
    local rolevo = RoleController:getInstance():getRoleVo()
    if base_data and rolevo and base_data.max_round >= open_config.val and rolevo.lev >= open_lev.val then
        is_open = true
    end
    
    if show_desc == true and is_open == false then
        message(open_config.desc)
    end
    return is_open
end


function Endless_trailController:checkNewEndLessIsShow()
    local open_lev = Config.EndlessData.data_const.endless_new_show_limit
    if open_lev == nil then return false end
    
    local is_show = false
    local rolevo = RoleController:getInstance():getRoleVo()
    if rolevo and rolevo.lev >= open_lev.val then
        is_show = true
    end

    return is_show
end

function Endless_trailController:requestInitProtocal(force)
    local is_open = self:checkIsOpen()
    if is_open == true then
        self:send23900()
        self:send23903()
        self:send23906()
        if self.role_assets_event then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end

    end
end

function Endless_trailController:registerProtocals()
    self:RegisterProtocal(23900, "handle23900") -- 基础信息
    self:RegisterProtocal(23901, "handle23901") -- 挑战无尽
    self:RegisterProtocal(23902, "handle23902") --战斗界面信息
    self:RegisterProtocal(23903, "handle23903") --首通奖励展示
    self:RegisterProtocal(23904, "handle23904") --领取奖励通关奖励
    self:RegisterProtocal(23905, "handle23905") --已派出伙伴信息
    self:RegisterProtocal(23906, "handle23906") --领取奖励通关奖励
    self:RegisterProtocal(23907, "handle23907") --可雇佣伙伴列表信息
    self:RegisterProtocal(23908, "handle23908") --派出伙伴
    self:RegisterProtocal(23909, "handle23909") --雇佣伙伴
    self:RegisterProtocal(23910, "handle23910") --Buff列表
    self:RegisterProtocal(23911, "handle23911") --选择Buff
    self:RegisterProtocal(23912, "handle23912") --是否有可领取的首通奖励
    self:RegisterProtocal(23913, "handle23913") --查看排行榜
end

--协议相关
function Endless_trailController:send23900()
    local protocol = {}
    self:SendProtocal(23900, protocol)
end

function Endless_trailController:handle23900(data)
    if data then
        self.model:setEndlessData(data)
        if NEEDCHANGEENTERSTATUS == 5 and not self.first_enter then
            self.first_enter  = true
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Endless)
        end
    end
end

function Endless_trailController:send23901(type,formation_type, pos_info, hallows_id)
    local protocol = {}
    protocol.type = type
    protocol.formation_type = formation_type
    protocol.pos_info = pos_info
    protocol.hallows_id = hallows_id
    self:SendProtocal(23901,protocol)
end

function Endless_trailController:handle23901(data)
    message(data.msg)
end

function Endless_trailController:send23902()
    local protocol = {}
    self:SendProtocal(23902,protocol)
end

function Endless_trailController:handle23902(data)
    self.model:setEndlessBattleData(data)
end

function Endless_trailController:send23903(type)
    local protocol = {}
    protocol.type = type
    self:SendProtocal(23903, protocol)
end

function Endless_trailController:handle23903(data)
    if data then
        self.model:setFirstData(data)
    end
end


function Endless_trailController:send23904(id,type)
    local protocol = {}
    protocol.id = id
    protocol.type = type
    self:SendProtocal(23904, protocol)
end

function Endless_trailController:handle23904(data)
    message(data.msg)
    if data.code == 1 then
        self:openEndlessRewardTips(false)
    end
end


function Endless_trailController:send23905()
    local protocol = {}
    self:SendProtocal(23905, protocol)
end

function Endless_trailController:handle23905(data)
    if data then
        self.model:setSendPartnerData(data)
    end
end


function Endless_trailController:send23906()
    local protocol = {}
    self:SendProtocal(23906, protocol)
end

function Endless_trailController:handle23906(data)
    if data then
        self.model:setHasHirePartnerData(data)
    end
end


function Endless_trailController:send23907()
    local protocol = {}
    self:SendProtocal(23907, protocol)
end

function Endless_trailController:handle23907(data)
    if data then
        self.model:setHirePartnerData(data)
    end
end

function Endless_trailController:send23908(id)
    local protocol = {}
    protocol.id = id
    self:SendProtocal(23908, protocol)
end

function Endless_trailController:handle23908(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(Endless_trailEvent.UPDATA_SENDPARTNER_SUCESS_DATA ,data)
    end
end


function Endless_trailController:send23909(rid,srv_id,id,flag)
    local protocol = {}
    protocol.id = id
    protocol.rid = rid
    protocol.srv_id = srv_id
    protocol.flag = flag
    self:SendProtocal(23909, protocol)
end

function Endless_trailController:handle23909(data)
    message(data.msg)
end

function Endless_trailController:send23910()
    local protocol = {}
    self:SendProtocal(23910, protocol)
end

function Endless_trailController:handle23910(data)
    if data then
        local is_open = false
        if  MainuiController:getInstance():checkIsInEndlessUIFight() then
            self:openEndlessBuffView(true,data)
            is_open = true
        end
        if not is_open then
            self.cache_buff_data = data
        end
    end
end

function Endless_trailController:send23911(buff_id)
    local protocol = {}
    protocol.buff_id = buff_id
    self:SendProtocal(23911, protocol)
end

function Endless_trailController:handle23911(data)
    message(data.msg)
    if data.code == 1 then
        self:openEndlessBuffView(false)

        -- 成功选择一个buff之后,也要移除掉提示
		PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Endless_trail)
    end
end

--是否有可领取的首通奖励
function Endless_trailController:send23912()
    local protocol = {}
    self:SendProtocal(23912, protocol)
end

function Endless_trailController:handle23912(data)
    self.model:setFirstStatus(data)
end

--查看排行榜
function Endless_trailController:send23913(type)
    local protocol = {}
    protocol.type = type
    if self.SendProtocal then
        self:SendProtocal(23913, protocol)
    end
end

function Endless_trailController:handle23913(data)
    self.model:updateRankInfo(data)
end

--请求排行榜数据
function Endless_trailController:sendRankInfo()
    delayOnce(function()
        local data = self.model:getEndlessData()
        if data then
            self:send23913(data.type)
        end 
    end,5)
end

--打开界面相关--
--[[
    @desc: 
    author:{author}
    time:2018-08-16 09:35:31
    --@status: 打开主界面
    @return:
]]
function Endless_trailController:openEndlessMainWindow(status)
    if status == true then
        if self:checkIsOpen(true) == false then
            return
        end
        if not self.endless_main_window then
            self.endless_main_window = EndlessTrailMainWindow.New()
        end
        if self.endless_main_window and self.endless_main_window:isOpen() == false then
            self.endless_main_window:open()
        end
    else 
        if self.endless_main_window then 
            self.endless_main_window:close()
            self.endless_main_window = nil
        end
    end
end

--[[
    @desc: 战斗界面
    author:{author}
    time:2018-08-16 11:35:45
    --@args: 
    @return:
]]
function Endless_trailController:openEndlessBattleView(status)
    if status == true then
        if not self.endless_battle_view then
            self.endless_battle_view = EndlessTrailBattleView.new()
        end
        if self.endless_battle_view and self.endless_battle_view:isOpen() == false then
            self.endless_battle_view:open()

            if self.cache_buff_data then --判断是否存在协议
                self:openEndlessBuffView(true, self.cache_buff_data)
                self.cache_buff_data = nil
            end
        end
    else 
        if self.endless_battle_view then 
            self.endless_battle_view:close()
            self.endless_battle_view = nil
        end
    end
end

--[[
    @desc: buff界面
    author:{author}
    time:2018-08-16 14:08:54
    @return:
]]
function Endless_trailController:openEndlessBuffView(status,data,is_force)
    if status == true then
        if not self.endless_buff_window then
            self.endless_buff_window = EndlessTrailBuffView.New()
        end
        data = data or self.cache_buff_data -- 可能在外面就调用这个时候直接用缓存的buff吧
        if data == nil then return end
        if self.endless_buff_window and self.endless_buff_window:isOpen() == false then
            self.endless_buff_window:open(data)
        end
        -- 移除掉缓存的,因为可能在外面点击去.这个时候不移除掉再进入战斗的时候会又一次打开
        self.cache_buff_data = nil
    else
        if self.endless_buff_window then
            if is_force then -- 引导中强制关闭界面，这时重新取出buff数据缓存
                self.cache_buff_data = self.endless_buff_window:getData()
            end
            self.endless_buff_window:close()
            self.endless_buff_window = nil
        end
    end
end


--[[
    @desc: 排行榜界面
    author:{author}
    time:2018-08-16 16:04:40
    @return:
]]
function Endless_trailController:openEndlessRankView(status,type,endless_type)
    if status == true then
        if not self.endless_rank_window then
            self.endless_rank_window = EndlessRankWindow.New(endless_type)
        end
        if self.endless_rank_window and self.endless_rank_window:isOpen() == false then
            self.endless_rank_window:open()
        end
    else
        if self.endless_rank_window then
            self.endless_rank_window:close()
            self.endless_rank_window = nil
        end
    end
end

--[[
    @desc: 支援界面
    author:{author}
    time:2018-08-16 16:24:00
    @return:
]]
function Endless_trailController:openEndlessFriendHelpView(status)
    if status == true then
        if not self.endless_friendhelp_window then
            self.endless_friendhelp_window = EndlessFriendHelpWindow.New()
        end
        if self.endless_friendhelp_window and self.endless_friendhelp_window:isOpen() == false then
            self.endless_friendhelp_window:open()
        end
    else
        if self.endless_friendhelp_window then
            self.endless_friendhelp_window:close()
            self.endless_friendhelp_window = nil
        end
    end
end


--[[
    @desc: 奖励详情一览
    author:{author}
    time:2018-08-17 15:41:56
    @return:
]]

function Endless_trailController:openEndlessRewardWindow(status,type)
    if status == true then
        if not self.endless_reward_window then
            self.endless_reward_window = EndlessRewardWindow.New(type)
        end
        if self.endless_reward_window and self.endless_reward_window:isOpen() == false then
            self.endless_reward_window:open()
        end
    else
        if self.endless_reward_window then
            self.endless_reward_window:close()
            self.endless_reward_window = nil
        end
    end
end


--[[
    @desc: 战斗领取
    author:{author}
    time:2018-08-17 15:41:56
    @return:
]]

function Endless_trailController:openEndlessRewardTips(status,id)
    if status == true then
        if not self.endless_reward_tips then
            self.endless_reward_tips = EndlessAwardsTips.New()
        end
        if self.endless_reward_tips and self.endless_reward_tips:isOpen() == false then
            self.endless_reward_tips:open(id)
        end
    else
        if self.endless_reward_tips then
            self.endless_reward_tips:close()
            self.endless_reward_tips = nil
        end
    end
end

--[[
    下一玩法开启提示
]]
function Endless_trailController:openEndlessOpenTips(status)
    if status == true then
        if not self.endless_open_tips then
            self.endless_open_tips = EndlessOpenTips.New()
        end
        if self.endless_open_tips and self.endless_open_tips:isOpen() == false then
            self.endless_open_tips:open()
        end
    else
        if self.endless_open_tips then
            self.endless_open_tips:close()
            self.endless_open_tips = nil
        end
    end
end


function Endless_trailController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
