BibleEvaluateGamePanel = BibleEvaluateGamePanel or BaseClass(BasePanel)

function BibleEvaluateGamePanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.bible_evaluate_game, type = AssetType.Main},
        {file = AssetConfig.eyou_activity_textures, type = AssetType.Dep},
        -- {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.itemDic = {}

    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)
    -- self:Init()
end

function BibleEvaluateGamePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function BibleEvaluateGamePanel:__delete()
    for k,v in pairs(self.itemDic) do
        if v.slot ~= nil then
            v.slot:DeleteMe()
        end
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.OnOpenEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function BibleEvaluateGamePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_evaluate_game))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.gameObject.name = "BibleEvaluateGamePanel"
    self.rightContent = self.gameObject.transform

    self.layoutContainer = self.rightContent:Find("ScrollParent/ScrollRect/Grid")
    self.vipgiftLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = 10,border = 4})
    self.vipgiftItem = self.layoutContainer:Find("Reward_1").gameObject

    for i=1,#DataCampaign.data_list[115].rewardgift do
        local rewardData = DataCampaign.data_list[115].rewardgift[i]
        local itemTemp
        if i == 1 or i == 2 or i == 3 then
            itemTemp = self.layoutContainer:Find("Reward_"..i).gameObject
        else
            itemTemp = GameObject.Instantiate(self.vipgiftItem)
        end
        itemTemp:SetActive(true)
        itemTemp.name = tostring(i)

        self.vipgiftLayout:AddCell(itemTemp)

        self.itemDic[i] = {}
        self.itemDic[i].item = itemTemp
        self.itemDic[i].img = itemTemp.transform:Find("Image")
        -- self.itemDic[i].slot = ItemSlot.New()
        -- UIUtils.AddUIChild(self.itemDic[i].img.gameObject, self.itemDic[i].slot.gameObject)
    end

    self.goEvaluateBtn = self.rightContent:Find("GoButton"):GetComponent(Button)
    self.goEvaluateBtn.onClick:AddListener(function()
                self:OnClickGoEvaluateButton()
            end)

    self.descText = self.rightContent:Find("DescBgImage/DescText"):GetComponent(Text)
    self.descText.text = ""
    self.receiveBtn = self.rightContent:Find("ReceiveButton"):GetComponent(Button)
    self.receiveBtn.onClick:AddListener(function()
                self:OnClickReceiveButton()
            end)
    -- local fun3 = function(effectView)
    --     local effectObject = effectView.gameObject

    --     effectObject.transform:SetParent(self.receiveBtn.transform)
    --     effectObject.transform.localScale = Vector3(1.1, 1, 1)
    --     effectObject.transform.localPosition = Vector3(-55, 28, -10)
    --     effectObject.transform.localRotation = Quaternion.identity

    --     Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    --     effectObject:SetActive(true)
    -- end
    -- self.bev = BaseEffectView.New({effectId = 20118, time = nil, callback = fun3})

    self:InitItems()
end
--前往谷歌商店评价
function BibleEvaluateGamePanel:OnClickGoEvaluateButton()
    SdkManager.Instance:goGooglePlay()
end
--领取奖励
function BibleEvaluateGamePanel:OnClickReceiveButton(index)
end

function BibleEvaluateGamePanel:GetDataItem(rewardList)
    -- body
    -- BaseUtils.dump(rewardList,"---------rewardList")
    local baseId = rewardList[1][1]
    local cnt = rewardList[1][2]
    local dataItem ={baseData =  DataItem.data_get[baseId],count = cnt}
    return dataItem
end
--初始化首充奖励的物品
function BibleEvaluateGamePanel:InitItems()
    -- body
    for i,v in ipairs(DataCampaign.data_list[115].rewardgift) do
        local dataItemDic =DataCampaign.data_list[115].rewardgift[i]  --读表取数据

        local slot = ItemSlot.New()
        local itemdata = ItemData.New()
        local cell = DataItem.data_get[dataItemDic[1]]
        itemdata:SetBase(cell)
        slot:SetAll(itemdata, {inbag = false, nobutton = true})
        NumberpadPanel.AddUIChild(self.itemDic[i].img.gameObject, slot.gameObject)
        slot:SetNum(dataItemDic[2])

        self.itemDic[i].slot = slot
    end
end

function BibleEvaluateGamePanel:UpdateWindow()
    -- CampaignManager.Instance:Send14000()
    self:updateTime()
end

function BibleEvaluateGamePanel:updateTime()

end



