--
-- @Author: chk
-- @Date:   2019-01-04 19:19:30
--

FactionWareController = FactionWareController or class("FactionWareController",BaseController)
local FactionWareController = FactionWareController

function FactionWareController:ctor()
	FactionWareController.Instance = self
	self.model = FactionModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function FactionWareController:dctor()
end

function FactionWareController:GetInstance()
	if not FactionWareController.Instance then
		FactionWareController.new()
	end
	return FactionWareController.Instance
end

function FactionWareController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1401_guild_depot_pb"
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)

	self:RegisterProtocal(proto.GUILD_DEPOT_DONATE,self.ResponeDonateEquip)
	self:RegisterProtocal(proto.GUILD_DEPOT_INFO,self.ResponeWareInfo)
	self:RegisterProtocal(proto.GUILD_DEPOT_DETAIL,self.ResponeEquipDetailInfo)
	self:RegisterProtocal(proto.GUILD_DEPOT_DESTROY,self.ResponeDestroyEquip)
	self:RegisterProtocal(proto.GUILD_DEPOT_EXCH,self.ResponeExchEquip)
	self:RegisterProtocal(proto.GUILD_DEPOT_BUY,self.ResponeExchBuy)
end

function FactionWareController:AddEvents()
	-- --请求基本信息
	-- local function ON_REQ_BASE_INFO()
		-- self:RequestLoginVerify()
	-- end
	-- self.model:AddListener(FactionWareModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)

	--self.model:AddListener(FactionEvent.RequestDonateEquip,handler(self,self.RequestDonateEquip))
end

-- overwrite
function FactionWareController:GameStart()
	local function call_back()
		local role  = RoleInfoModel.GetInstance():GetMainRoleData()
		if role.guild ~= "0" then
			self:RequestWareInfo()
		end
	end
	GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.Low)
end

----请求基本信息
--function LoginController:RequestLoginVerify()
	-- local pb = self:GetPbObject("m_login_verify_tos")
	-- self:WriteMsg(proto.LOGIN_VERIFY,pb)
--end

----服务的返回信息
--function FactionWareController:HandleLoginVerify(  )
	-- local data = self:ReadMsg("m_login_verify_toc")
--end

--请求仓库信息
function FactionWareController:RequestWareInfo()
	local pb = self:GetPbObject("m_guild_depot_info_tos")
	self:WriteMsg(proto.GUILD_DEPOT_INFO,pb)
end

function FactionWareController:ResponeWareInfo()
	self.model.wareInfo = self:ReadMsg("m_guild_depot_info_toc")
	self.model:SortItems(self.model.wareInfo.items)
	self.model:SetWareItems(self.model.selectQuality,self.model.selectStep,self.model.isMapSelf)
	self.model:SortItems(self.model.wareItems)
    self.model:AddFstItem()
	self.model:Brocast(FactionEvent.WareInfo)
end

--请求捐献装备
function FactionWareController:RequestDonateEquip(uid)
	local pb = self:GetPbObject("m_guild_depot_donate_tos")
	pb.uid = uid
	self:WriteMsg(proto.GUILD_DEPOT_DONATE,pb)
end


function FactionWareController:ResponeDonateEquip()
	local data = self:ReadMsg("m_guild_depot_donate_toc")
	local logParam = {}
	logParam.type = 1   --捐献; 2=兑换
	logParam.role_id = data.role_id
	logParam.role_name = data.role_name
	logParam.item = data.item
	logParam.score = data.score
	logParam.time = data.time
	local index = self.model:AddDonateLog(logParam)
	if self.model.isOpenWarePanel then
		self.model:AddDonateEquip(data.item)
		self.model.wareInfo.score = self.model.wareInfo.score + Config.db_equip[data.item.id].donate_score
		self.model:Brocast(FactionEvent.DonateLog,logParam, index)
	end
	self:AddLogToChat(logParam, index)
end

--请求物品信息
function FactionWareController:RequestEquipDetailInfo(uid)
	local pb = self:GetPbObject("m_guild_depot_detail_tos")
	pb.uid = uid
	self:WriteMsg(proto.GUILD_DEPOT_DETAIL,pb)
end

function FactionWareController:ResponeEquipDetailInfo()
	local data = self:ReadMsg("m_guild_depot_detail_toc")
	GlobalEvent:Brocast(GoodsEvent.GoodsDetail,data.item)
	--self.model:Brocast(FactionEvent.EquipDetailInfo,data.item)
end

--销毁装备
function FactionWareController:RequestDestroyEquip()
	local pb = self:GetPbObject("m_guild_depot_destroy_tos")
	for i, v in pairs(self.model.wareItemsId) do
		table.insert(pb.uids,v)
	end
	--pb.uids = self.model.wareItemsId
	self:WriteMsg(proto.GUILD_DEPOT_DESTROY,pb)
end

function FactionWareController:ResponeDestroyEquip()
	local data = self:ReadMsg("m_guild_depot_destroy_toc")
	if self.model.isOpenWarePanel then
		for i, v in pairs(data.uids) do
			self.model:DelWareEquip(v)
			--self.model:Brocast(FactionEvent.DelWareItem,v)
		end

		self.model.wareItemsId = {}
	end
end

--请求兑换装备
function FactionWareController:RequestExchEquip(uid)
	if not self.model:GetEquipCanExchange(uid) then
		Notify.ShowText(ConfigLanguage.Faction.ScoreNotEnough)
	else
		local pb = self:GetPbObject("m_guild_depot_exch_tos")
		pb.uid = uid
		self:WriteMsg(proto.GUILD_DEPOT_EXCH,pb)
	end

end

function FactionWareController:ResponeExchEquip()
	local data = self:ReadMsg("m_guild_depot_exch_toc")
	local logParam = {}
	logParam.type = 2   --捐献; 2=兑换
	logParam.role_id = data.role_id
	logParam.role_name = data.role_name
	logParam.item = data.item
	logParam.score = data.score
	logParam.time = data.time
	local index = self.model:AddDonateLog(logParam)
	if self.model.isOpenWarePanel then
		self.model:DelWareEquip(data.item.uid)
		local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
		if logParam.role_id == roleData.id  then
			self.model.wareInfo.score = self.model.wareInfo.score - data.score
			self.model:Brocast(FactionEvent.ExchangeSucess,logParam, index)
		end
	end
	self:AddLogToChat(logParam, index)
end

--换购
function FactionWareController:RequestExchBuy(item_id,num)
	if not self.model:GetCanExcBuy(item_id,num) then
		Notify.ShowText(ConfigLanguage.Faction.ScoreNotEnough)
	else
		local pb = self:GetPbObject("m_guild_depot_buy_tos")
		pb.item_id = item_id
		pb.num = num
		self:WriteMsg(proto.GUILD_DEPOT_BUY,pb)
	end

end

function FactionWareController:ResponeExchBuy()
	local data = self:ReadMsg("m_guild_depot_buy_toc")
	local logParam = {}
	logParam.type = 2   --捐献; 2=兑换
	logParam.role_id = data.role_id
	logParam.role_name = data.role_name
	logParam.item = data.item
	logParam.score = data.score
	logParam.time = data.time

	local index = self.model:AddDonateLog(logParam)
	self:AddLogToChat(logParam, index)

	local roleData = RoleInfoModel:GetInstance():GetMainRoleData()
	if logParam.role_id == roleData.id  then
		self.model.wareInfo.score = self.model.wareInfo.score - data.score
		self.model:Brocast(FactionEvent.ExchangeSucess,logParam, index)
	end
	--self.model.wareInfo.score = self.model.wareInfo.score - data.score
	--self.model:Brocast(FactionEvent.ExchangeSucess,logParam,index)
end

function FactionWareController:AddLogToChat(logParam, index)
	local item = logParam.item
	local item_id = item.id
	local itemCfg = Config.db_item[item_id]
	local content = string.format("<color=#ff9600><a href=role_%s>[%s]</a></color>Donated<color=#%s><a href=guildlog_%s>[%s]</a></color>.Obtained <color=#6ce19b>%s</color>points",
		logParam.role_id, logParam.role_name, ColorUtil.GetColor(itemCfg.color), index, itemCfg.name, logParam.score)
	if logParam.type == 2 then
		content = string.format("<color=#ff9600><a href=role_%s>[%s]</a></color>Exchanged<color=#%s><a href=guildlog_%s>[%s]</a></color>.Cost <color=#6ce19b>%s</color>points",
		logParam.role_id, logParam.role_name, ColorUtil.GetColor(itemCfg.color), index, itemCfg.name, logParam.score)
	end

	local data = {}
	data.channel_id = enum.CHAT_CHANNEL.CHAT_CHANNEL_GUILD
	data.type_id = 0
	data.content = content
	GlobalEvent:Brocast(ChatEvent.ReceiveMessage, data)
end

