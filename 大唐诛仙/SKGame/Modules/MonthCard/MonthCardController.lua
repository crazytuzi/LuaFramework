RegistModules("MonthCard/MonthCardConst")
RegistModules("MonthCard/MonthCardModel")
RegistModules("MonthCard/MonthCardPan")

MonthCardController = BaseClass(LuaController)

function MonthCardController:GetInstance()
	if MonthCardController.inst == nil then
		MonthCardController.inst = MonthCardController.New()
	end
	return MonthCardController.inst
end

function MonthCardController:__init()
	self.model = MonthCardModel:GetInstance()
	self.view = nil

	self:InitEvent()
	self:RegistProto()
end

function MonthCardController:__delete()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	MonthCardController.inst = nil
end

function MonthCardController:InitEvent()
end

-- 协议注册
function MonthCardController:RegistProto()
	self:RegistProtocal("S_GetMonthCardInfo")
	self:RegistProtocal("S_GetMonthCardAward")
end

function MonthCardController:GetCardPanel()
	self:C_GetMonthCardInfo()
	if self.view == nil then
		self.view = MonthCardPan.New()
	end
	return self.view
end

function MonthCardController:DestroyCardPanel()
	if self.view ~= nil then
		self.view:Destroy()
	end
	self.view = nil
end

function MonthCardController:Close()
	if self.view then
		self.view:Close()
	end
end
-- 获取月卡信息
function MonthCardController:C_GetMonthCardInfo()
	self:SendEmptyMsg(player_pb, "C_GetMonthCardInfo")
end

function MonthCardController:C_GetMonthCardAward()
	self:SendEmptyMsg(player_pb, "C_GetMonthCardAward")
end

function MonthCardController:S_GetMonthCardInfo(buff)
	local msg = self:ParseMsg(player_pb.S_GetMonthCardInfo(), buff)
	self.model:ParseMonthCardInfo(msg)
end

function MonthCardController:S_GetMonthCardAward(buff)
	local msg = self:ParseMsg(player_pb.S_GetMonthCardAward(), buff)
	self.model:ParseRewardInfo(msg)
end