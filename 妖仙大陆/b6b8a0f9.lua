

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local Bag = require "Zeus.UI.XmasterBag.UIBagMain"
local ItemModel = require 'Zeus.Model.Item'

local _M = {}
_M.__index = _M
local dialogKey


local Text = {
	fullBagTitle = Util.GetText(TextConfig.Type.ITEM,'fullBagTitle'),
	fullBagTips = Util.GetText(TextConfig.Type.ITEM,'fullBagTips'),
	btnBuyGrid = Util.GetText(TextConfig.Type.ITEM,'btnBuyGrid'),
	btnCleanBag = Util.GetText(TextConfig.Type.ITEM,'btnCleanBag'),
	NumFormat1 = Util.GetText(TextConfig.Type.ITEM,'bagGridFmt1'),
    NumFormat2 = Util.GetText(TextConfig.Type.ITEM,'bagGridFmt2'),
    CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costDiamond'),
    GridNumTitle = Util.GetText(TextConfig.Type.ITEM,'buyNumTitle'),
}


local function OpenBag()
	MenuMgrU.Instance:CloseAllMenu()
	local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain,0)
	return obj
end

local function OpenBagGrid()
	if not GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIBagMain) then
    	MenuMgrU.Instance:CloseAllMenu()
    	local openBagParam = Bag.CreateTbtParam(0,GlobalHooks.UITAG.GameUIBagMain,nil)
    	GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain,0,openBagParam)
    end

    local rolebag = DataMgr.Instance.UserData.RoleBag
    local function num_input_cb(input_obj, result)
        if result then
            if rolebag.UnitDimond*result > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
                 local content = Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan")
                local ok = Util.GetText(TextConfig.Type.SHOP, "OK")
                local cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
                local title = Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu")
                GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, ok, cancel, title, nil,  
                function()
                    ItemModel.OpenGridRequest(rolebag.PackType, result)
                end, 
                function()
                end)
            else
                ItemModel.OpenGridRequest(rolebag.PackType, result)
            end
        end
    end

    local CostDiamond = Util.GetText(TextConfig.Type.ITEM,'costBindDiamond')
    local function num_change(input_obj, num)
        input_obj.tb_cost.XmlText = string.format(CostDiamond,num * rolebag.UnitDimond)
    end

    local max_open = rolebag.MaxLimitSize - rolebag.LimitSize
    local txts = {
        string.format(Text.NumFormat1,rolebag.LimitSize),
        string.format(Text.NumFormat2,max_open),
    }

    
    EventManager.Fire("Event.ShowNumInput", {
        min = 1,
        max = max_open,
        num = (max_open > 5 and 5) or max_open,
        cb = num_input_cb,
        title = Text.GridNumTitle,
        change_cb = num_change,
        txt = txts,
        exit_cb = function()
        end
    } )
end

local function OpenBagMelt()
    MenuMgrU.Instance:CloseAllMenu()
    local openBagParam = Bag.CreateTbtParam(0,GlobalHooks.UITAG.GameUIMelt,nil)
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIBagMain,0,openBagParam)	
end

local function OnShowFullBagTips(eventname, params)

	if dialogKey and GameAlertManager.Instance.AlertDialog:IsDialogExist(dialogKey) then
		return
	end
	local rg = DataMgr.Instance.UserData.RoleBag
	if rg.MaxLimitSize > rg.LimitSize then
		dialogKey = GameAlertManager.Instance.AlertDialog:ShowAlertDialogWithCloseBtn(
			AlertDialog.PRIORITY_NORMAL,
			Text.fullBagTips,
			Text.btnBuyGrid,
			Text.btnCleanBag,
			Text.fullBagTitle,
			nil,
			OpenBagGrid,
			OpenBagMelt
		)
	else
		dialogKey = GameAlertManager.Instance.AlertDialog:ShowAlertDialogWithCloseBtn(
			AlertDialog.PRIORITY_NORMAL,
			Text.fullBagTips,
			Text.btnCleanBag,
			Text.fullBagTitle,
			nil,
			OpenBag
		)
	end

end

local function initial()
	EventManager.Subscribe("Event.OnShowFullBagTips", OnShowFullBagTips)	
end

_M.initial = initial
return _M
