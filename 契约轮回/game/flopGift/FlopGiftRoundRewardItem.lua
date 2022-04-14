--翻牌好礼轮次奖励Item
FlopGiftRoundRewardItem = FlopGiftRoundRewardItem or class("FlopGiftRoundRewardItem",BaseItem)

function FlopGiftRoundRewardItem:ctor(parent_node)
    self.abName = "FlopGift"
    self.assetName = "FlopGiftRoundRewardItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.fg_model = FlopGiftModel.GetInstance()
    self.fg_model_events = {}

    self.goods_icon_items = {}  --icon列表
   
    self.separate_frame_schedule_id = nil --分帧操作定时器id

    self:Load()
end

function FlopGiftRoundRewardItem:dctor()

    if table.nums(self.fg_model_events) > 0 then
        self.fg_model:RemoveTabListener(self.fg_model_events)
        self.fg_model_events = nil
    end

    destroyTab(self.goods_icon_items)

    if self.separate_frame_schedule_id then
        GlobalSchedule:Stop(self.separate_frame_schedule_id)
        self.separate_frame_schedule_id = nil
    end

end

function FlopGiftRoundRewardItem:LoadCallBack(  )
    self.nodes = {
        "scrollview/viewport/content","txt_round",
        "scrollview/viewport",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function FlopGiftRoundRewardItem:InitUI(  )
    self.txt_round = GetText(self.txt_round)
    
end

function FlopGiftRoundRewardItem:AddEvent(  )
    --处理翻牌结果返回
    local function callback(data)
        if self.data.round == self.fg_model.cur_round then
            for k,v in pairs(self.goods_icon_items) do
                if v:HandleTurn(data) then
                    return
                end
            end
        end
    end
    self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleTurn,callback)
end

--data
--round 轮次
--reward 奖励配置
--stencil_id 模板id
function FlopGiftRoundRewardItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function FlopGiftRoundRewardItem:UpdateView()
    self.need_update_view = false

    self:UpdateRound()
    self:UpdateIconItem()
    self:UpdatePositon()
end

--刷新轮次显示
function FlopGiftRoundRewardItem:UpdateRound(  )
    self.txt_round.text = string.format( "Rewards in Turn %s",self.data.round )
end

--刷新奖励物品Icon
function FlopGiftRoundRewardItem:UpdateIconItem(  )

    if not self.data.reward then
        return
    end

    local num = #self.data.reward
    if num == 0 then
        return
    end

    local function op_call_back(cur_frame_count,cur_all_count )

        local i = cur_all_count

        self.goods_icon_items[i] = self.goods_icon_items[i] or FlopGiftRoundRewardIconItem(self.content)

        local data = {}
        data.id = i
        data.round = self.data.round
        data.item_id = self.data.reward[i][1]
        data.num = self.data.reward[i][2]
        data.bind = self.data.reward[i][3]
        data.stencil_id = self.data.stencil_id

        self.goods_icon_items[i]:SetData(data)
    end

    local function all_frame_op_complete()
        self.separate_frame_schedule_id = nil
        
        --刷新content宽度
        local width = num * 65
        SetSizeDeltaX(self.content,width)
	end

    --0.1秒实例化1个
    self.separate_frame_schedule_id = SeparateFrameUtil.SeparateFrameOperate(op_call_back,0.1,1,num,nil,all_frame_op_complete)
end

--刷新位置
function FlopGiftRoundRewardItem:UpdatePositon(  )
    local offset_y = -121
    local start_y = -67.5
    local y = start_y +  (self.data.round-1) * offset_y
    
    SetAnchoredPosition(self.transform,159.5,y)
end
