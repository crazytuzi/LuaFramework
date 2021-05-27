ActGoldConsumeView = ActGoldConsumeView or BaseClass(ActBaseView)

function ActGoldConsumeView:__init(view, parent, act_id)
    self:LoadView(parent)
end

function ActGoldConsumeView:__delete()
    if self.consume_send_list then
        self.consume_send_list:DeleteMe()
        self.consume_send_list = nil
    end
end

function ActGoldConsumeView:InitView()
    self:CreateRateScroll()
end

--创建列表
function ActGoldConsumeView:CreateRateScroll()
    if nil == self.consume_send_list then
        local ph = self.ph_list.ph_comsume_list
        --创建滚动列表
        self.consume_send_list = GridScroll.New()
        --设置列表的位置，SingleChargeItemRender：item格式，方向
        self.consume_send_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 55, ConsumeRateRender, ScrollDir.Vertical, false, self.ph_list.ph_consume_item)
       --将列表添加到当前面板中
        self.node_t_list.layout_consume_gift.node:addChild(self.consume_send_list:GetView(), 100)
    end
end

function ActGoldConsumeView:RefreshView(param_list)
    local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.YBFS)
    local rate_list = {}
    if data and data.config then
        for i,v in ipairs(data.config) do
            local list = {}
            list.min = v.conmoney
            if i == #data.config then 
                list.max = 1
            else
                list.max = data.config[i + 1].conmoney
            end
            list.rate = v.rebateRate
            table.insert(rate_list, list)
        end
    end
    --设置列表数据
    self.consume_send_list:SetDataList(rate_list)
    -- --跳至顶部
    self.consume_send_list:JumpToTop()
    self.node_t_list.lbl_consume.node:setString(ActivityBrilliantData.Instance:GetGoldConsume())
end



ConsumeRateRender = ConsumeRateRender or BaseClass(BaseRender)
function ConsumeRateRender:__init()
end

function ConsumeRateRender:__delete()
end

function ConsumeRateRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ConsumeRateRender:OnFlush()
	if nil == self.data then
		return
    end
    if self.index % 2 == 0 then
		local size = self.node_tree.img_bg.node:getContentSize()
		local bg = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetRankingList("img_rankinglist_9"), true)
		self.node_tree.img_bg.node:addChild(bg)
	end
    local str = ""
    if self.data.min == 1 then 
        str = string.format(Language.ActivityBrilliant.ConsumeRangeGroup[1], self.data.max )
    elseif self.data.max == 1 then
        str = string.format(Language.ActivityBrilliant.ConsumeRangeGroup[3], self.data.min)
    else
        str = string.format(Language.ActivityBrilliant.ConsumeRangeGroup[2], self.data.min, self.data.max - 1)
    end
    self.node_tree.lbl_consume_range.node:setString(str)
    self.node_tree.txt_mult.node:setString(self.data.rate / 100 .. "%")
end

function ConsumeRateRender:CreateSelectEffect()
end