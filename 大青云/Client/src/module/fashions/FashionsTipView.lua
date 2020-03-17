--[[角色面板时装按钮Tip界面
zhangshuhui
2015年5月15日11:42:20
]]

_G.UIFashionsTip = BaseUI:new("UIFashionsTip");

function UIFashionsTip:Create()
	self:AddSWF("fashionsTipPanel.swf", true, "top")
end

function UIFashionsTip:OnLoaded(objSwf)
end

--显示Tip
function UIFashionsTip:OnShow()
	self:ShowFashionsInfo();
	self:UpdatePos();
end

function UIFashionsTip:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local monsePos = _sys:getRelativeMouse();--获取鼠标位置
	self.posX = monsePos.x;
	self.posY = monsePos.y;
	objSwf._x = monsePos.x + 25;
	objSwf._y = monsePos.y - objSwf._height - 26;
end

--显示信息
function UIFashionsTip:ShowFashionsInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local nameinfo, datalist = FashionsUtil:GetCurFashionsTipInfo();
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(datalist));
	objSwf.list:invalidateData();
	
	--时装名称
	if nameinfo == "" then
		nameinfo = StrConfig["fashions5"];
		
		objSwf.attrpanel._y = 85;
		objSwf.bg._height = 200;
	else
		nameinfo = string.format(StrConfig["fashions4"], nameinfo);
		
		objSwf.attrpanel._y = 136;
		objSwf.bg._height = 250;
	end
	objSwf.tffashionsinfo.htmlText = nameinfo;
	
	--属性
	objSwf.attrpanel.tfgongji.text = "+0";
	objSwf.attrpanel.tffangyu.text = "+0";
	objSwf.attrpanel.tfhp.text = "+0";
	objSwf.attrpanel.tfbaoji.text = "+0";
	objSwf.attrpanel.tfshanbi.text = "+0";
	objSwf.attrpanel.tfmingzhong.text = "+0";
	
	local list = FashionsUtil:GetFashionsAttrList()
	
	for i,vo in ipairs(list) do
		if vo.type == enAttrType.eaGongJi then
			objSwf.attrpanel.tfgongji.text = "+"..vo.val
		elseif vo.type == enAttrType.eaFangYu then
			objSwf.attrpanel.tffangyu.text = "+"..vo.val
		elseif vo.type == enAttrType.eaMaxHp then
			objSwf.attrpanel.tfhp.text = "+"..vo.val
		elseif vo.type == enAttrType.eaBaoJi then
			objSwf.attrpanel.tfbaoji.text = "+"..vo.val
		elseif vo.type == enAttrType.eaShanBi then
			objSwf.attrpanel.tfshanbi.text = "+"..vo.val
		elseif vo.type == enAttrType.eaMingZhong then
			objSwf.attrpanel.tfmingzhong.text = "+"..vo.val
		end
	end
end

function UIFashionsTip:HandleNotification(name,body)
	if name == NotifyConsts.StageMove then
		local objSwf = self.objSwf;
		if not objSwf then return; end
		local monsePos = _sys:getRelativeMouse();--获取鼠标位置
		if self.posX ~= monsePos.x or self.posY ~= monsePos.y then
			self.posX = monsePos.x;
			self.posY = monsePos.y;
			objSwf._x = monsePos.x + 25;
			objSwf._y = monsePos.y - objSwf._height - 26;
			self:Top();
		end
	end
end

function UIFashionsTip:ListNotificationInterests()
	return {NotifyConsts.StageMove};
end