_G.classlist['NpcModel'] = 'NpcModel'
_G.NpcModel = NpcModel or {
	npcList = {},       	--视野内NPC列表
	mapNpcList = {},		--当前地图内的NPC列表
	localNpcList = {}, 		--本地加载所有NPC
	storyNpcList = {}
}
NpcModel.objName = 'NpcModel'

function NpcModel:DeleteAllNpc()
	self.npcList = {}
end

function NpcModel:GetNpcList()
	return self.npcList
end

function NpcModel:AddNpc(npc)
	self.npcList[npc.cid] = npc
end

function NpcModel:GetNpc(cid)
	return self.npcList[cid]
end

--根据NPCID 大地图内显示的NPC
function NpcModel:GetNpcByNpcId(npcId)
	for k,npc in pairs(self.mapNpcList) do
		if npc.npcId == npcId then
			return npc;
		end
	end
	return nil;
end

--根据NPCID 视野范围内的显示的NPC
function NpcModel:GetCurrNpcByNpcId(npcId)
	for k,npc in pairs(self.npcList) do
		if npc.npcId == npcId then
			return npc;
		end
	end
	return nil;
end

function NpcModel:DeleteNpc(npc)
	self.npcList[npc.cid] = nil
end

function NpcModel:GetNpcNum()
	local count = 0
	for _, v in pairs(self.npcList) do
		if v ~= nil then
			count = count + 1
		end
	end
	return count
end

function NpcModel:DeleteCurMapNpcList()
	self.mapNpcList = {}
end

function NpcModel:GetCurMapNpcList()
	return self.mapNpcList
end

function NpcModel:AddCurMapNpc(npc)
	self.mapNpcList[npc.cid] = npc
end

function NpcModel:GetCurMapNpc(cid)
	return self.mapNpcList[cid]
end

---------------------------------------------------------------------------
-- npc脚本控制逻辑
---------------------------------------------------------------------------
function NpcModel:GetStoryNpcGid()
	local count = 1
	for _, v in pairs(self.storyNpcList) do
		if v ~= nil then
			count = count + 1
		end
	end
	return count
end

function NpcModel:AddStoryNpc(gid, npc)
	self.storyNpcList[gid] = npc
end

function NpcModel:GetStoryNpc(gid)
	return self.storyNpcList[gid]
end

function NpcModel:DeleteStoryNpc(npc)
	self.storyNpcList[npc.cid] = nil
end

function NpcModel:GetStoryNpcList()
	return self.storyNpcList
end

-----------------------------
function NpcModel:DeleteLocalNpcList()
	self.localNpcList = {}
end

function NpcModel:GetLocalNpcList()
	return self.localNpcList
end

function NpcModel:AddLocalNpc(npc)
	self.localNpcList[npc.cid] = npc
end

function NpcModel:GetLocalNpc(cid)
	return self.localNpcList[cid]
end

function NpcModel:DeleteLocalNpc(npc)
	self.localNpcList[npc.cid] = nil
end



