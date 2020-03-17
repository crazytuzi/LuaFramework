--[[
每日杀戮属性:属性增加提示
haohu
2015年2月28日15:42:02
]]
_G.classlist['UIKillValueAttrAdd'] = 'UIKillValueAttrAdd'
UIKillValueAttrAdd = BaseUI:new("UIKillValueAttrAdd");
UIKillValueAttrAdd.objName = 'UIKillValueAttrAdd'
UIKillValueAttrAdd.allowShow = true;
UIKillValueAttrAdd.killValue = nil;
UIKillValueAttrAdd.numAttrTxt = 6;

function UIKillValueAttrAdd:Create()
	self:AddSWF("killValueConfirm.swf", true, "center");
end

function UIKillValueAttrAdd:OnLoaded( objSwf )
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	objSwf.cb.select        = function(e) self:OnCbSelect(e); end
	for i = 1, UIKillValueAttrAdd.numAttrTxt do
		local textField = objSwf['txtAttr'..i];
		if textField then
			textField.autoSize = "left";
		end
	end
end

function UIKillValueAttrAdd:OnShow()
	self:UpdateShow();
	self:PlayEffect(true);
end

function UIKillValueAttrAdd:OnHide()
	self:PlayEffect(false);
end

function UIKillValueAttrAdd:GetWidth()
	return 364;
end

function UIKillValueAttrAdd:GetHeight()
	return 262;
end

function UIKillValueAttrAdd:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local killValue = self.killValue;
	if not killValue then return end
	objSwf.numLoader.num = killValue;
	self:ShowAttrAdded( killValue );
end

function UIKillValueAttrAdd:ShowAttrAdded(killValue)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = KillValueUtils:GetCfg(killValue);
	if not cfg then return; end
	local attrStr = cfg.addition_props;
	local attrTab = AttrParseUtil:Parse(attrStr);
	local vo, attrName, attrValue, str, textField;
	local strFormat = "%s <font color='#29cc00'>+%s</font>";
	for i = 1, UIKillValueAttrAdd.numAttrTxt do
		vo = attrTab[i];
		textField = objSwf['txtAttr'..i];
		if textField then
			if vo then
				attrName = enAttrTypeName[ vo.type ];
				attrValue = vo.val;
				str = string.format( strFormat, attrName, attrValue );
			else
				str = "";
			end
			textField.htmlText = str;
		end
	end
end

function UIKillValueAttrAdd:PlayEffect(play)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if play then
		objSwf.effect:playEffect(0);
	else
		objSwf.effect:stopEffect();
	end
end
function UIKillValueAttrAdd:OnBtnConfirmClick()
	self:Hide();
end

function UIKillValueAttrAdd:OnCbSelect(e)
	self.allowShow = not e.selected;
end

function UIKillValueAttrAdd:Open(killValue)
	if not self.allowShow then return; end
	self.killValue = killValue;
	if not self:IsShow() then
		self:Show();
	else
		self:UpdateShow();
	end
end