------------------
--结算系统统一逻辑
------------------
FinishCountBoxWindow = FinishCountBoxWindow or BaseClass(BaseWindow)
local GameObject = UnityEngine.GameObject

function FinishCountBoxWindow:__init(model)
    self.model = model

    self.name = "FinishCountBoxWindow"

    self.resList = {
        {file = AssetConfig.finish_count_box_win, type = AssetType.Main}
    }

    self.close_timer_id = 0
    self.close_tick_time = 30

    self.loaders = {}

end

function FinishCountBoxWindow:__delete()

    for k,v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil

    self:ClearDepAsset()
end

function FinishCountBoxWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.finish_count_box_win))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.Con = self.transform:Find("Main/Con")
    self.normalbox = self.transform:Find("Main/Normal")
    self.rarebox = self.transform:Find("Main/Rare")
    self:InitBox()


    --倒计时30，自动选一个
    self:start_close_timer()
end

function FinishCountBoxWindow:AddTips(go, base_id)
    local cell = DataItem.data_get[base_id]
    local itemdata = ItemData.New()
    itemdata:SetBase(cell)
    local btn = go.transform:GetComponent(Button) or go.transform:AddComponent(Button)
    btn.onClick:AddListener(
        function ()
            TipsManager.Instance:ShowItem({["gameObject"] = go, ["itemData"] = itemdata})
        end
    )
end

function FinishCountBoxWindow:InitBox()
    for i = 1,3 do
        local location = Vector3((i-2)*150, 0, 0)
        local box = GameObject.Instantiate(self.rarebox.gameObject)
        box.gameObject.name = tostring(i)
        UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
        box.transform.localPosition = location
        self:CloseBox(box.transform, i)
    end
end

function FinishCountBoxWindow:CloseBox(boxTs, index)
    boxTs:Find("Close").gameObject:SetActive(true)
    boxTs:Find("Open").gameObject:SetActive(false)
    boxTs:Find("Item").gameObject:SetActive(false)
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:GetComponent(Button).onClick:AddListener(function ()  self:DuangEffect(boxTs, index) end)
end

function FinishCountBoxWindow:OpenBox(index, data)
    local boxTs = self.Con:Find(tostring(index))
    if boxTs == nil then
        return
    end
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:Find("Close").gameObject:SetActive(false)
    boxTs:Find("Open").gameObject:SetActive(true)
    boxTs:Find("Item").gameObject:SetActive(true)
    local base_id = data.id
    local num = data.num
    local baseData = DataItem.data_get[base_id]

    local Item = boxTs:Find("Item")
    -- Item:Find("Icon"):GetComponent(Image).sprite = sprite
    local imgId = Item:Find("Icon").gameObject:GetInstanceID()
    if self.loaders[imgId] == nil then
           local go =  Item:Find("Icon").gameObject
           self.loaders[imgId] = SingleIconLoader.New(go)
    end
    self.loaders[imgId]:SetSprite(SingleIconType.Item,baseData.icon)


    Item:Find("Text"):GetComponent(Text).text = tostring(num)
    self:AddTips(Item.gameObject, base_id)
end

function FinishCountBoxWindow:OpenOtherBox(index1, index2, data1, data2)
    -- -- print("==========================222222222222")
    -- print(data1)
    -- print(data2)
    self.data1 = data1
    self.data2 = data2
    self.index1 = index1
    self.index2 = index2
    LuaTimer.Add(1000, function()
        self:OpenBox(self.index1 , self.data1)
        self:OpenBox(self.index2 , self.data2)
    end)
    LuaTimer.Add(5000, function () if self.gameObject ~= nil then self.model:CloseBoxWin() end end)
end

function FinishCountBoxWindow:DuangEffect(target, index)
    local second = function ()
        Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one, 0.5, function() end , LeanTweenType.easeOutElastic)
    end

    local descr1 = Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one*0.7, 0.2,
        function()
            second()
            if self.model.box_click_back_fun ~= nil then
                self.model.selected_box_index = index
                self.model.box_click_back_fun()
                self.model.box_click_back_fun = nil
            end
        end,
    LeanTweenType.linear)
end


--倒计时自动关闭
function FinishCountBoxWindow:start_close_timer()
    self:stop_close_timer()
    self.close_timer_id = LuaTimer.Add(0, 1000, function() self:timer_close_tick() end)
end

function FinishCountBoxWindow:stop_close_timer()
    if self.close_timer_id ~= 0 then
        LuaTimer.Delete(self.close_timer_id)
        self.close_timer_id = 0
        self.close_tick_time = 30
    end
end

function FinishCountBoxWindow:timer_close_tick()
    self.close_tick_time = self.close_tick_time - 1
    if self.close_tick_time <= 0 then
        self:stop_close_timer()

        if self.model.box_click_back_fun ~= nil then
            self.model.selected_box_index = Random.Range(1,  3)
            self.model.box_click_back_fun()
            self.model.box_click_back_fun = nil
        end
    end
end
