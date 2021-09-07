-- @author 黄耀聪
-- @date 2017年6月12日, 星期一

QuestKingScrollMarked = QuestKingScrollMarked or BaseClass(BaseWindow)

function QuestKingScrollMarked:__init(model)
    self.model = model
    self.name = "QuestKingScrollMarked"
    self.windowId = WindowConfig.WinID.quest_king_scroll_mark

    self.resList = {
        {file = AssetConfig.quest_king_scroll_marked, type = AssetType.Main},
        {file = AssetConfig.quest_king_textures, type = AssetType.Dep},
    }

    self.originHeight = 90
    self.maxHeight = 455
    self.originWidth = 469

    self.questId = nil
    self.envelop = nil

    self.slotList = {}

    self.updateListener = function() self:RollUp(200, function() self:Release() end) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function QuestKingScrollMarked:__delete()
    self.OnHideEvent:Fire()
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.contentExt ~= nil then
        self.contentExt:DeleteMe()
        self.contentExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.rewardLayout ~= nil then
        self.rewardLayout:DeleteMe()
        self.rewardLayout = nil
    end
    if self.confirmData ~= nil then
        self.confirmData:DeleteMe()
        self.confirmData = nil
    end
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.data:DeleteMe()
            end
        end
    end
    self:AssetClearAll()
end

function QuestKingScrollMarked:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.quest_king_scroll_marked))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.mainRect = t:Find("Main")
    self.mainRect.sizeDelta = Vector2(self.originWidth, self.originHeight)

    local main = t:Find("Main/Bg")
    self.closeBtn = main:Find("Close"):GetComponent(Button)

    self.layout = LuaBoxLayout.New(main:Find("InfoArea/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    self.title1 = main:Find("InfoArea/Title1").gameObject
    self.title2 = main:Find("InfoArea/Title2").gameObject
    self.descExt = MsgItemExt.New(main:Find("InfoArea/Desc"):GetComponent(Text), 340, 16, 18.53)
    self.contentExt = MsgItemExt.New(main:Find("InfoArea/Content"):GetComponent(Text), 340, 16, 18.53)

    self.refreshBtn = main:Find("ButtonArea/Refresh"):GetComponent(Button)
    self.gotoBtn = main:Find("ButtonArea/Goto"):GetComponent(Button)
    self.giveupBtn = main:Find("ButtonArea/Giveup"):GetComponent(Button)

    self.rewardLayout = LuaBoxLayout.New(main:Find("RewardArea/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 5})

    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    self.refreshBtn.onClick:AddListener(function() self:OnRefresh() end)
    self.gotoBtn.onClick:AddListener(function() self:OnGoto() end)
    self.giveupBtn.onClick:AddListener(function() self:OnGiveup() end)
end

function QuestKingScrollMarked:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function QuestKingScrollMarked:OnOpen()
    -- print(debug.traceback())
    self:RemoveListeners()
    QuestKingManager.Instance.updateEvent:AddListener(self.updateListener)

    self.envelop = self.openArgs[1]

    self:Release()
end

function QuestKingScrollMarked:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.model.selectEnvelop = nil
end

function QuestKingScrollMarked:RemoveListeners()
    QuestKingManager.Instance.updateEvent:RemoveListener(self.updateListener)
end

-- 卷起
function QuestKingScrollMarked:RollUp(delta, callback)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.counter = 0
    self.timerId = LuaTimer.Add(0, 22, function()
        self.counter = self.counter + 1
        self.mainRect.sizeDelta = Vector2(self.originWidth, self.maxHeight - self.counter * (self.maxHeight - self.originHeight) / math.ceil(delta / 22))
        if self.mainRect.sizeDelta.y <= self.originHeight then
            if self.timerId ~= nil then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
                if callback ~= nil then
                    LuaTimer.Add(200, callback)
                end
            end
        end
    end)
end

function QuestKingScrollMarked:OnClose()
    self:RollUp(200, function() WindowManager.Instance:CloseWindow(self, false) end)
end

-- 展开
function QuestKingScrollMarked:Release()
    for _,v in ipairs(self.model.currentList) do
        if v.envelop == self.envelop then
            self.questId = v.quest_id
            break
        end
    end
    self:Reload()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.currentPos = 0
    self.currentVel = 0
    self.timerId = LuaTimer.Add(0, 10, function()
        self.mainRect.sizeDelta = Vector2(self.originWidth, self.originHeight + self.currentPos)
        self.currentPos, self.currentVel = self:Calculate(self.currentPos, self.currentVel)
        if self.currentVel == 0 and self.currentPos == self.maxHeight - self.originHeight then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
            self.closeBtn.gameObject:SetActive(true)
        end
    end)
end

-- 计算下一帧掉落位置
function QuestKingScrollMarked:Calculate(pos, velocity)
    pos = pos + velocity
    if pos >= self.maxHeight - self.originHeight then
        velocity = - math.floor(velocity * 0.5)
        pos = self.maxHeight - self.originHeight
    else
        velocity = velocity + 2
    end
    return pos, velocity
end

function QuestKingScrollMarked:Reload()
    local questData = QuestManager.Instance:GetQuest(self.questId)
    if questData == nil then
        return
    end

    local list = {}
    for _,v in ipairs(questData.rewards_commit) do
        local data = QuestEumn.AwardItemInfo(v)
        if data ~= nil then
            table.insert(list, data)
        end
    end
    self.rewardLayout:ReSet()
    for i,v in ipairs(list) do
        if self.slotList[i] == nil then
            self.slotList[i] = {}
            self.slotList[i].slot = ItemSlot.New()
            self.slotList[i].data = ItemData.New()
        end
        self.slotList[i].data:SetBase(DataItem.data_get[v.baseid])
        self.slotList[i].slot:SetAll(self.slotList[i].data, {inbag = false, nobutton = true})
        self.slotList[i].slot:SetNum(v.count)
        self.rewardLayout:AddCell(self.slotList[i].slot.gameObject)
    end
    for i=#list + 1,#self.slotList do
        self.slotList[i].slot.gameObject:SetActive(false)
    end

    local content = ""
    local len = #questData.progress
    local ccount = 0

    for i,v in ipairs(questData.progress) do
        content = StringHelper.MatchBetweenSymbols(v.desc, "%[", "%]")[1]
        break
    end

    -- print(string.format("%s_%s",self.envelop, self.questId))
    self.contentExt:SetData(DataQuestKing.data_quest[string.format("%s_%s",self.envelop, self.questId)].desc..TI18N("\n\n<color='#249015'>任务不满意？可以点击刷新哟~</color>"))
    self.descExt:SetData(questData.trace_msg)

    if self.contentExt.contentTrans.sizeDelta.x < 340 then
        self.contentExt.contentTrans.sizeDelta = Vector2(340, self.contentExt.contentTrans.sizeDelta.y)
    end
    if self.descExt.contentTrans.sizeDelta.x < 340 then
        self.descExt.contentTrans.sizeDelta = Vector2(340, self.descExt.contentTrans.sizeDelta.y)
    end

    self.layout:ReSet()
    self.layout:AddCell(self.title1)
    self.layout:AddCell(self.descExt.contentTrans.gameObject)
    self.layout:AddCell(self.title2)
    self.layout:AddCell(self.contentExt.contentTrans.gameObject)

end

function QuestKingScrollMarked:OnRefresh()
    self.confirmData = self.confirmData or NoticeConfirmData.New()

    local cost = nil
    for i,v in ipairs(self.model.stageTimesCostTab[DataQuestKing.data_envelop_info[self.envelop].stage]) do
        cost = v.cost
        if self.model.rf_times <= v.max_times then
            break
        end
    end
    if cost == nil or #cost == 0 then
        self.confirmData.content = TI18N("刷新任务<color='#ffff00'>第一次</color>免费，后续将消耗一定资产，是否刷新？（本次刷新免费）")
    else
        local strtab = {}
        for _,v in ipairs(cost) do
            if v[1] < 90000 then
                table.insert(strtab, string.format("%s<color='#00ff00'>×%s</color>", ColorHelper.color_item_name(DataItem.data_get[v[1]].quality, DataItem.data_get[v[1]].name), v[2]))
            else
                table.insert(strtab, string.format("<color='#00ff00'>%s</color>{assets_2,%s}", v[2], v[1]))
            end
        end
        self.confirmData.content = string.format(TI18N("刷新任务<color='#ffff00'>第一次</color>免费，后续将消耗一定资产，是否刷新？（本次刷新消耗%s）"), table.concat(strtab, ","))
    end

    self.confirmData.sureCallback = function() QuestKingManager.Instance:send10252(self.envelop) end
    NoticeManager.Instance:ConfirmTips(self.confirmData)
end

function QuestKingScrollMarked:OnGoto()
    if self.questId ~= nil then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s，快去完成吧{face_1,1}"), DataQuestKing.data_quest[string.format("%s_%s",self.envelop, self.questId)].desc))
        self:RollUp(200, function() WindowManager.Instance:CloseWindow(self, false) LuaTimer.Add(300, function() QuestManager.Instance:DoQuest(QuestManager.Instance.questTab[self.questId]) end) end)
    end
end

function QuestKingScrollMarked:OnGiveup()
    self.confirmData = self.confirmData or NoticeConfirmData.New()

    local count_succ = 0
    local count_fail = 0
    for _,envelop in ipairs(DataQuestKing.data_envelop[self.model.stage]) do
        if self.model.finishTab[envelop] ~= nil then
            if self.model.finishTab[envelop].status == 1 then
                count_succ = count_succ + 1
            else
                count_fail = count_fail + 1
            end
        end
    end
    -- if DataQuestKing.data_stage[self.model.stage].lock_count < DataQuestKing.data_stage[self.model.stage].count - count_fail then
    --     self.confirmData.content = TI18N("是否放弃此任务")
    -- else
        self.confirmData.content = TI18N("放弃任务将<color='#00ff00'>可能导致您无法完成本阶段任务目标</color>，是否放弃此任务？")
    -- end

    self.confirmData.sureCallback = function()
        if self.questId ~= nil then
            QuestKingManager.Instance:send10205(self.questId)
        end
        self:RemoveListeners()
        self:RollUp(300, function() WindowManager.Instance:CloseWindow(self) end)
    end

    NoticeManager.Instance:ConfirmTips(self.confirmData)
end
