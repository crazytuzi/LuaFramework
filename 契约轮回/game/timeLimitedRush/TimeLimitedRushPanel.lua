--限时冲榜界面
TimeLimitedRushPanel = TimeLimitedRushPanel or class("TimeLimitedRushPanel",BasePanel)

function TimeLimitedRushPanel:ctor()
    self.abName = "timeLimitedRush"
    self.assetName = "TimeLimitedRushPanel"
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
    self.model_name = nil  --模型名
    self.btn_name = nil  --按钮名
    self.jump = nil --按钮跳转
    self.draw_tip = nil --抽奖提示
    self.proba_id = nil --概率id

    self.model_scale = nil --模型缩放倍数
    self.model_pos_x = nil  --模型x轴位置
    self.model_pos_y = nil --模型y轴位置

    --从已开启的活动中找到当期限时冲榜活动的id
    for k,v in pairs(self.op_model.act_list) do
        local cfg = Config.db_yunying[v.id]
        if cfg and cfg.panel == "5@11" then
            self.act_id = v.id
            
            local act_cfg = String2Table(cfg.model)
            self.model_name = act_cfg[1]
            self.btn_name = act_cfg[2]
            self.jump = act_cfg[3]
            self.draw_tip = act_cfg[4]
            self.proba_id = act_cfg[5]
            self.model_scale = act_cfg[6]
            self.model_pos_x = act_cfg[7]
            self.model_pos_y = act_cfg[8]
            break
        end
    end

    self.st_model.act_id = self.act_id

    self.score_box_act_id = self.act_id + 1  --积分奖励宝箱的活动id

    self.count_down_text = nil  --倒计时
  
    self.rewards_items = {}  --奖励预览item列表
    self.rank_items = {}  --奖励排行item列表
    self.score_box_items = {}  --积分积分宝箱item列表

    self.draw_cost_item_id = nil--抽奖消耗物品的id
    self.draw1_price = nil--单抽价格
    self.draw10_price = nil--十连抽价格

    self.score_data = {}  --积分数据 档次-积分

    self.progress_data = {}  --进度条数据 [索引] =  {积分,进度条位置}

    self.rewards_data = {}  --奖励预览数据

    self.default_rank_data = {} --默认排名数据

    self.preview_rewards_data = {}  --奖池预览数据 [item_id] = {item}

    self.update_rewards_schedule_id = nil  --分帧实例化奖励预览的定时器id 

    self.update_first_rank_schedule_id = nil --分帧实例化首次排名的定时器id

    self.update_score_box_schedule_id = nil  --分帧实例化积分宝箱的定时器id

    self.effect = nil  --特效
    self.model_item = nil -- 模型

    self.btn_draw1_reddot = nil --单抽按钮红点

    self.count = 0 --抽取次数

    self:InitData()
end

function TimeLimitedRushPanel:dctor()
    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

    self.st_model:RemoveTabListener(self.st_model_events)
    self.st_model_events = nil

    destroyTab(self.rewards_items,true)
    destroyTab(self.rank_items,true)
    destroyTab(self.score_box_items,true)

    destroySingle(self.count_down_text)
    self.count_down_text = nil

    destroySingle(self.effect)
    self.effect = nil

    destroySingle(self.model_item)
    self.model_item = nil

    destroySingle(self.btn_draw1_reddot)
    self.btn_draw1_reddot = nil

    if self.update_rewards_schedule_id then
		GlobalSchedule:Stop(self.update_rewards_schedule_id)
		self.update_rewards_schedule_id = nil
    end

    if self.update_first_rank_schedule_id then
		GlobalSchedule:Stop(self.update_first_rank_schedule_id)
		self.update_first_rank_schedule_id = nil
    end

    if self.update_score_box_schedule_id then
		GlobalSchedule:Stop(self.update_score_box_schedule_id)
		self.update_score_box_schedule_id = nil
    end
end

--初始化一些数据
function TimeLimitedRushPanel:InitData(  )

    local yy_cfg = Config.db_yunying[self.act_id]
    local reqs = String2Table(yy_cfg.reqs)
    local cost = nil
    for k,v in pairs(reqs) do
        if v[1] == "cost" then
            cost = v[2]
            break
        end
    end
    self.draw_cost_item_id = cost[1][2]
    self.draw1_price = cost[1][3]
    self.draw10_price = cost[2][3]

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

    self.preview_rewards_data = String2Table(yy_cfg.sundries)
    self.rewards_data  = String2Table(yy_cfg.reward)

    local rank_limen = {}
    for k,v in pairs(Config.db_rank) do
        if v.id == self.act_id then
            rank_limen = String2Table(v.rank_limen)
            break
        end
    end

    for k,v in pairs(rank_limen) do
        for i=v[1],v[2] do
            local tbl = {}
            tbl.rank = i
            tbl.score = string.format( "Needs %s pts",v[3])
            tbl.name = "Nobady on list"
            table.insert(self.default_rank_data, tbl)
        end
    end
end

function TimeLimitedRushPanel:LoadCallBack(  )
    self.nodes = {
        "countdown_parent","btn_close","countdown_parent/countdowntext",
        
        "left/left_up/toggle_group_parent",
        "left/left_up/toggle_group_parent/toggle_rank","left/left_up/toggle_group_parent/toggle_rewards",
        "left/left_up/toggle_group_parent/toggle_rewards/txt_toggle_rewards","left/left_up/toggle_group_parent/toggle_rank/txt_toggle_rank",

        "left/left_middle/rank_parent","left/left_middle/rewards_parent",
        "left/left_middle/rewards_parent/scroll_view_rewards/viewport_rewards/content_rewards","left/left_middle/rank_parent/scroll_view_rank/viewport_rank/content_rank",
        
        "left/left_buttom/txt_my_rank",
        "left/left_buttom/txt_my_score",

        "right/right_up/draw_info_parent",

        "right/right_up/draw_info_parent/btn_weapon","right/right_up/draw_info_parent/btn_rewards",

        "right/right_up/draw_info_parent/draw10_parent/img_draw10_cost","right/right_up/draw_info_parent/draw1_parent/btn_draw1","right/right_up/draw_info_parent/draw1_parent/txt_draw1_price","right/right_up/draw_info_parent/draw10_parent/txt_draw10_price","right/right_up/draw_info_parent/draw10_parent/btn_draw10","right/right_up/draw_info_parent/draw1_parent/img_draw1_cost",
    
        "right/right_up/effect_parent","right/right_up/model_parent",

        "right/right_buttom/txt_my_score2",
        "right/right_buttom/score_box_parent","right/right_buttom/img_score_progress",
    
        "right/right_up/draw_info_parent/txt_draw_tip","right/right_up/img_act_bg2","right/right_up/img_act_bg1",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    SearchTreasureController.GetInstance():RequestGetInfo(self.act_id)

end

function TimeLimitedRushPanel:InitUI()

    self.txt_countdowntext = GetText(self.countdowntext)

    self.txt_my_rank = GetText(self.txt_my_rank)
    self.txt_my_score = GetText(self.txt_my_score)

    self.toggle_rewards = GetToggle(self.toggle_rewards)
    self.toggle_rank = GetToggle(self.toggle_rank)
    self.txt_toggle_rewards = GetText(self.txt_toggle_rewards)
    self.txt_toggle_rank = GetText(self.txt_toggle_rank)

    self.img_draw1_cost = GetImage(self.img_draw1_cost)
    self.img_draw10_cost = GetImage(self.img_draw10_cost)
    GoodIconUtil:CreateIcon(self,self.img_draw1_cost,self.draw_cost_item_id,true)
    GoodIconUtil:CreateIcon(self,self.img_draw10_cost,self.draw_cost_item_id,true)


    self.txt_draw1_price = GetText(self.txt_draw1_price)
    self.txt_draw10_price = GetText(self.txt_draw10_price)
    self.txt_my_score2 = GetText(self.txt_my_score2)
    self.img_score_progress = GetImage(self.img_score_progress)

    self.img_act_bg1 = GetImage(self.img_act_bg1)
    self.img_act_bg2 = GetImage(self.img_act_bg2)
    self.txt_draw_tip = GetText(self.txt_draw_tip)
    self.img_weapon = GetImage(self.btn_weapon)

    LayerManager.GetInstance():AddOrderIndexByCls(self, self.effect_parent, nil, true, nil, false, 1)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_parent, nil, true, nil, false, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.draw_info_parent, nil, true, nil, false,5)

    local height = 59.15 * 3 + 40.65 * 47
    SetSizeDelta(self.content_rank.transform,368,height)

end

function TimeLimitedRushPanel:AddEvent()

    --关闭界面按钮
    local function call_back(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,call_back)

    --奖励预览按钮
    local function call_back(target, value)
        SetVisible(self.rewards_parent,value)
        --logError("奖励预览-"..tostring(value))
        if value then
            self.txt_toggle_rewards.text = "<color=#8584B0>Rewards Preview</color>"
        else
            self.txt_toggle_rewards.text = "<color=#ffffff>Rewards Preview</color>"
        end
    end
    AddValueChange(self.toggle_rewards.gameObject,call_back)

    --奖励排行按钮
    local function call_back(target, value)
        SetVisible(self.rank_parent,value)
        --logError("奖励排行-"..tostring(value))
        if value then
            self.txt_toggle_rank.text = "<color=#8584B0>Rewards Rank</color>"
        else
            self.txt_toggle_rank.text = "<color=#ffffff>Rewards Rank</color>"
        end
    end
    AddValueChange(self.toggle_rank.gameObject,call_back)

    --神兵按钮
    local function call_back(  )
        -- local jump = "{100,7,3,40001,7,true}"
        -- UnpackLinkConfig(jump)
        OpenLink(unpack(self.jump))
    end
    AddClickEvent(self.btn_weapon.gameObject,call_back)

    --奖池按钮
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(TimeLimitedRushPreviewRewardsPanel)
        panel:Open()

        local data = {}
        data.rewards = self.preview_rewards_data
        data.proba_id = self.proba_id
        panel:SetData(data)
    end
    AddClickEvent(self.btn_rewards.gameObject,call_back)

    --抽取一次
    local function call_back(  )

        if self.count == 0 then
            --首次单抽免费
            self:RequestDraw(1,0)
        else
            self:RequestDraw(1,self.draw1_price)
        end

        
    end
    AddClickEvent(self.btn_draw1.gameObject,call_back)

    --抽取十次
    local function call_back(  )
        self:RequestDraw(10,self.draw10_price)
    end
    AddClickEvent(self.btn_draw10.gameObject,call_back)


    --基本信息
    local function call_back()
        self:UpdateDrawInfo()
    end
    self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.UpdateInfo,call_back)

    --抽奖返回
    local function call_back(act_id)
        if act_id ~= self.act_id then
            return
        end

        --刷新下积分排行和积分宝箱
        self:RequestRankListInfo()
        self:RequestScoreBox()
        SearchTreasureController.GetInstance():RequestGetInfo(self.act_id)

    end
    self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.SearchResult,call_back)

    --积分排行数据返回
    local function call_back(data)

        if data.id ~= self.act_id then
            return
        end

        --logError("排行数据返回-"..Table2String(data))
    
        self:UpdateRankInfo(data.list)
        self:UpdateMyRankInfo(data.mine)

    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(RankEvent.RankReturnList,call_back)

    --积分宝箱信息返回
    local function call_back(data)
     
        if data.id ~= self.score_box_act_id then
            return
        end
        --logError("档次奖励返回，data"..Table2String(data))
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
function TimeLimitedRushPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedRushPanel:UpdateView()
    self.need_update_view = false

    self:UpdateTime()
    self:UpdateRewards()
    self:UpdateDefaultRankInfo()
    

    self:UpdateModel()
    --self:UpdateDrawInfo()

    self:RequestScoreBox()
end

--刷新剩余时间
function TimeLimitedRushPanel:UpdateTime(  )
    local end_time = self.op_model:GetActEndTimeByActId(self.act_id)
    if end_time then
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.isShowDay = true
        param.isShowSec = true
        param.isChineseType = true
        param.formatText = "Remaining Time:%s"
        self.count_down_text = CountDownText(self.countdown_parent, param)
        local function call_back()
            self.txt_countdowntext.text = ConfigLanguage.Nation.ActivityIsOver
        end
        self.count_down_text:StartSechudle(end_time, call_back)
    end
end

--刷新奖励预览列表
function TimeLimitedRushPanel:UpdateRewards(  )
    --分帧实例化预览奖励Item
    local num = #self.rewards_data
    if num <= 0 then
		return
    end
    
    local function op_call_back(cur_frame_count,cur_all_count)
        local rewards = self.rewards_data[cur_all_count]

        self.rewards_items[cur_all_count] = TimeLimitedRushRewardItem(self.content_rewards)

        local data = {}
        if rewards[1] == rewards[2] then
            data.rank = rewards[1]
        else
            data.rank = rewards[1].."-"..rewards[2]
        end
        data.index = cur_all_count
        
        data.rewards = rewards[3]
        self.rewards_items[cur_all_count]:SetData(data)
    end

    local function all_frame_op_complete()
      
    end
    
    self.update_rewards_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,0.1,1,num,nil,all_frame_op_complete)
end

--请求排行数据
function TimeLimitedRushPanel:RequestRankListInfo()
    --logError("请求限时抢购排行数据,act_id-"..self.act_id)
    RankController.GetInstance():RequestRankListInfo(self.act_id,1)
    --RankController.GetInstance():RequestRankListInfo(self.act_id,2)
end

--刷新默认奖励排行列表
function TimeLimitedRushPanel:UpdateDefaultRankInfo(  )
     --分帧实例化排名Item
     local num = #self.default_rank_data
     if num <= 0 then
         return
     end
     
     local function op_call_back(cur_frame_count,cur_all_count)

        local v = self.default_rank_data[cur_all_count]

        if v.rank <= 3 then
            self.rank_items[v.rank] = self.rank_items[v.rank] or TimeLimitedRushRankItemOne(self.content_rank)
        else
            self.rank_items[v.rank] = self.rank_items[v.rank] or TimeLimitedRushRankItemTwo(self.content_rank)
        end 
        local data = {}
        data.rank = v.rank
        data.name = v.name
        data.score = v.score
        self.rank_items[v.rank]:SetData(data)

     end
 
     local function all_frame_op_complete()
        self.update_first_rank_schedule_id = nil
        self:RequestRankListInfo()
     end
     
     self.update_first_rank_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)
end

--刷新奖励排行列表
function TimeLimitedRushPanel:UpdateRankInfo(info)
    local rank_data = {}

    for k,v in pairs(info) do
        local tbl = {}
        tbl.rank = v.rank
        tbl.score = v.sort
        tbl.name = v.base.name
        rank_data[v.rank] = tbl
    end


    for k,v in pairs(self.default_rank_data) do

         --这个排名下有服务端的排名数据就用服务端的
        local use_data = rank_data[v.rank]

        if not use_data then
            --没有就用默认的
            use_data = v;
        end

        local data = {}
        data.rank = use_data.rank
        data.name = use_data.name
        data.score = use_data.score
        self.rank_items[use_data.rank]:SetData(data)

    end


end

--刷新我的排名相关信息
function TimeLimitedRushPanel:UpdateMyRankInfo(data)
    --logError(Table2String(data))
    self.txt_my_score.text = data.sort
    self.txt_my_score2.text = data.sort
    if data.rank == 0 then
        self.txt_my_rank.text = "Unranked"
    else
        self.txt_my_rank.text = data.rank
    end

   

    --刷新进度条
    self:UpdateScoreProgress(data.sort)
end

--刷新模型和特效
function TimeLimitedRushPanel:UpdateModel(  )

    self.effect = UIEffect(self.effect_parent, 10311, false, self.layer)
    self.model_item = UIModelCommonCamera(self.model_parent, nil, self.model_name,nil,false)
    local cfg = {}
    cfg.pos = {x = self.model_pos_x, y = self.model_pos_y, z = 193}
    cfg.scale = {x=self.model_scale, y=self.model_scale, z=self.model_scale}

    if self.act_id == 100003 then
        cfg.trans_offset = {y=131}
    end
  

    self.model_item:SetConfig(cfg)
end

--刷新抽奖信息
function TimeLimitedRushPanel:UpdateDrawInfo()
    local info = self.st_model:GetInfo(self.act_id)
    self.count = (info and info.bless_value or 0)

    if self.count == 0 then
        --没抽取过 第一次免费 显示下红点
        self.txt_draw1_price.text = "Free"
        if not self.btn_draw1_reddot then
            self.btn_draw1_reddot = RedDot(self.btn_draw1)
            SetVisible(self.btn_draw1_reddot.transform,true)
            SetLocalPosition(self.btn_draw1_reddot.transform,67,18,0)
        end
    else
        self.txt_draw1_price.text = self.draw1_price
        if self.btn_draw1_reddot then
            destroySingle(self.btn_draw1_reddot)
            self.btn_draw1_reddot = nil
        end
    end

    self.txt_draw10_price.text = self.draw10_price

    --刷新活动背景文字 按钮图片 抽奖描述
    lua_resMgr:SetImageTexture(self,self.img_act_bg2,self.abName.."_image","img_timeLimitedRush_text2_"..self.act_id,true)
    --lua_resMgr:SetImageTexture(self,self.img_act_bg2,self.abName.."_image","img_timeLimitedRush_text2_100013",true)


    lua_resMgr:SetImageTexture(self,self.img_weapon,"main_image",self.btn_name,true)


    self.txt_draw_tip.text = self.draw_tip
end

--刷新积分进度
function TimeLimitedRushPanel:UpdateScoreProgress(score)
    
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

--请求积分宝箱信息
function TimeLimitedRushPanel:RequestScoreBox(  )
    GlobalEvent:Brocast(OperateEvent.REQUEST_GET_YY_INFO,self.score_box_act_id)
end

--刷新积分宝箱
function TimeLimitedRushPanel:UpdateScoreBox(info)
    --分帧实例化积分宝箱Item
    -- local num = #info.tasks
    -- if num <= 0 then
    --     return
    -- end
    
    -- local function op_call_back(cur_frame_count,cur_all_count)
    --     local v = info.tasks[cur_all_count]
    --     self.score_box_items[v.id] = self.score_box_items[v.id] or TimeLimitedRushScoreBoxItem(self.score_box_parent)
    --     local data = {}
    --     data.id = v.id
    --     data.level = v.level
    --     data.score = self.score_data[v.level]
    --     data.cfg = Config.db_yunying_reward[v.id .. "@" .. self.score_box_act_id]
    --     data.state = v.state
    --     data.act_id = self.score_box_act_id
    --     self.score_box_items[v.id]:SetData(data)
    -- end

    -- local function all_frame_op_complete()
    --    self.update_score_box_schedule_id = nil
    --     self:UpdateIconReddot()
    -- end
    
    -- self.update_score_box_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,0.1,1,num,nil,all_frame_op_complete)

    for k,v in pairs(info.tasks) do
        self.score_box_items[v.id] = self.score_box_items[v.id] or TimeLimitedRushScoreBoxItem(self.score_box_parent)
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

--请求抽奖
function TimeLimitedRushPanel:RequestDraw(count,price)
    if not RoleInfoModel.GetInstance():CheckGold(price,self.draw_cost_item_id) then
        return
    end
    --logError("限时抢购请求抽奖,act id-"..self.act_id)
    SearchTreasureController.GetInstance():RequestSearch(self.act_id,count)
end

--刷新右上角icon红点
function TimeLimitedRushPanel:UpdateIconReddot(  )
    local flag = false
    for k,v in pairs(self.score_box_items) do
        if v.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            flag = true
            break
        end
    end

    self.op_model:UpdateIconReddot(self.act_id,flag)
end