-- 师徒，师父解除师徒关系的面板
-- @author zgs
BreakTSPanel = BreakTSPanel or BaseClass(BasePanel)

function BreakTSPanel:__init(model)
    self.model = model
    self.name = "BreakTSPanel"

    self.resList = {
        {file = AssetConfig.apprentice_panel, type = AssetType.Main},
        {file = AssetConfig.heads, type = AssetType.Dep},
        -- {file = AssetConfig.bible_textures, type = AssetType.Dep}

    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdatePanel()
        -- TeacherManager.Instance:send15807()
    end)

    self.selectindex = 1
    self.stuDic = {}
    self.OnHideEvent:AddListener(function () self:OnHide() end)
    -- self.stInfoChangeFun = function ()
    --     self:UpdatePanel()
    -- end
    -- EventMgr.Instance:AddListener(event_name.teahcer_student_info_change, self.stInfoChangeFun)
end

function BreakTSPanel:OnHide()
    self:DeleteMe()
end

function BreakTSPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdatePanel()
    -- TeacherManager.Instance:send15807()
end

function BreakTSPanel:__delete()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    EventMgr.Instance:RemoveListener(event_name.teahcer_student_info_change, self.stInfoChangeFun)
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.btsp = nil
    self.model = nil
end

function BreakTSPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.apprentice_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    -- self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    -- self.closeBtn.onClick:AddListener(function()
    --     self:OnClickClose()
    -- end)

    self.MainCon = self.transform:FindChild("Main/Con")

    self.titleText = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.titleText.text = TI18N("解除师徒关系")
    self.descText = self.MainCon:FindChild("DescText"):GetComponent(Text)
    self.descText.text = TI18N("请选择你要解除关系的徒弟:")

    self.MainCon:FindChild("TDescText").gameObject:SetActive(false)
    self.MainCon:FindChild("SDescText").gameObject:SetActive(false)

    self.tHeadObj = self.MainCon:FindChild("THead").gameObject
    self.teacherText = self.MainCon:FindChild("THead/TText"):GetComponent(Text)
    self.teacherImage = self.MainCon:Find("THead/Image"):GetComponent(Image)
    self.teacherImage.gameObject:GetComponent(Button).onClick:AddListener( function() self:onClickHead(1) end)
    self.teacherSelectedObj = self.MainCon:Find("THead/Selected").gameObject
    self.teacherSelectedObj:SetActive(false)
    self.teacherLabelObj = self.MainCon:Find("THead/Lable").gameObject
    self.teacherLabelObj:SetActive(false)

    self.sHeadObj = self.MainCon:FindChild("SHead").gameObject
    self.studentText = self.MainCon:FindChild("SHead/SText"):GetComponent(Text)
    self.studentImage = self.MainCon:Find("SHead/Image"):GetComponent(Image)
    self.studentImage.gameObject:GetComponent(Button).onClick:AddListener( function() self:onClickHead(2) end)
    self.studentSelectedObj = self.MainCon:Find("SHead/Selected").gameObject
    self.studentSelectedObj:SetActive(false)
    self.studentLabelObj = self.MainCon:Find("SHead/Lable").gameObject
    self.studentLabelObj:SetActive(false)

    self.agreeBtn = self.MainCon:Find("AgreeButton"):GetComponent(Button)
    self.agreeTxt = self.agreeBtn.gameObject.transform:Find("Text"):GetComponent(Text)
    self.agreeTxt.text = TI18N("解除关系")
    self.opposeBtn = self.MainCon:FindChild("OpposeButton"):GetComponent(Button)
    self.opposeTxt = self.opposeBtn.gameObject.transform:Find("Text"):GetComponent(Text)
    self.opposeTxt.text = TI18N("取消")

    self.agreeBtn.onClick:AddListener( function() self:onClickAgreeBtn() end)
    self.opposeBtn.onClick:AddListener( function() self:onClickOpposeBtn() end)

    self:DoClickPanel()
end

function BreakTSPanel:onClickHead(index)
    self.selectindex = index
    if self.selectindex == 1 then
        self.teacherSelectedObj:SetActive(true)
        self.studentSelectedObj:SetActive(false)
    elseif self.selectindex == 2 then
        self.teacherSelectedObj:SetActive(false)
        self.studentSelectedObj:SetActive(true)
    end
end

function BreakTSPanel:onClickAgreeBtn()
    local info = self.stuDic[self.selectindex]
    local timeTemp = BaseUtils.BASE_TIME - info.login_time
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.sureLabel = TI18N("解除关系")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function ()
        TeacherManager.Instance:send15811(info.rid,info.platform,info.zone_id,1)
        self:Hiden()
    end
    if timeTemp > 86400 then
        --离线1天以上
        data.content = string.format(TI18N("确定要解除与您的徒弟<color='#00ff00'>%s</color>的师徒关系吗？（徒弟一天<color='#ffff00'>未登录</color>，可获少量奖励）"),info.name)
    else
        data.content = string.format(TI18N("确定要解除与您的徒弟<color='#00ff00'>%s</color>的师徒关系吗？（徒弟一天内<color='#ffff00'>有登录</color>，无法获得奖励）"),info.name)
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function BreakTSPanel:onClickOpposeBtn()
    self:Hiden()
end

function BreakTSPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function BreakTSPanel:UpdatePanel()
    self.selectindex = 1
    self.teacherSelectedObj:SetActive(true)
    self.studentSelectedObj:SetActive(false)
    self.stuDic = nil
    self.stuDic = {}
    for i,v in ipairs(self.model.teacherStudentList.list) do
        if v.status == 1 then
            table.insert(self.stuDic,v)
        end
    end
    self.tHeadObj:SetActive(false)
    self.sHeadObj:SetActive(false)
    self.teacherLabelObj:SetActive(false)
    self.studentLabelObj:SetActive(false)
    if #self.stuDic == 1 then
        self.tHeadObj:SetActive(true)
        self.teacherText.text = string.format("%s",self.stuDic[1].name)
        self.teacherImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.stuDic[1].classes, self.stuDic[1].sex))
        if BaseUtils.BASE_TIME - self.stuDic[1].login_time > 86400 then
            self.teacherLabelObj:SetActive(true)
        else
            self.teacherLabelObj:SetActive(false)
        end
    elseif #self.stuDic == 2 then
        self.tHeadObj:SetActive(true)
        self.sHeadObj:SetActive(true)
        self.teacherText.text = string.format("%s",self.stuDic[1].name)
        self.teacherImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.stuDic[1].classes, self.stuDic[1].sex))
        if BaseUtils.BASE_TIME - self.stuDic[1].login_time > 86400 then
            self.teacherLabelObj:SetActive(false)
        else
            self.teacherLabelObj:SetActive(true)
        end
        self.studentText.text = string.format("%s",self.stuDic[2].name)
        self.studentImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.stuDic[2].classes, self.stuDic[2].sex))
        if BaseUtils.BASE_TIME - self.stuDic[2].login_time > 86400 then
            self.studentLabelObj:SetActive(false)
        else
            self.studentLabelObj:SetActive(true)
        end
    end
end