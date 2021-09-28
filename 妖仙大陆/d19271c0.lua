local Util = require "Zeus.Logic.Util"

local Model = {}

Model.StateOpQuit = 0
Model.StateOpCancel = 1
Model.StateOpLock = 2
Model.StateOpTransact = 3

function Model.requestInviteTransaction(playerId)
    local content = nil
    if DataMgr.Instance.UserData.Actor.CombatState then
        content = Util.GetText(TextConfig.Type.TRANSACTION, "noTransactionInBattle")
        GameAlertManager.Instance:ShowFloatingTips(content)
        return
    end
    Pomelo.TradeHandler.inviteRequest(playerId, function(ex, sjson)
        if not ex then
            content = Util.GetText(TextConfig.Type.TRANSACTION, "transactionRequestTip")
            GameAlertManager.Instance:ShowFloatingTips(content)
        end
    end)
end

function Model.requestSetDiamond(diamond)
    Pomelo.TradeHandler.addItemRequest(diamond, nil, function(ex, sjson)
    end, XmdsNetManage.PackExtData.New(false, true))
end
function Model.requestSetItem(itemId, num, index)
    local items = {{index = index, id = itemId, num = num}}
    Pomelo.TradeHandler.addItemRequest(nil, items, function(ex, sjson)
    end, XmdsNetManage.PackExtData.New(false, true))
end
function Model.requestRemoveItem(index)
    Pomelo.TradeHandler.removeItemRequest({index}, function(ex, sjson)
    end, XmdsNetManage.PackExtData.New(false, true))
end

function Model.requestOpCancel()
    Pomelo.TradeHandler.tradeOperateRequest(Model.StateOpCancel, nil, nil, function(ex, sjson)
    end, XmdsNetManage.PackExtData.New(false, true))
end

function Model.requestOpLock(diamond, items, cb)
    Pomelo.TradeHandler.tradeOperateRequest(Model.StateOpLock, diamond, items, function(ex, sjson)
        if not ex then
            cb()
        end
    end)
end

function Model.requestOpTransact(cb)
    Pomelo.TradeHandler.tradeOperateRequest(Model.StateOpTransact, nil, nil, function(ex, sjson)
        if not ex then
            cb()
        end
    end)
end


function Model.onTransactionBegin(ex, sjson)
    local data = sjson:ToData()

    
    local _, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITransaction, 0)
    if ui then
        ui:setEnemyPlayer(data.tradePlayer)
    end
end

function Model.onTransactionItemChange(ex, sjson)
    local data = sjson:ToData()

    
    EventManager.Fire("Event.Transaction.ItemChange", {
        diamond = data.data.diamond,
        grids = data.data.grids,
    })
end
function Model.onTransactionOp(ex, sjson)
    local data = sjson:ToData()

    
    EventManager.Fire("Event.Transaction.Operate", {
        operate = data.operate
    })
end

function Model.InitNetWork()
    Pomelo.TradeHandler.tradeBeginPush(Model.onTransactionBegin)
    Pomelo.TradeHandler.tradeItemChangePush(Model.onTransactionItemChange)
    Pomelo.TradeHandler.tradeOperatePush(Model.onTransactionOp)
end


return Model
