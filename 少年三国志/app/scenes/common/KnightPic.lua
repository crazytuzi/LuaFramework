local JsonPic = require("app.scenes.common.JsonPic")
local KnightPic = {}

local functionList = {getPic = G_Path.getKnightPic,getPicConfig = G_Path.getKnightPicConfig,dir="knight"}

function KnightPic.createKnightPic( resId, parentWidget, name, hasShadow )
    return JsonPic.createJsonPic( resId, parentWidget, name, hasShadow,functionList )
end

function KnightPic.createKnightButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable )
    return JsonPic.createJsonButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable,functionList )
end


function KnightPic.createKnightNode( resId, name, hasShadow)
    return JsonPic.createJsonNode( resId, name, hasShadow,functionList)
end

function KnightPic.createBattleKnightPic( resId, parentWidget, name, hasShadow )
    return JsonPic.createBattleJsonPic( resId, parentWidget, name, hasShadow,functionList )
end

function KnightPic.createBattleKnightButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable )
    return JsonPic.createBattleJsonButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable,functionList )
end

--cutBottom为底部裁剪比例, 默认为0 , 表现不裁剪, 取值范围[0,1] ,比如0.2 表示裁剪底部20%
--wholeBody 默认为false, 如果为true,表示 只裁剪卡牌下面部分, 上面,左边,右边不裁剪
function KnightPic.getHalfNode( resId, cutBottom, wholeBody)

    return JsonPic.getHalfNode( resId, cutBottom, wholeBody,functionList)
   
end


return KnightPic