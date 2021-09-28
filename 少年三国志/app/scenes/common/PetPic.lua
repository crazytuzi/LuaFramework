local JsonPic = require("app.scenes.common.JsonPic")
local PetPic = {}

local functionList = {getPic = G_Path.getPetPic,getPicConfig = G_Path.getPetPicConfig,dir="pet"}

function PetPic.createPetPic( resId, parentWidget, name, hasShadow )
    return JsonPic.createJsonPic( resId, parentWidget, name, hasShadow,functionList )
end

function PetPic.createPetButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable )
    return JsonPic.createJsonButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable,functionList )
end


function PetPic.createPetNode( resId, name, hasShadow)
    return JsonPic.createJsonNode( resId, name, hasShadow,functionList)
end

function PetPic.createBattlePetPic( resId, parentWidget, name, hasShadow )
    return JsonPic.createBattleJsonPic( resId, parentWidget, name, hasShadow,functionList )
end

function PetPic.createBattlePetButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable )
    return JsonPic.createBattleJsonButton( resId, parentWidget, name, layer, func, hasShadow, hasDisable,functionList )
end

--cutBottom为底部裁剪比例, 默认为0 , 表现不裁剪, 取值范围[0,1] ,比如0.2 表示裁剪底部20%
--wholeBody 默认为false, 如果为true,表示 只裁剪卡牌下面部分, 上面,左边,右边不裁剪
function PetPic.getHalfNode( resId, cutBottom, wholeBody)

    return JsonPic.getHalfNode( resId, cutBottom, wholeBody,functionList)
   
end

function PetPic.getPicPositionXY(resId)
	if resId then
		local config = decodeJsonFile(functionList.getPicConfig(resId))
		if config then
			return tonumber(config.x), tonumber(config.y)
		end
	end
end


return PetPic