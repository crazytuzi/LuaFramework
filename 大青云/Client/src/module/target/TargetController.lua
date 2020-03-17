--[[
选中目标controller
haohu
2015年6月18日11:04:40
]]

_G.TargetController = setmetatable( {}, {__index = IController} );
TargetController.name = "TargetController"

function TargetController:Create()
    CControlBase:RegControl(self, true)
    TargetModel:Init()
end

function TargetController:OnKeyDown(keyCode)
	if not TargetManager:GetTarget() then return end
    if CControlBase.oldKey[_System.KeyCtrl] then
        if keyCode == _System.KeyTab then
            self:ToggleLock()
            return
        end
    end
end

function TargetController:InitTargetMonster()
    local monster = TargetManager:GetTarget()
    if not monster then return end
    local monsterId  = monster:GetMonsterId()
    local monsterCfg = t_monster[ monsterId ]
    if not monsterCfg then return end
    local name       = monsterCfg.name
    local maxHp      = monster:GetMaxHP()
    local hp         = monster:GetCurrHP()
    TargetModel:SetCId(monster:GetCid())
    TargetModel:SetId( monsterId )
    TargetModel:SetName( name )
    TargetModel:SetMaxHp( maxHp )
    TargetModel:SetHp( hp )
    TargetModel:SetLockState( false )
end

function TargetController:InitTargetPlayer()
    local player = TargetManager:GetTarget()
    if not player then return end
    local info  = player:GetPlayerInfo()
    local name  = info[enAttrType.eaName]
    local maxHp = info[enAttrType.eaMaxHp]
    local hp    = info[enAttrType.eaHp]
    local level = info[enAttrType.eaLevel]
	local prof = info[enAttrType.eaProf];
    TargetModel:SetId( player:GetRoleID() )
    TargetModel:SetIcon( player.icon )
    TargetModel:SetName( name )
    TargetModel:SetMaxHp( maxHp )
    TargetModel:SetHp( hp )
    TargetModel:SetLevel( level )
	TargetModel:SetProf(prof)
    TargetModel:SetLockState( false )
end

function TargetController:UpdateTarget(attrList)
    for _, v in pairs( attrList ) do
        TargetModel:UpdateTargetAttr( v.type, v.value )
    end
end

function TargetController:ToggleLock()
    local locked = TargetModel:GetLockState()
    TargetModel:SetLockState( not locked )
end