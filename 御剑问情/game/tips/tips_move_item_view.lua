TipsMoveItemView = TipsMoveItemView or BaseClass(BaseView)

function TipsMoveItemView:__init()
	self.ui_config = {"uis/views/tips/moveitemview_prefab", "MoveItemView"}
	self.view_layer = UiLayer.Pop
	self.duration = 0
	self.need_to_scale = false
	self.put_reason = -1
	self.item_data = {}
end

function TipsMoveItemView:__delete()
end

function TipsMoveItemView:ReleaseCallBack()
	self.move_obj = nil
	self.start_obj = nil
	self.target_obj = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:DelayNoticeNow()
end

function TipsMoveItemView:LoadCallBack()
	self.move_obj = self:FindObj("ItemCell")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.move_obj)
	self.item_cell:SetData(nil)
	self.move_obj:SetActive(false)
end

function TipsMoveItemView:DelayNoticeNow()
	if self.put_reason ~= -1 then
		--获取延迟奖励
		ItemData.Instance:HandleDelayNoticeNow(self.put_reason)
		self.put_reason = -1
	end
end

function TipsMoveItemView:CloseCallBack()
	self:DelayNoticeNow()
end

function TipsMoveItemView:OpenCallBack()
	local uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))

	if nil == self.start_obj or nil == self.target_obj then return end
	--转化开始坐标
	local start_rect = self.start_obj:GetComponent(typeof(UnityEngine.RectTransform))
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, start_rect.position)
	local _, start_local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	local start_pos = Vector3(start_local_pos_tbl.x, start_local_pos_tbl.y, 0)

	--转化结束坐标
	local target_rect = self.target_obj:GetComponent(typeof(UnityEngine.RectTransform))
	screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(uicamera, target_rect.position)
	local _, target_local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, uicamera, Vector2(0, 0))
	local target_pos = Vector3(target_local_pos_tbl.x, target_local_pos_tbl.y, 0)

	--先初始化位置
	self.move_obj.rect.localPosition = start_pos
	self.move_obj.rect.localScale = Vector3(1, 1, 1)
	self.move_obj:SetActive(true)

	self.item_cell:SetData(self.item_data)

	local tweener = nil
	if self.need_to_scale then
		tweener = self.move_obj.rect:DOScale(Vector3(0, 0, 0), self.duration + 0.1)
		tweener:SetEase(DG.Tweening.Ease.InCubic)
	end

	local close_view = function()
		if tweener then
			tweener:Kill()
		end

		self:DeleteMe()
	end
	self.move_obj:GetComponent(typeof(CurveMove)):MoveTo(target_pos, self.duration, close_view)
end

function TipsMoveItemView:SetItemData(item_data)
	self.item_data = item_data
end

function TipsMoveItemView:SetStartObj(start_obj)
	self.start_obj = start_obj
end

function TipsMoveItemView:SetTragetObj(target_obj)
	self.target_obj = target_obj
end

function TipsMoveItemView:SetDuration(duration)
	self.duration = duration
end

function TipsMoveItemView:SetNeedToScale(need_to_scale)
	self.need_to_scale = need_to_scale
end

function TipsMoveItemView:SetPutReason(put_reason)
	self.put_reason = put_reason
end