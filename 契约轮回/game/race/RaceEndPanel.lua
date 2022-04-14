--机甲竞速结束界面
RaceEndPanel = RaceEndPanel or class("RaceEndPanel",BasePanel)

function RaceEndPanel:ctor()
    self.abName = "Race"
    self.assetName = "RaceEndPanel"
    self.layer = "UI"

    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.end_item = nil

    self.goods_icon_settors = {}  --奖励物品icon列表

    
    self.max_count = Config.db_daily[1011].count

    self.continue_count_down_schedule_id = nil  --自动继续倒计时的定时器id

    self.continue_count_down_second = 5  --自动继续倒计时描述
end

function RaceEndPanel:dctor()
    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end

    if self.end_item then
        self.end_item:destroy()
        self.end_item = nil
    end

    for k,v in pairs(self.goods_icon_settors) do
        v:destroy()
    end
    self.goods_icon_settors = nil

    if self.continue_count_down_schedule_id then
        GlobalSchedule:Stop(self.continue_count_down_schedule_id)
        self.continue_count_down_schedule_id = nil
    end
end

function RaceEndPanel:LoadCallBack(  )
    self.nodes = {
        "txt_race_time","scroll_view/view_port/content","img_rank","new_record",
        "continue_count_down/txt_continue_count_down","continue_count_down",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end


    local data = {}
    data.star = 7
    data.isClear = true
    self.end_item = RaceEndItem(self.transform, data,self);
    self.end_item:StartAutoClose(5);
    self.end_item:ShowStars(true);
    self.end_item.close_format = "Exit"

    local function call_back()

        --自动关闭后 如果次数还有剩 那就再来一次
        if self.data.count > 0 then
            self.race_model.is_replay = true
        end

        self:Close()
        self.data.panel:Close()
        SceneControler:GetInstance():RequestSceneLeave()
    end
    self.end_item:SetAutoCloseCallBack(call_back);

    local function call_back()
        self:Close()
        self.data.panel:Close()
        SceneControler:GetInstance():RequestSceneLeave()
    end

    self.end_item:SetCloseCallBack(call_back);

    if self.data.count > 0 then
    
        local color = ColorUtil.GetColor(ColorUtil.ColorType.Yellow)
        self.end_item.sure_format = string.format( "Once more(<color=#%s>%s</color>/%s)",color,self.data.count,self.max_count )
        --self.end_item.sure_format = "再来一次"
        
        local function call_back(  )
            self.race_model.is_replay = true
            self:Close()
            self.data.panel:Close()
            SceneControler:GetInstance():RequestSceneLeave()
        end
        self.end_item:ShowSureBtn(call_back)

        self:StartContinueCountdown()

    end

    SetVisible(self.transform,false)
   
end

function RaceEndPanel:InitUI(  )
    self.img_rank = GetImage(self.img_rank)
    self.txt_race_time = GetText(self.txt_race_time)
    self.txt_continue_count_down = GetText(self.txt_continue_count_down)
end

function RaceEndPanel:AddEvent(  )
    
end

--data
--panel 竞速主界面
--race_time 达到终点的时间
--rank 名次
--count 剩余进入次数
--is_finish 玩家是否到达终点
--reward 服务端下发的奖励数据
function RaceEndPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function RaceEndPanel:UpdateView()
    self.need_update_view = false

    lua_resMgr:SetImageTexture(self,self.img_rank,self.abName.."_image","rank_" .. self.data.rank)

    local formatTime = "%02d";
    local time_tab = TimeManager:GetLastTimeBySeconds(self.data.race_time)


    time_tab.min = time_tab.min or 0
    time_tab.sec = time_tab.sec or 0
    local time_str = string.format(formatTime, time_tab.min) .. "min".. string.format(formatTime, time_tab.sec).. "sec"
            
    
    self.txt_race_time.text = time_str

    --是否新纪录
    local is_new_record = self.race_model.best_record == 0 or self.data.race_time < self.race_model.best_record
    --完成竞速 并且是新纪录 才显示新纪录的字样
    SetVisible(self.new_record,self.data.is_finish and is_new_record)


    self:UpdateReward()
end

--刷新奖励
function RaceEndPanel:UpdateReward(  )
    for k,v in pairs(self.data.reward) do
        local item_id = k
        local num = v

        local icon_settor = GoodsIconSettorTwo(self.content)
        table.insert(self.goods_icon_settors,icon_settor )
        local param = {}
        param["item_id"] = item_id
        param["size"] = 70
        param["num"] = num
        param["can_click"] = true
        icon_settor:SetIcon(param)
    end
end

--开始自动继续倒计时
function RaceEndPanel:StartContinueCountdown(  )
    SetVisible(self.continue_count_down,true)

    local function call_back()
        self.continue_count_down_second = self.continue_count_down_second - 1
        self.txt_continue_count_down.text = self.continue_count_down_second
        if self.continue_count_down_second <= 0 then
            GlobalSchedule:Stop(self.continue_count_down_schedule_id)
            self.continue_count_down_schedule_id = nil
        end
    end
    self.continue_count_down_schedule_id = GlobalSchedule:Start(call_back,1)
end