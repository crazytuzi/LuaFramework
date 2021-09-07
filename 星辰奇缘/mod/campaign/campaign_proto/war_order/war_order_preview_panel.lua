-- @author hze
-- @date #19/08/19#
-- @战令奖励预览面板

WarOrderPreviewPanel = WarOrderPreviewPanel or BaseClass(BasePanel)

function WarOrderPreviewPanel:__init(model)
    self.resList = {
        {file = AssetConfig.war_order_preview_panel, type = AssetType.Main}
        ,{file = AssetConfig.warordertextures, type = AssetType.Dep}
    }
    self.model = model
    self.mgr = CampaignProtoManager.Instance

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WarOrderPreviewPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for i, v in ipairs(self.itemList) do
            v:DeleteMe()
        end
    end

    if self.layout1 ~= nil then 
        self.layout1:DeleteMe()
    end

    if self.layout2 ~= nil then
        self.layout2:DeleteMe()
    end
end

function WarOrderPreviewPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_preview_panel))
    self.gameObject.name = "WarOrderPreviewPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform.anchoredPosition3D  = Vector3(0, 0, -310)

    local main = self.transform:Find("Main")

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnCloseClick() end)
    self.scroll = main:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function() self:DealExtraEffect() end)
    self.container = main:Find("ScrollRect/Container")
    self.container1 = self.container:Find("Item1/Container")
    self.container2 = self.container:Find("Item2/Container")

    self.item2 = self.container:Find("Item2")

    self.layout1 = LuaGridLayout.New(self.container1, {column = 7, bordertop = 5, borderleft = 15, cspacing = 11, rspacing = 8, cellSizeX = 64, cellSizeY = 64})
    self.layout2 = LuaGridLayout.New(self.container2, {column = 7, bordertop = 5, borderleft = 15, cspacing = 11, rspacing = 8, cellSizeX = 64, cellSizeY = 64})


    self.title1 = self.container:Find("Item1/Title/Text"):GetComponent(Text)
    self.title2 = self.container:Find("Item2/Title/Text"):GetComponent(Text)

    self.btn = main:Find("Button"):GetComponent(Button)
    self.btn.onClick:AddListener(function() self:OnClick() end)
    self.btnImg = main:Find("Button"):GetComponent(Image)
    self.btnTxt = main:Find("Button/Text"):GetComponent(Text)
end

function WarOrderPreviewPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarOrderPreviewPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    local titleStr = TI18N("%s奖励")
    self.title1.text = string.format(titleStr, WarOrderConfigHelper.GetOrder(1).name)
    self.title2.text = string.format(titleStr, WarOrderConfigHelper.GetOrder(2).name)


    local btnStr = string.format(TI18N("进阶%s"), WarOrderConfigHelper.GetOrder(2).name)
    if self.model:GetHighLevelWarStatus() then 
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.btnTxt.text = string.format(ColorHelper.DefaultButton4Str, btnStr)
    else
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.btnTxt.text = string.format(ColorHelper.DefaultButton3Str, btnStr)
    end

    self:ReloadData()
    self:DealExtraEffect()
end

function WarOrderPreviewPanel:OnHide()
    self:RemoveListeners()
end

function WarOrderPreviewPanel:AddListeners()
end

function WarOrderPreviewPanel:RemoveListeners()
end

--更新界面数据
function WarOrderPreviewPanel:ReloadData()
    local data = DataCampWarOrder.data_reward

    local commonList = {}
    local specailList = {}

    local markcomList = {}
    local markspeList = {}

    for lev, _ in pairs(data) do
        local reward = WarOrderConfigHelper.GetReward(lev)
        for j, v in ipairs(reward) do
            if v.type == 1 then 
                if not markcomList[v.item_id] then 
                    markcomList[v.item_id] = true
                    table.insert(commonList, v)
                end
            elseif v.type == 2 then 
                if not markspeList[v.item_id] then
                    markspeList[v.item_id] = true
                    table.insert(specailList, v)
                end
            end
        end
    end

    -- BaseUtils.dump(commonList, "ssss")
    -- BaseUtils.dump(specailList, "sssdd")


    local sortfun = function(a, b) return a.sort < b.sort end

    table.sort(commonList, sortfun)
    table.sort(specailList, sortfun)

    local count = 0
    for i, v in ipairs(commonList) do
        local slot = ItemSlot.New()
        local info = ItemData.New()
        info:SetBase(DataItem.data_get[v.item_id])
        slot:SetAll(info, {inbag = false, nobutton = true})
        -- slot:SetNum(v.num)
        UIUtils.AddUIChild(self.container1, slot.gameObject)
        slot:ShowEffect(v.effect == 1, 20223)
        count = count + 1
        self.itemList[count] = slot
        self.layout1:AddCell(slot.gameObject)
    end

    self.count = count  --记录普通的个数

    for i, v in ipairs(specailList) do
        local slot = ItemSlot.New()
        local info = ItemData.New()
        info:SetBase(DataItem.data_get[v.item_id])
        slot:SetAll(info, {inbag = false, nobutton = true})
        -- slot:SetNum(v.num)
        UIUtils.AddUIChild(self.container2, slot.gameObject)
        slot:ShowEffect(v.effect == 1, 20223)
        count = count + 1
        self.itemList[count] = slot
        self.layout2:AddCell(slot.gameObject)
    end

    local h = self.container1.sizeDelta.y + self.container2.sizeDelta.y + 70
    self.item2.anchoredPosition = Vector2(274, -88 - self.container1.sizeDelta.y)
    self.container.sizeDelta = Vector2(548, h)
end

function WarOrderPreviewPanel:OnCloseClick()
    self.model:CloseWarOrderPreviewPanel()
end

function WarOrderPreviewPanel:OnClick()
    if not self.model:GetHighLevelWarStatus() then 
        self.model:CloseWarOrderPreviewPanel()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warorderbuywindow)
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已进阶%s了哟{face_1,3}"), WarOrderConfigHelper.GetOrder(2).name))
    end
end

--处理特效
function WarOrderPreviewPanel:DealExtraEffect()
    local scrollRect = self.scroll
    local container = self.container

    local item_list = self.itemList

    local a_side = -container.anchoredPosition.y + 35
    local b_side = -container.anchoredPosition.y - 324

    local c_side = -container.anchoredPosition.y + 295
    local d_side = -container.anchoredPosition.y -64

    for k, v in ipairs(item_list) do
        if k <= self.count then 
            if v.effect ~= nil then 
                local a_xy = v.gameObject.transform.anchoredPosition.y
                local s_xy = v.gameObject.transform.sizeDelta.y
                v.effect:SetActive(a_xy < a_side and a_xy - s_xy > b_side)
            end
        else
            if v.effect ~= nil then
                local a_xy = v.gameObject.transform.anchoredPosition.y
                local s_xy = v.gameObject.transform.sizeDelta.y
                v.effect:SetActive(a_xy < c_side and a_xy - s_xy > d_side)
            end
        end
    end
end
