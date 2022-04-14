ArrowItem = ArrowItem or class("ArrowItem",BaseItem)

function ArrowItem:ctor(parent_node)
    self.abName = "Race"
    self.assetName = "ArrowItem"
    self.layer = "UI"

    self.race_model = RaceModel.GetInstance()
    self.race_model_events = {}

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.img_ab_name = "race_image"

    self.arrow_name_and_angle_map = {}  --箭头名字和旋转角度的映射
    self.arrow_name_and_angle_map.left = 90
    self.arrow_name_and_angle_map.right = 270
    self.arrow_name_and_angle_map.up = 0
    self.arrow_name_and_angle_map.down = 180

    ArrowItem.super.Load(self)
end

function ArrowItem:dctor()
    if table.nums(self.race_model_events) > 0 then
        self.race_model:RemoveTabListener(self.race_model_events)
        self.race_model_events = nil
    end
end

function ArrowItem:LoadCallBack(  )
    self.nodes = {
      "arrow_right","arrow_error","arrow_gray",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function ArrowItem:InitUI(  )
    self.arrow_right = GetImage(self.arrow_right)
end

function ArrowItem:AddEvent(  )
    
end

--data
--arrow_name 箭头名字
function ArrowItem:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function ArrowItem:UpdateView()
    self.need_update_view = false

    self:ShowGray()

    local angle = self.arrow_name_and_angle_map[self.data.arrow_name]
    SetRotation(self.arrow_gray,0,0,angle)
    SetRotation(self.arrow_error,0,0,angle)

    lua_resMgr:SetImageTexture(self, self.arrow_right, self.img_ab_name, "arrow_"..self.data.arrow_name,true,nil,false)
end

--指令输入正确
function ArrowItem:InputRight()
    SetVisible(self.arrow_gray,false)
    SetVisible(self.arrow_error,false)
    SetVisible(self.arrow_right,true)
    
end

--指令输入错误
function ArrowItem:InputError(call_back)
    SetVisible(self.arrow_gray,false)
    SetVisible(self.arrow_error,true)
    SetVisible(self.arrow_right,false)

    self:Shake(call_back)
end

--变灰
function ArrowItem:ShowGray()
    SetVisible(self.arrow_gray,true)
    SetVisible(self.arrow_error,false)
    SetVisible(self.arrow_right,false)
end

--指令箭头UI震动
function ArrowItem:Shake(call_back)

    local duration = 0.3
    local shake_x = 5
    local shake_y = 5
    local shake_z = 5

    local cur_time = duration

	local total_time = duration

	local schedule_id = nil

	--先*100再取随机数，取到后/100，实现取浮点随机数效果
	local temp_x = shake_x * 100
	local temp_y = shake_y * 100
	local temp_z = shake_z * 100

	--原始位置
	local old_x,old_y,old_z = GetLocalPosition(self.transform)

	local interval =  Time.deltaTime
	local timer = 0

	local function call_back_2()
		if cur_time > 0 and total_time > 0 then
			local percent = cur_time / total_time
			cur_time = cur_time - Time.deltaTime

			timer = timer + Time.deltaTime
			if timer < interval then
				return
			end
			
			timer = 0

			--震动距离
			local x = Mathf.Random(-Mathf.Abs(temp_x) * percent,Mathf.Abs(temp_x) * percent)
			local y = Mathf.Random(-Mathf.Abs(temp_y) * percent,Mathf.Abs(temp_y) * percent)
			local z = Mathf.Random(-Mathf.Abs(temp_z) * percent,Mathf.Abs(temp_z) * percent)

			--最终位置=原始位置+震动距离
			 x = old_x + x / 100
			 y = old_y + y / 100
			 z = old_z + z / 100

			SetLocalPosition(self.transform,x,y,z)

			 
		else
			SetLocalPosition(self.transform,old_x,old_y,old_z)
            GlobalSchedule:Stop(schedule_id)
            
            if call_back then
                call_back()
            end
		end
	end 

	schedule_id = GlobalSchedule:Start(call_back_2,0)
end


