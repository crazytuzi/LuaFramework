--[[
	新天神
]]

_G.NewTianshenController = setmetatable({},{__index=IController})

NewTianshenController.name = 'NewTianshenController';

function NewTianshenController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_TianShenList,self,self.OnNewTianshenInit);
	MsgManager:RegisterCallBack(MsgType.SC_TianShenOperStarResult,self,self.OnNewTianshenStarResult);
	MsgManager:RegisterCallBack(MsgType.SC_TianShenOperStepResult,self,self.OnNewTianshenLvResult);
	MsgManager:RegisterCallBack(MsgType.SC_TianShenOperEquipResult,self,self.OnNewTianshenEquipResult);
	MsgManager:RegisterCallBack(MsgType.SC_TianShenOperComposeResult,self,self.OnNewTianshenComposeResult);
	MsgManager:RegisterCallBack(MsgType.SC_TianShenOperInheritResult,self,self.OnNewTianshenInheritResult)
	MsgManager:RegisterCallBack(MsgType.SC_TianShenOperDiscardResult,self,self.OnNewTianshenDisResult)
end

function NewTianshenController:OnNewTianshenInit(msg)
	NewTianshenModel:InitData(msg.list)
end

--申请升星
function NewTianshenController:AskStarUp(id, starlist)
	local msg = ReqTianShenOperStarMsg:new()
	msg.id = id
	msg.starlist = starlist
	MsgManager:Send(msg)
end

--升星返回
function NewTianshenController:OnNewTianshenStarResult(msg)
	-- if msg.result == 0 then
	-- 	--升星成功
	-- 	--msg.id
	-- else
	-- 	--失败
	-- 	FloatManager:AddNormal(StrConfig["newtianshen112"])
	-- end
	self:sendNotification(NotifyConsts.tianShenStarUpUpdata, {msg.result})
end

--申请升级
function NewTianshenController:AskLvUp(id, flags)
	local msg = ReqTianShenOperStepMsg:new()
	msg.id = id
	msg.flags = flags
	MsgManager:Send(msg)
end

--升级返回
function NewTianshenController:OnNewTianshenLvResult(msg)
	if msg.result == 0 then
		--成功
		--msg.id
		self:sendNotification(NotifyConsts.tianShenLvUpUpdata)
	else
		--失败
	end
end

--申请出站  如果收回pos填-1
function NewTianshenController:AskFight(id, pos)
	local msg = ReqTianShenOperEquipMsg:new()
	msg.id = id
	msg.pos = pos
	MsgManager:Send(msg)
end

--出站结果
function NewTianshenController:OnNewTianshenEquipResult(msg)
	if msg.result == 0 then
		--msg.id
		--msg.pos
		self:sendNotification(NotifyConsts.tianShenOutUpdata, {msg.pos})
	else
		--失败
	end
end

--合成
function NewTianshenController:AskCompose(complist)
	local msg = ReqTianShenOperComposeMsg:new()
	msg.complist = complist
	MsgManager:Send(msg)
end

--合成结果
function NewTianshenController:OnNewTianshenComposeResult(msg)
	if msg.result == 0 then
		--成功
	end
	self:sendNotification(NotifyConsts.tianShenComUpdata)
	UINewTianshenComposeResult:Open(msg.compid, msg.result)
end

--申请传承
function NewTianshenController:AskResp(id, tarid, oper)
	local msg = ReqTianShenOperInheritMsg:new()
	msg.id = id
	msg.tarid = tarid
	msg.oper = oper
	MsgManager:Send(msg)
end

--传承结果
function NewTianshenController:OnNewTianshenInheritResult(msg)
	if msg.result == 0 then
		--msg.id
		--msg.tarid
		self:sendNotification(NotifyConsts.tianShenRespUpdata)
	end
end

--申请摧毁
function NewTianshenController:AskDis(id)
	local msg = ReqTianShenOperDiscardMsg:new()
	msg.id = id
	MsgManager:Send(msg)
end

--摧毁结果
function NewTianshenController:OnNewTianshenDisResult(msg)
	if msg.result == 0 then
		--msg.id
		NewTianshenModel:DisTianshen(msg.id)
		self:sendNotification(NotifyConsts.tianShenDisUpdata)
	end
end