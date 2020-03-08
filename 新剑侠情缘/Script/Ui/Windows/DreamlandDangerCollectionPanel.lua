local tbUi = Ui:CreateClass("DreamlandDangerCollectionPanel");

function tbUi:OnOpen(tbPassList, nNpcID)
    if tbPassList and not next(tbPassList) then
        return 0
    end
    self.tbPassList = tbPassList
    self.nNpcID = nNpcID
    self.RealUpdate = tbPassList and self.RealUpdate2 or self.RealUpdate1
    if not self:Update() then
        me.CenterMsg("附近好像没有合适的采集物！")
        return 0
    end
    
    if not tbPassList then
        self.nTimer = Timer:Register(5, self.Update, self);
    end
end

function tbUi:CloseTimer()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil;
    end
end

function tbUi:OnClose()
    self:CloseTimer()
end

function tbUi:Update( )
    if not self:RealUpdate() then
        Ui:CloseWindow(self.UI_NAME)
        return
    end
    return true
end

---显示传过来的道具列表
function tbUi:RealUpdate2()
    local fnClick = function (itemObj)
        RemoteServer.InDifferBattleRequestInst("SelectPlayerDeathDrop", itemObj.nId, self.nNpcID)
    end

    local tbShowList = {}
    for k,v in pairs(self.tbPassList) do
        local nNpcTemplateId, nFaction = unpack(v) 
        local szName = KNpc.GetNameByTemplateId(nNpcTemplateId)
        if nFaction then
            szName = string.format("%s门派之力", Faction:GetName(nFaction))
        end
        local tbNpc = {nTemplateId = nNpcTemplateId, szName = szName};
        tbNpc.nId = k
        if InDifferBattle:CheckCanUseTarNpc(tbNpc) then
            table.insert(tbShowList, tbNpc)
        end
    end

    local fnSetItem = function (itemObj, index)
        local tbNpc = tbShowList[index]
        itemObj.pPanel:Label_SetText("Name", tbNpc.szName)
        itemObj.nId = tbNpc.nId
        itemObj.pPanel.OnTouchEvent = fnClick
    end

    self.ScrollView:Update(tbShowList, fnSetItem)
    return true    
end

--周围npc列表
function tbUi:RealUpdate1()
    local nShowAroundNpcDistance = InDifferBattle.tbDefine.nShowAroundNpcDistance
    local tbNpcs,nCount = KNpc.GetAroundNpcList(me.GetNpc(), nShowAroundNpcDistance)
    if nCount == 0 then
        return
    end
    local tbShowList = {}
    local tbCloseToNpc = PlayerEvent:GetCloseToNpcTb()
    for i,v in ipairs(tbNpcs) do
        if tbCloseToNpc[v.nTemplateId] then
            if InDifferBattle:CheckCanUseTarNpc(v) then
                table.insert(tbShowList, v)
            end
        end
    end
    if #tbShowList == 0 then
        return
    end

    local fnClick = function (itemObj)
        Operation.SimpleTap(itemObj.nNpcID);    
    end

    local fnSetItem = function (itemObj, index)
        local pNpc = tbShowList[index]
        itemObj.pPanel:Label_SetText("Name", pNpc.szName)
        itemObj.nNpcID = pNpc.nId;
        itemObj.pPanel.OnTouchEvent = fnClick
    end

    self.ScrollView:Update(tbShowList, fnSetItem)

    return true
end

function tbUi:CloseWindow()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnScreenClick()
    self:CloseWindow()
end