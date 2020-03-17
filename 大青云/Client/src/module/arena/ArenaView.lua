--[[
	竞技场View
	wangshuaui
]]

_G.UIArena = BaseUI:new("UIArena");

UIArena.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
														--宽 高
									VPort = _Vector2.new(640,900),
									Rotation = 0,
									roleY = 0,
									taiZi = 0;
								  }

UIArena.yanWumodelList = {};
UIArena.avatList = {};
UIArena.isShowWindow = false;
UIArena.ErjiPanelList = {};

function UIArena : Create()
	self:AddSWF("arenaPanel.swf",true,"center");
	self:AddChild(UIRankRewardView,"erjipanel") -- smart
end;
-- 打开排行奖励
function UIArena : RanKingGo()
	local child = self:GetChild("erjipanel");
	if not child then
		return;
	end
	if UIRankRewardView:IsShow() then
		UIRankRewardView:Hide();
	else
		self:ShowChild("erjipanel");
	end;
end;
-- 面板类型
function UIArena:GetPanelType()
	return 1;
end;

function UIArena : OnLoaded(objSwf)
	--print("加载完成竞技场")\
	self:GetChild("erjipanel"):SetContainer(objSwf.childPanel) -- smart
	ArenaModel : InitFun();
	objSwf.closebtn.click = function() self:Closebtn()end;
	objSwf.btn_ranking.click = function() self:RanKingGo()end;
	-- 2级界面
	objSwf.beRolePanel.rolelist.itemClick = function(e) self:BeRoleListClick(e)end;
	objSwf.beRolePanel.rolelist.itemRollOver = function(e) self:BeRoleOver(e)end;
	objSwf.beRolePanel.rolelist.itemRollOut = function(e) self:BeRoleOut(e)end;
	-- fristlist
	objSwf.fristpanel.fristlist.itemClick = function(e) self:BeFristListClick(e)end;
	objSwf.fristpanel.fristlist.itemRollOver = function(e) self:BeFristOver(e)end;
	objSwf.fristpanel.fristlist.itemRollOut = function(e) self:BeFristOut(e)end;

	--规则
	objSwf.rulesBtn.rollOver = function() TipsManager:ShowBtnTips(StrConfig['arena141'],TipsConsts.Dir_RightDown); end
	objSwf.rulesBtn.rollOut = function() TipsManager:Hide(); end

	-- tips 
	objSwf.tips_addnum.click = function() self:AddChalNum()end;
	objSwf.tips_addnum.rollOver = function() self:AddChalNumTips()end;
	objSwf.tips_addnum.rollOut = function() TipsManager:Hide()end;

    -- objSwf.tips_addzhanli.click = function() self:AddChalNum()end;
	-- objSwf.tips_addzhanli.rollOver = function() self:AddChalNumTips()end;
	-- objSwf.tips_addzhanli.rollOut = function() TipsManager:Hide()end;

	objSwf.tips_claertime.click = function() self:ClaerTime()end;
	objSwf.tips_claertime.rollOver = function() self:ClaerTimeTips()end;
	objSwf.tips_claertime.rollOut = function() TipsManager:Hide()end;
	-- 竞技战报
	objSwf.btn_Skin1.click = function() self:SetSkInfoPanel()end;
	objSwf.skinfopanel.btn_Skin2.click = function() self:SetInfoPanel2()end;

	-- 123m名
	objSwf.btn_frist.click = function() self:SetFristPanel()end;

	-- 荣誉商店
	objSwf.btn_honor.click = function() self:ShowHonorShop()end;
	--objSwf.beRolePanel.hitTestDisable = true;TipsManager:Hide
	for i=1,3 do
		objSwf.beRolePanel["model"..i].hitTestDisable = true;
		objSwf.fristpanel["load"..i].hitTestDisable = true;
		objSwf.beRolePanel["roleitem"..i].tiaozhan.hitTestDisable = true;
		objSwf.fristpanel["fristitem"..i].tiaozhan.hitTestDisable = true;
	end
	objSwf.beRolePanel.myRolemodel.hitTestDisable = true;
	-- mouseEnabled = false

end;

-- drwa scene
_G.ARENA_DRAW_SCENE_UI = "ArenaDrawSceneUI"
function UIArena:DrawScene(isFrist)
	local objSwf = self.objSwf;
	--debug.debug();
	if not self.viewPort then self.viewPort = _Vector2.new(1300, 795); end
	if not self.objUISceneDraw then
		self.objUISceneDraw = UISceneDraw:new(_G.ARENA_DRAW_SCENE_UI, objSwf.scene_load, self.viewPort, true);
	end
	self.objUISceneDraw:SetUILoader( objSwf.scene_load )
	if isFrist then
		local src = "jjc_taizi_win.sen"
		self.objUISceneDraw:SetScene(src, function()
			self:ShowFristRank();
		end );
	else
		local src = "jjc_taizi.sen"
		self.objUISceneDraw:SetScene(src, function()
			self:ShowBeRoleInfo();
			self:ShowMyRoleInfo()
		end );
	end;
	self.objUISceneDraw:SetDraw( true );
end;

-- 显示荣誉商店
function UIArena : ShowHonorShop()
	UIShopCarryOn:OpenShopByType(ShopConsts.T_Honor)

	if UIRankRewardView:IsShow() then
		UIRankRewardView:Hide();
	end;
end;
function UIArena : OnShow()
	local objSwf = self.objSwf;
	--隐藏战报
	objSwf.skinfopanel._visible = false;
--	objSwf.skinfoup._visible = true;
	objSwf.btn_Skin1._visible = true;
	-- fristpanel
	objSwf.fristpanel._visible =  false;
	objSwf.beRolePanel._visible =  true;
	objSwf.btn_frist.selected = false;
	ArenaController : GetMyroleAtb()
	local honor,gold = ArenaModel:GetHoursReward();
	objSwf.pointReward.htmlText = string.format(StrConfig["arena131"],gold,honor);

	-- show scene
	--self:DrawScene();
	self:ShowRankRewardBtnFpx();
end;
--com.mars.common.SwfEffect

function UIArena:ShowRankRewardBtnFpx()
	local objSwf = self.objSwf;
	local myinfo = ArenaModel : GetMyroleInfo()
	if myinfo.isResults == 1 then
		objSwf.btn_ranking.effect._visible = false;
	else
		objSwf.btn_ranking.effect._visible = true;
	end;
end;

function UIArena:ShowYanWu()
	-- local objSwf = self.objSwf;
	-- local cfg = {
	-- 			EyePos = _Vector3.new(0,-50,0),
	-- 			LookPos = _Vector3.new(6,0,-8),
	-- 			VPort = _Vector2.new(987,595),
	-- 			}

	-- if not self.yanWumodelList[1] then 
	-- 	self.yanWumodelList[1] = UIPfxDraw:new("ArenayanwuQian",objSwf.qian_wu,cfg.VPort,cfg.EyePos,cfg.LookPos,"0x00000000");
	-- 	self.yanWumodelList[1]:PlayPfx("jingjichang_yanwu_qian.pfx")
	-- else
	-- 	self.yanWumodelList[1]:SetUILoader(objSwf.qian_wu);
	-- 	self.yanWumodelList[1]:SetCamera(cfg.VPort,cfg.EyePos,cfg.LookPos);
	-- end;
	-- self.yanWumodelList[1]:SetDraw(true) 


	-- local ccfg = {
	-- 			EyePos = _Vector3.new(0,-50,19),
	-- 			LookPos = _Vector3.new(0,0,12),
	-- 			VPort = _Vector2.new(987,595),
	-- 			}

	-- if not self.yanWumodelList[2] then 
	-- 	self.yanWumodelList[2] = UIPfxDraw:new("ArenayanwuHou",objSwf.hou_load,ccfg.VPort,ccfg.EyePos,ccfg.LookPos,"0x00000000");
	-- 	self.yanWumodelList[2]:PlayPfx("jingjichang_yanwu_hou.pfx")
	-- else
	-- 	self.yanWumodelList[2]:SetUILoader(objSwf.hou_load);
	-- 	self.yanWumodelList[2]:SetCamera(ccfg.VPort,ccfg.EyePos,ccfg.LookPos);
	-- end;
	-- self.yanWumodelList[2]:SetDraw(true) 

end;

function UIArena:OnFullShow()
	self.avatList = {};
	local objSwf = self.objSwf;
	-- 请求信息


	ArenaController : GetRolelist(1)
	self:ShowYanWu()
	-- self:UpdateMask();
end;

-- 123名和挑战对象的切换按钮
function UIArena : SetFristPanel()
	local objSwf = self.objSwf;

	if objSwf.fristpanel._visible == false then
		-- 显示123名
		objSwf.fristpanel._visible = true;
		objSwf.beRolePanel._visible = false;
		objSwf.btn_frist.selected = true;
		ArenaController : GetRolelist(0)
		--self:DrawScene(true)
	else
		-- 显示挑战对象
		objSwf.fristpanel._visible = false;
		objSwf.beRolePanel._visible = true;
		objSwf.btn_frist.selected = false;
		ArenaController : GetRolelist(1)
		ArenaController : GetMyroleAtb()
		--self:DrawScene()
	end;

end;



-- 显示123名list
function UIArena : ShowFristRank()
	local objSwf = self.objSwf;
	local paSwf = self.objSwf.fristpanel;
	local list = ArenaModel : GetFristList()
	if not list then return end;
	paSwf.fristlist.dataProvider:cleanUp();
	for i,info in ipairs(list) do
		local vo = {};
		if info.rank == ArenaModel:GetMyRank() then
			vo.isMyrole = true;
		end;
		vo.id =  info.id;
		vo.prof = info.prof;
		vo.name = info.roleName;
		vo.fight = info.fight;
		vo.rank =  string.format(StrConfig["arena102"],info.rank);
		vo.ranks = info.rank;
		vo.ranksf = "dt"..info.rank.."tm"
		paSwf.fristlist.dataProvider:push(UIData.encode(vo));
	end;
	paSwf.fristlist:invalidateData();


	for i=1,#list,1 do
		local obj = self.objSwf.fristpanel["load"..i]
		self:DrawRole(list[i],i*10,i+4)
	end;

end

function UIArena : BeFristListClick(e)
	self:ReqChaaenge(e.item.ranks)
end
-- 设置竞技战报文本
function UIArena : SetSkInfoPanel()
	--请求竞技战报
	local objSwf = self.objSwf;
--	objSwf.skinfoup._visible = false;
	objSwf.skinfopanel._visible = true;
	objSwf.btn_Skin1._visible = false;
	ArenaController : ReqSkInfo()
end;
function UIArena : UpdataSkinfo()
	local objSwf = self.objSwf;
	local skSwf = self.objSwf.skinfopanel;
	local infolist = ArenaModel:GetSkInfo()
	skSwf.skinfolist.dataProvider:cleanUp();
	for i,info in pairs(infolist) do
		local vo = {};
		vo.txt = info;
		skSwf.skinfolist.dataProvider:push(UIData.encode(vo));
	end;
	skSwf.skinfolist:invalidateData();
end;
-- 关闭竞技战报
function UIArena : SetInfoPanel2()
	local objSwf = self.objSwf;
	objSwf.skinfopanel._visible = false;
	--objSwf.skinfoup._visible = true;
	objSwf.btn_Skin1._visible = true;
end;
-- 清除时间
function UIArena : ClaerTime()
	local myinfo = ArenaModel : GetMyroleInfo();
	if myinfo.lastTime then
		if myinfo.lastTime <= 0 then
			FloatManager:AddNormal(StrConfig['arena130']);
			return;
		end;
		local okfun = function () self:DetermineClaertimer(); end;
		local nofun = function () end;
		local money = ArenaUtils : GetClaerTimeMoney();
		local id = UIConfirm:Open(string.format(StrConfig["arena125"],money),okfun,nofun);
		table.push(self.ErjiPanelList,id);
	end;
end;
function UIArena : DetermineClaertimer()
	local mymoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	local money =  ArenaUtils : GetClaerTimeMoney();
	if money > mymoney then
		FloatManager:AddSysNotice(2000017);--元宝不足，无法购买
		return ;
	end;
	ArenaController : ReqBuyCd()

end;
function UIArena : ClaerTimeTips()
TipsManager:ShowBtnTips(string.format(StrConfig["arena106"]),TipsConsts.Dir_RightDown);
end;
-- 添加次数
function UIArena : AddChalNum()
	local bo =  ArenaUtils : ChallengeNum()
	if bo == false then
		FloatManager:AddNormal(StrConfig['arena129']);
		return
	end;
	local okfun = function () self:DetermineBuy(); end;
	local nofun = function () end;
	local id = UIConfirm:Open(StrConfig["arena128"],okfun,nofun);
	table.push(self.ErjiPanelList,id)
end;
function UIArena : DetermineBuy()
	-- 需要判断时间够不够啊。。
	-- 元宝够不够
	local mymoney = MainPlayerModel.humanDetailInfo.eaUnBindMoney
	if 20 > mymoney then
		FloatManager:AddSysNotice(2000017);--元宝不足，无法购买
		return ;
	end;
	ArenaController : ReqBuyTimer()
end;
function UIArena : AddChalNumTips()
	TipsManager:ShowBtnTips(string.format(StrConfig["arena105"]),TipsConsts.Dir_RightDown);
end;
-- timer 计时器
function UIArena : timerText(t,s,m)
	if not self.bShowState then return; end
	local objSwf = UIArena.objSwf;
	local at = toint(t);
	local as = toint(s);
	local sm = toint(m);

	if at >= 0 and as > 39 and sm >= 0 then
		objSwf.txttime.htmlText = string.format(StrConfig["arena107"],"#ff0000",t,s,m)
	else
		objSwf.txttime.htmlText = string.format(StrConfig["arena107"],"#29cc00",t,s,m)
	end;
end;
--123名
function UIArena : BeFristOver(e)
	self:BeRoleOverEvent(e)
end
function UIArena : BeFristOut(e)
	self:BeRoleOutEvent()
end;
--被挑战
function UIArena : BeRoleOver(e)
	self:BeRoleOverEvent(e)
end;
function UIArena : BeRoleOut(e)
	self:BeRoleOutEvent()
end;
--  人物移入鼠标变化， 以及人物模型描边添加在此！
function UIArena : BeRoleOverEvent(e)
	local curid = e.item.id;
	local myid = MainPlayerController:GetRoleID();
	if curid == myid  then return end;
	CCursorManager:AddState("arenaAtk");
end;
function UIArena : BeRoleOutEvent()
	CCursorManager:DelState("arenaAtk");
end;
-- 自己信息
function UIArena : ShowMyRoleInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local info = ArenaModel : GetMyroleInfo()
	local rank = info.rank;
	objSwf.rank.text = rank;
	objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaHonor
	objSwf.txtfight.num = MainPlayerModel.humanDetailInfo.eaFight;
	objSwf.txtchal.text = string.format(StrConfig["arena104"], info.chal,info.maxchall);
	local t,s,m = ArenaModel : GetCurtime();
	self:timerText(t,s,m)
	objSwf.txtfield.text = info.field
	local vo = {};
	vo.name = MainPlayerModel.humanDetailInfo.eaName;
	vo.fight = tostring(MainPlayerModel.humanDetailInfo.eaFight);
	vo.ranksf = "dt"..rank.."tm"
	if rank == ArenaModel:GetMyRank() then
		vo.isMyrole = true;
	end;
	self.objSwf.beRolePanel.myitem:setData(UIData.encode(vo));  --显示

	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	local infoc = MainPlayerModel.sMeShowInfo;
	local voc = {};
	voc.prof = prof;
	voc.arms = infoc.dwArms;
	voc.dress = infoc.dwDress;
	voc.fashionsHead = infoc.dwFashionsHead
	voc.fashionsArms = infoc.dwFashionsArms
	voc.fashionsDress = infoc.dwFashionsDress
	voc.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = infoc.wing
	vo.suitflag = infoc.suitflag
	local obj = self.objSwf.beRolePanel.myRolemodel
	self:DrawRole(voc,10105,4)
end;

function UIArena:ShowMyRoleInfoUpdata()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local info = ArenaModel : GetMyroleInfo()
	local rank = info.rank;
	objSwf.rank.text = rank;
	objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaHonor
	objSwf.txtfight.num = MainPlayerModel.humanDetailInfo.eaFight;
	objSwf.txtchal.text = string.format(StrConfig["arena104"], info.chal,info.maxchall);
	local t,s,m = ArenaModel : GetCurtime();
	self:timerText(t,s,m)
	objSwf.txtfield.text = info.field
	local vo = {};
	vo.name = MainPlayerModel.humanDetailInfo.eaName;
	vo.fight = tostring(MainPlayerModel.humanDetailInfo.eaFight);
	vo.ranksf = "dt"..rank.."tm"
	self.objSwf.beRolePanel.myitem:setData(UIData.encode(vo));  --显示
end;
--  被挑战人物list显示
function UIArena : ShowBeRoleInfo()
	local objSwf = self.objSwf
	local list = ArenaModel:GetBerolelist();
	if not list then return end;
	objSwf.beRolePanel.rolelist.dataProvider:cleanUp();


	for i,info in ipairs(list) do
		local vo = {};
		if info.rank == ArenaModel:GetMyRank() then
			vo.isMyrole = true;
		end;
		vo.prof = info.prof;
		vo.rankz = info.rank
		vo.id =  info.id;
		vo.name = info.roleName;
		vo.fight = info.fight;
		vo.rank =  string.format(StrConfig["arena102"],info.rank);
		vo.ranksf = "dt"..info.rank.."tm"
		objSwf.beRolePanel.rolelist.dataProvider:push(UIData.encode(vo));
		local obj = self.objSwf.beRolePanel["model"..i]
		vo.prof = info.prof;
		self:DrawRole(list[i],i,i)
	end;
	objSwf.beRolePanel.rolelist:invalidateData();
end;
function UIArena : DrawRole(vo,ic,index)
	local objswf = self.objSwf;
	if self.avatList[ic] ~= nil then
		self.avatList[ic]:ExitMap();
		self.avatList[ic] = nil;
	end;
	self.avatList[ic] =  CPlayerAvatar:new();
	--self.curModel = self.avatList[ic];
	self.avatList[ic]:CreateByVO(vo);

	local list = self.objUISceneDraw:GetMarkers();
	local indexc = index;
	if index > 4 then
		indexc = index - 4;
	end;
	local indexc = "marker"..indexc
	self.avatList[ic]:EnterUIScene(self.objUISceneDraw.objScene,list[indexc].pos,list[indexc].dir,list[indexc].scale, enEntType.eEntType_Player)
end;
--创建人物配置文件
function UIArena:GetDefaultCfgRole()
	local cfg = {};
	cfg.scale =1;
	cfg.roleZ = 0;
	return cfg;
end;
--创建配置文件
function UIArena : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	cfg.roleY = 0;
	cfg.taiZi = 0;
	return cfg;
end
-- 被挑战人物click
function UIArena : BeRoleListClick(e)
	self:ReqChaaenge(e.item.rankz)
end;
-- 发起挑战判断
function UIArena : ReqChaaenge(rank)
	local timebo = ArenaUtils:TimeIsOk()

	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end;
	if mapCfg.can_teleport == false then
		FloatManager:AddSysNotice(2005014);--已达上限
		--FloatManager:AddNormal(StrConfig["arena139"]);
		return
	end;

	if rank == ArenaModel:GetMyRank() then
		FloatManager:AddNormal(StrConfig['arena138']);
		return
	end;
	if timebo == true then
		FloatManager:AddNormal(StrConfig['arena126']);
		return
	end;

	local chabo = ArenaUtils:ChallengeNum()
	if chabo == true then
		FloatManager:AddNormal(StrConfig['arena127']);
		return
	end;

	if self.isShowWindow == true then
		self:OkSendChangllenge(true,rank)
		return
	end;
	local rankName = ArenaModel:GetBeroleName(rank)
	local okfun = function(e) self:OkSendChangllenge(e,rank) end;
	local nofun = function() end;
	local id = UIConfirmWithNoTip:Open(string.format(StrConfig["arena136"]),okfun,nofun);
	table.push(self.ErjiPanelList,id)
end;

function UIArena:OkSendChangllenge(isshow,rank)
	self.isShowWindow = isshow;
	SitController:ReqCancelSit()
	ArenaController : ReqChallenge(rank)
end;
function UIArena : Closebtn()
	UIArena : Hide();
end;
	-- notifaction
function UIArena : ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,NotifyConsts.ArenaUpFirstRank,NotifyConsts.ArenaUpChaObjectlist,NotifyConsts.ArenaSkInfoUpdata,
		NotifyConsts.ArenaUpMyInfo,
		}
end;
function UIArena : HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaHonor then
			self.objSwf.txthonor.text = MainPlayerModel.humanDetailInfo.eaHonor -- info.honor;
		end;
	elseif name == NotifyConsts.ArenaUpFirstRank then --123名list
		UIArena:DrawScene(true)
	elseif name == NotifyConsts.ArenaUpChaObjectlist then -- 被挑战对象list
		UIArena:DrawScene()
	elseif name == NotifyConsts.ArenaSkInfoUpdata then
		self:UpdataSkinfo();
	elseif name == NotifyConsts.ArenaUpMyInfo then
		self:ShowMyRoleInfoUpdata();
		self:ShowRankRewardBtnFpx();
	end;
end;
function UIArena:OnDelete()
	for i,ob in pairs(self.yanWumodelList) do
		ob:SetUILoader(nil)
	end;
	if self.objUISceneDraw then
		self.objUISceneDraw:SetUILoader(nil);
	end;
end
function UIArena : OnHide()
	-- 停止绘画模型
	if self.objUISceneDraw then
		self.objUISceneDraw:SetDraw(false)
	end;

	for i,info in pairs(self.avatList) do
		info:ExitMap();
		self.avatList[i] = nil;
	end;

	for c,yan in pairs(self.yanWumodelList) do
		yan:SetDraw(false);
	end;
	if UIRankRewardView:IsShow() then
		UIRankRewardView:Hide();
	end;
	for i,info in pairs(self.ErjiPanelList) do
		UIConfirm:Close(info)
		UIConfirmWithNoTip:Close( info )
	end;
end;


function UIArena:GetWidth()
	return 1397
end;
function UIArena:GetHeight()
	return 823
end;

function UIArena:IsTween()
	return true;
end

function UIArena:IsShowLoading()
	return true;
end

function UIArena:IsShowSound()
	return true;
end

-- function UIArena:OnResize(wWidth, wHeight)
	-- if not self.bShowState then return end
	-- self:UpdateMask()
-- end

-- function UIArena:UpdateMask()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	-- local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.mcMask._x = wWidth/2-100
	-- objSwf.mcMask._y = wHeight/2-50
	-- objSwf.mcMask._width = wWidth + 600
	-- objSwf.mcMask._height = wHeight + 70
	-- self:UpdateCloseButton();
-- end

function UIArena:UpdateCloseButton()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local wWidth, wHeight = UIManager:GetWinSize()
	-- objSwf.closebtn._x = math.min( math.max( wWidth - 50, 1400 ), 1500 )
end
