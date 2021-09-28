RollingBarrageView = RollingBarrageView or BaseClass(BaseView)

local DELAY_TIME_LIST  = 0.5  -- 每隔1秒输出一句
local MAX_TEXT_NUM = 50		-- 语句最大记录值
local SPACE_OFFSET = 5
local TEXT_SPEED = 160		-- 平均速度,速度越大,弹幕移动越快
local TEXT_SPEED_LIST = {[1] = 160, [2] = 200, [3] = 180}

function RollingBarrageView:__init()
	self.ui_config = {"uis/views/rollingbarrageview_prefab","RollingBarrageView"}
	self.view_layer = UiLayer.PopTop

	self.load_text_obj_count = 0
	self.obj_list = {}
	self.new_obj_list = {}
	self.is_have_obj = {}
	self.curr_index = 0
	self.is_loading = false
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

function RollingBarrageView:OpenCallBack()
	self.load_text_obj_count = 0
	self.obj_list = {}
	self.new_obj_list = {}
	self.is_loading = false

	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	self.root_width = rect.rect.width

	if self.text_tab then
		local length = #self.text_tab > 10 and 10 or #self.text_tab
		for i = 1, length do
			self:NewLoadTextPrefab(i)
		end
	else
		self:SetLoadTimeCount()
	end
end

function RollingBarrageView:SetLoadTimeCount()
	self:RemoveTimerQuest()
	self.load_time_count = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LoadTextPrefab, self), DELAY_TIME_LIST)
end

function RollingBarrageView:RemoveTimerQuest()
	if self.load_time_count then
		GlobalTimerQuest:CancelQuest(self.load_time_count)
		self.load_time_count = nil
	end
end

function RollingBarrageView:FlushTextTab()
	self.text_tab = RollingBarrageData.Instance:GetTextData()
	local length = #self.text_tab > 10 and 10 or #self.text_tab
	if self:IsOpen() then
		for i = 1, length do
			self:NewLoadTextPrefab(i)
		end
	end
end

function RollingBarrageView:LoadTextPrefab(root_index)
	if self.is_loading then return end
	self.is_loading = true

	local root_index = root_index or self.load_text_obj_count % 3 + 1

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

		local des_list = RollingBarrageData.Instance:GetDesList()
		local des_index = self.load_text_obj_count - MAX_TEXT_NUM > 0 and (self.load_text_obj_count - MAX_TEXT_NUM * math.floor(self.load_text_obj_count / MAX_TEXT_NUM)) or self.load_text_obj_count
		text.text = des_list[des_index]

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
				self:LoadTextPrefab(temp_root_idnex)
			end
		end)
		tween:OnComplete(function ()
			GameObject.Destroy(obj)
			self.obj_list[obj] = nil
		end)
		self.is_loading = false
	end)
end
--国战的接口
function RollingBarrageView:NewLoadTextPrefab(text_index)
	if self.is_loading or self.is_have_obj[text_index] then 
		return
	end

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

		self.curr_index = (self.curr_index >= RollingTextLength or (self.curr_index + 1) > #self.text_tab) and 1 or self.curr_index + 1
		text.text = self.text_tab[self.curr_index]

		local new_text_tab = RollingBarrageData.Instance:GetNewTextData()
		if #new_text_tab > 0 then
			self.text_tab[#self.text_tab] = self.text_tab[self.curr_index]
			self.text_tab[self.curr_index] = new_text_tab[1]
			text.text = new_text_tab[1]
			table.remove(new_text_tab, 1)
		end

		self.new_obj_list[obj] = obj
		self.is_have_obj[text_index] = true

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
			self.new_obj_list[obj] = nil
			self.is_have_obj[text_index] = false
			self:NewLoadTextPrefab(text_index)
		end)
		self.is_loading = false
	end)
end

function RollingBarrageView:RemoveCountDownAndDestroyObj()
	for k, v in pairs(self.obj_list) do
		GameObject.Destroy(v)
	end
	self.obj_list = {}

	for k, v in pairs(self.new_obj_list) do
		GameObject.Destroy(v)
	end
	self.new_obj_list = {}

	self:RemoveTimerQuest()
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

	self:RemoveTimerQuest()
end