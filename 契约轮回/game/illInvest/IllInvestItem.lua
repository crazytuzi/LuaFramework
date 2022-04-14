--- Created by Admin.
--- DateTime: 2019/12/4 14:20

IllInvestItem = IllInvestItem or class("IllInvestItem", BaseCloneItem)
local IllInvestItem = IllInvestItem

function IllInvestItem:ctor(parent_node, layer)
    self.model = IllInvestModel.GetInstance()
    IllInvestItem.super.Load(self)
end

function IllInvestItem:dctor()
    if self.item then
        self.item:destroy()
    end
end

function IllInvestItem:LoadCallBack()
    self.nodes = {
        "Image/day","reward","pos","red"
    }
    self:GetChildren(self.nodes)
    self.dayImg = GetImage(self.day)
    self:AddEvent()
    if self.is_loaded then
        self:UpdateView()
    end
end

function IllInvestItem:AddEvent()

end

function IllInvestItem:SetDate(info, act_id)
    self.info = info
    self.act_id = act_id
    if self.is_loaded then
        self:UpdateView()
    end
end

function IllInvestItem:UpdateView()
    if not self.info then return end

    local idx = self.model:GetInfoData(self.act_id, self.info.day)
    SetVisible(self.reward,idx == 2)
    SetVisible(self.red, idx == 3)

    local function call_back()
        if idx == 3 then
            IllInvestCtr:GetInstance():RequestRewardInvest(self.act_id, self.info.day)
        else
            self.item:ClickEvent();
        end
    end

    local res = "illday_"..self.info.day
    lua_resMgr:SetImageTexture(self, self.dayImg, "sevenDayActive_image", res, true, nil, false)

    local tab = String2Table(self.info.rewards)
	local id 
	local num 
	local bind 
	if type(tab[1]) == "table" then
		id = tab[1][1]
		num = tab[1][2]
		bind = tab[1][3]
	else
		id = tab[1]
		num = tab[2]
		bind = tab[3]
	end

    if self.item == nil then
        self.item = GoodsIconSettorTwo(self.pos)
    end
    local param = {}
   -- param["model"] = self.model
    param["item_id"] = id
    param["num"] = num
    param["bind"] = bind
    param["can_click"] = true
    param["is_showtip"] = true
    param["out_call_back"] = call_back
    self.item:SetIcon(param)

    if idx == 2 then
        self.item:SetIconGray()
    else
        self.item:SetIconNormal()
    end
end


