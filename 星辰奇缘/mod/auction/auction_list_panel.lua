-- @author 黄耀聪
-- @date 2016年7月22日

AuctionListPanel = AuctionListPanel or BaseClass(BasePanel)

function AuctionListPanel:__init(model, gameObject, selectCallback)
    self.model = model
    self.gameObject = gameObject
    self.selectCallback = selectCallback
    self.name = "AuctionListPanel"
    self.mgr = AuctionManager.Instance

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.itemlist = {}
    self.updatelistener = function(idx) self:UpdateList(idx) end

    self:InitPanel()
end

function AuctionListPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.itemlist ~= nil then
        for _,v in pairs(self.itemlist) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemlist = nil
    end
    self:AssetClearAll()
end

function AuctionListPanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.scroll = t:Find("Scroll"):GetComponent(ScrollRect)
    self.container = t:Find("Scroll/Container")
    self.cloner = t:Find("Scroll/Cloner").gameObject
    self.nothing = t:Find("Scroll/Nothing").gameObject

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, scpacing = 3, border = 2})

    for i=1,14 do
        local obj = GameObject.Instantiate(self.cloner)
        self.itemlist[i] = AuctionListItem.New(self.model, obj, self.selectCallback)
        obj.name = tostring(i)
        self.layout:AddCell(obj)
    end
    self.cloner:SetActive(false)

    self.setting_data = {
       item_list = self.itemlist--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
end

function AuctionListPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function AuctionListPanel:OnOpen()
    self:RemoveListeners()
    self.mgr.onUpdateItem:AddListener(self.updatelistener)
    self.timerId = LuaTimer.Add(1000, 1000, function() self:OnTime() end)

    self.mgr:send16700()

    self:UpdateList()

    if self.selectCallback ~= nil then
        self.selectCallback()
    end
end

function AuctionListPanel:OnHide()
    self:RemoveListeners()

    local model = self.model
    if model.selectIdx ~= nil then
        model.datalist[model.selectIdx].item = nil
        model.selectIdx = nil
    end
end

function AuctionListPanel:RemoveListeners()
    self.mgr.onUpdateItem:RemoveListener(self.updatelistener)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function AuctionListPanel:UpdateList(idx)
    local model = self.model
    if idx == nil then
        local datalist = {}
        for _,v in pairs(self.model.datalist) do
            table.insert(datalist, v)
        end
        table.sort(datalist, function(a,b)
            if a.focus == b.focus then
                if a.over_time == b.over_time then
                    return a.idx < b.idx
                else
                    return a.over_time < b.over_time
                end
            else
                return a.focus > b.focus
            end
        end)
        self.nothing:SetActive(#datalist == 0)
        self.setting_data.data_list = datalist
        BaseUtils.refresh_circular_list(self.setting_data)
    else
        if model.datalist[idx] ~= nil and model.datalist[idx].item ~= nil then
            model.datalist[idx].item:update_my_self(model.datalist[idx])
        end
    end
end

function AuctionListPanel:OnTime()
    for _,v in pairs(self.itemlist) do
        v:OnTime()
    end
end


