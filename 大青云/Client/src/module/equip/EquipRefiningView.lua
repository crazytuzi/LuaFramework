--[[
装备炼化
wangshuai
]]

_G.UIRefinView = BaseUI:new("UIRefinView");
	
UIRefinView.CurPos = 0;
UIRefinView.curLinkId = 0;
UIRefinView.linkBtns = {};

function UIRefinView:Create()
	self:AddSWF("equipRefinPanel.swf",true,nil)
end;	

function UIRefinView:OnLoaded(objSwf)
	objSwf.roleLoaderRefin.hitTestDisable = true

	objSwf.rolelist.itemClick = function (e) self:RoleItemClick(e) end;

	objSwf.rule.rollOver = function() self:RuleOver()end;
	objSwf.rule.rollOut = function() TipsManager:Hide();end;
	objSwf.autoUplvl.click = function() self:AutoUplvl() end;
	--objSwf.autoUplvl.rollOver = function() self:AutoTipsShow() end;
	--objSwf.autoUplvl.rollOut = function() 
										-- TipsManager:Hide() 
										-- self.objSwf.overtips_mc._visible = false;
										-- end;

	objSwf.textOver.rollOver = function() self:OnTextOver()end;
	objSwf.textOver.rollOut  = function() TipsManager:Hide()end;
	objSwf.textOverShi.rollOver = function() self:OnQianghuaShiRollOver()end;
	objSwf.textOverShi.rollOut  = function() TipsManager:Hide()end;
	objSwf.textOver1.rollOver = function() self:OnTextOver()end;
	objSwf.textOver1.rollOut  = function() TipsManager:Hide()end;
	objSwf.textOverShi1.rollOver = function() self:OnQianghuaShiRollOver()end;
	objSwf.textOverShi1.rollOut  = function() TipsManager:Hide()end;
	objSwf.fpxImg.playOver = function() self:OverFpxImg()end;
	objSwf.fpxImg._visible = false;
end;
--鼠标悬浮属性名
function UIRefinView:OnQianghuaShiRollOver()
	local cfg = t_refin[1];
	TipsManager:ShowItemTips(cfg.itemid)
end
function UIRefinView:OnShow()
	local objSwf = self.objSwf;
	objSwf.fpxImg._visible = false;
	self.CurPos = 0;
	self:GetRoleItemList();
	self:ShowRefinLink();
	self:DrawRole();
	self:InitVip()
	self:GetAllAtbAdd();
	self:SetXiaohao();
	self.objSwf.overtips_mc._visible = false;
end

function UIRefinView:InitVip()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- VIP权限
	-- if VipController:GetIsEquipBack() == 1 then 
		-- objSwf.btnVipBack.disabled = false
	-- else
		-- objSwf.btnVipBack.disabled = true
	-- end
	-- objSwf.btnVipBack.click = function() UIVipBack:Open(VipConsts.TYPE_QIANGHUA) end
	
	-- objSwf.btnVipBack.rollOver = function() self:OnBtnVipBackRollOver(); end
	-- objSwf.btnVipBack.rollOut  = function()  self:OnBtnVipBackrollOut();  end
end

function UIRefinView:GetAllAtbAdd()
	local objSwf = self.objSwf;
	local strname = {28,29,20,32,31,30,33}
	local list = EquipModel:GetRefinList()
	local atblist = {};
	local nextlist = {};
	for i=0,10 do 
		local info = list[i]
		if not info then 
			local id = i*10000+0;
			info = {};
			info.id = id;
		end;
		local cfg = t_refin[info.id];
		local strname = AttrParseUtil.AttMap[cfg.attr];
		if atblist[strname] then 
			atblist[strname] = atblist[strname] + cfg.addVal;
		else
			atblist[strname] = cfg.addVal;
		end;
		local nextId = cfg.nextid;
		local necfg = t_refin[nextId];
		if necfg then 
			local sname = AttrParseUtil.AttMap[necfg.attr];
			if nextlist[sname] then 
				nextlist[sname] = nextlist[sname] + necfg.addVal;
			else
				nextlist[sname] = necfg.addVal;
			end;
		end;
	end;
	local str = '';
	local fightList = {};
	for i,info in pairs(strname) do
		local val = atblist[info] or 0;
		local vo = {};
		vo.type = info;
		vo.val = val;
		table.push(fightList,vo)
		local  name = enAttrTypeName[info]
		local n1 = string.sub(name,1,3)
		local n2 = string.sub(name,4,6)
		str = str .. "<font color='#ec8e11'>"..n1.."    "..n2..":<font/><font color='#f9f5eb'>      "..val.."<br/><br/>";
	end;
	objSwf.allAtb_txt.htmlText = str;
	local fight = EquipUtil:GetFight(fightList);
	objSwf.fightLoader.num = fight
	--下一级预览属性
	for i,info in pairs(atblist) do 
		local val = info
		local nexvat = nextlist[i] or 0;
		if nexvat then 
			nextlist[i] = nexvat - val;
		end;
	end;
	local nextFightList = {};
	local nextstr = "";
	for pa,po in pairs(strname) do 
		local val = nextlist[po] or 0;
		if val then 
			local vo = {};
			vo.type = po;
			vo.val = val;
			table.push(nextFightList,vo)
			nextstr = nextstr .. "<font color='#00ff00'>"..val.."</font><br/><br/>";
		end;
	end;
	local nextfight = EquipUtil:GetFight(nextFightList);
	objSwf.overtips_mc.nextfight_txt.htmlText = nextfight
	objSwf.overtips_mc.nextallAtb_txt.htmlText = nextstr
end;



function UIRefinView:SetXiaohao()
	local objSwf = self.objSwf;
	local lvl = 300;
	local id = 0;
	local list = EquipModel:GetRefinList()
	for i,info in pairs(list) do 
		if info.lvl < lvl then 
			lvl = info.lvl;
			id = info.id;
		end;
	end;
	local cfg = t_refin[id];
	local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold; 
	local color = curlingli < cfg.consume and "#FF0000" or "#00FF00";
	objSwf.consumetxt.htmlLabel = string.format(StrConfig['smithing026'], color,cfg.consume) 
	local color = curlingli < cfg.consume*11 and "#FF0000" or "#00FF00";
	objSwf.consumetxtAkey.htmlLabel = string.format(StrConfig['smithing026'], color,cfg.consume*11) 
	
	--道具消耗
	local has = BagModel:GetItemNumInBag(cfg.itemid);
	local color = has < cfg.number and "#FF0000" or "#00FF00";
	objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[cfg.itemid].name,has..'/'.. cfg.number );
	color = has < 11 and "#FF0000" or "#00FF00";
	objSwf.tfNeedItemAkey.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[cfg.itemid].name,has..'/'..(cfg.number*11) );
end;


function UIRefinView:OnTextOver()
	TipsManager:ShowBtnTips( StrConfig["equip914"],TipsConsts.Dir_RightDown)
end;

function UIRefinView:OnDelete()
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
	for k,_ in pairs(self.linkBtns) do
		if self.linkBtns[k] then self.linkBtns[k]:removeMovieClip(); end
		self.linkBtns[k] = nil;
	end
end;

function UIRefinView:RoleItemOver(e)
	if not e.item then return end;
	if not e.item.pos then return end;
	local pos = e.item.pos
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIRefinView:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	for k,_ in pairs(self.linkBtns) do
		if self.linkBtns[k] then self.linkBtns[k]:removeMovieClip(); end
		self.linkBtns[k] = nil;
	end
	UIVipBack:Hide()
end;

function UIRefinView:AutoTipsShow()
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	if myLevel == 300 then 
		return 
	end;

	local lvl = 300;
	local id = 0;
	local list = EquipModel:GetRefinList()
	for i,info in pairs(list) do 
		if info.lvl < lvl then 
			lvl = info.lvl;
			id = info.id;
		end;
	end;
	local cfg = t_refin[id];

	TipsManager:ShowBtnTips(string.format(StrConfig['equip909'],cfg.consume,cfg.consume*11),TipsConsts.Dir_RightDown); 
	self.objSwf.overtips_mc._visible = true;
end

UIRefinView.lastSendTime = 0;
function UIRefinView:AutoUplvl()
    --self:SetXiaohao()
	local bOk = false
	local nError = 0
	for i = 1, 11 do
		local nErr = 0
		bOk, nErr = self:OnisLvlUpOk(i-1)
		if nError == 0 then
			nError = nErr
		end
		if bOk then
			break
		end
	end
	if not bOk then
		if nError == 4 then 
			FloatManager:AddNormal(StrConfig["equip00000001"]);
			print("---------------------------------------------------------------------")
		elseif nError == 2 then 
			FloatManager:AddNormal(StrConfig["equip910"]);
		elseif nError == 3 then 
			FloatManager:AddNormal(StrConfig["equip911"]);
		elseif nError == 1 then 
			FloatManager:AddNormal(StrConfig["equip904"]);		
		end;
		return
	end
	if GetCurTime() - self.lastSendTime < 100 then
		return;
	end
	self.lastSendTime = GetCurTime();

	self:OnGuideClick() -- 点击任务接口
	EquipController:ReqrefinAutoLvlUp()
	--SoundManager:PlaySfx(2034);
	UIVipBack:Hide()
end;

function UIRefinView:BtnGoupClick()

	self:OnGuideClick() -- 点击任务接口

	local pos = self.CurPos;
	local result,Type = self:OnisLvlUpOk();
	if Type ~= 0 then 
		if Type == 4 then 
			FloatManager:AddNormal(StrConfig["equip00000001"]);
			print("---------------------------------------------------------------------")
		elseif Type == 2 then 
			FloatManager:AddNormal(StrConfig["equip910"]);
		elseif Type == 3 then 
			FloatManager:AddNormal(StrConfig["equip911"]);
		elseif Type == 1 then 
			FloatManager:AddNormal(StrConfig["equip904"]);		
		end;
		return
	end;
	EquipController:ReqRefinLvlUp(pos)
	SoundManager:PlaySfx(2005);
	UIVipBack:OnHide()
end;

function UIRefinView:BtnGoupOver()

	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return end;
	local item = bagVO:GetItemByPos(self.CurPos);
	if not item then return end;
	local objSwf = self.objSwf;
	objSwf.Uplook._visible = true;
	objSwf.imgup._visible = true;
end;

function UIRefinView:OnisLvlUpOk(pos)
	local pos = pos or self.CurPos;
	local serCfg = EquipModel:GetRefinInfo(pos); -- 当前
	local lvl = 0;
	if not serCfg then 
		lvl = 1;
	else
		lvl = serCfg.lvl;
	end;

	if lvl > 300 then 
		return false,3;
	end;

	local id = pos * 10000 + lvl;
	local cfg = t_refin[id];

	local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if curlingli < cfg.consume then 
	print("------------------------------zzzzzzqqqqqqqqqq")
		return false,1;
	end;
	--道具消耗
	local curDaoju = BagModel:GetItemNumInBag(cfg.itemid);
	if curDaoju < cfg.number then
	print("------------------------------qqqqqqqqqq")
	    return false,4;
	end;
	
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel
	if lvl >= mylvl then 
		return false,2;
	end; 
	
	return true,0;
end;

function UIRefinView:RoleItemClick(e)
	if not e.item then return end;
	if not e.item.pos then return end;
	local pos = e.item.pos
	self.CurPos = pos;
	--self:SelectRoleList()
end;

function UIRefinView:SelectRoleList()
	local pos = self.CurPos;
	local objSwf = self.objSwf;
	objSwf.rolelist.selectedIndex = pos;
	local vo = {};
	local curCfg = EquipModel:GetRefinInfo(pos); -- 当前
	vo.iconUrl = ResUtil:GetEquipPosUrl(pos)
	vo.pos = pos;
	if not curCfg then 
		curCfg = {}
		curCfg.lvl = 0;
	end;
	vo.desc = curCfg.lvl;
	vo.posName = BagConsts:GetEquipName(pos);
	objSwf.posName.htmlText = BagConsts:GetEquipName(pos);
	objSwf.curEquip:setData(UIData.encode(vo));  --显示 
	--self:SetCurPosInfo();
end;

function UIRefinView:SetCurPosInfo()
	local pos = self.CurPos;
	local objSwf = self.objSwf;
	local serCfg = EquipModel:GetRefinInfo(pos); -- 当前
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return end;
	local item = bagVO:GetItemByPos(pos);

	if not item then  -- 没有装备
		objSwf.val.htmlText = string.format(StrConfig['equip907'])
		objSwf.curAtb.htmlText = string.format(StrConfig['equip907'])
		objSwf.maxlvlPanel.curAtb.htmlText = string.format(StrConfig['equip907'])
		objSwf.nextAtb.htmlText = string.format(StrConfig['equip907'])
		if not serCfg then -- 未开通属性
			objSwf.curLvl.htmlText = 0
			objSwf.nextLvl.htmlText = 1
			local nextLvlId = 1 + (pos * 10000);
			local nextcfg = t_refin[nextLvlId]

			if not nextcfg then 
				nextcfg = t_refin[serCfg.id]
				-- 这就绝壁是找不到了
				objSwf.maxlvlPanel._visible = true;
			else
				objSwf.maxlvlPanel._visible = false;
			end;

	local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold; 
	local color = curlingli < nextcfg.consume and "#FF0000" or "#00FF00";
	objSwf.consumetxt.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume) 
	local color = curlingli < nextcfg.consume*11 and "#FF0000" or "#00FF00";
	objSwf.consumetxtAkey.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume*11) 
	
			--道具消耗
	        local has = BagModel:GetItemNumInBag(nextcfg.itemid);
	        local color = has < nextcfg.number and "#FF0000" or "#00FF00";
	        objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'.. nextcfg.number );
	        color = has < 11 and "#FF0000" or "#00FF00";
		    objSwf.tfNeedItemAkey.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'..(nextcfg.number*11) );
			local vipNum = VipController:GetZhuangbeiQianghua()
			local num = nextcfg.chance + vipNum;
			if num > 100 then num = 100 end;
			objSwf.chancetxt.htmlText = string.format(StrConfig['equip902'],num)
		else
			local cfg = t_refin[serCfg.id];
			local nextLvlId = (serCfg.lvl + 1) + (pos * 10000);
			local nextcfg = t_refin[nextLvlId]
			if not nextcfg then 
				nextcfg = t_refin[serCfg.id]
				-- 这就绝壁是找不到了
				objSwf.maxlvlPanel._visible = true;
			else
				objSwf.maxlvlPanel._visible = false;
			end;
			objSwf.curLvl.htmlText = cfg.lv;
			objSwf.nextLvl.htmlText = nextcfg.lv
			-- 当前满级panel
			objSwf.maxlvlPanel.curLvl.htmlText = cfg.lv;

		local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold; 
	local color = curlingli < nextcfg.consume and "#FF0000" or "#00FF00";
	objSwf.consumetxt.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume) 
	local color = curlingli < nextcfg.consume*11 and "#FF0000" or "#00FF00";
	objSwf.consumetxtAkey.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume*11) 

          --道具消耗
	        local has = BagModel:GetItemNumInBag(nextcfg.itemid);
	        local color = has < nextcfg.number and "#FF0000" or "#00FF00";
	        objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'.. nextcfg.number );
	        color = has < 11 and "#FF0000" or "#00FF00";
			objSwf.tfNeedItemAkey.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'..(nextcfg.number*11) );
			--objSwf.consumetxt.htmlText =string.format(StrConfig['equip903'],nextcfg.consume) 
			local vipNum = VipController:GetZhuangbeiQianghua()
			local num = nextcfg.chance + vipNum;
			if num > 100 then num = 100 end;
			objSwf.chancetxt.htmlText = string.format(StrConfig['equip902'],num)
		end;
	else
		if not serCfg then --  未开通属性
			local nextlvlId = 1 + (pos * 10000)
			local nextcfg = t_refin[nextlvlId]
			local nokaitongnextatb = 0
			local itemCfg = item:GetCfg();
			local atblist = AttrParseUtil:Parse(itemCfg.baseAttr);
			local atbVo = atblist[1];
			nokaitongnextatb = toint((atbVo.val * (nextcfg.percentage / 100)+nextcfg.addVal),0.5)-- ,0.5
			local nextatbNamelist = AttrParseUtil:Parse(nextcfg.attr)
			local nextatbName = enAttrTypeName[nextatbNamelist[1].type]
			objSwf.val.htmlText = string.format(StrConfig['equip913'],nextatbName,0)
			objSwf.curLvl.htmlText = 0;
			objSwf.curAtb.htmlText = string.format(StrConfig['equip901'],nextatbName,0);
			objSwf.nextLvl.htmlText = 1;
			objSwf.nextAtb.htmlText = string.format(StrConfig['equip901'],nextatbName,nokaitongnextatb);

			-- 当前满级panel
			objSwf.maxlvlPanel.curAtb.htmlText = string.format(StrConfig['equip901'],nextatbName,0);


		local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold; 
	local color = curlingli < nextcfg.consume and "#FF0000" or "#00FF00";
	objSwf.consumetxt.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume) 
	local color = curlingli < nextcfg.consume*11 and "#FF0000" or "#00FF00";
	objSwf.consumetxtAkey.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume*11) 

			
			--道具消耗
	        local has = BagModel:GetItemNumInBag(nextcfg.itemid);
	        local color = has < nextcfg.number and "#FF0000" or "#00FF00";
	        objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'.. nextcfg.number );
	        color = has < 11 and "#FF0000" or "#00FF00";
		    objSwf.tfNeedItemAkey.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'..(nextcfg.number*11) );			--objSwf.consumetxt.htmlText = string.format(StrConfig['equip903'],nextcfg.consume)
			local vipNum = VipController:GetZhuangbeiQianghua()
			local num = nextcfg.chance + vipNum;
			if num > 100 then num = 100 end;
			objSwf.chancetxt.htmlText = string.format(StrConfig['equip902'],num)
			objSwf.Uplook.htmlText = string.format(StrConfig['equip901'],nextatbName,nokaitongnextatb);

			if not nextcfg then 
				nextcfg = t_refin[serCfg.id]
				-- 这就绝壁是找不到了
				objSwf.maxlvlPanel._visible = true;
			else
				objSwf.maxlvlPanel._visible = false;
			end;

		else
			local curlvlId = serCfg.id;
			local nextLvlId = (serCfg.lvl + 1) + (pos * 10000);
			local cfg = t_refin[serCfg.id];
			local nextcfg = t_refin[nextLvlId]
			if not nextcfg then 
				nextcfg = cfg 
				objSwf.maxlvlPanel._visible = true;
				
			else
				objSwf.maxlvlPanel._visible = false;
			end;

			

			local atbNamelist = AttrParseUtil:Parse(cfg.attr)
			local atbName = enAttrTypeName[atbNamelist[1].type]
			local curlvlAtb = 0;
			local nextLvlAtb = 0;
			local itemCfg = item:GetCfg();
			local atblist = AttrParseUtil:Parse(itemCfg.baseAttr);
			local atbVo = atblist[1];

			curlvlAtb = toint((atbVo.val * (cfg.percentage / 100)+ cfg.addVal),0.5);-- + cfg.addVal
			nextLvlAtb = toint((atbVo.val * (nextcfg.percentage / 100)+ nextcfg.addVal),0.5)--+ nextcfg.addVal
			local nextatbNamelist = AttrParseUtil:Parse(nextcfg.attr)
			local nextatbName = enAttrTypeName[nextatbNamelist[1].type]
			objSwf.val.htmlText = string.format(StrConfig['equip913'],atbName,curlvlAtb)--cfg.percentage
			objSwf.curLvl.htmlText = cfg.lv;
			objSwf.curAtb.htmlText = string.format(StrConfig['equip901'],atbName,curlvlAtb)
			objSwf.nextLvl.htmlText = nextcfg.lv;
			local lookVal = nextcfg.percentage - cfg.percentage;
			objSwf.Uplook.htmlText = string.format(StrConfig['equip901'],nextatbName,nextLvlAtb - curlvlAtb)--nextcfg.percentage
			objSwf.nextAtb.htmlText = string.format(StrConfig['equip901'],nextatbName,nextLvlAtb)--nextcfg.percentage;

			-- 当前满级panel
			objSwf.maxlvlPanel.curLvl.htmlText = cfg.lv;
			objSwf.maxlvlPanel.curAtb.htmlText = string.format(StrConfig['equip901'],nextatbName,nextLvlAtb);
			local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold;

		local curlingli = MainPlayerModel.humanDetailInfo.eaUnBindGold; 
	local color = curlingli < nextcfg.consume and "#FF0000" or "#00FF00";
	objSwf.consumetxt.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume) 
	local color = curlingli < nextcfg.consume*11 and "#FF0000" or "#00FF00";
	objSwf.consumetxtAkey.htmlLabel = string.format(StrConfig['smithing026'], color,nextcfg.consume*11) 

			
			--道具消耗
	        local has = BagModel:GetItemNumInBag(nextcfg.itemid);
	        local color = has < nextcfg.number and "#FF0000" or "#00FF00";
	        objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'.. nextcfg.number );
	        color = has < 11 and "#FF0000" or "#00FF00";
			objSwf.tfNeedItemAkey.htmlLabel = string.format( StrConfig['smithing024'], color, t_item[nextcfg.itemid].name,has..'/'..(nextcfg.number*11) );
			--objSwf.consumetxt.htmlText =string.format(StrConfig['equip903'],nextcfg.consume) 
			local vipNum = VipController:GetZhuangbeiQianghua()
			local num = nextcfg.chance + vipNum;
			if num > 100 then num = 100 end;
			objSwf.chancetxt.htmlText = string.format(StrConfig['equip902'],num)
		end;
	end;
end;

function UIRefinView:GetRoleItemList()
	local objSwf = self.objSwf;
	local list = {}
	for i=1,11 do
		local vo = {};
		vo.iconUrl = ResUtil:GetEquipPosUrl(i-1)
		vo.pos = i - 1;
		local currVo = EquipModel:GetRefinInfo(vo.pos); -- 当前
		if not currVo then 
			currVo = {}
			currVo.lvl = 0;
		end; 
		vo.desc = currVo.lvl;
		vo.posName = BagConsts:GetEquipName(i);
		table.push(list,UIData.encode(vo));
	end;
	objSwf.rolelist.dataProvider:cleanUp();
	objSwf.rolelist.dataProvider:push(unpack(list));
	objSwf.rolelist:invalidateData();
end

function UIRefinView:RuleOver()
	TipsManager:ShowBtnTips(StrConfig['equip900'],TipsConsts.Dir_RightDown); 
end;



--------------------------Notification
function UIRefinView:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.EquipRefinUpdata then 
		self:GetRoleItemList();
		--self:SelectRoleList()
		self:ShowRefinLink();
		self:GetAllAtbAdd();
		self:SetXiaohao();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaVIPLevel then
			self:InitVip()
		end
	end;
end;
function UIRefinView:ListNotificationInterests()
	return {NotifyConsts.EquipRefinUpdata,
			NotifyConsts.PlayerAttrChange,
			};
end



--画模型
function UIRefinView:DrawRole()
	local uiLoader = self.objSwf.roleLoaderRefin;

	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("rolePanelPlayerRefin", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	self.objAvatar:PlayLianhualuAction()
	-- --播放特效
	-- local sex = MainPlayerModel.humanDetailInfo.eaSex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	--pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end

--显示连锁按钮
function UIRefinView:ShowRefinLink()
	local curlist = EquipModel:GetRefinList();
	local curlinkid = EquipUtil:GetRefinLinkId(curlist);
	for i,btn in ipairs(self.linkBtns) do 
		btn.visible = false;
	end;
	for i,cfg in ipairs(t_refinlink) do 
		if curlinkid >= cfg.id then 
			self:ShowStrenLinkBtn(i,true);
		else
			self:ShowStrenLinkBtn(i,false);
			break;
		end;
	end;
	self:IsShowCanUpLvlFpx(true,curlist)
end;

--显示连锁按钮
function UIRefinView:ShowStrenLinkBtn(index,active)
	if self.linkBtns[index] then
		self.linkBtns[index].visible = true;
		self.linkBtns[index].disabled = not active;
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf:getNextHighestDepth();
	local button = objSwf:attachMovie("StrenLinkButton"..index,"linkBtn"..index,depth);
	self.linkBtns[index] = button;
	button._x = 18 + (index-1)*36;
	button._y = 20;
	button.alwaysRollEvent = true;
	button.visible = true;
	button.disabled = not active;
	button.rollOut = function() TipsManager:Hide(); end
	button.rollOver = function() self:OnStrenLinkRollOver(index,button); end
end
--连锁tips
function UIRefinView:OnStrenLinkRollOver(index,button)
	local num = 0;
	local linkCfg = t_refinlink[index];
	local refinlist = EquipModel:GetRefinList(); 
	local curlinkid = EquipUtil:GetRefinLinkId(refinlist);
	if not linkCfg then return; end
	for i,info in pairs(refinlist) do 
		local lvlc = 0;
		lvlc = t_refinlink[index].openlvl
		if info.lvl >= lvlc then 
			num = num + 1;
		end;
	end;
	local tipsVO = {};
	if not button.disabled then 
		tipsVO.activeNum = num
	else
		local nextnum = 0;
		for i,info in pairs(refinlist) do 
			local lvlc = 0;
			lvlc = t_refinlink[curlinkid+1].openlvl
			if info.lvl >= lvlc then 
				nextnum = nextnum + 1;
			end;
		end;
		tipsVO.activeNum = nextnum
	end;
	tipsVO.linkId = index;
	TipsManager:ShowTips(TipsConsts.Type_RefinLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

--  升级效果
function UIRefinView:OnResultShowFpx(list)
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not list then return end;
	self:IsShowCanUpLvlFpx(false)
	for i,info in ipairs(list) do 
		if not info.pos then 
			-- trace(info)
			-- print(info.pos)
			-- print(debug.traceback())
			return;
		end;
		if info.pos < 0 or info.pos > 10 then 
			break;
		end;
		if info.result == 0 then 
			objSwf.fpxImg["fpx"..info.pos]._visible = true;
			objSwf.fpxImg["fpx"..info.pos]:gotoAndPlay(1);
			objSwf.fpxImg["fai"..info.pos]._visible = false;
		else
			objSwf.fpxImg["fpx"..info.pos]._visible = false;
			objSwf.fpxImg["fai"..info.pos]._visible = true;
			objSwf.fpxImg["fai"..info.pos]:gotoAndPlay(1);

		end;
	end;
	objSwf.fpxImg:gotoAndPlay(1)
	objSwf.fpxImg._visible = true;

end;

function UIRefinView:IsShowCanUpLvlFpx(boolean,list)
	if not self.bShowState then return end;
	local objSwf = self.objSwf;
   	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel;
   	local maxLevel = 300;
	if boolean then 
		objSwf.txt_fpx._visible = true;
		for i,info in pairs(list) do 
			if info.lvl >= myLevel or info.lvl == maxLevel then 
				objSwf.txt_fpx["fpxt"..info.pos]._visible = false;
			else
				objSwf.txt_fpx["fpxt"..info.pos]._visible = true;
				objSwf.txt_fpx["fpxt"..info.pos]:gotoAndPlay(1);
			end;
		end;
	else
		objSwf.txt_fpx._visible = false;
	end;
end;

function UIRefinView:OverFpxImg()
	if not self.bShowState then return end;
	self.objSwf.fpxImg._visible = false;
	local curlist = EquipModel:GetRefinList();
	self:IsShowCanUpLvlFpx(true,curlist)
end;

------------------------功能引导相关------------
function UIRefinView:GetLvlUPBtn()
	if not self:IsShow() then return; end
	return self.objSwf.autoUplvl;
end

----------------------------------  点击任务接口 ----------------------------------------

function UIRefinView:OnGuideClick()
	QuestController:TryQuestClick( QuestConsts.EquipRefinClick )
end

------------------------------------------------------------------------------------------

