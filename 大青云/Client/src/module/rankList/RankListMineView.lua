--[[
排行榜， 至尊殿堂
	wangshuai
]]
_G.UIRankSupreme = BaseUI:new("UIRankSupreme")

UIRankSupreme.defaultCfg = {
	EyePos = _Vector3.new(0,-20,19),
	LookPos = _Vector3.new(0,1,8),
	VPort = _Vector2.new(180,290),
	Rotation = 0
};
UIRankSupreme.avatList = {};
UIRankSupreme.modelList = {};
UIRankSupreme.curRolelist = {};
UIRankSupreme.startIndex = 1;
function UIRankSupreme:Create()
	self:AddSWF("RanklistMinePanel.swf",true,nil);
end;

function UIRankSupreme:OnLoaded(objSwf)
	objSwf.rolelist.itemClick = function(e) self:ItemClick(e)end;
	for i=1,3 do
		objSwf["roleloaer"..i].hitTestDisable = true;
	end;

	objSwf.leftBtn.click = function() self:LeftBtnClick()end;
	objSwf.rightBtn.click = function() self:RightBtnClick()end;
end;


function UIRankSupreme:OnShow()
	--RankListController:ReqRanlist(0);
	self.startIndex = 1;
	self.avatList = {};
	RankListController:ReqRanlist(0);
	-- 关闭父级子ui，right
	UIRanklistSuit:HideChildPanel()
	--self:ShowRoleList();
end;


function UIRankSupreme:LeftBtnClick()
	self.startIndex = self.startIndex - 1;
	self:ShowRole();
	self:UpdataCurChangeRoleBtn();
end;

function UIRankSupreme:RightBtnClick()
	self.startIndex = self.startIndex + 1;
	self:ShowRole();
	self:UpdataCurChangeRoleBtn();
end;

function UIRankSupreme:UpdataCurChangeRoleBtn()
	local objSwf = self.objSwf;
	local index = self.startIndex;
	local roleLenght = #self.curRolelist;


   
	objSwf.leftBtn.disabled = index <= 1 or roleLenght <= RankListConsts.ranline;
	objSwf.rightBtn.disabled = roleLenght <= RankListConsts.ranline or index+2 >= roleLenght


end;

function UIRankSupreme:OnDelete()
	for _,objUIDraw in pairs(self.modelList) do
		objUIDraw:SetUILoader(nil);
	end
end

-- is doubi
function UIRankSupreme:ItemClick(e)
	local showui = e.item.rankIndex;
	local index = RankListConsts.OpenOrder[showui]
	local cfg = RankListConsts.TabPage[index];
	if not cfg then return end;
	UIRanklistSuit.JumpTabeVal = RankListConsts.RankName[index];
	UIRankList:OnTabButtonClick("suit")
	--UIRanklistSuit:JumpTabe(index)
end;
function UIRankSupreme:RoleDraw(id,vo)	
	if vo.prof <= 0 or vo.prof > 4 then print("探出了啊");return end;
	local objSwf = UIRankSupreme.objSwf;
	local loader = objSwf["roleloaer"..id]
	if self.avatList[id] ~= nil then 
		self.avatList[id]:ExitMap();
		self.avatList[id] = nil;
	end;
	self.avatList[id] = CPlayerAvatar:new();
	self.avatList[id]:CreateByVO(vo);
	
	self.curModel = self.avatList[id];
	--print(id,vo.prof)
	local draw1 = UIDrawRankList[id];
	if not draw1 then draw1 = {}; end;
	local drawcfg = draw1[vo.prof];
	 if not drawcfg then 
		drawcfg = self:GetDefaultCfg()
	end;
	if not self.modelList[id] then 
	self.modelList[id] = UIDraw:new("RanklistDrawRole"..id,self.avatList[id], loader,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIRole",vo.prof);
	else
		self.modelList[id]:SetUILoader(loader);
		self.modelList[id]:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.modelList[id]:SetMesh(self.avatList[id]);
	end;
	self.modelList[id]:SetDraw(true);
	self.avatList[id]:StopAllAction();
	self.avatList[id]:PlayRanklistAction()
	

end;

-- 创建配置文件
function UIRankSupreme:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIRankSupreme:ShowRoleList()
	local objSwf = self.objSwf;
	self.curRolelist = {};
	---if RankListModel:GetCurListboo(0) == true then 
		--RankListModel:SetCurListboo(0,false);
		--return ;
	--end;
	local list = RankListModel:GetRankFrist()
	--objSwf.rolelist.dataProvider:cleanUp();
	local num = 0;
	for i,index  in ipairs(RankListConsts.OpenOrder) do 
		local info = list[index]
		if not info then break end;
		if info.role <= 0 then break end;
		local cfg = t_ranking[index];
		if not cfg then  return end
		local isOpen = RankListUtils:IsOpen(cfg.funid)
		local rolelvl = MainPlayerModel.humanDetailInfo.eaLevel;
		local name = cfg.name;
		if GMModule:IsGM() then
			local vo = {};
			--vo.name = info.roleName;
			--vo.fight = info.fight;
			vo.ranktc = info.role;
			vo.rankIndex = i;
			local voc = {};
			voc[1] = vo;
			voc[2] = info;
			table.push(self.curRolelist,voc);
			num = num + 1;
		else
			if isOpen then
				local vo = {};
				vo.name = info.roleName;
				vo.fight = info.fight;
				-- if num == 3 then 
				-- 	vo.iconUrl = ResUtil:GetUnionIconImg(RankListConsts.RankName[info.role],true);
				-- else
				-- 	vo.iconUrl = ResUtil:GetUnionIconImg(RankListConsts.RankName[info.role]);
				-- end;
				--vo.iconUrl = info.role
				vo.ranktc = info.role;
				vo.rankIndex = i;
				--vo.index = i;

				local voc = {};
				voc[1] = vo;
				voc[2] = info;
				table.push(self.curRolelist,voc);
				num = num + 1;
				--objSwf.rolelist.dataProvider:push(UIData.encode(vo));
				--self:RoleDraw(i,info)
			end;
		end
	end;
	--objSwf.rolelist:invalidateData();
	self:ShowRole();
	self:UpdataCurChangeRoleBtn()


end;

function UIRankSupreme:ShowRole()
	local objSwf = self.objSwf;
	local list = self:GetRoleInfo(self.curRolelist);
	objSwf.rolelist.dataProvider:cleanUp();
	for i,info in ipairs(list) do 
		if i == 3 then 
			info[1].iconUrl = ResUtil:GetUnionIconImg(RankListConsts.RankName[info[1].ranktc]);
		else
			info[1].iconUrl = ResUtil:GetUnionIconImg(RankListConsts.RankName[info[1].ranktc]);
		end;
		info[1].index = i;
		objSwf.rolelist.dataProvider:push(UIData.encode(info[1]));
		self:RoleDraw(i,info[2])
	end;
	objSwf.rolelist:invalidateData();
end;

function UIRankSupreme:GetRoleInfo(list)
	local index = self.startIndex;
	local maxindex = index + 2;
	local listvo = {};
	-- print(index,maxindex)
	-- trace(list)
	for i=index,maxindex do 
		table.push(listvo,list[i])
	end;
	return listvo;
end;

function UIRankSupreme:OnHide()
	for i,info in pairs(self.modelList) do 
		if info then 
			info:SetDraw(false)
			info:SetMesh(nil)
		end;
	end; 
	if self.avatList then 
		for ca,aoe in pairs(self.avatList) do 
			aoe:ExitMap();
			self.avatList[ca] = nil;
		end;
		self.avatList = nil;
	end;
end;

------ 消息处理 ---- 
function UIRankSupreme:ListNotificationInterests()
	return {
		NotifyConsts.RanklistAllRoleInfo,
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIRankSupreme:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.RanklistAllRoleInfo then 
		-- 显示人物list
		self:ShowRoleList();
	elseif name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaLevel then 
			--等级变化 重新刷新，
			RankListController:ReqRanlist(0);
			--self:ShowRoleList();
		end;
	end;
end;


