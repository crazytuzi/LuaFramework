-------------------------------------------
--挖矿场景逻辑
--@author hbf
--------------------------------------------
BaseDigOreLogic = BaseDigOreLogic or BaseClass(BaseSceneLogic)
function BaseDigOreLogic:__init()
	self.fuben_id = 0
	self.idx2obj_list = {}
	
end

function BaseDigOreLogic:__delete()

end

function BaseDigOreLogic:Enter(old_scene_type, new_scene_type)	
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)


	for idx,v in ipairs(MiningActConfig.miningPos) do
		local vo = GameVoManager.Instance:CreateVo(DigOreShowVo)
		vo.pos_x = v.x
		vo.pos_y = v.y
		vo.color = 0xffffff
		vo.slot = idx

		local data = ExperimentData.Instance:GetDigSlotInfoByIndex(idx)
		if data then
			vo.quality = data.quality
			vo.start_dig_time = data.start_dig_time
			vo.role_name = data.role_name
			vo.gilde_name = data.gilde_name
		end
		self.idx2obj_list[idx] = Scene.Instance:CreateObj(vo, SceneObjType.DirOreObj)
	end
end

function BaseDigOreLogic:GetDigShowByIdx(idx)
	return self.idx2obj_list[idx]
end

--退出
function BaseDigOreLogic:Out()
	BaseSceneLogic.Out(self)
	Scene.Instance:ClearDigOreShow() 
	self.idx2obj_list = {}
end

function BaseDigOreLogic:SetFubenId(fuben_id)
	self.fuben_id = fuben_id
end

function BaseDigOreLogic:GetNearPlayerObj()
	local mainrole = Scene.Instance:GetMainRole()
	local role_pos_x, role_pos_y = mainrole:GetLogicPos()
	local dis, sign_idx = 9999999999, 0
	for idx,v in ipairs(MiningActConfig.miningPos) do
		if nil == ExperimentData.Instance:GetDigSlotInfoByIndex(idx) then
			local _dis = (role_pos_x - v.x) * (role_pos_x - v.x) + (role_pos_y - v.y) * (role_pos_y - v.y)
			if _dis < dis then
				sign_idx = idx 
				dis = _dis
			end
		end
	end
	return self.idx2obj_list[sign_idx]
end

function BaseDigOreLogic:GetFubenId()
	return self.fuben_id
end
