require("game/advance/skill/advance_skill_view")
require("game/advance/skill/advance_skill_data")
require("game/advance/skill/advance_get_skill_view")
require("game/advance/skill/advance_skill_all_view")
require("game/advance/skill/advance_skill_book_view")
require("game/advance/skill/advance_skill_copy")
require("game/advance/skill/advance_skill_one_view")
require("game/advance/skill/advance_skill_info")

AdvanceSkillCtrl = AdvanceSkillCtrl or BaseClass(BaseController)

function AdvanceSkillCtrl:__init()
	if AdvanceSkillCtrl.Instance then
		print_error("[AdvanceSkillCtrl] Attemp to create a singleton twice !")
		return
	end
	AdvanceSkillCtrl.Instance = self

	self.data = AdvanceSkillData.New()
	self.view = AdvanceSkillView.New(ViewName.AdvanceSkillView)
	self.get_view = AdvanceGetSkillView.New(ViewName.AdvanceSkillGetView)
	self.all_view = AdvanceSkillAllView.New(ViewName.AdvanceSkillAllView)
	self.book_view = AdvanceSkillBookView.New(ViewName.AdvanceSkillBookView)
	self.copy_view = AdvanceSkillCopyView.New(ViewName.AdvanceSkillCopyView)
	self.one_view = AdvanceSkillOneView.New(ViewName.AdvanceSkillOneView)
	self.info_view = AdvanceSkillInfoView.New(ViewName.AdvanceSkillInfoView)

	self:RegisterAllProtocols()
end

function AdvanceSkillCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.get_view ~= nil then
		self.get_view:DeleteMe()
		self.get_view = nil
	end

	if self.all_view ~= nil then
		self.all_view:DeleteMe()
		self.all_view = nil
	end

	if self.book_view ~= nil then
		self.book_view:DeleteMe()
		self.book_view = nil
	end

	if self.copy_view ~= nil then
		self.copy_view:DeleteMe()
		self.copy_view = nil
	end

	if self.one_view ~= nil then
		self.one_view:DeleteMe()
		self.one_view = nil
	end

	if self.info_view ~= nil then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	AdvanceSkillCtrl.Instance = nil
end

function AdvanceSkillCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSJingLingOper)
	self:RegisterProtocol(SCImageSkillInfo, "OnSCImageSkillInfo")
end

function AdvanceSkillCtrl:OpenView(show_type)
	if show_type ~= nil then
		self.view:SetShowType(show_type)
	end
	self.view:Open()
end

function AdvanceSkillCtrl:OnSCImageSkillInfo(protocol)
	self.data:SetAdvanceSkillInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end

	if self.get_view:IsOpen() then
		self.get_view:Flush()
	end

	if self.all_view:IsOpen() then
		self.all_view:Flush()
	end

	if self.book_view:IsOpen() then
		self.book_view:Flush()
	end

	if self.copy_view:IsOpen() then
		self.copy_view:Flush()
	end

	if self.one_view:IsOpen() then
		self.one_view:Flush()
	end

	if self.info_view:IsOpen() then
		self.info_view:Flush()
	end

	AdvanceCtrl.Instance:FlushView()
	RemindManager.Instance:Fire(RemindName.AdvanceMount)
	RemindManager.Instance:Fire(RemindName.AdvanceWing)
	RemindManager.Instance:Fire(RemindName.AdvanceHalo)
	RemindManager.Instance:Fire(RemindName.AdvanceFightMount)
	RemindManager.Instance:Fire(RemindName.AdvanceBeautyHalo)
	RemindManager.Instance:Fire(RemindName.AdvanceHalidom)
	RemindManager.Instance:Fire(RemindName.AdvanceFoot)
	RemindManager.Instance:Fire(RemindName.AdvanceMantle)
end

function AdvanceSkillCtrl:OpenSkillInfoView(from_view)
	if from_view ~= nil then
		self.info_view:SetFromView(from_view)
		self.info_view:Open()
	end
end

function AdvanceSkillCtrl:SetBookShowType(show_type)
	self.book_view:SetShowType(show_type)
end

function AdvanceSkillCtrl:SendAdvanceSkillOpera(oper_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJingLingOper)
	send_protocol.oper_type = oper_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end 

function AdvanceSkillCtrl:GetShowType()
	return self.view:GetShowType()
end