require "ui.dialog"

YuanXiake = {
m_pElite,
m_pIcon, 
m_pLevel,
m_pMark,
m_pName,

m_pYuanDesc,

m_vLines = {}
}

setmetatable(YuanXiake, Dialog)
YuanXiake.__index = YuanXiake;

local _instance;
function YuanXiake.getInstance()
	if not _instance then
		_instance = YuanXiake:new();
		_instance:OnCreate();
	end

	return _instance;
end

function YuanXiake.peekInstance()
	return _instance;
end

function YuanXiake.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function YuanXiake.GetLayoutFileName()
	return "quackyuan.layout";
end

function YuanXiake:OnCreate()
	Dialog.OnCreate(self);
	
	local winMgr = CEGUI.WindowManager:getSingleton();
    
    self.m_pElite = winMgr:getWindow("quackyuan/topback/elite")
    if self.m_pElite then
        self.m_pElite:setVisible(false)
    else
        print("____error get quackyuan/topback/elite")
    end
	self.m_pIcon = winMgr:getWindow("quackyuan/topback/role");
	self.m_pLevel = winMgr:getWindow("quackyuan/topback/level");
	self.m_pMark = winMgr:getWindow("quackyuan/topback/mark");
	self.m_pName = winMgr:getWindow("quackyuan/topback/name");
	self.m_pFrame= winMgr:getWindow("quackyuan/topback");

	self.m_pYuanDesc = CEGUI.Window.toRichEditbox(winMgr:getWindow("quackyuan/topinfo/txt"));

	for i = 1, 6 do
		self.m_vLines[i] = winMgr:getWindow("quackyuan/info"..tostring(i-1));
	end
end

function YuanXiake:new()
	local yuan = {};
	yuan = Dialog:new();
	setmetatable(yuan, YuanXiake);

	return yuan;
end

function YuanXiake.SetAndShow(xiake)
	--check yuan information
	if xiake == nil then return; end
	if xiake.xiakeid == 0 then return; end

	local xiakeData = XiakeMng.ReadXiakeData(xiake.xiakeid);
	local yuan = YuanXiake.getInstance();
	yuan.m_pFrame:setProperty("Image", XiakeMng.eXiakeFrames[xiake.color]);
	yuan.m_pIcon:setProperty("Image", xiakeData.path);
    if yuan.m_pElite then
        yuan.m_pElite:setVisible(XiakeMng.IsElite(xiake.xiakekey))
    end
	yuan.m_pLevel:setText(GetDataManager():GetMainCharacterLevel());
	yuan.m_pName:setText(scene_util.GetPetNameColor(xiake.color)..xiakeData.xkxx.name);
	yuan.m_pYuanDesc:setReadOnly(true);
	yuan.m_pYuanDesc:Clear();
	yuan.m_pYuanDesc:AppendText(CEGUI.String(xiakeData.xkxx.shengping));
	yuan.m_pYuanDesc:Refresh();
	yuan.m_pMark:setProperty("Image", XiakeMng.eLvImages[xiake.starlv]);

	for i = 1, 6 do
		yuan.m_vLines[i]:setProperty("TextColours", "FFFFFFFF");
		if i <= xiakeData.xkxx.yuan:size() then
			local yData = knight.gsp.npc.GetCXiakeyuanTableInstance():getRecorder(xiakeData.xkxx.yuan[i - 1]);
			local bActive = false;
			if XiakeMng.m_vXiakes[xiake.xiakekey] ~= nil and XiakeMng.m_vXiakes[xiake.xiakekey].yuanids ~= nil then
				for k, v in pairs(xiake.yuanids) do
					if v == xiakeData.xkxx.yuan[i-1] then
						bActive = true;
					end
				end
			else
				XiakeMng.RequestXiakeDetail(xiake.xiakekey);
			end
			--ffffe600
			--ffa8a8a8
			if yData ~= nil and yData.id ~= 0 then
				local desc = yData.name .." : " .. yData.des;
				yuan.m_vLines[i]:setText(desc);
				if bActive then
					yuan.m_vLines[i]:setProperty("TextColours", "FFFFE600");
				else
					yuan.m_vLines[i]:setProperty("TextColours", "FF444444");
				end
			end
		else
			yuan.m_vLines[i]:setText("");
		end
	end
	yuan.m_pMainFrame:setVisible(true);
	yuan.m_pMainFrame:moveToFront();
end


return YuanXiake;

