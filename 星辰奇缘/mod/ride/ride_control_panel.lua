RideControlPanel  =  RideControlPanel or BaseClass(BasePanel)

function RideControlPanel:__init(parent)
    self.name  =  "RideControlPanel"
    self.parent = parent
    self.model  =  parent.model

    self.resList  =  {
        {file  =  AssetConfig.ridewindow_control_panel, type  =  AssetType.Main}
    }

    self.is_open  =  false

    self.top_item_list = nil
    self.bottom_item_list = nil
    self.last_select_ride_id = nil

    self.update_ride_info = function()
        self:update_info()
    end

    self.OnOpenEvent:Add(function() self:update_info() end)

    return self
end


function RideControlPanel:__delete()
    RideManager.Instance.OnUpdateRide:Remove(self.update_ride_info)

    self.last_select_ride_id = nil

    if self.top_item_list ~= nil then
        for i=1,#self.top_item_list do
            local item = self.top_item_list[i]
            item:Release()
        end
    end
    if self.bottom_item_list ~= nil then
        for i=1,#self.bottom_item_list do
            local item = self.bottom_item_list[i]
            item:Release()
        end
    end
    self.top_item_list = nil
    self.bottom_item_list = nil

    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function RideControlPanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow_control_panel))
    self.gameObject.name = "RideControlPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localPosition = Vector3(125, -8, 0)
    self.transform.localScale = Vector3(1, 1, 1)


    self.Mask = self.transform:FindChild("Mask")
    self.ScrollCon = self.Mask:FindChild("ScrollCon")
    self.Container = self.ScrollCon:FindChild("Container")
    self.ControledCon = self.Container:FindChild("ControledCon")
    self.TxtUnSelected = self.ControledCon:FindChild("TxtUnSelected")
    self.Top_ItemCon = self.ControledCon:FindChild("ItemCon")
    self.Top_Item = self.Top_ItemCon:FindChild("Item").gameObject

    self.UnControledCon = self.Container:FindChild("UnControledCon")
    self.Bottom_ItemCon = self.UnControledCon:FindChild("ItemCon")
    self.Bottom_Item = self.Bottom_ItemCon:FindChild("Item").gameObject


    RideManager.Instance.OnUpdateRide:Add(self.update_ride_info)


    self:update_info()
end

-------------------------更新逻辑
--左边坐骑列表选择更新
function RideControlPanel:update()
    self.last_select_ride_id = self.model.cur_ridedata.mount_base_id
    self:update_info()
end


--主更新乳沟
function RideControlPanel:update_info()

    --如果上次没有选中坐骑，则选择第一只坐骑进来，如果有选中，则选择上次选中的坐骑
    if self.last_select_ride_id == nil then
        self.last_select_ride_id = self.model.ride_mount
        if self.last_select_ride_id == 0 then
            --在坐骑列表中找到一个已经获得且激活的坐骑
            for key,value in pairs(self.model.ridelist) do
                if value.live_status == 2 then
                    self.last_select_ride_id = value.mount_base_id
                    break
                end
            end
        end
    end

    local rideData = self.model:get_ride_data_by_id(self.last_select_ride_id)
    self.cur_ride_data = rideData
    self.top_data_list = rideData.manger_pets

    self.bottom_data_list = self.model:get_uncontrol_pet_list()

    self:adjust_con()
    self:update_top_list()
    self:update_bottom_list()
end


--更新顶部管制列表列表
function RideControlPanel:update_top_list()
    if self.top_item_list == nil then
        self.top_item_list = {}
    else
        for i=1,#self.top_item_list do
            local item = self.top_item_list[i]
            item.gameObject:SetActive(false)
        end
    end

    for i=1,#self.top_data_list do
        local item = self.top_item_list[i]
        if item == nil then
            item = RideControlItem.New(self, self.Top_Item, i)
            table.insert(self.top_item_list, item)
        end

        -- print("---------------------------------")
        print(self.top_data_list[i].pet_id)
        -- BaseUtils.dump(self.top_data_list[i])



        item:set_item_data(self.top_data_list[i].pet_id, self.cur_ride_data, 1)
        item.gameObject:SetActive(true)
    end
end

--更新底部非管制列表
function RideControlPanel:update_bottom_list()
    if self.bottom_item_list == nil then
        self.bottom_item_list = {}
    else
        for i=1,#self.bottom_item_list do
            local item = self.bottom_item_list[i]
            item.gameObject:SetActive(false)
        end
    end

    for i=1,#self.bottom_data_list do
        local item = self.bottom_item_list[i]
        if item == nil then
            item = RideControlItem.New(self, self.Bottom_Item, i)
            table.insert(self.bottom_item_list, item)
        end
        item:set_item_data(self.bottom_data_list[i], self.cur_ride_data, 2)
        item.gameObject:SetActive(true)
    end
end

-------------------------容器内容自适应计算
--自适应计算总入口
function RideControlPanel:adjust_con()
    local top_height = self:adjust_top_con()
    local bottom_height = self:adjust_bottom_con()
    self.UnControledCon:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0-top_height)
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(499, top_height+bottom_height)
end

--自适应顶部
function RideControlPanel:adjust_top_con()
    self.TxtUnSelected.gameObject:SetActive(false)
    if #self.top_data_list == 0 then
        self.TxtUnSelected.gameObject:SetActive(true)
    end
    local new_h = self:count_item_height(#self.top_data_list)
    self.Top_ItemCon:GetComponent(RectTransform).sizeDelta = Vector2(479, new_h)
    local con_height = new_h > 0 and 50+new_h or 150+new_h
    self.ControledCon:GetComponent(RectTransform).sizeDelta = Vector2(499, con_height)
    return con_height
end

--自适应底部
function RideControlPanel:adjust_bottom_con()
    local new_h = self:count_item_height(#self.bottom_data_list)
    self.Bottom_ItemCon:GetComponent(RectTransform).sizeDelta = Vector2(479, new_h)
    self.UnControledCon:GetComponent(RectTransform).sizeDelta = Vector2(499, 50+new_h)
    return 50+new_h
end

--计算高度
function RideControlPanel:count_item_height(len)
    local row_num = 0
    if len%2 == 0 then
        row_num = len/2
    else
        row_num = math.floor(len/2) + 1
    end
    local new_h = 100+87*(row_num - 1)
    return new_h
end