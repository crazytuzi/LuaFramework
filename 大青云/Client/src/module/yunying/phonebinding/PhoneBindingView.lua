--[[
手机绑定
wangshuai
]]

_G.UIPhoneBindingView = BaseUI:new("UIPhoneBindingView");

function UIPhoneBindingView:Create()
	self:AddSWF("phoneBindingpanel.swf",true,nil)
end;

function UIPhoneBindingView:OnLoaded(objSwf)
	objSwf.btnEnter.click = function() self:OnEnterWeb()end;
	objSwf.itemlist.itemRollOver = function(e) self:OnItemOver(e)end;
	objSwf.itemlist.itemRollOut = function() TipsManager:Hide();end;
end;

function UIPhoneBindingView:OnShow()
	self:OnSetbtn();
	self:OnShowlist();
end

function UIPhoneBindingView:OnEnterWeb()
	Version:PhoingBindBrowse();
end
--  设置按钮
function UIPhoneBindingView:OnSetbtn()
	local objSwf = self.objSwf;
	local state = PhoneBindingModel:OnGetBindingState();
	if state then 
		objSwf.btnEnter.disabled = true;
	else
		objSwf.btnEnter.disabled = false;
	end;
end;

function UIPhoneBindingView:OnItemOver(e)
	local item  = e.item;
	if not item then return end;
	if not item.id then return end;
	TipsManager:ShowItemTips(item.id);
end;
function UIPhoneBindingView:OnShowlist()
	local objSwf = self.objSwf;
	local list = self:OnGetItemlist();
	local listvo = {};
	for i,info in pairs(list) do 
		local item = RewardSlotVO:new();
		item.id = info.id;
		item.count = info.num;
		table.push(listvo,item:GetUIData())
	end;

	objSwf.itemlist.dataProvider:cleanUp();
	objSwf.itemlist.dataProvider:push(unpack(listvo));
	objSwf.itemlist:invalidateData();
end;
function UIPhoneBindingView:OnGetItemlist()
	local cfg = t_consts[60].param;
	local list1 = split(cfg,"#");
	local listvo = {};
	for i,info in pairs(list1) do 
		local vo = {};
		local woc = split(info,",");
		vo.id = tonumber(woc[1]);
		vo.num = tonumber(woc[2]);
		table.push(listvo,vo)
	end;
	return listvo
end;