--翻牌好礼卡牌Item
FlopGiftCardItem = FlopGiftCardItem or class("FlopGiftCardItem",BaseItem)

function FlopGiftCardItem:ctor(parent_node)
    self.abName = "FlopGift"
    self.assetName = "FlopGiftCardItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.fg_model = FlopGiftModel.GetInstance()
    self.fg_model_events = {}

    self.goods_icon_item = nil --物品icon

    self.big_reward_effect = nil  --大奖边框特效

    FlopGiftCardItem.Load(self)
end

function FlopGiftCardItem:dctor()
    if table.nums(self.fg_model_events) > 0 then
        self.fg_model:RemoveTabListener(self.fg_model_events)
        self.fg_model_events = nil
    end

    destroySingle(self.goods_icon_item)
    self.goods_icon_item = nil

    destroySingle(self.big_reward_effect)
    self.big_reward_effect = nil
end

function FlopGiftCardItem:LoadCallBack(  )
    self.nodes = {
        "icon_parent","selected","front","back",
        "big_reward",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function FlopGiftCardItem:InitUI(  )
    
end

function FlopGiftCardItem:AddEvent(  )

    --卡牌点击
    local function callback(  )
        local cost = self.fg_model:GetCost()
        local item_id = cost[1]
        local item_name = Config.db_item[item_id].name
        local num = cost[2]

        local function ok_func(  )

            local bo = RoleInfoModel:GetInstance():CheckGold(num, Constant.GoldIDMap[item_id])
            if not bo then
                return
            end

            FlopGiftController.GetInstance():RequestTurn(self.data.id)
        end

        local message = string.format( "Do you wan to use %s%s to turn over a card",num,item_name )

        Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_func, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert,false,nil,FlopGiftCardItem.__cname)
    end
    AddClickEvent(self.back.gameObject,callback)


    --处理翻牌结果返回
    local function callback(data)
        if data.pos == self.data.id then
            self:Flop(data.item_id,data.item_count)
            self:UpdateSelected(true)
        else
            self:UpdateSelected(false)
        end
    end
    self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleTurn,callback)

    --处理刷新轮数返回
    local function callback(  )
        self:UpdateState()
    end
    self.fg_model_events[#self.fg_model_events + 1] = self.fg_model:AddListener(FlopGiftEvent.HandleNextRound,callback)
end

--data
--id
function FlopGiftCardItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end

   
end

function FlopGiftCardItem:UpdateView()
    self.need_update_view = false

    self:UpdateState()
    self:UpdateSelected(false)
    self:UpdatePositon()
end

--刷新状态（是否已翻开）
function FlopGiftCardItem:UpdateState(  )
    local tab = self.fg_model:GetCardItem(self.data.id)
    if tab then
        self:Flop(tab[1],tab[2])
    else
        self:Close()
        self:UpdateSelected(false)
    end
end

--翻开
function FlopGiftCardItem:Flop(item_id,item_count)

    local is_big_reward = self.fg_model:IsGetBigReward(item_id)

    SetVisible(self.back,false)

    --根据是否大奖显示牌面
    if is_big_reward then
        SetVisible(self.big_reward,true)
        SetVisible(self.front,false)
    else
        SetVisible(self.big_reward,false)
        SetVisible(self.front,true)
    end
    

    SetVisible(self.icon_parent,true)

    self.goods_icon_item = self.goods_icon_item or GoodsIconSettorTwo(self.icon_parent)
    local param = {}
    param.item_id = item_id
    param.num = item_count
    param.can_click = true
    param.size = {x = 90,y = 90}

    self.goods_icon_item:SetIcon(param)

    --边框特效
    self:UpdateEffect(is_big_reward)
    
end

--关上
function FlopGiftCardItem:Close( )
    SetVisible(self.back,true)
    SetVisible(self.front,false)
    SetVisible(self.icon_parent,false)
    SetVisible(self.big_reward,false)
    if self.big_reward_effect then
        SetVisible(self.big_reward_effect,false)
    end
end


--刷新是否已选中
function FlopGiftCardItem:UpdateSelected(is_selected)
    SetVisible(self.selected,is_selected)
end

--刷新位置
function FlopGiftCardItem:UpdatePositon(  )
    local offset_x = 121.86
    local start_x = 51
    local x = start_x + ((self.data.id-1) % 4) * offset_x

    
    local offset_y = -173.66
    local start_y = -93
    local y = start_y +  (math.ceil(self.data.id / 4)-1) * offset_y

    SetAnchoredPosition(self.transform,x,y)
end

--刷新翻开后的特效
function FlopGiftCardItem:UpdateEffect(is_big_reward)
    --检查这张卡牌上的物品是否是大奖
    --显示不同的边框特效
    if is_big_reward then

        if not self.big_reward_effect then
            self.big_reward_effect = UIEffect(self.transform,47001)
            local pos = { x = 4, y = 0, z = 0 }
            local scale = { x = 1.13, y = 1.33, z = 1 }
            self.big_reward_effect:SetConfig({ pos = pos,scale = scale })
        else
            SetVisible(self.big_reward_effect,true)
        end
    else
        if self.big_reward_effect then
            SetVisible(self.big_reward_effect,false)
        end
    
    end
end
