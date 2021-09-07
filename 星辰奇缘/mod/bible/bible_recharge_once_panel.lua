BibleRechargeOncePanel = BibleRechargeOncePanel or BaseClass(BasePanel)

function BibleRechargeOncePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.bible_recharge_once_panel, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:UpdateWindow() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.itemList = {}
    self.slotList = {}
end

function BibleRechargeOncePanel:__delete()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleRechargeOncePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_recharge_once_panel))
    self.gameObject.name = "BibleRechargeOncePanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    local panel = self.transform
    self.sevendayObjList = {nil, nil, nil, nil, nil, nil, nil}

    local layoutContainer = panel:Find("ScrollPanel/Container")
    self.layout = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.item = layoutContainer:Find("Item").gameObject
    self.item:SetActive(false)

    self.timeDescTxt = self.transform:Find("TimeDescText"):GetComponent(Text)
    local start = DataCampaign.data_list[78].cli_start_time[1]
    local over = DataCampaign.data_list[78].cli_end_time[1]
    local str = string.format(TI18N("活动时间：%s年%s月%s日-%s年%s月%s日"), start[1], start[2], start[3], over[1], over[2], over[3])
    self.timeDescTxt.text = str
end

function BibleRechargeOncePanel:OnOpen()
    self:UpdateWindow()
end

function BibleRechargeOncePanel:OnHide()
end

function BibleRechargeOncePanel:UpdateWindow()
    for i,v in ipairs(table_name) do
        local itemTemp = self.itemList[i]
        if itemTemp == nil then
            local obj = GameObject.Instantiate(self.item)
            obj:SetActive(true)
            obj.name = tostring(i)

            self.layout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                rechargeBtn=obj.transform:Find("RechargeButton"):GetComponent(Button),
                receiveBtn=obj.transform:Find("CanRecieveButton"):GetComponent(Button),
                descText = obj.transform:Find("DescText"):GetComponent(Text),
                stateText = obj.transform:Find("StateDescText"):GetComponent(Text),

                grid = obj.transform:Find("RewardScrollPanel/Grid"),
                rewardItem = obj.transform:Find("RewardScrollPanel/Grid/RewardItem_1").gameObject,
            }
            itemDic.rewardItem:SetActive(false)
            itemDic.layoutItem = LuaBoxLayout.New(itemDic.grid.gameObject, {axis = BoxLayoutAxis.X, cspacing = 5,border = 4})
            itemDic.rewardList = {}
            itemDic.rechargeBtn.onClick:AddListener(function ()
                --充值
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
            end)
            itemDic.receiveBtn.onClick:AddListener(function ()
                --领取
            end)

            itemTemp = itemDic
            self.itemList[i] = itemTemp
        end
        itemTemp.descText.text = ""
        itemTemp.stateText.text = ""
        for kk,kkvv in ipairs(table_name) do
            local rewardTemp = itemTemp.rewardList[kk]
            if rewardTemp == nil then
                local rewardObj = GameObject.Instantiate(itemTemp.rewardItem)
                rewardObj:SetActive(true)
                rewardObj.name = tostring(kk)

                itemDic.layoutItem:AddCell(rewardObj)

                local rewardDic = {
                    index = kk,
                    thisObj = rewardObj,
                    slot = ItemSlot.New(),
                    itemDataTemp = ItemData.New(),
                }
                table.insert(self.slotList, rewardDic.slot)
                NumberpadPanel.AddUIChild(rewardDic.thisObj, rewardDic.slot.gameObject)

                rewardTemp = rewardDic
                itemTemp.rewardList[kk] = rewardTemp
            end
            --
        end
    end
end