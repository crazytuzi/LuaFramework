--- Created by Admin.
--- DateTime: 2019/12/18 19:44

require('game.childAct.RequireChildAct')
ChildActCtrl = ChildActCtrl or class("ChildActCtrl",BaseController)
local ChildActCtrl = ChildActCtrl

function ChildActCtrl:ctor()
    ChildActCtrl.Instance = self
    self.model = ChildActModel.GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocal()
end

function ChildActCtrl:dctor()
end

function ChildActCtrl:GetInstance()
    if not ChildActCtrl.Instance then
        ChildActCtrl.new()
    end
    return ChildActCtrl.Instance
end

function ChildActCtrl:RegisterAllProtocal(  )
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function ChildActCtrl:AddEvents()
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ChildActMainPanel):Open(1)
    end
    GlobalEvent:AddListener(ChildActEvent.OpenChildRankPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ChildActMainPanel):Open(2)
    end
    GlobalEvent:AddListener(ChildActEvent.OpenChildBuyPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ChildActMainPanel):Open(3)
    end
    GlobalEvent:AddListener(ChildActEvent.OpenChildRechargePanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ChildActMainPanel):Open(4)
    end
    GlobalEvent:AddListener(ChildActEvent.OpenChildTargetPanel, call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ChildActMainPanel):Open(5)
    end
    GlobalEvent:AddListener(ChildActEvent.OpenChildBoxPanel, call_back)
	local function call_back()
		lua_panelMgr:GetPanelOrCreate(ChildActMainPanel):Open(6)
	end
	GlobalEvent:AddListener(ChildActEvent.OpenChildShopPanel, call_back)

    local function callback()
        local id1 = OperateModel:GetInstance():GetActIdByType(772)
        local id2 = OperateModel:GetInstance():GetActIdByType(773)
        local id3 = OperateModel:GetInstance():GetActIdByType(776)
        if id1 ~= 0 then
            OperateController:GetInstance():Request1700006(id1)
        end
        if id2 ~= 0 then
            OperateController:GetInstance():Request1700006(id2)
        end
        if id3 ~= 0 then
            OperateController:GetInstance():Request1700006(id3)
        end
    end
    GlobalEvent:AddListener(EventName.CrossDayAfter, callback) -- 跨天

    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.HandleYYInfo))
	local function call_back(id)
		if id == 13141 then
			self:ExcRed()
            self:SetMainRed()
		end
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end

-- overwrite
function ChildActCtrl:GameStart()

end

function ChildActCtrl:HandleYYInfo(data)
    if self.model:IsSelcet(data.id) then
        self.model:SetActIllInfo(data)
        self:CheckIllRD(data)
        GlobalEvent:Brocast(NationEvent.UpdateRewardInfo)
    end

    if self.model:IsSelcetTarget(data.id) then
        self:CheckIllRD(data)
    end
end

function ChildActCtrl:CheckIllRD(info)
    local is_show = false
    self.model.petRedPoints[info.id] = false
	
	if OperateModel:GetInstance():GetActIdByType(777) == info.id then
        self:ExcRed()
	else
		for i, v in pairs(info.tasks) do
			if v.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
				is_show = true
				self.model.petRedPoints[info.id] = true
			end
		end
	end

	self:SetMainRed()
end
function ChildActCtrl:SetMainRed()
	for i, v in pairs(self.model.petRedPoints) do
		if v then
			GlobalEvent:Brocast(MainEvent.ChangeRedDot, "soncele", v)
			return 
		end
	end
	
	GlobalEvent:Brocast(MainEvent.ChangeRedDot, "soncele", false)
end

function ChildActCtrl:ExcRed()
	local id = 177700
	local num = BagModel.GetInstance():GetItemNumByItemID(13141)
	local list = OperateModel.GetInstance():GetRewardConfig(id)
	local act_info = OperateModel:GetInstance():GetActInfo(id)
	self.model.petRedPoints[id] = false
	if not act_info then
		return
	end
	local info_list = act_info.tasks
	local is_show = false
	for i = 1, #list do
		local data = list[i]
		local info2 = self.model:GetExchangeTaskInfo(info_list, data.id)
		if info2 then
			local cur_ex_count = info2.count
			local limit = String2Table(data.limit)[2]
			local need_num = String2Table(data.cost)[1][2]
			--有剩余兑换数量
			if cur_ex_count < limit then
				if num >= need_num then
					is_show = true
					self.model.petRedPoints[id] = true
					break
				end
			end
		end
	end
	GlobalEvent:Brocast(ChildActEvent.UpdateMainRed)
end

