MainCollectgarbageText = MainCollectgarbageText or BaseClass(BaseView)

local m_accum = 0
local m_frames = 0
local m_time_left = 1

function MainCollectgarbageText:__init()
	self.ui_config = {"uis/views/main_prefab", "CollectgarbageText"}
	self.view_layer = UiLayer.Standby
	self.is_show = true
	Runner.Instance:AddRunObj(self, 16)
end

function MainCollectgarbageText:__delete()

end

function MainCollectgarbageText:LoadCallBack()
	self.text = self:FindVariable("text")
	self.fps_text = self:FindVariable("fps_text")
	self.is_show_view = self:FindVariable("is_show_view")
	self.move_text = self:FindObj("MoveText")
	self.att_text = self:FindObj("AttText")
	self:ListenEvent("AddRole", BindTool.Bind(self.AddRole,self))
	self:ListenEvent("AttckerRole", BindTool.Bind(self.AttckerRole,self))
	self:ListenEvent("CloseBtn", BindTool.Bind(self.CloseBtn,self))
	self:ListenEvent("RemoveRole", BindTool.Bind(self.RemoveRole,self))
	-- self:ListenEvent("MoveValueChange", BindTool.Bind(self.MoveValueChange, self))
	-- self:ListenEvent("AttValueChange", BindTool.Bind(self.AttValueChange, self))
end

function MainCollectgarbageText:CloseCallBack()
	Runner.Instance:RemoveRunObj(self)
end

function MainCollectgarbageText:ReleaseCallBack()
	-- 释放变量
	self.text = nil
	self.fps_text = nil
	self.is_show_view = nil
	self.move_text = nil
	self.att_text = nil
	Runner.Instance:RemoveRunObj(self)
end

function MainCollectgarbageText:Update()
	self:FpsUpdate()
end

function MainCollectgarbageText:MoveValueChange()
	local num = tonumber(self.move_text.input_field.text)
	if num == nil then
		SysMsgCtrl.Instance:ErrorRemind("请输入数字")
	end
end

function MainCollectgarbageText:AttValueChange()
	local num = tonumber(self.att_text.input_field.text)
	if num == nil then
		SysMsgCtrl.Instance:ErrorRemind("请输入数字")
	end
end

function MainCollectgarbageText:FpsUpdate()
	m_time_left = m_time_left - UnityEngine.Time.deltaTime 
    m_accum = m_accum + (UnityEngine.Time.timeScale / UnityEngine.Time.deltaTime) 
    m_frames = m_frames + 1
    if (m_time_left <= 0) then        
        local fps = m_accum / m_frames 
        local str = string.format("FPS:%.2f",fps)
        if self.fps_text then
			self.fps_text:SetValue(str)
		end 

		local lua_count = collectgarbage("count")
		if self.text then
			local str = string.format("COUNT:%.2f",lua_count)
			self.text:SetValue(str)
		end

        m_time_left = 1
        m_accum = 0 
        m_frames = 0  
    end 
end

function MainCollectgarbageText:AddRole()
	local num = tonumber(self.move_text.input_field.text) or 10
	-- error(num)
	for k = 1, num do
		self:CreateTestRole()
		-- error(type(changeblood))
	end
end

function MainCollectgarbageText:RemoveRole()
	Scene.Instance:DeleteObjsByType(SceneObjType.TestRole)
	obj_id_inc = 200000
	att_obj_id_inc = 210000
end

local obj_id_inc = 200000

function MainCollectgarbageText:CreateTestRole()
	obj_id_inc = obj_id_inc + 1
	local vo = TableCopy(GameVoManager.Instance:GetMainRoleVo())
	
	local prof_list = {
		{1, 1, 8109},
		{2, 0, 8209},
		{3, 1, 8309},
		{4, 0, 8409},
	}

	local prof_index = math.floor(math.random(1, 4))

	local main_role = Scene.Instance:GetMainRole()
 	if main_role then
 		local role_pos_x, role_pos_y = main_role:GetLogicPos()
 		vo.pos_x = math.floor(math.random(-30, 30)) + role_pos_x
		vo.pos_y = math.floor(math.random(-30, 30)) + role_pos_y
 	end
 	
	vo.role_id = obj_id_inc
	vo.obj_id = obj_id_inc
	vo.sex = prof_list[prof_index][2] or 1
	vo.prof =  prof_list[prof_index][1] or 1
	vo.wuqi_id = prof_list[prof_index][3] or vo.wuqi_id
	vo.appearance.wuqi_id = math.floor(math.random(1, 10))
	vo.mount_appeid = math.floor(math.random(1000, 1005))
	vo.appearance.wing_used_imageid = math.floor(math.random(1, 10))
	vo.appearance.fazhen_image_id = math.floor(math.random(1, 10))
	vo.move_speed = vo.move_speed + math.floor(math.random(-50, 50))

	local test_role = Scene.Instance:CreateTestRole(vo, SceneObjType.TestRole)
	test_role:SetTestMove()
end

local att_obj_id_inc = 210000

function MainCollectgarbageText:AttckerRole()
	local num = tonumber(self.att_text.input_field.text) or 1

	for k = 1, 2 * num do
		self:CreateAttTestRole()
	end
	self:StartAttcker()
end

function MainCollectgarbageText:CreateAttTestRole()
	att_obj_id_inc = att_obj_id_inc + 1
	local vo = TableCopy(GameVoManager.Instance:GetMainRoleVo())
	
	local prof_list = {
		{1, 1, 8109},
		{2, 0, 8209},
		{3, 1, 8309},
		{4, 0, 8409},
	}

	local prof_index = math.floor(math.random(1, 4))

	vo.role_id = att_obj_id_inc
	vo.obj_id = att_obj_id_inc
	
	local main_role = Scene.Instance:GetMainRole()
 	if main_role then
 		local role_pos_x, role_pos_y = main_role:GetLogicPos()
 		vo.pos_x = math.floor(math.random(-10, 10)) + role_pos_x
		vo.pos_y = math.floor(math.random(-10, 10)) + role_pos_y
 	end

	vo.sex = prof_list[prof_index][2] or 1
	vo.prof =  prof_list[prof_index][1] or 1
	vo.wuqi_id = prof_list[prof_index][3] or vo.wuqi_id
	vo.appearance.wuqi_id = math.floor(math.random(1, 10))
	vo.mount_appeid = 0
	vo.appearance.wing_used_imageid = math.floor(math.random(1, 10))
	vo.appearance.fazhen_image_id = math.floor(math.random(1, 10))
	vo.move_speed = vo.move_speed + math.floor(math.random(-50, 50))

	local test_role = Scene.Instance:CreateTestRole(vo, SceneObjType.TestRole)
	test_role:SetAttckerRole()
end

function MainCollectgarbageText:StartAttcker()
	local is_has_attr = 0
	for i = 210000, att_obj_id_inc do
		local one_target = Scene.Instance:GetObjByTypeAndKey(SceneObjType.TestRole, i)
		if one_target ~= nil then
			local two_target = nil
			if is_has_attr == 0 then
				two_target = Scene.Instance:GetObjByTypeAndKey(SceneObjType.TestRole, i + 1)
				if two_target ~= nil then
					one_target:SetAtkTarget(two_target)
					is_has_attr = 1
				end
			else
				two_target = Scene.Instance:GetObjByTypeAndKey(SceneObjType.TestRole, i - 1)
				if two_target ~= nil then
					one_target:SetAtkTarget(two_target)
					is_has_attr = 0
				end
			end
		end
	end
end

function MainCollectgarbageText:CloseBtn()
	self.is_show = not self.is_show
	self.is_show_view:SetValue(self.is_show)
end