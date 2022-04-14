-- 
-- @Author: LaoY
-- @Date:   2018-07-22 17:51:55
-- 
require('game.main.RequireMain')
require('game.map.RequireMap')

MainController = MainController or class("MainController", BaseController)
local MainController = MainController

function MainController:ctor()
    MainController.Instance = self
    self.model = MainModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function MainController:dctor()

end

function MainController:GetInstance()
    if not MainController.Instance then
        MainController.new()
    end
    return MainController.Instance
end

function MainController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function MainController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(MainModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)

    GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, handler(self, self.HandleIconCheck))
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(Rocker):Open()
        -- lua_panelMgr:GetPanelOrCreate(ChatMain):Open()
        lua_panelMgr:GetPanelOrCreate(MainUIView):Open()
    end
    GlobalEvent:AddListener(MainEvent.OpenMainPanel, call_back)

    local function call_back(target_id, total_time)
        lua_panelMgr:GetPanelOrCreate(MainCollectPanel):Open(target_id, total_time)
    end
    GlobalEvent:AddListener(FightEvent.StartPickUp, call_back)

    local function ON_OPEN_TASK_TALK(task_id, prog, content_str, call_back)
        if true then
            lua_panelMgr:GetPanelOrCreate(TaskTalkNovicePanel):Open(task_id, prog, content_str, call_back)
        else

        end
    end
    GlobalEvent:AddListener(MainEvent.OpenTaskTalk, ON_OPEN_TASK_TALK)

    local function OPEN_TASK_REWARD(task_id)
        lua_panelMgr:OpenPanel(TaskRewardPanel, task_id)
    end
    GlobalEvent:AddListener(MainEvent.OpenTaskReward, OPEN_TASK_REWARD)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(GVoiceTestPanel):Open()
    end
    GlobalEvent:AddListener(EventName.TestVoice, call_back)

    local function call_back()
        Notify.ShowText("This function is not opened yet")
    end
    GlobalEvent:AddListener(EventName.TestModel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MapPanel):Open()
    end
    GlobalEvent:AddListener(MainEvent.OpenMapPanel, call_back)

    local function call_back(scene_id)
        local type = Config.db_scene[scene_id].type;
        local stype = Config.db_scene[scene_id].stype
        local bit = MainModel.MiddleLeftBitState.Dungeon
        if type == enum.SCENE_TYPE.SCENE_TYPE_BOSS or stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_WORLD_BOSS 
             or stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR or stype == enum.SCENE_STYPE.SCENE_STYPE_THRONE then
            bit = MainModel.MiddleLeftBitState.Boss
        end
        self.model:ChangeMiddleLeftBit(bit, true)
        if stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_WORLD_BOSS then
            -- or stype == enum.SCENE_STYPE.SCENE_STYPE_GUILDGUARD
            bit = MainModel.MiddleLeftBitState.DungeonBoss;
        else
            self.model:ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.DungeonBoss, false)
        end
        self.model:ChangeMiddleLeftBit(bit, true)
        local panel = lua_panelMgr:GetPanel(MainUIView)
        if panel then
            panel:SetMiddleLeftVisibel()
        end
    end
    GlobalEvent:AddListener(DungeonEvent.ENTER_DUNGEON_SCENE, call_back)

    local function call_back()
        self.model:ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.Dungeon, false)
        self.model:ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.Boss, false)
        self.model:ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.DungeonBoss, false)
        local panel = lua_panelMgr:GetPanel(MainUIView)
        if panel then
            panel:SetMiddleLeftVisibel()
        end
    end
    GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)

    --local function call_back(id)
    --    self:CheckMainTopRightIcon()
    --end
    --GlobalEvent:AddListener(TaskEvent.FinishMainTask, call_back)

    local function call_back(level)
        if level and level <= 7 then
            -- GuideItem4.AutoMaintaskTip = GuideItem4.SpecialShowTime +3
            GuideItem4.AutoMaintaskTip = 3
        else
            GuideItem4.AutoMaintaskTip = 15
        end
    end
    GlobalEvent:AddListener(EventName.ChangeLevel, call_back)

    local function call_back(level)
        self:CheckMainTopRightIcon()
    end
    TaskModel:GetInstance():AddListener(TaskEvent.AccTaskList, call_back)


    --[[
        @author LaoY
        @des    右上角图标
        @param1 key_str     配置key
        @param2 flag     	是否显示
        @param3 sign     	标识符 选填。只有当key_str对应的图标支持多个的时候才需要填，多用于运营活动
        /*以下选填*/
        /*flag = true 才有用*/
        @param3 time_str    结束时间(结束不删除)|显示文本  number|string  时间戳
        @param4 del_time    删除时间                     删除时间；如果有结束时间没有删除时间，默认就是结束就删除 时间戳
        @param5 is_notice   是否为预告               	默认false
        @param6 show_etime  展示结束时间                 若展示时间大于结束时间，主界面图标倒计时处显示红色“已结束”字样
        @param7 is_yy_act   是否为运营活动               是否为运营活动，决定显示的倒计时的时间位数
    --]]
    local function call_back(key_str, flag, sign, time_str, del_time, is_notice, is_show_end, is_yy_act, act_id)
        --logError("MainEvent.ChangeRightIcon,key-"..key_str..",flag-"..tostring(flag))
        if flag then
            self.model:AddRightTopIcon(key_str, sign, time_str, del_time, is_notice, is_show_end, is_yy_act, act_id)
        else
            self.model:RemoveRightTopIcon(key_str, sign)
        end
    end
    GlobalEvent:AddListener(MainEvent.ChangeRightIcon, call_back)

    --[[
        @author LaoY
        @des     zuo上角图标
        @param1 key_str     配置key
        @param2 flag     	是否显示
        @param3 sign     	标识符 选填。只有当key_str对应的图标支持多个的时候才需要填，多用于运营活动
        /*以下选填*/
        /*flag = true 才有用*/
        @param3 time_str    结束时间(结束不删除)|显示文本  number|string  时间戳
        @param4 del_time    删除时间                     删除时间；如果有结束时间没有删除时间，默认就是结束就删除 时间戳
        @param5 is_notice   是否为预告               	默认false
        @param6 show_etime  展示结束时间                 若展示时间大于结束时间，主界面图标倒计时处显示红色“已结束”字样
        @param7 is_yy_act   是否为运营活动               是否为运营活动，决定显示的倒计时的时间位数
    --]]
    local function call_back(key_str, flag, sign, time_str, del_time, is_notice, is_show_end, is_yy_act, act_id)
        if flag then
            self.model:AddLeftTopIcon(key_str, sign, time_str, del_time, is_notice, is_show_end, is_yy_act, act_id)
        else
            self.model:RemoveLeftTopIcon(key_str, sign)
        end
    end
    GlobalEvent:AddListener(MainEvent.ChangeLeftIcon, call_back)

    --[[
        @author LaoY
        @des    主界面图标红点 通用的；主界面派发的事件是另外一个,用MainModel派发的,MainEvent.UpdateRightIcon
        @param1 key_str     配置key
        @param2 param     	是否显示红点 如果要显示数量，就传数字
        @param3 sign     	标识符 选填。只有当key_str对应的图标支持多个的时候才需要填，多用于运营活动。右下角不要填
    --]]
    local function call_back(key_str, param, sign)
        self.model:UpdateReddot(key_str, param, sign)
    end
    GlobalEvent:AddListener(MainEvent.ChangeRedDot, call_back)

    --[[
        @author LaoY
        @des    主界面中间提示图标
        @param1 key_str     配置key
        @param2 flag     	是否显示
        /*flag = true 才有用*/
        @param3 call_back    点击回调
        @param4 num  		 数量 选填
        @param5 time    	 出现时间（单位秒，不是时间戳） 选填。默认没有时间限制
        @param6 sign    	 先不用 出现多个同一图标时，要加额外标识值
    --]]
    local function call_back(key_str, flag, call_back, num, time, sign)
        if flag then
            self.model:AddMidTipIcon(key_str, call_back, num, time, sign)
        else
            self.model:RemoveMidTipIcon(key_str, sign)
        end
    end
    GlobalEvent:AddListener(MainEvent.ChangeMidTipIcon, call_back)

    local function call_back(old_power, new_power, attr_list)

        local panel = LoadingCtrl:GetInstance().loadingPanel
        if (panel and not panel.is_dctored) then

            local function step()
                self:ShowChangePowerTip(old_power, new_power, attr_list)
            end
            GlobalSchedule:StartOnce(step, 3)
        else
            self:ShowChangePowerTip(old_power, new_power, attr_list)
        end

    end
    GlobalEvent:AddListener(MainEvent.ChangePower, call_back)

    local function call_back(data)
        --等级奖励
        self.model.levelRewards = data
        self.model:Brocast(MainEvent.LevelRewardRet)
    end
    GlobalEvent.AddEventListener(WelfareEvent.Welfare_Global_LevelRewardDataEvent, call_back)

    local function step()
        if TestDestroy then
            local ignoreList = {
                ["Node"] = true,
                ["BaseItem"] = true,
                ["BasePanel"] = true,
                ["WindowPanel"] = true,
                ["BaseCloneItem"] = true,
                ["BaseWidget"] = true,
                ["UIPetModel"] = true,
                ["UIGodModel"] = true,
                ["UINpcModel"] = true,
            }
            TestDestroy = false
            local len = #TestDestroyClassList
            for i = 1, len do
                local className = TestDestroyClassList[i]
                if not ignoreList[className] then
                    local node = _G[className]
                    if not node then
                        logError("class is nil " .. className)
                    end
                    if node and not iskindof(node, "UIModel") and not iskindof(node, "BaseEffect") and not iskindof(node, "BaseWidget") and not iskindof(node, "BaseCloneItem") and not node.__cache_count then
                        local status, err = pcall(node.new)
                        node = nil
                        if status then
                            node = err
                        else
                            logError(className .. " 打开失败," .. err)
                        end
                        status, err = nil, nil
                        if node then
                            if iskindof(node, "BasePanel") then
                                node:Open()
                                status, err = pcall(node.Close, node)
                            else
                                status, err = pcall(node.destroy, node)
                            end
                        end

                        if not status and err then
                            logError(className .. " 关闭失败" .. err)
                        end
                    end
                end
            end
        end
    end

    local function call_back()
        if TestDestroy then
            GlobalSchedule:StartOnce(step, 10)
        end
    end
    GlobalEvent:AddListener(EventName.HotUpdateSuccess, call_back)

    local function callback()
        self.model:UpdateKillBuff()
    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("buffs",callback)

    local function call_back()
        self.model:RetainEvenKillNum()
    end
    GlobalEvent:AddListener(SceneEvent.KILL_MONSTER, call_back)
end

function MainController:HandleIconCheck(id)
    self:AddMainTopRightIcon(id)
    self:AddMainTopLeftIcon(id)
end

function MainController:ShowChangePowerTip(old_power, new_power, attr_list)
    -- Yzprint('--LaoY MainController.lua,line 213--',old_power, new_power,new_power - old_power, attr_list)
    -- Yzdump(attr_list,"attr_list")
    -- traceback()
    local panel = lua_panelMgr:GetPanel(PowerChange)
    if panel then
        panel:ChangeAttr(old_power, new_power, attr_list)
    else
        lua_panelMgr:OpenPanel(PowerChange, old_power, new_power, attr_list)
    end
end


-- overwrite
function MainController:GameStart()
    local function step()
        GlobalEvent:Brocast(MainEvent.OpenMainPanel)
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end

function MainController:CheckMainTopRightIcon()
    for k, cf in pairs(IconConfig.TopRightConfig) do
        if cf.is_auto and not self.model.right_top_icon_list[cf.key_str] and OpenTipModel.GetInstance():IsOpenSystem(cf.id, cf.sub_id) then
            self.model:AddRightTopIcon(cf.key_str)
        end
    end
end

function MainController:AddMainTopRightIcon(id)
    local sys_cf = Config.db_sysopen[id]
    local key = sys_cf.key
    local icon_cf = IconConfig.TopRightConfig[key]
    if not icon_cf or icon_cf.is_auto == false then
        return
    end
    self.model:AddRightTopIcon(key)
end

--------------------左上角

function MainController:CheckMainTopLeftIcon()
    for k, cf in pairs(IconConfig.TopLeftConfig) do
        if cf.is_auto and not self.model.left_top_icon_list[cf.key_str] and OpenTipModel.GetInstance():IsOpenSystem(cf.id, cf.sub_id) then
            self.model:AddLeftTopIcon(cf.key_str)
        end
    end
end

function MainController:AddMainTopLeftIcon(id)
    local sys_cf = Config.db_sysopen[id]
    local key = sys_cf.key
    local icon_cf = IconConfig.TopLeftConfig[key]
    if not icon_cf or icon_cf.is_auto == false then
        return
    end
    self.model:AddLeftTopIcon(key)
end
