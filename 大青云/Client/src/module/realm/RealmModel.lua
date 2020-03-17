--[[RealmModel
zhangshuhui
2015年4月1日18:31:00
]]

_G.RealmModel = Module:new();

-- 境界等阶
RealmModel.realmOrder = 0;
-- 境界星级
RealmModel.realmStar = 0;
-- 星级进度
RealmModel.realmProgress = 0;
-- 免费灌注次数
RealmModel.freeNum = 0;
-- 进阶进度
RealmModel.breakProgress = 0;
--属性列表
RealmModel.attrlist = {};
-- 巩固列表
RealmModel.strenthenList = {};
-- 联手渡劫  礼金和元宝次数
RealmModel.JoinlyBreakLJNum = 0;
RealmModel.JoinlyBreakYBNum = 0;
-- 游戏内最高境界等级
RealmModel.OrderMaxInGame = 0;
-- 进阶时自动购买
RealmModel.autoBuy = false;
-- 境界巩固Id
RealmModel.chongId = 0;
-- 境界巩固进度
RealmModel.chongProgress = 0;
-- 当前选中境界
RealmModel.selectId = 1;
--属性丹喂养数量
RealmModel.pillNum = 0;

function RealmModel:GetLevel()
	return self.realmOrder;
end

-- 境界等阶
function RealmModel:GetRealmOrder()
	return self.realmOrder;
end
function RealmModel:SetRealmOrder(order)
	local levelUp = order - self.realmOrder;
	self.realmOrder = order;
	if levelUp > 0 then
		self:sendNotification( NotifyConsts.RealmBreakSuccess );
	end
	--
	MainPlayerModel.humanDetailInfo[enAttrType.eaRealmLvl] = order;
end

-- 境界星级
function RealmModel:GetRealmStar()
	return self.realmStar;
end
function RealmModel:SetRealmStar(star)
	self.realmStar = star;
end

-- 星级进度
function RealmModel:GetRealmProgress()
	return self.realmProgress;
end
function RealmModel:SetRealmProgress(progress)
	self.realmProgress = progress;
end

-- 进阶进度
function RealmModel:GetBreakProgress()
	return self.breakProgress;
end
function RealmModel:SetBreakProgress(progress, istween)
	local addnum = progress - self.breakProgress;
	self.breakProgress = progress;
	
	Notifier:sendNotification(NotifyConsts.RealmBreakProgress,{istween=istween,addnum=addnum});
end

-- 免费灌注次数
function RealmModel:GetFreeNum()
	return self.freeNum;
end
function RealmModel:SetFreeNum(num)
	self.freeNum = num;
end

-- 属性列表
function RealmModel:GetAttrList()
	return self.attrlist;
end
function RealmModel:SetAttrList(list)
	self.attrlist = list;
	
	Notifier:sendNotification(NotifyConsts.RealmProgress,{list=list});
end
--更新属性列表
function RealmModel:UpdateAttrList(list)
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
	
	Notifier:sendNotification(NotifyConsts.RealmProgress,{list=list});
end

-- 巩固列表
function RealmModel:GetStrenthenList()
	return self.strenthenList;
end
function RealmModel:SetStrenthenList(list)
	self.strenthenList = list;
end

-- 联手渡劫  礼金次数
function RealmModel:GetJoinlyBreakLJNum()
	return self.JoinlyBreakLJNum;
end
function RealmModel:SetJoinlyBreakLJNum(num)
	self.JoinlyBreakLJNum = num;
end

-- 联手渡劫  元宝次数
function RealmModel:GetJoinlyBreakYBNum()
	return self.JoinlyBreakYBNum;
end
function RealmModel:SetJoinlyBreakYBNum(num)
	self.JoinlyBreakYBNum = num;
end

-- 游戏内最高境界等级
function RealmModel:GetOrderMaxInGame()
	return self.OrderMaxInGame;
end
function RealmModel:SetOrderMaxInGame(order)
	self.OrderMaxInGame = order;
	
	Notifier:sendNotification(NotifyConsts.RealmMaxUpdate);
end

--设置灌注结果
function RealmModel:SetFlootInfo(order,progress)
	self.realmOrder = order;
	self.realmStar = 0;
	self.realmProgress = progress;
	--
	MainPlayerModel.humanDetailInfo[enAttrType.eaRealmLvl] = order;
end

-- 得到境界重id
function RealmModel:GetChongId()
	return self.chongId;
end
-- 设置境界重id
function RealmModel:SetChongId(Id)
	self.chongId = Id;
end

-- 得到境界巩固进度
function RealmModel:GetChongProgress()
	return self.chongProgress;
end
-- 设置境界巩固进度
function RealmModel:SetChongProgress(progress)
	self.chongProgress = progress;
	
	self:sendNotification( NotifyConsts.StrenthenUpdate,{isGongGu = true} );
end

-- 得到当前选中境界
function RealmModel:GetSelectId()
	return self.selectId;
end
-- 设置当前选中境界
function RealmModel:SetSelectId(Id)
	self.selectId = Id;
	self:sendNotification( NotifyConsts.RealmModelChange );
end
----------------------------------------- 属性丹 -------------------------------
function RealmModel:SetPillNum(num)
	self.pillNum = num;
	self:sendNotification(NotifyConsts.RealmSXDChanged);
end

function RealmModel:GetPillNum()
	return self.pillNum;
end