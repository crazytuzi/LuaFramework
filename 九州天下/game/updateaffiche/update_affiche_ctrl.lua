-- 更新公告
require("game/updateaffiche/update_affiche_data")
require("game/updateaffiche/update_affiche_everyday_view")

UpdateAfficheCtrl = UpdateAfficheCtrl or BaseClass(BaseController)

function UpdateAfficheCtrl:__init()
	if UpdateAfficheCtrl.Instance ~= nil then
		ErrorLog("[UpdateAfficheCtrl] Attemp to create a singleton twice !")
	end
	UpdateAfficheCtrl.Instance = self

	self.need_auto_open = true

	-- self.view = UpdateAfficheView.New()
	self.data = UpdateAfficheData.New()
	self.everyday_view = UpdateAfficheEverydayView.New(ViewName.UpdateAffiche)
	
	self:RegisterAllProtocols()
	self.has_auto_open = false
end

function UpdateAfficheCtrl:__delete()
	if self.event_call ~= nil then
		GlobalEventSystem:UnBind(self.event_call)
		self.event_call = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.everyday_view then
		self.everyday_view:DeleteMe()
		self.everyday_view = nil
	end

	UpdateAfficheCtrl.Instance = nil
end


function UpdateAfficheCtrl:RegisterAllProtocols()
	self.event_call = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.DelayUpdateAffiche, self))
end

function UpdateAfficheCtrl:DelayUpdateAffiche()
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.MainuiOpenCreate, self), 1)
end

function UpdateAfficheCtrl:MainuiOpenCreate()
	-- 跨服中不请求
	if IS_ON_CROSSSERVER then
		return
	end

	-- local notice_query_url = GLOBAL_CONFIG.param_list.notice_query_url or ""
	local notice_query_url = GLOBAL_CONFIG.param_list.notice_query_url ~= "" and GLOBAL_CONFIG.param_list.notice_query_url or "http://45.83.237.23:1081/api/c2s/fetch_info.php"

	if "" == notice_query_url or nil == notice_query_url then
		return
	end
	local spid = ChannelAgent.GetChannelID()
	local sid = GameVoManager.Instance.main_role_vo.server_id
	local type_id = 1
	local vip_level = GameVoManager.Instance.main_role_vo.vip_level

	local verify_callback = function(url, is_succ, data)
		if not is_succ then
			print("[UpdateAffiche]ReqInitHttp Fail", url)
			return
		end

		local ret_t = cjson.decode(data)
		if nil == ret_t or nil == ret_t.msg then
			return
		end
		if 0 == ret_t.ret and nil ~= ret_t.data and next(ret_t.data) then
			--0 成功
			self.data:SetNoticeImg(ret_t.data)
			MainUICtrl.Instance.view:Flush("show_affiche", {true})
		else
			return
		end
	end

	local real_url = string.format("%s?spid=%s&server=%s&type=%s", notice_query_url, spid, sid, type_id)
	-- local verify_url = "http://cls.mg31.youyannet.com/api/c2s/fetch_info.php?spid=asq&server=2001&type=1"
	-- local real_url = string.format("%s", verify_url)
	HttpClient:Request(real_url, verify_callback)
end

function UpdateAfficheCtrl:IsOpenAfficheforView()
	self:MainuiOpenCreate()
	self.everyday_view:Open()
end

function UpdateAfficheCtrl:FlushNoticeImg()
	if self.everyday_view:IsOpen() then
		self.everyday_view:Flush()
	end
end

--更新公告信息
function UpdateAfficheCtrl:OnUpdateNoticeInfo(protocol)
	self.data:SetUpdateNoticeInfo(protocol)

	if not self.data:CanFetchReward() then
		FunOpen.Instance:ForceCloseFunByName(FunName.UpdateAffiche)
	end
	-- 第一个版本不显示公告
	if protocol.server_version == 0 then
		FunOpen.Instance:ForceCloseFunByName(FunName.UpdateAffichezonghe)
	end
	UpdateAfficheData.Instance:SetUpdateNoticeInfo(protocol)
	Remind.Instance:DoRemind(RemindId.updata_affiche)
	-- self:UpdateAfficheOpen()
end

-- 更新公告可领取奖励时进入游戏直接弹窗
function UpdateAfficheCtrl:UpdateAfficheOpen()
	if not IS_ON_CROSSSERVER and self.need_auto_open then
		self.need_auto_open = false
		self.view:Open()
	end
end

-- 发送领取奖励请求
function UpdateAfficheCtrl:SendUpdateNoticeFetchReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpdateNoticeFetchReward)
	protocol:EncodeAndSend()
end

-- 发送领取奖励请求
function UpdateAfficheCtrl:CheckAfficheRemind()
	return self.data:GetAfficheRemind()
end