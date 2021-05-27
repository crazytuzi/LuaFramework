require("scripts/game/role/role_data")

require("scripts/game/role/view/role_view")
require("scripts/game/role/view/role_other_attr_view")
require("scripts/game/role/role_items")

require("scripts/game/role/role_rule_view")
require("scripts/game/role/role_rule_data")
require("scripts/game/role/hallow_rule_view")
require("scripts/game/role/hallow_rule_data")

--------------------------------------------------------------
--角色相关，如属性，装备等
--------------------------------------------------------------
RoleCtrl = RoleCtrl or BaseClass(BaseController)
function RoleCtrl:__init()
	if RoleCtrl.Instance then
		ErrorLog("[RoleCtrl] Attemp to create a singleton twice !")
	end
	RoleCtrl.Instance = self

	self.role_data = RoleData.New()
	self.role_view = RoleView.New(ViewDef.Role)
	self.role_other_attr_view = RoleOtherAttrView.New(ViewDef.RoleOtherAttr)

	self.role_rule_view = RoleRuleView.New(ViewName.RoleRule)
	self.role_rule_data = RoleRuleData.New()

	self.hallow_rule_view = HallowRuleView.New(ViewName.HallowRule)
	self.hallow_rule_data = HallowRuleData.New()

	self:RegisterAllProtocols()
end

function RoleCtrl:__delete()
	RoleCtrl.Instance = nil

	self.role_data:DeleteMe()
	self.role_data = nil

	self.role_view:DeleteMe()
	self.role_view = nil

	self.role_other_attr_view:DeleteMe()
	self.role_other_attr_view = nil
--------------------------------------------

	self.role_rule_view:DeleteMe()
	self.role_rule_view = nil

	self.role_rule_data:DeleteMe()
	self.role_rule_data = nil

	self.hallow_rule_view:DeleteMe()
	self.hallow_rule_view = nil

	self.hallow_rule_data:DeleteMe()
	self.hallow_rule_data = nil
end

function RoleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCreateMainRole, "OnCreateMainRole")
	self:RegisterProtocol(SCMainRoleAttrChange, "OnMainRoleAttrChange")
	self:RegisterProtocol(SCMainRoleSpecialAttrChange, "OnMainRoleSpecialAttrChange")
end

function RoleCtrl:OnCreateMainRole(protocol)
	if nil ~= MainLoader.CloseReconnectView then
		MainLoader:CloseReconnectView()
	end

	-- 设置主角属性
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local names = Split(protocol.all_name, "\\")
	main_role_vo.entity_type = EntityType.Role
	main_role_vo.name = names[1] or ""
	main_role_vo.guild_name = names[3] or ""
	main_role_vo.partner_name = names[6] or ""
	main_role_vo.pos_x = protocol.attr[OBJ_ATTR.ENTITY_X]
	main_role_vo.pos_y = protocol.attr[OBJ_ATTR.ENTITY_Y]
	main_role_vo.dir = protocol.attr[OBJ_ATTR.ENTITY_DIR]
	main_role_vo.create_time = protocol.create_time
	main_role_vo.primary_server_id = protocol.primary_server_id
	main_role_vo.role_id = protocol.attr[OBJ_ATTR.ENTITY_ID]

	for k, v in pairs(protocol.attr) do
		main_role_vo[k] = v
	end


	Scene.Instance:ChangeMainRoleObjId(protocol.obj_id)

	GlobalEventSystem:Fire(LoginEventType.RECV_MAIN_ROLE_INFO)
	GlobalEventSystem:Fire(LoginEventType.ENTER_GAME_SERVER_SUCC)

	ViewManager.Instance:OpenViewByDef(ViewDef.MainUi)

	if RoleCtrl.ROLE_CREATED then
		if AgentAdapter.ReportOnCreateRole then
			AgentAdapter:ReportOnCreateRole(main_role_vo.name)
		end
		GlobalEventSystem:FireNextFrame(OtherEventType.CREATE_ROLE_SUCC)
		-- local use_vo = GameVoManager.Instance:GetUserVo()
		-- if AgentMs.ReportUrl then
		-- 	AgentMs:ReportUrl(use_vo.plat_server_id, main_role_vo.name, use_vo.cur_role_id, main_role_vo[OBJ_ATTR.CREATURE_LEVEL], "", "login")
		-- end
        
	end
	AgentMs:ReportEvent(AgentMs.REPORT_EVENT_LOGIN_GAME)
     --上传创角信息给后台
    if AgentMs.ReportCreateRoleInfo then
	    AgentMs:ReportCreateRoleInfo(main_role_vo.role_id)
	end
   
end

function RoleCtrl:OnMainRoleAttrChange(protocol)
	local main_role = Scene.Instance:GetMainRole()
	local old_value = 0
	for k, v in pairs(protocol.attr_list) do
		old_value = self.role_data:GetAttr(v.index) or 0
		main_role:SetAttr(v.index, v.value)
		self.role_data:OnChangeAttr(v.index, v.value, old_value)
		-- if v.index == OBJ_ATTR.ACTOR_PK_MODE and old_value ~= v.value then
		-- 	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_PK_MODE_CHANGE, v.value)
		-- end
		
		if v.index == OBJ_ATTR.CREATURE_LEVEL and old_value ~= v.value then
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			local user_vo = GameVoManager.Instance:GetUserVo()
			if AgentAdapter.ReportOnRoleLevUp and nil ~= main_role_vo and nil ~= user_vo then
				local zone_name = user_vo.plat_server_id .. "服-" .. user_vo.plat_server_name
				AgentAdapter:ReportOnRoleLevUp(main_role_vo.role_id, main_role_vo.name, main_role_vo[OBJ_ATTR.CREATURE_LEVEL], main_role_vo.server_id, zone_name)
			end

			GlobalEventSystem:Fire(OtherEventType.MAIN_ROLE_LEVEL_CHANGE)
		end

		if v.index == OBJ_ATTR.ACTOR_CIRCLE and old_value ~= v.value then
			GlobalEventSystem:Fire(OtherEventType.MAIN_ROLE_CIRCLE_CHANGE)
		end
	end
end

function RoleCtrl:OnMainRoleSpecialAttrChange(protocol)
	local main_role = Scene.Instance:GetMainRole()
	local old_value = 0

	for k, v in pairs(protocol.attr_other_list) do
		old_value = self.role_data:GetAttr(k) or 0
		main_role:SetAttr(k, v)
		self.role_data:OnChangeAttr(k, v, old_value)
	end
end
