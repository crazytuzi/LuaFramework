-- 地图控制器 lua版
-- ljh 20160629
-- 只处理
MapController = MapController or BaseClass(BaseMonoBehaviour)

-- 地图控制器 lua版
function MapController:__init()
    self.OnPointerDown = function(eventData)
        self:__OnPointerDown(eventData)
    end

    self.OnPointerUp = function(eventData)
        self:__OnPointerUp(eventData)
    end
end

function MapController:__delete()

end

function MapController:__OnPointerDown(eventData)
    SceneManager.Instance.sceneElementsModel:onMapPointerDown()
end

function MapController:__OnPointerUp(eventData)
    SceneManager.Instance.sceneElementsModel:onMapPointerUp()
end