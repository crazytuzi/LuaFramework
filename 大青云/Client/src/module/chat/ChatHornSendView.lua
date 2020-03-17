--[[
聊天喇叭发送面板
lizhuangzhuang
2014年9月22日11:49:32
]]
_G.classlist['UIChatHornSend'] = 'UIChatHornSend'
_G.UIChatHornSend = BaseUI:new("UIChatHornSend");
UIChatHornSend.objName = 'UIChatHornSend'
--喇叭列表
UIChatHornSend.hornlist = nil;
--从背包中使用时的参数
UIChatHornSend.bag = -1;
UIChatHornSend.itemPos = -1;
UIChatHornSend.bagHornId = 0;
--当前选中的喇叭id
UIChatHornSend.currSelectId = 0;

function UIChatHornSend:Create()
	self:AddSWF("chatHornSend.swf",true,"center");
end

function UIChatHornSend:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnFace.click = function() self:OnBtnFaceClick(); end
	objSwf.btnEnter.click = function() self:OnBtnEnterClick(); end
	objSwf.input.restrict = ChatConsts.Restrict;
	objSwf.input.textChange = function() self:OnInputTextChange(); end
	objSwf.ddList.change = function(e) self:OnDDListClick(e); end
	objSwf.item.rollOver = function() self:OnItemRollOver(); end
	objSwf.item.rollOut = function() self:OnItemRollOut(); end
end

function UIChatHornSend:OnDelete()
	self.hornlist = nil;
end

function UIChatHornSend:GetWidth()
	return 397;
end

--打开喇叭
--从背包打开时选中相应喇叭
function UIChatHornSend:Open(bag,pos)
	self.bag = bag;
	self.itemPos = pos;
	self:Show();
end

function UIChatHornSend:OnShow()
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	if not self.hornlist then
		self:InitHornlist();
	end
	local bagVO = BagModel:GetBag(self.bag);
	if bagVO then
		local itemVO = bagVO:GetItemByPos(self.itemPos);
		if itemVO then
			self.bagHornId = itemVO:GetTid();
		end
	end
	for i,vo in ipairs(self.hornlist) do
		if vo.id == self.bagHornId then
			objSwf.ddList.selectedIndex = i-1;
			return;
		end
	end
	self.bagHornId = 0;
	objSwf.ddList.selectedIndex = 0; 
end

function UIChatHornSend:OnHide()
	self.bag = -1;
	self.itemPos = -1;
	self.bagHornId = 0;
	self.currSelectId = 0;
end

--初始化喇叭列表
function UIChatHornSend:InitHornlist()
	self.hornlist = {};
	for id,cfg in pairs(t_horn) do
		local vo = {};
		vo.id = cfg.id;
		local itemCfg = t_item[cfg.needItem];
		if itemCfg then
			vo.name = itemCfg.name;
		end
		table.push(self.hornlist,vo);
	end
	table.sort(self.hornlist,function(A,B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	objSwf.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(self.hornlist) do
		objSwf.ddList.dataProvider:push(vo.name);
	end
end


--选择列表
function UIChatHornSend:OnDDListClick(e)
	if self.hornlist[e.index+1] then
		self.currSelectId = self.hornlist[e.index+1].id;
		self:ShowHornInfo();
	end
end

--显示当前喇叭信息
function UIChatHornSend:ShowHornInfo()
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	local cfg = t_horn[self.currSelectId];
	if not cfg then return; end
	local itemCfg = t_item[cfg.needItem];
	if not itemCfg then return; end
	local name = "<font color='"..TipsConsts:GetItemQualityColor(itemCfg.quality).."'>"..itemCfg.name.."</font>";
	objSwf.labelInfo.htmlText = string.format(StrConfig['chat109'],name);
	objSwf.labelDes.htmlText = itemCfg.story;
	objSwf.cbAutoMoney.htmlLabel = string.format(StrConfig['chat110'],cfg.money);
	local slotVO = RewardSlotVO:new();
	slotVO.id = itemCfg.id;
	slotVO.count = 0;
	objSwf.item:setData(slotVO:GetUIData());
end

function UIChatHornSend:OnItemRollOver()
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	TipsManager:ShowItemTips(self.currSelectId);
end

function UIChatHornSend:OnItemRollOut()
	TipsManager:Hide();
end

--点击表情
function UIChatHornSend:OnBtnFaceClick()
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	UIChatFace:Open(function(text)
		objSwf.input:appendText(text);
		objSwf.input.focused = true;
	end,objSwf.btnFace);
end

--点击回车
function UIChatHornSend:OnBtnEnterClick()
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	local text = objSwf.input.text;
	if text == "" then 
		FloatManager:AddCenter(StrConfig["chat113"]);
		return; 
	end
	local result;
	if self.currSelectId == self.bagHornId then
		result = ChatController:SendHorn(text,self.currSelectId,objSwf.cbAutoMoney.selected,self.bag,self.itemPos);
	else
		result = ChatController:SendHorn(text,self.currSelectId,objSwf.cbAutoMoney.selected,-1,-1);
	end
	if result then
		objSwf.input.text = "";
		self:Hide();
	else
		objSwf.input.text = text;
	end
end

--输入改变
function UIChatHornSend:OnInputTextChange()
	local objSwf = self:GetSWF("UIChatHornSend");
	if not objSwf then return; end
	local text = objSwf.input.text;
	if text == "" then return; end
	local hasEnter = false;
	text,hasEnter = ChatUtil:FilterInput(text);
	text = ChatUtil:CheckInputLength(text,ChatConsts.HornMaxInputNum);
	if hasEnter or text:tail("\r") then
		if text:tail("\r") then
			local textLen = text:len();
			text = string.sub(text,1,textLen-1);
		end
		local result;
		if self.currSelectId == self.bagHornId then
			result = ChatController:SendHorn(text,self.currSelectId,objSwf.cbAutoMoney.selected,self.bag,self.itemPos);
		else
			result = ChatController:SendHorn(text,self.currSelectId,objSwf.cbAutoMoney.selected,-1,-1);
		end
		if result then
			objSwf.input.text = "";
			self:Hide();
		else
			objSwf.input.text = text;
		end
	else
		objSwf.input.text = text;
	end
end

function UIChatHornSend:OnBtnCloseClick()
	self:Hide();
end