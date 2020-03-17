--[[
功能开启坐骑画模型
lizhuangzhuang
2015年3月6日11:51:17
]]

_G.FuncOpenHorseDraw = {};

FuncOpenHorseDraw.objUIDraw = nil;
FuncOpenHorseDraw.objAvatar = nil;

function FuncOpenHorseDraw:Enter(objSwf)
	objSwf.mcTitle:gotoAndStop(1);
	objSwf.mcButton:gotoAndStop(1);
	--
	local soundid = MountUtil:GetMountSound(MountModel.ridedMount.mountLevel,MainPlayerModel.humanDetailInfo.eaProf);
	if soundid > 0 then
		SoundManager:PlaySfx(soundid);
	end
	--
	local uiloader = objSwf.modelLoader;
	uiloader._x = -750;
	uiloader._y = -560;
	local modelId = 0;
	if MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Sickle then
		modelId = 60000022;
	elseif MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Sword then
		modelId = 60000022;
	elseif MainPlayerModel.humanDetailInfo.eaProf == enProfType.eProfType_Human then
		modelId = 60000022;
	else
		modelId = 60000022;
	end

self.objAvatar = CHorseAvatar:new(modelId)
	self.objAvatar:Create(modelId);
	_rd.camera:shake(2,2,160);
	
	local cfg = t_mountmodel[modelId];
	local stunActionFile = cfg.san_show;
	self.objAvatar:DoAction(stunActionFile,false);
	self.objAvatar.objMesh.transform:setRotation(0,0,1,-250/360);
	self.objAvatar.objMesh.transform:mulScalingRight(1.5,1.5,1.5);
	
	self.objUIDraw = UIDraw:new("FuncOpenHorseDraw",self.objAvatar,uiloader,
								_Vector2.new(1800,1200),
								_Vector3.new(0,-100,25),
								_Vector3.new(1,0,20),
								0x00000000);
	self.objUIDraw:SetDraw(true);
	self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
	self.meshDir = 0;
end


function FuncOpenHorseDraw:Exit()
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
	self.objAvatar:ExitMap();
	self.objAvatar = nil;
end

function FuncOpenHorseDraw:Update()
	-- self.meshDir = self.meshDir - math.pi/200;
	-- self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end