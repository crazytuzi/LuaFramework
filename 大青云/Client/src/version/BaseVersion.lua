--[[
版本基类
lizhuangzhuang
2015-9-16 17:02:40
------------------------------------------------
------------------------------------------------
所有版本的接口,都要在这里定义,然后在子类实现
]]

_G.Version = nil;--当前的版本

_G.BaseVersion = {};

BaseVersion.allVersion = {};

function BaseVersion:new(versionName)
	if self.allVersion[versionName] then
		print("Error:重复的平台版本.Version:",versionName);
		return;
	end
	local obj = {};
	obj.name = versionName;
	self.allVersion[versionName] = obj;
	for k,v in pairs(BaseVersion) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

function BaseVersion:GetName()
	return self.name;
end

function BaseVersion:Start(versionName)
	if not self.allVersion[versionName] then
		print("Error:不存在的平台版本.Version:",versionName)
		return false;
	end
	Version = self.allVersion[versionName];
	Version:OnStart();
	return true;
end

--启动模拟测试Version
function BaseVersion:StartTest(versionName)
	if not self.allVersion[versionName] then
		print("Error:不存在的平台版本.Version:",versionName)
		return false;
	end
	Version = self.allVersion[versionName];
	if versionName ~= VersionConsts.TXQQ then
		Version.Login = TestVersion.Login;
	end
	return true;
end

--启动事件
function BaseVersion:OnStart()

end

function BaseVersion:Warning()
	FloatManager:AddNormal("测试版不支持的接口");
end

--登录
function BaseVersion:Login()
	self:Warning();
end

function BaseVersion:Charge(amount)
	amount = amount or 10;
	if UIFirstRechargeWindow:Open(amount) then
		return;
	end
	self:Warning();
end

--进入游戏
function BaseVersion:OnEnterGame()
	return false;
end

--获取自动创角时间
function BaseVersion:GetAutoCreateTime()
	return 300000;
end

--下载微端
function BaseVersion:DownloadMClient()
	if _G.ismclient then return; end
	local mclienturl = _sys:getGlobal("mclienturl");
	local mchecksum = _sys:getGlobal("mchecksum");
	local onFinish = function(s)
		if not s then
			print("mclient download failed!");
			return;
		end
		print("mclient download success!");
		LoginController:GetMLoginUrl();
	end
	local onProgress = function(p)
		print("mclient download p:",p);
	end
	if (not mclienturl) or (not mchecksum) then
		mclienturl = self:GetMClientURL();
		mchecksum = self:GetMChecksum();
	end
	if mclienturl and mchecksum then
		if _sys:downloadMClient( mclienturl, mchecksum, StrConfig['login31'], StrConfig['login32'], onFinish,onProgress) == false then
			onFinish('success');
		end
	end
end

--是否开启V计划
function BaseVersion:IsOpenVPlan()
	return false;
end

--打开V计划官网
function BaseVersion:VPlanBrowse()
	self:Warning();
end

--打开V计划月费充值
function BaseVersion:VPlanMRecharge()
	self:Warning();
end

--打开V计划年费充值
function BaseVersion:VPlanYRecharge()
	self:Warning();
end

--是否开启手机绑定
function BaseVersion:IsOpenPhoneBinding()
	return false;
end

--打开手机绑定页面
function BaseVersion:PhoingBindBrowse()
	self:Warning();
end

--是否显示wan360加速球
function BaseVersion:IsOpenWanSpeed()
	return false;
end

--是否是Wan游戏大厅登陆
function BaseVersion:Is360Game()
	return false;
end

--是否显示游戏大厅按钮
function BaseVersion:IsShow360Game()
	return false;
end

--是否显示wan平台特殊渠道领奖按钮
function BaseVersion:IsShowWanChannelGame()
	return false;
end

--下载360游戏大厅
function BaseVersion:Download360Game()
	self:Warning();
end

--是否显示360特权
function BaseVersion:IsShowHd360()
	return false;
end

--打开360卫士特权页
function BaseVersion:Hd360Browse()
	self:Warning();
end

--是否开启QQ礼包
function BaseVersion:IsQQReward()
	return false;
end

--QQ群号
function BaseVersion:GetQQNum()
	return 0;
end

--快速加QQ群
function BaseVersion:QQRewardBrowse()
	self:Warning();
end

--打开防沉迷验证页面
function BaseVersion:FangChenMiBrowse()
	self:Warning();
end

--是否是联运版本
function BaseVersion:IsLianYun()
	return false;
end

--是否显示顺网平台特权(超级会员)
function BaseVersion:IsShowSwjoyTQ()
	return false;
end

--是否显示顺网平台会员
function BaseVersion:IsShowSwjoyVIP()
	return false;
end

--是否显示飞火平台特权(超级VIP)
function BaseVersion:IsShowFeiHuoTQ()
	return false;
end

--是否显示飞火手机绑定
function BaseVersion:IsShowFeihuoPhoneBind()
	return false;
end;

--飞火手机绑定链接
function BaseVersion:FeihuoPhoneBind()
	self:Warning();
end;

--是否屏蔽微端下载
function BaseVersion:IsHideMClient()
	return false;
end

--多玩上报初始化场景信息
function BaseVersion:DuoWanChangeScene()
	return false;
end

--多玩上报聊天信息
function BaseVersion:DuoWanCollectMsg()
	return false;
end

--多玩角色创角上报
function BaseVersion:DuoWanUserCreate()
	return false;
end

--多玩角色升级上报
function BaseVersion:DuoWanUserLevelUp()
	return false;
end

--多玩活动，百服盛典
function BaseVersion:DuowanisShowBaifuAct()
	return false;
end;

function BaseVersion:DuoWanBaifuAct()
	self:Warning();
end;

--打开顺网vip规则
function BaseVersion:LiaojieVip()
	self:Warning();
end

--打开顺网vip升级
function BaseVersion:UpViplvl()
	self:Warning();
end;

-- 是否显示迅雷vip
function BaseVersion:IsShowXunleiTQ()
	return false;
end

--是否显示迅雷手机绑定
function BaseVersion:IsShowXunleiPhone()
	return false;
end


---打开迅雷手机绑定
function BaseVersion:OpenXunleiPhoneBind()
	self:Warning();
end;

--是否是搜狗皮肤登录
function BaseVersion:IsSoGouSkinLogin()
	return false;
end

--是否是搜狗游戏大厅登录
function BaseVersion:IsSoGouGameBoxLogin()
	return false;
end

--搜狗游戏大厅下载
function BaseVersion:SouGouDownGameBox()
	self:Warning();
end;

--搜狗皮肤下载
function BaseVersion:SougouDownSkin()
	self:Warning();
end;

--搜狗显示搜狗vip
function BaseVersion:IsSoGouShowVipBtn()
	return false;
end;

--37wan手机绑定
function BaseVersion:L37wanBindPhone()
	self:Warning();
end;

function BaseVersion:IsShowBindPhone()
	return false;
end;

function BaseVersion:IsShowKugouVip()
	return false;
end

function BaseVersion:IsYXLaXin()
	return false;
end

function BaseVersion:LaXinBrowse()
	self:Warning();
end

--显示显示美女直播
function BaseVersion:IsShowGirlTV()
	return false;
end

--打开美女直播
function BaseVersion:GirlTVBrowse()
	self:Warning();
end

--是否显示手机APP
function BaseVersion:IsShowPhoneApp()
	return false;
end

--下载手机app-安卓
function BaseVersion:DownPhoneAppAndroid()
	self:Warning();
end

--下载手机app-IOS
function BaseVersion:DownPhoneAppIOS()
	self:Warning();
end

--天降惊喜
function BaseVersion:IsShowTianJiangjingxi()
	return false;
end

--天降惊喜Url
function BaseVersion:IsShowTianJiangjingxiUrl()
	self:Warning();
end

function BaseVersion:GetParams(filter)
	return nil;
end

function BaseVersion:GetFirstCharge(amount)
	self:Warning();
	return YouxiCfg.firstCharge;
end

function BaseVersion:IsShowRechargeButton()
	return true;
end

function BaseVersion:GetChannel()
	local channel = GetCommandParam('channel');
	channel = channel and tonumber(channel) or 0;
	return channel;
end

function BaseVersion:GetMClientURL()
	return ""
end
function BaseVersion:GetMChecksum()
	return ""
end