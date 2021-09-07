GuildBuildRestrictionSelectWindow  =  GuildBuildRestrictionSelectWindow or BaseClass(BasePanel)

function GuildBuildRestrictionSelectWindow:__init(model,index,curSelectItem)
    self.name  =  "GuildBuildRestrictionSelectWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.guild_build_restriction_select_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_build_icon, type = AssetType.Dep}
    }

    self.currentChosenItem = 0 -- 当前选择的额度，默认为不限制

    self.index = index  -- index为1-4，是用来区分建筑类型的
    self.curSelectItem = curSelectItem

    self.ToggleGroup = nil
    self.Toggle25 = nil
    self.Toggle50 = nil
    self.Toggle100 = nil
    self.ToggleUnlimited = nil

    self.okBtn = nil
    self.cancelBtn = nil

    self.is_open = false
    return self
end


function GuildBuildRestrictionSelectWindow:__delete()

    self.currentChosenItem = nil

    self.index = nil
    self.data_table = nil

    self.ToggleGroup = nil
    self.Toggle25 = nil
    self.Toggle50 = nil
    self.Toggle100 = nil
    self.ToggleUnlimited = nil


    self.okBtn = nil
    self.cancelBtn = nil

    self.is_open = false

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildBuildRestrictionSelectWindow:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_build_restriction_select_win))
    self.gameObject.name  =  "GuildBuildRestrictionSelectWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseBuildRestrictionSelectUI() end)


    self.MainCon = self.transform:FindChild("MainCon")
    self.TitleText = self.MainCon:FindChild("TitleTxt")
    self.TitleTextConcent = self.TitleText:GetComponent(Text)
    self.TitleTextConcent.text = string.format("%s%s%s%s%s%s%s",TI18N("是否要消耗<color=#00ff00>"),self:transformIndexToCost(),TI18N("</color>公会资金升级"),self:transformIndexToLevel(),TI18N("级<color=#00ff00>"),self:transformIndexToName(),"</color>")

    self.ToggleGroup = self.MainCon:FindChild("ToggleGroup")
    self.Toggle25 = self.ToggleGroup:FindChild("Toggle25"):GetComponent(Toggle)
    self.Toggle50 = self.ToggleGroup:FindChild("Toggle50"):GetComponent(Toggle)
    self.Toggle100 = self.ToggleGroup:FindChild("Toggle100"):GetComponent(Toggle)
    self.ToggleUnlimited = self.ToggleGroup:FindChild("ToggleUnlimited"):GetComponent(Toggle)

    self.okBtn = self.MainCon:FindChild("Okbtn"):GetComponent(Button)
    self.cancelBtn = self.MainCon:FindChild("CancelBtn"):GetComponent(Button)

    self.Toggle25.onValueChanged:AddListener(function()
        self.currentChosenItem = 1;
    end)
    self.Toggle50.onValueChanged:AddListener(function()
        self.currentChosenItem = 2;
    end)
    self.Toggle100.onValueChanged:AddListener(function()
        self.currentChosenItem = 3;
    end)
    self.ToggleUnlimited.onValueChanged:AddListener(function()
        self.currentChosenItem = 0;
    end)
    self.ToggleUnlimited.isOn = true;

    self.okBtn.onClick:AddListener(function()
        GuildManager.Instance:request11111(self.index, self.currentChosenItem)
    end)

    self.cancelBtn.onClick:AddListener(function()
        self.model:CloseBuildRestrictionSelectUI()
    end)


    self.is_open = true
end

--更新信息
function GuildBuildRestrictionSelectWindow:transformIndexToCost()

    local cost = 0
    local data = self.curSelectItem.data[2]
    if self.index == 0  then
        cost = data[self.model.my_guild_data.Lev+1].cost -- 升级公会消耗资金
    end
    if self.index == 1  then
        cost = data[self.model.my_guild_data.academy_lev+1].cost -- 研究院
    end
    if self.index == 2  then
        cost = data[self.model.my_guild_data.exchequer_lev+1].cost -- 厢房
    end
    if self.index == 3  then
        cost = data[self.model.my_guild_data.store_lev+1].cost
    end
    return cost
end

function GuildBuildRestrictionSelectWindow:transformIndexToName()
    local name = ""
    if self.index == 0 then
        name = TI18N("公会")
    end
    if self.index == 1 then
        name = TI18N("研究院")
    end
    if self.index == 2 then
        name = TI18N("厢房")
    end
    if self.index == 3 then
        name = TI18N("商店")
    end
    return name
end

function GuildBuildRestrictionSelectWindow:transformIndexToLevel()
    local level = 0
    if self.index == 0 then
        level = self.model.my_guild_data.Lev
    end
    if self.index == 1 then
        level = self.model.my_guild_data.academy_lev
    end
    if self.index == 2 then
        level = self.model.my_guild_data.exchequer_lev
    end
    if self.index == 3 then
        level = self.model.my_guild_data.store_lev
    end
    return level
end

