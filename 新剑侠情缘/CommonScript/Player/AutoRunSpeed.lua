
AutoRunSpeed.tbDef = AutoRunSpeed.tbDef or {}; 
local tbDef = AutoRunSpeed.tbDef;
tbDef.nMinRunLen = 1000; --最小距离可以加速
tbDef.nBuffID    = 1008; --BUff的ID
tbDef.nBuffLevel = 2; --Buff的等级


AutoRunSpeed.tbBaseLogic = AutoRunSpeed.tbBaseLogic or {}; 
local tbBaseLogic = AutoRunSpeed.tbBaseLogic;
function AutoRunSpeed:Create(pPlayer)
    self:Close(pPlayer);

    local tbAutoRunSpeed = Lib:NewClass(tbBaseLogic);
    pPlayer.tbAutoRunSpeed = tbAutoRunSpeed;
    tbAutoRunSpeed:OnCreate(pPlayer);
    return tbAutoRunSpeed;
end

function AutoRunSpeed:Close(pPlayer)
   if not pPlayer.tbAutoRunSpeed then
        return;
   end

   pPlayer.tbAutoRunSpeed:OnClose();
   pPlayer.tbAutoRunSpeed = nil; 
end

function AutoRunSpeed:MapStartRunSpeed(pPlayer, nDstX, nDstY, nPathLen)
    local pNpc = pPlayer.GetNpc();
    local nMapTemplateId = pNpc.nMapTemplateId;
    local bRet = self:CheckCanMapRunSpeed(pPlayer, nPathLen);
    if not bRet then
        Log("Error AutoRunSpeed Check", pPlayer.dwID, nMapTemplateId);
        return;
    end    

    local tbAutoRunSpeed = pPlayer.tbAutoRunSpeed;
    if not tbAutoRunSpeed or tbAutoRunSpeed.nMapTemplateId ~= nMapTemplateId then
        tbAutoRunSpeed = self:Create(pPlayer);
    end

    tbAutoRunSpeed:StartRunSpeed(nDstX, nDstY, nPathLen);    
end

function AutoRunSpeed:CheckCanMapRunSpeed(pPlayer, nPathLen)
    local pNpc = pPlayer.GetNpc();
    local nMapTemplateId = pNpc.nMapTemplateId;
    if not Map:IsRunSpeedMap(nMapTemplateId) then
        return false;
    end

    if tbDef.nMinRunLen > nPathLen then
        return false;
    end

    local nActMode = pPlayer.GetActionMode();
    if nActMode ~= Npc.NpcActionModeType.act_mode_none then
        return false, "";
    end

    if ActionInteract:IsInteract(pPlayer) then
        return false, "";
    end

    return true;   
end

function AutoRunSpeed:StopRunSpeed(pPlayer)
    local tbAutoRunSpeed = pPlayer.tbAutoRunSpeed;
    if not tbAutoRunSpeed then
        return;
    end

    tbAutoRunSpeed:StopRunSpeed();    
end


function tbBaseLogic:OnCreate(pPlayer)
    self.nPlayerID = pPlayer.dwID;
    self.nDstX     = 0;
    self.nDstY     = 0;
    self.bStart    = true;
    local pNpc = pPlayer.GetNpc();
    self.nMapTemplateId = pNpc.nMapTemplateId;
    Log("AutoRunSpeed OnCreate", self.nPlayerID, self.nMapTemplateId);
end

function tbBaseLogic:StartRunSpeed(nDstX, nDstY, nPathLen)
    if tbDef.nMinRunLen > nPathLen or nDstX == 0 or nDstY == 0 then
        return;
    end

    if self.nDstX == nDstX and self.nDstY == nDstY then
        return;
    end

    local pPlayer = self:GetPlayer();
    if not pPlayer then
        return;
    end

    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end

    local nTimeFrame = nPathLen / pNpc.nRunSpeed;
    if nTimeFrame <= Env.GAME_FPS then
        return;
    end

    self.nDstX = nDstX;
    self.nDstY = nDstY;
    self.bStart = true;
    pNpc.AddSkillState(tbDef.nBuffID, tbDef.nBuffLevel, 0, nTimeFrame, 0, 1);
end

function tbBaseLogic:StopRunSpeed()
    if not self.bStart then
        return;
    end

    self.nDstY = 0;
    self.nDstX = 0;
    self.bStart = false;

    local pPlayer = self:GetPlayer();
    if not pPlayer then
        return;
    end

    local pNpc = pPlayer.GetNpc();
    if not pNpc then
        return;
    end

    pNpc.RemoveSkillState(tbDef.nBuffID);   
end


function tbBaseLogic:OnClose()
    self:StopRunSpeed();
    Log("AutoRunSpeed OnClose", self.nPlayerID, self.nMapTemplateId);
end

function tbBaseLogic:GetPlayer()
    local pPlayer = KPlayer.GetPlayerObjById(self.nPlayerID);
    return pPlayer;
end
