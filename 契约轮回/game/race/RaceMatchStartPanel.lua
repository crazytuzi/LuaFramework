--机甲竞速匹配开始界面
RaceMatchStartPanel = RaceMatchStartPanel or class("RaceMatchStartPanel",BasePanel)

function RaceMatchStartPanel:ctor()
    self.abName = "Race"
    self.assetName = "RaceMatchStartPanel"
    self.layer = "UI"

    self.use_background = true  
    self.is_click_bg_close = true

    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.countdown_schedule_id = nil 
    
    self.cur_second = 60  --当前秒数
end

function RaceMatchStartPanel:dctor()
    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end

    if self.countdown_schedule_id then
        GlobalSchedule:Stop(self.countdown_schedule_id)
        self.countdown_schedule_id = nil
    end
end

function RaceMatchStartPanel:LoadCallBack(  )
    self.nodes = {
        "txt_countdown","btn_cancel_match",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function RaceMatchStartPanel:InitUI(  )
    self.txt_countdown = GetText(self.txt_countdown)
end

function RaceMatchStartPanel:AddEvent(  )

    --取消匹配按钮
    local function call_back( )
        self:Close()
        RaceController.GetInstance():RequestMatchStop(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE)
    end
    AddClickEvent(self.btn_cancel_match.gameObject,call_back)

    --匹配成功
    local function call_back()
        self:Close()

        if lua_panelMgr:GetPanel(RaceMatchSuccPanel) then
            return
        end

        local panel = lua_panelMgr:GetPanelOrCreate(RaceMatchSuccPanel)
		local data = {}
		panel:Open()
        panel:SetData(data)
    end
    self.race_model:AddListener(RaceEvent.MatchSucc,call_back)

end

--data
function RaceMatchStartPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function RaceMatchStartPanel:UpdateView()
    self.need_update_view = false

    self:StartCountdown()
end

--开始倒计时
function RaceMatchStartPanel:StartCountdown()

    

    self.txt_countdown.text = self.cur_second

    local function call_back()
        self.cur_second = self.cur_second - 1
        if self.cur_second < 0 then
            self.cur_second = 0

            GlobalSchedule:Stop(self.countdown_schedule_id)
            self.countdown_schedule_id = nil

            RaceController.GetInstance():RequestMatchStop(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE)
            self:Close()
            return
        end

        self.txt_countdown.text = self.cur_second
    end
    self.countdown_schedule_id = GlobalSchedule:Start(call_back,1)
end
