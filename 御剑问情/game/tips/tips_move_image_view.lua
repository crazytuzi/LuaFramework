TipsMoveImageView = TipsMoveImageView or BaseClass(BaseView)

TipsMoveImageView.MoveObjType = {
	Image = 1,
	Item = 2,
}
function TipsMoveImageView:__init()
	self.ui_config = {"uis/views/tips/moveimageview_prefab", "MoveImageView"}
	self.view_layer = UiLayer.Pop
	self.duration = 0
	self.need_to_scale = false
	self.put_reason = -1
	self.item_data = {}
	self.type = TipsMoveImageView.MoveObjType.Image
end

function TipsMoveImageView:__delete()
end

function TipsMoveImageView:ReleaseCallBack()
	self.move_obj = nil
	self.start_obj = nil
	self.target_obj = nil
	self.image_asset = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:DelayNoticeNow()
end

function TipsMoveImageView:LoadCallBack()
	self.move_obj = self:FindObj("MoveObj")
	self.image_asset = self:FindVariable("ImageAsset")
	if self.type == TipsMoveImageView.MoveObjType.Image then
		self.image_asset:SetAsset(self.asset_path, self.asset_name)
	elseif self.type == TipsMoveImageView.MoveObjType.Item then
		self.item_cell = ItemCell.New()
		self.item_cell:SetInstanceParent(self.move_obj)
		self.item_cell:SetData(nil)
	end
	self.move_obj:SetActive(false)
end

function TipsMoveImageView:DelayNoticeNow()
	if self.put_reason ~= -1 then
		--获取延迟奖励
		ItemData.Instance:HandleDelayNoticeNow(self.put_reason)
		self.put_reason = -1
	end
end

function TipsMoveImageView:CloseCallBack()
	self:DelayNoticeNow()
end

function TipsMoveImageView:OpenCallBack()
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

	if self.type == TipsMoveImageView.MoveObjType.Item then
		self.item_cell:SetData(self.item_data)
	end

	local close_view = function()
		if tweener1 then
			tweener1:Kill()
		end
		if tweener2 then
			tweener2:Kill()
		end
		if tweener3 then
			tweener3:Kill()
		end
		self:DeleteMe()
	end

	local tweener1 = nil
	if self.need_to_scale then
		tweener1 = self.move_obj.rect:DOScale(Vector3(1.4, 1.4, 1.4), 0.7)
		tweener1:SetEase(DG.Tweening.Ease.InBounce)
	end
	tweener1:OnComplete(
		function() 
			local tweener2 = nil
			if self.need_to_scale then
				tweener2 = self.move_obj.rect:DOScale(Vector3(0, 0, 0), self.duration + 0.1)
				tweener2:SetEase(DG.Tweening.Ease.InExpo)
			end

			local tweener3 = self.move_obj.rect:DOLocalMove(target_pos, self.duration + 0.1)
			tweener3:SetEase(DG.Tweening.Ease.InOutSine )
			tweener3:OnComplete(close_view)
		end
	)
end

function TipsMoveImageView:SetItemData(item_data)
	self.type = TipsMoveImageView.MoveObjType.Item
	self.item_data = item_data
end

function TipsMoveImageView:SetStartObj(start_obj)
	self.start_obj = start_obj
end

function TipsMoveImageView:SetTragetObj(target_obj)
	self.target_obj = target_obj
end

function TipsMoveImageView:SetDuration(duration)
	self.duration = duration
end

function TipsMoveImageView:SetNeedToScale(need_to_scale)
	self.need_to_scale = need_to_scale
end

function TipsMoveImageView:SetPutReason(put_reason)
	self.put_reason = put_reason
end

function TipsMoveImageView:SetImageAsset(path, name)
	self.type = TipsMoveImageView.MoveObjType.Image
	self.asset_path = path
	self.asset_name = name
end