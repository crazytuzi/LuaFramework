-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英段位赛 策划 星宇 后端 
-- <br/>Create: 2019-02-14
-- --------------------------------------------------------------------
ElitematchController = ElitematchController or BaseClass(BaseController)

function ElitematchController:config()
    self.model = ElitematchModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ElitematchController:getModel()
    return self.model
end
  
function ElitematchController:registerEvents()
    -- if not self.world_lev_event then 
    --     self.world_lev_event = GlobalEvent:getInstance():Bind(RoleEvent.WORLD_LEV,function()
    --         GlobalEvent:getInstance():UnBind(self.world_lev_event)
            
    --     end)
    -- end
end

--登陆后 在 获取到 角色信息 世界等级信息 和 英雄信息后调用此方法
function ElitematchController:loginSendProtoInfo()
    local is_open, limit_type = self.model:checkElitematchIsOpen(true)
    if is_open then
        self.is_check_redpoint = true
        self.model:setUpdateRedPoint(false)
        self:sender24905()
        self:sender24900()
    else
        if limit_type == 1 then --等级不足
            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                if self.role_lev_event == nil then
                    self.role_lev_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                        if key == "lev" then
                            local is_open = self.model:checkElitematchIsOpen(true)
                            if is_open then
                                self.is_check_redpoint = true
                                self.model:setUpdateRedPoint(false)
                                self:sender24905()
                                self:sender24900()
                                --移除事件
                                self.role_vo:UnBind(self.role_lev_event)
                            end
                        end
                    end)
                end
            end
        elseif limit_type == 2 then -- 世界等级不足
            self.world_lev_event2 = GlobalEvent:getInstance():Bind(RoleEvent.WORLD_LEV,function()
                local is_open = self.model:checkElitematchIsOpen(true)
                if is_open then
                    self.is_check_redpoint = true
                    self.model:setUpdateRedPoint(false)
                    self:sender24905()
                    self:sender24900()
                    --移除事件
                    GlobalEvent:getInstance():UnBind(self.world_lev_event2)
                end
            end)
        end
    end
end

function ElitematchController:registerProtocals()
    self:RegisterProtocal(24900, "handle24900")  --请求精英赛基础信息
    self:RegisterProtocal(24901, "handle24901")  --请求对手信息
    self:RegisterProtocal(24902, "handle24902")  --请求匹配对手
    self:RegisterProtocal(24903, "handle24903")  --挑战对手
    self:RegisterProtocal(24904, "handle24904")  --购买挑战次数

    self:RegisterProtocal(24905, "handle24905")  --"请求精英赛是否开战"

    self:RegisterProtocal(24906, "handle24906")  --战斗结算

    self:RegisterProtocal(24910, "handle24910")  --历史赛季赛区信息
    self:RegisterProtocal(24911, "handle24911")  --历史赛季

    self:RegisterProtocal(24915, "handle24915")  --领取奖励

    --阵法
    self:RegisterProtocal(24920, "handle24920")  --请求精英赛功能阵法
    self:RegisterProtocal(24921, "handle24921")  --设置精英赛功能阵法
    
    self:RegisterProtocal(24930, "handle24930")  --获取个人日志
    self:RegisterProtocal(24931, "handle24931")  --获取个人详情


    self:RegisterProtocal(24940, "handle24940")  --获取个人记录信息
    self:RegisterProtocal(24941, "handle24941")  --分享
    self:RegisterProtocal(24942, "handle24942")  --分享

    self:RegisterProtocal(24945, "handle24945")  --精英赛宣言
    self:RegisterProtocal(24946, "handle24946")  --保存精英赛宣言
    
    self:RegisterProtocal(24950, "handle24950")  --显示精英赛宣言结束
    
    self:RegisterProtocal(24952, "handle24952")  --段位赛战令基本信息
    self:RegisterProtocal(24953, "handle24953")  --段位赛战令一键领取等级礼包
    self:RegisterProtocal(24954, "handle24954")  --段位赛战令红点
    self:RegisterProtocal(24955, "handle24955")  --段位赛活动提示
    
end

--:请求精英赛基础信息
function ElitematchController:sender24900()
    local protocal = {}
    self:SendProtocal(24900, protocal)
end
function ElitematchController:handle24900(data)
    self.model:setSCData(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Get_Elite_Main_Info_Event, data)
    if self.is_check_redpoint then
        self:sender24920(1)
        self:sender24920(2) --王者赛需要弄多一个阵法类型
        self.is_check_redpoint = false
    end
    self.model:setSCDataBack24900()
end

--请求对手信息
function ElitematchController:sender24901()
    local protocal = {}
    self:SendProtocal(24901, protocal)
end

function ElitematchController:handle24901(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Get_Elite_Enemy_Info_Event, data)
    if next(data.rand_list) ~= nil then
        -- local cur_win = BaseView.winMap[#BaseView.winMap]
        if self.elitematch_matching_window then
            --说明在匹配界面在
        else
            if self.model.scdata.state == 0 then
                return
            end
            -- local match_type = ElitematchConst.MatchType.eNormalMatch
            -- if self.model.scdata.state == 3 and self.model.is_king then
            --     match_type = ElitematchConst.MatchType.eKingMatch
            -- end
            --如果不在匹配界面需要弹提示
            if self.model.scdata.is_skip == 0 then --玩家没有选择跳过战前布阵
                local msg = string.format(TI18N("超凡段位赛已经匹配到对手了,是否进入阵容调整？"))
                local call_back = function()
                    -- local time = data.to_combat_time - GameNet:getInstance():getTime()
                    -- if time <= 0 then
                    --     --说明开战了 不给调整布阵了
                    --     return 
                    -- end
                    -- HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.EliteMatch, {match_type = match_type, data.to_combat_time})
                    if self.elitematch_main_window then
                        self.elitematch_main_window:onClickMatchBtn()
                    else
                        self:openElitematchMainWindow(true, {is_open_match = true})
                    end
                end
                local cancel_back = function()
                    self:sender24903()
                end
                local extend_msg = TI18N("(点取消将直接开始战斗)")
                CommonAlert.show(msg, TI18N("确定"), call_back, TI18N("取消"), cancel_back, CommonAlert.type.rich, nil, {off_y = 43, title = TI18N("开始讨伐"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }, nil, nil) 
            end
        end
    end
end
--请求匹配对手
function ElitematchController:sender24902(is_skip)
    local protocal = {}
    protocal.type = is_skip
    self:SendProtocal(24902, protocal)
end

function ElitematchController:handle24902(data)

end
--挑战对手
function ElitematchController:sender24903()
    local protocal = {}
    self:SendProtocal(24903, protocal)
end

function ElitematchController:handle24903(data)
    if data.code == TRUE then

    else
        message(data.msg)
        GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Fight_Fail_Event)
    end
end
--购买次数
function ElitematchController:sender24904()
    local protocal = {}
    self:SendProtocal(24904, protocal)
end

function ElitematchController:handle24904(data)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_buy_count_Event, data)
    else
        message(data.msg)
    end
end
--开战时间
function ElitematchController:sender24905()
    local protocal = {}
    self:SendProtocal(24905, protocal)
end

function ElitematchController:handle24905(data)
    self.model:setEliteMatchFightTime(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Start_Time_Event, data)
    self.model:setSCDataBack24905()
end

--战斗结算
function ElitematchController:handle24906(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Fight_Result_Event)

    if self.timer_id then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer_id)
        self.timer_id = nil
    end
    self.scdata24906 = data
    self:openElitematchFightResultPanel(false)
    self.timer_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        if self.timer_id then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timer_id)
            self.timer_id = nil
        end
        if self.scdata24906 then
            self:openElitematchFightResultPanel(true, self.scdata24906)
        end
    end, 2, false)
end

--历史赛季赛区信息
function ElitematchController:sender24910()
    local protocal = {}
    self:SendProtocal(24910, protocal)
end

function ElitematchController:handle24910(data)
    -- if data.code == TRUE then
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_History_Zone_Event, data)
    -- else
    --     message(data.msg)
    -- end
end

--历史赛季
function ElitematchController:sender24911(match_index, start_index, end_index, zone_id)
    local protocal = {}
    protocal.period = match_index
    protocal.start_rank = start_index
    protocal.end_rank = end_index
    protocal.zone_id = zone_id
    self:SendProtocal(24911, protocal)
end

function ElitematchController:handle24911(data)
    -- if data.code == TRUE then
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_History_Record_Event, data)
    -- else
    --     message(data.msg)
    -- end
end

--领取段位奖励
function ElitematchController:sender24915(lev)
    local protocal = {}
    protocal.lev = lev
    self:SendProtocal(24915, protocal)
end

function ElitematchController:handle24915(data)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Receive_Reward_Event, data)
    else
        message(data.msg)
    end
end

--请求阵法
function ElitematchController:sender24920(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(24920, protocal)
end

function ElitematchController:handle24920(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Update_Elite_Fun_Form, data)

    local _type = nil
    if data.type == 1 then
        _type = PartnerConst.Fun_Form.EliteMatch
    else
        _type = PartnerConst.Fun_Form.EliteKingMatch
    end

    local model = HeroController:getInstance():getModel()
    for i,v in ipairs(data.formations) do
        v.type = _type
        model:setFormList(v, v.order)
    end
end

function ElitematchController:sender24921(type, formations )
    local protocal = {}
    protocal.type = type
    protocal.formations = formations
    self:SendProtocal(24921, protocal)
end

function ElitematchController:handle24921(data)

    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ElitematchEvent.Update_Elite_Save_Form, data)
        self:sender24920(1)
        self:sender24920(2)
    else
        message(data.msg)
    end
end

function ElitematchController:sender24930(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(24930, protocal)
end

function ElitematchController:handle24930(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Challenge_Record_Event, data)
end

function ElitematchController:sender24931(type, id)
    local protocal = {}
    protocal.type = type
    protocal.id = id
    self:SendProtocal(24931, protocal)
end

function ElitematchController:handle24931(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Challenge_Record_Info_Event, data)
end

function ElitematchController:sender24940(period)
    local protocal = {}
    protocal.period = period
    self:SendProtocal(24940, protocal)
end

function ElitematchController:handle24940(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Personal_Info_Event, data)
end


function ElitematchController:sender24941(channel)
    local protocal = {}
    protocal.channel = channel
    self:SendProtocal(24941, protocal)
end

function ElitematchController:handle24941(data)
    message(data.msg)
end

function ElitematchController:sender24942(id, share_srv_id, period)
    local protocal = {}
    protocal.id = id
    protocal.share_srv_id = share_srv_id
    protocal.period = period
    self:SendProtocal(24942, protocal)
end

function ElitematchController:handle24942(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Personal_Info_Event2, data)
end



--打开宣言
function ElitematchController:sender24945()
    local protocal = {}
    self:SendProtocal(24945, protocal)
end

function ElitematchController:handle24945(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Declaration_Event, data)
end

--保存宣言设置
function ElitematchController:sender24946(manifesto)
    local protocal = {}
    protocal.manifesto = manifesto
    self:SendProtocal(24946, protocal)
end

function ElitematchController:handle24946(data)
    message(data.msg)
end
--show宣言结束
function ElitematchController:sender24950()
    local protocal = {}
    self:SendProtocal(24950, protocal)
end

function ElitematchController:handle24950(data)
    message(data.msg)
end

---------------------------@ 打开界面
--打开精英大赛主界面
function ElitematchController:openElitematchMainWindow( status, setting )
    if status == true then
        -- 判断精英大赛是否开启
        if not self.model:checkElitematchIsOpen() then
            return
        end
        
        if self.elitematch_main_window == nil then
            self.elitematch_main_window = ElitematchMainWindow.New()
        end
        if self.elitematch_main_window:isOpen() == false then
            self.elitematch_main_window:open(setting)
        end
    else
        if self.elitematch_main_window then
            self.elitematch_main_window:close()
            self.elitematch_main_window = nil
        end
    end
end
--打开精英大赛匹配界面
function ElitematchController:openElitematchMatchingWindow(status, match_type, scdata)
    if status == true then
        if self.elitematch_matching_window == nil then
            self.elitematch_matching_window = ElitematchMatchingWindow.New()
        end
        if self.elitematch_matching_window:isOpen() == false then
            self.elitematch_matching_window:open(match_type, scdata)
        end
    else
        if self.elitematch_matching_window then
            self.elitematch_matching_window:close()
            self.elitematch_matching_window = nil
        end
    end
end

--打开精英大赛战斗结果界面
function ElitematchController:openElitematchFightResultPanel(status, data)
    if status == true then
        if self.elitematch_fight_result_panel == nil then
            self.elitematch_fight_result_panel = ElitematchFightResultPanel.New()
        end
        if self.elitematch_fight_result_panel.isOpen and self.elitematch_fight_result_panel:isOpen() == false then
            self.elitematch_fight_result_panel:open(data)
        end
    else
        if self.elitematch_fight_result_panel then
            self.elitematch_fight_result_panel:close()
            self.elitematch_fight_result_panel = nil
        end
    end
end
--打开奖励界面
function ElitematchController:openElitematchRewardPanel(status, index, level_id, rank)
    if status == true then
        if self.elitematch_reward_panel == nil then
            self.elitematch_reward_panel = ElitematchRewardPanel.New()
        end
        if self.elitematch_reward_panel:isOpen() == false then
            self.elitematch_reward_panel:open(index, level_id, rank)
        end
    else
        if self.elitematch_reward_panel then
            self.elitematch_reward_panel:close()
            self.elitematch_reward_panel = nil
        end
    end
end
--打开战斗记录
function ElitematchController:openElitematchFightRecordPanel(status, index, level_id)
    if status == true then
        if self.elitematch_fight_record_panel == nil then
            self.elitematch_fight_record_panel = ElitematchFightRecordPanel.New()
        end
        if self.elitematch_fight_record_panel:isOpen() == false then
            self.elitematch_fight_record_panel:open(index, level_id)
        end
    else
        if self.elitematch_fight_record_panel then
            self.elitematch_fight_record_panel:close()
            self.elitematch_fight_record_panel = nil
        end
    end
end
--打开录像
function ElitematchController:openElitematchFightVedioPanel(status, index, level_id, _type, setting)
    if status == true then
        if self.elitematch_fight_vedio_panel == nil then
            self.elitematch_fight_vedio_panel = ElitematchFightVedioPanel.New()
        end
        if self.elitematch_fight_vedio_panel:isOpen() == false then
            self.elitematch_fight_vedio_panel:open(index, level_id, _type, setting)
        end
    else
        if self.elitematch_fight_vedio_panel then
            self.elitematch_fight_vedio_panel:close()
            self.elitematch_fight_vedio_panel = nil
        end
    end
end
--打开历史赛季
function ElitematchController:openElitematchHistoryRecordWindow(status, index, max_period, zone_id)
    if status == true then
        if self.elitematch_history_record_window == nil then
            self.elitematch_history_record_window = ElitematchHistoryRecordWindow.New()
        end
        if self.elitematch_history_record_window:isOpen() == false then
            self.elitematch_history_record_window:open(index, max_period, zone_id)
        end
    else
        if self.elitematch_history_record_window then
            self.elitematch_history_record_window:close()
            self.elitematch_history_record_window = nil
        end
    end
end
--个人战绩记录
function ElitematchController:openElitematchPersonalInfoPanel(status, period,data)
    if status == true then
        if self.elitematch_personal_info_panel == nil then
            self.elitematch_personal_info_panel = ElitematchPersonalInfoPanel.New()
        end
        if self.elitematch_personal_info_panel:isOpen() == false then
            self.elitematch_personal_info_panel:open(period, data)
        end
    else
        if self.elitematch_personal_info_panel then
            self.elitematch_personal_info_panel:close()
            self.elitematch_personal_info_panel = nil
        end
    end
end
--宣言设置
function ElitematchController:openElitematchDeclarationPanel(status,msgType)
    if status == true then
        if self.elitematch_declaration_panel == nil then
            self.elitematch_declaration_panel = ElitematchDeclarationPanel.New(msgType)
        end
        if self.elitematch_declaration_panel:isOpen() == false then
            self.elitematch_declaration_panel:open()
        end
    else
        if self.elitematch_declaration_panel then
            self.elitematch_declaration_panel:close()
            self.elitematch_declaration_panel = nil
        end
    end
end
--宣言设置
function ElitematchController:openChooseFacePanel(status, index, id, world_pos, msg_type)
    if status == true then
        if self.choose_face_panel == nil then
            self.choose_face_panel = ChooseFacePanel.New()
        end
        if self.choose_face_panel:isOpen() == false then
            self.choose_face_panel:open(index, id, world_pos, msg_type)
        end
    else
        if self.choose_face_panel then
            self.choose_face_panel:close()
            self.choose_face_panel = nil
        end
    end
end
--宣言设置
function ElitematchController:openElitematchZoneListPanel(status, max_zone, callback)
    if status == true then
        if self.elitematch_zone_list_panel == nil then
            self.elitematch_zone_list_panel = ElitematchZoneListPanel.New()
        end
        if self.elitematch_zone_list_panel:isOpen() == false then
            self.elitematch_zone_list_panel:open(max_zone, callback)
        end
    else
        if self.elitematch_zone_list_panel then
            self.elitematch_zone_list_panel:close()
            self.elitematch_zone_list_panel = nil
        end
    end
end

-----------------------------------------段位赛战令活动---------------------------------------------
-- 战令基本信息
function ElitematchController:sender24952()
    local protocal = {}
    self:SendProtocal(24952, protocal)
end

function ElitematchController:handle24952(data)
    self.model:setOrderactionData(data)
    self.model:setSCDataBackOrderaction()
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_OrderAction_Init_Event, data)
end

--一键领取礼包
function ElitematchController:sender24953(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(24953, protocal)
end

function ElitematchController:handle24953(data)
    if data then
        message(data.msg)
    end
end

--红点
function ElitematchController:sender24954()
    local protocal = {}
    self:SendProtocal(24954, protocal)
end

function ElitematchController:handle24954(data)
    if data then
        self.model:setOrderactionRedStatus(data.flag)
        self.model:setSCDataBackOrderaction()
    end
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_OrderAction_First_Red_Event)
end

--段位赛活动提示
function ElitematchController:sender24955()
    local protocal = {}
    self:SendProtocal(24955, protocal)
end

function ElitematchController:handle24955(data)
    GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_OrderAction_IsPopWarn_Event,data)
end

--打开主界面
function ElitematchController:openElitematchOrderactionWindow(status)
    if status == true then
        -- 判断精英大赛是否开启
        if not self.model:checkElitematchIsOpen() then
            return
        end

        if not self.elitematch_orderaction_window then
            self.elitematch_orderaction_window = ElitematchOrderactionWindow.New()
        end
        self.elitematch_orderaction_window:open()
    else
        if self.elitematch_orderaction_window then 
            self.elitematch_orderaction_window:close()
            self.elitematch_orderaction_window = nil
        end
    end
end

--购买进阶卡
function ElitematchController:openBuyCardView(status)
    if status == true then
        if not self.buy_card_view then
            self.buy_card_view = ElitematchOrderactionUntieRewardWindow.New()
        end
        self.buy_card_view:open()
    else
        if self.buy_card_view then 
            self.buy_card_view:close()
            self.buy_card_view = nil
        end
    end
end

--打开活动结束警告界面
function ElitematchController:openElitematchEndWarnView(status,day)
    if status == true then
        if not self.end_warn_view then
            self.end_warn_view = ElitematchOrderActionEndWarnWindow.New()
        end
        self.end_warn_view:open(day)
    else
        if self.end_warn_view then 
            self.end_warn_view:close()
            self.end_warn_view = nil
        end
    end
end


function ElitematchController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end