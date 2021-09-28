require "Core.Module.Pattern.Proxy"

CloudPurchaseProxy = Proxy:New();

--==============================--
--desc:购买回调
--time:2017-09-21 08:39:46
--@cmd:
--@data:
--@return 
--==============================--
local function SendCloudPurchaseBuyCallBack(cmd, data)
	if(data and data.errCode == nil) then
		CloudPurchaseManager.SetBuyCount(data.t, data.tt)
		CloudPurchaseManager.HandleBuyRecoders(data.l)
		-- CloudPurchaseManager.AddBuyRecorder(CloudPurchaseManager.HandleBuyRecoder({name = HeroController:GetInstance().info.name, num = data.bt, item = CloudPurchaseManager.GetTodayConfig().careerReward.name, k = PlayerManager.GetPlayerKind()})	)	
		ModuleManager.SendNotification(CloudPurchaseNotes.CLOSE_CLOUDPURCHASEBUYPANEL)
		ModuleManager.SendNotification(CloudPurchaseNotes.UPDATE_CLOUDPURCHASEPANEL_RECORDER)		
	end	
end

--==============================--
--desc:获取云购信息
--time:2017-09-21 08:40:05
--@cmd:
--@data:
--@return 
--==============================--
local function GetCloudPurchaseInfoCallBack(cmd, data)
	if(data and data.errCode == nil) then
		CloudPurchaseManager.SetCloudPurchaseInfo(data)
		ModuleManager.SendNotification(CloudPurchaseNotes.OPEN_CLOUDPURCHASEPANEL)
	end		
end

--==============================--
--desc:通知云购开奖
--time:2017-09-21 08:40:14
--@cmd:
--@data:
--@return 
--==============================--
local function NoticeCloudPurchaseCallBack(cmd, data)
	if(data and data.errCode == nil) then
		CloudPurchaseManager.SetRedPoint(true)
	end		
end

--==============================--
--desc:获取上期获奖结果
--time:2017-09-21 08:40:24
--@cmd:
--@data:
--@return 
--==============================--
local function GetLastCloudPurchaseRecorderCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local rewards = {}
		local _insert = table.insert
		if(data.l) then
			rewards.my = {}
			for k, v in ipairs(data.l) do
				local item = {}
				setmetatable(item, {__index = ProductManager.GetProductById(v.spId)})
				item.num = v.num
				_insert(rewards.my, item)
			end
		end
		
		if(data.l2) then
			rewards.other = {}
			for k, v in ipairs(data.l2) do
				local item = {}
				item.reward = {}
				setmetatable(item.reward, {__index = ProductManager.GetProductById(v.spId)})
				item.reward.num = v.num
				item.pid = v.pid
				item.name = v.name
				_insert(rewards.other, item)
			end
		end
		
		ModuleManager.SendNotification(CloudPurchaseNotes.OPEN_CLOUDPURCHASERECODERPANEL, rewards)
	end		
end

local function GetCloudPurchaseRewardCallBack(cmd, data)
	if(data and data.errCode == nil) then
		CloudPurchaseManager.SetRewardState(data.rs)
		ModuleManager.SendNotification(CloudPurchaseNotes.UPDATE_CLOUDPURCHASEPANEL)
	end
end

function CloudPurchaseProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendCloudPurchaseBuy, SendCloudPurchaseBuyCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetCloudPurchaseInfo, GetCloudPurchaseInfoCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.NoticeCloudPurchase, NoticeCloudPurchaseCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLastCloudPurchaseRecorder, GetLastCloudPurchaseRecorderCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetCloudPurchaseReward, GetCloudPurchaseRewardCallBack);
	
end

function CloudPurchaseProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendCloudPurchaseBuy, SendCloudPurchaseBuyCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetCloudPurchaseInfo, GetCloudPurchaseInfoCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.NoticeCloudPurchase, NoticeCloudPurchaseCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLastCloudPurchaseRecorder, GetLastCloudPurchaseRecorderCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetCloudPurchaseReward, GetCloudPurchaseRewardCallBack);
	
end

function CloudPurchaseProxy.SendCloudPurchaseBuy(count)
	SocketClientLua.Get_ins():SendMessage(CmdType.SendCloudPurchaseBuy, {bt = count});	
end

function CloudPurchaseProxy.GetCloudPurchaseInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetCloudPurchaseInfo);	
end

function CloudPurchaseProxy.SendGetLastCloudPurchaseRecorder()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetLastCloudPurchaseRecorder);	
end

function CloudPurchaseProxy.SendGetCloudPurchaseReward()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetCloudPurchaseReward);	
end 