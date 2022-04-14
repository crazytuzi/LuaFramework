--
-- @Author: LaoY
-- @Date:   2018-12-20 14:27:57
--
require('game.magictower_treasure.RequireMagictowerTreasure')
MagictowerTreasureController = MagictowerTreasureController or class("MagictowerTreasureController",BaseController)
local MagictowerTreasureController = MagictowerTreasureController

function MagictowerTreasureController:ctor()
	MagictowerTreasureController.Instance = self
	self.model = MagictowerTreasureModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function MagictowerTreasureController:dctor()
end

function MagictowerTreasureController:GetInstance()
	if not MagictowerTreasureController.Instance then
		MagictowerTreasureController.new()
	end
	return MagictowerTreasureController.Instance
end

function MagictowerTreasureController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1111_mchunt_pb"
    self:RegisterProtocal(proto.MCHUNT_INFO, self.HandleInfo)
    self:RegisterProtocal(proto.MCHUNT_HUNT, self.HandleHunt)
    self:RegisterProtocal(proto.MCHUNT_DIG, self.HandleDig)
    self:RegisterProtocal(proto.MCHUNT_STAT, self.HandleStat)
    self:RegisterProtocal(proto.MCHUNT_LOG, self.HandleLog)
end

function MagictowerTreasureController:AddEvents()
	local function call_back()
		if self.model.mt_treasure_info and self.model.mt_treasure_info.dig == 0 and self.model.mt_treasure_info.etime ~= 0 then
			lua_panelMgr:OpenPanel(MtTreasureSelectPanel)
		else
			lua_panelMgr:OpenPanel(MtTreasurePanel)
		end
	end
	GlobalEvent:AddListener(MagictowerTreasureEvent.OpenMtTreasurePanel, call_back)

	-- --请求基本信息
	local function ON_REQ_BASE_INFO()
		self:RequestInfo()
	end
	self.model:AddListener(MagictowerTreasureEvent.REQ_INFO, ON_REQ_BASE_INFO)

	-- 请求寻宝
	local function ON_REQ_HUNT(type)
		self:RequestHunt(type)
	end
	self.model:AddListener(MagictowerTreasureEvent.REQ_HUNT, ON_REQ_HUNT)

	-- 请求挖宝
	local function ON_REQ_DIG(type,num)
		self:RequestDig(type,num)
	end
	self.model:AddListener(MagictowerTreasureEvent.REQ_DIG, ON_REQ_DIG)

	local function call_back(value)
		if self.model.mt_treasure_info then
			self.model.mt_treasure_info.power = value
			self.model:Brocast(MagictowerTreasureEvent.UpdatePower)
			self.model:UpdateReddot()
		end
	end
	RoleInfoModel:GetInstance():GetMainRoleData():BindData("mc_hunt",call_back)

	-- 收到寻宝
	local function ON_ACC_HUNT()
		lua_panelMgr:OpenPanel(MtTreasureSelectPanel)
	end
	self.model:AddListener(MagictowerTreasureEvent.ACC_HUNT,ON_ACC_HUNT)

	-- 收到挖宝
	local function ON_ACC_DIG()
		self.model:DigMtt()
	end
	self.model:AddListener(MagictowerTreasureEvent.ACC_DIG,ON_ACC_DIG)
end

-- overwrite
function MagictowerTreasureController:GameStart()
	local function step()
		self.model:Brocast(MagictowerTreasureEvent.REQ_INFO)
	end
	GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Low)
end

function MagictowerTreasureController:RequestInfo()
	self:WriteMsg(proto.MCHUNT_INFO)
end

function MagictowerTreasureController:HandleInfo()
    local data = self:ReadMsg("m_mchunt_info_toc")
    self.model.mt_treasure_info = data
    if data.etime ~= 0 then
    	lua_panelMgr:OpenPanel(MtTreasureMainPanel,2)
    	self.model:StartTime()
    	self.model.dig_talk_index = nil
    	if self.model.mt_treasure_info.dig == 0 or self.model.mt_treasure_info.dig == 1 then
		    self.model:AddNpcs()
		end
    end
    self.model:Brocast(MagictowerTreasureEvent.ACC_INFO)
    self.model:UpdateReddot()
end

function MagictowerTreasureController:RequestHunt(type)
	Yzprint('--LaoY MagictowerTreasureController.lua,line 114--',type,skip)
	local pb = self:GetPbObject("m_mchunt_hunt_tos")
	pb.type = type
	local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
	if lv >= MtTreasureConstant.SKipLevel then
		pb.skip = self.model.is_skip
	else
		pb.skip = false
	end
	self:WriteMsg(proto.MCHUNT_HUNT,pb)
end

function MagictowerTreasureController:HandleHunt()
    local data = self:ReadMsg("m_mchunt_hunt_toc")
    if self.model.mt_treasure_info then
    	self.model.mt_treasure_info.times = self.model.mt_treasure_info.times + 1
		self.model.mt_treasure_info.etime = data.etime
		self.model.mt_treasure_info.type = data.type
		self.model.mt_treasure_info.pos  = data.pos
		self.model.mt_treasure_info.scene  = data.scene
    end
    if data.etime ~= 0 then
    	lua_panelMgr:OpenPanel(MtTreasureMainPanel,2)
    	self.model:StartTime()
    	self.model.dig_talk_index = nil
    end
    self.model:AddNpcs()
	self.model:Brocast(MagictowerTreasureEvent.ACC_HUNT)
end

-- 1=劝服（对话）; 2=降服（击杀）; 3=吸收（采集）
function MagictowerTreasureController:RequestDig(type,num)
	local pb = self:GetPbObject("m_mchunt_dig_tos")
	pb.type = type
	pb.num  = num
	self:WriteMsg(proto.MCHUNT_DIG,pb)
end

function MagictowerTreasureController:HandleDig()
    local data = self:ReadMsg("m_mchunt_dig_toc")
    self.model.dig_data = data
    self.model.mt_treasure_info.dig = data.type
    if self.model.mt_treasure_info.dig ~= 1 then
		self.model:RemoveNpcs()
	end
	Yzprint('--LaoY MagictowerTreasureController.lua,line 149--',data)
	Yzdump(data,"data")
	self.model:Brocast(MagictowerTreasureEvent.ACC_DIG,data.type,data.num)
end

function MagictowerTreasureController:RequestStat(param)
	local pb = self:GetPbObject("m_mchunt_stat_tos")
	pb.param = param
	self:WriteMsg(proto.MCHUNT_STAT,pb)
end

function MagictowerTreasureController:HandleStat()
    local data = self:ReadMsg("m_mchunt_stat_toc")
    self.model:RemoveNpcs()
    self.model:ClearMtT()
	self.model:Brocast(MagictowerTreasureEvent.ACC_STAT,data.reward)
    lua_panelMgr:OpenPanel(MtTreasureRewardPanel,data.reward)

    OperationManager:GetInstance():StopAStarMove()
    AutoFightManager:GetInstance():Stop()
end

function MagictowerTreasureController:RequestLog()
	self:WriteMsg(proto.MCHUNT_LOG)
end

function MagictowerTreasureController:HandleLog()
    local data = self:ReadMsg("m_mchunt_log_toc")
    self.model.logs = data.logs
    self.model:Brocast(MagictowerTreasureEvent.ACC_LOG)
end