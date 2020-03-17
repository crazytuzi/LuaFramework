--[[
	家园， 寻仙
	wangshuai
]]

_G.UIHomesXunxian = BaseUI:new("UIHomesXunxian")

UIHomesXunxian.showPupilNum = 6;

function UIHomesXunxian:Create()
	self:AddSWF("homesteadXunxianPanel.swf",true,nil)
end;

function UIHomesXunxian:OnLoaded(objSwf)
	--objSwf.close_btn.click = function() self:Hide()end;
	objSwf.updata_btn.click = function() self:OnUpdataPupil()end;
	objSwf.updata_btn.rollOver = function() self:UpdataBtnOver()end;
	objSwf.updata_btn.rollOut  = function() TipsManager:Hide()end;

	for i=1,self.showPupilNum do
		objSwf["btn"..i].click = function() self:OnGetPupil(i)end;
	end;

	 objSwf.list.itemSkillRollOver = function(e) self:ItemSkillOver(e)end;
	 objSwf.list.itemSkillRollOut = function()  UIHomesSkillTips:Hide(); end;

end;

function UIHomesXunxian:OnShow()
	--获取信息
	HomesteadController:ZongmengInfo()
	HomesteadController:XunxianPupil(0)
	self:ShowPupilList();
	self:ShowUiInfo();
end;
	
function UIHomesXunxian:OnHide()

end;

function UIHomesXunxian:UpdataBtnOver()
	local num = HomesteadModel:GetXunXianUpdataNum()
	if num == 0 then num = 1 end;
	local cfg = t_homepupilRe[num];
	if not cfg then 
		cfg = t_homepupilRe[10];
	end;
	TipsManager:ShowBtnTips(string.format(StrConfig["homestead006"],cfg.need),TipsConsts.Dir_RightDown);
end;

function UIHomesXunxian:ShowUiInfo()
	local objSwf = self.objSwf;
	local pupilStr = HomesteadModel:GetMyPupilAllNum();
	local mainbuildLvl = HomesteadModel:GetBuildInfoLvl(HomesteadConsts.MainBuild)
	if mainbuildLvl <= 0 then mainbuildLvl = 1 end;
	local buildCfg = t_homebuild[mainbuildLvl];
	local maxNum = buildCfg.pupilMax;
	local pustr = pupilStr .. "/" .. maxNum;
	objSwf.curPupilNum_txt.htmlText = pustr
	self:UpdataLastTime()
end;

function UIHomesXunxian:UpdataLastTime()
	local objSwf  = self.objSwf;
	local lasttime = HomesteadModel:GetXunXianTime()
	if lasttime == -1 then 
		lasttime = 0;
	end;
	local t,s,f = CTimeFormat:sec2format(lasttime)
	local str = string.format("%02d:%02d:%02d",t,s,f)
	objSwf.lastTime_txt.htmlText = str
end;

function UIHomesXunxian:ItemSkillOver(e)
	local objSwf = self.objSwf;
	UIHomesSkillTips:SetSkillId(e.item.skillId);
end;
 
 UIHomesXunxian.isShowRemind = true;
function UIHomesXunxian:OnUpdataPupil()
	local num = HomesteadModel:GetXunXianUpdataNum()
	if num == 0 then  num = 1 end;
	local cfg = t_homepupilRe[num];
	if not cfg then 
		cfg = t_homepupilRe[10];
	end;
	local myYuanbao = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	if myYuanbao < cfg.need then 
		FloatManager:AddNormal( StrConfig['homestead047']);
		return 
	end;

	local func = function (desc) 
		--请求刷新
		self.isShowRemind = not desc;
		HomesteadController:XunxianPupil(1)
	end
	if self.isShowRemind then 
		UIConfirmWithNoTip:Open(string.format(StrConfig["homestead048"],"#00ff00",cfg.need),func)
	else
		HomesteadController:XunxianPupil(1)
	end;
end

function UIHomesXunxian:OnGetPupil(index)
	local cfglist = HomesteadModel:GetXunXianPupilInfo()
	local reNum = HomesteadModel:GetXunXianUpdataRescruit()
	local vo = cfglist[index];
	if not vo then return end;
	local cfg = t_homepupilskillrange[vo.quality + 1];

	local listasd = self:ParseAttrToMap(cfg.price)
	local XiaoVo = listasd[reNum];
	local moNum = XiaoVo.val;
	local money = MainPlayerModel.humanDetailInfo[XiaoVo.type]
	local colorStr = '';
	if moNum > money then 
		colorStr = "#ff0000"
	else
		colorStr = "#29cc00"
	end;
	local okfun = function () 
		local cfglist = HomesteadModel:GetXunXianPupilInfo()
		local reNum = HomesteadModel:GetXunXianUpdataRescruit()
		local vo = cfglist[index];
		local cfg = t_homepupilskillrange[vo.quality + 1];

		local listasd = self:ParseAttrToMap(cfg.price)
		local XiaoVo = listasd[reNum];
		local money = MainPlayerModel.humanDetailInfo[XiaoVo.type]
		local moNum = XiaoVo.val;
		if moNum > money then 
			FloatManager:AddNormal( StrConfig['homestead065']);
			return 
		end;
		if not vo then return end;
		HomesteadController:PupilAdd(vo.guid)
	end;
	UIConfirm:Open(string.format(StrConfig["homestead017"],colorStr,moNum),okfun)
end;

--str:属性类型,属性值#属性类型,属性值
function UIHomesXunxian:ParseAttrToMap(str)
	local map = {};
	local t = split(str,'#');
	for i = 1, #t do
		local t1 = split(t[i],',');
		local vo = {};
		vo.type = tonumber(t1[1]);	
		vo.val  = tonumber(t1[2]);
		table.push(map,vo)
	end
	return map;
end


function UIHomesXunxian:ShowPupilList()
	local objSwf = self.objSwf;
	local datalist = HomesteadUtil:GetXunXianListData()
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();

	local list = HomesteadModel:GetXunXianPupilInfo()
	for i,info in ipairs(list) do 
		local btn = objSwf["btn"..i];
		if info.state == 1 then 
			btn.disabled = true;
		else
			btn.disabled = false;
		end;
	end;
end;

-- -- 居中
-- function UIHomesXunxian:AutoSetPos()
-- 	if self.parent == nil then return; end
-- 	if not self.isLoaded then return; end
-- 	if not self.swfCfg then return; end
-- 	if not self.swfCfg.objSwf then return; end
-- 	local objSwf = self.swfCfg.objSwf;

-- 	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - objSwf._width/2
-- 	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - objSwf._height/2
-- 	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
-- 	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
-- end;

	-- notifaction
function UIHomesXunxian:ListNotificationInterests()
	return {
		NotifyConsts.HomesteadPupilList,
		NotifyConsts.HomesteadUpdatTime,
		}
end;
function UIHomesXunxian:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.HomesteadPupilList then
		self:ShowPupilList();
		self:ShowUiInfo();
	elseif name == NotifyConsts.HomesteadUpdatTime then 
		self:UpdataLastTime();
	end;
end;
