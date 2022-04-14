---
--- Created by  Administrator
--- DateTime: 2019/8/13 11:19
---
WarriorController = WarriorController or class("WarriorController", BaseController)
local WarriorController = WarriorController
require('game.warrior.RequireWarrior')
function WarriorController:ctor()
    WarriorController.Instance = self
	self.model = WarriorModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function WarriorController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function WarriorController:GetInstance()
    if not WarriorController.Instance then
        WarriorController.new()
    end
    return WarriorController.Instance
end

function WarriorController:AddEvents()


	local function call_back()
		lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 3);
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(WarriorEvent.OpenWarriorPanel, call_back);
	self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

function WarriorController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1606_warrior_pb"
	self:RegisterProtocal(proto.WARRIOR_INFO, self.HandleWarriorInfo);
	self:RegisterProtocal(proto.WARRIOR_UPDATE, self.HandleUpdateInfo);
	self:RegisterProtocal(proto.WARRIOR_END, self.HandleEndInfo);
	self:RegisterProtocal(proto.WARRIOR_RANK, self.HandleRankInfo);
	self:RegisterProtocal(proto.WARRIOR_CREEP, self.HandleCreep);


	
end

function WarriorController:HandleSceneChange(sceneID)
	local config = Config.db_scene[sceneID]
	if not config then
		print2("不存在场景配置" .. tostring(sceneID));
		return
	end
	
	if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_WARRIOR then
		--巅峰1v1
		--lua_panelMgr:GetPanelOrCreate(WarriorDungeonPanel):Open()
		self.isWarriorDungeon = true
		if self.model.meleeCenter then
			self.model.meleeCenter:destroy();
		end
		self.model.meleeCenter = WarriorDungeonPanel(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Bottom));
		--SetAlignType(self.meleeCenter, bit.bor(AlignType.Left, AlignType.Null))
	else
		if self.isWarriorDungeon then
			self.isWarriorDungeon = nil
			if self.model.meleeCenter then
				self.model.meleeCenter:destroy();
			end
			self.model.meleeCenter = nil;
		end
	end
end

-- overwrite
function WarriorController:GameStart()

end


--请求信息
function WarriorController:RequesWarriorInfo()
	local pb = self:GetPbObject("m_warrior_info_tos");
	
	self:WriteMsg(proto.WARRIOR_INFO, pb);
end

function WarriorController:HandleWarriorInfo()
	local data = self:ReadMsg("m_warrior_info_toc");
	
	self.model:Brocast(WarriorEvent.WarriorInfo,data)
end

--更新自己信息
function WarriorController:HandleUpdateInfo()
	local data = self:ReadMsg("m_warrior_update_toc");
	self.model.floor = data.floor
	self.model.score = data.score
	self.model.kill = data.kill
	self.model:Brocast(WarriorEvent.UpdateInfo,data)
end

function WarriorController:HandleEndInfo()
	local data = self:ReadMsg("m_warrior_end_toc");
	--logError("结束")
	lua_panelMgr:GetPanelOrCreate(WarriorEndPanel):Open(data)
	self.model:Brocast(WarriorEvent.EndInfo,data)
end

--请求排行榜数据
function WarriorController:RequesRankInfo(num)
	local pb = self:GetPbObject("m_warrior_rank_tos");
	pb.num = num
	self:WriteMsg(proto.WARRIOR_RANK, pb);
end

function WarriorController:HandleRankInfo()
	local data = self:ReadMsg("m_warrior_rank_toc");
	self.model:Brocast(WarriorEvent.RankInfo,data)
end

function WarriorController:HandleCreep()
	local data = self:ReadMsg("m_warrior_creep_toc");
	self.model.creepState = data.state
	self.model:Brocast(WarriorEvent.CreepInfo,data)
end






