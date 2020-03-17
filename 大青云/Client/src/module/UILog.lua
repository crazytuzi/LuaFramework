--[[
网页版log输出
lizhuangzhuang
2015年2月9日17:17:26 
]]

_G.UILog = BaseUI:new("UILog");

UILog.waitTxt = "";
UILog.state = 0;

function UILog:Create()
	self:AddSWF("logPanel.swf",true,"top");
end

function UILog:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide(); end
	objSwf.btnOpen.click = function() self:OnBtnOpenClick(); end
end

function UILog:GetWidth()
	if self.state == 0 then
		return 400;
	else
		return 800;
	end
end

function UILog:GetHeight()
	if self.state == 0 then
		return 300;
	else
		return 600;
	end
end

function UILog:AddLog(text)
	if UILog:IsShow() then
		self.objSwf.text:appendText(text .. "\n");
		self.objSwf.text.position = self.objSwf.text.maxscroll;
	else
		self.waitTxt = self.waitTxt .. text .. "\n";
		self:Show();
	end
end

function UILog:OnShow()
	self.objSwf.text:appendText(self.waitTxt);
	self.objSwf.text.position = self.objSwf.text.maxscroll;
	self.waitTxt = "";
end

function UILog:OnBtnOpenClick()
	local objSwf = self.objSwf;
	if self.state == 0 then
		self.state = 1;
		objSwf.text.width = 800;
		objSwf.text.height = 600;
	else
		self.state = 0;
		objSwf.text.width = 400;
		objSwf.text.height = 300;
	end
	self:AutoSetPos();
end

function UILog:OnHide()
	self.objSwf.text.text = "";
end

--遍历table  adder:houxudong date:2016/6/2 09:04:56
function UILog:print_table( lua_table,indent)
	if lua_table == nil then 
    	print("nil");
    return
  end
	indent = indent or 0
	for k, v in pairs(lua_table) do
		if type(k) == "string" then
			k = string.format("%q", k)
		end
		local szSuffix = ""
		if type(v) == "table" then
			szSuffix = "{"
		end
		local szPrefix = string.rep("    ", indent)
		if type(k) ~= 'userdata' then
			local formatting = szPrefix.."["..k.."]".." = "..szSuffix
			if type(v) == "table" then
				print(formatting)
				self:print_table(v, indent + 1)
				print(szPrefix.."},")
			else
				local szValue = ""
				if type(v) == "string" then
					szValue = string.format("%q", v)
				else
					szValue = tostring(v)
				end
				print(formatting..szValue..",")
			end
		end
	end
end