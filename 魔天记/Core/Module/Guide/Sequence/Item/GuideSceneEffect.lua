GuideSceneEffect = class("GuideSceneEffect");

function GuideSceneEffect:ctor(path, file)
    self._effGameObject = Resourcer.Get(path, file);
    if (self._effGameObject) then
        NGUITools.SetLayer(self._effGameObject, Layer.Effect)
        self.transform = self._effGameObject.transform
    end
end

function GuideSceneEffect:SetPos(pt)
    if (self.transform) then
        MapTerrain.SampleTerrainPositionAndSetPos(self.transform, pt)
    end
end

function GuideSceneEffect:SetEnable(val)
    if (self._effGameObject) then
        self._effGameObject:SetActive(val);
    end
end

function GuideSceneEffect:Dispose()
    if (self._effGameObject) then
        Resourcer.Recycle(self._effGameObject, false);
    end
end
