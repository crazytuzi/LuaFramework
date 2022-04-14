--限时抢购奖池预览界面
TimeLimitedRushPreviewRewardsPanel = TimeLimitedRushPreviewRewardsPanel or class("TimeLimitedRushPreviewRewardsPanel",WindowPanel)

function TimeLimitedRushPreviewRewardsPanel:ctor()
    self.abName = "TimeLimitedRush"
    self.assetName = "TimeLimitedRushPreviewRewardsPanel"
    self.layer = "UI"

    self.panel_type = 4

    self.is_click_bg_close = true


    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.goods_icon_items = {} --奖励物品item列表
end

function TimeLimitedRushPreviewRewardsPanel:dctor()
    destroyTab(self.goods_icon_items,true)
end

function TimeLimitedRushPreviewRewardsPanel:LoadCallBack(  )
    self.nodes = {
        "scroll_view_rewards/viewport_rewards/content_rewards","btn_proba",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function TimeLimitedRushPreviewRewardsPanel:InitUI(  )
    
end

function TimeLimitedRushPreviewRewardsPanel:AddEvent(  )
    local function callback(  )
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(self.data.proba_id)
    end
    AddClickEvent(self.btn_proba.gameObject,callback)
end

--data
--rewards 奖励列表
--proba_id  --概率id
function TimeLimitedRushPreviewRewardsPanel:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedRushPreviewRewardsPanel:UpdateView()
    self.need_update_view = false

    self:UpdateRewards()
end

--刷新奖励预览
function TimeLimitedRushPreviewRewardsPanel:UpdateRewards(  )
    for k,v in pairs(self.data.rewards) do
        local icon = GoodsIconSettorTwo(self.content_rewards)
        local param = {}
        param.item_id = v[1]
        param.num = v[2]
        param.bind = v[3]
        param.can_click = true
        param.size = {x = 65,y = 65}
        icon:SetIcon(param)

        table.insert( self.goods_icon_items, icon )
    end
end
