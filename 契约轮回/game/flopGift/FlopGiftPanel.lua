FlopGiftPanel = FlopGiftPanel or class("FlopGiftPanel",BasePanel)

function FlopGiftPanel:ctor()
    self.abName = "FlopGift"
    self.assetName = "FlopGiftPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.is_hide_other_panel = true
    self.use_background = true

    self.fg_model = FlopGiftModel.GetInstance()
    self.fg_model_events = {}

    self.global_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.round_reward_items = {}  --轮次奖励item列表
    self.card_items = {}  --卡牌item列表

    self.free_refresh_effect = nil --免费刷新特效

    self.countdowntext = nil  --倒计时

    self.show_reward_cfg = self.fg_model:GetShowReward()  --当前等级段的轮次奖励配置
   
    self.cur_round_refresh_cost_id = 0  --当前轮次刷新消耗道具id
    self.cur_round_refresh_cost_num = 0  --当前轮次刷新消耗道具数量


    self.card_separate_frame_schedule_id = nil --分帧实例化卡牌定时器id
    self.reward_separate_frame_schedule_id = nil --分帧实例化轮次奖励定时器id

    self.stencil_id = 0 --模板id
    self.stencil_mask = nil --模板遮罩
   
end

function FlopGiftPanel:dctor()
    if table.nums(self.fg_model_events) > 0 then
        self.fg_model:RemoveTabListener(self.fg_model_events)
        self.fg_model_events = nil
    end

    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil

    destroyTab(self.card_items,true)
    destroyTab(self.round_reward_items,true)

    destroySingle(self.free_refresh_effect)
    self.free_refresh_effect = nil

    destroySingle(self.countdowntext)
    self.countdowntext = nil

    if self.card_separate_frame_schedule_id then
        GlobalSchedule:Stop(self.card_separate_frame_schedule_id)
        self.card_separate_frame_schedule_id = nil
    end

    if self.reward_separate_frame_schedule_id then
        GlobalSchedule:Stop(self.reward_separate_frame_schedule_id)
        self.reward_separate_frame_schedule_id = nil
    end

    if self.stencil_mask then
        destroy(self.stencil_mask)
        self.stencil_mask = nil
    end
end

function FlopGiftPanel:LoadCallBack(  )
    self.nodes = {
        "btn_close",
        "left/countdown_parent","left/scrollview/viewport/content",
        "right/btn_refresh","right/card_parent","right/btn_help","right/btn_refresh/img_cost",
        "right/txt_cur_round","right/btn_refresh/txt_cost",

        "right/card_parent/FlopGiftCardItem",
        "left/scrollview/viewport",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "flopGift", false)
    FlopGiftController.GetInstance():RequestInfo()
end

function FlopGiftPanel:InitUI(  )
    self.img_cost = GetImage(self.img_cost)
    self.txt_cost = GetText(self.txt_cost)
    self.txt_cur_round = GetText(self.txt_cur_round)
end

function FlopGiftPanel:AddEvent(  )

    --关闭按钮
    local function callback(  )
        self:Close()
    end
    AddClickEvent(self.btn_close.gameObject,callback)

    --问号按钮
    local function callback(  )
        lua_panelMgr:GetPanelOrCreate(FlopGiftTipPanel):Open()
    end
    AddClickEvent(self.btn_help.gameObject,callback)

    --刷新
    local function callback(  )
        self:TryRequestRefresh()
    end
    AddClickEvent(self.btn_refresh.gameObject,callback)

    --处理翻牌好礼信息返回
    local function callback(  )
        self:UpdateRoundReward()
        self:UpdateCard()
        self:UpdateCurRound()
        self:UpdateRefresh()
    end
    self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleInfo,callback)

    --处理翻牌结果返回
    local function callback(  )
        self:UpdateRefresh()
    end
    self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleTurn,callback)

    --处理刷新轮数返回
    local function callback(  )
        self:UpdateRefresh()
        self:UpdateCurRound()
    end
    self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleNextRound,callback)

    --处理跨天
    local function callback(  )
        self:Close()
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(EventName.CrossDay,callback)
end

--data
function FlopGiftPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end


function FlopGiftPanel:UpdateView()
    self.need_update_view = false

    self:SetMask()
    self:UpdateCountdownText()
end


--设置遮罩
function FlopGiftPanel:SetMask()
    

    if not self.stencil_mask then
        self.stencil_mask = AddRectMask3D(self.viewport.gameObject)
    end

    if self.stencil_id == 0 then
        self.stencil_id = GetFreeStencilId()
    end

    self.stencil_mask.id = self.stencil_id
end

--刷新轮次奖励
function FlopGiftPanel:UpdateRoundReward(  )

    local num = #self.show_reward_cfg
    if num == 0 then
        return
    end

    local function op_call_back(cur_frame_count,cur_all_count )

        local i = cur_all_count

        self.round_reward_items[i] = self.round_reward_items[i] or FlopGiftRoundRewardItem(self.content)
        local data = {}
        data.round = i
        data.reward = self.show_reward_cfg[i]
        data.stencil_id = self.stencil_id
        self.round_reward_items[i]:SetData(data)
     
    end

    local function all_frame_op_complete()
        self.reward_separate_frame_schedule_id = nil
        
        --刷新content高度
        local height = 7 + (num * 121)
        SetSizeDeltaY(self.content,height)
	end

    --1帧实例化1个
    self.reward_separate_frame_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)

end

--刷新卡牌
function FlopGiftPanel:UpdateCard(  )

    local num = self.fg_model.all_card_count
    if num == 0 then
        return
    end

    local function op_call_back(cur_frame_count,cur_all_count )

        local i = cur_all_count
        self.card_items[i] = self.card_items[i] or FlopGiftCardItem(self.card_parent)
        local data = {}
        data.id = i
        self.card_items[i]:SetData(data)
   
    end

    local function all_frame_op_complete()
		self.card_separate_frame_schedule_id = nil
	end

    --1帧实例化1个
    self.card_separate_frame_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)
end

--刷新当前轮次信息
function FlopGiftPanel:UpdateCurRound(  )
    self.txt_cur_round.text = string.format( "Turn %s",self.fg_model.cur_round )
end

--刷新轮次刷新消耗
function FlopGiftPanel:UpdateRefresh(  )

    --没抽中大奖或者最后一轮 不显示刷新按钮
    if not self.fg_model.is_get_big_reward or self.fg_model:IsLastRound() then
        SetVisible(self.btn_refresh,false)
        return
    end

    SetVisible(self.btn_refresh,true)

    local reset = self.fg_model.flop_gift_cfg[self.fg_model.cur_round].reset
    reset = String2Table(reset)

    local item_id = reset[1][1]
    local num = reset[1][2]

    GoodIconUtil.GetInstance():CreateIcon(self, self.img_cost, item_id, true)

    if self.fg_model:IsAllTurnCard() then
        self.txt_cost.text = "Free"

        --显示免费刷新特效
        if not self.free_refresh_effect then
            self.free_refresh_effect = UIEffect(self.btn_refresh,20429)
            local pos = { x = 0, y = 0, z = 0 }
            local scale = { x = 1.88, y = 1, z = 0.6 }
            self.free_refresh_effect:SetConfig({ pos = pos,scale = scale })
        else
            SetVisible(self.free_refresh_effect.transform,true)
        end

    else
        self.txt_cost.text = "X "..num

        if self.free_refresh_effect then
            SetVisible(self.free_refresh_effect.transform,false)
        end
    end

   

    self.cur_round_refresh_cost_id = item_id
    self.cur_round_refresh_cost_num = num
end

--刷新倒计时
function FlopGiftPanel:UpdateCountdownText(  )
   
    --当天晚上12点的时间戳
    local end_time = TimeManager.GetInstance():GetTomorZeroTime()

    local param = {}
    param.isShowMin = true
    param.isShowHour = true
    param.isShowSec = true
    param.isChineseType = false
    self.countdowntext = self.countdowntext or CountDownText(self.countdown_parent,param)
    self.countdowntext:StartSechudle(end_time)
end

--尝试请求刷新
function FlopGiftPanel:TryRequestRefresh(  )

    local key_id = self.cur_round_refresh_cost_id
    local key_name = Config.db_item[key_id].name

    --获取已有抽奖消耗道具数量
    local had_num = BagController:GetInstance():GetItemListNum(key_id)
    
    local need_num = self.cur_round_refresh_cost_num

    --所有牌都翻完 免费刷新
    if self.fg_model:IsAllTurnCard() then
        need_num = 0
    end


    if had_num >= need_num then
        self:RequestRefresh(0)
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

        local function ok_fun()
            self:RequestRefresh(gold)
        end
        Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, nil, false,nil,FlopGiftPanel.__cname)
    end
end

--请求刷新
function FlopGiftPanel:RequestRefresh(need_gold)
    local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
    if not bo then
        return
    end

    FlopGiftController.GetInstance():RequestNextRound()
end