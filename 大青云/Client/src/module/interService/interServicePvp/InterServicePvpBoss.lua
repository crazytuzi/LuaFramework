--[[
	跨服boss
	2015年10月12日, PM 08:15:41
]]

_G.UIInterServiceBoss = BaseUI:new('UIInterServiceBoss');
function UIInterServiceBoss:Create()
	self:AddSWF('interServerBossPanel.swf',true,nil);
end

function UIInterServiceBoss:OnLoaded(objSwf)
	objSwf.btnEnter.click = function() 
		if TeamModel:IsInTeam() then 
			FloatManager:AddNormal(StrConfig["dominateRoute0211"]);
			return 
		end;
		
		if ArenaBattle.inArenaScene ~= 0 then
			FloatManager:AddNormal(StrConfig["activity105"]);
			return
		end		

		local mapId = CPlayerMap:GetCurMapID();
		local mapCfg = t_map[mapId];
		if not (mapCfg.type==1 or mapCfg.type==2) then
			FloatManager:AddNormal(StrConfig['activity105']);
			return;
		end
		
		SitController:ReqCancelSit()
		InterServicePvpController:ReqEnterCrossBoss()
	end
	local cfg = t_consts[160]
	local strList = split(cfg.param, '#')
	
	objSwf.txtTime.htmlText = string.format(StrConfig['interServiceDungeon31'],strList[1],strList[2])
	objSwf.txtTiaojian.htmlText = StrConfig['interServiceDungeon29']
	
	objSwf.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['interServiceDungeon30'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function () TipsManager:Hide(); end
	
	local constsCfg = t_consts[165]
	if constsCfg then
		local reward = t_consts[165].param
		objSwf.rewardList.dataProvider:cleanUp()
		objSwf.rewardList.dataProvider:push( unpack( RewardManager:Parse( reward ) ) )
		objSwf.rewardList:invalidateData()	
	end
	
	RewardManager:RegisterListTips( objSwf.rewardList )
end

function UIInterServiceBoss:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	InterServicePvpController:ReqCrossBossInfo()
	self:DrawScene()
end

function UIInterServiceBoss:ListNotificationInterests()
	return {
		NotifyConsts.ISKuafuMianRank,
		NotifyConsts.ISKuafuBossMemInfo
	}
end

function UIInterServiceBoss:InitInfo()
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	if InterServicePvpModel.bossRankList then
		for i = 1,5 do 
			objSwf['boss'..i].txtBossName.text = InterServicePvpModel.bossRankList[i].monsterName
			if InterServicePvpModel.bossRankList[i].firstroleName and InterServicePvpModel.bossRankList[i].firstroleName ~= '' then
				objSwf['boss'..i].txtBossHit.text = InterServicePvpModel.bossRankList[i].firstroleName
			else
				objSwf['boss'..i].txtBossHit.text = StrConfig['dungeon231']
			end
			
			if InterServicePvpModel.bossRankList[i].roleName and InterServicePvpModel.bossRankList[i].roleName ~= '' then
				objSwf['boss'..i].txtBossKill.text = InterServicePvpModel.bossRankList[i].roleName
			else
				objSwf['boss'..i].txtBossKill.text = StrConfig['dungeon231']
			end
		end
	end
end

function UIInterServiceBoss:SetBossMemInfo()
	local objSwf = self.objSwf
	if not objSwf then return end	

	local bossMemList = InterServicePvpModel.bossMemList
	objSwf.txtMem.text = ''
	local memTxt = ''
	if bossMemList then
		for k,v in pairs(bossMemList) do
			memTxt = memTxt..v.roleName..'、'
		end	
	end		
	memTxt = string.sub(memTxt,1,-2)
	objSwf.txtMem.text = memTxt
end

function UIInterServiceBoss:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end 

	if name == NotifyConsts.ISKuafuMianRank then
		self:InitInfo()		
	elseif name == NotifyConsts.ISKuafuBossMemInfo then
		self:SetBossMemInfo()
	end	
end


function UIInterServiceBoss:OnDelete()
	if self.objUISceneDraw then
		self.objUISceneDraw:SetUILoader(nil);
	end
end

function UIInterServiceBoss:OnHide()
	-- 停止绘画模型
	if self.objUISceneDraw then 
		self.objUISceneDraw:SetDraw(false)
	end;
end;

_G.InterServiceBossDrawSceneUI = "InterServiceBossDrawSceneUI" 
function UIInterServiceBoss:DrawScene(isFrist)
	local objSwf = self.objSwf;
	if not objSwf then return end	
	
	if not self.viewPort then self.viewPort = _Vector2.new(1200, 720); end
	if not self.objUISceneDraw then
		self.objUISceneDraw = UISceneDraw:new(_G.InterServiceBossDrawSceneUI, objSwf.scene_load, self.viewPort, true);
	end
	self.objUISceneDraw:SetUILoader( objSwf.scene_load )	
	local src = "kf_boss_ui.sen"
	self.objUISceneDraw:SetScene(src, function()
		
	end );	
	self.objUISceneDraw:SetDraw( true );
end;