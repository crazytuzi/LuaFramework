--[[
帮派仓库申请列表
liyuan
]]

_G.UIUnionWareHouseApply = BaseUI:new("UIUnionWareHouseApply")

UIUnionWareHouseApply.curShowType = 0;
function UIUnionWareHouseApply:Create()
	self:AddSWF("unionWareApply.swf",nil,true)
end;

local autoList = {'帮众','精英','长老','副帮主','帮主'}
function UIUnionWareHouseApply:OnLoaded(objSwf)	
	objSwf.btnAllAgree.click = function() 
		-- 1-批准，2-拒绝, 3-撤销
		UnionController:ReqGuildQueryCheckOper(0, 1)
	end;	
	objSwf.btnAllReject.click = function() 
		UnionController:ReqGuildQueryCheckOper(0, 2)
	end;	
	-- 列表
	objSwf.infolist.handlertongyiClick = function(e) 
		local operid = e.item.operid
		if operid and operid > 0 then
			UnionController:ReqGuildQueryCheckOper(operid, 1)
		end
	end
	objSwf.infolist.handlerjujueClick = function(e) 
		if operid and operid > 0 then
			UnionController:ReqGuildQueryCheckOper(operid, 2)
		end
	end
	objSwf.infolist.handlerchexiaoClick = function(e) 
		if operid and operid > 0 then
			UnionController:ReqGuildQueryCheckOper(operid, 3)
		end
	end
	
	objSwf.infolist.itemRewardRollOut = function(e) TipsManager:Hide(); end
	objSwf.infolist.itemRewardRollOver = function(e)
		local itemId = e.item.itemId
		if itemId and itemId > 0 then
			TipsManager:ShowItemTips(itemId);
		end
	end
	
	-- checkbox
	objSwf.checkAuto.click = function(e) 
		local lvAuto = objSwf.ddList.selectedIndex+1
		if objSwf.checkAuto.selected then 
			UnionController:ReqGuildSetAutoCheck(lvAuto)
		else
			UnionController:ReqGuildSetAutoCheck(0)
		end
	end
	
	-- 下拉框
	objSwf.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(autoList) do
		objSwf.ddList.dataProvider:push(vo);
	end
	objSwf.ddList.change = function(e) self:OnLevelChange(); end
	objSwf.ddList.rowCount = 5;
	objSwf.ddList.selectedIndex = 0
end;

function UIUnionWareHouseApply:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return; end
	UnionController:ReqGuildQueryCheckList() -- 请求协议		
	
	
end;

function UIUnionWareHouseApply:OnLevelChange()
	local objSwf = self.objSwf
	if not objSwf then return; end

	local lvAuto = objSwf.ddList.selectedIndex+1
	if objSwf.checkAuto.selected then 
		UnionController:ReqGuildSetAutoCheck(lvAuto)
	end
end

function UIUnionWareHouseApply:OnHide()

end;

function UIUnionWareHouseApply:ShowInfoList(applyData)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if applyData.pos and applyData.pos > 0 then
		objSwf.checkAuto.selected = true
		objSwf.ddList.selectedIndex = applyData.pos - 1
	else
		objSwf.checkAuto.selected = false
	end
	
	local list = applyData.list
	local listvo = {};
	for i,info in ipairs(list) do 
		local vo ={};
		vo.operid = info.operid
		vo.playerid = info.playerid
		vo.pos = info.pos
		vo.playerName = info.playerName
		vo.validtime = self:GetRemainTime(info.validtime - _G.GetServerTime())	
		
		vo.btnChexiao = 0
		vo.btnShenhe = 0
		vo.itemId = info.itemId or 0
		if info.playerid == MainPlayerController:GetRoleID() then
			--操作自己
			vo.btnChexiao = 1
		else
			if self:GetPermission() then
				vo.btnShenhe = 1
			end
		end
		
		local rewardSlotVO = RewardSlotVO:new();
		rewardSlotVO.id = info.itemId or 0
		rewardSlotVO.count = info.itemNum or 1
		-- rewardSlotVO.bind = itemCfg.bind ;
		local item1Str = UIData.encode(vo1) .. '*' .. rewardSlotVO:GetUIData()
		
		table.push(listvo,item1Str)				
	end;
	objSwf.infolist.dataProvider:cleanUp();
	objSwf.infolist.dataProvider:push(unpack(listvo));
	objSwf.infolist:invalidateData();
	-- objSwf.scrollbar.position = 0;
	
	applyData = nil
end;

function UIUnionWareHouseApply:GetRemainTime(remainTime)
	local day,hour,min1,sec = CTimeFormat:sec2formatEx(toint(remainTime))-- 剩余时间
	local resStr = ''
	if not hour then hour = 0 end
	if not min1 then min1 = 0 end
	if not sec then sec = 0 end
	resStr = string.format(StrConfig['union77'], hour,min1,sec)	
	return resStr
end
--------------------------Notification
function UIUnionWareHouseApply:ListNotificationInterests()
	return {
			NotifyConsts.GuildQueryCheckList,
			};
end
function UIUnionWareHouseApply:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.GuildQueryCheckList then 
		self:ShowInfoList(body.applyData);
	end;
end;

-- 帮派仓库审批权限
function UIUnionWareHouseApply:GetPermission()
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	-- 帮派仓库审批权限
	if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.bankApprove) == 1 then
		return true
	else
		return false
	end
end
