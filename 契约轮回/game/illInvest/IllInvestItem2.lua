--- Created by Admin.
--- DateTime: 2019/12/4 14:20

IllInvestItem2 = IllInvestItem2 or class("IllInvestItem2", BaseCloneItem)
local IllInvestItem2 = IllInvestItem2

function IllInvestItem2:ctor(parent_node, layer)
    self.model = IllInvestModel.GetInstance()
    IllInvestItem2.super.Load(self)
end

function IllInvestItem2:dctor()
    if self.item then
        self.item:destroy()
    end
end

function IllInvestItem2:LoadCallBack()
    self.nodes = {
        "name","pos","reward",
    }
    self:GetChildren(self.nodes)
    self.nameTex = GetText(self.name)

    self:AddEvent()
    if self.is_loaded then
        self:UpdateView()
    end
end

function IllInvestItem2:AddEvent()

end

function IllInvestItem2:SetDate(info, is_reward)
    self.info = info
    self.is_reward = is_reward
    if self.is_loaded then
        self:UpdateView()
    end
end

function IllInvestItem2:UpdateView()
    if self.info then
        local id
        if type(self.info[1]) == "table" then
            local role = RoleInfoModel.GetInstance():GetMainRoleData()
            local sex = role.gender
            id = self.info[1][sex]
        else
            id = self.info[1]
        end

        local num = self.info[2]
        local bind = self.info[3]
        if self.item == nil then
            self.item = GoodsIconSettorTwo(self.pos)
        end
        local param = {}
       -- param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["bind"] = bind
        param["can_click"] = true
        self.item:SetIcon(param)

        self.nameTex.text = Config.db_item[id].name

        if self.is_reward then
            SetVisible(self.reward.transform, true)
            self.item:SetIconGray()
        else
            SetVisible(self.reward.transform, false)
            self.item:SetIconNormal()
        end
    end
end


