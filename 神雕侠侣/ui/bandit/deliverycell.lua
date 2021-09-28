DeliveyCell = {}
require "utils.mhsdutils"
require "protocoldef.knight.gsp.faction.cjoinbiaoche"
require "utils.stringbuilder"

setmetatable(DeliveyCell, Dialog)
DeliveyCell.__index = DeliveyCell
local prefix = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function DeliveyCell.CreateNewDlg(pParentDlg)
	LogInfo("enter DeliveyCell.CreateNewDlg")
	local newDlg = DeliveyCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function DeliveyCell.GetLayoutFileName()
    return "banditsmallitem.layout"
end

function DeliveyCell:OnCreate(pParentDlg)
	LogInfo("enter DeliveyCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pGoBtn = winMgr:getWindow(tostring(prefix) .. "banditallsmallitem/main/go")
	self.m_pGoBtn:setVisible(false)
	self.m_pAddBtn = CEGUI.toPushButton(winMgr:getWindow(tostring(prefix) .. "banditallsmallitem/main/go1"))
	self.m_pTypeName = winMgr:getWindow(tostring(prefix) .. "banditallsmallitem/name1")
	self.m_pPic = winMgr:getWindow(tostring(prefix) .. "banditallsmallitem/main/tubiao")
	self.m_pLeaderName = winMgr:getWindow(tostring(prefix) .. "banditallsmallitem/name2")
	self.m_pNumber = winMgr:getWindow(tostring(prefix) .. "banditallsmallitem/main/TXT1")
		
	self.m_pAddBtn:subscribeEvent("Clicked", DeliveyCell.HandleAddBtnClicked, self)

	LogInfo("exit DeliveyCell OnCreate")
end

------------------- public: -----------------------------------

function DeliveyCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, DeliveyCell)

    return self
end

function DeliveyCell:HandleAddBtnClicked(args)
	LogInfo("DeliveyCell handle add button clicked")

	local strBuilder = StringBuilder:new()
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cyunbiao", self.m_iType + 1)
	strBuilder:Set("parameter1", cfg.touru)	
	GetMessageManager():AddConfirmBox(eConfirmNormal,strBuilder:GetString(MHSD_UTILS.get_msgtipstring(145198 + self.m_iType)),DeliveyCell.HandleAddConfirm,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	strBuilder:delete()
end

function DeliveyCell:HandleAddConfirm()
	LogInfo("DeliveyCell handle add confirm")
    local join = CJoinBiaoChe.Create()
	join.biaochekey = self.m_iKey
    LuaProtocolManager.getInstance():send(join)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function DeliveyCell:InitBiaocheInfo(key, biaochetype, rolename, teamnum)
	self.m_iKey = key
	self.m_iType = biaochetype
	if biaochetype == 0 then
		self.m_pPic:setProperty("Image", "set:MainControl16 image:yibanbiaoche")
		self.m_pTypeName:setText(MHSD_UTILS.get_resstring(2908))
	elseif biaochetype == 1 then
		self.m_pPic:setProperty("Image", "set:MainControl16 image:zhenbaobiaoche")
		self.m_pTypeName:setText(MHSD_UTILS.get_resstring(2909))
	end
	self.m_pLeaderName:setText(rolename)
	self.m_pNumber:setText(tostring(teamnum) .. "/3")
end

return DeliveyCell
