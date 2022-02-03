-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      年兽活动 后端 国辉  策划 中建
-- <br/>Create: 2020-01-03
-- --------------------------------------------------------------------
ActionyearmonsterController = ActionyearmonsterController or BaseClass(BaseController)

function ActionyearmonsterController:config()
    self.model = ActionyearmonsterModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ActionyearmonsterController:getModel()
    return self.model
end

function ActionyearmonsterController:registerEvents()

    if not self.red_bg_event then
        self.red_bg_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function(data)
            if data and data.is_year_red_bag then
                --此数据是 28214 返回的数据
                local info_data = data.info_data
                self:openActionyearmonsterRedbagEventPanel(true,{info_data = info_data})
            end
        end)
    end
end

function ActionyearmonsterController:registerProtocals()
    self:RegisterProtocal(28200, "handle28200") -- 基础数据信息
    self:RegisterProtocal(28201, "handle28201") -- 格子数据信息
    self:RegisterProtocal(28202, "handle28202") -- 移动进入指定格子，需接收到成功后方可移动 
    self:RegisterProtocal(28203, "handle28203") --  操作指定格子事件
    self:RegisterProtocal(28204, "handle28204") -- 请求进入副本
    self:RegisterProtocal(28205, "handle28205") -- 事件信息返回
    self:RegisterProtocal(28206, "handle28206") -- 背包信息
    self:RegisterProtocal(28207, "handle28207") -- 背包新增（更新）信息
    self:RegisterProtocal(28208, "handle28208") -- 背包删除信息

    self:RegisterProtocal(28209, "handle28209") -- 战斗结果

    self:RegisterProtocal(28210, "handle28210") -- 获取对方阵容信息
    self:RegisterProtocal(28211, "handle28211") -- 提交贡品
    self:RegisterProtocal(28212, "handle28212") -- 购买挑战次数
    self:RegisterProtocal(28213, "handle28213") -- 排行奖励
    self:RegisterProtocal(28214, "handle28214") -- 获取红包情况
    self:RegisterProtocal(28215, "handle28215") -- 挑战信息

    self:RegisterProtocal(28218, "handle28218") -- 格子更新

    self:RegisterProtocal(28216, "handle28216") -- 集字兑换
    self:RegisterProtocal(28217, "handle28217") -- 集字兑换界面

    self:RegisterProtocal(28219, "handle28219") -- 保存年兽表情
    self:RegisterProtocal(28220, "handle28220") -- 个人年兽表情
    self:RegisterProtocal(28221, "handle28221") -- 使用烟花
    self:RegisterProtocal(28222, "handle28222") -- 个人交换
    self:RegisterProtocal(28223, "handle28223") -- 是否有红包事件
    self:RegisterProtocal(28224, "handle28224") -- 是否有年兽可以挑战
    
    
end

--基本数据
function ActionyearmonsterController:sender28200( )
    self:SendProtocal(28200, {})
end

function ActionyearmonsterController:handle28200( data )
    --活动未开启
    if data.camp_id == 0 then
        self:openActionyearmonsterChallengePanel(false)
        self:openActionyearmonsterRedbagEventPanel(false)
        self:openActionyearmonsterRedbagEffectPanel(false)
        self:openActionyearmonsterSubmitPanel(false)
        self:openActionyearmonsterBagPanel(false)
        self:openActionyearmonsterMonsterInfo(false)
        self:openActionyearmonsterExchangeWindow(false)
        self:openActionyearmonsterMainWindow(false)
        return
    end

    self.model:setBaseData(data)
    self.model:setPlanesRoleLookId(data.look_id)
    self.model:setHolidayOpen(data.camp_id)
    HomeworldController:getInstance():getModel():setMyCurHomeFigureId(data.look_id)
    HomeworldController:getInstance():getModel():setActivateFigureList(data.list, true)

    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.YEAR_MONSTER_BASE_INFO, data)

    --主界面红点
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo then
        if data.val >= data.max_val  then
            MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.year_monster, false)
        else
            local holiday_nian_tribute_id = 80351
            local config  = Config.HolidayNianData.data_const.holiday_nian_tribute_id
            if config then
                holiday_nian_tribute_id = config.val
            end
            local have_count = role_vo:getActionAssetsNumByBid(holiday_nian_tribute_id)

            if have_count > 0 then
                MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.year_monster, true)
            else
                MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.year_monster, false)
            end
        end
    end

end

--格子数据信息
-- function ActionyearmonsterController:sender28201( )
--     self:SendProtocal(28201, {})
-- end

--格子数据信息
function ActionyearmonsterController:handle28201( data )
    self.model:setCellData(data)

    if data.tile_list and next(data.tile_list) ~= nil then
        self.model:setYearEvtVoList(data.tile_list)
    end
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.YEAR_MONSTER_CEIL_INFO, data)
end
--格子数据更新
function ActionyearmonsterController:handle28218(data)
    if next(data.tile_list) ~= nil then
        self.model:updateYearEvtVoList(data.tile_list)

        GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.YEAR_UPDATE_GRID_EVENT, data.tile_list)
    end
end


--移动进入指定格子，需接收到成功后方可移动 
function ActionyearmonsterController:sender28202( index)
    local protocal = {}
    protocal.index = index
    self:SendProtocal(28202, protocal)
end

function ActionyearmonsterController:handle28202( data )
    message(data.msg)
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Update_Role_Grid_Event, data)
end


-- 请求操作格子事件
function ActionyearmonsterController:sender28203( index, action, ext_list, extend )
    local protocal = {}
    protocal.index = index or self.evt_grid_index
    protocal.action = action
    protocal.ext_list = ext_list or {}
    self.evt_extend = extend -- 额外数据
    self:SendProtocal(28203, protocal)
end

function ActionyearmonsterController:handle28203( data )
    message(data.msg)
    -- 事件成功，可能需要做一些表现（例如buff图标动画）
    if data.code == TRUE and self.evt_extend and self.evt_extend.index == data.index then
        -- if self.evt_extend.buff_id and self.evt_extend.world_pos then -- 选择buff成功，播放飘动动画
        --     GlobalEvent:getInstance():Fire(PlanesEvent.Chose_Buff_Event, self.evt_extend.buff_id, self.evt_extend.world_pos)
        --     self:openPlanesBuffChoseWindow(false)
        -- end
        self.evt_extend = nil
    end
end

-- 请求进入副本
function ActionyearmonsterController:sender28204( )
    -- if self.model:getCurDunId() == 0 then -- 如果是开启副本，需要特殊处理
    --     self.is_open_dun_flag = true
    -- else
    --     self.is_open_dun_flag = false
    -- end
    -- 锁屏，防止连续点击
    -- if self.planes_main_wnd then
    --     self.planes_main_wnd:onLockScreenCallBack(true)
    -- end
    self.model:setCellData(nil)
    self:SendProtocal(28204, {})
end

function ActionyearmonsterController:handle28204( data )
    message(data.msg)
    -- 进入副本成功则打开地图界面
    --写到这里
    if data.flag == TRUE then
        -- if self.is_open_dun_flag then -- 开启副本先播特效再进入场景
        --     GlobalEvent:getInstance():Fire(PlanesEvent.Dun_Open_Effect_Event, data)
        -- else
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.YearMonsterWar)
            -- if self.planes_main_wnd then -- 解除锁屏，如果是需要先播特效的，特效播完会解除锁屏
            --     self.planes_main_wnd:onLockScreenCallBack(false)
            -- end
        -- end
    end
end

-- 请求背包数据
function ActionyearmonsterController:sender28206(  )
    self:SendProtocal(28206, {})
end

function ActionyearmonsterController:handle28206( data )
    self.model:setYearBagData(data.holiday_nian_item)
end

-- 背包数据更新、新增
function ActionyearmonsterController:handle28207( data )
    self.model:updateYearBagData(data.update_item)
end

-- 背包数据删除
function ActionyearmonsterController:handle28208( data )
    self.model:deleteYearBagData(data.delete_pos)
end

-- 战斗结果
function ActionyearmonsterController:handle28209( data )
    data.item_rewards = data.reward
    for i,v in ipairs(data.item_rewards) do
        v.bid = v.base_id
    end
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.YearMonsterWar, data)
    if self.actionyearmonster_challenge_panel then
        if data.type == ActionyearmonsterConstants.Evt_Type.YearMonster or 
            data.type == ActionyearmonsterConstants.Evt_Type.GoldYearMonster then
            self:sender28203(data.evt_index, 0, {} )
        end
    end
end


--敌方阵容
function ActionyearmonsterController:handle28210( data )
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Get_Master_Data_Event, data)
end
    
-- 提交祭品
function ActionyearmonsterController:sender28211( num )
    local protocal = {}
    protocal.num = num
    self:SendProtocal(28211, protocal)
end

function ActionyearmonsterController:handle28211( data )
    message(data.msg)
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Submit_item_Event, data)
    end
end

-- 购买挑战次数
function ActionyearmonsterController:sender28212( _type )
    local protocal = {}
    protocal.type = _type
    self:SendProtocal(28212, protocal)
end

function ActionyearmonsterController:handle28212( data )
    message(data.msg)
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Buy_count_Event, data)
    end
end

--红包显示
function ActionyearmonsterController:handle28214( data )
    if data.flag == 0 then
        self:openActionyearmonsterRedbagEventPanel(true,{info_data = data})
    else
       self:openActionyearmonsterRedbagEffectPanel(true, data)
    end
end

--挑战界面
function ActionyearmonsterController:sender28213( _type, num )
    local protocal = {}
    protocal.type = _type
    protocal.num = num
    self:SendProtocal(28213, protocal)
end
function ActionyearmonsterController:handle28213( data )
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Rank_Info_Event, data)
end


--挑战界面--后端推送
function ActionyearmonsterController:handle28215( data )
    if self.actionyearmonster_challenge_panel then
        self.actionyearmonster_challenge_panel:updateData(data)
    else
       self:openActionyearmonsterChallengePanel(true, {data = data})
    end
end



--打开活动主界面
function ActionyearmonsterController:openActionyearmonsterMainWindow(status, setting)
    if status == false then
        if self.actionyearmonster_main_window ~= nil then
            self.actionyearmonster_main_window:close()
            self.actionyearmonster_main_window = nil
        end
    else
        if self.actionyearmonster_main_window == nil then
            self.actionyearmonster_main_window = ActionyearmonsterMainWindow.New()
        end
        self.actionyearmonster_main_window:open(setting)
    end
end


--打开怪物布阵界面
function ActionyearmonsterController:openActionyearmonsterMonsterInfo(status, index)
    if status == false then
        if self.actionyearmonster_monster_info ~= nil then
            self.actionyearmonster_monster_info:close()
            self.actionyearmonster_monster_info = nil
        end
    else
        if self.actionyearmonster_monster_info == nil then
            self.actionyearmonster_monster_info = ActionyearmonsterMonsterInfo.New()
        end
        self.actionyearmonster_monster_info:open(index)
    end
end

--打开背包
function ActionyearmonsterController:openActionyearmonsterBagPanel(status, setting)
    if status == false then
        if self.actionyearmonster_bag_panel ~= nil then
            self.actionyearmonster_bag_panel:close()
            self.actionyearmonster_bag_panel = nil
        end
    else
        if self.actionyearmonster_bag_panel == nil then
            self.actionyearmonster_bag_panel = ActionyearmonsterBagPanel.New()
        end
        self.actionyearmonster_bag_panel:open(setting)
    end
end
--提交祭品
function ActionyearmonsterController:openActionyearmonsterSubmitPanel(status, setting)
    if status == false then
        if self.actionyearmonster_submit_panel ~= nil then
            self.actionyearmonster_submit_panel:close()
            self.actionyearmonster_submit_panel = nil
        end
    else
        if self.actionyearmonster_submit_panel == nil then
            self.actionyearmonster_submit_panel = ActionyearmonsterSubmitPanel.New()
        end
        self.actionyearmonster_submit_panel:open(setting)
    end
end

--打开红包特效
function ActionyearmonsterController:openActionyearmonsterRedbagEffectPanel(status, data)
    if status == false then
        if self.actionyearmonster_redbag_effect_panel ~= nil then
            self.actionyearmonster_redbag_effect_panel:close()
            self.actionyearmonster_redbag_effect_panel = nil
        end
    else
        self.is_show_redbag = true
        if self.actionyearmonster_redbag_effect_panel == nil then
            self.actionyearmonster_redbag_effect_panel = ActionyearmonsterRedbagEffectPanel.New()
        end
        self.actionyearmonster_redbag_effect_panel:open(data)
    end
end

--红包信息界面
function ActionyearmonsterController:openActionyearmonsterRedbagEventPanel(status, index)
    if status == false then
        if self.actionyearmonster_redbag_event_panel ~= nil then
            self.actionyearmonster_redbag_event_panel:close()
            self.actionyearmonster_redbag_event_panel = nil
        end
    else
        if self.actionyearmonster_redbag_event_panel == nil then
            self.actionyearmonster_redbag_event_panel = ActionyearmonsterRedbagEventPanel.New()
        end
        self.actionyearmonster_redbag_event_panel:open(index)
    end
end

--挑战boss界面
function ActionyearmonsterController:openActionyearmonsterChallengePanel(status, setting)
    if status == false then
        if self.actionyearmonster_challenge_panel ~= nil then
            self.actionyearmonster_challenge_panel:close()
            self.actionyearmonster_challenge_panel = nil
        end
    else
        if self.actionyearmonster_challenge_panel == nil then
            self.actionyearmonster_challenge_panel = ActionyearmonsterChallengePanel.New()
        end
        self.actionyearmonster_challenge_panel:open(setting)
    end
end
--战斗结算界面
function ActionyearmonsterController:openActionyearmonsterResultPanel(status, data, fight_type)
    if status == false then
        if self.actionyearmonster_result_panel ~= nil then
            self.actionyearmonster_result_panel:close()
            self.actionyearmonster_result_panel = nil
        end
    else
        if self.actionyearmonster_result_panel == nil then
            self.actionyearmonster_result_panel = ActionyearmonsterResultPanel.New(fight_type)
        end
        self.actionyearmonster_result_panel:open(data)
    end
end

-----------------@ 处理事件
-- evt_type:事件类型 index:格子索引
function ActionyearmonsterController:onHandleYearEvtById( evt_type, index )
    self.evt_grid_index = index  -- 这里缓存一下格子id

    if evt_type == ActionyearmonsterConstants.Evt_Type.Normal then -- 空事件
        -- 无需处理
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Monster then -- 怪物(小年兽)
        self:openActionyearmonsterMonsterInfo(true, index)
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Start then -- 出生点
        -- 无需处理
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Board then -- 广告牌
        self:sender28203( index, 0, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Goods then -- 获得道具
        self:sender28203( index, 1, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Dialog then -- 奖励NPC对话
        self:sender28203( index, 0, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.DesBarrier then -- 可破坏的障碍物
        --不知道id不知道怎么处理..
        -- local board_cfg = Config.HolidayNianData.data_board[v.val1]
        -- if board_cfg then
        --     PlanesController:getInstance():openPlanesBoardWindow(true, v.val1, data.index, {show_type = 2, board_cfg = board_cfg })
        -- end
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Barrier then -- 不可破坏的障碍物
        message(TI18N("目标点为不可行走区域，请选择其他目标点"))
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Character then  --获取文字
        self:sender28203( index, 1, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Tribute then  --获取贡品
        self:sender28203( index, 1, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.Fireworks then  --获取烟花
        self:sender28203( index, 1, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.RedBag then  --获取红包
        self:sender28203( index, 1, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.YearMonster then  --年兽
        -- self:openActionyearmonsterChallengePanel(true, {monster_type = 1})
        self:sender28203( index, 0, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.GoldYearMonster then  --黄金年兽
        -- self:openActionyearmonsterChallengePanel(true, {monster_type = 2})
        self:sender28203( index, 0, {} )
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.YearMonster_nothit then  --年兽(不可挑战)
        message(TI18N("相传收集附近的贡品，可以将其唤醒~"))
    elseif evt_type == ActionyearmonsterConstants.Evt_Type.GoldYearMonster_nothit then  --黄金年兽 (不可挑战)
        message(TI18N("嘘~金色年兽正在沉睡呢~不要惊动它"))
    end
end

-- 事件处理返回
function ActionyearmonsterController:handle28205( data )
    local evt_vo = self.model:getYearEvtVoByGridIndex(data.index)
    if not evt_vo or not evt_vo.config then return end

    if data.ext_list and next(data.ext_list) ~= nil then
        for k,v in pairs(data.ext_list) do
            if v.type == ActionyearmonsterConstants.Proto_28205.Dialog then
                local dialog_cfg = Config.HolidayNianData.data_dialogue[v.val1]
                if dialog_cfg then
                    ActionController:getInstance():openActionTimeCollectWindow(true,80, data.index, dialog_cfg)
                end
            elseif v.type == ActionyearmonsterConstants.Proto_28205.Board  then --广告牌
                local board_cfg = Config.HolidayNianData.data_board[v.val1]
                if board_cfg then
                    PlanesController:getInstance():openPlanesBoardWindow(true, v.val1, data.index, {show_type = 2, board_cfg = board_cfg })
                end
            elseif v.type == ActionyearmonsterConstants.Proto_28205.Goods then--获取道具
                -- v.type == ActionyearmonsterConstants.Evt_Type.Character or --获取文字
                -- v.type == ActionyearmonsterConstants.Evt_Type.Tribute or -- 获取贡品
                -- v.type == ActionyearmonsterConstants.Evt_Type.Fireworks  then --获取烟花
                self:showEvtItem(v.val1)
            elseif v.type == ActionyearmonsterConstants.Proto_28205.DesBarrier then--可破坏道具
            elseif v.type == ActionyearmonsterConstants.Proto_28205.YearMonster then--大年兽
            elseif v.type == ActionyearmonsterConstants.Proto_28205.GoldYearMonster then--金年兽

            end
        end
    end
end

function ActionyearmonsterController:showEvtItem(item_bid)
    if not item_bid then return end
    local items = {{bid = item_bid, num = 1}}
    MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true}, MainuiConst.item_open_type.normal)
end

---------------------------------------集字兑换--------------------------------------------
--集字兑换 
function ActionyearmonsterController:sender28216( id,num)
    local protocal = {}
    protocal.id = id
    protocal.num = num
    self:SendProtocal(28216, protocal)
end

--集字兑换
function ActionyearmonsterController:handle28216(data)
    message(data.msg)
end

--集字兑换界面 
function ActionyearmonsterController:sender28217()
    local protocal = {}
    self:SendProtocal(28217, protocal)
end

--集字兑换界面
function ActionyearmonsterController:handle28217(data)
    self.model:setExchangeData(data)
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.UPDATE_EXCHANGE_DATA_EVENT)
end

--集字兑换界面
function ActionyearmonsterController:openActionyearmonsterExchangeWindow(status)
    if status == false then
        if self.actionyearmonster_exchange_window ~= nil then
            self.actionyearmonster_exchange_window:close()
            self.actionyearmonster_exchange_window = nil
        end
    else
        if self.actionyearmonster_exchange_window == nil then
            self.actionyearmonster_exchange_window = ActionyearmonsterExchangeWindow.New()
        end
        self.actionyearmonster_exchange_window:open()
    end
end

--保存年兽表情 
function ActionyearmonsterController:sender28219(face)
    local protocal = {}
    protocal.face = face
    self:SendProtocal(28219, protocal)
end

--保存年兽表情
function ActionyearmonsterController:handle28219(data)
    message(data.msg)
end

--个人年兽表情
function ActionyearmonsterController:sender28220()
    local protocal = {}
    self:SendProtocal(28220, protocal)
end

function ActionyearmonsterController:handle28220(data)
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Face_Event, data)
end

--使用烟花
function ActionyearmonsterController:sender28221()
    local protocal = {}
    self:SendProtocal(28221, protocal)
end

function ActionyearmonsterController:handle28221(data)
    message(data.msg)
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Five_Effect_Event,data)    
end

--交互玩家数据
function ActionyearmonsterController:sender28222()
    local protocal = {}
    self:SendProtocal(28222, protocal)
end

function ActionyearmonsterController:handle28222(data)
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Year_Other_Role_Event, data)    
end

--请求主界面红包
function ActionyearmonsterController:sender28223()
    local protocal = {}
    self:SendProtocal(28223, protocal)
end


function ActionyearmonsterController:handle28223(data)
    GlobalEvent:getInstance():Fire(ActionyearmonsterEvent.Update_Year_Main_Redbag_Event, data.flag)    
end

--请求主界面红包
function ActionyearmonsterController:sender28224()
    local protocal = {}
    self:SendProtocal(28224, protocal)
end


function ActionyearmonsterController:handle28224(data)
    if data.timer_flag == 1 or data.gold_flag == 1 then
        if not MainuiController:getInstance().is_click_yearmoster then
            PromptController:getInstance():getModel():addPromptData({type = PromptTypeConst.Year_Monster_tips})
        end
    else
        PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Year_Monster_tips)
    end
end





function ActionyearmonsterController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end