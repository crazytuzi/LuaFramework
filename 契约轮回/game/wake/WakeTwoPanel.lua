--五次觉醒界面
WakeTwoPanel = WakeTwoPanel or class("WakeTwoPanel",BasePanel)

function WakeTwoPanel:ctor()
    self.abName = "wake"
    self.assetName = "WakeTwoPanel"
    self.layer = "UI"

    self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }

	self.win_type = 1				
	self.show_sidebar = false	
    self.is_hide_other_panel = true
    
    self.wake_model = WakeModel.GetInstance()
    self.wake_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.lines = {}  --线的列表
    self.grids = {}  --格子的列表
    self.img_grids = {} --格子的Image组件列表

    self.cur_step = self.wake_model:GetWake5Step()  --当前觉醒阶段

    self.cur_head_item = nil  --当前头像
    self.next_head_item = nil  --下一觉醒头像

    self.show_items = {}  --新增外形的items

    self.grids_effects = {}  --格子点亮后的特效列表

    self.btn_next_step_reddot = nil  --下一阶段按钮红点
    self.btn_wake_reddot = nil  --完成觉醒按钮红点

    local key = self.wake_model:GetWakeKey()
    self.wake_cfg = Config.db_wake[key]
end

function WakeTwoPanel:dctor()
    if table.nums(self.wake_model_events) > 0 then
        self.wake_model:RemoveTabListener(self.wake_model_events)
        self.wake_model_events = nil
    end

    destroySingle(self.ball_select_item)
    self.ball_select_item = nil

    destroySingle(self.cur_head_item)
    self.cur_head_item = nil

    
    destroySingle(self.next_head_item)
    self.next_head_item = nil

    destroyTab(self.show_items,true)

    self.lines = nil
    self.grids = nil
    self.img_grids = nil

    destroyTab(self.grids_effects,true)

    destroySingle(self.btn_next_step_reddot)
    self.btn_next_step_reddot = nil

    destroySingle(self.btn_wake_reddot)
    self.btn_wake_reddot = nil
end

function WakeTwoPanel:LoadCallBack(  )
    self.nodes = {
        "img_bg","title",
        "btn_close","txt_wake_tip","money_con",

        "balls_step_1/ball_24","balls_step_1/line_27","balls_step_1/ball_15","balls_step_1/ball_21","balls_step_1/ball_14","balls_step_1/line_18","balls_step_1/ball_22","balls_step_1/ball_17","balls_step_1/line_23","balls_step_1/line_14","balls_step_1/ball_18","balls_step_1/ball_25","balls_step_1/line_24","balls_step_1/line_17","balls_step_1/line_19","balls_step_1/line_21","balls_step_1/ball_23","balls_step_1/line_20","balls_step_1/line_16","balls_step_1/ball_13","balls_step_1/line_22","balls_step_1","balls_step_1/ball_20","balls_step_1/line_15","balls_step_1/ball_19","balls_step_1/line_26","balls_step_1/ball_26","balls_step_1/ball_27","balls_step_1/ball_16","balls_step_1/line_25",
    
        "balls_step_2/ball_30","balls_step_2/ball_35","balls_step_2/ball_46","balls_step_2/line_38","balls_step_2/ball_34","balls_step_2/ball_31","balls_step_2/line_34","balls_step_2/ball_40","balls_step_2/line_36","balls_step_2","balls_step_2/line_37","balls_step_2/line_35","balls_step_2/ball_32","balls_step_2/ball_44","balls_step_2/ball_42","balls_step_2/ball_33","balls_step_2/line_33","balls_step_2/ball_28","balls_step_2/line_39","balls_step_2/ball_29","balls_step_2/ball_47","balls_step_2/line_29","balls_step_2/ball_36","balls_step_2/line_30","balls_step_2/ball_39","balls_step_2/ball_41","balls_step_2/ball_38","balls_step_2/ball_37","balls_step_2/line_32","balls_step_2/ball_45","balls_step_2/line_31","balls_step_2/ball_43","balls_step_2/line_40","balls_step_2/line_43","balls_step_2/line_47","balls_step_2/line_42","balls_step_2/line_45","balls_step_2/line_46","balls_step_2/line_44","balls_step_2/line_41",

        "right/heads/improve/cur_head","right/heads/improve/next_head",

        "right/avatars/scrollview_avatar/viewport_avatar/content_avatar","right/avatars/scrollview_avatar/viewport_avatar/content_avatar/WakeEquipItem",
    
        "right/funs/txt_fun_opens",

        "right/limits/all_desc",
        "right/limits/all_desc/txt_open_grids","right/limits/all_desc/txt_open_level",

        "right/limits/btn_wake","right/limits/btn_next_step",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function WakeTwoPanel:InitUI(  )

    SetVisible(self.WakeEquipItem,false)

    --收集一下线和格子
    for i=13,47 do
    self.grids[i] = self["ball_" .. i]
       if i~= 13 and i~= 28 then
           self.lines[i] = self["line_"..i]
       end
    end

    self.img_bg = GetImage(self.img_bg)
    self.txt_wake_tip = GetText(self.txt_wake_tip)
    self.txt_fun_opens = GetText(self.txt_fun_opens)
    self.txt_open_grids = GetText(self.txt_open_grids)
    self.txt_open_level = GetText(self.txt_open_level)
    
    SetAlignType(self.title.transform, bit.bor(AlignType.Left, AlignType.Top))
	SetAlignType(self.btn_close.transform, bit.bor(AlignType.Right, AlignType.Top))
end

function WakeTwoPanel:AddEvent(  )

    --关闭按钮
    local function call_back(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,call_back)

    --处理格子返回数据
    local function call_back(  )
        self:HandleGridsData()
    end
    self.wake_model_events[#self.wake_model_events + 1] = self.wake_model:AddListener(WakeEvent.UpdateWakeGrid,call_back)

    --格子点击
    for k,v in pairs(self.grids) do
        local function call_back(target,x,y)
            local grid_id = k
		    local grid_cfg = Config.db_wake_grid[grid_id]
            local panel = lua_panelMgr:GetPanelOrCreate(WakeGridTipsPanel)
		    panel:SetData(grid_cfg)
		    panel:Open(target)
        end
        AddClickEvent(v.gameObject,call_back)
    end

      --下一阶段
    local function call_back(  )
        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
        if level < 520 then
            Notify.ShowText("Awaken requirement not reached")
            return
        end

        WakeController.GetInstance():RequestGoNextStep()

        self.cur_step = 2
        self.wake_model:SetWake5Step(2)
        
        self:HandleGridsData()

    end
    AddClickEvent(self.btn_next_step.gameObject,call_back)

    --觉醒按钮
    local function call_back(  )
        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
        if level < self.wake_cfg.level then
            Notify.ShowText("Awaken requirement not reached")
            return
        end
        WakeController.GetInstance():RequestWakeStart()
    end
    AddClickEvent(self.btn_wake.gameObject,call_back)


   --处理觉醒成功返回
    local function call_back(  )
        self:Close()
    end
    self.wake_model_events[#self.wake_model_events + 1] = self.wake_model:AddListener(WakeEvent.WakeSuccess,call_back)
end

--data
function WakeTwoPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function WakeTwoPanel:UpdateView()
    self.need_update_view = false

    self:UpdateBg()

    self:RequestGridsData()

    self:UpdateHead()
    self:UpdateAvatar()
    self:UpdateFuns()
end

--刷新背景
function WakeTwoPanel:UpdateBg()
	local key = self.wake_model:GetWakeKey()
	local wakeitem = Config.db_wake[key]
	local res = wakeitem.background
	lua_resMgr:SetImageTexture(self,self.img_bg, "iconasset/icon_big_bg_"..res, res)
end

--请求格子数据
function WakeTwoPanel:RequestGridsData(  )
    --logError("请求格子数据")
    WakeController.GetInstance():RequestWakeGrid()
end

--处理返回的格子数据
function WakeTwoPanel:HandleGridsData(  )
    --logError("当前激活的格子id-" .. self.wake_model.grid_id)
    if self.wake_model.grid_id >= 28 then
        --第二阶段格子激活中

        if self.cur_step == 1 then
            --处理换了设备的情况
            self.cur_step = 2
            self.wake_model:SetWake5Step(2)
        end

        self:UpdateWakeStep()
    elseif self.wake_model.grid_id == 27 then
        --第一阶段全部格子激活
        self:UpdateWakeStep()
    elseif self.wake_model.grid_id >= 12 then
        --第一阶段格子激活中
        self:UpdateWakeStep()
    else
       -- logError("grid_id无效，值为"..self.wake_model.grid_id)
    end
end

--刷新觉醒阶段
function WakeTwoPanel:UpdateWakeStep()
    self:UpdateLines()
    self:UpdateGrids()
    self:UpdateGridselectItem()
    self:UpdateTips()

   
    self:UpdateLimits()
end


--刷新线
function WakeTwoPanel:UpdateLines(  )
     --处理线的显示
     local start_index = 14
     local end_index = 27
     if self.cur_step== 2 then
         start_index = 29
         end_index = 47
     end
     for i=start_index,end_index do
         if self.wake_model.grid_id + 1  >= i then
             SetVisible(self.lines[i],true)
         else
             SetVisible(self.lines[i],false)
         end
     end
end

--刷新格子
function WakeTwoPanel:UpdateGrids(  )
    SetVisible(self.balls_step_1,self.cur_step == 1)
    SetVisible(self.balls_step_2,self.cur_step == 2)

    local start_index = 13
    local end_index = 27
    if self.cur_step== 2 then
        start_index = 28
        end_index = 47
    end
    for i=start_index,end_index do
        if self.wake_model.grid_id >= i then
            --已点亮的加上特效
            self.img_grids[i] = self.img_grids[i] or GetImage(self.grids[i])
            lua_resMgr:SetImageTexture(self,self.img_grids[i], 'wake_image', 'ball')
            self.grids_effects[i] = self.grids_effects[i] or UIEffect(self.grids[i], 10122)
        end
    end
end

--刷新格子选中特效Item
function WakeTwoPanel:UpdateGridselectItem(  )
    --显示当前待激活的格子的特效
    if self.ball_select_item then
		self.ball_select_item:destroy()
	end
	if self.wake_model.grid_id + 1 <= 47 then
		self.ball_select_item = WakeBallSelectItem(self.grids[self.wake_model.grid_id+1])
	end
end


--刷新tips
function WakeTwoPanel:UpdateTips(  )

    local tip = "Defeat Lv.500 or above monsters and have a chance to get Sage Shard"
    if self.cur_step == 2 then
        tip = "Defeat Lv.500 or above monsters and have a chance to get Sage Crystal"
    end
    self.txt_wake_tip.text = tip
end

--刷新头像
function WakeTwoPanel:UpdateHead(  )
    local key = self.wake_model:GetWakeKey()
	if not self.cur_head_item then
		self.cur_head_item = WakeHeadItem(self.cur_head)
		local arr = string.split(key,"@")
		local key = arr[1] .. "@" .. (tonumber(arr[2]) -1)
		self.cur_head_item:SetData(Config.db_wake[key])
	end
	if not self.next_head_item then
		self.next_head_item = WakeHeadItem(self.next_head)
		self.next_head_item:SetData(Config.db_wake[key])
	end
end

--刷新新增外形
function WakeTwoPanel:UpdateAvatar(  )
    local show = String2Table(self.wake_cfg.show)

    for k,v in pairs(show) do
		local item_id = v[1]
		local item =  WakeEquipItem(self.WakeEquipItem.gameObject, self.content_avatar)
        item:SetData(item_id)
        self.show_items[k] = item
    end
end

--刷新新功能开启
function WakeTwoPanel:UpdateFuns(  )
    self.txt_fun_opens.text = self.wake_cfg.desc
end

--刷新觉醒要求
function WakeTwoPanel:UpdateLimits()

    local level = RoleInfoModel:GetInstance():GetMainRoleLevel()

        --处理右下角显示
        if self.wake_model.grid_id == 27 then

            --第一阶段的格子激活完
            if self.cur_step == 1 then
                if level >= 520 then
                    --等级满足 显示下一阶段按钮
                    self:UpdateLimitsState(2)
                else
                    --等级不满足 显示要求文本
                    self:UpdateLimitsState(1)
                end
            else
                --已进入下一阶段 显示要求文本
                self:UpdateLimitsState(1)
            end

        elseif  self.wake_model.grid_id == 47 then
            
            --第二阶段的格子激活完
            if level >= self.wake_cfg.level then
                --等级满足 显示完成觉醒按钮
                self:UpdateLimitsState(3)
            else
                --等级不满足 显示要求文本
                self:UpdateLimitsState(1)
            end

        else
            --当前阶段的格子激活中 显示要求文本
            self:UpdateLimitsState(1)
        end

        
      

end

--刷新觉醒要求部分的状态 state:1-显示觉醒要求文本 隐藏两个按钮 2-显示下一阶段按钮 3-显示完成觉醒按钮
function WakeTwoPanel:UpdateLimitsState(state)
    if state == 1 then
        --显示觉醒要求文本 隐藏两个按钮
        SetVisible(self.btn_wake,false)
        SetVisible(self.btn_next_step,false)
        SetVisible(self.all_desc,true)

        local all_grids_count = 15
        local cur_avtive_grids_count = self.wake_model.grid_id - 12
        if self.cur_step == 2 then
            all_grids_count = 20
            cur_avtive_grids_count = self.wake_model.grid_id - 27
        end

        if cur_avtive_grids_count >= all_grids_count then
            self.txt_open_grids.text = string.format(ConfigLanguage.Wake.EnoughTwo,  cur_avtive_grids_count, all_grids_count)
        else
            self.txt_open_grids.text = string.format(ConfigLanguage.Wake.NotEnoughTwo,  cur_avtive_grids_count, all_grids_count)
        end

        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
        local need_level = 520
        if self.cur_step == 2 then
            need_level = self.wake_cfg.level
        end
        if level >= need_level then
            self.txt_open_level.text = string.format(ConfigLanguage.Wake.EnoughTwo, level,need_level)
        else
            self.txt_open_level.text = string.format(ConfigLanguage.Wake.NotEnoughTwo, level, need_level)
        end

    elseif state == 2 then
        --显示下一阶段按钮
        SetVisible(self.btn_wake,false)
        SetVisible(self.btn_next_step,true)
        SetVisible(self.all_desc,false)
        self.btn_next_step_reddot = self.btn_next_step_reddot or RedDot(self.btn_next_step)
        SetVisible(self.btn_next_step_reddot,true)
        SetLocalPosition(self.btn_next_step_reddot.transform,62,24)

    elseif state == 3 then
        --显示完成觉醒按钮
        SetVisible(self.btn_wake,true)
        SetVisible(self.btn_next_step,false)
        SetVisible(self.all_desc,false)

        self.btn_wake_reddot = self.btn_wake_reddot or RedDot(self.btn_wake)
        SetVisible(self.btn_wake_reddot,true)
        SetLocalPosition(self.btn_wake_reddot.transform,62,24)
    end
end
