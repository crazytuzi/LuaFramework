
ZhenFaTip = {
	desc = {2877, 2878, 2879, 2880, 2881}
};

setmetatable(ZhenFaTip, Dialog);
ZhenFaTip.__index = ZhenFaTip;

local _instance;

function ZhenFaTip.getInstance()
	if _instance == nil then
		_instance = ZhenFaTip:new();
		_instance:OnCreate();
	end

	return _instance;
end

function ZhenFaTip.peekInstance()
	return _instance;
end

function ZhenFaTip.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function ZhenFaTip:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, ZhenFaTip);

	return zf;
end

function ZhenFaTip.GetLayoutFileName()
	return "zhenfatipsdlg.layout";
end

function ZhenFaTip:OnCreate()
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_pDest = CEGUI.Window.toRichEditbox(winMgr:getWindow("zhenfatipsdlg/richeditbox"));
	self.m_pName = winMgr:getWindow("zhenfatipsdlg/name");
end

function ZhenFaTip:SetZhenFa(zhenfaID, zhenfaLv, isBeiKezhi)
print("zhenfaid, lv, ", zhenfaID, zhenfaLv);
	local e = self.m_pDest;
	e:Clear();

	local zhenfas = std.vector_int_();
	knight.gsp.team.GetCZhenFaeffectTableInstance():getAllID(zhenfas);

	local zhenfainfo = nil;
	for i = 0, zhenfas:size() - 1 do
		local item = knight.gsp.team.GetCZhenFaeffectTableInstance():getRecorder(i+1);
		if item.zhenfaid == zhenfaID and item.zhenfaLv == zhenfaLv then
			zhenfainfo = item;
			break;
		end
	end

	if zhenfainfo ~= nil then
		if isBeiKezhi then
			for i = 1,  zhenfainfo.describeloss:size() do
				e:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(self.desc[i])));
				e:AppendParseText(CEGUI.String(zhenfainfo.describeloss[i - 1]));
				e:AppendBreak();
			end
		else
			for i = 1,  zhenfainfo.describe:size() do
				e:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(self.desc[i]))); 
				e:AppendParseText(CEGUI.String(zhenfainfo.describe[i - 1]));
				e:AppendBreak();
			end
		end
		local zhenfaname = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(zhenfainfo.zhenfaid);
		local name = zhenfaname.name.."("..tostring(zhenfaLv)..")";
		self.m_pName:setText(name);
	end
	e:AppendBreak();

	e:Refresh();
end
