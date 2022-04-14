--扭蛋机抽奖结果界面
EggMachineResultPanel = EggMachineResultPanel or class("EggMachineResultPanel", FirworksResultPanel)
local EggMachineResultPanel = EggMachineResultPanel

function EggMachineResultPanel:ctor()
    self.btn_list = {
        { btn_res = "common:btn_yellow_2", btn_name = ConfigLanguage.Mix.Confirm, format = "%s sec later auto-closed", auto_time = 10, call_back = handler(self, self.OkFunc) },
        -- 说明
        { btn_res = "common:btn_blue_2", btn_name = "Draw once", call_back = handler(self, self.SearchOne) },
        { btn_res = "common:btn_blue_2", btn_name = "Draw 10 times", call_back = handler(self, self.SearchTen) },
    }

    local panel = lua_panelMgr:GetPanel(EggMachinePanel)
    self.draw_cost_item_id = panel.draw_cost_item_id --抽奖消耗物品的id
    self.draw_price = panel.draw_price --单抽价格
    self.act_id = panel.act_id  --活动id
end

function EggMachineResultPanel:dctor()
end

function EggMachineResultPanel:LoadCallBack()
    EggMachineResultPanel.super.LoadCallBack(self)

    --替换掉烟花icon
    GoodIconUtil:CreateIcon(self, self.zuanshi, self.draw_cost_item_id, true)
    GoodIconUtil:CreateIcon(self, self.zuanshi2, self.draw_cost_item_id, true)

    --修改价格
    self.value0.text = self.draw_price
    self.value1.text = self.draw_price * 10
end

--请求抽奖
function EggMachineResultPanel:RequestSearch(times)
    local price = self.draw_price * times
    if not RoleInfoModel.GetInstance():CheckGold(price,self.draw_cost_item_id) then
        return
    end
    self:FireTheHole(times)
end

function EggMachineResultPanel:FireTheHole(times)
    local id = self.act_id
    if id == 0 then
        logError("没有该id  ", id)
        return
    end
    GlobalEvent:Brocast(OperateEvent.REQUEST_FIRE, id, times)
end


--页面上fire刷新
function EggMachineResultPanel:AddEvent()
    local function call_back(id, data)
        local self_id = self.act_id
        if self_id == 0 then
            return
        end
        if id ~= self_id then
            return
        end
        self:UpdateRewardList(data)
        self:UpdateView()
    end
    self.event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_FIRE, call_back)
end











