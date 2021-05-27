-------------------------------------------------
--为各类ui拖动功能。
--@author bzw
-------------------------------------------------
UiDrag = UiDrag or BaseClass()

function UiDrag:__init()
	self.ui = nil

	self.ui_orgin_pos = nil
	self.ui_orgin_parent = nil

	self.soucre = nil
	self.drag_proxy_ui = nil
	self.orgin_world_pos = nil
	self.drag_area_name = nil
	
	self.is_lock = false
	self.is_draging = false
	self.is_fly_back_on_hitnothing = true
	self.is_fly_back_ing = false

	self.touch_began_callback = nil
	self.touch_move_callback = nil
	self.touch_end_callback = nil
	self.touch_cancle_callback = nil

	self.drag_complete_calback = nil
	self.on_hit_callback = nil
	self.need_call_back = true

	UiDragMgr.Instance:AddUiDrag(self)
end

function UiDrag:__delete()
	if self.ui ~= nil then
		self.ui:release()
		self.ui = nil
	end
	self.soucre = nil
	self.touch_began_callback = nil
	self.touch_move_callback = nil
	self.touch_end_callback = nil
	self.touch_cancle_callback = nil
	self.drag_complete_calback = nil
	self.on_hit_callback = nil

	UiDragMgr.Instance:RemoveUiDrag(self)
end

function UiDrag:SetUi(ui, soucre, drag_area_name, need_call_back)
	if nil ~= self.ui then
		self.ui:release()
	end
	if nil ~= need_call_back then
		self.need_call_back = need_call_back
	end
	self.ui = ui
	self.ui:retain()
	self.scale = ui:getScale()
	self.soucre = soucre
	self.drag_area_name = drag_area_name
	if self.ui ~= nil and self.soucre and not self:IsLock() then
		self.ui:setTouchEnabled(true)
		self.ui:setIsHittedScale(false)
		self.ui:addTouchEventListener(BindTool.Bind1(self.TouchHandler, self))
	end
end

function UiDrag:GetUi()
	return self.ui
end

function UiDrag:SetIsLock(is_lock)
	self.is_lock = is_lock
end

--是否锁定，锁定后拖动和响应都将失效
function UiDrag:IsLock()
	return self.is_lock
end

function UiDrag:GetSource()
	return self.soucre
end

function UiDrag:GetUiOrginPos()
	return self.ui_orgin_pos
end

function UiDrag:SetIsFlybackOnHitNothing(is_fly_back_on_hitnothing)
	self.is_fly_back_on_hitnothing = is_fly_back_on_hitnothing
end

function UiDrag:GetAreaName()
	return self.drag_area_name
end

function UiDrag:BindTouchBegan(touch_began_callback)
	self.touch_began_callback = touch_began_callback
end

function UiDrag:BindTouchMove(touch_move_callback)
	self.touch_move_callback = touch_move_callback
end

function UiDrag:BindTouchEnd(touch_end_callback)
	self.touch_end_callback = touch_end_callback
end

function UiDrag:BindTouchCancle(touch_cancle_callback)
	self.touch_cancle_callback = touch_cancle_callback
end

function UiDrag:BindDragComplete(drag_complete_calback)
	self.drag_complete_calback = drag_complete_calback
end

function UiDrag:BindOnHit(on_hit_callback)
	self.on_hit_callback = on_hit_callback
end

function UiDrag:TouchHandler(sender, event_type, touch)
	if self.ui == nil or self.soucre == nil and self:IsLock() then return end

	if event_type == XuiTouchEventType.Began then
		if not self.is_lock then
			self:OnTouchBegan(sender, touch)
		end
	
	elseif event_type == XuiTouchEventType.Moved then
		self:OnTouchMove(sender, touch)
	elseif event_type == XuiTouchEventType.Ended then
		self:OnTouchEnd(sender, touch)
	elseif event_type == XuiTouchEventType.Canceled then
		self:OnTouchCancle(sender, touch)
	end
end

function UiDrag:OnTouchBegan(sender, touch)
	if self.is_draging or self.is_fly_back_ing then return end

	self.is_draging = true

	local x, y = self.ui:getPosition()
	self.ui_orgin_pos = {x = x, y = y}
	self.ui_orgin_parent = self.ui:getParent()

	-- self.orgin_world_pos = sender:getTouchBeganPosition()
	self.orgin_world_pos = touch:getLocation()

	if self.touch_began_callback ~= nil then
		self.drag_proxy_ui = self.touch_began_callback()
		if self.drag_proxy_ui ~= nil then
			--self.drag_proxy_ui:retain()
			HandleRenderUnit:GetCoreScene():addChildToRenderGroup(self.drag_proxy_ui, GRQ_UI_UP)
		end
	end
	if self.drag_proxy_ui == nil then
		self.drag_proxy_ui = self.ui
		self.drag_proxy_ui:retain()
		self.drag_proxy_ui:removeFromParentAndCleanup(false)
		HandleRenderUnit:GetCoreScene():addChildToRenderGroup(self.drag_proxy_ui, GRQ_UI_UP)
		self.drag_proxy_ui:release()
	end
	self.drag_proxy_ui:setScale(self.scale)
	self.drag_proxy_ui:setPosition(self.orgin_world_pos)
end

function UiDrag:OnTouchMove(sender, touch)
	if not self.is_draging then return end

	local pos = touch:getLocation()
	self.drag_proxy_ui:setPosition(pos)
	if self.touch_move_callback ~= nil then
		self.touch_move_callback()
	end
end

function UiDrag:OnTouchEnd(sender, touch)
	if not self.is_draging then return end

	self.is_draging = false
	self:OnDragComplete(sender, touch)

	if self.touch_end_callback ~= nil then
		self.touch_end_callback()
	end
end

function UiDrag:OnTouchCancle(sender, touch)
	if not self.is_draging then return end

	self.is_draging = false
	self:OnDragComplete(sender, touch)

	if self.touch_cancle_callback ~= nil then
		self.touch_cancle_callback()
	end
end

--拖动完成
function UiDrag:OnDragComplete(sender, touch)
	local touch_pos = touch:getLocation()
	if nil == touch_pos then return end

	local hit_ui_t, touch_pos_tag = UiDragMgr.Instance:GetHitUiDrag(self, touch_pos)

	self.is_week_drag = false
 	local dis = GameMath.GetDistance(touch_pos.x, touch_pos.y, self.orgin_world_pos.x, self.orgin_world_pos.y, true)
 	if dis < 40 then
 		self.is_week_drag = true
 	end

	if hit_ui_t == nil and self.is_fly_back_on_hitnothing and self.need_call_back then --没有命中
		self:FlyBack()
	else
		self:FlyBackComplete(hit_ui_t, touch_pos_tag)
	end
end


--被命中
function UiDrag:OnHit(hitter, drag_ui_source, from_area_name, touch_pos)
	if hitter == nil then return end

	if self.on_hit_callback ~= nil then
		self.on_hit_callback(hitter:GetUi(), drag_ui_source, from_area_name, touch_pos)
	end
end

function UiDrag:FlyBack()
	self.is_fly_back_ing = true
	self.drag_proxy_ui:stopAllActions()

	local move_to =cc.MoveTo:create(0.2, cc.p(self.orgin_world_pos.x, self.orgin_world_pos.y))
	local spawn = cc.Spawn:create(move_to)
	local callback = cc.CallFunc:create(BindTool.Bind2(self.FlyBackComplete, self, nil))
	local action = cc.Sequence:create(spawn, callback)
	self.drag_proxy_ui:runAction(action)
end

function UiDrag:FlyBackComplete(hit_ui_t, touch_pos)
	if self.drag_proxy_ui == self.ui then --原神归位
		self.ui:removeFromParentAndCleanup(false)
		self.ui_orgin_parent:addChild(self.ui)
		self.ui:setPosition(self.ui_orgin_pos)
	else
		self.drag_proxy_ui:removeFromParent() 
	end

	--self.drag_proxy_ui:release()
	self.drag_proxy_ui = nil
	self.ui_orgin_pos = nil
	self.ui_orgin_parent = nil

	if hit_ui_t ~= nil then
		local drag_ui_source = self:GetSource()
		local hit_ui_source =  hit_ui_t:GetSource()
		if type(drag_ui_source) == "table" and drag_ui_source ~= nil then
			drag_ui_source = TableCopy(drag_ui_source)
		end
		if type(hit_ui_source) == "table" and hit_ui_source ~= nil then
			hit_ui_source = TableCopy(hit_ui_source)
		end

		if self.drag_complete_calback ~= nil then
			self.drag_complete_calback(hit_ui_t, hit_ui_source, hit_ui_t:GetAreaName(), self.is_week_drag)
		end

		if hit_ui_t then
			hit_ui_t:OnHit(self, drag_ui_source, self:GetAreaName(), touch_pos)
		end
	else
		if self.drag_complete_calback ~= nil then
			self.drag_complete_calback(nil, nil, nil, self.is_week_drag)
		end
	end

	self.is_fly_back_ing = false
end


-------------------------------------------------
--拖动管理器
--@author bzw
-------------------------------------------------
UiDragMgr = UiDragMgr or BaseClass()

function UiDragMgr:__init()
	self.uidrag_list = {}

	if UiDragMgr.Instance then
		ErrorLog("[UiDragMgr] Attemp to create a singleton twice !")
	end
	UiDragMgr.Instance = self
end

function UiDragMgr:__delete()
	for k,v in pairs(self.uidrag_list) do
		v:DeleteMe()
	end
	UiDragMgr.Instance = nil
end

function UiDragMgr:AddUiDrag(uidrag)
	if uidrag == nil then return end

	table.insert(self.uidrag_list, uidrag)
end

function UiDragMgr:RemoveUiDrag(uidrag)
	for k,v in pairs(self.uidrag_list) do
		if v == uidrag then
			table.remove(self.uidrag_list, k)
			break
		end
	end
end

function UiDragMgr:GetHitUiDrag(from_ui_t, pos)
	for k,v in pairs(self.uidrag_list) do
		local ui = v:GetUi()

		if ui ~= nil and ui ~= from_ui_t:GetUi() and ui:getParent() and not v:IsLock() then
			local touch_pos = ui:getParent():convertToNodeSpace(pos)
			local x, y = ui:getPosition()
			local size = ui:getContentSize()

			local w,h = math.ceil(size.width * ui:getScaleX()),  math.ceil(size.height * ui:getScaleY())
			local anchor = ui:getAnchorPoint()
			x = x - anchor.x * size.width
			y = y - anchor.y * size.height
			
			if touch_pos.x > x and touch_pos.y > y and touch_pos.x < x + w and touch_pos.y < y + h then
				return v, touch_pos
			end
		end
	end
	return nil
end
