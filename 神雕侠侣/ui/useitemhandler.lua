require "utils.log"
require "ui.workshop.workshoplabel"
require "ui.pet.petlabel"
UseItemHandler = {}

local function IsQhMaterial(itembaseid)
	if itembaseid == 38006 or itembaseid == 38007 or itembaseid == 38008 then
		return true
	end
	if itembaseid == 37172 or itembaseid == 37173 or itembaseid == 37174 then
		return true
	end
	return false
end

local function useMsItem()
	local curMapid = GetScene():GetMapInfo().id
	if curMapid ~= 1401 then
		local p = require "protocoldef.knight.gsp.faction.crequestbacktofaction":new()
		require "manager.luaprotocolmanager":send(p)
		UseItemHandler.useMsItemCo = coroutine.create(function()
			local NPCID = 12014
			local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(NPCID);
	    	if npcConfig.id == -1 then
	       	 	return false
	       	end
			GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, NPCID)
		end)
		return true
	else 
		UseItemHandler.useMsItemCo = nil
		local NPCID = 12014
		local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(NPCID);
    	if npcConfig.id == -1 then
       	 	return false
       	end
		GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, NPCID)
		return true
	end
	return false
end

function UseItemHandler.useFunctionItems(itemid)
  local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.citemusefunction")
  local ids = config:getDisorderAllID()
  for k,v in pairs(ids) do 
    if v == itemid then
      return config:getRecorder(v)
    end
  end
  
  return nil
end

function UseItemHandler.useItem(bagid, itemkey)
	LogInsane(string.format("bagid=%d, itemkey=%d", bagid, itemkey))
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if item == nil then
		return false
	end
	local itembaseid = item:GetBaseObject().id
	local firsttype = item:GetBaseObject().itemtypeid%16
	LogInsane("type"..item:GetBaseObject().itemtypeid.."first type="..firsttype)
	
	if itembaseid >= 37511 and itembaseid <= 37516 then
	  require "protocoldef.knight.gsp.marry.cringinfo"
    local p = CRingInfo.Create()
    require "manager.luaprotocolmanager":send(p)
	 return true
	end
	
	--special use function items
	local spItem = UseItemHandler.useFunctionItems(itembaseid)
	if spItem ~= nil then
	   if spItem.type == 0 then
	     GetGameUIManager():AddMessageTip(spItem.prompt);
	   end
	   if spItem.type == 1 then
	     local cmd = knight.gsp.task.CReqGoto(spItem.mapID, spItem.PosX, spItem.PosZ);
       GetNetConnection():send(cmd);
	   end
	   return true
	end
	
	if item:GetBaseObject().itemtypeid == 2198 then
		GetGameUIManager():AddMessageTipById(144920);
	end

	if firsttype == 5 then
        WorkshopLabel.Show(3)
		return true
	elseif item:GetBaseObject().itemtypeid%0x100 == 0x87 then
		local childtype = math.floor(item:GetBaseObject().itemtypeid/0x100)%0x10
		if childtype == 1 or childtype == 2 then
			require "ui.jewelry.ringmake":GetSingletonDialogAndShowIt()
			return true
		elseif childtype == 3 then
			local dlg = require "ui.jewelry.ringmake":GetSingletonDialogAndShowIt()
			dlg:setPaper(itembaseid)
			return true
		end
	elseif itembaseid == 35195 or itembaseid == 35196 or itembaseid == 35197 then
        WorkshopLabel.Show(2)
		return true
	elseif IsQhMaterial(itembaseid) then
		WorkshopLabel.Show(1)
		return true
	elseif itembaseid == 38005 then
		PetLabel.Show(3)
		return true
	elseif itembaseid == 50002 or itembaseid == 50015 then
		local NPCID = 10271
		local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(NPCID);
    	if npcConfig.id == -1 then
       	 	return false
       	end
    	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, NPCID)
    	return true
    elseif itembaseid == 38609 then
   		return useMsItem()
   	elseif itembaseid == 39846 then
   		require "ui.friendsdialog"
   		local dlg = FriendsDialog.getInstanceAndShow()
   		dlg:OpenEnemyView()
   	elseif itembaseid == 39844 then
   		require "ui.skill.qijingbamaidlg".getInstanceAndShow()
	elseif itembaseid == 50312 then
   		local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"
   		SDZhaJiLable.Show(1)
	end
	LogInsane("Not handlered")
	return false
end

return UseItemHandler
