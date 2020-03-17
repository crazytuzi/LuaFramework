--[[
帮派战 结算界面
wangshuai
]]
_G.UIUnionReward = BaseUI:new("UIUnionReward")

UIUnionReward.timerKey = nil;
UIUnionReward.time = 30;
function UIUnionReward:Create()
	self:AddSWF("UnionWarReawrd.swf",true,"center")
end;

function UIUnionReward:OnLoaded(objSwf)
	objSwf.closeBtn.click = function() self:OnCloseBtn() end;
	objSwf.closepanel.click = function() self:OnCloseBtn() end;
	objSwf.list.rewardRollOut = function() TipsManager:Hide() end;
	objSwf.list.rewardRollOver = function(e) self:RewardRollOver(e) end;

	RewardManager:RegisterListTips(objSwf.myItemList);
	RewardManager:RegisterListTips(objSwf.mySocreItemList);
end;

function UIUnionReward:OnShow()
	self:ShowList();
	self:SetText();
	self:SetMyReward();
	self.time = 30;
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,self.time);
end;


function UIUnionReward:OnHide()
	UnionWarModel:OutScene();
	TimerManager:UnRegisterTimer(self.timerKey);
	self.timerKey = nil;
	UnionWarController:OnReqGetReward()
end;

function UIUnionReward:SetMyReward()
	local objSwf = self.objSwf;
	local myUid = UnionModel:GetMyUnionId();
	local myReward = UnionWarModel:GetReawrdListItem(myUid);
	if not myReward then return end;
	local myrank = myReward.rank;
	local mylist = self:GetReardCfg(myrank,true)
	local rewardList = RewardManager:Parse(mylist[1],mylist[2],mylist[3]);
	objSwf.myItemList.dataProvider:cleanUp();
	objSwf.myItemList.dataProvider:push(unpack(rewardList));
	objSwf.myItemList:invalidateData();

	--个人积分奖励
	local MyScorerank = UnionWarModel.WarAllInfo.Myrank or 1;
	local selfindex = t_guildbattleselfindex;
	local mySocreGroup = 11;
	for i,info in ipairs(selfindex) do 
		local lvl = split(info.rank_range,",")
		if MyScorerank >= tonumber(lvl[1]) and MyScorerank <= tonumber(lvl[2]) then 
			mySocreGroup = i;
			break;
		end;
	end;
	local roleLvl = MainPlayerModel.humanDetailInfo.eaLevel;
	local myscoreCfgId = (roleLvl * 1000) + mySocreGroup
	local myscoreCfg = t_guildbattleself[myscoreCfgId];
	if not myscoreCfg then 
		myscoreCfg = {}
	end;
	local scorereward = RewardManager:Parse(myscoreCfg.reward);
	objSwf.mySocreItemList.dataProvider:cleanUp();
	objSwf.mySocreItemList.dataProvider:push(unpack(scorereward));
	objSwf.mySocreItemList:invalidateData();
end;

function UIUnionReward:Ontimer()
	UIUnionReward.time = UIUnionReward.time - 1;
	local objSwf = UIUnionReward.objSwf;
	objSwf.lastTimer.htmlText = string.format(StrConfig["unionwar218"],UIUnionReward.time)
	if UIUnionReward.time <= 0 then 
		UIUnionReward:Hide();
	end;
end;


function UIUnionReward:SetText()
	local objSwf = self.objSwf;
	local myUid = UnionModel:GetMyUnionId();
	local vo = UnionWarModel.IsFirst;
	local listvo = UnionWarModel:GetReawrdList()
	local myvo = UnionWarModel:GetReawrdListItem(myUid)
	if vo == 0 then 
		-- 服务器第一次
		objSwf.server1._visible = true;
		objSwf.server2._visible = false;
		if not listvo[1] then listvo[1] = {} end;
		if not listvo[2] then listvo[2] = {} 
			listvo[2].name = "";
			end;
		objSwf.server1.AtkUnionName.text = listvo[2].name;
		objSwf.server1.defUnionName.text = listvo[1].name;
	else
		-- 服务器黑了
		objSwf.server1._visible = false;
		objSwf.server2._visible = true;
		objSwf.server2.AtkUnionName.text = listvo[1].name;
	end;
	objSwf.MyUnionRank.text = myvo.rank;--"玛莎拉蒂";
	objSwf.MySroce.text = myvo.score;--"阿斯顿·马丁";
	local infovo = UnionWarModel:GetWarAllInfo();
	objSwf.MyScore_ge.text = infovo.myScore or 0;
	if myvo.isque == 0 then 
		-- 未获得
		objSwf.IsHaveQua.htmlText = string.format(StrConfig["unionwar215"])
	elseif myvo.isque == 1 then 
		-- 进攻
		objSwf.IsHaveQua.htmlText = string.format(StrConfig["unionwar216"])
	elseif myvo.isque == 2 then 
		-- 防御
		objSwf.IsHaveQua.htmlText = string.format(StrConfig["unionwar217"])
	end;
	
end;

function UIUnionReward:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list = {};
	local listvo = UnionWarModel:GetReawrdList()
	for i,vo in ipairs(listvo) do 
		local voc = {};
		if i == 1 then 
			voc.rank = "a";
		elseif i == 2 then 
			voc.rank = "b";
		elseif i == 3 then 
			voc.rank = "c";
		else
			voc.rank = i;
		end;
		voc.name = vo.name--"玛莎拉蒂"..i;
		voc.score = vo.score--i*2*10;
		if vo.isque == 0 then 
			voc.zige = "<font color='#ff0000'>未获得</font>"
		elseif vo.isque == 1 then 
			voc.zige = "<font color='#00ff00'>进攻资格</font>"
		elseif vo.isque == 2 then 
			voc.zige = "<font color='#3ec3ff'>防守资格</font>"
		end;
		table.push(list,UIData.encode(voc))
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end;
function UIUnionReward:OnCloseBtn()
	self:Hide();

end;

function UIUnionReward:RewardRollOver(e)
	local lvl = e.index+1;
	local list = self:GetReardCfg(lvl)
	local txt = "";
	for i,vo in pairs(list) do 
		local name = t_item[tonumber(i)].name
		local vlue = vo; 
		txt = txt.."<font color='#d1c0a5'>"..name.."：<font/><font color='#29cc00'>: "..vlue.."<br/>"
	end;
	TipsManager:ShowBtnTips(string.format(StrConfig["unionwar214"],txt));
	
end;

function UIUnionReward:GetReardCfg(rank,bo)
	local listvo  = {};
	local cfglengh = self:OnGetRewardLenght();
	local serverlvl = MainPlayerController:GetServerLvl();
	if rank > cfglengh then 
		local list = split(t_guildbattle[cfglengh]["reward"..serverlvl],"#");
		local cont = "80,"..t_guildbattle[cfglengh].cont[serverlvl];
		local liveness = "102,"..t_guildbattle[cfglengh].liveness;
		table.push(list,cont)
		table.push(list,liveness)
		if bo == true then 
			return list
		end;
		for i,vo in pairs(list) do 
			local listc = split(vo,",");
			listvo[listc[1]] = listc[2];
		end;
		return listvo;
	end;
	local list = split(t_guildbattle[rank]["reward"..serverlvl],"#");
	local cont = "80,"..t_guildbattle[rank].cont[serverlvl];
	local liveness = "102,"..t_guildbattle[rank].liveness;
	table.push(list,cont)
	table.push(list,liveness)
		if bo == true then 
			return list
		end;
	for c,ca in pairs(list) do 
		local listc = split(ca,",")
		listvo[listc[1]] = listc[2];
	end;
	return listvo;
end;

function UIUnionReward:OnGetRewardLenght()
	local num = 0;
	for i,info in pairs(t_guildbattle) do
		num = num + 1;
	end;
	return num;
end;