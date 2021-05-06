local CChoukaNpc = class("CChoukaNpc", CNpc)

function CChoukaNpc.ctor(self)
	CNpc.ctor(self)
end

function CChoukaNpc.CreateNpc(cls)
	local oNpc = CChoukaNpc.New()
	local npcdata = {
		dialogId=10000,
		diglogface=0,
		event=0,
		grade=1,
		id=62000,
		lifeTime=0,
		modelId=302,
		monster_type=1,
		mutateColor={},
		mutateTexture=0,
		name=[[抽卡建筑物]],
		nameType=1,
		ornamentId=0,
		refreshCycle=0,
		reuse=1,
		rotateY=-145.0,
		scale=1.0,
		sceneId=101000,
		title=[[]],
		tollgateId=20000,
		type=3,
		wpmodel=0,
		x=20000,
		y=15000,
		z=0.0,
	}
	if g_MapCtrl:GetMapID() ~= npcdata.sceneId then
		return
	end

	local pos_info = netscene.DecodePos({x=npcdata.x, y=npcdata.y, z=npcdata.z})
	oNpc.m_Name = npcdata.name
	oNpc:SetData(npcdata)
	local model_info = {shape = npcdata.modelId}
	if model_info then
		oNpc:ChangeShape(model_info.shape, model_info)
	end
	local name = string.format("[FF00FF]%s", npcdata.name)
	oNpc:SetNameHud(name)
	CObject.SetName(oNpc, string.format("n%d-%s", 0, npcdata.name))
	g_MapCtrl:UpdateByPosInfo(oNpc, pos_info)
	return oNpc
end

function CChoukaNpc.Trigger(self)
	g_ChoukaCtrl:StartChouka()
end

function CChoukaNpc.SetTouchTipsTag(self)
	
end

return CChoukaNpc