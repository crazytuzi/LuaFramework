require "ui.dialog"

SkillBookCell = {
m_strNamePrefix,
m_pItemIcon,
m_pItemName,
m_pData,
bSelect,
}

setmetatable(SkillBookCell, Dialog);
SkillBookCell.__index = SkillBookCell;

function SkillBookCell:OnCreate()
	Dialog.OnCreate(self, nil, self.m_strNamePrefix);
	local winMgr = CEGUI.WindowManager:getSingleton();

	local pfx = self.m_strNamePrefix;
	self.m_pItemIcon = CEGUI.Window.toItemCell(winMgr:getWindow(pfx.."quackskillbookcell/item"));
	self.m_pItemName = winMgr:getWindow(pfx.."quackskillbookcell/name");
	self.m_pBackImage= winMgr:getWindow(pfx.."quackskillbookcell/back");

	self.m_pItemName:setText("");

	self.m_pItemIcon:subscribeEvent("MouseClick", SkillBookCell.HandleBookSelect, self);
	self.m_pItemName:setMousePassThroughEnabled(true);
	self.m_pBackImage:subscribeEvent("MouseClick", SkillBookCell.HandleBookSelect, self);

	self.bSelect = false;
end

function SkillBookCell:HandleBookSelect(arg)
	if self.bSelect == true then
		if SkillBookXq.getInstance().m_iLastSelect == self then
			SkillBookXq.getInstance().m_iLastSelect = nil;
		end
		self.bSelect = false;
		self.m_pBackImage:setProperty("Image", SkillBookXq.eNormal);
		if SkillBookXq.m_iMode == SkillBookXq.eModeSelectBooks then
			SkillXkQh.getInstance().m_vBookItems[self.m_pData] = false;	
			SkillXkQh.getInstance():RefreshBooks();
		end
	else
		if string.len(self.m_pItemName:getText()) == 0 then
			return;
		end

		local bookWnd = SkillBookXq.getInstance();
		if SkillBookXq.m_iMode == SkillBookXq.eModeAdd or SkillBookXq.m_iMode == SkillBookXq.eModeChange then
			if bookWnd.m_iLastSelect ~= nil then
				bookWnd.m_iLastSelect.m_pBackImage:setProperty("Image", SkillBookXq.eNormal);
				bookWnd.m_iLastSelect.bSelect = false;
			end
			SkillBookXq.getInstance().m_iLastSelect = self;
		end

		if SkillBookXq.m_iMode == SkillBookXq.eModeSelectBooks then
			print("#########", self.m_pData);
			local iBookCount = 0;
			for k,v in pairs(SkillXkQh.getInstance().m_vBookItems) do
				if v == true then
					iBookCount = iBookCount + 1;
				end
			end

			if iBookCount >= 5 then return; end

			SkillXkQh.getInstance().m_vBookItems[self.m_pData] = true;
			print(SkillXkQh.getInstance().m_SkillInfo);
			SkillXkQh.getInstance():RefreshBooks();
		end
		self.bSelect = true;
		self.m_pBackImage:setProperty("Image", SkillBookXq.eSelect);
	end
end

function SkillBookCell:SetBookInfo(aBook)
	self.m_pMainFrame:setVisible(true);
	local itemd = GetRoleItemManager():FindItemByBagAndThisID(aBook, knight.gsp.item.BagTypes.BAG);
	local attr = itemd:GetBaseObject();
    
    --xiaolong added for item tips
    if attr and attr.id then
        local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(attr.id)
        if itembean and itembean.id ~= -1 then
            print("____SkillBookCell:SetBookInfo, itemid: " .. attr.id)
            self.m_pItemIcon:setID(itembean.id)
            self.m_pItemIcon:removeEvent("TableClick")
            self.m_pItemIcon:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
        end
    end

	local color = MHSD_UTILS.getColourStringByNumber(itemd:GetNameColour());
	self.m_pItemIcon:SetImage(GetIconManager():GetItemIconByID(attr.icon));
	self.m_pItemName:setProperty("TextColours", color);
	self.m_pItemName:setText(itemd:GetName());
	self.m_pData = aBook;
	self.bSelect = false;
	self.m_pBackImage:setProperty("Image", SkillBookXq.eNormal);
end

function SkillBookCell.GetLayoutFileName()
	return "quackskillbookcell.layout";
end

function SkillBookCell:new()
	local cell = {};
	cell = Dialog:new();
	setmetatable(cell, SkillBookCell);

	return cell;
end

function CreateBookCell(aStrPrefix)
	local ret = SkillBookCell:new();
	ret.m_strNamePrefix = aStrPrefix;
	ret:OnCreate();

	return ret;
end

SkillBookXq = {
m_iMode,
m_pBtnPrev,
m_pBtnNext,
m_pBtnOk,
m_pBtnCancel,

m_pTxtDesc,

m_pBookList,
m_vPBookCells,

m_iLastSelect,

eNormal = "set:MainControl9 image:shopcellnormal",
eSelect = "set:MainControl9 image:shopcellchoose",
eModeAdd = 1,
eModeChange = 2,
eModeSelectBooks = 3,
}

setmetatable(SkillBookXq, Dialog);
SkillBookXq.__index = SkillBookXq;

local _instance;
function SkillBookXq.peekInstance()
	return _instance;
end

function SkillBookXq.getInstance()
	if not _instance then
		_instance = SkillBookXq:new();
		_instance:OnCreate();
	end

	return _instance;
end

function SkillBookXq.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
	end
end

function SkillBookXq.GetLayoutFileName()
	return "quackskillbookadd.layout";
end

function SkillBookXq:newItem()
	local ret = {pIcon,pName,pGround,bSelect = false};
	return ret;
end

function SkillBookXq:OnCreate()
	Dialog.OnCreate(self);
	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_vBooks = std.vector_int_();
	self.m_iLastSelect = nil;

	self.m_vPBookCells = {};

	self.m_pBookList = CEGUI.Window.toScrollablePane(winMgr:getWindow("quackskillbookadd/main/scroll"));
--	for i = 1, 4 do
--		self.m_vItems[i] = self:newItem();
--		self.m_vItems[i].pIcon = CEGUI.Window.toItemCell(winMgr:getWindow("quackskillbookadd/main/item"..tostring(i - 1)));
--		self.m_vItems[i].pName = winMgr:getWindow("quackskillbookadd/main/name"..tostring(i - 1));
--		self.m_vItems[i].pName:setText("");
--		self.m_vItems[i].pGround = winMgr:getWindow("quackskillbookadd/main/book"..tostring(i - 1));
--		self.m_vItems[i].pGround:subscribeEvent("MouseClick", SkillBookXq.HandleBookSelect, self.m_vItems[i]);
--		self.m_vItems[i].pIcon:subscribeEvent("MouseClick", SkillBookXq.HandleBookSelect, self.m_vItems[i]);
--	end

	self.m_pTxtDesc = winMgr:getWindow("quackskillbookadd/txt");

--	self.m_pBtnPrev = winMgr:getWindow("quackskillbookadd/main/up");
--	self.m_pBtnNext = winMgr:getWindow("quackskillbookadd/main/down");

	self.m_pBtnOk = winMgr:getWindow("quackskillbookadd/ok");
	self.m_pBtnCancel = winMgr:getWindow("quackskillbookadd/cancel");

--	self.m_pBtnPrev:subscribeEvent("Clicked", SkillBookXq.HandlePrevPage, self);
--	self.m_pBtnNext:subscribeEvent("Clicked", SkillBookXq.HandleNextPage, self);

	self.m_pBtnOk:subscribeEvent("Clicked", SkillBookXq.HandleOkBtn, self);
	self.m_pBtnCancel:subscribeEvent("Clicked", SkillBookXq.HandleCancelBtn, self);
end

function SkillBookXq.cmp(a, b)
	if a ~= nil and b ~= nil then
		local aitemd = GetRoleItemManager():FindItemByBagAndThisID(a, knight.gsp.item.BagTypes.BAG);
		local aattr = aitemd:GetBaseObject();
		local bitemd = GetRoleItemManager():FindItemByBagAndThisID(b, knight.gsp.item.BagTypes.BAG);
		local battr = bitemd:GetBaseObject();
	--	print("---------book:" , aattr.level, battr.level);
		return aattr.level > battr.level;
	end
	return false;
end

function SkillBookXq:RefreshSkillBooks()
--sort skill book by level 
	local tmpBooks = {};
	for i = 0, self.m_vBooks:size() - 1 do
		tmpBooks[i + 1] = self.m_vBooks[i];
	end

	table.sort(tmpBooks, SkillBookXq.cmp);

	self.m_vBooks:clear();
	for i = 1, #tmpBooks do
		self.m_vBooks:push_back(tmpBooks[i]);
	end

	for i = 1, #self.m_vPBookCells do
		self.m_vPBookCells[i].m_pMainFrame:setVisible(false);
	end

	local cnt = 0;
	for i = 0, self.m_vBooks:size()-1 do
		if i+1 > #self.m_vPBookCells then
			self.m_vPBookCells[i+1] = CreateBookCell(tostring(i+1));
			self.m_vPBookCells[i+1]:SetBookInfo(self.m_vBooks[i]);
			self.m_pBookList:addChildWindow(self.m_vPBookCells[i+1].m_pMainFrame);
			XiakeMng.SetWndPos(self.m_vPBookCells[i+1].m_pMainFrame, 0, cnt*86 + 1);
		else
			self.m_vPBookCells[i+1]:SetBookInfo(self.m_vBooks[i]);
		end
		cnt = cnt + 1;
	end
end

function SkillBookXq:ModeAdd()
	SkillBookXq.m_iMode = SkillBookXq.eModeAdd;
	self.m_pTxtDesc:setText(MHSD_UTILS.get_resstring(2777));
	self.m_vBooks:clear();
	GetRoleItemManager():GetItemKeyListByType(self.m_vBooks, XiakeMng.eSkillBookType);

	self:RefreshSkillBooks();
end

function SkillBookXq:ModeChange()
	SkillBookXq.m_iMode = SkillBookXq.eModeChange;
	self.m_pTxtDesc:setText(MHSD_UTILS.get_resstring(2777));
	
	GetRoleItemManager():GetItemKeyListByType(self.m_vBooks, XiakeMng.eSkillBookType);
	self:RefreshSkillBooks();
end

function SkillBookXq:ModeSelectBooks()
	SkillBookXq.m_iMode = SkillBookXq.eModeSelectBooks;
	self.m_pTxtDesc:setText(MHSD_UTILS.get_resstring(2778));
	self.m_vBooks:clear();

	GetRoleItemManager():GetItemKeyListByType(self.m_vBooks, XiakeMng.eSkillBookType);
	self:RefreshSkillBooks();
end

function SkillBookXq:HandleOkBtn(arg)
	if SkillBookXq.m_iMode == SkillBookXq.eModeAdd then
		local key = MyXiake_xiake.getInstance().m_iSelectedXiakeKey;
		if key ~= nil and self.m_iLastSelect ~= nil then
			XiakeMng.RequestLearnSkill(key, self.m_iLastSelect.m_pData);
		end
	elseif SkillBookXq.m_iMode == SkillBookXq.eModeChange then
		local key = MyXiake_xiake.getInstance().m_iSelectedXiakeKey;
		if key ~= nil and self.m_iLastSelect and self.m_SkillInfo ~= nil and self.m_iLastSelect ~= nil then
			XiakeMng.RequestChangeSkill(key, self.m_SkillInfo.mK, self.m_iLastSelect.m_pData);
		end
	elseif SkillBookXq.m_iMode == SkillBookXq.eModeSelectBooks then
	end
	SkillBookXq.DestroyDialog();
end

function SkillBookXq:HandleCancelBtn(arg)
	SkillBookXq.DestroyDialog();
end

function SkillBookXq:new()
	local sb = {};
	sb = Dialog:new();
	setmetatable(sb, SkillBookXq);
	return sb;
end

