-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面改版 参考afk的 后端 国辉 策划 中建
-- <br/>Create: 2020-02-05
-- --------------------------------------------------------------------
PlanesafkController = PlanesafkController or BaseClass(BaseController)

function PlanesafkController:config()
    self.model = PlanesafkModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PlanesafkController:getModel()
    return self.model
end

function PlanesafkController:registerEvents()
    if not self.close_item_event then
        self.close_item_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function(data)
            if self.model:getIsShowSearchFinish() then
                self.model:setIsShowSearchFinish(false)
                self:openPlanesafkResultPanel(true)
            end
        end)
    end
end

function PlanesafkController:registerProtocals()
    self:RegisterProtocal(28600, "handle28600") -- 操作指定格子事件
    self:RegisterProtocal(28601, "handle28601") -- 进入副本
    self:RegisterProtocal(28602, "handle28602") -- 基础数据信息
    self:RegisterProtocal(28603, "handle28603") -- 该层格子数据信息
    self:RegisterProtocal(28604, "handle28604") -- 进入下一层
    self:RegisterProtocal(28605, "handle28605") -- 获得该层通关奖励

    self:RegisterProtocal(28606, "handle28606") -- 格子数据更新
    self:RegisterProtocal(28607, "handle28607") -- 获取对方阵容信息
    self:RegisterProtocal(28608, "handle28608") -- 战斗结果
    self:RegisterProtocal(28609, "handle28609") -- 回血事件英雄变换
    self:RegisterProtocal(28610, "handle28610") -- 计算变阵后总战力
    self:RegisterProtocal(28611, "handle28611") -- 保存阵法
    self:RegisterProtocal(28612, "handle28612") -- 请求阵法
    self:RegisterProtocal(28613, "handle28613") -- 英雄背包
    self:RegisterProtocal(28614, "handle28614") -- 事件信息返回
    self:RegisterProtocal(28615, "handle28615") -- 对话Id

    self:RegisterProtocal(28620, "handle28620") -- buff列表
    self:RegisterProtocal(28621, "handle28621") -- 商人列表
    self:RegisterProtocal(28622, "handle28622") -- 英雄租借
    self:RegisterProtocal(28623, "handle28623") -- 查看英雄信息
    self:RegisterProtocal(28624, "handle28624") -- 领取奖励更新
    self:RegisterProtocal(28625, "handle28625") -- 本日已领取奖励

    self:RegisterProtocal(28616, "handle28616") -- 位面战令基础信息
    self:RegisterProtocal(28617, "handle28617") -- 一键领取等级礼包
    self:RegisterProtocal(28618, "handle28618") -- 周期重置红点
    self:RegisterProtocal(28619, "handle28619") -- 是否要弹窗

    self:RegisterProtocal(28626, "handle28626") -- 日记要求
end

function PlanesafkController:sender28626()
    self:SendProtocal(28626, {})
end

function PlanesafkController:handle28626()
    -- body
end

-- 操作指定格子事件
--is_fight 是否进入战斗
function PlanesafkController:sender28600(line, index, action, ext_list , extend, is_fight)
    local protocal = {}
    protocal.line = line 
    protocal.index = index
    protocal.action = action
    protocal.ext_list = ext_list or {}

    self.evt_extend = extend -- 额外数据
    if is_fight then
        --本次是申请进入战斗的

        local delay_time = 0.4
        if self.planesafk_main_window then
            local is_hide = self.planesafk_main_window:updateScrollviewByIndex(line, index)
            if is_hide then
                self.planesafk_main_window:isLockPlanesMapScreen(true)-- 解除锁屏
            else
                delay_time = 0
            end
        end
        if delay_time == 0 then
            self:SendProtocal(28600, protocal)
        else
            delayOnce(function (  )
                if self.planesafk_main_window then
                    self.planesafk_main_window:isLockPlanesMapScreen(false)-- 解除锁屏
                end
                self:SendProtocal(28600, protocal)
            end, delay_time)
        end
    else
        self:SendProtocal(28600, protocal)    
    end
    
end

function PlanesafkController:handle28600( data )
    message(data.msg)

     -- 事件成功，可能需要做一些表现（例如buff图标动画）
    if data.code == TRUE and self.evt_extend and self.evt_extend.data and 
        self.evt_extend.data.line == data.line and self.evt_extend.data.index == data.index  then
        if self.evt_extend.buff_id and self.evt_extend.world_pos then -- 选择buff成功，播放飘动动画
            GlobalEvent:getInstance():Fire(PlanesafkEvent.Chose_Buff_Event, self.evt_extend.buff_id, self.evt_extend.world_pos)
            self:openPlanesafkBuffChoseWindow(false)
        end
        self.evt_extend = nil
    end
end

-- 主动触发格子事件(必须在场景地图内)
function PlanesafkController:initiativeTriggerEvtByIndex(line, index )
    if not line or line == 0 then return end
    if not index or index == 0  then return end
    if not self.planesafk_main_window  then return end

    local evt_vo = self:getMapEvtData(line, index)
    --暂时只触发buff事件
    if evt_vo and evt_vo.evt_config and evt_vo.evt_config.type == PlanesafkConst.Evt_Type.Buff then
        self:onHandlePlanesEvtById(evt_vo.evt_config.type, {line = line, index = index})
    end
end

-----------------@ 处理事件
-- evt_type:事件类型 index:格子索引
-- function PlanesafkController:onHandlePlanesEvtById( evt_type, line, index, is_black )
--data 28603协议返回的单个list数据
--data.evt_config --Config.PlanesData.data_evt_info[self.data.evt_id]
function PlanesafkController:onHandlePlanesEvtById( evt_type, data)
    if not data then return end
    if evt_type == PlanesafkConst.Evt_Type.Normal then -- 空事件
        -- 无需处理
    elseif evt_type == PlanesafkConst.Evt_Type.Monster then -- 怪物
        self:openPlanesafkMasterWindow(true, data)
    elseif evt_type == PlanesafkConst.Evt_Type.Guard then -- 守卫
        self:openPlanesafkMasterWindow(true, data)
    elseif evt_type == PlanesafkConst.Evt_Type.Recover then -- 英雄恢复(回复泉水)
        if self.model:getAllPlanesHeroData() ~= nil then --英雄信息回来了才响应事件
            local cfg = {btn_str="浸泡", res_id="board_img_7", title="回复泉水"}
            local config = Config.PlanesData.data_const.cure_desc
            if config then
                cfg.desc_1 = config.desc
            else
                cfg.desc_1 = TI18N("浸泡泉水可使所有存活的英雄恢复<div fontcolor=289b14>30%</div>的生命值，泉水仅可使用一次。")
            end
            self:openPlanesafkBoardWindow(true, PlanesafkConst.Recover_Id, data, {board_cfg = cfg})
        end
    elseif evt_type == PlanesafkConst.Evt_Type.Revive then -- 英雄恢复(复活祭坛)
        if self.model:getAllPlanesHeroData() ~= nil then --英雄信息回来了才响应事件
            local cfg = {btn_str="复活", res_id="board_img_4", title="复活十字架"}
            local config = Config.PlanesData.data_const.reborn_desc
            if config then
                cfg.desc_1 = config.desc
            else
                cfg.desc_1 = TI18N("可以随机复活一位已阵亡的英雄并回复其<div fontcolor=289b14>70%</div>的生命值，若当前无阵亡英雄则回复生命值最低的一位英雄<div fontcolor=289b14>100%</div>的生命。")
            end
            self:openPlanesafkBoardWindow(true, PlanesafkConst.Revive_Id, data, {board_cfg = cfg})
        end
    elseif evt_type == PlanesafkConst.Evt_Type.LeaseHero then -- 租借英雄
        self:sender28600(data.line, data.index, 0, {} )
    elseif evt_type == PlanesafkConst.Evt_Type.Buff then -- buff列表
        self:sender28600(data.line, data.index, 0, {} )
    elseif evt_type == PlanesafkConst.Evt_Type.Businessman then -- 商人
        self:sender28600(data.line, data.index, 0, {} )
    elseif evt_type == PlanesafkConst.Evt_Type.Occurrence then -- 矿点

    end
end


-- 事件信息返回 对应旧位面的 23108
function PlanesafkController:handle28614( data )
    if data.ext_list and next(data.ext_list) ~= nil then
        local dic_type = {}
        for k,v in pairs(data.ext_list) do
            if dic_type[v.type] == nil then
                dic_type[v.type] = {}
            end
            if v.type == 1 then   --buff选择
                if dic_type[v.type].buff_bid_list == nil then
                    dic_type[v.type].buff_bid_list = {}
                end
                table.insert(dic_type[v.type].buff_bid_list, v.val1)
            end
        end
        for _type, v in pairs(dic_type) do
            if _type == 1 then --buff选择
                self:openPlanesafkBuffChoseWindow(true, v.buff_bid_list, data)
            end
        end
    end
    

    -- if evt_vo.config.type == PlanesConst.Evt_Type.Dialog and dialog_id then -- 对话
    --     local dialog_cfg = Config.SecretDunData.data_dialogue[dialog_id]
    --     if dialog_cfg then
    --         MonopolyController:getInstance():openMonopolyDialogWindow(true, 88, data.index, dialog_cfg)
    --     end
    -- elseif evt_vo.config.type == PlanesConst.Evt_Type.Board and board_bid then -- 广告牌
    --     self:openPlanesBoardWindow(true, board_bid)
    -- elseif evt_vo.config.type == PlanesConst.Evt_Type.Buff and next(buff_bid_list) ~= nil then -- buff选择
    --     self:openPlanesBuffChoseWindow(true, buff_bid_list, data.index)
    -- end
    -- if item_bid then
    --     local items = {{bid = item_bid, num = 1}}
    --     MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true}, MainuiConst.item_open_type.normal)
    -- end
end

-- 进入副本
function PlanesafkController:sender28601( )
    if not PlanesafkController:getInstance():checkPlanesIsOpen() then return end
    local protocal = {}
    self:SendProtocal(28601, protocal)
end

function PlanesafkController:handle28601( data )
     message(data.msg)
    if data.flag == TRUE then
        -- BattleConst.Fight_Type.PlanesWar = 40
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PlanesWar)
    end
end

-- 基础数据信息
function PlanesafkController:sender28602( )
    local protocal = {}
    self:SendProtocal(28602, protocal)
end

function PlanesafkController:handle28602( data )
    self.model:setPlanesRoleLookId(data.look_id)
    self.model:setHolidayOpen(data.is_holiday)
    HomeworldController:getInstance():getModel():setMyCurHomeFigureId(data.look_id)
    HomeworldController:getInstance():getModel():setActivateFigureList(data.list, true)

    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Main_Base_Info_Event, data)
end

-- 地图信息
function PlanesafkController:sender28603( )
    local protocal = {}
    self:SendProtocal(28603, protocal)
end

function PlanesafkController:handle28603( data )
    if not self.is_first_open then
        self.is_first_open = true
        self.model:checkPlaneafkCanExploreRedPoint(data)
    end
    if data.floor == 0 then
        self:openPlanesafkOrderactionWindow(false)
        self:openPlanesafkEndWarnView(false)
        self:openBuyCardView(false)
        self:openPlanesafkBoardWindow(false)
        self:openPlanesafkChooseDifficultyPanel(false)
        self:openPlanesafkMasterWindow(false)
        self:openPlanesafkItemUsePanel(false)
        self:openPlanesafkHeroListPanel(false)
        self:openPlanesafkBuffChoseWindow(false)
        self:openPlanesafkBuffListPanel(false)
        self:openPlanesafkHireHeroWindow(false)
        self:openPlanesafkResultPanel(false)

        self:openPlanesafkMainWindow(false) --最后才关闭主界面
        return
    end
    if data.floor == 1 then
        self.model:setIsShowSearchFinish(false)
    end
    
    self.model:setMapData(data)
    self.model:updateRolePos(data)
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Main_Map_Info_Event, data)
end


--领取奖励更新
function PlanesafkController:handle28624( data )
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Last_Reward_Info_Event, data)
end

-- 本日已领取
function PlanesafkController:sender28625( )
    local protocal = {}
    self:SendProtocal(28625, protocal)
end

function PlanesafkController:handle28625( data )
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Update_Get_Reward_Event, data)
end
-- 进入下一层
function PlanesafkController:sender28604(floor, difficulty)
    local protocal = {}
    protocal.floor = floor
    protocal.difficulty = difficulty
    self:SendProtocal(28604, protocal)
end

function PlanesafkController:handle28604( data )
    message(data.msg)
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Next_Map_Info_Event, data)
    end
end

-- 获取通关奖励
function PlanesafkController:sender28605(floor)
    local protocal = {}
    protocal.floor = floor
    self:SendProtocal(28605, protocal)
end

function PlanesafkController:handle28605( data )
    message(data.msg)
    if data.flag == TRUE then
        GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Pass_Reward_Info_Event, data)
    end
end

-- 格子数据更新
function PlanesafkController:handle28606( data )
    self.model:updateRolePos(data)
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Update_Map_Info_Event, data)
end

-- 对方阵容数据
function PlanesafkController:handle28607( data )
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Get_Master_Data_Event, data)
end

-- 战斗结果
function PlanesafkController:handle28608( data )
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.PlanesWar, data)
end

-- 更新英雄血量数据 --回血事件英雄变换
function PlanesafkController:handle28609( data )
    if data.partners and next(data.partners) ~= nil then
        self.model:updateMyHeroData(data.partners)
    end
end

-- 请求上阵英雄战力总和 计算变阵后总战力
function PlanesafkController:sender28610( partner_ids )
    local protocal = {}
    protocal.partner_ids = partner_ids
    self:SendProtocal(28610, protocal)
end

function PlanesafkController:handle28610( data )
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Update_Form_Atk_Event, data.power)
end

-- 请求保存阵法
function PlanesafkController:sender28611( formation_type, pos_info, hallows_id )
    local protocal = {}
    protocal.formation_type = formation_type
    protocal.pos_info = pos_info
    protocal.hallows_id = hallows_id
    self:SendProtocal(28611, protocal)
end

function PlanesafkController:handle28611( data )
    if data.msg ~= "" then
        message(data.msg)
    end
    if data.flag == 1 then
        GlobalEvent:getInstance():Fire(PlanesafkEvent.Save_Form_Success_Event) 
    end
end

-- 请求位面阵容
function PlanesafkController:sender28612(  )
    self:SendProtocal(28612, {})
end

function PlanesafkController:handle28612( data )
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Get_Form_Data_Event, data) 
end

-- 请求英雄背包数据
function PlanesafkController:sender28613(  )
    self:SendProtocal(28613, {})
end

function PlanesafkController:handle28613( data )
    self.model:setAllPlanesHeroData(data.partners)
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Get_All_Hero_Event)
end

-- 触发剧情对话 对应旧位面 23111
function PlanesafkController:handle28615( data )
    -- 待处理--“lwc

    -- local dram_cfg = Config.SecretDunData.data_drama[data.id]
    -- if dram_cfg then
    --     -- 如果在场景内，则直接显示剧情对话，否则先缓存，进入场景后再显示
    --     if self.planes_map_wnd then
    --         -- 延迟 0.5 秒执行
    --         delayOnce(function (  )
    --             MonopolyController:getInstance():openMonopolyDialogWindow(true, 89, 0, dram_cfg)
    --         end, 0.5)
    --     else
    --         self.model:setPlanesDramIdCache(data.id)
    --     end
    -- end
end


-- 请求所有buff列表
function PlanesafkController:sender28620(  )
    self:SendProtocal(28620, {})
end

function PlanesafkController:handle28620( data )
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Get_Buff_Data_Event, data.buffs)
end


-- 返回商人信息
function PlanesafkController:handle28621( data )
    if self.planesafk_evt_shop_panel then
        GlobalEvent:getInstance():Fire(PlanesafkEvent.Evt_Shop_Event, data)
    else
        self:openPlanesafkEvtShopPanel(true, data)
    end
end

-- 返回租借英雄事件的数据
function PlanesafkController:handle28622( data )
    self:openPlanesafkHireHeroWindow(true, data)
end

function PlanesafkController:sender28623( pos )
    local protocal = {}
    protocal.pos = pos
    self:SendProtocal(28623, protocal)
end

function PlanesafkController:handle28623( data )
    HeroController:getInstance():openHeroTipsPanel(true, data)
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Look_Other_Hero_Event, data)
end

-- 打开雇佣英雄界面
function PlanesafkController:openPlanesafkHireHeroWindow( status, data)
    if not self.planesafk_main_window then return end
    if status == true then
        if not self.hire_hero_wnd then
            self.hire_hero_wnd = PlanesafkHireHeroWindow.New()
        end
        if self.hire_hero_wnd:isOpen() == false then
            self.hire_hero_wnd:open(data)
        end
    else
        if self.hire_hero_wnd then
            self.hire_hero_wnd:close()
            self.hire_hero_wnd = nil
        end
    end
end

function PlanesafkController:getMapEvtData(line, index)
    if self.planesafk_main_window then
        return self.planesafk_main_window:getMapEvtData(line, index)
    end
end


-- 打开位面冒险主界面
function PlanesafkController:openPlanesafkMainWindow( status, setting )
    if status == true then
        if not self.planesafk_main_window then
            self.planesafk_main_window = PlanesafkMainWindow.New()
        end
        if self.planesafk_main_window:isOpen() == false then
            self.planesafk_main_window:open(setting)
        end
    else
        if self.planesafk_main_window then
            self.planesafk_main_window:close()
            self.planesafk_main_window = nil
        end
    end
end

-- 打开位面遗物列表
function PlanesafkController:openPlanesafkBuffListPanel( status, setting )
    if status == true then
        if not self.planesafk_buff_list_panel then
            self.planesafk_buff_list_panel = PlanesafkBuffListPanel.New()
        end
        if self.planesafk_buff_list_panel:isOpen() == false then
            self.planesafk_buff_list_panel:open(setting)
        end
    else
        if self.planesafk_buff_list_panel then
            self.planesafk_buff_list_panel:close()
            self.planesafk_buff_list_panel = nil
        end
    end
end

-- 打开buff选择界面
function PlanesafkController:openPlanesafkBuffChoseWindow( status, buff_list, data )
    if status == true then
        if not self.buff_chose_wnd then
            self.buff_chose_wnd = PlanesafkBuffChoseWindow.New()
        end
        if self.buff_chose_wnd:isOpen() == false then
            self.buff_chose_wnd:open(buff_list, data)
        end
    else
        if self.buff_chose_wnd then
            self.buff_chose_wnd:close()
            self.buff_chose_wnd = nil
        end
    end
end

-- 打开位面英雄列表
function PlanesafkController:openPlanesafkHeroListPanel( status, setting )
    if status == true then
        if not self.planesafk_hero_list_panel then
            self.planesafk_hero_list_panel = PlanesafkHeroListPanel.New()
        end
        if self.planesafk_hero_list_panel:isOpen() == false then
            self.planesafk_hero_list_panel:open(setting)
        end
    else
        if self.planesafk_hero_list_panel then
            self.planesafk_hero_list_panel:close()
            self.planesafk_hero_list_panel = nil
        end
    end
end

-- 打开使用道具
function PlanesafkController:openPlanesafkItemUsePanel( status, setting )
    if status == true then
        if not self.planesafk_item_use_panel then
            self.planesafk_item_use_panel = PlanesafkItemUsePanel.New()
        end
        if self.planesafk_item_use_panel:isOpen() == false then
            self.planesafk_item_use_panel:open(setting)
        end
    else
        if self.planesafk_item_use_panel then
            self.planesafk_item_use_panel:close()
            self.planesafk_item_use_panel = nil
        end
    end
end

-- 打开位面困难择界面
function PlanesafkController:openPlanesafkChooseDifficultyPanel( status, setting )
    if status == true then
        if not self.planesafk_choose_difficulty_panel then
            self.planesafk_choose_difficulty_panel = PlanesafkChooseDifficultyPanel.New()
        end
        if self.planesafk_choose_difficulty_panel:isOpen() == false then
            self.planesafk_choose_difficulty_panel:open(setting)
        end
    else
        if self.planesafk_choose_difficulty_panel then
            self.planesafk_choose_difficulty_panel:close()
            self.planesafk_choose_difficulty_panel = nil
        end
    end
end

-- 打开位面商人
function PlanesafkController:openPlanesafkEvtShopPanel( status, setting )
    
    if status == true then
        if not self.planesafk_main_window then return end
        if not self.planesafk_evt_shop_panel then
            self.planesafk_evt_shop_panel = PlanesafkEvtShopPanel.New()
        end
        if self.planesafk_evt_shop_panel:isOpen() == false then
            self.planesafk_evt_shop_panel:open(setting)
        end
    else
        if self.planesafk_evt_shop_panel then
            self.planesafk_evt_shop_panel:close()
            self.planesafk_evt_shop_panel = nil
        end
    end
end

-- 矿点事件
function PlanesafkController:openPlanesafkEvtOccurrencePanel( status, setting )
    if status == true then
        if not self.planesafk_evt_occurrence_panel then
            self.planesafk_evt_occurrence_panel = PlanesafkEvtOccurrencePanel.New()
        end
        if self.planesafk_evt_occurrence_panel:isOpen() == false then
            self.planesafk_evt_occurrence_panel:open(setting)
        end
    else
        if self.planesafk_evt_occurrence_panel then
            self.planesafk_evt_occurrence_panel:close()
            self.planesafk_evt_occurrence_panel = nil
        end
    end
end

-- 打开敌方阵容界面
function PlanesafkController:openPlanesafkMasterWindow( status, data )
    if status == true then
        if not self.master_info_wnd then
            self.master_info_wnd = PlanesafkMasterWindow.New()
        end
        if self.master_info_wnd:isOpen() == false then
            self.master_info_wnd:open(data)
        end
    else
        if self.master_info_wnd then
            self.master_info_wnd:close()
            self.master_info_wnd = nil
        end
    end
end

-- 打开广告牌界面
function PlanesafkController:openPlanesafkBoardWindow( status, id, data, setting )
    if status == true then
        if not self.planes_board_wnd then
            self.planes_board_wnd = PlanesafkBoardWindow.New()
        end
        if self.planes_board_wnd:isOpen() == false then
            self.planes_board_wnd:open(id, data, setting)
        end
    else
        if self.planes_board_wnd then
            self.planes_board_wnd:close()
            self.planes_board_wnd = nil
        end
    end
end
-- 打开探索结束界面
function PlanesafkController:openPlanesafkResultPanel( status, setting )
    if status == true then
        if not self.planesafk_result_panel then
            self.planesafk_result_panel = PlanesafkResultPanel.New()
        end
        if self.planesafk_result_panel:isOpen() == false then
            self.planesafk_result_panel:open(id, setting)
        end
    else
        if self.planesafk_result_panel then
            self.planesafk_result_panel:close()
            self.planesafk_result_panel = nil
        end
    end
end


-----------------------------------------位面战令活动---------------------------------------------
-- 战令基本信息
function PlanesafkController:sender28616()
    local protocal = {}
    self:SendProtocal(28616, protocal)
end

function PlanesafkController:handle28616(data)
    self.model:setOrderactionData(data)
    self.model:checkPlanesafkRedPoint()
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_OrderAction_Init_Event, data)
end

--一键领取礼包
function PlanesafkController:sender28617(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(28617, protocal)
end

function PlanesafkController:handle28617(data)
    if data then
        message(data.msg)
    end
end

--红点
function PlanesafkController:sender28618()
    local protocal = {}
    self:SendProtocal(28618, protocal)
end

function PlanesafkController:handle28618(data)
    if data then
        self.model:setOrderactionRedStatus(data.flag)
        self.model:checkPlanesafkRedPoint()
    end
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_OrderAction_First_Red_Event)
end

--位面活动提示
function PlanesafkController:sender28619()
    local protocal = {}
    self:SendProtocal(28619, protocal)
end

function PlanesafkController:handle28619(data)
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_OrderAction_IsPopWarn_Event,data)
end

--打开主界面
function PlanesafkController:openPlanesafkOrderactionWindow(status)
    if status == true then
        local configlv = Config.PlanesWarOrderData.data_constant.limit_lev
        local configday = Config.PlanesWarOrderData.data_constant.open_srv_day
        local open_srv_day = RoleController:getInstance():getModel():getOpenSrvDay()
        local rolevo = RoleController:getInstance():getModel():getRoleVo()
        -- 是否开启planes_war_order_data:
        if configday and configlv and rolevo and (open_srv_day < configday.val or rolevo.lev < configlv.val) then
            message(string.format(TI18N("角色%d级且开服%d天开启"),configlv.val,configday.val))
            return
        end

        if not self.planesafk_orderaction_window then
            self.planesafk_orderaction_window = PlanesafkOrderactionWindow.New()
        end
        self.planesafk_orderaction_window:open()
    else
        if self.planesafk_orderaction_window then 
            self.planesafk_orderaction_window:close()
            self.planesafk_orderaction_window = nil
        end
    end
end

--购买进阶卡
function PlanesafkController:openBuyCardView(status)
    if status == true then
        if not self.buy_card_view then
            self.buy_card_view = PlanesafkOrderactionUntieRewardWindow.New()
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
function PlanesafkController:openPlanesafkEndWarnView(status,day)
    if status == true then
        if not self.end_warn_view then
            self.end_warn_view = PlanesafkOrderActionEndWarnWindow.New()
        end
        self.end_warn_view:open(day)
    else
        if self.end_warn_view then 
            self.end_warn_view:close()
            self.end_warn_view = nil
        end
    end
end
-----------------------------------------位面战令活动end---------------------------------------------

-- 位面功能是否开启
function PlanesafkController:checkPlanesIsOpen( not_tips )
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_lv_cfg = Config.PlanesData.data_const["planes_open_lev"]
    if limit_lv_cfg then
        if role_vo.lev >= limit_lv_cfg.val then
            return true
        else
            if not not_tips then
                message(limit_lv_cfg.desc)
            end
            return false
        end
    else
        return false
    end
end

function PlanesafkController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end