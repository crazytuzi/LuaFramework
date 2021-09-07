FairyLandboxWindow = FairyLandboxWindow or BaseClass(BaseWindow)
-------------------------
--幻境宝箱
-------------------------
function FairyLandboxWindow:__init(model)
    self.model = model
    self.name = "FairyLandboxWindow"
    -- self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Destroy
    self.windowId = WindowConfig.WinID.fairy_land_box
    self.resList = {
        {file = AssetConfig.fairy_land_box_win, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.is_open = false
    self.MainCon = nil
    self.MidCon = nil
    self.Item = nil
    self.ImgConfirmBtn = nil

    self.item_list = nil
    self.run_type = 0
    self.total_count = 1
    self.ttime = 0.4
    self.result_idx = nil

    self.soundCount = 0
    self.count_add = 0
    self.index_count = 1
    self.total_item_num = 20
    self.reward_index = nil
    self.notify_scroll_msg = nil
    self.last_item = nil
    ------------------------------------------------

    ------------------------------------------------
    self._chestbox_update = function(result_index, notify_scroll_msg)
        self:chestbox_update(result_index, notify_scroll_msg)
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function FairyLandboxWindow:__delete()
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v.equipSlot:DeleteMe()
        end
    end

    self.is_open = false

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    if self.run_type ~= 3 then
        if self.model.roll_type == nil then
            --打开滚盘
            DungeonManager.Instance.model:OpenRoll()
        end
    else
    end
    self.last_item = nil
    self.result_idx = nil
end

function FairyLandboxWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fairy_land_box_win))
    self.gameObject.name = "FairyLandboxWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.MidCon = self.MainCon.transform:Find("MidCon").gameObject
    self.Item = self.MidCon.transform:Find("Item").gameObject
    self.Item:SetActive(false)
    self.closeBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.ImgConfirmBtn = self.MainCon.transform:Find("ImgConfirmBtn").gameObject
    self.ImgConfirmBtn:GetComponent(Button).onClick:AddListener(function() self:on_click_confirm_btn() end)
    self.ImgConfirmBtn:SetActive(false)

    local data_list = self.model:get_box_list( self.model.roll_key, 19)
    local result_id = self.model.roll_id
    local roll_punish = self.model.roll_punish
    local random_index = math.floor(Random.Range(1,  20))
    if data_list[random_index] ~= nil then
        local temp_data = data_list[random_index]
        local result_data = nil
        for i=1,#DataFairy.data_base do
            local cfg_d = DataFairy.data_base[i]
            if self.model:FilterCfgData(cfg_d) then 
                if result_id == 1 or result_id == 2 or result_id == 3 then
                    if cfg_d.item_id == result_id and cfg_d.box_id == self.model.roll_key and cfg_d.item_num == roll_punish then
                        result_data = cfg_d
                    end
                elseif cfg_d.item_id == result_id and cfg_d.box_id == self.model.roll_key then
                    result_data = cfg_d
                    break
                end
            end
        end
        if result_data == nil then
            result_data = {item_id = result_id, item_num = 1}
        end
        data_list[random_index] = result_data
        data_list[20] = temp_data
    else
        local result_data = nil
        for i=1,#DataFairy.data_base do
            local cfg_d = DataFairy.data_base[i]
            if self.model:FilterCfgData(cfg_d) then 
                if cfg_d.item_id == result_id and cfg_d.box_id == self.model.roll_key then
                    result_data = cfg_d
                    break
                end
            end
        end
        if result_data == nil then
            result_data = {item_id = result_id, item_num = 1}
        end
        data_list[random_index] = result_data
    end


    self.is_open = true
    self:update_view(data_list)
    self:result_back(random_index)
end

function FairyLandboxWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function FairyLandboxWindow:OnShow()
    self.is_open = true
end

function FairyLandboxWindow:OnHide()
    -- SkillManager.Instance.OnUpdatePracSkillChestBox:Remove(self._chestbox_update)
end

--更新界面列表
function FairyLandboxWindow:update_view(data_list)
    if self.is_open == false then
        return
    end

    self.item_list = {}
    for i = 1, #data_list do
        local data = data_list[i]
        local item = self:create_item(self.Item)
        self:set_item_data(item, data)
        table.insert(self.item_list, item)
    end

    self.ImgConfirmBtn:SetActive(true)
end

--抽取结果返回
function FairyLandboxWindow:result_back(result_index)
    if self.is_open == false then
        return
    end

    self.result_idx = result_index
    --走五秒五秒后没有点确定就
    self.run_type = 1
    self.total_count = 1
    self:run_wait()
end


--确定按钮监听
function FairyLandboxWindow:on_click_confirm_btn(g)
    self.ImgConfirmBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    self.ImgConfirmBtn.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton4

    self:play_random_effect(self.result_idx)
end

function FairyLandboxWindow:play_random_effect(index)
    if self.is_open == false then
        return
    end

    self.reward_index = index --第八个是中奖
end

function FairyLandboxWindow:run_wait()
    if self.is_open == false then
        return
    end

    self.index_count = self.index_count%self.total_item_num
    self.index_count = self.index_count == 0 and 20 or self.index_count
    self:set_selected_state(self.item_list[self.index_count], true)

    if self.run_type == 1 then
        self.total_count = self.total_count + self.ttime/10

        if self.total_count >= 1.7 and self.reward_index == nil then
            self.total_count = 1
            self:on_click_confirm_btn()
        elseif self.index_count == self.reward_index then
            self.ttime = 0.4
            self.count_add = 0
            local circle = 1 --utils.random_by_list({2, 3}) --随机转几圈
            self.count_add = (1.8 - self.ttime)/(circle*self.total_item_num)
            self.run_type = 2
        end
        self.index_count = self.index_count + 1
        LuaTimer.Add(self.ttime / 10 * 1000, function() self:run_wait() end)

    elseif self.run_type == 2 then
        self.ttime = self.ttime + self.count_add

        if self.index_count == self.reward_index then
            self.ttime = 0.4
            self.count_add = 0

            if self.notify_scroll_msg ~= nil then
                NoticeManager.Instance:FloatTipsByString(self.notify_scroll_msg)
                self.notify_scroll_msg = nil
            end
            -- LuaTimer.Add(50, function() SkillManager.Instance:Send10814() end)
            self.notify_scroll_msg = nil
            self.total_count = 0
            self.run_type = 3
            LuaTimer.Add(1000, function() self:run_wait() end)
        else
            self.index_count = self.index_count + 1
            LuaTimer.Add(self.ttime / 5 * 1000, function() self:run_wait() end)
        end
    elseif self.run_type == 3 then
        self.total_count = self.total_count + 1
        if self.total_count > 0 then
            self.total_count = 1
            self:RollDisk()
        else
            LuaTimer.Add(1000, function() self:run_wait() end)
        end
    end
end

--执行滚盘结果
function FairyLandboxWindow:RollDisk()
    if self.model.roll_type == nil then
        --打开滚盘
        DungeonManager.Instance.model:OpenRoll()
        self.model:CloseBoxUI()
    else
        --惩罚
        self.model:CloseBoxUI()
    end
end

--创建新的item
function FairyLandboxWindow:create_item(originItem)
    local item = {}
    item.go = GameObject.Instantiate(originItem)
    UIUtils.AddUIChild(originItem.transform.parent.gameObject, item.go)
    item.go:SetActive(true)

    item.SlotItemCon = item.go.transform:FindChild("SlotItemCon").gameObject
    item.Text = item.go.transform:FindChild("Text"):GetComponent(Text)
    item.ImgSelect = item.go.transform:FindChild("ImgSelect").gameObject
    item.ImgSelect:SetActive(false)

    return item
end

--设置item的data
function FairyLandboxWindow:set_item_data(item, data)
    item.data = data
    local base_data = DataItem.data_get[data.item_id]

    if base_data ~= nil then
        item.Text.text = string.format("<color='%s'>%s</color>", ColorHelper.color[base_data.quality], base_data.name)
    else
        data.item_num = 1
        base_data= DataItem.data_get[21526]
        item.Text.text = string.format("<color='%s'>%s</color>", ColorHelper.color[base_data.quality], data.item_name)
    end
    local equipSlot = ItemSlot.New()
    item.equipSlot = equipSlot
    UIUtils.AddUIChild(item.SlotItemCon, equipSlot.gameObject)
    local itemData = ItemData.New()
    itemData:SetBase(BackpackManager.Instance:GetItemBase(20025))
    equipSlot:SetAll(base_data)
    equipSlot:SetNum(data.item_num)
    equipSlot:SetNotips(false)
end

--设置选中状态
function FairyLandboxWindow:set_selected_state(item, state)
    if self.is_open == false then
        return
    end
    if state then
        if self.soundCount < 9 then
            if self.soundCount%3 == 0 then
                SoundManager.Instance:Play(236)
            end
            self.soundCount = self.soundCount + 1
        end
    end
    if self.last_item ~= nil then
        self.last_item.ImgSelect:SetActive(false)
    end
    item.ImgSelect:SetActive(state)
    self.last_item = item
end

function FairyLandboxWindow:chestbox_update(result_index, notify_scroll_msg)
    if result_index ~= nil then
        self:result_back(result_index)
    end

    if notify_scroll_msg ~= nil then
        self.notify_scroll_msg = notify_scroll_msg
    end
end