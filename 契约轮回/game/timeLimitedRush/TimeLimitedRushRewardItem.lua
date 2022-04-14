--限时冲榜奖励预览列表Item
TimeLimitedRushRewardItem = TimeLimitedRushRewardItem or class("TimeLimitedRushRewardItem",BaseItem)

function TimeLimitedRushRewardItem:ctor(parent_node)
    self.abName = "timeLimitedRush"
    self.assetName = "TimeLimitedRushRewardItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI

    self.goods_icon_items = {}  --icon列表
   
    TimeLimitedRushRewardItem.Load(self)
end

function TimeLimitedRushRewardItem:dctor()
    destroyTab(self.goods_icon_items)
end

function TimeLimitedRushRewardItem:LoadCallBack(  )
    self.nodes = {
        "img_bg","img_rank","txt_rank","scroll_view_reward/viewport_reward/content_reward","ellipse",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function TimeLimitedRushRewardItem:InitUI(  )
    self.img_bg = GetImage(self.img_bg)
    self.img_rank = GetImage(self.img_rank)
    self.txt_rank = GetText(self.txt_rank)
end

function TimeLimitedRushRewardItem:AddEvent(  )
    
end

--data
--index 索引
--rank 排名
--rewards 奖励物品表
function TimeLimitedRushRewardItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedRushRewardItem:UpdateView()
    self.need_update_view = false

   
    self:UpdateRankInfo()
    self:UpdateRewards()
end

--刷新排名信息
function TimeLimitedRushRewardItem:UpdateRankInfo(  )
    if self.data.index <= 3 then
        SetVisible(self.img_rank.transform,true)
        SetVisible(self.ellipse,false)
        SetVisible(self.txt_rank.transform,false)

        lua_resMgr:SetImageTexture(self,self.img_rank,"timelimitedrush_image","img_timeLimitedRush_rank"..self.data.rank,true)
        lua_resMgr:SetImageTexture(self,self.img_bg,"timelimitedrush_image","img_timeLimitedRush_reward_bg"..self.data.rank,true)
    else
        SetVisible(self.img_rank.transform,false)
        SetVisible(self.ellipse,true)
        SetVisible(self.txt_rank.transform,true)

        self.txt_rank.text = string.format( "No.%s",self.data.rank )

        local bg_index = 5
        if self.data.index%2 == 0 then
            bg_index = 4
        end
        lua_resMgr:SetImageTexture(self,self.img_bg,"timelimitedrush_image","img_timeLimitedRush_reward_bg"..bg_index,true)
    end
end

--刷新奖励
function TimeLimitedRushRewardItem:UpdateRewards(  )
    for k,v in pairs(self.data.rewards) do
        self.goods_icon_items[k] = GoodsIconSettorTwo(self.content_reward)
        local param = {}
        param.item_id = v[1]
        param.num = v[2]
        param.bind = v[3]
        param.can_click = true
        param.size = {x = 60,y = 60}
        self.goods_icon_items[k]:SetIcon(param)
    end
end

