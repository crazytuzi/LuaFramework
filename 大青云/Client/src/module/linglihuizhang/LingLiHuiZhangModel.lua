--[[LingLiHuiZhangModel
zhangshuhui
2015年5月13日11:09:16
]]

_G.LingLiHuiZhangModel = Module:new();

--灵力徽章等阶
LingLiHuiZhangModel.huizhangOrder = 0;
--还有多少VIP免费灌注次数
LingLiHuiZhangModel.freenum = 0;
--属性列表
LingLiHuiZhangModel.attrlist = {};
--聚灵累计收益
LingLiHuiZhangModel.julingcount = 0;
--杀怪灵力
LingLiHuiZhangModel.killlinglinum = 0;

--是否是右下角提示打开的面板
LingLiHuiZhangModel.isitemguide = false;

--得到等阶
function LingLiHuiZhangModel:GetHuiZhangOrder()
	return HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
end
--设置等阶
function LingLiHuiZhangModel:SetHuiZhangOrder(order)
	self.huizhangOrder = order;
	
	Notifier:sendNotification(NotifyConsts.ZhuLingProgress,{list=nil});
end

--升阶
function LingLiHuiZhangModel:SetHuiZhangUpOrder(order)
	self.huizhangOrder = order;
	
	Notifier:sendNotification(NotifyConsts.ZhuLingProgress,{list=nil,isup=1});
end

--得到次数
function LingLiHuiZhangModel:GetFreeNum()
	return self.freenum;
end
--设置次数
function LingLiHuiZhangModel:SetFreeNum(num)
	self.freenum = num;
end

--得到属性列表
function LingLiHuiZhangModel:GetAttrList()
	return self.attrlist;
end
--设置属性列表
function LingLiHuiZhangModel:SetAttrList(list)
	self.attrlist = list;
end
--更新属性列表
function LingLiHuiZhangModel:UpdateAttrList(list)
	for i, voi in pairs( list ) do
		local isfind = false;
		for j ,voj in pairs( self.attrlist ) do
			if voi.type == voj.type then
				isfind = true;
				self.attrlist[j].val = voj.val + voi.val;
			end
		end
		
		if isfind == false then
			table.push(self.attrlist,voi);
		end
	end
	
	Notifier:sendNotification(NotifyConsts.ZhuLingProgress,{list=list});
end

--得到聚灵数量
function LingLiHuiZhangModel:GetJuLingCount()
	return self.julingcount;
end
--设置聚灵数量
function LingLiHuiZhangModel:SetJuLingCount(count)
	self.julingcount = count;
	
	Notifier:sendNotification(NotifyConsts.JuLingProgress);
end

--得到杀怪灵力
function LingLiHuiZhangModel:GetKillLingLiNum()
	return self.killlinglinum;
end
--设置杀怪灵力
function LingLiHuiZhangModel:SetKillLingLiNum(num)
	self.killlinglinum = num;
	
	Notifier:sendNotification(NotifyConsts.KillLingLiUpdate);
end

--得到是否是右下角提示打开的面板
function LingLiHuiZhangModel:GetIsItemGuide()
	return self.isitemguide;
end
--设置是否是右下角提示打开的面板
function LingLiHuiZhangModel:SetIsItemGuide(isitemguide)
	self.isitemguide = isitemguide;
end