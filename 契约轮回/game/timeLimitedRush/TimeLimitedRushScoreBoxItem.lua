--限时冲榜奖励积分积分宝箱Item
TimeLimitedRushScoreBoxItem = TimeLimitedRushScoreBoxItem or class("TimeLimitedRushScoreBoxItem",BaseItem)

function TimeLimitedRushScoreBoxItem:ctor(parent_node)
    self.abName = "timeLimitedRush"
    self.assetName = "TimeLimitedRushScoreBoxItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.goods_icon_items = {}  --预览奖励的items

    self.red_dot = nil --红点
    self.effect = nil  --特效

    self.global_events = {}

    TimeLimitedRushScoreBoxItem.Load(self)
end

function TimeLimitedRushScoreBoxItem:dctor()
    destroySingle(self.red_dot)
    self.red_dot = nil

    destroySingle(self.effect)
    self.effect = nil

    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil
end

function TimeLimitedRushScoreBoxItem:LoadCallBack(  )
    self.nodes = {
        "img_score_box","txt_score",
        "preview_parent","preview_parent/scroll_view_preview/viewport_preview/content_preview",
        "preview_parent/scroll_view_preview",
        "received",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function TimeLimitedRushScoreBoxItem:InitUI(  )
    self.img_score_box = GetImage(self.img_score_box)
    self.txt_score = GetText(self.txt_score)

    local panel = lua_panelMgr:GetPanel(TimeLimitedRushPanel)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.preview_parent, panel.transform, true, nil, false, 7)

    SetVisible(self.preview_parent,false)
    SetVisible(self.received,false)
end

function TimeLimitedRushScoreBoxItem:AddEvent(  )
    --点击宝箱
    local function call_back(  )

        if self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
            --已完成
            --logError("请求领取奖励")
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD,self.data.act_id,self.data.id,self.data.level)
        elseif self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            --未完成
            SetVisible(self.preview_parent,true)
        elseif self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            --已领奖
        end
    end
    AddClickEvent(self.img_score_box.gameObject,call_back)

    --点击奖励预览以外的地方 关闭奖励预览
    local function call_back(x,y)
        local is_in_preview = LayerManager:UIRectangleContainsScreenPoint(self.scroll_view_preview,x,y)
        SetVisible(self.preview_parent,is_in_preview)
    end
    local toucher = self.scroll_view_preview.gameObject:AddComponent(typeof(Toucher))
    toucher:SetClickEvent(call_back)

    --奖励领取返回
    local function call_back(data)
        if data.act_id ~= self.data.act_id or data.id ~= self.data.id then
            return
        end
        self.data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
        self:UpdateState()
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD,call_back)
end

--data
--id 序号
--level 档次
--score 积分需求
--cfg yunying_reward表
--state 奖励状态 1-已完成 2-未完成 3-已领奖
--act_id 活动id
function TimeLimitedRushScoreBoxItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedRushScoreBoxItem:UpdateView()
  
    self:UpdateInfo()

    self:UpdatePreviewRewards()

    self:UpdateState()

end



--刷新信息
function TimeLimitedRushScoreBoxItem:UpdateInfo(  )

    self.need_update_view = false
    self.txt_score.text = string.format( "%sPoint",self.data.score)
    --根据序号 加载不同宝箱图片
    local id = math.ceil(self.data.id / 2)
    lua_resMgr:SetImageTexture(self,self.img_score_box,"timelimitedrush_image","img_timeLimitedRush_reward_box"..id,true)
end

--刷新预览奖励
function TimeLimitedRushScoreBoxItem:UpdatePreviewRewards(  )

    if self.data.state ~= enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE  then
        --未完成状态才刷新预览奖励
        return
    end

    local rewards = String2Table(self.data.cfg.reward)
    for k,v in pairs(rewards) do
        self.goods_icon_items[k] = self.goods_icon_items[k] or GoodsIconSettorTwo(self.content_preview)
        local param = {}
        param["item_id"] = v[1]
        param["num"] = v[2]
        param["bind"] = v[3]
        param["size"] = {x=70, y=70}
        param["can_click"] = true
        self.goods_icon_items[k]:SetIcon(param)
    end
end

--刷新宝箱状态
function TimeLimitedRushScoreBoxItem:UpdateState(  )
    if self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        --已完成 显示特效和红点
        self.effect = self.effect or UIEffect(self.img_score_box.transform, 30011)

        self.red_dot = self.red_dot or RedDot(self.transform)
        SetVisible(self.red_dot.transform,true)
        SetLocalPosition(self.red_dot.transform,25.5,36,0)

    elseif self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        --未完成
     
    elseif self.data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        --已领奖 图标变灰 销毁特效和红点
        ShaderManager.GetInstance():SetImageGray(self.img_score_box)
        SetVisible(self.received,true)
        if self.effect then
            destroySingle(self.effect)
            self.effect = nil
        end
        if self.red_dot then
            destroySingle(self.red_dot)
            self.red_dot = nil
        end
    end
end
