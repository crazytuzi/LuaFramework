-- 师徒，出师成功，奖励提示面板
-- @author zgs
BeTeacherFinishRewardPanel = BeTeacherFinishRewardPanel or BaseClass(BasePanel)

function BeTeacherFinishRewardPanel:__init(model)
    self.model = model
    self.name = "BeTeacherFinishRewardPanel"

    self.resList = {
        {file = AssetConfig.be_teacher_panel, type = AssetType.Main}
    }
    self.data = nil
    self.OnOpenEvent:AddListener(function()
        self.data = self.openArgs
        self:UpdatePanel()
    end)
    self.slots = {}
    self.X_list = {201, 163, 126, 89, 55, 22}

    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:RemovePanel()
    end)
end


function BeTeacherFinishRewardPanel:RemovePanel()
    self:DeleteMe()
end

function BeTeacherFinishRewardPanel:OnInitCompleted()
    self.data = self.openArgs
    self:UpdatePanel()
end

function BeTeacherFinishRewardPanel:__delete()
    for i,v in ipairs(self.slots) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slots = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.btfrp = nil
    self.model = nil
end

function BeTeacherFinishRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.be_teacher_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.titleTxt = self.transform:Find("MainCon/ImgTitle/TxtTitle"):GetComponent(Text)
    self.titleTxt.text = TI18N("出师")

    self.transform:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)

    local sureBtn = self.transform:Find("MainCon/ImgShareBtn").gameObject
    sureBtn:SetActive(true)
    sureBtn:GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    -- sureBtn.transform.localPosition = Vector3(0, -120, 0)

    self.contentTxt = self.transform:Find("MainCon/MidCon/TxtPassVal"):GetComponent(Text)
    -- self.contentTxt.text = ""
    self.msgItemExt = MsgItemExt.New(self.contentTxt, 430, 16, 18)
    -- self.msgItemExt:SetData(string.format(self.desc, tostring(self.investTypeTime[self.model.invest_type]), tostring(self.receiveNum)), true)

    self.slotContainer = self.transform:Find("MainCon/MidCon/ConSlot")
    self.slotContainerRect = self.slotContainer:GetComponent(RectTransform)
    for i = 1, 6 do
        local parent = self.slotContainer:Find("SlotCon"..tostring(i)).gameObject
        parent:SetActive(true)
        local cell = ItemSlot.New()
        local trans = cell.gameObject.transform
        trans:SetParent(parent.transform)
        trans.localPosition = Vector3.zero
        trans.localScale = Vector3.one
        cell.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2.zero
        table.insert(self.slots, cell)
    end

    self:DoClickPanel()
end

function BeTeacherFinishRewardPanel:onClickDailyButton()
    self:Hiden()
end

function BeTeacherFinishRewardPanel:onClickTaskButton()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    local key = BaseUtils.get_unique_npcid(47, 1)
    SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
    self:Hiden()
end

function BeTeacherFinishRewardPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    -- print("BeTeacherFinishRewardPanel:DoClickPanel()"..debug.traceback())
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end


function BeTeacherFinishRewardPanel:UpdatePanel()
    if self.data.flag == 1 then
        --师傅
        local stu = nil
        for i,v in ipairs(self.model.teacherStudentList.list) do
            if v.rid == self.data.id and v.platform == self.data.platform and v.zone_id == self.data.zone_id then
                stu = v
                break
            end
        end
        if self.data.score >= 200 then
            self.msgItemExt:SetData(string.format(TI18N("恭喜！你的徒弟<color='#ffff00'>%s</color>已经顺利出师，他累计与你积累了<color='#ffff00'>%d点</color>师道值，由于师道值超过<color='#ffff00'>200点</color>，获得了以下丰厚奖励{face_1,3}"),stu.name, self.data.score))
        else
            self.msgItemExt:SetData(string.format(TI18N("恭喜！你的徒弟<color='#ffff00'>%s</color>已经顺利出师，他累计与你积累了<color='#ffff00'>%d点</color>师道值，由于师道值不足<color='#ffff00'>200点</color>，只能获得了以下奖励{face_1,44}"),stu.name, self.data.score))
        end
    else
        --徒弟
        self.msgItemExt:SetData(TI18N("恭喜！你已经顺利出师，获得了以下丰厚奖励{face_1,3}出师之后，成长目标仍然会保留，完成后你跟师傅都能得到奖励，继续努力哟！"))
    end
    self:ShowAward(self.data.list)
end

function BeTeacherFinishRewardPanel:ShowAward(data)

    for i,v in ipairs(data) do
        local slot = self.slots[i]
        local item = BackpackManager.Instance:GetItemBase(v.item_id)
        item.quantity = v.num
        item.bind = v.bind
        slot:SetAll(item, {nobutton = true})
        slot.gameObject:SetActive(true)
    end

    local conX = self.X_list[#data]
    self.slotContainerRect.anchoredPosition = Vector2(conX, -135)

    for i = #data + 1, 6 do
        self.slots[i].gameObject:SetActive(false)
    end
end
