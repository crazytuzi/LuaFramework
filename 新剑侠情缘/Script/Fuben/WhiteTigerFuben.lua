local WhiteTigerFuben = Fuben.WhiteTigerFuben
WhiteTigerFuben.tbAutoPathInfo = {}
function WhiteTigerFuben:DropBuff(nPosX, nPosY)
    local tbDropInfo = { tbUserDef = {{nObjID = -1, szTitle = ""}} }
    me.DropItemInPos(nPosX, nPosY, tbDropInfo)
end

function WhiteTigerFuben:Join()
    RemoteServer.CallWhiteTigerFunc("TryEnterPrepareMap", true)
end

function WhiteTigerFuben:OnClose()
    Fuben:ShowLeave()
    Fuben:SetFubenProgress(-1, "离开白虎堂")
end

function WhiteTigerFuben:SetFubenInfo(nProgress, szTitle, nTargetPosX, nTargetPosY)
    if szTitle then
        Fuben:SetFubenProgress(nProgress, szTitle)
    end
    Fuben:SetTargetPos(nTargetPosX or 0, nTargetPosY or 0)
end

function WhiteTigerFuben:IsMyMap(nMapTemplateId)
    nMapTemplateId = nMapTemplateId or me.nMapTemplateId

    return nMapTemplateId == self.PREPARE_MAPID 
    or nMapTemplateId == self.FIGHT_MAPID 
    or nMapTemplateId == self.OUTSIDE_MAPID 
    or nMapTemplateId == self.CROSS_MAP_TID
end

function WhiteTigerFuben:OnMapLoaded(nMapTemplateId)
    if me.nMapTemplateId ~= nMapTemplateId or not self:IsMyMap(nMapTemplateId) then
        return
    end

    if nMapTemplateId == self.PREPARE_MAPID then
        Ui:OpenWindow("WhiteTigerFubenEntryList")
    end

    UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
end

function WhiteTigerFuben:BeginAutoEnter()
    Ui:OpenWindow("MessageBox", "白虎堂将 [FFFE0D]%d[-] 秒开启，在准备场内尚未进入的，届时将会自动传送至一个随机的入口中", 
        {{function ()
            self:TryEnterFuben()
        end},
        {function ()
            Ui:CloseWindow("MessageBox")
        end},
        {function ()
            self:TryEnterFuben()
            Ui:CloseWindow("MessageBox")
        end}},
        {"同意", "拒绝"},
        nil,
        self.AUTO_JOIN_TIME)
end

function WhiteTigerFuben:TryEnterFuben()
    local nRoomId = MathRandom(self.SUB_ROOM_NUM)
    RemoteServer.CallWhiteTigerFunc("TryEnterOutSideFuben", nRoomId)
end

function WhiteTigerFuben:OnLeavePrepareMap()
    Ui:CloseWindow("HomeScreenFuben")
    Ui:CloseWindow("MessageBox")
end

function WhiteTigerFuben:FollowOperation(nMapId, szType)
    if szType == "0" then
        if self.tbAutoPathInfo[nMapId] then
            self:GotoTargetPos(nMapId, self.tbAutoPathInfo[nMapId])
        else
            RemoteServer.CallWhiteTigerFunc("OnTargetEnterFight", nMapId)
        end
    elseif szType == "1" then
        RemoteServer.CallWhiteTigerFunc("TryBackToPrepareMap")
    end
    return true
end

function WhiteTigerFuben:GotoTargetPos(nMapId, tbInfo)
    local nRoomId, nX, nY = unpack(tbInfo)
    self.tbAutoPathInfo[nMapId] = tbInfo
    if not self:IsPrepareMap() then
        return
    end
    local fnOnArive = function ()
        RemoteServer.CallWhiteTigerFunc("TryEnterOutSideFuben", nRoomId)
    end
    AutoPath:GotoAndCall(me.nMapId, nX, nY, fnOnArive)
end