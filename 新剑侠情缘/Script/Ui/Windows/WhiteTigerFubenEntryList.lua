local tbUi = Ui:CreateClass("WhiteTigerFubenEntryList")

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap, self }
    }
end

function tbUi:OnOpen()
    if not Fuben.WhiteTigerFuben:IsPrepareMap() then
        return 0
    end
    self:InitNpcList()
end

function tbUi:OnOpenEnd()
    self:ChangeListState(false)

    self.pPanel.OnTouchEvent = function ()
        local bListVisible = self.pPanel:IsActive("EntryList")
        if bListVisible then
            self:ChangeListState(false)
        end
    end
end

local tbCnNum = {"一", "二", "三", "四", "五", "六", "七", "八"}
function tbUi:InitNpcList()
    if self.tbNpcList then
        return
    end

    self.tbNpcList = {}
    local tbNpcs = Map:GetMapNpcInfo(me.nMapTemplateId) or {}
    for _, tbNpc in pairs(tbNpcs) do
        if tbNpc.CanAutoPath == 1 then
            local tbItem = {
                nIdx = tbNpc.Index,
                nNpcTemplateId = tbNpc.NpcTemplateId,
                nPosX = tbNpc.XPos,
                nPosY = tbNpc.YPos,
                nNearLength = tbNpc.WalkNearLength,
            }
            table.insert(self.tbNpcList, tbItem)
        end
    end

    table.sort(self.tbNpcList, function (a, b)
        return a.nIdx < b.nIdx
    end);

    for i = 1, 8 do
        local tbNpc = self.tbNpcList[i]
        if tbNpc then
            tbNpc.szName = "入口".. tbCnNum[i]
        end
    end
end

function tbUi:UpdateList()
    for i = 1, 8 do
        local tbData = self.tbNpcList[i]
        self.pPanel:SetActive("item" .. i, tbData or false)
        if tbData then
            self.pPanel:Label_SetText("Label" .. i, tbData.szName or "")
        end
    end
end

function tbUi:TryDir2Npc(nIdx)
    self:ChangeListState(false)

    local tbData  = self.tbNpcList[nIdx]
    if not tbData then
        me.CenterMsg("找不到Npc")
        return
    end

    AutoPath:GotoAndCall(me.nMapId, tbData.nPosX, tbData.nPosY, function ()
        local nNpcId = AutoAI.GetNpcIdByTemplateId(tbData.nNpcTemplateId)
        if nNpcId then
            Operation.SimpleTap(nNpcId)
        end
    end, tbData.nNearLength)
end

function tbUi:OnEnterMap()
    if not Fuben.WhiteTigerFuben:IsPrepareMap() then
        Ui:CloseWindow(self.UI_NAME)
    end
end

function tbUi:ChangeListState(bShow)
    self.pPanel:SetActive("EntryList", bShow)
    self.pPanel:SetBoxColliderEnable("Main", bShow)
end

tbUi.tbOnClick = {
    BtnShowList = function (self)
        self:ChangeListState(true)
        self:UpdateList()
    end
}

local fnInitBtn = function ()
    for i = 1, 8 do
        tbUi.tbOnClick["item" .. i] = function (self)
            self:TryDir2Npc(i)
        end
    end
end
fnInitBtn()