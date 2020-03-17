--[[
	jiayuan 建筑升级
	wangshuai
]]
_G.UIHomesBuildLvlUp = BaseUI:new("UIHomesBuildLvlUp")

UIHomesBuildLvlUp.buildLvl = 0;
UIHomesBuildLvlUp.itemId = nil;

function UIHomesBuildLvlUp:Create()
	self:AddSWF("homesteadBuildLvlUpPanel.swf",true,nil)
end

function UIHomesBuildLvlUp:OnLoaded(objSwf)
	objSwf.close_btn.click = function() self:Hide()end;

	objSwf.Uplvl_btn.click = function() self:OnUpBuildLvlClick()end;
	objSwf.Uplvl_btn.label = StrConfig["homestead046"]
--	objSwf.cancel_btn.click = function() self:Hide()end;
	RewardManager:RegisterListTips(objSwf.rewardlist);

	objSwf.txt_mc.rollOver = function() self:OnTxtmcOver() end;
	objSwf.txt_mc.rollOut  = function() TipsManager:Hide() end;

end;

function UIHomesBuildLvlUp:OnShow()
	if self.args and #self.args > 0 then
		self:SetUIdata(self.args[1][1])
		self:UpDataUI();
	end
end;

function UIHomesBuildLvlUp:OnHide()
	self.itemId = nil;

end;

function UIHomesBuildLvlUp:OnTxtmcOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if not self.itemId then return end;
	local tipsvo = ItemTipsUtil:GetItemTipsVO(self.itemId)
	if not tipsvo then return; end
	TipsManager:ShowTips(tipsvo.tipsType,tipsvo,tipsvo.tipsShowType, TipsConsts.Dir_RightDown);
end;


function UIHomesBuildLvlUp:OnUpBuildLvlClick()
	local lvl = self.buildLvl - 1;
	if lvl == 10 then 
		FloatManager:AddNormal(StrConfig["homestead044"])
		return 
	end
	local mainLvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild);
	if self.buildid ~= HomesteadConsts.MainBuild then 
		if lvl == mainLvl then 
			FloatManager:AddNormal(StrConfig["homestead052"])
			return 
		end;
	end;
	local cfg = t_homebuild[self.buildLvl];
	if cfg then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaLevel < cfg.playerLv then
			FloatManager:AddNormal( StrConfig['homestead073']);
			return;
		end
	end
	HomesteadController:BuildUplvl(self.buildid)
end;

function UIHomesBuildLvlUp:UpdataTxt()
	local objSwf = self.objSwf;
	local lvl = self.buildLvl - 1;
	if lvl == 0 then 
		lvl = StrConfig["homestead001"];
		objSwf.Uplvl_btn.label = StrConfig["homestead046"]
	elseif lvl == 10 then 
		lvl = StrConfig["homestead044"];
	else
		lvl = string.format(StrConfig["homestead018"],lvl);
		objSwf.Uplvl_btn.label = StrConfig["homestead046"]
	end;
	objSwf.lvl_txt.htmlText = lvl
	local MainbuildLvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
	local val = t_homebuild[MainbuildLvl+1]
	objSwf.nextlvl_txt.htmlText = MainbuildLvl+1 .. StrConfig["homestead067"];

end;
	
function UIHomesBuildLvlUp:SetUIdata(buildid)
	self.buildid = buildid or HomesteadConsts.MainBuild
	self.buildLvl = HomesteadModel:GetBuildInfoLvl(buildid)
	self.buildLvl = self.buildLvl + 1;
	self:UpdataTxt();
	self:Show();
end;

function UIHomesBuildLvlUp:UpDataUI()
	local objSwf = self.objSwf;
	local cfg = t_homebuild[self.buildLvl];
	local uplvlNeed = HomesteadUtil:GetHomeBuildCfg(self.buildid,self.buildLvl)
	local lingliCfg = t_huizhang[self.buildLvl -1 ];
	if not lingliCfg then 
		lingliCfg = t_huizhang[1]
	end;
	--trace(lingliCfg)
	--print("操你个大大爷的")
	objSwf.curl_txt.htmlText = lingliCfg.zhenqi[1];
	objSwf.curmaxl_txt.htmlText = lingliCfg.zhenqimax
	local lingliCfgNext = t_huizhang[self.buildLvl];
	if not lingliCfgNext then 
		lingliCfgNext = t_huizhang[2] 
	end;

	--trace(lingliCfgNext)
	objSwf.nextl_txt.htmlText = lingliCfgNext.zhenqi[1]
	objSwf.nextmaxl_txt.htmlText = lingliCfgNext.zhenqimax


	if not uplvlNeed then 
		return 
	end;
	local list = AttrParseUtil:ParseAttrToMap(uplvlNeed)
	local idlist = {};
	for i,info in pairs(list) do 
		local voc = {};
		voc.id = toint(i)
		voc.num = toint(info);
		table.push(idlist,voc)
	end; 

	local ccc = idlist[1]
	local str = ""
	local itemCfg = nil
	if t_item[ccc.id] then 
		itemCfg = t_item[ccc.id]; 
	elseif t_equip[ccc.id] then 
		itemCfg = t_equip[ccc.id]
	end;
	self.itemId = ccc.id;
	if not itemCfg then return end;
	local bagnum = BagModel:GetItemNumInBag(ccc.id);
	if bagnum >= ccc.num then 
		str = string.format(StrConfig["homestead045"],"#00ff00",itemCfg.name..bagnum,ccc.num)
	else
		str = string.format(StrConfig["homestead045"],"#ff0000",itemCfg.name..bagnum,ccc.num)
	end
	--print("没特尔走着了",str)
	objSwf.reward1_txt.htmlText = StrConfig['homestead062'] .. str
	objSwf.reward1_txt._visible = true;
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local strcolor = playerinfo.eaLevel >= cfg.playerLv and "#00ff00" or "#ff0000"
	objSwf.needlevel_txt.htmlText = string.format(StrConfig["homestead072"],strcolor,cfg.playerLv)
end;

function UIHomesBuildLvlUp:AutoSetPos()
	if self.parent == nil then return; end
	if not self.isLoaded then return; end
	if not self.swfCfg then return; end
	if not self.swfCfg.objSwf then return; end
	local objSwf = self.swfCfg.objSwf;

	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - objSwf._width/2
	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - objSwf._height/2
	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
end;
