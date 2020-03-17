--[[
结婚主界面
wangshuai
]]

_G.UIMarryMain = BaseUI:new("UIMarryMain")

function UIMarryMain:Create()
	self:AddSWF("marryMainPanel.swf",true,nil)

	self:AddChild(UIMarryRingStren,"RingStren")
end;

function UIMarryMain:OnLoaded(objSwf)
		--设置模型不接受事件
	objSwf.naroleLoader.hitTestDisable = true;
	objSwf.nvroleLoader.hitTestDisable = true;

	
	objSwf.naringItem.rollOver = function() self:OnRingOver(1) end;
	objSwf.naringItem.rollOut  = function() TipsManager:Hide() end;	
	objSwf.nvringItem.rollOver = function() self:OnRingOver(0) end;
	objSwf.nvringItem.rollOut  = function() TipsManager:Hide() end;

	objSwf.skilbtn.btnskill.rollOver = function() self:OnSkiRollOver()end;
	objSwf.skilbtn.btnskill.rollOut = function() TipsManager:Hide() end;

	objSwf.dinghunPanel.btnTael.click = function() self:OnBtnTeelClick()end;
	objSwf.dinghunPanel2.btnTael.click = function() self:OnBtnTeelClick()end;

	objSwf.ProValue.rollOver = function() self:OnProOver()end;
	objSwf.ProValue.rollOut = function() TipsManager:Hide()end;
	
	objSwf.btnMarryJieShao.click = function() self:OnBtnMarryJieShaoClick()end;

	--戒指强化
	self:GetChild("RingStren"):SetContainer(objSwf.childPanel);
	objSwf.strenRing_btn.click = function() self:OnStrenRingClick()end;

end;

--面板加载的附带资源
function UIMarryMain:WithRes()
	 return {"MarryRingStrenPanel.swf"}
end

function UIMarryMain:OnStrenRingClick()
	local child = self:GetChild("RingStren");
	if UIMarryRingStren:IsShow() then 
		UIMarryRingStren:Hide();
	else
		UIMarryRingStren:Show();
	end;
end;

function UIMarryMain:OnProOver()
	TipsManager:ShowBtnTips(StrConfig["marriage048"],TipsConsts.Dir_RightDown);
end;

function UIMarryMain:OnShow()
	MarriagController:ReqMarryMainPanelInfo()
	UIMarryRingStren:Hide();
end;

function UIMarryMain:OnBtnTeelClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local mapCfg = MapPoint[10200001];
	local npcVo = {};
	for i,info in pairs(mapCfg.npc) do 
		if info.id == MarriageConsts.NpcYuelao then 
			npcVo = info;
		end;
	end;
	local completeFuc = function()
		NpcController:ShowDialog(MarriageConsts.NpcYuelao);
	end;
	MainPlayerController:DoAutoRun(10200001,_Vector3.new(npcVo.x,npcVo.y,0),completeFuc)
	
end;

function UIMarryMain:OnBtnMarryJieShaoClick()
	UIMarriageJieShaoView:Show();
end;

function UIMarryMain:UpdataShow()
	self:OnHide();
	self:SetRightUI()
	self:SetPanelText();
	self:SetRoleData();
	self:SetRingStar();
end;

function UIMarryMain:SetRingStar()
	local objSwf = self.objSwf
	if not objSwf then return end;
	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.ringLvl >= 0 then
		if roleData.ringLvl >= UIMarryRingStren.StrenMaxStar then 
			objSwf.start.star = "EquipStrenGem";
			objSwf.start.grayStar = "EquipStrenGrayGem";
			objSwf.start.value = roleData.ringLvl - UIMarryRingStren.StrenMaxStar;
		else
			objSwf.start.star = "EquipStrenStar";
			objSwf.start.grayStar = "EquipStrenGrayStar";
			objSwf.start.value = roleData.ringLvl;
		end;
	end;
end;

function UIMarryMain:OnHide()
	for i,info in pairs(self.objUIDraw) do 
		if info then 
			info:SetDraw(false);
			info:SetMesh(nil);
		end;
	end;
	for ii,ica in pairs(self.objAvatar) do 
		ica:ExitMap();
	end;
end;

function UIMarryMain:SetPanelText()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.time ~= 0 then 
		local year, month, day, hour, minute, second = CTimeFormat:todate(roleData.time,true);
		objSwf.dinghunPanel.time.htmlText = string.format('%02d-%02d-%02d',year, month, day) .. "   " .. string.format('%02d:%02d:%02d',hour, minute, second);
		objSwf.dinghunPanel._visible = true;
	else
		objSwf.dinghunPanel._visible = false;
	end;

end;

function UIMarryMain:SetRightUI()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local state = MarriageModel:GetMyMarryState()

	--print(state)
	-- debug.debug();
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then --单身 离婚

		objSwf.naName2.htmlText = StrConfig["marriage073"]
		objSwf.nvName2.htmlText = StrConfig["marriage073"]
		objSwf.time.htmlText = StrConfig["marriage073"];
		objSwf.day.htmlText = StrConfig["marriage073"];
		objSwf.skilDesc.htmlText = StrConfig["marriage073"];

		local skicfg = t_consts[186].val1;
		local skcfg = t_skill[skicfg]
		local url = ResUtil:GetSkillIconUrl(skcfg.icon,"54");
		objSwf.skilbtn.iconLoader.source = url;
		objSwf.skilDesc.htmlText =  skcfg.effectStr

		objSwf.dinghunPanel2._visible = true;
		objSwf.strenRing_btn._visible = false;
		objSwf.start._visible = false;
		objSwf.strenImg._visible = false;
		UIMarryRingStren:Hide();
	elseif state == MarriageConsts.marryReserve then 

		objSwf.naName2.htmlText = StrConfig["marriage073"]
		objSwf.nvName2.htmlText = StrConfig["marriage073"]
		objSwf.time.htmlText = StrConfig["marriage073"];
		objSwf.day.htmlText = StrConfig["marriage073"];
		objSwf.skilDesc.htmlText = StrConfig["marriage073"];

		local skicfg = t_consts[186].val1;
		local skcfg = t_skill[skicfg]
		local url = ResUtil:GetSkillIconUrl(skcfg.icon,"54");
		objSwf.skilbtn.iconLoader.source = url;
		objSwf.skilDesc.htmlText =  skcfg.effectStr
		objSwf.dinghunPanel2._visible = false;
		objSwf.strenRing_btn._visible = false;
		objSwf.start._visible = false;
		objSwf.strenImg._visible = false;
		UIMarryRingStren:Hide();
	elseif state == MarriageConsts.marryMarried then --订婚，结婚
		--结婚
		objSwf.start._visible = true;
		objSwf.strenImg._visible = true;
		objSwf.strenRing_btn._visible = true;
		objSwf.dinghunPanel2._visible = false;
		local roleData = MarriageModel.MymarryPanelInfo
		local mySex = t_playerinfo[roleData.beProf]
		if mySex then 
			mySex = mySex.sex;
			if mySex == 0 then 
				objSwf.nvName2.htmlText = roleData.beRoleName;
				objSwf.naName2.htmlText = MainPlayerModel.humanDetailInfo.eaName
			elseif mySex == 1 then 
				objSwf.naName2.htmlText = roleData.beRoleName;
				objSwf.nvName2.htmlText = MainPlayerModel.humanDetailInfo.eaName
			end;
			if state == MarriageConsts.marryReserve then
				objSwf.time.htmlText = StrConfig['marriage071'];
			else
				local year, month, day, hour, minute, second = CTimeFormat:todate(roleData.time,true);
				objSwf.time.htmlText = string.format('%02d-%02d-%02d',year, month, day)-- .."<br/>" .. string.format('%02d:%02d:%02d',hour, minute, second);
			end
			
			objSwf.day.htmlText = roleData.MaxDay;

			local skicfg = t_consts[186].val1;
			local skcfg = t_skill[skicfg]
			local url = ResUtil:GetSkillIconUrl(skcfg.icon,"54");
			objSwf.skilbtn.iconLoader.source = url;
			objSwf.skilDesc.htmlText =  skcfg.effectStr

			local maxValue= 0 ;
			local cfg = {}
			for i,info in ipairs(t_marryIntimate) do 
				if info.needIntimate > roleData.intimate then 
					maxValue = info.needIntimate;
					cfg = info;
					break;
				end;
			end;
			objSwf.ProValue.maximum = maxValue
			objSwf.ProValue.value =roleData.intimate;

			objSwf.titleImg.source = ResUtil:GetMarryQinmiIcon(cfg.imgsource)


		end;

	end;
end;

function UIMarryMain:OnRingOver(index)
	local roleDatacc = MarriageModel.MymarryPanelInfo
	if roleDatacc and roleDatacc.ringId ~= 0 then 
		local cfg = t_marryRing[roleDatacc.ringId]
		if not cfg then return end;
		local itemTipsVO = ItemTipsUtil:GetItemTipsVO(cfg.itemId, 1);
		if not itemTipsVO then return end;
		itemTipsVO.ringLvl = MarriageModel:GetQingYuanVal()
		itemTipsVO.ringType = MarriageModel:GetRingType();
		local mysex = t_playerinfo[MainPlayerModel.humanDetailInfo.eaProf];
		mysex = mysex.sex or -1;
		if index == mysex then 
			itemTipsVO.ringStren = MarriageModel:GetMyStrenLvl()
		else
			itemTipsVO.ringStren = 0;
		end;
		TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
	end;
end;

function UIMarryMain:SetRoleData()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	

	--婚姻状态
	local state = MarriageModel:GetMyMarryState()
	--print("自己的婚姻状态",'--------',state)
	--自己
	local myPlayerProf = MainPlayerModel.humanDetailInfo.eaProf
	local mySex = t_playerinfo[myPlayerProf].sex;
	local mySexStr = "";
	if mySex == 0 then 
		mySexStr = "nv"
	elseif mySex == 1 then 
		mySexStr = "na"
	end;
	-- 对方
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then --单身 离婚
		--夫妻称号，空
		for i=0,1 do 
			local dd = "";
			if i == 0 then 
				dd = "nv"
			elseif i == 1 then 
				dd = "na"
			end;
			objSwf.natitle.htmlText = ""
			objSwf.nvtitle.htmlText = ""
			objSwf[dd.."UnionName"].htmlText = ""
			objSwf[dd.."Name"].htmlText = ""
			objSwf[dd.."ringItem"]:setData({});
			objSwf[dd.."Fight"]._visible = false;
			objSwf.role[dd]._visible = true;
		end;
	elseif state == MarriageConsts.marryReserve or state == MarriageConsts.marryMarried then --订婚，结婚
		--夫妻称号，
		local roleData = MarriageModel.MymarryPanelInfo
		local sex = t_playerinfo[roleData.beProf];
		if sex then
				sex = sex.sex;
			local sexStr = ""
			if sex == 0 then  -- 女
				sexStr = "nv"
			elseif sex == 1 then  --男
				sexStr = "na"
			end;	
			objSwf[sexStr.."title"].htmlText = MainPlayerModel.humanDetailInfo.eaName .. StrConfig["marriage0"..sexStr]
			objSwf[mySexStr.."title"].htmlText = roleData.beRoleName .. StrConfig["marriage0"..mySexStr]

			--对方数据
			objSwf[sexStr.."UnionName"].htmlText = roleData.beUnionName;
			objSwf[sexStr.."Name"].htmlText = roleData.beRoleName;
			-- 戒指
			local cfg = t_marryRing[roleData.ringId]
			if cfg then 
				local itemvo = RewardSlotVO:new()
				itemvo.id = cfg.itemId
				objSwf[sexStr.."ringItem"]:setData(itemvo:GetUIData());
				objSwf[mySexStr.."ringItem"]:setData(itemvo:GetUIData());
			else
				objSwf[sexStr.."ringItem"]:setData({});
				objSwf[mySexStr.."ringItem"]:setData({});
			end;
			objSwf[sexStr.."Fight"].num = roleData.fight;
			objSwf[sexStr.."Fight"]._visible = true;
			objSwf.role[sexStr]._visible = false;

			local vo = {};
			vo.prof = roleData.beProf;
			if roleData and roleData.marryType ~= 0 then 
				vo.marryType = roleData.marryType
			else
				vo.marryType = 2;
			end;
			--vo.marryType = roleData.marryType
			UIMarryMain:DrawRoleSelf(objSwf[sexStr..'roleLoader'],vo)
		end;
	end;
	--自己
	local name =  MainPlayerModel.humanDetailInfo.eaName;
	local unionName = UnionModel:GetMyUnionName();
	objSwf[mySexStr.."UnionName"].htmlText = unionName or "";
	objSwf[mySexStr.."Name"].htmlText = name;
	objSwf[mySexStr.."Fight"].num = MainPlayerModel.humanDetailInfo.eaFight;
	objSwf[mySexStr.."Fight"]._visible = true
	objSwf.role[mySexStr]._visible = false;
	local roleData = {};
	roleData.prof = MainPlayerModel.humanDetailInfo.eaProf;

	local roleDatacc = MarriageModel.MymarryPanelInfo
	if roleDatacc and roleDatacc.marryType ~= 0 then 
		roleData.marryType = roleDatacc.marryType;
	else
		roleData.marryType = 2;
	end;
	UIMarryMain:DrawRoleSelf(objSwf[mySexStr..'roleLoader'],roleData)
end;


--技能
function UIMarryMain:OnSkiRollOver()
	local state = MarriageModel:GetMyMarryState()
	if state == MarriageConsts.marryReserve or state == MarriageConsts.marryMarried then

		local roleData = MarriageModel.MymarryPanelInfo
		local cfg = t_marryRing[roleData.ringId]
		if cfg then 
			local id = cfg.skill;
			if not id then return end;
			TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id},TipsConsts.ShowType_Normal,
								TipsConsts.Dir_RightUp);

		end;
	end;
end;


--画模型

UIMarryMain.objAvatar = {};
UIMarryMain.objUIDraw = {};

function UIMarryMain:DrawRoleSelf(obj,data)
	local uiLoader = obj

	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = data.prof;
	vo.arms = 0
	vo.dress = 0
	local cfg = t_marry[data.marryType]
	if not cfg then return end;
	local fish = split(cfg.item,",");
	vo.fashionsHead = toint(fish[3])--703
	vo.fashionsArms = toint(fish[1])--701
	vo.fashionsDress = toint(fish[2])-- 702
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()0/
	vo.wing = 0
	if self.objAvatar[data.prof] then
		self.objAvatar[data.prof]:ExitMap();
		self.objAvatar[data.prof] = nil;	
	end
	self.objAvatar[data.prof] = CPlayerAvatar:new();
	self.objAvatar[data.prof]:CreateByVO(vo);
	--
	local prof = data.prof; --取玩家职业
    if not self.objUIDraw[data.prof] then
		self.objUIDraw[data.prof] = UIDraw:new("rolePanelPlayerMarry"..data.prof, self.objAvatar[data.prof], uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw[data.prof]:SetUILoader(uiLoader);
		self.objUIDraw[data.prof]:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw[data.prof]:SetMesh(self.objAvatar[data.prof]);
	end
	self.meshDir = 0;
	self.objAvatar[data.prof].objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw[data.prof]:SetDraw(true);
	self.objAvatar[data.prof]:PlayLianhualuAction()
end
