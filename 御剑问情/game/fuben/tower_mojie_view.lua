TowerMojieView = TowerMojieView or BaseClass(BaseView)

function TowerMojieView:__init(instance)
	self.full_screen = false								-- 是否是全屏界面
	self.ui_config = {"uis/views/fubenview_prefab","TowerMojieView"}
	self.play_audio = true
	self.scroller_is_load = false 							-- scroller是否完成初始化
	self.jump_index = -1 									-- 用于储存下一帧要跳转到的index
end

function TowerMojieView:__delete()
end

function TowerMojieView:LoadCallBack()
	self.jump_index = -1
	self:ListenEvent("OnClose", BindTool.Bind(self.OnClose, self))
	self.mojie_count = FuBenData.Instance:GetMoJieCount() 	--魔戒总数目
	self.cell_list = {}
	self:InitScroller()
end

function TowerMojieView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
	self.scroller = nil
end

function TowerMojieView:OpenCallBack()
	self.all_info = FuBenData.Instance:GetMoJieAllInfo() 	--所有魔戒信息
	self.scroller.scroller:ReloadData(0)
end

function TowerMojieView:ShowIndexCallBack(index)
	if index then
		if self.scroller_is_load then 						--scroller是否已经初始化，若未初始化调用JumpPage会报错
			--延迟一帧调用
			GlobalTimerQuest:AddDelayTimer(function ()
				self:JumpPage(index)
			end, 0)
		else
			self.jump_index = index 						--储存下一帧要跳转的index，待scroller初始化完成调用跳转
		end
	end
end

function TowerMojieView:JumpPage(page)
	local jump_index = page
	local scrollerOffset = 0
	local cellOffset = -1.36
	local useSpacing = false
	local scrollerTweenType = self.scroller.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.scroller.scroller:JumpToDataIndex(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end

--初始化滚动条
function TowerMojieView:InitScroller()
	self.scroller = self:FindObj("Scroller")
	local list_view_delegate = self.scroller.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

--滚动条数量
function TowerMojieView:GetNumberOfCells()
	return self.mojie_count
end

function TowerMojieView:OnClose()
	self:Close()
end

--滚动条刷新
function TowerMojieView:RefreshView(cell, data_index)
	self.scroller_is_load = true 			--标志scroller已经完成初始化
	if self.jump_index ~= -1 then 			--若有需要跳转的index
		local page = self.jump_index
		self.jump_index = -1
		self:ShowIndexCallBack(page)
	end
	local mojie_cell = self.cell_list[cell]
	if mojie_cell == nil then
		mojie_cell = TowerMojieInfo.New(cell.gameObject)
		self.cell_list[cell] = mojie_cell
	end
	local data = self.all_info[data_index + 1]
	data.lock = not FuBenData.Instance:GetIsActiveById(data.skill_id) --该魔戒是否锁定
	mojie_cell:SetData(data)
end


--------------------------------------- 动态生成info ----------------------------------------------
TowerMojieInfo = TowerMojieInfo or BaseClass(BaseRender)

function TowerMojieInfo:__init()
	self.skill_des = self:FindVariable("skill_des")
	self.mojie_icon = self:FindVariable("mojie_icon")
	self.mojie_lock = self:FindVariable("mojie_lock")
	self.mojie_name = self:FindVariable("mojie_name")
	self.mojie_get_layer = self:FindVariable("mojie_get_layer")
end

function TowerMojieInfo:__delete()
end

function TowerMojieInfo:SetData(data)
	if not data then return end
	self.data = data
	self:SetSkillDes()
	self:SetIcon()
	self:SetName()
	self.mojie_lock:SetValue(data.lock) 	--设置锁定状态
	self.mojie_get_layer:SetValue(data.pata_layer)
end
-- 设置技能描述
function TowerMojieInfo:SetSkillDes()
	local index = self.data.skill_id
	local params = self.data.skill_param
	local skill_des = string.format(Language.FubenTower.TowerMoJieSkillDes[self.data.skill_id + 1], params[1], params[2], params[3], params[4])
	self.skill_des:SetValue(skill_des)
end
-- 设置魔戒Icon
function TowerMojieInfo:SetIcon()
   local bundle, asset = ResPath.GetTowerMojieIcon(self.data.skill_id + 1)
   self.mojie_icon:SetAsset(bundle, asset)
end
-- 设置魔戒名称
function TowerMojieInfo:SetName()
   local bundle, asset = ResPath.GetTowerMojieName(self.data.skill_id + 1)
   self.mojie_name:SetAsset(bundle, asset)
end