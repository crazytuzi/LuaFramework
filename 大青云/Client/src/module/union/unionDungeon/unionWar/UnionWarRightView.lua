--[[
帮派战右侧面板
wangshuai
]]

_G.UIUnionRight = BaseUI:new("UIUnionRight")

UIUnionRight.curRankList = 1;
function UIUnionRight:Create()
	self:AddSWF("unionWarWindowPanel.swf",true,"center")
	self:AddChild(UIUnionWarMap,"unionmap")
end;

function UIUnionRight:OnLoaded(objSwf)
	self:GetChild("unionmap"):SetContainer(objSwf.childPanel)

	objSwf.list.rewardRollOver = function(e) self:RewardOver(e) end;
	objSwf.list.rewardRollOut  = function() TipsManager:Hide() end;

	objSwf.tab_jifen.click    = function() self:JifenTabClick()end;
	objSwf.tab_jisha.click    = function() self:JishaTabClick()end;
	objSwf.tab_preson.click   = function() self:PresonScore()end;
	objSwf.btnRule.rollOver   = function() self:RuleOver() end;
	objSwf.btnRule.rollOut    = function() TipsManager:Hide() end;

	objSwf.totemtips.rollOver = function() self:TotemShowTips() end;
	objSwf.totemtips.rollOut  = function() TipsManager:Hide() end;
	objSwf.totemtips.click    = function() self:TotemClick() end;

	objSwf.shengx.rollOver    = function() self:ShengXShowTips()end;
	objSwf.shengx.rollOut     = function() TipsManager:Hide()end;
	objSwf.shengx.click       = function() self:ShenxXClick()end;

	objSwf.wangzuo.rollOver   = function() self:WangZuoShowTips()end;
	objSwf.wangzuo.rollOut    = function() TipsManager:Hide()end;
	objSwf.wangzuo.click      = function() self:WangZuoClick() end;

	objSwf.wangzuocc.click      = function() self:WangZuoClick() end;
	objSwf.wangzuocc.htmlLabel = StrConfig["unionwar230"]
	

	objSwf.OutZhanchang.click = function() self:OutZhanchangClick()end;
	


	for i=1,3 do 
		--objSwf["lookpath"..i].click    = function() self:LookPathClick(i) end;
		--objSwf["lookpath"..i].rollOver = function() self:LookPathOver(i) end;
		--objSwf["lookpath"..i].rollOut  = function() TipsManager:Hide() end;
	end;

	--地图按钮
	objSwf.mapBtn.htmlLabel = StrConfig['unionwar233'];
	objSwf.mapBtn.click = function() self:MapShowBtn() end;

end;

function UIUnionRight:RewardOver(e)
	if self.curRankList == 2 then return end;
	local lvl = e.index+1;
	local list = self:GetReardCfg(lvl)
	local txt = "";
	for i,vo in pairs(list) do 
		local name = t_item[tonumber(i)].name
		local vlue = vo; 
		txt = txt.."<font color='#d1c0a5'>"..name.."：<font/><font color='#29cc00'>: "..vlue.."<br/>"
	end;
	TipsManager:ShowBtnTips(string.format(StrConfig["unionwar214"],txt));

end

function UIUnionRight:GetReardCfg(rank,bo)
	local listvo  = {};
	local cfglengh = self:OnGetRewardLenght();
	local serverlvl = MainPlayerController:GetServerLvl();
	if rank > cfglengh then 
		local list = split(t_guildbattle[cfglengh]["reward"..serverlvl],"#");
		if bo == true then 
			return list;
		end;
		for i,vo in pairs(list) do 
			local listc = split(vo,",");
			listvo[listc[1]] = listc[2];
		end;
		return listvo;
	end;
	local list = split(t_guildbattle[rank]["reward"..serverlvl],"#");
	if bo == true then 
		return list;
	end;
	for c,ca in pairs(list) do 
		local listc = split(ca,",")
		listvo[listc[1]] = listc[2];
	end;
	return listvo;
end;

function UIUnionRight:OnGetRewardLenght()
	local num = 0;
	for i,info in pairs(t_guildbattle) do
		num = num + 1;
	end;
	return num;
end;

function UIUnionRight:MapShowBtn()
	local objSwf = self.objSwf;
	if UIUnionWarMap:IsShow() then 
		if objSwf.childPanel._visible == true then 
			objSwf.mapBtn.htmlLabel = StrConfig['unionwar232'];
		else
			objSwf.mapBtn.htmlLabel = StrConfig['unionwar233'];
		end;
		objSwf.childPanel._visible = not objSwf.childPanel._visible;
		objSwf.childPanel.hitTestDisable = not objSwf.childPanel._visible;
	else
		self:ShowMap();
	end;
end;

-- 面板 附带资源
function UIUnionRight:WithRes()
	  return { "unionWarMapPanel.swf" };
end;

function UIUnionRight:ShowMap()	
	local child = self:GetChild("unionmap");
	if not child then return end;
	self:ShowChild("unionmap")
end;
function UIUnionRight:HideMap()
	if UIUnionWarMap:IsShow() then 
		UIUnionWarMap:Hide();
	end;
end;

function UIUnionRight:OnShow()
	local objSwf = self.objSwf;
	objSwf.tab_jifen.selected = true;
	self:Showlist(self.curRankList);
	self:ShowMap();
	self:ShowMyinfo();
	FloatManager:AddActivity(StrConfig['unionwar229']);
end;
function UIUnionRight:OnHide()
 
end;

function UIUnionRight:OutZhanchangClick()
	-- 退出战场
	UnionWarController:Outwar()
end;

function UIUnionRight:JifenTabClick()
	self.curRankList = 1;
	self:Showlist(self.curRankList);
end;	
function UIUnionRight:JishaTabClick()
	self.curRankList = 2;
	self:Showlist(self.curRankList);
end;

function UIUnionRight:PresonScore()
	self.curRankList = 3;
	self:Showlist(self.curRankList)
end;

function UIUnionRight:ShowMyinfo()
	local infovo = UnionWarModel:GetWarAllInfo();
	local buivo = UnionWarModel:GetWarBuilding();
	local objSwf = self.objSwf;
	objSwf.myjif.text = infovo.myUnionNum;
	local myunionId = UnionModel:GetMyUnionId()
	local cfg = UnionWarModel:GetMyRankData(myunionId);
	objSwf.myrank.text = cfg.rank;
	objSwf.myjif.text = cfg.Score;
	objSwf.mySocre.text = infovo.myScore or 0;
	if buivo.wangzuoname == "" then  
		objSwf.wangzuoName.textField.htmlText = StrConfig['unionwar227']
		objSwf.wangzuocc.htmlLabel = StrConfig["unionwar230"]
	else
		local myName = UnionModel:GetMyUnionName()
		if myName == buivo.wangzuoname then 
			objSwf.wangzuocc.htmlLabel = StrConfig["unionwar231"]
		else
			objSwf.wangzuocc.htmlLabel = StrConfig["unionwar230"]
		end;
		objSwf.wangzuoName.textField.text = buivo.wangzuoname;
	end;
	local time = UnionWarModel:GetWarAllInfo().UnionTime;
	local t,s,m = UnionWarModel:GetTimer(time)
	objSwf.Times.textField.text = string.format(StrConfig["unionwar210"],t,s,m);

end;

function UIUnionRight:UpTime()
	local time = UnionWarModel:GetWarAllInfo().UnionTime;
	local objSwf = self.objSwf;
	local t,s,m = UnionWarModel:GetTimer(time)
	if not objSwf then return end;
	if not time  then return end;
	objSwf.Times.textField.text = string.format(StrConfig["unionwar210"],t,s,m);
end;
function UIUnionRight:Showlist(type)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local isShowBtn = false;
	local list = {};
	if type == 1 then 
		--  积分
		isShowBtn = true
		objSwf.txtName.text = StrConfig['unionwar235'];
		objSwf.abc._visible = true;
		objSwf.txtnum.text = string.format(StrConfig["unionwar203"])
		list = UnionWarModel:GetIntergrallist();
	elseif type == 2 then 
		-- 击杀
		isShowBtn = false;
		objSwf.txtName.text = StrConfig['unionwar235'];
		objSwf.abc._visible = false;
		objSwf.txtnum.text = string.format(StrConfig["unionwar204"])
		list = UnionWarModel:GetKillList()
	elseif type == 3 then 
		isShowBtn = false;
		objSwf.abc._visible = false;
		objSwf.txtName.text = StrConfig['unionwar236'];
		objSwf.txtnum.text = string.format(StrConfig["unionwar205"])
		list = UnionWarModel:GetPresonScore()
	end;
	if not list then return end;
	local listvo = {};
	for i,info in ipairs(list)  do 
		local vo = {}
		if i == 1 then 
			vo.rank = "a"
		elseif i == 2 then 
			vo.rank = "b"
		elseif i == 3 then 
			vo.rank = "c"
		else
			vo.rank = i;
		end;
		vo.name = info.UnionName;
		vo.btnvisi = isShowBtn
		vo.addNum = info.Score;
		vo.rewardid = info.rewardId;
		local luckrank = UnionWarModel:GetWarAllInfo().luakRank or 1;
		if i == UnionWarModel:GetWarAllInfo().luakRank  then 
			vo.isluck = true
		else
			vo.isluck = false
		end;
		table.push(listvo,UIData.encode(vo))
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(listvo));
	objSwf.list:invalidateData();
end;
function UIUnionRight:RuleOver()
	TipsManager:ShowBtnTips(string.format(StrConfig["union404"]));--unionwar202
end;


function UIUnionRight:TotemShowTips()
	TipsManager:ShowBtnTips(string.format(StrConfig["unionwar206"]));
end;

function UIUnionRight:TotemClick()
	self:LookPathfun(1)
end;

function UIUnionRight:ShengXShowTips()
	TipsManager:ShowBtnTips(string.format(StrConfig["unionwar207"]));
end;

function UIUnionRight:ShenxXClick()
	self:LookPathfun(2)
end;

function UIUnionRight:WangZuoShowTips()
	TipsManager:ShowBtnTips(string.format(StrConfig["unionwar208"]));
end;

function UIUnionRight:WangZuoClick()
	self:LookPathfun(3)
end;


------ 消息处理 ---- 
function UIUnionRight:ListNotificationInterests()
	return {
		NotifyConsts.UnionWarAllinfo,NotifyConsts.UnionWarBuildingState,NotifyConsts.UnionWarUpdataList
		}
end;
function UIUnionRight:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.UnionWarAllinfo then 
		-- 显示人物list
		self:ShowMyinfo();
	end;
	if name == NotifyConsts.UnionWarBuildingState then 
		--self:
	end;
	if name == NotifyConsts.UnionWarUpdataList then 
		self:Showlist(self.curRankList);
		self:ShowMyinfo();
	end;
end;



-- 寻路按钮
function UIUnionRight:LookPathClick(i)
	-- if i == 1 then 
	-- 	-- 图腾
	-- 	elseif i == 2 then 
	-- 		-- 神像
	-- 	elseif i == 3 then 
	-- 		-- 王座
			self:LookPathfun(i)
	--end;
end;

function UIUnionRight:LookPathOver(i)
	if i == 1 then 
		-- 图腾
		TipsManager:ShowBtnTips(string.format(StrConfig["unionwar211"]));
		elseif i == 2 then 
			-- 神像
		TipsManager:ShowBtnTips(string.format(StrConfig["unionwar212"]));
		elseif i == 3 then 
			-- 王座
		TipsManager:ShowBtnTips(string.format(StrConfig["unionwar213"]));
	end;
end


function UIUnionRight:LookPathfun(type)
	local player = MainPlayerController:GetPlayer()
	local playerxy = player:GetPos() 
	local posX = 0;
	local posY = 0;
	local mapid = CPlayerMap:GetCurMapID();
	if type == 1 then 
		--图腾
		local voc = {};
		for i=5,9 do
			local xvo = {};
			local x = UnionWarConfig.building[i].x;
			local y = UnionWarConfig.building[i].y;
			local fx = playerxy.x - x;
			local fy = playerxy.y - y;
			local pos = math.sqrt(fx*fx+fy*fy)
			xvo.pos = pos;
			xvo.x = x;
			xvo.y = y;
			xvo.id = i
			table.push(voc,xvo)
		end;
		local sortlistc = UIUnionRight:onGoPathTow(self:SortIng(voc))
		posX = sortlistc.x;
		posY = sortlistc.y;
	elseif type == 2 then 	
		-- 神像
		local vo = {};
		for i=2,4 do 
			local cctv ={};
			local x = UnionWarConfig.building[i].x
			local y = UnionWarConfig.building[i].y
			local dx = playerxy.x - x;
			local dy = playerxy.y - y;
			local pos = math.sqrt(dx*dx+dy*dy);
			cctv.pos = pos;
			cctv.x = x;
			cctv.y = y;
			cctv.id = i
			table.push(vo,cctv)
		end;
		local sortList = UIUnionRight:onGoPathTow(self:SortIng(vo))
		posY = sortList.y;
		posX = sortList.x;
	elseif type == 3 then 
		-- 王座
		posX = UnionWarConfig.building[1].x
		posY = UnionWarConfig.building[1].y;
	end;

	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(posX,posY,0),completeFuc);
end;

function UIUnionRight:onGoPathTow(list)
	for i,info in ipairs(list) do
		local id = info.id;
		local state = UnionWarModel:GetWarBuildingIndex(id)
		if state == 1 then 
			return info
		end;
	end;
	return list[1];
end;

function UIUnionRight:SortIng(list)
	for i=1,#list-1 do 
		for i=1,#list-1 do 
			if list[i].pos > list[i+1].pos then 
				list[i],list[i+1] = list[i+1],list[i];
			end;
		end;
	end;
	return list;
end;

function UIUnionRight:GetWidth()
	return 366
end;
function UIUnionRight:GetHeight()
	return 542
end;