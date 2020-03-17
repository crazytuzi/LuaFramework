--[[
婚礼类型选择
wangshuai
]]

_G.UIMarryTypeSelect = BaseUI:new("UIMarryTypeSelect")

UIMarryTypeSelect.curType = 1;


function UIMarryTypeSelect:Create()
	self:AddSWF("MarryTypePanel.swf",true,"center")
end;

function UIMarryTypeSelect:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	objSwf.marryOne_btn.click = function() self:OnMarryTypeClick(1)end;
	objSwf.marryTwo_btn.click = function() self:OnMarryTypeClick(2)end;

	objSwf.sureMarry_btn.click = function() self:OnSureClick()end;

	for i=1,4 do 
		objSwf['itemtex_'..i].rollOver = function() self:OnItemTexOver(i)end;
		objSwf['itemtex_'..i].rollOut = function() TipsManager:Hide() end;
	end;

	for i=1,2 do 
		objSwf.type_img["lajiStep_"..i].rollOver = function() self:LajiFunc(i) end
		objSwf.type_img["lajiStep_"..i].rollOut = function() TipsManager:Hide() end; 
	end;
	for i=1,3 do 
		objSwf.type_img['nbStep_'..i].rollOver = function() self:NbFunc(i) end;
		objSwf.type_img['nbStep_'..i].rollOut = function() TipsManager:Hide() end;
	end;
end;

function UIMarryTypeSelect:LajiFunc(index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	index = index + 1;
	TipsManager:ShowBtnTips(StrConfig["marriage90"..index],TipsConsts.Dir_RightDown);
end;

function UIMarryTypeSelect:NbFunc(index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if index == 3 then 
		index = 4;
	end;
	TipsManager:ShowBtnTips(StrConfig["marriage90"..index],TipsConsts.Dir_RightDown);

end;

function UIMarryTypeSelect:OnItemTexOver(index) 
	local id = self.itemData[index];
	if t_fashions[id] then 
		local cfg = t_fashions[id];
		if not cfg then return; end
		cfg.lastTime = -1;
		TipsManager:ShowTips(TipsConsts.Type_Fanshion,{cfg=cfg},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
	end;
	if not id then return end;
	TipsManager:ShowItemTips(id);
end

-- 显示前的判断，每个show方法第一步
function UIMarryTypeSelect:ShowJudge()
	local state = MarriageModel:GetMyMarryState();
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then 
		FloatManager:AddNormal( StrConfig['marriage021']);
		return 
	end;
	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;
	--是否队长
	local mytema = TeamUtils:MainPlayerIsCaptain();
	if not mytema then 
		FloatManager:AddNormal( StrConfig['marriage076']);
		return 
	end;

	
	self:Show();
end;

function UIMarryTypeSelect:OnShow()
	self:UIUpdataShow();
end;

function UIMarryTypeSelect:OnHide()

end;

function UIMarryTypeSelect:OnSureClick()
	if UIMarriageTypeConfirmView then 
		UIMarriageTypeConfirmView:OpenPanel(self.curType);
	end;
	-- if not UIMarryTimeSelect:IsShow() then 
	-- 	UIMarryTimeSelect:Show();
	-- end;
end;

function UIMarryTypeSelect:OnMarryTypeClick(type)
	self.curType = type;
	self:UIUpdataShow();
end;

UIMarryTypeSelect.itemData = {}

function UIMarryTypeSelect:UIUpdataShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.curType == 1 then 
		objSwf.marryOne_btn.selected = true;
	else
		objSwf.marryTwo_btn.selected = true;
	end;
	for i=1,2 do
		objSwf.type_img["lajiStep_"..i].visible = self.curType==1;
	end
	for i=1,3 do 
		objSwf.type_img['nbStep_'..i].visible = self.curType==2;
	end
	
	objSwf.type_img:gotoAndStop(self.curType)
	objSwf.marryType_mc:gotoAndStop(self.curType)

	local cfg = t_marry[self.curType];
	if not cfg then return end;
	local money = split(cfg.cost,',')
	objSwf.rps_txt.htmlText = enAttrTypeName[toint(money[1])]..getNumShow(money[2]);
	objSwf.desc_txt.htmlText = cfg.depict;

	self.itemData = {};
	local ilist = split(cfg.item,",");
	local str = ""
	for i=1,4 do 
		local id = toint(ilist[i])
		if t_fashions[id] then 
			str = "<font color = '#00ff00'>".. t_fashions[id].name .. "</font>"
		elseif t_item[id] then 
			str = "<font color = '#00ff00'>".. t_item[id].name .. "x" .. cfg.invitionNum .."</font>"
		end;
		--print(str)
		objSwf["itemtex_"..i].htmlLabel = str;
		table.push(self.itemData,id)
	end;
end;


-- 是否缓动
function UIMarryTypeSelect:IsTween()
	return true;
end

--面板类型
function UIMarryTypeSelect:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIMarryTypeSelect:IsShowSound()
	return true;
end

function UIMarryTypeSelect:IsShowLoading()
	return true;
end
