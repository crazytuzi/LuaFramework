--多倍投资Item
WorthWelfareInvestmentItem = WorthWelfareInvestmentItem or class("WorthWelfareInvestmentItem",BaseCloneItem)

function WorthWelfareInvestmentItem:ctor(obj,parent_node)
    self.abName = "WorthWelfare"
    self.assetName = "WorthWelfareInvestmentItem"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.state = 1 --状态 1-未购买 2-未达成 3-可领取 4-已领取

    self.vip_model = VipModel.GetInstance()
    self.vip_model_events = {}

    self.is_reddot = false --是否显示红点
    self.reddot = nil  --红点



    self:Load()
end

function WorthWelfareInvestmentItem:dctor()
    self.vip_model:RemoveTabListener(self.vip_model_events)
    self.vip_model_events = nil

    destroySingle(self.reddot)
    self.reddot = nil
end

function WorthWelfareInvestmentItem:LoadCallBack(  )
    self.nodes = {
        "btn_receive","txt_state","img_icon","txt_count","txt_progress",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()

   
end

function WorthWelfareInvestmentItem:InitUI(  )
    self.txt_state = GetText(self.txt_state)
    self.img_icon = GetImage(self.img_icon)
    self.txt_count = GetText(self.txt_count)
    self.txt_progress = GetText(self.txt_progress)
    self.img_receive = GetImage(self.btn_receive)
end

function WorthWelfareInvestmentItem:AddEvent(  )
    local function callback(  )
        if self.state == 3 then
            VipController.GetInstance():RequestFetchInvesetReward(self.data.id,self.data.type)
        end
    end
    AddClickEvent(self.btn_receive.gameObject,callback)

    --领取奖励成功
    local function callback(item)
        if item.id == self.data.id then
            --logError("领取奖励成功")
            --重新请求投资信息
            VipController.GetInstance():RequestInvestInfo2()
        end
    end
    self.vip_model_events[#self.vip_model_events + 1] = self.vip_model:AddListener(VipEvent.SuccessFetchInveRewa,callback)
end

--data
--id 投资奖励配置表id
--type 投资奖励类型
--icon_id 图标id
--count 可领取钻石数量
--is_pay 是否已购买多倍投资
--target_lv 目标等级
--invest_state 投资状态 1-可领取 2-已领取
function WorthWelfareInvestmentItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function WorthWelfareInvestmentItem:UpdateView()
    self.need_update_view = false

    self:UpdateIcon()
    self:UpdateCount()
    self:UpdateProgress()
    self:UpdateState()

end

--刷新Icon
function WorthWelfareInvestmentItem:UpdateIcon(  )
    lua_resMgr:SetImageTexture(self,self.img_icon,"iconasset/icon_recharge", self.data.icon_id, true, nil, false)
end

--刷新可领取钻石数量
function WorthWelfareInvestmentItem:UpdateCount(  )
    self.txt_count.text = self.data.count
end

--刷新进度
function WorthWelfareInvestmentItem:UpdateProgress()
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
    if lv < self.data.target_lv then
        color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
    end
    
    self.txt_progress.text = string.format( "Reach Lv. <color=#%s>%s</color>/%s and can claim",color,lv,self.data.target_lv )
end

--获取状态
function WorthWelfareInvestmentItem:GetState(  )
    if not self.data.is_pay then
        --未购买
        return 1
    end

    if not self.data.invest_state then

        local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        if lv >= self.data.target_lv then
            --可领取
            return 3
        end
        --未达成
        return 2
    end

    if self.data.invest_state == 1 then
        --可领取
        return 3
    end

    if self.data.invest_state == 2 then
        --已领取
        return 4
    end


end

--刷新状态
function WorthWelfareInvestmentItem:UpdateState(  )

    self.state = self:GetState()

    -- if self.is_loaded then
        
    -- else
    --     self.need_update_state = true
    -- end

    if self.state == 1 then
        self.txt_state.text = "Not Bought"
    elseif self.state == 2 then
        self.txt_state.text = "Not Reached"
    elseif self.state == 3 then
        self.txt_state.text = "Claim"
    elseif self.state == 4 then
        self.txt_state.text = "Claimed"
    end

    if self.state == 3 then
        self.is_reddot = true
        ShaderManager.GetInstance():SetImageNormal(self.img_receive)
    else
        self.is_reddot = false
        ShaderManager.GetInstance():SetImageGray(self.img_receive)
    end

    --状态刷新后红点也要刷新
    self:UpdateReddot()
end

--刷新红点
function WorthWelfareInvestmentItem:UpdateReddot(  )
    if not self.is_reddot and not self.reddot then
        return
    end

    self.reddot = self.reddot or RedDot(self.btn_receive)
    SetVisible(self.reddot,self.is_reddot)
    SetLocalPosition(self.reddot.transform,40,13.5,0)
end