RegistModules("ChouDi/View/ChouDiPanel")
RegistModules("ChouDi/View/ChouDiItem")
RegistModules("ChouDi/View/ZhuiZongPanel")

RegistModules("ChouDi/ChouDiConst")
RegistModules("ChouDi/ChouDiModel")

ChouDiController = BaseClass(LuaController)


function ChouDiController:GetInstance()
	if ChouDiController.inst == nil then
		ChouDiController.inst = ChouDiController.New()
	end
	return ChouDiController.inst
end

function ChouDiController:__init()
	self.model = ChouDiModel:GetInstance()
	if self.isInited then return end
	resMgr:AddUIAB("ChouDi")

	self:RegistProto()
end

function ChouDiController:RegistProto()
	self:RegistProtocal("S_SynEnemyList")
	self:RegistProtocal("S_DeleteEnemy")
	self:RegistProtocal("S_TrackEnemy")
end
 
--获取仇敌列表
function ChouDiController:GetEnemyLit()
	local enemyList = {}
	for i,v in ipairs(self.model.choudiList) do
		table.insert(enemyList, v)
	end
	return enemyList
end


function ChouDiController:S_SynEnemyList(buffer)                       --接收仇敌列表
	self.model.choudiList = {}
	local msg = self:ParseMsg(enemy_pb.S_SynEnemyList(), buffer)
	SerialiseProtobufList( msg.listEnemy, function ( item )            --table赋值***********
		table.insert(self.model.choudiList, item )
	end )
	table.sort(self.model.choudiList, function(a,b)    
		return a.createTime > b.createTime                   --createTime--LLLLL
	end)
	if #self.model.choudiList > 50 then
		for i=#self.model.choudiList, 51, -1 do
			table.remove(#self.model.choudiList, i)
		end
	end
	self.model:DispatchEvent(ChouDiConst.CHOUDILIST_LOAD)
end

function ChouDiController:S_DeleteEnemy(buffer)                --接收删除仇敌消息
	local msg = self:ParseMsg(enemy_pb.S_DeleteEnemy(), buffer)
	for i = #self.model.choudiList , 1 ,-1 do
		if self.model.choudiList[i].enemyPlayerId == msg.enemyPlayerId then
			table.remove(self.model.choudiList, i)
		end
	end
	self.model:DispatchEvent(ChouDiConst.DELETECHOUDI)
end

function ChouDiController:S_TrackEnemy(buffer)
	local msg = self:ParseMsg(enemy_pb.S_TrackEnemy(), buffer)
	self.model.playerName = msg.playerName
	self.model.mapId = msg.mapId
	self.model:DispatchEvent(ChouDiConst.ZHUIZONG)
end



function ChouDiController:C_GetEnemyList()
	self:SendEmptyMsg(enemy_pb, "C_GetEnemyList")
end

function ChouDiController:C_DeleteEnemy(enemyPlayerId)
	local msg = enemy_pb.C_DeleteEnemy()
	msg.enemyPlayerId = enemyPlayerId
	self:SendMsg("C_DeleteEnemy", msg)
end

function ChouDiController:C_TrackEnemy(enemyPlayerId)       --追踪
	local msg = enemy_pb.C_TrackEnemy()
	msg.enemyPlayerId = enemyPlayerId
	self:SendMsg("C_TrackEnemy", msg)
end

function ChouDiController:__delete()
	ChouDiController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end