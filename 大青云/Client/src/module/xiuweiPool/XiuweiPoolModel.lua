--[[
修为池
]]

_G.XiuweiPoolModel = Module:new();
XiuweiPoolModel.xiuwei 		= 0;
XiuweiPoolModel.accumulate 	= 0;
XiuweiPoolModel.refine_times = 0;
-- XiuweiPoolModel.itemid 		 = 0;
XiuweiPoolModel.killMonsterXiu 		 = 0;

function XiuweiPoolModel:SetXiuweiInfo(xiuwei,accumulate,refine_times)
	self.xiuwei 		= xiuwei;
	self.accumulate 	= accumulate;
	self.refine_times 	= refine_times;
end;

-- function XiuweiPoolModel:SetLianzhiItem(itemid)
	-- self.itemid 		= itemid;
-- end;

function XiuweiPoolModel:SetkillMonsterXiu(killMonsterXiu)
	-- WriteLog(LogType.Normal,true,'---------------------XiuweiPoolModel:SetkillMonsterXiu',killMonsterXiu)
	if killMonsterXiu>=50 and XiuweiPoolController:IsOpen() then
		UICurrencyFlyView:Show(enAttrType.eaZhenQi);
	end
	self.killMonsterXiu 		= killMonsterXiu;
	self:getAccumulate();
	self:GetXiuwei();
	self.killMonsterXiu	= 0;
	Notifier:sendNotification( NotifyConsts.XiuweiPoolUpdate );
	-- XiuweiPoolController:RepXiuweiInfo()
end;

-- 得到当前可用的修为值
function XiuweiPoolModel:GetXiuwei()
	self.xiuwei = self.xiuwei+self.killMonsterXiu
	-- if self.xiuwei>t_xiuwei[1].max_current or self.accumulate>=t_xiuwei[1].max_accumulate then
		-- print('=========================self.xiuwei,t_xiuwei[1].max_current',self.xiuwei,t_xiuwei[1].max_current)
		-- self.xiuwei = t_xiuwei[1].max_current
	-- elseif self.xiuwei<0 then
		-- print('=========================self.xiuwei',self.xiuwei)
		-- self.xiuwei = 0
	-- end
	-- WriteLog(LogType.Normal,true,'---------------------self.xiuwei,self.killMonsterXiu',self.xiuwei,self.killMonsterXiu)
	return self.xiuwei or 0;
end;

--得到当日累计的修为值
function XiuweiPoolModel:getAccumulate()
	-- self.accumulate = self.accumulate+self.killMonsterXiu
	-- if self.accumulate>t_xiuwei[1].max_accumulate then
		-- self.accumulate = t_xiuwei[1].max_accumulate
	-- elseif self.accumulate<0 then
		-- self.accumulate = 0
	-- end
	-- WriteLog(LogType.Normal,true,'---------------------self.accumulate,self.killMonsterXiu',self.accumulate,self.killMonsterXiu)
	return self.accumulate or 0;
end;

-- 得到今日炼制次数
function XiuweiPoolModel:GetRefineTimes()
	return self.refine_times or 0;
end;

-- 得到炼制的丹药物品ID
function XiuweiPoolModel:GetRefineItemid()
	return self.itemid or 0;
end;

--怪物死亡获得的修为值
function XiuweiPoolModel:GetkillMonsterXiu()
	
	return self.killMonsterXiu or 0;
end;