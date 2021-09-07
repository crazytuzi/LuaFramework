FuseManager  = FuseManager or BaseClass(BaseManager)
DoubleFuseType = {
    [3] = true,
    [10] = true,
}
function FuseManager:__init()
    if FuseManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    FuseManager.Instance = self
    self.model = FuseModel.New()
    self.fuseTable = {}
    self.targetData = nil
    self.needItem = {}

    self:InitHandler()
    self:InitTable()
end

function FuseManager:InitHandler()
    self:AddNetHandler(10607, self.On10607)
    self:AddNetHandler(10610, self.On10610)
end

function FuseManager:Require10607(id, num)
    print(string.format("Require10607 %s %s", id, num))
    Connection.Instance:send(10607,{base_id = id, num = num})
end

function FuseManager:On10607(data)
    if data.flag == 1 then
        self.model:ShowEffect()
    end
    self.model:UpdateWindow()
end

function FuseManager:Require10610(id1, id2)
    Connection.Instance:send(10610,{id1 = id1, id2 = id2})
end

function FuseManager:On10610(data)
    if data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("合成成功"))
        self.model:ShowEffect()
        -- print(data.next_base_id)
        -- self.model:ShowFuseItem(data.next_base_id)
        self.needItem = {}
    end
    self.model:UpdateWindow(data.next_base_id)
end

function FuseManager:InitTable()
    for i,v in pairs(DataFuse.data_list) do
        if v.universal == 1 then
            if self.fuseTable[v.type_index] == nil then
                self.fuseTable[v.type_index] = {}
            end
            self.fuseTable[v.type_index][v.sub_type_index] = v
        end
    end
end

function FuseManager:SetTarget(index, sub_index)
    self.targetData = self.fuseTable[index][sub_index]
    self.needItem = {}
end

function FuseManager:SelectNeed(backpack_id, index)
    if self:IsSelected(backpack_id) then
        local index
        for i,v in ipairs(self.needItem) do
            if v == backpack_id then
                index = i
            end
        end
        table.remove(self.needItem, i)
    else
        local num = self.targetData.need_num
        local has = 0
        for k,v in pairs(self.needItem) do
            has = has + 1
        end
        if has == num then
            table.remove(self.needItem, 1)
        end
        table.insert(self.needItem, backpack_id)
    end
    -- self.needItem[index] = backpack_id
    self.model:UpdateWindow()
end

function FuseManager:IsSelected(id)
    for k,v in pairs(self.needItem) do
        if id == v then
            return true
        end
    end
    return false
end

function FuseManager:Commit(all)
    if DoubleFuseType[self.targetData.type_index] then
        if self.needItem[1] ~= nil and self.needItem[2] ~= nil then
          -- print("发送请求")
            local func = function() self:Require10610(self.needItem[1], self.needItem[2]) end
            local item1 = BackpackManager.Instance:GetPreciousItem(self.needItem[1])
            local item2 = BackpackManager.Instance:GetPreciousItem(self.needItem[2])
            local str = ""
            if item1 then
                local data = DataItem.data_get[self.needItem[1]]
                str = ColorHelper.color_item_name(data.quality ,string.format("[%s]", data.name))
            end
            if item2 then
                local data = DataItem.data_get[self.needItem[2]]
                if item1 then
                    str = str .. TI18N("和") .. ColorHelper.color_item_name(data.quality, string.format("[%s]", data.name))
                else
                    str = ColorHelper.color_item_name(data.quality, string.format("[%s]", data.name))
                end
            end
            local confirm_dat = {
                titleTop = TI18N("贵重物品")
                , title = string.format( "%s%s", str, TI18N("十分珍贵，<color='#df3435'>合成后无法找回</color>"))
                , password = TI18N(tostring(math.random(100, 999)))
                , confirm_str = TI18N("确认合成")
                , cancel_str = TI18N("取 消")
                , confirm_callback = func
            }
            if item1 or item2 then 
                TipsManager.Instance.model:OpentwiceConfirmPanel(confirm_dat)
            else
                func()
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要合成的护符"))
        end
    else
        if BackpackManager.Instance:GetItemCount(self.targetData.base_id) < self.targetData.need_num then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("{item_2, %s, 1, 1}不足, 无法操作"), self.targetData.base_id))
            return
        end
        local func = function() 
            if all then
                local hasnum = BackpackManager.Instance:GetItemCount(self.targetData.base_id)
                local canCreat = math.floor(hasnum / self.targetData.need_num)
                self:Require10607(self.targetData.id, canCreat)
            else
                self:Require10607(self.targetData.id, 1)
            end
        end
        local itemVo = DataItem.data_get[self.targetData.base_id]
        local confirm_dat = {
            titleTop = TI18N("贵重物品")
            , title = string.format( "%s%s", ColorHelper.color_item_name(itemVo.quality ,string.format("[%s]", itemVo.name)), TI18N("十分珍贵，<color='#df3435'>合成后无法找回</color>"))
            , password = TI18N(tostring(math.random(100, 999)))
            , confirm_str = TI18N("确认合成")
            , cancel_str = TI18N("取 消")
            , confirm_callback = func
        }
        if BackpackManager.Instance:GetPreciousItem(self.targetData.base_id) then 
            TipsManager.Instance.model:OpentwiceConfirmPanel(confirm_dat)
        else
            func()
        end
    end
end

function FuseManager:OpenByBaseID(base_id)
    local i1 = nil
    local i2 = nil
    local nextId = base_id
    -- local nextData = DataFuse.data_list[base_id]
    -- if nextData ~= nil then
    --     nextId = nextData.next_base_id
    -- end
    for i,v in pairs(DataFuse.data_list) do
        -- if (v.base_id == base_id or v.next_base_id == base_id)  and i1 == nil and i2 == nil then
        if (v.base_id == nextId)  and i1 == nil and i2 == nil then
            i1 = v.type_index
            i2 = v.sub_type_index
        end
    end
    if i1 == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("合成配方不存在噢～"))
    else
        if base_id == 22450 or base_id == 22452 then
            FaceManager.Instance:OpenWindow({i2})
        else
            FuseManager.Instance.model:OpenMain({i1, i2})
        end
        -- self.model:OpenMain({i1, i2})
    end
end
