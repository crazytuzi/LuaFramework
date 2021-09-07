require("game/player/title/title_data")
require("game/player/player_title_huanhua_view")
--------------------------------------------------------------
--角色称号
--------------------------------------------------------------
TitleCtrl = TitleCtrl or BaseClass(BaseController)

function TitleCtrl:__init()
	if TitleCtrl.Instance then
		print_error("[TitleCtrl] Attemp to create a singleton twice !")
	end
	TitleCtrl.Instance = self
	self.data = TitleData.New()
	self.huanhua_view = PlayerTitleHuanhuaView.New(ViewName.PlayerTitleHuanhua)
	self:RegisterAllProtocols()
end

function TitleCtrl:__delete()
	self.data:DeleteMe()
	TitleCtrl.Instance = nil
	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end
end

function TitleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTitleList, "OnTitleList")
	self:RegisterProtocol(SCUsedTitleList, "OnUsedTitleList")
	self:RegisterProtocol(SCRoleUsedTitleChange, "OnRoleUsedTitleChange")
end

--获得新称号时回调 或者 主动请求时回调 查看已激活的称号
function TitleCtrl:OnTitleList(protocol)
	self.data:OnTitleList(protocol)
	if self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.PlayerTitle)
end

--进入游戏时回调同步称号 用来初始化称号佩戴情况
function TitleCtrl:OnUsedTitleList(protocol)
	self.data:OnUsedTitleList(protocol)
	if Scene.Instance:GetMainRole() then
		Scene.Instance:GetMainRole():SetAttr("used_title_list", protocol.used_title_list)
	end
end

function TitleCtrl:OnRoleUsedTitleChange(protocol) --穿戴称号时
	self.data:OnRoleUsedTitleChange(protocol)
	if self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush()
	end
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("used_title_list", protocol.title_active_list)
	end
	PlayerCtrl.Instance:FlushPlayerView("title_change")
end

function TitleCtrl:SendCSUseTitle(title_active_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUseTitle)
	send_protocol.title_active_list = title_active_list
	send_protocol:EncodeAndSend()
end

--请求称号列表
function TitleCtrl:SendCSGetTitleList(title_active_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetTitleList)
	send_protocol:EncodeAndSend()
end

function TitleCtrl:SendUpgradeTitleReq(title_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeTitle)
	send_protocol.title_id = title_id
	send_protocol:EncodeAndSend()
end