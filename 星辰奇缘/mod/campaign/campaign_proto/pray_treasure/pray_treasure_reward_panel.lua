-- @author hze
-- @date #2019/09/19#
-- 祈愿宝阁奖池选择界面

PrayTreasureRewardPanel = PrayTreasureRewardPanel or BaseClass(BasePanel)

function PrayTreasureRewardPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.pray_treasure_reward_panel, type = AssetType.Main},
        {file = AssetConfig.praytreasuretextures, type = AssetType.Dep},
    }
    self.model = model
    self.parent = parent
    self.mgr = self.model.mgr


    self.itemList = {}
    self.last_index = 0

    self.itemInitFlag = true   

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self._update_load_listener = function() self:ReloadData() end
end

function PrayTreasureRewardPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for i, v in ipairs(self.itemList) do
            v:DeleteMe()
        end
    end
end

function PrayTreasureRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pray_treasure_reward_panel))
    self.gameObject.name = "PrayTreasureRewardPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform

    self.scroll = t:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function() self:DealExtraEffect() end)

    self.container = self.scroll.transform:Find("Container")
    self.itemCloner = self.container:Find("Tab").gameObject
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, border = 22})

    self.btn1 = self.transform:Find("Button1"):GetComponent(Button)
    self.btn1.onClick:AddListener(function() self:OnBtnClick(1) end)
    self.btn1Effect = BaseUtils.ShowEffect(20053, self.btn1.transform, Vector3(2.2, 0.75, 1), Vector3(-70, -16, -120))

    self.btn2 = self.transform:Find("Button2"):GetComponent(Button)
    self.btn2Txt = self.btn2.transform:Find("Text"):GetComponent(Text)
    self.btn2.onClick:AddListener(function() self:OnBtnClick(2) end)
    self.btn2Effect = BaseUtils.ShowEffect(20053, self.btn2.transform, Vector3(2.2, 0.75, 1), Vector3(-70, -16, -120))
    self.btn2Effect:SetActive(false)
    
    self.btn3 = self.transform:Find("Button3"):GetComponent(Button)
    self.btn3Txt = self.btn3.transform:Find("Text"):GetComponent(Text)
    self.btn3.onClick:AddListener(function() self:OnBtnClick(3) end)
    -- self.btn3Effect = BaseUtils.ShowEffect(20053, self.btn3.transform, Vector3(2.2, 0.75, 1), Vector3(-70, -16, -300))
    -- self.btn3Effect:SetActive(false)


    local data = DataCampPray.data_pool
    for i, v in ipairs(data) do
        self.itemList[i] = PrayTreasureRewardItem.New(self.model, GameObject.Instantiate(self.itemCloner), v.pool_id, self)
        self.layout:AddCell(self.itemList[i].gameObject)
    end
    self.itemCloner:SetActive(false)
end

function PrayTreasureRewardPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PrayTreasureRewardPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if not self.openArgs then
        return
    end
    self.campId = self.openArgs
    print(self.campId)

    self.initFlag = false

    self.selectStatus = self.model:GetPrayTreasureSelectStatus() or false
    self:UpdateBtnStatus()
    self:SetEnabledTips(true)
    self.btn2Effect:SetActive(self.selectStatus)

    self:ReloadData()
    self:DealExtraEffect()
end

function PrayTreasureRewardPanel:OnHide()
    self:RemoveListeners()
end

function PrayTreasureRewardPanel:AddListeners()
    self.mgr.updateWarOrderEvent:AddListener(self._update_load_listener)
end

function PrayTreasureRewardPanel:RemoveListeners()
    self.mgr.updateWarOrderEvent:RemoveListener(self._update_load_listener)
end

--更新界面数据
function PrayTreasureRewardPanel:ReloadData()
    for k, v in ipairs(self.itemList) do
        v:SetData()
    end
end

function PrayTreasureRewardPanel:UpdateBtnStatus(type) 
    self.btn1.gameObject:SetActive(not self.selectStatus)
    self.btn2.gameObject:SetActive(self.selectStatus)
    self.btn3.gameObject:SetActive(self.selectStatus)

    self.btn2Txt.text = TI18N("选择修改")
    self.btn3Txt.text = TI18N("清空选择")

    if type == 1 then
        self.btn2Txt.text = TI18N("确认选择")
    elseif type == 2 then
        self.btn2Txt.text = TI18N("确认修改")
    end
end


function PrayTreasureRewardPanel:OnBtnClick(index)
    if index == 1 then
        self.selectStatus = true
        self:UpdateBtnStatus(index)
        self:SetEnabledTips(false)
        self.initFlag = true
    elseif index == 2 then
        if not self.initFlag then
            self.initFlag = true
            self:UpdateBtnStatus(index)
            self:SetEnabledTips(false)
            self.btn2Effect:SetActive(false)
        else
            if not self.model:GetFullSelectList() then
                NoticeManager.Instance:FloatTipsByString(TI18N("当前未选满所需的奖池奖励哟，快去选择心仪的道具吧{face_1,3}"))
            else
                self:ResetRewardPool()
            end
        end
    elseif index == 3 then
        --清空选择，列表清空，刷新列表
        self.model:CleanPrayTreasureCliSelectTab()
        self:ReloadData()
    end
end

function PrayTreasureRewardPanel:ResetRewardPool()
    if self.model:GetPrayTreasureSelectStatus() then
        local reset_total_times = DataCampPray.data_other[1].value1[1]

        local last_times = reset_total_times - self.model.pray_reset_times
        local str = ""
        if last_times > 0 then
            str = string.format(TI18N("是否确认选择这些道具作为奖池（确定后将消耗重置次数进行重置，剩余<color='#248813'>%s/%s</color>次）"), last_times, reset_total_times)
        else
            local loss_cfg = DataCampPray.data_other[4].value1[1]
            str = string.format(TI18N("是否确认选择这些道具作为奖池（本轮奖池重置需要消耗%s{assets_2, %s}）"), loss_cfg[2], loss_cfg[1])
        end

        local dat = NoticeConfirmData.New()
        dat.type = ConfirmData.Style.Normal
        dat.content = str
        dat.cancelLabel = TI18N("返回")
        dat.sureCallback = function()
            -- self.mgr:Send21204()
            self.model:SelectRewardPool()
        end
        NoticeManager.Instance:ConfirmTips(dat)
    else
        self.model:SelectRewardPool()
    end
end

function PrayTreasureRewardPanel:SetEnabledTips(bool)
    for k, v in ipairs(self.itemList) do
        v:SetEnabledTips(bool)
    end
end

--处理特效
function PrayTreasureRewardPanel:DealExtraEffect()
    local delta1 = 25
    local delta2 = 25
    
    local scrollRect = self.scroll
    local container = scrollRect.content

    local a_side = -container.anchoredPosition.x
    local b_side = a_side + scrollRect.transform.sizeDelta.x

    local a_xy, s_xy = 0, 0
    for k, v in ipairs(self.itemList) do
        a_xy = v.gameObject.transform.anchoredPosition.x + delta1
        s_xy = v.gameObject.transform.sizeDelta.x - delta1 - delta2

        if v.itemList then
            for i, vv in ipairs(v.itemList) do
                if vv.slot then
                    vv.slot:ShowEffect((a_xy > a_side and a_xy + s_xy < b_side) and vv.cfg.is_eff == 1)
                end
            end
        end
    end
end

