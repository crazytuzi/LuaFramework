require "Core.Module.Pattern.Proxy"

LotteryProxy = Proxy:New();
function LotteryProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SendLottery, LotteryProxy._OnSendLotteryResultCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLotteryInfo, LotteryProxy._OnGetLotteryInfoCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetLotteryRecorder, LotteryProxy._OnGetLotteryRecorderCallBack);
	
	
end

function LotteryProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SendLottery, LotteryProxy._OnSendLotteryResultCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLotteryInfo, LotteryProxy._OnGetLotteryInfoCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetLotteryRecorder, LotteryProxy._OnGetLotteryRecorderCallBack);
	
end
-- 0：抽一次 1：抽10次 2:抽10次
function LotteryProxy.SendLottry(t, cost)
	if t == 0 and LotteryManager.GetIsFree() then
		SocketClientLua.Get_ins():SendMessage(CmdType.SendLottery, {t = t})
		return
	end
	MsgUtils.UseGoldConfirm(cost, self, "Lottery/LotteryPanel/goldBuy"
	, {n = t == 0 and 1 or 10, m = cost}
	, function()
		SocketClientLua.Get_ins():SendMessage(CmdType.SendLottery, {t = t})
	end, nil, nil)
end

function LotteryProxy.SendGetLotteryInfo()
	SocketClientLua.Get_ins():SendMessage(CmdType.GetLotteryInfo, {})
end

-- 得到抽奖信息
function LotteryProxy._OnSendLotteryResultCallBack(cmd, data)
	if(data and data.errCode == nil) then
		LotteryManager.OnSetLotteryInfo(data.el, data.locd, data.sc);
		
		if data.el ~= nil then
			ModuleManager.SendNotification(LotteryNotes.OPEN_LOTTERYRESULTPANEL)
		end
		
		ModuleManager.SendNotification(LotteryNotes.UPDATE_LOTTERYPANEL)
	end
end

function LotteryProxy._OnGetLotteryInfoCallBack(cmd, data)
	if(data and data.errCode == nil) then
		LotteryManager.OnSetLotteryInfo(nil, data.locd, data.sc);
		LotteryManager.SetLotteryRecorder(data.l)
		ModuleManager.SendNotification(LotteryNotes.OPEN_LOTTERYPANEL)
	end
end

function LotteryProxy._OnGetLotteryRecorderCallBack(cmd, data)
	if(data and data.errCode == nil) then
		local cfg = MsgUtils.GetMsgCfgById(1050);	
		local p = {a = data.pi, b = data.pn, c = data.spId, d = data.am}
		local msg = LanguageMgr.ApplyFormat(cfg and cfg.msgStr or "", p, true)	 
		MessageManager.Dispatch(LotteryManager, LotteryManager.LOTTERY_RECORDER, msg)
	end
end 