--限时冲榜界面
TimeLimitedTreasureHuntPanel = TimeLimitedTreasureHuntPanel or class("TimeLimitedTreasureHuntPanel",BasePanel)

function TimeLimitedTreasureHuntPanel:ctor()
    self.abName = "timeLimitedTreasureHunt"
    self.assetName = "TimeLimitedTreasureHuntPanel"
    self.layer = "UI"

    self.use_background = true  
    self.is_click_bg_close = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.global_events = {}


    self.op_model = OperateModel:GetInstance()

    self.st_model = SearchTreasureModel.GetInstance()

    self.st_model_events = {}

    self.act_id = nil  --活动id
    self.score_box_act_id = nil  --积分奖励宝箱的活动id

    self.cfg = nil --限时寻宝配置

    self.cost_item_id = nil  --抽奖消耗的物品的id
    self.draw1_cost_count = 0  --抽一次消耗的物品数量
    self.draw10_cost_count = 0  --抽十次消耗的物品数量
    self.btn_draw1_reddot = nil --单抽按钮红点

    self.proba_id = nil--概率id
   
    self.model_item = nil -- 模型
    self.model_name = nil --模型名
    self.model_scale = nil --模型缩放倍数
    self.model_pos_x = nil  --模型x轴位置
    self.model_pos_y = nil --模型y轴位置

    self.count_down_text = nil  --倒计时

    self.reward_items = {}  --展示奖励物品列表
    self.pos_list = {} --奖励物品位置列表
    self.reward_anim_schedule_ids = {}  --奖励物品旋转动画定时器id

    self.score_data = {}
    self.progress_data = {}

    self.score_box_items = {}  --积分奖励宝箱列表

    self:InitData()
end

--初始化一些数据
function TimeLimitedTreasureHuntPanel:InitData(  )

    --从已开启的活动中找到当期限时寻宝活动的id
    local key  = "191@1"
    for k,v in pairs(self.op_model.act_list) do
        local cfg = Config.db_yunying[v.id]
        if cfg and cfg.panel == key then
            self.act_id = v.id
            break
        end
    end

    self.st_model.act_id = self.act_id
    self.score_box_act_id = self.act_id + 100

    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    
    for k,v in pairs(Config.db_artifact_treasure) do
        if v.id == self.act_id and lv >= v.min_level and lv <= v.max_level  then
            self.cfg = v
            break
        end
    end

    self.model_scale = self.cfg.ratio --模型缩放倍数
    self.model_pos_x = self.cfg.x_axis  --模型x轴位置
    self.model_pos_y = self.cfg.y_axis --模型y轴位置

    self.model_name = self.cfg.res
    self.proba_id = self.cfg.proba_tip_id

    for i=1,7 do
        local cfg = Config.db_yunying_reward[i.."@"..self.score_box_act_id]
        self.score_data[i] = tonumber(cfg.task)
    end


    local n = 1/6
   
    self.progress_data[0] =  {0,0}
    self.progress_data[1] =  {self.score_data[1],0}
    self.progress_data[2] =  {self.score_data[2],n * 1}
    self.progress_data[3] =  {self.score_data[3],n * 2}
    self.progress_data[4] =  {self.score_data[4],n * 3}
    self.progress_data[5] =  {self.score_data[5],n * 4}
    self.progress_data[6] =  {self.score_data[6],n * 5}
    self.progress_data[7] =  {self.score_data[7],1}

end

function TimeLimitedTreasureHuntPanel:dctor()
    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

    self.st_model:RemoveTabListener(self.st_model_events)
    self.st_model_events = nil

    --删除所有action
    for i=1,12 do
        local reward_parent = self["reward_parent_"..i]
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(reward_parent)
    end

    destroySingle(self.model_item)
    self.model_item = nil

    destroySingle(self.count_down_text)
    self.count_down_text = nil

    destroyTab(self.reward_items,true)
    destroyTab(self.score_box_items,true)

    for k,v in pairs(self.reward_anim_schedule_ids) do
        GlobalSchedule:Stop(v)
    end
    self.reward_anim_schedule_ids = nil

    destroySingle(self.btn_draw1_reddot)
    self.btn_draw1_reddot = nil
end



function TimeLimitedTreasureHuntPanel:LoadCallBack(  )
    self.nodes = {
        "btn_close","img_title",

        "left/model_parent","left/countdown_parent","left/txt_power",

        "right/right_up/img_desc",
        "right/right_up/btn_draw10/img_draw10_cost","right/right_up/btn_draw1/img_draw1_cost","right/right_up/btn_draw1","right/right_up/btn_draw10",
        "right/right_up/btn_draw1/txt_draw1_cost","right/right_up/btn_draw10/txt_draw10_cost",
        "right/right_up/btn_help","right/right_up/btn_proba",

        "right/right_up/reward_parents/reward_parent_4","right/right_up/reward_parents/reward_parent_3","right/right_up/reward_parents/reward_parent_5","right/right_up/reward_parents/reward_parent_2","right/right_up/reward_parents/reward_parent_9","right/right_up/reward_parents/reward_parent_1","right/right_up/reward_parents/reward_parent_8","right/right_up/reward_parents/reward_parent_11","right/right_up/reward_parents/reward_parent_7","right/right_up/reward_parents/reward_parent_12","right/right_up/reward_parents/reward_parent_10","right/right_up/reward_parents/reward_parent_6",
    
        "right/right_buttom/score_box_parent","right/right_buttom/txt_score","right/right_buttom/img_score_progress",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

   
end

function TimeLimitedTreasureHuntPanel:InitUI()

    self.img_title = GetImage(self.img_title)

    self.txt_countdowntext = GetText(self.countdowntext)
    self.txt_power = GetText(self.txt_power)

    self.img_desc = GetImage(self.img_desc)

    self.img_draw1_cost = GetImage(self.img_draw1_cost)
    self.img_draw10_cost = GetImage(self.img_draw10_cost)

    self.txt_draw1_cost = GetText(self.txt_draw1_cost)
    self.txt_draw10_cost = GetText(self.txt_draw10_cost)

    self.txt_score = GetText(self.txt_score)
    self.img_score_progress = GetImage(self.img_score_progress)

    for i=1,12 do
        local parent = self["reward_parent_"..i]
        self.pos_list[i] = parent.localPosition
    end
end

function TimeLimitedTreasureHuntPanel:AddEvent()

    --关闭界面按钮
    local function call_back(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,call_back)

    --概率详情按钮
    local function call_back(  )
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(self.proba_id)
    end
    AddClickEvent(self.btn_proba.gameObject,call_back)

    --规则说明
    local function call_back(  )
        ShowHelpTip("You will get 1 point for every time in the Hunt, and if your total points reach a certain amount you can get rewards")
    end
    AddClickEvent(self.btn_help.gameObject,call_back)

     --抽取一次
    local function call_back(  )
      self:TryRequestDraw(1)
    end
    AddClickEvent(self.btn_draw1.gameObject,call_back)

    --抽取十次
    local function call_back(  )
      self:TryRequestDraw(10)
    end
    AddClickEvent(self.btn_draw10.gameObject,call_back)

    --抽奖返回
    local function call_back(act_id)
        if act_id ~= self.act_id then
            return
        end
        --logError("抽奖返回")
        self:RequestGetnfo()
        --请求新的积分宝箱信息
        self:RequestScoreBoxInfo()
    end
    self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.SearchResult,call_back)

    --活动基本信息返回
    local function call_back(  )
        local info = self.st_model:GetInfo(self.act_id)
        local count = (info and info.bless_value or 0)
        --logError("祝福值："..count)
        self:UpdateScoreInfo(count)
        self:UpdateScoreProgress(count)
        self:UpdateDrawCostCount(count)
    end
    self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.UpdateInfo,call_back)

    --积分宝箱信息返回
    local function call_back(data)
     
        if data.id ~= self.score_box_act_id then
            return
        end
        --刷新积分宝箱
        --logError("积分宝箱信息返回,data-"..Table2String(data))
        self:UpdateScoreBox(data)
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO,call_back)

    --积分宝箱奖励领取返回
    local function call_back(data)
        if data.act_id ~= self.act_id+1 then
            return
        end

        --领取过积分宝箱后刷新下icon红点
        self:UpdateIconReddot()
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD,call_back)
end

--data
function TimeLimitedTreasureHuntPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedTreasureHuntPanel:UpdateView()
    self.need_update_view = false

    self:RequestGetnfo()
    self:RequestScoreBoxInfo()

    self:UpdateTitleAndDesc()
    self:UpdateModel()
    self:UpdatePower()
    self:UpdateTime()

    self:UpdateReward()
    self:UpdateDrawInfo()
end

--请求活动基本信息
function TimeLimitedTreasureHuntPanel:RequestGetnfo(  )
    SearchTreasureController.GetInstance():RequestGetInfo(self.act_id)
end

--请求积分宝箱信息
function TimeLimitedTreasureHuntPanel:RequestScoreBoxInfo(  )
    --logError("请求积分宝箱信息")
    GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO,self.score_box_act_id)
end

--尝试请求抽取
function TimeLimitedTreasureHuntPanel:TryRequestDraw(draw_num)

    local key_id = self.cost_item_id
    local key_name = Config.db_item[key_id].name

    --获取已有抽奖消耗道具数量
    local had_num = BagController:GetInstance():GetItemListNum(key_id)

    local need_num = self.draw1_cost_count
    if draw_num == 10 then
       need_num = self.draw10_cost_count
    end

    --首次单抽免费
    if need_num == self.draw1_cost_count then
        local info = self.st_model:GetInfo(self.act_id)
        local count = (info and info.bless_value or 0)
        if count == 0 then
            need_num = 0
        end
    end
   
   

    if had_num >= need_num then
        self:RequestDraw(draw_num, 0)
    else
        --道具数量不足 提示用钻石抵扣
        local gold_num = need_num - had_num
        local gold = Config.db_voucher[key_id].price * gold_num

        local message = ""
        if had_num > 0 then
            message = string.format(ConfigLanguage.SearchT.AlertMsg5, key_name, gold, key_name, gold_num)
        else
            message = string.format(ConfigLanguage.SearchT.AlertMsg4, key_name, gold, key_name, gold_num)
        end

        local function ok_fun(is_check)
            self:RequestDraw(draw_num, gold)
        end
        Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false,nil,TimeLimitedTreasureHuntResultPanel.__cname)
    end
end

--请求抽取
function TimeLimitedTreasureHuntPanel:RequestDraw(draw_num, need_gold)
    local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
    if not bo then
        return
    end
    SearchTreasureController:GetInstance():RequestSearch(self.act_id, draw_num)
end

--刷新标题与描述图片
function TimeLimitedTreasureHuntPanel:UpdateTitleAndDesc( )

    lua_resMgr:SetImageTexture(self,self.img_title,"timeLimitedTreasureHunt_image",self.cfg.title)
    lua_resMgr:SetImageTexture(self,self.img_desc,"timeLimitedTreasureHunt_image",self.cfg.slogan)
end

--刷新模型
function TimeLimitedTreasureHuntPanel:UpdateModel(  )
    self.model_item = UIModelCommonCamera(self.model_parent, nil, self.model_name,nil,true)
    local cfg = {}
    cfg.pos = {x = self.model_pos_x, y = self.model_pos_y, z = 193}
    cfg.scale = {x=self.model_scale, y=self.model_scale, z=self.model_scale}

    self.model_item:SetConfig(cfg)
end

--刷新战力
function TimeLimitedTreasureHuntPanel:UpdatePower(  )
    self.txt_power.text = self.cfg.war
end

--刷新剩余时间
function TimeLimitedTreasureHuntPanel:UpdateTime(  )
    local end_time = self.op_model:GetActEndTimeByActId(self.act_id)
    if end_time then
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.isShowDay = true
        param.isShowSec = true
        param.isChineseType = true
        param.formatText = "Time remaining: %s"
        self.count_down_text = CountDownText(self.countdown_parent, param)
        local function call_back()
            self.txt_countdowntext.text = ConfigLanguage.Nation.ActivityIsOver
        end
        self.count_down_text:StartSechudle(end_time, call_back)
    end
end

--刷新展示奖励
function TimeLimitedTreasureHuntPanel:UpdateReward(  )
    local reward = String2Table(self.cfg.reward)
    for k,v in pairs(reward) do
        local index = v[1]
        local item_id = v[2]

        local goods_icon = GoodsIconSettorTwo(self["reward_parent_"..index])

        local param = {}
        param.item_id = item_id
        --param.num = reward[2]
        --param.bind = reward[3]
        param.can_click = true
        param.size = {x = 75,y = 75}
        
        goods_icon:SetIcon(param)

        self.reward_items[index] = goods_icon
    end

    --播放旋转动画
    for i=1,#self.reward_items do
        self:PlayRewardAnim(i,i + 1)
    end
end

--播放奖励物品旋转动画
function TimeLimitedTreasureHuntPanel:PlayRewardAnim( index ,target_index)

    if target_index ~= 12 then
        target_index = target_index % 12
    end

    local reward_parent = self["reward_parent_"..index]
    local target = self.pos_list[target_index]
    local move_action = cc.MoveTo(1.5,target.x,target.y)
    local callfunc_action = cc.CallFunc(function(  )
        self:PlayRewardAnim(index,target_index + 1)
    end)
    local seq_action = cc.Sequence(move_action,callfunc_action)
    cc.ActionManager:GetInstance():addAction(seq_action,reward_parent)
end



--播放奖励物品旋转动画
-- function TimeLimitedTreasureHuntPanel:PlayRewardAnim(index)

--     local angle = 0 + Mathf.PI * 2 / 12 * (index - 1)
--     local w = 300
--     local h = 100
--     local parent = self["reward_parent_"..index]
--     local function callback(  )
--         angle = angle - Time.deltaTime / 100
--         local x = w * Mathf.Cos(angle * Mathf.Rad2Deg) 
--         local y = h * Mathf.Sin(angle * Mathf.Rad2Deg)
--         SetLocalPositionXY(parent,x,y)
--     end

--     local id = GlobalSchedule:Start(callback)
--     table.insert(self.reward_anim_schedule_ids,id)
-- end

--刷新抽奖信息
function TimeLimitedTreasureHuntPanel:UpdateDrawInfo()
    local yy_cfg = Config.db_yunying[self.act_id]
    local reqs = String2Table(yy_cfg.reqs)
    for k,v in pairs(reqs) do
        if v[1] == "cost" then
            self.cost_item_id = v[2][1][2]
            GoodIconUtil.GetInstance():CreateIcon(self,self.img_draw1_cost,  self.cost_item_id, true)
            GoodIconUtil.GetInstance():CreateIcon(self,self.img_draw10_cost,  self.cost_item_id, true)

            self.draw1_cost_count = v[2][1][3]
            self.draw10_cost_count = v[2][2][3]

            break
        end
    end
    
    local timelimited_treasure_hunt_reddot = self.st_model:CheckTimelimitedTreasureHuntReddot()
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "timeLimitedTreasureHunt", timelimited_treasure_hunt_reddot)
end

--刷新抽奖消耗物品数量
function TimeLimitedTreasureHuntPanel:UpdateDrawCostCount(count)
    if count == 0 then
        --首次单抽免费
        self.txt_draw1_cost.text = ConfigLanguage.Nation.Free
        if not self.btn_draw1_reddot then
            self.btn_draw1_reddot = RedDot(self.btn_draw1)
            SetVisible(self.btn_draw1_reddot.transform,true)
            SetLocalPosition(self.btn_draw1_reddot.transform,79,23.5,0)
        end
    else
        self.txt_draw1_cost.text = "X"..self.draw1_cost_count
        if self.btn_draw1_reddot then
            destroySingle(self.btn_draw1_reddot)
            self.btn_draw1_reddot = nil
        end
    end
    self.txt_draw10_cost.text = "X"..self.draw10_cost_count
end


--刷新积分信息
function TimeLimitedTreasureHuntPanel:UpdateScoreInfo(score)
    self.txt_score.text = score
end

--刷新积分进度
function TimeLimitedTreasureHuntPanel:UpdateScoreProgress(score)
    
    --小于最低档次和大于最高档次的，直接处理
    if score < self.score_data[1] then
        self.img_score_progress.fillAmount = 0
        return
    end
    if score >= self.score_data[#self.score_data] then
        self.img_score_progress.fillAmount = 1
        return
    end

    --否则插值计算进度条位置
    local progress = 0
    for i=1,6 do
        local data = self.progress_data[i]
        local target_score = data[1]
        local target_progress = data[2]

        local next_data = self.progress_data[i + 1]
        local next_target_score = next_data[1]
        local next_target_progress = next_data[2]

        if score == target_score then
            --相等时直接获取进度条位置
            progress = target_progress
            break
        elseif score == next_target_score then
             --相等时直接获取进度条位置
            progress = next_target_progress
            break
        elseif score > target_score and score < next_target_score then
            --插值计算进度条位置
            local n1 = score - target_score
            local n2 = next_target_score - target_score
            local n3 = n1 / n2
            progress = Mathf.Lerp(target_progress,next_target_progress,n3)
            break
        end
    end
    
    
    self.img_score_progress.fillAmount = progress
end

--刷新积分宝箱
function TimeLimitedTreasureHuntPanel:UpdateScoreBox(info)
  
    for k,v in pairs(info.tasks) do
        self.score_box_items[v.id] = self.score_box_items[v.id] or TimeLimitedTreasureHuntScoreBoxItem(self.score_box_parent)
        local data = {}
        data.id = v.id
        data.level = v.level
        data.score = self.score_data[v.level]
        data.cfg = Config.db_yunying_reward[v.id .. "@" .. self.score_box_act_id]
        data.state = v.state
        data.act_id = self.score_box_act_id
        self.score_box_items[v.id]:SetData(data)
    end
    self:UpdateIconReddot()

end

--刷新右上角icon红点
function TimeLimitedTreasureHuntPanel:UpdateIconReddot(  )
    local flag = false
    for k,v in pairs(self.score_box_items) do
        if v.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            flag = true
            break
        end
    end

    self.op_model:UpdateIconReddot(self.act_id,flag)
end