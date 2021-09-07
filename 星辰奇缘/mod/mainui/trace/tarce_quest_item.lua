-- -----------------------------
-- 任务追踪 每一项
-- hosr
-- -----------------------------
TraceQuestItem = TraceQuestItem or BaseClass()

function TraceQuestItem:__init(gameObject, main)
    self.main = main
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.transform:SetParent(self.main.container.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.rect = gameObject:GetComponent(RectTransform)
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.desc = self.transform:Find("Desc"):GetComponent(Text)
    self.desc_rect = self.desc.gameObject:GetComponent(RectTransform)
    self.succ = self.transform:Find("SuccImg"):GetComponent(Image)
    self.fight = self.transform:Find("FightImg").gameObject
    self.extra = self.transform:Find("ExtImg").gameObject
    self.extra:SetActive(false)
    self.select = self.transform:Find("Select").gameObject
    self.select_rect = self.select:GetComponent(RectTransform)
    self.btnobj = self.transform:Find("Button").gameObject
    self.btnTxt = self.btnobj.transform:Find("Text"):GetComponent(Text)
    self.btn = self.btnobj:GetComponent(Button)
    self.btnScript = self.gameObject:GetComponent(CustomButton)

    self.btnShow = self.transform:Find("BtnShow"):GetComponent(Button)

    self.btnShow.onClick:AddListener(
    function ()
        if self.ShowItemData ~= nil then
            local info = {
                itemData = self.ShowItemData,
                gameObject = self.ShowItemData.gameObject,
                extra = {nobutton = true, inbag = false,pointTxt = TI18N("等级：20")}}
            TipsManager.Instance:ShowAllItemTips(info)
        end
    end)

    self.btnShow.gameObject:SetActive(false)
    self.imgShow = self.transform:Find("BtnShow/ImgEquip"):GetComponent(Image)

    self.isNew = false
    self.data = nil
    self.finish = 0
    self.noShow = false
    self.height = 0

    self.extra_desc = ""
    self.extra_height = 0
    self.countTime = 0
    self.countId = nil

    self.clickCall = nil
    self.downCall = nil
    self.upCall = nil
    self.holdCall = nil

    self.downId = nil

    self.questEffect = nil

    self._UpdateAutoTag = function() self:UpdateAutoTag() end
    self._UpdateChainAutoTag = function() self:UpdateChainAutoTag() end -- 由于历练环的戳有宝箱图标需要用一个改过的函数来更新 by 嘉俊 2017/8/29 10：50

end

function TraceQuestItem:Show()
end

function TraceQuestItem:Hide()
    if self.countId ~= nil then
        self:CountDonwEnd(true)
    end
    AutoQuestManager.Instance.updateAutoTagOfCycle:RemoveListener(self._UpdateAutoTag)
    AutoQuestManager.Instance.updateAutoTagOfChain:RemoveListener(self._UpdateChainAutoTag)
end

function TraceQuestItem:Reset()
    self.btnScript.onClick:RemoveAllListeners()
    self.btnScript.onDown:RemoveAllListeners()
    self.btnScript.onUp:RemoveAllListeners()
end

function TraceQuestItem:AddExtraDesc(extra_desc)
end

function TraceQuestItem:AddExtraDescAndCountDown(extra_desc, time)
    self.extra_desc = extra_desc
    self.countTime = time
    self.extra_desc_obj = GameObject.Instantiate(self.desc.gameObject)
    self.extra_desc_obj.transform:SetParent(self.desc.gameObject.transform.parent)
    self.extra_desc_obj.transform.localScale = Vector3.one
    self.extra_desc_rect = self.extra_desc_obj:GetComponent(RectTransform)
    self.extra_desc_txt = self.extra_desc_obj:GetComponent(Text)

    local tstr = ""
    if self.countTime > 60 then
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>分钟)"), os.date("%M", self.countTime))
    else
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>秒)"), os.date("%S", self.countTime))
    end
    self.extra_desc_txt.text = self.extra_desc .. tstr

    self.extra_desc_rect.sizeDelta = Vector2(200, self.extra_desc_txt.preferredHeight)
    self.extra_desc_rect.anchoredPosition = Vector2(self.desc_rect.anchoredPosition.x, self.desc_rect.anchoredPosition.y - self.desc.preferredHeight)
    self.extra_height = self.extra_desc_txt.preferredHeight
    self.height = self.height + self.extra_height

    if self.countId ~= nil then
        LuaTimer.Delete(self.countId)
        self.countId = nil
    end
    self.countId = LuaTimer.Add(0, 1000, function() self:CountDonw() end)

    self.main:Layout()
end


function TraceQuestItem:CountDonw()
    local tstr = ""
    if self.countTime > 60 then
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>分钟)"), os.date("%M", self.countTime))
    else
        tstr = string.format(TI18N("(剩余<color='#ffff00'>%s</color>秒)"), os.date("%S", self.countTime))
    end
    self.extra_desc_txt.text = self.extra_desc .. tstr
    self.countTime = self.countTime - 1
    if self.countTime < 0 then
        self:CountDonwEnd()
    end
end

function TraceQuestItem:CountDonwEnd(isDestroy, noHeight)
    if self.countId ~= nil then
        LuaTimer.Delete(self.countId)
        self.countId = nil
    end

    if self.extra_desc_obj ~= nil then
        GameObject.DestroyImmediate(self.extra_desc_obj)
        self.extra_desc_obj = nil
    end

    if not noHeight then
        self.height = self.height - self.extra_height
        self.extra_height = 0
    end
    self.countTime = 0

    if not isDestroy then
        self.main:Layout()
    end
end

-- 点击某一个
function TraceQuestItem:ClickOne(id)
    -- inserted by 嘉俊
    -- print("**********************click")
    AutoQuestManager.Instance.disabledAutoQuest:Fire()
    -- end by 嘉俊
    if self.clickCall ~= nil then
        self.clickCall(id)
    end
    -- -- inserted by 嘉俊
    -- if AutoQuestManager.Instance.model.isOpen then
    --     self.succ.gameObject:SetActive(true)
    --     self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest, "I18NTeacher")
    -- end
    -- -- end by 嘉俊

end

function TraceQuestItem:DownOne(id)
    if self.downCall ~= nil then
        self.downCall(id)
    end

    if self.select ~= nil then
        self.select:SetActive(true)
        self.select_rect.sizeDelta = Vector2(224, self.height + 2)
    end
    self.downId = LuaTimer.Add(200, function() self.main:ShowArrowEffect(self.transform) end)
end

function TraceQuestItem:UpOne(id)
    if self.downId ~= nil then
        LuaTimer.Delete(self.downId)
        self.downId = nil
    end

    if self.upCall ~= nil then
        self.upCall(id)
    end

    if self.select ~= nil then
        self.select:SetActive(false)
    end
end

function TraceQuestItem:HoldOne(id)
    if self.holdCall ~= nil then
        self.holdCall(id)
    end

    if self.data ~= nil then
        local sec_type = self.data.sec_type
        if sec_type == QuestEumn.TaskType.guide then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {2, self.data.id})
        elseif sec_type == QuestEumn.TaskType.practice or sec_type == QuestEumn.TaskType.practice_pro then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskdrama)
        elseif sec_type == QuestEumn.TaskType.main and self.data.lev >= 30 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskdrama)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.taskwindow, self.data)
        end
    end

    if self.select ~= nil then
        self.select:SetActive(false)
    end
end

function TraceQuestItem:SetData(questData)
    if questData == nil then
        return
    end
    local id = questData.id
    self.data = questData
    self.finish = questData.finish
    self.btnScript.onClick:RemoveAllListeners()
    self.btnScript.onDown:RemoveAllListeners()
    self.btnScript.onUp:RemoveAllListeners()
    self.btnScript.onClick:AddListener(function() self:ClickOne(id) end)
    self.btnScript.onDown:AddListener(function() self:DownOne(id) end)
    self.btnScript.onUp:AddListener(function() self:UpOne(id) end)
    self.btnScript.onHold:AddListener(function() self:HoldOne(id) end)

    local isfight = false
    local isItem = false
    local noprogress = false

    -- 处理某些任务在任务名字后面添加轮次显示
    local preval = ""
    if questData.sec_type == QuestEumn.TaskType.cycle then
        --职业循环
        local color = QuestManager.Instance.round_cycle == 10 and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/10)</color>", color, QuestManager.Instance.round_cycle)
    elseif questData.sec_type == QuestEumn.TaskType.offer then
        local round = QuestManager.Instance.round_offer
        local ring = QuestManager.Instance.ring_offer
        local  totalRound = 10 ;
        local color = "#ee3900"
        if round > 10 then
            round = round - 10
        end
        -- if ring <= 3 then
        --     totalRound = 30
        --     round = round * ring
        -- end
        preval = string.format("<color='%s'>(%s/%s)</color>", color, round,totalRound)
    elseif questData.sec_type == QuestEumn.TaskType.treasuremap then
        local color = QuestManager.Instance.round_treasure == 10 and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/10)</color>", color, QuestManager.Instance.round_treasure)
    elseif questData.sec_type == QuestEumn.TaskType.guild then
        local color = QuestManager.Instance.round_guild == 6 and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/6)</color>", color, QuestManager.Instance.round_guild)
    elseif questData.sec_type == QuestEumn.TaskType.fineType then
        local color = QuestManager.Instance.round_fine == 10 and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/10)</color>", color, QuestManager.Instance.round_fine)
    elseif questData.sec_type == QuestEumn.TaskType.chain then
        local color = QuestManager.Instance.round_chain == QuestManager.Instance.round_chain_max and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, QuestManager.Instance.round_chain, QuestManager.Instance.round_chain_max)
    elseif questData.sec_type == QuestEumn.TaskType.couple or questData.sec_type == QuestEumn.TaskType.ambiguous then
        local color = QuestManager.Instance.round_couple == QuestManager.Instance.round_couple_max and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, QuestManager.Instance.round_couple, QuestManager.Instance.round_couple_max)
    elseif questData.sec_type == QuestEumn.TaskType.plant then
        local color = QuestManager.Instance.round_plant == QuestManager.Instance.round_plant_max and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, QuestManager.Instance.round_plant, QuestManager.Instance.round_plant_max)
    elseif questData.sec_type == QuestEumn.TaskType.teacher then
        local color = QuestManager.Instance.round_teacher == QuestManager.Instance.round_teacher_max and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, QuestManager.Instance.round_teacher, QuestManager.Instance.round_teacher_max)
    elseif questData.sec_type == QuestEumn.TaskType.shipping then
        local color = QuestManager.Instance.round_teacher == QuestManager.Instance.round_teacher_max and "#00ff12" or "#ee3900"
        local shipquest = DataShipping.data_quest[id]
        preval = string.format("<color='%s'>(%s/%s)</color>", color, shipquest.ring, shipquest.max_ring)
    elseif questData.sec_type == QuestEumn.TaskType.seekChild then
        local childTaskData = DataCampHideSeek.data_child_task[questData.id]
        local color = childTaskData.curIndex == childTaskData.maxIndex and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, childTaskData.curIndex, childTaskData.maxIndex)
    elseif questData.sec_type == QuestEumn.TaskType.acquaintance then
        local color = QuestManager.Instance.round_hello == QuestManager.Instance.round_hello_max and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, QuestManager.Instance.round_hello, QuestManager.Instance.round_hello_max)
    elseif questData.sec_type == QuestEumn.TaskType.singledog then
        local color = QuestManager.Instance.round_singledog == 5 and "#00ff12" or "#ee3900"
        preval = string.format("<color='%s'>(%s/%s)</color>", color, QuestManager.Instance.round_singledog, 5)

    elseif questData.sec_type == QuestEumn.TaskType.shipping then
    end

    self.noShow = false
    if questData.sec_type == QuestEumn.TaskType.guide and questData.follow == 0 then
        -- 指引任务，根据配置显示或隐藏
        self.noShow = true
    elseif questData.sec_type == QuestEumn.TaskType.treasuremap then
        self.treasuremapItem = self
        if self.main:CheckTreasuremapFinish() then
            self.treasuremapItem.noShow = true
        end
    end

    self.name.text = string.format("<color='%s'>[%s]%s</color>%s", QuestEumn.ColorName(questData.sec_type), QuestEumn.TypeName[questData.sec_type], questData.name, preval)

    local content = ""
    local len = #questData.progress
    local ccount = 0
    if #questData.progress == 0 then
        local npc = ""
        if questData.trace_msg ~= "" then
            content = questData.trace_msg
        else
            if questData.finish == QuestEumn.TaskStatus.CanAccept then--可接
                if questData.npc_accept ~= 0 then
                    npc = DataUnit.data_unit[questData.npc_commit].name
                end
            elseif questData.finish == QuestEumn.TaskStatus.Doing then-- 进行中
                if questData.npc_commit ~= 0 then
                    npc = DataUnit.data_unit[questData.npc_commit].name
                end
            elseif questData.finish == QuestEumn.TaskStatus.Finish then -- 完成
                if questData.sec_type == QuestEumn.TaskType.chain then
                    local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                    if npcData ~= nil then
                        npc = npcData.name
                    end
                else
                    if questData.npc_commit ~= 0 then
                        npc = DataUnit.data_unit[questData.npc_commit].name
                    end
                end
            end
            content = string.format(TI18N("拜访<color='#00ff12'>%s</color>"), npc)
        end
    else
        for i,v in ipairs(questData.progress) do
            -- 标志某些任务内容为战斗内容
            if v.cli_label == QuestEumn.CliLabel.fight or v.cli_label == QuestEumn.CliLabel.patrol then
                isfight = true
            elseif v.cli_label == QuestEumn.CliLabel.gain then
                isItem = true
            end
            -- 有些任务进度隐藏不显示
            if v.is_hide == 0 then
                ccount = ccount + 1
                if ccount > 1 and ccount < len then
                    -- 处理文本换行，避免多换行导致高度错误
                    content = content .. "\n"
                end
                local preval = ""
                if v.target_val > 1 then
                    if questData.id ~= 83631 and questData.id ~= 83625 then
                        preval = string.format("<color='#00ff12'>(%d/%d)</color>", (questData.progress_ser ~= nil and questData.progress_ser[i] ~= nil) and questData.progress_ser[i].value or 0, v.target_val)
                    else
                        preval = ""
                    end
                end
                if v.desc == nil or v.desc == "[]" then
                    local target_id = v.target
                    if questData.progress_ser ~= nil and questData.progress_ser[i] ~= nil then
                        target_id = questData.progress_ser[i].target
                    end
                    local tar_name = QuestManager.Instance:GetTargetByLabel(v.cli_label, target_id)
                    if v.cli_label == QuestEumn.CliLabel.catchpet or v.cli_label == QuestEumn.CliLabel.gain then
                        local npcName = ""
                        if questData.sec_type == QuestEumn.TaskType.chain then
                            local npcData = DataUnit.data_unit[QuestManager.Instance.chainBaseId]
                            if npcData ~= nil then
                                npcName = npcData.name
                            end
                        elseif questData.sec_type == QuestEumn.TaskType.cycle then
                            npcName = string.format(TI18N("%s首席"), KvData.classes_name[RoleManager.Instance.RoleData.classes])
                        else
                            if questData.npc_commit ~= 0 then
                                npcName = DataUnit.data_unit[questData.npc_commit].name
                            end
                        end
                        local ss = string.format(QuestEumn.RequireName[v.cli_label], npcName, tar_name)
                        content = content .. string.format("%s%s", ss, preval)
                    elseif v.cli_label == QuestEumn.CliLabel.protest then
                        local tar_name = QuestManager.Instance.target_name
                        if tar_name == "" then
                            tar_name = TI18N("坏蛋")
                        end
                        local ss = string.format(QuestEumn.RequireName[v.cli_label], tar_name)
                        content = content .. string.format("%s%s", ss, preval)
                    else
                        content = content .. string.format("%s<color='#00ff12'>%s</color>%s", QuestEumn.RequireName[v.cli_label], tar_name, preval)
                    end
                else
                    content = content .. string.format("%s%s", StringHelper.MatchBetweenSymbols(v.desc, "%[", "%]")[1], preval)
                end
            end
        end
    end

    self.desc.text = content

    self.extra.gameObject:SetActive(false)

    local succRectTransform = self.transform:Find("SuccImg"):GetComponent(RectTransform)
    succRectTransform.sizeDelta = Vector2(48,28) -- 100环后的戳由于手动调过宽高，所以要手动调回原来的比例 by 嘉俊 2017/8/28 10:55

    -- 处理一下标签显示
    if questData.finish == 2 then

        self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest, "I18NFinishSmall")
        self.succ.gameObject:SetActive(not noprogress)
        self.fight.gameObject:SetActive(false)
    else
        if questData.finish == 0 then
            self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest, "I18NAcceptSmall")
            self.succ.gameObject:SetActive(not noprogress)
        else
            self.succ.gameObject:SetActive(false)
        end
        if isfight then
            self.fight.gameObject:SetActive(true)
        else
            self.fight.gameObject:SetActive(false)
        end
    end

    if self.questEffect ~= nil then -- 如果特效存在先屏蔽掉，之后的逻辑会让特效在百环时被激活 by 嘉俊 2017/8/29
        self.questEffect:SetActive(false)
    end

    -- inserted by 嘉俊 历练任务中，当达到100环或200环且任务完成时，停止自动
    if QuestManager.Instance.round_chain == 100 or QuestManager.Instance.round_chain == 200 then
        if questData.sec_type == QuestEumn.TaskType.chain and questData.finish == 2 then
            if AutoQuestManager.Instance.model.isOpen then
                print("环数百环导致自动停止")
                AutoQuestManager.Instance.disabledAutoQuest:Fire()
                MainUIManager.Instance.dialogModel:Hide()
            end
        end
        if questData.sec_type == QuestEumn.TaskType.chain then -- 在登录游戏时也加入整百环的宝箱图标检测 by 嘉俊 2017/8/28 19:52
            local succRectTransform = self.transform:Find("SuccImg"):GetComponent(RectTransform)
            succRectTransform.sizeDelta = Vector2(38,38) -- 调整宝箱大小 by 嘉俊 2017/8/28 10:36
            self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest,"BoxI18N")
            self.succ.gameObject:SetActive(true)
            self.questEffect = BaseUtils.ShowEffect(20053, self.transform, Vector3(3.5, 1, 1), Vector3(-110,-54,-400))
            self.questEffect:SetActive(true)
        end
    end
    -- end by 嘉俊

    -- inserted by 嘉俊 自动历练，自动职业任务自动戳处理
    if questData.sec_type == QuestEumn.TaskType.chain  then
        AutoQuestManager.Instance.updateAutoTagOfChain:RemoveListener(self._UpdateChainAutoTag)
        AutoQuestManager.Instance.updateAutoTagOfChain:AddListener(self._UpdateChainAutoTag)
    else
        AutoQuestManager.Instance.updateAutoTagOfChain:RemoveListener(self._UpdateChainAutoTag)
    end

    if questData.sec_type == QuestEumn.TaskType.cycle then
        AutoQuestManager.Instance.updateAutoTagOfCycle:RemoveListener(self._UpdateAutoTag)
        AutoQuestManager.Instance.updateAutoTagOfCycle:AddListener(self._UpdateAutoTag)
    else
        AutoQuestManager.Instance.updateAutoTagOfCycle:RemoveListener(self._UpdateAutoTag)
    end
    -- end by 嘉俊

    -- 处理单位高度计算
    self.desc.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(200, self.desc.preferredHeight)
    local descHeight = self.desc.preferredHeight
    self.desc.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(200, descHeight)
    local height = 5 + 25 + descHeight + 6 + 10
    self.height = height

    if isItem and questData.sec_type == QuestEumn.TaskType.chain then
        if questData.finish == QuestEumn.TaskStatus.Finish then
            self:Hide()
        else
            local mapName = QuestManager.Instance:GetHangupMapName()
            if mapName ~= nil then
                local leaveTime = 20 * 60 - (BaseUtils.BASE_TIME - self.data.accept_time)
                if leaveTime > 0 then
                    self:AddExtraDescAndCountDown(string.format(TI18N("购买或击败<color='#ffff00'>%s</color>内的怪物可获得"), mapName), leaveTime)
                end
            end
        end
    end

    if questData.type == QuestEumn.TaskTypeSer.main then
        self.main.mainObj = self.gameObject
    elseif questData.sec_type == QuestEumn.TaskType.cycle then
        self.main.cycleObj = self.gameObject
    end
    self.ShowItemData  = nil
    local showData = DataQuest.data_show_reward[questData.id];
    if showData ~= nil then
        if questData.id == 22310 and RoleManager.Instance.RoleData.lev < 20 then
             self.btnShow.gameObject:SetActive(false)
        else
            local roleData = RoleManager.Instance.RoleData
            local itemId = 0;
            for _,item in pairs(showData.reward) do
               if (item[2] == roleData.sex or item[2] == 2) and (item[1] == roleData.classes or item[1] == 0) then
                itemId = item[3]
                break
               end
            end
            if itemId ~= 0 then
             local itemData = BackpackManager.Instance:GetItemBase(itemId);
             if itemData ~= nil then
                if self.imgLoader == nil then
                    self.imgLoader = SingleIconLoader.New(self.imgShow.gameObject)
                end
                self.ShowItemData = itemData
                self.imgLoader:SetSprite(SingleIconType.Item, itemData.icon)
             end
             self.btnShow.gameObject:SetActive(true)
            else
                self.btnShow.gameObject:SetActive(false)
            end
        end
    else
        self.btnShow.gameObject:SetActive(false)
    end
    self.btnShow:GetComponent(RectTransform).anchoredPosition = Vector2(-138, (self.height - 56) * 0.5)
end


function TraceQuestItem:UpdateShippingCountDown(time)
    self.countTime = time
    local time = math.ceil(36000 - (BaseUtils.BASE_TIME - time))

    local h = math.floor(time/3600)>9 and math.floor(time/3600) or string.format("0%s", tostring(math.floor(time/3600)))
    local m = math.floor(time%3600/60)>9 and math.floor(time%3600/60) or string.format("0%s", tostring(math.floor(time%3600/60)))

    self.desc.text = string.format(TI18N("剩余<color='#00ff12'>%s小时%s分</color>"), tostring(h), tostring(m))

    -- self.countId = LuaTimer.Add(0, 1000, function() self:CountDonw() end)

end

function TraceQuestItem:SetCustomData(customData)
    self.noShow = false
    self.customData = customData
    self.name.text = string.format("<color='#ffcc66'>%s</color>", customData.title)
    self.desc.text = customData.Desc
    self.height = 65
    self.fight.gameObject:SetActive(customData.fight == true)
    self.succ.gameObject:SetActive(customData.finish == true)
    self.btnScript.onClick:RemoveAllListeners()
    self.btnScript.onDown:RemoveAllListeners()
    self.btnScript.onUp:RemoveAllListeners()
    local id = customData.customId
    self.btnScript.onClick:AddListener(function() self.main:ClickCustomOne(id) end)
    self.btnScript.onDown:AddListener(function() self.main:DownCustomOne(id) end)
    self.btnScript.onUp:AddListener(function() self.main:UpCustomOne(id) end)
    self.btnScript.onHold:AddListener(function() self.main:HoldCustomOne(id) end)
    local descHeight = self.desc.preferredHeight
    self.desc.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(200, descHeight)
    local height = 5 + 25 + descHeight + 6 + 10
    self.height = height

    if self.countId ~= nil then
        self:CountDonwEnd(true, true)
    end

    local leaveTime = 60 * 60 - (BaseUtils.BASE_TIME - self.customData.countDown)
    if leaveTime > 0 then
        self:AddExtraDescAndCountDown("", leaveTime)
    end
end

function TraceQuestItem:UpdateChainAutoTag() -- 历练环戳更新 比起职业任务多了一个宝箱图标的变换
    if not BaseUtils.isnull(self.succ.gameObject) then
        self.succ.gameObject:SetActive(false)
        if AutoQuestManager.Instance.model.isOpen then
            self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest,"AutoI18N")
            self.succ.gameObject:SetActive(true)
        else
            if self.finish == 2 then
                self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest,"I18NFinishSmall")
                self.succ.gameObject:SetActive(true)
            end
        end
        if QuestManager.Instance.round_chain == 100 or QuestManager.Instance.round_chain == 200 then -- 往下三行 当完成整百环时戳统一都为宝箱图标 by 嘉俊 2017/8/28 17:52
            local succRectTransform = self.transform:Find("SuccImg"):GetComponent(RectTransform)
            succRectTransform.sizeDelta = Vector2(38,38) -- 调整宝箱大小 by 嘉俊 2017/8/28 10:36
            self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest,"BoxI18N")
            self.succ.gameObject:SetActive(true)
        end
    end
end
function TraceQuestItem:UpdateAutoTag() -- 职业戳更新
    if not BaseUtils.isnull(self.succ.gameObject) then
        self.succ.gameObject:SetActive(false)
        if AutoQuestManager.Instance.model.isOpen then
            self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest,"AutoI18N")
            self.succ.gameObject:SetActive(true)
        else
            if self.finish == 2 then
                self.succ.sprite = self.main.main.assetWrapper:GetSprite(AssetConfig.teamquest,"I18NFinishSmall")
                self.succ.gameObject:SetActive(true)
            end
        end
    end
end