-- @Author: lwj
-- @Date:   2019-03-27 21:50:03
-- @Last Modified time: 2019-03-27 21:50:17

CandyClosingPanel = CandyClosingPanel or class("CandyClosingPanel", BasePanel)
local CandyClosingPanel = CandyClosingPanel

function CandyClosingPanel:ctor()
    self.abName = "candy"
    self.assetName = "CandyClosingPanel"
    self.layer = "UI"

    self.model = CandyModel.GetInstance()
    self.reward_list = {}
end

function CandyClosingPanel:dctor()

end

function CandyClosingPanel:Open(data)
    self.data = data
    CandyClosingPanel.super.Open(self)
end

function CandyClosingPanel:LoadCallBack()
    self.nodes = {
        "btn_cancle", "btn_confirm", "reward_scro/Viewport/reward_content", "exp",
        "rank",
        "rank_img", "Sundries/eft_con", "Sundries/V_Icon"
    }
    self:GetChildren(self.nodes)
    self.exp = GetText(self.exp)
    self.rank = GetText(self.rank)
    self.rank_img = GetImage(self.rank_img)

    self:AddEvent()
    self:InitPanel()
end

function CandyClosingPanel:AddEvent()
    AddButtonEvent(self.btn_cancle.gameObject, handler(self, self.Close))
    AddButtonEvent(self.btn_confirm.gameObject, handler(self, self.Close))
end

function CandyClosingPanel:OpenCallBack()
    self.time = 15
    self:StopClock()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.ClockFun), 1, -1)
end

function CandyClosingPanel:ClockFun()
    if self.time > 0 then
        self.time = self.time - 1
    else
        self:Close()
    end
end

function CandyClosingPanel:InitPanel()
    self:LoadEft()
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.V_Icon.transform, nil, true, nil, false, 2)
    local after_transfer_exp = GetShowNumber(self.data.exp)
    self.exp.text = after_transfer_exp
    if self.data.rank <= 3 then
        SetVisible(self.rank, true)
        SetVisible(self.rank_img, true)
        lua_resMgr:SetImageTexture(self, self.rank_img, "candy_image", "rank_icon_" .. self.data.rank, false, nil, false)
    else
        SetVisible(self.rank_img, false)
        SetVisible(self.rank, true)
    end
    self.rank.text = "No. " .. self.data.rank .. " No. X"
    local str = Config.db_candyroom_reward[self.data.rank].reward
    if self.model:IsCross() then
        str = Config.db_candyroom_reward[self.data.rank].cross_reward
    end
    local reward_tbl = String2Table(str)
    for i = 1, #reward_tbl do
        local param = {}
        local operate_param = {}
        local cfg = Config.db_item[tonumber(reward_tbl[i][1])]
        param["cfg"] = cfg
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 76, y = 76 }
        if reward_tbl[1] ~= 90010018 then
            param["num"] = reward_tbl[i][2]
        end
        local itemIcon = GoodsIconSettorTwo(self.reward_content)
        itemIcon:SetIcon(param)
        self.reward_list[#self.reward_list + 1] = itemIcon
    end
end

function CandyClosingPanel:LoadEft()
    self.effect_Win = UIEffect(self.eft_con, 10401, false, self.layer)

    self.effect_Win2 = UIEffect(self.eft_con, 10402, false, self.layer)
    self.effect_Win2:SetConfig({ scale = 1.06, pos = { x = 17, y = 6, z = 0 } })
end

function CandyClosingPanel:StopClock()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function CandyClosingPanel:CloseCallBack()
    self:StopClock()
    for i, v in pairs(self.reward_list) do
        if v then
            v:destroy()
        end
    end
    self.reward_list = {}
    if self.effect_Win ~= nil then
        self.effect_Win:destroy()
    end

    if self.effect_Win2 ~= nil then
        self.effect_Win2:destroy()
    end
end



