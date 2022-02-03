-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
BattleDramaController = BattleDramaController or BaseClass(BaseController)

function BattleDramaController:config()
    self.model = BattleDramaModel.New(self)
    self.dispather = GlobalEvent:getInstance()

end

function BattleDramaController:getModel()
    return self.model
end

function BattleDramaController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.role_vo = RoleController:getInstance():getRoleVo()
        end)
    end
end

function BattleDramaController:registerProtocals()
    self:RegisterProtocal(13000, "handle13000")    --剧情副本数据
    self:RegisterProtocal(13001, "handle13001")    --更新当前关卡信息
    self:RegisterProtocal(13002, "handle13002")    --制作下一关卡
    self:RegisterProtocal(13003, "handle13003")    --挑战领主
    self:RegisterProtocal(13004, "handle13004")    --快速战斗
    self:RegisterProtocal(13005, "handle13005")    --扫荡关卡
    self:RegisterProtocal(13006, "handle13006")    --剧情副本常规信息
    self:RegisterProtocal(13007, "handle13007")    --副本挂机奖励
    self:RegisterProtocal(13008, "handle13008")    --通关奖励显示
    self:RegisterProtocal(13009, "handle13009")    --领取通关奖励
    self:RegisterProtocal(13010, "handle13010")    --章节开启
    self:RegisterProtocal(13011, "handle13011")    --buff信息
    self:RegisterProtocal(13015, "handle13015")    --通关录像
    self:RegisterProtocal(13016, "handle13016")    --战斗计算信息

    self:RegisterProtocal(13017, "handle13017")     --累积挂机时间
    self:RegisterProtocal(13018, "handle13018")     --领取挂机奖励
    self:RegisterProtocal(13019, "handle13019")     --挂机奖励通知
    self:RegisterProtocal(13020, "handle13020")     --玩家剧情副本超过其他玩家百分比
end


function BattleDramaController:send13011()
    local protocal = {}
    self:SendProtocal(13011, protocal)
end

function BattleDramaController:handle13011(data)
    if data then
        if self.role_vo then
            self.model:setBuffData(data)
        end
    end
end

function BattleDramaController:handle13016( data )
    if data then
        BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.Darma, data)
    end
end

function BattleDramaController:send13000()
    local protocal = {}
    self:SendProtocal(13000,protocal)
end

function BattleDramaController:handle13000(data)
    if data then
        if self.role_vo then
            self.model:setDramaData(data)
            if NEEDCHANGEENTERSTATUS == 4 and not self.first_enter then
                self.first_enter = true
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
            end 
        end
    end
end

function BattleDramaController:handle13001(data)
    if data then
        if self.role_vo then
            self.model:updateDramaData(data)
        end
    end
end
--制作下一关卡
function BattleDramaController:send13002()
    local protocal = {}
    self:SendProtocal(13002, protocal)
end

function BattleDramaController:handle13002(data)
    message(data.msg)
end

function BattleDramaController:send13003(is_auto)
   local protocal = {
       is_auto = is_auto or 0
    }
   self:SendProtocal(13003,protocal) 
end

function BattleDramaController:handle13003(data)
    message(data.msg)
end

function BattleDramaController:send13004()
    local protocal = {}
    self:SendProtocal(13004, protocal)
end

function BattleDramaController:handle13004(data)
    message(data.msg)
end

function BattleDramaController:send13005(dun_id,num)
    local protocal = {}
    protocal.dun_id = dun_id
    protocal.num = num
    self:SendProtocal(13005, protocal)
end

function BattleDramaController:handle13005(data)
    message(data.msg)
    if data.code == 1 then
        self.model:updateCurDunListInfo(data)
        self:openDramSwapView(false)
        self:openDramSwapRewardView(true,data)
    end
end

function BattleDramaController:send13006()
    -- print("BattleDramaController:send13006(>>>>>>>>>>>>>>>>>>>>")
    local protocal = {}
    self:SendProtocal(13006, protocal)
end

function BattleDramaController:handle13006(data)
    -- dump(data,"********* handle13006 *********")
    if data then
        self.model:setQuickData(data)
    end
end

function BattleDramaController:handle13007(data)
    if data then
        self:openDramHookRewardView(true,data)
    end
end

function BattleDramaController:send13008()
    local protocal = {}
    self:SendProtocal(13008, protocal)
end

function BattleDramaController:handle13008(data)
    if data then
        self.model:setDramaReward(data)
    end
end

function BattleDramaController:send13009(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(13009, protocal)
end
function BattleDramaController:handle13009(data)
    if data then
        message(data.msg)
        if data.code == 1 then
            if self.battle_drama_reward_view then
                self.battle_drama_reward_view:udpateDataByID(data.id)
            end
        end
    end
end

function BattleDramaController:handle13010(data)

    self:handleUnlockChapter(data)
end

function BattleDramaController:send13015( dun_id )
    local protocal = {}
    protocal.dun_id = dun_id
    self:SendProtocal(13015, protocal)
end

function BattleDramaController:handle13015( data )
    if data and data.dungeon_replay_log then
        GlobalEvent:getInstance():Fire(Battle_dramaEvent.UpdatePassVedioDataEvent, data.dungeon_replay_log)
    end
end

function BattleDramaController:openDramRewardView(value)
    if value == false then
        if self.battle_drama_reward_view ~= nil then
            self.battle_drama_reward_view:close()
            self.battle_drama_reward_view = nil
        end
    else
        if self.battle_drama_reward_view == nil then
            self.battle_drama_reward_view = BattleDramaRewardWindow.New()
        end

        if self.battle_drama_reward_view and self.battle_drama_reward_view:isOpen() == false then
            self.battle_drama_reward_view:open()
        end
    end
end

--==============================--
--desc:引导需要通关奖励面板
--time:2018-06-28 06:37:06
--@return 
--==============================--
function BattleDramaController:getDramaBattlePassRewardRoot()
    if self.battle_drama_reward_view then
        return self.battle_drama_reward_view.root_wnd
    end
end

-- 打开通关录像界面
function BattleDramaController:openDramaPassVedioView( status )
    if status == false then
        if self.battle_drama_vedio_view ~= nil then
            self.battle_drama_vedio_view:close()
            self.battle_drama_vedio_view = nil
        end
    else
        if self.battle_drama_vedio_view == nil then
            self.battle_drama_vedio_view = BattlDramaPassVedioView.New()
        end

        if self.battle_drama_vedio_view and self.battle_drama_vedio_view:isOpen() == false then
            self.battle_drama_vedio_view:open()
        end
    end
end


--打开Boss信息界面
function BattleDramaController:openDramBossInfoView(value,data)
    if value == false then
        if self.battle_drama_boss_info ~= nil then
            self.battle_drama_boss_info:close()
            self.battle_drama_boss_info = nil
        end
    else
        if self.battle_drama_boss_info == nil then
            self.battle_drama_boss_info = BattlDramaBossInfoWindow.New(data)
        end

        if self.battle_drama_boss_info and self.battle_drama_boss_info:isOpen() == false then
            self.battle_drama_boss_info:open()
        end
    end
end

function BattleDramaController:openDramSwapView(value, data)
    if value == false then
        if self.battle_drama_swap_view ~= nil then
            self.battle_drama_swap_view:close()
            self.battle_drama_swap_view = nil
        end
    else        
        if self.battle_drama_swap_view == nil then
            self.battle_drama_swap_view = BattlDramaSwapWindow.New(data)
        end

        if self.battle_drama_swap_view and self.battle_drama_swap_view:isOpen() == false then
            self.battle_drama_swap_view:open()
        end
    end
end

--==============================--
--desc:扫荡结算界面
--time:2018-09-21 08:21:33
--@value:
--@data:
--@return 
--==============================--
function BattleDramaController:openDramSwapRewardView(value, data)
    if value == false then
        if self.battle_drama_swap_reward_view ~= nil then
            self.battle_drama_swap_reward_view:close()
            self.battle_drama_swap_reward_view = nil
        end
    else
        -- 设置不要马上显示升级
        LevupgradeController:getInstance():waitForOpenLevUpgrade(true)
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        if self.battle_drama_swap_reward_view == nil then
            self.battle_drama_swap_reward_view = BattlDramaSwapRewardWindow.New(data)
        end

        if self.battle_drama_swap_reward_view and self.battle_drama_swap_reward_view:isOpen() == false then
            self.battle_drama_swap_reward_view:open(data)
        end
    end
end

--==============================--
--desc:挑战BOSS
--time:2018-09-21 07:28:58
--@value:
--@return 
--==============================--
function BattleDramaController:openDramBattleAutoCombatView(value)
    if value == false then
        if self.battle_drama_auto_combat_view ~= nil then
            self.battle_drama_auto_combat_view:close()
            self.battle_drama_auto_combat_view = nil
        end
    else
        if self.model.drama_data == nil or Config.DungeonData.data_drama_const.auto_combat_dun_id.val > self.model.drama_data.max_dun_id then
            self:send13003(0)
            return
        end
        if self.role_vo == nil or Config.DungeonData.data_drama_const.auto_combat_lev.val > self.role_vo.lev then
            self:send13003(0)
            return
        end
        if StoryController:getInstance():isInStory() or GuideController:getInstance():isInGuide() then
            self:send13003(0)
            return
        end
        if self.model.auto_combat ~= nil then
            self:send13003(self.model.auto_combat)
            return
        end

        if self.battle_drama_auto_combat_view == nil then
            self.battle_drama_auto_combat_view = BattleDramaAutoCombatWindow.New()
        end

        if self.battle_drama_auto_combat_view and self.battle_drama_auto_combat_view:isOpen() == false then
            self.battle_drama_auto_combat_view:open()
        end
    end
end

--==============================--
--desc:快速作战
--time:2018-09-21 07:28:58
--@value:
--@return 
--==============================--
function BattleDramaController:openDramBattleQuickView(value)
    if value == false then
        if self.battle_drama_battle_quick_view ~= nil then
            self.battle_drama_battle_quick_view:close()
            self.battle_drama_battle_quick_view = nil
        end
    else
        -- 设置不要马上显示升级
        LevupgradeController:getInstance():waitForOpenLevUpgrade(true)
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        if self.battle_drama_battle_quick_view == nil then
            self.battle_drama_battle_quick_view = BattlDramaQuickBattleWindow.New()
        end

        if self.battle_drama_battle_quick_view and self.battle_drama_battle_quick_view:isOpen() == false then
            self.battle_drama_battle_quick_view:open()
        end
    end
end

function BattleDramaController:getDramBattleQuickRoot()
    if self.battle_drama_battle_quick_view then
        return self.battle_drama_battle_quick_view.root_wnd
    end
end

function BattleDramaController:getDramaBattleHookRewardRoot()
    if self.battle_drama_hook_reward_view then
        return self.battle_drama_hook_reward_view.root_wnd
    end
end

--==============================--
--desc:快速作战收益界面
--time:2018-09-21 08:22:04
--@value:
--@data:
--@return 
--==============================--
function BattleDramaController:openDramHookRewardView(value, data)
    if value == false then
        if self.battle_drama_hook_reward_view ~= nil then
            self.battle_drama_hook_reward_view:close()
            self.battle_drama_hook_reward_view = nil
        end
    else
        -- 如果在引导中,并且不是特殊处理的的引导,就不弹
        local guide_config = GuideController:getInstance():getGuideConfig()
        if guide_config and guide_config.id ~= GuideConst.special_id.quick_guide and guide_config.id ~= GuideConst.special_id.hook_guide  then
            return 
        end

        -- 设置不要马上显示升级
        LevupgradeController:getInstance():waitForOpenLevUpgrade(true)
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        if self.battle_drama_hook_reward_view == nil then
            self.battle_drama_hook_reward_view = BattlDramaHookRewardWindow.New()
        end

        if self.battle_drama_hook_reward_view and self.battle_drama_hook_reward_view:isOpen() == false then
            self.battle_drama_hook_reward_view:open(data)
        end
    end
end

function BattleDramaController:openDramWorldView(value)
    if value == false then
        if self.battle_drama_world_view ~= nil then
            self.battle_drama_world_view:close()
            self.battle_drama_world_view = nil
        end
    else
        if self.battle_drama_world_view == nil then
            self.battle_drama_world_view = BattleDramaWorldWindows.New()
        end

        if self.battle_drama_world_view and self.battle_drama_world_view:isOpen() == false then
            self.battle_drama_world_view:open()
        end
    end
end

function BattleDramaController:openBattleDramaUnlockWindow(value,data)
    if value == false then
        if self.battle_drama_unlock_view ~= nil then
            self.battle_drama_unlock_view:close()
            self.battle_drama_unlock_view = nil
        end
    else
        if self.battle_drama_unlock_view == nil then
            self.battle_drama_unlock_view = BattleDramaUnlockWindow.New()
        end

        if self.battle_drama_unlock_view and self.battle_drama_unlock_view:isOpen() == false then
            self.battle_drama_unlock_view:open(data)
        end
    end
end

function BattleDramaController:openBattleDramaUnlockChapterView(value, data)
    if value == false then
        if self.battle_drama_unlock_chapter_view ~= nil then
            self.battle_drama_unlock_chapter_view:close()
            self.battle_drama_unlock_chapter_view = nil
        end
    else
        if self.battle_drama_unlock_chapter_view == nil then
            self.battle_drama_unlock_chapter_view = BattleDramaUnlockChapterView.New()
        end

        if self.battle_drama_unlock_chapter_view and self.battle_drama_unlock_chapter_view:isOpen() == false then
            self.battle_drama_unlock_chapter_view:open(data)
        end
    end
end

-- 引导需要
function BattleDramaController:getBattleQingbaoRoot()
    if self.battle_drama_qingbao_tips_view then
        return self.battle_drama_qingbao_tips_view.root_wnd
    end
end

function BattleDramaController:openBattleDramaQingBaoTipsView(value, data)
    if value == false then
        if self.battle_drama_qingbao_tips_view ~= nil then
            self.battle_drama_qingbao_tips_view:close()
            self.battle_drama_qingbao_tips_view = nil
        end
    else
        if self.battle_drama_qingbao_tips_view == nil then
            self.battle_drama_qingbao_tips_view = BattleDramaQingBaoTipsView.New()
        end
        if self.battle_drama_qingbao_tips_view and self.battle_drama_qingbao_tips_view:isOpen() == false then
            self.battle_drama_qingbao_tips_view:open(data)
        end
    end
end


function BattleDramaController:openBattleDramaFuncView(value)
    if value == false then
        if self.battle_drama_qingbao_tips_view ~= nil then
            self.battle_drama_qingbao_tips_view:close()
            self.battle_drama_qingbao_tips_view = nil
        end
    else
        if self.battle_drama_qingbao_tips_view == nil then
            self.battle_drama_qingbao_tips_view = BattlDramafuncWindow.New()
        end
        if self.battle_drama_qingbao_tips_view and self.battle_drama_qingbao_tips_view:isOpen() == false then
            self.battle_drama_qingbao_tips_view:open()
        end
    end
end

--掉落信息总览界面
function BattleDramaController:openDramDropWindows(value,max_dun_id)
    if value == false then
        if self.battle_drama_drop_tips_view ~= nil then
            self.battle_drama_drop_tips_view:close()
            self.battle_drama_drop_tips_view = nil
        end
    else
        if self.battle_drama_drop_tips_view == nil then
            self.battle_drama_drop_tips_view = BattlDramaDropWindow.New()
        end

        if self.battle_drama_drop_tips_view and self.battle_drama_drop_tips_view:isOpen() == false then
            self.battle_drama_drop_tips_view:open(max_dun_id)
        end
    end
end

function BattleDramaController:handleUnlockChapter(data)
    if Config.DungeonData.data_drama_dungeon_info(data.dun_id) then
        local next_id = Config.DungeonData.data_drama_dungeon_info(data.dun_id).next_id
        if next_id == 0 then
            data.is_last_chapter = true
        end
    end
    data.is_last_chapter = false
    if data then
        WorldmapController:getInstance():openWorldMapMainWindow(true,data)
    end
end

--==============================--
--desc:世界等级tips
--time:2018-09-29 12:03:37
--@status:
--@data:
--@return 
--==============================
function BattleDramaController:openWorldLevTips(status)
    if not status then
        if self.world_lev_tips then
            self.world_lev_tips:close()
            self.world_lev_tips = nil
        end
    else
        if self.world_lev_tips == nil then
            self.world_lev_tips = BattleDramaWorldLevTips.New()
        end
        self.world_lev_tips:open()
    end
end

-- 剧情副本的章节地图界面
function BattleDramaController:openBattleDramaMapWindows( status, chapter_id )
    if status == true then
        if self.battle_drama_map_view == nil then
            self.battle_drama_map_view = BattleDramaMapWindows.New()
        end
        self.battle_drama_map_view:open(chapter_id)
    else
        if self.battle_drama_map_view then
            self.battle_drama_map_view:close()
            self.battle_drama_map_view = nil
        end
    end
end

-- 显示剧情副本界面UI
function BattleDramaController:openBattleDramaUI( status, battle_res_id, battle_type, not_timer )
    if status == true then
        if self.battle_drama_ui == nil then
            self.battle_drama_ui = BttleTopDramaView.new(battle_res_id, battle_type)
        end
        if self.battle_drama_ui then
            self.battle_drama_ui:openView()
        end
        self:openBattleDramaTimer(false)
    else
        if self.battle_drama_ui then
            self.battle_drama_ui:hideView()
            if not not_timer then
                self:openBattleDramaTimer(true)
            end
        end
    end
end

function BattleDramaController:getBattleDramaUI(  )
    if self.battle_drama_ui and not tolua.isnull(self.battle_drama_ui) then
        return self.battle_drama_ui
    end
end

function BattleDramaController:updateBtnLayerStatus( status )
    if self.battle_drama_ui and not tolua.isnull(self.battle_drama_ui) then
        self.battle_drama_ui:updateBtnLayerStatus(status)
    end
end

function BattleDramaController:updataZhenfaInfo( status, data )
    if self.battle_drama_ui and not tolua.isnull(self.battle_drama_ui) then
        self.battle_drama_ui:updataZhenfaInfo(status, data)
    end
end

function BattleDramaController:updateRound( round )
    if self.battle_drama_ui and not tolua.isnull(self.battle_drama_ui) then
        self.battle_drama_ui:updateRound(round)
    end
end

function BattleDramaController:playResourceCollect( x, y )
    if tolua.isnull(self.battle_drama_ui) then return end
    if self.battle_drama_ui.playResourceCollect then
        self.battle_drama_ui:playResourceCollect(x, y)
    end
end

-- 剧情副本UI定时器，剧情副本隐藏到一定时间后，则释放
function BattleDramaController:openBattleDramaTimer( status )
    if status == true then
        -- 默认清除战斗场景的时间间隔,外部控制吧,
        if CLEAN_BATTLE_SCENE_TIME == nil then
            CLEAN_BATTLE_SCENE_TIME = 60
        end
        self.drama_begin_time = GameNet:getInstance():getTime()
        if self.battle_drama_timer == nil then
            self.battle_drama_timer = GlobalTimeTicket:getInstance():add(function()
                local cur_time = GameNet:getInstance():getTime()
                -- 剧情副本隐藏8分钟后则释放
                if (cur_time - self.drama_begin_time) > CLEAN_BATTLE_SCENE_TIME then
                    GlobalTimeTicket:getInstance():remove(self.battle_drama_timer)
                    self.battle_drama_timer = nil
                    if self.battle_drama_ui then
                        self.battle_drama_ui:DeleteMe()
                        self.battle_drama_ui = nil
                    end
                end
            end, 30)
        end
    else
        if self.battle_drama_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.battle_drama_timer)
            self.battle_drama_timer = nil
        end
    end
end

function BattleDramaController:__delete()
    self:openBattleDramaTimer(false)
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--------------- 离线挂机使用
function BattleDramaController:send13017()
    self:SendProtocal(13017, {})
end
function BattleDramaController:handle13017(data)
    self.model:updateHookAccumulateTime(data)
end

function BattleDramaController:requestGetHookTimeAwards()
    self:SendProtocal(13018, {})
end
function BattleDramaController:handle13018(data)
    message(data.msg)
end

-- 挂机提示
function BattleDramaController:handle13019(data)
    if GuideController:getInstance():isInGuide() then return end        -- 在剧情或者在引导中不处理
    if StoryController:getInstance():getModel():isStoryState() then return end 

    local main_index = MainuiController:getInstance():getMainUIIndex()
    local confirm_str = TI18N("前往")
    local desc = TI18N("您的挂机收益即将达到上限，请前往出击界面领取")
    if main_index == MainuiConst.btn_index.drama_scene then
        confirm_str = TI18N("确定")
        desc = TI18N("您的挂机收益即将达到上限，请点击收益宝箱领取")
    end

    local confirm_callback = function (  )
        if main_index ~= MainuiConst.btn_index.drama_scene then
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
        end
        self.hook_alert = nil
        GlobalEvent:getInstance():Fire(Battle_dramaEvent.Close_Hook_Alert_Event)
    end

    local cancel_callback = function (  )
        self.hook_alert = nil
        GlobalEvent:getInstance():Fire(Battle_dramaEvent.Close_Hook_Alert_Event)
    end
    self.hook_alert = CommonAlert.show(desc, confirm_str, confirm_callback, TI18N("取消"), cancel_callback, nil, nil, {view_tag=ViewMgrTag.RECONNECT_TAG})
end

function BattleDramaController:checkHookAlertIsOpen(  )
    if self.hook_alert then
        return true
    end
    return false
end

-- 剧情副本进度超过其他玩家百分比
function BattleDramaController:send13020(  )
    self:SendProtocal(13020, {})
end
function BattleDramaController:handle13020( data )
    if data.val then
        GlobalEvent:getInstance():Fire(Battle_dramaEvent.UpdateDramaProgressDataEvent, data.val)
    end
end

