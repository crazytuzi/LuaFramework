-- --------------------------------------------------------------------
-- 巅峰冠军赛
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      控制器  后端锋林  策划 中建
-- <br/>Create: 2019-11-12
-- --------------------------------------------------------------------
ArenapeakchampionController = ArenapeakchampionController or BaseClass(BaseController)

function ArenapeakchampionController:config()
    self.model = ArenapeakchampionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ArenapeakchampionController:getModel()
    return self.model
end

function ArenapeakchampionController:registerEvents()
end

function ArenapeakchampionController:registerProtocals()
    self:RegisterProtocal(27700, "handle27700")  --"主界面信息协议"
    self:RegisterProtocal(27701, "handle27701")  --"个人信息"
    self:RegisterProtocal(27702, "handle27702")  --"我的比赛信息"
    self:RegisterProtocal(27703, "handle27703")  --"竞猜信息"
    self:RegisterProtocal(27704, "handle27704")  --"竞猜押注"
    self:RegisterProtocal(27705, "handle27705")  --"我的竞猜信息"
    self:RegisterProtocal(27706, "handle27706")  --"巅峰冠军赛结算"
    self:RegisterProtocal(27707, "handle27707")  --"竞猜押注实时更新"
    self:RegisterProtocal(27708, "handle27708")  --"我的pk信息"
    
    self:RegisterProtocal(27709, "handle27709")  --"64强"
    self:RegisterProtocal(27710, "handle27710")  --"8强"


    self:RegisterProtocal(27712, "handle27712")  --"获取指定位置对战信息"
    self:RegisterProtocal(27713, "handle27713")  --"排名协议"

    self:RegisterProtocal(27714, "handle27714")  --"排名协议"
    self:RegisterProtocal(27716, "handle27716")  --"竞猜押注有变化（客户端收到后请求27707）"

    self:RegisterProtocal(27725, "handle27725")  --"设置阵法" --未测试
    self:RegisterProtocal(27726, "handle27726")  --"请求阵法"

    self:RegisterProtocal(27730, "handle27730")  --"请求红点信息"
    self:RegisterProtocal(27731, "handle27731")  --"点击红点"
end

--主界面协议
function ArenapeakchampionController:sender27700()
    local protocal = {}
    self:SendProtocal(27700, protocal)
end

function ArenapeakchampionController:handle27700(data)
    self.model:setMainData(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MAIN_EVENT, data)

    local is_open = self.model:checkPeakChampionIsOpen(true)
    if not is_open then return end
    
    if data.round_status == 2 or data.round_status == 1 then
        --进竞猜阶段..后端才会刷新数据.这个时候我刷新一下数据 额外到休整期也会清
        self.model:setMatchData256(nil, data.zone_id)
        self.model:setMatchData64(nil, data.zone_id)
        self.model:setMatchData8(nil, data.zone_id)
    end
    self.current_round_status = data.round_status

    --通知客户端观看录像
    if data.flag == 2 then
        GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SHOW_VEDIO_EVENT, data)
    end

    if data.step_status == ArenaConst.champion_step_status.opened then
        -- 这里时候要判断一下是否有引导,有引导不处理,剧情中也不需要弹

        if GuideController:getInstance():isInGuide() then return end
        if StoryController:getInstance():getModel():isStoryState() then return end 

        local time = data.round_status_time - GameNet:getInstance():getTime()
        if data.flag == 3 or (data.round_status == 2 and time < 300 ) then
            if not self.had_show_notice then
                ActivityController:openSignView(true, ActivitySignType.peak_champion_guess, {timer = true})
                self.had_show_notice = true
            end
        end
    end
    --结束界面
    if data.step_status == 2 and not self.init_27706 then
        self.init_27706 = true
        self:sender27706()
    end
end


--个人信息
function ArenapeakchampionController:sender27701()
    local protocal = {}
    self:SendProtocal(27701, protocal)
end

function ArenapeakchampionController:handle27701(data)
    self.model:setMyGuessData(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SINGLE_INFO_EVENT, data)
end

--我的比赛信息
function ArenapeakchampionController:sender27702()
    local protocal = {}
    self:SendProtocal(27702, protocal)
end

function ArenapeakchampionController:handle27702(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MY_MATCH_INFO_EVENT, data)
end

--我的pk信息
function ArenapeakchampionController:sender27708()
    local protocal = {}
    self:SendProtocal(27708, protocal)
end

function ArenapeakchampionController:handle27708(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MY_MATCH_LOG_EVENT, data)
end

--竞猜信息
function ArenapeakchampionController:sender27703()
    local protocal = {}
    self:SendProtocal(27703, protocal)
end

function ArenapeakchampionController:handle27703(data)
    self.model:setBetTypeInfo(data.bet_type)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_GUESSING_INFO_EVENT, data)
end
--竞猜押注
function ArenapeakchampionController:sender27704(bet_type, bet_val)
    local protocal = {}
    protocal.bet_type = bet_type
    protocal.bet_val = bet_val
    self:SendProtocal(27704, protocal)
end

function ArenapeakchampionController:handle27704(data)
    message(data.msg)
    if data.code == TRUE then
        --下次成功需要更新代币
        self:sender27701()
        self.model:setBetTypeInfo(data.bet_type)
        GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_GUESSING_STAKE_EVENT, data)
        if self.arenapeakchampion_guess_count_panel then
            self.arenapeakchampion_guess_count_panel:onClickCloseBtn()
        end
    end
        
end
--我的竞猜信息
function ArenapeakchampionController:sender27705()
    local protocal = {}
    self:SendProtocal(27705, protocal)
end

function ArenapeakchampionController:handle27705(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MY_GUESSING_INFO_EVENT, data)
end

--冠军赛结算界面
function ArenapeakchampionController:sender27706()
    local protocal = {}
    self:SendProtocal(27706, protocal)
end

--冠军赛结算界面
function ArenapeakchampionController:handle27706(data)
    self:openArenapeakchampionResultPanel(true, data)
end

--竞猜押注实时更新
function ArenapeakchampionController:sender27707()
    local protocal = {}
    self:SendProtocal(27707, protocal)
end
--竞猜押注实时更新
function ArenapeakchampionController:handle27707(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_UPDATE_GUESSING_INFO_EVENT, data)
end

--竞猜押注有变化（客户端收到后请求27707）
function ArenapeakchampionController:handle27716(data)
    --不在竞猜界面不处理
    if not self.arenapeakchampion_guessing_window  then return end
    local cur_time = os.time()
    if self.time == nil or (cur_time - self.time) > 3 then
        self.time = cur_time
        self:sender27707()
    end
end

--64强
function ArenapeakchampionController:sender27709(zone_id, type)
    local protocal = {}
    protocal.zone_id = zone_id
    protocal.type = type
    self:SendProtocal(27709, protocal)
end

function ArenapeakchampionController:handle27709(data)
    if data.type == 1 then --256
        self.model:setMatchData256(data.list, data.zone_id)
    elseif data.type == 2 then --64强
        self.model:setMatchData64(data.list, data.zone_id)
    else
        --其他数据忽略
        return
    end
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_TOP_64_EVENT, data)
end


--8强
function ArenapeakchampionController:sender27710(zone_id)
    local protocal = {}
    protocal.zone_id = zone_id
    self:SendProtocal(27710, protocal)
end

function ArenapeakchampionController:handle27710(data)
    self.model:setMatchData8(data.pos_list, data.zone_id)
    
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_TOP_8_EVENT, data)
end

--获取指定位置对战信息
--  {uint32, zone_id, "赛区"}
-- ,{uint8, type, "1:晋级赛  2:64强"}
-- ,{uint8,   group,  "组号(0-4 0:表示是4强竞猜)"}
-- ,{uint8,  pos,  "位置(1/3/5/7/9/11/13../24)"} 
function ArenapeakchampionController:sender27712(zone_id, type, group, pos)
    local protocal = {}
    protocal.zone_id = zone_id
    protocal.type = type
    protocal.group = group
    protocal.pos = pos
    self:SendProtocal(27712, protocal)
end

function ArenapeakchampionController:handle27712(data)
    self:openLookFightVedioPanel(data)
end
--历史信息的排行
function ArenapeakchampionController:sender27713(zone_id, period)
    local protocal = {}
    protocal.zone_id = zone_id
    protocal.period = period
    self:SendProtocal(27713, protocal)
end

function ArenapeakchampionController:handle27713(data)
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_RANK_EVENT, data)
end

--当前排行榜信息
function ArenapeakchampionController:sender27714(zone_id, start_num, end_num)
    local protocal = {}
    protocal.zone_id = zone_id
    protocal.start_num = start_num
    protocal.end_num = end_num
    self:SendProtocal(27714, protocal)
end

function ArenapeakchampionController:handle27714(data)
    if data.end_num == 1 then
        --有排行信息才能有红点逻辑
        if #data.rank_list > 0 then
            self.model:setWorshipRedPoint(data.day_worship, data)
        end
    end
    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_CURRENT_RANK_EVENT, data)
end

--设置阵法
function ArenapeakchampionController:sender27725(formations)
    local protocal = {}
    protocal.formations = formations
    self.record_formations = formations
    self:SendProtocal(27725, protocal)
end

function ArenapeakchampionController:handle27725(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SAVE_FROM_EVENT, data)
        if self.record_formations then
            local model = HeroController:getInstance():getModel()
            for i,v in ipairs(self.record_formations) do
                v.type = PartnerConst.Fun_Form.ArenapeakchampionDef
                model:setFormList(v, v.order)
            end
        end
    end
end

--获取阵法
function ArenapeakchampionController:sender27726()
    local protocal = {}
    self:SendProtocal(27726, protocal)
end

function ArenapeakchampionController:handle27726(data)
    local model = HeroController:getInstance():getModel()
    for i,v in ipairs(data.formations) do
        v.type = PartnerConst.Fun_Form.ArenapeakchampionDef
        model:setFormList(v, v.order)
        -- v.old_order = v.order --记录保存旧的old_order
    end

    GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_FROM_EVENT, data)
end

--请求红点信息(登陆获取)
function ArenapeakchampionController:sender27730()
    local protocal = {}
    self:SendProtocal(27730, protocal)
end

function ArenapeakchampionController:handle27730(data)
    self.model:setLoginRedPoint(data)
end

--点击红点
function ArenapeakchampionController:sender27731(_type)
    local protocal = {}
    protocal.type = _type
    self:SendProtocal(27731, protocal)
end

function ArenapeakchampionController:handle27731(data)
    -- GlobalEvent:getInstance():Fire(ArenapeakchampionEvent.ARENAPEAKCHAMPION_HIT_RED_POINT_EVENT, data)
end



--打开巅峰竞技场主界面
function ArenapeakchampionController:openArenapeakchampionMainWindow( status, setting )
    if status == true then
        if IS_HIDE_CROSS then
            message(TI18N("巅峰冠军赛暂未开启"))
            return
        end
        local main_data = self.model:getMainData()
        if not main_data then return end
        if main_data.flag == 4 then
            message(TI18N("服务器繁忙，入口将稍后开启，请留意邮件通知"))
            if self.is_send_27700 == nil then
                -- 申请一下最新协议 避免客户端记录该数值 导致没有重登的话就不会移除该状态
                self.is_send_27700 = true --此值再跨服战场界面关闭的时候清除
                self:sender27700()
            end
            return
        end

        if self.arenapeakchampion_main_window == nil then
            self.arenapeakchampion_main_window = ArenapeakchampionMainWindow.New()
        end
        if self.arenapeakchampion_main_window:isOpen() == false then
            self.arenapeakchampion_main_window:open(setting)
        end
    else
        if self.arenapeakchampion_main_window then
            self.arenapeakchampion_main_window:close()
            self.arenapeakchampion_main_window = nil
        end
    end
end
function ArenapeakchampionController:getArenapeakchampionGuessingWindow()
    if self.arenapeakchampion_guessing_window then
        return self.arenapeakchampion_guessing_window
    end
end

--打开巅峰竞技场竞猜界面
function ArenapeakchampionController:openArenapeakchampionGuessingWindow( status, setting )
    if status == true then
        if IS_HIDE_CROSS then
            message(TI18N("巅峰竞技场暂未开启"))
            return
        end
        local main_data = self.model:getMainData()
        if not main_data then return end
        if main_data.flag == 4 then
            message(TI18N("服务器繁忙，入口将稍后开启，请留意邮件通知"))
            return
        end

        if self.arenapeakchampion_guessing_window == nil then
            self.arenapeakchampion_guessing_window = ArenapeakchampionGuessingWindow.New()
        end
        if self.arenapeakchampion_guessing_window:isOpen() == false then
            self.arenapeakchampion_guessing_window:open(setting)
        end
    else
        if self.arenapeakchampion_guessing_window then
            self.arenapeakchampion_guessing_window:close()
            self.arenapeakchampion_guessing_window = nil
        end
    end
end--打开巅峰竞技场竞猜界面
function ArenapeakchampionController:openArenapeakchampionMymatchPanel( status, setting )
    if status == true then
        if self.arenapeakchampion_mymatch_panel == nil then
            self.arenapeakchampion_mymatch_panel = ArenapeakchampionMymatchPanel.New()
        end
        if self.arenapeakchampion_mymatch_panel:isOpen() == false then
            self.arenapeakchampion_mymatch_panel:open(setting)
        end
    else
        if self.arenapeakchampion_mymatch_panel then
            self.arenapeakchampion_mymatch_panel:close()
            self.arenapeakchampion_mymatch_panel = nil
        end
    end
end

--打开对战详情
function ArenapeakchampionController:openArenapeakchampionFightInfoPanel( status, setting )
    if status == true then
        if self.arenapeakchampion_fight_info_panel == nil then
            self.arenapeakchampion_fight_info_panel = ArenapeakchampionFightInfoPanel.New()
        end
        if self.arenapeakchampion_fight_info_panel:isOpen() == false then
            self.arenapeakchampion_fight_info_panel:open(setting)
        end
    else
        if self.arenapeakchampion_fight_info_panel then
            self.arenapeakchampion_fight_info_panel:close()
            self.arenapeakchampion_fight_info_panel = nil
        end
    end
end

--打开竞猜记录
function ArenapeakchampionController:openArenapeakchampionGuessInfoPanel( status, setting )
    if status == true then
        if self.arenapeakchampion_guess_info_panel == nil then
            self.arenapeakchampion_guess_info_panel = ArenapeakchampionGuessInfoPanel.New()
        end
        if self.arenapeakchampion_guess_info_panel:isOpen() == false then
            self.arenapeakchampion_guess_info_panel:open(setting)
        end
    else
        if self.arenapeakchampion_guess_info_panel then
            self.arenapeakchampion_guess_info_panel:close()
            self.arenapeakchampion_guess_info_panel = nil
        end
    end
end
--打开竞猜数量界面
function ArenapeakchampionController:openArenapeakchampionGuessCountPanel( status, setting )
    if status == true then
        if self.arenapeakchampion_guess_count_panel == nil then
            self.arenapeakchampion_guess_count_panel = ArenapeakchampionGuessCountPanel.New()
        end
        if self.arenapeakchampion_guess_count_panel:isOpen() == false then
            self.arenapeakchampion_guess_count_panel:open(setting)
        end
    else
        if self.arenapeakchampion_guess_count_panel then
            self.arenapeakchampion_guess_count_panel:close()
            self.arenapeakchampion_guess_count_panel = nil
        end
    end
end
--结算界面
function ArenapeakchampionController:openArenapeakchampionResultPanel( status, setting )
    if status == true then
        if self.arenapeakchampion_result_panel == nil then
            self.arenapeakchampion_result_panel = ArenapeakchampionResultPanel.New()
        end
        if self.arenapeakchampion_result_panel:isOpen() == false then
            self.arenapeakchampion_result_panel:open(setting)
        end
    else
        if self.arenapeakchampion_result_panel then
            self.arenapeakchampion_result_panel:close()
            self.arenapeakchampion_result_panel = nil
        end
    end
end
--巅峰商店
function ArenapeakchampionController:openArenapeakchampionShopWindow( status, setting )
    if status == true then
        if self.arenapeakchampion_shop_window == nil then
            self.arenapeakchampion_shop_window = ArenapeakchampionShopWindow.New()
        end
        if self.arenapeakchampion_shop_window:isOpen() == false then
            self.arenapeakchampion_shop_window:open(setting)
        end
    else
        if self.arenapeakchampion_shop_window then
            self.arenapeakchampion_shop_window:close()
            self.arenapeakchampion_shop_window = nil
        end
    end
end

--是引用别的界面的所以要整合数据 27702的数据结构
function ArenapeakchampionController:openLookFightVedioPanel(data)
    if not data then return end    

    local first_data = {} 
    first_data.combat_type = BattleConst.Fight_Type.Arenapeakchampion
    first_data.srv_id = data.a_srv_id
    first_data.atk_name = data.a_name
    first_data.def_srv_id = data.b_srv_id
    first_data.def_name = data.b_name
    
    first_data.win_count = 0
    first_data.lose_count = 0
    
    local second_data = self.model:getSecondData(data, true)
    local new_list = {}
    --按策划要求过滤
    for i,v in ipairs(second_data.arena_replay_infos) do
        local is_continue = false
        if v.ret == nil then --有空队伍的
            if #v.a_plist == 0 and # v.b_plist == 0 then
                --双方队伍都空了
                --不要了
                is_continue = true
            elseif #v.a_plist ~= 0 and # v.b_plist == 0 then
                v.ret = 1
                first_data.win_count = first_data.win_count + 1
            elseif #v.a_plist == 0 and # v.b_plist ~= 0 then
                v.ret = 2
                first_data.lose_count = first_data.lose_count + 1
            end
        else
            if v.ret == 1 then
                first_data.win_count = first_data.win_count + 1
            else
                first_data.lose_count = first_data.lose_count + 1
            end
        end
        
        if not is_continue then
            table.insert(new_list, v)
        end
        if i == 2 and (first_data.win_count == 2 or first_data.lose_count == 2) then
            --说明已经 2:0 或者 0:2了
            break
        end
    end
    second_data.arena_replay_infos = new_list
    --过滤
    ElitematchController:getInstance():openElitematchFightVedioPanel(true, first_data, 1, 3, second_data)
end

function ArenapeakchampionController:openArenapeakchampionShop()
    local setting = {}
    setting.mall_type = MallConst.MallType.PeakchampionShop
    setting.item_id = Config.ItemData.data_assets_label2id.peak_guess_cent
    setting.config = Config.ExchangeData.data_shop_exchage_peakchampion
    setting.shop_name = TI18N("巅峰商店")
    MallController:getInstance():openMallSingleShopPanel(true, setting)
end

function ArenapeakchampionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end