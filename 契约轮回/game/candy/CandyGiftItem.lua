-- @Author: lwj
-- @Date:   2019-02-23 15:39:40
-- @Last Modified time: 2019-02-23 15:39:43

CandyGiftItem = CandyGiftItem or class("CandyGiftItem", BaseCloneItem)
local CandyGiftItem = CandyGiftItem

function CandyGiftItem:ctor(parent_node, layer)
    CandyGiftItem.super.Load(self)

end

function CandyGiftItem:dctor()
    if self.click_event_id then
        self.model:RemoveListener(self.click_event_id)
    end
    self.click_event_id = nil
end

function CandyGiftItem:LoadCallBack()
    self.model = CandyModel.GetInstance()
    self.nodes = {
        "bg", "sel_img", "icon", "name", "Des_bg/des",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.name = GetText(self.name)
    self.des = GetText(self.des)

    self:AddEvent()
end

function CandyGiftItem:AddEvent()
    local function callback()
        self.model.cur_sel_gift = self.data.id
        self.model:Brocast(CandyEvent.SelectCandyGift, self.data.id)
    end
    AddClickEvent(self.bg.gameObject, callback)
    self.click_event_id = self.model:AddListener(CandyEvent.SelectCandyGift, handler(self, self.Select))
end

function CandyGiftItem:CheckSelectDefault()
    if self.data.id == 1 then
        self.model.cur_sel_gift = self.data.id
        self.model:Brocast(CandyEvent.SelectCandyGift, self.data.id)
    end
end

function CandyGiftItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function CandyGiftItem:UpdateView()
    self:CheckSelectDefault()
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_candy", "Candy_Gift_icon_" .. self.data.id, false, nil, false)
    self.name.text = self.data.name
    self.des.text = string.format(ConfigLanguage.Candy.PopPlusShowDes, self.data.pop)
end
function CandyGiftItem:Select(id)
    SetVisible(self.sel_img, self.data.id == id)
end


