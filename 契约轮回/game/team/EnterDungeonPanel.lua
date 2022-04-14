EnterDungeonPanel = EnterDungeonPanel or class("EnterDungeonPanel",WindowPanel)
local EnterDungeonPanel = EnterDungeonPanel

function EnterDungeonPanel:ctor()
	self.abName = "team"
	self.assetName = "EnterDungeonPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.item_list = {}
	self.model = TeamModel:GetInstance()
	self.global_events = {}
	self.is_agree = false
end

function EnterDungeonPanel:dctor()
end

function EnterDungeonPanel:Open( )
	EnterDungeonPanel.super.Open(self)
end

function EnterDungeonPanel:LoadCallBack()
	self.nodes = {
		"enter_text","Slider/timeTxt","Slider","role_list/Viewport/Content","enter_quit_btn","wait_btn",
		"role_list/Viewport/Content/EnterDungeonItem","countdown","countdown/countdowntext",
	}
	self:GetChildren(self.nodes)
	self.enter_text = GetText(self.enter_text)
	self.EnterDungeonItem_gameobject = self.EnterDungeonItem.gameObject
	self.Slider = self.Slider:GetComponent("Slider")
	self:SetPanelSize(509.4, 356)
	self:AddEvent()
	self:SetTileTextImage("team_image", "team_enter_dunge_title")
end

function EnterDungeonPanel:AddEvent()
	local function call_back(target,x,y)
		TeamController:GetInstance():DungeEnterAsk(self.dunge_id, 1)
		--self.countdownitem:StopSchedule()
	end
	AddClickEvent(self.enter_quit_btn.gameObject,call_back)

	local function call_back(target,x,y)
		TeamController:GetInstance():DungeEnterAsk(self.dunge_id, 0)
		self:Close()
	end
	AddClickEvent(self.wait_btn.gameObject,call_back)

	local function call_back()
		self:Close()
	end
	self.event_id = self.model:AddListener(TeamEvent.EnterDungeDisAgree, call_back)

	local function call_back()
		self:CheckEnterDunge()
	end
	self.event_id2 = self.model:AddListener(TeamEvent.EnterDungeAsk, call_back)

	--[[local function call_back()
		self:Close()
	end
	self.event_id3 = self.model:AddListener(TeamEvent.EnterDunge, call_back)--]]
	local function call_back()
		self:Close()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)

	local function call_back(index, toggle_id)
        if not self.show_sidebar then
            return
        end
        self:MenuCallBack(index, toggle_id, true)
    end
    local function call_back2()
    	TeamController:GetInstance():DungeEnterAsk(self.dunge_id, 0)
    	self:Close()
    end
    self.bg_win:SetCallBack(call_back2, call_back)
end

function EnterDungeonPanel:OpenCallBack()
	self:UpdateView()
end

function EnterDungeonPanel:UpdateView( )
	local team_info = self.model:GetTeamInfo()
	if not self.countdownitem and self.dunge_id and team_info then
		self.enter_text.text = "<color=#AA5D25>Your team is entering</color><color=#7025aa>" .. Config.db_dunge[self.dunge_id].name .. "</color>"
		local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
		if not self.countdownitem then
			self:CountDown()
		end
	    SetVisible(self.EnterDungeonItem_gameobject, false) 
	    local members = team_info.members
	    for i=1, #members do
	    	local member = members[i]
	    	local item = EnterDungeonItem(self.EnterDungeonItem_gameobject, self.Content)
	    	item:SetData(member)
	    	self.item_list[i] = item
	    end
	    self:CheckEnterDunge()
	end
end

function EnterDungeonPanel:CountDown()
	local param = {
	    isShowMin = true,
	    duration = 0.2,
	    formatTime="%d"
	}
	self.countdownitem = CountDownText(self.countdown , param)
	self.countdownitem:StartSechudle(os.time()+30, handler(self , self.Finish) , handler(self , self.CDUpdate))
end

function EnterDungeonPanel:CheckEnterDunge()
	if self.model:IsMembersAgree() and self.model:IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
		local function ok_fun()
			TeamController:GetInstance():DungeEnter(self.dunge_id)
		end
		self.schedule_id = GlobalSchedule:StartOnce(ok_fun, 1)
	end
end

function EnterDungeonPanel:Finish()
	if not self.model:IsMembersAgree() then
		Notify.ShowText("One or more members declined to enter")
		self:Close()
	end
end

function EnterDungeonPanel:CDUpdate(timeTab)
	self.Slider.value = timeTab.sec/30
	if timeTab.sec == 5 and not self.is_agree then
		self.is_agree = true
		if not self.model:IsAgree(RoleInfoModel:GetInstance():GetMainRoleId()) then
			TeamController:GetInstance():DungeEnterAsk(self.dunge_id, 1)
		end
	end
end


function EnterDungeonPanel:CloseCallBack(  )
	if self.countdownitem then
		self.countdownitem:destroy()
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
	end
	if self.schedule_id2 then
		GlobalSchedule:Stop(self.schedule_id2)
	end
	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end
	if self.event_id2 then
		self.model:RemoveListener(self.event_id2)
		self.event_id2 = nil
	end
	--[[if self.event_id3 then
		self.model:RemoveListener(self.event_id3)
		self.event_id3 = nil
	end--]]
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = nil
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
end
function EnterDungeonPanel:SwitchCallBack(index)
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

--dunge_id:副本id
--role_ids:已同意队员id
function EnterDungeonPanel:SetData(dunge_id, role_ids)
	self.dunge_id = dunge_id
	self.role_ids = role_ids
	if self.is_loaded then
		self:UpdateView()
	end
end