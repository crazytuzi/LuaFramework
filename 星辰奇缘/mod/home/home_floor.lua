-- 家园 地板
-- ljh 160705
HomeFloor = HomeFloor or BaseClass()

function HomeFloor:__init(model)
    self.model = model

    self.name = "HomeFloor"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:InitPanel()
end

function HomeFloor:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end

    if bool then
        self:update()
    else
        self.gameObject.transform.localPosition = Vector3(0, -200, 0)
    end
end

function HomeFloor:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HomeFloor:InitPanel()
    self.gameObject = GameObject()
    self.gameObject.name = "HomeFloor"
    self.gameObject.transform:SetParent(SceneManager.Instance.sceneElementsModel.scene_elements.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    BaseUtils.ChangeLayersRecursively(self.transform, "Model")
    -----------------------------

    -----------------------------
    -- self:update()
end

function HomeFloor:SetFloor()
    local floorData = self.model.floor_data
    -- BaseUtils.dump(floorData, "<color='#00ff00'>floorData</color>")
    if floorData == nil then return end
	local skin = floorData.skin
	local res = floorData.res
	local animation_id = 0
	local callback = function(tpose, animationData, poolData) self:TposeComplete(tpose, animationData, poolData) end
    HomeTposeLoader.New(skin, res, animation_id, 1, callback)
end

function HomeFloor:TposeComplete(tpose, animationData, poolData)
    if self.gameObject == nil then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        return
    end

    self.animationData = animationData

    if self.tpose == nil then
        self.tpose = tpose
    else
        GameObject.Destroy(self.tpose)
        -- if self.tpose ~= nil then
        --     self.tpose:SetActive(false)
        --     self.tpose.name = "Destroy_Tpose"
        --     GameObject.Destroy(self.tpose)
        -- end

        self.tpose = tpose
    end

    -- 存储用于对象池的使用的数据
    self.poolData = poolData

    self.tpose.name = "tpose"
    Utils.ChangeLayersRecursively(self.tpose.transform, "Model")
    self.tpose.transform:SetParent(self.gameObject.transform)
    self.tpose.transform.localPosition = Vector3.zero
    self.tpose.transform.localRotation = Quaternion.identity

    self:update()
end

function HomeFloor:update()
    if self.gameObject ~= nil then
        local home_data = DataFamily.data_home_data[self.model.home_lev]
        if home_data ~= nil then
            if home_data.map_id == 30012 then
            	self.gameObject.transform.localPosition = Vector3(6.33, 3.56, 49)
            elseif home_data.map_id == 30013 then
                self.gameObject.transform.localPosition = Vector3(8.85, 4.54, 49)
            end
        end
    end
    if self.tpose ~= nil then
        self.tpose.transform.localScale = Vector3(0.732, 0.732, 0.732)
        -- self.tpose.transform:Rotate(Vector3(270, 0, 0))
    end
end