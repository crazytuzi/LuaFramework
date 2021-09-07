DynamicScrollList = DynamicScrollList or BaseClass()

-- setting :
--     MaskScroll : 遮罩滚动控件transform
--     ListCon : 列表容器transform
--     ObjList : Item对象列表（必须有Update方法用于更新自己return 自己的高度, GetHeight方法获取对象高度）
DynamicScrollList.GetObjType = {
    Top = 0,
    Bot = 1,
}
function DynamicScrollList:__init(setting)
    if setting.MaskScroll == nil then
        Debug.LogError("动态滚动列表ScrollRect为空")
    end
    self.MaskScroll = setting.MaskScroll
    if setting.ListCon == nil then
        Debug.LogError("动态滚动列表列表容器为空")
    end
    self.ListCon = setting.ListCon
    if setting.ObjList == nil then
        Debug.LogError("动态滚动列表对象列表为空")
    end
    self.ObjList = setting.ObjList
    self.MaskScroll:GetComponent(ScrollRect).onValueChanged:AddListener(function()
        self:OnValueChange()
    end)
    self.defaultHeight = self.ObjList[1].transform.sizeDelta.y
    self.item_height = {}
    self.First_index = 1
    self.Last_index = 1
    self.topObj = nil
    self.botObj = nil
    self.lastcheck_val = 0
end

function DynamicScrollList:OnValueChange()
    if self.data_list == nil or #self.data_list == 0 then
        return
    end
    if self.lastcheck_val - self.ListCon.anchoredPosition.y > 5 then
        self.lastcheck_val = self.ListCon.anchoredPosition.y
    else
        return
    end
    local topval = -self.ListCon.anchoredPosition.y
    local botval = topval - self.MaskScroll.sizeDelta.y
    if self.topObj ~= nil and self.topObj.transform.anchoredPosition.y+5 < topval + self.topObj:GetHeight() and self.First_index > 1 then
        self.First_index = self.First_index - 1

    end
    if self.botObj ~= nil and self.botObj.transform.anchoredPosition.y-5 < botval and self.Last_index < #self.data_list then
        self.Last_index = self.Last_index - 1

    end
end

function DynamicScrollList:GetObj(type)
    if type == DynamicScrollList.GetObjType.Bot then
        self.Last_index = self.Last_index - 1
        for k,v in pairs(self.ObjList) do
            if v.index == self.Last_index then
                self.botObj = v
                break
            end
        end
    else
        self.First_index = self.First_index + 1
        for k,v in pairs(self.ObjList) do
            if v.index == self.First_index then
                self.topObj = v
                break
            end
        end
    end
end

function DynamicScrollList:Update_Height()
    local height = #self.data_list * self.defaultHeight
    for k,v in pairs(self.item_height) do
        height = height + v - self.defaultHeight
    end
    self.ListCon.sizeDelta = Vector2(self.ListCon.sizeDelta, height)
end

function DynamicScrollList:RefreshData(data)
    self.data_list = data
    if #self.data_list < #self.ObjList then
        self.First_index = 1
        self.Last_index = #self.data_list
    elseif self.Last_index > #self.data_list then
        self.First_index = #self.data_list - #self.ObjList
        self.Last_index = #self.data_list
    end
end