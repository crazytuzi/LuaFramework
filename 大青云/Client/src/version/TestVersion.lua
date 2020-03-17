--[[
内网测试版本
lizhuangzhuang
2015年9月16日17:15:29
]]

_G.TestVersion = BaseVersion:new("test");

--登录
function TestVersion:Login(accountID)
	local msg = ReqConnSrvMsg:new();
	if not accountID then
		accountID = _sys:getGlobal("uid");
	end
	msg.accountID = accountID;
	msg.platform = "youxi";
	msg.game_name = "dqy";
	msg.server_id = 1;
	msg.time = 0;
	msg.is_adult = 1;--防沉迷验证
	msg.exts = "";--扩展信息
	msg.sign = "";--签名
	msg.mac = _sys.macAddress
	msg.version = _G.MsgBuildVersion
	msg.virtualIP = 1;
	MsgManager:Send(msg);
	if _G.testVersionName and _G.testVersionName~="" then
		_sys:setGlobal("uid",accountID);
		_sys:setGlobal("skey",1);
		_G.loginInfo = {};
		_G.loginInfo.uid = _sys:getGlobal("uid");
		_G.loginInfo.skey = _sys:getGlobal("skey");
	end
end

function TestVersion:IsOpenVPlan()
	return true;--临时屏蔽
end

function TestVersion:IsOpenPhoneBinding()
	return true;
end

function TestVersion:IsOpenWanSpeed()
	return true;
end

function TestVersion:Is360Game()
	return true;
end

function TestVersion:IsShowHd360()
	return true;
end

function TestVersion:IsShow360Game()
	return true;
end

function TestVersion:IsQQReward()
	return true;
end

function TestVersion:GetQQNum()
	return 88888888;
end

function TestVersion:IsYXLaXin()
	return true;
end