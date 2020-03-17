--[[
	跨服擂台赛
	2015年10月12日, PM 08:15:41
]]

_G.UIInterContest = BaseUI:new('UIInterContest');
UIInterContest.leftX = 490
UIInterContest.rightX = 772
UIInterContest.currentSeason = -1

UIInterContest.line200 = {
	[1]=2001,[3]=2001,[5]=2005,[7]=2005,[9]=2009,[11]=2009,[13]=2013,[15]=2013,
	[17]=2017,[19]=2017,[21]=2021,[23]=2021,[25]=2025,[27]=2025,[29]=2029,[31]=2029,
	[2]=2002,[4]=2002,[6]=2006,[8]=2006,[10]=2010,[12]=2010,[14]=2014,[16]=2014,
	[18]=2018,[20]=2018,[22]=2022,[24]=2022,[26]=2026,[28]=2026,[30]=2030,[32]=2030,
}
UIInterContest.line300 = {
	[1]=3001,[3]=3001,[5]=3001,[7]=3001,[9]=3009,[11]=3009,[13]=3009,[15]=3009,
	[17]=3017,[19]=3017,[21]=3017,[23]=3017,[25]=3025,[27]=3025,[29]=3025,[31]=3025,
	[2]=3002,[4]=3002,[6]=3002,[8]=3002,[10]=3010,[12]=3010,[14]=3010,[16]=3010,
	[18]=3018,[20]=3018,[22]=3018,[24]=3018,[26]=3026,[28]=3026,[30]=3026,[32]=3026,
}

function UIInterContest:Create()
	self:AddSWF('interServerContestPanel.swf',true,nil);
end

function UIInterContest:OnLoaded(objSwf)
	objSwf.btnEnter.click = function()	
		SitController:ReqCancelSit()
		InterContestController:ReqEnterCrossArena()
	end
	objSwf.btnAward.click = function()
		-- FPrint('ooooooooooooooooooo')
		if not UIInterContestAward:IsShow() then
			UIInterContestAward:Show(1)		
		end
	end
	objSwf.btnXiazhu.click = function()
		-- FloatManager:AddNormal( StrConfig["interServiceDungeon76"]);
		-- return
		InterContestController:ReqCrossArenaXiaZhuInfo()	
		
		if UIInterContestGuwuDialog:IsShow() then
			UIInterContestGuwuDialog:Hide()
		end	
	end
	objSwf.btnGuwu.click = function()
		
		if not self:OnTime() then
			FloatManager:AddNormal( StrConfig['interServiceDungeon202'] )
			return
		end
		
		if InterContestModel.guwuflag == 0 then
			FloatManager:AddNormal( StrConfig['interServiceDungeon201'] )
			return
		end
		
		if UIInterContestGuwuDialog:IsShow() then
			UIInterContestGuwuDialog:UpdateInfo()
		else
			UIInterContestGuwuDialog:Show()
		end
		
		if UIInterContestGuwu:IsShow() then
			UIInterContestGuwu:Hide()
		end		
	end
	objSwf.btnGuwu.rollOver = function () TipsManager:ShowBtnTips(StrConfig['interServiceDungeon90'],TipsConsts.Dir_RightDown); end
	objSwf.btnGuwu.rollOut = function () TipsManager:Hide(); end
	objSwf.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['interServiceDungeon77'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function () TipsManager:Hide(); end
	-- objSwf.btnMyOp.click = function()
		-- InterContestController:ReqCrossArenaDuiShou()
	-- end
	objSwf.ddList.change = function(e) self:OnListChange(); end
	self:HideAllLine()	
end

function UIInterContest:OnTime()
	local weekConCfg = t_consts[178];
	local timeConCfg = t_consts[179];
	if not weekConCfg or not timeConCfg then
		return 
	end
	
	local weekNum = (CTimeFormat:toweekEx(GetServerTime()) + 1) % 7
	local weekCfg = split(weekConCfg.param,',');
	local inDay = false;
	for i , v in ipairs(weekCfg) do
		if toint(v) == weekNum then
			inDay = true;
			break
		end
	end
	if not inDay then
		return
	end
	
	local timeCfg = split(timeConCfg.param,'#');
	local starCfg = split(timeCfg[3],':');
	local endCfg = split(timeCfg[4],':');
	
	local starHour , starMin , starSec = toint(starCfg[1]) , toint(starCfg[2]) , toint(starCfg[3]);
	local endHour , endMin , endSec = toint(endCfg[1]) , toint(endCfg[2]) , toint(endCfg[3]);
	
	local year, month, day, hour, minute, second = CTimeFormat:todate(GetServerTime(),true);
	if hour >= starHour and hour <= endHour then
		if hour == endHour then
			if minute > endMin then
				return
			end
		end
		return true
	end
	return false
end

function UIInterContest:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	InterContestController:ReqCrossArenaInfo(InterContestModel.seasonid)
end


function UIInterContest:InitInfo()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	objSwf.btnEnter.disabled = true
	if InterContestModel.enterflag and InterContestModel.enterflag == 1 then
		objSwf.btnEnter.disabled = false
	end
	
	self:HideAllLine()	
	
	self:DrawLine()
	objSwf.ddList.dataProvider:cleanUp();
	-- FTrace(InterContestModel.seasonList, 'fffffffffffffffff')
	for i,vo in ipairs(InterContestModel.seasonList) do
		-- FPrint(vo)
		objSwf.ddList.dataProvider:push(vo);
	end
	
	local showNum = #InterContestModel.seasonList
	objSwf.ddList.rowCount = showNum
	
	local minSeason = InterContestModel.seasonListId[1]
	if self.currentSeason == -1 or self.currentSeason < minSeason then	
		local maxSeason = -1
		if InterContestModel.seasonListId[showNum] then
			maxSeason = InterContestModel.seasonListId[showNum]	
		end
		if maxSeason > -1 and self.currentSeason ~= maxSeason then
			self.currentSeason = maxSeason
		end
		objSwf.ddList.selectedIndex = showNum - 1
	end
end

function UIInterContest:OnListChange()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local seasonid = 0
	if InterContestModel.seasonListId[objSwf.ddList.selectedIndex+1] then
		seasonid = InterContestModel.seasonListId[objSwf.ddList.selectedIndex+1]
	end
	if seasonid == 0 or seasonid == self.currentSeason then return end
	self.currentSeason = seasonid
	InterContestController:ReqCrossArenaInfo(seasonid)
end

function UIInterContest:DrawLine()
	local objSwf = self.objSwf
	if not objSwf then return end

	local rankList = {}
	for k,v in ipairs (InterContestModel.rankList) do			
		local rankVO = {}
		rankVO.pos = v.id%1000
		rankVO.id = v.id
		rankVO.prof = v.prof
		rankVO.roleName = v.roleName
		local name = MainPlayerModel.humanDetailInfo.eaName;
		if rankVO.roleName == name then
			rankVO.roleName = "<font color='#00ff00'>" .. name .. " </font>";
		end
		table.push(rankList,UIData.encode(rankVO))		
	end
	if rankList then
		objSwf.rewardList.dataProvider:cleanUp();
		objSwf.rewardList.dataProvider:push(unpack(rankList));
		objSwf.rewardList:invalidateData();
		for k,v in pairs(InterContestModel.rankList) do
			if v.id >= 5000 then
				objSwf.mccontextScend._visible = true
				objSwf.mccontextFirst._visible = true
				if self:GetLine5000(v.pos) == 5002 then
					objSwf.mccontextFirst._x = UIInterContest.rightX
					objSwf.mccontextScend._x = UIInterContest.leftX
				else
					objSwf.mccontextFirst._x = UIInterContest.leftX
					objSwf.mccontextScend._x = UIInterContest.rightX					
				end
				self:ShowLine4000(v)
				self:ShowLine3000(v)
				self:ShowLine2000(v)
				self:ShowLine1000(v)
			elseif v.id >= 4000 then
				self:ShowLine4000(v)
				self:ShowLine3000(v)
				self:ShowLine2000(v)
				self:ShowLine1000(v)
			elseif v.id >= 3000 then
				self:ShowLine3000(v)
				self:ShowLine2000(v)
				self:ShowLine1000(v)
			elseif v.id >= 2000 then
				self:ShowLine2000(v)
				self:ShowLine1000(v)
			elseif v.id >= 1000 then
				self:ShowLine1000(v)
			end
		end
	end
end

function UIInterContest:ShowLine4000(v)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local lineIndex = self:GetLine4000(v.pos)
	if lineIndex then
		if lineIndex%2 == 0 then
			objSwf.txtrightname.text = v.roleName or ''
			if v.prof and v.prof >= 1 and v.prof <= 4 then
				objSwf.iconHeadtright.source = ResUtil:GetHeadIcon60(v.prof)							
			else		
				objSwf.iconHeadtright:unload()
				objSwf.iconHeadtright.source = nil
			end
		else
			objSwf.txtleftname.text = v.roleName or ''	
			if v.prof and v.prof >= 1 and v.prof <= 4 then
				objSwf.iconHeadleft.source = ResUtil:GetHeadIcon60(v.prof)	
			else
				objSwf.iconHeadleft:unload()
				objSwf.iconHeadleft.source = nil
			end
		end				
	end
	local line4 = objSwf['line'..self:GetLine4000(v.pos)]
	if line4 then line4._visible = true end
end
function UIInterContest:ShowLine3000(v)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local line8 = objSwf['line'..UIInterContest.line300[v.pos]]
	if line8 then line8._visible = true end
end
function UIInterContest:ShowLine2000(v)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local line16 = objSwf['line'..UIInterContest.line200[v.pos]]
	if line16 then line16._visible = true end
end
function UIInterContest:ShowLine1000(v)
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	local line32 = objSwf['line'..(1000+v.pos)]
	if line32 then line32._visible = true end
end

function UIInterContest:HideAllLine()	
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	objSwf.iconHeadleft:unload()
	objSwf.iconHeadtright:unload()
	objSwf.iconHeadleft.source = nil
	objSwf.iconHeadtright.source = nil
	objSwf.txtleftname.text = ''
	objSwf.txtrightname.text = ''
	objSwf.mccontextScend._visible = false
	objSwf.mccontextFirst._visible = false
	for i = 1,32 do
		local line32 = objSwf['line'..(1000 + i)]
		if line32 then line32._visible = false end
		local line16 = objSwf['line'..UIInterContest.line200[i]]
		if line16 then line16._visible = false end
		local line8 = objSwf['line'..UIInterContest.line300[i]]
		if line8 then line8._visible = false end
		local line4 = objSwf['line'..self:GetLine4000(i)]
		if line4 then line4._visible = false end
	end	
end

function UIInterContest:GetLine4000(index)
	if index%2 == 0 then
		if index >= 2 and index <= 16 then
			return 4002
		end
		if index >= 18 and index <= 32 then
			return 4018
		end
	else
		if index >= 1 and index <= 15 then
			return 4001
		end
		if index >= 17 and index <= 31 then
			return 4017
		end
	end
end

function UIInterContest:GetLine5000(index)
	if index%2 == 0 then
		return 5002
	else
		return 5001
	end
end

function UIInterContest:ListNotificationInterests()
	return {
		NotifyConsts.ISKuafuArenaRankInfo,
	}
end

function UIInterContest:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.ISKuafuArenaRankInfo then
		self:InitInfo()		
	end	
end


function UIInterContest:OnDelete()
	
end

function UIInterContest:OnHide()
	if UIInterContestAward:IsShow() then
		UIInterContestAward:Hide()	
	end	
	if UIInterContestGuwuDialog:IsShow() then
		UIInterContestGuwuDialog:Hide()	
	end
	if UIInterContestGuwu:IsShow() then
		UIInterContestGuwu:Hide()	
	end
	if UIInterContestZige:IsShow() then
		UIInterContestZige:Hide()	
	end		
end;

