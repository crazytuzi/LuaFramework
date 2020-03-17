--[[ 
帮派王城战右侧界面
wangshuai
]]
_G.UIUnionWarCityRight = BaseUI:new("UIUnionWarCityRight");

UIUnionWarCityRight.jianzhuwu = {"qinglong","baihu","zhuque","xuanwu","wangzuo"}
function UIUnionWarCityRight:Create()
	self:AddSWF("unionCityWar.swf",true,"center")
	self:AddChild(UIUnionCityWarMap,"map")
end;

function UIUnionWarCityRight:OnLoaded(objSwf)
	self:GetChild("map"):SetContainer(objSwf.childPanel)
	local tjpanel = objSwf.tongji;

	for i=1,5 do 
		tjpanel["btn_jianzhu"..i].rollOver = function() self:Overtextjianzhuwu(i)end;
		tjpanel["btn_jianzhu"..i].rollOut  = function() TipsManager:Hide() end;
		tjpanel["path_"..i].click = function() self:btnAutoPath(i)end;

	end;
	objSwf.OutZhanchang.click = function() self:OutCityWar() end;
 
	objSwf.tab_tongji.click = function() self:HideJishaPenel() end;
	objSwf.tab_jisha.click  = function() self:HideTongjiPanle() end;
	objSwf.btnRule.rollOver = function() self:RuleOver() end;
	objSwf.btnRule.rollOut = function()  TipsManager:Hide()  end;
	objSwf.mapclick.click = function() self:OnShowOrHideMap()end;
end;

function UIUnionWarCityRight:OnShowOrHideMap()
	if UIUnionCityWarMap:IsShow() then 
		UIUnionCityWarMap:Hide();
	else
		UIUnionCityWarMap:Show();
	end;
end;

function UIUnionWarCityRight:RuleOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["union405"]));
end;

function UIUnionWarCityRight:OnShow()
	self:HideJishaPenel();
	-- 获取时间
	self:SetCurLastTimer();
	self:ShowMap();
end;

function UIUnionWarCityRight:ShowMap()
	local child = self:GetChild("map");
	if not child then return end;
	self:ShowChild("map")
end;
function UIUnionWarCityRight:HideMap()
	if UIUnionCityWarMap:IsShow() then 
		UIUnionCityWarMap:Hide();
	end;
end;


function UIUnionWarCityRight:OutCityWar()
	self:Hide();
	UnionCityWarController:Outwar()
end;

function UIUnionWarCityRight:OnHide()

end;
function UIUnionWarCityRight:SetCurLastTimer()
	if not UnionCityWarModel.cityWarinfo.time then return end;
	local time = UnionCityWarModel.cityWarinfo.time;
	local txt = UnionCityWarModel:GetTime(time)
	local objSwf =self.objSwf;
	if not objSwf then return end;
	objSwf.time.text = txt;
end;
-- panel操作
function UIUnionWarCityRight:ShowTongjiPanle()
	local objSwf = self.objSwf.tongji;
	-- 刷新数据
	local warinfo = UnionCityWarModel.cityWarinfo;
	if warinfo.mytype == 1 then 
		objSwf.fangshou._visible = false;
		objSwf.jinggong._visible = true;
		objSwf.desc.text = StrConfig["unioncitywar805"]
	else 
		objSwf.fangshou._visible = true;
		objSwf.jinggong._visible = false;
		objSwf.desc.text = StrConfig["unioncitywar804"]
	end;
	-- trace(warinfo)
	-- print("战场信息")
	objSwf.ProSoulValue.maximum = warinfo.superMaxHp;
	objSwf.ProSoulValue.value = warinfo.superHp;
	
	local namelist = UnionCityWarModel.citySuperState;
	for i,info in ipairs(namelist) do 
		if not objSwf["txt_"..i] then break end;
		objSwf["txt_"..i].text = info.unionName;
		objSwf["di_"..i]:SetState(info.state)
	end;
end;

function UIUnionWarCityRight:HideTongjiPanle()
	local objSwf = self.objSwf;
	objSwf.tongji._visible = false;
	objSwf.jishapanel._visible = true;
	objSwf.tab_jisha.selected = true;
	self:ShowJishaPenel();
end;

function UIUnionWarCityRight:ShowJishaPenel()
	local objSwf = self.objSwf;
	-- 刷新数据
--	print("刷新击杀数据")
	local list = UnionCityWarModel.cityWarRoleJishaList;
	-- trace(list)
	-- print("刷新击杀数据")
	local endvo = {};
	for i,info in ipairs(list) do 
		 local vo = {};
		 vo.name = info.roleName;
		 vo.addNum = info.jisha;
		 if info.rank == 1 then 
		 	vo.rank = "a";
		 elseif info.rank == 2 then 
		 	vo.rank = "b"
		 elseif info.rank == 3 then 
		 	vo.rank = "c"
		 else
		 	vo.rank = info.rank;
		 end;
		 vo.camp = info.type+5;
		 table.push(endvo,UIData.encode(vo))
	end;
	objSwf.jishapanel.list.dataProvider:cleanUp();
	objSwf.jishapanel.list.dataProvider:push(unpack(endvo));
	objSwf.jishapanel.list:invalidateData();

	local myuid = MainPlayerController:GetRoleID()
--	print(myuid)
	local myinfo = UnionCityWarModel:GetRoleInfo(myuid)
	if not  myinfo then return end;
	local roleid = MainPlayerController:GetRoleID()
	objSwf.jishapanel.myjisha.text = myinfo.jisha;
	objSwf.jishapanel.myrank.text = myinfo.rank
end;

function UIUnionWarCityRight:HideJishaPenel()
	local objSwf = self.objSwf;
	objSwf.jishapanel._visible = false;
	objSwf.tongji._visible = true;
	objSwf.tab_tongji.selected = true;
	self:ShowTongjiPanle();
end;
 
----------------建筑物寻路       1114120_1425887764
function UIUnionWarCityRight:btnAutoPath(i)

	self:LookPathFun(i)
end;

function UIUnionWarCityRight:LookPathFun(type)
	local cfgPoint = unionCityWarbuilding;
	local posX,posY = cfgPoint[type].x,cfgPoint[type].y;
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(CPlayerMap:GetCurMapID(),_Vector3.new(posX,posY,0),completeFuc);
end;
--文本移入tips
function UIUnionWarCityRight:Overtextjianzhuwu(i)
	local cfg = UnionCityWarModel.citySuperState;
	if i == 1 then 
		-- qinglong
		TipsManager:ShowBtnTips(string.format(StrConfig["unioncitywar807"],cfg[i].unionName));
	elseif i == 2 then 
		-- baihu
		TipsManager:ShowBtnTips(string.format(StrConfig["unioncitywar808"],cfg[i].unionName));
	elseif i == 3 then 
		-- xuanwu
		TipsManager:ShowBtnTips(string.format(StrConfig["unioncitywar809"],cfg[i].unionName));
	elseif i == 4 then
		-- zhuque 
		TipsManager:ShowBtnTips(string.format(StrConfig["unioncitywar810"],cfg[i].unionName));
	elseif i == 5 then 
		-- wangzuo
		TipsManager:ShowBtnTips(string.format(StrConfig["unioncitywar822"]));
	end;
end;


function UIUnionWarCityRight:GetWidth()
	return 358
end;
function UIUnionWarCityRight:GetHeight()
	return 460
end;

	-- notifaction
function UIUnionWarCityRight:ListNotificationInterests()
	return {
		NotifyConsts.CityUnionWarResult,
		NotifyConsts.CityUnionWarJishaListUpdata,
		NotifyConsts.CityUnionWarAllInfoUpdata,
		NotifyConsts.CityUnionWarSuperState,
		}
end;
function UIUnionWarCityRight:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.CityUnionWarResult then -- 结果
		UIUnionCityWarResult:Show();
	elseif name == NotifyConsts.CityUnionWarJishaListUpdata then -- 击杀
		self:ShowJishaPenel();
	elseif name == NotifyConsts.CityUnionWarAllInfoUpdata then -- 总信息
		self:ShowTongjiPanle()
	elseif name == NotifyConsts.CityUnionWarSuperState then --神像状态
		self:ShowTongjiPanle();
	end;
end;


