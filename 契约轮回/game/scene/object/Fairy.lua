 --
-- @Author: LaoY
-- @Date:   2019-01-09 20:11:26
-- 小恶魔 小天使
Fairy = Fairy or class("Fairy",DependObjcet)
function Fairy:ctor()
	self.check_follow_range_square = 100 * 100
	self.smooth_time = 0.45
	self.stop_check_offset_time = 5
	self.follow_angle = 135
	
	self:ChangeBody()

	self:SetPosition(self:GetFollowPosition())
	self:SetBodyPosition(0,120)
	UpdateBeat:Add(self.Update, self, 1)
end

function Fairy:dctor()
	if self.scheduleId then
		GlobalSchedule:Stop(self.scheduleId)
		self.scheduleId = nil
	end
end

function Fairy:AddEvent()
	local function call_back(slot,data)
		if slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY or slot == enum.ITEM_STYPE.ITEM_STYPE_FAIRY2 then
			self:ChangeBody()
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EquipEvent.PutOnEquip, call_back)
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EquipEvent.PutOffEquip, call_back)

	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.baby",call_back)

	local function call_back()
		self:LoadBabyWing()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.baby_wing",call_back)
end

function Fairy:ChangeBody()
    -- self:RemoveDependObject()

	local abName
	local assetName

	self.main_role = SceneManager:GetInstance():GetMainRole()
	local res_id = self.owner_info.figure.baby and self.owner_info.figure.baby.model
    local show = self.owner_info.figure.baby and self.owner_info.figure.baby.show

    if show then
    	local cf = Config.db_baby_order[res_id .. "@0"]
    	if cf then
	        abName = cf.res_id
	        assetName = cf.res_id
	    end
    end
    if not abName then
        local item_id = EquipModel:GetInstance():GetEquipDevilOrFairy()


		if not item_id then
			return
		end
		local config = Config.db_fairy[item_id]

		if not config then
			return
		end

		local res_id = config.resource
		abName = "model_cw_" .. res_id
		assetName = "model_cw_" .. res_id
    end
	
	if abName then
		self:CreateBodyModel(abName,assetName)
	end

	local item_id = EquipModel:GetInstance():GetEquipDevil()


	if not item_id then
		if self.scheduleId then
			GlobalSchedule:Stop(self.scheduleId)
			self.scheduleId = nil
		end
		return
	end
	local config = Config.db_fairy[item_id]

	if not config then
		if self.scheduleId then
			GlobalSchedule:Stop(self.scheduleId)
			self.scheduleId = nil
		end
		return
	end
	local pItem = EquipModel:GetInstance():GetEquipBySlot(enum.ITEM_STYPE.ITEM_STYPE_FAIRY)
	self.etime = pItem.etime
	self.pickup = config.pickup
	local  IsExpire = BagModel:GetInstance():IsExpire(self.etime)
	if self.owner_object.is_main_role and self.pickup  == 1 and not IsExpire then
		if self.scheduleId then
			GlobalSchedule:Stop(self.scheduleId)
			self.scheduleId = nil
		end
		self.scheduleId = GlobalSchedule.StartFun(handler(self, self.CheckDrop), 1, -1)
	else
		if self.scheduleId then
			GlobalSchedule:Stop(self.scheduleId)
			self.scheduleId = nil
		end
	end
end

--local time = 1
 function Fairy:CheckDrop()
	 if  BagModel:GetInstance():IsExpire(self.etime) or self.pickup ~= 1 then
		 return
	 end
	 local drop_list = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_DROP) or {}
	 if table.isempty(drop_list) then
		 return
	 end
	 local scene_id = SceneManager:GetInstance():GetSceneId()
	 local config = Config.db_scene[scene_id]
	 if  config then
		 if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT  then
			 return
		 end
	 end
		 local index = 1
		 local list = {}
		 for id, drop in pairs(drop_list) do
			 if index > 5 then
				 break
			 end
			 local distance = Vector2.Distance(self.main_role:GetPosition(), drop.position)
			 if drop.object_info.drop_type == enum.DROP_MODE.DROP_MODE_SCENE  and drop:IsCanPick() and distance <= 500 then
				 if  not list[index] then
					 list[index] = {}
					 list[index]["id"] = id
					 list[index]["distance"] = distance
				 end
				 index  = index + 1
			 end

		 end

		 if not table.isempty(list) then
			 local scene_id = SceneManager:GetInstance():GetSceneId()
			 table.sort(list, function(a,b)
				return a.distance < b.distance
			 end)
			 GlobalEvent:Brocast(FightEvent.ReqAutoPickUp, list, scene_id)
		 end
 end

 function Fairy:LoadBodyCallBack()
	self:LoadBabyWing()
 	-- if self.owner_info.figure.baby and self.owner_info.figure.baby.show then
 	-- end
 end

 function Fairy:LoadBabyWing()
 	if not self.transform then
 		return
 	end
 	
 	local show = self.owner_info.figure.baby and self.owner_info.figure.baby.show
 	if not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_WING, 1)
        return
 	end
 	local res_id = self.owner_info.figure.baby_wing and self.owner_info.figure.baby_wing.model
    local show = self.owner_info.figure.baby_wing and self.owner_info.figure.baby_wing.show
    if not res_id or res_id == 0 or not show then
        self:RemoveDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_WING, 1)
    else
        self:CreateDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_WING, 1)
    end
 end