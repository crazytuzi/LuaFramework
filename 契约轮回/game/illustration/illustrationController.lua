require('game.illustration.Requireillustration')
illustrationController = illustrationController or class("illustrationController",BaseController)

function illustrationController:ctor()
	illustrationController.Instance = self

	self.ill_model = illustrationModel:GetInstance()
	self.ill_model_events = {}

	self.bag_model = BagModel.GetInstance()
	self.bag_model_events = {}

	self.beast_model = BeastModel.GetInstance()

	self.global_events = {}
	self.role_data_event = nil
	self:AddEvents()
	self:RegisterAllProtocal()
end

function illustrationController:dctor()
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = {}

	self.ill_model:RemoveTabListener(self.bag_model_events)
	self.ill_model_events = {}

	self.bag_model:RemoveTabListener(self.bag_model_events)
	self.bag_model_events = {}

	if self.role_data_event then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_data_event)
        self.role_data_event = nil
    end
end

function illustrationController:GetInstance()
	if not illustrationController.Instance then
		illustrationController.new()
	end
	return illustrationController.Instance
end

function illustrationController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1142_illustration_pb"
	self:RegisterProtocal(proto.ILLUSTRATION_INFO, self.HandleInfo)
	self:RegisterProtocal(proto.ILLUSTRATION_UPSTAR, self.HandleUpStar)
	self:RegisterProtocal(proto.ILLUSTRATION_DECOMPOSE, self.HandleDecompose)
end

function illustrationController:AddEvents()

	local function call_back()
		--logError("图鉴背包更新")
		self:CheckReddot()
	end
	self.bag_model_events[#self.bag_model_events + 1] = self.bag_model:AddListener(illustrationEvent.LoadillustrationItems,call_back)

	local function call_back()
		--logError("图鉴信息更新")
		self:CheckReddot()
	end
	self.ill_model_events[#self.ill_model_events + 1] = self.ill_model:AddListener(illustrationEvent.Updateillustration,call_back)


	local function call_back()
	   --logError("图鉴精华更新")
	   self:CheckReddot()
    end
    self.role_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.illusEssence, call_back)
end

function illustrationController:CheckReddot()
	--走异兽那边的红点刷新接口才行
	self.beast_model:UpdateReddot()
end

--请求图鉴信息
function illustrationController:RequestInfo()
	local pb = self:GetPbObject("m_illustration_info_tos")
	self:WriteMsg(proto.ILLUSTRATION_INFO,pb)

	----logError("请求图鉴信息")
end

--处理图鉴信息
function illustrationController:HandleInfo()
	local data = self:ReadMsg("m_illustration_info_toc")
	local list = data.list

	self.ill_model:UpdateIllInfos(list)
	self.ill_model:Brocast(illustrationEvent.Updateillustration)
	--logError("处理图鉴信息")
end

--请求图鉴激活/升星
function illustrationController:RequestUpStar(id)
	local pb = self:GetPbObject("m_illustration_upstar_tos")
	pb.id = id
	self:WriteMsg(proto.ILLUSTRATION_UPSTAR,pb)

	--logError("请求图鉴升星"..id)
end

--处理图鉴激活/升星
function illustrationController:HandleUpStar()
	local data = self:ReadMsg("m_illustration_upstar_toc")
	local illustration = data.illustration

	self.ill_model:UpdateIllInfo(illustration)
	self.ill_model:Brocast(illustrationEvent.Updateillustration)
	self.ill_model:Brocast(illustrationEvent.UpStarComplete)

	--升星后重新请求下图鉴背包信息
	BagController.GetInstance():RequestBagInfo(BagModel.illustration)

	--logError("处理图鉴升星，id"..illustration.id.."-star"..illustration.star)
end

--请求图鉴道具分解
function illustrationController:RequestDecompose(uids)
	local pb = self:GetPbObject("m_illustration_decompose_tos")
	for i, v in pairs(uids) do
        pb.uid:append(i)
    end
	self:WriteMsg(proto.ILLUSTRATION_DECOMPOSE,pb)

	--logError("请求图鉴分解")
end

--处理图鉴道具分解
function illustrationController:HandleDecompose()
	local data = self:ReadMsg("m_illustration_decompose_toc")

	--logError("处理图鉴分解")

	self.ill_model:Brocast(illustrationEvent.DecomposeComplete)

	--分解后重新请求下图鉴背包信息
	BagController.GetInstance():RequestBagInfo(BagModel.illustration)
end

-- overwrite
function illustrationController:GameStart()

	--游戏开始时请求图鉴信息
    local function step()
      self:RequestInfo()
    end
	GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.VLow)
end