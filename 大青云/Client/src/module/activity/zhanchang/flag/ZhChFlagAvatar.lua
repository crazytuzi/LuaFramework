--[[
战旗
wangshuai
]]
_G.ZhChFlagAvatar = {};

setmetatable(ZhChFlagAvatar, {__index = CAvatar})
local metaZhChFlagAvatar = {__index = ZhChFlagAvatar}

function ZhChFlagAvatar:NewFlagAvatar(id,camp)
	local flagava = CAvatar:new();
	flagava.avtName = "flagava";
	setmetatable(flagava, metaZhChFlagAvatar);
	flagava.camp = camp;
	flagava.id = id;
	flagava.type = "flag"
	return flagava;
end;

function ZhChFlagAvatar:InitAvatar()
	local campId = self.camp;
	--print(campId)
	local cfg = ZhanFlagModelConfig[campId]
	local modeid = cfg.modelId;

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
function ZhChFlagAvatar:EnterMap(x,y,faceto)
	local curScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		curScene,
		_Vector3.new(x, y, 0),
		faceto
		)
	self.objNode.dwType = enEntType.eEntType_Flag;
end;

-- Get 类型
function ZhChFlagAvatar:OnEnterScene(objNode)
	objNode.dwType = enEntType.eEntType_Flag;
end;
-- out map 
function ZhChFlagAvatar:ExitMap()
	self:ExitSceneMap();
	self:Destroy();
end;
-- is or not mouse State
function ZhChFlagAvatar:SetHighLightState(IState)
	self.blState = IState;
end;