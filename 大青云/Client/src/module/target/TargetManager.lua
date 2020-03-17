--[[
选中目标管理器
郝户
2014年9月15日19:26:10
]]

_G.TargetManager = {}

TargetManager.target = nil

TargetManager.AllTargetTypeDic = {
    [TargetConsts.TargetType.Monster] = true,
    [TargetConsts.TargetType.Boss]    = true,
    [TargetConsts.TargetType.Player]  = true
}

function TargetManager:UpdateTarget( attrList )
    TargetController:UpdateTarget( attrList )
end

function TargetManager:ShowTarget( charType, char )
	--判断目标类型：player, boss, or monster.
    local targetType = TargetConsts:GetTargetType( charType, char )
    if not TargetManager.AllTargetTypeDic[ targetType ] then return end
    self.target = char
    --根据目标类型不同，以不同的方式建立数据模型
    if targetType == TargetConsts.TargetType.Monster or targetType == TargetConsts.TargetType.Boss then
        TargetController:InitTargetMonster()
    elseif targetType == TargetConsts.TargetType.Player then
        TargetController:InitTargetPlayer()
    end
    --打开目标面板
    local targetPanelMap = TargetConsts:GetTargetPanelMap()
    for tarType, tarPanel in pairs( targetPanelMap ) do
    	if tarType == targetType then
    		tarPanel:ShowTarget()
    	else
    		tarPanel:HideTarget()
    	end
    end
    --建立buff数据模型
    BuffTargetModel:Rebuild( char:GetBuffInfo() )
end

function TargetManager:HideTarget()
    self.target = nil
    local targetPanelMap = TargetConsts:GetTargetPanelMap()
    for _, targetPanel in pairs( targetPanelMap ) do
    	targetPanel:HideTarget()
    end
     TargetModel:Init() -- 清数据
end

function TargetManager:GetTarget()
    return self.target
end

function TargetManager:CheckIsTarget(char)
    return char == self.target
end

function TargetManager:GetCid()
    local char = self.target
    return char and char:GetCid()
end

function TargetManager:IsLocked()
    return TargetModel:GetLockState()
end