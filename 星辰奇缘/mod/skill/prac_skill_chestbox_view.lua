PracSkillChestboxView = PracSkillChestboxView or BaseClass(BaseWindow)

function PracSkillChestboxView:__init(model)
    self.model = model
    self.name = "PracSkillChestboxView"
    self.windowId = WindowConfig.WinID.chest_box_win
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy
    self.soundCount = 0
    self.resList = {
        {file = AssetConfig.prac_skill_chestbox, type = AssetType.Main}
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

    self.count_add = 0
    self.index_count = 1
    self.total_item_num = 15
    self.reward_index = nil
    self.notify_scroll_msg = nil
    self.last_item = nil

    self.equipSlotList = {}
	------------------------------------------------

    ------------------------------------------------
    self._chestbox_update = function(result_index, notify_scroll_msg)
        self:chestbox_update(result_index, notify_scroll_msg)
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PracSkillChestboxView:__delete()
    for k,v in pairs(self.equipSlotList) do
        v:DeleteMe()
        v = nil
    end

    self.ImgConfirmBtnImg.sprite = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    self:OnHide()

    if self.run_type ~= 3 then
        SkillManager.Instance:Send10814()
    end
    self.is_open = false
    if self.model.chest_box_data ~= nil and self.model.chest_box_data.has_get == nil then
        SkillManager.Instance:Send10813(self.model.chest_box_data.id, self.model.chest_box_data.battle_id)
    else
        if self.notify_scroll_msg ~= nil then
            NoticeManager.Instance:FloatTipsByString(self.notify_scroll_msg)
            self.notify_scroll_msg = nil
        end
    end
    self.last_item = nil
    self.result_idx = nil
end

function PracSkillChestboxView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.prac_skill_chestbox))
    self.gameObject.name = "PracSkillChestboxView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.MidCon = self.MainCon.transform:Find("MidCon").gameObject
    self.Item = self.MidCon.transform:Find("Item").gameObject

    self.closeBtn = self.MainCon.transform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.ImgConfirmBtn = self.MainCon.transform:Find("ImgConfirmBtn").gameObject
    self.ImgConfirmBtn:GetComponent(Button).onClick:AddListener(function() self:on_click_confirm_btn() end)
    self.ImgConfirmBtn:SetActive(false)
    self.ImgConfirmBtnImg = self.ImgConfirmBtn:GetComponent(Image)
    self.ImgConfirmBtnTxt = self.MainCon.transform:Find("ImgConfirmBtn/Text"):GetComponent(Text)
    self.ImgConfirmBtnTxt.supportRichText = true

    ---------------------------------------------
    self:OnShow()
end

function PracSkillChestboxView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function PracSkillChestboxView:OnShow()
    self.is_open = true

    if self.model.chest_box_data ~= nil then
        SkillManager.Instance:Send10813(self.model.chest_box_data.id, self.model.chest_box_data.battle_id)
    end

    self:update_view()

    SkillManager.Instance.OnUpdatePracSkillChestBox:Add(self._chestbox_update)
end

function PracSkillChestboxView:OnHide()
    SkillManager.Instance.OnUpdatePracSkillChestBox:Remove(self._chestbox_update)
end

--更新界面列表
function PracSkillChestboxView:update_view()
    if self.is_open == false then
        return
    end
    local data_list = self.model.chest_box_data.exps

    self.item_list = {}
    for i = 1, #data_list do
        local data = data_list[i]
        local item = self:create_item(self.Item)
        self.equipSlotList[i] = self:set_item_data(item, data)
        table.insert(self.item_list, item)
    end

    self.ImgConfirmBtn:SetActive(true)
end

--抽取结果返回
function PracSkillChestboxView:result_back(result_index)
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
function PracSkillChestboxView:on_click_confirm_btn(g)
    -- self.ImgConfirmBtn:GetComponent(Image).color = Color.grey
    -- self.ImgConfirmBtn.transform:Find("Image"):GetComponent(Image).color = Color.grey

    self.ImgConfirmBtnTxt.text = string.format(ColorHelper.DefaultButton4Str, TI18N("确 定"))
    self.ImgConfirmBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    self:play_random_effect(self.result_idx)
end

function PracSkillChestboxView:play_random_effect(index)
    if self.is_open == false then
        return
    end

    self.reward_index = index --第八个是中奖
end

function PracSkillChestboxView:run_wait()
    if self.is_open == false then
        return
    end

    self.index_count = self.index_count%self.total_item_num
    self.index_count = self.index_count == 0 and 15 or self.index_count
    self:set_selected_state(self.item_list[self.index_count], true)

    if self.run_type == 1 then
        self.total_count = self.total_count + self.ttime/10

        if self.total_count >= 2 and self.reward_index == nil then
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
            LuaTimer.Add(50, function() SkillManager.Instance:Send10814() end)
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
        if self.total_count >= 3 then
            self.total_count = 1
            self:close_my_self()
        else
            LuaTimer.Add(1000, function() self:run_wait() end)
        end
    end
end

--创建新的item
function PracSkillChestboxView:create_item(originItem)
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
function PracSkillChestboxView:set_item_data(item, data)
    item.data = data
    item.Text.text = tostring(data.exp)

    local equipSlot = ItemSlot.New()
    UIUtils.AddUIChild(item.SlotItemCon, equipSlot.gameObject)
    local itemData = ItemData.New()
    itemData:SetBase(BackpackManager.Instance:GetItemBase(20025))
    equipSlot:SetAll(itemData)
    equipSlot:SetNotips(false)
    return equipSlot
end

--设置选中状态
function PracSkillChestboxView:set_selected_state(item, state)
    if self.last_item ~= nil then
        self.last_item.ImgSelect:SetActive(false)
    end
    if state then
        if self.soundCount < 9 then
            if self.soundCount%3 == 0 then
                SoundManager.Instance:Play(236)
            end
            self.soundCount = self.soundCount + 1
        end
    end
    item.ImgSelect:SetActive(state)
    self.last_item = item
end

--关掉自己
function PracSkillChestboxView:close_my_self(g)
    if self.is_open == false then
        return
    end

    WindowManager.Instance:CloseWindow(self)
end

function PracSkillChestboxView:chestbox_update(result_index, notify_scroll_msg)
    if result_index ~= nil then
        self:result_back(result_index)
    end

    if notify_scroll_msg ~= nil then
        self.notify_scroll_msg = notify_scroll_msg
    end
end