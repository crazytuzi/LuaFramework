-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-11-26
-- --------------------------------------------------------------------
PlanesController = PlanesController or BaseClass(BaseController)

function PlanesController:config()
    self.model = PlanesModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PlanesController:getModel()
    return self.model
end

function PlanesController:registerEvents()
end

function PlanesController:registerProtocals()
    self:RegisterProtocal(23100, "handle23100") -- 副本基础数据
    self:RegisterProtocal(23101, "handle23101") -- 地图格子数据
    self:RegisterProtocal(23102, "handle23102") -- 更新部分地图格子数据
    self:RegisterProtocal(23103, "handle23103") -- 请求移动到某一格子
    self:RegisterProtocal(23104, "handle23104") -- 请求操作格子事件
    self:RegisterProtocal(23105, "handle23105") -- 请求进入副本
    self:RegisterProtocal(23106, "handle23106") -- 请求进入层数
    self:RegisterProtocal(23107, "handle23107") -- 租借宝可梦事件数据
    self:RegisterProtocal(23108, "handle23108") -- 事件处理返回
    self:RegisterProtocal(23109, "handle23109") -- 对方阵容数据
    self:RegisterProtocal(23110, "handle23110") -- 战斗结果
    self:RegisterProtocal(23111, "handle23111") -- 剧情对话
    self:RegisterProtocal(23112, "handle23112") -- 请求背包数据
    self:RegisterProtocal(23113, "handle23113") -- 背包数据更新、新增
    self:RegisterProtocal(23114, "handle23114") -- 背包数据删除
    self:RegisterProtocal(23115, "handle23115") -- 可出战宝可梦数据（包括雇佣的）
    self:RegisterProtocal(23116, "handle23116") -- 雇佣宝可梦详细数据
    self:RegisterProtocal(23117, "handle23117") -- 领取首通奖励
    self:RegisterProtocal(23118, "handle23118") -- 所有buff数据
    self:RegisterProtocal(23119, "handle23119") -- 更新宝可梦血量数据
    self:RegisterProtocal(23120, "handle23120") -- 请求上阵宝可梦总战力
    self:RegisterProtocal(23121, "handle23121") -- 保存阵法
    self:RegisterProtocal(23122, "handle23122") -- 请求阵法
end

-- 位面冒险副本基础数据
function PlanesController:sender23100(  )
    self:SendProtocal(23100, {})
end

function PlanesController:handle23100( data )
    self.model:setCurDunId(data.dun_id)
    self.model:setCurDunProgressVal(data.val, data.max_val)
    self.model:setCanChoseDunList(data.ids)
    self.model:setGotFirstAwardDunList(data.reward_ids)
    self.model:setCanGetAwardDunList(data.can_reward_ids)
    self.model:setPlanesResetTime(data.update_time)
    self.model:setPlanesRoleLookId(data.look_id)
    self.model:setHolidayOpen(data.is_holiday)
    HomeworldController:getInstance():getModel():setMyCurHomeFigureId(data.look_id)
    HomeworldController:getInstance():getModel():setActivateFigureList(data.list, true)
    if data.dun_id == 0 and self.planes_map_wnd then -- 当前副本id为0且处于地图场景界面中（重置时）,强制关闭场景界面
        self:openPlanesMapWindow(false)
    end
    GlobalEvent:getInstance():Fire(PlanesEvent.Update_Dun_Base_Event)
end

-- 地图格子数据
function PlanesController:handle23101( data )
    if data.floor then
        self.model:setCurPlanesFloor(data.floor)
    end
    if data.tile_list and next(data.tile_list) ~= nil then
        self.model:setPlanesEvtVoList(data.tile_list)
    end
    GlobalEvent:getInstance():Fire(PlanesEvent.Update_Map_Data_Event, data)
end

-- 更新部分地图格子数据
function PlanesController:handle23102( data )
    if data.floor ~= self.model:getCurPlanesFloor() then return end
    if data.tile_list and next(data.tile_list) ~= nil then
        -- 更新事件
        self.model:updatePlanesEvtVoList(data.tile_list)
        -- 更新格子
        GlobalEvent:getInstance():Fire(PlanesEvent.Update_Grid_Event, data.tile_list)
    end
end

-- 通知后端移动到某一格子
function PlanesController:sender23103( index )
    local protocal = {}
    protocal.index = index
    self:SendProtocal(23103, protocal)
end

function PlanesController:handle23103( data )
    if data.msg and data.msg ~= "" then
        message(data.msg)
    end
    GlobalEvent:getInstance():Fire(PlanesEvent.Update_Role_Grid_Event, data)
end

-- 请求操作格子事件
function PlanesController:sender23104( index, action, ext_list, extend )
    -- if self.planes_map_wnd then
    --     self.planes_map_wnd:isLockPlanesMapScreen(true) -- 位面锁屏，禁止角色移动
    -- end
    local protocal = {}
    protocal.index = index or self.evt_grid_index
    protocal.action = action
    protocal.ext_list = ext_list or {}
    self.evt_extend = extend -- 额外数据
    local evt_vo = self.model:getPlanesEvtVoByGridIndex(protocal.index)
    if evt_vo and evt_vo.config and evt_vo.config.group_id ~= 0 and action == 1 then -- 多选一事件，要弹出确认框
        local show_break_index_list = self.model:getPlanesSameGroupIndexList(evt_vo.config.group_id, protocal.index) -- 相同事件组id，且是显示状态
        if next(show_break_index_list) == nil then
            self:SendProtocal(23104, protocal)
        else
            local tips_str = string.format(TI18N("若选择触发该事件后，附近命运台阶和其中的事件将消失，是否确定选择【%s】事件？"), evt_vo.config.name)
            if self.confirm_alert then
                self.confirm_alert:close()
                self.confirm_alert = nil
            end
            local cancel_callback = function() 
                if self.planes_map_wnd then
                    self.planes_map_wnd:isLockPlanesMapScreen(false)-- 解除锁屏
                end
            end
            self.confirm_alert = CommonAlert.show(tips_str, TI18N("确认"), function (  )
                if self.planes_map_wnd then
                    self.planes_map_wnd:isLockPlanesMapScreen(true) -- 锁屏，防止0.5秒内玩家移动角色位置
                end
                GlobalEvent:getInstance():Fire(PlanesEvent.Show_Break_Effect_Event, show_break_index_list)
                -- 延迟触发，等地块裂开特效播完（选buff事件特殊处理）
                local delay_time = 0.5
                if evt_vo and evt_vo.config and evt_vo.config.type == PlanesConst.Evt_Type.Buff then
                    delay_time = 0
                end
                delayOnce(function (  )
                    if self.planes_map_wnd then
                        self.planes_map_wnd:isLockPlanesMapScreen(false)-- 解除锁屏
                    end
                    self:SendProtocal(23104, protocal)
                end, delay_time)
            end, TI18N("取消"), cancel_callback)
        end
    else
        self:SendProtocal(23104, protocal)
    end
end

function PlanesController:handle23104( data )
    -- if self.planes_map_wnd then
    --     self.planes_map_wnd:isLockPlanesMapScreen(false) -- 位面锁屏解除
    -- end
    if data.msg and data.msg ~= "" then
        message(data.msg)
    end
    -- 事件成功，可能需要做一些表现（例如buff图标动画）
    if data.code == TRUE and self.evt_extend and self.evt_extend.index == data.index then
        if self.evt_extend.buff_id and self.evt_extend.world_pos then -- 选择buff成功，播放飘动动画
            GlobalEvent:getInstance():Fire(PlanesEvent.Chose_Buff_Event, self.evt_extend.buff_id, self.evt_extend.world_pos)
            self:openPlanesBuffChoseWindow(false)
        end
        self.evt_extend = nil
    end
end

-- 请求进入副本
function PlanesController:sender23105( id )
    local protocal = {}
    protocal.id = id
    if self.model:getCurDunId() == 0 then -- 如果是开启副本，需要特殊处理
        self.is_open_dun_flag = true
    else
        self.is_open_dun_flag = false
    end
    -- 锁屏，防止连续点击
    if self.planes_main_wnd then
        self.planes_main_wnd:onLockScreenCallBack(true)
    end
    self:SendProtocal(23105, protocal)
end

function PlanesController:handle23105( data )
    if data.msg and data.msg ~= "" then
        message(data.msg)
    end
    -- 进入副本成功则打开地图界面
    if data.flag == TRUE and data.id > 0 and data.floor > 0 then
        if self.is_open_dun_flag then -- 开启副本先播特效再进入场景
            GlobalEvent:getInstance():Fire(PlanesEvent.Dun_Open_Effect_Event, data)
        else
            local param = {}
            param.dun_id = data.id
            param.floor = data.floor
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PlanesWar, param)
            if self.planes_main_wnd then -- 解除锁屏，如果是需要先播特效的，特效播完会解除锁屏
                self.planes_main_wnd:onLockScreenCallBack(false)
            end
        end
    end
end

-- 请求进入层数
function PlanesController:sender23106( floor )
    local protocal = {}
    protocal.floor = floor
    self:SendProtocal(23106, protocal)
end

function PlanesController:handle23106( data )
    if data.msg and data.msg ~= "" then
        message(data.msg)
    end
end

-- 返回租借宝可梦事件的数据
function PlanesController:handle23107( data )
    if data.load_partner and next(data.load_partner) ~= nil then
        self:openPlanesHireHeroWindow(true, data.load_partner)
    end
end

-- 事件处理返回
function PlanesController:handle23108( data )
    local evt_vo = self.model:getPlanesEvtVoByGridIndex(data.index)
    if not evt_vo or not evt_vo.config then return end

    local dialog_id = nil -- 对话id
    local item_bid_list = {} -- 破坏障碍所需道具
    local buff_bid_list = {} -- buff的id
    local board_bid = nil -- 广告牌id
    local item_bid = nil -- 获得的物品bid
    if data.ext_list and next(data.ext_list) ~= nil then
        for k,v in pairs(data.ext_list) do
            if v.type == 5 then
                dialog_id = v.val1
            elseif v.type == 6 then
                table.insert(item_bid_list, v.val1)
            elseif v.type == 7 then
                table.insert(buff_bid_list, v.val1)
            elseif v.type == 8 then
                board_bid = v.val1
            elseif v.type == 9 then
                item_bid = v.val1 
            end
        end
    end
    if evt_vo.config.type == PlanesConst.Evt_Type.Dialog and dialog_id then -- 对话
        local dialog_cfg = Config.SecretDunData.data_dialogue[dialog_id]
        if dialog_cfg then
            MonopolyController:getInstance():openMonopolyDialogWindow(true, 88, data.index, dialog_cfg)
        end
    elseif evt_vo.config.type == PlanesConst.Evt_Type.Board and board_bid then -- 广告牌
        self:openPlanesBoardWindow(true, board_bid)
    elseif evt_vo.config.type == PlanesConst.Evt_Type.Buff and next(buff_bid_list) ~= nil then -- buff选择
        self:openPlanesBuffChoseWindow(true, buff_bid_list, data.index)
    end
    if item_bid then
        local items = {{bid = item_bid, num = 1}}
        MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true}, MainuiConst.item_open_type.normal)
    end
end

-- 对方阵容数据
function PlanesController:handle23109( data )
    GlobalEvent:getInstance():Fire(PlanesEvent.Get_Master_Data_Event, data)
end

-- 战斗结果
function PlanesController:handle23110( data )
    GuildbossController:getInstance():openGuildbossResultWindow(true, data, BattleConst.Fight_Type.PlanesWar)
end

-- 触发剧情对话
function PlanesController:handle23111( data )
    local dram_cfg = Config.SecretDunData.data_drama[data.id]
    if dram_cfg then
        -- 如果在场景内，则直接显示剧情对话，否则先缓存，进入场景后再显示
        if self.planes_map_wnd then
            -- 延迟 0.5 秒执行
            delayOnce(function (  )
                MonopolyController:getInstance():openMonopolyDialogWindow(true, 89, 0, dram_cfg)
            end, 0.5)
        else
            self.model:setPlanesDramIdCache(data.id)
        end
    end
end

-- 请求背包数据
function PlanesController:sender23112(  )
    self:SendProtocal(23112, {})
end

function PlanesController:handle23112( data )
    self.model:setPlanesBagData(data.secret_item)
end

-- 背包数据更新、新增
function PlanesController:handle23113( data )
    self.model:updatePlanesBagData(data.update_item)
end

-- 背包数据删除
function PlanesController:handle23114( data )
    self.model:deletePlanesBagData(data.delete_pos)
end

-- 请求宝可梦背包数据
function PlanesController:sender23115(  )
    self:SendProtocal(23115, {})
end

function PlanesController:handle23115( data )
    self.model:setAllPlanesHeroData(data.partners)
    GlobalEvent:getInstance():Fire(PlanesEvent.Get_All_Hero_Event)
end

-- 请求查看雇佣宝可梦详细数据
function PlanesController:sender23116( pos )
    local protocal = {}
    protocal.pos = pos
    self:SendProtocal(23116, protocal)
end

function PlanesController:handle23116( data )
    HeroController:getInstance():openHeroTipsPanel(true, data)
    GlobalEvent:getInstance():Fire(PlanesEvent.Look_Other_Hero_Event, data)
end

-- 请求领取首通奖励
function PlanesController:sender23117( dun_id )
    local protocal = {}
    protocal.dun_id = dun_id
    self:SendProtocal(23117, protocal)
end

function PlanesController:handle23117( data )
    if data.msg ~= "" then
        message(data.msg)
    end
    if data.flag == 1 and data.dun_id then -- 领取成功
        self.model:addGotFirstAwardDunId(data.dun_id)
        GlobalEvent:getInstance():Fire(PlanesEvent.Get_First_Award_Event)
    end
end

-- 请求所有buff列表
function PlanesController:sender23118(  )
    self:SendProtocal(23118, {})
end

function PlanesController:handle23118( data )
    GlobalEvent:getInstance():Fire(PlanesEvent.Get_Buff_Data_Event, data.buffs)
end

-- 更新宝可梦血量数据
function PlanesController:handle23119( data )
    if data.partners and next(data.partners) ~= nil then
        self.model:updateMyHeroData(data.partners)
    end
end

-- 请求上阵宝可梦战力总和
function PlanesController:sender23120( partner_ids )
    local protocal = {}
    protocal.partner_ids = partner_ids
    self:SendProtocal(23120, protocal)
end

function PlanesController:handle23120( data )
    GlobalEvent:getInstance():Fire(PlanesEvent.Update_Form_Atk_Event, data.power)
end

-- 请求保存阵法
function PlanesController:sender23121( formation_type, pos_info, hallows_id )
    local protocal = {}
    protocal.formation_type = formation_type
    protocal.pos_info = pos_info
    protocal.hallows_id = hallows_id
    self:SendProtocal(23121, protocal)
end

function PlanesController:handle23121( data )
    if data.msg ~= "" then
        message(data.msg)
    end
    if data.flag == 1 then
        GlobalEvent:getInstance():Fire(PlanesEvent.Save_Form_Success_Event) 
    end
end

-- 请求位面阵容
function PlanesController:sender23122(  )
    self:SendProtocal(23122, {})
end

function PlanesController:handle23122( data )
    GlobalEvent:getInstance():Fire(PlanesEvent.Get_Form_Data_Event, data) 
end

-- 请求上报日志
function PlanesController:sender23123( _type )
    local protocal = {}
    protocal.type = _type
    self:SendProtocal(23123, protocal)
end

-----------------@ 处理事件
-- evt_type:事件类型 index:格子索引
function PlanesController:onHandlePlanesEvtById( evt_type, index )
    self.evt_grid_index = index  -- 这里缓存一下格子id
    if evt_type == PlanesConst.Evt_Type.Normal then -- 空事件
        -- 无需处理
    elseif evt_type == PlanesConst.Evt_Type.Monster then -- 怪物
        self:openPlanesMasterWindow(true, index)
    elseif evt_type == PlanesConst.Evt_Type.Guard then -- 守卫
        self:openPlanesMasterWindow(true, index)
    elseif evt_type == PlanesConst.Evt_Type.Box then -- 宝箱
        self:sender23104(index, 1, {})
    elseif evt_type == PlanesConst.Evt_Type.Start then -- 出生点
        -- 无需处理
    elseif evt_type == PlanesConst.Evt_Type.Board then -- 广告牌
        self:sender23104( index, 0, {} )
    elseif evt_type == PlanesConst.Evt_Type.Goods then -- 获得道具
        self:sender23104( index, 1, {} )
    elseif evt_type == PlanesConst.Evt_Type.Recover then -- 宝可梦恢复(回复泉水)
        self:openPlanesBoardWindow(true, PlanesConst.Recover_Id, index)
    elseif evt_type == PlanesConst.Evt_Type.Portal then -- 传送门
        local tips_str = TI18N("是否通过传送门进入另一层？（进入后依然可通过传送门返回该层场景）")
        CommonAlert.show(tips_str, TI18N("确认"), function (  )
            self:sender23104( index, 1, {} )
        end, TI18N("取消"))
    elseif evt_type == PlanesConst.Evt_Type.LeaseHero then -- 租借宝可梦
        self:sender23104( index, 0, {} )
    elseif evt_type == PlanesConst.Evt_Type.Dialog then -- 奖励NPC对话
        self:sender23104( index, 0, {} )
    elseif evt_type == PlanesConst.Evt_Type.DesBarrier then -- 可破坏的障碍物
        self:openPlanesBoardWindow(true, PlanesConst.DesBarrier_Id, index)
    elseif evt_type == PlanesConst.Evt_Type.Switch then -- 开关
        self:openPlanesBoardWindow(true, PlanesConst.Switch_Id, index)
    elseif evt_type == PlanesConst.Evt_Type.Stage then -- 升降台
        self:openPlanesBoardWindow(true, PlanesConst.Stage_Id, index)
    elseif evt_type == PlanesConst.Evt_Type.Barrier then -- 不可破坏的障碍物
        message(TI18N("目标点为不可行走区域，请选择其他目标点"))
    elseif evt_type == PlanesConst.Evt_Type.Buff then -- buff列表
        self:sender23104( index, 0, {} )
    elseif evt_type == PlanesConst.Evt_Type.Revive then -- 宝可梦恢复(复活祭坛)
        self:openPlanesBoardWindow(true, PlanesConst.Revive_Id, index)
    end
end

-- 主动触发格子事件(必须在场景地图内)
function PlanesController:initiativeTriggerEvtByIndex( index )
    if not index or index == 0 or not self.planes_map_wnd then return end

    local evt_vo = self.model:getPlanesEvtVoByGridIndex(index)
    -- 暂时只触发buff事件
    if evt_vo and evt_vo.config and evt_vo.config.type == PlanesConst.Evt_Type.Buff then
        self:onHandlePlanesEvtById(evt_vo.config.type, index)
    end
end

-- 位面功能是否开启
function PlanesController:checkPlanesIsOpen( not_tips )
    local role_vo = RoleController:getInstance():getRoleVo()
    local limit_lv_cfg = Config.SecretDunData.data_const["open_lev"]
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

-------------@ 界面相关
-- 打开位面冒险主界面
function PlanesController:openPlanesMainWindow( status )
    if status == true then
        if not self:checkPlanesIsOpen() then
            return
        end

        if not self.planes_main_wnd then
            self.planes_main_wnd = PlanesMainWindow.New()
        end
        if self.planes_main_wnd:isOpen() == false then
            self.planes_main_wnd:open()
        end
    else
        if self.planes_main_wnd then
            self.planes_main_wnd:close()
            self.planes_main_wnd = nil
        end
    end
end

-- 引导相关
function PlanesController:getPlanesMainRoot(  )
    if self.planes_main_wnd then
        return self.planes_main_wnd.root_wnd
    end
end

-- 打开位面冒险地图场景(不能直接调用此接口，必须先打开 openPlanesDunInfoWindow 界面，再点击进入场景)
function PlanesController:openPlanesMapWindow( status, param )
    if status == true then
        if not self.planes_map_wnd then
            self.planes_map_wnd = PlanesMapWindow.New()
        end
        if self.planes_map_wnd:isOpen() == false then
            self.planes_map_wnd:open(param)
        end
    else
        if self.planes_map_wnd then
            self.planes_map_wnd:close()
            self.planes_map_wnd = nil
        end
    end
end

-- 打开探险背包界面
function PlanesController:openPlanesBagPanel( status, setting )
    if status == true then
        if not self.planes_bag_panel then
            self.planes_bag_panel = PlanesBagPanel.New()
        end
        if self.planes_bag_panel:isOpen() == false then
            self.planes_bag_panel:open(setting)
        end
    else
        if self.planes_bag_panel then
            self.planes_bag_panel:close()
            self.planes_bag_panel = nil
        end
    end
end
-- 打开宝可梦列表界面
function PlanesController:openPlanesHeroListPanel( status, setting )
    if status == true then
        if not self.planes_hero_list_panel then
            self.planes_hero_list_panel = PlanesHeroListPanel.New()
        end
        if self.planes_hero_list_panel:isOpen() == false then
            self.planes_hero_list_panel:open(setting)
        end
    else
        if self.planes_hero_list_panel then
            self.planes_hero_list_panel:close()
            self.planes_hero_list_panel = nil
        end
    end
end

-- 打开广告牌界面
function PlanesController:openPlanesBoardWindow( status, id, grid_index, setting )
    if status == true then
        if not self.planes_board_wnd then
            self.planes_board_wnd = PlanesBoardWindow.New()
        end
        if self.planes_board_wnd:isOpen() == false then
            self.planes_board_wnd:open(id, grid_index, setting)
        end
    else
        if self.planes_board_wnd then
            self.planes_board_wnd:close()
            self.planes_board_wnd = nil
        end
    end
end

-- 打开敌方阵容界面
function PlanesController:openPlanesMasterWindow( status, grid_index )
    if status == true then
        if not self.master_info_wnd then
            self.master_info_wnd = PlanesMasterWindow.New()
        end
        if self.master_info_wnd:isOpen() == false then
            self.master_info_wnd:open(grid_index)
        end
    else
        if self.master_info_wnd then
            self.master_info_wnd:close()
            self.master_info_wnd = nil
        end
    end
end

-- 打开副本信息界面(同时也是副本入口界面)
function PlanesController:openPlanesDunInfoWindow( status, dun_id )
    if status == true then
        if not self.dun_info_wnd then
            self.dun_info_wnd = PlanesDunInfoWindow.New()
        end
        if self.dun_info_wnd:isOpen() == false then
            self.dun_info_wnd:open(dun_id)
        end
    else
        if self.dun_info_wnd then
            self.dun_info_wnd:close()
            self.dun_info_wnd = nil
        end
    end
end

-- 引导需要
function PlanesController:getPlanesInfoRoot(  )
    if self.dun_info_wnd then
        return self.dun_info_wnd.root_wnd
    end
end

-- 打开雇佣宝可梦界面
function PlanesController:openPlanesHireHeroWindow( status, data )
    if status == true then
        if not self.hire_hero_wnd then
            self.hire_hero_wnd = PlanesHireHeroWindow.New()
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

-- 打开buff选择界面
function PlanesController:openPlanesBuffChoseWindow( status, buff_list, grid_index )
    if status == true then
        if not self.buff_chose_wnd then
            self.buff_chose_wnd = PlanesBuffChoseWindow.New()
        end
        if self.buff_chose_wnd:isOpen() == false then
            self.buff_chose_wnd:open(buff_list, grid_index)
        end
    else
        if self.buff_chose_wnd then
            self.buff_chose_wnd:close()
            self.buff_chose_wnd = nil
        end
    end
end

-- 打开我的buff列表界面
function PlanesController:openPlanesBuffListWindow( status )
    if status == true then
        if not self.buff_list_wnd then
            self.buff_list_wnd = PlanesBuffListWindow.New()
        end
        if self.buff_list_wnd:isOpen() == false then
            self.buff_list_wnd:open()
        end
    else
        if self.buff_list_wnd then
            self.buff_list_wnd:close()
            self.buff_list_wnd = nil
        end
    end
end

-- 打开奖励加成界面
function PlanesController:openPlanesAwardInfoWindow( status )
    if status == true then
        if not self.award_info_wnd then
            self.award_info_wnd = PlanesAwardInfoWindow.New()
        end
        if self.award_info_wnd:isOpen() == false then
            self.award_info_wnd:open()
        end
    else
        if self.award_info_wnd then
            self.award_info_wnd:close()
            self.award_info_wnd = nil
        end
    end
end 

-- 打开首通奖励界面
function PlanesController:openPlanesFirstAwardWindow( status )
    if status == true then
        if not self.first_award_wnd then
            self.first_award_wnd = PlanesFirstAwardWindow.New()
        end
        if self.first_award_wnd:isOpen() == false then
            self.first_award_wnd:open()
        end
    else
        if self.first_award_wnd then
            self.first_award_wnd:close()
            self.first_award_wnd = nil
        end
    end
end

function PlanesController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end