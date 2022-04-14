require('game.worthWelfare.RequireWorthWelfare')
WorthWelfareController = WorthWelfareController or class("WorthWelfareController",BaseController)

function WorthWelfareController:ctor()
	WorthWelfareController.Instance = self

	self.open_lv = Config.db_sysopen["1180@1"].level --超值福利开放等级

	self.lv_update_event_id = nil --等级刷新事件id

    self:AddEvents()
    
	self:RegisterAllProtocal()

	
end

function WorthWelfareController:dctor()

end

function WorthWelfareController:GetInstance()
	if not WorthWelfareController.Instance then
		WorthWelfareController.new()
	end
	return WorthWelfareController.Instance
end

function WorthWelfareController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	--self.pb_module_name = "pb_1142_illustration_pb"
	--self:RegisterProtocal(proto.ILLUSTRATION_INFO, self.HandleInfo)
end

function WorthWelfareController:AddEvents()
	local function callback()
		local panel = lua_panelMgr:GetPanelOrCreate(WorthWelfarePanel)
		panel:Open()
		panel:SetData()
	end
	GlobalEvent:AddListener(WorthWelfareEvent.OpenWorthWelfarePanel, callback)

	
end

-- overwrite
function WorthWelfareController:GameStart()
	local function step()
	
		-- if self.lv_update_event_id then
		-- 	GlobalEvent.RemoveListener(self.lv_update_event_id)
		-- 	self.lv_update_event_id = nil
		-- end
	
		-- local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
		-- if lv >= self.open_lv then
		-- 	--等级达到 显示图标
		-- 	GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "worthWelfare", true)
		-- 	GlobalEvent:Brocast(MainEvent.ChangeRedDot, "worthWelfare", true)
		-- else
		-- 	--否则监听等级刷新事件
		-- 	local function callback(  )
		-- 		local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
		-- 		if cur_lv >= self.open_lv then
		-- 			GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "worthWelfare", true)
		-- 			GlobalEvent:Brocast(MainEvent.ChangeRedDot, "worthWelfare", true)
		-- 			GlobalEvent.RemoveListener(self.lv_update_event_id)
		-- 			self.lv_update_event_id = nil
		-- 		end
		-- 	end
		-- 	self.lv_update_event_id = GlobalEvent:AddListener(EventName.ChangeLevel, callback)
			
		-- end

		--进入游戏时等级满足就显示icon和红点
		local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
		if lv >= self.open_lv then
			GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "worthWelfare", true)
			GlobalEvent:Brocast(MainEvent.ChangeRedDot, "worthWelfare", true)
		end

		if not self.lv_update_event_id then
			local function callback(  )
				local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
				if lv > self.open_lv then
					--升级时检查是否有可领取多倍投资
					local list = VipModel.GetInstance():GetInvesInfo().list
					local is_reddot = WorthWelfareModel.GetInstance():CheckInvestmentReddot(list)
					GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "worthWelfare", true)
					GlobalEvent:Brocast(MainEvent.ChangeRedDot, "worthWelfare", is_reddot)
				elseif lv == self.open_lv then
					--等级达到 开启超值福利 显示红点
					GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "worthWelfare", true)
					GlobalEvent:Brocast(MainEvent.ChangeRedDot, "worthWelfare", true)
				end
			end
			self.lv_update_event_id = GlobalEvent:AddListener(EventName.ChangeLevel, callback)
		end

    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)

end

