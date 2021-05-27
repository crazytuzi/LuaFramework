--活动每日活动页面
ActivityAchievePage = ActivityAchievePage or BaseClass()


function ActivityAchievePage:__init()
	self.view = nil

	self.current_btn_index = 1
	self.current_type = 1
	self.last_selec_min_num = 0
	self.tabbar = nil 
	self.btn_list = nil 
end	

function ActivityAchievePage:__delete()

	self:RemoveEvent()

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if self.achieve_list then
		self.achieve_list:DeleteMe()
		self.achieve_list = nil
	end

	if self.btn_list then
		self.btn_list:DeleteMe()
		self.btn_list = nil 
	end

	self.view = nil
	ClientCommonButtonDic[CommonButtonType.ACHIEVE_AWARD_LIST_VIEW] = nil
	
end	

--初始化页面接口
function ActivityAchievePage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateBtn()
	self:CreateAchiveList()
	self:InitEvent()
end	

function ActivityAchievePage:CreateBtn()
	if nil == self.btn_list then
		local ph = self.view.ph_list.ph_achievebtn_list
		self.btn_list = ListView.New()
		self.btn_list:Create(ph.x, ph.y, ph.w, ph.h, nil, BtnRender, nil, nil, self.view.ph_list.ph_btn_item)
		self.btn_list:GetView():setAnchorPoint(0, 0)
		self.btn_list:SetItemsInterval(5)
		self.btn_list:SetMargin(2)
		self.btn_list:SetJumpDirection(ListView.Top)
		self.btn_list:SetDelayCreateCount(10)
		self.btn_list:SetSelectCallBack(BindTool.Bind1(self.SelectCallBack, self))
		self.view.node_t_list.layout_achivement.node:addChild(self.btn_list:GetView(), 100)

		local min_t = AchieveData.Instance:GetMinIndexT()
		if not min_t then return end
		local data = {}
		for k, v in ipairs(min_t) do
			if k < 8 then
				data[k] = {name = Language.Achieve.Name[k], type = k, min_num = v}
			end
		end

		local function sort_func()
			return function(a, b)
						if a.min_num ~= b.min_num then
							return a.min_num > b.min_num
						else
							return a.type < b.type
						end
					end
		end
		table.sort(data, sort_func())
		self.btn_list:SetDataList(data)
	end	
end

function ActivityAchievePage:SelectCallBack(item, btn_index)
	if not item or not item:GetData() then return end
	local data = item:GetData()
	-- print("index=========", btn_index)
	-- PrintTable(data)
	self.current_btn_index = btn_index
	self.current_type = data.type
	self:FlushAchieveList(data.type)
	self.achieve_list:SelectIndex(1)
	local min_t = AchieveData.Instance:GetMinIndexT()
	if not min_t then return end
	self.last_selec_min_num = min_t[self.current_type]	
end

--成就
function ActivityAchievePage:CreateAchiveList()
	if nil == self.achieve_list then
		local ph = self.view.ph_list.ph_achieve_list
		self.achieve_list = ListView.New()
		self.achieve_list:Create(ph.x, ph.y, ph.w, ph.h, nil, AchieveRender, nil, nil, self.view.ph_list.ph_achieve_item)
		self.achieve_list:GetView():setAnchorPoint(0, 0)
		self.achieve_list:SetItemsInterval(5)
		self.achieve_list:SetJumpDirection(ListView.Top)
		self.achieve_list:SetDelayCreateCount(10)
		self.achieve_list:SetMargin(3)
		self.view.node_t_list.layout_achivement.node:addChild(self.achieve_list:GetView(), 100)
		ClientCommonButtonDic[CommonButtonType.ACHIEVE_AWARD_LIST_VIEW] = self.achieve_list
	end
end

--初始化事件
function ActivityAchievePage:InitEvent()
	
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化

	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

	self.remind_handler = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindUpAchieveChange, self))
	self.achieve_data_evt = GlobalEventSystem:Bind(AchievementEventType.ACHIEVE_DATA_CHANGE, BindTool.Bind(self.UpdateData, self))

	self:RemindUpAchieveChange(RemindName.AchieveAchievement,0)
end

--移除事件
function ActivityAchievePage:RemoveEvent()
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil
	end

	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil
	end	

	if self.remind_handler then
		GlobalEventSystem:UnBind(self.remind_handler)
		self.remind_handler = nil
	end	

	if self.achieve_data_evt then
		GlobalEventSystem:UnBind(self.achieve_data_evt)
		self.achieve_data_evt = nil
	end	
end

--更新视图界面
function ActivityAchievePage:UpdateData(data)
	local min_t = AchieveData.Instance:GetMinIndexT()
	if not min_t then self.btn_list:SelectIndex(self.current_btn_index) return end
	if self.last_selec_min_num > 0 and min_t[self.current_type] <= 0 then
		local data = {}
		for k, v in ipairs(min_t) do
			if k < 8 then
				data[k] = {name = Language.Achieve.Name[k], type = k, min_num = v}
			end
		end

		local function sort_func()
			return function(a, b)
						if a.min_num ~= b.min_num then
							return a.min_num > b.min_num
						else
							return a.type < b.type
						end
					end
		end
		table.sort(data, sort_func())
		self.btn_list:SetDataList(data)
		self.btn_list:SelectIndex(1)
	else	
		self.btn_list:SelectIndex(self.current_btn_index)
	end

	self:RoleDataChangeCallback()
end	


function ActivityAchievePage:RemindUpAchieveChange(remind_name, num)
	if remind_name == RemindName.AchieveAchievement then
		for i = 1, 7 do
			self:UpdateAchieveRemind(i)
		end
		self:FlushAchieveList(self.current_type)
	end
end

function ActivityAchievePage:UpdateAchieveRemind(index)
	if self.btn_list and self.btn_list:GetItemAt(index) then
		self.btn_list:GetItemAt(index):SetRemindFlag()
	end
end


--监听装备变化
function ActivityAchievePage:EquipmentDataChangeCallback(bool, change_item_id, change_item_index, change_reason)
	
end

--人物属性变化
function ActivityAchievePage:RoleDataChangeCallback(key, value)
	local achievement_points = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE) or 0
	self.view.node_t_list.txt_achieve_point.node:setString(achievement_points)
end	

function ActivityAchievePage:FlushAchieveList(index)
	local data = AchieveData.Instance:GetAchieveListData(index)
	self.achieve_list:SetDataList(data)
end