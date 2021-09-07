require("game/touxian/touxian_view")
require("game/touxian/touxian_data")

TouXianCtrl = TouXianCtrl or BaseClass(BaseController)
function TouXianCtrl:__init()
	if TouXianCtrl.Instance ~= nil then
		print_error("[TouXianCtrl] attempt to create singleton twice!")
		return
	end
	TouXianCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = TouXianView.New(ViewName.TouXianView)
	self.data = TouXianData.New()

	-- 圣旨界面
	RemindManager.Instance:Register(RemindName.TouXian, BindTool.Bind(self.GetTouXianRemind, self))
end

function TouXianCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil
	RemindManager.Instance:UnRegister(RemindName.TouXian)

	TouXianCtrl.Instance = nil
end

function TouXianCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHonourTitleTriggerSkillInfo, "OnSCHonourTitleTriggerSkillInfo")
	self:RegisterProtocol(SCHonourTitleAllInfo, "OnSCHonourTitleAllInfo")
end

function TouXianCtrl:OnSCHonourTitleTriggerSkillInfo(protocol)
	-- local buff_info = {
	-- 	buff_type = EFFECT_CLIENT_TYPE.ECT_TOUXIAN,
	-- 	time = protocol.param2 * 1000
	-- }
	-- BuffProgressData.Instance:SetBuffInfo(buff_info)
	-- ViewManager.Instance:Open(ViewName.BuffProgressView)
	-- BuffProgressCtrl.Instance:Flush()
end

function TouXianCtrl:OnSCHonourTitleAllInfo(protocol)
	local old_level = self.data:GetCurLevel()
	local role = Scene.Instance:GetObj(protocol.obj_id)
	if role then
		if role:IsMainRole() then
			self.data:SetHonourTitleAllInfo(protocol)
			self.view:Flush()
			if protocol.title_level > old_level and self.view:IsOpen() then
				self.view:CheckJumpIndex()
			end
			RemindManager.Instance:Fire(RemindName.TouXian)
		end
		role:SetAttr("touxian_level", protocol.title_level)
	end
end

function TouXianCtrl:SendReq(req_type, param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHonourTitleReq)
	protocol.req_type = req_type or 0
	protocol.param = param or 0
	protocol:EncodeAndSend()
end

function TouXianCtrl:GetTouXianRemind()
	local cur_level = self.data:GetCurLevel() + 1
	local max_level = #self.data:GetLevelCfg()
	cur_level = cur_level >= max_level and max_level or cur_level
	local cur_cfg =  self.data:GetConfigByLevel(cur_level)
	if not next(cur_cfg) then return 0 end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.capability >= cur_cfg.upgrade_need_capa and ItemData.Instance:GetItemNumIsEnough(cur_cfg.stufff_id, cur_cfg.stuff_num) then
		return 1
	end
	return 0
end

function TouXianCtrl:GetUpButton()
	return self.view:GetUpBtn()
end

function TouXianCtrl:GetClick()
	return self.view.OnClickUp
end

function TouXianCtrl:GetCloseBtn()
	return self.view:GetCloseBtn()
end

function TouXianCtrl:GetCloseClick()
	return self.view.Close
end