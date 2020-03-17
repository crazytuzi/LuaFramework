--[[
战旗
zhangshuhui
]]
_G.DiGongFlagAvatar = {};

setmetatable(DiGongFlagAvatar, {__index = CAvatar})
local metaDiGongFlagAvatar = {__index = DiGongFlagAvatar}

function DiGongFlagAvatar:NewFlagAvatar()
	local flagava = CAvatar:new();
	flagava.avtName = "flagava";
	setmetatable(flagava, metaDiGongFlagAvatar);
	flagava.type = "digongflag"
	return flagava;
end;

function DiGongFlagAvatar:InitAvatar()
	local colvo = t_collection[403];
	if not colvo then
		return;
	end
	local modeid = colvo.modelId;

	local file = t_model[modeid];

	local sklFile = file.skl;
	local sknFile = file.skn;
	local defAnima = file.san_idle;

	local sknPath = Assets:GetNpcMesh(sknFile);
	local sklPath = Assets:GetNpcSkl(sklFile);
	local animaPath = Assets:GetNpcAnima(defAnima);

	self:SetPart("Body",sknPath);
	self:ChangeSkl(sklPath);
	self:SetIdleAction(animaPath);

	self.dwSklFile = sklFile;
	self.dwSknFile = sknFile;
	self.dwDefAnima = defAnima;
end;
--进入 地图绘制模型
function DiGongFlagAvatar:EnterMap(x,y,faceto)
	local curScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		curScene,
		_Vector3.new(x, y, 0),
		faceto
		)
	self.objNode.dwType = enEntType.eEntType_DigongFlag;
end;

-- Get 类型
function DiGongFlagAvatar:OnEnterScene(objNode)
	objNode.dwType = enEntType.eEntType_DigongFlag;
end;
-- out map 
function DiGongFlagAvatar:ExitMap()
	self:ExitSceneMap();
	self:Destroy();
end;
-- is or not mouse State
function DiGongFlagAvatar:SetHighLightState(IState)
	self.blState = IState;
end;