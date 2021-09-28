require "Core.Module.Pattern.Proxy"

ProductGetProxy = Proxy:New();
function ProductGetProxy:OnRegister()

end

function ProductGetProxy:OnRemove()

end



ProductGetProxy.moduleCloseMsg = nil

function ProductGetProxy.GetItemInfo(id)
    local iteminfo = ProductGetProxy.GetPorductConfig(id).get_item
    if not iteminfo then return nil end
    iteminfo = string.trim(iteminfo)
    if string.len(iteminfo) == 0 then return nil end
    local iss = string.split(iteminfo, ',')
    for i,v in ipairs(iss) do
        iss[i] = string.split(v, '_')
    end
    return iss
end

function ProductGetProxy.GetActivityConfig(id)
    return ActivityDataManager.GetCfBy_id(id)
end

function ProductGetProxy.GetPorductConfig(id)
    return ProductManager.GetProductById(id)
end

-- 尝试显示 获取物品的界面
-- 显示道具获取面板, id 道具id(number), msg 关闭来源模块的消息号,用于关闭来源模块
function ProductGetProxy.TryShowGetUI(product_id,msg)
    

   ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,{id = tonumber(product_id), msg=msg });

end




