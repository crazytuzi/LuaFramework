---
--- Created by  Administrator
--- DateTime: 2019/10/31 14:25
---
require('game.limittower.RequireLimitTower')
LimitTowerController = LimitTowerController or class("LimitTowerController", BaseController)
local LimitTowerController = LimitTowerController

function LimitTowerController:ctor()
    LimitTowerController.Instance = self
	self.is_first = true
    self.events = {}
	self.model = LimitTowerModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocol()
	
end

function LimitTowerController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	if self.power_change_bind_id then
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.power_change_bind_id)
		self.power_change_bind_id = nil
	end
	self.is_first = true
end

function LimitTowerController:GetInstance()
    if not LimitTowerController.Instance then
        LimitTowerController.new()
    end
    return LimitTowerController.Instance
end

function LimitTowerController:AddEvents()

    local function call_back() --打开界面
        lua_panelMgr:GetPanelOrCreate(LimitTowerPanel):Open()
    end
    GlobalEvent:AddListener(LimitTowerEvent.OpenLimitTowerPanel,call_back)
	
	local function call_back(stype)
		if stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER then
			self:UpdateMainRed()
		end
	end
	GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData,call_back)
	
	local function call_back()
		if not self.is_first then
			self:UpdateMainRed()
		end
	end
	self.power_change_bind_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("power", call_back)
end

function LimitTowerController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
end

-- overwrite
function LimitTowerController:GameStart()
	local function step()
	   DungeonCtrl:GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER)
		GlobalSchedule.StopFun(self.time_id)	
	end

	self.time_id = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.VLow)
end


function LimitTowerController:UpdateMainRed()
	local tab = DungeonModel:GetInstance().dungeon_info_list
	if table.isempty(tab)  then
		return 
	end
	
	if tab[enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER] then
		local info =  tab[enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER].info
		if info then
			self.model.curFloor = info.cur_floor
			local cfg = Config.db_yunying_dunge_limit_tower
			for i = 1, #cfg do
				local actId = cfg[i].act_id
				if OperateModel:GetInstance():IsActOpenByTime(actId) then
					self.model.actID = actId
					self.is_first = false
					break
				end	
			end
			self.model:UpdateMainRed()
		end	
	end
end
