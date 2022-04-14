-- @Author: lwj
-- @Date:   2019-11-14 21:30:09
-- @Last Modified time: 2019-11-14 21:30:22

DecorateItem = DecorateItem or class("DecorateItem", BaseCloneItem)
local DecorateItem = DecorateItem

function DecorateItem:ctor(parent_node, layer)
    self.maxStar = 5
    self.star_list = {}

    DecorateItem.super.Load(self)
end

function DecorateItem:dctor()
    self.star_list = {}
    if self.update_rd_event then
        self.model:RemoveListener(self.update_rd_event)
        self.update_rd_event = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.click_event_id then
        self.model:RemoveListener(self.click_event_id)
        self.click_event_id = nil
    end
    if self.sel_event_id then
        self.model:RemoveListener(self.sel_event_id)
        self.sel_event_id = nil
    end
    if self.goods then
        self.goods:destroy()
        self.goods = nil
    end
end

function DecorateItem:LoadCallBack()
    self.model = FashionModel.GetInstance()
    self.nodes = {
        "power", "icon_con", "sel_img", "name", "Sundries/Bg", "wearing", "red_con", "unactiva",
        "Star_con/sbg_3/star_3", "Star_con/sbg_5/star_5", "Star_con/sbg_2/star_2", "Star_con/sbg_4/star_4",
        "Star_con/sbg_1/star_1", "Star_con",
    }
    self:GetChildren(self.nodes)
    self:AddStar()
    self.power = GetText(self.power)
    self.name = GetText(self.name)

    self:AddEvent()
end
function DecorateItem:AddStar()
    self.star_list[#self.star_list + 1] = self.star_1
    self.star_list[#self.star_list + 1] = self.star_2
    self.star_list[#self.star_list + 1] = self.star_3
    self.star_list[#self.star_list + 1] = self.star_4
    self.star_list[#self.star_list + 1] = self.star_5
end

function DecorateItem:AddEvent()
    local function callback()
        self.model:Brocast(FashionEvent.DecoItemClick, self.data, self.ser_data)
    end
    AddClickEvent(self.Bg.gameObject, callback)

    local function callback(data)
        if data.conData.type_id ~= self.data.conData.type_id then
            return
        end
        self:Select(data)
    end
    self.click_event_id = self.model:AddListener(FashionEvent.DecoItemClick, callback)
    self.sel_event_id = self.model:AddListener(FashionEvent.SetDefaultSel, handler(self, self.HandleSelDefaut))
    self.update_rd_event = self.model:AddListener(FashionEvent.ChangeItemRedDot, handler(self, self.SetRedDot))
end

function DecorateItem:SetData(data)
    self.data = data
    self.ser_data = FashionModel.GetInstance():GetFashionInfoById(data.conData.id)
    self:UpdateView()
end

function DecorateItem:UpdateView()
    if not self.ser_data then
        --未激活
        self.data.state = 1
    else
        if self.ser_data.star < self.maxStar then
            --未满星
            self.data.state = 2
        else
            --满星
            self.data.state = 3
        end
    end

    local star = self.ser_data and self.ser_data.star or 0
    for i = 1, 5 do
        SetVisible(self.star_list[i], i <= star)
    end

    self.id = self.data.conData.id
    local param = {}
    local operate_param = {}
    param["item_id"] = self.id
    param["operate_param"] = operate_param
    param["size"] = { x = 90, y = 90 }
    param.bind = 2
    if not self.goods then
        self.goods = GoodsIconSettorTwo(self.icon_con)
    end
    self.goods:SetIcon(param)
    self.goods:UpdateRayTarget(false)
    if self.data.state == 1 then
        self.goods:SetIconGray()
    else
        self.goods:SetIconNormal()
        local put_on_id = self.model:GetMenuPutOnIdByMenu(self.data.conData.type_id)
        SetVisible(self.wearing, put_on_id == self.data.conData.id)
    end
    SetVisible(self.unactiva, self.data.state == 1)

    self.name.text = Config.db_item[self.id].name
    self:ShowPower()
    self:SetRedDot(self.data.is_show_red, self.id)
end

function DecorateItem:ShowPower()
    local star = self.ser_data and self.ser_data.star or 0
    local config = Config.db_fashion_star[self.data.conData.id .. "@" .. star]
    local attr = String2Table(config.attrib)
    local power_num = GetPowerByConfigList(attr)
    self.power.text = power_num
    self.data.power = power_num
end

function DecorateItem:Select(data)
    SetVisible(self.sel_img, data.conData.id == self.data.conData.id)
end

function DecorateItem:HandleSelDefaut(id)
    if id ~= self.data.conData.id then
        return
    end
    self.model:Brocast(FashionEvent.DecoItemClick, self.data, self.ser_data)
end

function DecorateItem:SetRedDot(isShow, id)
    if id ~= self.data.conData.id then
        return
    end
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end