--翻牌好礼轮次奖励物品Item
FlopGiftRoundRewardIconItem = FlopGiftRoundRewardIconItem or class("FlopGiftRoundRewardIconItem",BaseItem)

function FlopGiftRoundRewardIconItem:ctor(parent_node)
    self.abName = "FlopGift"
    self.assetName = "FlopGiftRoundRewardIconItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.goods_icon = nil  --物品icon
   
    self.fg_model = FlopGiftModel.GetInstance()
    self.fg_model_events = {}

    self.is_get = false --是否已抽取到

    self:Load()
end

function FlopGiftRoundRewardIconItem:dctor()
    if table.nums(self.fg_model_events) > 0 then
        self.fg_model:RemoveTabListener(self.fg_model_events)
        self.fg_model_events = nil
    end

    destroySingle(self.goods_icon)
    self.goods_icon = nil
end

function FlopGiftRoundRewardIconItem:LoadCallBack(  )
    self.nodes = {
        "gray","icon_parent","have_get",
        "big_reward",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function FlopGiftRoundRewardIconItem:InitUI(  )

end

function FlopGiftRoundRewardIconItem:AddEvent(  )

    -- --处理翻牌结果返回
    -- local function callback(data)
    --     logError("FlopGiftRoundRewardIconItem-处理翻牌结果返回")
    --     if data.item_id == self.data.item_id then
    --         self:UpdateState()
    --     end
    -- end
    -- self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleTurn,callback)
end

--data
--id
--round 轮次
--item_id 物品id
--num 物品数量
--bind 物品绑定
--stencil_id 模板id
function FlopGiftRoundRewardIconItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function FlopGiftRoundRewardIconItem:UpdateView()
    self.need_update_view = false

    self:UpdateIcon()
    self:UpdateBigReward()
    self:UpdateState()
    self:UpdatePositon()
end



--刷新物品Icon
function FlopGiftRoundRewardIconItem:UpdateIcon( )
    self.goods_icon = self.goods_icon or GoodsIconSettorTwo(self.icon_parent)

    local param = {}

    param.item_id = self.data.item_id
    param.num = self.data.num
    param.bind = self.data.bind
    param.can_click = true
    param.size = {x = 65,y = 65}

    --特效
    local color = Config.db_item[self.data.item_id].color - 1
    param["color_effect"] = color
    param["effect_type"] = 2
    param["stencil_id"] = self.data.stencil_id
    param["stencil_type"] = 3
    self.goods_icon:SetIcon(param)
end

--刷新大奖边框
function FlopGiftRoundRewardIconItem:UpdateBigReward()
    local is_big_reward = self.data.id == 1
    SetVisible(self.big_reward,is_big_reward)
end

--刷新状态（是否已抽取）
function FlopGiftRoundRewardIconItem:UpdateState(  )
    local is_get = self.fg_model:IsGet(self.data.round,self.data.item_id,self.data.num) 
    SetVisible(self.gray,is_get)
    SetVisible(self.have_get,is_get)

    self.is_get = is_get
end

--处理翻牌结果
function FlopGiftRoundRewardIconItem:HandleTurn(data)
    if data.item_id == self.data.item_id and data.item_count == self.data.num and not self.is_get then
        self:UpdateState()
        return  true
    end
    return false
end

--刷新位置
function FlopGiftRoundRewardIconItem:UpdatePositon(  )
    local offset_x = 65
    local start_x = 32.5
    local x = start_x +  (self.data.id-1) * offset_x
    
    SetAnchoredPosition(self.transform,x,-40.135)
end