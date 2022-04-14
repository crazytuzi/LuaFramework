--机甲竞速游戏主界面
RaceMainPanel = RaceMainPanel or class("RaceMainPanel",BasePanel)

function RaceMainPanel:ctor()
    self.abName = "Race"
    self.assetName = "RaceMainPanel"
    self.layer = "UI"

    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.global_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.bottom_layer = nil  --bottom层
    self.top_layer = nil --top层

    self.cur_start_countdown_second = 10  --当前机甲竞速开始倒计时剩余秒数
    self.start_countdown_schedule_id = nil  --机甲竞速开始倒计时的定时器id

    self.end_countdown_schedule_id = nil  --机甲竞速结束倒计时的定时器id
    self.end_time = 0  --副本结束时间
    
    self.last_countdown_schedule_id = nil  --机甲竞速最后10秒倒计时的定时器id

    self.race_timer = 0  --机甲竞速计时
    self.race_timer_schedule_id = nil ---机甲竞速计时的定时器id

    self.player_race_time = nil --玩家最终竞速时长

    self.sum_input_countdown_second = 8  --指令输入倒计时总秒数
    self.cur_input_countdown_second = self.sum_input_countdown_second --当前指令输入倒计时剩余秒数
    self.input_countdown_interval = 0.1 --指令输入倒计时刷新间隔
    self.input_countdown_schedule_id = nil  --指令输入倒计时的定时器id
    self.is_stop_input_countdown = false --是否暂停指令输入倒计时

    self.cur_player_instruct_batch = 1  --当前玩家指令批数
    self.max_instruct_batch = nil  --最大指令批数
    self.conmand_cfgs = {}  --指令配置 key为指令批数 value为对应配置

    self.arrow_items = {}  --指令箭头UI项

    self.can_input = false  --玩家是否能进行指令输入
    self.cur_await_input_instructs = {} --当前等待输入的指令列表
    self.cur_await_input_instruct_index = 1 --当前等待输入的指令索引

    self.all_datas = {}  --所有机甲数据 key为uid
    self.player_data = nil  --玩家数据 key为uid

    self.all_race_uids = {}  --所有竞速中的机甲uid key和value都为uid
    self.race_range = {}  --排名 key为名次 value为uid

    self.orignal_speed = RaceConfig.MachineArmorSpeed * SceneConstant.PixelsPerUnit  --初始速度

    self.move_schedule_id = nil  --移动机甲与摄像机的定时器id
    self.check_distance_schedule_id = nil  --检查距离的定时器id
    self.robot_speed_up_schedule_id = nil  --机器人加速的定时器id

    self.uid_and_buff_schedule_id_map = {}  --uid与加速buff的定时器id的映射

    self.race_distance = nil  --竞速起点与终点的总距离
    self.mini_map_progress_length = 128.5  --小地图进度长度



    self.rank_items = {}  --排名UI项列表  key为uid value为RankItem
    self.final_rank = {}  --最终排名uid列表（已到终点的） key为名次 value为uid
    self.temp_rank = {}  --临时排名uid列表（未到终点的） key为名次 value为uid

    self.is_skip_arrow_scale = true  --是否跳过箭头UI缩放效果

    self.main_top_left = nil --左上角人物头像和血条的界面

    self.guide_item = nil  --引导UI
    self.guide_schedule_id = nil  --引导UI销毁的定时器id
    
    self.img_speed_up_scale_time = 0.0625  --加速图标缩放时间（单次）
    self.perfect_and_miss_scale_time = 0.0625  --perfect和miss图标缩放时间（单次）
    self.perfect_and_miss_hide_time = 1  --perfect和miss图标显示后的隐藏时间
    self.count_down_txt_scale_time = 0.5  --倒计时缩放时间
    self.arrow_scale_time = 0.25  --箭头缩放时间（单次）
    self.stop_input_time = 1.5  --指令输入完成后，暂停输入接受的时间

    self.is_finish = false  --玩家是否到达终点
end

function RaceMainPanel:dctor()


    GlobalEvent:Brocast(EventName.EndRace)

    --删除玩家身上可能存在的烟花特效
    EffectManager.GetInstance():RemoveAllSceneEffect(self.player_data.machine_armor)

    self:HandleLayer(true)

    self:StopAllSchedule()

  

    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end

    if table.nums(self.global_events) > 0 then
         GlobalEvent:RemoveTabListener(self.global_events)
        self.global_events = nil
    end

    for k,v in pairs(self.arrow_items) do
        v:destroy()
    end
    self.arrow_items = nil

    for k,v in pairs(self.rank_items) do
        v:destroy()
    end
    self.rank_items = nil

    if self.main_top_left then
        self.main_top_left:destroy()
        self.main_top_left = nil
    end

    self.all_datas = nil
    self.player_data = nil

    if self.guide_item then
        self.guide_item:destroy()
        self.guide_item = nil
    end
end

function RaceMainPanel:LoadCallBack(  )
    self.nodes = {
        "perfect","miss",
        "speed_up_1","speed_up_3","speed_up_2",
        "finish","player_flag",
        "left_arrows/btn_arrow_right","right_arrows/btn_arrow_up","right_arrows/btn_arrow_down","left_arrows/btn_arrow_left",
        "mid_arrows/arrow_bg/arrow_point_2","mid_arrows/arrow_bg/arrow_point_5","mid_arrows/arrow_bg/arrow_point_3","mid_arrows/arrow_bg/arrow_point_4","mid_arrows/arrow_bg/arrow_point_1","mid_arrows/arrow_bg/arrow_point_6","mid_arrows/arrow_bg/arrow_point_7","mid_arrows/arrow_bg/arrow_point_8",
        "mid_arrows/txt_input_countdown","mid_arrows/scrollbar_progress",
        "start_countdown/txt_start_countdown","start_countdown",
        "race_start","race_end",
        "end_countdown","end_countdown/txt_end_countdown",
        "last_countdown","last_countdown/txt_last_countdown",
        "mini_map",
        "mini_map/group/pos_1","mini_map/group/pos_2","mini_map/group/pos_3",
        "rank",
        "rank/txt_best_record","rank/txt_cur_timer",
        "rank/rank_container",
        "btn_exit",
        "guide_container","guide_container/click_node",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    
    --关闭UI层其他界面
    local list = LuaPanelManager.GetInstance().panel_list["UI"]
    for k,v in pairs(list) do
       if k ~= self then
           LuaPanelManager.GetInstance():ClosePanel(k)
       end
    end
   
    self.scene_layer = GetImage(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Scene))
    self.bottom_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Bottom)
    self.top_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Top)
    self.scene_obj = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObj)
    self.scene_text = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    self.scene_image = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneImage)


    self:HandleLayer(false)

    self.camera_trans =  MapManager.Instance.sceneCamera.transform
    SetGlobalPositionX(self.camera_trans,RaceConfig.CameraOriginalPosX)

    --请求副本信息
    DungeonCtrl.GetInstance():RequeseExpDungeonInfo()

end

function RaceMainPanel:InitUI()
    self.txt_input_countdown = GetText(self.txt_input_countdown)
    self.txt_start_countdown = GetText(self.txt_start_countdown)
    self.txt_end_countdown = GetText(self.txt_end_countdown)
    self.txt_last_countdown = GetText(self.txt_last_countdown)
    self.scrollbar_progress = GetScrollbar(self.scrollbar_progress)

    self.txt_cur_timer = GetText(self.txt_cur_timer)
    self.txt_best_record = GetText(self.txt_best_record)

    SetVisible(self.end_countdown,false)

    self.main_top_left = MainTopLeft(self.transform,self.layer)

    local function call_back()
       --禁用左上角头像点击
       self.main_top_left.transform:GetComponent("GraphicRaycaster").enabled = false
        
        --隐藏vip相关UI
       SetVisible( self.main_top_left.transform:Find("vip_con"),false)

       --适配
       SetAlignType(self.main_top_left, bit.bor(AlignType.Left, AlignType.Top))

       --防止被加速图标遮挡
       self.main_top_left.transform:SetAsLastSibling()
    end
    self.main_top_left.loaded_call_back = call_back

    --适配
    SetAlignType(self.rank, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.mini_map, bit.bor(AlignType.Right, AlignType.Top))
    SetAlignType(self.btn_exit, bit.bor(AlignType.Right, AlignType.Top))

end

function RaceMainPanel:AddEvent()
    local function call_back()
        self:OnArrowClick("left")
    end
    AddButtonEvent(self.btn_arrow_left.gameObject,call_back)

    local function call_back()
        self:OnArrowClick("right")
    end
    AddButtonEvent(self.btn_arrow_right.gameObject,call_back)

    local function call_back()
        self:OnArrowClick("up")
    end
    AddButtonEvent(self.btn_arrow_up.gameObject,call_back)

    local function call_back()
        self:OnArrowClick("down")
    end
    AddButtonEvent(self.btn_arrow_down.gameObject,call_back)

    local function call_back()
        --logError("点击了退出")
        local function call_back_2()
           --[[  DungeonCtrl:GetInstance():RequestLeaveDungeon();
            self:Close() ]]
            self.player_data.rank = 3
            self.player_race_time = self.race_timer
            self:RaceEnd()
        end
        Dialog.ShowTwo("Tip", "Are you sure you want to leave?\n(Leave now will still cost your attempts)", "Confirm", call_back_2, nil, "Cancel", nil, nil)
    end
    AddClickEvent(self.btn_exit.gameObject,call_back)

    local function call_back(  )
        
    end
    AddButtonEvent(self.click_node.gameObject,call_back)


    local function call_back(info)
		if info.stype ==  enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE then
			self.race_model.best_record = info.best_record
            self.race_model.enter_times = info.enter_times
            self.race_model.rest_times = info.rest_times
			--logError("接收机甲竞速副本信息 best_record:"..self.race_model.best_record..",enter_times:"..self.race_model.enter_times..",rest_times:"..self.race_model.rest_times)

            ---刷新最佳纪录
            local formatTime = "%02d";
            local time_tab = TimeManager:GetLastTimeBySeconds(self.race_model.best_record)
            
            time_tab.min = time_tab.min or 0
            time_tab.sec =  time_tab.sec or 0

            --毫秒部分
            local m_sec = self.race_timer%1
            local time_str = string.format(formatTime, time_tab.min) .. ":".. string.format(formatTime, time_tab.sec) .. ":" .. string.format(formatTime, m_sec * 100)

            self.txt_best_record.text = time_str
        end
	end
	self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, call_back);

    --防止因为关闭了某个界面导致主界面被重新打开
    local function call_back()
        SetVisible(self.bottom_layer,false)
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(EventName.ClosePanel, call_back);

    --立即调用副本结束回调 以打开结束界面
    local function call_back(time,cb)
        if cb then
            cb()
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_AUTO_EXIT, call_back);
end

--data
function RaceMainPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end

end

function RaceMainPanel:UpdateView()
    self.need_update_view = false

    --开始倒计时
    self:StartRaceStartCountdown()
    --创建机甲
    self:CreateMachineArmor()
    --创建排名UI项
    self:CreateRankItems()
end

--处理各个层
function RaceMainPanel:HandleLayer(visible)
    SetVisible(self.bottom_layer,visible)
    self.scene_layer.raycastTarget = visible

    --主角
    SetVisible(self.scene_obj:GetChild(2):GetChild(1),visible)
    SetVisible(self.scene_obj:GetChild(2):GetChild(2),visible)

    --法宝 宠物等其他东西的显示控制
    for i=0,self.scene_obj.childCount - 1 do
        if i >= 3 then
            SetVisible(self.scene_obj:GetChild(i),visible)
        end
    end
 
    SetVisible(self.scene_text:GetChild(0),visible)

    SetVisible(self.scene_image,visible)
end

--停止所有定时器
function RaceMainPanel:StopAllSchedule()
    if self.start_countdown_schedule_id then
        GlobalSchedule:Stop(self.start_countdown_schedule_id)
        self.start_countdown_schedule_id = nil
    end

    if self.end_countdown_schedule_id then
        GlobalSchedule:Stop(self.end_countdown_schedule_id)
        self.end_countdown_schedule_id = nil
    end

    if self.last_countdown_schedule_id then
        GlobalSchedule:Stop(self.last_countdown_schedule_id)
        self.last_countdown_schedule_id = nil
    end
    SetLocalScale(self.txt_last_countdown.transform,1,1,1) --复原scale

    if self.race_timer_schedule_id then
        GlobalSchedule:Stop(self.race_timer_schedule_id)
        self.race_timer_schedule_id = nil
    end

    if self.input_countdown_schedule_id then
        GlobalSchedule:Stop(self.input_countdown_schedule_id)
        self.input_countdown_schedule_id = nil
    end

    if self.move_schedule_id then
        GlobalSchedule:Stop(self.move_schedule_id)
        self.move_schedule_id = nil
    end
    self:ChangeAllMachineArmorState(SceneConstant.ActionName.idle)

    if  self.check_distance_schedule_id then
        GlobalSchedule:Stop( self.check_distance_schedule_id)
        self.check_distance_schedule_id = nil
    end

    if  self.robot_speed_up_schedule_id then
        GlobalSchedule:Stop( self.robot_speed_up_schedule_id)
        self.robot_speed_up_schedule_id = nil
    end

    if self.uid_and_buff_schedule_id_map then
        for k,v in pairs(self.uid_and_buff_schedule_id_map) do
            GlobalSchedule:Stop(v)
        end
        self.uid_and_buff_schedule_id_map = nil
    end
  
    if  self.guide_schedule_id then
        GlobalSchedule:Stop(  self.guide_schedule_id )
        self.guide_schedule_id = nil
    end

    --logError("停止了所有定时器")
end

--开始机甲竞速开始倒计时
function RaceMainPanel:StartRaceStartCountdown()
    
    local function call_back(  )
        self.cur_start_countdown_second = self.cur_start_countdown_second - 1

        if self.cur_start_countdown_second == 1 then
            --提前点开始结束倒计时
            self:StartRaceEndCountdown()
        end

        if self.cur_start_countdown_second < 1 then

            GlobalSchedule:Stop(self.start_countdown_schedule_id)
            self.start_countdown_schedule_id = nil

            --开始倒计时结束 
            SetVisible(self.start_countdown,false)
            SetVisible(self.race_start,true)
            local function race_start_call_back(  )
                --等1秒后隐藏结束，正式开始机甲竞速
                SetVisible(self.race_start,false)
                self:StartRaceTimer()
                self:RaceStart()
            end
            GlobalSchedule:StartOnce(race_start_call_back,1)
            return
        end

        self.txt_start_countdown.text = self.cur_start_countdown_second 

        --缩放效果
        local function smooth_call_back(num)
            if self.txt_start_countdown then
                SetLocalScale(self.txt_start_countdown.transform,num,num,1)
            end
        end
        TimelineManager.GetInstance():SmoothNumber(2,1,self.count_down_txt_scale_time,smooth_call_back)
    end

    self.start_countdown_schedule_id = GlobalSchedule:Start(call_back,1)


    --引导
    self.guide_item = GuideItem2(self.guide_container)

    local guide_step = {}
    guide_step.click_child="click_node"
    guide_step.auto_click=0
    --guide_step.sec=10
    guide_step.type=2
    guide_step.res_type=6
    guide_step.content = "Enter the right command in time to accelerate your mecha"
    guide_step.off_set = "{425,-196}"
    guide_step.button_effect=0
    guide_step.sound= ""
    guide_step.des= ""
    guide_step.delay=0
    guide_step.is_clear=1
    guide_step.scene_type=""
    guide_step.scale = 0.85

    self.guide_item:SetData(guide_step, self.guide_container)

    --10秒后销毁引导UI
    local function call_back(  )
        self.guide_schedule_id = nil
        self.guide_item:destroy()
        self.guide_item = nil
    end
    self.guide_schedule_id = GlobalSchedule:StartOnce(call_back,10)

end


--开始机甲竞速副本结束倒计时
function RaceMainPanel:StartRaceEndCountdown(  )

    --延迟一秒后再显示
    local function call_back(  )
        SetVisible(self.end_countdown,true)
    end
    GlobalSchedule:StartOnce(call_back,1)

    local data = DungeonModel:GetInstance().DungeEnter[DungeonModel:GetInstance().curDungeonID];
    if not data then
        return
    end

    self.end_time = data.etime

    local time_tab = nil;
    local time_str = "";
    local formatTime = "%02d";

    local function call_back(  )
        
        time_tab = TimeManager:GetLastTimeData(os.time(), self.end_time);
            if table.isempty(time_tab) then
                --logError("机甲竞速副本倒计时的time_tab为空")
            else

                time_tab.min = time_tab.min or 0
                time_tab.sec =  time_tab.sec or 0

                local time_str = string.format(formatTime, time_tab.min) .. ":" .. string.format(formatTime, time_tab.sec)

                --剩余时间不足10秒 开始最后10秒倒计时
                if time_tab.min <= 0 and time_tab.sec <= 10 then
                    --停掉副本结束倒计时
                    if self.end_countdown_schedule_id then
                    GlobalSchedule:Stop(self.end_countdown_schedule_id)
                    self.end_countdown_schedule_id = nil
                    end

                    self:StartRaceLastCountdown()
                end
                self.txt_end_countdown.text = time_str;--"副本倒计时: " 


            end
    end
    self.end_countdown_schedule_id = GlobalSchedule:Start(call_back,1)
end

--开始机甲竞速计时
function RaceMainPanel:StartRaceTimer(  )
    local function call_back(  )
        self.race_timer = self.race_timer + 0.05
        
        local formatTime = "%02d";
        local time_tab = TimeManager:GetLastTimeBySeconds(self.race_timer)

        time_tab.min = time_tab.min or 0
        time_tab.sec =  time_tab.sec or 0

        --毫秒部分
        local m_sec = self.race_timer%1
        local time_str = string.format(formatTime, time_tab.min) .. ":".. string.format(formatTime, time_tab.sec) .. ":" .. string.format(formatTime, m_sec * 100)
        self.txt_cur_timer.text = time_str
    end
    self.race_timer_schedule_id = GlobalSchedule:Start(call_back,0.05)
end

--开始最后10秒结束倒计时
function RaceMainPanel:StartRaceLastCountdown(  )

    --倒计时已经开始过了 直接返回
    if self.last_countdown_schedule_id then
        return
    end


    --logError("最后10秒倒计时开始")
    SetVisible(self.end_countdown,false)
    SetVisible(self.last_countdown,true)

    local last_time = 10
   


    local function call_back()

        if not self.txt_last_countdown then
            if self.last_countdown_schedule_id then
                GlobalSchedule:Stop(self.last_countdown_schedule_id)
                self.last_countdown_schedule_id = nil
            end
        end

        local function smooth_call_back(num)
            if self.txt_last_countdown then
                SetLocalScale(self.txt_last_countdown.transform,num,num,1)
            end
        end
        TimelineManager.GetInstance():SmoothNumber(1.2,1,self.count_down_txt_scale_time,smooth_call_back)

        last_time = last_time - 1
        
        self.txt_last_countdown.text = last_time

        if last_time <= 0 then
            --停止最后10秒倒计时
            GlobalSchedule:Stop(self.last_countdown_schedule_id)
            self.last_countdown_schedule_id = nil
            SetVisible(self.last_countdown,false)

            --显示结束图片
            SetVisible(self.race_end,true)
            --logError("时间到了")
            if not self.player_race_time then
                self.player_race_time = self.race_timer
            end
           
            self:RaceEnd()
        end
    end
    self.last_countdown_schedule_id = GlobalSchedule:Start(call_back,1)
end

--机甲竞速开始
function RaceMainPanel:RaceStart()
    --logError("机甲竞速开始")
    SetVisible(self.txt_input_countdown,true)

    --收集对应进入次数的指令配置信息
    for k,v in pairs(self.race_model.conmand_cfgs) do
        if self.race_model.enter_times >= v.min_time and self.race_model.enter_times <= v.max_time then
             self.conmand_cfgs[v.console] = v
        end
    end
    self.max_instruct_batch = table.nums(self.conmand_cfgs)

    self:UpdateInstruct()

    self.can_input = true

    --获取scene obj 并设置对应加速图标
    local num = 1
    for k,v in pairs(self.all_datas) do
        local machine_armor = SceneManager.GetInstance():GetObject(k)
        v.machine_armor = machine_armor
        v.img_speed_up = self["speed_up_"..num]
        num = num + 1
    end

    

    --开始移动机甲
    self:StartMoveMachineArmor()

    --开始机器人加速判定
    self:StartRandomRobotSpeedUp()

    GlobalEvent:Brocast(EventName.StartRace)
    
end

--刷新指令
function RaceMainPanel:UpdateInstruct()

    --logError("指令批数刷新，当前批数："..self.cur_player_instruct_batch)

    --重置相关数据
    self.cur_await_input_instructs = {}
    self.cur_await_input_instruct_index = 1
    self.cur_input_countdown_second = self.sum_input_countdown_second

    --刷新指令箭头UI并开始新的指令输入倒计时
  
    self:StartInputCountdown()


    if self.is_skip_arrow_scale then
        --第一次刷新箭头UI时 跳过缩放
        self.is_skip_arrow_scale = false
        self:UpdateArrowItem()
    else
        
       

        
        --先暂停输入 和 输入倒计时
        self.can_input = false
        self.is_stop_input_countdown = true

        --箭头刷新时的缩放效果
        local function call_back(num)
            for k,v in pairs(self.arrow_items) do
                SetLocalScale(v.transform,num,num,1)
            end
        
            if num == 1.2 then
                local function call_back2(num)
                    for k,v in pairs(self.arrow_items) do
                        SetLocalScale(v.transform,num,num,1)
                    end
                end
                TimelineManager.GetInstance():SmoothNumber(1.2,1,self.arrow_scale_time,call_back2)
            end

        end
        TimelineManager.GetInstance():SmoothNumber(1,1.2,self.arrow_scale_time,call_back)


        --等1.5秒再允许输入和开始输入倒计时
        local function call_back(  )
            self.can_input = true
            self.is_stop_input_countdown = false

            --重新允许输入后再刷新指令箭头UI 开始指令输入倒计时
            self:UpdateArrowItem()
        end
        GlobalSchedule:StartOnce(call_back,self.stop_input_time)
    end

   
end

--刷新指令箭头UI
function RaceMainPanel:UpdateArrowItem()

    --当前指令批数对应的指令数量
    local count = self.conmand_cfgs[self.cur_player_instruct_batch].count
    --logError("指令刷新数量："..count)
    for i=1,count do
        --随机指令箭头
        local arrow_num = math.random(1,4)
        local arrow_name = self.race_model.arrows[arrow_num]
        self.cur_await_input_instructs[i] = arrow_name

        local arrow_item = self.arrow_items[i] or ArrowItem(self["arrow_point_"..i])
        --SetVisible(arrow_item.transform,true)
        self.arrow_items[i] = arrow_item

        local data = {}
        data.arrow_name = arrow_name
        ----logError("随机指令："..arrow_name)
        arrow_item:SetData(data)
    end

  

end

--开始指令输入倒计时
function RaceMainPanel:StartInputCountdown()

    --正在倒计时的要停下来 然后重新开始倒计时
    if self.input_countdown_schedule_id then
        GlobalSchedule:Stop(self.input_countdown_schedule_id)
            self.input_countdown_schedule_id = nil
    end

    local function call_back()

        if self.is_stop_input_countdown then
            --暂停指令输入倒计时
            return;
        end

        self.cur_input_countdown_second = self.cur_input_countdown_second - self.input_countdown_interval
        
        if self.cur_input_countdown_second < 0 then
            --倒计时时间到了 显示miss 刷新一组新指令

            self:ShowPerfectOrMiss(false)

            GlobalSchedule:Stop(self.input_countdown_schedule_id)
            self.input_countdown_schedule_id = nil

            self:UpdateInstruct()
        end

        --只显示整数秒数
        local num = self.cur_input_countdown_second
        num = math.floor(num + 1)
        self.txt_input_countdown.text = num .. "s"

        --进度
        local progress = self.cur_input_countdown_second / self.sum_input_countdown_second
        self.scrollbar_progress.size = progress
    end

    self.input_countdown_schedule_id = GlobalSchedule:Start(call_back,self.input_countdown_interval)
end

--箭头按钮点击监听
function RaceMainPanel:OnArrowClick(arrow_name)
    if not self.can_input then
        return
    end
 
    --logError("输入指令"..arrow_name)

    local arrow_item = self.arrow_items[self.cur_await_input_instruct_index]
    if arrow_item.data.arrow_name == arrow_name then

        --指令输入正确
        
        arrow_item:InputRight()
        local count = #self.arrow_items
        if self.cur_await_input_instruct_index == count then
            --所有指令都已输入正确 刷新指令

            self:ShowPerfectOrMiss(true)

            --添加加速buff
            local buff = self.conmand_cfgs[self.cur_player_instruct_batch].buff
            self:SpeedUp(self.player_data.uid,buff)

            --只有输入指令正确才增加指令批数
            self.cur_player_instruct_batch = self.cur_player_instruct_batch + 1
            if self.cur_player_instruct_batch > self.max_instruct_batch then
                --限制为最大批数
                self.cur_player_instruct_batch = self.max_instruct_batch
            end
            self:UpdateInstruct()


        else
            self.cur_await_input_instruct_index = self.cur_await_input_instruct_index + 1
        end

    else
        --指令输入错误 输入进度重置 指令箭头UI全部变灰
        self.can_input = false
        self:ShowPerfectOrMiss(false)
        local function call_back()
            
            for i=1,self.cur_await_input_instruct_index do
                self.arrow_items[i]:ShowGray()
            end

            self.can_input = true
            self.cur_await_input_instruct_index = 1
        end

        arrow_item:InputError(call_back)
    end
end

--创建机甲
function RaceMainPanel:CreateMachineArmor()
    local actors = {}
    local flag = false
    local main_role_data =  RoleInfoModel.GetInstance():GetMainRoleData()

    --玩家机甲固定到2号位
    local temp_tab = {}
    for k,v in pairs(self.race_model.race_roles) do
        if v.id == main_role_data.id then
            table.insert( temp_tab, 2,v )
        else
            table.insert( temp_tab,v )
        end
    end

    --如果self.race_model.race_roles第一位就是玩家 
    --那么在上面那段代码操作后Key就会变成2 3 4 需要手动校正一下
    if not temp_tab[1] then
        temp_tab[1] = temp_tab[4]
        temp_tab[4] = nil
    end

    self.race_model.race_roles = temp_tab

    --构造数据
    for k,v in pairs(self.race_model.race_roles) do
       local actor = {}
       actor.type = enum.ACTOR_TYPE.ACTOR_TYPE_MACHINEARMOR

       --uid
       if v.id == main_role_data.id then
           actor.uid = self.race_model.player_uid
       else
            if not flag then
                actor.uid = self.race_model.robot_1_uid
                flag = true
            else
                actor.uid = self.race_model.robot_2_uid
            end
       end

       actor.name = v.name

       --路径
       local path_cfg = Config.db_dunge_race_path[k]

       if not path_cfg then
            --logError("路径配置不存在-"..k)
            return
       end

       local start_point = String2Table(path_cfg.start_point)
       local end_point = String2Table(path_cfg.end_point)

       --初始坐标
       local coord = {}
       coord.x = start_point[1]
       coord.y = start_point[2]
       actor.coord = coord

       table.insert( actors, actor )

       --数据收集
       local data = self.all_datas[actor.uid] or {}
       self.all_datas[actor.uid] = data
       data.uid = actor.uid
       data.role_data = v
       data.name = actor.name
       data.index = k  --机甲从上到下的位置
       data.start_x = start_point[1]
       data.start_y = start_point[2]
       data.end_x = end_point[1]
       data.end_y = end_point[2]

       data.speed = self.orignal_speed
       data.is_player = v.id == main_role_data.id
       if data.is_player then
           self.player_data = data
           self.player_data.uid = actor.uid

           --TODO:
           --data.speed = self.orignal_speed * 5
       else 
           --TODO:
           --data.speed = self.orignal_speed * 5

           --机器人指令批数
           data.cur_robot_instruct_batch = 1
       end

     
       --table.insert( self.all_race_uids,actor.uid)
       self.all_race_uids[actor.uid] = actor.uid

       if not self.race_distance then
          self.race_distance =  end_point[1] - start_point[1]
       end
    end

    SceneManager.GetInstance():AddObjectList(actors)

    --设置玩家箭头标志图片位置
    local player_machine_armor = SceneManager.GetInstance():GetObject(self.race_model.player_uid)
    if player_machine_armor then
        local function call_back()
            SetVisible(self.player_flag,true)
            self:SetPlayerFlagImagePos()
        end
        player_machine_armor.loaded_call_back = call_back
    end

    
  
end

--开始移动机甲
function RaceMainPanel:StartMoveMachineArmor()

    --切换到跑
    self:ChangeAllMachineArmorState(SceneConstant.ActionName.run)

    local offset_x = self.player_data.machine_armor.transform.position.x - self.camera_trans.position.x

    --开始向右移动
    local function call_back()
      self:MoveMachineArmor()
      self:MoveCamera(offset_x)
    end
    self.move_schedule_id = GlobalSchedule:Start(call_back,0)

    --定时距离检测
    local function call_back()
        self:CheckDistance()

        if table.nums(self.all_race_uids) == 0 then
            --所有机甲都到终点
            --logError("所有机甲到达终点")
            self:RaceEnd()
        end
    end
    self.check_distance_schedule_id =  GlobalSchedule:Start(call_back,0.1)
end

--切换所有机甲状态
function RaceMainPanel:ChangeAllMachineArmorState(state_name)
    for k,v in pairs(self.all_datas) do
        self:ChangeMachineArmorState(v.machine_armor,state_name)
    end
end

--切换指定机甲状态
function RaceMainPanel:ChangeMachineArmorState(machine_armor,state_name)
    if machine_armor then
        machine_armor:ChangeMachineState(state_name,true)
    end
   
end

--移动机甲
function RaceMainPanel:MoveMachineArmor()
    for k,v in pairs(self.all_race_uids) do
        local data = self.all_datas[v]
        data.machine_armor:SetPosition(data.machine_armor.position.x + data.speed * Time.deltaTime,data.machine_armor.position.y)
    end
end

--移动相机
function RaceMainPanel:MoveCamera(offset_x)
    SetLocalPositionX(self.camera_trans, self.player_data.machine_armor.transform.position.x - offset_x)
end

--检查距离
function RaceMainPanel:CheckDistance(  )

    local distances = {} --终点距离列表 距离与data 的表

    for k,v in pairs(self.all_race_uids) do
        local data = self.all_datas[v]
        local distance = Mathf.Abs(data.machine_armor.position.x - data.end_x)
        if distance <= 10 or data.machine_armor.position.x > data.end_x  then
          --到终点了 移出列表 不再进行移动
          self.all_race_uids[k] = nil
          table.insert( self.final_rank,v)

          --切换状态
          self:ChangeMachineArmorState(data.machine_armor,SceneConstant.ActionName.idle)

          --移除可能存在的buff特效
          BuffManager.GetInstance():RemoveBuff(k)  
          EffectManager.GetInstance():RemoveAllSceneEffect(self.all_datas[k].machine_armor)
          --logError("移除buff和特效")

          --隐藏加速图标
          SetVisible(self.all_datas[k].img_speed_up,false)

          if data.is_player then
            --玩家到达终点后 停止输入接收和输入倒计时的定时器 停止机甲竞速计时
            self.player_race_time = self.race_timer
            self.can_input = false
            GlobalSchedule:Stop(self.input_countdown_schedule_id)
            self.input_countdown_schedule_id = nil
            GlobalSchedule:Stop(self.race_timer_schedule_id)
            self.race_timer_schedule_id = nil

            --显示抵达终点图片
            SetVisible(self.finish,true)

            --玩家到达终点时播放加速烟花特效
            local effect_cfg =  Config.db_effect[30001]
            local effect_name = effect_cfg.name
            local config= {
                pos = {x = 0,y = 2.55,z = 6.22}, scale = 1, speed = 1, is_loop = true,
            }
            local effect = SceneTargetEffect(self.player_data.machine_armor.transform,effect_name, EffectManager.SceneEffectType.Target, self)
            effect:SetConfig(config)
  
            self.is_finish = true
        end

          --有机甲到达终点了 尝试开始最后10秒倒计时
          self:StartRaceLastCountdown()

          --logError("到达终点-"..data.name)
       else
        local tab = {}
        tab.distance = distance
        tab.data = data
        table.insert( distances,tab)

       end

       --设置小地图进度
       local progress = 1 - distance / self.race_distance
       local pos_y = self.mini_map_progress_length * progress
       SetLocalPositionY(self["pos_"..data.index],pos_y)
    end

    --修改排名项UI的顺序
    local function sort_func(a,b)
        --距离近的靠前
        if a.distance ~= b.distance then
            return a.distance < b.distance
        end

        --距离相同时玩家靠前
        if a.data.is_player ~=  b.data.is_player then
            return a.data.is_player
        end
	end
    table.sort(distances,sort_func)

    self.temp_rank = {}
    for k,v in pairs(distances) do
        table.insert(self.temp_rank,v.data.uid)
    end
    self:SortRankItems()
end

--开始随机机器人加速
function RaceMainPanel:StartRandomRobotSpeedUp(  )

    --8秒一次判定是否进行机器人加速
    local function call_back()
        for k,v in pairs(self.all_race_uids) do
            local data = self.all_datas[v]     
            if not data.is_player then
                local target_num = self.conmand_cfgs[data.cur_robot_instruct_batch].command
                local random_num = Mathf.Random(1,10000)
                if random_num <= target_num then
                    --机器人加速
                    self:SpeedUp(v,self.conmand_cfgs[ data.cur_robot_instruct_batch].buff)

                    --增加批数
                    data.cur_robot_instruct_batch =  data.cur_robot_instruct_batch + 1
                    if  data.cur_robot_instruct_batch >= self.max_instruct_batch then
                        data.cur_robot_instruct_batch = self.max_instruct_batch
                    end
                end
            end       
        end

    end
    self.robot_speed_up_schedule_id = GlobalSchedule:Start(call_back,8)
end

--加速
function RaceMainPanel:SpeedUp(uid,buff_id)
    if not self.uid_and_buff_schedule_id_map then
        return
    end
    local schedule_id = self.uid_and_buff_schedule_id_map[uid]
    if schedule_id  then
        --已经有一个加速buff了 先移除 防止到时候提前给速度复原了
        BuffManager.GetInstance():RemoveBuff(uid)
        GlobalSchedule:Stop(schedule_id)
        self.uid_and_buff_schedule_id_map[uid] = nil
        logError("移除已有加速buff")
    end

    local buff_cfg = Config.db_buff[buff_id]

    local p_buff = {
		id = buff_id,
		type = buff_cfg.type,
	 	value = buff_cfg.value,
	 	eff = buff_cfg.effect,
	 	etime = os.time() + buff_cfg.last,
	 	group = buff_cfg.group,
     }
    --logError("添加buff,uid:"..uid..",buff_id:"..buff_id)
    BuffManager.GetInstance():AddBuff(uid,p_buff)
   
    --修改速度 切换状态
    local attrs = buff_cfg.attrs
    attrs = String2Table(attrs)
    local ratio = attrs[1][2] / 10000  --加速系数
    self.all_datas[uid].speed = self.orignal_speed + self.orignal_speed * ratio
    self:ChangeMachineArmorState(self.all_datas[uid].machine_armor,SceneConstant.ActionName.Fly)
    --logError("加速，系数"..ratio)

    --显示加速图标
    SetVisible(self.all_datas[uid].img_speed_up,true)
    local show_speed_up_schedule_id
    local function call_back()
        --显示期间需要刷新位置
        if self.all_datas then
            self:SetSpeedUpImagePos(self.all_datas[uid].machine_armor,self.all_datas[uid].img_speed_up)
        else
            GlobalSchedule.Stop(show_speed_up_schedule_id)
        end
    end
    show_speed_up_schedule_id = GlobalSchedule:Start(call_back,0.05)

    --时间到后要让速度复原
    local time = Config.db_buff[buff_id].last / 1000
    --加速图标缩放效果
    self:PingPongScale(self.all_datas[uid].img_speed_up,1,1.5,self.img_speed_up_scale_time)


    local schedule_id
    local function call_back()
        --移除buff
        BuffManager.GetInstance():RemoveBuff(uid)  
        --移除buff特效
        EffectManager.GetInstance():RemoveAllSceneEffect(self.all_datas[uid].machine_armor)  
        
        --logError("移除buff和特效")

        --恢复速度
        self.all_datas[uid].speed = self.orignal_speed  
       
        --移除定时器id
        if self.uid_and_buff_schedule_id_map then
            self.uid_and_buff_schedule_id_map[uid] = nil 
        end
       

        --加速后没到终点 切换状态到run
        if self.all_race_uids[uid] then
            self:ChangeMachineArmorState(self.all_datas[uid].machine_armor,SceneConstant.ActionName.run)
        end
       
        --隐藏加速图标
        SetVisible(self.all_datas[uid].img_speed_up,false)
        GlobalSchedule.Stop(show_speed_up_schedule_id)

        --logError("速度复原")
    end
    schedule_id = GlobalSchedule:StartOnce(call_back,time)
    self.uid_and_buff_schedule_id_map[uid] = schedule_id
end

--处理机甲竞速结束
--所有机甲到达终点或剩余时间为0时机甲竞速结束
function RaceMainPanel:RaceEnd(  )
    --logError("机甲竞速结束")
    self:StopAllSchedule()
    self:ChangeAllMachineArmorState(SceneConstant.ActionName.idle)

    SetVisible(self.last_countdown,false)

    --移除所有特效
    for k,v in pairs(self.all_datas) do
        --移除buff
        BuffManager.GetInstance():RemoveBuff(k)  
        --移除buff特效
        EffectManager.GetInstance():RemoveAllSceneEffect(v.machine_armor)
        --隐藏加速图标
        SetVisible(v.img_speed_up,false)
    end

   
    --上传竞速结果
    RaceController.GetInstance():RequestReportResult(self.is_finish,self.player_data.rank,self.player_race_time)

    --请求退出副本（获得奖励数据后再打开结束界面）
    DungeonCtrl:GetInstance():RequestLeaveDungeon();
end

--创建排名项UI
function RaceMainPanel:CreateRankItems()

    local rank = 2
    for k,v in pairs(self.all_datas) do

        local data = {}
        data.name = v.name
        data.role_data = v.role_data

        if v.is_player then
            self.rank_items[k] = RankItem(self.rank_container,self.layer,"PlayerRankItem")
            --玩家初始排名为1
            data.rank = 1
            data.role_icon_size = 63
        else
           self.rank_items[k] = RankItem(self.rank_container,self.layer,"RobotRankItem")
           data.rank = rank
           rank = rank + 1
           data.role_icon_size = 40
        end

        self.rank_items[k]:SetData(data)

        self.temp_rank[rank] = k
    end
end

--排序排名项UI
function RaceMainPanel:SortRankItems()
    local num = 0

    for k,v in pairs(self.final_rank) do
        num = num + 1
        self.rank_items[v]:ChangeRank(num)
        self.all_datas[v].rank = num
    end

    for k,v in pairs(self.temp_rank) do
        num = num + 1
        self.rank_items[v]:ChangeRank(num)
        self.all_datas[v].rank = num
    end
end

--显示指令输入正确或错误的艺术字
function RaceMainPanel:ShowPerfectOrMiss(is_perfect)

    local node = self.miss
    if is_perfect then
        node = self.perfect

        --播放perfect音效
        SoundManager.GetInstance():PlayById(54)
    end

    SetVisible(node,true)

    self:PingPongScale(node,1.5,2,self.perfect_and_miss_scale_time)


    local function call_back(  )
        SetVisible(node,false)
    end
    GlobalSchedule:StartOnce(call_back,self.perfect_and_miss_hide_time)
end

--设置加速图片位置
function RaceMainPanel:SetSpeedUpImagePos(machine_armor,speed_up_trans)
    local ui_pos = self:GetImagePosWithMachineArmor(machine_armor)
    if ui_pos then
        SetAnchoredPosition(speed_up_trans,ui_pos.x + 127.7,ui_pos.y + 80) --x 177.7
    else
        SetVisible(speed_up_trans,false)
    end
end

--设置玩家箭头标志图片位置
function RaceMainPanel:SetPlayerFlagImagePos()
    local player_machine_armor = SceneManager.GetInstance():GetObject(self.race_model.player_uid)
    local ui_pos = self:GetImagePosWithMachineArmor(player_machine_armor)
    if ui_pos then
        SetAnchoredPosition(self.player_flag,ui_pos.x + 22.9,ui_pos.y + 243)
    else
        SetVisible(self.player_flag,false)
    end
end

--获取对应机甲位置的UI图片位置
function RaceMainPanel:GetImagePosWithMachineArmor(machine_armor)
    local world_pos = machine_armor.transform.position
    local scene_pos = RectTransformUtility.WorldToScreenPoint(MapManager.Instance.sceneCamera,world_pos)
    local ui_layer = LayerManager.GetInstance():GetLayerByName(LayerManager.LayerNameList.UI)
    local rect = GetRectTransform(ui_layer)
    local ui_pos = nil
    local flag = false
    flag,ui_pos = RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,scene_pos,MapManager.Instance.uiCamera,nil)
    if flag then
       return ui_pos
    else
        --logError("加速图片坐标转换失败")
        return nil
    end
end

--来回缩放效果
function RaceMainPanel:PingPongScale(trans,old_size,target_size,duration)
    local function call_back(num)
        SetLocalScale(trans,num,num,1)
        if num == target_size then
           local function call_back_2(num)
            SetLocalScale(trans,num,num,1)
           end
           TimelineManager.GetInstance():SmoothNumber(target_size,old_size,duration,call_back_2)
        end
    end
    TimelineManager.GetInstance():SmoothNumber(old_size,target_size,duration,call_back)
end

--请求退出副本后 设置奖励数据
function RaceMainPanel:SetRaceReward(reward)

    SetVisible(self.btn_exit,false)

     --打开结束界面
     local panel = lua_panelMgr:GetPanelOrCreate(RaceEndPanel)
     local data = {}
     data.panel = self
     data.rank = self.player_data.rank
     data.race_time = self.player_race_time
     data.count = self.race_model.rest_times
     data.is_finish = self.is_finish
     data.reward = reward
     if self.race_model.task_id then
         --是任务进来的 结算界面就当次数满了那样显示 不出现再来一次按钮了
         data.count = 0
         self.race_model.task_id = nil
     end
     panel:Open()
     panel:SetData(data)
 
end
