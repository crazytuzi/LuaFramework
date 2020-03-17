--[[
聊天表情
lizhuangzhuang
2014年9月24日14:17:05
]]

_G.UIChatFace = BaseUI:new("UIChatFace");

--回调
UIChatFace.callBack = nil;
--跟随按钮位置
UIChatFace.followBtn = nil;

UIChatFace.tabButton = {};
UIChatFace.currStat = "";

UIChatFace.PageNum = 20;

function UIChatFace:Create()
	self:AddSWF("chatFace.swf",true,"highTop");
end

function UIChatFace:NeverDeleteWhenHide()
	return true;
end

function UIChatFace:OnLoaded(objSwf,name)
	self.tabButton["normal"] = objSwf.btnNormal;
	self.tabButton["vip"] = objSwf.btnVip;
	objSwf.btnVip._visible = false
	for name,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(name); end
	end
	for i=1,UIChatFace.PageNum do
		local btn = objSwf['btn'..i];
		if btn then
			btn.click = function() self:OnBtnFaceClick(i); end
		end
	end
end

function UIChatFace:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

--
--@param callBack 回调选择的表情
--@param followBtn 跟随按钮位置
function UIChatFace:Open(callBack,followBtn)
	self.callBack = callBack;
	self.followBtn = followBtn;
	self:Show();
end

function UIChatFace:OnShow()
	self:DoSetPos();
	self:OnTabButtonClick("normal");
end

function UIChatFace:OnHide()
	self.followBtn = nil;
	self.callBack = nil;
end

function UIChatFace:OnTabButtonClick(name)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.tabButton[name] then return; end
	self.tabButton[name].selected = true;
	self.currStat = name;
	--
	local tf = nil;
	if name == "normal" then
		objSwf.tfVip._visible = false;
		objSwf.tfNormal._visible = true;
		tf = objSwf.tfNormal;
	else
		objSwf.tfVip._visible = true;
		objSwf.tfNormal._visible = false;
		tf = objSwf.tfVip;
	end
	if tf.htmlText ~= "" then
		local url = "";
		for i=1,UIChatFace.PageNum do
			local cfg = nil;
			if name == "normal" then
				cfg = ChatConsts.Face[i];
			else
				cfg = ChatConsts.Face[UIChatFace.PageNum+i];
			end
			local btn = objSwf['btn'..i];
			if btn and cfg then
				url = url .. cfg.url;
			end
		end
		tf.htmlText = url;
	end
end

--点击表情按钮
function UIChatFace:OnBtnFaceClick(i)
	if self.currStat == "vip" then
		if not VipController:VIPFace() then
			FloatManager:AddNormal(string.format("%sVIP可用",VipController:GetVipNameByIndex(111)));
			return;
		end
	end
	local cfg = nil;
	if self.currStat == "normal" then
		cfg = ChatConsts.Face[i];
	else
		cfg = ChatConsts.Face[UIChatFace.PageNum+i];
	end
	if not cfg then return; end
	if self.callBack then
		self.callBack(cfg.key);
	end
	self:Hide();
end

function UIChatFace:Update()
	if not self.bShowState then return; end
	self:DoSetPos();
end

function UIChatFace:DoSetPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.followBtn then return; end
	local pos = UIManager:PosLtoG(self.followBtn,5,0);
	if pos then
		objSwf._x = pos.x;
		objSwf._y = pos.y-self:GetHeight();
	end
end

function UIChatFace:HandleNotification(name,body)
	if not self.bShowState then return;end
	local objSwf = self:GetSWF("UIChatFace");
	if not objSwf then return;end
	if name == NotifyConsts.StageClick then
		local panelTarget = string.gsub(objSwf._target,"/",".");
		if string.find(body.target,panelTarget) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIChatFace:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end