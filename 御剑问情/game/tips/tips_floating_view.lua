TipsFloatingView = TipsFloatingView or BaseClass(BaseView)

local MAX_SHOW_LENGTH = 5 	-- 最多显示数量
local SPACE_OFFSET = 32		-- 间隔
local MOVE_TIME = 0.4		-- 进来时间
local OUT_SPEED = 1.2			-- 出去时间

function TipsFloatingView:__init()
	self.ui_config = {"uis/views/tips/floatingtips_prefab", "FloatingTips"}
	self.view_layer = UiLayer.PopTop

	self.messge = ""
	self.is_loading = false
	self.load_text_obj_count = 0
	self.msg_list = {}
	self.text_rect_list = {}
	self.once_distance = 30
	self.text_list = {}
	self.obj_list = {}
	self.can_load_next = true
	self.tween_list = {}
end

function TipsFloatingView:__delete()
end

function TipsFloatingView:LoadCallBack()
	self.text_root = self:FindObj("TextRoot")
end

function TipsFloatingView:ReleaseCallBack()
	self:RemoceDelay()
	self:DestroyObj()

	-- 清理变量和对象
	self.text = nil
	self.text_root = nil
end

function TipsFloatingView:OpenCallBack()
	local rect = self.text_root:GetComponent(typeof(UnityEngine.RectTransform))
	self.root_height = rect.rect.height
end

function TipsFloatingView:CloseCallBack()
	self:RemoceDelay()
	self:DestroyObj()
	self.load_text_obj_count = 0
	self.text_rect_list = {}
end

function TipsFloatingView:SetCallBack(remove_call_back)
	self.remove_call_back = remove_call_back
end

function TipsFloatingView:Show(msg)
	self:Flush()
end

function TipsFloatingView:DestroyObj()
	for k, v in pairs(self.obj_list) do
		GameObjectPool.Instance:Free(v)
	end
	self.obj_list = {}

	for k, v in pairs(self.text_rect_list) do
		GameObjectPool.Instance:Free(v.obj)
	end
	self.text_rect_list = {}

	self.tween_list = {}
end

function TipsFloatingView:RemoceDelay()
	if self.close_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function TipsFloatingView:InsertMsg(msg)
	table.insert(self.msg_list, msg)
	-- self:ShowText()
end

function TipsFloatingView:ShowText()
	if not self:IsOpen() then
		return
	end
	
	self:LoadTextPrefab()
end

function TipsFloatingView:LoadTextPrefab()
	if self.is_loading or #self.msg_list <= 0 or not self.can_load_next then return end

	self:RemoceDelay()

	self.is_loading = true
	self.can_load_next = false

	GameObjectPool.Instance:SpawnAsset("uis/views/tips/floatingtips_prefab", "FloatingText", function(obj)
		if nil == obj then
			return
		end
		self.load_text_obj_count = self.load_text_obj_count + 1

		if self.text_root then
			obj.transform:SetParent(self.text_root.transform, false)
		end

		local rect_tran = obj:GetComponent(typeof(UnityEngine.RectTransform))
		local text = obj:GetComponent(typeof(UnityEngine.UI.Text))
		local canvas_group = obj:GetComponent(typeof(UnityEngine.CanvasGroup))

		text.text = self.msg_list[1]
		self:RemoveMsg()

		self.obj_list[obj] = obj

		-- 把prefab坐标设置到最下面屏幕外
		rect_tran:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, self.root_height, text.preferredHeight)

		canvas_group.alpha = 0

		self:CalculatePosition()
		-- 移动prefab
		local tween = rect_tran:DOAnchorPosY(rect_tran.anchoredPosition.y + self.once_distance + SPACE_OFFSET, MOVE_TIME)

		tween:SetEase(DG.Tweening.Ease.InOutSine)
		tween:OnUpdate(function()
			canvas_group.alpha = canvas_group.alpha + UnityEngine.Time.deltaTime / MOVE_TIME
		end)
		tween:OnComplete(function ()
			self.obj_list[obj] = nil
			local temp_list = {rect_tran = rect_tran, text = text, obj = obj, canvas_group = canvas_group}
			self.text_rect_list[rect_tran] = temp_list

			if #self.msg_list <= 1 and nil == self.close_timer then
				self.close_timer = GlobalTimerQuest:AddDelayTimer(
					BindTool.Bind(self.CloseTips, self), 2)
				self:CalculatePosition()
			end
			self.can_load_next = true
		end)

		self.is_loading = false
	end)
end

function TipsFloatingView:CalculatePosition()
	for k, v in pairs(self.text_rect_list) do
		if nil == self.tween_list[v.rect_tran] then
			self.tween_list[v.rect_tran] = v.rect_tran
			local tween = v.rect_tran:DOAnchorPosY(v.rect_tran.anchoredPosition.y + self.once_distance, MOVE_TIME)
			tween:SetEase(DG.Tweening.Ease.Linear)
			tween:OnComplete(function ()
				tween = v.rect_tran:DOAnchorPosY(self.once_distance - v.rect_tran.anchoredPosition.y, OUT_SPEED)
				tween:OnUpdate(function()
					v.canvas_group.alpha = v.canvas_group.alpha - UnityEngine.Time.deltaTime / MOVE_TIME * 1.5
				end)
				tween:OnComplete(function ()
					if v.rect_tran.anchoredPosition.y >= self.once_distance and nil ~= self.tween_list[v.rect_tran] then
						self.tween_list[v.rect_tran] = nil
						self.load_text_obj_count = self.load_text_obj_count - 1
						GameObjectPool.Instance:Free(v.obj)
						-- GameObject.Destroy(v.obj)
						self.text_rect_list[v.rect_tran] = nil
					end
				end)
			end)
		end
	end
end

function TipsFloatingView:RemoveMsg()
	table.remove(self.msg_list, 1)
	if nil ~= self.remove_call_back then
		self.remove_call_back()
	end
end

function TipsFloatingView:CloseTips()
	self:Close()
end

function TipsFloatingView:SetRendering(value)

end

function TipsFloatingView:OnFlush(param_list)
	-- self.text:SetValue(self.messge)
	self:ShowText()
end