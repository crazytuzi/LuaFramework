BibleFocusGiftPanel = BibleFocusGiftPanel or BaseClass(BasePanel)

function BibleFocusGiftPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.bible_focus_gift, type = AssetType.Main},
        {file = AssetConfig.eyou_activity_textures, type = AssetType.Dep},
        -- {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.itemDic = {}
    self.focusgiftObjList = {}
    self.slotlist = {}
    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)
    -- self:Init()
end

function BibleFocusGiftPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function BibleFocusGiftPanel:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.OnOpenEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function BibleFocusGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_focus_gift))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.gameObject.name = "BibleFocusGiftPanel"
    self.rightContent = self.gameObject.transform

    self.layoutContainer = self.rightContent:Find("ScrollParent/ScrollPanel/Grid")
    self.focusgiftLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.focusgiftItem = self.layoutContainer:Find("Item_1").gameObject
    -- self.focusgiftItem:SetActive(false)
    self:InitFocusGiftItems()
end

function BibleFocusGiftPanel:InitFocusGiftItems()
    for i=1,7 do --数量
        local obj
        if i == 1 then
            obj = self.layoutContainer:Find("Item_1").gameObject
        elseif i == 2 then
            obj = self.layoutContainer:Find("Item_2").gameObject
        else
            obj = GameObject.Instantiate(self.focusgiftItem)
        end
        obj:SetActive(true)
        obj.name = tostring(i)

        self.focusgiftLayout:AddCell(obj)

        local imagesList = {
                  obj.transform:Find("Reward_1/Image"):GetComponent(Image)
                , obj.transform:Find("Reward_2/Image"):GetComponent(Image)
                , obj.transform:Find("Reward_3/Image"):GetComponent(Image)
                , obj.transform:Find("Reward_4/Image"):GetComponent(Image)
                , obj.transform:Find("Reward_5/Image"):GetComponent(Image)
                , obj.transform:Find("Reward_6/Image"):GetComponent(Image)
            }
        local imagesListSlot = {}
        for i=1,6 do
            local slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(imagesList[i].gameObject, slot.gameObject)
            slot:ShowBg(false)
            table.insert(imagesListSlot,slot)
            table.insert(self.slotlist,slot)
        end
        local itemDic = {
            index = i,
            thisObj = obj,
            titleText = obj.transform:Find("ItemTitleText"):GetComponent(Text),
            contentText = obj.transform:Find("ItemDescText"):GetComponent(Text),
            rewardList = imagesListSlot,
            leftImage = obj.transform:Find("LeftImage"):GetComponent(Image),
            lineImgObj = obj.transform:Find("LineImage").gameObject,
        }
        self.focusgiftObjList[i] = itemDic

        self:InitItemDataIndex(i,itemDic)
    end
end
--数据填充
function BibleFocusGiftPanel:InitItemDataIndex(index,itemDic)
    -- body
end

function BibleFocusGiftPanel:GetDataItem(rewardList)
    -- body
    -- BaseUtils.dump(rewardList,"---------rewardList")
    local baseId = rewardList[1][1]
    local cnt = rewardList[1][2]
    local dataItem ={baseData =  DataItem.data_get[baseId],count = cnt}
    return dataItem
end
--初始化
function BibleFocusGiftPanel:InitItems()
    -- body
    for i,v in ipairs(self.onlinerewardTplDataDic) do
        local dataItemDic = self:GetDataItem(v.reward)  --读表取数据

        local slot = ItemSlot.New()
        local itemdata = ItemData.New()
        local cell = dataItemDic.baseData
        itemdata:SetBase(cell)
        slot:SetAll(itemdata, {inbag = false, nobutton = true})
        -- BaseUtils.dump(self.itemDic[i],"self.itemDic[i]")
        NumberpadPanel.AddUIChild(self.itemDic[i].img.gameObject, slot.gameObject)
        slot:SetNum(dataItemDic.count)
        -- self.itemDic[i].nameTxt.text = cell.name --显示物品名称
        table.insert(self.slotlist, slot)
        self.itemDic[i].slot = slot
    end
end

function BibleFocusGiftPanel:UpdateWindow()
    -- CampaignManager.Instance:Send14000()
    self:updateTime()
end

function BibleFocusGiftPanel:updateTime()

end



