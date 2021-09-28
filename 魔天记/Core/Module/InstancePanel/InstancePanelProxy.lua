require "Core.Module.Pattern.Proxy"

InstancePanelProxy = Proxy:New();

InstancePanelProxy.MESSAGE_BOX_PRODUCTS_CHANGE = "MESSAGE_BOX_PRODUCTS_CHANGE";

InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE = "MESSAGE_SAO_DANG_COMPLETE";
InstancePanelProxy.MESSAGE_GET_BOX_PROS_SUCCESS = "MESSAGE_GET_BOX_PROS_SUCCESS";

InstancePanelProxy.MESSAGE_ELSETIME_CHANGE = "MESSAGE_ELSETIME_CHANGE";
InstancePanelProxy.MESSAGE_FB_OVER = "MESSAGE_FB_OVER";


function InstancePanelProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetFB_instReds, InstanceDataManager.GetFB_instRedsResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Saodang, InstancePanelProxy.SaodangResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetBoxProducts, InstancePanelProxy.GetBoxProductsResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetOldSceneInfo, InstancePanelProxy.GetOldSceneInfoResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.YiJianSaodang, InstancePanelProxy.YiJianSaodangResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ResetInstanteTime, InstancePanelProxy.ResetInstanteTimeResult)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetGBoxInfos, InstancePanelProxy.GetGBoxInfosResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetGBoxProducts, InstancePanelProxy.GetGBoxProductsResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetFB_ElseTime, InstancePanelProxy.GetFB_ElseTimeResult);
end

function InstancePanelProxy:OnRemove()	
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetFB_instReds, InstanceDataManager.GetFB_instRedsResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetFB_ElseTime, InstancePanelProxy.GetFB_ElseTimeResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetGBoxProducts, InstancePanelProxy.GetGBoxProductsResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetGBoxInfos, InstancePanelProxy.GetGBoxInfosResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ResetInstanteTime, InstancePanelProxy.ResetInstanteTimeResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.YiJianSaodang, InstancePanelProxy.YiJianSaodangResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Saodang, InstancePanelProxy.SaodangResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetOldSceneInfo, InstancePanelProxy.GetOldSceneInfoResult);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetBoxProducts, InstancePanelProxy.GetBoxProductsResult);
end

InstancePanelProxy.outFbHanlder = nil;
function InstancePanelProxy.OutFBHandler()
	
	InstancePanelProxy.outFbHanlder = nil;
	local map = GameSceneManager.map;
	
	if map ~= nil then
		local _fid = map._fid;
		
		local fb_cf = InstanceDataManager.GetMapCfById(_fid);
		
		if fb_cf ~= nil and fb_cf.type == InstanceDataManager.InstanceType.MainInstance then
			InstancePanelProxy.outFbHanlder = FBResultProxy.TryShowInstancePanel;
		end
	end
	
	
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetOldSceneInfo, {});
	
end


--[[C 获取上一场景信息
输入：

输出：
scene:{sid:sceneId,x,y,z} 下线场景点
0x030C

]]
function InstancePanelProxy.GetOldSceneInfoResult(cmd, data)
	
	
	
	
	if(data.errCode == nil) then
		
		
		-- 如果是 剧情副本的话， 那么就需要 返回上额场景后 打开副本界面
		local info = data.scene;
		
		local toScene = {};
		toScene.sid = info.sid;
		toScene.position = Convert.PointFromServer(info.x, info.y, info.z);
		
		-- GameSceneManager.to = toScene;
		if(InstancePanelProxy.outFbHanlder) then
			GameSceneManager.SetInitSceneCallBack(InstancePanelProxy.outFbHanlder)
		end

		GameSceneManager.GotoScene(info.sid,nil,to);
		
		
	end
	
end


function InstancePanelProxy.TryGetBoxProducts(spId)
	
	
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetBoxProducts, {spId = spId});
	
end

--[[17 查看宝箱
输入
id: 道具id
输出：
items:[(spId,num)....]

]]
function InstancePanelProxy.GetBoxProductsResult(cmd, data)
	
	
	
	if(data.errCode == nil) then
		MessageManager.Dispatch(InstancePanelProxy, InstancePanelProxy.MESSAGE_BOX_PRODUCTS_CHANGE, data);
	end
	
end



-- 副本扫荡
function InstancePanelProxy.TrySaodang(fb_id)
	SocketClientLua.Get_ins():SendMessage(CmdType.Saodang, {id = fb_id .. ""});
--[[ local tesetData = {};
 tesetData[1]={instId="750001",items={{num=1000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};
 tesetData[2]={instId="750001",items={{num=2000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};
 tesetData[3]={instId="750001",items={{num=3000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};


 tesetData[4]={instId="750001",items={{num=4000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};
 tesetData[5]={instId="750001",items={{num=5000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};
 tesetData[6]={instId="750001",items={{num=6000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};
 tesetData[7]={instId="750001",items={{num=7000,spId=1} ,{num=3000,spId=4},{num=2,spId=301001} }};


  log("-------TrySaodang--------- "..InstancePanelNotes.OPEN_INSTANCESHAODANGINFOPANEL);

   ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCESHAODANGINFOPANEL,{l=tesetData});
   ]]
end

--[[0B 扫荡副本

输入：
instId：副本Id
输出：
[l:[instId:副本id，items:[(spId,num)....] ]...
0x0F09
]]
function InstancePanelProxy.SaodangResult(cmd, data)
	
	
	if(data.errCode == nil) then
		--  S <-- 17:29:27.304, 0x0F0B, 14, {"l":[{"items":[{"num":20000,"spId":4},{"num":1000,"spId":1},{"num":1,"spId":301001}],"instId":"750001"}]}
		ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCESHAODANGINFOPANEL, data);
		
		MessageManager.Dispatch(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE);
	end
	
end


-- 一键扫荡
function InstancePanelProxy.TryYIJianSaodang(t, k)
	
	SocketClientLua.Get_ins():SendMessage(CmdType.YiJianSaodang, {t = t, k = k});
	
end

--[[09 一键扫荡

输入：
t：副本类型
k：副本难度
输出：
[l:[instId:副本id，items:[(spId,num)....] ]...
0x0F09


]]
function InstancePanelProxy.YiJianSaodangResult(cmd, data)
	
	
	if(data.errCode == nil) then
		
		
		ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCESHAODANGINFOPANEL, data);
		
		MessageManager.Dispatch(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE);
	end
	
end


function InstancePanelProxy.TryResetInstanteTime(fb_id)
	
	SocketClientLua.Get_ins():SendMessage(CmdType.ResetInstanteTime, {id = fb_id .. ""});
end

function InstancePanelProxy.ResetInstanteTimeResult(cmd, data)
	
	
	if(data.errCode == nil) then
		MessageManager.Dispatch(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE);
	end
	
end

-- 0C 获取宝箱记录
function InstancePanelProxy.TryGetGBoxInfos()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetGBoxInfos, {});
end

function InstancePanelProxy.GetGBoxInfosResult(cmd, data)
	
	
	if(data.errCode == nil) then
		InstanceDataManager.SetHasGetBoxLog(data)
	end
	
end

--[[0D 获取宝箱记录¶
输入：
t：副本类型
k：副本难度
index：星级下标（1到4）
输出：
t：副本类型，k：副本难度，rs:[index：下标,flag:表示状态] (index:1到4 对应星级，flag：是否领取 0未领取，1：领取）
items:[(spId,num)....]
0x0F0D

 S <-- 15:34:03.865, 0x0F0D, 19, {"rs":[{"flag":0,"index":2},{"flag":0,"index":4},{"flag":1,"index":1},{"flag":0,"index":3}],"t":1,"k":1,"items":[{"am":1,"spId":502001}]}
]]
function InstancePanelProxy.TryGetGBoxProducts(t, k, index)
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetGBoxProducts, {t = t, k = k, index = index});
end

function InstancePanelProxy.GetGBoxProductsResult(cmd, data)
	
	
	if(data.errCode == nil) then
		InstancePanelProxy.TryGetGBoxInfos();
		MessageManager.Dispatch(InstancePanelProxy, InstancePanelProxy.MESSAGE_GET_BOX_PROS_SUCCESS);
	end
	
end


-- function InstancePanelProxy.SceneDispose()
--    InstancePanelProxy.txtTarget = nil;
--    if InstancePanelProxy._sec_timer ~= nil then
--        InstancePanelProxy._sec_timer:Stop();
--        InstancePanelProxy._sec_timer = nil;
--    end
-- end
function InstancePanelProxy.TryGetFB_ElseTime()
	
	SocketClientLua.Get_ins():SendMessage(CmdType.GetFB_ElseTime, {});
end



function InstancePanelProxy.GetFB_ElseTimeResult(cmd, data)
	
	
	
	if(data.errCode == nil) then
		
		MessageManager.Dispatch(InstancePanelProxy, InstancePanelProxy.MESSAGE_ELSETIME_CHANGE, data.t);
		
	end
	
end 