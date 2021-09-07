DialogOption = DialogOption or BaseClass()

function DialogOption:__init(main, gameObject)
    self.main = main
    self.gameObject = gameObject
    self.transform = self.gameObject.transform

    self.btnTab = {}

    self:InitPanel()
end

function DialogOption:__delete()
    self.btnTab = {}
end

function DialogOption:InitPanel()
    self.container = self.transform:Find("ScrollView/Content").gameObject
    self.containerRect = self.container:GetComponent(RectTransform)
    self.baseBtn = self.container.transform:Find("BaseButton"):GetComponent(Button)
    self.baseBtnTxt = self.baseBtn.gameObject.transform:Find("Text"):GetComponent(Text)
    self.baseBtnImg = self.baseBtn.gameObject.transform:Find("Image/TypeImg"):GetComponent(Image)
    self.baseBtn.onClick:AddListener(function() self.main:Hiden() end)
    self.baseBtn.gameObject:SetActive(false)
end

function DialogOption:ShowOption(base, tasks)
    self.baseBtn.gameObject:SetActive(false)
    for _,tab in ipairs(self.btnTab) do
        tab["gameObject"]:SetActive(false)
    end

    self.main:ShowContent(base.plot_talk)

    local isover = false
    if #base.buttons == 0 then
        if #tasks == 0 then
            self.baseBtnTxt.text = TI18N("就随便看看")
            self.baseBtnImg.sprite = self.main.assetWrapper:GetSprite(AssetConfig.dialog_res, "DialogType3")
            self.baseBtnImg:SetNativeSize()
            self.baseBtn.gameObject:SetActive(true)
        else
            self.baseBtn.gameObject:SetActive(false)
            isover = self:TaskButtons(tasks)
        end
    else
        if #tasks ~= 0 then
            isover = self:TaskButtons(tasks)
        end
        if not isover then
            self:DoButtons(base.buttons)
        end
    end

    if not isover then
        self.gameObject:SetActive(true)
    end
    return true
end

function DialogOption:DoButtons(buttons)
    for i,v in ipairs(buttons) do
        local action = v.button_id
        local args = v.button_args
        local rule = v.button_show

        local tab = self.btnTab[i]
        if tab == nil then
            local buttonObj = GameObject.Instantiate(self.baseBtn.gameObject)
            local trans = buttonObj.transform
            trans:SetParent(self.container.transform)
            trans.localScale = Vector3.one
            tab = {}
            tab["gameObject"] = buttonObj
            tab["transform"] = trans
            tab["button"] = buttonObj:GetComponent(Button)
            tab["txt"] = buttonObj.transform:Find("Text"):GetComponent(Text)
            tab["img"] = buttonObj.transform:Find("Image/TypeImg"):GetComponent(Image)
            table.insert(self.btnTab, tab)
        end

        tab["txt"].text = v.button_desc
        local imgName = "DialogType3"
        if action == 1 then
            imgName = "DialogType2"
        elseif action == 2 or action == 5 then
            imgName = "DialogType1"
        elseif action == 3 then
            imgName = "DialogType1"
            local val = QuestManager.Instance.time_cycle_max - QuestManager.Instance.time_cycle + 1
            val = val >= 0 and val or 0
            tab["txt"].text = string.format(TI18N("%s<color='#66ff00'>(今日剩余%s轮)</color>"), v.button_desc, val)
        elseif action == 6 then
            imgName = "DialogType5"
        end
        tab["img"].sprite = self.main.assetWrapper:GetSprite(AssetConfig.dialog_res, imgName)
        tab["img"]:SetNativeSize()

        tab["transform"].localPosition = Vector3(0, -(i - 1) * 50, 0)
        tab["gameObject"]:SetActive(true)

        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener(function() self.main.model:ButtonAction(action, args, rule) end)
    end
end

function DialogOption:TaskButtons(tasks)
    for i,task in ipairs(tasks) do
        if task.sec_type == QuestEumn.TaskType.cycle then
            local ok = self.main.questInfo:ShowQuest(task)
            return ok
        elseif task.sec_type == QuestEumn.TaskType.offer and task.finish == 2 then
            self.main.questInfo:ShowQuest(task)
            return true
        elseif task.type == QuestEumn.TaskTypeSer.main and task.finish ~= 1 then
            self.main.questInfo:ShowQuest(task)
            return true
        elseif task.sec_type == QuestEumn.TaskType.guild and task.finish == 2 then
            self.main.questInfo:ShowQuest(task)
            return true
        else
            local tab = self.btnTab[i]
            if tab == nil then
                local buttonObj = GameObject.Instantiate(self.baseBtn.gameObject)
                local trans = buttonObj.transform
                trans:SetParent(self.container.transform)
                trans.localScale = Vector3.one
                tab = {}
                tab["gameObject"] = buttonObj
                tab["transform"] = trans
                tab["button"] = buttonObj:GetComponent(Button)
                tab["txt"] = buttonObj.transform:Find("Text"):GetComponent(Text)
                tab["img"] = buttonObj.transform:Find("Image/TypeImg"):GetComponent(Image)
                table.insert(self.btnTab, tab)
            end

            tab["img"].sprite = self.main.assetWrapper:GetSprite(AssetConfig.dialog_res, "DialogType1")
            tab["img"]:SetNativeSize()
            tab["txt"].text = string.format("%s-%s%s", QuestEumn.TypeName[task.sec_type], task.name, QuestEumn.StateName[task.finish + 1])
            local arg = task
            tab["button"].onClick:RemoveAllListeners()
            tab["button"].onClick:AddListener(function() self.main.questInfo:ShowQuest(arg) end)

            tab["transform"].localPosition = Vector3(0, -(i - 1) * 50, 0)
            tab["gameObject"]:SetActive(true)
        end
    end
    return false
end