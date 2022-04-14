--六次觉醒界面
--后续类似的七觉 八觉... 可以直接继承这个然后重写部分参数和方法就完事了
WakeThreePanel = WakeThreePanel or class("WakeThreePanel",WakeTwoPanel)
WakeThreePanel.Tip1 = "Insufficient items"
function WakeThreePanel:ctor()
    self.abName = "wake"
    self.assetName = "WakeThreePanel"
    self.layer = "UI"

    --每个阶段 可进入到下一阶段的等级限制
    self.step_lv_limit = {610,620,self.wake_cfg.level}

    --3个阶段的格子起始id
    self.grid_start_id = {48,73,103}

    --3个阶段的格子结束id
    self.grid_end_id = {72,102,137}

    self.wake_count = 6  --觉醒次数

    --3个阶段tip用到的参数
    self.tip_param_1 = {600,610,620}  --等级
    self.tip_param_2 = {12012,12013,12014}  --物品id

    self.balls_steps = {}  --各阶段的线与点
    
    self.cur_step = self.wake_model:GetWakeStep2(self.wake_count)  --当前觉醒阶段

    self.next_step_flag = false --防止弱网下连续点击下一阶段
end

function WakeThreePanel:dctor()
  
end

function WakeThreePanel:LoadCallBack(  )
    self.nodes = {
        "img_bg","title",
        "btn_close","txt_wake_tip","money_con",
        "right/heads/improve/cur_head","right/heads/improve/next_head",

        "right/avatars/scrollview_avatar/viewport_avatar/content_avatar","right/avatars/scrollview_avatar/viewport_avatar/content_avatar/WakeEquipItem",
    
        "right/funs/txt_fun_opens",

        "right/limits/all_desc",
        "right/limits/all_desc/txt_open_grids","right/limits/all_desc/txt_open_level",

        "right/limits/btn_wake","right/limits/btn_next_step",

        "balls_step_1/line_49","balls_step_1/ball_61","balls_step_1/ball_62","balls_step_1/line_59","balls_step_1/line_60","balls_step_1/line_71","balls_step_1/line_72","balls_step_1/ball_69","balls_step_1/ball_55","balls_step_1/ball_56","balls_step_1/ball_57","balls_step_1/ball_70","balls_step_1/ball_71","balls_step_1/line_68","balls_step_1/line_69","balls_step_1/line_70","balls_step_1/line_53","balls_step_1/line_54","balls_step_1/line_55","balls_step_1/line_56","balls_step_1/ball_58","balls_step_1/ball_59","balls_step_1/ball_60","balls_step_1/line_51","balls_step_1/line_52","balls_step_1","balls_step_1/ball_50","balls_step_1/ball_51","balls_step_1/line_57","balls_step_1/line_58","balls_step_1/ball_48","balls_step_1/ball_63","balls_step_1/ball_64","balls_step_1/ball_49","balls_step_1/ball_52","balls_step_1/ball_53","balls_step_1/ball_65","balls_step_1/ball_66","balls_step_1/line_63","balls_step_1/line_64","balls_step_1/line_65","balls_step_1/line_66","balls_step_1/line_67","balls_step_1/line_61","balls_step_1/line_62","balls_step_1/ball_54","balls_step_1/ball_72","balls_step_1/line_50","balls_step_1/ball_67","balls_step_1/ball_68",
        "balls_step_2/line_96","balls_step_2/line_97","balls_step_2/line_98","balls_step_2/line_99","balls_step_2/ball_74","balls_step_2/ball_75","balls_step_2/line_92","balls_step_2/line_93","balls_step_2/line_94","balls_step_2/line_95","balls_step_2/ball_81","balls_step_2/ball_82","balls_step_2/ball_83","balls_step_2/ball_93","balls_step_2/ball_94","balls_step_2/ball_95","balls_step_2/ball_96","balls_step_2/ball_78","balls_step_2/ball_79","balls_step_2/ball_80","balls_step_2/ball_91","balls_step_2/ball_92","balls_step_2/line_87","balls_step_2/line_88","balls_step_2/line_89","balls_step_2/line_90","balls_step_2/line_91","balls_step_2/ball_100","balls_step_2/ball_101","balls_step_2/ball_102","balls_step_2/ball_84","balls_step_2/ball_85","balls_step_2/ball_86","balls_step_2/ball_97","balls_step_2/ball_98","balls_step_2/ball_99","balls_step_2/ball_87","balls_step_2/ball_88","balls_step_2/ball_89","balls_step_2/ball_90","balls_step_2/line_100","balls_step_2/line_101","balls_step_2/line_102","balls_step_2/line_79","balls_step_2/line_80","balls_step_2/line_81","balls_step_2/line_82","balls_step_2/line_75","balls_step_2/line_76","balls_step_2/line_77","balls_step_2/line_78","balls_step_2/ball_76","balls_step_2/ball_77","balls_step_2/line_83","balls_step_2/line_84","balls_step_2/line_85","balls_step_2/line_86","balls_step_2/line_74","balls_step_2","balls_step_2/ball_73",
        "balls_step_3/ball_132","balls_step_3/ball_133","balls_step_3/ball_134","balls_step_3/ball_116","balls_step_3/ball_117","balls_step_3/line_108","balls_step_3/line_109","balls_step_3/line_104","balls_step_3/ball_103","balls_step_3","balls_step_3/ball_130","balls_step_3/ball_131","balls_step_3/ball_122","balls_step_3/ball_123","balls_step_3/ball_124","balls_step_3/ball_120","balls_step_3/ball_121","balls_step_3/ball_112","balls_step_3/ball_113","balls_step_3/ball_105","balls_step_3/ball_106","balls_step_3/ball_107","balls_step_3/ball_108","balls_step_3/line_120","balls_step_3/line_121","balls_step_3/line_122","balls_step_3/line_117","balls_step_3/line_118","balls_step_3/line_119","balls_step_3/ball_135","balls_step_3/ball_136","balls_step_3/ball_118","balls_step_3/ball_119","balls_step_3/line_114","balls_step_3/line_115","balls_step_3/line_116","balls_step_3/line_123","balls_step_3/line_124","balls_step_3/line_125","balls_step_3/ball_104","balls_step_3/ball_137","balls_step_3/line_105","balls_step_3/line_106","balls_step_3/line_107","balls_step_3/line_110","balls_step_3/line_111","balls_step_3/line_112","balls_step_3/line_113","balls_step_3/ball_125","balls_step_3/ball_126","balls_step_3/ball_127","balls_step_3/line_133","balls_step_3/line_134","balls_step_3/line_135","balls_step_3/line_136","balls_step_3/line_137","balls_step_3/ball_109","balls_step_3/ball_110","balls_step_3/ball_111","balls_step_3/ball_128","balls_step_3/ball_129","balls_step_3/line_130","balls_step_3/line_131","balls_step_3/line_132","balls_step_3/line_126","balls_step_3/line_127","balls_step_3/line_128","balls_step_3/line_129","balls_step_3/ball_114","balls_step_3/ball_115",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function WakeThreePanel:InitUI(  )

    SetVisible(self.WakeEquipItem,false)

    --收集一下线和格子
    for i=self.grid_start_id[1],self.grid_end_id[3] do
        self.grids[i] = self["ball_" .. i]

        --    if i~= self.grid_start_id[1] and i~= self.grid_start_id[2] and i~= self.grid_start_id[3] then
        --        self.lines[i] = self["line_"..i]
        --    end
        self.lines[i] = self["line_"..i]
    end

    for i=1,#self.grid_start_id do
        self.balls_steps[i] = self["balls_step_"..i]
    end

    self.img_bg = GetImage(self.img_bg)
    self.txt_wake_tip = GetText(self.txt_wake_tip)
    self.txt_fun_opens = GetText(self.txt_fun_opens)
    self.txt_open_grids = GetText(self.txt_open_grids)
    self.txt_open_level = GetText(self.txt_open_level)
    
    SetAlignType(self.title.transform, bit.bor(AlignType.Left, AlignType.Top))
    SetAlignType(self.btn_close.transform, bit.bor(AlignType.Right, AlignType.Top))
    
    SetVisible(self.btn_wake,false)
    SetVisible(self.btn_next_step,false)
end

function WakeThreePanel:AddEvent(  )

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
            local jump1 = nil
            local jump2 = nil
            if self.cur_step == 3 then
                jump1 = 1
                jump2 = 1
            end
		    panel:SetData(grid_cfg,jump1,jump2)
		    panel:Open(target)
        end
        AddClickEvent(v.gameObject,call_back)
    end

    --下一阶段
    local function call_back(  )
        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
        local need_lv = self.step_lv_limit[self.cur_step]
        if level < need_lv then
            Notify.ShowText("Awaken requirement not reached")
            return
        end

        if self.next_step_flag == true then
            return
        end

        self.next_step_flag = true

        WakeController.GetInstance():RequestGoNextStep()
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

    --下一阶段返回
    local function call_back(  )

        self.cur_step = self.cur_step + 1
        self.wake_model:SetWakeStep2(self.wake_count,self.cur_step)
        self:HandleGridsData()

        self.next_step_flag = false
    end
    self.wake_model_events[#self.wake_model_events + 1] = self.wake_model:AddListener(WakeEvent.HandleGoNextStep,call_back)
end

--处理返回的格子数据
function WakeThreePanel:HandleGridsData(  )

    local grid_id = self.wake_model.grid_id

    if grid_id >= self.grid_start_id[1] - 1 and grid_id <= self.grid_end_id[#self.grid_end_id] then

        --尝试进行阶段修正 防止因为玩家换了设备导致从本地读取的阶段数据对不上
        if self.cur_step == 1 then
            --从最后一个阶段倒着检查到第2个阶段
            for i=#self.grid_start_id,2,-1 do
                if grid_id >= self.grid_start_id[i] then
                    --修正为第i阶段
                    self.cur_step = i;
                    self.wake_model:SetWakeStep2(self.wake_count,i)
                    break;
                end
            end
        end

        --根据阶段进行刷新
        self:UpdateWakeStep()

    else
            --logError("grid_id无效，值为"..grid_id)
    end

end

--刷新线
function WakeThreePanel:UpdateLines(  )
     --处理线的显示
     local start_index = self.grid_start_id[self.cur_step] + 1
     local end_index = self.grid_end_id[self.cur_step]

     for i=start_index,end_index do
         if self.wake_model.grid_id + 1  >= i then
             SetVisible(self.lines[i],true)
         else
             SetVisible(self.lines[i],false)
         end
     end
end

--刷新格子
function WakeThreePanel:UpdateGrids(  )

    for i=1,#self.balls_steps do
        SetVisible(self.balls_steps[i],self.cur_step == i)
    end

    local start_index = self.grid_start_id[self.cur_step]
    local end_index = self.grid_end_id[self.cur_step]

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
function WakeThreePanel:UpdateGridselectItem(  )
    --显示当前待激活的格子的特效
    if self.ball_select_item then
		self.ball_select_item:destroy()
	end
	if self.wake_model.grid_id + 1 <= self.grid_end_id[#self.grid_end_id] then
		self.ball_select_item = WakeBallSelectItem(self.grids[self.wake_model.grid_id+1])
	end
end


--刷新tips
function WakeThreePanel:UpdateTips(  )

    local str = "Defeat Lv.%s or above monsters and have a chance to get %s"

    local lv = self.tip_param_1[self.cur_step]
    local name = Config.db_item[self.tip_param_2[self.cur_step]].name

    local tip = string.format(str,lv,name)
    self.txt_wake_tip.text = tip
end


--刷新觉醒要求
function WakeThreePanel:UpdateLimits()

    local level = RoleInfoModel:GetInstance():GetMainRoleLevel()

    local grid_id = self.wake_model.grid_id

    --先检查是否是当前阶段激活完但没进入下一阶段的情况
    for i=1,#self.grid_end_id do
        if grid_id == self.grid_end_id[i] and self.cur_step == i then

            --第 i 阶段格子激活完 但还没进入下一阶段或完成觉醒

            if level >= self.step_lv_limit[i] then
                --等级满足

                if i < #self.grid_end_id then
                    --不是最后一个阶段 显示下一阶段按钮
                    self:UpdateLimitsState(2)
                    return
                else
                    --最后一个阶段 显示完成觉醒按钮
                    self:UpdateLimitsState(3)
                    return
                end

            else

                --等级不满足 显示要求文本
                self:UpdateLimitsState(1)
                return
            end
        end
    end


    --当前阶段还没激活完 显示要求文本
    self:UpdateLimitsState(1)


        
      

end

--刷新觉醒要求部分的状态 state:1-显示觉醒要求文本 隐藏两个按钮 2-显示下一阶段按钮 3-显示完成觉醒按钮
function WakeThreePanel:UpdateLimitsState(state)
    if state == 1 then
        --显示觉醒要求文本 隐藏两个按钮
        SetVisible(self.btn_wake,false)
        SetVisible(self.btn_next_step,false)
        SetVisible(self.all_desc,true)

        --当前阶段总格子数量
        local all_grids_count = (self.grid_end_id[self.cur_step] + 1) - self.grid_start_id[self.cur_step]
       
        --当前阶段已激活格子数量
        local cur_avtive_grids_count = self.wake_model.grid_id - (self.grid_start_id[self.cur_step] - 1)


        if cur_avtive_grids_count >= all_grids_count then
            self.txt_open_grids.text = string.format(ConfigLanguage.Wake.EnoughTwo,  cur_avtive_grids_count, all_grids_count)
        else
            self.txt_open_grids.text = string.format(ConfigLanguage.Wake.NotEnoughTwo,  cur_avtive_grids_count, all_grids_count)
        end

        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()

        --到下一阶段的需求等级
        local need_level = self.step_lv_limit[self.cur_step]

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
