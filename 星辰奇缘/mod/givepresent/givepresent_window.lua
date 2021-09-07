GivePresentWindow = GivePresentWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function GivePresentWindow:__init(model)
    self.model = model
    self.name = "GivePresentWindow"
    -- self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.giftwindow
    self.currpage = nil
    self.giveMgr = GivepresentManager.Instance
    self.resList = {
        {file = AssetConfig.givepresentwin, type = AssetType.Main}
        -- ,{file = AssetConfig.infoicon_textures, type = AssetConfig.Dep}
        ,{file = AssetConfig.heads, type = AssetConfig.Dep}

    }
    self.specialList = {156}

    self.listener = function()
        self:RefreshOnBackpackChange()
    end
    self.topItemobj = {}
    self.topPresentobj = {}
    self.iconloader = {}
end

function GivePresentWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.presentLayout ~= nil then
        self.presentLayout:DeleteMe()
        self.presentLayout = nil
    end
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    if self.tabpage ~= nil then
        self.tabpage:DeleteMe()
        self.tabpage = nil
    end
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.listener)
    NationalSecondManager.Instance.OnUpdateFlowerFriend:RemoveListener(self.listener)
    self:ClearDepAsset()
end

function GivePresentWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.givepresentwin))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseMain() end)
    self.transform:Find("MainCon/Right/Panel1/ResultPanel/InfoButton"):GetComponent(Button).onClick:AddListener(
        function()
            TipsManager.Instance:ShowText(
                {
                gameObject = self.transform:Find("MainCon/Right/Panel1/ResultPanel/InfoButton").gameObject,
                itemData = {TI18N("1、每天可赠送给同一玩家5个道具\n2、部分道具需达到一定亲密度才可赠送\n3、互加好友后组队、送花可获得亲密度\n4、部分珍稀道具不限赠送次数\n5、月度礼包特权效果可使每天赠送道具上限+1")}
                }
                )
        end)
    self.playerscrollrect = self.transform:Find("MainCon/Left/Panel/ScrollLayer"):GetComponent(LVerticalScrollRect)
    self.datalist = self.giveMgr.playerList
    self.rightPanleGroup = {
        [1] = self.transform:Find("MainCon/Right/Panel1"),
        [2] = self.transform:Find("MainCon/Right/Panel2"),
        [3] = self.transform:Find("MainCon/Right/Panel3"),
    }
    local setting1 = {
        axis = BoxLayoutAxis.X
        ,spacing = 0
        ,Left = 0
    }
    self.ToggleGroup = self.transform:Find("MainCon/Right/Panel1/ToggleGroup")
    self.presentLayout = LuaBoxLayout.New(self.rightPanleGroup[2]:Find("MaskScroll/Container"), setting1)
    self.presentItem = self.transform:Find("MainCon/Right/Panel2/MaskScroll/Gift").gameObject
    self.selectParentCon = self.rightPanleGroup[2]:Find("ResultPanel/Page/1")
    self.presentInputfield = self.rightPanleGroup[2]:Find("ResultPanel/InputField"):GetComponent(InputField)
    self.presentInputfield_tips = self.rightPanleGroup[2]:Find("ResultPanel/Text"):GetComponent(Text)
    self.presentSendBtn = self.rightPanleGroup[2]:Find("ResultPanel/GiftToButton")
    self.noimg = self.transform:Find("MainCon/Left/noimg").gameObject

    self.presentInputfield.textComponent = self.presentInputfield.gameObject.transform:FindChild("Text").gameObject:GetComponent(Text)
    self.presentInputfield.placeholder = self.presentInputfield.gameObject.transform:FindChild("Placeholder").gameObject:GetComponent(Graphic)

    self.topItemList = {}
    self.topItemobj = {}
    self.botItemList = {}
    self.itemSelect_num = 0
    self.maxNum = self.giveMgr.MaxGiveNum

    self:InitLeft()
    self:InitTab()
    self:InitGiveItemPanel()
    self:InitGivePresentPanel()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
    NationalSecondManager.Instance.OnUpdateFlowerFriend:AddListener(self.listener)
    -- self.giveMgr:UpdateGiveHistory()
    -- self.OnOpenEvent:AddListener(function() self:OnShow() end)
end

-- function GivePresentWindow:OnShow()
--     -- ShouhuManager.Instance:request10901()
--     -- self:InitLeft()
--     self.playerscrollrect:RefreshData(self.datalist)
--     self:InitTab()
--     self:InitGiveItemPanel()
--     self:InitGivePresentPanel()
-- end

-- function GivePresentWindow:OnHide()

-- end

function GivePresentWindow:InitLeft()
    self.noimg:SetActive(#self.datalist <= 0)
    local GetData = function(index)
        return {item_index = index+1, data = self.datalist[index+1]}
    end
    self.playerscrollrect:SetPoolInfo(#self.datalist, "GivePresentPlayerItem", GetData, {assetWrapper = self.assetWrapper, onclick = function(item, data) self:OnclickPlayerItem(item, data) end})
end

function GivePresentWindow:RefreshData()
    if self.playerscrollrect ~= nil then
        self.playerscrollrect:RefreshData(self.datalist)
    end
end

function GivePresentWindow:OnclickPlayerItem(item, data)
    if self.currselectPlay ~= nil then
        self.currselectPlay.transform:Find("Select").gameObject:SetActive(false)
    end
    self.currselectPlay = item
    self.currselectPlay.transform:Find("Select").gameObject:SetActive(true)
    self:RefreshRight(data)
end

function GivePresentWindow:InitTab()
    local go = self.transform:Find("MainCon/Right/TabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end)
    self:InitPage()
    if self.openArgs ~= nil then
        self.tabgroup:ChangeTab(self.openArgs)
    end
end

function GivePresentWindow:InitPage()
    local panel = self.rightPanleGroup[1]:Find("MaskScroll").gameObject
    self.tabpage = TabbedPanel.New(panel, 3, 343.2)
    self.tabpage.MoveEndEvent:AddListener(
        function(page)
            for i=1,3 do
                self.ToggleGroup:Find(tostring(i)):GetComponent(Toggle).isOn = (i==page)
            end
        end
    )
end

function GivePresentWindow:OnTabChange(tab)
    for i,v in ipairs(self.rightPanleGroup) do
        v.gameObject:SetActive(tab == i)
    end
    self.currTab = tab
end


------赠送道具处理
function GivePresentWindow:InitGiveItemPanel()
    self.topItemList = self.giveMgr:GetHasItemList()
    self.botItemList = {}
    for i = 1, 30 do
        local index = i
        local Page = math.ceil(index/10)
        local num = (index-1)%10+1
        local go = self.rightPanleGroup[1]:Find(string.format("MaskScroll/Container/Page%s/%s", tostring(Page), tostring(num))).gameObject
        if self.topItemobj[i] == nil then
            local obj = TopItem.New(go, index, self)
            -- table.insert(self.topItemobj, obj)
            self.topItemobj[i] = obj
        else
            self.topItemobj[i]:RefreshData()
        end
    end
    self.rightPanleGroup[1]:Find("ResultPanel/Button"):GetComponent(Button).onClick:RemoveAllListeners()
    self.rightPanleGroup[1]:Find("ResultPanel/Button"):GetComponent(Button).onClick:AddListener(function() self:OnBtnSendItem() end)
    self:UpdateGiveItemSelect()
    self:UpdateGiveItemUnSelect()
    self.itemSelect_num = 0
    -- self:SetItemNum()
    -- self.maxNum = self.giveMgr.MaxGiveNum - self.giveMgr:GetTimesOfGive(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id)
    -- if self.itemSelect_num > self.maxNum then
    --     self:InitGiveItemPanel()
    -- end
    self.rightPanleGroup[1]:Find("ResultPanel/BarText"):GetComponent(Text).text = string.format("%s/%s", tostring(self.giveMgr.MaxGiveNum-self.maxNum+self.itemSelect_num), tostring(self.giveMgr.MaxGiveNum))
    self.rightPanleGroup[1]:Find("ResultPanel/bar").sizeDelta = Vector2(100*(self.giveMgr.MaxGiveNum-self.maxNum+self.itemSelect_num)/self.giveMgr.MaxGiveNum,12)
end

function GivePresentWindow:MakeDiaowen()
    local diaowenID = SkillManager.Instance.model:get_diaowen_classes_produce()
    local percost = SkillManager.Instance.model:get_diaowen_producing_cost()
    local maxenergy = RoleManager.Instance.RoleData.energy
    SkillManager.Instance:Send10810(10007)
end

-- 增加列表选中道具
function GivePresentWindow:AddToTopItem(base_id, num)
    local list = BackpackManager.Instance:GetItemByBaseid(base_id)
    for _,itemdata in pairs(list) do
        if itemdata.expire_time ~= nil and itemdata.expire_time ~= 0 and itemdata.expire_time - BaseUtils.BASE_TIME <= 0 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>已过期</color>，不能赠送喔{face_1,2}"), DataItem.data_get[base_id].name))
            return
        end
    end
    for i,v in ipairs(self.topItemList) do
        if v.base_id == base_id then
            self.topItemList[i].num = self.topItemList[i].num + num
        end
    end
    -- self:UpdateGiveItemSelect()
end

--减少列表选中道具
function GivePresentWindow:DecToTopItem(base_id, num, data)
    for i,v in ipairs(self.topItemList) do
        if v.base_id == base_id then
            self.topItemList[i].num = self.topItemList[i].num - num
        end
    end

    self:UpdateGiveItemSelect()
end
-- 增加选中道具
function GivePresentWindow:AddToBotItem(base_id, num, data)
    local list = BackpackManager.Instance:GetItemByBaseid(base_id)
    for _,itemdata in pairs(list) do
        if itemdata.expire_time ~= nil and itemdata.expire_time ~= 0 and itemdata.expire_time - BaseUtils.BASE_TIME <= 0 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>已过期</color>，不能赠送喔{face_1,2}"), DataItem.data_get[base_id].name))
            return
        end
    end
    local old = false
    for i,v in ipairs(self.botItemList) do
        if v.base_id == base_id then
            self.botItemList[i].num = self.botItemList[i].num + num
            old = true
        end
    end
    if old == false then
        table.insert(self.botItemList, {base_id = base_id, num = num, data = data})
    end
    if self.giveMgr:IsLimited(base_id) or base_id == 0 or (data ~= nil and data ~= nil and self.giveMgr:IsLimited(data.base_id)) then
        self.itemSelect_num = self.itemSelect_num + 1
    end

    local baseItemData = BackpackManager.Instance:GetItemBase(base_id)
    if base_id == 0 then
        local key = SkillManager.Instance.model:get_diaowen_classes_produce()
        baseItemData = BackpackManager.Instance:GetItemBase(key)
    end
    if baseItemData ~= nil then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已选中%s"), ColorHelper.color_item_name(baseItemData.quality, baseItemData.name)))
    end
    self:DecToTopItem(base_id, num, data)
    self:UpdateGiveItemSelect()
    self:UpdateGiveItemUnSelect()
    self:SetItemNum()
end
--减少选中道具
function GivePresentWindow:DecToBotItem(base_id, num, data)
    local old = false
    for i,v in ipairs(self.botItemList) do
        if v.base_id == base_id then
            self.botItemList[i].num = self.botItemList[i].num - num
            if self.botItemList[i].num <= 0 then
                table.remove(self.botItemList, i)
            end
            old = true
        end
    end
    if old == false then
        table.insert(self.botItemList, {base_id = base_id, num = num, data = data})
    end
    if self.giveMgr:IsLimited(base_id) or base_id == 0 or (data ~= nil and data.data ~= nil and self.giveMgr:IsLimited(data.data.base_id)) then
        self.itemSelect_num = self.itemSelect_num - 1
    end
    self:AddToTopItem(base_id, num)
    self:UpdateGiveItemSelect()
    self:UpdateGiveItemUnSelect()
    self:SetItemNum()
end

--更新选择道具到下面列表
function GivePresentWindow:UpdateGiveItemSelect()
    local has = 0
    for i = 1, 5 do
        local v = self.botItemList[i]
        if v~= nil then
            has = 1
        end
        local item = self.rightPanleGroup[1]:Find(string.format("ResultPanel/Page/%s", tostring(i)))
        self:SetBotItem(item,v)
    end
    self.rightPanleGroup[1]:Find("ResultPanel/Page").gameObject:SetActive(has>0)
    self.rightPanleGroup[1]:Find("ResultPanel/UnSelectText").gameObject:SetActive(has==0)
end

--更新选择道具到下上面列表
function GivePresentWindow:UpdateGiveItemUnSelect()
    for i,v in pairs(self.topItemobj) do
        v:RefreshData()
    end
end

--设置选择道具
function GivePresentWindow:SetBotItem(item, data)
    if data ~= nil then
        self:GetIcon(item:Find("Icon").gameObject, data.base_id, data.data)
        item:Find("NumImg/NumText"):GetComponent(Text).text = tostring(data.num)
        item:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
        item:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:DecToBotItem(data.base_id, 1, data) end)
        local diaowenID = SkillManager.Instance.model:get_diaowen_classes_produce()
        if data.data ~= nil and data.data.step > 0 then
            -- local basdata = DataItem.data_get[self.data.base_id]
            -- if self.data.base_id == 0 then
            --     basdata = DataItem.data_get[diaowenID]
            -- end
            item:Find("LvImg").gameObject:SetActive(true)
            item:Find("LvImg/Text"):GetComponent(Text).text = "Lv."..tostring(data.data.step)
        else
            item:Find("LvImg").gameObject:SetActive(false)
        end
    end
    if data == nil then
        item:Find("LvImg").gameObject:SetActive(false)
    end
    item:Find("Icon").gameObject:SetActive(data ~= nil)
    item:Find("Button").gameObject:SetActive(data ~= nil)
    item:Find("NumImg").gameObject:SetActive(data ~= nil)
end

function GivePresentWindow:SetItemNum()
    if self.tragetData == nil then
        return
    end
    self.maxNum = self.giveMgr.MaxGiveNum - self.giveMgr:GetTimesOfGive(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id)
    if self.itemSelect_num > self.maxNum then
        self:InitGiveItemPanel()
    end
    self.rightPanleGroup[1]:Find("ResultPanel/BarText"):GetComponent(Text).text = string.format("%s/%s", tostring(self.giveMgr.MaxGiveNum-self.maxNum+self.itemSelect_num), tostring(self.giveMgr.MaxGiveNum))
    self.rightPanleGroup[1]:Find("ResultPanel/bar").sizeDelta = Vector2(100*(self.giveMgr.MaxGiveNum-self.maxNum+self.itemSelect_num)/self.giveMgr.MaxGiveNum,12)
end

function GivePresentWindow:SetItemText()
    self.rightPanleGroup[1]:Find("Text"):GetComponent(Text).text = string.format(TI18N("赠送道具给<color='#00FF00'>%s</color>"),tostring(self.tragetData.name))
end

function GivePresentWindow:OnBtnSendItem()
    if next(self.botItemList) == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请选择要赠送的礼物"))
            return
    end
    if self.tragetData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择赠送对象{face_1,3}"))
        return
    end
    if self.itemSelect_num > self.maxNum then
        print("超过可赠送数量")
    else
        -- local isSendConfirm = false
        -- for k,v in pairs(self.botItemList) do
        --      if v.base_id == 26013 and BuffPanelManager.Instance.model.buffDic ~= nil and BuffPanelManager.Instance.model.buffDic[31015] ~= nil then
        --         isSendConfirm = true
        --     end
        -- end
        -- if isSendConfirm == true then
        --           local confirmData = NoticeConfirmData.New()
        --           confirmData.type = ConfirmData.Style.Normal
        --           confirmData.content = string.format("你在<color='#ffff00'>12小时内</color>收到他人赠送的<color='#ffff00'>入场券</color>，在此期间你再赠送入场券将<color='#ffff00'>不能收到复活卡</color>，是否继续")
        --           confirmData.sureSecond = -1
        --           confirmData.cancelSecond = -1
        --           confirmData.sureLabel = TI18N("继续赠送")
        --           confirmData.cancelLabel = TI18N("取消")
        --           confirmData.sureCallback = function()
        --             self.giveMgr:SendItemToPlayer(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id, self.botItemList)
        --          end
        --          NoticeManager.Instance:ConfirmTips(confirmData)
        -- else
            self.giveMgr:SendItemToPlayer(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id, self.botItemList)
    end

end



---------------------=================================赠送礼物逻辑=========================---------------------------------------
------------------------------------------------------------------------------------------------------------------------------
function GivePresentWindow:InitGivePresentPanel()
    self.presentSendBtn:GetComponent(Button).onClick:AddListener(function() self:OnBtnSendPresent() end)
    self.presentInputfield.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    self.selectPresentList = {}
    self:UpdateGivePresentPanel()
end


function GivePresentWindow:UpdateGivePresentPanel()
    self.topPresentList = self.giveMgr.BaseGiftList
    self.presentSelect_num = 0
    self.selectPresentList = {}
    local parent = self.rightPanleGroup[2]:Find("MaskScroll/Container")
    self.presentLayout:ReSet()
    for i,v in ipairs(self.giveMgr.BaseGiftList) do
        if self:IsSpecial(v) == true then
           local name = tostring(v)
            local item = parent:Find(name)
            if item == nil then
                item = GameObject.Instantiate(self.presentItem)
                item.gameObject.name = name
            else
                item = item.gameObject
            end

            if self.topPresentobj[i] == nil then
                self.topPresentobj[i] = TopPresent.New(item, v, self)
            else
                self.topPresentobj[i]:RefreshData()
            end
            self.presentLayout:AddCell(item)
        end
    end
    self:RefreshBotPresent()
end

function GivePresentWindow:IsSpecial(id)
    local data = DataItem.data_get[id]
    for k,v in pairs(self.specialList) do
        if data.type == v then
            for k2,v2 in pairs(NationalSecondManager.Instance.flowerGiveFriendData) do
                if v2.id == id then
                    return true
                end
            end
            return false
        end

    end
    return true
end

function GivePresentWindow:UpdateGivePresentUnSelect()
    for i,v in pairs(self.topPresentobj) do
        v:RefreshData()
    end
end

function GivePresentWindow:OnSelectPresent(base_id)
    local list = BackpackManager.Instance:GetItemByBaseid(base_id)
    for _,itemdata in pairs(list) do
        if itemdata.expire_time ~= nil and itemdata.expire_time ~= 0 and itemdata.expire_time - BaseUtils.BASE_TIME <= 0 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s<color='#ffff00'>已过期</color>，不能赠送喔{face_1,2}"), DataItem.data_get[base_id].name))
            return
        end
    end

    if self.tragetData ~= nil and self.tragetData.online == 0 then

    elseif self.tragetData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择赠送玩家"))
    end
    if self.selectPresentList[base_id] == nil then
        self.selectPresentList[base_id] = 1
    else
        self.selectPresentList[base_id] = self.selectPresentList[base_id] + 1
    end
    -- self:SetSelectPresent(base_id)
    local baseItemData = BackpackManager.Instance:GetItemBase(base_id)
    if baseItemData ~= nil then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已选中%s"), ColorHelper.color_item_name(baseItemData.quality, baseItemData.name)))
    end
    self:RefreshBotPresent()
    self:UpdateGivePresentUnSelect()
end

function GivePresentWindow:DisSelectPresent(base_id)
    if self.selectPresentList[base_id] == nil then
        self.selectPresentList[base_id] = nil
    else
        self.selectPresentList[base_id] = self.selectPresentList[base_id] - 1
    end
    if self.selectPresentList[base_id] == 0 then
        self.selectPresentList[base_id] = nil
    end
    self:RefreshBotPresent()
    self:UpdateGivePresentUnSelect()
end

function GivePresentWindow:RefreshBotPresent()
    local index = 1
    for k,v in pairs(self.selectPresentList) do
        local con = self.rightPanleGroup[2]:Find(string.format("ResultPanel/Page/%s", tostring(index)))
        con:Find("Icon").gameObject:SetActive(true)
        self:GetIcon(con:Find("Icon").gameObject, k)
        con:Find("NumImg/NumText"):GetComponent(Text).text = tostring(v)
        con:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
        con:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:DisSelectPresent(k) end)
        con:Find("NumImg").gameObject:SetActive(true)
        con:Find("Button").gameObject:SetActive(true)
        con.gameObject:SetActive(true)
        index = index + 1
    end
    for i=index,5 do
        self.rightPanleGroup[2]:Find(string.format("ResultPanel/Page/%s", tostring(i))).gameObject:SetActive(false)
    end
    self.rightPanleGroup[2]:Find("ResultPanel/UnSelectText").gameObject:SetActive(index == 1)
end

function GivePresentWindow:SetSelectPresent(base_id)
    self:GetIcon(self.selectParentCon:Find("Icon").gameObject, base_id)
    self.selectPresentID = base_id
    -- self.selectParentCon:Find("Icon").gameObject:SetActive(sprite ~= nil)
end

function GivePresentWindow:OnMsgChange(val)
    local len = string.utf8len(val)
    local remain = 20 - len

    self.rightPanleGroup[2]:Find("ResultPanel/Text"):GetComponent(Text).text = string.format(TI18N("还可以输入%s个字"), tostring(remain))
end

function GivePresentWindow:SetPresentText()
    local str = string.format(TI18N("赠送礼物给<color='#00FF00'>%s</color>"), tostring(self.tragetData.name))
    self.rightPanleGroup[2]:Find("GiftToText"):GetComponent(Text).text = str
end

function GivePresentWindow:OnBtnSendPresent()
    if next(self.selectPresentList) == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要赠送的礼物"))
        return
    end
    if self.tragetData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择赠送玩家"))
        return
    end
    local msg = self.presentInputfield.text
    if msg == "" then
        msg = nil
    end
    local temp = {}
    for k,v in pairs(self.selectPresentList) do
        table.insert(temp, {base_id = k, num = v})
    end

    -- BaseUtils.dump(self.tragetData,"赠送数据")

    if FriendManager.Instance:IsFriend(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id) then
        local isSendConfirm = false
        local isSendSingMark = false
        for k,v in pairs(temp) do
            if v.base_id == 26013 and BuffPanelManager.Instance.model.buffDic ~= nil and BuffPanelManager.Instance.model.buffDic[31015] ~= nil then
                isSendConfirm = true
            elseif (SingManager.Instance.activeState == 2 or SingManager.Instance.activeState == 4 or SingManager.Instance.activeState == 6 or SingManager.Instance.activeState == 8)  and (v.base_id == 29153 or v.base_id == 20032 or v.base_id == 29051) then
                -- isSendSingMark = true   --(暂时屏蔽好声音赠花优化)
            end
        end
        if isSendConfirm == true then
                  local confirmData = NoticeConfirmData.New()
                  confirmData.type = ConfirmData.Style.Normal
                  confirmData.content = string.format("你在<color='#ffff00'>12小时内</color>收到他人赠送的<color='#ffff00'>入场券</color>，在此期间你再赠送入场券将<color='#ffff00'>不能收到复活卡</color>，是否继续")
                  confirmData.sureSecond = -1
                  confirmData.cancelSecond = -1
                  confirmData.sureLabel = TI18N("继续赠送")
                  confirmData.cancelLabel = TI18N("取消")
                  confirmData.sureCallback = function()
                    self.giveMgr:Require11842(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id, temp, msg)
                 end
                 NoticeManager.Instance:ConfirmTips(confirmData)
        elseif isSendSingMark then
                  local confirmData = NoticeConfirmData.New()
                  confirmData.type = ConfirmData.Style.Normal
                  confirmData.sureSecond = -1
                  confirmData.cancelSecond = -1
                  confirmData.sureLabel = TI18N("继续赠送")
                  confirmData.cancelLabel = TI18N("取消")
                  confirmData.sureCallback = function()
                    self.giveMgr:Require11842(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id, temp, msg)
                  end
                  local stage = SingManager.Instance.activeState
                  if stage == 2 or stage == 6 then ---------好声音预选赛/入围赛报名
                    confirmData.content = string.format(TI18N("当前星辰好声音活动处于报名阶段，送花将不增加好评，是否继续？"))
                  elseif stage == 4 then--------------------好声音预选赛投票
                    if true then 
                        confirmData.content = string.format(TI18N("%没有报名好声音，送花不增加好评"), self.tragetData.name)
                    else
                        confirmData.content = string.format(TI18N("%s当天还有%s点送花好评可增加，每朵最多增加20票"), self.tragetData.name, "xx")
                    end
                  elseif stage == 8 then--------------------好声音入围赛投票
                    if false then 
                        confirmData.content = string.format(TI18N("%没有报名好声音，送花不增加好评"), self.tragetData.name)
                    end
                    confirmData.content = string.format(TI18N("%s当天还有%s点送花好评可增加，每朵最多增加10票"), self.tragetData.name, "xx")
                  end
                  NoticeManager.Instance:ConfirmTips(confirmData)
        else
            self.giveMgr:Require11842(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id, temp, msg)
        end
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = string.format(TI18N("<color=#33E0EC>%s</color>还不是你的好友，赠送不增加亲密度<color=#ffff00>（建议先加为好友）</color>"), self.tragetData.name)
        data.sureLabel = TI18N("添加好友")
        data.cancelLabel = TI18N("仍然赠送")
        data.blueSure = true
        data.showClose = 1
        data.cancelCallback = function() self.giveMgr:Require11842(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id, temp, msg) end
        data.sureCallback = function() FriendManager.Instance:AddFriend(self.tragetData.id, self.tragetData.platform, self.tragetData.zone_id) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

---------------------=================================其它工具=========================---------------------------------------
------------------------------------------------------------------------------------------------------------------------------


function GivePresentWindow:RefreshRight(data)
    self.tragetData = data
    self:SetItemNum()
    self:SetItemText()
    self:SetPresentText()
end

function GivePresentWindow:RefreshOnBackpackChange()

    for i,v in ipairs(self.topItemList) do
        local num = BackpackManager.Instance:GetUnbindItemCount(v.base_id)
        if v.data ~= nil then
            local backdata = BackpackManager.Instance:GetItemById(v.base_id)
            if backdata == nil then
                num = 0
            else
                num = backdata.quantity
            end
        end
        if v.base_id == 0 then
            num = self.giveMgr:GetUnbindDiaowenCount()
        end
        local selectnum = 0
        for ii,selectitem in ipairs(self.botItemList) do
            if selectitem.base_id ==  v.base_id then
                selectnum = selectitem.num
                if selectitem.num >= num then
                    self.botItemList[ii].num = num
                    num = 0
                else
                    num = num - selectnum
                end
            end
        end
        self.topItemList[i].num = num
    end
    self:UpdateGiveItemSelect()
    self:UpdateGiveItemUnSelect()
    self:UpdateGivePresentPanel()
    self:UpdateGivePresentUnSelect()
end

function GivePresentWindow:GetIcon(go, base_id, data)

    local diaowenList = DataSkillLife.data_diao_wen["10007_10"].product
    local key = 0
    for i,v in ipairs(diaowenList) do
        if v.classes == RoleManager.Instance.RoleData.classes then
            key = v.key
        end
    end
    local icon
    if base_id == 0 then
        icon = DataItem.data_get[key].icon
    elseif data ~= nil then
        icon = DataItem.data_get[data.base_id].icon
    else
        icon = DataItem.data_get[base_id].icon
    end
    local id = go:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(go)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, icon)
end


function GivePresentWindow:RefreshFriendShip()
    self:RefreshData()
end
