-- -----------------------------
-- 诸神之战 战队信息面板
-- hosr
-- -----------------------------
GodsWarOtherTeamPanel = GodsWarOtherTeamPanel or BaseClass(BasePanel)

function GodsWarOtherTeamPanel:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.godswarmember, type = AssetType.Main },
        { file = AssetConfig.godswarres, type = AssetType.Dep },
        { file = AssetConfig.bigatlas_godswarbg0, type = AssetType.Dep },
        { file = AssetConfig.classcardgroup_textures, type = AssetType.Dep },
    }

    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.itemList = { }
    self.isFull = false
end

function GodsWarOtherTeamPanel:__delete()
    self.buttonImg.sprite = nil

    for i, v in ipairs(self.itemList) do
        v:DeleteMe()
    end
    self.itemList = nil
end

function GodsWarOtherTeamPanel:OnShow()
    self.data = self.openArgs
    self:Update()
end

function GodsWarOtherTeamPanel:OnHide()
end

function GodsWarOtherTeamPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarmember))
    self.gameObject.name = "GodsWarOtherTeamPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener( function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener( function() self:Close() end)

    local container = self.transform:Find("Main/Scroll/Container")
    local len = container.childCount
    for i = 1, len do
        local item = GodsWarOtherTeamItem.New(container:GetChild(i - 1).gameObject, self)
        table.insert(self.itemList, item)
    end

    self.fightObj = self.transform:Find("Main/Fight").gameObject
    self.fight = self.transform:Find("Main/Fight/Val"):GetComponent(Text)
    self.button = self.transform:Find("Main/Button").gameObject
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)
    self.button:GetComponent(Button).onClick:AddListener( function() self:ClickButton() end)
    self.buttonImg = self.button:GetComponent(Image)

    self.name = self.transform:Find("Main/Name"):GetComponent(Text)

    self:OnShow()
end

function GodsWarOtherTeamPanel:Close()
    self.model:CloseTeam()
end

-- {uint32, tid, "战队ID"}
-- ,{string, platform, "平台标识"}
-- ,{uint16, zone_id, "区号"}
-- ,{string, name, "战队名字"}
-- ,{uint8, lev, "战队等级"}
-- ,{uint8, member_num, "战队人数"}
function GodsWarOtherTeamPanel:Update()
    self.name.text = string.format("%s<color='#31f2f9'>(%s)</color>", self.data.name, BaseUtils.GetServerNameMerge(self.data.platform, self.data.zone_id))

    if self.data.win_times == nil or self.data.loss_times == nil then
        self.fight.text = ""
        self.fightObj:SetActive(false)
    else
        self.fightObj:SetActive(true)
        self.fight.text = string.format(TI18N("战绩:%s胜%s负"), self.data.win_times, self.data.loss_times)
    end
    local normalIndex = 1

    table.sort(self.data.members, function(a, b)
        if a.position ~= b.position then
            return a.position < b.position
        else
            return a.fight_capacity > b.fight_capacity
        end
    end )

    for i, v in ipairs(self.data.members) do
        local item = self.itemList[normalIndex]
        item:SetData(v)
        normalIndex = normalIndex + 1
    end

    for i = normalIndex, #self.itemList do
        self.itemList[i]:Reset()
    end

    if not GodsWarManager.Instance.isHitstory then
        self.isFull =(self.data.member_num == 7)
        local status = GodsWarManager.Instance.status
        if status < GodsWarEumn.Step.Publicity then
            self:UpdateButton()
            if self.isFull then
                self.buttonImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            else
                self.buttonImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            end
            self.button:SetActive(true)
        elseif status >= GodsWarEumn.Step.Elimination8Idel then
            -- self.buttonTxt.text = TI18N("投 票")
            -- self.button:SetActive(true)

            self.button:SetActive(false)
        else
            self.button:SetActive(false)
        end
    else
        self.buttonTxt.text = TI18N("录 像")
        self.button:SetActive(true)
    end
end

function GodsWarOtherTeamPanel:ClickButton()
    if not GodsWarManager.Instance.isHitstory then
        local status = GodsWarManager.Instance.status
        if status < GodsWarEumn.Step.Publicity then
            if not self.isFull then
                --  申请加入
                if not self.data.isRequest then
                    GodsWarManager.Instance:Send17907(self.data.tid, self.data.platform, self.data.zone_id)
                    self.data.isRequest = true
                    self:UpdateButton()
                end
            end
        else  
            -- 投票
            local  dataList = GodsWarManager.Instance:GetElimintionData(self.data.zone_id) or {}
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_vote, {zone = self.data.zone_id, dataList = dataList})
        end
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = self.data.zone_id,name = self.data.name})
    end
end

function GodsWarOtherTeamPanel:UpdateButton()
    if self.data.isRequest then
        self.buttonTxt.text = TI18N("已申请")
    else
        self.buttonTxt.text = TI18N("申请加入")
    end
end