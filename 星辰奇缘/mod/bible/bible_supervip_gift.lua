BibleSuperVipGiftPanel = BibleSuperVipGiftPanel or BaseClass(BasePanel)

function BibleSuperVipGiftPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.bible_supervip_gift, type = AssetType.Main},
        {file = AssetConfig.eyou_activity_textures, type = AssetType.Dep},
        -- {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.itemDic = {}
    self.vipgiftObjList = {}

    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)
    -- self:Init()
    self.supervipDataList = {
        [1] = {title = TI18N("超级VIP特权一"),content = TI18N("满足超级VIP要求的玩家，加金牌客服Cherry并完善个人的资料信息，即可轻松获得加好友+完善资料两个超值大礼包！")},
        [2] = {title = TI18N("超级VIP特权二"),content = TI18N("方便快捷的绿色客服通道，Eyougame金牌美女客服Cherry的一对一贴心服务，让您的问题优先获得快速最佳的处理。")},
        [3] = {title = TI18N("超级VIP特权三"),content = TI18N("不定期开展属于超级VIP的专属活动，更多奖励，更多互动，更多精彩的玩法为您单独配置！")},
        [4] = {title = TI18N("超级VIP特权四"),content = TI18N("作为超级VIP玩家，生日当天，一份贴心的生日礼物自然少不了，期待惊喜的出现吧！")},
        [5] = {title = TI18N("超级VIP特权五"),content = TI18N("每逢重大节日，我们都会为各位尊贵的超级VIP玩家准备一份精美的节日礼包作为节日祝福！")},
        [6] = {title = TI18N("超级VIP特权六"),content = TI18N("新服开放，游戏活动，版本更新等最新游戏动态第一时间在此公布，让您先人一步掌握游戏第一手资讯！")},
    }
end

function BibleSuperVipGiftPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function BibleSuperVipGiftPanel:__delete()
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

function BibleSuperVipGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_supervip_gift))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.gameObject.name = "BibleSuperVipGiftPanel"
    self.rightContent = self.gameObject.transform

    self.layoutContainer = self.rightContent:Find("LeftDescParent/ScrollRect/Grid")
    self.vipgiftLayout = LuaBoxLayout.New(self.layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.vipgiftItem = self.layoutContainer:Find("Item_1").gameObject

    self.descText = self.rightContent:Find("BottomDescText"):GetComponent(Text)
    self.descText.gameObject:GetComponent(Button).onClick:AddListener(function()
                self:OnClickDescText()
            end)
    self.lineText = self.descText.transform:Find("LineText"):GetComponent(Text)

    self.copyBtn = self.rightContent:Find("CopyButton"):GetComponent(Button)
    self.copyBtn.onClick:AddListener(function()
                self:OnClickCopyButton()
            end)
    self.copyBtn.gameObject:SetActive(false)

    self:updateVipGiftItems()
end
function BibleSuperVipGiftPanel:OnClickDescText()
    self.copyBtn.gameObject:SetActive(true)
end
--复制微信号
function BibleSuperVipGiftPanel:OnClickCopyButton()

end

function BibleSuperVipGiftPanel:updateVipGiftItems()
    for i,v in ipairs(self.supervipDataList) do
        local obj
        if i == 1 then
            obj = self.layoutContainer:Find("Item_1").gameObject
        elseif i == 2 then
            obj = self.layoutContainer:Find("Item_2").gameObject
        else
            obj = GameObject.Instantiate(self.vipgiftItem)
        end
        obj:SetActive(true)
        obj.name = tostring(i)

        self.vipgiftLayout:AddCell(obj)

        local itemDic = {
            index = i,
            thisObj = obj,
            titleText = obj.transform:Find("TitleText"):GetComponent(Text),
            contentText = obj.transform:Find("ContentText"):GetComponent(Text),
        }
        itemDic.titleText.text = v.title
        itemDic.contentMsg = MsgItemExt.New(itemDic.contentText, 310, 16, 18)
        itemDic.contentMsg:SetData(v.content)
        self.vipgiftObjList[i] = itemDic

        self:InitItemDataIndex(i,itemDic)
    end
end
--数据填充
function BibleSuperVipGiftPanel:InitItemDataIndex(index,itemDic)
    -- body
end

function BibleSuperVipGiftPanel:GetDataItem(rewardList)
    -- body
    -- BaseUtils.dump(rewardList,"---------rewardList")
    local baseId = rewardList[1][1]
    local cnt = rewardList[1][2]
    local dataItem ={baseData =  DataItem.data_get[baseId],count = cnt}
    return dataItem
end
--初始化
function BibleSuperVipGiftPanel:InitItems()
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

        self.itemDic[i].slot = slot
    end
end

function BibleSuperVipGiftPanel:UpdateWindow()
    -- CampaignManager.Instance:Send14000()
    self.copyBtn.gameObject:SetActive(false)
    self.descText.text = ""
    self.lineText.text = "—"
    local perLineWidth = self.lineText.preferredWidth
    local lineCount = self.descText.preferredWidth / perLineWidth
    for i=1,lineCount do
        self.lineText.text = self.lineText.text.."—"
    end
    --
    self:updateTime()
end

function BibleSuperVipGiftPanel:updateTime()

end



