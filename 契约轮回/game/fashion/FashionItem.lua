-- @Author: lwj
-- @Date:   2018-12-26 16:20:05
-- @Last Modified time: 2019-05-21 21:49:03

FashionItem = FashionItem or class("FashionItem", BaseItem)
local FashionItem = FashionItem

function FashionItem:ctor(parent_node, layer)
    self.abName = "fashion"
    self.assetName = "FashionItem"
    self.layer = layer

    self.model = FashionModel:GetInstance()
    self.modelEventList = {}
    BaseItem.Load(self)
end

function FashionItem:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.modelEventList then
        for i, v in pairs(self.modelEventList) do
            self.model:RemoveListener(v)
        end
        self.modelEventList = {}
    end

    self.starList = {}
    self:DestroyGoodsIcon()
end

function FashionItem:DestroyGoodsIcon()
    if self.item then
        self.item:destroy()
        self.item = nil
    end
end

function FashionItem:LoadCallBack()
    self.nodes = {
        "select", "bg", "puton", "icon", "name",
        "unavailable",
        "stars/sbg_3/star3", "stars/sbg_2/star2", "stars/sbg_5/star5", "stars/sbg_4/star4", "stars/sbg_1/star1",
        "stars",
    }
    self:GetChildren(self.nodes)
    self.sel_img = self.select:GetComponent('Image')
    self.nameT = self.name:GetComponent('Text')
    self:AddEvent()
    self:AddStars()
    self:UpdateView()
end

function FashionItem:AddEvent()
    local function call_back()
        self.model.curItemId = self.data.conData.id
        self.model:Brocast(FashionEvent.FashionItemClick, self.data.conData, self.fashionItem, self.data.is_show_red)
    end
    AddClickEvent(self.bg.gameObject, call_back)

    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.FashionItemClick, handler(self, self.Select))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.UpdatePuttOn, handler(self, self.UpdatePutOn))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(FashionEvent.ChangeItemRedDot, handler(self, self.SetRedDot))
end

function FashionItem:AddStars()
    self.starList = {}
    table.insert(self.starList, self.star1)
    table.insert(self.starList, self.star2)
    table.insert(self.starList, self.star3)
    table.insert(self.starList, self.star4)
    table.insert(self.starList, self.star5)
end

function FashionItem:SetData(data)
    if data then
        self.data = data
    else
        self.data = self.data
    end
    if self.is_loaded then
        self:UpdateView()
    end
end

function FashionItem:UpdateView()
    --self.Text:GetComponent('Text').text = self.data[2]
    self.id = self.data.conData.id
    self:DestroyGoodsIcon()
    self.item = GoodsIconSettorTwo(self.icon)
    local param = {}
    param["model"] = self.model
    param["item_id"] = self.id
    param["size"] = { x = 60, y = 60 }
    param['bind'] = 2
    self.item:SetIcon(param)
    --self.item:UpdateIconByItemIdClick(self.id, nil, { x = 78, y = 78 })
    self.nameT.text = Config.db_item[self.id].name
    self.fashionItem = self.model:GetFashionItemById(self.id)
    if self.fashionItem then
        self:SetAvailible()
        if self.data.conData.max_star == 0 then
            SetVisible(self.stars, false)
        else
            SetVisible(self.stars, true)
            for i = 1, #self.starList do
                SetVisible(self.starList[i], i <= self.fashionItem.star)
            end
        end
    else
        self:SetUnAvailible()
    end

    local is_defa = false
    if self.model.side_index and self.model.default_sel_id and self.model.side_index ~= 4 and self.data.conData.id == self.model.default_sel_id then
        is_defa = true
    elseif self.model.default_sel_id == nil and self.data.conData.index == 1 then
        is_defa = true
    end
    if is_defa then
        self.model.curItemId = self.data.conData.id
        self:Select(self.data.conData)
        self.model:Brocast(FashionEvent.FashionItemClick, self.data.conData, self.fashionItem, self.data.is_show_red, true)

        --清除默認選中
        self.model.default_sel_id = nil
    end
    self:UpdatePutOn()
    self:SetRedDot(self.data.is_show_red, self.id)
end

function FashionItem:SetUnAvailible()
    SetVisible(self.stars, false)
    SetVisible(self.unavailable, true)
    self.item:SetIconGray()
end

function FashionItem:SetAvailible()
    SetVisible(self.stars, true)
    SetVisible(self.unavailable, false)
    self.item:SetIconNormal()
end

function FashionItem:Select(conData)
    SetVisible(self.sel_img, conData.id == self.data.conData.id)
end

function FashionItem:UpdatePutOn()
    local cur_put_on = self.model:GetCurMenuPutOnId() or 0
    SetVisible(self.puton, cur_put_on == self.data.conData.id)
end

function FashionItem:SetRedDot(isShow, id)
    if id ~= self.id then
        return
    end
    if not self.red_dot then
        self.red_dot = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.red_dot:SetPosition(-102, 29)
    end
    self.data.is_show_red = isShow
    self.red_dot:SetRedDotParam(isShow)
end
