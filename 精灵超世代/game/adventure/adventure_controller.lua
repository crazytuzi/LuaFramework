-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      冒险主控制器
-- <br/>Create: 2018-05-29
-- --------------------------------------------------------------------
AdventureController = AdventureController or BaseClass(BaseController)

function AdventureController:config()
    self.ui_model = AdventureUIModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function AdventureController:getUiModel()
    return self.ui_model
end

function AdventureController:registerEvents()
    --[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)

            self.role_vo = RoleController:getInstance():getRoleVo()
            local is_open = AdventureActivityController:getInstance():isOpenActivity(AdventureActivityConst.Ground_Type.adventure)
            if is_open == true then
                self:requestInitProtocal(true)
            else
                if self.role_assets_event == nil then
                    self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "lev" then
                            self:requestInitProtocal()
                        end
                    end)
                end
            end
        end)
    end--]]
end

--==============================--
--desc:请求基本信息
--time:2018-10-13 09:21:11
--@return 
--==============================--
function AdventureController:requestInitProtocal(forces)
    local is_open = forces
    if is_open == nil then
        is_open = AdventureActivityController:getInstance():isOpenActivity(AdventureActivityConst.Ground_Type.adventure)
    end
    if is_open == false then return end
    if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
    self:send20600()
    self:send20601() 
    self:send20604()
end

function AdventureController:registerProtocals()
    self:RegisterProtocal(20600, "handle20600")    --基本信息
    self:RegisterProtocal(20601, "handle20601")    --BUFF信息
    self:RegisterProtocal(20602, "handle20602")    --房间信息
    self:RegisterProtocal(20603, "handle20603")    --服务端通知更新指定房间信息
    self:RegisterProtocal(20604, "handle20604")    --获取当前伙伴信息数据
    self:RegisterProtocal(20605, "handle20605")    --设置上阵伙伴信息
    self:RegisterProtocal(20606, "handle20606")    --每一层结算
    self:RegisterProtocal(20607, "handle20607")    --使用3个主要技能的
    self:RegisterProtocal(20608, "handle20608")    --进去指定房间
    self:RegisterProtocal(20609, "handle20609")    --技能信息
    self:RegisterProtocal(20610, "handle20610")    --选中伙伴
    self:RegisterProtocal(20611, "handle20611")    --一击必杀请求
    self:RegisterProtocal(20612, "handle20612")    --冒险重置
    self:RegisterProtocal(20636, "handle20636")    --购买驱魂药剂协议

    self:RegisterProtocal(20620, "handle20620")    --事件反馈
    self:RegisterProtocal(20621, "handle20621")    --猜拳结果反馈
    self:RegisterProtocal(20622, "handle20622")    --buff信息查看
    self:RegisterProtocal(20623, "handle20623")    --答题信息
    self:RegisterProtocal(20624, "handle20624")    --怪物信息

    self:RegisterProtocal(20625, "handle20625")    --获得技能,主要是用于表现效果处理

    self:RegisterProtocal(20627, "handle20627")    --NPC对话序号
    self:RegisterProtocal(20628, "handle20628")    --NPC对话结果
    self:RegisterProtocal(20630, "handle20630")    --宝箱打开结果
    self:RegisterProtocal(20631, "handle20631")    --神秘商店事件

    self:RegisterProtocal(20632, "handle20632")    --神秘商店总览
    self:RegisterProtocal(20633, "handle20633")    --神秘商店购买

    self:RegisterProtocal(20634, "handle20634")
    self:RegisterProtocal(20635, "handle20635")

    --秘矿冒险
    -- self:RegisterProtocal(20640, "handle20640")  --矿脉基础协议
    -- self:RegisterProtocal(20641, "handle20641")  --单个矿脉信息
    -- self:RegisterProtocal(20642, "handle20642")  --当前防守中的宝可梦ID
    -- self:RegisterProtocal(20643, "handle20643")  --矿脉挑战
    -- self:RegisterProtocal(20644, "handle20644")  --日志记录
    -- self:RegisterProtocal(20645, "handle20645")  --某个矿的日志记录
    -- self:RegisterProtocal(20646, "handle20646")  --保存防守布阵
    -- self:RegisterProtocal(20647, "handle20647")  --宝箱信息列表
    -- self:RegisterProtocal(20648, "handle20648")  --领取宝箱
    -- self:RegisterProtocal(20649, "handle20649")  --战斗结算

    -- self:RegisterProtocal(20651, "handle20651")  --放弃占领
    -- self:RegisterProtocal(20652, "handle20652")  --请求我的矿脉的数据
    -- self:RegisterProtocal(20653, "handle20653")  --有矿脉的层
    -- self:RegisterProtocal(20654, "handle20654")  --购买矿工
    -- self:RegisterProtocal(20655, "handle20655")  --购买次数
    -- self:RegisterProtocal(20656, "handle20656")  --反击
    -- self:RegisterProtocal(20657, "handle20657")  --红点 (防守记录的)
    -- self:RegisterProtocal(20658, "handle20658")  --申请圣器id
    -- self:RegisterProtocal(20659, "handle20659")  --首次打开有次数红点.
    -- self:RegisterProtocal(20660, "handle20660")  --放弃占领
end

--矿脉基础协议
function AdventureController:send20640(floor, is_notice)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.is_notice = is_notice or 0
    -- self:SendProtocal(20640,proto)
end

function AdventureController:handle20640(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_BASE_INFO_EVENT,data)
end
--单个矿脉信息
function AdventureController:send20641(floor, room_id)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- self:SendProtocal(20641,proto)
end

function AdventureController:handle20641(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_SINGLE_INFO_EVENT,data)
end

--当前防守中的宝可梦ID
function AdventureController:send20642()
    -- local proto = {}
    -- self:SendProtocal(20642,proto)
end

function AdventureController:handle20642(data)
    self.ui_model:updateMineDefenseInfo(data)
end

--矿脉挑战
function AdventureController:send20643(floor, room_id, is_skip)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- proto.is_skip = is_skip
    -- self:SendProtocal(20643,proto)
    -- if self.adventure_mine_fight_panel then
    --     self:openAdventureMineFightPanel(false)
    -- end
end
function AdventureController:handle20643(data)
    message(data.msg)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_FIGHT_EVENT,data)
end

--日志记录
function AdventureController:send20644()
    -- local proto = {}
    -- self:SendProtocal(20644,proto)
end
function AdventureController:handle20644(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_ALL_LOG_EVENT,data)
end

--某个矿的日志记录
function AdventureController:send20645(floor, room_id)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- self:SendProtocal(20645,proto)
end
function AdventureController:handle20645(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_SINGE_LOG_EVENT,data)
end

--保存防守布阵
function AdventureController:send20646(floor, room_id, id, pos_info, hallows_id)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- proto.id = id
    -- proto.pos_info = pos_info
    -- proto.hallows_id = hallows_id
    -- self:SendProtocal(20646,proto)
end
function AdventureController:handle20646(data)
    if data.flag == TRUE then
        self:send20642()
        if self.adventure_mine_window and self.adventure_mine_window.sendUpdateMineData then
            self.adventure_mine_window:sendUpdateMineData()
        end
        GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_SAVE_FORM_EVENT)
        -- if self.adventure_mine_result_window then
        --     self:openAdventureMineFightResultPanel(false)
        -- end

        --如果有反击操作 而且 矿脉管理存在
        if self.is_strike_back and self.adventure_mine_my_info_panel then
            self.is_strike_back = false
            self:send20652()
        end
    end
    message(data.msg)
end
--宝箱信息列表
function AdventureController:send20647()
    -- local proto = {}
    -- self:SendProtocal(20647,proto)
end
function AdventureController:handle20647(data)
    self.ui_model:setScdata20647(data)
    -- GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_BOX_LIST_EVENT,data)
end

--领取宝箱
function AdventureController:send20648(num)
    -- local proto = {}
    -- proto.num = num
    -- self:SendProtocal(20648,proto)
end
function AdventureController:handle20648(data)
    self.ui_model:setReceiveByNum(data.num)
    -- GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_RECEIVE_BOX_EVENT,data)
end

--推送矿战结算协议
function AdventureController:handle20649(data)
    if data.result == 1 then
        BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.AdventrueMine, data)
        --胜利了得刷新一下 如果界面还在的话
        if self.adventure_mine_window and self.adventure_mine_window.sendUpdateMineData then
            self.adventure_mine_window:sendUpdateMineData()
            self:send20647()
        end
    else
        BattleController:getInstance():openFailFinishView(true, BattleConst.Fight_Type.AdventrueMine, data.result, data)
    end 

    if self.adventure_mine_fight_panel then
        self:openAdventureMineFightPanel(false)
    end
end

--放弃占领
function AdventureController:send20651(floor, room_id)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- self:SendProtocal(20651,proto)
end

function AdventureController:handle20651(data)
    if data.code == TRUE then
        if self.adventure_mine_window and self.adventure_mine_window.sendUpdateMineData then
            self.adventure_mine_window:sendUpdateMineData()
        end
        self:send20642()
        GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_GIVE_UP_OCCUPY_EVENT)
    end
    message(data.msg)
end

--请求我的矿脉的数据
function AdventureController:send20652()
    -- local proto = {}
    -- self:SendProtocal(20652, proto)
end

function AdventureController:handle20652(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_MY_MINE_INFO_EVENT, data)
end

--有矿脉的层
function AdventureController:send20653()
    -- local proto = {}
    -- self:SendProtocal(20653, proto)
end

function AdventureController:handle20653(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_All_LAYER_INFO_EVENT, data)
end
--购买旷工
function AdventureController:send20654(floor, room_id, _type)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- proto.type = _type
    -- self:SendProtocal(20654, proto)
end

function AdventureController:handle20654(data)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_BUY_EMPLOY_EVENT, data)
    end
    message(data.msg)
end

--购买次数
function AdventureController:send20655()
    -- local proto = {}
    -- self:SendProtocal(20655, proto)
end

function AdventureController:handle20655(data)
    -- if data.code == TRUE then
    --     GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_BUY_COUNT_EVENT, data)
    -- end
    message(data.msg)
end
--反击
function AdventureController:send20656(rid, srvid)
    -- local proto = {}
    -- proto.rid = rid
    -- proto.srvid = srvid
    -- self:SendProtocal(20656, proto)
end

function AdventureController:handle20656(data)
    if data.floor ~= 0 and data.room_id ~= 0 then
        GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_STRIKE_BACK_EVENT, data)
        --标志是否有反击操作
        self.is_strike_back = true
    else
        message(TI18N("对方已经没有可以攻占的灵矿了"))
    end
end

--红点 --登陆获取
function AdventureController:send20657()
    -- local proto = {}
    -- self:SendProtocal(20657, proto)
end

function AdventureController:handle20657(data)
    self.ui_model:setMineRecordRedpoint(data.code == 1)
    -- GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_RECORD_RED_POINT_EVENT, data)
end

--红点 --登陆获取
function AdventureController:send20659()
    -- local proto = {}
    -- self:SendProtocal(20659, proto)
end

function AdventureController:handle20659(data)
    self.ui_model:setMineCountRedpoint(data.code == 1)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_LOGIN_RED_POINT_EVENT, data)
end
--获取对手圣器id
function AdventureController:send20658()
    -- local proto = {}
    -- self:SendProtocal(20658, proto)
end

function AdventureController:handle20658(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.ADVENTURE_MINE_HALLOWS_LIST_EVENT, data)
end
--放弃占领
function AdventureController:send20660(floor, room_id)
    -- local proto = {}
    -- proto.floor = floor
    -- proto.room_id = room_id
    -- self:SendProtocal(20660, proto)
end

function AdventureController:handle20660(data)
    message(data.msg)
end


function AdventureController:openAnswerView(value,data)
    if value == false then
        if self.adventure_answer_view ~= nil then
            self.adventure_answer_view:close()
            self.adventure_answer_view = nil 
        end
    else
        if self.adventure_answer_view == nil then
            self.adventure_answer_view = AdventureEvtAnswerWindow.New(data)
        end
        if self.adventure_answer_view and self.adventure_answer_view:isOpen() == false then
            self.adventure_answer_view:open()
        end
    end
end



--==============================--
--desc:打开冒险站前布阵界面
--time:2019-01-24 02:06:30
--@status:
--@return 
--==============================--
function AdventureController:openAdventureFormWindow(status, setting)
    if not status then
        if self.form_window then
            self.form_window:close()
            self.form_window = nil
        end
    else
        if self.form_window == nil then
            self.form_window = AdventureFormWindow.New()
        end
        self.form_window:open(setting)
    end
end

function AdventureController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
    if self.ui_model ~= nil then
        self.ui_model:DeleteMe()
        self.ui_model = nil
    end

end

-- 引导需要
function AdventureController:getAdventureRoot()
    if self.adventure_window then
        return self.adventure_window.root_wnd
    end
end

-- 引导需要下一层的指引
function AdventureController:getNextAlertRoot()
    if self.adventure_window then
        local alert = self.adventure_window:getAlert()
        if alert then
            return alert.root_wnd
        end
    end
end



function AdventureController:checkMaxMineLayerInfo()
    local base_data = self.ui_model:getAdventureBaseData()
    if base_data == nil or base_data.current_id == nil or base_data.id == nil then return false end
    local id = math.floor((base_data.id)/10) * 10
    if id < 10 then
        return false
    end
    self:requestEnterAdventureMine(id)
    return true
end

--进入最大层的矿脉
function AdventureController:requestEnterMaxAdventureMine()
    local base_data = self.ui_model:getAdventureBaseData() 
    if not base_data then return end
    local floor = base_data.pass_id or 0
    local max_floor = 0
    local config_list = Config.AdventureMineData.data_floor_data
    if config_list then
        for k,config in pairs(config_list) do
            if floor >= config.floor and max_floor < config.floor then 
                max_floor = config.floor
            end
        end
    end 
    if max_floor ~= 0 then
        self:requestEnterAdventure(true, max_floor)
    end
end

--==============================--
--desc:进入冒险的主入口
--time:2019-01-24 02:04:15
--@is_max_id -- 是否是跳转最大层
--@floor -- 要跳转的矿脉层
--@return 
--==============================--
function AdventureController:requestEnterAdventure(is_max_id, _floor)
    local form_list = self.ui_model:getFormList()
    if form_list == nil or next(form_list) == nil then
        self:openAdventureFormWindow(true, {max_floor = _floor})
    else
        -- local base_data = self.ui_model:getAdventureBaseData()
        -- if base_data == nil or base_data.current_id == nil or base_data.id == nil then return end
        -- local floor 
        -- is_max_id = true --由于优化修改导致都是跳转最大层的效果(以防修改 保留以下代码)
        -- if is_max_id then
        --     floor = base_data.id
        -- else
        --     floor = base_data.current_id
        -- end

        -- if _floor ~= nil then
        --    floor = _floor 
        -- end
        -- local config = Config.AdventureMineData.data_floor_data[floor]
        -- if config then --有值.说明是矿脉层
        --     local setting = {}
        --     setting.is_show_open_effect = true
        --     setting.floor_id = floor
        --     MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.AdventrueMine, setting) 
        -- else
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Adventrue) 
        -- end
    end
end

--跳转到某个矿脉层
--@open_setting 打开的配置
function AdventureController:requestEnterAdventureMine(floor, open_setting)
    -- local form_list = self.ui_model:getFormList()
    -- if form_list == nil or next(form_list) == nil then
    --     self:openAdventureFormWindow(true)
    -- else
    --     local config = Config.AdventureMineData.data_floor_data[floor]
    --     if config then 
    --         local setting = {}
    --         setting.is_show_open_effect = true
    --         setting.floor_id = floor
    --         setting.open_setting = open_setting
    --         MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.AdventrueMine, setting) 
    --     end
    -- end
end

--冒险主界面
function AdventureController:openAdventureMainWindow(status)
    if not status then
        if self.adventure_window then
            self.adventure_window:close()
            self.adventure_window = nil
        end
    else
        -- 没有布阵是不给进去的
        local form_list = self.ui_model:getFormList()
        if form_list == nil or next(form_list) == nil then
            print("跳转进入神界冒险有误,当前还没有布阵 ============>")
            return
        end

        if self.adventure_mine_window then
            self:openAdventureMineWindow(false)
        end

        -- 没有基础数据也不做响应
        local base_data = self.ui_model:getAdventureBaseData()
        if base_data == nil then return end

        if self.adventure_window == nil then
            self.adventure_window = AdventureMainWindow.New(base_data.id)
        end
        self.adventure_window:open()
    end
end

function AdventureController:getAdventureMineWindow(  )
    return self.adventure_mine_window
end

--冒险矿井界面
function AdventureController:openAdventureMineWindow(status, setting)
    self:openAdventureMainWindow(status)
    -- if not status then
    --     if self.adventure_mine_window then
    --         self.adventure_mine_window:close()
    --         self.adventure_mine_window = nil
    --     end
    -- else
    --     -- 没有布阵是不给进去的
    --     local form_list = self.ui_model:getFormList()
    --     if form_list == nil or next(form_list) == nil then
    --         print("跳转进入神界冒险有误,当前还没有布阵 ============>")
    --         return
    --     end
    --     if self.adventure_window then
    --         self:openAdventureMainWindow(false)
    --     end

    --     -- 没有基础数据也不做响应
    --     local base_data = self.ui_model:getAdventureBaseData()
    --     if base_data == nil then return end

    --     if self.adventure_mine_window == nil then
    --         self.adventure_mine_window = AdventureMineWindow.New(base_data.id)
    --         self.adventure_mine_window:open(setting)
    --     else
    --         self.adventure_mine_window:openRootWnd(setting)    
    --     end
    -- end
end

--冒险矿战斗记录
function AdventureController:openAdventureMineFightRecordPanel(status, setting)
     if not status then
        if self.adventure_mine_fight_recrod_panel then
            self.adventure_mine_fight_recrod_panel:close()
            self.adventure_mine_fight_recrod_panel = nil
        end
    else
        if self.adventure_mine_fight_recrod_panel == nil then
            self.adventure_mine_fight_recrod_panel = AdventureMineFightRecordPanel.New()
        end
        self.adventure_mine_fight_recrod_panel:open(setting)
    end
end

--冒险我的矿脉
function AdventureController:openAdventureMineMyInfoPanel(status, setting)
     if not status then
        if self.adventure_mine_my_info_panel then
            self.adventure_mine_my_info_panel:close()
            self.adventure_mine_my_info_panel = nil
        end
    else
        if self.adventure_mine_my_info_panel == nil then
            self.adventure_mine_my_info_panel = AdventureMineMyInfoPanel.New()
        end
        self.adventure_mine_my_info_panel:open(setting)
    end
end

--冒险矿脉跳转
function AdventureController:openAdventureMineLayerPanel(status, setting)
     if not status then
        if self.adventure_mine_layer_panel then
            self.adventure_mine_layer_panel:close()
            self.adventure_mine_layer_panel = nil
        end
    else
        if self.adventure_mine_layer_panel == nil then
            self.adventure_mine_layer_panel = AdventureMineLayerPanel.New()
        end
        self.adventure_mine_layer_panel:open(setting)
    end
end
--冒险准备战斗 和 矿脉管理
function AdventureController:openAdventureMineFightPanel(status, setting)
     if not status then
        if self.adventure_mine_fight_panel then
            self.adventure_mine_fight_panel:close()
            self.adventure_mine_fight_panel = nil
        end
    else
        if self.adventure_mine_fight_panel == nil then
            self.adventure_mine_fight_panel = AdventureMineFightPanel.New()
        end
        self.adventure_mine_fight_panel:open(setting)
    end
end


--打开矿战结算界面
function AdventureController:openAdventureMineFightResultPanel(bool, data)
    if bool == true then
        -- 不能直接出剧情或者引导
        LevupgradeController:getInstance():waitForOpenLevUpgrade(true) 
        BattleResultMgr:getInstance():setWaitShowPanel(true)
        if not self.adventure_mine_result_window then 
            self.adventure_mine_result_window = AdventureMineFightResultPanel.New(data.result, BattleConst.Fight_Type.AdventrueMine)
        end
        if self.adventure_mine_result_window and self.adventure_mine_result_window:isOpen() == false then
            self.adventure_mine_result_window:open(data, BattleConst.Fight_Type.AdventrueMine)
        end
    else 
        if self.adventure_mine_result_window then 
            self.adventure_mine_result_window:close()
            self.adventure_mine_result_window = nil
            GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
        end
    end
end


function AdventureController:openWindowByConfig(data)
    if data == nil or data.config == nil then return end
    local config = data.config

    if AdventureEvent.isMonster(config.evt_type) then --boss或者怪物--
        if self.ui_model:allHeroIsDie() == true then
            message(TI18N("宝可梦全部阵亡,本轮冒险已结束!"))
            return
        end
        self:openEvtViewByType(true, AdventureEvtChallengeWindow, data)
    elseif config.evt_type == AdventureEvent.EventType.box then --B宝箱--
        self:openEvtViewByType(true, AdventureEvtBoxWindow, data)
    elseif config.evt_type == AdventureEvent.EventType.finger_guessing then --猜拳--
        self:openEvtViewByType(true, AdventureEvtFighterGuessWindow, data)
    elseif config.evt_type == AdventureEvent.EventType.answer then --答题--
        self:openEvtViewByType(true, AdventureEvtStartWindow, data)
    elseif config.evt_type == AdventureEvent.EventType.npc then --npc事件--
        self:openEvtViewByType(true, AdventureEvtNpcView, data)
    elseif config.evt_type == AdventureEvent.EventType.freebox then -- 免费宝箱
        self:openEvtViewByType(true, AdventureEvtFreeBoxWindow, data)
    elseif config.evt_type == AdventureEvent.EventType.npc_talk then -- npc对话
        self:openEvtViewByType(true, AdventureEvtOtherNpcWindow, data)
    elseif config.evt_type == AdventureEvent.EventType.shop then -- 神秘商店
        self:openEvtViewByType(true, AdventureEvtShopView, data)
    elseif config.evt_type == AdventureEvent.EventType.effect then --特效事件
        self:send20620(data.id, AdventureEvenHandleType.handle, {})
    end
end 

--打开各种事件面板
function AdventureController:openEvtViewByType(status, ref_class, data, extendparam, is_other)
	if status == false then
		if self.adventure_evt_view ~= nil then
			self.adventure_evt_view:close()
			self.adventure_evt_view = nil
		end
	else
        if data == nil then return end
		local ref_class = ref_class or AdventureEvtChallengeWindow 
		if self.adventure_evt_view == nil then
			self.adventure_evt_view = ref_class.New(data, extendparam, is_other)
		end
		if self.adventure_evt_view and self.adventure_evt_view:isOpen() == false then
			self.adventure_evt_view:open()
		end
	end
end 

--==============================--
--desc:冒险商店
--time:2019-01-22 09:12:07
--@status:
--@return 
--==============================--
function AdventureController:openAdventrueShopWindow(status)
    if not status then
        if self.shop_window then
            self.shop_window:close()
            self.shop_window = nil
        end
    else
        if self.shop_window == nil then
            self.shop_window = AdventureShopWindow.New()
        end
        self.shop_window:open()
    end
end

--==============================--
--desc:一击必杀界面
--time:2019-01-23 09:56:18
--@status:
--@return 
--==============================--
function AdventureController:openAdventureShotKillWindow(status, config)
    if not status then
        if self.shot_kill_window then
            self.shot_kill_window:close()
            self.shot_kill_window = nil
        end
    else
        if config == nil then return end
        if self.shot_kill_window == nil then
            self.shot_kill_window = AdventureShotKillWindow.New()
        end
        self.shot_kill_window:open(config)
    end
end

--==============================--
--desc:使用药品
--time:2019-01-25 12:20:05
--@status:
--@return 
--==============================--
function AdventureController:openAdventureUseHPWindow(status, config)
    if not status then
        if self.use_hp_window then
            self.use_hp_window:close()
            self.use_hp_window = nil
        end
    else
        if config == nil then return end
        if self.use_hp_window == nil then
            self.use_hp_window = AdventureUseHPWindow.New()
        end
        self.use_hp_window:open(config)
    end
end

--事件操作
function AdventureController:send20620(room_id,action,ext_list)
    local protocal = {}
    protocal.room_id = room_id 
    protocal.action = action  
    protocal.ext_list = ext_list or {}
    self:SendProtocal(20620, protocal)
end

function AdventureController:handle20620(data)
    message(data.msg)
    if data.code == 2 then
        self:openEvtViewByType(false)
    end
end

--请求房间信息
function AdventureController:send20602()
    local protocal = {}
    self:SendProtocal(20602, protocal)
end

--房间信息返回
function AdventureController:handle20602(data)
    self.ui_model:setRoomList(data)
end

--服务端通知更新指定房间信息
function AdventureController:handle20603(data)
    self.ui_model:updateRoomList(data)
end

function AdventureController:send20604()
	self:SendProtocal(20604, {})
end 

--获取当前伙伴信息数据
function AdventureController:handle20604(data)
    self.ui_model:setFightSkipCount(data.combat_num)
    self.ui_model:updateFormPartner(data.partners, data.id)
    if NEEDCHANGEENTERSTATUS == 2 and not self.first_enter then
        self.first_enter  = true
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
    end
end

--请求布阵
function AdventureController:requestSetForm(plist, max_floor)
    self.max_floor = max_floor
    local protocal = {}
    protocal.plist = plist or {}
    self:SendProtocal(20605, protocal)
end

function AdventureController:handle20605(data)
    if data.code == 1 then
        self.ui_model:setLastAdventureNum(data.last_num)
        self:openAdventureFormWindow(false)
        self:requestEnterAdventure(true, self.max_floor)
        self.max_floor = nil
        --需要重置一下宝可梦防守信息
        self:send20642()
    end
end

function AdventureController:send20608(room_id)
    local protocal = {}
    protocal.room_id = room_id
    self:SendProtocal(20608, protocal)
end

function AdventureController:handle20608(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(AdventureEvent.HandleRoomOverEvent, data.room_id)
    end
end

--基本信息
function AdventureController:send20600()
    local protocal = {}
    self:SendProtocal(20600, protocal)
end

--基本信息返回
function AdventureController:handle20600(data)
    if data then
        self.ui_model:setAdventureBaseData(data)
    end
    if self.must_change_window then
        self.must_change_window = false
        self:requestEnterAdventure(true)
    end
end

--设置必须转换window.因为 是从矿脉层跳转到冒险层
function AdventureController:setMustChangeWindow()
    self.must_change_window = true
end

--buff信息
function AdventureController:send20601()
	self:SendProtocal(20601, {})
end

--buff信息返回
function AdventureController:handle20601(data)
	if data then
		self.ui_model:setBuffData(data)
	end
end 

function AdventureController:handle20622(data)
    if data then
        GlobalEvent:getInstance():Fire(AdventureEvent.Update_Evt_Buff_Info,data)
    end
end

function AdventureController:handle20621(data)
    if data then
        GlobalEvent:getInstance():Fire(AdventureEvent.Update_Evt_Guess_Result,data)
    end
end

function AdventureController:handle20623(data)
    if data then
        GlobalEvent:getInstance():Fire(AdventureEvent.Update_Evt_Answer_Info, data)
    end
end

function AdventureController:handle20628(data)
    if data then
        message(data.msg)
        delayOnce(function ()
            self:openEvtViewByType(false)
            self:showGetItemTips(data.items)
        end,1)
    end
end

function AdventureController:handle20630(data)
    if data then
        GlobalEvent:getInstance():Fire(AdventureEvent.Update_Evt_Box_Result_Info, data)
    end
end

function AdventureController:handle20627(data)
    if data then
        GlobalEvent:getInstance():Fire(AdventureEvent.Update_Evt_Npc_Info, data)
    end
end

function AdventureController:handle20631(data)
    if data.type == 1 then          -- 点击房间事件时候请求20协议之后返回处理
        GlobalEvent:getInstance():Fire(AdventureEvent.Update_Evt_Shop_Info, data)
    elseif data.type == 2 then      -- 点击技能商店直接弹出
        self:openAdventureEvtShopView(true, data.list)
    end
end

--==============================--
--desc:主动打开神秘商店
--time:2019-01-25 09:09:21
--@status:
--@data:
--@return 
--==============================--
function AdventureController:openAdventureEvtShopView(status, data)
    if not status then
        if self.shop_evt_window then
            self.shop_evt_window:close()
            self.shop_evt_window = nil
        end
    else
        if self.shop_evt_window == nil then
            self.shop_evt_window = AdventureEvtShopView.New()
        end
        self.shop_evt_window:open(data)
    end
end

--==============================--
--desc:冒险中飘字处理
--time:2019-01-28 04:22:40
--@items:
--@is_guess:是否是猜拳结果
--@ret:猜拳的结果
--@return 
--==============================--
function AdventureController:showGetItemTips(items, is_guess, ret)
    if items then
        local str = ""
        for i, v in ipairs(items) do
            if str ~= "" then
                str = str .. "，"
            end
            local item_config = Config.ItemData.data_get_data(v.bid)
            if Config.ItemData.data_assets_id2label[v.bid] then
                str = string.format("%s<img src=%s scale=0.4 visible=true /><div fontcolor=#289b14>x%s</div>", str, PathTool.getItemRes(item_config.icon), v.num)
            else
                str = string.format("%s<div fontcolor=%s>%s</div><div fontcolor=#289b14>x%s</div>", str, tranformC3bTostr(BackPackConst.quality_color_id[item_config.quality]), item_config.name, v.num)
            end
        end
        if is_guess == true then
            ret = ret or 0
            if ret == 0 then                -- 平
                str = string.format(TI18N("竟然有人能跟我猜成平手，这%s拿去"), str)
            elseif ret == 1 then            -- 赢
                str = string.format(TI18N("你赢了，这%s归你了"), str)
            else
                str = string.format(TI18N("你输了，这%s还给你"), str)
            end
        else
            str = string.format(TI18N("获取%s"), str)
        end

        playOtherSound("c_get") 
        GlobalMessageMgr:getInstance():showMoveVertical(str)
    end 
end

--- 冒险每一层结算数据
function AdventureController:openAdventureFloorResultWindow(status, data)
    if not status then
        if self.floor_result_window then
            self.floor_result_window:close()
            self.floor_result_window = nil
        end
    else
        if data == nil or data.items_list == nil then return end

        if self.floor_result_window == nil then
            self.floor_result_window = AdventureFloorResultWindow.New()
        end
        self.floor_result_window:open(data)
    end
end

--- 服务端主动推送的结算界面
function AdventureController:handle20606(data)
    self:openAdventureFloorResultWindow(true, data)
end


--==============================--
--desc:使用3个技能
--time:2019-01-24 05:01:40
--@skill_id:
--@val:
--@return 
--==============================--
function AdventureController:send20607(skill_id, val)
    local protocal = {}
    protocal.skill_id = skill_id
    protocal.val = val
    self:SendProtocal(20607, protocal)
end

--==============================--
--desc:使用技能
--time:2019-01-24 04:57:32
--@data:
--@return 
--==============================--
function AdventureController:handle20607(data)
    message(data.msg)
    if data.code == 1 then
        self:openAdventureShotKillWindow(false)
        self:openAdventureUseHPWindow(false)
    end
end 

--==============================--
--desc:请求技能信息
--time:2019-01-24 05:00:05
--@return 
--==============================--
function AdventureController:send20609()
    self:SendProtocal(20609, {})
end

-- 技能信息
function AdventureController:handle20609(data)
    if data then
        GlobalEvent:getInstance():Fire(AdventureEvent.UpdateSkillInfo, data.skill_list)
    end
end

-- 购买驱魂药剂协议
function AdventureController:send20636(num)
    local protocal = {}
    protocal.num = num
    self:SendProtocal(20636, protocal)
end

-- 技能信息
function AdventureController:handle20636(data)
    message(data.msg)
end

function AdventureController:requestSelectPartner(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(20610, protocal)
end

-- 选中伙伴返回
function AdventureController:handle20610(data)
    -- message(data.msg)
    if data.code == 1 then
        self.ui_model:updateSelectPartnerID(data.id)
    end
end

-- 设置怪物血量
function AdventureController:handle20624(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateMonsterHP, data.hp_per) 
end

--==============================--
--desc: 请求一击必杀的信息列表
--time:2019-01-25 01:15:17
--@return 
--==============================--
function AdventureController:send20611()
    self:SendProtocal(20611, {})
end

function AdventureController:handle20611(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateShotKillInfo, data.room_list) 
end

--==============================--
--desc:请求神秘商店总览
--time:2019-01-25 12:05:39
--@return 
--==============================--
function AdventureController:requestShopTotal()
    self:SendProtocal(20632, {})
end

--==============================--
--desc:神秘商店总览
--time:2019-01-25 11:25:40
--@data:
--@return 
--==============================--
function AdventureController:handle20632(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateShopTotalEvent, data.list)
end

--==============================--
--desc:请求购买商店总店
--time:2019-01-25 12:06:56
--@id:
--@return 
--==============================--
function AdventureController:requestBuyShopItem(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(20633, protocal)
end

--==============================--
--desc:购买神秘商店
--time:2019-01-25 11:26:04
--@data:
--@return 
--==============================--
function AdventureController:handle20633(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(AdventureEvent.UpdateShopItemEvent, data.id)
    end
end

--宝箱奖励展示
function AdventureController:send20634()
    self:SendProtocal(20634,{})
end
function AdventureController:handle20634(data)
    self.ui_model:setAdventureBoxStatus(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.UpdateBoxTeskEvent,data)
end
--领取宝箱
function AdventureController:send20635(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(20635,proto)
end
function AdventureController:handle20635(data)
    message(data.msg)
end
--打开宝箱界面
function AdventureController:openAdventureBoxRewardView(status,kill_master)
    if status == true then
        if self.box_reward_window == nil then
            self.box_reward_window = AdventureBoxRewardWindow.New(kill_master)
        end
        self.box_reward_window:open()
    else
        if self.box_reward_window then
            self.box_reward_window:close()
            self.box_reward_window = nil
        end
    end
end

--==============================--
--desc:获得技能
--time:2019-01-26 04:28:19
--@data:
--@return 
--==============================--
function AdventureController:handle20625(data)
    GlobalEvent:getInstance():Fire(AdventureEvent.GetSkillForEffectAction, data.id, data.skill_id)
end

--==============================--
--desc:冒险重置,这里需要判断是不是在当前界面,是不是在战斗中
--time:2019-01-28 05:15:17
--@data:
--@return 
--==============================--
function AdventureController:handle20612(data)
    local ui_fight_type = MainuiController:getInstance():getUIFightType()
    if ui_fight_type == MainuiConst.ui_fight_type.sky_scene or
     ui_fight_type == MainuiConst.ui_fight_type.adventrueMine then
        local is_in_fight = BattleController:getInstance():isInFight()
        if is_in_fight then --如果是在战斗中,则等战斗结束之后,弹出提示
            if self.battle_exit_event == nil then
                self.battle_exit_event = GlobalEvent:getInstance():Bind(SceneEvent.EXIT_FIGHT, function(combat_type)
                    if combat_type == BattleConst.Fight_Type.Adventrue or combat_type == BattleConst.Fight_Type.AdventrueMine then
                        self:showAdventureReset()
                    end
                end)
            end 
        else
            self:showAdventureReset()
        end
    end
end

function AdventureController:showAdventureReset()
    if self.battle_exit_event then
        GlobalEvent:getInstance():UnBind(self.battle_exit_event)
        self.battle_exit_event = nil
    end
    MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene)

    delayOnce(function() 
        local msg = TI18N("神界冒险已重置，是否重新进入？")
        CommonAlert.show(msg, TI18N("确定"),function() 
            self:requestEnterAdventure()
        end, TI18N("取消"))
    end, 0.2)     
end