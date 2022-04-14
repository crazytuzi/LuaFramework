RaceTipPanel = RaceTipPanel or class("RaceTipPanel",WindowPanel)

function RaceTipPanel:ctor()
    self.abName = "race"
    self.assetName = "RaceTipPanel"
    self.layer = "UI"

    self.panel_type = 4
    self.use_background = true  
    self.is_click_bg_close = true

    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.cur_second = 9 --当前秒数
    self.count_down_schedule_id = nil  --倒计时定时器
end

function RaceTipPanel:dctor()
    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end

       
    if self.count_down_schedule_id then
        GlobalSchedule:Stop(self.count_down_schedule_id)
        self.count_down_schedule_id = nil
    end
end

function RaceTipPanel:LoadCallBack()
    self.nodes = {
        "txt_des","btn_go","btn_go/txt_count_down",
    }

    self:GetChildren(self.nodes)

   
    self:InitUI()
    
    --活动未开启 直接隐藏按钮然后return掉就行
    if not self.race_model.is_active_open then
        SetVisible(self.btn_go,false)

        --改成true 处理活动自动弹窗的问题
        self.race_model.is_active_open = true

       return
    end


    self:AddEvent()
    if self.need_update_view then
       self:UpdateView()
    end
end

function RaceTipPanel:InitUI(  )
    self.txt_des = GetText(self.txt_des)
    self.txt_des.text = RaceConfig.RaceTip
    self.txt_count_down = GetText(self.txt_count_down)
end

function RaceTipPanel:AddEvent(  )
    local function call_back(  )
    
        if self.count_down_schedule_id then
            GlobalSchedule:Stop(self.count_down_schedule_id)
            self.count_down_schedule_id = nil
        end
        self:Close()
        
        --请求开始匹配
        RaceController.GetInstance():RequestMatchStart(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE,0)

        
    end
    AddClickEvent(self.btn_go.gameObject,call_back)
end

--data
function RaceTipPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function RaceTipPanel:UpdateView()
    self.need_update_view = false

    local function call_back(  )
        self.cur_second = self.cur_second - 1
        if self.cur_second < 0 then
            GlobalSchedule:Stop(self.count_down_schedule_id)
            self.count_down_schedule_id = nil
            
            self:Close()

            --请求开始匹配
            RaceController.GetInstance():RequestMatchStart(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE,0)

        else
            self.txt_count_down.text = self.cur_second
        end


    end
    self.count_down_schedule_id = GlobalSchedule:Start(call_back,1)
end
