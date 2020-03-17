--[[
升品结果
wangshuai
]]

_G.UIEquipProductResult = BaseUI:new("UIEquipProductResult")

UIEquipProductResult.superList = {};
UIEquipProductResult.oldatblist = {};
UIEquipProductResult.nowatblist = {};
UIEquipProductResult.curpos = 0;
function UIEquipProductResult:Create()
	self:AddSWF("equipProductResultPanel.swf",true,"center")
end;

function UIEquipProductResult:OnLoaded(objSwf)
	objSwf.closepnale.click = function() self:OnClosePanel()end;

	objSwf.item1.rollOver = function(e) self:ShowEquipTips(e); end;
	objSwf.item1.rollOut = function() TipsManager:Hide(); end
	objSwf.texiao.playOver = function() self:TexiaoOver()end;
end;
function UIEquipProductResult:ShowEquipTips(e)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.curpos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.curpos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;

function UIEquipProductResult:TexiaoOver()
	local objSwf = self.objSwf;
	objSwf.texiao:gotoAndStop(23)
	local num = 100
	TimerManager:RegisterTimer(function()
		if self:IsShow() == true then 
			num = num - 10;
			objSwf.texiao._alpha = num;
		end;
		end, 100, 10)
end;
function UIEquipProductResult:OnShow()
	local objSwf = self.objSwf;
	objSwf.texiao:gotoAndPlay(1)
	objSwf.proOld:gotoAndStop(self.oldquality+1);
	objSwf.proNow:gotoAndStop(self.nowquality+1);

	local oldatb = "";
	for i,info in pairs(self.oldatblist) do 
		local name = enAttrTypeName[info.type];
		oldatb = oldatb .. "<font color='#445864'>"..name..":    </font><font color='#a0a0a0'>+"..info.val.."</font>";
	end;
	local nowatb = "";
	for ca,ao in pairs(self.nowatblist) do
		local name = enAttrTypeName[ao.type];
		nowatb = nowatb .. "<font color='#445864'>"..name..":    </font><font color='#32961e'>+"..ao.val.."</font>";
	end;

	objSwf.oldatb.htmlText = oldatb;
	objSwf.nowatb.htmlText = nowatb;
		
	objSwf.oldsuper.text = StrConfig['equip229'];


	--local vo = {}EquipUtil:GetEquipUIVO(self.curpos,false); -- 获取数据


	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return {}; end
	local item = bagVO:GetItemByPos(self.curpos);

	local itemvo = RewardSlotVO:new();
	itemvo.id = item:GetTid();
	itemvo.count = 1;
	local vo = {};

	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack({itemvo:GetUIData()}));
	objSwf.list:invalidateData();

	--objSwf.item1:setData(UIData.encode(vo));  --显示 

	if self.superList.superNum <= 0 then 
		objSwf.noesuper.text = StrConfig['equip229']
		return ;
	end;
	objSwf.noesuper.htmlText = self:GetText();

end;

function UIEquipProductResult:ProductResultData(vo)
	local objSwf = self.objSwf;

	-- local voc = {}
	-- voc.superList = {};
	-- voc.superNum= 2;
	-- voc.superList.superNum= 2;
	-- 	for i=1,2 do 
	-- 		local xvo = {};
	-- 		xvo.guid = "*******_2533823423"
	-- 		xvo.id = toint("10100"..i)
	-- 		xvo.val1 = math.random(50,40)
	-- 		xvo.val2 = 0;
	-- 		xvo.lock = 0;
	-- 		table.push(voc.superList,xvo)
	-- 	end;

	self.superList = vo.nowsuepr 
	self.oldatblist = vo.oldlist;
	self.nowatblist = vo.nowlist;

	self.oldquality = vo.oldquality;
	self.nowquality = vo.nowquality;

	self.curpos = vo.pos;
	self:Show();
	--self.superNum = vo.nowsuepr. superNum
end;


function UIEquipProductResult:GetText()
	local str = ""
	for i=1,self.superList.superNum do
		local vo = self.superList.superList[i];
		local holeLvl = 0--self.superHoleList[i];
		local cfg = t_equipSuper[vo.id];
		local holeCfg = t_superHoleUp[holeLvl];
		if vo.id == 0 then
			str = str .. "<textformat leading='5' leftmargin='0'><p>" .. self:GetHtmlText("「卓越」 未附加","#838383",TipsConsts.Default_Size,false) .. "</p></textformat>"; 
		else
			local attrStr = "";
			--锁定的卓越属性
			if vo.lock == 1 then
				attrStr = attrStr .. "<textformat leading='-14' leftmargin='0'><p>";
				attrStr = attrStr .. "<img width='13' height='17' vspace='-2' src='" .. ResUtil:GetTipsSuperLockUrl() .. "'/>";
			else
				attrStr = attrStr .. "<textformat leading='-14' leftmargin='11'><p>";
			end

			--attrStr = attrStr .. "<textformat leading='-14' leftmargin='0'><p>";
			attrStr = attrStr .. string.format("「%s」",cfg.name);

			attrStr = attrStr .. "</p></textformat>";
			local attrT = split(cfg.attrName,",");
			local attrTypeT = split(cfg.attrType,",");
			for j=1,#attrT do
				attrStr = attrStr .. "<textformat leading='-14' leftmargin='105'><p>";
				if attrIsPercent(AttrParseUtil.AttMap[attrTypeT[j]]) then
					attrStr = attrStr .. string.format("%s+%0.2f%%",attrT[j],vo["val"..j]/100);
				else
					attrStr = attrStr .. attrT[j] .. "+"..vo["val"..j];
				end
				if holeLvl > 0 then
					local addVal = toint(vo["val"..j]*holeCfg.addPercent/100,0.5);
					if attrIsPercent(AttrParseUtil.AttMap[attrTypeT[j]]) then
						attrStr = attrStr .. string.format("(+%0.2f%%)",addVal/100);
					else
						attrStr = attrStr .. string.format("(+%s)",addVal);
					end
				end
				 attrStr = attrStr .. "</p></textformat><br/>";
				-- --
				-- attrStr = attrStr .. "<textformat leading='5' leftmargin='210'><p>";
				-- if holeLvl == 0 then
				-- 	-- attrStr = attrStr .. "<font color='#838383'>未觉醒</font>";
				-- else
				-- 	attrStr = attrStr .. string.format("觉醒%s重",holeLvl);
				-- end
				-- attrStr = attrStr .. "</p></textformat>";
			end
			str = str .. self:GetHtmlText(attrStr,"#29cc00",TipsConsts.Default_Size,false);
		end
	end
	return str
end;

function UIEquipProductResult:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end

function UIEquipProductResult:OnClosePanel()
	self:Hide();
end;

function UIEquipProductResult:OnHide()

end;