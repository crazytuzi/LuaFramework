--[[
修为池
]]
_G.XiuweiPoolController = setmetatable({},{__index=IController})
XiuweiPoolController.name = "XiuweiPoolController";
XiuweiPoolController.firstValue = 0
XiuweiPoolController.curVal = 0

function XiuweiPoolController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_GetRefineDanYaoInfo,self,self.onGetRefineDanYaoInfo);
	MsgManager:RegisterCallBack(MsgType.SC_RefineDanYao,self,self.onRefineDanYaoResult);
end;

function XiuweiPoolController:onGetRefineDanYaoInfo(msg)
	XiuweiPoolModel:SetXiuweiInfo(msg.xiuwei,msg.accumulate,msg.refine_times)
	if self.firstValue==0 then
		self.firstValue = msg.xiuwei
	else 
		self.curVal = msg.xiuwei - self.firstValue
		--是否显示得到修为特效
		local cfg = t_xiuwei[1];
		if not cfg then 
			return 
		end;
		-- local IsShowEffect = curVal%cfg.effect_limit
		-- WriteLog(LogType.Normal,true,"============IsShowEffect curVal",IsShowEffect,curVal)
		if self.curVal>=cfg.effect_limit then
			self.firstValue = msg.xiuwei
			self.curVal = 0
			UIXiuweiEffectView:Show()
		end
	end
	Notifier:sendNotification(NotifyConsts.XiuweiPoolUpdate)
	RemindFuncTipsController:ExecRemindFunc(RemindFuncTipsConsts.RFTC_XiuWei);
end;

function XiuweiPoolController:onRefineDanYaoResult(msg)
	if msg.result == 0 then 
		local rewardStr = "";
		for i,itemVO in ipairs(msg.resultlist) do
			rewardStr = rewardStr .. itemVO.itemid..","..itemVO.itemnum;
			if i < #msg.resultlist then
				rewardStr = rewardStr .. "#";
			end
		end
		UIUseDan:Open(rewardStr)
		
		XiuweiPoolController:RepXiuweiInfo()
		Notifier:sendNotification( NotifyConsts.XiuweiPoolUpdate );
		-- if UIXiuweiPool:IsShow() then 
			-- UIXiuweiPool:PlyIcon();
		-- end;
	elseif msg.result == -3 then 
		--异常错误
		FloatManager:AddNormal(StrConfig["xiuweiPool12"])
	elseif msg.result == -2 then 
		--修为值不够
		FloatManager:AddNormal(StrConfig["xiuweiPool03"])
	elseif msg.result == -5 then 
		-- 背包格子不足
		FloatManager:AddNormal(StrConfig["xiuweiPool05"])
	elseif msg.result == -1 then 
		-- 炼制次数已达上限
		FloatManager:AddNormal(StrConfig["xiuweiPool04"])
	elseif msg.result == -4 then 
		-- 找不到这个物品
		FloatManager:AddNormal(StrConfig["xiuweiPool13"])
	elseif msg.result == -6 then 
		-- 找不到这个物品
		FloatManager:AddNormal(StrConfig["xiuweiPool14"])
	elseif msg.result == -7 then 
		-- 找不到这个物品
		FloatManager:AddNormal(StrConfig["xiuweiPool21"])
	end;
end;

----------------------------------------C to s
function XiuweiPoolController:RepXiuweiInfo()
	local msg = ReqGetRefineDanYaoInfoMsg:new();
	MsgManager:Send(msg)	
	--print("请求所有信息-0-------------")
end;

function XiuweiPoolController:ReqDanYaoInfo()
	local msg = ReqRefineDanYaoMsg:new()
	MsgManager:Send(msg)
	 --print("请求炼制丹药")
end;

--怪物死亡获得的修为值
function XiuweiPoolController:GetValMonsterDie(monster)
	-- WriteLog(LogType.Normal,true,'-----------------------怪物死亡获得的修为值')
	
	-- local monsterId = monster:GetMonsterId()
	-- WriteLog(LogType.Normal,true,'---------------------monsterId',monsterId)
	-- local monsterCfg = t_monster[monsterId]
	-- local levelCha = MainPlayerModel.humanDetailInfo.eaLevel - monsterCfg.level
	-- WriteLog(LogType.Normal,true,'---------------------levelCha',levelCha)
	-- if math.abs(levelCha)>t_xiuwei[1].lv_distance then
		-- return;
	-- end
	-- local killMonsterXiu =  t_xiuweipoint[monsterCfg.type].xiuwei
	-- WriteLog(LogType.Normal,true,'---------------------XiuweiPoolController:killMonsterXiu',killMonsterXiu)
	-- XiuweiPoolModel:SetkillMonsterXiu(killMonsterXiu)
	-- Notifier:sendNotification( NotifyConsts.XiuweiPoolUpdate );
	XiuweiPoolController:RepXiuweiInfo()
end;

function XiuweiPoolController:IsOpen()
	local openLevel = t_funcOpen[FuncConsts.XiuweiPool].open_level;	
	return MainPlayerModel.humanDetailInfo.eaLevel>=openLevel;
end