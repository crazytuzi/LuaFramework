RollingBarrageView = RollingBarrageView or BaseClass(BaseView)

local DELAY_TIME_LIST  = 0.5  -- 每隔1秒输出一句
local MAX_TEXT_NUM = 50		-- 语句最大记录值
local SPACE_OFFSET = 5
local TEXT_SPEED = 160		-- 平均速度,速度越大,弹幕移动越快
local TEXT_SPEED_LIST = {[1] = 160, [2] = 200, [3] = 180}

function RollingBarrageView:__init()
	self.ui_config = {"uis/views/rollingbarrageview","RollingBarrageView"}
	self.view_layer = UiLayer.PopTop

	self.load_text_obj_count = 0
	self.obj_list = {}
	self.is_loading = false
	self.text = ""
end

function RollingBarrageView:__delete()

end

function RollingBarrageView:LoadCallBack()
	-- 底部滚动条
	self.list_view_1 = self:FindObj("ListView1")

  	-- 中间滚动条
  	self.list_view_2 = self:FindObj("ListView2")

  	-- 顶部滚动条
  	self.list_view_3 = self:FindObj("ListView3")
end

function RollingBarrageView:SetText(text)
	self.text = text
	self:Flush()
end

function RollingBarrageView:OpenCallBack()
	self.load_text_obj_count = 0
	self.obj_list = {}
	self.is_loading = false

	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	self.root_width = rect.rect.width
end

function RollingBarrageView:OnFlush()
	self:LoadTextPrefab()
end

function RollingBarrageView:LoadTextPrefab()
	if self.is_loading then return end
	self.is_loading = true

	local root_index = self.load_text_obj_count % 3 + 1

	if root_index == 3 and nil ~= self.load_time_count then
		GlobalTimerQuest:CancelQuest(self.load_time_count)
		self.load_time_count = nil
	end

	UtilU3d.PrefabLoad("uis/views/rollingbarrageview_prefab", "BarrageText", function(obj)
		if nil == obj then
			return
		end
		local is_can_load_next = false
		local temp_root_idnex = root_index

		self.load_text_obj_count = self.load_text_obj_count + 1

		obj.transform:SetParent(self["list_view_"..root_index].transform, false)

		local rect_tran = obj:GetComponent(typeof(UnityEngine.RectTransform))
		local text = obj:GetComponent(typeof(UnityEngine.UI.Text))

		text.text = self.text

		self.obj_list[obj] = obj

		-- 把prefab坐标设置到最右边屏幕外
		rect_tran:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, self.root_width, text.preferredWidth)

		-- 需要移动的总路程
		local total_distance = text.preferredWidth + SPACE_OFFSET + self.root_width
		-- 移动prefab
		local tween = rect_tran:DOAnchorPosX(0 - text.preferredWidth - SPACE_OFFSET, total_distance / TEXT_SPEED_LIST[temp_root_idnex])
		-- 随机间隔
		local random_space = math.random(30, (self.root_width - text.preferredWidth))

		tween:SetEase(DG.Tweening.Ease.Linear)
		tween:OnUpdate(function ()
			if not self:IsOpen() then
				DG.Tweening.DOTween.Kill(tween)
				return
			end
			if self.root_width - rect_tran.anchoredPosition.x > (text.preferredWidth + random_space)
				and not is_can_load_next then
				is_can_load_next = true
			end
		end)
		tween:OnComplete(function ()
			GameObject.Destroy(obj)
			self.obj_list[obj] = nil
		end)
		self.is_loading = false
	end)
end

function RollingBarrageView:RemoveCountDownAndDestroyObj()
	for k, v in pairs(self.obj_list) do
		GameObject.Destroy(v)
	end
	self.obj_list = {}

	if nil ~= self.load_time_count then
		GlobalTimerQuest:CancelQuest(self.load_time_count)
		self.load_time_count = nil
	end
end

function RollingBarrageView:CloseCallBack()
	self:RemoveCountDownAndDestroyObj()
end

function RollingBarrageView:ReleaseCallBack()
	self:RemoveCountDownAndDestroyObj()

	-- 释放变量
	self.list_view_1 = nil
	self.list_view_2 = nil
	self.list_view_3 = nil
end