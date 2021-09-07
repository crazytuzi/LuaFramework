-- ----------------------------------------------------------
-- UI  招募奖励面板
-- ----------------------------------------------------------
RecruitmentRewardPanel = RecruitmentRewardPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function RecruitmentRewardPanel:__init(model, parent)
	self.model = model
    self.parent = parent
    self.name = "RecruitmentRewardPanel"
    self.resList = {
        {file = AssetConfig.regression_panel3, type = AssetType.Main}
        , {file = AssetConfig.bigatlas_regression, type = AssetType.Main}
        , {file = AssetConfig.regression_textures, type = AssetType.Dep}
        , {file = AssetConfig.doubleeleven_res, type = AssetType.Dep}
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    -- self.subContainer_item_list = {}
    self.item_list = {}
    
    self.timerId = nil
    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function RecruitmentRewardPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.regression_panel3))
    self.gameObject.name = "RecruitmentRewardPanel"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    self.transform = self.gameObject.transform

    -----------------------------------------
    local transform = self.transform
    UIUtils.AddBigbg(transform:Find("Regression"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_regression)))


    -- 按钮功能绑定
    local btn
    self.okBtuuton = transform:FindChild("OkButton"):GetComponent(Button)
    self.okBtuuton.onClick:AddListener(function() self:OnOkButton() end)

    -- self.textExt = MsgItemExt.New(transform:FindChild("DescText"):GetComponent(Text), 520, 16, 30)
    -- self.textExt:SetData("邀好友庆回归，<color='#00ff00'>绑定携手</color>奖励领不停！")
    transform:FindChild("DescText"):GetComponent(Text).text = TI18N("邀好友庆回归，<color='#00ff00'>绑定携手</color>奖励领不停！")
    
    self.bindText = transform:FindChild("BindText"):GetComponent(Text)
    self.timeText = transform:FindChild("TimeText"):GetComponent(Text)
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

    --     local item = RecruitmentRewardItem.New(go, self)
    --     table.insert(self.subContainer_item_list, item)
    -- end
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

function RecruitmentRewardPanel:__delete()
    for k,v in pairs(self.item_list) do
        v:DeleteMe()
        v = nil
    end

    self:OnHide()

    -- if self.timerId ~= nil then
    --     LuaTimer.Delete(self.timerId)
    --     self.timerId = nil
    -- end

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RecruitmentRewardPanel:OnShow()
    self:update()
    RegressionManager.Instance.loginUpdate:Add(self._update)
    RegressionManager.Instance.recruitUpdate:Add(self._update) 

    -- if self.timerId ~= nil then
    --     LuaTimer.Delete(self.timerId)
    --     self.timerId = nil
    -- end
    -- self.timerId = LuaTimer.Add(0, 1000, function() self:OnTimer() end)
end

function RecruitmentRewardPanel:OnHide()
    RegressionManager.Instance.loginUpdate:Remove(self._update) 
    RegressionManager.Instance.recruitUpdate:Remove(self._update) 

    -- if self.timerId ~= nil then
    --     LuaTimer.Delete(self.timerId)
    --     self.timerId = nil
    -- end
end

function RecruitmentRewardPanel:update()
    local model = RegressionManager.Instance.model

    if model.role_name_bind == "" then
        self.bindText.text = TI18N("绑定玩家：暂无")
    else
        self.bindText.text = string.format(TI18N("绑定玩家：%s"), model.role_name_bind)
    end

    self.time_out = model.time_return_bind + 30 * 24 * 3600

    if model.time_return_bind == 0 then
        self.timeText.gameObject:SetActive(false)
        self.bindText.transform.localPosition = Vector2(85, -200)
    else
        self.timeText.gameObject:SetActive(true)
        self.bindText.transform.localPosition = Vector2(173, -200)
        self.timeText.text = string.format("剩余：   <color='#00ff00'>%s</color>", BaseUtils.formate_time_gap(self.time_out - BaseUtils.BASE_TIME, ":", 1, BaseUtils.time_formate.DAY))
    end

    local activite = model.activite_bind
    if activite == nil then
        activite = 0
    end
    local data_list = {}
    for i=1, #DataFriend.data_get_recall_reward do
        local item = self.item_list[i]
        if item == nil then
            local go = GameObject.Instantiate(self.cloneItem)
            go:SetActive(true)
            go.transform:SetParent(self.container)
            go:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

            item = RecruitmentRewardItem.New(go, self)
            table.insert(self.item_list, item)
        end

        local data = BaseUtils.copytab(DataFriend.data_get_recall_reward[i])
        -- table.insert(data_list, data)
        if model.recruit_rewards[i] then
            data.receive = true
        else
            data.receive = false
        end
        data.activite = activite

        item:update_my_self(data, i)
    end

    -- self.subContainer_setting_data.data_list = data_list
    -- BaseUtils.refresh_circular_list(self.subContainer_setting_data)
end

function RecruitmentRewardPanel:OnOkButton()
    RegressionManager.Instance.model:OpenInvitationFriendReturnWindow()
end

function RecruitmentRewardPanel:ItemOkButtonClick(gameObject)
    RegressionManager.Instance:Send11884(tonumber(gameObject.name))    
end

-- function RecruitmentRewardPanel:OnTimer()
--     local model = RegressionManager.Instance.model

--     if model.role_name_bind ~= "" then
--         self.bindText.text = string.format(TI18N("绑定玩家：%s"), model.role_name_bind)
--     end
-- end

function RecruitmentRewardPanel:OnValueChanged()
    for i=1, #self.item_list do
        local item = self.item_list[i]
        item:OnValueChanged()
    end
end
