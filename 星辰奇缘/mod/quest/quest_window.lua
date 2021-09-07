-- ------------------------------
-- 任务大面板
-- hosr
-- ------------------------------
QuestWindow = QuestWindow or BaseClass(BaseWindow)

function QuestWindow:__init(model)
    self.model = model
    self.name = "QuestWindow"
    self.windowId = WindowConfig.WinID.taskwindow
    self.resList = {
        {file = AssetConfig.questwindow, type = AssetType.Main},
        {file = AssetConfig.bigatlas_taskBg, type = AssetType.Main},
    }
    self.treeTab = {}
    self.currentData = nil
    self.currentIndex = 0
    self.itemCellTab = {}

    self.questPosition = {}
end

function QuestWindow:__delete()
    for i,v in ipairs(self.itemCellTab) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemCellTab = nil

    self:CountDonwEnd()
    for k,v in pairs(self.treeTab) do
        v:DeleteMe()
    end
    self.treeTab = nil
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function QuestWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.questwindow))
    self.gameObject.name = "QuestWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self:InitLeft()
    self:InitRight()

    local tabGroupObj = self.transform:Find("Main/TabButtonGroup").gameObject
    local setting = {
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(tabGroupObj, function(index) self:TabChange(index) end, setting)

    self:OnOpen()
end

function QuestWindow:InitLeft()
    self.baseItem = self.transform:Find("Main/Left/BaseItem").gameObject
    self.baseItem:SetActive(false)
    self.leftContainer = self.transform:Find("Main/Left/Container").gameObject
end

function QuestWindow:ClickDetail(data)
    self:ShowDetail(data)
end

function QuestWindow:InitRight()
    self.taskName = self.transform:Find("Main/Right/Name"):GetComponent(Text)
    self.contentTxt = self.transform:Find("Main/Right/Content"):GetComponent(Text)
    self.descTxt = self.transform:Find("Main/Right/Desc"):GetComponent(Text)
    self.buttonObj = self.transform:Find("Main/Right/Button").gameObject
    self.buttonLabel = self.buttonObj.transform:Find("Text"):GetComponent(Text)
    self.button = self.buttonObj:GetComponent(Button)
    self.buttonImg = self.buttonObj:GetComponent(Image)
    self.helpBtnObj = self.transform:Find("Main/Right/HelpButton").gameObject
    self.helpBtn = self.helpBtnObj:GetComponent(Button)
    self.container = self.transform:Find("Main/Right/Award").gameObject
    self.giveupObj = self.transform:Find("Main/Right/GiveupButton").gameObject
    self.giveupBtn = self.giveupObj:GetComponent(Button)
    self.openBtnObj = self.transform:Find("Main/Right/OpenButton").gameObject
    self.openBtn = self.openBtnObj:GetComponent(Button)
    self.transform:Find("Main/Right/Image"):GetComponent(Image).enabled = false
    UIUtils.AddBigbg(self.transform:Find("Main/Right/Image"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_taskBg)))

    self.giveupObj:SetActive(false)
    self.openBtnObj:SetActive(false)

    self.button.onClick:AddListener(function() self:OnClickButton() end)
    self.helpBtn.onClick:AddListener(function() self:OnClickHelp() end)
    self.giveupBtn.onClick:AddListener(function() self:OnClickGiveup() end)
    self.openBtn.onClick:AddListener(function() self:OnClickOpen() end)
end

function QuestWindow:OnOpen()
    self.cacheMode = CacheMode.Destroy
end

function QuestWindow:OnHide()
end

function QuestWindow:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.taskwindow)
end

function QuestWindow:OnClickOpen()
    self.cacheMode = CacheMode.Visible
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskdrama)
end

-- 做任务
function QuestWindow:OnClickButton()
    if self.currentData == nil then
        return
    end

    if self.currentData.type == 1 then
        QuestManager.Instance:DoQuest(self.currentData.data)
    elseif self.currentData.type == 2 then
        local args = StringHelper.Split(self.currentData.data.accpet_type, ",")
        if tonumber(args[1]) == QuestEumn.LabelAct.npc then
            local npcId = tonumber(args[2])
            if npcId == nil then
                local ll = {}
                for a in string.gmatch(args[2], "(%d+)") do
                    table.insert(ll, a)
                end
                npcId = ll[RoleManager.Instance.RoleData.classes]
            end
            local key = BaseUtils.get_unique_npcid(npcId, 1)
            QuestManager.Instance.model:FindNpc(key)
        elseif tonumber(args[1]) == QuestEumn.LabelAct.panel then
            local win = tonumber(args[2])
            local ll = {}
            for i = 3, #args do
                table.insert(ll, args[i])
            end
            WindowManager.Instance:OpenWindowById(win, ll)
        end
    end
    self:Close()
end

-- 求助
function QuestWindow:OnClickHelp()
end

-- 放弃
function QuestWindow:OnClickGiveup()
    if self.currentData == nil then
        return
    end
    QuestManager.Instance:GiveUp(self.currentData.data)
end

function QuestWindow:FormatQuestData()
    local list = {}
    for k,questData in pairs(QuestManager.Instance.questTab) do
        if questData.sec_type ~= QuestEumn.TaskType.camp_inquire 
            and questData.sec_type ~= QuestEumn.TaskType.summer 
            and questData.sec_type ~= QuestEumn.TaskType.sign_draw 
            and questData.sec_type ~= QuestEumn.TaskType.april_treasure 
            and questData.sec_type ~= QuestEumn.TaskType.integral_exchange 
            and questData.sec_type ~= QuestEumn.TaskType.war_order
            then
                if list[questData.sec_type] == nil then
                    list[questData.sec_type] = {}
                end
                table.insert(list[questData.sec_type], questData)
        end
    end
    for sec_type,secList in pairs(list) do
        table.sort(secList, function(a,b) return a.id < b.id end)
    end
    return list
end

function QuestWindow:TabChange(index)
    if self.currentIndex ~= 0 and self.currentIndex ~= index then
        self.treeTab[self.currentIndex]:HideAll()
    end
    self.currentIndex = index
    local tree = self.treeTab[index]
    local info = {}
    if tree == nil then
        tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickDetail(data) end)
        self.treeTab[index] = tree
        if index == 1 then
            local list = self:FormatQuestData()
            for type,typeTab in pairs(list) do
                local main = {label = string.format(TI18N("%s任务"), QuestEumn.TypeName[type]), height = 70, subs = {}, type = type}
                for _,questData in ipairs(typeTab) do
                    table.insert(main.subs, {label = questData.name, height = 50, callbackData = {type = 1, data = questData}})
                end
                table.insert(info, main)
            end
        elseif index == 2 then
            -- 展示任务，数据不一样
            local main = {label = TI18N("可接任务"), height = 70, subs = {}}
            for i,showData in ipairs(DataQuest.data_show) do
                table.insert(main.subs, {label = showData.name, height = 50, callbackData = {type = 2, data = showData}})
            end
            table.insert(info, main)
        end
        table.sort(info, function(a,b) return a.type < b.type end)
        tree:SetData(info)
    else
        tree:ShowAll()
    end

    if #info > 0 then
        if self.openArgs == nil then
            tree:ClickMain(1)
        else
            local questData = self.openArgs
            local mainIndex = self:GetMainIndex(questData.sec_type)
            local subIndex = self:GetSubIndex(mainIndex, questData.id)
            tree:ClickMain(mainIndex, subIndex)
        end
    end
end

function QuestWindow:GetMainIndex(sec_type)
    local tree = self.treeTab[1]
    for i,v in ipairs(tree.info) do
        if v.type == sec_type then
            return i
        end
    end
    return 1
end

function QuestWindow:GetSubIndex(mainIndex, id)
    local tree = self.treeTab[1]
    local main = tree.info[mainIndex]
    for i,v in ipairs(main.subs) do
        if v.callbackData.data.id == id then
            return i
        end
    end
    return 1
end

function QuestWindow:ShowDetail(data)
    self:CountDonwEnd()
    self.openBtnObj:SetActive(false)
    self.giveupObj:SetActive(false)
    self.helpBtnObj:SetActive(false)
    self.currentData = data
    self.chainContent = ""
    if data.type == 1 then
        -- 正常任务数据
        local questData = data.data

        if questData.sec_type == QuestEumn.TaskType.main or questData.sec_type == QuestEumn.TaskType.practice or questData.sec_type == QuestEumn.TaskType.practice_pro then
            if RoleManager.Instance.RoleData.lev >= 20 then
                self.openBtnObj:SetActive(true)
            end
        elseif questData.sec_type == QuestEumn.TaskType.chain then
            self.giveupObj:SetActive(true)
        end

        self.taskName.text = questData.name
        self.chainContent = QuestManager.Instance:GetQuestContent(questData)
        self.contentTxt.text = self.chainContent
        if questData.talk_process == "" then
            self.descTxt.text = TI18N("暂无详情")
        else
            if questData.sec_type == QuestEumn.TaskType.chain then
                self.descTxt.text = self:GetChainDesc(questData)
                if QuestManager.Instance:GetQuestCurrentLabel(questData) == QuestEumn.CliLabel.gain then
                    self.countTime = 20 * 60 - (BaseUtils.BASE_TIME - questData.accept_time)
                    if self.countTime > 0 then
                        self:AddChainCountDown()
                    end
                end
            else
                self.descTxt.text = questData.talk_process
            end
        end
        self:ShowAward(questData.rewards_commit)
        if questData.finish == QuestEumn.TaskStatus.Doing then
            self.buttonLabel.text = TI18N("前往任务")
            self.buttonLabel.color = ColorHelper.DefaultButton1
            self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        elseif questData.finish == QuestEumn.TaskStatus.Finish then
            self.buttonLabel.text = TI18N("领取奖励")
            self.buttonLabel.color = ColorHelper.DefaultButton2
            self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            self.buttonLabel.text = TI18N("接取任务")
            self.buttonLabel.color = ColorHelper.DefaultButton2
            self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        end
    elseif data.type == 2 then
        -- 展示数据
        local showData = data.data
        self.taskName.text = showData.name
        self.contentTxt.text = showData.target
        self.descTxt.text = showData.detail
        self.buttonLabel.text = TI18N("前往任务")
        self.buttonLabel.color = ColorHelper.DefaultButton1
        self.buttonImg.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        self:ShowAward({})
    end
end

function QuestWindow:ShowAward(awards)
    for _,cell in ipairs(self.itemCellTab) do
        cell.gameObject:SetActive(false)
    end
    local QuestCount = 0
    for i,v in ipairs(awards) do
        local item = QuestEumn.AwardItemInfo(v)
        if item ~= nil then
            local baseid = item.baseid
            local count = item.count
            local bind = item.bind

            local item = BackpackManager.Instance:GetItemBase(baseid)
            item.quantity = count
            item.bind = bind

            local cell = self.itemCellTab[i]
            if cell == nil then
                cell = ItemSlot.New()
                local trans = cell.gameObject.  transform
                trans:SetParent(self.container.transform)
                trans.localScale = Vector3.one
                table.insert(self.itemCellTab, cell)
            end
            cell:SetAll(item)
            cell.gameObject.transform.localPosition = Vector3(32 + QuestCount * 70, -35, 0)
            cell.gameObject:SetActive(true)
            QuestCount = QuestCount + 1
        end
    end
end

function QuestWindow:GetChainDesc(questData)
    local desc = questData.talk_process
    if #questData.progress == 0 then
        -- if cli_label == QuestEumn.CliLabel.visit then
            -- 拜访
            local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
            if npcData ~= nil then
                desc = string.gsub(desc, "npc", npcData.name)
            end
        -- end
    else
        for i,cp in ipairs(questData.progress) do
            local sp = questData.progress_ser[i]
            local cli_label = cp.cli_label
            if cli_label == QuestEumn.CliLabel.fight then
                -- 战斗
                local npcData = DataUnit.data_unit[sp.target]
                if npcData ~= nil then
                    desc = string.gsub(desc, "fight", npcData.name, 1)
                end
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                if npcData ~= nil then
                    desc = string.gsub(desc, "npc", npcData.name, 1)
                end
            elseif cli_label == QuestEumn.CliLabel.gain then
                -- 获得道具
                local itemData = DataItem.data_get[sp.target]
                if itemData ~= nil then
                    desc = string.gsub(desc, "item", itemData.name, 1)
                end
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                if npcData ~= nil then
                    desc = string.gsub(desc, "npc", npcData.name, 1)
                end
            elseif cli_label == QuestEumn.CliLabel.catchpet then
                -- 获得宠物
                local petData = DataPet.data_pet[sp.target]
                if petData ~= nil then
                    desc = string.gsub(desc, "pet", petData.name, 1)
                end
                local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                if npcData ~= nil then
                    desc = string.gsub(desc, "npc", npcData.name, 1)
                end
            end
        end
    end
    return desc
end

function QuestWindow:AddChainCountDown()
    local tstr = ""
    if self.countTime > 60 then
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>分钟,在有效时间内才有几率掉落)"), os.date("%M", self.countTime))
    else
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>秒,在有效时间内才有几率掉落)"), os.date("%S", self.countTime))
    end

    self.contentTxt.text = self.chainContent..tstr

    self.countId = LuaTimer.Add(0, 1000, function() self:CountDonw() end)
end

function QuestWindow:CountDonw()
    local tstr = ""
    if self.countTime > 60 then
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>分钟,在有效时间内才有几率掉落)"), os.date("%M", self.countTime))
    else
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>秒,在有效时间内才有几率掉落)"), os.date("%S", self.countTime))
    end
    self.contentTxt.text = self.chainContent..tstr
    self.countTime = self.countTime - 1
    if self.countTime < 0 then
        self:CountDonwEnd()
    end
end

function QuestWindow:CountDonwEnd()
    if self.countId ~= nil then
        LuaTimer.Delete(self.countId)
        self.countId = nil
    end
    self.contentTxt.text = self.chainContent
end
