--[[
卓越引导UI
lizhuangzhuang
2015年8月2日16:31:03
]]

_G.UIZhuoyueGuide = BaseUI:new("UIZhuoyueGuide");

UIZhuoyueGuide.objUIDraw = nil;
UIZhuoyueGuide.objAvatar = nil;

UIZhuoyueGuide.currId = 0;--当前id
UIZhuoyueGuide.selectId = 0;--选中的id

function UIZhuoyueGuide:Create()
	self:AddSWF("zhuoyueGuide.swf",true,"center");
end

function UIZhuoyueGuide:OnLoaded(objSwf)
	objSwf.roleLoader.hitTestDisable = true;
	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.list.itemRollOver = function(e) self:OnRoleItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	for i=1,11 do
		objSwf["btn"..i].click = function() self:OnBtnLinkClick(i-1); end
	end
	for i=1,2 do
		objSwf["btnPage"..i].click = function() self:SelectZhuoYue(i); end
		local cfg = t_zhuoyueguide[i];
		if cfg then
			objSwf["btnPage"..i].label = cfg.name;
		end
	end
	objSwf.mcTitle:stop();
	objSwf.mcFight:stop();
	objSwf.mcGet:stop();
end

function UIZhuoyueGuide:IsTween()
	return true;
end

function UIZhuoyueGuide:IsShowLoading()
	return true;
end

function UIZhuoyueGuide:GetPanelType()
	return 1;
end

function UIZhuoyueGuide:IsShowSound()
	return true;
end

function UIZhuoyueGuide:GetWidth()
	return 1243;
end

function UIZhuoyueGuide:GetHeight()
	return 772;
end

function UIZhuoyueGuide:OnShow()
	local id = ZhuoyueGuideModel:GetId();
	if id == 0 then
		self.currId = ZhuoyueGuideModel.maxId;
	else
		self.currId = id;
	end
	self:SelectZhuoYue(self.currId);
end

function UIZhuoyueGuide:OnHide()
	self.selectId = 0;
	self.currId = 0;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end

function UIZhuoyueGuide:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIZhuoyueGuide:SelectZhuoYue(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,2 do
		if i == id then
			objSwf["btnPage"..i].selected = true;
		else
			objSwf["btnPage"..i].selected = false;
		end
	end
	if id == self.selectId then return; end
	self.selectId = id;
	self:Show3DRole();
	self:ShowRoleEquip();
	self:ShowInfo();
end


function UIZhuoyueGuide:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_zhuoyueguide[self.selectId];
	if not cfg then return; end
	objSwf.mcTitle:gotoAndStop(cfg.index);
	objSwf.mcFight:gotoAndStop(cfg.index);
	objSwf.mcGet:gotoAndStop(cfg.index);
	objSwf.tfText.htmlText = cfg.text;
	--
	local text = "";
	local nametext = "";
	local attrlist = AttrParseUtil:Parse(cfg.attr);
	for i,vo in ipairs(attrlist) do
		nametext = nametext .. string.format("全%s提升：<br/>",enAttrTypeName[vo.type]);
		text = text .. string.format("%s%%（最高）<br/>",vo.val)
	end
	objSwf.tfAttrName.htmlText = nametext;
	objSwf.tfAttr.htmlText = text;
	--
	for i=BagConsts.Equip_WuQi,BagConsts.Equip_JieZhi2 do
		local tujingCfg = t_zhuoyuetujing[cfg.superNum*100+i];
		objSwf["btn"..(i+1)].htmlLabel = "<u>"..tujingCfg.tujing.."</u>";
	end
end

--点击链接
function UIZhuoyueGuide:OnBtnLinkClick(pos)
	if not pos then return; end
	local cfg = t_zhuoyueguide[self.selectId];
	if not cfg then return; end
	local tujingCfg = t_zhuoyuetujing[cfg.superNum*100+pos];
	local paramlist = split(tujingCfg.param,",");
	NoticeScriptManager:DoScript(tujingCfg.script,paramlist);
end

function UIZhuoyueGuide:Show3DRole()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_zhuoyueguide[self.selectId];
	if not cfg then return; end
	local key = "showEquip" .. MainPlayerModel.humanDetailInfo.eaProf;
	local info = MainPlayerModel.sMeShowInfo;
	local arms = info.dwArms;
	local dress = info.dwDress;
	local tujingCfg = t_zhuoyuetujing[cfg.superNum*100+0];
	if tujingCfg then
		arms = tujingCfg[key];
	end
	local tujingCfg = t_zhuoyuetujing[cfg.superNum*100+2];
	if tujingCfg then
		dress = tujingCfg[key];
	end
	local vo = {};
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = arms;
	vo.dress = dress;
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = 0
	vo.fashionsArms = 0
	vo.fashionsDress = 0
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = 0;
	vo.suitflag = info.suitflag;
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("zhuoyueGuide", self.objAvatar, objSwf.roleLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(objSwf.roleLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	self.objAvatar:PlayShenzhuangIdleAction()
	self.objAvatar:PlayShenzhuangAction()
end

function UIZhuoyueGuide:ShowRoleEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_zhuoyueguide[self.selectId];
	if not cfg then return; end
	--
	local key = "showEquip" .. MainPlayerModel.humanDetailInfo.eaProf;
	objSwf.list.dataProvider:cleanUp();
	for i=BagConsts.Equip_WuQi,BagConsts.Equip_JieZhi2 do
		local tujingCfg = t_zhuoyuetujing[cfg.superNum*100+i];
		local slotVo = ShowEquipSlotVO:new();
		slotVo.hasItem = true;
		slotVo.pos = i;
		slotVo.tid = tujingCfg[key];
		objSwf.list.dataProvider:push(slotVo:GetUIData());
	end
	objSwf.list:invalidateData();
	--
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local totalNum = 0;
	for i=BagConsts.Equip_WuQi,BagConsts.Equip_JieZhi2 do
		if self.selectId < self.currId then
			objSwf["tf"..(i+1)].text = "(1/1)";
			totalNum = totalNum + 1;
		else
			local bagItem = bagVO:GetItemByPos(i);
			if not bagItem then
				objSwf["tf"..(i+1)].text = "(0/1)";
			else
				local equipCfg = t_equip[bagItem:GetTid()];
				if not equipCfg then print('Error!! no equip %s' .. bagItem:GetTid())break end
				local newSuperVO = EquipModel:GetNewSuperVO(bagItem:GetId());
				local num = 0;
				if newSuperVO then
					for _,vo in ipairs(newSuperVO.newSuperList) do
						if vo.id > 0 then
							num = num + 1;
						end
					end
				end
				if num >= cfg.superNum and equipCfg.level >= cfg.order then
					objSwf["tf"..(i+1)].text = "(1/1)";
					totalNum = totalNum + 1;
				else
					objSwf["tf"..(i+1)].text = "(0/1)";
				end
			end
		end
	end
	--进度条
	objSwf.siP.maximum = cfg.equipNum;
	objSwf.siP.value = totalNum;
	objSwf.tfP.text = totalNum.."/"..cfg.equipNum;
end

function UIZhuoyueGuide:OnRoleItemOver(e)
	if not e.item then return; end
	local cfg = t_zhuoyueguide[self.selectId];
	if not cfg then return; end
	local tujingCfg = t_zhuoyuetujing[cfg.superNum*100+e.item.pos];
	local key = "showEquip" .. MainPlayerModel.humanDetailInfo.eaProf;
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(tujingCfg[key]);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end