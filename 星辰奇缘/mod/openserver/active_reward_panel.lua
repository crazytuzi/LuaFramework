ActiveRewardPanel = ActiveRewardPanel or BaseClass(BasePanel)

function ActiveRewardPanel:__init(model,parent)
    self.model = model
    self.name = "ActiveRewardPanel"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.active_reward_panel, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        -- self:RemovePetUpdateEvent()
    end)

    -- self.lastSelectItem = nil
    -- self.itemDataTimeDic = {}
    -- self.selectedType = 0 --选中类型。 0表示不选中，1表示选中仓库宠物，2表示选中携带宠物
    -- self.hideSelectedTaken = function ()
    --     self:HideSelectedTakenGrid()
    -- end
    -- self.hideSelectedStore = function ()
    --     self:HideSelectedStoreGrid()
    -- end

    -- self.petUpdateFun = function ()
    --     self:UpdateTakenPet()
    -- end

    -- self.petStoreUpdateFun = function ()
    --     self:UpdateStorePet()
    -- end

    -- self.petreleasepanel = nil
    -- -- EventMgr.Instance:AddListener(event_name.pet_update, self.petUpdateFun)
    -- EventMgr.Instance:AddListener(event_name.petstore_update, self.petStoreUpdateFun)
end

function ActiveRewardPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function ActiveRewardPanel:__delete()

    -- EventMgr.Instance:RemoveListener(event_name.pet_update, self.petUpdateFun)
    -- EventMgr.Instance:RemoveListener(event_name.petstore_update, self.petStoreUpdateFun)
    for k1,v1 in pairs(self.itemStoreDic) do
        for k2,v2 in pairs(v1.imgSlotList) do
            v2:DeleteMe()
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    self:AssetClearAll()
    -- self:RemovePetUpdateEvent()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function ActiveRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.active_reward_panel))
    self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent, self.gameObject)

    self.curConsumeText = self.transform:Find("TImage/Slider/Text2"):GetComponent(Text) --活跃进度描显示
    self.slider = self.transform:Find("TImage/Slider"):GetComponent(Slider) --活跃进度条

    self.seeBtn = self.transform:Find("TImage/SeeButton"):GetComponent(Button) --查看
    self.seeBtn.onClick:AddListener(function ()
        self:ClickGoSeeBtn()
    end)
    self.transform:Find("TImage/RuleImage"):GetComponent(Button).onClick:AddListener(function ()
        --显示描述
    end)

    self.grid = self.transform:Find("ItemParent/ItemGrid")
    self.itemConsumeReward = self.grid:Find("Item").gameObject
    self.itemConsumeReward:SetActive(false)
    self.gpsLayout = LuaBoxLayout.New(self.grid.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.itemStoreDic = {}
end

--查看
function ActiveRewardPanel:ClickGoSeeBtn()
end

function ActiveRewardPanel:UpdateWindow()
    self:UpdateConsumeList()
end
--
function ActiveRewardPanel:UpdateConsumeList()
    for i,v in ipairs(self.itemStoreDic) do
        if v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
    local dataList = {}
    for i=1,#dataList do
        local itemTaken = self.itemStoreDic[i]
        local data = dataList[i]
        -- BaseUtils.dump(data,"self.model.petlist[i]")
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemConsumeReward)
            obj.name = tostring(i)

            self.gpsLayout:AddCell(obj)
            local imagesList = {
                      obj.transform:Find("Image1"):GetComponent(Image)
                    , obj.transform:Find("Image2"):GetComponent(Image)
                    , obj.transform:Find("Image3"):GetComponent(Image)
                    , obj.transform:Find("Image4"):GetComponent(Image)
                    , obj.transform:Find("Image5"):GetComponent(Image)
                }
            local imagesListSlot = {}
            for i=1,5 do
                local slot = ItemSlot.New()
                NumberpadPanel.AddUIChild(imagesList[i].gameObject, slot.gameObject)
                slot:ShowBg(false)
                table.insert(imagesListSlot,slot)
            end
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = data,
                isLock = false,
                nobtn=obj.transform:GetComponent(NoButton), --未达成
                getbtn=obj.transform:GetComponent(GetButton), --领取
                progressText = obj.transform:Find("ProgressText"):GetComponent(Text), --进度
                descText = obj.transform:Find("DescText"):GetComponent(Text), --描述
                consumeText = obj.transform:Find("Left/Gold"):GetComponent(Text),
                imgList = imagesList, --img list
                imgSlotList = imagesListSlot, --slot list
            }
            self.itemStoreDic[i] = itemDic
            itemTaken = itemDic

            itemDic.getbtn.onClick:AddListener(function ()
                self:ClickGetBtn(i)
            end)
        end
        itemTaken.dataItem = data

        itemTaken.thisObj:SetActive(true)
        itemTaken.descText.text = TI18N("评分")
        itemTaken.nameText.text = data.name

    end
end

function ActiveRewardPanel:ClickGetBtn()
    -- body
end