--机甲竞速匹配成功界面
RaceMatchSuccPanel = RaceMatchSuccPanel or class("RaceMatchSuccPanel",WindowPanel)

function RaceMatchSuccPanel:ctor()
    self.abName = "Race"
    self.assetName = "RaceMatchSuccPanel"
    self.layer = "UI"

    self.panel_type = 4
    self.use_background = true  

    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.countdown_schedule_id = nil 
    
    self.cur_second = 30  --当前秒数

    self.role_icons = {} --玩家头像UI列表

    self.is_enter = false
end

function RaceMatchSuccPanel:dctor()
    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end

    if self.countdown_schedule_id then
        GlobalSchedule:Stop(self.countdown_schedule_id)
        self.countdown_schedule_id = nil
    end

    for k,v in ipairs(self.role_icons) do
        v:destroy()
    end
    self.role_icons = nil
end

function RaceMatchSuccPanel:LoadCallBack(  )
    self.nodes = {
        "txt_name_1","btn_start","txt_countdown","img_ready_1","txt_name_3","txt_name_2","role_icon_2","role_icon_1","img_ready_3","img_ready_2","role_icon_3",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    self:SetTileTextImage("race_image","title_match_succ",false)
   

    --隐藏关闭按钮
    SetVisible(self.bg_win.windowCloseBtn,false)
end

function RaceMatchSuccPanel:InitUI(  )
    self.txt_countdown = GetText(self.txt_countdown)

    self.txt_name_1 = GetText(self.txt_name_1)
    self.txt_name_2 = GetText(self.txt_name_2)
    self.txt_name_3 = GetText(self.txt_name_3)

end

function RaceMatchSuccPanel:AddEvent()

    --进入机甲竞速副本
    local function call_back()
        self:EnterRace()
    end
    AddClickEvent(self.btn_start.gameObject,call_back)
end

--data
function RaceMatchSuccPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function RaceMatchSuccPanel:UpdateView()
    self.need_update_view = false

   self:StartCountdown()
   self:UpdateRoleIcon()
end

--开始倒计时
function RaceMatchSuccPanel:StartCountdown(  )
    self.txt_countdown.text = self.cur_second

    local function call_back()
        self.cur_second = self.cur_second - 1
        if self.cur_second < 0 then
            self.cur_second = 0

            GlobalSchedule:Stop(self.countdown_schedule_id)
            self.countdown_schedule_id = nil
            
            self:EnterRace()
           

            return
        end

        self.txt_countdown.text = self.cur_second
    end
    self.countdown_schedule_id = GlobalSchedule:Start(call_back,1,60)
end

--刷新角色头像
function RaceMatchSuccPanel:UpdateRoleIcon()
    
    local main_role_data =  RoleInfoModel.GetInstance():GetMainRoleData()

    for i=1,3 do
        self.role_icons[i] = RoleIcon(self["role_icon_"..i])

        local param = {}
        param.is_squared = true
        param.size = 70
        local role_data = self.race_model.race_roles[i]
        param.role_data = role_data

        self.role_icons[i]:SetData(param)

        --玩家名字
        self["txt_name_"..i].text = role_data.name

        --当前玩家 修改名字颜色 隐藏已准备标志
        if role_data.id == main_role_data.id then
            SetColor( self["txt_name_"..i],184,77,74,255)
            SetVisible(self["img_ready_"..i],false)
        end
    end

end

--进入机甲竞速
function RaceMatchSuccPanel:EnterRace(  )
    if self.is_enter then
        return
    end

    self.is_enter = true

    self:Close()

    if self.race_model.task_id then
        --是任务进入的
        local param = {}
        param.task_id = self.race_model.task_id
        DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE, nil, nil, nil, nil,param)
    else
        DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE, nil, nil, nil, nil)
    end
end
