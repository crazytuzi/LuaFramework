require "luascript/script/game/scene/scene/mainLandScene"
require "luascript/script/game/scene/scene/portScene"
require "luascript/script/game/scene/scene/worldScene"

sceneController={
    curIndex=1
}

--targetType：跳转的目标地块的类型，8表示跳转军团城市
function sceneController:changeSceneByIndex(index,coords,targetType)
    self.curIndex=index
    if index==1 then--郊外
       mainLandScene:setShow()
       portScene:setHide()
       worldScene:setHide()
    elseif index==0 then--主基地
       mainLandScene:setHide()
       portScene:setShow()
       worldScene:setHide()
    elseif index==2 then--世界
       mainLandScene:setHide()
       portScene:setHide()
       worldScene:setShow(coords,targetType)
    end
    G_setWholeSkin(G_isOpenWinterSkin)
end

function sceneController:getNextIndex()
    if self.curIndex>=3 then
        return 1
    else
        return self.curIndex+1
    end
end