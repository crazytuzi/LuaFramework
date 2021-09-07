-- ----------------------------------------------------------
-- UI - 坐骑窗口 头像栏
-- @ljh 2016.5.24
-- ----------------------------------------------------------
RideView_HeadBar = RideView_HeadBar or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function RideView_HeadBar:__init(parent)
	self.parent = parent
    self.model = parent.model
    -- self.model = PetManager.Instance.model
    self.name = "RideView_HeadBar"
    self.resList = {
        {file = AssetConfig.ridewindow_headbar, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.ride_texture, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
        , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.is_show = false

    self.container = nil
    self.headobject = nil
    self.scrollrect = nil

    self.headlist = {}
    self.ridedata = nil

    self.isshow = false
    self.ridenum_max = 0
    self.updateridehead_mark = false

    ------------------------------------------------
    self._updateridehead = function() self:updateridehead(true) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RideView_HeadBar:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow_headbar))
    self.gameObject.name = "RideView_HeadBar"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    self.container = self.transform:FindChild("HeadBar/mask/HeadContainer").gameObject
    self.headobject = self.container.transform:FindChild("Head").gameObject

    self.scrollrect = self.transform:FindChild("HeadBar/mask"):GetComponent(ScrollRect)

    -- for k,v in pairs(DataPet.data_add_ride_nums) do
    --     if v.ride_nums > self.ridenum_max then
    --         self.ridenum_max = v.ride_nums
    --     end
    -- end

    ----------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function RideView_HeadBar:__delete()
    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RideView_HeadBar:OnShow()
	if self.is_show == false then
		self:addevents()
        self:updateridehead()
	end
	self.is_show = true

    if self.parent.openArgs ~= nil and #self.parent.openArgs > 2 then
        self:selectRideByIndex(self.parent.openArgs[3])
    end
end

function RideView_HeadBar:OnHide()
	self.is_show = false
    self:removeevents()
end

function RideView_HeadBar:addevents()
    RideManager.Instance.OnUpdateRide:Add(self._updateridehead)
    RideManager.Instance.OnUpdateOneRide:Add(self._updateridehead)
end

function RideView_HeadBar:removeevents()
    RideManager.Instance.OnUpdateRide:Remove(self._updateridehead)
    RideManager.Instance.OnUpdateOneRide:Remove(self._updateridehead)
end


function RideView_HeadBar:updateridehead(eventFlag)
    if self.init == false then
        return
    end
    local ridelist = self.model.ridelist
    local headnum = self.model.ride_nums
    local headlist = self.headlist
    local headobject = self.headobject
    local container = self.container
    local data

    local selectBtn = nil

    local myRideList = {}

        for k,v in pairs(ridelist) do
            if self.parent.currentIndex == 2 or self.parent.currentIndex == 3 or self.parent.currentIndex == 4 then
                if DataMount.data_ride_new_data[v.base.base_id] == nil then
                    table.insert(myRideList,v)
                end
            else
                table.insert(myRideList,v)
            end
        end



    for i = 1, #myRideList do
        data = myRideList[i]
        local headitem = headlist[i]

        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[i] = item
            headitem = item
        end
        headitem.gameObject:SetActive(true)
        if data ~= nil then
            headitem.name = tostring(i)

            -- local ride_name = data.base.name
            -- if data.transformation_id ~= nil and data.transformation_id ~= 0 then
            --     ride_name = DataMount.data_ride_data[data.transformation_id].name
            -- end
            -- headitem.transform:FindChild("NameText"):GetComponent(Text).text = ride_name

            -- local lvText = string.format("等级：%s", data.lev)
            -- if data.live_status == 0 then
            --     lvText = "未激活"
            --     headitem.transform:FindChild("NameText"):GetComponent(Text).text = "<color='#78b2ee'>坐骑蛋</color>"
            -- elseif data.live_status == 1 or data.live_status == 2 then
            --     lvText = "已激活"
            --     headitem.transform:FindChild("NameText"):GetComponent(Text).text = "<color='#18db66'>坐骑蛋</color>"
            -- end
            -- headitem.transform:FindChild("LVText"):GetComponent(Text).text = lvText

            self:updateNameColor(data, headitem)

            headitem.transform:FindChild("Using").gameObject:SetActive(data.index == self.model.ride_mount)
            -- headitem.transform:FindChild("Possess").gameObject:SetActive(data.possess_pos > 0)
            local headId = tostring(data.base.head_id)
            -- if data.transformation_id ~= nil and data.transformation_id ~= 0 then
            --     headId = tostring(DataMount.data_ride_data[data.transformation_id].head_id)
            -- end
            if data.live_status ~= 3 then
                headId = 0
            end

            local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
            headImage.sprite = self.assetWrapper:GetSprite(AssetConfig.headride, headId)
            -- headImage:SetNativeSize()
            headImage.rectTransform.sizeDelta = Vector2(54, 54)
            -- headImage.gameObject:SetActive(true)

            -- local headbg = self.model:get_rideheadbg(data)
            -- headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
            --     = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

            local button = headitem:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:onheaditemclick(headitem) end)

            headitem.transform:FindChild("AddIcom").gameObject:SetActive(false)
            if self.ridedata ~= nil and self.ridedata.index == data.index then selectBtn = headitem end
        else
            headitem.name = "0"
            local button = headitem:GetComponent(Button)
            headitem.transform:FindChild("AddIcom").gameObject:SetActive(true)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:onheaditemclick(headitem) end)
            headitem.transform:FindChild("Head_78/Head").gameObject:SetActive(false)
        end
    end

    --如果事件驱动，不跑
    if not eventFlag then  
        if #myRideList > 0 then
            if selectBtn == nil then
                self:onheaditemclick(headlist[1])
            else
                self:onheaditemclick(selectBtn)
            end
        end
    end

    if #self.headlist > #myRideList then
        for i=#myRideList + 1,#self.headlist do
            self.headlist[i].gameObject:SetActive(false)
            print(self.headlist[i].gameObject.name)
        end
    end

end

function RideView_HeadBar:updateNameColor(data, headitem, isselect)
    if data == nil then
        headitem.transform:FindChild("NameText").gameObject:SetActive(false)
        headitem.transform:FindChild("LVText").gameObject:SetActive(false)
        headitem.transform:FindChild("LVText").gameObject:SetActive(false)
        return
    end
    local ride_name = data.base.name
    -- if data.transformation_id ~= nil and data.transformation_id ~= 0 then
    --     ride_name = DataMount.data_ride_data[data.transformation_id].name
    -- end

    if isselect then
        if data.live_status == 0 then
            headitem.transform:FindChild("NameText"):GetComponent(Text).text = TI18N(data.base.name)
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("未激活")
        elseif data.live_status == 1 or data.live_status == 2 then
            headitem.transform:FindChild("NameText"):GetComponent(Text).text = TI18N(data.base.name)
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("孵化中"))
        else
            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ride_name
            if self.model.cur_ridedata ~= nil then
               if  DataMount.data_ride_new_data[data.base.base_id] == nil then
                    headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("%s:%s", TI18N("等级"), data.lev)
                else
                    headitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("无级别")
                end
            end
        end
    else
        if data.live_status == 0 then
            headitem.transform:FindChild("NameText"):GetComponent(Text).text = TI18N(data.base.name)
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("未激活")
        elseif data.live_status == 1 or data.live_status == 2 then
            headitem.transform:FindChild("NameText"):GetComponent(Text).text = TI18N(data.base.name)
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("孵化中"))
        else
            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ride_name
            if self.model.cur_ridedata ~= nil then
                if DataMount.data_ride_new_data[data.base.base_id] == nil then
                    headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format("%s:%s", TI18N("等级"), data.lev)
                else
                    headitem.transform:FindChild("LVText"):GetComponent(Text).text = TI18N("无级别")
                end
            end
        end
    end

    if self.model.cur_ridedata ~= nil then
        if DataMount.data_ride_new_data[data.base.base_id] == nil then
            headitem.transform:FindChild("SpecialLabel").gameObject:SetActive(false)
        else
            headitem.transform:FindChild("SpecialLabel").gameObject:SetActive(true)
        end
    end
end

function RideView_HeadBar:onheaditemclick(item)

    if self.model.ridelist[tonumber(item.name)] == nil then
        -- NoticeManager.Instance:FloatTipsByString("未获得坐骑")
        return
    end
    self.model.cur_ridedata = self.model.ridelist[tonumber(item.name)]
    self.ridedata = self.model.cur_ridedata

    self.parent:SelectRide()

    local head
    for i = 1, #self.headlist do
        head = self.headlist[i]
        head.transform:FindChild("Select").gameObject:SetActive(false)

        self:updateNameColor(self.model.ridelist[tonumber(head.name)], head)
    end
    item.transform:FindChild("Select").gameObject:SetActive(true)
    self:updateNameColor(self.model.ridelist[tonumber(item.name)], item, true)
end

function RideView_HeadBar:onheadaddclick()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你是否要前往宠物图鉴查看可携带宠物？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() self.parent.tabGroup:ChangeTab(self.parent.childIndex.manual)  end
    NoticeManager.Instance:ConfirmTips(data)
end

function RideView_HeadBar:onheadlockclick(item)
    local itembase = BackpackManager.Instance:GetItemBase(DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_id)

    local str = string.format(TI18N("是否消耗%s%s开启宠物栏？")
        , DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_val
        , ColorHelper.color_item_name(itembase.quality, itembase.name))

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() PetManager.Instance:Send10523()  end
    NoticeManager.Instance:ConfirmTips(data)
end

function RideView_HeadBar:selectRideByIndex(index)
    local ridelist = self.model.ridelist
    local headlist = self.headlist
    for i = 1, #ridelist do
        local data = ridelist[i]
        if data.index == index then
            local headitem = headlist[i]
            if headitem ~= nil then
                self:onheaditemclick(headitem)
            end
        end

    end
end

function RideView_HeadBar:selectRideObjByIndex(index)
    local ridelist = self.model.ridelist
    local headlist = self.headlist
    for i = 1, #ridelist do
        local data = ridelist[i]
        if data.index == index then
            local headitem = headlist[i]
            if headitem ~= nil then
                return headitem
            end
        end
    end
end