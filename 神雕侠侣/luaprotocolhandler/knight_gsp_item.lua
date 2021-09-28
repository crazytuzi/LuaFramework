
local sqianghuaresult = require "protocoldef.knight.gsp.item.sqianghuaresult"
function sqianghuaresult:process()
	LogInsaneFormat("protocoldef.knight.gsp.item.sqianghuaresult")
	--local proto = KnightClient.toSQianghuaResult(p)
	local itemkey = self.itemkey
	local bagid = self.bagid
	local newitemid = self.newitemid
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey,bagid)
    if pItem:GetObject() == nil then
        return
	end
	pItem:SetObjectID(newitemid)
	
	local itemcell = GetRoleItemManager():GetItemCellByLoc(pItem:GetLocation())
	if itemcell then
		LogInsane("Update icon in bag")
		itemcell:SetImage(GetIconManager():GetItemIconByID(pItem:GetBaseObject().icon))
	end
	
	local dlg = require "ui.workshop.workshopqhnew".getInstanceOrNot()
	if dlg and not dlg.QhAll then
    	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(newitemid)
	    if attr.id ~= -1 then 
	        local parameters = std.vector_std__wstring_()
	        parameters:push_back(attr.name)
            if GetChatManager() then
                GetChatManager():AddTipsMsg(144765, 0, parameters)
            end
	    end
    end
    local label = require "ui.workshop.workshoplabel"
    if label then
        label:RefreshItemTips(pItem)
    end
    if CWaringlistDlg:GetSingleton() then
        local pWarning = CWaringlistDlg:GetSingleton():GetWarning(3)
        if pWarning then
           pWarning:RefreshState()
        end
    end
end

local szonebattleaward = require "protocoldef.knight.gsp.item.szonebattleaward"
function szonebattleaward:process()
    print("_____szonebattleaward:process")
    
	require "ui.battlerewarddlg"
    local batRewardDlg = BattleRewardDlg.getInstanceAndShow()
	if batRewardDlg then
	   batRewardDlg:RefreshInfo(self.roleexp, self.petexp, self.money, self.items)
	end
end

local sgetotherroleinfo = require "protocoldef.knight.gsp.item.sgetotherroleinfo" 
function sgetotherroleinfo:process()
	LogInsane("sgetotherroleinfo process")
	require "ui.characterinfo.characterpropertymini"
	CharacterPropertyMini.getInstanceAndShow():Init(self.roleid, self.rolename, self.shape, self.level, 
		self.school, self.totalscore, self.baginfo, self.tips, self.footlogoid)	
end

local ssendgetotherroleinfomsg = require "protocoldef.knight.gsp.item.ssendgetotherroloeinfomsg"
function ssendgetotherroleinfomsg:process()
	LogInsane("ssendgetotherroloeinfomsg process")
	require "ui.characterinfo.getroleinfomsg"
	GetRoleInfoMsg.AddMsg(self.roleid, self.rolename)		
end

local p = require "protocoldef.knight.gsp.item.sgemsmeltopendialog"
function p:process()
	require "ui.workshop.stonecombin"
	local dlg = StoneCombin.getInstance()
end

local p = require "protocoldef.knight.gsp.item.sgemsmelt"
function p:process()
	require "ui.workshop.stonecombin"
	local dlg = StoneCombin.getInstanceOrNot()
	if dlg then
		dlg:CombinResult(self.itemkey)
	end
end

local p = require "protocoldef.knight.gsp.item.sreqmultiexptime"
function p:process()
	require "ui.mapchose.mapchosedlg"
	require "ui.battleautodlg"
	local dlg = MapChoseDlg.GetSingleton();
	if dlg then
		dlg.UpdateMulExpInfo(self.doubleexpflag,self.doubleexpremaintime,self.tripleexpflag,self.tripleexpremaintime);
	end
    --print("____self.tripleexpflag: " .. self.tripleexpflag)
    --print("____self.tripleexpremaintime: " .. self.tripleexpremaintime)
    --CBattleAutoDlg.s_tripleexpflag = tonumber(self.tripleexpflag);
	--CBattleAutoDlg.s_tripleexpremaintime = tonumber(self.tripleexpremaintime);
	BattleAutoDlg.s_tripleexpflag = tonumber(self.tripleexpflag)
	BattleAutoDlg.s_tripleexpremaintime = tonumber(self.tripleexpremaintime)
end

local sdecomposepreview = require "protocoldef.knight.gsp.item.sdecomposepreview"
function sdecomposepreview:process()
	LogInsane("sdecomposepreview process")
	require "ui.jewelry.ringdecomposition"
	if RingDecomposition:getInstanceOrNot() then
		RingDecomposition:getInstance():FreshMaterial(self.result)	
	end
end

local sdecomposedecoration = require "protocoldef.knight.gsp.item.sdecomposedecoration"
function sdecomposedecoration:process()
	LogInsane("sdecomposedecoration process")
	require "ui.jewelry.ringdecomposition"
	if RingDecomposition:getInstanceOrNot() then
		RingDecomposition:getInstance():InitInfo()
	end
end

local p = require "protocoldef.knight.gsp.item.sforgedecoration"
function p:process()
	local dlg = require "ui.jewelry.ringmake":getInstance()
	if dlg then
		if self.decoration > 0 and self.decoration <= #dlg.previews then
			GetGameUIManager():AddUIEffect(dlg.previews[self.decoration].item, 
					require "utils.mhsdutils".get_effectpath(10400), false)
		end
	end
end

local p = require "protocoldef.knight.gsp.item.srefinedecoration"
function p:process()
	local pobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, self.itemkey)
	if pobj then
		pobj.props[self.prop+1].level = self.proplevel
	end
	local dlg = require "ui.jewelry.ringstrong":getInstanceOrNot()
	if dlg then
		 dlg:RefreshJewelryAttr(self.itemkey, self.prop+1)
	end
end

local pd = require "protocoldef.knight.gsp.item.sleijilogin"
function pd:process()
	if self.avail == 1  then
		local d = require "ui.loginreward.loginrewardentrancedlg".getInstanceAndShow()
		require "ui.loginreward.loginrewarddlg":getInstanceAndShow():process(self.days,self.awards)	
		d:process()
	end
end

local sreqpresentnew = require "protocoldef.knight.gsp.item.sreqpresentnew"
function sreqpresentnew:process()
	if self.presenttype == 1  and self.result == 1 then
		require ("ui.loginreward.loginrewardcell").DisableOKButton()
	end
end
local sopensuperweapondlg = require "protocoldef.knight.gsp.item.sopensuperweapondlg"
function sopensuperweapondlg:process()
	require("ui.shenbingliqidlg").getInstanceAndShow()
end
local sreqsuperweapon = require "protocoldef.knight.gsp.item.sreqsuperweapon"
function sreqsuperweapon:process()
    local itemkey = self.itemkey
	local newitemid = self.newitemid
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey,knight.gsp.item.BagTypes.EQUIP)
    if pItem:GetObject() == nil then
        return
	end
	pItem:SetObjectID(newitemid)
	
	local itemcell = GetRoleItemManager():GetItemCellByLoc(pItem:GetLocation())
	if itemcell then
		LogInsane("Update icon in bag")
		itemcell:SetImage(GetIconManager():GetItemIconByID(pItem:GetBaseObject().icon))
	end
	require("ui.shenbingliqidlg").playSucEffect()
end


local p = require "protocoldef.knight.gsp.item.sopenmeltitempannel"
function p:process()
	print("open RongLianDlg XXXX")
	local dlg = require "ui.ronglian.rongliandlg"
	dlg.getInstance()
end

local p = require "protocoldef.knight.gsp.item.smeltitem"
function p:process()
	print("SMELT back: ", self.itemid, " ", self.itemnum)
	require "ui.ronglian.rongliandlg"

	local dlg = RongLianDlg.getInstanceOrNot()
	if dlg then
		dlg:ShowMeltResult(self.itemid, self.itemnum)
	end
end

local p = require "protocoldef.knight.gsp.item.sopenvipdepot"
function p:process()
  require "ui.item.depot":GetSingletonDialogAndShowIt()
end

local p = require "protocoldef.knight.gsp.item.sbuydepotyuanbao"
local confirmtype
local confirmtype
local function confirmAddCapacity()
  if confirmtype then
    GetMessageManager():CloseConfirmBox(confirmtype, false)
    confirmtype = nil
  end
  local dlg = require "ui.item.depot":getInstanceOrNot()
  if not dlg then
    return
  end
  local p = require "protocoldef.knight.gsp.item.cbuydepotcapacity":new()
  require "manager.luaprotocolmanager":send(p)
end
function p:process()
  local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146135).msg
  local sb = require "utils.stringbuilder":new()
  sb:Set("parameter1", self.costyuanbao)
  local msg = sb:GetString(formatstr)
  sb:delete()
  
  confirmtype = require "utils.mhsdutils".addConfirmDialog(msg, confirmAddCapacity)
end

local p = require "protocoldef.knight.gsp.item.sresequipbless"
function p:process()
	print("protocoldef.knight.gsp.item.sresequipbless process")
    local dlg = require "ui.workshop.workshopzhufu":getInstanceNotCreate()
    if dlg then
    	dlg:OnBlessSuccess()
    end
end

local p = require "protocoldef.knight.gsp.item.supdatefootlogo"
function p:process()
  print("supdatefootlogo process "..tostring(self.targetroleid).." "..tostring(self.footlogoid))
  if GetScene() then
  	local character = GetScene():FindCharacterByID(self.targetroleid)
  	if character then
  		character:SetFootprint(self.footlogoid)
  	end
  end
end

local p = require "protocoldef.knight.gsp.item.sopenbless"
function p:process()
	print("protocoldef.knight.gsp.item.sopenbless process")
    require "ui.workshop.workshopzhufu":getInstanceAndShow()
end

local p = require "protocoldef.knight.gsp.item.sgemyuansuopendialog"
function p:process()
	print("protocoldef.knight.gsp.item.sgemyuansuopendialog process")
end

local p = require "protocoldef.knight.gsp.item.sgemyuansu"
function p:process()
	print("protocoldef.knight.gsp.item.sgemyuansu process")
	local YuanSuRongLianDlg = require "ui.team.yuansurongliandlg"
	YuanSuRongLianDlg.OnSGemYuanSu(self)
end


