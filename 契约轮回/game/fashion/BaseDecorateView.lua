-- @Author: lwj
-- @Date:   2019-11-16 14:09:01 
-- @Last Modified time: 2019-11-16 14:09:02

BaseDecorateView = BaseDecorateView or class("BaseDecorateView", BaseItem)
local BaseDecorateView = BaseDecorateView

function BaseDecorateView:ctor(parent_node, layer)
    self.single_line_cout = 3
    self.single_item_height = 231

    self.model_event = {}
    self.star_list = {}
    self.btn_mode = 1
    self.cur_id = 0
    self.cost_tbl = {}
    self.ori_id = 110000
    self.model = FashionModel.GetInstance()
end

function BaseDecorateView:dctor()
    if self.activa_red_dot then
        self.activa_red_dot:destroy()
        self.activa_red_dot = nil
    end
    if self.cost_icon then
        self.cost_icon:destroy()
        self.cost_icon = nil
    end
    if not table.isempty(self.attr_item_list) then
        for i, v in pairs(self.attr_item_list) do
            if v then
                v:destroy()
            end
        end
        self.attr_item_list = {}
    end
    self.star_list = {}
    if not table.isempty(self.item_list) then
        for i, v in pairs(self.item_list) do
            if v then
                v:destroy()
            end
        end
        self.item_list = {}
    end
    if not table.isempty(self.pillar_item_list) then
        for i, v in pairs(self.pillar_item_list) do
            if v then
                v:destroy()
            end
        end
        self.pillar_item_list = {}
    end
    if not table.isempty(self.model_event) then
        for i, v in pairs(self.model_event) do
            self.model:RemoveListener(v)
        end
        self.model_event = {}
    end
end

function BaseDecorateView:LoadCallBack()
    self.nodes = {
        "Left_Scro/Viewport/Content/real_con/item_con/DecorateItem", "Left_Scro/Viewport/Content/real_con/pillar_con",
        "Left_Scro/Viewport/Content/real_con/pillar_con/PillarItem",
        "Left_Scro/Viewport/Content/real_con", "Left_Scro/Viewport/Content/real_con/item_con",
        "Right/way", "Right/full_star", "Right/Star_con", "Right/btn_dress_up",
        "Right/Star_con/sbg_3/star_3", "Right/Star_con/sbg_5/star_5", "Right/icon_con", "Right/btn_activate", "Right/name", "Right/icon", "Right/btn_activate/btn_text", "Right/attr_con", "Right/power", "Right/Star_con/sbg_2/star_2", "Right/Star_con/sbg_4/star_4", "Right/attr_con/DecorateAttrItem", "Right/Star_con/sbg_1/star_1",
        "Right/btn_dress_up/dress_up_text",
        "Right/btn_activate/red_con",
    }
    self:GetChildren(self.nodes)
    self:AddStar()
    self.real_con_rect = GetRectTransform(self.real_con)
    self.item_rect = GetRectTransform(self.item_con)
    self.pillar_rect = GetRectTransform(self.pillar_con)
    self.item_obj = self.DecorateItem.gameObject
    self.pillar_obj = self.PillarItem.gameObject
    self.attr_obj = self.DecorateAttrItem.gameObject

    self.icon = GetImage(self.icon)

    self.power = GetText(self.power)
    self.name = GetText(self.name)
    self.way = GetText(self.way)
    self.btn_img = GetImage(self.btn_activate)
    self.btn_text = GetText(self.btn_text)
    self.dress_up_text = GetText(self.dress_up_text)

    self:AddEvent()
    self:InitPanel()
end
function BaseDecorateView:AddStar()
    self.star_list[#self.star_list + 1] = self.star_1
    self.star_list[#self.star_list + 1] = self.star_2
    self.star_list[#self.star_list + 1] = self.star_3
    self.star_list[#self.star_list + 1] = self.star_4
    self.star_list[#self.star_list + 1] = self.star_5
end

function BaseDecorateView:AddEvent()
    local function callback()
        if not self.model.is_can_click_activa then
            return
        end
        self.model.is_can_click_activa = false
        self.model.isCanShowTips = true
        if self.btn_mode == 1 then
            local is_enough = self:CheckIsEnoughCost()
            if not is_enough then
                Notify.ShowText(ConfigLanguage.Fashion.MaterialNotEnouth)
                self.model.is_can_click_activa = true
                return
            end
            self.model.is_activa = true
            self.model:SetNormalBtnMode(0)
            self.model:Brocast(FashionEvent.ActivateFashion, self.cur_id)
        elseif self.btn_mode == 2 then
            local is_enough = self:CheckIsEnoughCost()
            if not is_enough then
                Notify.ShowText(ConfigLanguage.Fashion.MaterialNotEnouth)
                self.model.is_can_click_activa = true
                return
            end
            self.model:SetNormalBtnMode(1)
            self.model:Brocast(FashionEvent.UpStarFashion, self.cur_id)
        else
            Notify.ShowText(ConfigLanguage.Fashion.AlreadyFullStar)
        end
        self.model.is_need_update_role_icon = true
    end
    AddButtonEvent(self.btn_activate.gameObject, callback)

    -----卸下
    local function callback()
        --1::卸下     2::穿戴
        --local dress_str = put_on_id == data.conData.id and "卸下" or "幻化"
        if not self.model.is_can_click_dress then
            return
        end
        self.model.is_can_click_dress = false
        local put_id = self.dress_btn_mode == 1 and self.ori_id or self.cur_id
        local mode = self.dress_btn_mode == 1 and 1 or 2
        self.model:SetNormalBtnMode(mode)
        self.model.cur_deco_type = self.index
        self.model:Brocast(FashionEvent.PutOnFashion, put_id)
        self.model.isCanShowTips = true
        self.model.is_need_update_role_icon = true
    end
    AddButtonEvent(self.btn_dress_up.gameObject, callback)

    self.model_event = self.model_event or {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.DecoItemClick, handler(self, self.HandleDecoItemClick))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.UpdatePanel, handler(self, self.HandleUpdatePanel))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.ChangePanelRedDot, handler(self, self.SetActivaRD))
end

function BaseDecorateView:InitPanel()
    self:InitLeft()
end

function BaseDecorateView:HandleUpdatePanel()
    --事件规避
    if self.index ~= self.model.openning_index then
        return
    end
    local list = self.model:GetCueShowList(self.index)
    local dataList = {}
    for i = 1, #list do
        local itemData = {}
        if type(list[i]) == "table" then
            itemData.conData = Config.db_fashion[list[i][1] .. "@" .. self.index]
        else
            itemData.conData = Config.db_fashion[list[i] .. "@" .. self.index]
        end
        dataList[i] = itemData
    end
    self:LoadLeftItem(dataList)
    if self.model.is_activa then
        self.model:SetDefaultSel(self.index, dataList[1].conData.id)
        self.model.is_activa = false
    else
        local data, ser_data = self:GetData()
        self:UpdateStar(data, ser_data)
        self:UpdateBottom(data, ser_data)
        self:LoadAttr(data, ser_data)
    end
end

function BaseDecorateView:GetData()
    local list = self.item_list
    local data = {}
    local ser_data = {}
    for i, v in pairs(list) do
        if v then
            if v.data.conData.id == self.model.curItemId then
                data = v.data
                ser_data = v.ser_data
                break
            end
        end
    end
    return data, ser_data
end

function BaseDecorateView:InitLeft()
    local index = self.index
    local list = self.model:GetCueShowList(self.index)
    local dataList = {}
    local itemData = {}
    for i = 1, #list do
        itemData = {}
        if type(list[i]) == "table" then
            itemData.conData = Config.db_fashion[list[i][1] .. "@" .. index]
        else
            itemData.conData = Config.db_fashion[list[i] .. "@" .. index]
        end
        dataList[i] = itemData
    end
    local line_count
    local num = #dataList
    if num <= self.single_line_cout then
        line_count = 1
    else
        --整除数
        local rest = num % self.single_line_cout
        local full_num = num - rest
        line_count = full_num / self.single_line_cout
        --多余行数
        if rest > 0 then
            line_count = line_count + 1
        end
    end

    local big_item_height = self.single_item_height * line_count
    SetSizeDelta(self.real_con_rect, 528, big_item_height)

    self:LoadLeftItem(dataList)
    self:LoadPillar(line_count)
    SetAnchoredPosition(self.item_rect, 0, 0)
    SetAnchoredPosition(self.pillar_rect, 0, 0)
    self.model:SetDefaultSel(self.index, dataList[1].conData.id)
end

function BaseDecorateView:LoadLeftItem(list)
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = DecorateItem(self.item_obj, self.item_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].cl_name = self.__cname
        list[i].is_show_red = self.model:CheckIsShowItemRedDot(self.index, list[i].conData.id)
        item:SetData(list[i])
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function BaseDecorateView:LoadPillar(num)
    self.pillar_item_list = self.pillar_item_list or {}
    local cur_y = -5
    local len = num
    for i = 1, len do
        local item = self.pillar_item_list[i]
        if not item then
            item = PillarItem(self.pillar_obj, self.pillar_con)
            self.pillar_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(cur_y)
        cur_y = cur_y - self.single_item_height
    end
    for i = len + 1, #self.pillar_item_list do
        local item = self.pillar_item_list[i]
        item:SetVisible(false)
    end
end

function BaseDecorateView:HandleDecoItemClick(data, ser_data)
    if data.cl_name ~= self.__cname then
        return
    end
    local id = data.conData.id
    self.model.curItemId = id
    if self.index == 12 then
        self.model.cur_chat_id = id
    else
        self.model.cur_icon_id = id
    end
    self.cur_id = id
    lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_chatFrame", id, true, nil, false)
    if self.index == 11 then
        local show_cf = FrameShowConfig.IconFrame[id]
        local scale = show_cf.scale or 1
        SetLocalScale(self.icon.transform, scale, scale, scale)
    end
    local item_cf = Config.db_item[id]
    if not item_cf then
        logError("BaseDecorateView: 物品表没有id为 ", id, "  的配置")
        return
    end
    self.name.text = item_cf.name
    self:UpdateStar(data, ser_data)
    self.way.text = item_cf.guide

    self:LoadAttr(data, ser_data)
    self:UpdateBottom(data, ser_data)
end

function BaseDecorateView:UpdateStar(data, ser_data)
    local star = ser_data and ser_data.star or 0
    for i = 1, 5 do
        SetVisible(self.star_list[i], i <= star)
    end
    SetVisible(self.full_star, data.state == 3)
    self.power.text = data.power
end

function BaseDecorateView:LoadAttr(data, ser_data)
    local star = ser_data and ser_data.star or 0
    local key = data.conData.id .. "@" .. star
    local star_cf = Config.db_fashion_star[key]
    if not star_cf then
        return
    end
    local list = String2Table(star_cf.attrib)

    self.attr_item_list = self.attr_item_list or {}
    local len = #list
    for i = 1, len do
        local tbl = list[i]
        local info = {}
        info.title = GetAttrNameByIndex(tbl[1])
        if string.utf8len(info.title) == 2 then
            info.title = table.concat(string.utf8list(info.title), "      ")
        end
        info.title = info.title .. ":"
        if data.state == 1 then
            --未激活
            info.cur = tbl[2]
            local next_tbl = String2Table(Config.db_fashion_star[data.conData.id .. "@" .. 0].attrib)
            info.next = next_tbl[i][2]
        elseif data.state == 2 then
            --已激活
            info.cur = tbl[2]
            local next_tbl = String2Table(Config.db_fashion_star[data.conData.id .. "@" .. star + 1].attrib)
            info.next = next_tbl[i][2]
        else
            --满星
            info.cur = tbl[2]
        end

        local item = self.attr_item_list[i]
        if not item then
            item = DecorateAttrItem(self.attr_obj, self.attr_con)
            self.attr_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(info)
    end
    for i = len + 1, #self.attr_item_list do
        local item = self.attr_item_list[i]
        item:SetVisible(false)
    end
end

function BaseDecorateView:UpdateBottom(data, ser_data)
    local key = data.conData.id .. "@" .. self.index
    local cf = {}
    self.btn_mode = data.state
    if data.state == 1 then
        --激活
        self.btn_text.text = ConfigLanguage.Fashion.ActicateFashion
        self.btn_img.raycastTarget = true;
        cf = Config.db_fashion[key]
    elseif data.state == 2 then
        self.btn_img.raycastTarget = true;
        self.btn_text.text = ConfigLanguage.Fashion.UpStar
        local next = ser_data.star + 1
        key = data.conData.id .. "@" .. next
        cf = Config.db_fashion_star[key]
    else
        self.btn_img.raycastTarget = false;
        self.btn_text.text = ConfigLanguage.Fashion.UpStar
        key = data.conData.id .. "@" .. ser_data.star
        cf = Config.db_fashion_star[key]
    end
    SetVisible(self.btn_dress_up, data.state ~= 1)
    local put_on_id = self.model:GetMenuPutOnIdByMenu(data.conData.type_id)
    --当前穿戴的
    self.dress_btn_mode = put_on_id == data.conData.id and 1 or 2
    local dress_str = put_on_id == data.conData.id and "Remove" or "Morph"
    self.dress_up_text.text = dress_str
    if not cf then
        logError("BaseDecorateView: 没有key值为 ", key, " 的升星配置")
        return
    end

    self.cost_tbl = String2Table(cf.cost)
    local is_enough, num, need_num = self:CheckIsEnoughCost()
    local numStr = "<color=#ffea00>" .. num .. "/" .. need_num .. "</color>"
    if not is_enough then
        --不够
        numStr = "<color=#FF0000>" .. num .. "/" .. need_num .. "</color>"
    end
    if not self.cost_icon then
        self.cost_icon = GoodsIconSettorTwo(self.icon_con)
    end
    local param = {}
    param["item_id"] = self.cost_tbl[1]
    param["num"] = numStr
    param["size"] = { x = 70, y = 70 }
    param["can_click"] = true
    param["bind"] = 2
    self.cost_icon:SetIcon(param)
    self:SetActivaRD(data.is_show_red, self.model.cur_deco_type)
end

function BaseDecorateView:CheckIsEnoughCost()
    local num = BagModel.GetInstance():GetItemNumByItemID(self.cost_tbl[1])
    local need_num = self.cost_tbl[2]
    local result = true
    if num < need_num then
        result = false
    end
    return result, num, need_num
end

function BaseDecorateView:SetActivaRD(isShow, idx)
    if idx ~= 11 and idx ~= 12 then
        return
    end
    if not self.activa_red_dot then
        self.activa_red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.activa_red_dot:SetPosition(0, 0)
    self.activa_red_dot:SetRedDotParam(isShow)
end
