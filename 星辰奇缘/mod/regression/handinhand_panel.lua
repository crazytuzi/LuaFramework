-- ----------------------------------------------------------
-- UI - 老玩家回归窗口 携手并进礼面板
-- ----------------------------------------------------------
HandInHandPanel = HandInHandPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function HandInHandPanel:__init(parent, parentContainer)
	self.parent = parent
    self.model = parent.model
    self.parentContainer = parentContainer
    self.name = "HandInHandPanel"
    self.resList = {
        {file = AssetConfig.regression_panel2, type = AssetType.Main}
        , {file = AssetConfig.regression_textures, type = AssetType.Dep}
        , {file = AssetConfig.bigatlas_regression, type = AssetType.Main}
        , {file = AssetConfig.doubleeleven_res, type = AssetType.Dep}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    -- self.subContainer_item_list = {}
    self.item_list = {}

    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HandInHandPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.regression_panel2))
    self.gameObject.name = "HandInHandPanel"
    self.gameObject.transform:SetParent(self.parentContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform
    UIUtils.AddBigbg(transform:Find("Regression"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_regression)))


    -- 按钮功能绑定
    local btn
    self.okBtuuton = transform:FindChild("BindText"):GetComponent(Button)
    self.okBtuuton.onClick:AddListener(function() self:OnBindText() end)
    self.bindText = transform:FindChild("BindText"):GetComponent(Text)
    self.bindBgText = transform:FindChild("BindBgText"):GetComponent(Text)
    transform:FindChild("DescText"):GetComponent(Text).text = TI18N("领取<color='#00ff00'>300活跃奖励</color>或达到<color='#00ff00'>600活跃</color>以上后将不可再绑定招募人")
    -- self.textExt = MsgItemExt.New(transform:FindChild("Mask/Text"):GetComponent(Text), 520, 16, 30)
    -- self.textExt:SetData(campaign_data.cond_desc)

    self.timeText  = transform:FindChild("TimeText"):GetComponent(Text)

    transform:FindChild("OkButton"):GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)

    -- local itemSlot = ItemSlot.New()
    -- UIUtils.AddUIChild(self.transform:FindChild("Item"), itemSlot.gameObject)
    -- local itembase = BackpackManager.Instance:GetItemBase(DataFriend.data_get_recalled_bind_reward[1].reward[1][1])
    -- local itemData = ItemData.New()
    -- itemData:SetBase(itembase)
    -- itemData.quantity = DataFriend.data_get_recalled_bind_reward[1].reward[1][2]
    -- itemSlot:SetAll(itemData)
    -----------------------------------------

    -- self.subPanel = transform:Find("Panel").gameObject
    -- self.subContainer = self.subPanel.transform:FindChild("Container")
    -- self.subPanel_Item = self.transform:FindChild("CloneItem").gameObject
    -- self.subContainer_vScroll =  self.subPanel:GetComponent(ScrollRect)
    -- self.subContainer_vScroll.onValueChanged:AddListener(function()
    --     BaseUtils.on_value_change(self.subContainer_setting_data)
    -- end)

    -- self.subContainer_item_list = {}
    -- for i=1, 6 do
    --     local go = GameObject.Instantiate(self.subPanel_Item)
    --     go.transform:SetParent(self.subContainer.transform)
    --     go:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
    --     go:GetComponent(RectTransform).localPosition = Vector3(0, 0, 0)
    --     go.name = tostring(i)

    --     local item = HandInHandItem.New(go, self)
    --     table.insert(self.subContainer_item_list, item)
    -- end
    -- self.subPanel_Item:SetActive(false)

    -- self.subContainer_single_item_height = self.subPanel_Item.transform:GetComponent(RectTransform).sizeDelta.y
    -- self.subContainer_scroll_con_height = self.subPanel:GetComponent(RectTransform).sizeDelta.y
    -- self.subContainer_item_con_last_y = self.subContainer:GetComponent(RectTransform).anchoredPosition.y

    -- self.subContainer_setting_data = {
    --    item_list = self.subContainer_item_list--放了 item类对象的列表
    --    ,data_list = {} --数据列表
    --    ,item_con = self.subContainer  --item列表的父容器
    --    ,single_item_height = self.subContainer_single_item_height --一条item的高度
    --    ,item_con_last_y = self.subContainer_item_con_last_y --父容器改变时上一次的y坐标
    --    ,scroll_con_height = self.subContainer_scroll_con_height--显示区域的高度
    --    ,item_con_height = 0 --item列表的父容器高度
    --    ,scroll_change_count = 0 --父容器滚动累计改变值
    --    ,data_head_index = 0  --数据头指针
    --    ,data_tail_index = 0 --数据尾指针
    --    ,item_head_index = 0 --item列表头指针
    --    ,item_tail_index = 0 --item列表尾指针
    -- }

    self.cloneItem = self.transform:FindChild("CloneItem").gameObject
    self.cloneItem:SetActive(false)
    self.container = self.transform:FindChild("Panel/Container")

    self.transform:FindChild("Panel"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)
    -----------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function HandInHandPanel:__delete()
    for k,v in pairs(self.item_list) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HandInHandPanel:OnShow()
    self:update()
    RegressionManager.Instance.loginUpdate:Add(self._update)
    RegressionManager.Instance.recruitUpdate:Add(self._update) 
end

function HandInHandPanel:OnHide()
    RegressionManager.Instance.loginUpdate:Remove(self._update)
    RegressionManager.Instance.recruitUpdate:Remove(self._update) 
end

function HandInHandPanel:update()
    if self.model.role_name_recall == "" then
        self.bindText.text = TI18N("绑定招募人")
        self.bindBgText.text = TI18N("________")
        self.okBtuuton.enabled = true
    else
        self.bindText.text = string.format(TI18N("已绑定:%s"), self.model.role_name_recall)
        self.bindBgText.text = ""
        self.okBtuuton.enabled = false
    end

    self.time_out = self.model.time_return + 30 * 24 * 3600

    self.timeText.text = BaseUtils.formate_time_gap(self.time_out - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.DAY)

    local activite = self.model.activite_recall
    if activite == nil then
        activite = 0
    end
    local data_list = {}
    for i=1, #DataFriend.data_get_recalled_reward do
        local data = BaseUtils.copytab(DataFriend.data_get_recalled_reward[i])
        local item = self.item_list[i]
        if item == nil then
            local go = GameObject.Instantiate(self.cloneItem)
            go:SetActive(true)
            go.transform:SetParent(self.container)
            go:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

            item = HandInHandItem.New(go, self)
            table.insert(self.item_list, item)
        end
        
        -- table.insert(data_list, data)
        if self.model.berecruit_rewards[i] then
            data.receive = true
        else
            data.receive = false
        end
        data.activite = activite

        item:update_my_self(data, i)
    end

    self:OnValueChanged()
    LuaTimer.Add(100, function() self:OnValueChanged() end)
    -- self.subContainer_setting_data.data_list = data_list
    -- BaseUtils.refresh_circular_list(self.subContainer_setting_data)
end

function HandInHandPanel:OnBindText()
    self.model:OpenInputRecruitidWindow()
end

function HandInHandPanel:OnOkButton()
    AgendaManager.Instance.model:OpenWindow({3})
end

function HandInHandPanel:ItemOkButtonClick(gameObject)
    RegressionManager.Instance:Send11882(tonumber(gameObject.name))    
end

function HandInHandPanel:OnValueChanged()
    for i=1, #self.item_list do
        local item = self.item_list[i]
        item:OnValueChanged()
    end
end
