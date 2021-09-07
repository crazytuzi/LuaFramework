-- 峡谷之巅队伍信息列表
-- @author hze
-- @date 2018/07/25

CanYonOtherTeamPanel = CanYonOtherTeamPanel or BaseClass(BasePanel)

function CanYonOtherTeamPanel:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.canyonotherteampanel, type = AssetType.Main },
        -- { file = AssetConfig.godswarres, type = AssetType.Dep },
        { file = AssetConfig.bigatlas_godswarbg0, type = AssetType.Dep },
        { file = AssetConfig.classcardgroup_textures, type = AssetType.Dep },
    }

    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.itemList = { }
    self.isFull = false
end

function CanYonOtherTeamPanel:__delete()
    self.buttonImg.sprite = nil

    for i, v in ipairs(self.itemList) do
        v:DeleteMe()
    end
    self.itemList = nil
end

function CanYonOtherTeamPanel:OnShow()
    self.data = self.openArgs
    self:Update()
end

function CanYonOtherTeamPanel:OnHide()
end

function CanYonOtherTeamPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.canyonotherteampanel))
    self.gameObject.name = "CanYonOtherTeamPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener( function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener( function() self:Close() end)

    local container = self.transform:Find("Main/Scroll/Container")
    local len = container.childCount
    for i = 1, len do
        local item = CanYonOtherTeamItem.New(container:GetChild(i - 1).gameObject, self)
        table.insert(self.itemList, item)
    end

    self.fightObj = self.transform:Find("Main/Fight").gameObject
    self.fight = self.transform:Find("Main/Fight/Val"):GetComponent(Text)
    self.button = self.transform:Find("Main/Button").gameObject
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)
    self.button:GetComponent(Button).onClick:AddListener( function() self:ClickButton() end)
    self.buttonImg = self.button:GetComponent(Image)

    self.order = self.transform:Find("Main/Order"):GetComponent(Text)

    self:OnShow()
end

function CanYonOtherTeamPanel:Close()
    self.model:CloseTeam()
end

-- {uint32, tid, "战队ID"}
-- ,{string, platform, "平台标识"}
-- ,{uint16, zone_id, "区号"}
-- ,{string, name, "战队名字"}
-- ,{uint8, lev, "战队等级"}
-- ,{uint8, member_num, "战队人数"}
function CanYonOtherTeamPanel:Update()
    self.order.text = string.format("%s:<color='#31f2f9'>(%s)</color>", TI18N("编号："), self.data.name)

    if self.data.win_times == nil or self.data.loss_times == nil then
        self.fight.text = ""
        self.fightObj:SetActive(false)
    else
        self.fightObj:SetActive(true)
        self.fight.text = string.format(TI18N("平均剩余行动力:%s"), self.data.win_times)
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

end

