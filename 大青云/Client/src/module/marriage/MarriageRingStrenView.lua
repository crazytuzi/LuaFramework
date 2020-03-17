--[[
戒指强化
wangshuai
]]

_G.UIMarryRingStren = BaseUI:new("UIMarryRingStren")

function UIMarryRingStren:Create()
	self:AddSWF("MarryRingStrenPanel.swf",true,nil)
end;

function UIMarryRingStren:OnLoaded(objSwf)
	objSwf.closeBtn.click = function() self:Hide() end;
	objSwf.ringItem.rollOver = function() self:OnRingOver() end;
	objSwf.ringItem.rollOut  = function() TipsManager:Hide() end;

	objSwf.btnNeedItem.rollOver = function() self:OnNeedItemOver() end;
	objSwf.btnNeedItem.rollOut = function() TipsManager:Hide() end;

	objSwf.btnStren.click = function() self:OnBtnStrenClick() end;

	objSwf.chenggFpx.playOver = function() self:OnPlayerOver()end;

	objSwf.btnStren.rollOver = function() self:OnbtnStrenOber() end;
	objSwf.btnStren.rollOut = function() self:OnbtnStrenOut() end;

end;

function UIMarryRingStren:OnbtnStrenOber()
	local objSwf  =self.objSwf;
	if not objSwf then return end;
	objSwf.overtips_mc._visible = true;
end;

function UIMarryRingStren:OnbtnStrenOut()
	local objSwf  =self.objSwf;
	if not objSwf then return end;
	objSwf.overtips_mc._visible = false;
end;

function UIMarryRingStren:OnShow()

	self:UpdataShowLvlInfo()
	self:SetRingStar();
	self:SetAtbVal();
	self:SetProVal();
	self:UpdataXiaohao();
	self:UpdataRingitem();
	self:PlayerFpx(true);
	self.objSwf.overtips_mc._visible = false;
end;

function UIMarryRingStren:OnHide()

end;

function UIMarryRingStren:OnPlayerOver()
	self.objSwf.chenggFpx._visible = false;

end;

UIMarryRingStren.lastlvl = 0;
function UIMarryRingStren:PlayerFpx(stop)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if stop then 
		for i=1,10 do 
			objSwf["feixingeffect"..i]._visible = false;
			objSwf["feixingeffect"..i]:gotoAndStop(1)
		end;
		objSwf.chenggFpx._visible = false;
		local roleData = MarriageModel.MymarryPanelInfo
		--self.lastlvl = roleData.ringLvl or 0;
		return 
	end;

	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.ringLvl >= 0 then 
		if self.lastlvl == roleData.ringLvl then 
			return 
		end;
		self.lastlvl = roleData.ringLvl;
		for i=1,10 do 
			if i == roleData.ringLvl then 
				objSwf["feixingeffect"..i]._visible = true;
				objSwf["feixingeffect"..i]:gotoAndPlay(1)
			else
				objSwf["feixingeffect"..i]._visible = false;
				objSwf["feixingeffect"..i]:gotoAndStop(1)
			end;
		end;
	end;
	-- 成功特效2
	objSwf.chenggFpx._visible = true;
	objSwf.chenggFpx:gotoAndPlay(1);
end;

function UIMarryRingStren:UpdataShowLvlInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local roleData = MarriageModel.MymarryPanelInfo

	if roleData and roleData.ringLvl >= 0 then 
		local cfg = t_marrystren[roleData.ringLvl + 1];
		if not cfg and roleData.ringLvl > 0 then 
			objSwf.maxLvl_img._visible = true;
			objSwf.start._visible = false;
			objSwf.proVal._visible = false;
			objSwf.btnStren._visible = false;
			objSwf.xiaohaoName._visible = false;
			objSwf.btnNeedItem._visible = false;
		elseif cfg then 
			objSwf.maxLvl_img._visible = false;
			objSwf.start._visible = true;
			objSwf.proVal._visible = true;
			objSwf.btnStren._visible = true;
			objSwf.xiaohaoName._visible = true;
			objSwf.btnNeedItem._visible = true;
		end;
	end;
end;

function UIMarryRingStren:OnBtnStrenClick()
	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.newVal >= 0 and roleData.ringLvl >= 0 then 
		local cfg = t_marrystren[roleData.ringLvl + 1];
		if cfg then 
			local id = cfg.item[1] or 0
			local num = cfg.item[2] or 0;
			local bagNum = BagModel:GetItemNumInBag(id);
			if num > bagNum then 
				FloatManager:AddNormal(StrConfig["marriage018"])
				return 
			end;
		end;
	end;
	UIMarryRingStren.lastlvl = roleData.ringLvl;
	MarriagController:ReqMarryRingStren()
end;

function UIMarryRingStren:UpdataRingitem()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local roleDatacc = MarriageModel.MymarryPanelInfo
	if roleDatacc and roleDatacc.ringId ~= 0 then 
		local cfg = t_marryRing[roleDatacc.ringId]
		local itemvo = RewardSlotVO:new()
		itemvo.id = cfg.itemId
		objSwf.ringItem:setData(itemvo:GetUIData());
	end;
end;

function UIMarryRingStren:OnRingOver()
	local roleDatacc = MarriageModel.MymarryPanelInfo
	if roleDatacc and roleDatacc.ringId ~= 0 then 
		local cfg = t_marryRing[roleDatacc.ringId]
		if not cfg then return end;
		local itemTipsVO = ItemTipsUtil:GetItemTipsVO(cfg.itemId, 1);
		if not itemTipsVO then return end;
		itemTipsVO.ringLvl = MarriageModel:GetQingYuanVal()
		itemTipsVO.ringType = MarriageModel:GetRingType();
		itemTipsVO.ringStren = MarriageModel:GetMyStrenLvl()
		TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
	end;
end;

UIMarryRingStren.StrenMaxStar = 10;

function UIMarryRingStren:SetRingStar()
	local objSwf = self.objSwf
	if not objSwf then return end;
	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.ringLvl >= 0 then
		if roleData.ringLvl >= self.StrenMaxStar then 
			objSwf.start.star = "EquipStrenGem";
			objSwf.start.grayStar = "EquipStrenGrayGem";
			objSwf.start.value = roleData.ringLvl - self.StrenMaxStar;
		else
			objSwf.start.star = "EquipStrenStar";
			objSwf.start.grayStar = "EquipStrenGrayStar";
			objSwf.start.value = roleData.ringLvl;
		end;
	end;
end;

UIMarryRingStren.nextValList = {}

function UIMarryRingStren:SetAtbVal()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local roleData = MarriageModel.MymarryPanelInfo
	--trace(roleData)
	--print('-------------------')
	if roleData and roleData.ringLvl >= 0 then 
		local cfg = t_marrystren[roleData.ringLvl];
		local rcfg = t_marryRing[roleData.ringId];
		--trace(cfg)
		--trace(rcfg)
		if cfg and rcfg then 
			local baseAtb = AttrParseUtil:Parse(rcfg.attr);
			local newAtb = AttrParseUtil:Parse(cfg.attr);
			local addVal = cfg.times / 100;
			for ba,at in pairs(baseAtb) do 
				at.val = at.val * addVal;
				for ca,sa in pairs(newAtb) do 
					if sa.type == at.type then 
						at.val = at.val + sa.val;
						break;
					end;
				end;
			end;
			--最终属性
			local str = ""
			for ea,eba in pairs(baseAtb) do 
				str = str .. "<font color='#BE8C44'>" .. enAttrTypeName[eba.type] .. "</font>        +" .. getAtrrShowVal(eba.type,eba.val) .. "<br/>";
			end;
			objSwf.allAtb_txt.htmlText = str;


			local nextCfg = t_marrystren[roleData.ringLvl + 1];
			if nextCfg then 
				local nextbaseAtb = AttrParseUtil:Parse(rcfg.attr);
				local newAtb = AttrParseUtil:Parse(nextCfg.attr);
				local addVal = nextCfg.times / 100;
				for ba,at in pairs(nextbaseAtb) do 
					at.val = at.val * addVal;
					for ca,sa in pairs(newAtb) do 
						if sa.type == at.type then 
							at.val = at.val + sa.val;
							break;
						end;
					end;
					--计算差值
					for aq,pa in pairs(baseAtb) do 
						if pa.type == at.type then 
							at.val = at.val - pa.val;
						end;
					end;
				end;

				--最终属性
				local str = ""
				for i=1,10 do 
					local img = objSwf.overtips_mc['img_'..i];
					if img then
						img._visible = false;
					end;
				end;
				for ea,eba in pairs(nextbaseAtb) do 
					str = str .. getAtrrShowVal(eba.type,eba.val) .. "<br/>";
					local img = objSwf.overtips_mc['img_'..ea];
					if img then 
						img._visible = true;
					end;
				end;
				objSwf.overtips_mc.nextallAtb_txt.htmlText = str;
			else
				print(roleData.ringLvl + 1,debug.traceback())
				for i=1,10 do 
					local img = objSwf.overtips_mc['img_'..i];
					if img then
						img._visible = false;
					end;
				end;
			end;
		end;
	end;
end;


function UIMarryRingStren:SetProVal()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.newVal >= 0 and roleData.ringLvl >= 0 then 
		local cfg = t_marrystren[roleData.ringLvl + 1];
		if cfg then 
			local maxVal = cfg.progress;
			objSwf.proVal.maximum = maxVal
			objSwf.proVal.value = roleData.newVal;
		end;
	end;
end;

function UIMarryRingStren:OnNeedItemOver()

	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.newVal >= 0 and roleData.ringLvl >= 0 then 
		local cfg = t_marrystren[roleData.ringLvl + 1];
		if cfg then 
			local id = cfg.item[1] or 0
			TipsManager:ShowItemTips(id);
		end;
	end;
end;

function UIMarryRingStren:UpdataXiaohao()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local roleData = MarriageModel.MymarryPanelInfo
	if roleData and roleData.newVal >= 0 and roleData.ringLvl >= 0 then 
		local cfg = t_marrystren[roleData.ringLvl + 1];
		--trace(cfg)
		if cfg then 
			local id = cfg.item[1] or 0
			local num = cfg.item[2] or 0;
			local bagNum = BagModel:GetItemNumInBag(id);
			local color = "#ff0000"
			if bagNum >= num then 
				color = "#00ff00"
			end;
			if t_item[id] then 
				objSwf.btnNeedItem.htmlLabel = "<font color ='".. color.. "'><u>" .. t_item[id].name .. "X" .. num .. "</u></font>"
			end;
		end;
	end;
end;

---	-- notifaction
function UIMarryRingStren:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		}
end;
function UIMarryRingStren:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:UpdataXiaohao();
	end
end;
