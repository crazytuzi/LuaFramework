require "Core.Module.Pattern.Proxy"

TrumpProxy = Proxy:New();
TrumpProxy._curFusionPanelSelectQc = -1
TrumpProxy._selectTrumpMaterials = { }   -- 法宝融合材料
TrumpProxy._selectTrump = nil
local insert = table.insert

function TrumpProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpRefineZoneChange, TrumpProxy._OnTrumpRefineZoneChangeCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpGet, TrumpProxy._OnTrumpGetCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ProductChange, TrumpProxy._OnProductChange);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpOnDress, TrumpProxy._OnTrumpOnDressCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpUnDress, TrumpProxy._OnTrumpUnDressCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpOnekKeyFunsion, TrumpProxy._OnTrumpOnekKeyFunsionCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpFunsion, TrumpProxy._OnTrumpFunsionCallBack);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TrumpRefine, TrumpProxy._OnTrumpRefineCallBack);


end

function TrumpProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpRefineZoneChange, TrumpProxy._OnTrumpRefineZoneChangeCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpGet, TrumpProxy._OnTrumpGetCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ProductChange, TrumpProxy._OnProductChange);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpOnDress, TrumpProxy._OnTrumpOnDressCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpUnDress, TrumpProxy._OnTrumpUnDressCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpOnekKeyFunsion, TrumpProxy._OnTrumpOnekKeyFunsionCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpFunsion, TrumpProxy._OnTrumpFunsionCallBack);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TrumpRefine, TrumpProxy._OnTrumpRefineCallBack);
end

-- 0 灵石炼宝,1 一键炼宝, 2 钻石炼宝
function TrumpProxy.SendGetTrumpByType(_t, _qc)
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpGet, { t = _t, qc = _qc })
end
 
function TrumpProxy._OnTrumpRefineZoneChangeCallBack(cmd, data)
    if (data and data.errCode == nil) then
        TrumpManager.SetNextQc(data.qc)
        TrumpManager.SetQcList(data.qcl)
        TrumpManager.SetCollectAreaData(data.l)
        ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL)
    end
end

function TrumpProxy._OnProductChange(cmd, data)
    if (data and data.errCode == nil) then
        if (data.m) then
            if (data.m[1] and data.m[1].st ~= ProductManager.ST_TYPE_IN_TRUMPBAG and data.m[1].st ~= ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
                return
            end
        end

        if (data.u) then
            if (data.u[1] and data.u[1].st ~= ProductManager.ST_TYPE_IN_TRUMPBAG and data.u[1].st ~= ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
                return
            end
        end

        if (data.a) then
            if (data.a[1] and data.a[1].st ~= ProductManager.ST_TYPE_IN_TRUMPBAG and data.a[1].st ~= ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG) then
                return
            end
        end

        if (data.a) then
            TrumpManager.AddTrump(data.a)
        end

        if (data.u) then
            TrumpProxy.ResetTrumpMaterials()
            TrumpManager.ChangeTrump(data.u)
        end

        if (data.m) then
            TrumpProxy.ResetTrumpMaterials()
            TrumpManager.MoveTrump(data.m)
        end
        PlayerManager.CalculatePlayerAttribute()

        ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL)
    end
end

function TrumpProxy.SendOneKeyCollect()
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpOneKeyCollect, { qc = TrumpManager.GetCollectQc() })
end 
 
function TrumpProxy._OnTrumpOnDressCallBack(cmd, data)
    if (data and data.errCode == nil) then
        TrumpManager.SetMainTrumpId(data.id)
        ModuleManager.SendNotification(TrumpNotes.CLOSE_TRUMPINFOPANEL)
        ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL)
        MessageManager.Dispatch(TrumpManager, TrumpManager.SelfTrumpFollow);
    end
end

function TrumpProxy._OnTrumpUnDressCallBack(cmd, data)
    if (data and data.errCode == nil) then
        TrumpManager.SetMainTrumpId(0)
        ModuleManager.SendNotification(TrumpNotes.CLOSE_TRUMPINFOPANEL)
        ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL)
        MessageManager.Dispatch(TrumpManager, TrumpManager.SelfTrumpFollow);
    end
end


function TrumpProxy.SendOneKeyFunsion()
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpOnekKeyFunsion, { })
end

function TrumpProxy.GetCurFusionPanelSelectQc()
    return TrumpProxy._curFusionPanelSelectQc
end

function TrumpProxy.SetCurFusionPanelSelectQc(qc)
    TrumpProxy._curFusionPanelSelectQc = qc
    TrumpProxy._selectTrumpMaterials = { }
    TrumpProxy._selectTrumpMaterials = TrumpManager.GetTrumpByQc(qc)
    ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL_SELECTMATERIAL)
end

function TrumpProxy.RemoveTrumpMaterial(data)
    for k, v in pairs(TrumpProxy._selectTrumpMaterials) do
        if v.info.id == data.info.id then
            TrumpProxy._selectTrumpMaterials[k] = nil
            break
        end
    end
end

function TrumpProxy.AddTrumpMaterial(data)
    insert(TrumpProxy._selectTrumpMaterials, data)
end

function TrumpProxy.ResetTrumpMaterials()
    TrumpProxy._selectTrumpMaterials = { }
    ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL_SELECTMATERIAL)
end

function TrumpProxy.GetTrumpMaterials()
    return TrumpProxy._selectTrumpMaterials
end
 
function TrumpProxy.SendOneKeyFunsion()
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpOnekKeyFunsion, { })
end

function TrumpProxy.SendFunsion()
    local ids = { }
    local flag = false
    if (TrumpProxy._selectTrump) then
        for k, v in ipairs(TrumpProxy._selectTrumpMaterials) do
            if (v.info.configData.quality > TrumpProxy._selectTrump.info.configData.quality) then
                flag = true
            end
            insert(ids, v.info.id)
        end
    else
        MsgUtils.ShowTips("trump/trumpProxy/fusionSelectNotice");
        return
    end

    if (flag) then
        ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
            title = LanguageMgr.Get("common/notice"),
            msg = LanguageMgr.Get("trump/trumpProxy/fusionNotice"),
            ok_Label = LanguageMgr.Get("common/ok"),
            cance_lLabel = LanguageMgr.Get("common/cancle"),
            hander = function() SocketClientLua.Get_ins():SendMessage(CmdType.TrumpFunsion, { id = TrumpProxy._selectTrump.info.id, ids = ids }) end
        } );
    else
        SocketClientLua.Get_ins():SendMessage(CmdType.TrumpFunsion, { id = TrumpProxy._selectTrump.info.id, ids = ids })
    end
end

function TrumpProxy.SendTrumpOnDress(_id)
    if (_id == nil) then _id = TrumpProxy._selectTrump.info.id end
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpOnDress, { id = _id })
end


function TrumpProxy.SendTrumpUnDress(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.TrumpUnDress, { })

end 

function TrumpProxy._OnTrumpGetCallBack(cmd, data)
    if (data and data.errCode ~= nil) then

    end
end

function TrumpProxy._OnTrumpOnekKeyFunsionCallBack(cmd, data)
    if (data and data.errCode == nil) then
        TrumpManager.SetTrumpBagData(data.trump_bag)
        ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL)
    end
end

function TrumpProxy.SetSelectTrumpData(data)
    if (data) then
        TrumpProxy._selectTrump = data
    end

    if (not TrumpProxy._selectTrump) then
        TrumpProxy._selectTrump = TrumpManager.GetFirstTrumpData()
    end

    ModuleManager.SendNotification(TrumpNotes.UPDATE_SUBTRUMPPANEL_DATA, TrumpProxy._selectTrump)
end

function TrumpProxy.ResetSelectTrump()
    TrumpProxy._selectTrump = nil
end

function TrumpProxy.MoveProduct(data)
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Move_Product, TrumpProxy._OnTrumpMoveCallBack);
    local _data = { }
    _data.id1 = data.id
    _data.pt1 = data.pt
    _data.st1 = data.st
    _data.pt2 = data.pt
    if (data.st == ProductManager.ST_TYPE_IN_TRUMPBAG) then
        local index = TrumpManager.GetTrumpEquipEmptyPos()
        if (index == -1) then
            log("没有位置可以装备了")
            return
        else
            log("装备位置" .. index)
            _data.idx = index
        end
        _data.st2 = ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG

    elseif data.st == ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG then
        _data.st2 = ProductManager.ST_TYPE_IN_TRUMPBAG
        local index = TrumpManager.GetTrumpBagEmptyPos()
        if (index == -1) then
            log("没有位置卸下装备了")
            return
        else
            log("卸下位置" .. index)
            _data.idx = index
        end
    end
    SocketClientLua.Get_ins():SendMessage(CmdType.Move_Product, _data)
end

function TrumpProxy._OnTrumpMoveCallBack(cmd, data)
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Move_Product, TrumpProxy._OnTrumpMoveCallBack);

    if (data and data.errCode == nil) then
        ModuleManager.SendNotification(TrumpNotes.CLOSE_TRUMPINFOPANEL)
    end
end

function TrumpProxy._OnTrumpFunsionCallBack(cmd, data)
    if (data and data.errCode == nil) then
        TrumpProxy.ResetTrumpMaterials()
        TrumpManager.SetTrumpBagData(data.trump_bag)
        TrumpProxy.SetSelectTrumpData(TrumpManager.GetTrumpEquipDataBySId(data.id))
        ModuleManager.SendNotification(TrumpNotes.UPDATE_TRUMPPANEL)
    end
end

function TrumpProxy.SendTrumpRefine()
    if (TrumpProxy._selectRefineTrump) then
        SocketClientLua.Get_ins():SendMessage(CmdType.TrumpRefine, { id = TrumpProxy._selectRefineTrump.info.id })
    else
        log("选择法宝")
    end
end

function TrumpProxy._OnTrumpRefineCallBack(cmd, data)
    if (data and data.errCode == nil) then

    end
end

function TrumpProxy.SetSelectRefineTrumpData(data)
    if (data) then
        TrumpProxy._selectRefineTrump = data
    end

    if (not TrumpProxy._selectRefineTrump) then
        TrumpProxy._selectRefineTrump = TrumpManager.GetFirstTrumpData()
    end

    ModuleManager.SendNotification(TrumpNotes.UPDATE_SUBTRUMPREFINEPANEL_DATA, TrumpProxy._selectRefineTrump)
end

function TrumpProxy.ResetSelectRefineTrump()
    TrumpProxy._selectRefineTrump = nil
end