require "ui.dialog"
require "utils.scene_common"
require "ui.xiake.xiake_manager"

local XiakePreviewDlg = {}
setmetatable(XiakePreviewDlg, Dialog)
XiakePreviewDlg.__index = XiakePreviewDlg

-- 每页显示多少个
local cellPerPage = 11

-- 三种清单对应侠客颜色
local tColorGroup = {}
tColorGroup[1] = {3,2,1}
tColorGroup[2] = {4,3,2}
tColorGroup[3] = {4,3}

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function XiakePreviewDlg.getInstance()
	LogInfo("XiakePreviewDlg getinstance")
	if not _instance then
		_instance = XiakePreviewDlg:new()
		_instance:OnCreate()
	end

	return _instance
end

function XiakePreviewDlg.getInstanceAndShow()
	print("enter instance show")
	if not _instance then
		_instance = XiakePreviewDlg:new()
		_instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
	end

	return _instance
end

function XiakePreviewDlg.getInstanceNotCreate()
	return _instance
end

function XiakePreviewDlg.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function XiakePreviewDlg.ToggleOpenClose()
	if not _instance then
		_instance = XiakePreviewDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function XiakePreviewDlg.GetLayoutFileName()
	return "quackfoundlist.layout"
end

function XiakePreviewDlg:OnCreate()
	LogInfo("enter XiakePreviewDlg oncreate")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr then return end

	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("quackfoundlist/back"))
	if self.m_pPane then
		self.m_pPane:EnableHorzScrollBar(true)
		self.m_pPane:subscribeEvent("NextPage", XiakePreviewDlg.HandleNextPage, self)
	end
end

------------------- private: -----------------------------------

function XiakePreviewDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, XiakePreviewDlg)

	return self
end

function XiakePreviewDlg:InitXiakeList(ColorId)

	if not ColorId then return end

	local tShowColor = tColorGroup[ColorId]
	if type(tShowColor) ~= 'table' then return end

	local tXiakeConfig = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakexin")
	if not tXiakeConfig then return end

	local tAllXiakeId = tXiakeConfig:getDisorderAllID()
	local tXiakeIdGroup = {}

	-- 将不同颜色侠客id放入不同table
	for _,nXiakeId in ipairs(tAllXiakeId) do
		local tXiake = tXiakeConfig:getRecorder(nXiakeId)
		if tXiake and tXiake.color and tXiake.rank and tXiake.rank > 0 then
			if not tXiakeIdGroup[tXiake.color] then
				tXiakeIdGroup[tXiake.color] = {}
			end
			table.insert(tXiakeIdGroup[tXiake.color], nXiakeId)
		end
	end

	self.m_tXiakeList = {}

	-- 按照指定颜色及排行顺序存储清单中的侠客id
	for _, color in ipairs(tShowColor) do
		table.sort(tXiakeIdGroup[color], function (a, b) return tXiakeConfig:getRecorder(a).rank > tXiakeConfig:getRecorder(b).rank end)
		for _, id in ipairs(tXiakeIdGroup[color]) do
			table.insert(self.m_tXiakeList, id)
		end
	end

	self.m_iMaxPage = math.ceil(#self.m_tXiakeList / cellPerPage)
	self.m_iCurPage = 1
	self.m_Loaded = {}
end

function XiakePreviewDlg:RefreshXiakeList()

	local tXiakeConfig = BeanConfigManager.getInstance():GetTableByName("knight.gsp.npc.cxiakexin")
	if not tXiakeConfig then return end

	local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr then return end

	-- 根据当前页计算此次应该加载那些侠客
	local startIndex = (self.m_iCurPage - 1) * cellPerPage + 1
	local endIndex = self.m_iCurPage * cellPerPage
	if endIndex > #self.m_tXiakeList then
		endIndex = #self.m_tXiakeList
	end

	for index = startIndex, endIndex do
		if not self.m_Loaded[index] then
			local nXiakeId = self.m_tXiakeList[index]
			if nXiakeId then
				local tXiake = tXiakeConfig:getRecorder(nXiakeId)
				if tXiake and tXiake.color and tXiake.name then
					local cellWnd = winMgr:loadWindowLayout("quackfoundlistcell.layout", tostring(index))
					if cellWnd and self.m_pPane then
						self.m_pPane:addChildWindow(cellWnd)
						self.m_Loaded[index] = true
						-- 设置位置
						local x = math.floor((index - 1) * cellWnd:getSize().x.offset)
						cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, 1)))
					end

					-- 边框
					local back = winMgr:getWindow(tostring(index).."quackfoundlistcell/back")
					local sBackImg = XiakeMng.eXiakeFrames[tXiake.color]
					if back and sBackImg then
						back:setProperty("Image", sBackImg)
					end

					-- 头像
					local icon = winMgr:getWindow(tostring(index).."quackfoundlistcell/icon")
					if icon then
						local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(nXiakeId)
						if monster and monster.modelID then
							local shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID)
							if shape and shape.headID then
								icon:setProperty("Image", GetIconManager():GetImagePathByID(shape.headID):c_str())
							end
						end
					end

					-- 名字
					local name = winMgr:getWindow(tostring(index).."quackfoundlistcell/name")
					if name then
						name:setText(tostring(scene_util.GetPetNameColor(tXiake.color))..tostring(tXiake.name))
					end
				end
			end
		end
	end
end

-- 翻页加载下一批
function XiakePreviewDlg:HandleNextPage(args)

	if not self.m_iMaxPage or not self.m_iCurPage or self.m_iCurPage >= self.m_iMaxPage then return end

	self.m_iCurPage = self.m_iCurPage + 1
	local BarPos = self.m_pPane:getHorzScrollbar():getScrollPosition()
	self.m_pPane:getHorzScrollbar():Stop()
	self:RefreshXiakeList()
	self.m_pPane:getHorzScrollbar():setScrollPosition(BarPos)
end

return XiakePreviewDlg