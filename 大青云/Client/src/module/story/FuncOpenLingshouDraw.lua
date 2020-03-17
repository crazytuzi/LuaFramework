--[[
功能开启灵兽画模型
ly
2015年5月7日11:51:17
]]

_G.FuncOpenLingshouDraw = {};
FuncOpenLingshouDraw.objUIDraw = nil;
FuncOpenLingshouDraw.objAvatar = nil;

function FuncOpenLingshouDraw:Enter(uiloader)
	uiloader._x = -300;
	uiloader._y = -140;
	local modelId = 0;
	if MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Sickle then
		modelId = 20010001;
	elseif MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Sword then
		modelId = 20010001;
	elseif MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Human then
		modelId = 20010001;
	else
		modelId = 20010001;
	end
	FPrint('hhhhhhhhhhhhhhhhhhhhhhhhhhhh')
	self.objAvatar = CLingshouAvatar:new(modelId)
	self.objAvatar:Create(modelId);

	self.objUIDraw = UIDraw:new("FuncOpenLingshouDraw",self.objAvatar,uiloader,
								_Vector2.new(900,600),
								_Vector3.new(0,-70,10),
								_Vector3.new(1,0,11),
								0x00000000);
	self.objUIDraw:SetDraw(true);
	self.objUIDraw:PlayPfx("functionopen.pfx");
	self.meshDir = 0;
end


function FuncOpenLingshouDraw:Exit()
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
	self.objAvatar:ExitMap();
	self.objAvatar = nil;
end

function FuncOpenLingshouDraw:Update()
	self.meshDir = self.meshDir - math.pi/200;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end