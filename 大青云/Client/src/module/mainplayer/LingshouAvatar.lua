_G.CLingshouAvatar = {}
CLingshouAvatar.objName = 'CLingshouAvatar'
setmetatable(CLingshouAvatar,{__index = CPlayerAvatar});

--对应的模型ID，骨骼ID，默认动画
function CLingshouAvatar:new()
    print("CLingshouAvatar:new()")
	local obj = CPlayerAvatar:new();
	obj.avtName = "lingshou";
    setmetatable(obj,{__index = CLingshouAvatar});

    return obj;
end;

--创建默认
--需要角色id,职业等
function CLingshouAvatar:Create(dwModelID)
	 print("创建默认")
    self.dwModelID = dwModelID
    local mountConfig = t_lingshoumodel[dwModelID]
	--设置骨骼 
	local szSklFile = mountConfig.skl
    local sknFile = mountConfig.skn
	local list = split(sknFile, '#')
    self:SetPart("Body", list[1])
	 self:SetPart("Kuijia", list[2])
    self:ChangeSkl(szSklFile)
    self.objMesh.name ="lingshou"
	--设置默认动作 
	self:SetAttackAction()
	return true
end

local animaDeltaTime = 30
function CLingshouAvatar:OnUpdate(e)

end;

--进入地图
function CLingshouAvatar:OnEnterScene(objNode)
    objNode.dwType = enEntType.eEntType_Player;
end;


function CLingshouAvatar:SetAttackAction()
	local cfg = t_lingshoumodel[self.dwModelID]

	self:SetIdleAction(cfg.san_idle, true)
end;

