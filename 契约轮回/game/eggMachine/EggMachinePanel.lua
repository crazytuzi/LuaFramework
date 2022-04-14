--扭蛋机界面
EggMachinePanel = EggMachinePanel or class("EggMachinePanel",BasePanel)

function EggMachinePanel:ctor()
    self.abName = "eggMachine"
    self.assetName = "EggMachinePanel"
    self.layer = "UI"

    self.use_background = true  
    self.is_click_bg_close = true

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.op_model = OperateModel.GetInstance()

    self.global_events = {}

    self.act_type_id = 980
    self.act_id = OperateModel.GetInstance():GetActIdByType(self.act_type_id)--活动id
    --self.act_id = 298001


    self.act_cfg = self.op_model:GetConfig(self.act_id)--活动配置  
    
    self.draw_cost_item_id = nil--抽奖消耗物品的id
    self.draw_price = nil--单抽价格

    self.preview_goods_icon_items = {}--奖励预览item列表
    self.separate_frame_schedule_id = nil--分帧实例化的定时器id

    self.ui_effect = nil--大奖特效
    self.big_reward_goods_icon_item = nil--大奖的item

    self.records_items = {}  --抽奖记录的item
    
    self.egg_machine_animator = nil  --扭蛋机动画组件
    self.anim_clip_length = nil --扭蛋机动画长度
    self.anim_schedule_id = nil --扭蛋机动画定时器id

    self.is_drawing = false  --抽奖动画是否播放中
end

function EggMachinePanel:dctor()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_draw1)
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_draw10)
    
    destroyTab(self.preview_goods_icon_items,true)

    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

    destroySingle(self.ui_effect)
    self.ui_effect = nil

    destroySingle(self.big_reward_goods_icon_item)
    self.big_reward_goods_icon_item = nil
    
    if self.separate_frame_schedule_id then
		GlobalSchedule:Stop(self.separate_frame_schedule_id)
		self.separate_frame_schedule_id = nil
    end

    if self.anim_schedule_id then
		GlobalSchedule:Stop(self.anim_schedule_id)
		self.anim_schedule_id = nil
    end
    
   
end

function EggMachinePanel:LoadCallBack(  )
    self.nodes = {
        "btn_close",

        "left/left_up/rewards_scroll_view/rewards_viewport/rewards_content",

        "left/left_middle/reward_icon_parent","left/left_middle/txt_reward_name","left/left_middle/reward_effect_parent",
        "left/left_middle/reward_name_bg",
        "left/left_middle/btn_proba",

        "right/draw1/txt_draw1_des","right/draw1/btn_draw1","right/draw1/txt_draw1_cost",

        "right/draw10/txt_draw10_cost","right/draw10/txt_draw10_des","right/draw10/btn_draw10",
        "right/draw1/img_draw1_cost","right/draw10/img_draw10_cost",

        "right",
        "right/draw1","right/draw10",

        "left/left_buttom/records_scroll_view/records_viewport/txt_records",

        
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function EggMachinePanel:InitUI(  )
    self.txt_reward_name = GetText(self.txt_reward_name)
    self.txt_draw1_cost = GetText(self.txt_draw1_cost)
    self.txt_draw1_des = GetText(self.txt_draw1_des)
    self.txt_draw10_cost = GetText(self.txt_draw10_cost)
    self.txt_draw10_des = GetText(self.txt_draw10_des)

    self.img_draw1_cost = GetImage(self.img_draw1_cost)
    self.img_draw10_cost = GetImage(self.img_draw10_cost)

    self.txt_records = GetText(self.txt_records)

    SetVisible(self.draw1,false)
    SetVisible(self.draw10,false)
end

function EggMachinePanel:AddEvent(  )

    --关闭界面按钮
    local function call_back(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,call_back)

    --抽取一次
    local function call_back(  )
        self:RequestDraw(1)
    end
    AddClickEvent(self.btn_draw1.gameObject,call_back)

    --抽取十次
    local function call_back(  )
        self:RequestDraw(10)
    end
    AddClickEvent(self.btn_draw10.gameObject,call_back)

    --概率按钮
    local function call_back(  )
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(15)
    end
    AddClickEvent(self.btn_proba.gameObject,call_back)

    --抽奖返回
    local function call_back(act_id,reward_ids)
        if act_id ~= self.act_id then
            return
        end

        local panel = lua_panelMgr:GetPanel(EggMachineResultPanel)
        if not panel then
            panel = lua_panelMgr:GetPanelOrCreate(EggMachineResultPanel)
            panel:Open(reward_ids)
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_FIRE,call_back)

    local function call_back(act_id,logs)
        if act_id ~= self.act_id then
            return
        end
        self:UpdateRecord(logs)
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(OperateEvent.DELIVER_YY_LOG,call_back)
    
    local function call_back(act_id,log)
        if act_id ~= self.act_id then
            return
        end
        self:UpdateRecord({log})
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(OperateEvent.UPDATE_YY_LOG,call_back)
end

--data
function EggMachinePanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function EggMachinePanel:UpdateView()
    self.need_update_view = false

    self:UpdateRewardsPreview()
    self:UpdateBigReward()
    self:RequestRecords()
    self:UpdateDrawInfo()
end

--刷新奖励预览
function EggMachinePanel:UpdateRewardsPreview(  )

    local rewards = String2Table(self.act_cfg.sundries)
    rewards = self:GetRewardsByLv(rewards)[1]

    --分帧实例化预览的奖励Item
    local num = #rewards
    if num <= 0 then
		return
    end
    
    local function op_call_back(cur_frame_count,cur_all_count)
        local reward = rewards[cur_all_count]

        self.preview_goods_icon_items[cur_all_count] = GoodsIconSettorTwo(self.rewards_content)
        local param = {}
        param.item_id = reward[1]
        param.num = reward[2]
        param.bind = reward[3]
        param.can_click = true
        param.size = {x = 65,y = 65}
        self.preview_goods_icon_items[cur_all_count]:SetIcon(param)
    end

    local function all_frame_op_complete()
        self.separate_frame_schedule_id = nil

        --所有奖励预览物品加载完后，加载扭蛋机动画Item
        local function call_back(objs)
            local go = GameObject.Instantiate(objs[0],self.right)
            go.transform:SetAsFirstSibling()
            SetVisible(self.draw1,true)
            SetVisible(self.draw10,true)

            self.egg_machine_animator = go:GetComponent("Animator")
            self.anim_clip_length = GetClipLength(self.egg_machine_animator,"EggMachineAnim")
        end
        lua_resMgr:LoadPrefab(self,self.abName.."_prefab","EggMachineAnimItem.prefab",call_back)
    end
    
    self.separate_frame_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)

end

--刷新本期大奖
function EggMachinePanel:UpdateBigReward()
    

    local rewards = String2Table(self.act_cfg.reward)
    rewards = self:GetRewardsByLv(rewards)

    local reward = rewards[1]
    if type(rewards[1][1]) == "table" then
        reward = rewards[1][1]
    end

    

    --大奖icon
    self.big_reward_goods_icon_item = GoodsIconSettorTwo(self.reward_icon_parent)
    local param = {}
    param.item_id = reward[1]
    param.num = reward[2]
    param.bind = reward[3]
    param.can_click = true
    param.size = {x = 65,y = 65}
    self.big_reward_goods_icon_item:SetIcon(param)

    --大奖名称
    self.txt_reward_name.text = Config.db_item[param.item_id].name

    --加载特效
    self.ui_effect = UIEffect(self.reward_effect_parent, 10311, false, self.layer)

    --设置层级，让特效在最下面
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.reward_icon_parent, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.reward_name_bg, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.txt_reward_name.transform, nil, true, nil, false, 3)
end

--请求中奖记录
function EggMachinePanel:RequestRecords(  )
    GlobalEvent:Brocast(OperateEvent.REQUEST_YY_LOG,self.act_id)
end

--刷新抽奖相关信息
function EggMachinePanel:UpdateDrawInfo(  )
    local reqs = String2Table(self.act_cfg.reqs)
    local cost = nil
    for k,v in pairs(reqs) do
        if v[1] == "cost" then
            cost = v[2][1]
            break
        end
    end
    self.draw_cost_item_id = cost[1]
    self.draw_price = cost[2]

    --价格
    self.txt_draw1_cost.text = self.draw_price
    self.txt_draw10_cost.text = self.draw_price * 10

    --钻石icon
    GoodIconUtil:CreateIcon(self, self.img_draw1_cost, self.draw_cost_item_id, true)
    GoodIconUtil:CreateIcon(self, self.img_draw10_cost, self.draw_cost_item_id, true)

end

--请求抽奖
function EggMachinePanel:RequestDraw(count)
    if self.is_drawing then
        --抽奖动画播放中，不允许再次请求抽奖
        return
    end

    local price = self.draw_price * count
    if not RoleInfoModel.GetInstance():CheckGold(price,self.draw_cost_item_id) then
        return
    end

    

    --播放扭蛋机动画
    self.is_drawing = true
    self.egg_machine_animator:Play("EggMachineAnim")

    local function call_back(  )
        self.anim_schedule_id = nil
        GlobalEvent:Brocast(OperateEvent.REQUEST_FIRE, self.act_id, count)

        --动画播放结束后油等两秒保证结果面板打开再把标志位设置回去
        local function call_back(  )
            self.is_drawing = false
        end
        GlobalSchedule:StartOnce(call_back,2) 
    end
    self.anim_schedule_id = GlobalSchedule:StartOnce(call_back,self.anim_clip_length) 

    local target = self["btn_draw"..count]

    --播放按钮旋转动画
    local action1 = cc.RotateTo(0.5,-90)
    local action2 = cc.DelayTime(0.25)
    local action3 = cc.RotateTo(0.5,0)
    local action4 = cc.Sequence(action1,action2,action3)
    cc.ActionManager:GetInstance():addAction(action4,target)
end

--根据等级获取对应的奖励物品表
function EggMachinePanel:GetRewardsByLv(reward)
    --local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local lv = RoleInfoModel.GetInstance().world_level
    --logError(lv)
    local rewards = nil  --当前等级对应的奖励物品表

    --根据当前等级获取对应的奖励物品表

    if type(reward[1][1]) == "number" then
        --特殊处理只配了一个等级区间的情况
        local min_lv = reward[1][1]
        local max_lv = reward[1][2] 
        if lv >= min_lv and lv <= max_lv then
            rewards = reward
        end
    else
        for k,v in pairs(reward) do
            local min_lv = v[1][1]
            local max_lv = v[1][2] 
            if lv >= min_lv and lv <= max_lv then
                rewards = v
                break;
            end
        end
    end

   

    --把代表等级区间的第一个元素移除掉就得到奖励物品表了
    table.remove(rewards,1)
    return rewards
end

--刷新抽奖记录
function EggMachinePanel:UpdateRecord(logs)
    local tbl = {}
    for k,v in pairs(logs) do
        local player_name = v.role_name
        player_name = string.format( "<color=#%s>【%s】</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),player_name)
    
        local item_name = Config.db_item[v.item_id].name
        local item_color = Config.db_item[v.item_id].color
        item_name = string.format( "<color=#%s>【%s】</color>",ColorUtil.GetColor(item_color),item_name)
    
        table.insert( tbl, string.format( "%s won big prize in Gashapon machine%s\n",player_name,item_name))
    end
    local str = table.concat( tbl, "", 1, #tbl )
    self.txt_records.text = self.txt_records.text .. str
end