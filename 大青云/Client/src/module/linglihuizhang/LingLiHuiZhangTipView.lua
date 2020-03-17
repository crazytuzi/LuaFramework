--[[角色面板灵力徽章按钮Tip界面
zhangshuhui
2015年5月20日11:42:20
]]

_G.UILingLiHuiZhangTip = BaseUI:new("UILingLiHuiZhangTip");

--右上还是右下 0:右上 1:右下 
UILingLiHuiZhangTip.showtype = 0;

function UILingLiHuiZhangTip:Create()
	self:AddSWF("linglihuizhangTipPanel.swf", true, "top")
end

function UILingLiHuiZhangTip:OnLoaded(objSwf)
end

--显示Tip
function UILingLiHuiZhangTip:OnShow()
	self:ShowHuiZhangInfo();
	self:UpdatePos();
end

function UILingLiHuiZhangTip:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	self.posX = monsePos.x;
	self.posY = monsePos.y;
	objSwf._x = monsePos.x + 25;
	
	if self.showtype == 0 then
		objSwf._y = monsePos.y - objSwf._height - 26;
	else
		objSwf._y = monsePos.y + 26;
	end
end

--显示信息
function UILingLiHuiZhangTip:ShowHuiZhangInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	--等阶
	objSwf.lvlLoader.htmlText = "Lv."..LingLiHuiZhangModel:GetHuiZhangOrder();
	
	-- 产量
	objSwf.tfchanliang.text = "";
	
	local cfg = t_huizhang[LingLiHuiZhangModel:GetHuiZhangOrder()];
	if cfg then
		local huizhangaddpre = 0;
		local vipValue = VipController:GetJulingwanChanchu(VipController:GetVipLevel())
		if vipValue > 0 then--if playerinfo.eaVIPLevel > 0 then
			huizhangaddpre = vipValue--t_vip[playerinfo.eaVIPLevel].vip_huizhang_zhenqi;
		end
		local addnum = cfg.zhenqi[1] * huizhangaddpre / 100;
		if addnum % 1 > 0 then
			addnum = addnum - addnum % 1 + 1;
		end
		
		local str = "";
		if cfg.zhenqi[2] / 60 == 1 then
			str = string.format(StrConfig["linglihuizhang28"],cfg.zhenqi[1],addnum ,"", "");
		else
			str = string.format(StrConfig["linglihuizhang28"],cfg.zhenqi[1],addnum ,cfg.zhenqi[2] / 60, "");
		end
		objSwf.tfchanliang.htmlText = str;
		
		--累计收益
		local zhenqinummax = cfg.zhenqimax;
		if playerinfo.eaVIPLevel > 0 then
			zhenqinummax = zhenqinummax * (100 + VipController:GetJulingwanShangxianZengjia()) / 100;
		end
		objSwf.tfshouyi.text = LingLiHuiZhangModel:GetJuLingCount().."/"..zhenqinummax;
		
		--增长速率
		if playerinfo.eaVIPLevel <= 0 then
			objSwf.vipmaxinfo.htmlText = string.format(StrConfig["linglihuizhang26"],t_vippower[10101].c_v1/100);
		else
			objSwf.vipmaxinfo.htmlText = string.format(StrConfig["linglihuizhang27"],playerinfo.eaVIPLevel,huizhangaddpre);
		end
	end
	
	objSwf.tfbtnopen.htmlText = StrConfig["linglihuizhang34"];
end

function UILingLiHuiZhangTip:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local monsePos = _sys:getRelativeMouse();--获取鼠标位置
		if self.posX ~= monsePos.x or self.posY ~= monsePos.y then
			self.posX = monsePos.x;
			self.posY = monsePos.y;
			objSwf._x = monsePos.x + 25;
			if self.showtype == 0 then
				objSwf._y = monsePos.y - objSwf._height - 26;
			else
				objSwf._y = monsePos.y + 26;
			end
			self:Top();
		end
	end
end

function UILingLiHuiZhangTip:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end