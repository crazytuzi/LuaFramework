--[[
	2015年1月14日, PM 04:23:32
	技能设置子面板
	wangyanwei
]]

_G.UISetSkill = BaseUI:new('UISetSkill');

function UISetSkill:Create()
	self:AddSWF("setSkillPanel.swf", true, nil);
end

UISetSkill.listIndex = 0;
UISetSkill.keyIndex = 0; --按键值
function UISetSkill:OnLoaded(objSwf)
	objSwf.txt_1.text = StrConfig['setsys61'];
	objSwf.txt_2.text = StrConfig['setsys62'];
	-- for i = 1 , 2 do
		-- objSwf['txt_' .. i].htmlText = string.format(StrConfig['setsys0350'],i);
		-- objSwf['btnRadioPlayer_' .. i].handleInput = function (e) 
			-- if UIConfirm:IsShow() then
				-- return;
			-- end
			-- if not SetSystemConsts.KeyConsts[e.detailsCode.code] then FloatManager:AddSysNotice( 2017001 ); end 
			-- self:OnSetSkillClick(e,i); 
		-- end
	-- end
	--//药品
	objSwf.tf1.text = UIStrConfig['setsys0500'];
	objSwf.btn_drug.handleInput = function (e) 
		if UIConfirm:IsShow() then
			return;
		end
		if not SetSystemConsts.KeyConsts[e.detailsCode.code] then FloatManager:AddSysNotice( 2017001 ); end 
		self:OnSetSkillClick(e); 
	end
	
	--//技能
	objSwf.list.itemClick = function (e)
		self.listIndex = e.item.index;
	end
	objSwf.list.handleInput = function (e)
		if UIConfirm:IsShow() then
			return;
		end
		if e.detailsCode.value == 'keyDown' then
			self.keyIndex = e.detailsCode.code;
			if not SetSystemConsts.KeyConsts[self.keyIndex] then FloatManager:AddSysNotice( 2017001 );return end
			if SetSystemConsts.KeyConsts[self.keyIndex] == e.item.dicText then
				return;
			end
			if SetSystemModel:GetIsFuncKey(SetSystemConsts.KeyConsts[self.keyIndex]) then
				local func = function ()
					self.listStr = {};
					SetSystemModel:OnClearKeyStr(SetSystemConsts.KeyConsts[UISetSkill.keyIndex]);
					self:OnDrawSkillList(UISetSkill.keyIndex);
					Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
				end
				local canFuc = function ()
					UISystemBasic.tabButton[UISystemBasic.oldTabButton].selected = true;
				end
				self.uiconfirmID = UIConfirm:Open(StrConfig['setsys0100'],func,canFuc);
			else
				self.listStr = {};
				self:OnDrawSkillList(self.keyIndex);
				Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
			end
		end
	end
	objSwf.btn_autoSkill.click = function ()
		if UIConfirm:IsShow() then
			UIConfirm:Close(self.uiconfirmID);
		end
		local func = function()
			self:AutoSkillClick();
		end
		self.autoSkillConfirmID = UIConfirm:Open(StrConfig['setsys0120'],func);
	end
end

--推荐技能设置点击
UISetSkill.AutoSkillConsts = 14;		--可变更设置的长度
function UISetSkill:AutoSkillClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
	for i , cfg in pairs(t_skillShortCut) do
		local skillGroupID = cfg[prof];
		local skillGroupCfg = t_skillgroup[skillGroupID];
		if skillGroupCfg then
			local SkillInGroupCfg = SkillModel:GetSkillInGroup(skillGroupID);
			if SkillInGroupCfg then
				local skillID = SkillInGroupCfg:GetID();
				if i <= self.AutoSkillConsts then		--拦截长度
					SkillController:SkillShortCutSet( i - 1, skillID );
				end
			end
		end
	end
end

function UISetSkill:OnShow()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.list:selectedState();
	self:OnDrawSkillList();
end

--画出list
UISetSkill.listStr = {};
function UISetSkill:OnDrawSkillList(listIndex)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	self.listStr = {};
	objSwf.list.dataProvider:cleanUp();
	local cfg = SetSystemModel:GetSkillKey();
	-- trace(cfg)
	-- debug.debug();
	--先将武魂的技能取出来
	for i , v in ipairs(cfg) do
		local vo = {};
		vo.txt = StrConfig['setsys' .. i];
		if i == self.listIndex then
			UISystemBasic.setState = true;
			vo.dicText = SetSystemConsts.KeyConsts[listIndex];
		else
			vo.dicText = cfg[i].str;
		end
		vo.index = i;
		self.listStr[i] = {};
		self.listStr[i].str = vo.dicText;
		self.listStr[i].id = i;
		objSwf.list.dataProvider:push(UIData.encode(vo));
	end
	SetSystemModel.copySkillKey = self.listStr;
	objSwf.list:invalidateData();
	self:OnShowBtnTxt();
	objSwf.list:selectedState();
end

function UISetSkill:OnSetSkillClick(e)
	local objSwf = self.objSwf ;
	if SetSystemConsts.KeyConsts[e.detailsCode.code] == objSwf.btn_drug.text then
		return;
	end
	self.listIndex = 0;
	UISystemBasic.setState = true;
	--//临时只有一个数据  写法错误
	if e.detailsCode.value == 'keyDown' then
		for i , v in pairs(SetSystemConsts.KeyConsts) do
			if _sys:isKeyDown(i) then
				if SetSystemModel:GetIsFuncKey(v) then      --这个先锁 先用上面的试用一行 
					local func = function () 
						UISetSkill:ClearKeyStr(v);
						SetSystemModel.copyDrugKey[1].str = v;
						self:OnDrawSkillList();
						self:OnShowBtnTxt();
						Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
						return;
					end
					local canFuc = function ()
						UISystemBasic.tabButton[UISystemBasic.oldTabButton].selected = true;
					end
					self.uiconfirmID = UIConfirm:Open(StrConfig['setsys0100'],func,canFuc);
				else
					SetSystemModel.copyDrugKey[1].str = v;
					self:OnDrawSkillList();
					self:OnShowBtnTxt();
					Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
					return;
				end
			end
		end
	end
end

function UISetSkill:ClearKeyStr(str)
	SetSystemModel:OnClearKeyStr(str);
	self:OnShowBtnTxt();          ---清掉 在重新赋值
end

--显示按键文本
function UISetSkill:OnShowBtnTxt()
	
	local cfg = SetSystemModel:GetDrugKey();
	local objSwf = self.objSwf ;
	if not objSwf then return end
	--//临时只有一个键的原因，写法错误
	for i , v in ipairs(cfg) do
		-- print(v.str)
		-- debug.debug();
		objSwf.btn_drug.label = v.str;
	end	
	
end

function UISetSkill:OnHide()
	self.listIndex = 0;
	self.listStr = {};
	self:OnIpSearchFocusOut();
	UIConfirm:Close(self.autoSkillConfirmID);
end

--默认设置
function UISetSkill:OnInitSkillKey()
	local skillCfg = SetSystemModel.SetSkillInit;
	for i , v in pairs(skillCfg) do
		SkillConsts.KeyMap[i].keyCode = v.keyCode;
	end
end

function UISetSkill:OnIpSearchFocusOut()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_drug.focused = false;
	objSwf.btn_drug.selected = false;
	objSwf.list:selectedState();
	objSwf.list.focused = false;
end

--消息处理
function UISetSkill:HandleNotification(name,body)
	if name == NotifyConsts.StageClick then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut()
	elseif name == NotifyConsts.SetSystemSkillChange then  --接到数据执行
		self:OnDrawSkillList();
		self:OnShowBtnTxt();
	end
end

-- 消息监听
function UISetSkill:ListNotificationInterests()
	return {
			NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut,
			NotifyConsts.SetSystemSkillChange
			}
end