-- 已废
-- @author zgs
StudentPanel = StudentPanel or BaseClass(BasePanel)

function StudentPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "StudentPanel"

    self.resList = {
        {file = AssetConfig.student_panel, type = AssetType.Main},
        {file = AssetConfig.zone_textures, type = AssetType.Dep},
        -- ,{file  =  AssetConfig.guild_dep_res, type  =  AssetType.Dep}
        -- , {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self.tabgroup:ChangeTab(1)
    end)

    self.itemTargetDic = {}
    self.itemsDailyDic = {}
end

function StudentPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self.tabgroup:ChangeTab(1)
end

function StudentPanel:__delete()
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function StudentPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.student_panel))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.leftInfo = self.transform:Find("LeftInfo")
    self.head = self.leftInfo:Find("Headbg/Head"):GetComponent(Image)
    self.classIcon = self.leftInfo:Find("ClassIcon"):GetComponent(Image)
    self.nameText = self.leftInfo:Find("NameText"):GetComponent(Text)
    self.inputField = self.leftInfo:Find("SigInputField"):GetComponent(InputField)
    self.levText = self.leftInfo:Find("LevText"):GetComponent(Text)
    self.svalueText = self.leftInfo:Find("SvalueText"):GetComponent(Text) --公会
    self.bsstateText = self.leftInfo:Find("BSStateText"):GetComponent(Text) -- 授业状态
    self.countText = self.leftInfo:Find("CountText"):GetComponent(Text) --入门时间

    self.rightCon = self.transform:Find("RightCon")
    self.targeList = self.rightCon:Find("TargetList")
    self.gridTarget = self.targeList:Find("ScrollPanel/Grid")
    self.itemTarget = self.gridTarget:Find("Item").gameObject
    self.itemTarget:SetActive(false)
    self.targetListLayout = LuaBoxLayout.New(self.gridTarget.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.targeList.gameObject:GetComponent(Button_1).onClick:AddListener(function()
        self:OnClickShowSpace()
    end)
    self.targeList.gameObject:GetComponent(Button_2).onClick:AddListener(function()
        self:OnClickShowPrivateChat()
    end)

    self.tsDaily = self.rightCon:Find("TSDaily")
    self.dailyRewardImageBg = self.tsDaily:Find("HeadImageBg"):GetComponent(Image)
    self.gridDaily = self.tsDaily:Find("ScrollPanel/Grid")
    self.itemDaily = self.gridDaily:Find("Item").gameObject
    self.itemDaily:SetActive(false)
    self.dailyLayout = LuaBoxLayout.New(self.gridDaily.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.gridDaily.gameObject:GetComponent(Button_1).onClick:AddListener(function()
        self:OnClickShowSpace()
    end)
    self.gridDaily.gameObject:GetComponent(Button_2).onClick:AddListener(function()
        self:OnClickShowPrivateChat()
    end)
    self.gridDaily.gameObject:GetComponent(Button_3).onClick:AddListener(function()
        self:OnClickShowEncourage()
    end)

    local setting = {
            notAutoSelect = true,
            noCheckRepeat = true,
            openLevel = {0, 0, 0},
            perWidth = 117,
            perHeight = 45,
            isVertical = true
        }

    local go = self.transform:Find("TabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(go, function (index) self:OnTabChange(index) end,setting)
end
--看空间
function StudentPanel:OnClickShowSpace()
    -- body
end
--私聊
function StudentPanel:OnClickShowPrivateChat()
    -- body
end
--良师鼓励
function StudentPanel:OnClickShowEncourage()
    -- body
end

function StudentPanel:OnTabChange(index)
    if index == 1 then
        self.targeList.gameObject:SetActive(false)
        self.tsDaily.gameObject:SetActive(true)
        self:UpdateTeacherStudentDailyTask()
    elseif index == 2 then
        self.targeList.gameObject:SetActive(true)
        self.tsDaily.gameObject:SetActive(false)
        self.UpdateTargetList()
    end
end

function StudentPanel:UpdateTeacherStudentDailyTask()
    for i,v in ipairs(self.itemsDailyDic) do
        if v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
    for i=1,totalCnt do -- 更改数据来源
        local itemTaken = self.itemsDailyDic[i]
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemTarget)
            obj.name = tostring(i)

            self.listLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = nil,
                -- btn=obj.transform:GetComponent(Button),
                nameText = obj.transform:Find("NameText"):GetComponent(Text),
                valueText = obj.transform:Find("ValueText"):GetComponent(Text),
                -- stateText = obj.transform:Find("StateText"):GetComponent(Text),
                -- relationText = obj.transform:Find("RelationText"):GetComponent(Text),
                -- -- fightFlag = obj.transform:Find("FightFlag").gameObject,
                bgImg = obj.transform:Find("Image"):GetComponent(Image),
                -- classIconImg = obj.transform:Find("ClassIcon"):GetComponent(Image),
            }
            self.itemsDailyDic[i] = itemDic
            itemTaken = itemDic

            -- itemDic.btn.onClick:AddListener(function ()
            --     self:onClickBtn(i)
            -- end)
        end

        itemTaken.thisObj:SetActive(true)
    end
end

function StudentPanel:UpdateTargetList()
    for i,v in ipairs(self.itemTargetDic) do
        if v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
    for i=1,totalCnt do -- 更改数据来源
        local itemTaken = self.itemTargetDic[i]
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemTarget)
            obj.name = tostring(i)

            self.listLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = nil,
                btn=obj.transform:GetComponent(Button),
                nameText = obj.transform:Find("DescText"):GetComponent(Text),
                valueText = obj.transform:Find("ValueText"):GetComponent(Text),
                stateText = obj.transform:Find("StateText"):GetComponent(Text),
                -- relationText = obj.transform:Find("RelationText"):GetComponent(Text),
                -- -- fightFlag = obj.transform:Find("FightFlag").gameObject,
                -- bgImg = obj.transform:Find("Image"):GetComponent(Image),
                -- classIconImg = obj.transform:Find("ClassIcon"):GetComponent(Image),
            }
            self.itemTargetDic[i] = itemDic
            itemTaken = itemDic

            itemDic.btn.onClick:AddListener(function ()
                self:onClickBtn(i)
            end)
        end

        itemTaken.thisObj:SetActive(true)
    end
end

function StudentPanel:onClickBtn(index)
end
