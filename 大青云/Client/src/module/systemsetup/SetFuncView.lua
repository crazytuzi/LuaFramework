--[[
	2015年1月14日, PM 04:25:30
	功能设置子面板
	wangyanwei
]]

_G.UISetFunc = BaseUI:new('UISetFunc');


function UISetFunc:Create()
	self:AddSWF("setFuncPanel.swf", true, nil);
end

function UISetFunc:OnLoaded(objSwf)
	objSwf.txt_1.text = StrConfig['setsys61'];
	objSwf.txt_2.text = StrConfig['setsys62'];
end

function UISetFunc:OnShow()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	self.listStr = {};
	self:ShowContsKey();
	self:OnChangeList();
end

--不可变更按键
function UISetFunc:ShowContsKey()
	local objSwf = self.objSwf ; 
	if not objSwf then return end
	local contsCfg = t_consts[59];
	if not contsCfg then return end
	local strCfg = split(contsCfg.param,'#');
	objSwf.setFuncList.dataProvider:cleanUp();
	for i , v in ipairs(strCfg) do
		local vo = {};
		local cfg = split(v,',');
		vo.txt1 = cfg[1];
		vo.txt2 = cfg[2];
		objSwf.setFuncList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.setFuncList:invalidateData();
end

UISetFunc.listIndex = 0; ---list选中哪个item索引
UISetFunc.keyIndex = 0; --按键值
function UISetFunc:OnChangeList()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	self:OnUpDataList();
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
					UISetFunc:ClearKeyStr(SetSystemConsts.KeyConsts[UISetFunc.keyIndex]);
					self:OnUpDataList(UISetFunc.keyIndex);
					Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
				end
				local canFuc = function ()
					UISystemBasic.tabButton[UISystemBasic.oldTabButton].selected = true;
				end
				UIConfirm:Open(StrConfig['setsys0100'],func,canFuc);
			else
				self.listStr = {};
				self:OnUpDataList(self.keyIndex);
				Notifier:sendNotification( NotifyConsts.SetSystemDisabled );
			end
		end
	end
end

UISetFunc.listStr = {};
function UISetFunc:OnUpDataList(e)
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.list.dataProvider:cleanUp();
	self.listStr = {};
	local cfg = SetSystemModel:GetFuncKey();
	for i , v in ipairs (SetSystemConsts.KeyFuncID) do
		local vo = {};
		vo.txt = t_funcOpen[v].name;
		if i == self.listIndex then
			UISystemBasic.setState = true;
			vo.dicText = SetSystemConsts.KeyConsts[e];
		else
			vo.dicText = cfg[v].str;
		end
		self.listStr[i] = {};
		self.listStr[i].id = cfg[v].id;
		self.listStr[i].str = vo.dicText;
		vo.index = i;
		objSwf.list.dataProvider:push(UIData.encode(vo));
	end
	objSwf.list:invalidateData();
	self:GetFuncListStr();
	objSwf.list:selectedState();
end

--清除掉相同字符
function UISetFunc:ClearKeyStr(str)
	SetSystemModel:OnClearKeyStr(str);
end

--获取到所有list的字符
function UISetFunc:GetFuncListStr()
	local cfg = {};
	for i , v in ipairs(self.listStr) do
		for j , k in pairs(SetSystemModel.copyModelFuncKey) do
			if v.id == k.id then
				k.str = v.str;
			end
		end
	end
end

function UISetFunc:OnHide()
	self.listIndex = 0;
end

function UISetFunc:OnIpSearchFocusOut()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.list:selectedState();
	objSwf.list.focused = false;
	
end

--消息处理
function UISetFunc:HandleNotification(name,body)
	if name == NotifyConsts.StageClick then
		self:OnIpSearchFocusOut();
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut();
	elseif name == NotifyConsts.SetSystemFuncChange then  --接到数据执行
		self:OnUpDataList();
	end
end

-- 消息监听
function UISetFunc:ListNotificationInterests()
	return {
			NotifyConsts.StageClick,
			NotifyConsts.StageFocusOut,
			NotifyConsts.SetSystemFuncChange
			}
end