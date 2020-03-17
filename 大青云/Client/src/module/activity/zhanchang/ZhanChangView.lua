--[[
战场
wangshuai
]]


_G.UIZhanChang = BaseUI:new("UIZhanChang");

UIZhanChang.curpaneindex = 0;

function UIZhanChang:Create()
	self:AddSWF("zhanchangPanel.swf",true,"center");
	self:AddChild(UIZhanChangMap,"map")
end

function UIZhanChang:OnLoaded(objSwf,name)
	self:GetChild("map"):SetContainer(objSwf.childPanel)
	objSwf.AllInfoPanel.hitTestDisable = true;
	--objSwf.info.click = function () self:ShowPanel()end;
	objSwf.showpanel.click = function() self:CloseCurPanel()end;

	objSwf.panel.OutZhanchang.click = function() self:OutzhanchangClick()end;
	objSwf.panel.zc_info.click = function () self:ShowMyInfo()end;
	objSwf.panel.zc_chux.click = function () self:ShowShixueInfo()end;
	objSwf.panel.zc_gongx.click = function () self:ShowGongxInfo()end; 
	objSwf.panel.zc_jisha.click = function () self:ShowLianxujisha()end;
	objSwf.panel.myinfopp.deinfo.click = function () self:ShowAllInfoPanel()end;
	objSwf.AllInfoPanel.closeBtn.click = function() self:ShowInfoPanel()end;

	--详细信息榜单
	objSwf.AllInfoPanel.zonglan.click = function() self:ShowZonglanlist()end;
	objSwf.AllInfoPanel.Azonlan.click = function() self:ShowAzonglanList()end;
	objSwf.AllInfoPanel.Bzonlan.click = function() self:ShowBzonglanList()end;

	objSwf.entermap.click = function() self:ShowMapbtn() end;

	objSwf.btnRule.rollOver = function() self:ShowRule() end;
	objSwf.btnRule.rollOut = function() TipsManager:Hide() end;

	--  宝箱tips
	objSwf.panel.gongxianPanel.gongxianlist.rewardRollOut = function() TipsManager:Hide()end;
	objSwf.panel.shixuePanel.sshixuelist.rewardRollOut = function() TipsManager:Hide() end;
	objSwf.panel.lianxuMaxNumpanle.lianxuMaxlist.rewardRollOut = function() TipsManager:Hide() end;


	objSwf.panel.gongxianPanel.gongxianlist.rewardRollOver = function(e) self:RewardRollOver(e,"a") end;
	objSwf.panel.shixuePanel.sshixuelist.rewardRollOver = function(e) self:RewardRollOver(e,"b") end;
	objSwf.panel.lianxuMaxNumpanle.lianxuMaxlist.rewardRollOver = function(e) self:RewardRollOver(e,"c") end;

	for i=1,3 do
		objSwf.panel.detailedInfo["lookpath"..i].click = function() self:OnAutoPath(i) end;
		objSwf.panel.detailedInfo["lookpath"..i].rollOver = function() self:ShowLookPathOver(i) end;
		objSwf.panel.detailedInfo["lookpath"..i].rollOut = function() TipsManager:Hide() end;

		objSwf.panel.detailedInfo["flage"..i].rollOver = function() self:ShowflagePathOver(i) end;
		objSwf.panel.detailedInfo["flage"..i].rollOut = function() TipsManager:Hide() end;

	end;
end;

function UIZhanChang:ShowflagePathOver(i)
	if i == 1 or i == 2 then 
		TipsManager:ShowBtnTips(StrConfig["zhanchang122"]);
	elseif i == 3 then 
		TipsManager:ShowBtnTips(StrConfig["zhanchang124"]);
	end;
end;

function UIZhanChang:ShowLookPathOver(i)
	if i == 3 then 
		if self.tFlagState ~= 0 then 
			TipsManager:ShowBtnTips(StrConfig["zhanchang125"]);
		else
			TipsManager:ShowBtnTips(StrConfig["zhanchang411"]);
		end;
		return
	end;
	TipsManager:ShowBtnTips(StrConfig["zhanchang125"]);
end;

function UIZhanChang:CloseCurPanel()
	self:Hide();
	UIZhanChErjiView:Show();
end;

function UIZhanChang:OnAutoPath(i)
	local myCamp = ActivityZhanChang:GetMyCamp(); 
	if i == 1 then  -- 北部
		local cfg = ZhChFlagConfig[toint(myCamp..i)]
		ZhChFlagController:OnFlagMouseClick(cfg)
	elseif i == 2 then  -- 南部
		local cfg = ZhChFlagConfig[toint(myCamp..i)]
		ZhChFlagController:OnFlagMouseClick(cfg)
	elseif i == 3 then -- 特殊
		local flagState = ActivityZhanChang:GetFlagEnemyState();
		local id = 1;
		for i,info in ipairs(flagState) do 
			if info.idx < 10 then 
				if info.canPick == 1 then 
					id = info.idx;
				end;
			end;
		end;
		local cfg = ZhChFlagConfig[toint(id)]
		if cfg.camp == 0 then cfg.camp = myCamp end;
		if self.tFlagState == 0 then 
			local cfg = ZhChMonsterPoint[10 + id];
			local mapid = CPlayerMap:GetCurMapID();
			MainPlayerController:DoAutoRun(mapid,_Vector3.new(cfg.x,cfg.y,0),function()
				AutoBattleController:OpenAutoBattle();
			end);
			return
		end
		ZhChFlagController:OnFlagMouseClick(cfg)
	end;
end;


function UIZhanChang:ShowRule()
	TipsManager:ShowBtnTips(StrConfig["zhanchang127"]);
end;

function UIZhanChang:RewardRollOver(e,type)
	local rank = e.item.rank;
	if rank == "a" then 
		rank = 1;
	elseif rank == "b" then 
		rank = 2;
	elseif rank == "c" then 
		rank = 3;
	end;
	local serverlvl = MainPlayerController:GetServerLvl();
	if type == "a" then 
		-- 贡献
		local rewardid = self:GetRewardId(serverlvl,rank,"contri");
		local itemvo = RewardSlotVO:new();
		itemvo.id = tonumber(rewardid);
		itemvo.count = 1;
		local tips = itemvo:GetTipsInfo();
		TipsManager:ShowTips(tips.tipsType,tips.info,tips.tipsShowType)
	elseif type == "b" then 
		-- 噬血
		local rewardidc = self:GetRewardId(serverlvl,rank,"kill")
		local itemvo = RewardSlotVO:new();
		itemvo.id = tonumber(rewardidc);
		itemvo.count = 1;
		local tips = itemvo:GetTipsInfo();
		TipsManager:ShowTips(tips.tipsType,tips.info,tips.tipsShowType)
	elseif type == "c" then 
		-- 连续打击
	end;
end;

function UIZhanChang:GetRewardId(serverlvl,rank,type)
	local str = t_campAward[serverlvl][type];
	return str[rank]
end;
function UIZhanChang:ShowMapbtn() 
	local objSwf = self.objSwf;
	
	if UIZhchRewardInsterction:IsShow() then 
		UIZhchRewardInsterction:Hide();
	else
		UIZhchRewardInsterction:Show();
	end;
end;
-- 面板 附带资源
function UIZhanChang:WithRes()
	return { "ZhanchangMapPanel.swf" };
end;

function UIZhanChang:OnShow()
	local  objSwf = self.objSwf;
	objSwf.AllInfoPanel._visible = false;
	--向服务器请求  总览信息w
	ActivityZhanChang : ReqZhancRank()
	UIZhanChang:ShowMyInfo()
	UIZhanChang:HideMySkInfo()
	-- 显示地图
	self:ShowMap()
	UIZhanChang:ShowTimerFun("00","30","00")
	UIZhanChang:updataSourceTime("00",'00')

end
--显示战场倒计时
function UIZhanChang:ShowTimerFun(t,s,m)
	if not self.bShowState then return; end  -- 关闭等于False
	local objSwf = self.objSwf;
	objSwf.timer.text = string.format(StrConfig["zhanchang116"],t,s,m);
end;

function UIZhanChang:ShowMap()
	local child = self:GetChild("map");
	if not child then print("被弹出了")return end;
	self:ShowChild("map")
end;
--AB 总览list 
function UIZhanChang:ShowZonglanlist()
	local objSwf = self.objSwf.AllInfoPanel
	local listc = ActivityZhanChang.zcGeneral; -- 总榜单list
	--trace(listc)
	--print("总览list   ")
	local voc = {}
	for i,info in ipairs(listc) do 
		--print("总览list数据")
		local vo = {};
		vo.conrl = info.contr;
		if i == 1 then 
			vo.rank = "a";
		elseif i == 2 then 
			vo.rank = "b";
		elseif i == 3 then 
			vo.rank = "c";
		else
			vo.rank = i;
		end;
		vo.camp = info.camp;
		vo.name = info.roleName;
		vo.addNum = info.addnum;
		vo.lianxuNum = info.contnum;
		table.push(voc,UIData.encode(vo))
	end;

	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(voc));
	objSwf.list:invalidateData();
	self.curpaneindex = 1;
end;
-- A 总览list
function UIZhanChang:ShowAzonglanList()
	local objSwf = self.objSwf.AllInfoPanel
	local listc = ActivityZhanChang.zcGeneralList[1]  -- 6方总览
	-- trace(listc)
	-- print("A 总览list   ")
	if not listc then listc = {} end;
	--print(#listc,"A方总览长度")
	local voc = {};
	for i,info in ipairs(listc) do 
		local vo = {};
		vo.conrl = info.contr;
		if i == 1 then 
			vo.rank = "a";
		elseif i == 2 then 
			vo.rank = "b";
		elseif i == 3 then 
			vo.rank = "c";
		else
			vo.rank = i;
		end;
		vo.camp = info.camp
		vo.name = info.roleName;
		vo.addNum = info.addnum;
		vo.lianxuNum = info.contnum;
		table.push(voc,UIData.encode(vo))
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(voc));
	objSwf.list:invalidateData();
	self.curpaneindex = 2;
end;
-- B 总览list
function UIZhanChang:ShowBzonglanList()
	local objSwf = self.objSwf.AllInfoPanel
	local listc = ActivityZhanChang.zcGeneralList[2] -- 7 方总览
	-- trace(listc)
	-- print("B 总览list   ")
	if not listc then listc = {} end;
	local voc = {};
	for i,info in ipairs(listc) do 
		local vo = {};
		vo.conrl = info.contr;
		if i == 1 then 
			vo.rank = "a";
		elseif i == 2 then 
			vo.rank = "b";
		elseif i == 3 then 
			vo.rank = "c";
		else
			vo.rank = i;
		end;
		vo.name = info.roleName;
		vo.addNum = info.addnum;
		vo.lianxuNum = info.contnum;
		table.push(voc,UIData.encode(vo))
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(voc));
	objSwf.list:invalidateData();
	self.curpaneindex = 3;
end;

function UIZhanChang:updataSourceTime(s,m)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local time = ActivityZhanChang.zcInfoVo.sourceTime;
	local flagState = ActivityZhanChang:GetFlagEnemyState();
	local cfg = ActivityZhanChang.zcInfoVo;


	local nFlagState = 0; -- 1可以采集，，0等待刷新 2 在路上
	local bFlagState = 0;
	self.tFlagState = 0;

	for i,info in  ipairs(flagState)do 
		if toint(info.idx) < 10 then  -- 特殊旗子
			if self.tFlagState == 0 then 
				self.tFlagState = info.canPick
			end
		else -- 普通战旗
			local id = toint(info.idx) % 10;
			if id == 1 then 
				bFlagState = info.canPick;
			elseif id == 2 then 
				nFlagState = info.canPick;
			end
			if info.canPick == 1 then  -- 可以采集
				if id == 1 then  -- 北战旗
					bFlagState = 1;
				elseif id == 2 then -- 南战旗
					nFlagState = 1;
				end;
			elseif info.canPick == 0 then -- 不可以采集
				if id == 1 then  -- 北战旗
					bFlagState = 0;
				elseif id == 2 then -- 南战旗
					nFlagState = 0;
				end;
			elseif info.canPick == 2 then  -- 在路上
				if id == 1 then  -- 北战旗
					bFlagState = 2
				elseif id == 2 then -- 南战旗
					nFlagState = 2;
				end;	
			end;
		end;
	end;
	if nFlagState ~= 0 then 
		objSwf.panel.detailedInfo.resTimeN.htmlText = StrConfig["zhanchang31"..nFlagState]
	else
		objSwf.panel.detailedInfo.resTimeN.htmlText = string.format(StrConfig["zhanchang310"],s,m)
	end
	
	if bFlagState ~= 0 then 
		objSwf.panel.detailedInfo.resTimeB.htmlText = StrConfig["zhanchang31"..bFlagState]
	else 
		objSwf.panel.detailedInfo.resTimeB.htmlText = string.format(StrConfig["zhanchang310"],s,m)
	end;
	
	if self.tFlagState ~= 0 then 
		objSwf.panel.detailedInfo.xinshiNum.htmlText = StrConfig["zhanchang31"..self.tFlagState]
	else
		objSwf.panel.detailedInfo.xinshiNum.htmlText = string.format(StrConfig["zhanchang410"],cfg.num)
	end;
	--print(s,m,"uiSenter")
	--objSwf.panel.detailedInfo.resTime.text = string.format(StrConfig["zhanchang103"],s,m);
end;
function UIZhanChang:GetId()
	return 3;
end;
--显示所有信息排行
function UIZhanChang:ShowAllInfoPanel()
	--向服务器请求  总览信息
	ActivityZhanChang : ReqZhancRank()
	self.curpaneindex = 1;
	local objSwf = self.objSwf;
	self.objSwf.AllInfoPanel.hitTestDisable = false;
	self.objSwf.AllInfoPanel._visible = true;
	--显示总战场信息
	objSwf.AllInfoPanel.zonglan.selected = true;
	--self:ShowZonglanlist();
end;
--关闭所有信息排行
function UIZhanChang:ShowInfoPanel()
	self.objSwf.AllInfoPanel.hitTestDisable = true;
	self.objSwf.AllInfoPanel._visible = false;
end;
--显示panel
function UIZhanChang:ShowPanel()
	local objSwf = self.objSwf;
	objSwf.panel._visible = not objSwf.panel._visible;
end;

 -- buttonGroup
-- 显示详细信息
function UIZhanChang:ShowMyInfo()
	-- detailedInfo 需要显示详细信息  隐藏，嗜血，排行
	local objSwf = self.objSwf.panel;

	objSwf.zc_info.selected = true;

	objSwf.detailedInfo._visible = true;
	objSwf.shixuePanel._visible = false;
	objSwf.gongxianPanel._visible = false;
	objSwf.lianxuMaxNumpanle._visible = false;

	-- 设置数据
	self:SetMyInfoPanel()
		--关闭我的信息
	self:HideMySkInfo()
end;


-- 显示嗜血
function UIZhanChang:ShowShixueInfo()
	local objSwf = self.objSwf.panel;
	objSwf.detailedInfo._visible = false;
	objSwf.shixuePanel._visible = true;
	objSwf.gongxianPanel._visible = false;
	objSwf.lianxuMaxNumpanle._visible = false;
	objSwf.zc_info.selected = false;


	self:ShiXueRnakShow();
	-- 显示我的战斗信息
	self:ShowMySkInfo();
end;
-- 显示连续击杀
function UIZhanChang:ShowLianxujisha()
	--print("显示连续击杀")
	local objSwf = self.objSwf.panel;
	objSwf.detailedInfo._visible = false;
	objSwf.shixuePanel._visible = false;
	objSwf.gongxianPanel._visible = false;
	objSwf.lianxuMaxNumpanle._visible = true;
	objSwf.zc_info.selected = false;

	self:setlianxuJishaList();
	-- 显示我的战斗信息
	self:ShowMySkInfo();

end;
function UIZhanChang:setlianxuJishaList()
	local objSwf = self.objSwf.panel.lianxuMaxNumpanle
	local list = ActivityZhanChang.zclianxuMaxNum;
	local voc = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.name = info.roleName;
		if i == 1 then 
			vo.rank = "a";
		elseif i == 2 then 
			vo.rank = "b";
		elseif i == 3 then 
			vo.rank = "c";
		else
			vo.rank = i;
		end;
		vo.camp = info.camp;
		vo.addNum = info.Addnum;
		vo.btnvisi = false;
		table.push(voc,UIData.encode(vo))
	end;

	objSwf.lianxuMaxlist.dataProvider:cleanUp();
	objSwf.lianxuMaxlist.dataProvider:push(unpack(voc));
	objSwf.lianxuMaxlist:invalidateData();

end;
-- 显示贡献
function UIZhanChang:ShowGongxInfo()
	local objSwf = self.objSwf.panel;
	objSwf.detailedInfo._visible = false;
	objSwf.shixuePanel._visible = false;
	objSwf.gongxianPanel._visible = true;
	objSwf.lianxuMaxNumpanle._visible = false;
	objSwf.zc_info.selected = false;
	self:GongxianRankShow();
	-- 显示我的战斗信息
	self:ShowMySkInfo();
end;

UIZhanChang.ErjiPanelList = {};

--退出战场
function UIZhanChang:OutzhanchangClick()

	local okfun = function() self:OkOutZhanchang() end;
	local nofun = function() end;
	local id = UIConfirm:Open(string.format(StrConfig["zhanchang104"]),okfun,nofun)
	table.push(self.ErjiPanelList,id)
end;
function UIZhanChang:OkOutZhanchang()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	ActivityController:QuitActivity(activity:GetId());
	ZhChFlagController:EscMap()
end;

function UIZhanChang:SetMyInfoPanel()
	local objSwf = self.objSwf.panel.detailedInfo;
	local cfg = ActivityZhanChang.zcInfoVo;
	--objSwf.xinshiNum.text = cfg.num;
	--trace(cfg)
	--print("信息更新-~~~~~~~~~~~~UI")
	objSwf.scoreA.num = cfg.scoreA;
	objSwf.scoreB.num = cfg.scoreB;
end;

--  总榜单数据
function UIZhanChang:AllRankShow()
	local list = ActivityZhanChang.allRank
end;
-- 嗜血榜单
function UIZhanChang:ShiXueRnakShow()
	local objSwf = self.objSwf.panel.shixuePanel;	
	--print("刷新噬血榜")
	local list = ActivityZhanChang.zcSkllList
	local vo = {};
	for i,info in ipairs(list) do 
		local xvo = {};
		if i == 1 then 
			xvo.rank = "a";
		elseif i == 2 then 
			xvo.rank = "b";
		elseif i == 3 then 
			xvo.rank = "c";
		else
			xvo.rank = i;
		end;
		xvo.name = info.roleName;
		xvo.camp = info.camp;
		xvo.addNum = info.addnum;
		xvo.lianxuNum = info.contnum;
		table.push(vo,UIData.encode(xvo));
	end;

	objSwf.sshixuelist.dataProvider:cleanUp();
	objSwf.sshixuelist.dataProvider:push(unpack(vo));
	objSwf.sshixuelist:invalidateData();
end;
-- 贡献榜单
function UIZhanChang:GongxianRankShow()
	--print("显示贡献榜")
	local objSwf = self.objSwf.panel.gongxianPanel
	local list = ActivityZhanChang.zcContrList;
	local vo = {};
	for i,info in ipairs(list) do 
		local xvo = {};
		if i == 1 then 
			xvo.rank = "a";
		elseif i == 2 then 
			xvo.rank = "b";
		elseif i == 3 then 
			xvo.rank = "c";
		else
			xvo.rank = i;
		end;
		xvo.camp = info.camp;
		xvo.addNum = info.contr;
		xvo.name = info.roleName;
		table.push(vo,UIData.encode(xvo));
	end;
	objSwf.gongxianlist.dataProvider:cleanUp();
	objSwf.gongxianlist.dataProvider:push(unpack(vo));
	objSwf.gongxianlist:invalidateData();
end;
-- 我方总览
function UIZhanChang:ATeamShow()
	local list = ActivityZhanChang.ourRank
end;
-- 敌方总览
function UIZhanChang:BTeamShow()
	local list = ActivityZhanChang.otherRanl
end;

-- 显示我的战斗信息
function UIZhanChang:ShowMySkInfo()
	local objSwf = self.objSwf


	if objSwf.panel.zc_info.selected == true then 
		return ;
	end;
	local objSwf = self.objSwf.panel;
	objSwf.myinfopp._visible = true;
	local vo  = ActivityZhanChang.zcInfoVo;
	objSwf.myinfopp.myContr.text = vo.contr;
	objSwf.myinfopp.myleis.text = vo.addnum;
	objSwf.myinfopp.mylxs.text = vo.contnum;

	local zlobjSwf = self.objSwf.AllInfoPanel;
	zlobjSwf.myContr.text = vo.contr;
	zlobjSwf.myleis.text = vo.addnum;
	zlobjSwf.mylxs.text = vo.contnum;
end

function UIZhanChang:HideMySkInfo()
	local objSwf = self.objSwf.panel;
	objSwf.myinfopp._visible = false;
end;

function UIZhanChang:GetWidth()
 	return 1017
end;
function UIZhanChang:GetHeight()
	return 411
end;

function UIZhanChang:OnHide()
	for i,info in pairs(self.ErjiPanelList) do 
		UIConfirm:Close(info)
	end;
end;
