DungeMergePanel = DungeMergePanel or class("DungeMergePanel",WindowPanel)
local DungeMergePanel = DungeMergePanel

function DungeMergePanel:ctor()
	self.abName = "dungeon"
	self.assetName = "DungeMergePanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.set_merge = false
	self.global_events = {}
end

function DungeMergePanel:dctor()
	self.ok_func = nil
	self.cancel_func = nil
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = nil
end

function DungeMergePanel:Open(stype, ok_func, cancel_func, count, add_func)
	DungeMergePanel.super.Open(self)
	self.ok_func = ok_func
	self.cancel_func = cancel_func
	self.add_func = add_func
	self.max_count = count
	self.merge_count = count
	self.stype = stype
end

function DungeMergePanel:LoadCallBack()
	self.nodes = {
		"Image/count","Image2/merge","debtn","addbtn","money","canclebtn","okbtn",
		"Image/addcountbtn",
	}
	self:GetChildren(self.nodes)

	self.count = GetText(self.count)
	self.merge = GetText(self.merge)
	self.money = GetText(self.money)
	self:SetPanelSize(505.8, 332.4)
	self:SetTileTextImage("dungeon_image", "merge_title")
	self:AddEvent()
end

function DungeMergePanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.canclebtn.gameObject,call_back)

	local function call_back(target,x,y)
		local cost = String2Table(Config.db_game["dunge_merge_cost"].val)[1][1]
		local need = cost[2] * (self.merge_count-1)
		local vo = RoleInfoModel:GetInstance():CheckGold(need, Constant.GoldType.BGold)
		if not vo then
			return
		end
		self.set_merge = true
		if self.ok_func then
			self.ok_func(self.merge_count)
		end
		self:Close()
	end
	AddButtonEvent(self.okbtn.gameObject,call_back)

	local function call_back(target,x,y)
		if self.merge_count - 1 <= 1 then
			Notify.ShowText("At least combine twice")
			return
		end
		self.merge_count = self.merge_count -1
		self:UpdateMoney()
	end
	AddButtonEvent(self.debtn.gameObject,call_back)

	local function call_back(target,x,y)
		if self.merge_count + 1 > self.max_count then
			Notify.ShowText("Max combination reached")
			return
		end
		self.merge_count = self.merge_count + 1
		self:UpdateMoney()
	end
	AddButtonEvent(self.addbtn.gameObject,call_back)

	local function call_back(target,x,y)
		self.add_func()
	end
	AddClickEvent(self.addcountbtn.gameObject,call_back)

	local function call_back(stype, data)
		if stype == self.stype then
			self.max_count = data.rest_times
			self.merge_count = data.rest_times
			self:UpdateView()
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonTime, call_back)
end

function DungeMergePanel:OpenCallBack()
	self:UpdateView()
end

function DungeMergePanel:UpdateView( )
	self.count.text = self.max_count
	self.merge.text = self.merge_count
	self:UpdateMoney()
	if self.add_func then
		SetVisible(self.addcountbtn, true)
	else
		SetVisible(self.addcountbtn, false)
	end
end

function DungeMergePanel:UpdateMoney()
	self.merge.text = self.merge_count
	local cost = String2Table(Config.db_game["dunge_merge_cost"].val)
	local need_money = cost[1][1][2]
	need_money = need_money * (self.merge_count-1)
	self.money.text = need_money
end

function DungeMergePanel:CloseCallBack(  )
	if not self.set_merge then
		if self.cancel_func then
			self.cancel_func()
		end
	end
end
function DungeMergePanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end