
local tbDamageCount = Ui:CreateClass("BattleLabel");

local emNPC_FLYCHAR_TYPE_HIT_NORMAL = 1;
local emNPC_FLYCHAR_TYPE_HIT_DEADLY = 2;
local emNPC_FLYCHAR_TYPE_HIT_MISS = 3;
local emNPC_FLYCHAR_TYPE_HURT_NORMAL = 4;
local emNPC_FLYCHAR_TYPE_HURT_DEADLY = 5;
local emNPC_FLYCHAR_TYPE_HURT_MISS = 6;
local emNPC_FLYCHAR_TYPE_CURE = 7;
local emNPC_FLYCHAR_POTENCY_VITALITY = 9
local emNPC_FLYCHAR_POTENCY_STRENGTH = 10
local emNPC_FLYCHAR_POTENCY_DEXTERITY = 11
local emNPC_FLYCHAR_POTENCY_ENERGY = 12

function tbDamageCount:OnOpen()
    self:StartDamageCount();
end

function tbDamageCount:StartDamageCount()
    self:ResetInfo();
    self.bDmgCountStart = true;

    self:ShowInfo("开始伤害统计\n计时:0分0秒");
    self.nDamageStartTime = 0;
    if (not self.nDmgCountTimer) then
        self.nDmgCountTimer = Timer:Register(Env.GAME_FPS, self.OnFlyCharTimer, self);
    end
end

function tbDamageCount:OnFlyCharTimer()
    self:UpdateFlyChar();
    return true;
end

function  tbDamageCount:ResetInfo()
    self.nHitDamage         = 0;
    self.nHurtDamage        = 0;
    self.nHitDeadlyDamage   = 0;
    self.nHurtDeadlyDamage  = 0;
    self.nHitMiss           = 0;
    self.nHurtMiss          = 0;
    self.nHitMaxDamage      = 0;
    self.nHurtMaxDamage     = 0;
    self.bDmgCountStart             = false;
    self.nDamageStartTime   = 0;

    if self.nDmgCountTimer then
        Timer:Close(self.nDmgCountTimer);
        self.nDmgCountTimer = nil;
    end
end

function tbDamageCount:OnClose()
    if self.nDmgCountTimer then
        Timer:Close(self.nDmgCountTimer);
        self.nDmgCountTimer = nil;
    end

end

function tbDamageCount:UpdateFlyChar()
    local szTime;
    if ((self.nDamageStartTime or 0) > 0) then
        local nTimeSpan = GetTime() - self.nDamageStartTime;
        szTime = Lib:TimeDesc(nTimeSpan);
    else
        szTime = XT("计时:0分0秒");
    end
    
    local szMsg = string.format(XT([[造成伤害:%d
受到伤害:%d
造成会心伤害:%d
受到会心伤害:%d
丢失:%d
闪避:%d
造成最大伤害:%d
受到最大伤害:%d
计时:%s
]]),
        self.nHitDamage,
        self.nHurtDamage,
        self.nHitDeadlyDamage,
        self.nHurtDeadlyDamage,
        self.nHitMiss,
        self.nHurtMiss,
        self.nHitMaxDamage,
        self.nHurtMaxDamage,
        szTime
        );
    self:ShowInfo(szMsg);   
end 

function tbDamageCount:OnUpdateFlyChar(nType, nValue)
    if not self.bDmgCountStart then
        return;
    end    

    if nType == emNPC_FLYCHAR_TYPE_HIT_NORMAL then
        self.nHitDamage = self.nHitDamage + nValue;

    elseif nType == emNPC_FLYCHAR_TYPE_HIT_DEADLY then
        self.nHitDeadlyDamage = self.nHitDeadlyDamage + nValue;

    elseif nType == emNPC_FLYCHAR_TYPE_HIT_MISS then
        self.nHitMiss = self.nHitMiss + 1;

    elseif nType == emNPC_FLYCHAR_TYPE_HURT_NORMAL then
        self.nHurtDamage = self.nHurtDamage + nValue;

    elseif nType == emNPC_FLYCHAR_TYPE_HURT_MISS then
        self.nHurtMiss = self.nHurtMiss + 1;

    elseif nType == emNPC_FLYCHAR_TYPE_HURT_DEADLY then
        self.nHurtDeadlyDamage = self.nHurtDeadlyDamage + nValue;

    end

    if nType == emNPC_FLYCHAR_TYPE_HIT_NORMAL or nType == emNPC_FLYCHAR_TYPE_HIT_DEADLY then
        if nValue > self.nHitMaxDamage then
            self.nHitMaxDamage = nValue;
        end    

    elseif nType == emNPC_FLYCHAR_TYPE_HURT_NORMAL or nType == emNPC_FLYCHAR_TYPE_HURT_DEADLY then
        if nValue > self.nHurtMaxDamage then
            self.nHurtMaxDamage = nValue;
        end  

    end     

    if (self.nDamageStartTime == 0) then
        self.nDamageStartTime = GetTime();
    end

    self:UpdateFlyChar();       
end

function tbDamageCount:ShowInfo(szTxt)
    self.pPanel:Label_SetText("Label", szTxt);      
end    


function tbDamageCount:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_SYNC_FLY_CHAR,        self.OnUpdateFlyChar},
    };

    return tbRegEvent;
end