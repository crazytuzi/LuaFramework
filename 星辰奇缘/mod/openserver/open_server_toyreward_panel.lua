OpenServerToyRewardPanel = OpenServerToyRewardPanel or BaseClass(BasePanel)

function OpenServerToyRewardPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = ToyRewardManager.Instance
    self.resList = {
        {file = AssetConfig.open_server_toyreward_panel, type = AssetType.Main}
        ,{file = AssetConfig.openserver_toyreward_big_bg, type = AssetType.Main}
        ,{file = AssetConfig.toyreward_big, type = AssetType.Dep}

        ,{file = AssetConfig.toyreward_textures, type = AssetType.Dep}
        ,{file = AssetConfig.leveljumptexture, type = AssetType.Dep}
        
        ,{file = string.format(AssetConfig.effect,20330), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect,20332), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }

    self.timeFormat = TI18N("%s月%s日-%s月%s日")

    self.topItemData = {}
    self.topItemList = {}
    self.extra = {inbag = false, nobutton = true}

    self.SetRewardTimeListerner = function(data) self:SetRewardTime(data) end
    self.GetRewardOneListerner = function(type,id) self:GetRewardOne(type,id) end
    self.GetRewardTenListerner = function(type,id) self:GetRewardTen(type,id) end

    self.timerId = nil
    self.timerEffectId = nil
    self.firstEffectTimerId = nil
    self.secondEffecttimerId = nil
    self.thirdEffecttimerId = nil

    self.wingLeftTimerId = nil
    self.wingRightTimerId = nil

    self.wingLeftDirection = 1
    self.wingRightDirection = 1

    self.firstEffect = nil
    self.secondEffect = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    

    self.isReward = false
    self.showNum = nil
    self.hasReward = false

    self.alponeTimerId = nil
    self.slotList = {}
    self.nameList = {}


    self.imgLoaderOne = nil
    self.imgLoaderTwo = nil
end

function OpenServerToyRewardPanel:__delete()
    OpenBetaManager.Instance.onTurnTime:RemoveListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardTenListerner)

    if self.hasReward then
        OpenBetaManager.Instance:send14040()
    end
    self.hasReward = false


    for i,v in ipairs(self.slotList) do
        v:DeleteMe()
    end
    self.slotList = nil

    self.nameList = nil

    if self.bmBmExt ~= nil then
        self.bmBmExt:DeleteMe()
        self.bmBmExt = nil
    end
    if self.showMaskTimeId ~= nil then
        LuaTimer.Delete(self.showMaskTimeId)
        self.showMaskTimeId = nil
    end

    if self.timerEffectId ~= nil then
        LuaTimer.Delete(self.timerEffectId)
        self.timerEffectId = nil
    end

    if self.firstEffectTimerId ~= nil then
        LuaTimer.Delete(self.firstEffectTimerId)
        self.firstEffectTimerId = nil
    end

     if self.secondEffecttimerId ~= nil then
        LuaTimer.Delete(self.secondEffecttimerId)
        self.secondEffecttimerId = nil
    end

     if self.thirdEffecttimerId ~= nil then
        LuaTimer.Delete(self.thirdEffecttimerId)
        self.thirdEffecttimerId = nil
    end

    if self.alponeTimerId ~= nil then
        Tween.Instance:Cancel(self.alponeTimerId)
        self.alponeTimerId = nil
    end

    if self.getPanelTweenId ~= nil then
        Tween.Instance:Cancel(self.getPanelTweenId)
        self.getPanelTweenId = nil
    end

    if self.wingLeftTimerId ~= nil then
        Tween.Instance:Cancel(self.wingLeftTimerId)
        self.wingLeftTimerId = nil
    end

    if self.wingRightTimerId ~= nil then
        Tween.Instance:Cancel(self.wingRightTimerId)
        self.wingRightTimerId = nil
    end

    if self.firstEffect ~= nil then
        self.firstEffect:DeleteMe()
        self.firstEffect = nil
    end

    if self.secondEffect ~= nil then
        self.secondEffect:DeleteMe()
        self.secondEffect = nil
    end

    if self.topItemList ~= nil then
        for i,v in ipairs(self.topItemList) do
          v:DeleteMe()
        end
    end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    if self.imgLoaderOne ~= nil then
        self.imgLoaderOne:DeleteMe()
        self.imgLoaderOne = nil
    end

     if self.imgLoaderTwo ~= nil then
        self.imgLoaderTwo:DeleteMe()
        self.imgLoaderTwo = nil
    end

    self.getIconImage.sprite = nil

    self.bigImage.sprite =nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function OpenServerToyRewardPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_toyreward_panel))
    self.gameObject.name = "OpenServerToyRewardPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.transform
    
    UIUtils.AddBigbg(self.transform:Find("BackBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.openserver_toyreward_big_bg)))

    self.bigImage = self.transform:Find("RightBackBg/ToyMachine"):GetComponent(Image)
    self.bigImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_big, "ToyRewardMachine")


    self.owerTxt = self.transform:Find("Tobbg/LeftText"):GetComponent(Text)
    self.costTxt = self.transform:Find("Tobbg/RightText"):GetComponent(Text)
    self.imgLoaderOne = SingleIconLoader.New(self.transform:Find("Tobbg/Icon").gameObject)

    self.scrollRect = self.transform:Find("RectScroll")
    -- self.scrollRect:GetComponent(ScrollRect).enabled = false
    self.container = t:Find("RectScroll/Container")
    self.itemCloner = t:Find("RectScroll/TopItemSlot")
    self.itemCloner.gameObject:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container.gameObject, {axis = BoxLayoutAxis.X, border = 5, cspacing = 10})
    self.timeText = self.transform:Find("TopContainer/TimeBg/TimeText"):GetComponent(Text)

    -- local buttonContainTr = t:Find("ButtomContain")
    -- for i = 1, 2 do
    --     local slot = ItemSlot.New()
    --     local item = buttonContainTr:Find(string.format("TopMask/ItemContainer%s",i))
    --     UIUtils.AddUIChild(item.gameObject, slot.gameObject)
    --     table.insert(self.slotList, slot)
    --     table.insert(self.nameList, item:Find("Text"):GetComponent(Text))
    -- end
    -- buttonContainTr:Find("TopMask/TopTab/Text"):GetComponent(Text).text = TI18N("每天前10次可获")

    self.buttonOne = t:Find("ButtonLeft"):GetComponent(Button)
    self.buttonTen = t:Find("ButtonRight"):GetComponent(Button)
    self.buttonOneImg = t:Find("ButtonLeft"):GetComponent(Image)
    self.buttonTenImg = t:Find("ButtonRight"):GetComponent(Image)

    self.buttonOne.onClick:AddListener(function() self:ButtonClick(ToyRewardEumn.Type.One) end)
    self.buttonTen.onClick:AddListener(function() self:ButtonClick(ToyRewardEumn.Type.Ten) end)

    self.wing = t:Find("WingbBg")
    self.leftWing = t:Find("WingbBg/LeftWing")
    self.rightWing = t:Find("WingbBg/RightWing")

    self.toyRewardMachine = t:Find("RightBackBg")



    self.getIcon = t:Find("GetIcon")
    self.getIcon.gameObject:SetActive(false)
    self.getIcon.localPosition = Vector3(144, -55, -400)
    self.getIconImage = t:Find("GetIcon"):GetComponent(Image)
    self.getIconImage.enabled = false

    self.firstEffect = BibleRewardPanel.ShowEffect(20330, self.gameObject.transform, Vector3(0.81,0.81,0.81), Vector3(0, -6.4, -400))
    self.firstEffect:SetActive(false)

    self.secondEffect = BibleRewardPanel.ShowEffect(20332, self.getIcon, Vector3.one, Vector3(0, 0, -400))
    self.secondEffect:SetActive(false)

    self.maskPanel = t:Find("MaskPanel")
    self.maskPanelImage= self.maskPanel:GetComponent(Image)

    self.msgTxt = self.transform:Find("MsgText"):GetComponent(Text)
    self.msgTxt:GetComponent(Button).onClick:AddListener(function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain) end)

    -- self.bmBmExt = MsgItemExt.New(t:Find("MsgText"):GetComponent(Text), 237, 17, 27)
    -- self.bmBmExt:SetData(DataCampaign.data_list[self.campId].cond_desc)
    self.noticeBtn = self.transform:Find("Notice"):GetComponent(Button)

    
    self.oneMsgTxt = MsgItemExt.New(self.transform:Find("OneMsgText"):GetComponent(Text), 130, 13, 40)
    self.tenMsgTxt = MsgItemExt.New(self.transform:Find("TenMsgText"):GetComponent(Text), 150, 13, 40)
end

function OpenServerToyRewardPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerToyRewardPanel:OnOpen()
    self:Clear()
    self:Grey(false)

    OpenBetaManager.Instance.onTurnTime:AddListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:AddListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:AddListener(self.GetRewardTenListerner)


    local campData = DataCampaign.data_list[self.campId]

    --消耗物品
    self.toyId = tonumber(campData.camp_cond_client)
    self.costId = DataCampTurn.data_turnplate[self.toyId].cost[1][1]

    if DataItem.data_get[self.costId] == nil then 
        Log.Error(string.format("DataCampTurn配置消耗id不存在，id:%s",self.costId))
    end

    self.imgLoaderOne:SetSprite(SingleIconType.Item, DataItem.data_get[self.costId].icon)

    self.turnplate_data = DataCampTurn.data_turnplate[self.toyId]
    self.ext_data = DataCampTurn.data_ext[self.toyId]

    --活力值
    self.active_cost = self.ext_data.active_cost

    --时间
    local open_time = CampaignManager.Instance.open_srv_time
    local end_time = open_time + campData.cli_end_time[1][2] * 24 * 3600 + campData.cli_end_time[1][3]
    self.timeText.text = string.format( self.timeFormat, tonumber(os.date("%m", open_time)), tonumber(os.date("%d", open_time)), tonumber(os.date("%m", end_time)), tonumber(os.date("%d", end_time)))

    --tips
    self.noticeBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {campData.cond_desc}, isChance = true})
        TipsManager.Instance.model:ShowChance({gameObject = self.noticeBtn.gameObject, chanceId = 214, special = true, isMutil = true})
    end)


    self.wing.gameObject:SetActive(true)
    self.wingLeftDirection = 1
    self.wingRightDirection = 1

    self.leftWing.localRotation = Quaternion.Euler(0, 0, 0)
    self.rightWing.localRotation = Quaternion.Euler(0, 0, 0)
    self.wing.gameObject:SetActive(true)
    self.isReward = false
    self.getIcon.gameObject:SetActive(false)
    self.maskPanel.gameObject:SetActive(false)
    self.toyRewardMachine.gameObject:SetActive(true)

    self.firstEffect:SetActive(false)
    self.secondEffect:SetActive(false)

    OpenBetaManager.Instance:send14038()

    self:RotationLeftWing()
    self:RotationRightWing()
    self:UpdateTopItemList()
    self:UpdateActiveVal()
    self:UpdateBtnTxt()
    -- self:UpdateAllData()
end

function OpenServerToyRewardPanel:OnHide()
    self:Clear()
    if self.hasReward then
        OpenBetaManager.Instance:send14040()
    end
    self.hasReward = false
end

function OpenServerToyRewardPanel:Clear()

    if not BaseUtils.is_null(self.firstEffect) then
        self.firstEffect.gameObject:SetActive(false)
    end

    if not BaseUtils.is_null(self.secondEffect) then
        self.secondEffect.gameObject:SetActive(false)
    end

    OpenBetaManager.Instance.onTurnTime:RemoveListener(self.SetRewardTimeListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardOneListerner)
    OpenBetaManager.Instance.onTurnResult:RemoveListener(self.GetRewardTenListerner)

    if self.showMaskTimeId ~= nil then
        LuaTimer.Delete(self.showMaskTimeId)
        self.showMaskTimeId = nil
    end

    if self.timerEffectId ~= nil then
        LuaTimer.Delete(self.timerEffectId)
        self.timerEffectId = nil
    end

    if self.firstEffectTimerId ~= nil then
        LuaTimer.Delete(self.firstEffectTimerId)
        self.firstEffectTimerId = nil
    end

     if self.secondEffecttimerId ~= nil then
        LuaTimer.Delete(self.secondEffecttimerId)
        self.secondEffecttimerId = nil
    end

     if self.thirdEffecttimerId ~= nil then
        LuaTimer.Delete(self.thirdEffecttimerId)
        self.thirdEffecttimerId = nil
    end

    if self.alponeTimerId ~= nil then
        Tween.Instance:Cancel(self.alponeTimerId)
        self.alponeTimerId = nil
    end

    if self.wingLeftTimerId ~= nil then
        Tween.Instance:Cancel(self.wingLeftTimerId)
        self.wingLeftTimerId = nil
    end

    if self.wingRightTimerId ~= nil then
        Tween.Instance:Cancel(self.wingRightTimerId)
        self.wingRightTimerId = nil
    end

     if self.getPanelTweenId ~= nil then
        Tween.Instance:Cancel(self.getPanelTweenId)
        self.getPanelTweenId = nil
    end
end



function OpenServerToyRewardPanel:RotationLeftWing()
    if self.wingLeftTimerId ~= nil then
        Tween.Instance:Cancel(self.wingLeftTimerId)
        self.wingLeftTimerId = nil
    end
    self.wingLeftTimerId  = Tween.Instance:ValueChange(-20 * self.wingLeftDirection ,20 * self.wingLeftDirection ,2, nil, LeanTweenType.Linear,function(value) self:RotateLeftWingValueChange(value) end):setLoopPingPong().id
    self.wingLeftDirection  = self.wingLeftDirection  * -1
end

function OpenServerToyRewardPanel:RotationRightWing()
    if self.wingRightTimerId ~= nil then
        Tween.Instance:Cancel(self.wingRightTimerId)
        self.wingRightTimerId = nil
    end
    self.wingRightTimerId  = Tween.Instance:ValueChange(20 * self.wingRightDirection ,-20 * self.wingRightDirection ,2, nil, LeanTweenType.Linear,function(value) self:RotateRightWingValueChange(value) end):setLoopPingPong().id
    self.wingRightDirection  = self.wingRightDirection  * -1
end

function OpenServerToyRewardPanel:RotateLeftWingValueChange(value)
     self.leftWing.localRotation = Quaternion.Euler(0, 0, value)
end

function OpenServerToyRewardPanel:RotateRightWingValueChange(value)
     self.rightWing.localRotation = Quaternion.Euler(0, 0, value)
end

function OpenServerToyRewardPanel:UpdateTopItemList()
    -- print(self.toyId)
    local dataList = DataCampTurn.data_item
    -- 处理图片排列P
    local lev = RoleManager.Instance.RoleData.lev
    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    local count = 0
    for i, data in ipairs(dataList) do
        if data.type == self.toyId then
            if count == 8 then
                break
            end
            if (lev >= data.lev_min and lev <= data.lev_max) or (data.lev_min == 0 and data.lev_max == 0) then 
                if classes == data.classes or data.classes == 0 then 
                    if sex == data.sex or data.sex == 2 then 
                        count = count + 1
                        local slot = nil
                        local Id = data.item_id
                        local itemData = DataItem.data_get[Id]
                        if self.topItemList[i] == nil then
                            local template = GameObject.Instantiate(self.itemCloner.gameObject)
                            slot = ToyRewardItem.New(template)
                            self.layout:AddCell(slot.ItemSlot.gameObject)
                            self.topItemList[i] = slot
                        else
                            slot = self.topItemList[i]
                            slot.ItemSlot.gameObject:SetActive(true)
                        end
                        slot.ItemSlot:SetAll(itemData, self.extra)
                        slot:SetQualityInBag(itemData.quality)
                        slot.ItemSlot:SetNum(data.num)
                        slot:ShowEffect(20223, data.is_effect)
                    end
                end
            end
        end
    end
end


function OpenServerToyRewardPanel:UpdateAllData()
    self:UpdateHas()

    local roleLev = RoleManager.Instance.RoleData.lev
    local rewardList = DataCampTurn.data_total_reward[self.toyId].item_list
    local count = 0
    for i,v in ipairs(rewardList) do
        local topId = tonumber(v[1])
        local bind = tonumber(v[2])
        local topNum = tonumber(v[3])
        local minLev = tonumber(v[4])
        local maxLev = tonumber(v[5])

        if (roleLev >= minLev and roleLev <= maxLev) or (minLev == 0 and maxLev == 0) then
            count = count + 1
            local topItemData = DataItem.data_get[topId]
            local slot = self.slotList[count]
            if slot ~= nil then
                slot:SetAll(topItemData, self.extra)
                slot:SetNum(topNum)
                self.nameList[count].text = DataItem.data_get[topId].name
            end
        end
    end
end

function OpenServerToyRewardPanel:UpdateActiveVal()
    local active_val = RoleManager.Instance.RoleData.energy
    if active_val > self.active_cost then active_val = self.active_cost end
    -- self.msgTxt.text = string.format(TI18N("获得<color='#2fc823'>%s</color>活跃度可免费扭蛋一次（<color='#fff000'>%s</color>/<color='#2fc823'>%s</color>）"), self.active_cost, active_val, self.active_cost)
    self.msgTxt.text = string.format(TI18N("获得<color='#2fc823'>%s</color>活跃度可免费扭蛋一次"), self.active_cost)
end

function OpenServerToyRewardPanel:UpdateBtnTxt()
    local onecount = BackpackManager.Instance:GetItemCount(self.costId)
    local str1 = TI18N("拥有{assets_1,%s,1},可免费扭蛋")
    local str2 = TI18N("花费{assets_1,90002,%s}购买%s{assets_2,%s}赠送%s次扭蛋机会")

    if onecount >= 1 then 
        self.oneMsgTxt:SetData(string.format(str1, self.costId))
    else
        self.oneMsgTxt:SetData(string.format(str2, self.ext_data.gold_cost, 5, self.turnplate_data.gain[1][1], 1))
    end

    if onecount >= 10 then 
        self.tenMsgTxt:SetData(string.format(str1, self.costId))
    else
        self.tenMsgTxt:SetData(string.format(str2, self.ext_data.ten_gold_cost, 50, self.turnplate_data.gain[1][1], 10))
    end
    
end

-- 协议14038回调
function OpenServerToyRewardPanel:SetRewardTime()
    local max = self.ext_data.gold_cost_max
    if OpenBetaManager.Instance.model.turnplateList[self.toyId] == nil then
        self.costTxt.text = max .."/".. max
    else
        local num = max - OpenBetaManager.Instance.model.turnplateList[self.toyId].num
        self.costTxt.text = num .. "/" .. max
    end
    self:UpdateHas()
end


function OpenServerToyRewardPanel:UpdateHas()
    local count = BackpackManager.Instance:GetItemCount(DataCampTurn.data_turnplate[self.toyId].cost[1][1])
    if count > 0 then
        self.owerTxt.text = string.format("%s/1", count)
    else
        self.owerTxt.text = string.format("<color='#ff0000'>%s</color>/1", count)
    end
end


function OpenServerToyRewardPanel:ButtonClick(rewardType)
    if self.hasReward then
        return
    end

    local count = BackpackManager.Instance:GetItemCount(self.costId)
    local enough = false
    if rewardType == ToyRewardEumn.Type.One then
        enough = (count >= 1)
    elseif rewardType == ToyRewardEumn.Type.Ten then
        enough = (count >= 10)
    end


    local func  = function() 
        if rewardType == ToyRewardEumn.Type.One then
            OpenBetaManager.Instance:send14039(tonumber(DataCampaign.data_list[self.campId].camp_cond_client))
        elseif rewardType == ToyRewardEumn.Type.Ten then
            OpenBetaManager.Instance:send14041(tonumber(DataCampaign.data_list[self.campId].camp_cond_client), 10)
        end
    end

    if not enough then
        local descString = TI18N("是否确认花费{assets_1,90002,%s}购买%s{assets_2,%s}，同时免费进行扭蛋？")
        if rewardType == ToyRewardEumn.Type.One then
            descString = string.format(descString, self.ext_data.gold_cost, 5, self.turnplate_data.gain[1][1])
        else
            descString = string.format(descString, self.ext_data.ten_gold_cost, 50, self.turnplate_data.gain[1][1])
        end
        self.hasReward = false
        
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureCallback = func
        confirmData.content = descString
        NoticeManager.Instance:ConfirmTips(confirmData)
    else
        func()
    end


    self.rewardType = rewardType
end

-- 协议14039回调
function OpenServerToyRewardPanel:GetRewardOne(type,id)
    if id ~= 0 and type == self.toyId and self.rewardType == ToyRewardEumn.Type.One then
        self.hasReward = true
        self:PlayAnimation(type,id)
    end
end

-- 协议14041回调
function OpenServerToyRewardPanel:GetRewardTen(type,id)
    if id ~= 0 and type == self.toyId and self.rewardType == ToyRewardEumn.Type.Ten then
        self.hasReward = true
        self:PlayAnimation(type,id)
    end
end

function OpenServerToyRewardPanel:PlayAnimation(type,id)
    self.getIcon.gameObject:SetActive(false)
    self.getIconImage.enabled = false
    self.getIcon.localPosition = Vector3(144, -55, -400)

    self:Grey(true)
    self.toyRewardMachine.gameObject:SetActive(false)
    self.firstEffect:SetActive(true)
    self.firstEffectTimerId = LuaTimer.Add(4100, function() self:PlayAnimationNext(type, id) end)
    self.showMaskTimeId = LuaTimer.Add(3200, function() self:ShowBlackMask() end)
end

function OpenServerToyRewardPanel:Grey(bool)
    if bool then
        self.buttonOneImg.color = Color.grey
        self.buttonTenImg.color = Color.grey
    else
        self.buttonOneImg.color = Color.white
        self.buttonTenImg.color = Color.white
    end
end

function OpenServerToyRewardPanel:ShowBlackMask()
    self:maskAlponeChange(0)
    self.maskPanel.gameObject:SetActive(true)
    self.alponeTimerId  = Tween.Instance:ValueChange(0, 180, 0.5, nil, LeanTweenType.Linear, function(value) self:maskAlponeChange(value) end).id
end

function OpenServerToyRewardPanel:PlayAnimationNext(type,id)
   self.maskPanel.gameObject:SetActive(true)
   self.firstEffect:SetActive(false)
   self.toyRewardMachine.gameObject:SetActive(true)

    self.showNum = (BaseUtils.BASE_TIME - 1) % 4 + 1
    self.getIcon.gameObject:SetActive(true)
    self.getIconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.toyreward_textures,"egg" .. self.showNum)
    self.getIconImage:SetNativeSize()

   self.secondEffect:SetActive(true)

   self.getPanelTweenId = Tween.Instance:MoveLocal(self.getIcon.gameObject, Vector3.zero, 0.5, function() self:OpenGetPanel(type,id) end, LeanTweenType.easeOutQuart).id
end

function OpenServerToyRewardPanel:maskAlponeChange(value)
    local t = value / 255
    local color = Color(0,0,0,t)

    self.maskPanelImage.color = color
end

function OpenServerToyRewardPanel:OpenGetPanel(type,id)
    self.getIconImage.enabled = true
    if self.alponeTimerId ~= nil then
        Tween.Instance:Cancel(self.alponeTimerId)
        self.alponeTimerId = nil
    end
    if self.rewardType == ToyRewardEumn.Type.One then
        self:OpenGetOne(type,id)
    elseif self.rewardType == ToyRewardEumn.Type.Ten then
        self:OpenGetTen(type,id)
    end
end

function OpenServerToyRewardPanel:OpenGetOne(type,id)
    if self.OpenServerToyRewardPanel == nil then
        self.OpenServerToyRewardPanel = ToyRewardGetPanel.New(self, self.parent.transform.parent, true)
    end
    self.OpenServerToyRewardPanel:Show({self.rewardType,id,self.showNum})
end

function OpenServerToyRewardPanel:OpenGetTen(type,id)
    if self.OpenServerToyRewardPanel == nil then
        self.OpenServerToyRewardPanel = ToyRewardGetPanel.New(self, self.parent.transform.parent, true)
    end
    self.OpenServerToyRewardPanel:Show({self.rewardType,nil,self.showNum})
end

-- 开蛋界面加载完
function OpenServerToyRewardPanel:PanelOpened()
    self.getIconImage.enabled = false
    self.getIcon.gameObject:SetActive(false)
    self.maskPanel.gameObject:SetActive(false)
end

-- 开蛋界面关闭
function OpenServerToyRewardPanel:PanelClosed()
    self.hasReward = false
    self.isReward = false
    self:Grey(false)
    -- self:RotationLeftWing()
    -- self:RotationRightWing()
end
