require("game/serveractivity/crazy_money_tree/crazy_moneytree_view")
require("game/serveractivity/crazy_money_tree/nomoney_view")
require("game/serveractivity/crazy_money_tree/crazy_moneytree_data")

CrazyMoneyTreeCtrl = CrazyMoneyTreeCtrl or BaseClass(BaseController)

function CrazyMoneyTreeCtrl:__init()
	if CrazyMoneyTreeCtrl.Instance ~= nil then
		print("[CrazyMoneyTreeCtrl]error:create a singleton twice")
	end

	CrazyMoneyTreeCtrl.Instance = self
	self.view = CrazyMoneyTreeView.New(ViewName.CrazyMoneyTreeView)
	self.nomoney_view = NoMoneyView.New(ViewName.NoMoneyView)
	self.data = CrazyMoneyTreeData.New()
	self:RegisterAllProtocols()  --注册协议
	--Remind.Instance:RegisterOneRemind(RemindId.crazy_money_tree, BindTool.Bind1(self.CheckRemind, self))
end

function CrazyMoneyTreeCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.nomoney_view then
		self.nomoney_view:DeleteMe()
		self.nomoney_view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	CrazyMoneyTreeCtrl.Instance = nil
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function CrazyMoneyTreeCtrl:RegisterAllProtocols()
	-- 注册接收到的协议
	self:RegisterProtocol(SCRAShakeMoneyInfo, "OnRAShakeMoneyInfo")
	self.open_trigger_handle = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.SendAllInfoReq, self))
end
function CrazyMoneyTreeCtrl:SendAllInfoReq() 
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY ) then
		return
    end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY,RA_SHAKEMONEY_OPERA_TYPE.RA_SHAKEMONEY_OPERA_TYPE_QUERY_INFO)
end

function CrazyMoneyTreeCtrl:OnRAShakeMoneyInfo(protocol)
	self.data:SetRAShakeMoneyInfo(protocol)
	RemindManager.Instance:Fire(RemindName.CrazyTree)

	local level = PlayerData.Instance.role_vo.level
	local act_cfg = ActivityData.Instance:GetActivityConfig(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY)
	if act_cfg~= nil and level >= act_cfg.min_level then
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHAKE_MONEY ) then
			MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.CRAZY_TREE, {true})
		else
			MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.CRAZY_TREE, {false})
	    end
	end
	self.view:Flush()
end

function CrazyMoneyTreeCtrl:Open()
	self.view:Open()
end

function CrazyMoneyTreeCtrl:NoMoneyViewOpen()
	self.nomoney_view:Open()	
end

function CrazyMoneyTreeCtrl:Close()
	self.nomoney_view:Close()	
end

function CrazyMoneyTreeCtrl:Flush(param)
	
end
function CrazyMoneyTreeCtrl:CheckRemind()
	return self.data:GetCanCrazy()
end